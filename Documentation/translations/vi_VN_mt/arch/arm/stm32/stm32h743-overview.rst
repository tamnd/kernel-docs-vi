.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/stm32/stm32h743-overview.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Tổng quan về STM32H743
======================

Giới thiệu
------------

STM32H743 là Cortex-M7 MCU nhắm đến nhiều ứng dụng khác nhau.
Nó có tính năng:

- Lõi Cortex-M7 chạy lên tới @400 MHz
- Bộ nhớ flash bên trong 2 MB, RAM bên trong 1 MB
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
----------

Bảng dữ liệu và tài liệu tham khảo được cung cấp công khai trên trang web ST (STM32H743_).

.. _STM32H743: http://www.st.com/en/microcontrollers/stm32h7x3.html?querycriteria=productId=LN2033

:Tác giả: Alexandre Torgue <alexandre.torgue@st.com>
