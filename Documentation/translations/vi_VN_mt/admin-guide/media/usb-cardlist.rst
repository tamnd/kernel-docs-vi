.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/usb-cardlist.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển USB
===========

Các bảng USB được xác định bằng mã nhận dạng có tên USB ID.

Lệnh ZZ0000ZZ cho phép xác định ID USB::

$ lsusb
    ...
Bus 001 Thiết bị 015: ID 046d:082d Logitech, Inc. Webcam HD Pro C920
    Xe buýt 001 Thiết bị 074: ID 2040:b131 Hauppauge
    Bus 001 Thiết bị 075: ID 2013:024f PCTV Hệ thống nanoStick T2 290e
    ...

Các thiết bị máy ảnh mới hơn sử dụng cách tiêu chuẩn để phơi sáng như vậy,
thông qua lớp video USB. Những camera đó được tự động hỗ trợ bởi
ZZ0000ZZ.

Máy ảnh và thiết bị TV USB cũ hơn sử dụng Lớp nhà cung cấp USB: mỗi nhà cung cấp
xác định cách riêng của mình để truy cập vào thiết bị. Phần này chứa
danh sách thẻ cho các thiết bị cấp nhà cung cấp như vậy.

Mặc dù điều này không phổ biến như trên PCI nhưng đôi khi ID USB tương tự được sử dụng
bằng các sản phẩm khác nhau. Vì vậy, một số trình điều khiển phương tiện cho phép chuyển ZZ0000ZZ
tham số, để thiết lập số thẻ khớp với thông số chính xác
cài đặt cho một loại sản phẩm cụ thể.

