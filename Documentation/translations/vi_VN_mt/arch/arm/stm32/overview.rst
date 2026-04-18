.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/stm32/overview.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Tổng quan về STM32 ARM Linux
========================

Giới thiệu
------------

Dòng bộ vi xử lý Cortex-A (MPU) và STMicroelectronics STM32 của STMicroelectronics STM32
Bộ vi điều khiển Cortex-M (MCU) được hỗ trợ bởi nền tảng 'STM32' của
ARMLinux.

Cấu hình
-------------

Đối với MCU, hãy sử dụng cấu hình mặc định được cung cấp:
        tạo stm32_defconfig
Đối với MPU, hãy sử dụng cấu hình multi_v7:
        tạo multi_v7_defconfig

Cách trình bày
------

Tất cả các tệp cho nhiều họ máy đều nằm trong mã nền tảng
chứa trong Arch/arm/mach-stm32

Có một bảng chung board-dt.c trong thư mục mach hỗ trợ
Cây thiết bị dẹt, có nghĩa là nó hoạt động với bất kỳ bo mạch tương thích nào có
Cây thiết bị.

:Tác giả:

- Maxime coquelin <mcoquelin.stm32@gmail.com>
- Ludovic Barre <ludovic.barre@st.com>
- Gerald Baeza <gerald.baeza@st.com>
