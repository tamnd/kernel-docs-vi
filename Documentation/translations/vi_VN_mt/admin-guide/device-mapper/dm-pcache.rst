.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/dm-pcache.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================
dm-pcache — Bộ đệm liên tục
=================================

ZZ0000ZZ

Tài liệu này mô tả ZZ0001ZZ, một mục tiêu Device-Mapper cho phép
Vùng ZZ0002ZZ (bộ nhớ liên tục, “pmem”) có thể định địa chỉ byte hoạt động như một
bộ nhớ đệm có hiệu suất cao, liên tục gặp sự cố trước một khối chậm hơn
thiết bị.  Mã tồn tại trong ZZ0000ZZ.

Tóm tắt tính năng nhanh
=====================

* Bộ nhớ đệm ZZ0001ZZ (hiện chỉ hỗ trợ chế độ này).
* ZZ0002ZZ được phân bổ trên thiết bị pmem.
* Xác minh ZZ0003ZZ (tùy chọn, trên mỗi bộ đệm).
* An toàn khi xảy ra sự cố: mọi cấu trúc siêu dữ liệu đều được sao chép (ZZ0000ZZ) và được bảo vệ bằng số thứ tự CRC+.
* ZZ0004ZZ (cây lập chỉ mục được phân chia theo địa chỉ logic) để có tính song song PMem cao
* I/O ZZ0005ZZ thuần túy – không có các chuyến khứ hồi BIO bổ sung
* ZZ0006ZZ duy trì tính nhất quán của sự cố phụ trợ


Người xây dựng
===========

::

pcache <cache_dev> <backing_dev> [<number_of_Option_arguments> <cache_mode writeback> <data_crc true|false>]

===================================================================================
ZZ0000ZZ Bất kỳ thiết bị khối nào có khả năng DAX (ZZ0001ZZ…).
                            Tất cả các khối được lưu trong bộ nhớ đệm siêu dữ liệu ZZ0002ZZ đều được lưu trữ ở đây.

ZZ0000ZZ Thiết bị khối chậm được lưu trữ.

ZZ0000ZZ Tùy chọn, Chỉ ZZ0001ZZ được chấp nhận tại
                            khoảnh khắc.

ZZ0000ZZ Tùy chọn, mặc định là ZZ0001ZZ

* ZZ0000ZZ – lưu trữ CRC32 cho mỗi mục được lưu trong bộ nhớ đệm
			      và xác minh khi đọc
                            * ZZ0001ZZ – bỏ qua CRC (nhanh hơn)
===================================================================================

Ví dụ
-------

.. code-block:: shell

   dmsetup create pcache_sdb --table \
     "0 $(blockdev --getsz /dev/sdb) pcache /dev/pmem0 /dev/sdb 4 cache_mode writeback data_crc true"

Lần đầu tiên thiết bị pmem được sử dụng, dm-pcache sẽ tự động định dạng thiết bị đó
(siêu khối, cache_info, v.v.).


Dòng trạng thái
===========

Bản in ZZ0000ZZ (ZZ0001ZZ):

::

<sb_flags> <seg_total> <cache_segs> <segs_used> \
   <gc_percent> <cache_flags> \
   <key_head_seg>:<key_head_off> \
   <dirty_tail_seg>:<dirty_tail_off> \
   <key_tail_seg>:<key_tail_off>

Ý nghĩa trường
--------------

==================================================================================
ZZ0000ZZ Cờ siêu khối (ví dụ: điểm đánh dấu cuối).

ZZ0000ZZ Số lượng phân đoạn ZZ0001ZZ vật lý.

ZZ0000ZZ Số lượng phân đoạn được sử dụng cho bộ đệm.

ZZ0000ZZ Phân đoạn hiện được phân bổ (trọng lượng bitmap).

ZZ0000ZZ Dấu nước cao GC hiện tại (0-90).

ZZ0000ZZ Bit 0 – Đã bật DATA_CRC
                                 Bit 1 - INIT_DONE (khởi tạo bộ đệm)
                                 Bit 2-5 – chế độ bộ đệm (0 == WB).

ZZ0000ZZ Nơi các bộ khóa mới đang được viết.

