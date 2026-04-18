.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/linear.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========
dm-tuyến tính
=========

Mục tiêu "tuyến tính" của Device-Mapper ánh xạ một phạm vi tuyến tính của Device-Mapper
thiết bị này lên phạm vi tuyến tính của thiết bị khác.  Đây là tòa nhà cơ bản
khối quản lý khối lượng hợp lý.

Tham số: <đường dẫn dev> <offset>
    <đường dẫn nhà phát triển>:
	Tên đường dẫn đầy đủ đến thiết bị khối cơ bản hoặc
        số thiết bị "chính:nhỏ".
    <bù đắp>:
	Khu vực bắt đầu trong thiết bị.


Tập lệnh mẫu
===============

::

#!/bin/sh
  # Create ánh xạ nhận dạng cho thiết bị
  echo "0 ZZ0000ZZ tuyến tính $1 0" | dmsetup tạo danh tính

::

#!/bin/sh
  # Join 2 thiết bị cùng nhau
  size1=ZZ0000ZZ
  size2=ZZ0001ZZ
  echo "0 $size1 tuyến tính $1 0
  $size1 $size2 tuyến tính $2 0" | dmsetup tạo đã tham gia

::

#!/usr/bin/Perl -w
  # Split chia thiết bị thành các khối 4M rồi nối chúng lại với nhau theo thứ tự ngược lại.

$name = "đảo ngược" của tôi;
  $extent_size của tôi = 4 * 1024 * 2;
  $dev của tôi = $ARGV[0];
  bảng $ của tôi = "";
  số $ của tôi = 0;

if (! đã xác định($dev)) {
          die("Xin vui lòng chỉ định một thiết bị.\n");
  }

$dev_size của tôi = ZZ0000ZZ;
  $extents = int($dev_size / $extent_size) của tôi -
                (($dev_size % $extent_size) ? 1 : 0);

trong khi ($phạm vi > 0) {
          $this_start = $count * $extent_size của tôi;
          $phạm vi--;
          $count++;
          $this_offset = $extents * $extent_size của tôi;

$table .= "$this_start $extent_size tuyến tính $dev $this_offset\n";
  }

ZZ0000ZZ;
