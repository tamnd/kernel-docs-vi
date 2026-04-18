.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/xgene-hwmon.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân xgene-hwmon
=====================================

Chip được hỗ trợ:

* APM X-Gene SoC

Sự miêu tả
-----------

Trình điều khiển này bổ sung thêm hỗ trợ đọc nhiệt độ phần cứng và nguồn điện cho
APM X-Gene SoC sử dụng giao diện liên lạc hộp thư.
Đối với cây thiết bị, đó là hộp thư DT tiêu chuẩn.
Đối với ACPI, đó là hộp thư PCC.

Các cảm biến sau được hỗ trợ

* Nhiệt độ
      - Nhiệt độ trên khuôn SoC tính bằng mili độ C
      - Báo động khi xảy ra nhiệt độ cao/quá nhiệt

* Quyền lực
      - Nguồn CPU tính bằng uW
      - Nguồn IO tính bằng uW

giao diện sysfs
---------------

temp0_input
	- Nhiệt độ trên khuôn SoC (mili độ C)
temp0_cript_alarm
	- Số 1 sẽ cho biết nhiệt độ trên khuôn đã vượt quá ngưỡng
nguồn0_input
	- Nguồn vào CPU (uW)
nguồn1_input
	- Nguồn IO vào (uW)
