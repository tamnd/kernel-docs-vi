.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/linux/cxl-driver.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Hoạt động của trình điều khiển CXL
====================

Các thiết bị được mô tả trong phần này có trong ::

/sys/bus/cxl/thiết bị/
  /dev/cxl/

Thư viện ZZ0000ZZ, được duy trì như một phần của dự án NDTCL, có thể
được sử dụng để tương tác tập lệnh với các thiết bị này.

Trình điều khiển
=======
Trình điều khiển CXL được chia thành một số trình điều khiển.

* cxl_core - giao diện init cơ bản và tạo đối tượng cốt lõi
* cxl_port - khởi tạo root và cung cấp giao diện liệt kê cổng.
* cxl_acpi - khởi tạo bộ giải mã gốc và tương tác với dữ liệu ACPI.
* cxl_p/mem - khởi tạo thiết bị bộ nhớ
* cxl_pci - sử dụng cxl_port để liệt kê hệ thống phân cấp vải thực tế.

Thiết bị điều khiển
==============
Đây là một ví dụ từ hệ thống một ổ cắm có 4 cầu nối máy chủ. Hai máy chủ
các cầu nối có một thiết bị bộ nhớ được gắn vào và các thiết bị này được xen kẽ
vào một vùng nhớ duy nhất. Vùng bộ nhớ đã được chuyển đổi thành dax. ::

# ls /sys/bus/cxl/thiết bị/
    dax_khu vực0 bộ giải mã3.0 bộ giải mã6.0 mem0 cổng3
    bộ giải mã0.0 bộ giải mã4.0 bộ giải mã6.1 mem1 port4
    bộ giải mã1.0 bộ giải mã5.0 điểm cuối5 cổng1 vùng0
    bộ giải mã2.0 bộ giải mã5.1 điểm cuối6 cổng2 root0


.. kernel-render:: DOT
   :alt: Digraph of CXL fabric describing host-bridge interleaving
   :caption: Diagraph of CXL fabric with a host-bridge interleave memory region

   digraph foo {
     "root0" -> "port1";
     "root0" -> "port3";
     "root0" -> "decoder0.0";
     "port1" -> "endpoint5";
     "port3" -> "endpoint6";
     "port1" -> "decoder1.0";
     "port3" -> "decoder3.0";
     "endpoint5" -> "decoder5.0";
     "endpoint6" -> "decoder6.0";
     "decoder0.0" -> "region0";
     "decoder0.0" -> "decoder1.0";
     "decoder0.0" -> "decoder3.0";
     "decoder1.0" -> "decoder5.0";
     "decoder3.0" -> "decoder6.0";
     "decoder5.0" -> "region0";
     "decoder6.0" -> "region0";
     "region0" -> "dax_region0";
     "dax_region0" -> "dax0.0";
   }

Đối với phần này, chúng ta sẽ khám phá các thiết bị có trong cấu hình này, nhưng
chúng ta sẽ khám phá sâu hơn về cấu hình trong các cấu hình ví dụ bên dưới.

Thiết bị cơ bản
------------
Hầu hết các thiết bị trong vải CXL đều là một loại ZZ0000ZZ nào đó (vì mỗi thiết bị
thiết bị chủ yếu định tuyến yêu cầu từ thiết bị này sang thiết bị tiếp theo, thay vì
cung cấp dịch vụ trực tiếp).

Gốc
~~~~
ZZ0002ZZ là đối tượng logic được tạo bởi trình điều khiển ZZ0003ZZ trong
ZZ0000ZZ - nếu tìm thấy Lớp thiết bị ZZ0001ZZ ZZ0004ZZ.

Root chứa các liên kết đến:

* ZZ0001ZZ được xác định bởi CHBS trong ZZ0000ZZ

* ZZ0000ZZ thường được kết nối với ZZ0001ZZ.

* ZZ0001ZZ được xác định bởi CFMWS ZZ0000ZZ

::

# ls /sys/bus/cxl/devices/root0
    bộ giải mã0.0 dport0 dport5 port2 hệ thống con
    bộ giải mã_commed dport1 phương thức port3 sự kiện
    devtype dport4 port1 port4 uport

