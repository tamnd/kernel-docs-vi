.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================
Tài liệu quản lý bộ nhớ
==================================

Đây là hướng dẫn để hiểu hệ thống con quản lý bộ nhớ
của Linux.  Nếu bạn đang tìm kiếm lời khuyên về cách phân bổ bộ nhớ đơn giản,
xem ZZ0000ZZ.  Để kiểm soát và điều chỉnh hướng dẫn,
xem ZZ0001ZZ.

.. toctree::
   :maxdepth: 1

   physical_memory
   page_tables
   process_addrs
   bootmem
   page_allocation
   vmalloc
   slab
   highmem
   page_reclaim
   swap
   swap-table
   page_cache
   shmfs
   oom

Tài liệu chưa được sắp xếp
======================

Đây là tập hợp các tài liệu chưa được sắp xếp về quản lý bộ nhớ Linux
(MM) bên trong hệ thống con với mức độ chi tiết khác nhau, từ ghi chú và
các phản hồi của danh sách gửi thư để xây dựng các mô tả về cấu trúc dữ liệu và
thuật toán.  Tất cả nên được tích hợp độc đáo vào cấu trúc trên
tài liệu, hoặc bị xóa nếu nó đã phục vụ mục đích của nó.

.. toctree::
   :maxdepth: 1

   active_mm
   allocation-profiling
   arch_pgtable_helpers
   balance
   damon/index
   free_page_reporting
   hmm
   hwpoison
   hugetlbfs_reserv
   ksm
   memory-model
   memfd_preservation
   mmu_notifier
   multigen_lru
   numa
   overcommit-accounting
   page_migration
   page_frags
   page_owner
   page_table_check
   remap_file_pages
   split_page_table_lock
   transhuge
   unevictable-lru
   vmalloced-kernel-stacks
   vmemmap_dedup
   zsmalloc
