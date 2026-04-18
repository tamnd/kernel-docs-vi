.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/nfs/client-identifier.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========================
Mã định danh máy khách NFSv4
=======================

Tài liệu này giải thích cách giao thức NFSv4 xác định máy khách
các trường hợp để duy trì trạng thái mở và khóa tệp trong quá trình
hệ thống khởi động lại. Một mã định danh đặc biệt và hiệu trưởng được duy trì
trên mỗi khách hàng. Chúng có thể được thiết lập bởi quản trị viên, tập lệnh
do quản trị viên trang web cung cấp hoặc các công cụ do Linux cung cấp
các nhà phân phối.

Có những rủi ro nếu mã định danh NFSv4 của khách hàng và mã định danh chính của nó
không được lựa chọn cẩn thận.


Giới thiệu
------------

Giao thức NFSv4 sử dụng "khóa tệp dựa trên hợp đồng thuê". Trợ giúp cho thuê
Máy chủ NFSv4 cung cấp bảo đảm khóa tệp và quản lý chúng
tài nguyên.

Nói một cách đơn giản, máy chủ NFSv4 tạo hợp đồng thuê cho mỗi máy khách NFSv4.
Máy chủ thu thập trạng thái mở và khóa tệp của mỗi khách hàng theo
hợp đồng thuê cho khách hàng đó.

Khách hàng có trách nhiệm gia hạn hợp đồng thuê định kỳ.
Trong khi hợp đồng thuê vẫn còn hiệu lực, máy chủ giữ hợp đồng thuê đó
đảm bảo các khóa tập tin mà khách hàng đã tạo vẫn giữ nguyên.

Nếu khách hàng ngừng gia hạn hợp đồng thuê (ví dụ: nếu nó gặp sự cố),
giao thức NFSv4 cho phép máy chủ loại bỏ quyền mở của máy khách
và khóa trạng thái sau một khoảng thời gian nhất định. Khi một khách hàng
khởi động lại, nó báo cho các máy chủ trạng thái mở và khóa
liên quan đến hợp đồng thuê trước đó không còn giá trị và có thể được
bị phá hủy ngay lập tức.

Ngoài ra, mỗi máy chủ NFSv4 quản lý một danh sách khách hàng liên tục
hợp đồng thuê. Khi máy chủ khởi động lại và máy khách cố gắng khôi phục
trạng thái của chúng, máy chủ sử dụng danh sách này để phân biệt giữa
các máy khách giữ trạng thái trước khi máy chủ khởi động lại và các máy khách
gửi yêu cầu OPEN và LOCK mới. Điều này cho phép khóa tập tin
tồn tại an toàn trong suốt quá trình khởi động lại máy chủ.

Mã định danh máy khách NFSv4
------------------------

Mỗi máy khách NFSv4 trình bày một mã định danh cho các máy chủ NFSv4 để
họ có thể liên kết khách hàng với hợp đồng thuê của nó. của mỗi khách hàng
định danh bao gồm hai phần tử:

- co_ownerid: Một chuỗi tùy ý nhưng cố định.

- trình xác minh khởi động: Trình xác minh hiện thân 64-bit cho phép
    máy chủ để phân biệt các giai đoạn khởi động liên tiếp của cùng một máy khách.

Đặc tả NFSv4.0 đề cập đến hai mục này như một
"nfs_client_id4". Đặc tả NFSv4.1 đề cập đến hai điều này
các mục dưới dạng "client_owner4".

Máy chủ NFSv4 liên kết mã định danh này với giá trị chính và bảo mật
hương vị mà khách hàng đã sử dụng khi trình bày nó. Máy chủ sử dụng cái này
Hiệu trưởng cho phép các hoạt động sửa đổi hợp đồng thuê tiếp theo
được gửi bởi khách hàng. Thực tế, nguyên tắc này là yếu tố thứ ba của
định danh.

Là một phần của danh tính được trình bày cho các máy chủ, một
Chuỗi "co_ownerid" có một số thuộc tính quan trọng:

