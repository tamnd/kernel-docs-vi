.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/cdc_mbim.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================================================
cdc_mbim - Trình điều khiển cho modem băng thông rộng di động CDC MBIM
======================================================================

Trình điều khiển cdc_mbim hỗ trợ các thiết bị USB tuân theo "Universal
Đặc tả lớp con lớp truyền thông bus nối tiếp dành cho thiết bị di động
Mô hình giao diện băng thông rộng" [1], là sự phát triển hơn nữa của
"Thông số kỹ thuật phân lớp của lớp truyền thông bus nối tiếp đa năng dành cho
Thiết bị mô hình điều khiển mạng" [2] được tối ưu hóa cho băng thông rộng di động
thiết bị, hay còn gọi là "modem 3G/LTE".


Tham số dòng lệnh
=======================

Trình điều khiển cdc_mbim không có tham số riêng.  Nhưng việc thăm dò
hành vi dành cho các chức năng MBIM tương thích ngược NCM 1.0 (một
"Chức năng NCM/MBIM" như được định nghĩa trong phần 3.2 của [1]) bị ảnh hưởng
bởi tham số trình điều khiển cdc_ncm:

thích_mbim
-----------
:Loại: Boolean
:Phạm vi hợp lệ: Không áp dụng (0-1)
: Giá trị mặc định: Y (ưu tiên MBIM)

Tham số này đặt chính sách hệ thống cho các chức năng NCM/MBIM.  Như vậy
các chức năng sẽ được xử lý bởi trình điều khiển cdc_ncm hoặc cdc_mbim
trình điều khiển tùy thuộc vào cài đặt Prefer_mbim.  Cài đặt thích_mbim=N
làm cho trình điều khiển cdc_mbim bỏ qua các chức năng này và cho phép cdc_ncm
thay vào đó, người lái xe sẽ xử lý chúng.

Tham số có thể ghi và có thể thay đổi bất cứ lúc nào. Hướng dẫn sử dụng
cần phải hủy liên kết/liên kết để thay đổi có hiệu lực đối với NCM/MBIM
các chức năng được liên kết với trình điều khiển "sai"


Cách sử dụng cơ bản
===========

Các chức năng MBIM không hoạt động khi không được quản lý. Chỉ trình điều khiển cdc_mbim
cung cấp giao diện không gian người dùng cho kênh điều khiển MBIM và sẽ
không tham gia quản lý chức năng. Điều này ngụ ý rằng một
ứng dụng quản lý không gian người dùng MBIM luôn được yêu cầu để kích hoạt
Chức năng MBIM.

Các ứng dụng không gian người dùng như vậy bao gồm nhưng không giới hạn ở:

- mbimcli (có trong thư viện libmbim [3]) và
 - Trình quản lý modem [4]

Việc thiết lập phiên IP MBIM yêu cầu ít nhất những hành động này bởi
ứng dụng quản lý:

- mở kênh điều khiển
 - cấu hình cài đặt kết nối mạng
 - kết nối với mạng
 - cấu hình giao diện IP

Phát triển ứng dụng quản lý
----------------------------------
Giao diện không gian người dùng <-> của trình điều khiển được mô tả bên dưới.  MBIM
giao thức kênh điều khiển được mô tả trong [1].


Không gian người dùng kênh điều khiển MBIM ABI
==================================

Thiết bị ký tự /dev/cdc-wdmX
------------------------------
Trình điều khiển tạo đường ống hai chiều đến kênh điều khiển chức năng MBIM
sử dụng trình điều khiển cdc-wdm làm trình điều khiển phụ.  Phần cuối không gian người dùng của
ống kênh điều khiển là một thiết bị ký tự /dev/cdc-wdmX.

Trình điều khiển cdc_mbim không xử lý hoặc kiểm soát các thông báo trên bộ điều khiển
kênh.  Kênh được ủy quyền hoàn toàn cho việc quản lý không gian người dùng
ứng dụng.  Do đó, tùy thuộc vào ứng dụng này để đảm bảo rằng nó
tuân thủ tất cả các yêu cầu về kênh điều khiển trong [1].

Thiết bị cdc-wdmX được tạo dưới dạng con của điều khiển MBIM
giao diện thiết bị USB.  Thiết bị ký tự được liên kết với một thiết bị cụ thể
Hàm MBIM có thể được tra cứu bằng sysfs.  Ví dụ::

bjorn@nemi:~$ ls /sys/bus/usb/drivers/cdc_mbim/2-4:2.12/usbmisc
 cdc-wdm0

