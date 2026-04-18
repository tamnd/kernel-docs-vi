.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/sy7636a-hwmon.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân sy7636a-hwmon
===========================

Chip được hỗ trợ:

* Silergy SY7636A PMIC


Sự miêu tả
-----------

Trình điều khiển này bổ sung thêm tính năng hỗ trợ đọc nhiệt độ phần cứng cho
Silergy SY7636A PMIC.

Các cảm biến sau được hỗ trợ

* Nhiệt độ
      - Nhiệt độ bên ngoài NTC tính bằng mili độ C

giao diện sysfs
---------------

temp0_input
	- Nhiệt độ bên ngoài NTC (mili độ C)