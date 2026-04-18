.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/intel/igb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================================================
Trình điều khiển cơ sở Linux cho kết nối mạng Ethernet Intel(R)
===============================================================

Trình điều khiển Intel Gigabit Linux.
Bản quyền(c) 1999-2018 Tập đoàn Intel.

Nội dung
========

- Xác định bộ chuyển đổi của bạn
- Tham số dòng lệnh
- Cấu hình bổ sung
- Hỗ trợ


Xác định bộ điều hợp của bạn
============================
Để biết thông tin về cách xác định bộ điều hợp của bạn và để có phiên bản Intel mới nhất
trình điều khiển mạng, hãy tham khảo trang web Hỗ trợ của Intel:
ZZ0000ZZ


Tham số dòng lệnh
========================
Nếu trình điều khiển được xây dựng dưới dạng mô-đun, các tham số tùy chọn sau sẽ được sử dụng
bằng cách nhập chúng vào dòng lệnh bằng lệnh modprobe bằng cách sử dụng lệnh này
cú pháp::

modprobe igb [<option>=<VAL1>,<VAL2>,...]

Cần phải có <VAL#> cho mỗi cổng mạng trong hệ thống được hỗ trợ bởi
người lái xe này. Các giá trị sẽ được áp dụng cho từng phiên bản, theo thứ tự hàm.
Ví dụ::

modprobe igb max_vfs=2,4

Trong trường hợp này, có hai cổng mạng được igb hỗ trợ trong hệ thống.

NOTE: Bộ mô tả mô tả bộ đệm dữ liệu và các thuộc tính liên quan đến dữ liệu
bộ đệm. Thông tin này được truy cập bởi phần cứng.

max_vfs
-------
:Phạm vi hợp lệ: 0-7

Tham số này bổ sung hỗ trợ cho SR-IOV. Nó khiến người lái xe phải sinh ra
giá trị max_vfs của các hàm ảo.  Nếu giá trị lớn hơn 0 thì sẽ
cũng buộc tham số VMDq phải bằng 1 hoặc nhiều hơn.

Các thông số cho trình điều khiển được tham chiếu theo vị trí. Vì vậy, nếu bạn có một
bộ điều hợp cổng kép hoặc nhiều bộ điều hợp trong hệ thống của bạn và muốn N ảo
chức năng trên mỗi cổng, bạn phải chỉ định một số cho mỗi cổng với mỗi tham số
cách nhau bằng dấu phẩy. Ví dụ::

modprobe igb max_vfs=4

Điều này sẽ sinh ra 4 VF trên cổng đầu tiên.

::

modprobe igb max_vfs=2,4

Điều này sẽ sinh ra 2 VF ở cổng đầu tiên và 4 VF ở cổng thứ hai.

NOTE: Phải thận trọng khi tải trình điều khiển có các thông số này.
Tùy thuộc vào cấu hình hệ thống của bạn, số lượng khe cắm, v.v., điều đó là không thể
để dự đoán trong mọi trường hợp các vị trí sẽ nằm trên dòng lệnh.

NOTE: Cả thiết bị và trình điều khiển đều không kiểm soát cách ánh xạ VF vào cấu hình
không gian. Bố cục xe buýt sẽ thay đổi tùy theo hệ điều hành. Trên các hệ điều hành có
hỗ trợ nó, bạn có thể kiểm tra sysfs để tìm ánh xạ.

NOTE: Khi chế độ SR-IOV hoặc chế độ VMDq được bật, tính năng lọc VLAN phần cứng
và tính năng tước/chèn thẻ VLAN sẽ vẫn được bật. Hãy loại bỏ cái cũ
Bộ lọc VLAN trước khi thêm bộ lọc VLAN mới. Ví dụ::

liên kết ip đặt eth0 vf 0 vlan 100 // đặt vlan 100 cho VF 0
    liên kết ip được đặt eth0 vf 0 vlan 0 // Xóa vlan 100
    ip link set eth0 vf 0 vlan 200 // đặt vlan 200 mới cho VF 0

Gỡ lỗi
------
:Phạm vi hợp lệ: 0-16 (0=none,...,16=all)
: Giá trị mặc định: 0

Tham số này điều chỉnh các thông báo gỡ lỗi cấp độ được hiển thị trong nhật ký hệ thống.


Các tính năng và cấu hình bổ sung
======================================

Khung Jumbo
------------
Hỗ trợ Khung Jumbo được bật bằng cách thay đổi Đơn vị truyền tối đa (MTU)
đến giá trị lớn hơn giá trị mặc định là 1500.

Sử dụng lệnh ifconfig để tăng kích thước MTU. Ví dụ: nhập
sau đây trong đó <x> là số giao diện::

ifconfig eth<x> mtu 9000 trở lên

Ngoài ra, bạn có thể sử dụng lệnh ip như sau ::

bộ liên kết ip mtu 9000 dev eth<x>
    liên kết ip thiết lập dev eth<x>

Cài đặt này không được lưu trong các lần khởi động lại. Việc thay đổi cài đặt có thể được thực hiện
vĩnh viễn bằng cách thêm 'MTU=9000' vào tệp:

- Đối với RHEL: /etc/sysconfig/network-scripts/ifcfg-eth<x>
- Đối với SLES: /etc/sysconfig/network/<config_file>

NOTE: Cài đặt MTU tối đa cho Khung Jumbo là 9216. Giá trị này trùng khớp
với kích thước Khung Jumbo tối đa là 9234 byte.

