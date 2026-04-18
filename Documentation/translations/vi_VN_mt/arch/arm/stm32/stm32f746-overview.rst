.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/stm32/stm32f746-overview.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================
Tổng quan về STM32F746
==================

Giới thiệu
------------

STM32F746 là Cortex-M7 MCU nhắm đến nhiều ứng dụng khác nhau.
Nó có tính năng:

- Lõi Cortex-M7 chạy lên tới @216 MHz
- Bộ nhớ flash bên trong 1MB, RAM bên trong 320KBytes (+4KB SRAM dự phòng)
- Bộ điều khiển FMC để kết nối các bộ nhớ SDRAM, NOR và NAND
- Chế độ kép QSPI
- Hỗ trợ SD/MMC/SDIO
- Bộ điều khiển Ethernet
- Bộ điều khiển USB OTFG FS & HS
- Hỗ trợ xe buýt I2C, SPI, CAN
- Một số bộ định thời đa năng 16 & 32 bit
- Giao diện âm thanh nối tiếp
- Bộ điều khiển LCD
- HDMI-CEC
-SPDIFRX

Tài nguyên
---------

Bảng dữ liệu và tài liệu tham khảo được cung cấp công khai trên trang web ST (STM32F746_).

.. _STM32F746: http://www.st.com/content/st_com/en/products/microcontrollers/stm32-32-bit-arm-cortex-mcus/stm32f7-series/stm32f7x6/stm32f746ng.html

:Tác giả: Alexandre Torgue <alexandre.torgue@st.com>
