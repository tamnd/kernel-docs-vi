.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/isa-versions.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================
Ánh xạ phiên bản CPU sang ISA
==========================

Ánh xạ một số phiên bản CPU sang các phiên bản ISA có liên quan.

Lưu ý Power4 và Power4+ không được hỗ trợ.

===================================================================================
Phiên bản kiến trúc CPU
===================================================================================
Power10 Power ISA v3.1
Power9 Power ISA v3.0B
Power8 Power ISA v2.07
e6500 Power ISA v2.06 với một số ngoại lệ
e5500 Power ISA v2.06 với một số ngoại lệ, không có Altivec
Power7 Power ISA v2.06
Power6 Power ISA v2.05
PA6T Power ISA v2.04
Cell PPU - Power ISA v2.02 với một số ngoại lệ nhỏ
          - Cộng Altivec/VMX ~= 2.03
Power5++ Power ISA v2.04 (không có VMX)
Power5+ Power ISA v2.03
Power5 - Sách kiến trúc bộ hướng dẫn sử dụng PowerPC I v2.02
          - Sách kiến trúc môi trường ảo PowerPC II v2.02
          - Sách kiến trúc môi trường vận hành PowerPC III v2.02
PPC970 - Sách kiến trúc bộ hướng dẫn sử dụng PowerPC I v2.01
          - Sách kiến trúc môi trường ảo PowerPC II v2.01
          - Sách kiến trúc môi trường vận hành PowerPC III v2.01
          - Cộng Altivec/VMX ~= 2.03
Power4+ - Sách kiến trúc bộ hướng dẫn sử dụng PowerPC I v2.01
          - Sách kiến trúc môi trường ảo PowerPC II v2.01
          - Sách kiến trúc môi trường vận hành PowerPC III v2.01
Power4 - Sách kiến trúc bộ hướng dẫn sử dụng PowerPC I v2.00
          - Sách kiến trúc môi trường ảo PowerPC II v2.00
          - Sách kiến trúc môi trường vận hành PowerPC III v2.00
===================================================================================


Các tính năng chính
------------

========== ====================
CPU VMX (còn gọi là Altivec)
========== ====================
Nguồn10 Có
Nguồn9 Có
Nguồn8 Có
e6500 Có
e5500 Không
Nguồn7 Có
Nguồn6 Có
PA6T Có
Ô PPU Có
Power5++ Không
Power5+ Không
Nguồn5 Không
PPC970 Có
Power4+ Không
Nguồn4 Không
========== ====================

========== ====
CPU VSX
========== ====
Nguồn10 Có
Nguồn9 Có
Nguồn8 Có
e6500 Không
e5500 Không
Nguồn7 Có
Nguồn6 Không
PA6T Không
Ô PPU Không
Power5++ Không
Power5+ Không
Nguồn5 Không
PPC970 Không
Power4+ Không
Nguồn4 Không
========== ====

==================================================
Bộ nhớ giao dịch CPU
==================================================
Power10 Không (* xem Power ISA v3.1, "Phụ lục A. Lưu ý về việc xóa bộ nhớ giao dịch khỏi kiến trúc")
Power9 Có (* xem giao dịch_memory.txt)
Nguồn8 Có
e6500 Không
e5500 Không
Power7 Không
Nguồn6 Không
PA6T Không
Ô PPU Không
Power5++ Không
Power5+ Không
Nguồn5 Không
PPC970 Không
Power4+ Không
Nguồn4 Không
==================================================
