.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/driver-model/bus.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========
Các loại xe buýt
=========

Sự định nghĩa
~~~~~~~~~~
Xem kerneldoc để biết cấu trúc bus_type.

int bus_register(struct bus_type * bus);


Tuyên ngôn
~~~~~~~~~~~

Mỗi loại bus trong kernel (PCI, USB, v.v.) phải khai báo một static
đối tượng thuộc loại này. Họ phải khởi tạo trường tên và có thể
tùy chọn khởi tạo cuộc gọi lại trận đấu::

cấu trúc bus_type pci_bus_type = {
          .name = "pci",
          .match = pci_bus_match,
   };

Cấu trúc phải được xuất sang trình điều khiển trong tệp tiêu đề:

cấu trúc bên ngoài bus_type pci_bus_type;


Sự đăng ký
~~~~~~~~~~~~

Khi trình điều khiển xe buýt được khởi tạo, nó sẽ gọi bus_register. Cái này
khởi tạo phần còn lại của các trường trong đối tượng bus và chèn nó
vào danh sách toàn cầu các loại xe buýt. Khi đối tượng xe buýt được đăng ký,
người lái xe buýt có thể sử dụng các trường trong đó.


Cuộc gọi lại
~~~~~~~~~

match(): Gắn Driver vào thiết bị
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Định dạng cấu trúc ID thiết bị và ngữ nghĩa để so sánh
chúng vốn dành riêng cho xe buýt. Trình điều khiển thường khai báo một mảng
ID thiết bị của các thiết bị họ hỗ trợ nằm trong một bus cụ thể
cấu trúc điều khiển.

Mục đích của việc gọi lại trận đấu là tạo cơ hội cho xe buýt
xác định xem một trình điều khiển cụ thể có hỗ trợ một thiết bị cụ thể hay không bằng cách
so sánh ID thiết bị mà trình điều khiển hỗ trợ với ID thiết bị của
thiết bị cụ thể mà không làm mất đi chức năng dành riêng cho xe buýt hoặc
loại an toàn.

Khi tài xế đăng ký với xe buýt, danh sách thiết bị của xe buýt là
lặp đi lặp lại và lệnh gọi lại khớp được gọi cho từng thiết bị
không có trình điều khiển liên quan đến nó.



Danh sách thiết bị và trình điều khiển
~~~~~~~~~~~~~~~~~~~~~~~

Danh sách các thiết bị và trình điều khiển nhằm thay thế địa chỉ cục bộ
danh sách mà nhiều xe buýt lưu giữ. Chúng là danh sách các thiết bị cấu trúc và
struct device_drivers tương ứng. Tài xế xe buýt được tự do sử dụng
liệt kê theo ý muốn, nhưng việc chuyển đổi sang loại dành riêng cho xe buýt có thể
cần thiết.

Lõi LDM cung cấp các chức năng trợ giúp để lặp qua từng danh sách ::

int bus_for_each_dev(struct bus_type * bus, struct device * start,
		       dữ liệu trống *,
		       int (ZZ0000ZZ, void *));

int bus_for_each_drv(struct bus_type * bus, struct device_driver * start,
		       dữ liệu void *, int (ZZ0000ZZ, void *));

Những người trợ giúp này lặp lại danh sách tương ứng và gọi lệnh gọi lại
cho từng thiết bị hoặc trình điều khiển trong danh sách. Tất cả các quyền truy cập danh sách đều được
được đồng bộ hóa bằng cách lấy khóa của xe buýt (đọc hiện tại). Tài liệu tham khảo
số lượng trên mỗi đối tượng trong danh sách được tăng lên trước khi gọi lại
được gọi là; nó được giảm đi sau khi thu được đối tượng tiếp theo. các
lock không được giữ khi gọi lại.


sysfs
~~~~~~~~
Có một thư mục cấp cao nhất có tên là 'bus'.

Mỗi xe buýt có một thư mục trong thư mục xe buýt, cùng với hai mặc định
thư mục::

/sys/bus/pci/
	|-- thiết bị
	`-- trình điều khiển

Tài xế đã đăng ký với xe buýt sẽ nhận được danh bạ trong tài xế của xe buýt
thư mục::

/sys/bus/pci/
	|-- thiết bị
	ZZ0000ZZ-- e100

Mỗi thiết bị được phát hiện trên một xe buýt loại đó sẽ có một liên kết tượng trưng trong
thư mục thiết bị của xe buýt tới thư mục của thiết bị trong thư mục vật lý
hệ thống phân cấp::

/sys/bus/pci/
	|-- thiết bị
	ZZ0001ZZ-- 00:00.0 -> ../../../root/pci0/00:00.0
	ZZ0002ZZ-- 00:01.0 -> ../../../root/pci0/00:01.0
	|   ZZ0000ZZ-- trình điều khiển


Xuất thuộc tính
~~~~~~~~~~~~~~~~~~~~

::

cấu trúc bus_attribute {
	thuộc tính cấu trúc attr;
	ssize_t (ZZ0000ZZ, char * buf);
	ssize_t (ZZ0001ZZ, const char * buf, số lượng size_t);
  };

Trình điều khiển xe buýt có thể xuất các thuộc tính bằng macro BUS_ATTR_RW hoạt động
tương tự như macro DEVICE_ATTR_RW cho thiết bị. Ví dụ, một
định nghĩa như thế này::

BUS_ATTR_RW tĩnh (gỡ lỗi);

tương đương với việc khai báo::

bus_attribute tĩnh bus_attr_debug;

Sau đó, điều này có thể được sử dụng để thêm và xóa thuộc tính khỏi bus
thư mục sysfs bằng cách sử dụng::

int bus_create_file(struct bus_type ZZ0000ZZ);
	void bus_remove_file(struct bus_type ZZ0001ZZ);
