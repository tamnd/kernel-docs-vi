.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/stef48h28.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân stef48h28
=======================

Chip được hỗ trợ:

* Thiết bị tương tự STEF48H28

Tiền tố: 'stef48h28'

Địa chỉ được quét: -

Bảng dữ liệu: ZZ0000ZZ

Tác giả:

- Charles Hsu <hsu.yungteng@gmail.com>


Sự miêu tả
-----------

STEF48H28 là cầu chì điện tử tích hợp 30 A cho đường ray nguồn 9-80 V DC.
Nó cung cấp khả năng kiểm soát khởi động, khóa điện áp thấp/quá áp và
bảo vệ quá dòng bằng cách sử dụng sơ đồ thích ứng (I x t) cho phép
các xung dòng điện cao ngắn điển hình của tải CPU/GPU.

Thiết bị này cung cấp đầu ra màn hình dòng điện tương tự và bộ điều khiển trên chip.
tín hiệu theo dõi nhiệt độ để giám sát hệ thống. Hành vi khởi động là
có thể lập trình thông qua cài đặt độ trễ chèn và khởi động mềm.

Các tính năng bổ sung bao gồm chỉ báo nguồn điện tốt, tự chẩn đoán,
tắt máy nhiệt và giao diện PMBus để đo từ xa và trạng thái
báo cáo.

Hỗ trợ dữ liệu nền tảng
---------------------

Trình điều khiển hỗ trợ dữ liệu nền tảng trình điều khiển PMBus tiêu chuẩn.

Mục nhập hệ thống
-------------

====================================================================================
in1_label "vin".
in1_input Đo điện áp. Từ đăng ký READ_VIN.
in1_min Điện áp tối thiểu. Từ đăng ký VIN_UV_WARN_LIMIT.
in1_max Điện áp tối đa. Từ đăng ký VIN_OV_WARN_LIMIT.

in2_label "vout1".
in2_input Đo điện áp. Từ đăng ký READ_VOUT.
in2_min Điện áp tối thiểu. Từ đăng ký VOUT_UV_WARN_LIMIT.
in2_max Điện áp tối đa. Từ đăng ký VOUT_OV_WARN_LIMIT.

curr1_label "iin".      curr1_input Đo dòng điện. Từ đăng ký READ_IIN.

curr2_label "iout1".    curr2_input Đo dòng điện. Từ đăng ký READ_IOUT.

power1_label "pin"
power1_input Đo công suất đầu vào. Từ đăng ký READ_PIN.

power2_label "bĩu môi1"
power2_input Đo công suất đầu ra. Từ đăng ký READ_POUT.

temp1_input Đo nhiệt độ. Từ đăng ký READ_TEMPERATURE_1.
temp1_max Nhiệt độ tối đa. Từ đăng ký OT_WARN_LIMIT.
temp1_crit Nhiệt độ cao tới hạn. Từ đăng ký OT_FAULT_LIMIT.

temp2_input Đo nhiệt độ. Từ đăng ký READ_TEMPERATURE_2.
====================================================================================