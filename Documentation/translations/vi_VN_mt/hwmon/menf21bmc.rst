.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/menf21bmc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân menf21bmc_hwmon
=============================

Chip được hỗ trợ:

* MEN 14F021P00

Tiền tố: 'menf21bmc_hwmon'

Địa chỉ được quét: -

Tác giả: Andreas Werner <andreas.werner@men.de>

Sự miêu tả
-----------

menf21bmc là Bộ điều khiển quản lý bảng (BMC) cung cấp I2C
giao diện với máy chủ để truy cập các tính năng được triển khai trong BMC.

Trình điều khiển này cho phép truy cập vào tính năng giám sát điện áp của thiết bị chính
điện áp của bảng.
Các cảm biến điện áp được kết nối với đầu vào ADC của BMC.
Bộ điều khiển Mikro PIC16F917.

Ghi chú sử dụng
-----------

Trình điều khiển này là một phần của trình điều khiển MFD có tên "menf21bmc" và có
không tự động phát hiện thiết bị.
Bạn sẽ phải khởi tạo trình điều khiển MFD một cách rõ ràng.
Vui lòng xem Documentation/i2c/instantiating-devices.rst để biết
chi tiết.

Mục nhập hệ thống
-------------

Các thuộc tính sau được hỗ trợ. Tất cả các thuộc tính chỉ đọc
Giới hạn được đọc một lần bởi người lái xe.

=============================================
in0_input +3,3V điện áp đầu vào
in1_input +5.0V điện áp đầu vào
in2_input +12.0V điện áp đầu vào
in3_input +5V Điện áp đầu vào dự phòng
in4_input VBAT (pin trên bo mạch)

in[0-4]_min Giới hạn điện áp tối thiểu
in[0-4]_max Giới hạn điện áp tối đa

in0_label "MON_3_3V"
in1_label "MON_5V"
in2_label "MON_12V"
in3_label "5V_STANDBY"
in4_label "VBAT"
=============================================
