.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/nfs/rpc-cache.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========
Bộ đệm RPC
==========

Tài liệu này giới thiệu ngắn gọn về bộ nhớ đệm
các cơ chế trong lớp sunrpc được sử dụng, đặc biệt,
để xác thực NFS.

Bộ nhớ đệm
======

Bộ nhớ đệm thay thế bảng xuất cũ và cho phép
nhiều giá trị khác nhau để làm bộ nhớ đệm.

Tuy nhiên, có một số bộ đệm có cấu trúc tương tự nhau
hoàn toàn có thể rất khác nhau về nội dung và cách sử dụng.  Có một kho văn bản
mã chung để quản lý các bộ đệm này.

Ví dụ về bộ nhớ đệm có thể cần thiết là:

- ánh xạ từ địa chỉ IP đến tên khách hàng
  - ánh xạ từ tên khách hàng và hệ thống tập tin đến các tùy chọn xuất
  - ánh xạ từ UID tới danh sách GID, để khắc phục giới hạn của NFS
    trong số 16 gids.
  - ánh xạ giữa UID/GID cục bộ và UID/GID từ xa cho các trang web
    không có sự phân công uid thống nhất
  - ánh xạ từ nhận dạng mạng tới khóa chung để xác thực mật mã.

Mã chung xử lý những việc như:

- tra cứu bộ đệm chung với khóa chính xác
   - hỗ trợ 'NEGATIVE' cũng như các mục tích cực
   - cho phép thời gian EXPIRED trên các mục bộ đệm và xóa
     các mặt hàng đã hết hạn sử dụng và không còn được sử dụng nữa.
   - đưa ra yêu cầu tới không gian người dùng để điền vào các mục trong bộ đệm
   - cho phép không gian người dùng đặt trực tiếp các mục trong bộ đệm
   - trì hoãn các yêu cầu RPC phụ thuộc vào việc chưa hoàn thành
     các mục trong bộ đệm và phát lại các yêu cầu đó khi mục bộ đệm
     đã hoàn tất.
   - dọn sạch các mục cũ khi chúng hết hạn.

Tạo bộ đệm
----------------

- Một bộ nhớ đệm cần có một mốc thời gian để lưu trữ.  Đây là hình thức của một
   định nghĩa cấu trúc phải chứa cấu trúc cache_head
   như một phần tử, thường là phần tử đầu tiên.
   Nó cũng sẽ chứa một chìa khóa và một số nội dung.
   Mỗi phần tử bộ đệm được tính tham chiếu và chứa
   thời gian hết hạn và cập nhật để sử dụng trong quản lý bộ đệm.
- Bộ đệm cần có cấu trúc "cache_detail"
   mô tả bộ đệm.  Điều này lưu trữ bảng băm, một số
   các tham số để quản lý bộ đệm và một số thao tác chi tiết về cách
   để làm việc với các mục bộ đệm cụ thể.

Các hoạt động là:

struct cache_head \*alloc(void)
      Điều này chỉ đơn giản là phân bổ bộ nhớ thích hợp và trả về
      một con trỏ tới cache_detail được nhúng trong
      cấu trúc

void cache_put(struct kref \*)
      Điều này được gọi khi tham chiếu cuối cùng đến một mục
      bị rơi.  Con trỏ được chuyển đến trường 'ref'
      trong cache_head.  cache_put sẽ giải phóng bất kỳ
      tài liệu tham khảo được tạo bởi 'cache_init' và, nếu CACHE_VALID
      được đặt, mọi tham chiếu được tạo bởi cache_update.
      Sau đó nó sẽ giải phóng bộ nhớ được phân bổ bởi
      'phân bổ'.

int match(struct cache_head \*orig, struct cache_head \*new)
      kiểm tra xem các phím trong hai cấu trúc có khớp nhau không.  Trở lại
      1 nếu có, 0 nếu không.

void init(struct cache_head \*orig, struct cache_head \*new)
      Đặt các trường 'khóa' thành 'mới' từ 'orig'.  Điều này có thể
      bao gồm việc tham chiếu đến các đối tượng được chia sẻ.

