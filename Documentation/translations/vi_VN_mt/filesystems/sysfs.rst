.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/sysfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================================================
sysfs - Hệ thống tập tin _The_ để xuất các đối tượng kernel
=====================================================

Patrick Mochel <mochel@osdl.org>

Mike Murphy <mamurph@cs.clemson.edu>

:Sửa đổi: ngày 16 tháng 8 năm 2011
:Bản gốc: ngày 10 tháng 1 năm 2003


Nó là gì
~~~~~~~~~~

sysfs là hệ thống tệp dựa trên RAM ban đầu dựa trên ramfs. Nó cung cấp
một phương tiện để xuất cấu trúc dữ liệu hạt nhân, các thuộc tính của chúng và
liên kết giữa chúng với không gian người dùng.

sysfs vốn được gắn với cơ sở hạ tầng kobject. Xin vui lòng đọc
Documentation/core-api/kobject.rst để biết thêm thông tin liên quan đến kobject
giao diện.


Sử dụng sysfs
~~~~~~~~~~~

sysfs luôn được biên dịch nếu CONFIG_SYSFS được xác định. Bạn có thể truy cập
nó bằng cách thực hiện::

mount -t sysfs sysfs /sys


Tạo thư mục
~~~~~~~~~~~~~~~~~~

Đối với mỗi kobject được đăng ký với hệ thống, sẽ có một thư mục
được tạo cho nó trong sysfs. Thư mục đó được tạo dưới dạng thư mục con
của cha mẹ của kobject, thể hiện hệ thống phân cấp đối tượng nội bộ cho
không gian người dùng. Các thư mục cấp cao nhất trong sysfs đại diện cho các thư mục chung
tổ tiên của hệ thống phân cấp đối tượng; tức là các hệ thống con các đối tượng
thuộc về.

sysfs lưu trữ nội bộ một con trỏ tới kobject thực hiện một
thư mục trong đối tượng kernfs_node được liên kết với thư mục đó. trong
trước đây con trỏ kobject này đã được sysfs sử dụng để tham chiếu
đếm trực tiếp trên kobject bất cứ khi nào tệp được mở hoặc đóng.
Với việc triển khai sysfs hiện tại, số tham chiếu kobject là
chỉ được sửa đổi trực tiếp bởi hàm sysfs_schedule_callback().


Thuộc tính
~~~~~~~~~~

Các thuộc tính có thể được xuất cho kobject dưới dạng tệp thông thường trong
hệ thống tập tin. sysfs chuyển tiếp các thao tác I/O của tệp tới các phương thức được xác định
cho các thuộc tính, cung cấp phương tiện để đọc và ghi kernel
thuộc tính.

Các thuộc tính phải là tệp văn bản ASCII, tốt nhất chỉ có một giá trị
mỗi tập tin. Cần lưu ý rằng việc chỉ chứa một
giá trị trên mỗi tệp, vì vậy việc thể hiện một mảng các giá trị được chấp nhận về mặt xã hội
các giá trị cùng loại.

Trộn các loại, thể hiện nhiều dòng dữ liệu và làm những điều lạ mắt
định dạng dữ liệu bị phản đối rất nhiều. Làm những việc này có thể nhận được
bạn đã bị sỉ nhục một cách công khai và mã của bạn được viết lại mà không báo trước.


Một định nghĩa thuộc tính chỉ đơn giản là::

thuộc tính cấu trúc {
	    char *tên;
	    mô-đun cấu trúc * chủ sở hữu;
	    chế độ umode_t;
    };


int sysfs_create_file(struct kobject * kobj, const struct attribute * attr);
    void sysfs_remove_file(struct kobject * kobj, const struct attribute * attr);


Một thuộc tính trần không có phương tiện để đọc hoặc ghi giá trị của
thuộc tính. Các hệ thống con được khuyến khích xác định thuộc tính riêng của chúng
cấu trúc và các hàm bao bọc để thêm và xóa các thuộc tính cho
một loại đối tượng cụ thể.

