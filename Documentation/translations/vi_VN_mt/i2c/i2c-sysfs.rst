.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/i2c/i2c-sysfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================
Hệ thống Linux I2C
==================

Tổng quan
========

Cấu trúc liên kết I2C có thể phức tạp do sự tồn tại của I2C MUX
(Bộ ghép kênh I2C). Linux
kernel tóm tắt các kênh MUX thành các số bus I2C hợp lý. Tuy nhiên, có
là một lỗ hổng kiến thức để ánh xạ từ số vật lý bus I2C và cấu trúc liên kết MUX
tới số bus I2C logic. Tài liệu này nhằm mục đích lấp đầy khoảng trống này, vì vậy
khán giả (ví dụ: kỹ sư phần cứng và nhà phát triển phần mềm mới) có thể tìm hiểu
khái niệm về bus I2C logic trong kernel, bằng cách biết I2C vật lý
cấu trúc liên kết và điều hướng qua các hệ thống I2C trong Linux shell. Kiến thức này là
hữu ích và cần thiết để sử dụng ZZ0000ZZ cho mục đích phát triển và
gỡ lỗi.

Đối tượng mục tiêu
---------------

Những người cần sử dụng Linux shell để tương tác với hệ thống con I2C trên hệ thống
Linux đang chạy trên đó.

Điều kiện tiên quyết
-------------

1. Kiến thức chung về các lệnh và hoạt động của hệ thống tệp shell Linux.

2. Kiến thức chung về cấu trúc liên kết I2C, I2C MUX và I2C.

Vị trí của I2C Sysfs
=====================

Thông thường, hệ thống tệp Linux Sysfs được gắn vào thư mục ZZ0000ZZ,
vì vậy bạn có thể tìm thấy I2C Sysfs trong ZZ0001ZZ
nơi bạn có thể trực tiếp ZZ0002ZZ tới nó.
Có một danh sách các liên kết tượng trưng trong thư mục đó. Các liên kết đó
bắt đầu với ZZ0003ZZ là các bus I2C, có thể là vật lý hoặc logic. các
các liên kết khác bắt đầu bằng số và kết thúc bằng số là thiết bị I2C, trong đó
số đầu tiên là số xe buýt I2C và số thứ hai là địa chỉ I2C.

Điện thoại Google Pixel 3 chẳng hạn::

blueline:/sys/bus/i2c/devices $ ls
  0-0008 0-0061 1-0028 3-0043 4-0036 4-0041 i2c-1 i2c-3
  0-000c 0-0066 2-0049 4-000b 4-0040 i2c-0 i2c-2 i2c-4

ZZ0000ZZ là bus I2C có số hiệu là 2 và ZZ0001ZZ là thiết bị I2C
trên địa chỉ bus 2 0x49 được liên kết với trình điều khiển kernel.

Thuật ngữ
===========

Đầu tiên chúng ta hãy định nghĩa một số thuật ngữ để tránh nhầm lẫn ở các phần sau.

(Vật lý) Bộ điều khiển bus I2C
-----------------------------

Hệ thống phần cứng mà nhân Linux đang chạy có thể có nhiều
bộ điều khiển bus I2C vật lý. Bộ điều khiển là phần cứng và vật lý, và
hệ thống có thể xác định nhiều thanh ghi trong không gian bộ nhớ để thao tác
bộ điều khiển. Nhân Linux có trình điều khiển bus I2C trong thư mục nguồn
ZZ0000ZZ để dịch kernel I2C API vào thanh ghi
hoạt động cho các hệ thống khác nhau. Thuật ngữ này không giới hạn ở Linux
chỉ hạt nhân.

Số vật lý của xe buýt I2C
-----------------------

Đối với mỗi bộ điều khiển bus I2C vật lý, nhà cung cấp hệ thống có thể chỉ định một bộ điều khiển vật lý
số cho mỗi bộ điều khiển. Ví dụ: bộ điều khiển bus I2C đầu tiên có
địa chỉ thanh ghi thấp nhất có thể được gọi là ZZ0000ZZ.

Xe buýt I2C hợp lý
---------------

Mỗi số bus I2C bạn thấy trong Linux I2C Sysfs đều là một bus I2C hợp lý với một
số được giao. Điều này tương tự với thực tế là mã phần mềm thường
được ghi trên không gian bộ nhớ ảo, thay vì không gian bộ nhớ vật lý.

