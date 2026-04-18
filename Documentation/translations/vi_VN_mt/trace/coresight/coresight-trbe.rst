.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/trace/coresight/coresight-trbe.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================================
Phần mở rộng bộ đệm dấu vết (TRBE).
===================================

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