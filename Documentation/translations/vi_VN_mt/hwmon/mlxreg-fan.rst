.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/mlxreg-fan.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân mlxreg-fan
========================

Cung cấp khả năng điều khiển FAN cho các hệ thống Mellanox tiếp theo:

- QMB700, được trang bị cổng InfiniBand 40x200GbE;
- MSN3700, được trang bị cổng Ethernet 32x200GbE hoặc 16x400GbE;
- MSN3410, được trang bị cổng Ethernet 6x400GbE cộng với 48x50GbE;
- MSN3800, được trang bị cổng Ethernet 64x1000GbE;

Tác giả: Vadim Pasternak <vadimp@mellanox.com>

Đây là những hệ thống Top of the Rack được trang bị switch Mellanox
bảng với các thiết bị Mellanox Quantum hoặc Spectrume-2.
Bộ điều khiển FAN được triển khai bằng logic thiết bị lập trình.

Độ lệch thanh ghi mặc định được đặt trong thiết bị lập trình là như
sau đây:

========================= ====
pwm1 0xe3
fan1 (tacho1) 0xe4
fan2 (tacho2) 0xe5
fan3 (tacho3) 0xe6
fan4 (tacho4) 0xe7
fan5 (tacho5) 0xe8
fan6 (tacho6) 0xe9
fan7 (tacho7) 0xea
fan8 (tacho8) 0xeb
fan9 (tacho9) 0xec
fan10 (tacho10) 0xed
fan11 (tacho11) 0xee
fan12 (tacho12) 0xef
========================= ====

Thiết lập này có thể được lập trình lại với các thanh ghi khác.

Sự miêu tả
-----------

Trình điều khiển thực hiện một giao diện đơn giản để điều khiển quạt được kết nối với
đầu ra PWM và đầu vào máy đo tốc độ.
Trình điều khiển này nhận được PWM và vị trí đăng ký máy đo tốc độ theo
cấu hình hệ thống và tạo các đối tượng hwmon FAN/PWM và hệ thống làm mát
thiết bị. PWM và máy đo tốc độ được cảm nhận thông qua bộ điều khiển có thể lập trình trên bo mạch
thiết bị xuất bản đồ đăng ký của nó. Thiết bị này có thể được gắn vào
bất kỳ loại xe buýt nào được hỗ trợ ánh xạ đăng ký.
Một phiên bản duy nhất được tạo bằng một bộ điều khiển PWM, tối đa 12 máy đo tốc độ và
một thiết bị làm mát. Nó có thể có nhiều trường hợp như thiết bị lập trình
hỗ trợ.
Trình điều khiển đưa quạt tới không gian người dùng thông qua hwmon và
giao diện sysfs của nhiệt.

/sys tập tin trong hệ thống con hwmon
-----------------------------

================== =========================================================
fan[1-12]_fault Tệp RO cho máy đo tốc độ TACH1-TACH12 chỉ báo lỗi
fan[1-12]_input Tệp RO cho máy đo tốc độ Đầu vào TACH1-TACH12 (trong RPM)
Tệp pwm1 RW cho chu kỳ nhiệm vụ mục tiêu của quạt [1-12] (0..255)
================== =========================================================

/sys trong hệ thống con nhiệt
-------------------------------

================== ==========================================================
Tệp cur_state RW cho trạng thái làm mát hiện tại của thiết bị làm mát
		     (0..max_state)
Tệp RO max_state để có trạng thái làm mát tối đa của thiết bị làm mát
================== ==========================================================
