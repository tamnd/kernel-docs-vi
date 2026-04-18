.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/usb/gadget_configfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================================================
Tiện ích Linux USB được định cấu hình thông qua configfs
============================================


Ngày 25 tháng 4 năm 2013




Tổng quan
========

Tiện ích Linux USB là một thiết bị có UDC (Bộ điều khiển thiết bị USB) và có thể
được kết nối với Máy chủ USB để mở rộng nó với các chức năng bổ sung như nối tiếp
cổng hoặc khả năng lưu trữ dung lượng lớn.

Một tiện ích được máy chủ của nó xem như một tập hợp các cấu hình, mỗi cấu hình chứa
một số giao diện, theo quan điểm của tiện ích, được gọi là
chức năng, mỗi chức năng đại diện cho ví dụ. kết nối nối tiếp hoặc đĩa SCSI.

Linux cung cấp một số chức năng cho các tiện ích sử dụng.

Tạo một tiện ích có nghĩa là quyết định sẽ có những cấu hình nào
và mỗi cấu hình sẽ cung cấp những chức năng nào.

Cấu hình (vui lòng xem ZZ0000ZZ) hoạt động tốt
nhằm mục đích thông báo cho kernel về quyết định nêu trên.
Tài liệu này nói về cách thực hiện điều đó.

Nó cũng mô tả cách thiết kế tích hợp configfs vào tiện ích.




Yêu cầu
============

Để tính năng này hoạt động, phải có sẵn cấu hình, vì vậy CONFIGFS_FS phải
'y' hoặc 'm' trong .config. Khi viết bài này, USB_LIBCOMPOSITE chọn CONFIGFS_FS.




Cách sử dụng
=====

