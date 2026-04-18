.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/w1/w1-generic.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================
Giới thiệu về hệ thống con 1 dây (w1)
=============================================

Bus 1 dây là một bus chủ-phụ đơn giản giao tiếp thông qua một
dây tín hiệu (cộng với mặt đất, nên hai dây).

Các thiết bị giao tiếp trên bus bằng cách kéo tín hiệu xuống đất thông qua một cổng mở
thoát đầu ra và bằng cách lấy mẫu mức logic của đường tín hiệu.

Hệ thống con w1 cung cấp khuôn khổ để quản lý w1 master và
giao tiếp với nô lệ.

Tất cả các thiết bị phụ w1 phải được kết nối với thiết bị chính bus w1.

Ví dụ về thiết bị chính w1:

- Thiết bị usb DS9490
    - W1-over-GPIO
    - DS2482 (cầu i2c tới w1)
    - Các thiết bị mô phỏng, chẳng hạn như bộ chuyển đổi RS232, bộ chuyển đổi cổng song song, v.v.


Hệ thống con w1 làm gì?
------------------------------

Khi trình điều khiển chính w1 đăng ký với hệ thống con w1, điều sau đây sẽ xảy ra:

- các mục sysfs cho w1 master đó được tạo
 - bus w1 được tìm kiếm định kỳ cho các thiết bị phụ mới

Khi tìm thấy một thiết bị trên xe buýt, lõi w1 sẽ cố tải trình điều khiển cho dòng thiết bị đó
và kiểm tra xem nó đã được tải chưa. Nếu thế thì người tài xế gia đình gắn bó với nô lệ.
Nếu không có trình điều khiển cho gia đình, một trình điều khiển mặc định sẽ được chỉ định, cho phép thực hiện
hầu hết mọi loại hoạt động. Mỗi thao tác logic là một giao dịch
về bản chất, có thể chứa một số (hai hoặc một) thao tác cấp thấp.
Hãy xem cách người ta có thể đọc ngữ cảnh EEPROM:
1. người ta phải ghi bộ đệm điều khiển, tức là bộ đệm chứa byte lệnh
và địa chỉ hai byte. Ở bước này bus được thiết lập lại và thiết bị thích hợp
được chọn bằng lệnh W1_SKIP_ROM hoặc W1_MATCH_ROM.
Sau đó, bộ đệm điều khiển được cung cấp sẽ được ghi vào dây.
2. đọc. Điều này sẽ phát hành phản hồi đọc eeprom.

Có thể từ 1. đến 2. w1 master thread sẽ reset bus để tìm kiếm
và thiết bị nô lệ thậm chí sẽ bị xóa, nhưng trong trường hợp này 0xff sẽ
được đọc vì không có thiết bị nào được chọn.


Họ thiết bị W1
------------------

Các thiết bị phụ được xử lý bởi trình điều khiển được viết cho dòng thiết bị w1.

Trình điều khiển gia đình điền vào cấu trúc w1_family_ops (xem w1_family.h) và
đăng ký với hệ thống con w1.

Tài xế gia đình hiện tại:

w1_therm
  - (Trình điều khiển gia đình cảm biến nhiệt ds18?20)
    cung cấp chức năng đọc nhiệt độ được liên kết với phương thức ->rbin()
    của cấu trúc w1_family_ops ở trên.

w1_smem
  - trình điều khiển cho ô nhớ 64bit đơn giản cung cấp phương pháp đọc ID.

Bạn có thể gọi các phương thức trên bằng cách đọc các tệp sysfs thích hợp.


Trình điều khiển chính w1 cần triển khai những gì?
--------------------------------------------------

Trình điều khiển cho bus master w1 phải cung cấp tối thiểu hai chức năng.

Các thiết bị mô phỏng phải cung cấp khả năng thiết lập mức tín hiệu đầu ra
(write_bit) và lấy mẫu mức tín hiệu (read_bit).

Các thiết bị hỗ trợ 1 dây nguyên bản phải cung cấp khả năng ghi và
lấy mẫu một chút (touch_bit) và đặt lại bus (reset_bus).

Hầu hết phần cứng đều cung cấp các chức năng cấp cao hơn giúp giảm tải việc xử lý w1.
Xem định nghĩa struct w1_bus_master trong w1.h để biết chi tiết.


giao diện sysfs chính của w1
----------------------------

====================================================================================
<xx-xxxxxxxxxxxx> Thư mục của thiết bị được tìm thấy. Định dạng là
                          gia đình nối tiếp
liên kết tượng trưng xe buýt (tiêu chuẩn) đến xe buýt w1
liên kết tượng trưng của trình điều khiển (tiêu chuẩn) với trình điều khiển w1
w1_master_add (rw) đăng ký thủ công một thiết bị phụ
w1_master_attempts (ro) số lần thực hiện tìm kiếm
w1_master_max_slave_count (rw) số lượng nô lệ tối đa để tìm kiếm tại một thời điểm
w1_master_name (ro) tên của thiết bị (w1_bus_masterX)
w1_master_pullup (rw) Pullup mạnh 5V 0 bật, 1 tắt
w1_master_remove (rw) xóa thiết bị phụ theo cách thủ công
w1_master_search (rw) số lượng tìm kiếm còn lại phải thực hiện,
                          -1=liên tục (mặc định)
w1_master_slave_count (ro) số lượng nô lệ được tìm thấy
w1_master_slaves (ro) tên của các nô lệ, mỗi tên một dòng
w1_master_timeout (ro) độ trễ tính bằng giây giữa các lần tìm kiếm
w1_master_timeout_us (ro) độ trễ tính bằng micro giây giữa các lần tìm kiếm
====================================================================================

Nếu bạn có bus w1 không bao giờ thay đổi (bạn không thêm hoặc xóa thiết bị),
bạn có thể đặt tham số mô-đun search_count thành một số dương nhỏ
cho một số lượng nhỏ các tìm kiếm xe buýt ban đầu.  Ngoài ra nó có thể là
được đặt thành 0, sau đó thêm thủ công số sê-ri của thiết bị phụ bằng cách
tập tin thiết bị w1_master_add.  Các tệp w1_master_add và w1_master_remove
thường chỉ có ý nghĩa khi tính năng tìm kiếm bị tắt, vì tìm kiếm sẽ
phát hiện lại các thiết bị đã bị xóa thủ công hiện có và hết thời gian chờ theo cách thủ công
đã thêm các thiết bị không có trên xe buýt.

Việc tìm kiếm bus diễn ra theo một khoảng thời gian, được chỉ định dưới dạng tổng thời gian chờ và
tham số mô-đun timeout_us (một trong hai tham số này có thể bằng 0) miễn là
w1_master_search vẫn lớn hơn 0 hoặc -1.  Mỗi nỗ lực tìm kiếm
giảm w1_master_search đi 1 (xuống 0) và tăng
w1_master_attempts bằng 1.

giao diện sysfs nô lệ w1
------------------------

=================== ==================================================================
liên kết tượng trưng xe buýt (tiêu chuẩn) đến xe buýt w1
liên kết tượng trưng của trình điều khiển (tiêu chuẩn) với trình điều khiển w1
đặt tên tên thiết bị, thường giống với tên thư mục
w1_slave (tùy chọn) một tệp nhị phân có ý nghĩa phụ thuộc vào
                    tài xế gia đình
rw (tùy chọn) được tạo cho các thiết bị phụ không có
		    tài xế gia đình phù hợp. Cho phép đọc/ghi dữ liệu nhị phân.
=================== ==================================================================