Mỗi bus I2C logic có thể là một bản tóm tắt của bộ điều khiển bus I2C vật lý hoặc
sự trừu tượng hóa của một kênh phía sau I2C MUX. Trong trường hợp nó là sự trừu tượng của một
Kênh MUX, bất cứ khi nào chúng tôi truy cập thiết bị I2C thông qua bus logic như vậy, kernel
sẽ chuyển I2C MUX cho bạn sang kênh thích hợp như một phần của
trừu tượng.

Xe buýt I2C vật lý
----------------

Nếu bus I2C logic là sự trừu tượng trực tiếp của bộ điều khiển bus I2C vật lý,
chúng ta hãy gọi nó là bus I2C vật lý.

hãy cẩn thận
------

Đây có thể là phần khó hiểu đối với những người chỉ biết về I2C vật lý
thiết kế của một bảng. Thực tế có thể đổi tên số vật lý của bus I2C
đến một số khác ở cấp độ bus I2C logic trong Nguồn cây thiết bị (DTS) bên dưới
phần ZZ0000ZZ. Xem ZZ0001ZZ
để biết ví dụ về tệp DTS.

Cách thực hành tốt nhất: ZZ0000ZZ Tốt hơn là giữ I2C
số vật lý của bus giống với số bus I2C logic tương ứng của chúng,
thay vì đổi tên hoặc ánh xạ chúng, để có thể ít gây nhầm lẫn cho người khác.
người dùng. Những xe buýt I2C vật lý này có thể được dùng làm điểm khởi đầu tốt cho I2C
Những người hâm mộ MUX. Đối với các ví dụ sau, chúng tôi sẽ giả sử rằng I2C vật lý
xe buýt có số giống với số vật lý xe buýt I2C của họ.

Đi bộ qua xe buýt logic I2C
============================

Đối với nội dung sau, chúng tôi sẽ sử dụng cấu trúc liên kết I2C phức tạp hơn làm
ví dụ. Dưới đây là biểu đồ ngắn gọn về cấu trúc liên kết I2C. Nếu bạn không hiểu
biểu đồ này thoạt nhìn, đừng ngại tiếp tục đọc tài liệu này
và xem lại nó khi bạn đọc xong.

::

i2c-7 (bộ điều khiển bus I2C vật lý 7)
  ZZ0000ZZ-- 73-0072 (I2C MUX 8 kênh ở 0x72)
      ZZ0002ZZ-- i2c-78 (kênh-0)
      ZZ0003ZZ-- ... (kênh-1...6, i2c-79...i2c-84)
      |       ZZ0001ZZ-- i2c-203 (kênh-3)

Phân biệt Bus I2C vật lý và logic
----------------------------------------

Một cách đơn giản để phân biệt giữa bus I2C vật lý và bus I2C logic,
là đọc liên kết tượng trưng ZZ0000ZZ trong thư mục bus I2C bằng cách sử dụng
lệnh ZZ0001ZZ hoặc ZZ0002ZZ.

Một liên kết tượng trưng thay thế để kiểm tra là ZZ0000ZZ. Liên kết này chỉ tồn tại
trong thư mục bus I2C logic được lấy ra từ một bus I2C khác.
Đọc liên kết này cũng sẽ cho bạn biết thiết bị I2C MUX nào được tạo
xe buýt I2C hợp lý này.

Nếu liên kết tượng trưng trỏ đến một thư mục kết thúc bằng ZZ0000ZZ thì nó phải là một
bus I2C vật lý, trực tiếp trừu tượng hóa bộ điều khiển bus I2C vật lý. Ví dụ::

$ readlink /sys/bus/i2c/devices/i2c-7/device
  ../../f0087000.i2c
$ ls /sys/bus/i2c/devices/i2c-7/mux_device
  ls: /sys/bus/i2c/devices/i2c-7/mux_device: Không có tập tin hoặc thư mục như vậy

Trong trường hợp này, ZZ0000ZZ là bus I2C vật lý, vì vậy nó không có ký hiệu
liên kết ZZ0001ZZ trong thư mục của nó. Và nếu nhà phát triển phần mềm hạt nhân
tuân theo thông lệ chung bằng cách không đổi tên các bus I2C vật lý, điều này cũng sẽ
nghĩa là bộ điều khiển bus I2C vật lý 7 của hệ thống.

