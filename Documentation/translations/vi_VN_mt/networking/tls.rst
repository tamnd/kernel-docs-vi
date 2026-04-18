.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/tls.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _kernel_tls:

============
Hạt nhân TLS
============

Tổng quan
=========

Bảo mật lớp vận chuyển (TLS) là Giao thức lớp trên (ULP) chạy trên
TCP. TLS cung cấp tính toàn vẹn và bảo mật dữ liệu từ đầu đến cuối.

Giao diện người dùng
====================

Tạo kết nối TLS
-------------------------

Trước tiên, hãy tạo ổ cắm TCP mới và sau khi kết nối được thiết lập, hãy đặt
TLS ULP.

.. code-block:: c

  sock = socket(AF_INET, SOCK_STREAM, 0);
  connect(sock, addr, addrlen);
  setsockopt(sock, SOL_TCP, TCP_ULP, "tls", sizeof("tls"));

Đặt TLS ULP cho phép chúng tôi đặt/nhận các tùy chọn ổ cắm TLS. Hiện tại
chỉ mã hóa đối xứng được xử lý trong kernel.  Sau TLS
bắt tay hoàn tất, chúng ta đã có đầy đủ các thông số cần thiết để di chuyển
đường dẫn dữ liệu đến kernel. Có tùy chọn ổ cắm riêng để di chuyển
việc truyền và nhận vào kernel.

.. code-block:: c

  /* From linux/tls.h */
  struct tls_crypto_info {
          unsigned short version;
          unsigned short cipher_type;
  };

  struct tls12_crypto_info_aes_gcm_128 {
          struct tls_crypto_info info;
          unsigned char iv[TLS_CIPHER_AES_GCM_128_IV_SIZE];
          unsigned char key[TLS_CIPHER_AES_GCM_128_KEY_SIZE];
          unsigned char salt[TLS_CIPHER_AES_GCM_128_SALT_SIZE];
          unsigned char rec_seq[TLS_CIPHER_AES_GCM_128_REC_SEQ_SIZE];
  };


  struct tls12_crypto_info_aes_gcm_128 crypto_info;

  crypto_info.info.version = TLS_1_2_VERSION;
  crypto_info.info.cipher_type = TLS_CIPHER_AES_GCM_128;
  memcpy(crypto_info.iv, iv_write, TLS_CIPHER_AES_GCM_128_IV_SIZE);
  memcpy(crypto_info.rec_seq, seq_number_write,
					TLS_CIPHER_AES_GCM_128_REC_SEQ_SIZE);
  memcpy(crypto_info.key, cipher_key_write, TLS_CIPHER_AES_GCM_128_KEY_SIZE);
  memcpy(crypto_info.salt, implicit_iv_write, TLS_CIPHER_AES_GCM_128_SALT_SIZE);

  setsockopt(sock, SOL_TLS, TLS_TX, &crypto_info, sizeof(crypto_info));

Việc truyền và nhận được đặt riêng biệt, nhưng cách thiết lập giống nhau, sử dụng một trong hai
TLS_TX hoặc TLS_RX.

Gửi dữ liệu ứng dụng TLS
----------------------------

Sau khi cài đặt tùy chọn ổ cắm TLS_TX, tất cả dữ liệu ứng dụng được gửi qua này
socket được mã hóa bằng TLS và các tham số được cung cấp trong tùy chọn socket.
Ví dụ: chúng ta có thể gửi một bản ghi hello world được mã hóa như sau:

.. code-block:: c

  const char *msg = "hello world\n";
  send(sock, msg, strlen(msg));

dữ liệu send() được mã hóa trực tiếp từ bộ đệm không gian người dùng được cung cấp
tới bộ đệm gửi hạt nhân được mã hóa nếu có thể.

Lệnh gọi hệ thống sendfile sẽ gửi dữ liệu của tệp qua các bản ghi TLS ở mức tối đa
chiều dài (2^14).

.. code-block:: c

  file = open(filename, O_RDONLY);
  fstat(file, &stat);
  sendfile(sock, file, &offset, stat.st_size);

Bản ghi TLS được tạo và gửi sau mỗi lệnh gọi send(), trừ khi
MSG_MORE đã được thông qua.  MSG_MORE sẽ trì hoãn việc tạo bản ghi cho đến khi
MSG_MORE không được vượt qua hoặc đạt đến kích thước bản ghi tối đa.

