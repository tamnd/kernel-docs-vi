.. SPDX-License-Identifier: (GPL-2.0-only OR BSD-3-Clause)

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/hd-audio/intel-multi-link.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. include:: <isonum.txt>

====================================================
Tiện ích mở rộng đa liên kết HDAudio trên nền tảng Intel
================================================

:Bản quyền: ZZ0000ZZ 2023 Tập đoàn Intel

Tệp này ghi lại 'cấu trúc đa liên kết' được giới thiệu vào năm 2015 với
bộ xử lý Skylake và gần đây đã được mở rộng trên các nền tảng Intel mới hơn

Ánh xạ liên kết hiện có của HDaudio (bổ sung 2015 trong SkyLake)
========================================================

Codec HDAudio bên ngoài được xử lý bằng link #0, trong khi codec iDISP
đối với HDMI/DisplayPort được xử lý bằng liên kết #1.

Thay đổi duy nhất đối với định nghĩa năm 2015 là tuyên bố về
LCAP.ALT=0x0 - vì bit ALT đã được đặt trước trước đó nên đây là một
thay đổi tương thích ngược.

LCTL.SPA và LCTL.CPA được thiết lập tự động khi thoát khỏi thiết lập lại. Họ
chỉ được sử dụng trong trình điều khiển hiện có khi cần phải có giá trị SCF
đã sửa.

Cấu trúc cơ bản của codec HDaudio
----------------------------------

::

+----------+
  ZZ0000ZZ
  +----------+
  ZZ0001ZZ---+
  +----------+ |
                  |
                  +--> 0x0 +--------------+ LCAP
                           ZZ0002ZZ
                           +--------------+
                           ZZ0003ZZ
                           +--------------+
                           ZZ0004ZZ
                           +--------------+
                           ZZ0005ZZ
                           +--------------+
                           ZZ0006ZZ
                           +--------------+
                           ZZ0007ZZ
                           +--------------+
                           ZZ0008ZZ
                           +--------------+

0x4 +--------------+ LCTL
                           ZZ0000ZZ
                           +--------------+
                           ZZ0001ZZ
                           +--------------+
                           ZZ0002ZZ
                           +--------------+
                           ZZ0003ZZ
                           +--------------+

0x8 +--------------+ LOSIDV
                           ZZ0000ZZ
                           +--------------+
                           ZZ0001ZZ
                           +--------------+
                           ZZ0002ZZ
                           +--------------+

0xC +--------------+ LSDIID
                           ZZ0000ZZ
                           +--------------+
                           ZZ0001ZZ
                           +--------------+
                           ZZ0002ZZ
                           +--------------+

Ánh xạ liên kết mở rộng SoundWire HDaudio
=======================================

Liên kết mở rộng SoundWire được xác định khi LCAP.ALT=1 và
LEPTR.ID=0.

Điều khiển DMA sử dụng thanh ghi LOSIDV hiện có.

Những thay đổi bao gồm các mô tả bổ sung cho bảng liệt kê không có
hiện diện ở các thế hệ trước.

- đồng bộ hóa đa liên kết: khả năng trong LCAP.LSS và điều khiển trong LSYNC
- số lượng liên kết con (IP người quản lý) trong LCAP.LSCOUNT
- quản lý năng lượng được chuyển từ các bit SHIM sang LCTL.SPA
- chuyển giao cho DSP để truy cập vào các thanh ghi đa liên kết, SHIM/IP với LCTL.OFLEN
- ánh xạ các codec SoundWire tới các bit ID SDI
- di chuyển các thanh ghi SHIM và Cadence tới các offset khác nhau, không có
  thay đổi về chức năng. Giá trị LEPTR.PTR là phần bù từ
  Địa chỉ ML, có giá trị mặc định là 0x30000.

Cấu trúc mở rộng cho SoundWire (giả sử 4 IP quản lý)
--------------------------------------------------------

::