NOTE: Việc sử dụng khung Jumbo ở tốc độ 10 hoặc 100 Mbps không được hỗ trợ và có thể dẫn đến
hiệu suất kém hoặc mất liên kết.


công cụ đạo đức
---------------
Trình điều khiển sử dụng giao diện ethtool để cấu hình trình điều khiển và
chẩn đoán cũng như hiển thị thông tin thống kê. Công cụ đạo đức mới nhất
Phiên bản này là cần thiết cho chức năng này. Tải xuống tại:

ZZ0000ZZ


Kích hoạt Wake trên LAN (WoL)
-----------------------------
WoL được cấu hình thông qua tiện ích ethtool.

WoL sẽ được kích hoạt trên hệ thống trong lần tắt hoặc khởi động lại tiếp theo. cho
phiên bản trình điều khiển này, để kích hoạt WoL, phải tải trình điều khiển igb
trước khi tắt hoặc tạm dừng hệ thống.

NOTE: Wake on LAN chỉ được hỗ trợ trên cổng A của các thiết bị nhiều cổng.  Ngoài ra
Wake On LAN không được hỗ trợ cho thiết bị sau:
- Bộ điều hợp máy chủ bốn cổng Intel(R) Gigabit VT


Nhiều hàng đợi
--------------
Trong chế độ này, một vectơ MSI-X riêng biệt được phân bổ cho mỗi hàng đợi và một vectơ cho
các ngắt "khác" như thay đổi trạng thái liên kết và lỗi. Tất cả các ngắt đều
được điều chỉnh thông qua kiểm duyệt ngắt. Việc kiểm duyệt ngắt phải được sử dụng để tránh
các cơn bão bị gián đoạn trong khi trình điều khiển đang xử lý một ngắt. Sự điều độ
giá trị ít nhất phải lớn bằng thời gian dự kiến của người lái xe
xử lý một ngắt. Nhiều hàng đợi bị tắt theo mặc định.

REQUIREMENTS: Cần có hỗ trợ MSI-X cho Multiqueue. Nếu không tìm thấy MSI-X,
hệ thống sẽ chuyển sang trạng thái ngắt MSI hoặc Legacy. Trình điều khiển này hỗ trợ
nhận nhiều hàng đợi trên tất cả các hạt nhân hỗ trợ MSI-X.

NOTE: Trên một số hạt nhân, cần phải khởi động lại để chuyển giữa chế độ hàng đợi đơn
và chế độ nhiều hàng đợi hoặc ngược lại.


Tính năng chống giả mạo MAC và VLAN
-----------------------------------
Khi một trình điều khiển độc hại cố gắng gửi một gói giả mạo, nó sẽ bị loại bỏ.
phần cứng và không được truyền đi.

Một ngắt được gửi tới trình điều khiển PF để thông báo về nỗ lực giả mạo. Khi một
gói giả mạo được phát hiện, trình điều khiển PF sẽ gửi thông báo sau tới
nhật ký hệ thống (được hiển thị bằng lệnh "dmesg"):
(Các) sự kiện giả mạo được phát hiện trên VF(n), trong đó n = VF đã cố gắng thực hiện
giả mạo


Đặt địa chỉ MAC, VLAN và giới hạn tốc độ bằng công cụ IProute2
--------------------------------------------------------------
Bạn có thể đặt địa chỉ MAC của Chức năng ảo (VF), VLAN mặc định và
giới hạn tốc độ bằng công cụ IProute2. Tải về phiên bản mới nhất của
Công cụ IProute2 từ Sourceforge nếu phiên bản của bạn không có tất cả các tính năng
bạn yêu cầu.

Công cụ định hình dựa trên tín dụng (Chế độ Qav)
------------------------------------------------
Khi bật qdisc CBS ở chế độ giảm tải phần cứng, định hình lưu lượng bằng cách sử dụng
CBS (được mô tả trong IEEE 802.1Q-2018 Mục 8.6.8.2 và được thảo luận trong
Thuật toán Phụ lục L) sẽ chạy trong bộ điều khiển i210 nên chính xác hơn và
sử dụng ít CPU hơn.

Khi sử dụng CBS đã giảm tải và tốc độ lưu lượng tuân theo tốc độ đã định cấu hình
(không vượt quá mức đó), CBS sẽ có ít hoặc không ảnh hưởng đến độ trễ.

Phiên bản giảm tải của thuật toán có một số giới hạn, gây ra bởi cách hoạt động không tải
độ dốc được thể hiện trong các thanh ghi của bộ chuyển đổi. Nó chỉ có thể đại diện cho những con dốc nhàn rỗi
theo đơn vị 16,38431 kbps, có nghĩa là nếu độ dốc nhàn rỗi là 2576kbps là
được yêu cầu, bộ điều khiển sẽ được cấu hình để sử dụng độ dốc không tải ~2589 kbps,
bởi vì trình điều khiển làm tròn giá trị lên. Để biết thêm chi tiết, xem các bình luận trên
ZZ0000ZZ.

NOTE: Tính năng này chỉ dành riêng cho mẫu i210.


Ủng hộ
=======
Để biết thông tin chung, hãy truy cập trang web hỗ trợ của Intel tại:
ZZ0000ZZ

Nếu xác định được sự cố với mã nguồn đã phát hành trên hạt nhân được hỗ trợ
với bộ điều hợp được hỗ trợ, hãy gửi email thông tin cụ thể liên quan đến sự cố
tới intel-wired-lan@lists.osuosl.org.