.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/net_failover.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============
NET_FAILOVER
============

Tổng quan
========

Trình điều khiển net_failover cung cấp cơ chế chuyển đổi dự phòng tự động thông qua API
để tạo và hủy một netdev chuyển đổi dự phòng chính và quản lý một mạng chính và
netdev nô lệ dự phòng được đăng ký thông qua chuyển đổi dự phòng chung
cơ sở hạ tầng.

Netdev chuyển đổi dự phòng hoạt động như một thiết bị chính và điều khiển 2 thiết bị phụ. các
giao diện ảo ban đầu được đăng ký dưới dạng netdev nô lệ 'dự phòng' và
một thiết bị passthru/vf có cùng MAC được đăng ký làm nô lệ 'chính'
netdev. Cả netdev 'chế độ chờ' và 'chuyển đổi dự phòng' đều được liên kết với cùng một
thiết bị 'pci'. Người dùng truy cập vào giao diện mạng thông qua netdev 'chuyển đổi dự phòng'.
Netdev 'chuyển đổi dự phòng' chọn netdev 'chính' làm mặc định để truyền khi
nó có sẵn với liên kết và chạy.

Điều này có thể được sử dụng bởi trình điều khiển song song để kích hoạt độ trễ thấp thay thế
đường dẫn dữ liệu. Nó cũng cho phép di chuyển trực tiếp máy ảo được kiểm soát bởi hypervisor với
VF được đính kèm trực tiếp bằng cách chuyển sang đường dẫn dữ liệu ảo ảo khi VF
đã được rút phích cắm.

Đường dẫn dữ liệu tăng tốc virtio-net: chế độ STANDBY
=============================================

net_failover cho phép đường dẫn dữ liệu được tăng tốc được điều khiển bởi hypervisor tới virtio-net
kích hoạt máy ảo một cách minh bạch mà không có/tối thiểu những thay đổi về không gian người dùng dành cho khách.

Để hỗ trợ điều này, trình ảo hóa cần kích hoạt VIRTIO_NET_F_STANDBY
tính năng trên giao diện virtio-net và gán cùng một địa chỉ MAC cho cả hai
giao diện virtio-net và VF.

Dưới đây là đoạn mã libvirt XML ví dụ hiển thị cấu hình như vậy:
::

<loại giao diện='mạng'>
    <địa chỉ mac='52:54:00:00:12:53'/>
    <mạng nguồn='enp66s0f0_br'/>
    <target dev='tap01'/>
    <loại người mẫu='tài năng'/>
    <tên trình điều khiển='vhost' queues='4'/>
    <trạng thái liên kết='xuống'/>
    <loại nhóm='kiên trì'/>
    <tên bí danh='ua-backup0'/>
  </giao diện>
  <loại giao diện='hostdev' được quản lý='có'>
    <địa chỉ mac='52:54:00:00:12:53'/>
    <nguồn>
      <loại địa chỉ='pci' miền='0x0000' bus='0x42' slot='0x02' function='0x5'/>
    </ nguồn>
    <loại nhóm='transient' Persist='ua-backup0'/>
  </giao diện>

Trong cấu hình này, định nghĩa thiết bị đầu tiên dành cho virtio-net
giao diện và điều này hoạt động như thiết bị 'liên tục' cho biết rằng điều này
giao diện sẽ luôn được cắm vào. Điều này được chỉ định bởi thẻ 'teaming' với
loại thuộc tính bắt buộc có giá trị 'liên tục'. Trạng thái liên kết cho
thiết bị virtio-net được đặt thành 'không hoạt động' để đảm bảo rằng netdev 'chuyển đổi dự phòng' thích
thiết bị truyền qua VF để liên lạc thông thường. Thiết bị virtio-net sẽ
được đưa LÊN trong quá trình di chuyển trực tiếp để cho phép liên lạc không bị gián đoạn.

Định nghĩa thiết bị thứ hai dành cho giao diện truyền qua VF. Đây là
Thẻ 'nhóm' được cung cấp loại 'tạm thời' cho biết rằng thiết bị này có thể
định kỳ được rút phích cắm. Thuộc tính thứ hai - 'persistent' được cung cấp và
trỏ đến tên bí danh được khai báo cho thiết bị virtio-net.

Khởi động VM với cấu hình trên sẽ dẫn đến 3 lỗi sau
giao diện được tạo trong VM:
::

4: ens10: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc trạng thái noqueue UP nhóm mặc định qlen 1000
      liên kết/ether 52:54:00:00:12:53 brd ff:ff:ff:ff:ff:ff
      inet 192.168.12.53/24 brd 192.168.12.255 phạm vi toàn cầu năng động ens10
         valid_lft 42482 giây ưu tiên_lft 42482 giây
      liên kết phạm vi inet6 fe80::97d8:db2:8c10:b6d6/64
         valid_lft mãi mãi ưa thích_lft mãi mãi
  5: ens10nsby: <BROADCAST,MULTICAST> mtu 1500 qdisc fq_codel master ens10 trạng thái DOWN nhóm mặc định qlen 1000
      liên kết/ether 52:54:00:00:12:53 brd ff:ff:ff:ff:ff:ff
  7: ens11: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq master ens10 trạng thái UP nhóm mặc định qlen 1000
      liên kết/ether 52:54:00:00:12:53 brd ff:ff:ff:ff:ff:ff

