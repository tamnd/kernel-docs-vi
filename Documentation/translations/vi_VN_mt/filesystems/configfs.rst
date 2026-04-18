.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/configfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================================================
Configfs - Cấu hình đối tượng hạt nhân hướng đến không gian người dùng
======================================================================

Joel Becker <joel.becker@oracle.com>

Cập nhật: ngày 31 tháng 3 năm 2005

Bản quyền (c) 2005 Tập đoàn Oracle,
	Joel Becker <joel.becker@oracle.com>


configfs là gì?
=================

configfs là một hệ thống tập tin dựa trên ram cung cấp khả năng ngược lại của
chức năng của sysfs.  Trong đó sysfs là chế độ xem dựa trên hệ thống tập tin của
đối tượng kernel, configfs là trình quản lý kernel dựa trên hệ thống tập tin
đối tượng hoặc config_items.

Với sysfs, một đối tượng được tạo trong kernel (ví dụ: khi một thiết bị
được phát hiện) và nó được đăng ký với sysfs.  Khi đó thuộc tính của nó
xuất hiện trong sysfs, cho phép không gian người dùng đọc các thuộc tính thông qua
readdir(3)/đọc(2).  Nó có thể cho phép một số thuộc tính được sửa đổi thông qua
viết(2).  Điểm quan trọng là đối tượng được tạo ra và
bị phá hủy trong kernel, kernel điều khiển vòng đời của sysfs
đại diện và sysfs chỉ đơn thuần là một cửa sổ cho tất cả những điều này.

configfs config_item được tạo thông qua thao tác không gian người dùng rõ ràng:
mkdir(2).  Nó bị phá hủy thông qua rmdir(2).  Các thuộc tính xuất hiện tại
mkdir(2) và có thể được đọc hoặc sửa đổi thông qua read(2) và write(2).
Giống như sysfs, readdir(3) truy vấn danh sách các mục và/hoặc thuộc tính.
symlink(2) có thể được sử dụng để nhóm các mục lại với nhau.  Không giống như sysfs,
thời gian tồn tại của biểu diễn hoàn toàn được điều khiển bởi không gian người dùng.  các
các mô-đun hạt nhân hỗ trợ các mục phải đáp ứng điều này.

Cả sysfs và configfs đều có thể và nên tồn tại cùng nhau trên cùng một
hệ thống.  Một cái không phải là sự thay thế cho cái kia.

Sử dụng configfs
==============

configfs có thể được biên dịch dưới dạng mô-đun hoặc vào kernel.  Bạn có thể truy cập
nó bằng cách thực hiện::

mount -t configfs none/config

Cây configfs sẽ trống trừ khi các mô-đun máy khách cũng được tải.
Đây là các mô-đun đăng ký loại mục của chúng với configfs như
các hệ thống con.  Khi hệ thống con máy khách được tải, nó sẽ xuất hiện dưới dạng
thư mục con (hoặc nhiều hơn một) trong /config.  Giống như sysfs,
cây configfs luôn ở đó, cho dù được gắn trên/config hay không.

Một mục được tạo thông qua mkdir(2).  Các thuộc tính của vật phẩm cũng sẽ
xuất hiện vào lúc này.  readdir(3) có thể xác định các thuộc tính là gì,
read(2) có thể truy vấn các giá trị mặc định của chúng và write(2) có thể lưu trữ các giá trị mới
các giá trị.  Không trộn nhiều thuộc tính vào một tệp thuộc tính.

Có hai loại thuộc tính configfs:

* Thuộc tính thông thường, tương tự như thuộc tính sysfs, là văn bản ASCII nhỏ
  các tệp có kích thước tối đa là một trang (PAGE_SIZE, 4096 trên i386).  Tốt nhất là
  chỉ nên sử dụng một giá trị cho mỗi tệp và áp dụng các cảnh báo tương tự từ sysfs.
  Configfs mong đợi write(2) lưu trữ toàn bộ bộ đệm cùng một lúc.  Khi viết thư cho
  các thuộc tính configfs thông thường, các quy trình không gian người dùng trước tiên phải đọc toàn bộ
  tập tin, sửa đổi những phần họ muốn thay đổi, sau đó viết toàn bộ
  đệm trở lại.

