.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================
Tài liệu lõi API
======================

Đây là phần mở đầu của sách hướng dẫn sử dụng API lõi lõi.  Sự chuyển đổi
(và việc viết!) tài liệu cho sổ tay này được đánh giá cao!

Tiện ích cốt lõi
==============

Phần này có tài liệu chung và "cốt lõi".  Đầu tiên là một
một lượng lớn thông tin kerneldoc còn sót lại từ thời docbook; nó
thực sự nên chia tay vào một ngày nào đó khi ai đó tìm thấy năng lượng để làm
nó.

.. toctree::
   :maxdepth: 1

   kernel-api
   workqueue
   watch_queue
   printk-basics
   printk-formats
   printk-index
   symbol-namespaces
   asm-annotations
   real-time/index
   housekeeping.rst

Cấu trúc dữ liệu và tiện ích cấp thấp
=======================================

Chức năng thư viện được sử dụng xuyên suốt kernel.

.. toctree::
   :maxdepth: 1

   kobject
   kref
   cleanup
   assoc_array
   folio_queue
   xarray
   maple_tree
   idr
   circular-buffers
   rbtree
   generic-radix-tree
   packing
   this_cpu_ops
   timekeeping
   errseq
   wrappers/atomic_t
   wrappers/atomic_bitops
   floating-point
   union_find
   min_heap
   parser
   list

Vào và ra ở mức độ thấp
========================

.. toctree::
   :maxdepth: 1

   entry

Nguyên thủy đồng thời
======================

Cách Linux ngăn chặn mọi việc xảy ra cùng một lúc.  Xem
Documentation/locking/index.rst để biết thêm tài liệu liên quan.

.. toctree::
   :maxdepth: 1

   refcount-vs-atomic
   irq/index
   local_ops
   padata
   ../RCU/index
   wrappers/memory-barriers.rst

Quản lý phần cứng cấp thấp
=============================

Quản lý bộ đệm, quản lý hotplug CPU, v.v.

.. toctree::
   :maxdepth: 1

   cachetlb
   cpu_hotplug
   memory-hotplug
   genericirq
   protection-keys

Quản lý bộ nhớ
=================

Cách phân bổ và sử dụng bộ nhớ trong kernel.  Lưu ý rằng có rất nhiều
thêm tài liệu về quản lý bộ nhớ trong Documentation/mm/index.rst.

.. toctree::
   :maxdepth: 1

   memory-allocation
   unaligned-memory-access
   dma-api
   dma-api-howto
   dma-attributes
   dma-isa-lpc
   swiotlb
   mm-api
   cgroup
   genalloc
   pin_user_pages
   boot-time-mm
   gfp_mask-from-fs-io
   kho/index

Giao diện gỡ lỗi kernel
===============================

.. toctree::
   :maxdepth: 1

   debug-objects
   tracepoint
   debugging-via-ohci1394

Mọi thứ khác
===============

Các tài liệu không phù hợp với nơi khác hoặc chưa được phân loại.

.. toctree::
   :maxdepth: 1

   librs
   liveupdate
   netlink