Ở đây, ens10 là giao diện chính 'failover', ens10nsby là 'standby' phụ
giao diện virtio-net và ens11 là giao diện chuyển tiếp VF 'chính' phụ.

Một điểm cần lưu ý ở đây là một số daemon cấu hình mạng không gian người dùng
như systemd-networkd, ifupdown, v.v., không hiểu 'net_failover'
thiết bị; và trong lần khởi động đầu tiên, VM có thể gặp phải cả thiết bị 'chuyển đổi dự phòng'
và VF lấy địa chỉ IP (giống hoặc khác) từ máy chủ DHCP.
Điều này sẽ dẫn đến việc thiếu kết nối với VM. Vì vậy, một số điều chỉnh có thể là
cần thiết cho các trình nền cấu hình mạng này để đảm bảo rằng IP được
chỉ nhận được trên thiết bị 'chuyển đổi dự phòng'.

Dưới đây là đoạn vá được sử dụng với tập lệnh 'cloud-ifupdown-helper' được tìm thấy trên
Hình ảnh đám mây Debian::

@@ -27,6 +27,8 @@ do_setup() {
       local doing="$cfgdir/.$INTERFACE"
       cuối cùng cục bộ="$cfgdir/$INTERFACE"

+ if [ -d "/sys/class/net/${INTERFACE}/master" ]; sau đó thoát 0; fi
  +
       ifup --no-act "$INTERFACE" > /dev/null 2>&1; sau đó
           # interface đã biết ifupdown rồi, không cần tạo cfg
           log "Bỏ qua việc tạo cấu hình cho $INTERFACE"


Di chuyển trực tiếp máy ảo với SR-IOV VF & virtio-net ở chế độ STANDBY
==================================================================

net_failover cũng cho phép hỗ trợ di chuyển trực tiếp do hypervisor kiểm soát
với các máy ảo có thiết bị SR-IOV VF được gắn trực tiếp bằng cách tự động chuyển đổi dự phòng sang
đường dẫn dữ liệu ảo ảo khi rút phích cắm VF.

Đây là tập lệnh mẫu hiển thị các bước để bắt đầu di chuyển trực tiếp từ
trình ảo hóa nguồn. Lưu ý: Giả định rằng VM được kết nối với một
cầu phần mềm 'br0' có một VF duy nhất được gắn vào cùng với vnet
thiết bị vào VM. Đây không phải là VF được chuyển qua VM (xem trong
tệp vf.xml).
::

# cat vf.xml
  <loại giao diện='hostdev' được quản lý='có'>
    <địa chỉ mac='52:54:00:00:12:53'/>
    <nguồn>
      <loại địa chỉ='pci' miền='0x0000' bus='0x42' slot='0x02' function='0x5'/>
    </ nguồn>
    <loại nhóm='transient' Persist='ua-backup0'/>
  </giao diện>

# Source Hypervisor di chuyển.sh
  #!/bin/bash

DOMAIN=vm-01
  PF=ens6np0
  VF=ens6v1 # VF gắn vào cầu.
  VF_NUM=1
  Giao diện TAP_IF=vmtap01 # virtio-net trong VM.
  VF_XML=vf.xml

MAC=52:54:00:00:12:53
  ZERO_MAC=00:00:00:00:00:00

# Set giao diện virtio-net lên.
  virsh domif-setlink $DOMAIN $TAP_IF trở lên

# Remove VF được chuyển qua VM.
  thiết bị tách rời virsh --live --config $DOMAIN $VF_XML

bộ liên kết ip $PF vf $VF_NUM mac $ZERO_MAC

Mục nhập # Add FDB dành cho lưu lượng truy cập để tiếp tục đi tới VM thông qua
  # the VF -> br0 -> đường dẫn giao diện vnet.
  cầu fdb thêm $MAC dev $VF
  cầu nối fdb thêm nhà phát triển $MAC $TAP_IF chính

# Migrate máy ảo
  virsh di chuyển --live --persistent $DOMAIN qemu+ssh://$REMOTE_HOST/system

# Clean cập nhật các mục nhập FDB sau khi quá trình di chuyển hoàn tất.
  cầu fdb del $MAC nhà phát triển $VF
  bridge fdb del $MAC dev $TAP_IF master

Trên trình ảo hóa đích, cầu nối chung 'br0' được tạo trước khi di chuyển
bắt đầu và VF từ PF đích được thêm vào bridge. Tương tự như vậy một
mục nhập FDB thích hợp được thêm vào.

Tập lệnh sau được thực thi trên trình ảo hóa đích sau khi di chuyển
hoàn tất và nó gắn lại VF vào VM và hạ gục mạng virtio-net
giao diện::

# reattach-vf.sh
  #!/bin/bash

cầu fdb del 52:54:00:00:12:53 dev ens36v0
  cầu fdb del 52:54:00:00:12:53 dev vmtap01 master
  thiết bị đính kèm virsh --config --live vm01 vf.xml
  virsh domif-setlink vm01 vmtap01 bị hỏng