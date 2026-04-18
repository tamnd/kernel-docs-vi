.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/pli1209bc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân pli1209bc
=======================

Chip được hỗ trợ:

* Giám sát kỹ thuật số PLI1209BC

Tiền tố: 'pli1209bc'

Địa chỉ được quét: 0x50 - 0x5F

Bảng dữ liệu: ZZ0000ZZ

tác giả:
    - Marcello Sylvester Bauer <sylv@sylv.io>

Sự miêu tả
-----------

Vicor PLI1209BC là thiết bị giám sát hệ thống điện kỹ thuật số biệt lập cung cấp
giao diện liên lạc giữa bộ xử lý chủ và một Mô-đun chuyển đổi Bus
(BCM). PLI giao tiếp với bộ điều khiển hệ thống thông qua PMBus tương thích
giao diện qua giao diện UART bị cô lập. Thông qua PLI, bộ xử lý chủ
có thể định cấu hình, đặt giới hạn bảo vệ và giám sát BCM.

Mục nhập hệ thống
-------------

=====================================================================================
in1_label "vin2"
in1_input Điện áp đầu vào.
in1_rated_min Điện áp đầu vào định mức tối thiểu.
in1_rated_max Điện áp đầu vào định mức tối đa.
in1_max Điện áp đầu vào tối đa.
in1_max_alarm Báo động điện áp đầu vào cao.
in1_crit Điện áp đầu vào tới hạn.
in1_crit_alarm Cảnh báo quan trọng về điện áp đầu vào.

in2_label "vout2"
in2_input Điện áp đầu ra.
in2_rated_min Điện áp đầu ra định mức tối thiểu.
in2_rated_max Điện áp đầu ra định mức tối đa.
in2_alarm Cảnh báo điện áp đầu ra

curr1_label "iin2"
curr1_input Dòng điện đầu vào.
curr1_max Dòng điện đầu vào tối đa.
curr1_max_alarm Báo động cao hiện tại đầu vào tối đa.
curr1_crit Dòng điện đầu vào tới hạn.
curr1_crit_alarm Nhập cảnh báo quan trọng hiện tại.

curr2_label "iout2"
curr2_input Dòng điện đầu ra.
curr2_crit Dòng điện đầu ra tới hạn.
curr2_crit_alarm Xuất cảnh báo quan trọng hiện tại.
curr2_max Dòng điện đầu ra tối đa.
curr2_max_alarm Xuất cảnh báo hiện tại ở mức cao.

power1_label "pin2"
power1_input Nguồn điện đầu vào.
power1_alarm Báo động nguồn đầu vào.

power2_label "bĩu môi2"
power2_input Công suất đầu ra.
power2_rated_max Công suất đầu ra định mức tối đa.

temp1_input Nhiệt độ khuôn.
temp1_alarm Báo động nhiệt độ chết.
temp1_max Nhiệt độ khuôn tối đa.
temp1_max_alarm Báo động nhiệt độ cao.
temp1_crit Nhiệt độ khuôn tới hạn.
temp1_crit_alarm Báo động nhiệt độ quan trọng.
=====================================================================================