.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/watchdog/mlx-wdt.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================================
Trình điều khiển cơ quan giám sát Mellanox
==========================================

cho các thiết bị chuyển mạch hệ thống dựa trên x86
==================================================

Trình điều khiển này cung cấp chức năng giám sát cho nhiều loại Mellanox
Hệ thống chuyển mạch Ethernet và Infiniband.

Thiết bị giám sát Mellanox được triển khai trong một thiết bị logic lập trình được.

Có 2 loại triển khai cơ quan giám sát CTNH.

Loại 1:
  Thời gian chờ CT thực tế có thể được định nghĩa là lũy thừa 2 mili giây.
  ví dụ. thời gian chờ 20 giây sẽ được làm tròn thành 32768 mili giây.
  Khoảng thời gian chờ tối đa là 32 giây (32768 mili giây),
  Nhận thời gian còn lại không được hỗ trợ

Loại 2:
  Thời gian chờ CT thực tế được xác định bằng giây. và nó cũng giống như
  thời gian chờ do người dùng xác định.
  Thời gian chờ tối đa là 255 giây.
  Nhận thời gian còn lại được hỗ trợ.

Loại 3:
  Tương tự như Loại 2 với thời gian chờ tối đa kéo dài.
  Thời gian chờ tối đa là 65535 giây.

Việc triển khai cơ quan giám sát CTNH loại 1 tồn tại trong các hệ thống cũ và
tất cả các hệ thống mới đều có cơ quan giám sát CTNH loại 2.
Hai loại hình thực hiện CTNH cũng có bản đồ đăng ký khác nhau.

Việc triển khai cơ quan giám sát CTNH loại 3 có thể tồn tại trên tất cả các hệ thống Mellanox
với thiết bị logic lập trình viên mới.
Nó được phân biệt bởi bit khả năng WD.
Các hệ thống cũ vẫn chỉ có một cơ quan giám sát chính.

Hệ thống Mellanox có thể có 2 cơ quan giám sát: chính và phụ.
Các thiết bị giám sát chính và phụ có thể được kích hoạt cùng nhau
trên cùng một hệ thống.
Có một số hành động có thể được xác định trong cơ quan giám sát:
thiết lập lại hệ thống, khởi động quạt ở tốc độ tối đa và tăng bộ đếm đăng ký.
2 hành động cuối cùng được thực hiện mà không cần thiết lập lại hệ thống.
Các hành động không cần thiết lập lại được cung cấp cho thiết bị giám sát phụ trợ,
đó là tùy chọn.
Cơ quan giám sát có thể được khởi động trong quá trình thăm dò, trong trường hợp này nó sẽ được
được ping bởi lõi cơ quan giám sát trước khi thiết bị cơ quan giám sát được mở bởi
ứng dụng không gian người dùng.
Cơ quan giám sát có thể được khởi tạo theo cách ngay lập tức, tức là đã bắt đầu
nó không thể dừng lại được.

Trình điều khiển mlx-wdt này hỗ trợ cả việc triển khai cơ quan giám sát CTNH.

Trình điều khiển cơ quan giám sát được thăm dò từ trình điều khiển mlx_platform chung.
Trình điều khiển Mlx_platform cung cấp một bộ thanh ghi thích hợp cho
Thiết bị giám sát Mellanox, tên nhận dạng (mlx-wdt-main hoặc mlx-wdt-aux),
thời gian chờ ban đầu, thực hiện hành động trong cờ hết hạn và cấu hình.
cờ cấu hình cơ quan giám sát: nowout và start_at_boot, hw cơ quan giám sát
phiên bản - type1 hoặc type2.
Trình điều khiển sẽ kiểm tra trong quá trình khởi tạo nếu hệ thống trước đó được thiết lập lại
đã được thực hiện bởi cơ quan giám sát. Nếu có, nó sẽ thông báo về sự kiện này.

Việc truy cập vào các thanh ghi CTNH được thực hiện thông qua giao diện regmap chung.
Các thanh ghi của thiết bị logic khả trình có thứ tự endian nhỏ.
