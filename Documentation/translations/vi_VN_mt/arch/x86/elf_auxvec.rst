.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/elf_auxvec.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================
Các vectơ phụ trợ ELF dành riêng cho x86
==================================

Tài liệu này mô tả ngữ nghĩa của các vectơ phụ trợ x86.

Giới thiệu
============

ELF Các vectơ phụ trợ cho phép hạt nhân cung cấp hiệu quả
các thông số cấu hình cụ thể cho không gian người dùng. Trong ví dụ này, một chương trình
phân bổ một ngăn xếp thay thế dựa trên kích thước do kernel cung cấp ::

#include <sys/auxv.h>
   #include <elf.h>
   #include <tín hiệu.h>
   #include <stdlib.h>
   #include <khẳng định.h>
   #include <err.h>

#ifndef AT_MINSIGSTKSZ
   #define AT_MINSIGSTKSZ 51
   #endif

   ....
stack_t ss;

ss.ss_sp = malloc(ss.ss_size);
   khẳng định(ss.ss_sp);

ss.ss_size = getauxval(AT_MINSIGSTKSZ) + SIGSTKSZ;
   ss.ss_flags = 0;

nếu (sigaltstack(&ss, NULL))
        err(1, "sigaltstack");


Các vectơ phụ trợ tiếp xúc
=============================

AT_SYSINFO được sử dụng để định vị điểm vào vsyscall.  Nó không phải
được xuất ở chế độ 64-bit.

AT_SYSINFO_EHDR là địa chỉ bắt đầu của trang chứa vDSO.

AT_MINSIGSTKSZ biểu thị kích thước ngăn xếp tối thiểu mà hạt nhân yêu cầu để
cung cấp tín hiệu đến không gian người dùng.  AT_MINSIGSTKSZ thấu hiểu không gian
được kernel sử dụng để phù hợp với bối cảnh người dùng cho hiện tại
cấu hình phần cứng.  Nó không hiểu ngăn xếp không gian người dùng tiếp theo
mức tiêu thụ mà người dùng phải thêm vào.  (ví dụ: Ở trên, không gian người dùng thêm
SIGSTKSZ đến AT_MINSIGSTKSZ.)