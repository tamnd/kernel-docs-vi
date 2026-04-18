.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/bpa-rs600.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân bpa-rs600
=======================

Chip được hỗ trợ:

* BPA-RS600-120

Bảng dữ liệu: Có sẵn công khai tại trang web BluTek
       ZZ0000ZZ

tác giả:
      - Chris Packham <chris.packham@allyedtelesis.co.nz>

Sự miêu tả
-----------

BPA-RS600 là mô-đun nguồn điện có thể tháo rời 600W nhỏ gọn.

Ghi chú sử dụng
-----------

Trình điều khiển này không thăm dò các thiết bị PMBus. Bạn sẽ phải khởi tạo
thiết bị một cách rõ ràng.

Thuộc tính Sysfs
----------------

========================================================================
curr1_label "iin"
curr1_input Đo dòng điện đầu vào
curr1_max Dòng điện đầu vào tối đa
curr1_max_alarm Nhập cảnh báo hiện tại ở mức cao

curr2_label "iout1"
curr2_input Đo dòng điện đầu ra
curr2_max Dòng điện đầu ra tối đa
curr2_max_alarm Dòng điện báo động cao

fan1_input Tốc độ quạt đo được
fan1_alarm Cảnh báo của người hâm mộ
fan1_fault Lỗi quạt

in1_label "vin"
in1_input Đo điện áp đầu vào
in1_max Điện áp đầu vào tối đa
in1_max_alarm Báo động điện áp đầu vào cao
in1_min Điện áp đầu vào tối thiểu
in1_min_alarm Báo động điện áp đầu vào thấp

in2_label "vout1"
in2_input Đo điện áp đầu ra
in2_max Điện áp đầu ra tối đa
in2_max_alarm Báo động điện áp đầu ra cao
in2_min Điện áp đầu ra tối đa
in2_min_alarm Báo động điện áp đầu ra thấp

power1_label "pin"
power1_input Công suất đầu vào đo được
power1_alarm Báo động nguồn đầu vào
power1_max Công suất đầu vào tối đa

power2_label "bĩu môi1"
power2_input Công suất đầu ra đo được
power2_max Công suất đầu ra tối đa
power2_max_alarm Báo động công suất đầu ra cao

temp1_input Đo nhiệt độ xung quanh đầu nối đầu vào
temp1_alarm Báo động nhiệt độ

temp2_input Đo nhiệt độ xung quanh đầu nối đầu ra
temp2_alarm Báo động nhiệt độ
========================================================================