# cat /sys/bus/cxl/devices/root0/devtype
    cxl_port

Cổng # cat1/devtype
    cxl_port

Bộ giải mã # cat0.0/devtype
    cxl_decoding_root

Gốc là ZZ0000ZZ đầu tiên trong kết cấu CXL, như được trình bày bởi Linux
Trình điều khiển CXL.  ZZ0001ZZ là một loại ZZ0002ZZ đặc biệt, trong đó nó
chỉ có kết nối cổng hạ lưu.

Cảng
~~~~
Đối tượng ZZ0000ZZ được mô tả tốt hơn là ZZ0001ZZ.  Nó có thể đại diện cho một
cầu nối máy chủ đến thư mục gốc hoặc cổng chuyển đổi thực tế trên bộ chuyển mạch. MỘT ZZ0002ZZ
chứa một hoặc nhiều bộ giải mã được sử dụng để định tuyến các yêu cầu bộ nhớ ở các cổng xuôi dòng,
có thể được kết nối với ZZ0003ZZ khác hoặc ZZ0004ZZ.

::

# ls /sys/bus/cxl/thiết bị/port1
    bộ giải mã1.0 trình điều khiển dport0 parent_dport uport
    bộ giải mã_commited hệ thống con dport113 endpoint5
    sự kiện phương thức devtype dport2

Loại nhà phát triển # cat
    cxl_port

Bộ giải mã # cat1.0/devtype
    cxl_decoding_switch

Điểm cuối # cat5/devtype
    cxl_port

CXL ZZ0001ZZ trong vải được thử nghiệm trong quá trình ZZ0000ZZ tại
thời điểm ZZ0002ZZ được thăm dò.  Việc cho phép logic ngay lập tức
kết nối giữa cầu gốc và cầu chủ.

* Root có kết nối cổng xuôi dòng với cầu nối máy chủ

* Cầu chủ có kết nối cổng ngược dòng tới thư mục gốc.

* Cầu chủ có một hoặc nhiều kết nối cổng xuôi dòng để chuyển đổi
  hoặc các cổng điểm cuối.

ZZ0000ZZ là một loại CXL ZZ0001ZZ đặc biệt. Nó rõ ràng
được xác định trong đặc tả ACPI thông qua ID ZZ0002ZZ.  Cổng ZZ0003ZZ
sẽ được thăm dò tại thời điểm ZZ0004ZZ, trong khi các cổng tương tự trên switch thực tế
sẽ được thăm dò sau.  Mặt khác, các cổng cầu chuyển mạch và máy chủ trông rất
tương tự - cả hai đều chứa bộ giải mã chuyển mạch mà tuyến đường truy cập giữa
các cảng thượng nguồn và hạ lưu.

Điểm cuối
~~~~~~~~
ZZ0000ZZ là cổng đầu cuối trong kết cấu.  Đây là ZZ0001ZZ,
và có thể là một trong nhiều ZZ0002ZZ được thiết bị bộ nhớ trình bày. Nó
vẫn được coi là một loại ZZ0003ZZ trong vải.

ZZ0000ZZ chứa ZZ0001ZZ và Thiết bị kết hợp của thiết bị
Bảng thuộc tính (mô tả khả năng của thiết bị). ::

# ls /sys/bus/cxl/thiết bị/điểm cuối5
    Bộ giải mã CDAT_sự kiện phương thức đã cam kết
    bộ giải mã5.0 devtype parent_dport uport
    hệ thống con trình điều khiển bộ giải mã5.1

# cat/sys/bus/cxl/thiết bị/endpoint5/devtype
    cxl_port

# cat /sys/bus/cxl/devices/endpoint5/decoding5.0/devtype
    cxl_decoding_endpoint


