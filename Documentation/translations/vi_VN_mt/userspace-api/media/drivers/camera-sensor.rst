.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/drivers/camera-sensor.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _media_using_camera_sensor_drivers:

Sử dụng trình điều khiển cảm biến máy ảnh
===========================

Phần này mô tả các phương pháp phổ biến về cách giao diện thiết bị phụ V4L2
được sử dụng để điều khiển trình điều khiển cảm biến máy ảnh.

Bạn cũng có thể thấy ZZ0000ZZ hữu ích.

Cấu hình đường ống bên trong cảm biến
--------------------------------------

Cảm biến máy ảnh có một quy trình xử lý nội bộ bao gồm cắt xén và
chức năng đóng thùng. Trình điều khiển cảm biến thuộc hai lớp riêng biệt, một cách tự do
trình điều khiển dựa trên danh sách có thể cấu hình và đăng ký, tùy thuộc vào cách trình điều khiển
cấu hình chức năng này.

Trình điều khiển cảm biến máy ảnh có thể cấu hình tự do
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Trình điều khiển cảm biến máy ảnh có thể cấu hình tự do sẽ hiển thị thông tin bên trong của thiết bị
đường ống xử lý dưới dạng một hoặc nhiều thiết bị phụ với các cách cắt xén khác nhau và
các cấu hình mở rộng quy mô. Kích thước đầu ra của thiết bị là kết quả của một chuỗi
các thao tác cắt xén và chia tỷ lệ từ kích thước mảng pixel của thiết bị.

Một ví dụ về trình điều khiển như vậy là trình điều khiển CCS.

Đăng ký trình điều khiển dựa trên danh sách
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Đăng ký trình điều khiển dựa trên danh sách nói chung, thay vì có thể cấu hình thiết bị
họ kiểm soát dựa trên yêu cầu của người dùng, bị giới hạn ở một số cài đặt trước
cấu hình kết hợp một số tham số khác nhau trên phần cứng
cấp độ là độc lập. Cách trình điều khiển chọn cấu hình như vậy dựa trên
định dạng được đặt trên bảng nguồn ở cuối đường dẫn bên trong của thiết bị.

Hầu hết các trình điều khiển cảm biến đều được thực hiện theo cách này.

Cấu hình khoảng thời gian khung
----------------------------

Có hai phương pháp khác nhau để có được khả năng cho các khung khác nhau
khoảng thời gian cũng như cấu hình khoảng thời gian khung. Thực hiện cái nào
phụ thuộc vào loại thiết bị.

Cảm biến camera thô
~~~~~~~~~~~~~~~~~~

Thay vì tham số cấp cao như khoảng thời gian khung, khoảng thời gian khung là
là kết quả của việc cấu hình một số cảm biến camera thực hiện
thông số cụ thể. May mắn thay, những thông số này có xu hướng giống nhau trong nhiều
ít hơn tất cả các cảm biến máy ảnh thô hiện đại.

Khoảng thời gian khung được tính bằng phương trình sau::

khoảng thời gian khung hình = (chiều rộng cắt tương tự + khoảng trống ngang) *
			 (chiều cao cắt tương tự + khoảng trống dọc) / tốc độ pixel

Công thức này độc lập với bus và có thể áp dụng cho các tham số định thời thô trên
rất nhiều thiết bị ngoài cảm biến máy ảnh. Các thiết bị không có analog
cắt, sử dụng kích thước hình ảnh nguồn đầy đủ, tức là kích thước mảng pixel.

Khoảng trống ngang và dọc được chỉ định bởi ZZ0000ZZ và
ZZ0001ZZ, tương ứng. Đơn vị điều khiển ZZ0002ZZ
là pixel và đơn vị của ZZ0003ZZ là dòng. Tỷ lệ pixel trong
ZZ0005ZZ của cảm biến được chỉ định bởi ZZ0004ZZ trong cùng
thiết bị phụ. Đơn vị của điều khiển đó là pixel trên giây.

Trình điều khiển dựa trên danh sách đăng ký cần triển khai các nút thiết bị phụ chỉ đọc cho
mục đích. Các thiết bị không dựa trên danh sách đăng ký cần những thứ này để cấu hình
đường ống xử lý nội bộ của thiết bị.

Thực thể đầu tiên trong đường dẫn tuyến tính là mảng pixel. Mảng pixel có thể
được theo sau bởi các thực thể khác ở đó để cho phép định cấu hình việc tạo nhóm,
bỏ qua, chia tỷ lệ hoặc cắt xén kỹ thuật số, xem ZZ0000ZZ.

Máy ảnh USB, v.v. thiết bị
~~~~~~~~~~~~~~~~~~~~~~~~

Phần cứng lớp video USB, cũng như nhiều máy ảnh cung cấp chất lượng cao hơn tương tự
giao diện cấp độ nguyên bản, thường sử dụng khái niệm khoảng thời gian khung (hoặc khung
rate) ở cấp độ thiết bị trong phần sụn hoặc phần cứng. Điều này có nghĩa là kiểm soát cấp thấp hơn
được triển khai bởi camera thô có thể không được sử dụng trên uAPI (hoặc thậm chí kAPI) để kiểm soát
khoảng thời gian khung hình trên các thiết bị này.

Xoay, định hướng và lật
----------------------------------

Một số hệ thống có cảm biến camera được gắn lộn ngược so với tự nhiên
lắp xoay. Trong những trường hợp như vậy, người lái xe phải cung cấp thông tin cho
không gian người dùng với điều khiển ZZ0000ZZ.

Trình điều khiển cảm biến cũng phải báo cáo hướng lắp đặt của cảm biến bằng
ZZ0000ZZ.

Trình điều khiển cảm biến có bất kỳ thao tác lật dọc hoặc ngang nào được nhúng trong
trình tự lập trình đăng ký sẽ khởi tạo các điều khiển ZZ0000ZZ và ZZ0001ZZ bằng
các giá trị được lập trình bởi các chuỗi thanh ghi. Các giá trị mặc định của chúng
điều khiển sẽ là 0 (bị vô hiệu hóa). Đặc biệt các điều khiển này không được đảo ngược,
độc lập với vòng quay lắp của cảm biến.