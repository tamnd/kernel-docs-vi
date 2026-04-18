.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/leds/leds-lp5812.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Trình điều khiển hạt nhân cho lp5812
====================================

* Trình điều khiển TI/National Semiconductor LP5812 LED
* Bảng dữ liệu: ZZ0000ZZ

Tác giả: Jared Chu <jared-zhou@ti.com>

Sự miêu tả
===========

LP5812 là trình điều khiển LED ma trận 4x3 có hỗ trợ cả thủ công và
điều khiển hoạt hình tự động. Trình điều khiển này cung cấp giao diện sysfs để
kiểm soát và định cấu hình thiết bị LP5812 và các kênh LED của nó.

Giao diện hệ thống
===============

Trình điều khiển này sử dụng giao diện lớp LED nhiều màu tiêu chuẩn được xác định
trong Tài liệu/ABI/testing/sysfs-class-led-multicolor.rst.

Mỗi đầu ra LP5812 LED xuất hiện dưới ZZ0000ZZ với
nhãn được chỉ định (ví dụ ZZ0001ZZ).

Các thuộc tính sau được hiển thị:
  - multi_intensity: Kiểm soát cường độ RGB trên mỗi kênh
  - độ sáng: Kiểm soát độ sáng tiêu chuẩn (0-255)

Chế độ điều khiển tự động
========================

Trình điều khiển còn hỗ trợ điều khiển tự động thông qua cấu hình mẫu
(ví dụ: chế độ trực tiếp, tcmscan hoặc mixscan) được xác định trong cây thiết bị.
Khi được định cấu hình, LP5812 có thể tạo hiệu ứng chuyển tiếp và màu sắc
không có sự can thiệp của CPU.

Tham khảo tài liệu ràng buộc cây thiết bị để biết các chuỗi chế độ hợp lệ và
ví dụ về cấu hình.

Cách sử dụng ví dụ
=============

Để điều khiển LED_A::
    Cường độ # Set RGB (R=50, G=50, B=50)
    echo 50 50 50 > /sys/class/leds/LED_A/multi_intensity
    Độ sáng tổng thể của # Set ở mức tối đa
    echo 255 > /sys/class/leds/LED_A/độ sáng