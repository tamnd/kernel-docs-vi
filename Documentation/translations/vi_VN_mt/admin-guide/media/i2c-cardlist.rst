.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/i2c-cardlist.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển I²C
===========

Bus I²C (Mạch tích hợp liên kết) là bus ba dây được sử dụng nội bộ
tại các thẻ nhớ để liên lạc giữa các chip khác nhau. Trong khi xe buýt
không hiển thị với hạt nhân Linux, trình điều khiển cần gửi và nhận
lệnh thông qua bus. Bản tóm tắt trình điều khiển hạt nhân Linux có hỗ trợ
triển khai các trình điều khiển khác nhau cho từng thành phần bên trong bus I2C, như thể
xe buýt đã được hiển thị trên bo mạch hệ thống chính.

Một trong những vấn đề với thiết bị I2C là đôi khi cùng một thiết bị có thể
hoạt động với phần cứng I²C khác nhau. Ví dụ: điều này phổ biến trên các thiết bị
đi kèm với bộ điều chỉnh dành cho thị trường Bắc Mỹ và một bộ điều chỉnh khác dành cho
Châu Âu. Một số trình điều khiển có tham số modprobe ZZ0000ZZ để cho phép sử dụng
số bộ điều chỉnh khác nhau để giải quyết vấn đề đó.

Trình điều khiển I2C được hỗ trợ hiện tại (không bao gồm trình điều khiển dàn dựng) là
được liệt kê dưới đây.

Bộ giải mã, bộ xử lý và bộ trộn âm thanh
-------------------------------------

============= ================================================================
Tên tài xế
============= ================================================================
cs3308 Cirrus Logic CS3308 âm thanh ADC
cs5345 Cirrus Logic CS5345 âm thanh ADC
cs53l32a Cirrus Logic CS53L32A âm thanh ADC
Bộ giải mã âm thanh MSP34xx Micronas MSP34xx
sony-btf-mpx MPX nội bộ của Sony BTF
Bộ thu tda1997x NXP TDA1997x HDMI
tda7432 Bộ xử lý âm thanh Philips TDA7432
tda9840 Bộ xử lý âm thanh Philips TDA9840
Tea6415c Bộ xử lý âm thanh Philips TEA6415C
Tea6420 Bộ xử lý âm thanh Philips TEA6420
tlv320aic23b Bộ giải mã âm thanh TLV320AIC23B của Texas Instruments
tvaudio Chip giải mã âm thanh đơn giản
uda1342 Bộ giải mã âm thanh Philips UDA1342
vp27smpx MPX nội bộ của Panasonic VP27
wm8739 Wolfson Vi điện tử WM8739 âm thanh nổi ADC
wm8775 Wolfson Microelectronics WM8775 âm thanh ADC với bộ trộn đầu vào
============= ================================================================

Chip nén âm thanh/video
-----------------------------

============= ================================================================
Tên tài xế
============= ================================================================
saa6752hs Bộ mã hóa âm thanh/video Philips SAA6752HS MPEG-2
============= ================================================================

Thiết bị cảm biến máy ảnh
---------------------

============= ================================================================
Tên tài xế
============= ================================================================
Cảm biến máy ảnh tương thích ccs MIPI CCS (cả SMIA++ và SMIA)
et8ek8 ET8EK8 cảm biến máy ảnh
cảm biến hi556 Hynix Hi-556
cảm biến hi846 Hynix Hi-846
cảm biến imx208 Sony IMX208
cảm biến imx214 Sony IMX214
cảm biến imx219 Sony IMX219
cảm biến imx258 Sony IMX258
cảm biến imx274 Sony IMX274
cảm biến imx290 Sony IMX290
cảm biến imx319 Sony IMX319
cảm biến imx334 Sony IMX334
cảm biến imx355 Sony IMX355
cảm biến imx412 Sony IMX412
mt9m001 mt9m001
mt9m111 mt9m111, mt9m112 và mt9m131
mt9p031 Aptina MT9P031
mt9t112 Aptina MT9T111/MT9T112
cảm biến mt9v011 Micron mt9v011
Cảm biến mt9v032 Micron MT9V032
Cảm biến mt9v111 Aptina MT9V111
ov13858 Cảm biến OmniVision OV13858
ov13b10 Cảm biến OmniVision OV13B10
ov2640 Cảm biến OmniVision OV2640
ov2659 Cảm biến OmniVision OV2659
ov2680 Cảm biến OmniVision OV2680
ov2685 Cảm biến OmniVision OV2685
ov5640 Cảm biến OmniVision OV5640
ov5645 Cảm biến OmniVision OV5645
ov5647 Cảm biến OmniVision OV5647
ov5670 Cảm biến OmniVision OV5670
ov5675 Cảm biến OmniVision OV5675
ov5695 Cảm biến OmniVision OV5695
ov7251 Cảm biến OmniVision OV7251
ov7640 Cảm biến OmniVision OV7640
ov7670 Cảm biến OmniVision OV7670
ov772x Cảm biến OmniVision OV772x
ov7740 Cảm biến OmniVision OV7740
ov8856 Cảm biến OmniVision OV8856
ov9640 Cảm biến OmniVision OV9640
ov9650 Cảm biến OmniVision OV9650/OV9652
rj54n1cb0c Cảm biến RJ54N1CB0C sắc nét
s5c73m3 Cảm biến Samsung S5C73M3
s5k4ecgx Cảm biến Samsung S5K4ECGX
s5k5baf Cảm biến Samsung S5K5BAF
s5k6a3 Cảm biến Samsung S5K6A3
============= ================================================================

