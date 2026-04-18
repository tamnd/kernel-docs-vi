.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/dlink/dl2k.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================================================
Cài đặt bộ điều hợp Gigabit Ethernet dựa trên D-Link DL2000
==============================================================

Ngày 23 tháng 5 năm 2002

.. Contents

 - Compatibility List
 - Quick Install
 - Compiling the Driver
 - Installing the Driver
 - Option parameter
 - Configuration Script Sample
 - Troubleshooting


Danh sách tương thích
==================

Hỗ trợ bộ chuyển đổi:

- Bộ chuyển đổi Gigabit Ethernet D-Link DGE-550T.
- Bộ chuyển đổi Gigabit Ethernet D-Link DGE-550SX.
- Bộ điều hợp Gigabit Ethernet dựa trên D-Link DL2000.


Trình điều khiển hỗ trợ Linux kernel 2.4.7 sau này. Chúng tôi đã thử nghiệm nó
trên các môi trường bên dưới.

. Red Hat v6.2 (cập nhật kernel lên 2.4.7)
 . Red Hat v7.0 (cập nhật kernel lên 2.4.7)
 . Red Hat v7.1 (hạt nhân 2.4.7)
 . Red Hat v7.2 (hạt nhân 2.4.7-10)


Cài đặt nhanh
=============
Cài đặt trình điều khiển linux bằng lệnh sau ::

1. làm tất cả
    2. insmod dl2k.ko
    3. ifconfig eth0 lên 10.xxx.xxx.xxx netmask 255.0.0.0
			^^ ^^^ ^^ ^^ ^^ ^^ ^^ ^^\ ^^ ^^ ^^ ^^\
					IP NETMASK

Bây giờ eth0 sẽ hoạt động, bạn có thể kiểm tra nó bằng cách "ping" hoặc lấy thêm thông tin bằng cách
"ifconfig". Nếu kiểm tra ok thì tiếp tục bước tiếp theo.

4. ``cp dl2k.ko /lib/modules/`uname -r`/kernel/drivers/net``
5. Thêm dòng sau vào /etc/modprobe.d/dl2k.conf::

bí danh eth0 dl2k

6. Chạy ZZ0000ZZ để cập nhật các chỉ mục mô-đun.
7. Chạy ZZ0001ZZ hoặc ZZ0002ZZ để tạo script cấu hình ifcfg-eth0
   nằm ở /etc/sysconfig/network-scripts hoặc tạo thủ công.

[xem - Mẫu tập lệnh cấu hình]
8. Driver sẽ tự động tải và cấu hình vào lần khởi động tiếp theo.

Biên dịch trình điều khiển
====================
Trong Linux, trình điều khiển NIC được cấu hình phổ biến nhất dưới dạng mô-đun có thể tải được.
Cách tiếp cận xây dựng một hạt nhân nguyên khối đã trở nên lỗi thời. Người lái xe
có thể được biên dịch như một phần của hạt nhân nguyên khối, nhưng không được khuyến khích.
Phần còn lại của phần này giả định trình điều khiển được xây dựng dưới dạng mô-đun có thể tải được.
Trong môi trường Linux, bạn nên xây dựng lại trình điều khiển từ
nguồn thay vì dựa vào phiên bản được biên dịch trước. Cách tiếp cận này cung cấp
độ tin cậy tốt hơn vì trình điều khiển được biên dịch trước có thể phụ thuộc vào thư viện hoặc
các tính năng kernel không có trong bản cài đặt Linux nhất định.

3 file cần thiết để build driver thiết bị Linux là dl2k.c, dl2k.h và
Makefile. Để biên dịch, cài đặt Linux phải bao gồm trình biên dịch gcc,
nguồn kernel và các tiêu đề kernel. Trình điều khiển Linux hỗ trợ Linux
Hạt nhân 2.4.7. Sao chép các tập tin vào một thư mục và nhập lệnh sau
để biên dịch và liên kết trình điều khiển:

Ổ đĩa CD-ROM
------------

::

[root@XXX /] mkdir cdrom
    [root@XXX /] mount -r -t iso9660 -o conv=auto /dev/cdrom /cdrom
    [root@XXX /] cd gốc
    [root@XXX /root] mkdir dl2k
    [root@XXX /root] cd dl2k
    [root@XXX dl2k] cp /cdrom/linux/dl2k.tgz /root/dl2k
    [root@XXX dl2k] tar xfvz dl2k.tgz
    [root@XXX dl2k] tạo tất cả

Ổ đĩa mềm
-----------------

::

