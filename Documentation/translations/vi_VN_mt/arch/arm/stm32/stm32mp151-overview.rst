.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/stm32/stm32mp151-overview.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================
Tổng quan về STM32MP151
===================

Giới thiệu
------------

STM32MP151 là Cortex-A MPU nhắm đến nhiều ứng dụng khác nhau.
Nó có tính năng:

- Lõi ứng dụng Cortex-A7 đơn
- Hỗ trợ giao diện bộ nhớ tiêu chuẩn
- Kết nối tiêu chuẩn, kế thừa rộng rãi từ dòng STM32 MCU
- Hỗ trợ bảo mật toàn diện

Thêm chi tiết:

- Lõi Cortex-A7 chạy lên tới @800 MHz
- Bộ điều khiển FMC để kết nối các bộ nhớ SDRAM, NOR và NAND
-QSPI
- Hỗ trợ SD/MMC/SDIO
- Bộ điều khiển Ethernet
-ADC/DAC
- Bộ điều khiển USB EHCI/OHCI
- USB OTG
- Hỗ trợ xe buýt I2C, SPI
- Một số bộ tính giờ cho mục đích chung
- Giao diện âm thanh nối tiếp
- Bộ điều khiển LCD-TFT
-DCMIPP
-SPDIFRX
-DFSDM

:Tác giả:

- Roan van Dijk <roan@protonic.nl>