Thiết bị bộ nhớ (memdev)
~~~~~~~~~~~~~~~~~~~~~~
ZZ0002ZZ được trình điều khiển ZZ0003ZZ thăm dò và thêm vào trong ZZ0000ZZ
và được quản lý bởi trình điều khiển ZZ0004ZZ. Nó chủ yếu cung cấp ZZ0005ZZ
giao diện với thiết bị bộ nhớ, thông qua ZZ0001ZZ và hiển thị nhiều
dữ liệu cấu hình thiết bị. ::

# ls /sys/bus/cxl/thiết bị/mem0
    sự kiện bảo mật dev firmware_version payload_max
    trình điều khiển label_storage_size pmem nối tiếp
    hệ thống con ram numa_node phần sụn

Thiết bị bộ nhớ là một đối tượng cơ sở riêng biệt không phải là cổng.  Trong khi
thiết bị vật lý mà nó thuộc về cũng có thể lưu trữ ZZ0000ZZ, mối quan hệ
giữa ZZ0001ZZ và ZZ0002ZZ không được ghi lại trong sysfs.

Mối quan hệ cảng
~~~~~~~~~~~~~~~~~~
Trong ví dụ của chúng tôi được mô tả ở trên, có bốn cầu nối máy chủ được gắn vào
root và hai trong số các cầu nối máy chủ có một điểm cuối được đính kèm.

.. kernel-render:: DOT
   :alt: Digraph of CXL fabric describing host-bridge interleaving
   :caption: Diagraph of CXL fabric with a host-bridge interleave memory region

   digraph foo {
     "root0"    -> "port1";
     "root0"    -> "port2";
     "root0"    -> "port3";
     "root0"    -> "port4";
     "port1" -> "endpoint5";
     "port3" -> "endpoint6";
   }

Bộ giải mã
--------
ZZ0000ZZ là viết tắt của Bộ giải mã bộ nhớ thiết bị được quản lý bởi máy chủ CXL (HDM). Đó là
một thiết bị định tuyến truy cập qua kết cấu CXL đến điểm cuối và tại
điểm cuối chuyển địa chỉ ZZ0001ZZ sang địa chỉ ZZ0002ZZ.

Thông số kỹ thuật CXL 3.1 ngụ ý rất nhiều rằng chỉ các bộ giải mã điểm cuối mới nên
tham gia dịch ZZ0000ZZ sang ZZ0001ZZ.
::

8.2.4.20 Cấu trúc khả năng giải mã CXL HDM

IMPLEMENTATION NOTE
  Luồng giải mã cầu nối máy chủ và cổng chuyển mạch ngược dòng CXL

IMPLEMENTATION NOTE
  Logic giải mã thiết bị

Những ghi chú này ngụ ý rằng có hai nhóm bộ giải mã logic.

* Bộ giải mã định tuyến - bộ giải mã định tuyến truy cập nhưng không dịch
  địa chỉ từ HPA tới DPA.

* Bộ giải mã dịch - bộ giải mã dịch các truy cập từ HPA sang DPA
  cho một điểm cuối của dịch vụ.

Trình điều khiển CXL phân biệt 3 loại bộ giải mã: root, switch và endpoint. Chỉ
bộ giải mã điểm cuối là Bộ giải mã dịch, tất cả những bộ giải mã khác là Bộ giải mã định tuyến.

.. note:: PLATFORM VENDORS BE AWARE

   Linux makes a strong assumption that endpoint decoders are the only decoder
   in the fabric that actively translates HPA to DPA.  Linux assumes routing
   decoders pass the HPA unchanged to the next decoder in the fabric.

   It is therefore assumed that any given decoder in the fabric will have an
   address range that is a subset of its upstream port decoder. Any deviation
   from this scheme undefined per the specification.  Linux prioritizes
   spec-defined / architectural behavior.

Bộ giải mã có thể có một hoặc nhiều ZZ0001ZZ nếu được định cấu hình để xen kẽ
truy cập bộ nhớ.  Điều này sẽ được trình bày trong sysfs thông qua ZZ0000ZZ
tham số.

