.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/tls-handshake.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
Bắt tay TLS trong hạt nhân
==========================

Tổng quan
========

Bảo mật lớp vận chuyển (TLS) là Giao thức lớp trên (ULP) chạy
trên TCP. TLS cung cấp tính toàn vẹn và bảo mật dữ liệu đầu cuối trong
Ngoài việc xác thực ngang hàng.

Việc triển khai kTLS của kernel xử lý giao thức con bản ghi TLS, nhưng
không xử lý giao thức con bắt tay TLS được sử dụng để thiết lập
một phiên TLS. Người tiêu dùng hạt nhân có thể sử dụng API được mô tả ở đây để
yêu cầu thiết lập phiên TLS.

Có một số cách có thể để cung cấp dịch vụ bắt tay trong
hạt nhân. API được mô tả ở đây được thiết kế để ẩn các chi tiết đó
triển khai để người tiêu dùng TLS trong kernel không cần phải
biết cách bắt tay được thực hiện như thế nào.


Tác nhân bắt tay người dùng
====================

Theo văn bản này, không có triển khai bắt tay TLS nào trong
Hạt nhân Linux. Để cung cấp dịch vụ bắt tay, một tác nhân bắt tay
(thường là trong không gian người dùng) được bắt đầu trong mỗi không gian tên mạng nơi một
người tiêu dùng hạt nhân có thể yêu cầu bắt tay TLS. Đại lý bắt tay lắng nghe
đối với các sự kiện được gửi từ kernel cho biết yêu cầu bắt tay là
đang chờ đợi.

Một ổ cắm mở được chuyển đến tác nhân bắt tay thông qua hoạt động liên kết mạng,
để tạo một bộ mô tả ổ cắm trong bảng mô tả tệp của tác nhân.
Nếu quá trình bắt tay hoàn tất thành công, tác nhân bắt tay sẽ quảng bá
ổ cắm để sử dụng TLS ULP và đặt thông tin phiên bằng cách sử dụng
Tùy chọn ổ cắm SOL_TLS. Tác nhân bắt tay trả lại ổ cắm cho
kernel thông qua hoạt động liên kết mạng thứ hai.


Bắt tay hạt nhân API
====================

Người tiêu dùng TLS kernel bắt đầu bắt tay TLS phía máy khách khi mở
socket bằng cách gọi một trong các hàm tls_client_hello(). Đầu tiên, nó
điền vào cấu trúc chứa các tham số của yêu cầu:

.. code-block:: c

  struct tls_handshake_args {
        struct socket   *ta_sock;
        tls_done_func_t ta_done;
        void            *ta_data;
        const char      *ta_peername;
        unsigned int    ta_timeout_ms;
        key_serial_t    ta_keyring;
        key_serial_t    ta_my_cert;
        key_serial_t    ta_my_privkey;
        unsigned int    ta_num_peerids;
        key_serial_t    ta_my_peerids[5];
  };

Trường @ta_sock tham chiếu đến ổ cắm mở và được kết nối. Người tiêu dùng
phải giữ một tham chiếu trên ổ cắm để ngăn nó bị phá hủy
trong khi quá trình bắt tay đang diễn ra. Người tiêu dùng cũng phải có
đã khởi tạo một tệp cấu trúc trong tệp sock->.


@ta_done chứa hàm gọi lại được gọi khi bắt tay
đã hoàn thành. Giải thích thêm về chức năng này có trong phần "Bắt tay
Hoàn thành" bên dưới.

Người tiêu dùng có thể cung cấp tên máy chủ kết thúc NUL trong @ta_peername
trường được gửi như một phần của ClientHello. Nếu không có tên ngang hàng nào được cung cấp,
thay vào đó, tên máy chủ DNS được liên kết với địa chỉ IP của máy chủ sẽ được sử dụng.

Người tiêu dùng có thể điền vào trường @ta_timeout_ms để buộc cung cấp dịch vụ
tác nhân bắt tay sẽ thoát sau một vài mili giây. Điều này cho phép
socket phải được đóng hoàn toàn sau khi cả kernel và tác nhân bắt tay
đã đóng điểm cuối của họ.

Tài liệu xác thực như chứng chỉ x.509, chứng chỉ riêng
các khóa và các khóa chia sẻ trước được cung cấp cho tác nhân bắt tay trong các khóa
được người tiêu dùng khởi tạo trước khi bắt tay
yêu cầu. Người tiêu dùng có thể cung cấp một khóa riêng được liên kết với
khóa quy trình của tác nhân bắt tay trong trường @ta_keyring để ngăn chặn
quyền truy cập các khóa đó bởi các hệ thống con khác.

Để yêu cầu phiên TLS được xác thực x.509, người tiêu dùng điền vào
các trường @ta_my_cert và @ta_my_privkey có số sê-ri là
các khóa chứa chứng chỉ x.509 và khóa riêng cho chứng chỉ đó
giấy chứng nhận. Sau đó, nó gọi hàm này:

.. code-block:: c

  ret = tls_client_hello_x509(args, gfp_flags);

Hàm trả về 0 khi yêu cầu bắt tay đang được thực hiện. A
trả về bằng 0 đảm bảo hàm gọi lại @ta_done sẽ được gọi
cho ổ cắm này. Hàm trả về một lỗi âm nếu bắt tay
không thể bắt đầu được. Lỗi âm đảm bảo chức năng gọi lại
@ta_done sẽ không được gọi trên ổ cắm này.