* Thuộc tính nhị phân, tương tự như thuộc tính nhị phân của sysfs,
  nhưng có một vài thay đổi nhỏ về ngữ nghĩa.  Giới hạn PAGE_SIZE không
  áp dụng, nhưng toàn bộ mục nhị phân phải vừa với bộ đệm vmalloc'ed hạt nhân đơn.
  Các lệnh gọi write(2) từ không gian người dùng được lưu vào bộ đệm và các thuộc tính'
  Phương thức write_bin_attribute sẽ được gọi vào lần đóng cuối cùng, do đó nó là
  bắt buộc không gian người dùng phải kiểm tra mã trả về của close(2) để
  xác minh rằng thao tác đã kết thúc thành công.
  Để tránh người dùng độc hại OOMing kernel, có một thuộc tính mỗi nhị phân
  giá trị bộ đệm tối đa.

Khi một mục cần được hủy, hãy xóa nó bằng rmdir(2).  Một
vật phẩm không thể bị phá hủy nếu bất kỳ vật phẩm nào khác có liên kết đến nó (thông qua
liên kết tượng trưng (2)).  Liên kết có thể được loại bỏ thông qua hủy liên kết (2).

Định cấu hình FakeNBD: một ví dụ
===============================

Hãy tưởng tượng có trình điều khiển Network Block Device (NBD) cho phép bạn
truy cập các thiết bị chặn từ xa.  Hãy gọi nó là FakeNBD.  FakeNBD sử dụng configfs
cho cấu hình của nó.  Rõ ràng sẽ có một chương trình hay
quản trị viên hệ thống sử dụng để định cấu hình FakeNBD, nhưng bằng cách nào đó chương trình đó phải thông báo
người lái xe về chuyện đó.  Đây là nơi configfs xuất hiện.

Khi trình điều khiển FakeNBD được tải, nó sẽ tự đăng ký với configfs.
readdir(3) thấy điều này ổn ::

# ls/cấu hình
	giảnbd

Kết nối fakenbd có thể được tạo bằng mkdir(2).  Tên là
tùy ý, nhưng có khả năng công cụ này sẽ sử dụng tên này.  Có lẽ
đó là uuid hoặc tên đĩa::

# mkdir /config/fakenbd/đĩa1
	# ls /config/fakenbd/đĩa1
	thiết bị mục tiêu rw

Thuộc tính đích chứa địa chỉ IP của máy chủ FakeNBD sẽ
kết nối với.  Thuộc tính thiết bị là thiết bị trên máy chủ.
Có thể dự đoán được, thuộc tính rw sẽ xác định xem kết nối có
chỉ đọc hoặc đọc-ghi::

# echo 10.0.0.1 > /config/fakenbd/đĩa1/đích
	# echo/dev/sda1 >/config/fakenbd/đĩa1/thiết bị
	# echo 1 > /config/fakenbd/đĩa1/rw

Thế thôi.  Đó là tất cả những gì có.  Bây giờ thiết bị đã được cấu hình, thông qua
vỏ không kém.

Mã hóa bằng configfs
====================

Mọi đối tượng trong configfs đều là config_item.  config_item phản ánh một
đối tượng trong hệ thống con.  Nó có các thuộc tính khớp với các giá trị trên đó
đối tượng.  configfs xử lý biểu diễn hệ thống tập tin của đối tượng đó
và các thuộc tính của nó, cho phép hệ thống con bỏ qua tất cả trừ
tương tác cơ bản về trưng bày/cửa hàng.

Các mục được tạo và hủy bên trong config_group.  Một nhóm là một
tập hợp các mục có chung thuộc tính và hoạt động.
Các mục được tạo bởi mkdir(2) và bị xóa bởi rmdir(2), nhưng configfs
xử lý việc đó.  Nhóm có một tập hợp các thao tác để thực hiện các nhiệm vụ này