bjorn@nemi:~$ grep . /sys/bus/usb/drivers/cdc_mbim/2-4:2.12/usbmisc/cdc-wdm0/dev
 180:0


Mô tả cấu hình USB
-----------------------------
Trường wMaxControlMessage của bộ mô tả chức năng CDC MBIM
giới hạn kích thước thông báo điều khiển tối đa. Ứng dụng quản lý là
chịu trách nhiệm đàm phán kích thước thông điệp điều khiển tuân thủ các
yêu cầu trong phần 9.3.1 của [1], lấy trường mô tả này
được xem xét.

Ứng dụng không gian người dùng có thể truy cập chức năng CDC MBIM
bộ mô tả của hàm MBIM bằng cách sử dụng một trong hai USB
giao diện hạt nhân mô tả cấu hình được mô tả trong [6] hoặc [7].

Xem thêm tài liệu ioctl bên dưới.


Sự phân mảnh
-------------
Ứng dụng vùng người dùng chịu trách nhiệm về tất cả thông báo điều khiển
phân mảnh và chống phân mảnh, như được mô tả trong phần 9.5 của [1].


/dev/cdc-wdmX write()
---------------------
Các thông báo điều khiển MBIM từ ứng dụng quản lý ZZ0000ZZ
vượt quá kích thước thông báo điều khiển đã thương lượng.


/dev/cdc-wdmX read()
--------------------
Ứng dụng quản lý ZZ0000ZZ chấp nhận các thông báo điều khiển của
kích thước thông điệp điều khiển được đàm phán.


/dev/cdc-wdmX ioctl()
---------------------
IOCTL_WDM_MAX_COMMAND: Nhận kích thước lệnh tối đa
Ioctl này trả về trường wMaxControlMessage của CDC MBIM
mô tả chức năng cho các thiết bị MBIM.  Điều này được dự định như một
thuận tiện, loại bỏ nhu cầu phân tích các bộ mô tả USB từ
không gian người dùng.

::

#include <stdio.h>
	#include <fcntl.h>
	#include <sys/ioctl.h>
	#include <linux/types.h>
	#include <linux/usb/cdc-wdm.h>
	int chính()
	{
		__u16 tối đa;
		int fd = open("/dev/cdc-wdm0", O_RDWR);
		if (!ioctl(fd, IOCTL_WDM_MAX_COMMAND, &max))
			printf("wMaxControlMessage là %d\n", max);
	}


Dịch vụ thiết bị tùy chỉnh
----------------------
Đặc tả MBIM cho phép nhà cung cấp tự do xác định các tính năng bổ sung
dịch vụ.  Điều này được hỗ trợ đầy đủ bởi trình điều khiển cdc_mbim.

Hỗ trợ cho các dịch vụ MBIM mới, bao gồm các dịch vụ do nhà cung cấp chỉ định, là
được triển khai hoàn toàn trong không gian người dùng, giống như phần còn lại của điều khiển MBIM
giao thức

Các dịch vụ mới phải được đăng ký trong Sổ đăng ký MBIM [5].



Không gian người dùng kênh dữ liệu MBIM ABI
===============================

thiết bị mạng wwanY
--------------------
Trình điều khiển cdc_mbim đại diện cho kênh dữ liệu MBIM dưới dạng một kênh duy nhất
thiết bị mạng thuộc loại "wwan". Thiết bị mạng này ban đầu được
được ánh xạ tới phiên IP MBIM 0.


Phiên IP được ghép kênh (IPS)
-----------------------------
MBIM cho phép ghép kênh lên tới 256 phiên IP trên một dữ liệu USB
kênh.  Trình điều khiển cdc_mbim mô hình hóa các phiên IP như 802.1q VLAN
thiết bị con của thiết bị wwanY chính, ánh xạ phiên IP MBIM tới
VLAN ID Z cho tất cả các giá trị Z lớn hơn 0.

Z tối đa của thiết bị được đưa ra trong cấu trúc MBIM_DEVICE_CAPS_INFO
được mô tả trong phần 10.5.1 của [1].

Ứng dụng quản lý không gian người dùng chịu trách nhiệm thêm mới
VLAN liên kết trước khi thiết lập các phiên IP MBIM trong đó SessionId
lớn hơn 0. Các liên kết này có thể được thêm bằng cách sử dụng VLAN thông thường
giao diện kernel, ioctl hoặc netlink.

Ví dụ: thêm liên kết cho phiên IP MBIM với SessionId 3::

liên kết ip thêm liên kết wwan0 tên wwan0.3 loại vlan id 3

Trình điều khiển sẽ tự động ánh xạ thiết bị mạng "wwan0.3" tới MBIM
Phiên IP 3.


