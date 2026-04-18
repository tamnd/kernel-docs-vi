.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/frontend-cardlist.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==================
Trình điều khiển giao diện người dùng
================

.. note::

  #) There is no guarantee that every frontend driver works
     out of the box with every card, because of different wiring.

  #) The demodulator chips can be used with a variety of
     tuner/PLL chips, and not all combinations are supported. Often
     the demodulator and tuner/PLL chip are inside a metal box for
     shielding, and the whole metal box has its own part number.


Trình điều khiển bộ điều khiển Giao diện chung (EN50221)
=============================================

=============================================================================
Tên tài xế
=============================================================================
cxd2099 Trình điều khiển giao diện chung Sony CXD2099AR
sp2 CIMaX SP2
=============================================================================

Giao diện ATSC (Bắc Mỹ/Mặt đất Hàn Quốc/Cáp DTV)
============================================================

=============================================================================
Tên tài xế
=============================================================================
au8522_dig Auvitek AU8522 dựa trên bản demo DTV
au8522_decoding Auvitek AU8522 dựa trên bản demo ATV
bcm3510 Broadcom BCM3510
lg2160 LG Điện tử dựa trên LG216x
lgdt3305 LG Electronics LGDT3304 và LGDT3305 dựa trên
lgdt3306a LG Electronics LGDT3306A dựa trên
lgdt330x dựa trên LG Electronics LGDT3302/LGDT3303
nxt200x NxtWave Truyền thông dựa trên NXT2002/NXT2004
or51132 Oren OR51132 dựa trên
or51211 Oren OR51211 dựa trên
s5h1409 dựa trên Samsung S5H1409
s5h1411 dựa trên Samsung S5H1411
=============================================================================

Mặt trước DVB-C (cáp)
=======================

=============================================================================
Tên tài xế
=============================================================================
dựa trên stv0297 ST STV0297
tda10021 Philips TDA10021 dựa trên
tda10023 Philips TDA10023 dựa trên
dựa trên ves1820 VLSI VES1820
=============================================================================

Giao diện DVB-S (vệ tinh)
===========================

=============================================================================
Tên tài xế
=============================================================================
cx24110 Conexant CX24110 dựa trên
cx24116 Conexant CX24116 dựa trên
cx24117 Conexant CX24117 dựa trên
cx24120 Conexant CX24120 dựa trên
cx24123 Conexant CX24123 dựa trên
ds3000 Công nghệ Montage dựa trên DS3000
mb86a16 Fujitsu MB86A16 dựa trên
dựa trên mt312 Zarlink VP310/MT312/ZL10313
s5h1420 dựa trên Samsung S5H1420
si21xx Phòng thí nghiệm Silicon dựa trên SI21XX
Bộ chỉnh silicon stb6000 ST STB6000
stv0288 ST STV0288 dựa trên
stv0299 ST STV0299 dựa trên
dựa trên stv0900 ST STV0900
Bộ chỉnh silicon stv6110 ST STV6110
tda10071 NXP TDA10071
tda10086 Philips TDA10086 dựa trên
tda8083 Philips TDA8083 dựa trên
tda8261 Philips TDA8261 dựa trên
tda826x Bộ điều chỉnh silicon Philips TDA826X
ts2020 Bộ điều chỉnh dựa trên Công nghệ Montage TS2020
tua6100 Infineon TUA6100 PLL
cx24113 Bộ điều chỉnh Conexant CX24113/CX24128 dành cho DVB-S/DSS
itd1000 Integrant ITD1000 Bộ điều chỉnh Zero IF cho DVB-S/DSS
dựa trên ves1x93 VLSI VES1893 hoặc VES1993
Bộ điều chỉnh silicon zl10036 Zarlink ZL10036
Bộ điều chỉnh silicon zl10039 Zarlink ZL10039
=============================================================================

Giao diện DVB-T (mặt đất)
=============================