Ví dụ: mô hình trình điều khiển xác định struct device_attribute như::

cấu trúc thiết bị_thuộc tính {
	    thuộc tính cấu trúc attr;
	    ssize_t (*show)(struct device *dev, struct device_attribute *attr,
			    char *buf);
	    ssize_t (*store)(struct device *dev, struct device_attribute *attr,
			    const char *buf, size_t count);
    };

int device_create_file(thiết bị cấu trúc ZZ0000ZZ);
    void device_remove_file(thiết bị cấu trúc ZZ0001ZZ);

Nó cũng định nghĩa trình trợ giúp này để xác định các thuộc tính của thiết bị ::

#define DEVICE_ATTR(_name, _mode, _show, _store) \
    struct device_attribute dev_attr_##_name = __ATTR(_name, _mode, _show, _store)

Ví dụ: khai báo::

DEVICE_ATTR tĩnh (foo, S_IWUSR | S_IRUGO, show_foo, store_foo);

tương đương với việc làm::

cấu trúc tĩnh device_attribute dev_attr_foo = {
	    .attr = {
		    .name = "foo",
		    .mode = S_IWUSR | S_IRUGO,
	    },
	    .show = show_foo,
	    .store = store_foo,
    };

Lưu ý như đã nêu trong include/linux/sysfs.h "OTHER_WRITABLE? Nói chung
được coi là một ý tưởng tồi." vì vậy hãy cố gắng thiết lập một tệp sysfs có thể ghi cho
mọi người sẽ không thể hoàn nguyên về chế độ RO cho "Khác".

Đối với các trường hợp thông thường sysfs.h cung cấp các macro tiện lợi để thực hiện
việc xác định các thuộc tính dễ dàng hơn cũng như làm cho mã ngắn gọn hơn và
có thể đọc được. Trường hợp trên có thể rút gọn thành:

cấu trúc tĩnh device_attribute dev_attr_foo = __ATTR_RW(foo);

danh sách những người trợ giúp có sẵn để xác định hàm bao bọc của bạn là:

__ATTR_RO(tên):
		 giả sử name_show mặc định và chế độ 0444
__ATTR_WO(tên):
		 chỉ giả định một name_store và bị giới hạn ở chế độ
                 0200 chỉ có quyền truy cập ghi root.
__ATTR_RO_MODE(tên, chế độ):
	         để có quyền truy cập RO hạn chế hơn; hiện tại
                 trường hợp sử dụng duy nhất là Bảng tài nguyên hệ thống EFI
                 (xem trình điều khiển/chương trình cơ sở/efi/esrt.c)
__ATTR_RW(tên):
	         giả sử name_show, name_store và cài đặt mặc định
                 sang chế độ 0644.
__ATTR_NULL:
	         đặt tên thành NULL và được sử dụng ở cuối danh sách
                 chỉ báo (xem: kernel/workqueue.c)

Lệnh gọi lại dành riêng cho hệ thống con
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Khi một hệ thống con xác định một loại thuộc tính mới, nó phải thực hiện một
tập hợp các hoạt động sysfs để chuyển tiếp các cuộc gọi đọc và ghi tới
phương thức hiển thị và lưu trữ của chủ sở hữu thuộc tính::

cấu trúc sysfs_ops {
	    ssize_t (ZZ0000ZZ, thuộc tính cấu trúc ZZ0001ZZ);
	    ssize_t (ZZ0002ZZ, thuộc tính cấu trúc ZZ0003ZZ, size_t);
    };

[ Các hệ thống con lẽ ra đã xác định struct kobj_type là một
bộ mô tả cho loại này, đó là nơi chứa con trỏ sysfs_ops
được lưu trữ. Xem tài liệu kobject để biết thêm thông tin. ]

