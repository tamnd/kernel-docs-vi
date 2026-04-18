.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/surface_aggregator/overview.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========
Tổng quan
========

Mô-đun tổng hợp bề mặt/hệ thống (SAM, SSAM) là một (được cho là ZZ0000ZZ)
bộ điều khiển nhúng (EC) trên các thiết bị Microsoft Surface. Ban đầu nó đã được
được giới thiệu trên các thiết bị thế hệ thứ 4 (Surface Pro 4, Surface Book 1), nhưng
trách nhiệm và bộ tính năng của nó đã được mở rộng đáng kể
với các thế hệ sau.


Tính năng và tích hợp
========================

Hiện chưa có nhiều thông tin về SAM trên các thiết bị thế hệ thứ 4 (Surface Pro
4, Surface Book 1), do sử dụng giao diện truyền thông khác
giữa máy chủ và EC (như chi tiết bên dưới). Vào ngày 5 (Surface Pro 2017, Surface
Book 2, Surface Laptop 1) và các thiết bị thế hệ sau, SAM chịu trách nhiệm
để cung cấp thông tin về pin (cả trạng thái hiện tại và giá trị tĩnh,
chẳng hạn như công suất tối đa, v.v.), cũng như các loại nhiệt độ
cảm biến (ví dụ: nhiệt độ da) và cài đặt chế độ làm mát/hiệu suất cho
chủ nhà. Đặc biệt, trên Surface Book 2, nó còn cung cấp thêm một
giao diện để xử lý việc tách clipboard đúng cách (tức là tách phần
phần hiển thị từ phần bàn phím của thiết bị), trên Surface Laptop 1
và 2 nó là bắt buộc đối với đầu vào HID trên bàn phím. Hệ thống con HID này đã được
được tái cấu trúc cho các thiết bị thế hệ thứ 7 và trên các thiết bị đó, đặc biệt là Surface
Laptop 3 và Surface Book 3, chịu trách nhiệm cho tất cả đầu vào HID chính (tức là.
bàn phím và bàn di chuột).

Mặc dù các tính năng không thay đổi nhiều ở mức độ thô kể từ ngày 5
thế hệ, giao diện bên trong đã trải qua một số thay đổi khá lớn. Bật
Các thiết bị thế hệ thứ 5 và thứ 6, cả thông tin về pin và nhiệt độ đều được cung cấp
tiếp xúc với ACPI thông qua trình điều khiển miếng chêm (được gọi là Thông báo bề mặt ACPI, hoặc
SAN), dịch các truy cập ghi/đọc bus nối tiếp chung ACPI sang SAM
yêu cầu. Trên các thiết bị thế hệ thứ 7, lớp bổ sung này không còn nữa và những lớp này
các thiết bị yêu cầu trình điều khiển nối trực tiếp vào giao diện SAM. Tương tự,
trên các thế hệ mới hơn, ít thiết bị được khai báo hơn trong ACPI, khiến chúng có một chút
khó phát hiện hơn và yêu cầu chúng tôi mã hóa cứng một loại sổ đăng ký thiết bị.
Do đó, bus SSAM và hệ thống con với các thiết bị khách
(ZZ0000ZZ) đã được triển khai.


Giao tiếp
=============

Loại giao diện truyền thông giữa máy chủ và EC phụ thuộc vào
thế hệ của thiết bị Surface. Trên các thiết bị thế hệ thứ 4, máy chủ và EC
giao tiếp qua HID, cụ thể là sử dụng thiết bị HID-over-I2C, trong khi trên
Thế hệ thứ 5 trở đi, giao tiếp diễn ra thông qua nối tiếp USART
thiết bị. Theo các trình điều khiển được tìm thấy trên các hệ điều hành khác, chúng tôi
hãy gọi thiết bị nối tiếp và trình điều khiển của nó là Surface Serial Hub (SSH). Khi nào
cần thiết, chúng tôi phân biệt cả hai loại SAM bằng cách gọi chúng là
SAM-over-SSH và SAM-over-HID.

Hiện tại, hệ thống con này chỉ hỗ trợ SAM-over-SSH. Giao tiếp SSH
giao diện được mô tả chi tiết hơn dưới đây. Giao diện HID chưa được
được thiết kế ngược và hiện tại vẫn chưa rõ có bao nhiêu (và
which) các khái niệm về giao diện SSH được nêu chi tiết bên dưới có thể được chuyển sang
nó.

Hub nối tiếp bề mặt
------------------

Như đã trình bày ở trên, Surface Serial Hub (SSH) là
giao diện truyền thông cho SAM trên Surface thế hệ thứ 5 và tất cả các thế hệ sau
thiết bị. Ở cấp độ cao nhất, giao tiếp có thể được chia thành hai phần chính
loại: Yêu cầu, tin nhắn được gửi từ máy chủ đến EC có thể kích hoạt lệnh trực tiếp
phản hồi từ EC (được liên kết rõ ràng với yêu cầu) và các sự kiện
(đôi khi còn được gọi là thông báo), được gửi từ EC tới máy chủ mà không cần
là một phản hồi trực tiếp cho một yêu cầu trước đó. Chúng tôi cũng có thể đề cập đến các yêu cầu
không có phản hồi như lệnh. Nói chung, các sự kiện cần được kích hoạt thông qua một
của nhiều yêu cầu dành riêng trước khi chúng được gửi bởi EC.

Xem Documentation/driver-api/surface_aggregator/ssh.rst để biết
thêm tài liệu giao thức kỹ thuật và
Documentation/driver-api/surface_aggregator/internal.rst cho một
tổng quan về kiến trúc trình điều khiển bên trong.