Để bắt đầu bắt tay TLS phía máy khách bằng khóa chia sẻ trước, hãy sử dụng:

.. code-block:: c

  ret = tls_client_hello_psk(args, gfp_flags);

Tuy nhiên, trong trường hợp này, người tiêu dùng điền vào mảng @ta_my_peerids
với số sê-ri của các khóa chứa danh tính ngang hàng mà nó mong muốn
để cung cấp và trường @ta_num_peerids có số lượng mảng
các mục đã điền. Các trường khác điền như trên.


Để bắt đầu bắt tay TLS phía máy khách ẩn danh, hãy sử dụng:

.. code-block:: c

  ret = tls_client_hello_anon(args, gfp_flags);

Tác nhân bắt tay không trình bày thông tin nhận dạng ngang hàng cho điều khiển từ xa
trong kiểu bắt tay này. Chỉ xác thực máy chủ (tức là máy khách
xác minh danh tính của máy chủ) được thực hiện trong quá trình bắt tay. Như vậy
phiên đã thiết lập chỉ sử dụng mã hóa.


Người tiêu dùng là máy chủ trong kernel sử dụng:

.. code-block:: c

  ret = tls_server_hello_x509(args, gfp_flags);

hoặc

.. code-block:: c

  ret = tls_server_hello_psk(args, gfp_flags);

Cấu trúc đối số được điền như trên.


Nếu người tiêu dùng cần hủy yêu cầu bắt tay, chẳng hạn do ^C
hoặc sự kiện cấp thiết khác, người tiêu dùng có thể gọi:

.. code-block:: c

  bool tls_handshake_cancel(sock);

Hàm này trả về true nếu yêu cầu bắt tay liên quan đến
@sock đã bị hủy. Lệnh gọi lại hoàn thành bắt tay của người tiêu dùng
sẽ không được gọi. Nếu hàm này trả về sai thì người tiêu dùng
cuộc gọi lại hoàn thành đã được gọi.


Hoàn thành bắt tay
====================

Khi tác nhân bắt tay đã hoàn tất quá trình xử lý, nó sẽ thông báo cho
kernel để người tiêu dùng có thể sử dụng lại ổ cắm đó. Tại thời điểm này,
lệnh gọi lại hoàn thành bắt tay của người tiêu dùng, được cung cấp trong @ta_done
trường trong cấu trúc tls_handshake_args, được gọi.

Tóm tắt của chức năng này là:

.. code-block:: c

  typedef void	(*tls_done_func_t)(void *data, int status,
                                   key_serial_t peerid);

Người tiêu dùng cung cấp cookie trong trường @ta_data của
Cấu trúc tls_handshake_args được trả về trong tham số @data của
cuộc gọi lại này. Người tiêu dùng sử dụng cookie để khớp lệnh gọi lại với
thread đang chờ quá trình bắt tay hoàn tất.

Trạng thái bắt tay thành công được trả về thông qua @status
tham số:

+-------------+-------------------------------------------------------+
Ý nghĩa của ZZ0000ZZ |
+=============+========================================================================================
Phiên ZZ0001ZZ TLS được thiết lập thành công |
+-------------+-------------------------------------------------------+
ZZ0002ZZ Từ xa ngang hàng đã từ chối bắt tay hoặc |
Xác thực ZZ0003ZZ không thành công |
+-------------+-------------------------------------------------------+
ZZ0004ZZ Lỗi phân bổ tài nguyên tạm thời |
+-------------+-------------------------------------------------------+
ZZ0005ZZ Người tiêu dùng đã cung cấp đối số không hợp lệ |
+-------------+-------------------------------------------------------+
ZZ0006ZZ Thiếu tài liệu xác thực |
+-------------+-------------------------------------------------------+
ZZ0007ZZ Đã xảy ra lỗi không mong muốn |
+-------------+-------------------------------------------------------+

Tham số @peerid chứa số sê-ri của khóa chứa
danh tính của máy ngang hàng từ xa hoặc giá trị TLS_NO_PEERID nếu phiên không hoạt động
được xác thực.

Cách tốt nhất là đóng và phá hủy ổ cắm ngay lập tức nếu
bắt tay thất bại.


Những cân nhắc khác
--------------------

Trong khi quá trình bắt tay đang diễn ra, người sử dụng kernel phải thay đổi
chức năng gọi lại sk_data_ready của socket để bỏ qua tất cả dữ liệu đến.
Khi chức năng gọi lại hoàn thành bắt tay đã được gọi, bình thường
hoạt động nhận có thể được tiếp tục.

Sau khi phiên TLS được thiết lập, người tiêu dùng phải cung cấp bộ đệm
và sau đó kiểm tra thông báo điều khiển (CMSG) là một phần của mọi
sock_recvmsg tiếp theo(). Mỗi thông báo điều khiển cho biết liệu
dữ liệu tin nhắn đã nhận là dữ liệu bản ghi TLS hoặc siêu dữ liệu phiên.

Xem tls.rst để biết chi tiết về cách người tiêu dùng kTLS nhận ra thư đến
(được giải mã) dữ liệu ứng dụng, cảnh báo và gói bắt tay sau khi
ổ cắm đã được khuyến khích sử dụng TLS ULP.