Hệ thống con là cấp cao nhất của mô-đun máy khách.  Trong quá trình khởi tạo,
mô-đun máy khách đăng ký hệ thống con với configfs, hệ thống con
xuất hiện dưới dạng một thư mục ở đầu hệ thống tập tin configfs.  A
hệ thống con cũng là một config_group và có thể thực hiện mọi thứ một config_group
có thể.

cấu trúc config_item
==================

::

cấu trúc config_item {
		char *ci_name;
		char ci_namebuf[UOBJ_NAME_LEN];
		struct kref ci_kref;
		cấu trúc list_head ci_entry;
		struct config_item *ci_parent;
		cấu trúc config_group *ci_group;
		cấu trúc config_item_type *ci_type;
		cấu trúc nha khoa *ci_dentry;
	};

void config_item_init(struct config_item *);
	void config_item_init_type_name(struct config_item *,
					const char * tên,
					cấu trúc config_item_type *type);
	cấu hình cấu hình_item ZZ0000ZZ);
	void config_item_put(struct config_item *);

Nói chung, struct config_item được nhúng trong cấu trúc vùng chứa, một
cấu trúc thực sự đại diện cho những gì hệ thống con đang làm.  các
Phần config_item của cấu trúc đó là cách đối tượng tương tác với
configfs.

Dù được xác định tĩnh trong tệp nguồn hay được tạo bởi cha mẹ
config_group, config_item phải có một trong các hàm _init()
kêu gọi nó.  Điều này khởi tạo số lượng tham chiếu và thiết lập
các trường thích hợp.

Tất cả người dùng của config_item phải có tài liệu tham khảo về nó thông qua
config_item_get() và bỏ tham chiếu khi chúng được thực hiện thông qua
config_item_put().

Bản thân config_item không thể làm được gì nhiều hơn là xuất hiện trong configfs.
Thông thường, một hệ thống con muốn mục này hiển thị và/hoặc lưu trữ các thuộc tính,
trong số những thứ khác.  Đối với điều đó, nó cần một loại.

cấu trúc config_item_type
=======================

::

cấu trúc configfs_item_Operation {
		khoảng trống (ZZ0000ZZ);
		int (*allow_link)(struct config_item *src,
				  struct config_item *target);
		khoảng trống (*drop_link)(struct config_item *src,
				 struct config_item *target);
	};

cấu trúc config_item_type {
		mô-đun cấu trúc *ct_owner;
		cấu trúc configfs_item_Operation *ct_item_ops;
		cấu trúc configfs_group_Operation *ct_group_ops;
		cấu hình configfs_attribute **ct_attrs;
		cấu hình configfs_bin_attribute **ct_bin_attrs;
	};

Chức năng cơ bản nhất của config_item_type là xác định những gì
các hoạt động có thể được thực hiện trên config_item.  Tất cả các mục đã được
được phân bổ động sẽ cần cung cấp ct_item_ops->release()
phương pháp.  Phương thức này được gọi khi số tham chiếu của config_item
đạt đến số không.

cấu trúc configfs_attribute
=========================

::

cấu trúc configfs_attribute {
		char *ca_name;
		mô-đun cấu trúc *ca_owner;
		umode_t ca_mode;
		ssize_t (ZZ0000ZZ, char *);
		ssize_t (ZZ0001ZZ, const char *, size_t);
	};

Khi config_item muốn một thuộc tính xuất hiện dưới dạng tệp trong thư mục của mục đó
configfs, nó phải xác định configfs_attribute mô tả nó.
Sau đó, nó thêm thuộc tính vào mảng kết thúc NULL
config_item_type->ct_attrs.  Khi mục này xuất hiện trong configfs,
tệp thuộc tính sẽ xuất hiện cùng với configfs_attribute->ca_name
tên tập tin.  configfs_attribute->ca_mode chỉ định quyền của tệp.

