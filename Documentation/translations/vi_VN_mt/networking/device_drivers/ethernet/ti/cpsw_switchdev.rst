.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/ti/cpsw_switchdev.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================================================================
Trình điều khiển ethernet dựa trên Switchdev CPSW của Texas Instruments
=======================================================================

:Phiên bản: 2.0

Đổi tên cổng
=============

Trên các phiên bản udev cũ hơn, việc đổi tên ethX thành swXpY sẽ không tự động được thực hiện
được hỗ trợ

Để đổi tên qua udev::

liên kết ip -d hiển thị dev sw0p1 | chuyển đổi grep

SUBSYSTEM=="net", ACTION=="thêm", ATTR{phys_switch_id}==<switchid>, \
	    ATTR{phys_port_name}!="", NAME="sw0$attr{phys_port_name}"


Chế độ mac kép
==============

- Theo mặc định, trình điều khiển mới (cpsw_new.c) đang hoạt động ở chế độ emac kép, do đó
  hoạt động như 2 giao diện mạng riêng lẻ. Sự khác biệt chính so với CPSW cũ
  người lái xe là:

- chế độ lăng nhăng được tối ưu hóa: P0_UNI_FLOOD (cả hai cổng) được bật trong
   ngoài ALLMULTI (cổng hiện tại) thay vì ALE_BYPASS.
   Vì vậy, các cổng ở chế độ lăng nhăng sẽ giữ khả năng mcast và vlan
   lọc, mang lại lợi ích đáng kể khi các cổng được nối
   tới cùng một cây cầu nhưng không bật chế độ "chuyển đổi" hoặc sang cầu khác
   những cây cầu.
 - việc học bị vô hiệu hóa trên các cổng vì nó không có nhiều ý nghĩa đối với
   cổng tách biệt - không chuyển tiếp trong CTNH.
 - kích hoạt hỗ trợ cơ bản cho devlink.

   ::

chương trình phát triển devlink
		nền tảng/48484000.switch

chương trình thông số devlink dev
	nền tảng/48484000.switch:
	tên switch_mode loại trình điều khiển cụ thể
	giá trị:
		giá trị thời gian chạy cmode sai
	tên ale_bypass loại trình điều khiển cụ thể
	giá trị:
		giá trị thời gian chạy cmode sai

Thông số cấu hình Devlink
================================

Xem Tài liệu/mạng/devlink/ti-cpsw-switch.rst

Kết nối ở chế độ mac kép
=========================

Chế độ Dual_mac yêu cầu hai video được dành riêng cho mục đích nội bộ,
theo mặc định, số cổng CPSW bằng nhau. Kết quả là cầu phải được
được định cấu hình ở chế độ vlan không biết hoặc default_pvid phải được điều chỉnh ::

liên kết ip thêm tên br0 loại cầu
	bộ liên kết ip dev br0 loại cầu vlan_filtering 0
	echo 0 > /sys/class/net/br0/bridge/default_pvid
	bộ liên kết ip dev sw0p1 master br0
	bộ liên kết ip dev sw0p2 master br0

hoặc::

liên kết ip thêm tên br0 loại cầu
	bộ liên kết ip dev br0 loại cầu vlan_filtering 0
	echo 100 > /sys/class/net/br0/bridge/default_pvid
	bộ liên kết ip dev br0 loại cầu vlan_filtering 1
	bộ liên kết ip dev sw0p1 master br0
	bộ liên kết ip dev sw0p2 master br0

Kích hoạt "chuyển đổi"
======================

Chế độ Switch có thể được bật bằng cách định cấu hình tham số trình điều khiển devlink
"switch_mode" thành 1/true::

devlink dev param set platform/48484000.switch \
	tên switch_mode giá trị 1 thời gian chạy cmode

Điều này có thể được thực hiện bất kể trạng thái của thiết bị netdev của Cổng - UP/DOWN, nhưng
Các thiết bị netdev của Port phải ở trạng thái UP trước khi kết nối với bridge để tránh
ghi đè cấu hình cầu khi trình điều khiển chuyển đổi CPSW tải lại hoàn toàn
cấu hình khi Cổng đầu tiên thay đổi trạng thái thành UP.

Khi cả hai giao diện đã tham gia cầu nối - trình điều khiển chuyển đổi CPSW sẽ kích hoạt
đánh dấu các gói bằng cờ offload_fwd_mark trừ khi "ale_bypass=0"

Tất cả cấu hình được thực hiện thông qua switchdev API.

Thiết lập cầu
=============

::

devlink dev param set platform/48484000.switch \
	tên switch_mode giá trị 1 thời gian chạy cmode