Khi một tập tin được đọc hoặc ghi, sysfs gọi phương thức thích hợp
cho loại này. Sau đó, phương thức này sẽ dịch struct kobject chung
và cấu trúc các con trỏ thuộc tính tới các loại con trỏ thích hợp và
gọi các phương thức liên quan.


Để minh họa::

#define to_dev_attr(_attr) container_of(_attr, struct device_attribute, attr)

ssize_t tĩnh dev_attr_show(struct kobject *kobj, struct attribute *attr,
				char *buf)
    {
	    struct device_attribute *dev_attr = to_dev_attr(attr);
	    thiết bị cấu trúc *dev = kobj_to_dev(kobj);
	    ssize_t ret = -EIO;

nếu (dev_attr->show)
		    ret = dev_attr->show(dev, dev_attr, buf);
	    if (ret >= (ssize_t)PAGE_SIZE) {
		    printk("dev_attr_show: %pS trả về số lượng sai\n",
				    dev_attr->show);
	    }
	    trở lại ret;
    }



Đọc/Ghi dữ liệu thuộc tính
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Để đọc hoặc ghi thuộc tính, các phương thức show() hoặc store() phải
được chỉ định khi khai báo thuộc tính. Các loại phương thức phải như
đơn giản như những gì được xác định cho thuộc tính thiết bị::

ssize_t (*show)(struct device *dev, struct device_attribute *attr, char *buf);
    ssize_t (*store)(struct device *dev, struct device_attribute *attr,
		    const char *buf, size_t count);

IOW, chúng chỉ nên lấy một đối tượng, một thuộc tính và bộ đệm làm tham số.


sysfs phân bổ bộ đệm có kích thước (PAGE_SIZE) và chuyển nó đến
phương pháp. sysfs sẽ gọi phương thức chính xác một lần cho mỗi lần đọc hoặc
viết. Điều này buộc các hành vi sau đây trên phương pháp
triển khai:

- Khi đọc (2), phương thức show() sẽ lấp đầy toàn bộ bộ đệm.
  Hãy nhớ lại rằng một thuộc tính chỉ được xuất một giá trị hoặc một
  mảng có giá trị tương tự nhau, vì vậy cái này sẽ không đắt đến thế.

Điều này cho phép không gian người dùng thực hiện đọc một phần và tìm kiếm chuyển tiếp
  tùy ý trên toàn bộ tập tin theo ý muốn. Nếu không gian người dùng tìm lại
  bằng 0 hoặc thực hiện pread(2) với độ lệch là '0', phương thức show() sẽ
  được gọi lại, sắp xếp lại, để lấp đầy bộ đệm.

- Khi ghi (2), sysfs mong đợi toàn bộ bộ đệm sẽ được chuyển trong quá trình
  viết đầu tiên. sysfs sau đó chuyển toàn bộ bộ đệm sang phương thức store().
  Một null kết thúc được thêm vào sau dữ liệu trên các cửa hàng. Điều này làm cho
  các chức năng như sysfs_streq() an toàn khi sử dụng.

Khi ghi các tập tin sysfs, các tiến trình không gian người dùng trước tiên phải đọc
  toàn bộ tập tin, sửa đổi các giá trị mà nó muốn thay đổi, sau đó viết
  toàn bộ bộ đệm trở lại.

Việc triển khai phương thức thuộc tính phải hoạt động trên cùng một
  đệm khi đọc và ghi giá trị.

Các ghi chú khác:

- Việc ghi khiến phương thức show() được sắp xếp lại bất kể giá trị hiện tại
  vị trí tập tin.

- Bộ đệm sẽ luôn có độ dài byte PAGE_SIZE. Trên x86, cái này
  là 4096.

- Phương thức show() sẽ trả về số byte được in vào
  bộ đệm.

- Việc triển khai mới các phương thức show() chỉ nên sử dụng sysfs_emit() hoặc
  sysfs_emit_at() khi định dạng giá trị được trả về không gian người dùng.