Nếu một thuộc tính có thể đọc được và cung cấp phương thức ->show, phương thức đó sẽ
được gọi bất cứ khi nào không gian người dùng yêu cầu đọc (2) trên thuộc tính.  Nếu một
thuộc tính có thể ghi và cung cấp phương thức ->store, phương thức đó sẽ là
được gọi bất cứ khi nào không gian người dùng yêu cầu ghi (2) trên thuộc tính.

cấu trúc configfs_bin_attribute
=============================

::

cấu trúc configfs_bin_attribute {
		cấu trúc configfs_attribute cb_attr;
		void *cb_private;
		size_t cb_max_size;
	};

Thuộc tính nhị phân được sử dụng khi thuộc tính cần sử dụng blob nhị phân để
xuất hiện dưới dạng nội dung của một tệp trong thư mục configfs của mục.
Để làm như vậy, hãy thêm thuộc tính nhị phân vào mảng kết thúc NULL
config_item_type->ct_bin_attrs và mục này xuất hiện trong configfs,
tệp thuộc tính sẽ xuất hiện cùng với configfs_bin_attribute->cb_attr.ca_name
tên tập tin.  configfs_bin_attribute->cb_attr.ca_mode chỉ định tệp
quyền.
Thành viên cb_private được cung cấp cho người lái xe sử dụng, trong khi thành viên
Thành viên cb_max_size chỉ định số lượng bộ đệm vmalloc tối đa
được sử dụng.

Nếu thuộc tính nhị phân có thể đọc được và config_item cung cấp một
phương thức ct_item_ops->read_bin_attribute(), phương thức đó sẽ được gọi
bất cứ khi nào không gian người dùng yêu cầu đọc (2) trên thuộc tính.  Điều ngược lại
sẽ xảy ra cho write(2). Việc đọc/ghi được lưu vào bộ đệm nên chỉ có một
việc đọc/ghi một lần sẽ xảy ra; các thuộc tính không cần phải quan tâm đến bản thân nó
với nó.

cấu trúc config_group
===================

config_item không thể sống trong chân không.  Cách duy nhất người ta có thể được tạo ra
thông qua mkdir(2) trên config_group.  Điều này sẽ kích hoạt việc tạo ra một
mục con::

cấu trúc config_group {
		cấu hình config_item cg_item;
		struct list_head cg_children;
		struct configfs_subsystem *cg_subsys;
		cấu trúc list_head default_groups;
		danh sách cấu trúc_head nhóm_entry;
	};

void config_group_init(struct config_group *group);
	void config_group_init_type_name(struct config_group *group,
					 const char * tên,
					 cấu trúc config_item_type *type);


Cấu trúc config_group chứa config_item.  Cấu hình đúng cách
mục đó có nghĩa là một nhóm có thể hoạt động như một mục theo đúng nghĩa của nó.
Tuy nhiên, nó có thể làm được nhiều hơn thế: nó có thể tạo các mục hoặc nhóm con.  Đây là
được thực hiện thông qua các hoạt động nhóm được chỉ định trên
config_item_type::

cấu trúc configfs_group_Operation {
		struct config_item *(*make_item)(struct config_group *group,
						 const char *tên);
		struct config_group *(*make_group)(struct config_group *group,
						   const char *tên);
		khoảng trống (*disconnect_notify)(struct config_group *group,
					  struct config_item *item);
		khoảng trống (*drop_item)(struct config_group *group,
				  struct config_item *item);
	};

Một nhóm tạo ra các mục con bằng cách cung cấp
phương thức ct_group_ops->make_item().  Nếu được cung cấp, phương thức này được gọi từ
mkdir(2) trong thư mục của nhóm.  Hệ thống con cấp phát một địa chỉ mới
config_item (hoặc nhiều khả năng là cấu trúc vùng chứa của nó), khởi tạo nó,
và trả nó về configfs.  Configfs sau đó sẽ điền vào hệ thống tập tin
cây để phản ánh mục mới.