Luồng dịch vụ thiết bị (DSS)
----------------------------
MBIM cũng cho phép ghép kênh lên tới 256 luồng dữ liệu không phải IP
cùng một kênh dữ liệu USB được chia sẻ.  Trình điều khiển cdc_mbim mô hình hóa những điều này
phiên như một tập hợp các thiết bị con 802.1q VLAN khác của wwanY chính
thiết bị, ánh xạ MBIM DSS phiên A tới VLAN ID (256 + A) cho tất cả các giá trị
của A

Giá trị A tối đa của thiết bị được đưa ra trong MBIM_DEVICE_SERVICES_INFO
cấu trúc được mô tả trong phần 10.5.29 của [1].

Các thiết bị con DSS VLAN được sử dụng làm giao diện thực tế giữa
kênh dữ liệu MBIM được chia sẻ và ứng dụng không gian người dùng nhận biết MBIM DSS.
Nó không nhằm mục đích trình bày nguyên trạng cho người dùng cuối. các
giả định là ứng dụng không gian người dùng đang khởi tạo phiên DSS
cũng đảm nhiệm việc đóng khung cần thiết cho dữ liệu DSS, trình bày
luồng tới người dùng cuối theo cách thích hợp cho loại luồng.

Thiết bị mạng ABI yêu cầu tiêu đề ethernet giả cho mọi DSS
khung dữ liệu đang được vận chuyển.  Nội dung của tiêu đề này là
tùy ý, ngoại trừ các trường hợp sau:

- Các khung TX sử dụng giao thức IP (0x0800 hoặc 0x86dd) sẽ bị loại bỏ
 - Khung RX sẽ có trường giao thức được đặt thành ETH_P_802_3 (nhưng sẽ
   không được định dạng đúng khung 802.3)
 - Khung RX sẽ có địa chỉ đích được đặt cho phần cứng
   địa chỉ của thiết bị chủ

Ứng dụng quản lý không gian người dùng hỗ trợ DSS chịu trách nhiệm
thêm tiêu đề ethernet giả trên TX và loại bỏ nó trên RX.

Đây là một ví dụ đơn giản sử dụng các công cụ phổ biến, xuất
DssSessionId 5 dưới dạng thiết bị ký tự pty được trỏ đến bởi /dev/nmea
liên kết tượng trưng::

liên kết ip thêm liên kết wwan0 tên wwan0.dss5 loại vlan id 261
  liên kết ip được đặt dev wwan0.dss5 lên
  socat INTERFACE:wwan0.dss5,type=2 PTY:,echo=0,link=/dev/nmea

Đây chỉ là một ví dụ, phù hợp nhất để thử nghiệm DSS
dịch vụ. Các ứng dụng không gian người dùng hỗ trợ các dịch vụ MBIM DSS cụ thể
dự kiến sẽ sử dụng các công cụ và giao diện lập trình theo yêu cầu của
dịch vụ đó.

Lưu ý rằng việc thêm liên kết VLAN cho các phiên DSS là hoàn toàn tùy chọn.  A
thay vào đó, ứng dụng quản lý có thể chọn liên kết một ổ cắm gói
trực tiếp đến thiết bị mạng chính, sử dụng thẻ VLAN đã nhận để
ánh xạ các khung tới phiên DSS chính xác và thêm ethernet VLAN 18 byte
tiêu đề có thẻ thích hợp trên TX.  Trong trường hợp này sử dụng ổ cắm
bộ lọc được khuyến nghị, chỉ khớp với tập hợp con DSS VLAN. Điều này tránh
sao chép không cần thiết dữ liệu phiên IP không liên quan vào không gian người dùng.  Ví dụ::

cấu trúc tĩnh sock_filter dssfilter[] = {
	/* sử dụng offset âm đặc biệt để nhận thẻ VLAN */
	BPF_STMT(BPF_LDZZ0000ZZBPF_ABS, SKF_AD_OFF + SKF_AD_VLAN_TAG_PRESENT),
	BPF_JUMP(BPF_JMPZZ0001ZZBPF_K, 1, 0, 6), /* đúng */

/* xác minh phạm vi DSS VLAN */
	BPF_STMT(BPF_LDZZ0000ZZBPF_ABS, SKF_AD_OFF + SKF_AD_VLAN_TAG),
	BPF_JUMP(BPF_JMPZZ0001ZZBPF_K, 256, 0, 4), /* 256 là DSS VLAN đầu tiên */
	BPF_JUMP(BPF_JMPZZ0002ZZBPF_K, 512, 3, 0), /* 511 là DSS VLAN cuối cùng */

/* xác minh loại ether */
	BPF_STMT(BPF_LDZZ0000ZZBPF_ABS, 2 * ETH_ALEN),
	BPF_JUMP(BPF_JMPZZ0001ZZBPF_K, ETH_P_802_3, 0, 1),

BPF_STMT(BPF_RET|BPF_K, (u_int)-1), /* chấp nhận */
	BPF_STMT(BPF_RET|BPF_K, 0), /* bỏ qua */
  };



