.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/unstriped.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================================
Mục tiêu "không có sọc" của trình ánh xạ thiết bị
=================================================

Giới thiệu
============

Mục tiêu "không bị sọc" của trình ánh xạ thiết bị cung cấp một cơ chế minh bạch để
bỏ sọc mục tiêu "sọc" của trình ánh xạ thiết bị để truy cập vào các đĩa bên dưới
mà không cần phải chạm vào thiết bị khối hỗ trợ thực sự.  Nó cũng có thể
được sử dụng để giải mã phần cứng RAID-0 để truy cập vào đĩa sao lưu.

Thông số:
<số sọc> <kích thước chunk> <sọc #> <dev_path> <offset>

<số sọc>
        Số sọc trong RAID 0.

<kích thước khối>
	Số lượng 512B trong phân đoạn chunk.

<dev_path>
	Thiết bị khối bạn muốn gỡ bỏ sọc.

<sọc #>
        Số sọc trong thiết bị tương ứng với vật lý
        ổ đĩa bạn muốn gỡ sọc.  Điều này phải được lập chỉ mục 0.


Tại sao nên sử dụng mô-đun này?
====================

Một ví dụ về việc hoàn tác một dm-stripe hiện có
-------------------------------------------

Tập lệnh bash nhỏ này sẽ thiết lập 4 thiết bị lặp và sử dụng thiết bị hiện có
mục tiêu sọc để kết hợp 4 thiết bị thành một.  Sau đó nó sẽ sử dụng
mục tiêu không có sọc ở trên cùng của thiết bị có sọc để truy cập
các thiết bị vòng lặp hỗ trợ riêng lẻ.  Chúng tôi ghi dữ liệu vào phần mới được tiếp xúc
thiết bị không có sọc và xác minh dữ liệu được ghi khớp với nhau
thiết bị cơ bản trên mảng sọc::

#!/bin/bash

MEMBER_SIZE=$((128 * 1024 * 1024))
  NUM=4
  SEQ_END=$((${NUM}-1))
  CHUNK=256
  BS=4096

RAID_SIZE=$((${MEMBER_SIZE}*${NUM}/512))
  DM_PARMS="0 ${RAID_SIZE} sọc ${NUM} ${CHUNK}"
  COUNT=$((${MEMBER_SIZE} / ${BS}))

cho tôi ở $(seq 0 ${SEQ_END}); làm
    dd if=/dev/zero of=member-${i} bs=${MEMBER_SIZE} count=1 oflag=direct
    losttup /dev/loop${i} member-${i}
    DM_PARMS+=" /dev/loop${i} 0"
  xong

tiếng vang $DM_PARMS | dmsetup tạo raid0
  cho tôi ở $(seq 0 ${SEQ_END}); làm
    echo "0 1 không sọc ${NUM} ${CHUNK} ${i} /dev/mapper/raid0 0" | dmsetup tạo set-${i}
  xong;

cho tôi ở $(seq 0 ${SEQ_END}); làm
    dd if=/dev/urandom of=/dev/mapper/set-${i} bs=${BS} count=${COUNT} oflag=direct
    diff /dev/mapper/set-${i} member-${i}
  xong;

cho tôi ở $(seq 0 ${SEQ_END}); làm
    dmsetup xóa set-${i}
  xong

dmsetup loại bỏ raid0

cho tôi ở $(seq 0 ${SEQ_END}); làm
    thua lỗ -d /dev/loop${i}
    rm -f thành viên-${i}
  xong

Một ví dụ khác
---------------

Ổ đĩa Intel NVMe chứa hai lõi trên thiết bị vật lý.
Mỗi lõi của ổ đĩa có quyền truy cập riêng biệt vào phạm vi LBA của nó.
Mẫu LBA hiện tại có đoạn RAID 0 128k trên mỗi lõi, dẫn đến
trong một dải 256k trên hai lõi::

Lõi 0: Lõi 1:
  __________ __________
  ZZ0000ZZ ZZ0001ZZ
  ZZ0002ZZ ZZ0003ZZ
  ---------- ----------

Mục đích của việc giải mã này là cung cấp QoS tốt hơn trong môi trường ồn ào.
môi trường lân cận. Khi hai phân vùng được tạo trên
ổ đĩa tổng hợp mà không cần giải nén, đọc trên một phân vùng
có thể ảnh hưởng đến việc ghi trên phân vùng khác.  Điều này là do các phân vùng
được sọc trên hai lõi.  Khi chúng tôi giải mã phần cứng RAID 0 này
và tạo phân vùng trên mỗi thiết bị mới được hiển thị, hai phân vùng hiện có
bị tách biệt về mặt vật lý.

Với mục tiêu dm-unstriped, chúng tôi có thể tách tập lệnh fio
có các công việc đọc và viết độc lập với nhau.  So với
khi chúng tôi chạy thử nghiệm trên một ổ đĩa kết hợp có phân vùng, chúng tôi có thể
để giảm 92% độ trễ đọc bằng cách sử dụng mục tiêu của trình ánh xạ thiết bị này.


Ví dụ sử dụng dmsetup
=====================

không có sọc trên thiết bị Intel NVMe có 2 lõi
------------------------------------------------------

::

dmsetup tạo nvmset0 --table '0 512 không có sọc 2 256 0 /dev/nvme0n1 0'
  dmsetup tạo nvmset1 --table '0 512 unstriped 2 256 1 /dev/nvme0n1 0'

Hiện tại sẽ có 2 thiết bị lộ Intel NVMe core 0 và 1
tương ứng::

/dev/mapper/nvmset0
  /dev/mapper/nvmset1

unstriped on top sọc với 4 ổ sử dụng chunk size 128K
---------------------------------------------------------------

::

dmsetup tạo raid_disk0 --table '0 512 không sọc 4 256 0 /dev/mapper/sọc 0'
  dmsetup tạo raid_disk1 --table '0 512 không sọc 4 256 1/dev/mapper/sọc 0'
  dmsetup tạo raid_disk2 --table '0 512 không sọc 4 256 2/dev/mapper/sọc 0'
  dmsetup tạo raid_disk3 --table '0 512 không sọc 4 256 3 /dev/mapper/sọc 0'
