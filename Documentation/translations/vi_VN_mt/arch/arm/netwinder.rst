.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/netwinder.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================
Tài liệu cụ thể của NetWinder
================================

NetWinder là một máy tính nhỏ có công suất thấp, được thiết kế chủ yếu
để chạy Linux.  Nó dựa trên bộ xử lý StrongARM RISC,
Cầu DC21285 PCI, với phần cứng kiểu PC được dán xung quanh.

Sử dụng cổng
==========

============= ==================================
Mô tả tối thiểu tối đa
============= ==================================
0x0000 0x000f DMA1
0x0020 0x0021 PIC1
Bàn phím 0x0060 0x006f
0x0070 0x007f RTC
0x0080 0x0087 DMA1
0x0088 0x008f DMA2
0x00a0 0x00a3 PIC2
0x00c0 0x00df DMA2
0x0180 0x0187 IRDA
0x01f0 0x01f6 ide0
Cổng trò chơi 0x0201
Đọc cấu hình 0x0203 RWA010
0x0220?	SoundBlaster
0x0250?	WaveArtist
Chỉ số cấu hình 0x0279 RWA010
0x02f8 0x02ff ttyS1 nối tiếp
0x0300 0x031f Ether10
0x0338 GPIO1
0x033a GPIO2
Thanh ghi cấu hình 0x0370 0x0371 W83977F
0x0388?	AdLib
0x03c0 0x03df VGA
0x03f6 ide0
0x03f8 0x03ff ttyS0 nối tiếp
0x0400 0x0408 DC21143
0x0480 0x0487 DMA1
0x0488 0x048f DMA2
Ghi cấu hình 0x0a79 RWA010
0xe800 0xe80f ide0/ide1 BM DMA
============= ==================================


Ngắt sử dụng
===============

======= ======= ===========================
Loại IRQ Mô tả
======= ======= ===========================
 0 ISA hẹn giờ 100Hz
 1 bàn phím ISA
 2 tầng ISA
 3 ISA nối tiếp ttyS1
 4 ISA Nối tiếp ttyS0
 5 con chuột ISA PS/2
 6 ISA IRDA
 7 Máy in ISA
 8 báo động ISA RTC
 9 ISA
10 ISA GP10 (Nút đặt lại màu cam)
11 ISA
12 ISA WaveArtist
13 ISA
14 ISA hda1
15 ISA
======= ======= ===========================

Cách sử dụng DMA
=========

======= ======= ============
Loại DMA Mô tả
======= ======= ============
 0 ISA IRDA
 1 ISA
 2 tầng ISA
 3 ISA WaveArtist
 4 ISA
 5 ISA
 6 ISA
 7 ISA WaveArtist
======= ======= ============