Bộ giải mã gốc
~~~~~~~~~~~~
ZZ0001ZZ là cấu trúc logic của địa chỉ vật lý và xen kẽ
các cấu hình có trong trường CFMWS của ZZ0000ZZ.
Linux trình bày thông tin này dưới dạng bộ giải mã có trong ZZ0002ZZ.  Chúng tôi
coi đây là ZZ0003ZZ, mặc dù về mặt kỹ thuật nó tồn tại ở ranh giới
của đặc tả CXL và triển khai gốc CXL dành riêng cho nền tảng.

Linux coi các bộ giải mã logic này là một loại ZZ0000ZZ và là
bộ giải mã đầu tiên trong kết cấu CXL nhận quyền truy cập bộ nhớ từ nền tảng
bộ điều khiển bộ nhớ.

ZZ0002ZZ được tạo trong ZZ0000ZZ.  Một bộ giải mã gốc
được tạo cho mỗi mục nhập CFMWS trong ZZ0001ZZ.

Tham số ZZ0000ZZ được điền bởi các trường mục tiêu CFMWS. Mục tiêu
của bộ giải mã gốc là ZZ0001ZZ, có nghĩa là việc xen kẽ được thực hiện ở gốc
mức giải mã là ZZ0002ZZ.

Chỉ bộ giải mã gốc mới có khả năng ZZ0000ZZ.

Các phần xen kẽ như vậy phải được cấu hình bởi nền tảng và được mô tả trong ACPI
CEDT CFMWS, với tư cách là UID cầu nối máy chủ CXL mục tiêu trong CFMWS phải khớp với CXL
UID cầu nối máy chủ trong trường CHBS của ZZ0000ZZ và trường UID của CXL Cầu nối máy chủ được xác định trong
ZZ0001ZZ.

Cài đặt xen kẽ trong bộ giải mã gốc mô tả cách xen kẽ các truy cập giữa
ZZ0000ZZ, không phải toàn bộ bộ xen kẽ.

Phạm vi bộ nhớ được mô tả trong bộ giải mã gốc được sử dụng để

1) Tạo vùng bộ nhớ (ZZ0000ZZ trong ví dụ này) và

2) Liên kết vùng với Tài nguyên bộ nhớ IO (ZZ0000ZZ)

::

# ls /sys/bus/cxl/devices/decode0.0/
    cap_pmem devtype khu vực0
    kích thước cap_ram interleave_grainarity
    cap_type2 xen kẽ_ways bắt đầu
    hệ thống con bị khóa cap_type3
    create_ram_khu vực phương thức target_list
    sự kiện xóa_khu vực qos_class

# cat /sys/bus/cxl/thiết bị/bộ giải mã0.0/khu vực0/tài nguyên
    0xc050000000

Tài nguyên bộ nhớ IO được tạo trong quá trình khởi động sớm khi vùng CFMWS
được xác định trong Bản đồ bộ nhớ EFI hoặc bảng E820 (trên x86).

Bộ giải mã gốc được định nghĩa là một loại devtype riêng biệt, nhưng cũng là một loại
của ZZ0000ZZ do có các mục tiêu ở hạ nguồn. ::

# cat /sys/bus/cxl/devices/decode0.0/devtype
    cxl_decoding_root

Chuyển đổi bộ giải mã
~~~~~~~~~~~~~~
Bất kỳ bộ giải mã dịch, không root đều được coi là ZZ0002ZZ và sẽ
hiện diện với loại ZZ0000ZZ. Cả hai bộ giải mã ZZ0003ZZ và ZZ0004ZZ (thiết bị) đều thuộc loại ZZ0001ZZ. ::

# ls /sys/bus/cxl/thiết bị/bộ giải mã1.0/
    devtype kích thước bị khóa target_list
    phương thức interleave_grainarity bắt đầu target_type
    sự kiện hệ thống con khu vực interleave_ways

# cat /sys/bus/cxl/devices/decoding1.0/devtype
    cxl_decoding_switch

# cat /sys/bus/cxl/thiết bị/bộ giải mã1.0/khu vực
    vùng0