- Chuỗi "co_ownerid" xác định máy khách trong quá trình khởi động lại
    recovery, do đó chuỗi liên tục trên toàn bộ máy khách
    khởi động lại.
  - Chuỗi “co_ownerid” giúp server phân biệt client
    từ những chuỗi khác, do đó chuỗi này là duy nhất trên toàn cầu. Lưu ý
    rằng không có cơ quan trung ương nào chỉ định "co_ownerid"
    dây.
  - Vì nó thường xuất hiện trên mạng một cách rõ ràng nên
    Chuỗi "co_ownerid" không tiết lộ thông tin cá nhân về
    bản thân khách hàng.
  - Nội dung của chuỗi “co_ownerid” được thiết lập và không thay đổi
    trước khi máy khách thử gắn kết NFSv4 sau khi khởi động lại.
  - Giao thức NFSv4 đặt giới hạn 1024 byte cho kích thước của
    chuỗi "co_ownerid".

Bảo vệ trạng thái cho thuê NFSv4
----------------------------

Máy chủ NFSv4 sử dụng "client_owner4" như được mô tả ở trên để
ấn định một hợp đồng thuê duy nhất cho mỗi khách hàng. Theo sơ đồ này, có
trường hợp mà các khách hàng có thể can thiệp lẫn nhau. Đây là
gọi là "ăn cắp tiền thuê".

Nếu các máy khách riêng biệt trình bày cùng một chuỗi "co_ownerid" và sử dụng
cùng một hiệu trưởng (ví dụ: AUTH_SYS và UID 0), một máy chủ là
không thể nói rằng khách hàng không giống nhau. Mỗi khác biệt
khách hàng trình bày một trình xác minh khởi động khác, do đó nó xuất hiện với
máy chủ như thể có một máy khách thường xuyên khởi động lại.
Cả khách hàng đều không thể duy trì trạng thái mở hoặc khóa trong trường hợp này.

Nếu các máy khách riêng biệt trình bày cùng một chuỗi "co_ownerid" và sử dụng
nguyên tắc riêng biệt, máy chủ có thể cho phép khách hàng đầu tiên
hoạt động bình thường nhưng từ chối các khách hàng tiếp theo có cùng nội dung
chuỗi "co_ownerid".

Nếu chuỗi "co_ownerid" hoặc chuỗi gốc của khách hàng không ổn định,
việc khôi phục trạng thái sau khi khởi động lại máy chủ hoặc máy khách không được đảm bảo.
Nếu một máy khách bất ngờ khởi động lại nhưng lại đưa ra một lỗi khác
Chuỗi "co_ownerid" hoặc chuỗi gốc đối với máy chủ, máy chủ mồ côi
trạng thái mở và khóa trước đó của khách hàng. Điều này chặn quyền truy cập vào
các tập tin bị khóa cho đến khi máy chủ loại bỏ trạng thái mồ côi.

Nếu máy chủ khởi động lại và máy khách hiển thị "co_ownerid" đã thay đổi
chuỗi hoặc hiệu trưởng tới máy chủ, máy chủ sẽ không cho phép
khách hàng lấy lại trạng thái mở và khóa của nó và có thể cung cấp cho các khóa đó
cho các khách hàng khác trong thời gian chờ đợi. Điều này được gọi là "khóa
ăn trộm".

Trộm cắp hợp đồng thuê và trộm khóa làm tăng khả năng bị từ chối
của dịch vụ và trong những trường hợp hiếm hoi thậm chí là hỏng dữ liệu.

Lựa chọn mã định danh khách hàng thích hợp
------------------------------------------

Theo mặc định, việc triển khai máy khách Linux NFSv4 sẽ xây dựng
Chuỗi "co_ownerid" bắt đầu bằng các từ "Linux NFS" theo sau là
tên nút UTS của khách hàng (tình cờ, cùng tên nút đó
được sử dụng làm "tên máy" trong thông tin xác thực AUTH_SYS). nhỏ
triển khai, việc xây dựng này thường là đầy đủ. Tuy nhiên, thường thì
bản thân tên nút không đủ độc đáo và có thể thay đổi
một cách bất ngờ. Các tình huống có vấn đề bao gồm:

- Máy khách NFS-root (không có ổ đĩa), trong đó máy chủ DHCP cục bộ (hoặc
    tương đương) không cung cấp tên máy chủ duy nhất.

- "Vùng chứa" trong một máy chủ Linux.  Nếu mỗi thùng chứa có
    một không gian tên mạng riêng biệt, nhưng không sử dụng không gian tên UTS
    để cung cấp một tên máy chủ duy nhất thì có thể có nhiều NFS
    các trường hợp máy khách có cùng tên máy chủ.

