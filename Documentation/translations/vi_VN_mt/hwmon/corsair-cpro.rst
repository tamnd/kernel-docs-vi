.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/corsair-cpro.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân corsair-cpro
==========================

Các thiết bị được hỗ trợ:

* Corsair Commander Pro
  * Corsair Commander Pro (1000D)

Tác giả: Marius Zachmann

Sự miêu tả
-----------

Trình điều khiển này triển khai giao diện sysfs cho Corsair Commander Pro.
Corsair Commander Pro là thiết bị USB có 6 đầu nối quạt,
4 đầu nối cảm biến nhiệt độ và 2 đầu nối Corsair LED.
Nó có thể đọc các mức điện áp trên đầu nối nguồn SATA.

Ghi chú sử dụng
-----------

Vì là thiết bị USB nên có thể trao đổi nóng. Thiết bị được tự động phát hiện.

Mục nhập hệ thống
-------------

===================================================================================================
in0_Điện áp đầu vào trên SATA 12v
in1_input Điện áp trên SATA 5v
in2_input Điện áp trên SATA 3.3v
temp[1-4]_input Nhiệt độ trên cảm biến nhiệt độ được kết nối
fan[1-6]_input Vòng tua quạt được kết nối.
fan[1-6]_label Hiển thị loại quạt được thiết bị phát hiện.
fan[1-6]_target Đặt vòng/phút mục tiêu tốc độ quạt.
			Khi đọc, nó sẽ báo giá trị cuối cùng nếu được trình điều khiển đặt.
			Ngược lại sẽ trả về lỗi.
pwm[1-6] Đặt tốc độ quạt. Giá trị từ 0-255. Chỉ có thể đọc được nếu pwm
			đã được thiết lập trực tiếp.
===================================================================================================

Mục gỡ lỗi
---------------

=============================================
firmware_version Phiên bản phần sụn
bootloader_version Phiên bản bộ nạp khởi động
=============================================