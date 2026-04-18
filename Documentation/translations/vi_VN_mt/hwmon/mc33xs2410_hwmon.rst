.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/mc33xs2410_hwmon.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân mc33xs2410_hwmon
==============================

Các thiết bị được hỗ trợ:

* NXP MC33XS2410

Bảng dữ liệu: ZZ0000ZZ

tác giả:

Dimitri Fedrau <dimitri.fedrau@liebherr.com>

Sự miêu tả
-----------

MC33XS2410 là công tắc phía cao tự bảo vệ bốn kênh có tính năng
chức năng giám sát phần cứng như nhiệt độ, dòng điện và điện áp cho từng
của bốn kênh.

Mục nhập hệ thống
-------------

===================================================================================
temp1_label "Nhiệt độ khuôn trung tâm"
temp1_input Nhiệt độ đo được của khuôn trung tâm

temp[2-5]_label "Nhiệt độ kênh [1-4]"
temp[2-5]_input Đo nhiệt độ của một kênh
temp[2-5]_alarm Báo động nhiệt độ
temp[2-5]_max Nhiệt độ tối đa
===================================================================================