+----------+
  ZZ0000ZZ
  +----------+
  ZZ0001ZZ
  +----------+
  ZZ0002ZZ---+
  +----------+ |
                  |
                  +--> 0x0 +--------------+ LCAP
                           ZZ0003ZZ
                           +--------------+
                           ZZ0004ZZ
                           +--------------+
                           ZZ0005ZZ
                           +--------------+
                           ZZ0006ZZ
                           +--------------+
                           ZZ0007ZZ-----------+
                           +--------------+ |
                                                       |
                       0x4 +--------------+ LCTL |
                           ZZ0008ZZ |
                           +--------------+ |
                           ZZ0009ZZ |
                           +--------------+ |
                           ZZ0010ZZ |
                           +--------------+ cho mỗi liên kết con x
                           ZZ0011ZZ |
                           +--------------+ |
                           ZZ0012ZZ |
                           +--------------+ |
                                                       |
                       0x8 +--------------+ LOSIDV |
                           ZZ0013ZZ |
                           +--------------+ |
                           ZZ0014ZZ |
                           +--------------+ |
                           ZZ0015ZZ +---+-----------------------------------------------------------------------+
                           +--------------+ ZZ0016ZZ
                                                   v |
             0xC + 0x2 * x +--------------+ LSDIIDx +---> 0x30000 +-----------------+ 0x00030000 |
                           ZZ0017ZZ ZZ0018ZZ SoundWire SHIM ZZ0019ZZ
                           +--------------+ ZZ0020ZZ chung ZZ0021ZZ
                           ZZ0022ZZ ZZ0023ZZ
                           +--------------+ ZZ0024ZZ SoundWire IP ZZ0025ZZ
                           ZZ0026ZZ ZZ0027ZZ
                           +--------------+ ZZ0028ZZ SoundWire SHIM ZZ0029ZZ
                                                        ZZ0030ZZ dành riêng cho nhà cung cấp ZZ0031ZZ
                      0x1C +--------------+ LSYNC ZZ0032ZZ
                           ZZ0033ZZ |                                                         v
                           +--------------+ |              +-----------------+ 0x00030000 + 0x8000 * x
                           ZZ0034ZZ ZZ0035ZZ SoundWire SHIM |
                           +--------------+ ZZ0036ZZ chung |
                           ZZ0037ZZ |              +-----------------+ 0x00030100 + 0x8000 * x
                           +--------------+ IP SoundWire ZZ0038ZZ |
                           ZZ0039ZZ |              +-----------------+ 0x00036000 + 0x8000 * x
                           +--------------+ ZZ0040ZZ SoundWire SHIM |
                                                        ZZ0041ZZ dành riêng cho nhà cung cấp |
                      0x20 +--------------+ LEPTR |              +-----------------+
                           ZZ0042ZZ |
                           +--------------+ |
                           ZZ0043ZZ |
                           +--------------+ |
                           ZZ0044ZZ-------------+
                           +--------------+


Ánh xạ liên kết mở rộng DMIC HDaudio
==================================

Liên kết mở rộng DMIC được xác định khi LCAP.ALT=1 và
LEPTR.ID=0xC1 được đặt.

Điều khiển DMA sử dụng thanh ghi LOSIDV hiện có

Những thay đổi bao gồm các mô tả bổ sung cho bảng liệt kê không có
hiện diện ở các thế hệ trước.

- đồng bộ hóa đa liên kết: khả năng trong LCAP.LSS và điều khiển trong LSYNC
- quản lý năng lượng với các bit LCTL.SPA
- chuyển giao cho DSP để truy cập vào các thanh ghi đa liên kết, SHIM/IP với LCTL.OFLEN

- di chuyển các thanh ghi DMIC sang các offset khác nhau mà không thay đổi
  chức năng. Giá trị LEPTR.PTR là phần bù từ ML
  địa chỉ, với giá trị mặc định là 0x10000.

Cấu trúc mở rộng cho DMIC
---------------------------

::

+----------+
  ZZ0000ZZ
  +----------+
  ZZ0001ZZ
  +----------+
  ZZ0002ZZ---+
  +----------+ |
                  |
                  +--> 0x0 +--------------+ LCAP
                           ZZ0003ZZ
                           +--------------+
                           ZZ0004ZZ
                           +--------------+
                           ZZ0005ZZ
                           +--------------+
                           ZZ0006ZZ
                           +--------------+

