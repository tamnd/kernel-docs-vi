.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/pci-cardlist.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển PCI
===========

Các bảng PCI được xác định bằng mã nhận dạng có tên PCI ID. ID PCI
thực sự được sáng tác bởi hai phần:

- ID nhà cung cấp và ID thiết bị;
	- ID hệ thống con và ID thiết bị hệ thống con;

Lệnh ZZ0000ZZ cho phép xác định ID PCI của nhà cung cấp/thiết bị:

.. code-block:: none
   :emphasize-lines: 3

    $ lspci -nn
    ...
    00:0a.0 Multimedia controller [0480]: Philips Semiconductors SAA7131/SAA7133/SAA7135 Video Broadcast Decoder [1131:7133] (rev d1)
    00:0b.0 Multimedia controller [0480]: Brooktree Corporation Bt878 Audio Capture [109e:0878] (rev 11)
    01:00.0 Multimedia video controller [0400]: Conexant Systems, Inc. CX23887/8 PCIe Broadcast Audio and Video Decoder with 3D Comb [14f1:8880] (rev 0f)
    02:01.0 Multimedia video controller [0400]: Internext Compression Inc iTVC15 (CX23415) Video Decoder [4444:0803] (rev 01)
    02:02.0 Multimedia video controller [0400]: Conexant Systems, Inc. CX23418 Single-Chip MPEG-2 Encoder with Integrated Analog Video/Broadcast Audio Decoder [14f1:5b7a]
    02:03.0 Multimedia video controller [0400]: Brooktree Corporation Bt878 Video Capture [109e:036e] (rev 11)
    ...

ID hệ thống con có thể được lấy bằng ZZ0000ZZ

.. code-block:: none
   :emphasize-lines: 4

    $ lspci -vn
    ...
	00:0a.0 0480: 1131:7133 (rev d1)
		Subsystem: 1461:f01d
		Flags: bus master, medium devsel, latency 32, IRQ 209
		Memory at e2002000 (32-bit, non-prefetchable) [size=2K]
		Capabilities: [40] Power Management version 2
    ...

Ở ví dụ trên, thẻ đầu tiên sử dụng trình điều khiển ZZ0001ZZ và
có ID nhà cung cấp/thiết bị PCI bằng ZZ0002ZZ và hệ thống con PCI
ID bằng ZZ0003ZZ (xem ZZ0000ZZ).

Thật không may, đôi khi cùng một ID hệ thống con PCI được sử dụng bởi nhiều người khác nhau.
sản phẩm. Vì vậy, một số trình điều khiển phương tiện cho phép truyền tham số ZZ0000ZZ,
để thiết lập số thẻ khớp với cài đặt chính xác cho
một bảng cụ thể.

Các thẻ PCI/PCIe được hỗ trợ hiện tại (không bao gồm trình điều khiển dàn dựng) là
được liệt kê bên dưới\ [#]_.

.. [#] some of the drivers have sub-drivers, not shown at this table

=============================================================================
Tên tài xế
=============================================================================
mô-đun CI dựa trên Altera-ci Altera FPGA
b2c2-flexcop-pci Technisat/B2C2 Air/Sky/Cable2PC PCI
bt878 DVB/ATSC Hỗ trợ card TV dựa trên bt878
Video bttv BT8x8 dành cho Linux
coban Cisco Coban
cx18 Bộ mã hóa Conexant cx23418 MPEG
cx23885 Conexant cx23885 (người kế nhiệm 2388x)
cx25821 Liên kết cx25821
cx88xx Conexant 2388x (người kế nhiệm bt878)
Cầu thiết bị kỹ thuật số ddbridge
dm1105 SDMC DM1105 dựa trên thẻ PCI
Dụng cụ lấy khung dt3155 DT3155
thẻ dvb-ttpci AV7110
thẻ Earth-pt1 PT1
Earth-pt3 Thẻ Earthsoft PT3
hexium_gemini Công cụ lấy khung Hexium Gemini
hexium_orion Hexium HV-PCI6 và bộ lấy khung Orion
thẻ dựa trên phễu HOPPER
ipu3-cio2 Trình điều khiển Intel ipu3-cio2
ivtv Conexant cx23416/cx23415 Bộ mã hóa/giải mã MPEG
ivtvfb Bộ đệm khung Conexant cx23415
thẻ dựa trên bọ ngựa MANTIS
mgb4 Digiteq Ô tô MGB4 bộ lấy khung
mxb Siemens-Nixdorf 'Bảng mở rộng đa phương tiện'
netup-unidvb Thẻ NetUP Universal DVB
ngene Micronas nGene
thẻ Pluto2 Pluto2
saa7134 Philips SAA7134
saa7164 NXP SAA7164
Thẻ smipcie SMI PCIe DVBSky
thẻ chụp solo6x10 Bluecherry / Softlogic 6x10 (MPEG-4/H.264)
tw5864 Bộ mã hóa và lấy video/âm thanh Techwell TW5864
tw686x Intersil/Techwell TW686x
tw68 Techwell tw68x Video dành cho Linux
Bộ giải mã zoran Zoran-36057/36067 JPEG
=============================================================================

Một số trình điều khiển đó hỗ trợ nhiều thiết bị, như được hiển thị ở thẻ
danh sách dưới đây:

.. toctree::
	:maxdepth: 1

	bttv-cardlist
	cx18-cardlist
	cx23885-cardlist
	cx88-cardlist
	ivtv-cardlist
	saa7134-cardlist
	saa7164-cardlist
	zoran-cardlist