Được gắn thẻ phiên IP 0 VLAN
------------------------
Như đã mô tả ở trên, phiên IP 0 của MBIM được coi là đặc biệt bởi
người lái xe.  Ban đầu nó được ánh xạ tới các khung không được gắn thẻ trên wwanY
thiết bị mạng.

Ánh xạ này ngụ ý một số hạn chế đối với IPS và DSS được ghép kênh
các phiên, có thể không phải lúc nào cũng thực tế:

- không có phiên IPS hoặc DSS nào có thể sử dụng kích thước khung hình lớn hơn MTU trên
   phiên IP 0
 - không phiên IPS hoặc DSS nào có thể ở trạng thái hoạt động trừ khi mạng
   thiết bị đại diện cho phiên IP 0 cũng hoạt động

Những vấn đề này có thể tránh được bằng cách tùy chọn tạo bản đồ IP trình điều khiển
phiên 0 đến thiết bị con VLAN, tương tự như tất cả các phiên IP khác.  Cái này
hành vi được kích hoạt bằng cách thêm liên kết VLAN cho ID VLAN ma thuật
4094. Sau đó, trình điều khiển sẽ ngay lập tức bắt đầu ánh xạ phiên IP MBIM
0 vào VLAN này và sẽ thả các khung không được gắn thẻ trên wwanY chính
thiết bị.

Mẹo: Người dùng cuối có thể ít nhầm lẫn hơn khi đặt tên cho VLAN này
thiết bị phụ sau MBIM SessionID thay vì ID VLAN.  Ví dụ::

liên kết ip thêm liên kết wwan0 tên wwan0.0 gõ vlan id 4094


Ánh xạ VLAN
------------

Tóm tắt ánh xạ trình điều khiển cdc_mbim được mô tả ở trên, chúng ta có cái này
mối quan hệ giữa thẻ VLAN trên thiết bị mạng wwanY và MBIM
phiên trên kênh dữ liệu USB được chia sẻ::

VLAN ID MBIM loại MBIM SessionID Ghi chú
  ---------------------------------------------------------
  IPS 0 không được gắn thẻ a)
  1 - 255 IPS 1 - 255 <VLANID>
  256 - 511 DSS 0 - 255 <VLANID - 256>
  512 - 4093 b)
  4094 IPS 0c)

a) nếu không tồn tại liên kết VLAN ID 4094, liên kết khác sẽ bị loại bỏ
    b) phạm vi VLAN không được hỗ trợ, bị loại bỏ vô điều kiện
    c) nếu tồn tại liên kết VLAN ID 4094, liên kết khác sẽ bị loại bỏ




Tài liệu tham khảo
==========

1) Diễn đàn người triển khai USB, Inc. - "Xe buýt nối tiếp đa năng
    Đặc tả lớp con lớp truyền thông cho băng thông rộng di động
    Mô hình giao diện", Bản sửa đổi 1.0 (Errata 1), ngày 1 tháng 5 năm 2013

-ZZ0000ZZ

2) Diễn đàn người triển khai USB, Inc. - "Xe buýt nối tiếp đa năng
    Thông số kỹ thuật phân lớp lớp truyền thông cho điều khiển mạng
    Model Devices", Bản sửa đổi 1.0 (Errata 1), ngày 24 tháng 11 năm 2010

-ZZ0000ZZ

3) libmbim - "một thư viện dựa trên glib để nói chuyện với modem WWAN và
    các thiết bị hỗ trợ Model băng thông rộng giao diện di động (MBIM)
    giao thức"

-ZZ0000ZZ

4) ModemManager - "daemon được kích hoạt DBus để điều khiển thiết bị di động
    thiết bị và kết nối băng thông rộng (2G/3G/4G)"

-ZZ0000ZZ

5) "Đăng ký MBIM (Mô hình giao diện băng thông rộng di động)"

-ZZ0000ZZ

6) "/sys/kernel/debug/usb/định dạng đầu ra của thiết bị"

- Tài liệu/driver-api/usb/usb.rst

7) "/sys/bus/usb/devices/.../mô tả"

- Tài liệu/ABI/ổn định/sysfs-bus-usb