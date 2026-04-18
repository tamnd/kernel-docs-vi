.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/ti/am65_nuss_cpsw_switchdev.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================================================
Trình điều khiển ethernet dựa trên switchdev của Texas Instruments K3 AM65 CPSW NUSS
===================================================================

:Phiên bản: 1.0

Đổi tên cổng
=============

Để đổi tên qua udev::

liên kết ip -d hiển thị dev sw0p1 | chuyển đổi grep

SUBSYSTEM=="net", ACTION=="thêm", ATTR{phys_switch_id}==<switchid>, \
	    ATTR{phys_port_name}!="", NAME="sw0$attr{phys_port_name}"


Chế độ đa mac
==============

- Trình điều khiển mặc định hoạt động ở chế độ multi-mac, do đó
  hoạt động như N giao diện mạng riêng lẻ.

Thông số cấu hình Devlink
================================

Xem Tài liệu/mạng/devlink/am65-nuss-cpsw-switch.rst

Kích hoạt "chuyển đổi"
=================

Chế độ Switch có thể được bật bằng cách định cấu hình tham số trình điều khiển devlink
"switch_mode" thành 1/true::

devlink dev param set platform/c000000.ethernet \
        tên switch_mode giá trị thời gian chạy cmode thực

Điều này có thể được thực hiện bất kể trạng thái của thiết bị netdev của Cổng - UP/DOWN, nhưng
Các thiết bị netdev của Port phải ở trạng thái UP trước khi kết nối với bridge để tránh
ghi đè cấu hình cầu khi trình điều khiển chuyển đổi CPSW tải lại hoàn toàn
cấu hình khi cổng đầu tiên thay đổi trạng thái thành UP.

Khi cả hai giao diện đã tham gia cầu nối - trình điều khiển chuyển đổi CPSW sẽ kích hoạt
đánh dấu các gói bằng cờ offload_fwd_mark.

Tất cả cấu hình được thực hiện thông qua switchdev API.

Thiết lập cầu
============

::

devlink dev param set platform/c000000.ethernet \
        tên switch_mode giá trị thời gian chạy cmode thực

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
==========

::

bộ liên kết ip dev BRDEV loại cầu stp_state 1/0

Cấu hình VLAN
==================

::

bridge vlan add dev br0 vid 1 pvid untagged self <---- thêm cổng cpu vào VLAN 1

Ghi chú. Bước này là bắt buộc đối với bridge/default_pvid.

Thêm Vlan bổ sung
===============

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
=====================

::

bridge vlan add dev sw0p1 vid 100 pvid untagged master
 bridge vlan add dev sw0p2 vid 100 master


bridge vlan add dev br0 vid 100 self
 liên kết ip thêm liên kết br0 tên br0.100 loại vlan id 100

Ghi chú. Việc cài đặt PVID trên thiết bị Bridge chỉ hoạt động đối với
VLAN mặc định (default_pvid).