cập nhật void(struct cache_head \*orig, struct cache_head \*new)
      Đặt các trường 'nội dung' thành 'mới' từ 'orig'.

int cache_show(struct seq_file \*m, struct cache_detail \*cd, struct cache_head \*h)
      Tùy chọn.  Được sử dụng để cung cấp tệp /proc liệt kê các
      nội dung của một bộ đệm.  Điều này sẽ hiển thị một mục,
      thường chỉ trên một dòng.

int cache_request(struct cache_detail \*cd, struct cache_head \*h, char \*\*bpp, int \*blen)
      Định dạng yêu cầu gửi đến không gian người dùng cho một mục
      để được khởi tạo.  \*bpp is a buffer of size \*blen.
      bpp nên được chuyển tiếp qua tin nhắn được mã hóa,
      và \*blen nên được giảm xuống để hiển thị mức độ miễn phí
      không gian còn lại.  Trả về 0 nếu thành công hoặc <0 nếu không
      đủ chỗ hoặc vấn đề khác.

int cache_parse(struct cache_detail \*cd, char \*buf, int len)
      Một tin nhắn từ không gian người dùng đã đến để điền vào
      mục bộ nhớ đệm.  Nó nằm trong 'buf' có độ dài 'len'.
      cache_parse sẽ phân tích cú pháp này, tìm mục trong
      bộ đệm với sunrpc_cache_lookup_rcu và cập nhật mục
      với sunrpc_cache_update.


- Bộ đệm cần được đăng ký bằng cache_register().  Cái này
   đưa nó vào danh sách các bộ nhớ đệm sẽ được cập nhật thường xuyên
   được làm sạch để loại bỏ dữ liệu cũ.

Sử dụng bộ đệm
-------------

Để tìm giá trị trong bộ đệm, hãy gọi sunrpc_cache_lookup_rcu truyền con trỏ
tới cache_head trong một mục mẫu có điền các trường 'key'.
Điều này sẽ được chuyển đến ->match để xác định mục tiêu.  Nếu không
mục nhập được tìm thấy, mục nhập mới sẽ được tạo, thêm vào bộ đệm và
được đánh dấu là không chứa dữ liệu hợp lệ.

Mục được trả về thường được chuyển tới cache_check để kiểm tra
nếu dữ liệu hợp lệ và có thể bắt đầu cuộc gọi để nhận dữ liệu mới.
cache_check sẽ trả về -ENOENT trong mục nhập là âm hoặc nếu tăng
cần gọi nhưng không thể thực hiện được, -EAGAIN nếu cuộc gọi nâng cấp đang chờ xử lý,
hoặc 0 nếu dữ liệu hợp lệ;

cache_check có thể được chuyển qua "struct cache_req\*".  Cấu trúc này là
thường được nhúng trong yêu cầu thực tế và có thể được sử dụng để tạo
bản sao trì hoãn của yêu cầu (struct cache_deferred_req).  Đây là
được thực hiện khi mục bộ đệm được tìm thấy không được cập nhật, nhưng đó là lý do để
tin rằng không gian người dùng có thể sớm cung cấp thông tin.  Khi bộ đệm
mục này trở nên hợp lệ, bản sao hoãn lại của yêu cầu sẽ được
xem lại (-> xem lại).  Dự kiến phương pháp này sẽ
sắp xếp lại yêu cầu để xử lý.

Giá trị được trả về bởi sunrpc_cache_lookup_rcu cũng có thể được chuyển tới
sunrpc_cache_update để đặt nội dung cho mục.  Mục thứ hai là
được thông qua sẽ giữ nội dung.  Nếu mục được tìm thấy bởi _lookup
có dữ liệu hợp lệ thì nó sẽ bị loại bỏ và một mục mới sẽ được tạo.  Cái này
giúp bất kỳ người dùng nào của một mục không phải lo lắng về việc nội dung thay đổi trong khi
nó đang được kiểm tra.  Nếu mục được tìm thấy bởi _lookup không chứa
dữ liệu hợp lệ thì nội dung sẽ được sao chép qua và CACHE_VALID được đặt.

Điền vào bộ đệm
------------------