Các thẻ USB được hỗ trợ hiện tại (không bao gồm trình điều khiển dàn dựng) là
được liệt kê bên dưới\ [#]_.

.. [#]

   some of the drivers have sub-drivers, not shown at this table.
   In particular, gspca driver has lots of sub-drivers,
   for cameras not supported by the USB Video Class (UVC) driver,
   as shown at :doc:`gspca card list <gspca-cardlist>`.

=====================================================================================
Tên tài xế
=====================================================================================
airspy AirSpy
au0828 Auvitek AU0828
b2c2-flexcop-usb Technisat/B2C2 Air/Sky/Cable2PC USB
cx231xx Conexant cx231xx USB quay video
Đầu thu dvb-as102 Abilis AS102 DVB
dvb-ttusb-ngân sách Technotrend/Hauppauge Nova - thiết bị USB
dvb-usb-a800 AVerMedia AverTV DVB-T USB 2.0 (A800)
dvb-usb-af9005 Afatech AF9005 DVB-T USB1.1
dvb-usb-af9015 Afatech AF9015 DVB-T USB2.0
dvb-usb-af9035 Afatech AF9035 DVB-T USB2.0
dvb-usb-anysee Anysee DVB-T/C USB2.0
dvb-usb-au6610 Alcor Micro AU6610 USB2.0
dvb-usb-az6007 AzureWave 6007 và bản sao DVB-T/C USB2.0
dvb-usb-az6027 Azurewave DVB-S/S2 USB2.0 AZ6027
dvb-usb-ce6230 Intel CE6230 DVB-T USB2.0
dvb-usb-cinergyT2 Terratec CinergyT2/qanu USB 2.0 DVB-T
lai dvb-usb-cxusb Conexant USB2.0
dvb-usb-dib0700 DiBcom DiB0700
dvb-usb-dibusb-common DiBcom DiB3000M-B
dvb-usb-dibusb-mc DiBcom DiB3000M-C/P
dvb-usb-digitv Nebula Electronics uDigiTV DVB-T USB2.0
dvb-usb-dtt200u WideView WT-200U và WT-220U (bút) DVB-T
dvb-usb-dtv5100 AME DTV-5100 USB2.0 DVB-T
dvb-usb-dvbsky DVBSky USB
dvb-usb-dw2102 DvbWorld & TeVii DVB-S/S2 USB2.0
dvb-usb-ec168 E3C EC168 DVB-T USB2.0
dvb-usb-gl861 Genesys Logic GL861 USB2.0
mô-đun dvb-usb-gp8psk GENPIX 8PSK->USB
dvb-usb-lmedm04 LME DM04/QQBOX DVB-S USB2.0
dvb-usb-m920x Uli m920x DVB-T USB2.0
dvb-usb-nova-t-usb2 Hauppauge WinTV-NOVA-T usb2 DVB-T USB2.0
Bộ thu dvb-usb-opera Opera1 DVB-S USB2.0
dvb-usb-pctv452e Pinnacle PCTV HDTV Pro USB thiết bị/TT Connect S2-3600
dvb-usb-rtl28xxu Realtek RTL28xxU DVB USB
dvb-usb-technisat-usb2 Technisat DVB-S/S2 USB2.0
dvb-usb-ttusb2 Đỉnh cao 400e DVB-S USB2.0
dvb-usb-umt-010 HanfTek UMT-010 DVB-T USB2.0
dvb_usb_v2 Hỗ trợ nhiều thiết bị USB DVB v2
dvb-usb-vp702x TwinhanDTV StarBox và bản sao DVB-S USB2.0
dvb-usb-vp7045 TwinhanDTV Alpha/MagicBoxII, DNTV tinyUSB2, Beetle USB2.0
em28xx Empia EM28xx USB thiết bị
go7007 WIS GO7007 MPEG bộ mã hóa
Trình điều khiển gspca cho một số Máy ảnh USB
hackrf HackRF
hdpvr Hauppauge HD PVR
msi2500 Mirics MSi2500
bộ điều chỉnh mxl111sf MxL111SF DTV USB2.0
pvrusb2 Hauppauge WinTV-PVR USB2
Máy ảnh Philips pwc USB
s2250 Cảm biến 2250/2251
s2255drv USB Thiết bị quay video Sensoray 2255
smsusb Siano SMS1xxx dựa trên bộ thu MDTV
ttusb_dec Thiết bị Technotrend/Hauppauge USB DEC
quay video usbtv USBTV007
Lớp video uvcvideo USB (UVC)
zd1301 ZyDAS ZD1301
=====================================================================================

.. toctree::
	:maxdepth: 1

	au0828-cardlist
	cx231xx-cardlist
	em28xx-cardlist
	siano-cardlist

	gspca-cardlist

	dvb-usb-dib0700-cardlist
	dvb-usb-dibusb-mb-cardlist
	dvb-usb-dibusb-mc-cardlist

	dvb-usb-a800-cardlist
	dvb-usb-af9005-cardlist
	dvb-usb-az6027-cardlist
	dvb-usb-cinergyT2-cardlist
	dvb-usb-cxusb-cardlist
	dvb-usb-digitv-cardlist
	dvb-usb-dtt200u-cardlist
	dvb-usb-dtv5100-cardlist
	dvb-usb-dw2102-cardlist
	dvb-usb-gp8psk-cardlist
	dvb-usb-m920x-cardlist
	dvb-usb-nova-t-usb2-cardlist
	dvb-usb-opera1-cardlist
	dvb-usb-pctv452e-cardlist
	dvb-usb-technisat-usb2-cardlist
	dvb-usb-ttusb2-cardlist
	dvb-usb-umt-010-cardlist
	dvb-usb-vp702x-cardlist
	dvb-usb-vp7045-cardlist

	dvb-usb-af9015-cardlist
	dvb-usb-af9035-cardlist
	dvb-usb-anysee-cardlist
	dvb-usb-au6610-cardlist
	dvb-usb-az6007-cardlist
	dvb-usb-ce6230-cardlist
	dvb-usb-dvbsky-cardlist
	dvb-usb-ec168-cardlist
	dvb-usb-gl861-cardlist
	dvb-usb-lmedm04-cardlist
	dvb-usb-mxl111sf-cardlist
	dvb-usb-rtl28xxu-cardlist
	dvb-usb-zd1301-cardlist

	other-usb-cardlist