- Khách hàng trên nhiều miền quản trị có quyền truy cập vào một
    máy chủ NFS phổ biến. Nếu tên máy chủ không được chỉ định tập trung
    thì tính duy nhất không thể được đảm bảo trừ khi tên miền được
    được bao gồm trong tên máy chủ.

Linux cung cấp hai cơ chế để thêm tính duy nhất cho "co_ownerid" của nó
chuỗi:

nfs.nfs4_unique_id
      Tham số mô-đun này có thể đặt chuỗi ký hiệu duy nhất tùy ý
      thông qua dòng lệnh kernel hoặc khi mô-đun "nfs" được
      đã tải.

/sys/fs/nfs/net/nfs_client/định danh
      Tệp ảo này, có sẵn từ Linux 5.3, là tệp cục bộ của
      không gian tên mạng trong đó nó được truy cập và do đó có thể cung cấp
      sự khác biệt giữa các không gian tên mạng (container) khi
      tên máy chủ vẫn thống nhất.

Lưu ý rằng tập tin này trống khi tạo không gian tên. Nếu
hệ thống container có quyền truy cập vào một số loại nhận dạng trên mỗi container
thì có thể sử dụng bộ định danh đó. Ví dụ: một bộ xác định duy nhất có thể
được hình thành khi khởi động bằng cách sử dụng mã định danh nội bộ của vùng chứa:

sha256sum /etc/machine-id | awk '{print $1}' \\
        > /sys/fs/nfs/net/nfs_client/định danh

Cân nhắc về bảo mật
-----------------------

Việc sử dụng bảo mật mật mã cho các hoạt động quản lý cho thuê
được khuyến khích mạnh mẽ.

Nếu NFS với Kerberos không được định cấu hình, máy khách Linux NFSv4 sẽ sử dụng
AUTH_SYS và UID 0 là phần chính trong nhận dạng khách hàng của nó.
Cấu hình này không chỉ không an toàn mà còn làm tăng nguy cơ
cho thuê và trộm khóa. Tuy nhiên, nó có thể là lựa chọn duy nhất cho
cấu hình máy khách không có bộ lưu trữ liên tục cục bộ.
Tính duy nhất và tính bền vững của chuỗi "co_ownerid" là rất quan trọng trong việc này
trường hợp.

Khi có keytab Kerberos trên máy khách Linux NFS, máy khách
cố gắng sử dụng một trong các nguyên tắc trong keytab đó khi
nhận dạng chính nó tới các máy chủ. Tùy chọn gắn kết "sec=" không
kiểm soát hành vi này. Ngoài ra, một máy khách một người dùng có
Hiệu trưởng Kerberos có thể sử dụng số tiền gốc đó thay cho số tiền gốc của khách hàng.
hiệu trưởng chủ nhà.

Sử dụng Kerberos cho mục đích này cho phép máy khách và máy chủ
sử dụng cùng một hợp đồng thuê cho các hoạt động được bao trùm bởi tất cả cài đặt "sec=".
Ngoài ra, máy khách Linux NFS sử dụng bảo mật RPCSEC_GSS
hương vị với Kerberos và tính toàn vẹn QOS để ngăn chặn quá trình vận chuyển
sửa đổi các yêu cầu sửa đổi hợp đồng thuê.

Ghi chú bổ sung
----------------
Máy khách Linux NFSv4 thiết lập một hợp đồng thuê duy nhất trên mỗi NFSv4
máy chủ mà nó truy cập. Gắn kết NFSv4 từ máy khách Linux NFSv4 của máy tính
máy chủ cụ thể sau đó chia sẻ hợp đồng thuê đó.

Khi máy khách thiết lập trạng thái mở và khóa, giao thức NFSv4
cho phép trạng thái thuê chuyển sang các máy chủ khác, theo dõi dữ liệu
đã được di chuyển. Điều này ẩn hoàn toàn việc di chuyển dữ liệu khỏi
các ứng dụng đang chạy. Máy khách Linux NFSv4 hỗ trợ trạng thái
di chuyển bằng cách hiển thị cùng một "client_owner4" cho tất cả các máy chủ
những cuộc gặp gỡ.

========
Xem thêm
========

- nfs(5)
  - Kerberos(7)
  - RFC 7530 cho thông số kỹ thuật NFSv4.0
  - RFC 8881 cho thông số kỹ thuật NFSv4.1.