Mặt khác, nếu liên kết tượng trưng trỏ tới một bus I2C khác, thì bus I2C
được trình bày bởi thư mục hiện tại phải là một bus logic. Xe buýt I2C nhọn
bởi liên kết là bus mẹ có thể là bus I2C vật lý hoặc
logic một. Trong trường hợp này, bus I2C được trình bày bởi thư mục hiện tại
tóm tắt kênh I2C MUX dưới bus mẹ.

Ví dụ::

$ readlink /sys/bus/i2c/devices/i2c-73/device
  ../../i2c-7
$ readlink /sys/bus/i2c/devices/i2c-73/mux_device
  ../7-0071

ZZ0000ZZ là một bus logic fanout của I2C MUX dưới ZZ0001ZZ
có địa chỉ I2C là 0x71.
Bất cứ khi nào chúng tôi truy cập thiết bị I2C bằng bus 73, kernel sẽ luôn
chuyển I2C MUX có địa chỉ 0x71 sang kênh thích hợp cho bạn như một phần của
trừu tượng.

Tìm ra số Bus I2C hợp lý
----------------------------------

Trong phần này, chúng tôi sẽ mô tả cách tìm ra số bus I2C logic
đại diện cho các kênh I2C MUX nhất định dựa trên kiến thức về vật lý
Cấu trúc liên kết phần cứng I2C.

Trong ví dụ này, chúng tôi có một hệ thống có bus I2C vật lý 7 và chưa được đổi tên
trong DTS. Có MUX 4 kênh ở địa chỉ 0x71 trên xe buýt đó. Có một cái khác
MUX 8 kênh tại địa chỉ 0x72 phía sau kênh 1 của 0x71 MUX. Hãy để chúng tôi
điều hướng qua Sysfs và tìm ra số bus I2C hợp lý của kênh 3
của 0x72 MUX.

Trước hết chúng ta vào thư mục của ZZ0000ZZ::

~$ cd /sys/bus/i2c/devices/i2c-7
  /sys/bus/i2c/devices/i2c-7$ ls
  7-0071 hệ thống con tên i2c-60
  sự kiện xóa_device i2c-73 new_device
  thiết bị i2c-86 của_node
  i2c-203 i2c-dev nguồn

Ở đó, chúng ta thấy 0x71 MUX là ZZ0000ZZ. Đi vào bên trong nó::

/sys/bus/i2c/devices/i2c-7$ cd 7-0071/
  /sys/bus/i2c/devices/i2c-7/7-0071$ ls -l
  sức mạnh phương thức kênh-0 kênh-3
  hệ thống con tên trình điều khiển kênh-1
  sự kiện kênh-2 nhàn rỗi_trạng thái của_node

Đọc link ZZ0000ZZ sử dụng ZZ0001ZZ hoặc ZZ0002ZZ::

/sys/bus/i2c/devices/i2c-7/7-0071$ liên kết đọc kênh-1
  ../i2c-73

Chúng tôi phát hiện ra rằng kênh 1 của 0x71 MUX trên ZZ0000ZZ đã được chỉ định
với số bus I2C hợp lý là 73.
Chúng ta hãy tiếp tục hành trình đến thư mục ZZ0001ZZ theo một trong hai cách::

# cd sang i2c-73 dưới quyền root I2C Sysfs
  /sys/bus/i2c/devices/i2c-7/7-0071$ cd /sys/bus/i2c/devices/i2c-73
  /sys/bus/i2c/thiết bị/i2c-73$

# cd liên kết tượng trưng kênh
  /sys/bus/i2c/devices/i2c-7/7-0071$ cd kênh-1
  /sys/bus/i2c/devices/i2c-7/7-0071/channel-1$

# cd nội dung liên kết
  /sys/bus/i2c/devices/i2c-7/7-0071$ cd ../i2c-73
  /sys/bus/i2c/devices/i2c-7/i2c-73$

Dù bằng cách nào, bạn sẽ kết thúc trong thư mục của ZZ0000ZZ. Tương tự như trên,
bây giờ chúng ta có thể tìm thấy 0x72 MUX và số bus I2C hợp lý
các kênh của nó được chỉ định::

/sys/bus/i2c/devices/i2c-73$ ls
  73-0040 thiết bị i2c-83 new_device
  73-004e i2c-78 i2c-84 của_node
  73-0050 i2c-79 i2c-85 điện
  73-0070 hệ thống con i2c-80 i2c-dev
  73-0072 i2c-81 mux_device sự kiện
  xóa_tên thiết bị i2c-82
  /sys/bus/i2c/devices/i2c-73$ cd 73-0072
  /sys/bus/i2c/devices/i2c-73/73-0072$ ls
  trình điều khiển kênh-0 kênh-4 của_node
  kênh-1 kênh-5 công suất nhàn rỗi_state
  hệ thống con phương thức kênh-2 kênh-6
  sự kiện tên kênh-3 kênh-7
  /sys/bus/i2c/devices/i2c-73/73-0072$ kênh liên kết đọc-3
  ../i2c-81

