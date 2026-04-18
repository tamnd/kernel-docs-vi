.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/raspberrypi-hwmon.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân Raspberrypi-hwmon
===========================================

Các bảng được hỗ trợ:

* Raspberry Pi A+ (thông qua GPIO trên SoC)
  * Raspberry Pi B+ (thông qua GPIO trên SoC)
  * Raspberry Pi 2 B (thông qua GPIO trên SoC)
  * Raspberry Pi 3 B (thông qua GPIO trên bộ mở rộng cổng)
  * Raspberry Pi 3 B+ (thông qua PMIC)

Tác giả: Stefan Wahren <stefan.wahren@i2se.com>

Sự miêu tả
-----------

Trình điều khiển này thăm dò định kỳ thuộc tính hộp thư của phần sụn VC4 để phát hiện
điều kiện điện áp thấp.

Mục nhập hệ thống
-----------------

============================================
in0_lcrit_alarm Báo động điện áp thấp
============================================
