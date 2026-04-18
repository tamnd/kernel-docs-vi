.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/cardlist.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========
Danh sách thẻ
==========

Hệ thống con phương tiện cung cấp hỗ trợ cho nhiều trình điều khiển PCI và USB, cùng với
trình điều khiển dành riêng cho nền tảng. Nó cũng chứa một số trình điều khiển I2C phụ trợ.

Trình điều khiển dành riêng cho nền tảng thường có trên các hệ thống nhúng,
hoặc được hỗ trợ bởi bo mạch chính. Thông thường, việc thiết lập chúng được thực hiện thông qua
OpenFirmware hoặc ACPI.

Tuy nhiên, trình điều khiển PCI và USB độc lập với bo mạch của hệ thống,
và người dùng có thể thêm/bớt.

Bạn cũng có thể xem qua
ZZ0000ZZ
để biết thêm chi tiết về các thẻ được hỗ trợ.

.. toctree::
	:maxdepth: 2

	usb-cardlist
	pci-cardlist
	platform-cardlist
	radio-cardlist
	i2c-cardlist
	misc-cardlist