ZZ0000ZZ có các liên kết giữa một vùng được xác định bởi gốc
bộ giải mã và các cổng mục tiêu xuôi dòng.  Việc xen kẽ được thực hiện trong bộ giải mã chuyển mạch
là một cổng xen kẽ đa luồng xuống (hoặc ZZ0001ZZ cho
cầu chủ).

Cài đặt xen kẽ trong bộ giải mã chuyển mạch mô tả cách xen kẽ các truy cập
trong số ZZ0000ZZ, không phải toàn bộ tập hợp xen kẽ.

Bộ giải mã chuyển mạch được tạo trong quá trình ZZ0000ZZ trong
Trình điều khiển ZZ0001ZZ và được tạo dựa trên DVSEC của thiết bị PCI
sổ đăng ký.

Lập trình bộ giải mã chuyển mạch được xác thực trong quá trình thăm dò nếu chương trình nền tảng
chúng trong khi khởi động (Xem ZZ0000ZZ bên dưới) hoặc khi chuyển giao nếu được lập trình tại
thời gian chạy (Xem ZZ0001ZZ bên dưới).


Bộ giải mã điểm cuối
~~~~~~~~~~~~~~~~
Bất kỳ bộ giải mã nào được gắn vào điểm ZZ0003ZZ trong kết cấu CXL (ZZ0001ZZ) đều được
được coi là ZZ0002ZZ. Bộ giải mã điểm cuối thuộc loại
ZZ0000ZZ. ::

# ls /sys/bus/cxl/thiết bị/bộ giải mã5.0
    bắt đầu bị khóa devtype
    hệ thống con phương thức dpa_resource
    chế độ dpa_size target_type
    sự kiện khu vực interleave_grainarity
    kích thước xen kẽ_ways

# cat /sys/bus/cxl/devices/decoding5.0/devtype
    cxl_decoding_endpoint

# cat /sys/bus/cxl/thiết bị/bộ giải mã5.0/khu vực
    vùng0

ZZ0000ZZ có liên kết với vùng được xác định bởi gốc
bộ giải mã và mô tả tài nguyên cục bộ của thiết bị được liên kết với vùng này.

Không giống như bộ giải mã root và switch, bộ giải mã điểm cuối dịch ZZ0000ZZ sang
Phạm vi địa chỉ ZZ0001ZZ.  Cài đặt xen kẽ trên điểm cuối
do đó hãy mô tả toàn bộ ZZ0002ZZ.

Các vùng ZZ0000ZZ phải được cam kết theo thứ tự. Ví dụ,
Vùng DPA bắt đầu từ 0x80000000 không thể được cam kết trước vùng DPA
bắt đầu từ 0x0.

Kể từ Linux v6.15, Linux không hỗ trợ các thiết lập xen kẽ ZZ0000ZZ, tất cả
các điểm cuối trong một tập xen kẽ được kỳ vọng sẽ có cùng các điểm xen kẽ
cài đặt (độ chi tiết và cách thức phải giống nhau).

Bộ giải mã điểm cuối được tạo trong ZZ0000ZZ trong
Trình điều khiển ZZ0001ZZ và được tạo dựa trên các thanh ghi DVSEC của thiết bị PCI.

Mối quan hệ giải mã
~~~~~~~~~~~~~~~~~~~~~
Trong ví dụ của chúng tôi được mô tả ở trên, có một bộ giải mã gốc định tuyến bộ nhớ
truy cập qua hai cầu máy chủ.  Mỗi cầu chủ có một bộ giải mã để định tuyến
truy cập vào các mục tiêu điểm cuối duy nhất của họ.  Mỗi điểm cuối có một bộ giải mã
dịch HPA sang DPA và phục vụ yêu cầu bộ nhớ.

Trình điều khiển xác nhận mối quan hệ giữa các cổng bằng cách lập trình bộ giải mã, do đó
chúng ta có thể nghĩ các bộ giải mã có liên quan theo kiểu phân cấp tương tự như
cổng.