Thiết bị flash
-------------

============= ================================================================
Tên tài xế
============= ================================================================
đèn flash adp1653 ADP1653
Trình điều khiển đèn flash kép lm3560 LM3560
Trình điều khiển đèn flash kép lm3646 LM3646
============= ================================================================

Trình điều khiển IR I2C
-------------

============= ================================================================
Tên tài xế
============= ================================================================
mô-đun ir-kbd-i2c I2C cho IR
============= ================================================================

Trình điều khiển ống kính
------------

============= ================================================================
Tên tài xế
============= ================================================================
cuộn dây thoại ống kính ad5820 AD5820
cuộn dây thoại ống kính ak7375 AK7375
cuộn dây thoại ống kính dw9714 DW9714
cuộn dây thoại ống kính dw9768 DW9768
cuộn dây thoại ống kính dw9807-vcm DW9807
============= ================================================================

Chip trợ giúp khác
--------------------------

============= ================================================================
Tên tài xế
============= ================================================================
video-i2c I2C vận chuyển video
m52790 Công tắc A/V Mitsubishi M52790
st-mipid02 STMicroelectronics MIPID02 CSI-2 đến cầu nối PARALLEL
Bộ khuếch đại video ths7303 THS7303/53
============= ================================================================

Bộ giải mã RDS
------------

============= ================================================================
Tên tài xế
============= ================================================================
saa6588 SAA6588 Bộ giải mã Chip vô tuyến RDS
============= ================================================================

Chip điều chỉnh SDR
---------------

============= ================================================================
Tên tài xế
============= ================================================================
max2175 Maxim 2175 Bộ điều chỉnh RF sang Bits
============= ================================================================

Bộ giải mã video và âm thanh
------------------------

============= ================================================================
Tên tài xế
============= ================================================================
cx25840 Bộ giải mã âm thanh/video Conexant CX2584x
saa717x Bộ giải mã âm thanh/video Philips SAA7171/3/4
============= ================================================================

Bộ giải mã video
--------------

============= ================================================================
Tên tài xế
============= ================================================================
Adv7180 Thiết bị tương tự Bộ giải mã ADV7180
Adv7183 Thiết bị tương tự Bộ giải mã ADV7183
Adv748x Thiết bị tương tự Bộ giải mã ADV748x
Adv7604 Thiết bị tương tự Bộ giải mã ADV7604
Adv7842 Thiết bị tương tự Bộ giải mã ADV7842
bt819 BT819A Bộ giải mã VideoStream
bt856 BT856 Bộ giải mã VideoStream
bt866 BT866 Bộ giải mã VideoStream
ks0127 KS0127 bộ giải mã video
bộ giải mã video ml86v7667 OKI ML86V7667
saa7110 Bộ giải mã video Philips SAA7110
saa7115 Bộ giải mã video Philips SAA7111/3/4/5
tc358743 Bộ giải mã Toshiba TC358743
tvp514x Bộ giải mã video TVP514x của Texas Instruments
tvp5150 Bộ giải mã video TVP5150 của Texas Instruments
tvp7002 Bộ giải mã video TVP7002 của Texas Instruments
tw2804 Techwell TW2804 nhiều bộ giải mã video
Bộ giải mã video tw9903 Techwell TW9903
Bộ giải mã video tw9906 Techwell TW9906
Bộ giải mã video tw9910 Techwell TW9910
Bộ giải mã video vpx3220 vpx3220a, vpx3216b & vpx3214c
============= ================================================================