Nếu hệ thống con muốn đứa trẻ trở thành một nhóm thì hệ thống con
cung cấp ct_group_ops->make_group().  Mọi thứ khác đều hoạt động giống nhau,
sử dụng các hàm _init() của nhóm trên nhóm.

Cuối cùng, khi không gian người dùng gọi rmdir(2) trên mục hoặc nhóm,
ct_group_ops->drop_item() được gọi.  Vì config_group cũng là một
config_item, không cần thiết phải có phương thức drop_group() riêng biệt.
Hệ thống con phải config_item_put() tham chiếu đã được khởi tạo
khi phân bổ mặt hàng.  Nếu một hệ thống con không có việc gì để làm, nó có thể bỏ qua
phương thức ct_group_ops->drop_item() và configfs sẽ gọi
config_item_put() trên mục thay mặt cho hệ thống con.

Quan trọng:
   drop_item() là vô hiệu và do đó không thể thất bại.  Khi rmdir(2)
   được gọi, configfs WILL xóa mục khỏi cây hệ thống tập tin
   (giả sử rằng nó không có con để giữ cho nó bận rộn).  Hệ thống con là
   chịu trách nhiệm trả lời về việc này.  Nếu hệ thống con có tham chiếu đến
   mục trong các chủ đề khác, bộ nhớ được an toàn.  Có thể mất một thời gian
   để vật phẩm thực sự biến mất khỏi việc sử dụng của hệ thống con.  Nhưng nó
   đã biến mất khỏi configfs.

Khi drop_item() được gọi, liên kết của mục đó đã bị rách
xuống.  Nó không còn tham chiếu đến cha mẹ của nó nữa và không có chỗ trong
hệ thống phân cấp mục.  Nếu khách hàng cần dọn dẹp trước việc này
sự cố xảy ra, hệ thống con có thể thực hiện
phương thức ct_group_ops->disconnect_notify().  Phương thức này được gọi sau
configfs đã xóa mục này khỏi chế độ xem hệ thống tệp nhưng trước
item bị xóa khỏi nhóm cha của nó.  Giống như drop_item(),
ngắt kết nối_notify() bị vô hiệu và không thể thất bại.  Các hệ thống con của khách hàng nên
không bỏ bất kỳ tài liệu tham khảo nào ở đây vì họ vẫn phải thực hiện điều đó trong drop_item().

Không thể xóa config_group khi nó vẫn còn các mục con.  Cái này
được triển khai trong mã configfs rmdir(2).  ->drop_item() sẽ không có
được gọi vì mục này chưa bị đánh rơi.  rmdir(2) sẽ thất bại, vì
thư mục không trống.

cấu trúc configfs_subsystem
=========================

Một hệ thống con phải tự đăng ký, thường là vào lúc module_init.  Cái này
yêu cầu configfs làm cho hệ thống con xuất hiện trong cây tệp::

cấu trúc configfs_subsystem {
		cấu trúc config_group su_group;
		cấu trúc mutex su_mutex;
	};

int configfs_register_subsystem(struct configfs_subsystem *subsys);
	void configfs_unregister_subsystem(struct configfs_subsystem *subsys);

Một hệ thống con bao gồm một config_group cấp cao nhất và một mutex.
Nhóm là nơi config_items con được tạo.  Đối với một hệ thống con,
nhóm này thường được xác định tĩnh.  Trước khi gọi
configfs_register_subsystem(), hệ thống con phải khởi tạo
nhóm thông qua các hàm nhóm _init() thông thường và nó cũng phải có
đã khởi tạo mutex.

Khi lệnh gọi đăng ký quay trở lại, hệ thống con đang hoạt động và nó
sẽ hiển thị qua configfs.  Tại thời điểm đó, mkdir(2) có thể được gọi và
hệ thống con phải sẵn sàng cho việc đó.

Một ví dụ
==========

Ví dụ tốt nhất về những khái niệm cơ bản này là simple_children
hệ thống con/nhóm và mục simple_child trong
mẫu/configfs/configfs_sample.c. Nó hiển thị một đối tượng tầm thường hiển thị
và lưu trữ một thuộc tính cũng như một nhóm đơn giản tạo và hủy
những đứa trẻ này

