.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/scsi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=======================
Hướng dẫn giao diện SCSI
=====================

:Tác giả: James Bottomley
:Tác giả: Rob Landley

Giới thiệu
============

Giao thức vs xe buýt
---------------

Ngày xửa ngày xưa, Giao diện hệ thống máy tính nhỏ đã định nghĩa cả
bus I/O song song và giao thức dữ liệu để kết nối nhiều loại
thiết bị ngoại vi (ổ đĩa, ổ băng từ, modem, máy in, máy quét,
ổ đĩa quang, thiết bị kiểm tra và thiết bị y tế) sang máy tính chủ.

Mặc dù bus SCSI song song (nhanh/rộng/siêu) cũ phần lớn đã thất thủ
không còn được sử dụng nữa, bộ lệnh SCSI được sử dụng rộng rãi hơn bao giờ hết để
giao tiếp với các thiết bị qua một số xe buýt khác nhau.

ZZ0000ZZ là một thiết bị lớn
giao thức dựa trên gói ngang hàng. Các lệnh SCSI là 6, 10, 12 hoặc 16
dài byte, thường theo sau là tải trọng dữ liệu liên quan.

Các lệnh SCSI có thể được truyền qua bất kỳ loại bus nào và
là giao thức mặc định cho các thiết bị lưu trữ được gắn vào USB, SATA, SAS,
Các thiết bị Fibre Channel, FireWire và ATAPI. Các gói SCSI cũng
thường được trao đổi qua Infiniband,
TCP/IP (ZZ0000ZZ), thậm chí ZZ0001ZZ.

Thiết kế hệ thống con Linux SCSI
----------------------------------

Hệ thống con SCSI sử dụng thiết kế ba lớp, với lớp trên, lớp giữa và lớp thấp
các lớp. Mọi hoạt động liên quan đến hệ thống con SCSI (chẳng hạn như đọc một
khu vực từ đĩa) sử dụng một trình điều khiển ở mỗi cấp độ trong số 3 cấp độ: một cấp độ trên
trình điều khiển lớp, một trình điều khiển lớp thấp hơn và lớp giữa SCSI.

Lớp trên SCSI cung cấp giao diện giữa không gian người dùng và
kernel, ở dạng khối và nút thiết bị char cho I/O và ioctl().
Lớp dưới SCSI chứa trình điều khiển cho các thiết bị phần cứng cụ thể.

Ở giữa là lớp giữa SCSI, tương tự như lớp định tuyến mạng
chẳng hạn như ngăn xếp IPv4. Lớp giữa SCSI định tuyến dữ liệu dựa trên gói
giao thức giữa các nút /dev của lớp trên và nút tương ứng
các thiết bị ở lớp dưới. Nó quản lý hàng đợi lệnh, cung cấp lỗi
chức năng xử lý và quản lý năng lượng, đồng thời phản hồi ioctl()
yêu cầu.

Lớp trên SCSI
================

Lớp trên hỗ trợ giao diện người dùng-kernel bằng cách cung cấp thiết bị
nút.

sd (Đĩa SCSI)
--------------

sd (sd_mod.o)

sr (SCSI CD-ROM)
----------------

sr (sr_mod.o)

st (Băng SCSI)
--------------

st (st.o)

sg (SCSI Chung)
-----------------

sg (sg.o)

ch (Trình thay đổi phương tiện SCSI)
-----------------------

ch (ch.c)

Lớp giữa SCSI
==============

Triển khai lớp giữa SCSI
----------------------------

bao gồm/scsi/scsi_device.h
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. kernel-doc:: include/scsi/scsi_device.h
   :internal:

trình điều khiển/scsi/scsi.c
~~~~~~~~~~~~~~~~~~~

Tệp chính cho lớp giữa SCSI.

.. kernel-doc:: drivers/scsi/scsi.c
   :export:

trình điều khiển/scsi/scsicam.c
~~~~~~~~~~~~~~~~~~~~~~

Hỗ trợ ZZ0000ZZ
các chức năng, để sử dụng với HDIO_GETGEO, v.v.

.. kernel-doc:: drivers/scsi/scsicam.c
   :export:

trình điều khiển/scsi/scsi_error.c
~~~~~~~~~~~~~~~~~~~~~~~~~~

Các thói quen xử lý lỗi/hết thời gian chờ SCSI phổ biến.

.. kernel-doc:: drivers/scsi/scsi_error.c
   :export:

trình điều khiển/scsi/scsi_devinfo.c
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Quản lý scsi_dev_info_list, theo dõi danh sách đen và danh sách trắng
thiết bị.

.. kernel-doc:: drivers/scsi/scsi_devinfo.c
   :export:

