.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/mm/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===================
Quản lý bộ nhớ
=================

Hệ thống con quản lý bộ nhớ Linux chịu trách nhiệm, như tên gọi của nó,
để quản lý bộ nhớ trong hệ thống. Điều này bao gồm việc thực hiện
bộ nhớ ảo và phân trang theo yêu cầu, phân bổ bộ nhớ cho cả kernel
cấu trúc bên trong và các chương trình không gian người dùng, ánh xạ các tập tin vào
xử lý không gian địa chỉ và nhiều thứ thú vị khác.

Quản lý bộ nhớ Linux là một hệ thống phức tạp với nhiều cấu hình
cài đặt. Hầu hết các cài đặt này đều có sẵn thông qua ZZ0000ZZ
hệ thống tập tin và có thể được truy vấn và điều chỉnh bằng ZZ0001ZZ. Các API này
được mô tả trong Documentation/admin-guide/sysctl/vm.rst và trong ZZ0002ZZ.

.. _man 5 proc: http://man7.org/linux/man-pages/man5/proc.5.html

Quản lý bộ nhớ Linux có thuật ngữ riêng và nếu bạn chưa biết
quen thuộc với nó, hãy cân nhắc việc đọc Documentation/admin-guide/mm/concepts.rst.

Ở đây chúng tôi ghi lại chi tiết cách tương tác với các cơ chế khác nhau trong
quản lý bộ nhớ Linux.

.. toctree::
   :maxdepth: 1

   concepts
   cma_debugfs
   damon/index
   hugetlbpage
   idle_page_tracking
   ksm
   memory-hotplug
   multigen_lru
   nommu-mmap
   numa_memory_policy
   numaperf
   pagemap
   shrinker_debugfs
   slab
   soft-dirty
   transhuge
   userfaultfd
   zswap
   kho
