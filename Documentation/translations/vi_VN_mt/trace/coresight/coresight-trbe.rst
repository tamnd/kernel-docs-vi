.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/trace/coresight/coresight-trbe.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================================
Phần mở rộng bộ đệm dấu vết (TRBE).
==============================

:Tác giả: Anshuman Khandual <anshuman.khandual@arm.com>
    :Ngày: Tháng 11 năm 2020

Mô tả phần cứng
--------------------

Trace Buffer Extension (TRBE) là phần cứng percpu ghi lại trong hệ thống
bộ nhớ, dấu vết CPU được tạo từ đơn vị theo dõi percpu tương ứng. Cái này
được cắm vào như một thiết bị chìm coresight vì dấu vết tương ứng
máy phát điện (ETE), được cắm vào làm thiết bị nguồn.

TRBE không tuân thủ các thông số kỹ thuật của kiến trúc CoreSight, nhưng
được điều khiển thông qua khung trình điều khiển CoreSight để hỗ trợ ETE (được
Tích hợp tuân thủ CoreSight).

Các tập tin và thư mục Sysfs
---------------------------

Các thiết bị TRBE xuất hiện trên bus coresight hiện có cùng với các thiết bị khác
thiết bị coresight::

>$ ls /sys/bus/coresight/thiết bị
	trbe0 trbe1 trbe2 trbe3

ZZ0000ZZ có tên TRBE được liên kết với CPU.::

>$ ls /sys/bus/coresight/devices/trbe0/
        căn chỉnh cờ

ZZ0002ZZ
   * ZZ0000ZZ: TRBE căn chỉnh con trỏ ghi
   * ZZ0001ZZ: TRBE cập nhật bộ nhớ với các cờ truy cập và bẩn