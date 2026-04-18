.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/kernel-api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================
Hạt nhân Linux API
====================


Các hàm thư viện C cơ bản
=========================

Khi viết trình điều khiển, nói chung bạn không thể sử dụng các thủ tục từ
Thư viện C. Một số chức năng nhìn chung được thấy là hữu ích
và chúng được liệt kê dưới đây. Hoạt động của các chức năng này có thể khác nhau
hơi khác so với những gì được xác định bởi ANSI và những sai lệch này được ghi chú trong
văn bản.

Chuyển đổi chuỗi
------------------

.. kernel-doc:: lib/vsprintf.c
   :export:

.. kernel-doc:: include/linux/kstrtox.h
   :functions: kstrtol kstrtoul

.. kernel-doc:: lib/kstrtox.c
   :export:

.. kernel-doc:: lib/string_helpers.c
   :export:

Thao tác chuỗi
-------------------

.. kernel-doc:: include/linux/fortify-string.h
   :internal:

.. kernel-doc:: lib/string.c
   :export:

.. kernel-doc:: include/linux/string.h
   :internal:

.. kernel-doc:: mm/util.c
   :functions: kstrdup kstrdup_const kstrndup kmemdup kmemdup_nul memdup_user
               vmemdup_user strndup_user memdup_user_nul

Các chức năng thư viện hạt nhân cơ bản
==============================

Nhân Linux cung cấp nhiều chức năng tiện ích cơ bản hơn.

Hoạt động bit
--------------

.. kernel-doc:: include/asm-generic/bitops/instrumented-atomic.h
   :internal:

.. kernel-doc:: include/asm-generic/bitops/instrumented-non-atomic.h
   :internal:

.. kernel-doc:: include/asm-generic/bitops/instrumented-lock.h
   :internal:

Hoạt động bitmap
-----------------

.. kernel-doc:: lib/bitmap.c
   :doc: bitmap introduction

.. kernel-doc:: include/linux/bitmap.h
   :doc: declare bitmap

.. kernel-doc:: include/linux/bitmap.h
   :doc: bitmap overview

.. kernel-doc:: include/linux/bitmap.h
   :doc: bitmap bitops

.. kernel-doc:: lib/bitmap.c
   :export:

.. kernel-doc:: lib/bitmap.c
   :internal:

.. kernel-doc:: include/linux/bitmap.h
   :internal:

Phân tích dòng lệnh
--------------------

.. kernel-doc:: lib/cmdline.c
   :export:

Con trỏ lỗi
--------------

.. kernel-doc:: include/linux/err.h
   :internal:

Sắp xếp
-------

.. kernel-doc:: lib/sort.c
   :export:

.. kernel-doc:: lib/list_sort.c
   :export:

Tìm kiếm văn bản
--------------

.. kernel-doc:: lib/textsearch.c
   :doc: ts_intro

.. kernel-doc:: lib/textsearch.c
   :export:

.. kernel-doc:: include/linux/textsearch.h
   :functions: textsearch_find textsearch_next \
               textsearch_get_pattern textsearch_get_pattern_len

CRC và các hàm toán học trong Linux
===============================

Kiểm tra tràn số học
----------------------------

.. kernel-doc:: include/linux/overflow.h
   :internal:

Chức năng CRC
-------------

.. kernel-doc:: lib/crc/crc4.c
   :export:

.. kernel-doc:: lib/crc/crc7.c
   :export:

.. kernel-doc:: lib/crc/crc8.c
   :export:

.. kernel-doc:: lib/crc/crc16.c
   :export:

.. kernel-doc:: lib/crc/crc-ccitt.c
   :export:

.. kernel-doc:: lib/crc/crc-itu-t.c
   :export:

.. kernel-doc:: include/linux/crc32.h

.. kernel-doc:: include/linux/crc64.h

Nhật ký cơ sở 2 và chức năng nguồn
------------------------------

.. kernel-doc:: include/linux/log2.h
   :internal:

Nhật ký số nguyên và chức năng nguồn
-------------------------------

.. kernel-doc:: include/linux/int_log.h