Hạt nhân sẽ cần phân bổ bộ đệm cho dữ liệu được mã hóa.
Bộ đệm này được phân bổ tại thời điểm send() được gọi, sao cho
toàn bộ lệnh gọi send() sẽ trả về -ENOMEM (hoặc chờ chặn
cho bộ nhớ), nếu không quá trình mã hóa sẽ luôn thành công.  Nếu gửi() trả về
-ENOMEM và một số dữ liệu còn sót lại trên bộ đệm ổ cắm từ phiên bản trước
gọi bằng MSG_MORE, dữ liệu MSG_MORE được để lại trên bộ đệm ổ cắm.

Nhận dữ liệu ứng dụng TLS
------------------------------

Sau khi cài đặt tùy chọn ổ cắm TLS_RX, tất cả các cuộc gọi ổ cắm gia đình recv
được giải mã bằng các tham số TLS được cung cấp.  Phải có bản ghi TLS đầy đủ
được nhận trước khi việc giải mã có thể xảy ra.

.. code-block:: c

  char buffer[16384];
  recv(sock, buffer, 16384);

Dữ liệu nhận được sẽ được giải mã trực tiếp vào bộ đệm của người dùng nếu nó
đủ lớn và không có sự phân bổ bổ sung nào xảy ra.  Nếu không gian người dùng
bộ đệm quá nhỏ, dữ liệu sẽ được giải mã trong kernel và được sao chép vào
không gian người dùng.

ZZ0000ZZ được trả về nếu phiên bản TLS trong tin nhắn nhận được không
khớp với phiên bản được chuyển trong setsockopt.

ZZ0000ZZ được trả về nếu tin nhắn nhận được quá lớn.

ZZ0000ZZ được trả về nếu quá trình giải mã không thành công vì bất kỳ lý do nào khác.

Gửi tin nhắn điều khiển TLS
---------------------------

Ngoài dữ liệu ứng dụng, TLS còn có các thông báo điều khiển như cảnh báo
tin nhắn (loại bản ghi 21) và tin nhắn bắt tay (loại bản ghi 22), v.v.
Những tin nhắn này có thể được gửi qua ổ cắm bằng cách cung cấp loại bản ghi TLS
thông qua CMSG. Ví dụ: hàm sau gửi @data của byte @length
sử dụng bản ghi loại @record_type.

.. code-block:: c

  /* send TLS control message using record_type */
  static int klts_send_ctrl_message(int sock, unsigned char record_type,
                                    void *data, size_t length)
  {
        struct msghdr msg = {0};
        int cmsg_len = sizeof(record_type);
        struct cmsghdr *cmsg;
        char buf[CMSG_SPACE(cmsg_len)];
        struct iovec msg_iov;   /* Vector of data to send/receive into.  */

        msg.msg_control = buf;
        msg.msg_controllen = sizeof(buf);
        cmsg = CMSG_FIRSTHDR(&msg);
        cmsg->cmsg_level = SOL_TLS;
        cmsg->cmsg_type = TLS_SET_RECORD_TYPE;
        cmsg->cmsg_len = CMSG_LEN(cmsg_len);
        *CMSG_DATA(cmsg) = record_type;
        msg.msg_controllen = cmsg->cmsg_len;

        msg_iov.iov_base = data;
        msg_iov.iov_len = length;
        msg.msg_iov = &msg_iov;
        msg.msg_iovlen = 1;

        return sendmsg(sock, &msg, 0);
  }

Dữ liệu thông báo điều khiển phải được cung cấp ở dạng không được mã hóa và sẽ được
được mã hóa bởi kernel.

Nhận tin nhắn điều khiển TLS
------------------------------

Thông báo điều khiển TLS được truyền vào bộ đệm vùng người dùng, kèm theo thông báo
loại được truyền qua cmsg.  Nếu không có bộ đệm cmsg được cung cấp thì sẽ xảy ra lỗi
được trả về nếu nhận được thông báo điều khiển.  Thông điệp dữ liệu có thể
nhận được mà không có bộ đệm cmsg.

