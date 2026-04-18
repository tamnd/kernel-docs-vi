.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/stm32/stm32f429-overview.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Tổng quan về STM32F429
======================

Giới thiệu
------------

STM32F429 là Cortex-M4 MCU nhắm đến nhiều ứng dụng khác nhau.
Nó có tính năng:

- ARM Cortex-M4 lên tới 180 MHz với FPU
- Bộ nhớ Flash bên trong 2MB
- Hỗ trợ bộ nhớ ngoài thông qua bộ điều khiển FMC (PSRAM, SDRAM, NOR, NAND)
- I2C, SPI, SAI, CAN, USB OTG, bộ điều khiển Ethernet
- Giao diện điều khiển & Camera LCD
- Bộ xử lý mật mã

Tài nguyên
----------

Bảng dữ liệu và tài liệu tham khảo được cung cấp công khai trên trang web ST (STM32F429_).

.. _STM32F429: http://www.st.com/web/en/catalog/mmc/FM141/SC1169/SS1577/LN1806?ecmp=stm32f429-439_pron_pr-ces2014_nov2013

:Tác giả: Maxime coquelin <mcoquelin.stm32@gmail.com>
