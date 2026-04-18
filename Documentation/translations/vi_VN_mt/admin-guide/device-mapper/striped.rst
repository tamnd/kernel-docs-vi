.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/striped.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========
sọc dm
==========

Mục tiêu "sọc" của Device-Mapper được sử dụng để tạo sọc (tức là RAID-0)
thiết bị trên một hoặc nhiều thiết bị cơ bản. Dữ liệu được ghi theo "khối",
với các khối liên tiếp xoay vòng giữa các thiết bị cơ bản. Điều này có thể
có khả năng cung cấp thông lượng I/O được cải thiện bằng cách sử dụng một số
các thiết bị song song.

Tham số: <num devs> <chunk size> [<dev path> <offset>]+
    <số nhà phát triển>:
	Số lượng thiết bị cơ bản
    <kích thước đoạn>:
	Kích thước của mỗi đoạn dữ liệu Ít nhất phải như
        lớn như PAGE_SIZE của hệ thống.
    <đường dẫn nhà phát triển>:
	Tên đường dẫn đầy đủ đến thiết bị khối cơ bản hoặc
	số thiết bị "chính:nhỏ".
    <bù đắp>:
	Khu vực bắt đầu trong thiết bị.

Một hoặc nhiều thiết bị cơ bản có thể được chỉ định. Kích thước thiết bị sọc phải
là bội số của kích thước khối nhân với số lượng thiết bị cơ bản.


Tập lệnh mẫu
===============

::

#!/usr/bin/Perl -w
  # Create một thiết bị sọc trên bất kỳ số lượng thiết bị cơ bản nào. thiết bị
  # will được gọi là "stripe_dev" và có kích thước chunk là 128k.

$ chunk_size của tôi = 128 * 2;
  $dev_name = "stripe_dev" của tôi;
  $num_devs của tôi = @ARGV;
  @dev của tôi = @ARGV;
  của tôi ($min_dev_size, $stripe_dev_size, $i);

nếu (!$num_devs) {
          die("Chỉ định ít nhất một thiết bị\n");
  }

$min_dev_size = ZZ0000ZZ;
  cho ($i = 1; $i < $num_devs; $i++) {
          $this_size của tôi = ZZ0001ZZ;
          $min_dev_size = ($min_dev_size < $this_size) ?
                          $min_dev_size : $this_size;
  }

$stripe_dev_size = $min_dev_size * $num_devs;
  $stripe_dev_size -= $stripe_dev_size % ($chunk_size * $num_devs);

$table = "0 $stripe_dev_size sọc $num_devs $chunk_size";
  cho ($i = 0; $i < $num_devs; $i++) {
          $table .= " $devs[$i] 0";
  }

ZZ0000ZZ;