.. kernel-doc:: lib/math/int_pow.c
   :export:

.. kernel-doc:: lib/math/int_sqrt.c
   :export:

Hàm chia
------------------

.. kernel-doc:: include/asm-generic/div64.h
   :functions: do_div

.. kernel-doc:: include/linux/math64.h
   :internal:

.. kernel-doc:: lib/math/gcd.c
   :export:

UUID/GUID
---------

.. kernel-doc:: lib/uuid.c
   :export:

Cơ sở hạt nhân IPC
=====================

Tiện ích IPC
-------------

.. kernel-doc:: ipc/util.c
   :internal:

Bộ đệm FIFO
===========

giao diện kfifo
---------------

.. kernel-doc:: include/linux/kfifo.h
   :internal:

hỗ trợ giao diện chuyển tiếp
=======================

Hỗ trợ giao diện chuyển tiếp được thiết kế để cung cấp một cơ chế hiệu quả
cho các công cụ và phương tiện để chuyển tiếp lượng lớn dữ liệu từ hạt nhân
không gian sang không gian người dùng.

giao diện chuyển tiếp
---------------

.. kernel-doc:: kernel/relay.c
   :export:

.. kernel-doc:: kernel/relay.c
   :internal:

Hỗ trợ mô-đun
==============

Tự động tải mô-đun hạt nhân
--------------------------

.. kernel-doc:: kernel/module/kmod.c
   :export:

Gỡ lỗi mô-đun
----------------

.. kernel-doc:: kernel/module/stats.c
   :doc: module debugging statistics overview

dup_failed_modules - theo dõi các mô-đun bị lỗi trùng lặp
****************************************************

.. kernel-doc:: kernel/module/stats.c
   :doc: dup_failed_modules - tracks duplicate failed modules

bộ đếm debugf thống kê mô-đun
**********************************

.. kernel-doc:: kernel/module/stats.c
   :doc: module statistics debugfs counters

Hỗ trợ mô-đun liên
--------------------

Tham khảo các tập tin trong kernel/module/ để biết thêm thông tin.

Giao diện phần cứng
===================

Kênh DMA
------------

.. kernel-doc:: kernel/dma.c
   :export:

Quản lý tài nguyên
--------------------

.. kernel-doc:: kernel/resource.c
   :internal:

.. kernel-doc:: kernel/resource.c
   :export:

Xử lý MTRR
-------------

.. kernel-doc:: arch/x86/kernel/cpu/mtrr/mtrr.c
   :export:

Khung bảo mật
==================

.. kernel-doc:: security/security.c
   :internal:

.. kernel-doc:: security/inode.c
   :export:

Giao diện kiểm tra
================

.. kernel-doc:: kernel/audit.c
   :export:

.. kernel-doc:: kernel/auditsc.c
   :internal:

.. kernel-doc:: kernel/auditfilter.c
   :internal:

Khung kế toán
====================

.. kernel-doc:: kernel/acct.c
   :internal:

Chặn thiết bị
=============

.. kernel-doc:: include/linux/bio.h
.. kernel-doc:: block/blk-core.c
   :export:

.. kernel-doc:: block/blk-core.c
   :internal:

.. kernel-doc:: block/blk-map.c
   :export:

.. kernel-doc:: block/blk-sysfs.c
   :internal:

.. kernel-doc:: block/blk-settings.c
   :export:

.. kernel-doc:: block/blk-flush.c
   :export:

.. kernel-doc:: block/blk-lib.c
   :export:

.. kernel-doc:: block/blk-integrity.c
   :export:

.. kernel-doc:: kernel/trace/blktrace.c
   :internal:

.. kernel-doc:: block/genhd.c
   :internal:

.. kernel-doc:: block/genhd.c
   :export:

.. kernel-doc:: block/bdev.c
   :export:

thiết bị than
============

.. kernel-doc:: fs/char_dev.c
   :export:

Khung đồng hồ
===============