.. kernel-render:: DOT
   :alt: Digraph of hierarchical relationship between root, switch, and endpoint decoders.
   :caption: Diagraph of CXL root, switch, and endpoint decoders.

   digraph foo {
     "root0"    -> "decoder0.0";
     "decoder0.0" -> "decoder1.0";
     "decoder0.0" -> "decoder3.0";
     "decoder1.0" -> "decoder5.0";
     "decoder3.0" -> "decoder6.0";
   }

Khu vực
-------

Vùng bộ nhớ
~~~~~~~~~~~~~
ZZ0000ZZ là một cấu trúc logic kết nối một tập hợp các cổng CXL trong
kết cấu tới Tài nguyên bộ nhớ IO.  Cuối cùng nó được sử dụng để lộ bộ nhớ
trên các thiết bị này tới hệ thống con DAX thông qua ZZ0001ZZ.

Một ví dụ về vùng RAM: ::

# ls /sys/bus/cxl/thiết bị/khu vực0/
    access0 devtype modalias hệ thống con uuid
    chế độ trình điều khiển access1 target0
    cam kết mục tiêu tài nguyên interleave_grainarity1
    sự kiện kích thước dax_zone0 interleave_ways

Một vùng bộ nhớ có thể được xây dựng trong quá trình thăm dò điểm cuối, nếu bộ giải mã được
được lập trình bởi BIOS/EFI (xem ZZ0002ZZ) hoặc bằng cách tạo vùng theo cách thủ công
thông qua ZZ0000ZZ hoặc ZZ0001ZZ của ZZ0003ZZ
giao diện.

Cài đặt xen kẽ trong ZZ0000ZZ mô tả cấu hình của
ZZ0001ZZ - và là những gì có thể được nhìn thấy ở điểm cuối
cài đặt xen kẽ.

.. kernel-render:: DOT
   :alt: Digraph of CXL memory region relationships between root and endpoint decoders.
   :caption: Regions are created based on root decoder configurations. Endpoint decoders
             must be programmed with the same interleave settings as the region.

   digraph foo {
     "root0"    -> "decoder0.0";
     "decoder0.0" -> "region0";
     "region0" -> "decoder5.0";
     "region0" -> "decoder6.0";
   }

Vùng DAX
~~~~~~~~~~
ZZ0000ZZ được sử dụng để chuyển đổi CXL ZZ0001ZZ thành thiết bị DAX. A
Sau đó, thiết bị DAX có thể được truy cập trực tiếp thông qua giao diện mô tả tệp hoặc
được chuyển đổi sang Hệ thống RAM thông qua trình điều khiển kmem DAX.  Xem phần trình điều khiển DAX
để biết thêm chi tiết. ::

# ls /sys/bus/cxl/devices/dax_khu vực0/
    sự kiện phương thức devtype dax0.0
    hệ thống con trình điều khiển dax_zone

Giao diện hộp thư
------------------
Giao diện lệnh hộp thư cho từng thiết bị được hiển thị trong ::

/dev/cxl/mem0
  /dev/cxl/mem1

Những hộp thư này có thể nhận bất kỳ lệnh nào do đặc tả kỹ thuật xác định. Lệnh thô
(lệnh tùy chỉnh) chỉ có thể được gửi đến các giao diện này nếu cấu hình bản dựng
ZZ0000ZZ được thiết lập.  Đây được coi là một bản gỡ lỗi và/hoặc
giao diện phát triển, không phải là cơ chế được hỗ trợ chính thức để tạo
các lệnh dành riêng cho nhà cung cấp (xem hệ thống con ZZ0001ZZ để biết điều đó).

Lập trình giải mã
===================

Lập trình thời gian chạy
-------------------
Trong quá trình thăm dò, bộ giải mã ZZ0002ZZ duy nhất được lập trình là ZZ0000ZZ.
Trong thực tế, ZZ0001ZZ là một cấu trúc logic để mô tả bộ nhớ
cấu hình vùng và xen kẽ ở cấp độ cầu nối máy chủ - như được mô tả
trong ACPI CEDT CFMWS.

Tất cả các bộ giải mã ZZ0000ZZ và ZZ0001ZZ khác có thể được người dùng lập trình
trong thời gian chạy - nếu nền tảng hỗ trợ các cấu hình đó.