ZZ0000ZZ Bộ chìa khóa bẩn đầu tiên vẫn cần
                                 ghi lại vào thiết bị sao lưu.

ZZ0000ZZ Bộ khóa đầu tiên có thể được GC lấy lại.
==================================================================================


Tin nhắn
========

ZZ0000ZZ

::

thông báo dmsetup <dev> 0 gc_percent <0-90>


Lý thuyết hoạt động
===================

Thiết bị phụ
-----------

===================================================================================
backing_dev Bất kỳ thiết bị khối nào (SSD/HDD/loop/LVM, v.v.).
cache_dev thiết bị DAX; phải để lộ bộ nhớ truy cập trực tiếp.
===================================================================================

Phân đoạn và bộ khóa
---------------------

* Không gian pmem được chia thành ZZ0000ZZ.
* Mỗi lần ghi sẽ phân bổ không gian từ mỗi CPU ZZ0001ZZ bên trong một phân đoạn.
* ZZ0002ZZ ghi lại phạm vi logic về nguồn gốc và nơi nó tồn tại
  bên trong pmem (phân khúc + offset + thế hệ).
* 128 phím tạo thành ZZ0003ZZ (kset); ksets được viết tuần tự trong pmem
  và bản thân chúng có khả năng an toàn khi va chạm (CRC).
* Cặp ZZ0004ZZ phân định các kset sạch/bẩn và sống/chết.

Viết lại
----------

Chìa khóa bẩn được xếp thành hàng trên cây; một nhân viên nền sao chép dữ liệu
quay lại backing_dev và tiến tới ZZ0000ZZ.  Tiểu sử FLUSH/FUA từ
các lớp trên buộc phải cam kết siêu dữ liệu ngay lập tức.

Thu gom rác
------------------

GC bắt đầu khi ZZ0000ZZ.  Nó bước đi
từ ZZ0001ZZ, giải phóng các phân đoạn có mọi khóa đã bị vô hiệu và
tiến bộ ZZ0002ZZ.

Xác minh CRC
----------------

Nếu ZZ0000ZZ dm-pcache tính toán CRC32 trên mỗi dữ liệu được lưu trong bộ nhớ đệm
phạm vi khi nó được chèn và lưu nó trong khóa trên phương tiện.  Đọc
xác thực CRC trước khi sao chép cho người gọi.


Xử lý lỗi
================

* ZZ0002ZZ – tất cả các bản sao siêu dữ liệu đều được đọc bằng
  ZZ0000ZZ; nhật ký lỗi không thể sửa được và hủy bỏ quá trình khởi tạo.
* ZZ0003ZZ – nếu không tìm thấy phân đoạn trống nào, hãy viết return ZZ0001ZZ;
  dm-pcache thử lại nội bộ (yêu cầu trì hoãn).
* ZZ0004ZZ – khi đính kèm, trình điều khiển sẽ phát lại các kset từ ZZ0005ZZ đến
  xây dựng lại cây trong lõi; thế hệ của mỗi phân khúc bảo vệ chống lại
  phím sử dụng sau này miễn phí.


Hạn chế & TODO
==================

* Chỉ có chế độ ZZ0000ZZ; các chế độ khác theo kế hoạch.
* Chỉ bộ đệm FIFO không hợp lệ; kế hoạch khác (LRU, ARC...)
* Hiện tại việc tải lại bảng không được hỗ trợ.
* Loại bỏ theo kế hoạch.


Quy trình làm việc mẫu
================

.. code-block:: shell

   # 1.  Create devices
   dmsetup create pcache_sdb --table \
     "0 $(blockdev --getsz /dev/sdb) pcache /dev/pmem0 /dev/sdb 4 cache_mode writeback data_crc true"

   # 2.  Put a filesystem on top
   mkfs.ext4 /dev/mapper/pcache_sdb
   mount /dev/mapper/pcache_sdb /mnt

   # 3.  Tune GC threshold to 80 %
   dmsetup message pcache_sdb 0 gc_percent 80

   # 4.  Observe status
   watch -n1 'dmsetup status pcache_sdb'

   # 5.  Shutdown
   umount /mnt
   dmsetup remove pcache_sdb


ZZ0000ZZ đang được phát triển tích cực; phản hồi, báo cáo lỗi và bản vá
rất được hoan nghênh!