Khung đồng hồ xác định giao diện lập trình để hỗ trợ phần mềm
quản lý cây đồng hồ hệ thống. Khung này được sử dụng rộng rãi với
Nền tảng System-On-Chip (SOC) để hỗ trợ quản lý năng lượng và nhiều thứ khác nhau
các thiết bị có thể cần tốc độ xung nhịp tùy chỉnh. Lưu ý rằng những "đồng hồ" này
không liên quan đến chấm công hoặc đồng hồ thời gian thực (RTC), mỗi loại đều
có khung riêng biệt. Những chiếc ZZ0000ZZ này
Các phiên bản có thể được sử dụng để quản lý, ví dụ như tín hiệu 96 MHz được sử dụng
để chuyển các bit vào và ra khỏi các thiết bị ngoại vi hoặc bus, hoặc cách khác
kích hoạt chuyển đổi máy trạng thái đồng bộ trong phần cứng hệ thống.

Quản lý năng lượng được hỗ trợ bởi việc kiểm soát đồng hồ phần mềm rõ ràng: không sử dụng
đồng hồ bị vô hiệu hóa nên hệ thống không lãng phí năng lượng khi thay đổi
trạng thái của bóng bán dẫn không được sử dụng tích cực. Trên một số hệ thống, điều này có thể
được hỗ trợ bởi cổng đồng hồ phần cứng, nơi đồng hồ được kiểm soát mà không bị
bị vô hiệu hóa trong phần mềm. Các phần của chip được cấp nguồn nhưng không có xung nhịp
có thể giữ được trạng thái cuối cùng của họ. Trạng thái năng lượng thấp này thường
được gọi là ZZ0000ZZ. Chế độ này vẫn phát sinh dòng điện rò rỉ,
đặc biệt là với hình dạng mạch mịn hơn, nhưng đối với mạch CMOS, công suất là
chủ yếu được sử dụng bởi những thay đổi trạng thái đồng hồ.

Trình điều khiển nhận biết nguồn điện chỉ bật đồng hồ khi thiết bị họ quản lý
đang được sử dụng tích cực. Ngoài ra, trạng thái ngủ của hệ thống thường khác nhau tùy theo
miền đồng hồ nào đang hoạt động: trong khi trạng thái "chờ" có thể cho phép đánh thức
từ một số miền đang hoạt động, trạng thái "mem" (tạm dừng tới RAM) có thể yêu cầu
việc tắt đồng hồ nhiều hơn bắt nguồn từ PLL tốc độ cao hơn và
bộ dao động, hạn chế số lượng nguồn sự kiện đánh thức có thể xảy ra. A
phương pháp tạm dừng của người lái xe có thể cần phải biết về đồng hồ dành riêng cho hệ thống
hạn chế về trạng thái ngủ mục tiêu.

Một số nền tảng hỗ trợ bộ tạo xung nhịp có thể lập trình. Chúng có thể được sử dụng
bởi các loại chip bên ngoài, chẳng hạn như các CPU khác, các thiết bị đa phương tiện
codec và các thiết bị có yêu cầu nghiêm ngặt về xung nhịp giao diện.

.. kernel-doc:: include/linux/clk.h
   :internal:

Nguyên thủy đồng bộ hóa
==========================

Cập nhật đọc-sao chép (RCU)
----------------------

.. kernel-doc:: include/linux/rcupdate.h

.. kernel-doc:: kernel/rcu/tree.c

.. kernel-doc:: kernel/rcu/tree_exp.h

.. kernel-doc:: kernel/rcu/update.c

.. kernel-doc:: include/linux/srcu.h

.. kernel-doc:: kernel/rcu/srcutree.c

.. kernel-doc:: include/linux/rculist_bl.h

.. kernel-doc:: include/linux/rculist.h

.. kernel-doc:: include/linux/rculist_nulls.h

.. kernel-doc:: include/linux/rcu_sync.h

.. kernel-doc:: kernel/rcu/sync.c

.. kernel-doc:: kernel/rcu/tasks.h

.. kernel-doc:: kernel/rcu/tree_stall.h

.. kernel-doc:: include/linux/rcupdate_trace.h

.. kernel-doc:: include/linux/rcupdate_wait.h

.. kernel-doc:: include/linux/rcuref.h

.. kernel-doc:: include/linux/rcutree.h
