.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/gigabyte_waterforce.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân gigabyte_waterforce
=================================

Các thiết bị được hỗ trợ:

* Gigabyte AORUS WATERFORCE X240
* Gigabyte AORUS WATERFORCE X280
* Gigabyte AORUS WATERFORCE X360

Tác giả: Aleksa Savic

Sự miêu tả
-----------

Trình điều khiển này cho phép hỗ trợ giám sát phần cứng cho Gigabyte Waterforce được liệt kê
bộ làm mát chất lỏng CPU tất cả trong một. Các cảm biến có sẵn là tốc độ bơm và quạt trong RPM, như
cũng như nhiệt độ nước làm mát. Cũng có sẵn thông qua debugfs là phiên bản phần sụn.

Việc gắn quạt là tùy chọn và cho phép điều khiển quạt từ thiết bị. Nếu
nó không được kết nối, các cảm biến liên quan đến quạt sẽ báo cáo số 0.

Đèn LED RGB có địa chỉ và màn hình LCD không được hỗ trợ trong trình điều khiển này và sẽ
được kiểm soát thông qua các công cụ không gian người dùng.

ghi chú sử dụng
-----------

Vì đây là các USB HID nên trình điều khiển có thể được tải tự động bởi kernel và
hỗ trợ trao đổi nóng.

Mục nhập hệ thống
-------------

=========== ==================================================
fan1_input Tốc độ quạt (tính bằng vòng/phút)
fan2_input Tốc độ bơm (tính bằng vòng/phút)
temp1_input Nhiệt độ nước làm mát (tính bằng mili độ C)
=========== ==================================================

Mục gỡ lỗi
---------------

======================================================
firmware_version Phiên bản phần mềm cơ sở của thiết bị
======================================================