.. code-block:: c

  char buffer[16384];
  char cmsg[CMSG_SPACE(sizeof(unsigned char))];
  struct msghdr msg = {0};
  msg.msg_control = cmsg;
  msg.msg_controllen = sizeof(cmsg);

  struct iovec msg_iov;
  msg_iov.iov_base = buffer;
  msg_iov.iov_len = 16384;

  msg.msg_iov = &msg_iov;
  msg.msg_iovlen = 1;

  int ret = recvmsg(sock, &msg, 0 /* flags */);

  struct cmsghdr *cmsg = CMSG_FIRSTHDR(&msg);
  if (cmsg->cmsg_level == SOL_TLS &&
      cmsg->cmsg_type == TLS_GET_RECORD_TYPE) {
      int record_type = *((unsigned char *)CMSG_DATA(cmsg));
      // Do something with record_type, and control message data in
      // buffer.
      //
      // Note that record_type may be == to application data (23).
  } else {
      // Buffer contains application data.
  }

recv sẽ không bao giờ trả về dữ liệu từ các loại bản ghi TLS hỗn hợp.

Cập nhật chính của TLS 1.3
--------------------------

Trong TLS 1.3, tin nhắn bắt tay KeyUpdate báo hiệu rằng người gửi
cập nhật khóa TX của nó. Mọi tin nhắn được gửi sau KeyUpdate sẽ được
được mã hóa bằng khóa mới. Thư viện không gian người dùng có thể vượt qua cái mới
khóa vào kernel bằng các tùy chọn ổ cắm TLS_TX và TLS_RX, như đối với
các phím ban đầu. Không thể thay đổi phiên bản và mật mã TLS.

Để tránh cố gắng giải mã các bản ghi đến bằng cách sử dụng khóa sai,
quá trình giải mã sẽ bị tạm dừng khi nhận được tin nhắn KeyUpdate
kernel, cho đến khi khóa mới được cung cấp bằng ổ cắm TLS_RX
tùy chọn. Bất kỳ hoạt động đọc nào xảy ra sau khi KeyUpdate đã được đọc và
trước khi khóa mới được cung cấp sẽ bị lỗi với EKEYEXPIRED. cuộc thăm dò ý kiến() sẽ
không báo cáo bất kỳ sự kiện đọc nào từ ổ cắm cho đến khi khóa mới được
được cung cấp. Không có sự tạm dừng ở phía truyền.

Vùng người dùng phải đảm bảo rằng crypto_info được cung cấp đã được đặt
đúng cách. Đặc biệt, kernel sẽ không kiểm tra key/nonce
tái sử dụng.

Số lượng cập nhật khóa thành công và thất bại được theo dõi trong
ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ,
Thống kê ZZ0003ZZ. Thống kê ZZ0004ZZ
đếm các tin nhắn bắt tay KeyUpdate đã được nhận.

Tích hợp vào thư viện TLS không gian người dùng
-----------------------------------------------

Ở mức cao, kernel TLS ULP là sự thay thế cho record
lớp của thư viện TLS không gian người dùng.

Một bản vá cho OpenSSL để sử dụng ktls làm lớp bản ghi
ZZ0000ZZ.

ZZ0000ZZ
gọi gửi trực tiếp sau khi bắt tay bằng gnutls.
Vì nó không triển khai lớp bản ghi đầy đủ nên hãy kiểm soát
tin nhắn không được hỗ trợ.

Tối ưu hóa tùy chọn
----------------------

Có một số tối ưu hóa nhất định theo điều kiện cụ thể mà TLS ULP có thể thực hiện,
nếu được yêu cầu. Những tối ưu hóa đó không mang lại lợi ích chung
hoặc có thể ảnh hưởng đến tính chính xác, do đó họ yêu cầu chọn tham gia.
Tất cả các tùy chọn được đặt cho mỗi ổ cắm bằng setsockopt() và
trạng thái có thể được kiểm tra bằng cách sử dụng getsockopt() và qua ổ cắm diag (ZZ0000ZZ).

TLS_TX_ZEROCOPY_RO
~~~~~~~~~~~~~~~~~~

Chỉ dành cho giảm tải thiết bị. Cho phép dữ liệu sendfile() được truyền trực tiếp
vào NIC mà không tạo bản sao trong kernel. Điều này cho phép không sao chép thực sự
hành vi khi tính năng giảm tải thiết bị được bật.

Ứng dụng phải đảm bảo rằng dữ liệu không bị sửa đổi giữa
đã gửi và truyền tải hoàn tất. Nói cách khác, đây chủ yếu là
có thể áp dụng nếu dữ liệu được gửi trên ổ cắm qua sendfile() ở chế độ chỉ đọc.