trình điều khiển/scsi/scsi_ioctl.c
~~~~~~~~~~~~~~~~~~~~~~~~~~

Xử lý các lệnh gọi ioctl() cho thiết bị SCSI.

.. kernel-doc:: drivers/scsi/scsi_ioctl.c
   :export:

trình điều khiển/scsi/scsi_lib.c
~~~~~~~~~~~~~~~~~~~~~~~~

Thư viện xếp hàng SCSI.

.. kernel-doc:: drivers/scsi/scsi_lib.c
   :export:

trình điều khiển/scsi/scsi_lib_dma.c
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Các chức năng thư viện SCSI tùy thuộc vào DMA (thu thập phân tán bản đồ và hủy bản đồ
danh sách).

.. kernel-doc:: drivers/scsi/scsi_lib_dma.c
   :export:

trình điều khiển/scsi/scsi_proc.c
~~~~~~~~~~~~~~~~~~~~~~~~~

Các chức năng trong tệp này cung cấp giao diện giữa tệp PROC
hệ thống và trình điều khiển thiết bị SCSI Nó chủ yếu được sử dụng để gỡ lỗi,
thống kê và chuyển thông tin trực tiếp đến trình điều khiển cấp thấp. I.E.
hệ thống ống nước để quản lý /proc/scsi/\*

.. kernel-doc:: drivers/scsi/scsi_proc.c

trình điều khiển/scsi/scsi_netlink.c
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Cơ sở hạ tầng để cung cấp các sự kiện không đồng bộ từ quá trình vận chuyển đến không gian người dùng thông qua
netlink, sử dụng một giao thức NETLINK_SCSITRANSPORT duy nhất cho tất cả
vận chuyển. Xem ZZ0000ZZ
để biết thêm chi tiết.

.. kernel-doc:: drivers/scsi/scsi_netlink.c
   :internal:

trình điều khiển/scsi/scsi_scan.c
~~~~~~~~~~~~~~~~~~~~~~~~~

Quét máy chủ để xác định thiết bị nào (nếu có) được đính kèm. các
Thuật toán quét/thăm dò chung như sau, có ngoại lệ đối với
nó tùy thuộc vào cờ cụ thể của thiết bị, tùy chọn biên dịch và toàn cầu
cài đặt thay đổi (thời gian khởi động hoặc tải mô-đun). Một LUN cụ thể được quét
thông qua lệnh INQUIRY; nếu LUN có thiết bị được đính kèm, scsi_device
được phân bổ và thiết lập cho nó. Đối với mọi id của mọi kênh trên
máy chủ nhất định, hãy bắt đầu bằng cách quét LUN 0. Bỏ qua các máy chủ không phản hồi tại
tất cả vào bản quét LUN 0. Ngược lại, nếu LUN 0 có thiết bị được đính kèm,
phân bổ và thiết lập scsi_device cho nó. Nếu mục tiêu là SCSI-3 trở lên,
phát hành REPORT LUN và quét tất cả các LUN được REPORT LUN trả về;
mặt khác, quét tuần tự các LUN cho đến khi đạt mức tối đa hoặc LUN
được thấy rằng không thể có một thiết bị gắn liền với nó.

.. kernel-doc:: drivers/scsi/scsi_scan.c
   :export:

trình điều khiển/scsi/scsi_sysctl.c
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Thiết lập mục sysctl: "/dev/scsi/logging_level"
(DEV_SCSI_LOGGING_LEVEL) đặt/trả về scsi_logging_level.

trình điều khiển/scsi/scsi_sysfs.c
~~~~~~~~~~~~~~~~~~~~~~~~~~

Các thói quen giao diện sysfs của SCSI.

.. kernel-doc:: drivers/scsi/scsi_sysfs.c
   :export:

trình điều khiển/scsi/hosts.c
~~~~~~~~~~~~~~~~~~~~

Giao diện trình điều khiển SCSI cấp trung đến cấp thấp

.. kernel-doc:: drivers/scsi/hosts.c
   :export:

trình điều khiển/scsi/scsi_common.c
~~~~~~~~~~~~~~~~~~~~~~~~~~

chức năng hỗ trợ chung

.. kernel-doc:: drivers/scsi/scsi_common.c
   :export:

Lớp vận chuyển
-----------------

Các lớp vận chuyển là thư viện dịch vụ dành cho trình điều khiển ở phiên bản SCSI thấp hơn
lớp hiển thị các thuộc tính vận chuyển trong sysfs.

Vận chuyển kênh sợi quang
~~~~~~~~~~~~~~~~~~~~~~~

Tệp driver/scsi/scsi_transport_fc.c xác định các thuộc tính vận chuyển
cho Kênh Sợi Quang.

