.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/cardlist.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

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