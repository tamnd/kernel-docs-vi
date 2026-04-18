.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/mm-api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================
API quản lý bộ nhớ
========================

Truy cập bộ nhớ không gian người dùng
=====================================

.. kernel-doc:: arch/x86/include/asm/uaccess.h
   :internal:

.. kernel-doc:: arch/x86/lib/usercopy_32.c
   :export:

.. kernel-doc:: mm/gup.c
   :functions: get_user_pages_fast

.. _mm-api-gfp-flags:

Kiểm soát phân bổ bộ nhớ
==========================

.. kernel-doc:: include/linux/gfp_types.h
   :doc: Page mobility and placement hints

.. kernel-doc:: include/linux/gfp_types.h
   :doc: Watermark modifiers

.. kernel-doc:: include/linux/gfp_types.h
   :doc: Reclaim modifiers

.. kernel-doc:: include/linux/gfp_types.h
   :doc: Useful GFP flag combinations

Bộ đệm phiến
==============

.. kernel-doc:: include/linux/slab.h
   :internal:

.. kernel-doc:: mm/slub.c
   :export:

.. kernel-doc:: mm/slab_common.c
   :export:

.. kernel-doc:: mm/util.c
   :functions: kfree_const kvmalloc_node kvfree

Ánh xạ gần như liền kề
=============================

.. kernel-doc:: mm/vmalloc.c
   :export:

Ánh xạ tệp và bộ đệm trang
===========================

Sơ đồ tập tin
-------------

.. kernel-doc:: mm/filemap.c
   :export:

Đọc trước
---------

.. kernel-doc:: mm/readahead.c
   :doc: Readahead Overview

.. kernel-doc:: mm/readahead.c
   :export:

Viết lại
---------

.. kernel-doc:: mm/page-writeback.c
   :export:

Cắt ngắn
--------

.. kernel-doc:: mm/truncate.c
   :export:

.. kernel-doc:: include/linux/pagemap.h
   :internal:

Bể nhớ
============

.. kernel-doc:: mm/mempool.c
   :export:

Thêm chức năng quản lý bộ nhớ
================================

.. kernel-doc:: mm/memory.c
   :export:

.. kernel-doc:: mm/page_alloc.c
.. kernel-doc:: mm/mempolicy.c
.. kernel-doc:: include/linux/mm_types.h
   :internal:
.. kernel-doc:: include/linux/mm_inline.h
.. kernel-doc:: include/linux/page-flags.h
.. kernel-doc:: include/linux/mm.h
   :internal:
.. kernel-doc:: include/linux/page_ref.h
.. kernel-doc:: include/linux/mmzone.h
.. kernel-doc:: mm/util.c
   :functions: folio_mapping

.. kernel-doc:: mm/rmap.c
.. kernel-doc:: mm/migrate.c
.. kernel-doc:: mm/mmap.c
.. kernel-doc:: mm/kmemleak.c
.. #kernel-doc:: mm/hmm.c (build warnings)
.. kernel-doc:: mm/memremap.c
.. kernel-doc:: mm/hugetlb.c
.. kernel-doc:: mm/swap.c
.. kernel-doc:: mm/memcontrol.c
.. #kernel-doc:: mm/memory-tiers.c (build warnings)
.. kernel-doc:: mm/shmem.c
.. kernel-doc:: mm/migrate_device.c
.. #kernel-doc:: mm/nommu.c (duplicates kernel-doc from other files)
.. kernel-doc:: mm/mapping_dirty_helpers.c
.. #kernel-doc:: mm/memory-failure.c (build warnings)
.. kernel-doc:: mm/percpu.c
.. kernel-doc:: mm/maccess.c
.. kernel-doc:: mm/vmscan.c
.. kernel-doc:: mm/memory_hotplug.c
.. kernel-doc:: mm/mmu_notifier.c
.. kernel-doc:: mm/balloon.c
.. kernel-doc:: mm/huge_memory.c
