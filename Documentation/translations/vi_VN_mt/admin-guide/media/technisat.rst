.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/technisat.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Cách thiết lập thiết bị Technisat/B2C2 Flexcop
================================================

.. note::

   This documentation is outdated.

Tác giả: Uwe Bugla <uwe.bugla@gmx.de> Tháng 8 năm 2009

Tìm hiểu thiết bị bạn có
-----------------------------

Thông báo quan trọng: Trình điều khiển NOT hỗ trợ các thiết bị Technisat USB 2!

Trước tiên hãy khởi động hộp linux của bạn với kernel đã được vận chuyển:

.. code-block:: none

	lspci -vvv for a PCI device (lsusb -vvv for an USB device) will show you for example:
	02:0b.0 Network controller: Techsan Electronics Co Ltd B2C2 FlexCopII DVB chip /
	Technisat SkyStar2 DVB card (rev 02)

	dmesg | grep frontend may show you for example:
	DVB: registering frontend 0 (Conexant CX24123/CX24109)...

Biên dịch hạt nhân:
-------------------

Nếu Flexcop / Technisat là thiết bị DVB / TV / Radio duy nhất trong hộp của bạn
loại bỏ các mô-đun không cần thiết và kiểm tra cái này:

ZZ0000ZZ => ZZ0001ZZ

Trong thư mục này bỏ chọn mọi trình điều khiển được kích hoạt ở đó
(ngoại trừ ZZ0000ZZ chỉ dành cho ATSC thế hệ thứ 3 -> vui lòng xem trường hợp 9).

Sau đó vui lòng kích hoạt:

- Phần module chính:

ZZ0000ZZ => ZZ0001ZZ => ZZ0002ZZ

#) => ZZ0000ZZ (thẻ PCI) hoặc
  #) => ZZ0001ZZ (bộ chuyển đổi USB 1.1)
     và cho mục đích khắc phục sự cố:
  #) => ZZ0002ZZ

- Phần module Frontend/Tuner/Demodulator:

ZZ0000ZZ => ZZ0001ZZ
   => ZZ0002ZZ ZZ0003ZZ =>

- SkyStar DVB-S Phiên bản 2.3:

#) => ZZ0000ZZ
    #) => ZZ0001ZZ

- SkyStar DVB-S Phiên bản 2.6:

#) => ZZ0000ZZ
    #) => ZZ0001ZZ

- SkyStar DVB-S Phiên bản 2.7:

#) => ZZ0000ZZ
    #) => ZZ0001ZZ
    #) => ZZ0002ZZ

- SkyStar DVB-S Phiên bản 2.8:

#) => ZZ0000ZZ
    #) => ZZ0001ZZ
    #) => ZZ0002ZZ

- Thẻ AirStar DVB-T:

#) => ZZ0000ZZ
    #) => ZZ0001ZZ

- Card CableStar DVB-C:

#) => ZZ0000ZZ
    #) => ZZ0001ZZ

- Thẻ AirStar ATSC thế hệ 1:

#) => ZZ0000ZZ

- Thẻ AirStar ATSC thế hệ 2:

#) => ZZ0000ZZ
    #) => ZZ0001ZZ

- Thẻ AirStar ATSC thế hệ thứ 3:

#) => ZZ0000ZZ
    #) ZZ0001ZZ => ZZ0002ZZ => ZZ0003ZZ