Ở đó, chúng tôi tìm ra số bus I2C hợp lý của kênh 3 của 0x72 MUX
là 81. Sau này chúng ta có thể sử dụng số này để chuyển sang thư mục I2C Sysfs của chính nó hoặc
đưa ra lệnh ZZ0000ZZ.

Mẹo: Khi bạn hiểu cấu trúc liên kết I2C với MUX, hãy lệnh
ZZ0000ZZ
trong
ZZ0001ZZ
có thể cho bạn
tổng quan về cấu trúc liên kết I2C một cách dễ dàng, nếu nó có sẵn trên hệ thống của bạn. Ví dụ::

$ i2c detect -l ZZ0000ZZ sắp xếp -V
  bộ chuyển đổi i2c-7 i2c npcm_i2c_7 I2C
  i2c-73 i2c i2c-7-mux (chan_id 1) Bộ chuyển đổi I2C
  i2c-78 i2c i2c-73-mux (chan_id 0) Bộ chuyển đổi I2C
  i2c-79 i2c i2c-73-mux (chan_id 1) Bộ chuyển đổi I2C
  i2c-80 i2c i2c-73-mux (chan_id 2) Bộ chuyển đổi I2C
  i2c-81 i2c i2c-73-mux (chan_id 3) Bộ chuyển đổi I2C
  i2c-82 i2c i2c-73-mux (chan_id 4) Bộ chuyển đổi I2C
  i2c-83 i2c i2c-73-mux (chan_id 5) Bộ chuyển đổi I2C
  i2c-84 i2c i2c-73-mux (chan_id 6) Bộ chuyển đổi I2C
  i2c-85 i2c i2c-73-mux (chan_id 7) Bộ chuyển đổi I2C

Số Bus I2C hợp lý được ghim
-----------------------------

Nếu không được chỉ định trong DTS, khi trình điều khiển I2C MUX được áp dụng và thiết bị MUX được
được thăm dò thành công, kernel sẽ gán các kênh MUX với một bus logic
số dựa trên số bus logic lớn nhất hiện tại tăng dần. cho
ví dụ: nếu hệ thống có ZZ0000ZZ là số bus logic cao nhất và
Áp dụng thành công MUX 4 kênh chúng ta sẽ có ZZ0001ZZ cho
MUX kênh 0 và đến ZZ0002ZZ cho kênh MUX 3.

Nhà phát triển phần mềm kernel có thể ghim các kênh MUX của fanout vào một kênh tĩnh
số bus I2C logic trong DTS. Tài liệu này sẽ không đi sâu vào chi tiết về
cách triển khai điều này trong DTS, nhưng chúng ta có thể xem ví dụ trong:
ZZ0000ZZ

Trong ví dụ trên, có I2C MUX 8 kênh tại địa chỉ 0x70 trên vật lý
I2C bus 2. Kênh 2 của MUX được xác định là ZZ0000ZZ trong DTS,
và được ghim vào bus I2C logic số 18 với dòng ZZ0001ZZ
trong phần ZZ0002ZZ.

Đi xa hơn, có thể thiết kế lược đồ số bus I2C hợp lý
con người có thể dễ dàng ghi nhớ hoặc tính toán một cách số học. Ví dụ, chúng tôi
có thể ghim các kênh fanout của MUX trên bus 3 để bắt đầu ở mức 30. Vì vậy, 30 sẽ là
số bus logic của kênh 0 của MUX trên bus 3 và 37 sẽ là
số bus logic của kênh 7 của MUX trên bus 3.

Thiết bị I2C
===========

Trong các phần trước, chúng tôi chủ yếu đề cập đến bus I2C. Trong phần này chúng ta hãy xem
những gì chúng ta có thể học được từ thư mục thiết bị I2C có tên liên kết ở định dạng
của ZZ0000ZZ. Phần ZZ0001ZZ trong tên là bus I2C logic
số thập phân, trong khi phần ZZ0002ZZ là số hex của địa chỉ I2C
của từng thiết bị.