=============================================================================
Tên tài xế
=============================================================================
af9013 Bộ giải mã Afatech AF9013
cx22700 Conexant CX22700 dựa trên
Bộ giải mã cx22702 Conexant cx22702 (OFDM)
cxd2820r Sony CXD2820R
cxd2841er Sony CXD2841ER
cxd2880 Bộ điều chỉnh + bộ giải điều chế Sony CXD2880 DVB-T2/T
dib3000mb DiBcom 3000M-B
dib3000mc DiBcom 3000P/M-C
dib7000m DiBcom 7000MA/MB/PA/PB/MC
dib7000p DiBcom 7000PC
dib9000 DiBcom 9000
trình điều khiển drxd Micronas DRXD
ec100 E3C EC100
l64781 LSI L64781
dựa trên mt352 Zarlink MT352
nxt6000 NxtWave Truyền thông dựa trên NXT6000
rtl2830 Realtek RTL2830 DVB-T
rtl2832 Realtek RTL2832 DVB-T
rtl2832_sdr Realtek RTL2832 SDR
s5h1432 Bộ giải mã Samsung s5h1432 (OFDM)
si2168 Phòng thí nghiệm silicon Si2168
sp8870 Spase dựa trên sp8870
sp887x Spase dựa trên sp887x
dựa trên stv0367 ST STV0367
tda10048 Philips TDA10048HN dựa trên
dựa trên tda1004x Philips TDA10045H/TDA10046H
zd1301_demod ZyDAS ZD1301
dựa trên zl10353 Zarlink ZL10353
=============================================================================

Bộ dò sóng mặt đất kỹ thuật số/PLL
===================================

=============================================================================
Tên tài xế
=============================================================================
dvb-pll Bộ điều chỉnh dựa trên I2C PLL chung
dib0070 Bộ điều chỉnh băng tần cơ sở silicon DiBcom DiB0070
dib0090 DiBcom DiB0090 bộ điều chỉnh băng tần cơ sở silicon
=============================================================================

Giao diện ISDB-S (vệ tinh) & ISDB-T (mặt đất)
===================================================

=============================================================================
Tên tài xế
=============================================================================
mn88443x Socionext MN88443x
tc90522 Toshiba TC90522
=============================================================================

Giao diện ISDB-T (mặt đất)
==============================

=============================================================================
Tên tài xế
=============================================================================
dib8000 DiBcom 8000MB/MC
mb86a20s Fujitsu mb86a20s
Giao diện s921 Sharp S921
=============================================================================

Giao diện đa tiêu chuẩn (cáp + mặt đất)
=============================================

=============================================================================
Tên tài xế
=============================================================================
drxk dựa trên Micronas DRXK
mn88472 Panasonic MN88472
mn88473 Panasonic MN88473
si2165 Phòng thí nghiệm Silicon dựa trên si2165
Bộ điều chỉnh silicon tda18271c2dd NXP TDA18271C2
=============================================================================

Giao diện đa tiêu chuẩn (vệ tinh)
===================================

=============================================================================
Tên tài xế
=============================================================================
m88ds3103 Công nghệ dựng phim M88DS3103
bộ giải điều chế dựa trên mxl5xx MaxLinear MxL5xx
dựa trên stb0899 STB0899
Bộ điều chỉnh dựa trên stb6100 STB6100
dựa trên stv090x STV0900/STV0903(A/B)
dựa trên stv0910 STV0910
Bộ điều chỉnh dựa trên stv6110x STV6110/(A)
Bộ điều chỉnh dựa trên stv6111 STV6111
=============================================================================

Thiết bị điều khiển SEC dành cho DVB-S
=============================

=============================================================================
Tên tài xế
=============================================================================
a8293 Allegro A8293
af9033 Bộ giải mã Afatech AF9033 DVB-T
ascot2e Bộ điều chỉnh Sony Ascot2E
atbm8830 Bộ giải mã AltoBeam ATBM8830/8831 DMB-TH
Bộ giải mã drx39xyj Micronas DRX-J
Helene Sony HELENE Bộ điều chỉnh Sat/Ter (CXD2858ER)
horus3a Bộ điều chỉnh Sony Horus3A
Bộ điều khiển isl6405 ISL6405 SEC
Bộ điều khiển isl6421 ISL6421 SEC
Bộ điều khiển isl6423 ISL6423 SEC
ix2505v Bộ chỉnh silicon Sharp IX2505V
lgs8gl5 Bộ giải mã Silicon Legend LGS-8GL5 (OFDM)
Bộ giải mã lgs8gxx Legend Silicon LGS8913/LGS8GL5/LGS8GXX DMB-TH
Bộ điều khiển lnbh25 LNBH25 SEC
bộ điều khiển lnbh29 LNBH29 SEC
Bộ điều khiển lnbp21 LNBP21/LNBH24 SEC
Bộ điều khiển lnbp22 LNBP22 SEC
m88rs2000 M88RS2000 DVB-S bộ giải mã và bộ điều chỉnh
Bộ điều chỉnh tda665x TDA665x
=============================================================================

Công cụ để phát triển giao diện người dùng mới
==============================

=============================================================================
Tên tài xế
=============================================================================
dvb_dummy_fe Trình điều khiển giao diện người dùng giả
=============================================================================