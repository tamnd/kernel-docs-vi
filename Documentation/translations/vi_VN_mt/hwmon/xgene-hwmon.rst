.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/xgene-hwmon.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân xgene-hwmon
=========================

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