Bộ mã hóa video
--------------

============= ================================================================
Tên tài xế
============= ================================================================
Adv7170 Thiết bị analog Bộ mã hóa video ADV7170
Adv7175 Thiết bị tương tự Bộ mã hóa video ADV7175
Bộ mã hóa video Adv7343 ADV7343
Bộ mã hóa video Adv7393 ADV7393
adv7511-v4l2 Bộ mã hóa ADV7511 của thiết bị tương tự
Bộ mã hóa video ak881x AK8813/AK8814
saa7127 Bộ mã hóa video kỹ thuật số Philips SAA7127/9
saa7185 Bộ mã hóa video Philips SAA7185
ths8200 Bộ mã hóa video THS8200 của Texas Instruments
============= ================================================================

Chip cải tiến video
-----------------------

============= ================================================================
Tên tài xế
============= ================================================================
upd64031a NEC Điện tử uPD64031A Giảm bóng ma
upd64083 NEC Electronics uPD64083 Phân tách Y/C 3 chiều
============= ================================================================

Trình điều khiển bộ chỉnh
-------------

===================================================================
Tên tài xế
===================================================================
Bộ chỉnh silicon e4000 Elonics E4000
Bộ điều chỉnh silicon fc0011 Fitipower FC0011
Bộ điều chỉnh silicon fc0012 Fitipower FC0012
Bộ điều chỉnh silicon fc0013 Fitipower FC0013
Bộ điều chỉnh silicon fc2580 FCI FC2580
Bộ điều chỉnh silicon it913x ITE Tech IT913x
m88rs6000t Bộ điều chỉnh nội bộ Montage M88RS6000
Bộ điều chỉnh silicon max2165 Maxim MAX2165
mc44s803 Freescale MC44S803 Bộ điều chỉnh băng thông rộng CMOS công suất thấp
msi001 Mirics MSi001
mt2060 Bộ điều chỉnh IF silicon Microtune MT2060
mt2063 Bộ điều chỉnh IF silicon Microtune MT2063
Bộ chỉnh mt20xx Microtune 2032/2050
Bộ chỉnh silicon mt2131 Microtune MT2131
Bộ chỉnh silicon mt2266 Microtune MT2266
Bộ điều chỉnh mxl301rf MaxLinear MxL301RF
Bộ điều chỉnh silicon MaxLinear MSL5005S mxl5005s
Bộ điều chỉnh silicon mxl5007t MaxLinear MxL5007T
qm1d1b0004 Bộ điều chỉnh Sharp QM1D1B0004
qm1d1c0042 Bộ chỉnh sắc nét QM1D1C0042
Bộ điều chỉnh silicon qt1010 Quantek QT1010
Bộ chỉnh silicon r820t Rafael Micro R820T
si2157 Bộ điều chỉnh silicon Si2157 của Phòng thí nghiệm Silicon
các loại bộ chỉnh Hỗ trợ bộ chỉnh đơn giản
Bộ điều chỉnh silicon tda18212 NXP TDA18212
Bộ điều chỉnh silicon tda18218 NXP TDA18218
Bộ điều chỉnh silicon tda18250 NXP TDA18250
Bộ điều chỉnh silicon tda18271 NXP TDA18271
tda827x Bộ điều chỉnh silicon Philips TDA827X
tda8290 TDA 8290/8295 + 8275(a)/18271 kết hợp bộ điều chỉnh
tda9887 TDA 9885/6/7 bộ giải mã IF tương tự
Bộ dò đài Tea5761 TEA 5761
Bộ dò sóng radio Tea5767 TEA 5767
tua9001 Bộ chỉnh silicon Infineon TUA9001
Bộ điều chỉnh xc2028 XCeive xc2028/xc3028
Bộ điều chỉnh silicon xc4000 Xceive XC4000
Bộ điều chỉnh silicon xc5000 Xceive XC5000
===================================================================

.. toctree::
	:maxdepth: 1

	tuner-cardlist
	frontend-cardlist