Điều hướng phân cấp và Mutex hệ thống con
============================================

Có một phần thưởng bổ sung mà configfs cung cấp.  config_groups và
config_items được sắp xếp theo thứ bậc do thực tế là chúng
xuất hiện trong một hệ thống tập tin.  Một hệ thống con là NEVER để chạm vào hệ thống tập tin
các bộ phận, nhưng hệ thống con có thể quan tâm đến hệ thống phân cấp này.  cho
lý do này, hệ thống phân cấp được phản ánh thông qua config_group->cg_children
và các thành viên cấu trúc config_item->ci_parent.

Một hệ thống con có thể điều hướng danh sách cg_children và con trỏ ci_parent
để xem cây được tạo bởi hệ thống con.  Điều này có thể chạy đua với configfs'
quản lý hệ thống phân cấp, vì vậy configfs sử dụng mutex của hệ thống con để
bảo vệ các sửa đổi.  Bất cứ khi nào một hệ thống con muốn điều hướng
phân cấp, nó phải làm như vậy dưới sự bảo vệ của hệ thống con
mutex.

Một hệ thống con sẽ bị ngăn không cho có được mutex trong khi một hệ thống con mới
mục được phân bổ chưa được liên kết vào hệ thống phân cấp này.   Tương tự, nó
sẽ không thể lấy được mutex trong khi vật phẩm rơi ra không
vẫn chưa được hủy liên kết.  Điều này có nghĩa là con trỏ ci_parent của một mục sẽ
không bao giờ là NULL khi vật phẩm ở trong configfs và vật phẩm đó sẽ chỉ
nằm trong danh sách cg_children của cha mẹ nó trong cùng khoảng thời gian.  Điều này cho phép
một hệ thống con để tin cậy ci_parent và cg_children trong khi họ nắm giữ
mutex.

Tổng hợp mục thông qua liên kết tượng trưng(2)
===============================

configfs cung cấp một nhóm đơn giản thông qua group->item parent/child
mối quan hệ.  Tuy nhiên, thông thường, một môi trường lớn hơn đòi hỏi sự tổng hợp
bên ngoài kết nối cha/con.  Điều này được thực hiện thông qua
liên kết tượng trưng(2).

config_item có thể cung cấp ct_item_ops->allow_link() và
phương thức ct_item_ops->drop_link().  Nếu phương thức ->allow_link() tồn tại,
symlink(2) có thể được gọi với config_item làm nguồn của liên kết.
Các liên kết này chỉ được phép giữa configfs config_items.  bất kỳ
symlink(2) cố gắng bên ngoài hệ thống tập tin configfs sẽ bị từ chối.

Khi symlink(2) được gọi, nguồn config_item's ->allow_link()
phương thức được gọi với chính nó và một mục đích.  Nếu mục nguồn
cho phép liên kết đến mục đích, nó trả về 0. Một mục nguồn có thể muốn
từ chối một liên kết nếu nó chỉ muốn liên kết đến một loại đối tượng nhất định (ví dụ:
trong hệ thống con của chính nó).

Khi unlink(2) được gọi trên liên kết tượng trưng, mục nguồn là
được thông báo qua phương thức ->drop_link().  Giống như phương thức ->drop_item(),
đây là hàm void và không thể trả về lỗi.  Hệ thống con là
chịu trách nhiệm đáp ứng với sự thay đổi.

Không thể xóa config_item khi nó liên kết với bất kỳ mục nào khác, cũng như không thể xóa
nó có thể được gỡ bỏ trong khi một mục liên kết với nó.  Liên kết tượng trưng lơ lửng thì không
được phép trong configfs.

Nhóm con được tạo tự động
===============================

