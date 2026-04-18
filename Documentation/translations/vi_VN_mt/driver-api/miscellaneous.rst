.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/miscellaneous.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Thiết bị cổng song song
=======================

.. kernel-doc:: include/linux/parport.h
   :internal:

.. kernel-doc:: drivers/parport/ieee1284.c
   :export:

.. kernel-doc:: drivers/parport/share.c
   :export:

.. kernel-doc:: drivers/parport/daisy.c
   :internal:

Trình điều khiển 16x50 UART
===========================

.. kernel-doc:: drivers/tty/serial/8250/8250_core.c
   :export:

Xem serial/driver.rst để biết các API liên quan.

Điều chế độ rộng xung (PWM)
============================

Điều chế độ rộng xung là một kỹ thuật điều chế chủ yếu được sử dụng để
điều khiển nguồn điện cung cấp cho các thiết bị điện.

Khung PWM cung cấp sự trừu tượng hóa cho các nhà cung cấp và người tiêu dùng
Tín hiệu PWM. Bộ điều khiển cung cấp một hoặc nhiều tín hiệu PWM
được đăng ký là ZZ0000ZZ. Nhà cung cấp
dự kiến ​​sẽ nhúng cấu trúc này vào cấu trúc dành riêng cho trình điều khiển.
Cấu trúc này chứa các trường mô tả một con chip cụ thể.

Một con chip hiển thị một hoặc nhiều nguồn tín hiệu PWM, mỗi nguồn được hiển thị dưới dạng
một chiếc ZZ0000ZZ. Các hoạt động có thể được
được thực hiện trên các thiết bị PWM để kiểm soát chu kỳ, chu kỳ nhiệm vụ, cực tính và
trạng thái hoạt động của tín hiệu.

Lưu ý rằng các thiết bị PWM là tài nguyên độc quyền: chúng luôn chỉ có thể được
được sử dụng bởi một người tiêu dùng tại một thời điểm.

.. kernel-doc:: include/linux/pwm.h
   :internal:

.. kernel-doc:: drivers/pwm/core.c
   :export:
