.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/gxp-fan-ctrl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân gxp-fan-ctrl
==========================

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