.. kernel-doc:: drivers/scsi/scsi_transport_fc.c
   :export:

Lớp vận chuyển iSCSI
~~~~~~~~~~~~~~~~~~~~~

Tệp driver/scsi/scsi_transport_iscsi.c xác định phương thức vận chuyển
thuộc tính cho lớp iSCSI, gửi các gói SCSI qua TCP/IP
kết nối.

.. kernel-doc:: drivers/scsi/scsi_transport_iscsi.c
   :export:

Lớp vận chuyển SCSI (SAS) được đính kèm nối tiếp
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tệp driver/scsi/scsi_transport_sas.c xác định phương thức vận chuyển
các thuộc tính cho SCSI được đính kèm nối tiếp, một biến thể của SATA nhắm đến mục tiêu lớn
hệ thống cao cấp.

Lớp vận chuyển SAS chứa mã chung để xử lý các HBA SAS, một
biểu diễn gần đúng của cấu trúc liên kết SAS trong mô hình trình điều khiển và
các thuộc tính sysfs khác nhau để hiển thị các cấu trúc liên kết và quản lý này
giao diện cho không gian người dùng.

Ngoài các đối tượng cốt lõi SCSI cơ bản, lớp vận chuyển này
giới thiệu hai đối tượng trung gian bổ sung: SAS PHY là
được biểu thị bằng struct sas_phy xác định PHY "đi" trên SAS HBA hoặc
Bộ mở rộng và SAS từ xa PHY được đại diện bởi struct sas_rphy xác định
PHY "đến" trên Thiết bị mở rộng SAS hoặc thiết bị đầu cuối. Lưu ý rằng đây là
hoàn toàn là một khái niệm phần mềm, phần cứng cơ bản cho PHY và
điều khiển từ xa PHY hoàn toàn giống nhau.

Trong mã này không có khái niệm cổng SAS, người dùng có thể xem PHY là gì
tạo thành một cổng rộng dựa trên thuộc tính port_identifier, đó là
giống nhau cho tất cả PHY trong một cổng.

.. kernel-doc:: drivers/scsi/scsi_transport_sas.c
   :export:

Lớp vận chuyển SATA
~~~~~~~~~~~~~~~~~~~~

Việc vận chuyển SATA được xử lý bởi libata, có sổ sách riêng về
tài liệu trong thư mục này.

Lớp vận chuyển song song SCSI (SPI)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tệp driver/scsi/scsi_transport_spi.c xác định phương thức vận chuyển
thuộc tính cho xe buýt SCSI truyền thống (nhanh/rộng/siêu).

.. kernel-doc:: drivers/scsi/scsi_transport_spi.c
   :export:

Lớp vận chuyển SCSI RDMA (SRP)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tệp driver/scsi/scsi_transport_srp.c xác định phương thức vận chuyển
thuộc tính cho SCSI qua Truy cập bộ nhớ trực tiếp từ xa.

.. kernel-doc:: drivers/scsi/scsi_transport_srp.c
   :export:

Lớp dưới SCSI
================

Các loại truyền tải của Bộ điều hợp Bus Máy chủ
--------------------------------

Nhiều bộ điều khiển thiết bị hiện đại sử dụng bộ lệnh SCSI làm giao thức để
giao tiếp với thiết bị của họ thông qua nhiều loại phương tiện vật lý khác nhau
kết nối.

Trong ngôn ngữ SCSI, một bus có khả năng mang các lệnh SCSI được gọi là
"vận chuyển" và bộ điều khiển kết nối với bus như vậy được gọi là "máy chủ
bộ chuyển đổi xe buýt" (HBA).

Gỡ lỗi vận chuyển
~~~~~~~~~~~~~~~

Tệp driver/scsi/scsi_debug.c mô phỏng bộ điều hợp máy chủ có
số lượng đĩa (hoặc thiết bị giống đĩa) có thể thay đổi được đính kèm, chia sẻ một
số lượng phổ biến của RAM. Kiểm tra rất nhiều để đảm bảo rằng chúng tôi
không làm các khối bị lẫn lộn và làm hoảng sợ hạt nhân nếu có gì đó không ổn
điều bình thường được nhìn thấy.

Để thực tế hơn, các thiết bị mô phỏng có khả năng vận chuyển
thuộc tính của đĩa SAS.

Để biết tài liệu, hãy xem ZZ0000ZZ

việc cần làm
~~~~

Song song (nhanh/rộng/siêu) SCSI, USB, SATA, SAS, Kênh sợi quang,
Thiết bị FireWire, ATAPI, Infiniband, Cổng song song,
liên kết mạng...
