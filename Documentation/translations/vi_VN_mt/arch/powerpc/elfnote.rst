.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/elfnote.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================
ELF Lưu ý Không gian tên PowerPC
==========================

Không gian tên PowerPC trong ELF Ghi chú của nhị phân kernel được sử dụng để lưu trữ
các khả năng và thông tin có thể được sử dụng bởi bộ nạp khởi động hoặc vùng người dùng.

Các loại và mô tả
---------------------

Các loại được sử dụng với không gian tên "PowerPC" được xác định trong [#f1]_.

1) PPC_ELFNOTE_CAPABILITIES

Xác định các khả năng được hạt nhân hỗ trợ/yêu cầu. Loại này sử dụng một
bitmap làm trường "mô tả". Mỗi bit được mô tả dưới đây:

- Bit có khả năng Ultravisor (chỉ PowerNV).

.. code-block:: c

	#define PPCCAP_ULTRAVISOR_BIT (1 << 0)

Cho biết rằng hệ nhị phân hạt nhân powerpc biết cách chạy trong một
hệ thống hỗ trợ siêu âm.

Trong hệ thống hỗ trợ bộ siêu giám sát, một số tài nguyên máy hiện được kiểm soát
bởi máy siêu âm. Nếu hạt nhân không có khả năng giám sát màn hình nhưng cuối cùng nó lại
đang chạy trên máy có ultravisor, kernel có thể sẽ bị lỗi
cố gắng truy cập tài nguyên ultravisor. Ví dụ: nó có thể gặp sự cố sớm
boot đang cố gắng thiết lập mục nhập bảng phân vùng 0.

Trong hệ thống hỗ trợ bộ giám sát, bộ nạp khởi động có thể cảnh báo người dùng hoặc ngăn chặn
hạt nhân không được chạy nếu khả năng giám sát của PowerPC không tồn tại
hoặc bit có khả năng Ultravisor không được đặt.

Tài liệu tham khảo
----------

.. [#f1] arch/powerpc/include/asm/elfnote.h