[root@XXX /] cd gốc
    [root@XXX /root] mkdir dl2k
    [root@XXX /root] cd dl2k
    [root@XXX dl2k] mcopy a:/linux/dl2k.tgz /root/dl2k
    [root@XXX dl2k] tar xfvz dl2k.tgz
    [root@XXX dl2k] tạo tất cả

Cài đặt trình điều khiển
=====================

Cài đặt thủ công
-------------------

Khi trình điều khiển đã được biên dịch, nó phải được tải, kích hoạt và ràng buộc
  tới một ngăn xếp giao thức để thiết lập kết nối mạng. Để tải một
  mô-đun nhập lệnh::

insmod dl2k.o

hoặc::

insmod dl2k.o <tham số tùy chọn> ; thêm tham số

---------------------------------------------------------

ví dụ::

insmod dl2k.o media=100mbps_hd

hoặc::

insmod dl2k.o media=3

hoặc::

insmod dl2k.o media=3,2 ; cho 2 thẻ

---------------------------------------------------------

Vui lòng tham khảo danh sách các tham số dòng lệnh được hỗ trợ bởi
  trình điều khiển thiết bị Linux bên dưới.

Lệnh insmod chỉ tải trình điều khiển và đặt tên cho nó theo dạng
  eth0, eth1, v.v. Để đưa NIC vào trạng thái hoạt động,
  cần phải đưa ra lệnh sau::

ifconfig eth0 lên

Cuối cùng, để liên kết trình điều khiển với giao thức đang hoạt động (ví dụ: TCP/IP với
  Linux), hãy nhập lệnh sau::

ifup eth0

Lưu ý rằng điều này chỉ có ý nghĩa nếu hệ thống có thể tìm thấy cấu hình
  tập lệnh chứa thông tin mạng cần thiết. Một mẫu sẽ được
  đưa ra trong đoạn tiếp theo.

Các lệnh để dỡ trình điều khiển như sau::

ifdown eth0
    ifconfig eth0 bị hỏng
    rmmod dl2k.o

Sau đây là các lệnh để liệt kê các mô-đun hiện đang được tải và
  để xem cấu hình mạng hiện tại::

lsmod
    ifconfig


Cài đặt tự động
----------------------
Phần này mô tả cách cài đặt trình điều khiển sao cho
  tự động được tải và cấu hình khi khởi động. Mô tả sau đây
  dựa trên bản phân phối Red Hat 6.0/7.0, nhưng nó có thể dễ dàng được chuyển sang
  các bản phân phối khác cũng vậy.

Mũ Đỏ v6.x/v7.x
-----------------
1. Thông thường, hãy sao chép dl2k.o vào thư mục mô-đun mạng
     /lib/modules/2.x.x-xx/net hoặc /lib/modules/2.x.x/kernel/drivers/net.
  2. Xác định vị trí tệp cấu hình mô-đun khởi động, phổ biến nhất là trong
     thư mục /etc/modprobe.d/. Thêm các dòng sau::

bí danh ethx dl2k
	tùy chọn dl2k <tham số tùy chọn>

trong đó ethx sẽ là eth0 nếu NIC là bộ chuyển đổi ethernet duy nhất, eth1 nếu
     một bộ điều hợp ethernet khác đã được cài đặt, v.v. Hãy tham khảo bảng ở phần
     phần trước để biết danh sách các tham số tùy chọn.
  3. Xác định vị trí các tập lệnh cấu hình mạng, thông thường là
     thư mục /etc/sysconfig/network-scripts và tạo cấu hình
     tập lệnh có tên ifcfg-ethx chứa thông tin mạng.
  4. Lưu ý rằng đối với hầu hết các bản phân phối Linux, có bao gồm Red Hat, một cấu hình
     tiện ích có giao diện người dùng đồ họa được cung cấp để thực hiện bước 2
     và 3 ở trên.


Mô tả tham số
=====================
Bạn có thể cài đặt trình điều khiển này mà không cần bất kỳ tham số bổ sung nào. Tuy nhiên, nếu bạn
sẽ có nhiều chức năng mở rộng thì cần phải thiết lập thêm
tham số. Dưới đây là danh sách các tham số dòng lệnh được hỗ trợ bởi
Thiết bị Linux
người lái xe.


===================================================================================
mtu=packet_size Chỉ định kích thước gói tối đa. mặc định
				  là 1500.

media=media_type Chỉ định loại phương tiện mà NIC hoạt động.
				  phương tiện hoạt động tự động cảm biến.

