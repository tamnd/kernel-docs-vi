.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/stm32/stm32h750-overview.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Tổng quan về STM32H750
======================

Giới thiệu
------------

STM32H750 là Cortex-M7 MCU nhắm đến nhiều ứng dụng khác nhau.
Nó có tính năng:

- Lõi Cortex-M7 chạy lên tới @480 MHz
- Đèn flash bên trong 128K, RAM bên trong 1 MB
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
-DFSDM

Tài nguyên
---------

Bảng dữ liệu và tài liệu tham khảo được cung cấp công khai trên trang web ST (STM32H750_).

.. _STM32H750: https://www.st.com/en/microcontrollers-microprocessors/stm32h750-value-line.html

:Tác giả: Dillon Min <dillon.minfei@gmail.com>