Nội dung thư mục thiết bị I2C
----------------------------

Bên trong mỗi thư mục thiết bị I2C có một tệp có tên ZZ0000ZZ.
Tập tin này cho biết tên thiết bị được sử dụng cho trình điều khiển kernel
thăm dò thiết bị này. Sử dụng lệnh ZZ0001ZZ để đọc nội dung của nó. Ví dụ::

/sys/bus/i2c/devices/i2c-73$ mèo 73-0040/tên
  ina230
  /sys/bus/i2c/devices/i2c-73$ mèo 73-0070/tên
  pca9546
  /sys/bus/i2c/devices/i2c-73$ mèo 73-0072/tên
  pca9547

Có một liên kết tượng trưng có tên ZZ0000ZZ để cho biết trình điều khiển nhân Linux là gì
được sử dụng để thăm dò thiết bị này::

/sys/bus/i2c/devices/i2c-73$ readlink -f 73-0040/driver
  /sys/bus/i2c/drivers/ina2xx
  /sys/bus/i2c/devices/i2c-73$ readlink -f 73-0072/driver
  /sys/bus/i2c/drivers/pca954x

Nhưng nếu liên kết ZZ0000ZZ ngay từ đầu không tồn tại,
điều đó có thể có nghĩa là trình điều khiển hạt nhân không thể thăm dò thiết bị này do
một số lỗi. Lỗi có thể được tìm thấy trong ZZ0001ZZ::

/sys/bus/i2c/devices/i2c-73$ ls 73-0070/driver
  ls: 73-0070/driver: Không có tập tin hoặc thư mục như vậy
  /sys/bus/i2c/devices/i2c-73$ dmesg | grep 73-0070
  pca954x 73-0070: thăm dò không thành công
  pca954x 73-0070: thăm dò không thành công

Tùy thuộc vào thiết bị I2C là gì và trình điều khiển hạt nhân nào được sử dụng để thăm dò
thiết bị, chúng tôi có thể có nội dung khác trong thư mục thiết bị.

Thiết bị I2C MUX
--------------

Mặc dù bạn có thể đã biết điều này trong các phần trước, nhưng thiết bị I2C MUX
sẽ có liên kết tượng trưng ZZ0000ZZ bên trong thư mục thiết bị của nó.
Các liên kết tượng trưng này trỏ đến các thư mục bus I2C logic của chúng::

/sys/bus/i2c/devices/i2c-73$ ls -l 73-0072/channel-*
  lrwxrwxrwx ... 73-0072/channel-0 -> ../i2c-78
  lrwxrwxrwx ... 73-0072/channel-1 -> ../i2c-79
  lrwxrwxrwx ... 73-0072/channel-2 -> ../i2c-80
  lrwxrwxrwx ... 73-0072/channel-3 -> ../i2c-81
  lrwxrwxrwx ... 73-0072/channel-4 -> ../i2c-82
  lrwxrwxrwx ... 73-0072/channel-5 -> ../i2c-83
  lrwxrwxrwx ... 73-0072/channel-6 -> ../i2c-84
  lrwxrwxrwx ... 73-0072/channel-7 -> ../i2c-85

Thiết bị cảm biến I2C / Hwmon
-------------------------

Thiết bị cảm biến I2C cũng thường thấy. Nếu chúng bị ràng buộc bởi kernel hwmon
(Giám sát phần cứng) thành công, bạn sẽ thấy thư mục ZZ0000ZZ
bên trong thư mục thiết bị I2C. Hãy tiếp tục đào sâu vào đó bạn sẽ tìm thấy Hwmon
Sysfs cho thiết bị cảm biến I2C::

/sys/bus/i2c/devices/i2c-73/73-0040/hwmon/hwmon17$ ls
  hệ thống con tên curr1_input in0_lcrit_alarm
  sự kiện nguồn in1_crit của thiết bị
  in0_crit in1_crit_alarm power1_crit update_interval
  in0_crit_alarm in1_nguồn đầu vào1_crit_alarm
  in0_input in1_lcrit power1_input
  in0_lcrit in1_lcrit_alarm shunt_resistor

Để biết thêm thông tin về Hwmon Sysfs, hãy tham khảo tài liệu:

../hwmon/sysfs-interface.rst

Khởi tạo thiết bị I2C trong I2C Sysfs
------------------------------------

Tham khảo phần "Phương pháp 4: Khởi tạo từ không gian người dùng" của instantiating-devices.rst