Việc sửa đổi dữ liệu có thể dẫn đến các phiên bản khác nhau của dữ liệu đang được sử dụng
đối với lần truyền TCP ban đầu và các lần truyền lại TCP. Đến người nhận
điều này sẽ trông giống như các bản ghi TLS đã bị giả mạo và sẽ dẫn đến
trong các lỗi xác thực hồ sơ.

TLS_RX_EXPECT_NO_PAD
~~~~~~~~~~~~~~~~~~~~

Chỉ TLS 1.3. Yêu cầu người gửi không ghi chép hồ sơ. Điều này cho phép dữ liệu
được giải mã trực tiếp vào bộ đệm không gian người dùng với TLS 1.3.

Việc tối ưu hóa này chỉ an toàn khi được kích hoạt nếu đầu cuối từ xa đáng tin cậy,
mặt khác, nó là một vectơ tấn công nhằm tăng gấp đôi chi phí xử lý TLS.

Nếu bản ghi được giải mã hóa ra đã được đệm hoặc không phải là dữ liệu
record nó sẽ được giải mã lại vào bộ đệm kernel mà không có bản sao nào.
Những sự kiện như vậy được tính trong thống kê ZZ0000ZZ.

TLS_TX_MAX_PAYLOAD_LEN
~~~~~~~~~~~~~~~~~~~~~~

Chỉ định kích thước tối đa của tải trọng văn bản gốc cho các bản ghi TLS được truyền đi.

Khi tùy chọn này được thiết lập, kernel sẽ thực thi giới hạn đã chỉ định trên tất cả các dữ liệu gửi đi.
Bản ghi TLS. Không có đoạn văn bản rõ nào vượt quá kích thước này. Tùy chọn này có thể được sử dụng
để triển khai tiện ích mở rộng Giới hạn kích thước bản ghi TLS [1].

* Đối với TLS 1.2, giá trị tương ứng trực tiếp với giới hạn kích thước bản ghi.
* Đối với TLS 1.3, giá trị phải được đặt thành record_size_limit - 1, vì
  giới hạn kích thước bản ghi bao gồm một byte bổ sung cho ContentType
  lĩnh vực.

Phạm vi hợp lệ cho tùy chọn này là 64 đến 16384 byte cho TLS 1.2 và 63 đến
16384 byte cho TLS 1.3. Mức tối thiểu thấp hơn cho TLS 1.3 chiếm
byte bổ sung được sử dụng bởi trường ContentType.

[1] ZZ0000ZZ

Thống kê
==========

Việc triển khai TLS hiển thị số liệu thống kê cho mỗi không gian tên sau đây
(ZZ0000ZZ):

- ZZ0000ZZ, ZZ0001ZZ -
  số phiên TX và RX hiện được cài đặt ở nơi máy chủ xử lý
  mật mã

- ZZ0000ZZ, ZZ0001ZZ -
  số phiên TX và RX hiện được cài đặt nơi NIC xử lý
  mật mã

- ZZ0000ZZ, ZZ0001ZZ -
  số phiên TX và RX được mở bằng mật mã máy chủ

- ZZ0000ZZ, ZZ0001ZZ -
  số phiên TX và RX được mở bằng mật mã NIC

- ZZ0000ZZ -
  giải mã bản ghi không thành công (ví dụ: do thẻ xác thực không chính xác)

- ZZ0000ZZ -
  số lần đồng bộ lại RX được gửi tới các NIC xử lý mật mã

- ZZ0000ZZ -
  số lượng bản ghi RX phải được giải mã lại do
  Dự đoán sai ZZ0001ZZ. Lưu ý rằng bộ đếm này sẽ
  cũng tăng đối với các bản ghi phi dữ liệu.

- ZZ0000ZZ -
  số lượng bản ghi dữ liệu RX phải được giải mã lại do
  Dự đoán sai ZZ0001ZZ.

- ZZ0000ZZ, ZZ0001ZZ -
  số lượng khóa lại thành công trên các phiên hiện có cho TX và RX

- ZZ0000ZZ, ZZ0001ZZ -
  số lượng khóa lại không thành công trên các phiên hiện có cho TX và RX

- ZZ0000ZZ -
  số lượng tin nhắn bắt tay KeyUpdate đã nhận, yêu cầu không gian người dùng
  để cung cấp khóa RX mới