Sự tương tác này là thứ tạo ra môi trường ZZ0000ZZ.

Xem tài liệu ZZ0000ZZ để biết thêm thông tin về cách
định cấu hình bộ giải mã CXL khi chạy.

Bộ giải mã tự động
-------------
Bộ giải mã tự động là bộ giải mã được lập trình bởi BIOS/EFI khi khởi động và được
hầu như luôn bị khóa (không thể thay đổi).  Điều này được thực hiện bởi một nền tảng
có thể có cấu hình tĩnh - hoặc một số đặc điểm nhất định có thể ngăn cản
thời gian chạy động thay đổi đối với bộ giải mã (chẳng hạn như yêu cầu bổ sung
lập trình bộ điều khiển trong tổ hợp CPU ngoài phạm vi CXL).

Bộ giải mã tự động được thăm dò tự động miễn là thiết bị và bộ nhớ
các khu vực mà chúng được liên kết với thăm dò mà không gặp vấn đề gì.  Khi thăm dò Auto
Bộ giải mã, trách nhiệm chính của người lái xe là đảm bảo vải được
sane - như thể xác thực các vùng và bộ giải mã được lập trình thời gian chạy.

Nếu Linux không thể xác nhận cấu hình bộ giải mã tự động thì bộ nhớ sẽ không
được hiển thị dưới dạng thiết bị DAX - và do đó không được hiển thị trên trang
allocator - mắc kẹt nó một cách hiệu quả.

Xen kẽ
----------

Trình điều khiển Linux CXL hỗ trợ xen kẽ ZZ0000ZZ. Điều này quyết định
cách thức xen kẽ được lập trình ở mỗi bước giải mã khi trình điều khiển xác thực
mối quan hệ giữa bộ giải mã và cha mẹ của nó.

Ví dụ: trong thiết lập xen kẽ ZZ0000ZZ với 16 điểm cuối
được gắn vào 4 cầu nối máy chủ, linux mong đợi các cách/độ chi tiết sau
qua gốc, cầu chủ và điểm cuối tương ứng.

.. flat-table:: 4x4 cross-link first interleave settings

  * - decoder
    - ways
    - granularity

  * - root
    - 4
    - 256

  * - host bridge
    - 4
    - 1024

  * - endpoint
    - 16
    - 256

Tại thư mục gốc, mọi quyền truy cập nhất định sẽ được định tuyến đến
Cầu nối máy chủ mục tiêu ZZ0000ZZ. Trong một cầu chủ, mọi
Điểm cuối mục tiêu ZZ0001ZZ.  Mỗi điểm cuối dịch dựa trên
trên toàn bộ bộ xen kẽ 16 thiết bị.

Bộ xen kẽ không cân bằng không được hỗ trợ - bộ giải mã ở điểm tương tự
trong hệ thống phân cấp (ví dụ: tất cả các bộ giải mã cầu nối máy chủ) phải có cùng cách thức và
cấu hình chi tiết.

Tại gốc
~~~~~~~
Sự xen kẽ của bộ giải mã gốc được xác định bởi trường CFMWS của ZZ0000ZZ.  CEDT thực tế có thể định nghĩa nhiều CFMWS
cấu hình để mô tả cùng một năng lực vật lý, với mục đích cho phép
người dùng quyết định trong thời gian chạy xem bộ nhớ trực tuyến là xen kẽ hay
không xen kẽ. ::

Loại bảng phụ: 01 [Cấu trúc cửa sổ bộ nhớ cố định CXL]
       Địa chỉ cơ sở cửa sổ: 0000000100000000
               Kích thước cửa sổ: 0000000100000000
  Thành viên xen kẽ (2^n): 00
     Số học xen kẽ: 00
              Mục tiêu đầu tiên: 00000007

Loại bảng phụ: 01 [Cấu trúc cửa sổ bộ nhớ cố định CXL]
       Địa chỉ cơ sở cửa sổ: 0000000200000000
               Kích thước cửa sổ: 0000000100000000
  Thành viên xen kẽ (2^n): 00
     Số học xen kẽ: 00
              Mục tiêu đầu tiên: 00000006