- store() sẽ trả về số byte được sử dụng từ bộ đệm. Nếu
  toàn bộ bộ đệm đã được sử dụng, chỉ cần trả về đối số đếm.

- show() hoặc store() luôn có thể trả về lỗi. Nếu một giá trị xấu xuất hiện
  qua, hãy chắc chắn trả lại một lỗi.

- Đối tượng được truyền vào các phương thức sẽ được ghim vào bộ nhớ thông qua sysfs
  tham chiếu đếm đối tượng được nhúng của nó. Tuy nhiên, thể chất
  thực thể (ví dụ: thiết bị) mà đối tượng đại diện có thể không xuất hiện. Hãy là
  chắc chắn có cách để kiểm tra điều này, nếu cần thiết.


Việc triển khai thuộc tính thiết bị rất đơn giản (và ngây thơ) là ::

ssize_t show_name tĩnh (thiết bị cấu trúc *dev, struct device_attribute *attr,
			    char *buf)
    {
	    return sysfs_emit(buf, "%s\n", dev->name);
    }

ssize_t store_name tĩnh (thiết bị cấu trúc *dev, struct device_attribute *attr,
			    const char *buf, size_t đếm)
    {
	    snprintf(dev->name, sizeof(dev->name), "%.*s",
		    (int)min(count, sizeof(dev->name) - 1), buf);
	    số lần trả lại;
    }

DEVICE_ATTR tĩnh (tên, S_IRUGO, show_name, store_name);


(Lưu ý rằng việc triển khai thực tế không cho phép không gian người dùng đặt
tên cho một thiết bị.)


Bố cục thư mục cấp cao nhất
~~~~~~~~~~~~~~~~~~~~~~~~~~

Sự sắp xếp thư mục sysfs cho thấy mối quan hệ của kernel
các cấu trúc dữ liệu.

Thư mục sysfs cấp cao nhất trông giống như::

chặn/
    xe buýt/
    lớp/
    nhà phát triển/
    thiết bị/
    phần mềm/
    fs/
    siêu giám sát/
    hạt nhân/
    mô-đun/
    quyền lực/

devices/ chứa biểu diễn hệ thống tập tin của cây thiết bị. Nó bản đồ
trực tiếp tới cây thiết bị hạt nhân bên trong, là hệ thống phân cấp của
thiết bị cấu trúc

bus/ chứa bố cục thư mục phẳng của các loại xe buýt khác nhau trong
hạt nhân. Thư mục của mỗi xe buýt chứa hai thư mục con::

thiết bị/
	trình điều khiển/

devices/ chứa các liên kết tượng trưng cho từng thiết bị được phát hiện trong hệ thống
trỏ đến thư mục của thiết bị trong/sys/devices.

driver/ chứa một thư mục cho mỗi trình điều khiển thiết bị được tải
cho các thiết bị trên xe buýt cụ thể đó (điều này giả định rằng các trình điều khiển không
trải rộng trên nhiều loại xe buýt).

fs/ chứa một thư mục cho một số hệ thống tập tin.  Hiện tại mỗi
hệ thống tập tin muốn xuất các thuộc tính phải tạo hệ thống phân cấp riêng của nó
bên dưới fs/ (xem Fuse/fuse.rst để biết ví dụ).

module/ chứa các giá trị tham số và thông tin trạng thái cho tất cả
các mô-đun hệ thống đã được tải, cho cả mô-đun dựng sẵn và mô-đun có thể tải.

dev/ chứa hai thư mục: char/ và block/. Bên trong hai cái này
thư mục có các liên kết tượng trưng có tên <major>:<minor>.  Những liên kết tượng trưng này
trỏ đến các thư mục bên dưới/sys/devices cho từng thiết bị.  /sys/dev cung cấp một
cách nhanh chóng để tra cứu giao diện sysfs cho một thiết bị từ kết quả của
một hoạt động stat(2).

