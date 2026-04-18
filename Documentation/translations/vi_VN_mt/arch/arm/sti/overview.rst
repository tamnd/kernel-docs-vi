.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/sti/overview.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
Tổng quan về STi ARM Linux
==========================

Giới thiệu
------------

Dòng sản phẩm Bộ xử lý ứng dụng và đa phương tiện vi điện tử ST
  Hệ thống trên chip CortexA9 được hỗ trợ bởi nền tảng 'STi' của
  ARMLinux. Hiện tại STiH407, STiH410 và STiH418 được hỗ trợ.


cấu hình
-------------

Cấu hình cho nền tảng STi được hỗ trợ thông qua multi_v7_defconfig.

Cách trình bày
------

Tất cả các tệp cho nhiều họ máy (STiH407, STiH410 và STiH418)
  được đặt trong mã nền tảng có trong Arch/arm/mach-sti

Có một bảng chung board-dt.c trong thư mục mach hỗ trợ
  Cây thiết bị dẹt, có nghĩa là, Nó hoạt động với bất kỳ bo mạch tương thích nào có
  Cây thiết bị.


Tác giả tài liệu
---------------

Srinivas Kandagatla <srinivas.kandagatla@st.com>, (c) 2013 ST Vi điện tử
