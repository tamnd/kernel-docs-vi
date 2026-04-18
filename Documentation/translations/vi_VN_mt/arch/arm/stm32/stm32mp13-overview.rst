.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/stm32/stm32mp13-overview.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Tổng quan về STM32MP13
======================

Giới thiệu
------------

STM32MP131/STM32MP133/STM32MP135 là Cortex-A MPU nhắm đến nhiều ứng dụng khác nhau.
Họ có tính năng:

- Một lõi ứng dụng Cortex-A7
- Hỗ trợ giao diện bộ nhớ tiêu chuẩn
- Kết nối tiêu chuẩn, kế thừa rộng rãi từ dòng STM32 MCU
- Hỗ trợ bảo mật toàn diện

Thêm chi tiết:

- Lõi Cortex-A7 chạy lên tới @900 MHz
- Bộ điều khiển FMC để kết nối các bộ nhớ SDRAM, NOR và NAND
-QSPI
- Hỗ trợ SD/MMC/SDIO
- Bộ điều khiển Ethernet 2 *
-CAN
-ADC/DAC
- Bộ điều khiển USB EHCI/OHCI
- USB OTG
- Hỗ trợ xe buýt I2C, SPI, CAN
- Một số bộ tính giờ cho mục đích chung
- Giao diện âm thanh nối tiếp
- Bộ điều khiển LCD
-DCMIPP
-SPDIFRX
-DFSDM

:Tác giả:

- Alexandre Torgue <alexandre.torgue@foss.st.com>
