.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/gxp-fan-ctrl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân gxp-fan-ctrl
======================================

Chip được hỗ trợ:

* HPE GXP SOC

Tác giả: Nick Hawkins <nick.hawkins@hpe.com>


Sự miêu tả
-----------

gxp-fan-ctrl là trình điều khiển cung cấp khả năng điều khiển quạt cho hpe gxp soc.
Driver cho phép thu thập trạng thái quạt và sử dụng quạt
Điều khiển PWM.


Thuộc tính Sysfs
----------------

========================================================================================
pwm[0-7] Quạt 0 đến 7 giá trị PWM tương ứng (0-255)
fan[0-7]_fault Quạt 0 đến 7 trạng thái lỗi tương ứng: 1 lỗi, 0 ok
fan[0-7]_enable Quạt 0 đến 7 trạng thái bật tương ứng: 1 bật, 0 tắt
========================================================================================