Loại bảng phụ: 01 [Cấu trúc cửa sổ bộ nhớ cố định CXL]
       Địa chỉ cơ sở cửa sổ: 0000000300000000
               Kích thước cửa sổ: 0000000200000000
  Thành viên xen kẽ (2^n): 01
     Số học xen kẽ: 00
              Mục tiêu đầu tiên: 00000007
               Mục tiêu tiếp theo: 00000006

Trong ví dụ này, CFMWS xác định hai vùng 4GB riêng biệt không xen kẽ
cho mỗi cầu nối máy chủ và một vùng 8GB xen kẽ nhắm mục tiêu cả hai. Cái này
sẽ dẫn đến 3 bộ giải mã gốc có trong thư mục gốc. ::

# ls /sys/bus/cxl/devices/root0/bộ giải mã*
    bộ giải mã0.0 bộ giải mã0.1 bộ giải mã0.2

Kích thước bắt đầu của # cat /sys/bus/cxl/devices/decoding0.0/target_list
    7
    0x100000000
    0x100000000

Kích thước bắt đầu của # cat /sys/bus/cxl/devices/decoding0.1/target_list
    6
    0x200000000
    0x100000000

Kích thước bắt đầu của # cat /sys/bus/cxl/devices/decoding0.2/target_list
    7,6
    0x300000000
    0x200000000

Những bộ giải mã này không thể lập trình được trong thời gian chạy.  Chúng được sử dụng để tạo ra một
ZZ0000ZZ để đưa bộ nhớ này trực tuyến với các cài đặt được lập trình trong thời gian chạy
tại bộ giải mã ZZ0001ZZ và ZZ0002ZZ.

Tại Host Bridge hoặc Switch
~~~~~~~~~~~~~~~~~~~~~~~~
Bộ giải mã ZZ0000ZZ và ZZ0001ZZ có thể được lập trình thông qua các trường sau:

- ZZ0000ZZ - vùng HPA được liên kết với vùng bộ nhớ
- ZZ0001ZZ - kích thước của khu vực
- ZZ0002ZZ - danh sách các cổng hạ lưu
- ZZ0003ZZ - số cổng hạ lưu xen kẽ qua
- ZZ0004ZZ - độ chi tiết để xen kẽ.

Linux hy vọng bộ giải mã chuyển mạch ZZ0000ZZ sẽ
bắt nguồn từ các kết nối cổng ngược dòng của họ. Trong ZZ0003ZZ xen kẽ
cấu hình, ZZ0001ZZ của bộ giải mã bằng
ZZ0002ZZ.

Tại điểm cuối
~~~~~~~~~~~
ZZ0000ZZ được lập trình tương tự như bộ giải mã Host Bridge và Switch,
ngoại trừ cách thức và mức độ chi tiết được xác định bởi phần xen kẽ
(ví dụ: cài đặt xen kẽ được xác định bởi ZZ0001ZZ liên quan).

- ZZ0000ZZ - vùng HPA được liên kết với vùng bộ nhớ
- ZZ0001ZZ - kích thước của khu vực
- ZZ0002ZZ - số điểm cuối trong tập xen kẽ
- ZZ0003ZZ - độ chi tiết để xen kẽ.

Các cài đặt này được bộ giải mã điểm cuối sử dụng cho các yêu cầu bộ nhớ ZZ0000ZZ
từ HPA đến DPA.  Đây là lý do tại sao họ phải biết về toàn bộ tập hợp xen kẽ.

Linux không hỗ trợ các cấu hình xen kẽ không cân bằng.  Kết quả là, tất cả
các điểm cuối trong một tập xen kẽ phải có cùng cách thức và mức độ chi tiết.

Cấu hình ví dụ
======================
.. toctree::
   :maxdepth: 1

   example-configurations/single-device.rst
   example-configurations/hb-interleave.rst
   example-configurations/intra-hb-interleave.rst
   example-configurations/multi-interleave.rst