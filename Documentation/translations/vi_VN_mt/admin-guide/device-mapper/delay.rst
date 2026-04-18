.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/delay.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========
dm-độ trễ
=========

Độ trễ mục tiêu "độ trễ" của Device-Mapper đọc và/hoặc ghi
và/hoặc xóa và tùy ý ánh xạ chúng tới các thiết bị khác nhau.

Lập luận::

<thiết bị> <offset> <delay> [<write_device> <write_offset> <write_delay>
			       [<flush_device> <flush_offset> <flush_delay>]]

Dòng trong bảng phải có 3, 6 hoặc 9 đối số:

3: áp dụng offset và delay cho các thao tác đọc, ghi và xóa trên thiết bị

6: áp dụng offset và delay cho thiết bị, đồng thời áp dụng write_offset và write_delay
   để ghi và xóa các thao tác trên write_device tùy chọn khác nhau với
   tùy chọn bù trừ ngành khác nhau

9: giống như 6 đối số cộng với xác định rõ ràng Flush_offset và Flush_delay
   bật/với Flush_device/flush_offset tùy chọn khác nhau.

Phần bù được chỉ định trong các lĩnh vực.

Độ trễ được chỉ định bằng mili giây.


Tập lệnh mẫu
===============

::
	#!/bin/sh
	#
	Thiết bị được ánh xạ # Create có tên "bị trì hoãn" làm trì hoãn các hoạt động đọc, ghi và xóa trong 500 mili giây.
	#
	dmsetup tạo độ trễ --bảng "0 ZZ0000ZZ độ trễ $1 0 500"

::
	#!/bin/sh
	#
	Thiết bị được ánh xạ # Create trì hoãn hoạt động ghi và xóa trong 400ms và
	# splitting đọc vào thiết bị $1 nhưng ghi và xóa sang thiết bị khác $2
	# to có độ lệch khác nhau lần lượt là 2048 và 4096 lĩnh vực.
	#
	dmsetup tạo độ trễ --bảng "0 độ trễ ZZ0000ZZ $1 2048 0 $2 4096 400"

::
	#!/bin/sh
	#
	Thiết bị được ánh xạ # Create trì hoãn đọc trong 50 mili giây, ghi trong 100 mili giây và xóa trong 333 mili giây
	# onto thiết bị hỗ trợ tương tự ở các cung 0 offset.
	#
	dmsetup tạo độ trễ --bảng "0 ZZ0000ZZ độ trễ $1 0 50 $2 0 100 $1 0 333"