(Bài viết gốc mô tả chức năng đầu tiên
có sẵn thông qua configfs có thể được nhìn thấy ở đây:
ZZ0000ZZ

::

$ modprobe libcomposite
	$ không gắn kết $CONFIGFS_HOME -t configfs

trong đó CONFIGFS_HOME là điểm gắn kết cho configfs

1. Tạo tiện ích
-----------------------

Để mỗi tiện ích được tạo, thư mục tương ứng của nó phải được tạo::

$ mkdir $CONFIGFS_HOME/usb_gadget/<tên tiện ích>

ví dụ.::

$ mkdir $CONFIGFS_HOME/usb_gadget/g1

	...
	...
	...

$ cd $CONFIGFS_HOME/usb_gadget/g1

Mỗi tiện ích cần phải có id nhà cung cấp <VID> và id sản phẩm <PID> được chỉ định::

$ echo <VID> > idVendor
	$ echo <PID> > idProduct

Một tiện ích cũng cần có số sê-ri, nhà sản xuất và chuỗi sản phẩm.
Để có nơi lưu trữ chúng phải tạo một thư mục con strings
cho mỗi ngôn ngữ, ví dụ::

chuỗi $ mkdir/0x409

Sau đó, các chuỗi có thể được chỉ định ::

$ echo <số sê-ri> > chuỗi/0x409/số sê-ri
	$ echo <nhà sản xuất> > chuỗi/0x409/nhà sản xuất
	$ echo <sản phẩm> > chuỗi/0x409/sản phẩm

Các bộ mô tả chuỗi tùy chỉnh khác có thể được tạo dưới dạng các thư mục trong
thư mục của ngôn ngữ, với chuỗi văn bản được ghi vào thuộc tính "s"
trong thư mục của chuỗi::

$ chuỗi mkdir/0x409/xu.0
	$ echo <chuỗi văn bản> > strings/0x409/xu.0/s

Khi trình điều khiển chức năng hỗ trợ nó, các chức năng có thể cho phép liên kết tượng trưng đến các tùy chỉnh này
bộ mô tả chuỗi để liên kết các chuỗi đó với bộ mô tả lớp.

2. Tạo cấu hình
------------------------------

Mỗi tiện ích sẽ bao gồm một số cấu hình, tương ứng của chúng
thư mục phải được tạo::

$ mkdir configs/<name>.<number>

trong đó <name> có thể là bất kỳ chuỗi nào hợp pháp trong hệ thống tệp và
<number> là số của cấu hình, ví dụ::

$ cấu hình mkdir/c.1

	...
	...
	...

Mỗi cấu hình cũng cần các chuỗi của nó nên phải tạo một thư mục con
cho mỗi ngôn ngữ, ví dụ::

$ cấu hình mkdir/c.1/strings/0x409

Sau đó, chuỗi cấu hình có thể được chỉ định ::

$ echo <configuration> > configs/c.1/strings/0x409/configuration

Một số thuộc tính cũng có thể được đặt cho cấu hình, ví dụ:::

$ echo 120 > configs/c.1/MaxPower

3. Tạo các hàm
-------------------------

Tiện ích sẽ cung cấp một số chức năng, mỗi chức năng tương ứng
thư mục phải được tạo::

$ mkdir function/<name>.<tên instance>

trong đó <name> tương ứng với một trong các tên hàm và tên phiên bản được phép
là một chuỗi tùy ý được phép trong hệ thống tệp, ví dụ:::

$ mkdir function/ncm.usb0 # usb_f_ncm.ko được tải với request_module()

  ...
  ...
  ...

Mỗi hàm cung cấp tập hợp các thuộc tính cụ thể của nó, với chế độ chỉ đọc
hoặc truy cập đọc-ghi. Nếu có thể, chúng cần được viết thành
thích hợp.
Vui lòng tham khảo Tài liệu/ABI/testing/configfs-usb-gadget để biết thêm thông tin.

4. Liên kết các chức năng với cấu hình của chúng
------------------------------------------------------

Tại thời điểm này, một số tiện ích được tạo ra, mỗi tiện ích có một số
cấu hình được chỉ định và một số chức năng có sẵn. Những gì còn lại
đang chỉ định chức năng nào khả dụng trong cấu hình nào (giống
chức năng có thể được sử dụng trong nhiều cấu hình). Điều này đạt được với
tạo liên kết tượng trưng::

$ ln -s function/<name>.<instance name> configs/<name>.<number>

ví dụ.::

$ ln -s hàm/ncm.usb0 configs/c.1

	...
	...
	...

5. Kích hoạt tiện ích
----------------------

Tất cả các bước trên phục vụ mục đích soạn thảo tiện ích của
cấu hình và chức năng.

Cấu trúc thư mục ví dụ có thể trông như thế này::

.
  ./chuỗi
  ./strings/0x409
  ./strings/0x409/serialnumber
  ./strings/0x409/product
  ./strings/0x409/nhà sản xuất
  ./configs
  ./configs/c.1
  ./configs/c.1/ncm.usb0 -> ../../../../usb_gadget/g1/functions/ncm.usb0
  ./configs/c.1/strings
  ./configs/c.1/strings/0x409
  ./configs/c.1/strings/0x409/configuration
  ./configs/c.1/bmAttribut
  ./configs/c.1/MaxPower
  ./chức năng
  ./functions/ncm.usb0
  ./functions/ncm.usb0/ifname
  ./functions/ncm.usb0/qmult
  ./functions/ncm.usb0/host_addr
  ./functions/ncm.usb0/dev_addr
  ./UDC
  ./bcdUSB
  ./bcdDevice
  ./idSản phẩm
  ./idVendor
  ./bMaxPacketSize0
  ./bDeviceProtocol
  ./bDeviceSubClass
  ./bDeviceClass


Tiện ích như vậy cuối cùng phải được kích hoạt để máy chủ USB có thể liệt kê nó.

Để kích hoạt tiện ích, nó phải được liên kết với UDC (Thiết bị USB
Bộ điều khiển)::

$ echo <tên udc> > UDC

trong đó <udc name> là một trong những cái được tìm thấy trong /sys/class/udc/*
ví dụ::

$ echo s3c-hsotg > UDC


6. Vô hiệu hóa tiện ích
-----------------------

::

$ echo "" > UDC

7. Dọn dẹp
--------------

Xóa chức năng khỏi cấu hình::

$ rm configs/<config name>.<number>/<function>

trong đó <tên cấu hình>.<số> chỉ định cấu hình và <chức năng> là
một liên kết tượng trưng đến một chức năng bị xóa khỏi cấu hình, ví dụ:::

$ rm cấu hình/c.1/ncm.usb0

	...
	...
	...

Xóa các thư mục chuỗi trong cấu hình::

$ rmdir configs/<config name>.<number>/strings/<lang>

ví dụ.::

$ rmdir cấu hình/c.1/strings/0x409

	...
	...
	...

và xóa các cấu hình::

$ rmdir configs/<tên cấu hình>.<số>

ví dụ.::

cấu hình rmdir/c.1

	...
	...
	...

Xóa các chức năng (tuy nhiên, các mô-đun chức năng không được tải)::

$ rmdir hàm/<tên>.<tên phiên bản>

ví dụ.::

$ rmdir hàm/ncm.usb0

	...
	...
	...

Xóa các thư mục chuỗi trong tiện ích::

chuỗi $ rmdir/<lang>

ví dụ.::

chuỗi $ rmdir/0x409

và cuối cùng xóa tiện ích::

$ cd ..
	$ rmdir <tên tiện ích>

ví dụ.::

$ rmdir g1




Thiết kế thực hiện
=====================

Dưới đây là ý tưởng về cách hoạt động của configfs.
Trong configfs có các mục và nhóm, cả hai đều được biểu diễn dưới dạng thư mục.
Sự khác biệt giữa một mục và một nhóm là một nhóm có thể chứa
các nhóm khác. Trong hình bên dưới chỉ có một mục được hiển thị.
Cả các mục và nhóm đều có thể có các thuộc tính được biểu diễn dưới dạng tệp.
Người dùng có thể tạo và xóa thư mục nhưng không thể xóa tệp,
có thể ở chế độ chỉ đọc hoặc đọc-ghi, tùy thuộc vào nội dung chúng thể hiện.

Phần hệ thống tập tin của configfs hoạt động trên config_items/groups và
configfs_attributes chung và cùng loại cho tất cả
các phần tử được cấu hình. Tuy nhiên, chúng được nhúng vào mục đích sử dụng cụ thể
các cấu trúc lớn hơn. Trong hình bên dưới có một chữ "cs" chứa
một config_item và một "sa" chứa configfs_attribute.

Chế độ xem hệ thống tập tin sẽ như thế này ::

./
  ./cs (thư mục)
     |
     +--sa (tập tin)
     |
     .
     .
     .

Bất cứ khi nào người dùng đọc/ghi tệp "sa", một hàm sẽ được gọi
chấp nhận cấu trúc config_item và cấu trúc configfs_attribute.
Trong hàm đã nói, "cs" và "sa" được truy xuất bằng cách sử dụng giếng
kỹ thuật container_of đã biết và hàm sa thích hợp (hiển thị hoặc
store) được gọi và chuyển "cs" và bộ đệm ký tự. Buổi trình diễn
là để hiển thị nội dung của tệp (sao chép dữ liệu từ cs sang
đệm), còn "store" dùng để sửa đổi nội dung của tập tin (sao chép dữ liệu
từ bộ đệm đến cs), nhưng điều đó tùy thuộc vào người thực hiện
hai chức năng để quyết định những gì họ thực sự làm.

::

typedef struct configure_structure cs;
  typedef struct cụ thể_attribute sa;

sa
                         +-----------------------------------+
          cs ZZ0002ZZ
  +-----------------+ ZZ0003ZZ
  ZZ0004ZZ ZZ0005ZZ
  ZZ0006ZZ ZZ0007ZZ
  Cấu trúc ZZ0008ZZ ZZ0009ZZ----|------>|struct ZZ0011ZZ
  ZZ0012ZZ config_item ZZ0013ZZ |       |configfs_attribute|       |
  ZZ0016ZZ ZZ0017ZZ
  ZZ0018ZZ +-----------------------------------+
  ZZ0019ZZ.
  ZZ0020ZZ.
  +-----------------+ .

Tên tệp được quyết định bởi người thiết kế mục/nhóm cấu hình, trong khi
các thư mục nói chung có thể được đặt tên theo ý muốn. Một nhóm có thể có
một số nhóm con mặc định của nó được tạo tự động.

Để biết thêm thông tin về configfs, vui lòng xem
ZZ0000ZZ.

Các khái niệm được mô tả ở trên chuyển sang các tiện ích USB như thế này:

1. Một tiện ích có nhóm cấu hình của nó, trong đó có một số thuộc tính (idVendor,
   idProduct, v.v.) và các nhóm phụ mặc định (cấu hình, hàm, chuỗi).
   Việc ghi vào các thuộc tính khiến thông tin được lưu trữ ở nơi thích hợp
   địa điểm. Trong các nhóm con cấu hình, chức năng và chuỗi, người dùng có thể
   tạo các nhóm con của họ để thể hiện cấu hình, chức năng và nhóm
   của chuỗi trong một ngôn ngữ nhất định.

2. Người dùng tạo cấu hình và chức năng trong phần cấu hình
   tạo ra các liên kết tượng trưng cho các chức năng. Thông tin này được sử dụng khi
   Thuộc tính UDC của tiện ích được ghi vào, có nghĩa là ràng buộc tiện ích với
   UDC. Mã trong driver/usb/gadget/configfs.c lặp lại trên tất cả
   cấu hình và trong mỗi cấu hình, nó lặp lại tất cả các chức năng và
   ràng buộc họ. Bằng cách này, toàn bộ tiện ích được ràng buộc.

3. Tệp driver/usb/gadget/configfs.c chứa mã cho

- config_group của tiện ích
	- nhóm mặc định của tiện ích (cấu hình, chức năng, chuỗi)
	- liên kết các chức năng với các cấu hình (liên kết tượng trưng)

4. Mỗi chức năng USB đương nhiên có chế độ xem riêng về những gì nó muốn được cấu hình, vì vậy
   config_groups cho các hàm cụ thể được xác định trong hàm
   tập tin triển khai driver/usb/gadget/f_*.c.

5. Mã của hàm được viết theo cách nó sử dụng
   usb_get_function_instance(), lần lượt gọi request_module.  Vì vậy,
   với điều kiện modprobe hoạt động, các mô-đun cho các chức năng cụ thể sẽ được tải
   tự động. Xin lưu ý rằng điều ngược lại không đúng: sau khi một tiện ích được
   bị vô hiệu hóa và bị phá bỏ, các mô-đun vẫn được tải.
