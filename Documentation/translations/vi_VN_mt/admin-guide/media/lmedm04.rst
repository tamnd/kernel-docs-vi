.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/lmedm04.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Tệp chương trình cơ sở cho thẻ lmedm04
================================

Để giải nén phần sụn cho DM04/QQBOX, bạn cần sao chép tệp
(các) tệp sau đây vào thư mục này.

Dành cho DM04+/QQBOX LME2510C (Bộ chỉnh sắc nét 7395)
-------------------------------------------

Trình điều khiển Sharp 7395 có thể được tìm thấy trong windows/system32/drivers

US2A0D.sys (ngày 17 tháng 3 năm 2009)


và chạy:

.. code-block:: none

	scripts/get_dvb_firmware lme2510c_s7395

sẽ tạo ra dvb-usb-lme2510c-s7395.fw

Có thể tìm thấy phần sụn thay thế nhưng cũ hơn trên trình điều khiển
đĩa DVB-S_EN_3.5A trong BDADriver/trình điều khiển

LMEBDA_DVBS7395C.sys (ngày 18 tháng 1 năm 2008)

và chạy:

.. code-block:: none

	./get_dvb_firmware lme2510c_s7395_old

sẽ tạo ra dvb-usb-lme2510c-s7395.fw

Phần sụn LG có thể được tìm thấy trên trình điều khiển
đĩa DM04+_5.1A[LG] trong BDADriver/trình điều khiển

Dành cho DM04 LME2510 (Bộ điều chỉnh LG)
---------------------------

LMEBDA_DVBS.sys (ngày 13 tháng 11 năm 2007)

và chạy:


.. code-block:: none

	./get_dvb_firmware lme2510_lg

sẽ tạo ra dvb-usb-lme2510-lg.fw


Phần sụn LG khác có thể được trích xuất thủ công từ US280D.sys
chỉ tìm thấy trong windows/system32/drivers

dd if=US280D.sys ibs=1 Skip=42360 count=3924 of=dvb-usb-lme2510-lg.fw

Dành cho DM04 LME2510C (Bộ điều chỉnh LG)
----------------------------

.. code-block:: none

	dd if=US280D.sys ibs=1 skip=35200 count=3850 of=dvb-usb-lme2510c-lg.fw


Trình điều khiển bộ chỉnh Sharp 0194 có thể được tìm thấy trong windows/system32/drivers

US290D.sys (ngày 09 tháng 4 năm 2009)

Dành cho LME2510
-----------

.. code-block:: none

	dd if=US290D.sys ibs=1 skip=36856 count=3976 of=dvb-usb-lme2510-s0194.fw


Dành cho LME2510C
------------


.. code-block:: none

	dd if=US290D.sys ibs=1 skip=33152 count=3697 of=dvb-usb-lme2510c-s0194.fw


Trình điều khiển bộ chỉnh m88rs2000 có thể được tìm thấy trong windows/system32/drivers

US2B0D.sys (ngày 29 tháng 6 năm 2010)


.. code-block:: none

	dd if=US2B0D.sys ibs=1 skip=34432 count=3871 of=dvb-usb-lme2510c-rs2000.fw

Chúng ta cần sửa đổi id của firmware rs2000 nếu không nó sẽ khởi động id khởi động 3344:1120.


.. code-block:: none


	echo -ne \\xF0\\x22 | dd conv=notrunc bs=1 count=2 seek=266 of=dvb-usb-lme2510c-rs2000.fw

Sao chép (các) tệp chương trình cơ sở vào /lib/firmware