=======================================
				  10mbps_hd 10Mbps bán song công.
				  10mbps_fd Song công hoàn toàn 10Mbps.
				  100mbps_hd 100Mbps song công một nửa.
				  100mbps_fd Song công hoàn toàn 100Mbps.
				  1000mbps_fd Song công hoàn toàn 1000Mbps.
				  1000mbps_hd 1000Mbps song công một nửa.
				  0 Phương tiện hoạt động tự động cảm nhận.
				  1 song công 10Mbps.
				  2 song công hoàn toàn 10Mbps.
				  3 song công 100Mbps.
				  4 song công hoàn toàn 100Mbps.
				  5 song công 1000Mbps.
				  6 song công hoàn toàn 1000Mbps.
				  =======================================

Theo mặc định, NIC hoạt động ở chế độ tự động.
				  Chỉ có loại 1000mbps_fd và 1000mbps_hd
				  có sẵn cho bộ chuyển đổi sợi.

vlan=n Chỉ định ID VLAN. Nếu vlan=0 thì
				  Chức năng Mạng cục bộ ảo (VLAN) là
				  vô hiệu hóa.

jumbo=[0|1] Chỉ định hỗ trợ khung jumbo. Nếu lớn = 1,
				  NIC chấp nhận các khung hình lớn. Theo mặc định, điều này
				  chức năng bị vô hiệu hóa.
				  Khung Jumbo thường cải thiện hiệu suất
				  int gigabit.
				  Tính năng này cần tương thích với khung jumbo
				  từ xa.

rx_coalesce=m Số khung rx được xử lý mỗi ngắt.
rx_timeout=n Rx DMA thời gian chờ để ngắt.
				  Nếu được đặt rx_coalesce > 0, phần cứng chỉ xác nhận
				  một ngắt cho m khung hình. Phần cứng sẽ không
				  xác nhận ngắt rx cho đến khi nhận được m khung hoặc
				  đạt thời gian chờ là n * 640 nano giây.
				  Đặt rx_coalesce và rx_timeout thích hợp có thể
				  giảm tắc nghẽn và tình trạng quá tải
				  đã là một nút thắt cổ chai cho mạng tốc độ cao.

Ví dụ: rx_coalesce=10 rx_timeout=800.
				  nghĩa là phần cứng chỉ xác nhận 1 ngắt
				  cho 10 khung hình nhận được hoặc thời gian chờ là 512 us.

tx_coalesce=n Số khung tx được xử lý mỗi ngắt.
				  Đặt n > 1 có thể giảm số lần ngắt
				  tắc nghẽn thường làm giảm hiệu suất của
				  card mạng tốc độ cao. Mặc định là 16.

tx_flow=[1|0] Chỉ định điều khiển luồng Tx. Nếu tx_flow=0,
				  điều khiển luồng Tx vô hiệu hóa trình điều khiển khác
				  tự động phát hiện.
rx_flow=[1|0] Chỉ định điều khiển luồng Rx. Nếu rx_flow=0,
				  trình điều khiển kích hoạt luồng Rx khác
				  tự động phát hiện.
===================================================================================


Mẫu tập lệnh cấu hình
===========================
Đây là mẫu của tập lệnh cấu hình đơn giản::

DEVICE=eth0
    USERCTL=không
    ONBOOT=có
    POOTPROTO=không có
    BROADCAST=207.200.5.255
    NETWORK=207.200.5.0
    NETMASK=255.255.255.0
    IPADDR=207.200.5.2


Khắc phục sự cố
===============
Q1. Tệp nguồn chứa ^ M đằng sau mỗi dòng.

Đảm bảo tất cả các tệp đều có định dạng tệp Unix (không có LF). Hãy thử cách sau
    Lệnh shell để chuyển đổi tập tin::

mèo dl2k.c | col -b > dl2k.tmp
	mv dl2k.tmp dl2k.c

HOẶC::

mèo dl2k.c | tr -d "\r" > dl2k.tmp
	mv dl2k.tmp dl2k.c

Q2: Không thể tìm thấy tệp tiêu đề (ZZ0000ZZ)?

Để biên dịch trình điều khiển, bạn cần có các tệp tiêu đề kernel. Sau
    cài đặt nguồn kernel, các tập tin tiêu đề thường nằm ở
    /usr/src/linux/include, đây là thư mục bao gồm mặc định được cấu hình
    trong Makefile. Đối với một số bản phân phối, có một bản sao của tệp tiêu đề trong
    /usr/src/include/linux và /usr/src/include/asm, bạn có thể thay đổi
    INCLUDEDIR trong Makefile sang /usr/include mà không cần cài đặt nguồn kernel.

Lưu ý rằng RH 7.0 không cung cấp các tệp tiêu đề chính xác trong /usr/include,
    bao gồm những tập tin đó sẽ tạo ra một phiên bản trình điều khiển sai.