0x4 +--------------+ LCTL
                           ZZ0000ZZ
                           +--------------+
                           ZZ0001ZZ
                           +--------------+
                           ZZ0002ZZ
                           +--------------+
                           ZZ0003ZZ
                           +--------------+
                           ZZ0004ZZ
                           +--------------+ +---> 0x10000 +-----------------+ 0x00010000
                                                       ZZ0005ZZ DMIC SHIM |
                       0x8 +--------------+ LOSIDV ZZ0006ZZ chung |
                           ZZ0007ZZ |              +-----------------+ 0x00010100
                           +--------------+ IP ZZ0008ZZ DMIC |
                           ZZ0009ZZ |              +-----------------+ 0x00016000
                           +--------------+ ZZ0010ZZ DMIC SHIM |
                           ZZ0011ZZ ZZ0012ZZ dành riêng cho nhà cung cấp |
                           +--------------+ |              +-----------------+
                                                       |
                      0x20 +--------------+ LEPTR |
                           ZZ0013ZZ |
                           +--------------+ |
                           ZZ0014ZZ |
                           +--------------+ |
                           ZZ0015ZZ-----------+
                           +--------------+


Ánh xạ liên kết mở rộng SSP HDaudio
=================================

Liên kết mở rộng DMIC được xác định khi LCAP.ALT=1 và
LEPTR.ID=0xC0 được đặt.

Điều khiển DMA sử dụng thanh ghi LOSIDV hiện có

Những thay đổi bao gồm các mô tả bổ sung cho việc liệt kê và kiểm soát chưa được áp dụng
có ở các thế hệ trước:
- số lượng liên kết con (phiên bản IP SSP) trong LCAP.LSCOUNT
- quản lý năng lượng được chuyển từ các bit SHIM sang LCTL.SPA
- chuyển giao cho DSP để truy cập vào các thanh ghi đa liên kết, SHIM/IP
với LCTL.OFLEN
- di chuyển các thanh ghi IP SHIM và SSP sang các offset khác nhau, không có
thay đổi về chức năng.  Giá trị LEPTR.PTR là phần bù từ ML
địa chỉ, với giá trị mặc định là 0x28000.

Cấu trúc mở rộng cho SSP (giả sử 3 phiên bản IP)
-----------------------------------------------------------

::

+----------+
  ZZ0000ZZ
  +----------+
  ZZ0001ZZ
  +----------+
  ZZ0002ZZ---+
  +----------+ |
                  |
                  +--> 0x0 +--------------+ LCAP
                           ZZ0003ZZ
                           +--------------+
                           ZZ0004ZZ
                           +--------------+
                           ZZ0005ZZ
                           +--------------+
                           ZZ0006ZZ--------------------------cho mỗi liên kết con x ----------------+
                           +--------------+ |
                                                                                                                 |
                       0x4 +--------------+ LCTL |
                           ZZ0007ZZ |
                           +--------------+ |
                           ZZ0008ZZ |
                           +--------------+ |
                           ZZ0009ZZ |
                           +--------------+ |
                           ZZ0010ZZ |
                           +--------------+ |
                           ZZ0011ZZ |
                           +--------------+ +---> 0x28000 +-----------------+ 0x00028000 |
                                                       ZZ0012ZZ SSP SHIM ZZ0013ZZ
                       0x8 +--------------+ LOSIDV ZZ0014ZZ chung ZZ0015ZZ
                           ZZ0016ZZ ZZ0017ZZ
                           +--------------+ ZZ0018ZZ SSP IP ZZ0019ZZ
                           ZZ0020ZZ ZZ0021ZZ
                           +--------------+ ZZ0022ZZ SSP SHIM ZZ0023ZZ
                           ZZ0024ZZ ZZ0025ZZ dành riêng cho nhà cung cấp ZZ0026ZZ
                           +--------------+ ZZ0027ZZ
                                                       |                                                         v
                      0x20 +--------------+ LEPTR |              +-----------------+ 0x00028000 + 0x1000 * x
                           ZZ0028ZZ ZZ0029ZZ SSP SHIM |
                           +--------------+ ZZ0030ZZ chung |
                           ZZ0031ZZ |              +-----------------+ 0x00028100 + 0x1000 * x
                           +--------------+ IP ZZ0032ZZ SSP |
                           ZZ0033ZZ-------------+ +-----------------+ 0x00028C00 + 0x1000 * x
                           +--------------+ ZZ0034ZZ
                                                                      ZZ0035ZZ
                                                                      +-----------------+