Bạn có thể tìm thêm thông tin về các tính năng cụ thể của mô hình trình điều khiển trong
Tài liệu/driver-api/driver-model/.

block/ chứa các liên kết tượng trưng đến tất cả các thiết bị khối được phát hiện trên hệ thống.
Các liên kết tượng trưng này trỏ đến các thư mục trong/sys/devices.

class/ chứa một thư mục cho từng lớp thiết bị, được nhóm theo loại chức năng.
Mỗi thư mục trong class/ chứa các liên kết tượng trưng đến các thiết bị trong thư mục /sys/devices.

firmware/ chứa dữ liệu và cấu hình phần sụn hệ thống, chẳng hạn như bảng phần sụn,
Thông tin ACPI và dữ liệu cây thiết bị.

hypervisor/ chứa thông tin nền tảng ảo hóa và cung cấp giao diện cho
trình ảo hóa cơ bản.  Nó chỉ hiện diện khi chạy trên máy ảo.

kernel/ chứa các tham số kernel thời gian chạy, cài đặt cấu hình và trạng thái.

power/ chứa thông tin hệ thống con quản lý nguồn bao gồm
trạng thái ngủ, khả năng tạm dừng/tiếp tục và chính sách.


Giao diện hiện tại
~~~~~~~~~~~~~~~~~~

Các lớp giao diện sau hiện tồn tại trong sysfs.


thiết bị (bao gồm/linux/device.h)
--------------------------------
Kết cấu::

cấu trúc thiết bị_thuộc tính {
	    thuộc tính cấu trúc attr;
	    ssize_t (*show)(struct device *dev, struct device_attribute *attr,
			    char *buf);
	    ssize_t (*store)(struct device *dev, struct device_attribute *attr,
			    const char *buf, size_t count);
    };

Khai báo::

DEVICE_ATTR(_name, _mode, _show, _store);

Tạo/Xóa::

int device_create_file(struct device ZZ0000ZZ attr);
    void device_remove_file(struct device ZZ0001ZZ attr);


trình điều khiển xe buýt (bao gồm/linux/device.h)
------------------------------------
Kết cấu::

cấu trúc bus_attribute {
	    thuộc tính cấu trúc attr;
	    ssize_t (ZZ0000ZZ, char * buf);
	    ssize_t (ZZ0001ZZ, const char * buf, số lượng size_t);
    };

Khai báo::

BUS_ATTR_RW tĩnh (tên);
    tĩnh BUS_ATTR_RO(tên);
    tĩnh BUS_ATTR_WO(tên);

Tạo/Xóa::

int bus_create_file(struct bus_type ZZ0000ZZ);
    void bus_remove_file(struct bus_type ZZ0001ZZ);


trình điều khiển thiết bị (bao gồm/linux/device.h)
---------------------------------------

Kết cấu::

cấu trúc driver_attribute {
	    thuộc tính cấu trúc attr;
	    ssize_t (ZZ0000ZZ, char * buf);
	    ssize_t (ZZ0001ZZ, const char * buf,
			    số lượng size_t);
    };

Khai báo::

DRIVER_ATTR_RO(_name)
    DRIVER_ATTR_RW(_name)

Tạo/Xóa::

int driver_create_file(struct device_driver ZZ0000ZZ);
    void driver_remove_file(struct device_driver ZZ0001ZZ);


Tài liệu
~~~~~~~~~~~~~

Cấu trúc thư mục sysfs và các thuộc tính trong mỗi thư mục xác định một
ABI giữa kernel và không gian người dùng. Đối với bất kỳ ABI nào, điều quan trọng là
ABI này ổn định và được ghi chép đầy đủ. Tất cả các thuộc tính sysfs mới phải
được ghi lại trong Tài liệu/ABI. Xem thêm Tài liệu/ABI/README để biết thêm
thông tin.