Một config_group mới có thể muốn có hai loại config_items con.
Mặc dù điều này có thể được hệ thống hóa bằng các tên ma thuật trong ->make_item(), nhưng nó rất phức tạp.
rõ ràng hơn là có một phương pháp theo đó không gian người dùng nhìn thấy sự khác biệt này.

Thay vì có một nhóm trong đó một số mặt hàng hoạt động khác với
những người khác, configfs cung cấp một phương thức theo đó một hoặc nhiều nhóm con được
được tạo tự động bên trong cha mẹ khi tạo nó.  Như vậy,
mkdir("parent") dẫn đến "parent", "parent/subgroup1", cho đến hết
"mẹ/nhóm conN".  Các mục loại 1 bây giờ có thể được tạo trong
"parent/subgroup1" và các mục thuộc loại N có thể được tạo trong
"mẹ/nhóm conN".

Các nhóm con tự động hoặc nhóm mặc định này không loại trừ các nhóm khác
con của nhóm cha mẹ.  Nếu ct_group_ops->make_group() tồn tại,
các nhóm con khác có thể được tạo trực tiếp trên nhóm chính.

Hệ thống con configfs chỉ định các nhóm mặc định bằng cách thêm chúng bằng cách sử dụng
hàm configfs_add_default_group() cho config_group gốc
cấu trúc.  Mỗi nhóm được thêm vào sẽ được điền vào cây configfs cùng một lúc
thời gian là nhóm mẹ.  Tương tự, chúng được loại bỏ cùng một lúc
với tư cách là cha mẹ.  Không có thông báo bổ sung được cung cấp.  Khi ->drop_item()
cuộc gọi phương thức sẽ thông báo cho hệ thống con rằng nhóm cha sẽ biến mất, nó
cũng có nghĩa là mọi nhóm con mặc định được liên kết với nhóm mẹ đó.

Do đó, các nhóm mặc định không thể bị xóa trực tiếp thông qua
rmdir(2).  Chúng cũng không được xem xét khi rmdir(2) trên cha mẹ
nhóm đang kiểm tra trẻ em.

Hệ thống con phụ thuộc
====================

Đôi khi các trình điều khiển khác phụ thuộc vào các mục cấu hình cụ thể.  cho
ví dụ: việc gắn kết ocfs2 phụ thuộc vào mục vùng nhịp tim.  Nếu đó
mục khu vực bị xóa bằng rmdir(2), mount ocfs2 phải BUG hoặc đi
chỉ đọc.  Không vui.

configfs cung cấp hai lệnh gọi API bổ sung: configfs_depend_item() và
configfs_undepend_item().  Một trình điều khiển khách hàng có thể gọi
configfs_depend_item() trên một mục hiện có để cho configfs biết rằng đó là
phụ thuộc vào.  configfs sau đó sẽ trả về -EBUSY từ rmdir(2) cho điều đó
mục.  Khi mục này không còn phụ thuộc vào nữa, trình điều khiển máy khách sẽ gọi
configfs_undepend_item() trên đó.

Những API này không thể được gọi bên dưới bất kỳ lệnh gọi lại configfs nào, vì
họ sẽ xung đột.  Họ có thể chặn và phân bổ.  Trình điều khiển khách hàng
có lẽ không nên gọi họ theo suy nghĩ riêng của mình.  Đúng hơn là nó nên
đang cung cấp API mà các hệ thống con bên ngoài gọi.

Cái này hoạt động thế nào?  Hãy tưởng tượng quá trình gắn kết ocfs2.  Khi nó gắn kết,
nó yêu cầu một mục khu vực nhịp tim.  Điều này được thực hiện thông qua một cuộc gọi vào
mã nhịp tim.  Bên trong mã nhịp tim, mục khu vực được xem xét
lên.  Ở đây, mã nhịp tim gọi configfs_depend_item().  Nếu nó
thành công, thì nhịp tim biết khu vực này an toàn để cung cấp cho ocfs2.
Nếu thất bại, dù sao thì nó cũng sẽ bị phá bỏ và nhịp tim có thể hoạt động một cách duyên dáng.
bỏ qua một lỗi.