liên kết ip thêm tên br0 loại cầu
	bộ liên kết ip dev br0 loại cầu lão hóa_time 1000
	liên kết ip được thiết lập dev sw0p1 lên
	liên kết ip được thiết lập dev sw0p2 lên
	bộ liên kết ip dev sw0p1 master br0
	bộ liên kết ip dev sw0p2 master br0

[*] bridge vlan add dev br0 vid 1 pvid untagged self

[*] nếu vlan_filtering=1. ở đâu default_pvid=1

Ghi chú. Các bước [*] là bắt buộc.


Bật/tắt STP
===========

::

bộ liên kết ip dev BRDEV loại cầu stp_state 1/0

Cấu hình VLAN
==================

::

bridge vlan add dev br0 vid 1 pvid untagged self <---- thêm cổng cpu vào VLAN 1

Ghi chú. Bước này là bắt buộc đối với bridge/default_pvid.

Thêm Vlan bổ sung
=================

1. không được gắn thẻ::

bridge vlan add dev sw0p1 vid 100 pvid untagged master
	bridge vlan add dev sw0p2 vid 100 pvid untagged master
	bridge vlan add dev br0 vid 100 pvid untagged self <--- Thêm cổng cpu vào VLAN100

2. được gắn thẻ::

bridge vlan add dev sw0p1 vid 100 master
	bridge vlan add dev sw0p2 vid 100 master
	bridge vlan add dev br0 vid 100 pvid được gắn thẻ tự <---- Thêm cổng cpu vào VLAN100

FDB
----

FDB được tự động thêm vào cổng chuyển đổi thích hợp khi phát hiện

Thêm FDB theo cách thủ công::

cầu fdb thêm aa:bb:cc:dd:ee:ff dev sw0p1 master vlan 100
    bridge fdb add aa:bb:cc:dd:ee:fe dev sw0p2 master <---- Thêm vào tất cả các VLAN

MDB
----

MDB được tự động thêm vào cổng chuyển đổi thích hợp khi phát hiện

Thêm MDB theo cách thủ công::

cầu mdb thêm dev br0 cổng sw0p1 grp 239.1.1.1 vĩnh viễn vid 100
  bridge mdb thêm dev br0 port sw0p1 grp 239.1.1.1 vĩnh viễn <---- Thêm vào tất cả các Vlan

Lũ lụt đa hướng
==================
Cổng CPU mcast_flooding luôn bật

Bật/tắt tràn trên các cổng switch:
bộ liên kết cầu dev sw0p1 mcast_flood bật/tắt

Cổng truy cập và trung kế
=========================

::

bridge vlan add dev sw0p1 vid 100 pvid untagged master
 bridge vlan add dev sw0p2 vid 100 master


bridge vlan add dev br0 vid 100 self
 liên kết ip thêm liên kết br0 tên br0.100 loại vlan id 100

Ghi chú. Cài đặt PVID trên chính thiết bị Bridge chỉ hoạt động đối với
VLAN mặc định (default_pvid).

NFS
===

Cách duy nhất để NFS hoạt động là chroot ở môi trường tối thiểu khi
cấu hình chuyển đổi sẽ ảnh hưởng đến kết nối là cần thiết.
Giả sử bạn đang khởi động NFS với giao diện eth1 (tập lệnh bị hack và
nó chỉ ở đó để chứng minh NFS là có thể thực hiện được).

thiết lập.sh::

#!/bin/sh
	quá trình mkdir
	mount -t proc none /proc
	ifconfig br0 > /dev/null
	nếu [ $? -ne 0 ]; sau đó
		echo "Lắp cầu"
		liên kết ip thêm tên br0 loại cầu
		bộ liên kết ip dev br0 loại cầu lão hóa_time 1000
		bộ liên kết ip dev br0 loại cầu vlan_filtering 1

liên kết ip đặt eth1 xuống
		liên kết ip đặt tên eth1 sw0p1
		liên kết ip được thiết lập dev sw0p1 lên
		liên kết ip được thiết lập dev sw0p2 lên
		bộ liên kết ip dev sw0p2 master br0
		bộ liên kết ip dev sw0p1 master br0
		bridge vlan add dev br0 vid 1 pvid untagged self
		ifconfig sw0p1 0.0.0.0
		udhchc -i br0
	fi
	umount /proc

run_nfs.sh:::

#!/bin/sh
	mkdir /tmp/root/bin -p
	mkdir /tmp/root/lib -p

cp -r /lib/ /tmp/root/
	cp -r /bin/ /tmp/root/
	cp /sbin/ip /tmp/root/bin
	cp /sbin/bridge /tmp/root/bin
	cp /sbin/ifconfig /tmp/root/bin
	cp /sbin/udhcpc /tmp/root/bin
	cp /path/to/setup.sh /tmp/root/bin
	chroot /tmp/root/ busybox sh /bin/setup.sh

chạy ./run_nfs.sh