Mỗi bộ đệm có một tên và khi bộ đệm được đăng ký, một thư mục
với tên đó được tạo trong /proc/net/rpc

Thư mục này chứa một tệp có tên 'kênh' là một kênh
để liên lạc giữa kernel và người dùng để điền vào bộ đệm.
Thư mục này sau này có thể chứa các tập tin tương tác khác
với bộ đệm.

'Kênh' hoạt động hơi giống một ổ cắm datagram. Mỗi lần 'viết' là
được chuyển toàn bộ vào bộ đệm để phân tích cú pháp và giải thích.
Mỗi bộ đệm có thể xử lý các yêu cầu ghi khác nhau, nhưng nó
dự kiến rằng một tin nhắn được viết sẽ chứa:

- một chiếc chìa khóa
  - thời gian hết hạn
  - một nội dung

với mục đích là một mục trong bộ đệm có khóa cung cấp
nên được tạo hoặc cập nhật để có nội dung nhất định và
thời gian hết hạn nên được đặt trên mặt hàng đó.

Đọc từ một kênh thú vị hơn một chút.  Khi một bộ đệm
tra cứu không thành công hoặc khi thành công nhưng tìm thấy một mục có thể sớm
hết hạn, một yêu cầu sẽ được gửi để cập nhật mục bộ đệm đó bởi
không gian người dùng.  Những yêu cầu này xuất hiện trong tệp kênh.

Các lần đọc liên tiếp sẽ trả về các yêu cầu liên tiếp.
Nếu không còn yêu cầu trả về nữa, lệnh đọc sẽ trả về EOF, nhưng
chọn hoặc thăm dò để đọc sẽ chặn việc chờ yêu cầu khác
đã thêm vào.

Do đó, người trợ giúp không gian người dùng có khả năng::

mở kênh.
    chọn để có thể đọc được
    đọc một yêu cầu
    viết phản hồi
  vòng lặp.

Nếu nó chết và cần được khởi động lại, mọi yêu cầu chưa được thực hiện
đã trả lời sẽ vẫn xuất hiện trong tập tin và sẽ được đọc bởi người mới
trường hợp của người trợ giúp.

Mỗi bộ đệm phải xác định một phương thức "cache_parse" để nhận một thông báo
được viết từ không gian người dùng và xử lý nó.  Nó sẽ trả về một lỗi
(truyền trở lại tòa nhà ghi) hoặc 0.

Mỗi bộ đệm cũng phải xác định một phương thức "cache_request" để
lấy một mục bộ đệm và mã hóa yêu cầu vào bộ đệm
được cung cấp.

.. note::
  If a cache has no active readers on the channel, and has had not
  active readers for more than 60 seconds, further requests will not be
  added to the channel but instead all lookups that do not find a valid
  entry will fail.  This is partly for backward compatibility: The
  previous nfs exports table was deemed to be authoritative and a
  failed lookup meant a definite 'no'.

định dạng yêu cầu/phản hồi
-----------------------

Mặc dù mỗi bộ đệm có thể tự do sử dụng định dạng riêng cho các yêu cầu
và phản hồi qua kênh, những điều sau đây được khuyến nghị là
có sẵn các thói quen phù hợp và hỗ trợ để giúp:
Mỗi bản ghi yêu cầu hoặc phản hồi phải có thể in được ASCII
với chính xác một ký tự dòng mới sẽ ở cuối.
Các trường trong bản ghi phải được phân tách bằng dấu cách, thông thường là một.
Nếu cần khoảng trắng, dòng mới hoặc ký tự null trong một trường thì chúng
được trích dẫn nhiều.  hai cơ chế có sẵn:

- Nếu một trường bắt đầu bằng '\x' thì nó phải chứa số chẵn
   các chữ số hex và các cặp chữ số này cung cấp các byte trong
   lĩnh vực.
- nếu không thì \ trong trường phải có 3 chữ số bát phân theo sau
   cung cấp mã cho một byte.  Các nhân vật khác được xử lý
   như chính họ.  Ít nhất, khoảng trắng, dòng mới, null và
   '\' phải được trích dẫn theo cách này.
