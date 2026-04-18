.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/i2c/writing-clients.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
Triển khai trình điều khiển thiết bị I2C
========================================

Đây là hướng dẫn nhỏ dành cho những ai muốn viết kernel driver cho I2C
hoặc thiết bị SMBus, sử dụng Linux làm máy chủ/máy chủ giao thức (không phải máy phụ).

Để thiết lập trình điều khiển, bạn cần thực hiện một số việc. Một số là tùy chọn và
một số việc có thể được thực hiện hơi khác hoặc hoàn toàn khác. Sử dụng cái này như một
hướng dẫn, không phải như một cuốn sách quy tắc!


Nhận xét chung
===============

Cố gắng giữ không gian tên kernel càng sạch càng tốt. Cách tốt nhất để
làm điều này là sử dụng tiền tố duy nhất cho tất cả các ký hiệu chung. Đây là
đặc biệt quan trọng đối với các biểu tượng được xuất, nhưng bạn nên làm
nó cũng dành cho các biểu tượng không được xuất. Chúng tôi sẽ sử dụng tiền tố ZZ0000ZZ trong phần này
hướng dẫn.


Cấu trúc điều khiển
====================

Thông thường, bạn sẽ triển khai một cấu trúc trình điều khiển duy nhất và khởi tạo
tất cả khách hàng từ nó. Hãy nhớ rằng, cấu trúc trình điều khiển chứa quyền truy cập chung
các thói quen và không được khởi tạo bằng 0 ngoại trừ các trường có dữ liệu bạn
cung cấp.  Cấu trúc máy khách chứa thông tin dành riêng cho thiết bị như
nút thiết bị mô hình trình điều khiển và địa chỉ I2C của nó.

::

const tĩnh struct i2c_device_id foo_idtable[] = {
	{ "foo", my_id_for_foo },
	{ "thanh", my_id_for_bar },
	{ }
  };
  MODULE_DEVICE_TABLE(i2c, foo_idtable);

cấu trúc tĩnh i2c_driver foo_driver = {
	.driver = {
		.name = "foo",
		.pm = &foo_pm_ops, /* tùy chọn */
	},

.id_table = foo_idtable,
	.probe = foo_probe,
	.remove = foo_remove,

.shutdown = foo_shutdown, /* tùy chọn */
	.command = foo_command, /* tùy chọn, không dùng nữa */
  }

Trường tên là tên trình điều khiển và không được chứa dấu cách.  Nó
phải khớp với tên mô-đun (nếu trình điều khiển có thể được biên dịch dưới dạng mô-đun),
mặc dù bạn có thể sử dụng MODULE_ALIAS (chuyển "foo" trong ví dụ này) để thêm
tên khác cho mô-đun.  Nếu tên trình điều khiển không khớp với mô-đun
tên, mô-đun sẽ không được tải tự động (hotplug/coldplug).

Tất cả các trường khác dành cho chức năng gọi lại sẽ được giải thích
bên dưới.


Dữ liệu khách hàng bổ sung
==========================

Mỗi cấu trúc máy khách có một trường ZZ0000ZZ đặc biệt có thể trỏ tới bất kỳ cấu trúc máy khách nào.
cấu trúc cả.  Bạn nên sử dụng điều này để giữ dữ liệu dành riêng cho thiết bị.

::

/*lưu trữ giá trị*/
	void i2c_set_clientdata(struct i2c_client *client, void *data);

/* lấy giá trị */
	vô hiệu *i2c_get_clientdata(const struct i2c_client *client);

Lưu ý rằng bắt đầu với kernel 2.6.34, bạn không phải đặt trường ZZ0000ZZ
tới NULL trong lệnh xóa() hoặc nếu thăm dò() không thành công nữa. Lõi i2c thực hiện điều này
tự động vào những dịp này. Đó cũng là những lần duy nhất cốt lõi sẽ
chạm vào trường này.


Truy cập máy khách
====================

Giả sử chúng ta có cấu trúc khách hàng hợp lệ. Đến một lúc nào đó chúng ta sẽ cần
để thu thập thông tin từ khách hàng hoặc viết thông tin mới cho
khách hàng.

Tôi thấy việc xác định hàm foo_read và foo_write cho việc này rất hữu ích.
Đối với một số trường hợp, việc gọi trực tiếp các hàm I2C sẽ dễ dàng hơn,
nhưng nhiều con chip có một số ý tưởng về giá trị đăng ký có thể dễ dàng
được đóng gói.

Các hàm bên dưới là ví dụ đơn giản và không nên sao chép
theo nghĩa đen::

int foo_read_value(struct i2c_client *client, u8 reg)
  {
	if (reg < 0x10) /* thanh ghi cỡ byte */
		trả về i2c_smbus_read_byte_data(client, reg);
	else /* thanh ghi cỡ từ */
		trả về i2c_smbus_read_word_data(client, reg);
  }

int foo_write_value(struct i2c_client *client, u8 reg, giá trị u16)
  {
	if (reg == 0x10) /* Không thể ghi - lỗi trình điều khiển! */
		trả về -EINVAL;
	khác nếu (reg < 0x10) /* thanh ghi cỡ byte */
		trả về i2c_smbus_write_byte_data(client, reg, value);
	else /* thanh ghi cỡ từ */
		trả về i2c_smbus_write_word_data(client, reg, value);
  }


Thăm dò và gắn kết
=====================

Ngăn xếp Linux I2C ban đầu được viết để hỗ trợ truy cập vào phần cứng
giám sát chip trên bo mạch chủ PC và do đó được sử dụng để nhúng một số giả định
phù hợp với SMBus (và PC) hơn là I2C.  Một trong số này
giả định là hầu hết các bộ điều hợp và trình điều khiển thiết bị đều hỗ trợ SMBUS_QUICK
giao thức để thăm dò sự hiện diện của thiết bị.  Một điều nữa là các thiết bị và trình điều khiển của chúng
có thể được cấu hình đầy đủ chỉ bằng cách sử dụng các nguyên hàm thăm dò như vậy.

Khi Linux và ngăn xếp I2C của nó được sử dụng rộng rãi hơn trong các hệ thống nhúng
và các thành phần phức tạp như bộ điều hợp DVB, những giả định đó ngày càng trở nên rõ ràng hơn.
có vấn đề.  Trình điều khiển cho các thiết bị I2C gây ra ngắt cần nhiều hơn (và
khác nhau) thông tin cấu hình, cũng như các trình điều khiển xử lý các biến thể chip
không thể phân biệt được bằng cách thăm dò giao thức hoặc cần một số bảng
thông tin cụ thể để hoạt động chính xác.


Liên kết thiết bị/trình điều khiển
----------------------------------

Cơ sở hạ tầng hệ thống, thường là mã khởi tạo dành riêng cho bo mạch hoặc
chương trình cơ sở khởi động, báo cáo những thiết bị I2C tồn tại.  Ví dụ, có thể có
một bảng, trong kernel hoặc từ bộ tải khởi động, xác định các thiết bị I2C
và liên kết chúng với thông tin cấu hình dành riêng cho từng bo mạch về IRQ
và các tạo tác nối dây khác, loại chip, v.v.  Điều đó có thể được sử dụng để
tạo đối tượng i2c_client cho mỗi thiết bị I2C.

Trình điều khiển thiết bị I2C sử dụng mô hình liên kết này hoạt động giống như bất kỳ trình điều khiển nào khác
loại trình điều khiển trong Linux: chúng cung cấp phương thức thăm dò() để liên kết với
các thiết bị đó và phương thức Remove() để hủy liên kết.

::

int tĩnh foo_probe(struct i2c_client *client);
	static void foo_remove(struct i2c_client *client);

Hãy nhớ rằng i2c_driver không tạo các thẻ điều khiển máy khách đó.  các
tay cầm có thể được sử dụng trong foo_probe().  Nếu foo_probe() báo thành công
(số 0 không phải là mã trạng thái phủ định) nó có thể lưu mã điều khiển và sử dụng nó cho đến khi
foo_remove() trả về.  Mô hình liên kết đó được hầu hết các trình điều khiển Linux sử dụng.

Hàm thăm dò được gọi khi có một mục trong trường tên id_table
trùng với tên của thiết bị. Nếu chức năng thăm dò cần mục nhập đó, nó
có thể lấy nó bằng cách sử dụng

::

const struct i2c_device_id *id = i2c_match_id(foo_idtable, client);


Tạo thiết bị
---------------

Nếu bạn biết thực tế rằng một thiết bị I2C được kết nối với một bus I2C nhất định,
bạn có thể khởi tạo thiết bị đó bằng cách điền vào i2c_board_info
cấu trúc với địa chỉ thiết bị và tên trình điều khiển và gọi
i2c_new_client_device().  Điều này sẽ tạo ra thiết bị, sau đó là lõi trình điều khiển
sẽ đảm nhiệm việc tìm kiếm trình điều khiển phù hợp và sẽ gọi phương thức thăm dò() của nó.
Nếu trình điều khiển hỗ trợ các loại thiết bị khác nhau, bạn có thể chỉ định loại bạn muốn
muốn sử dụng trường loại.  Bạn cũng có thể chỉ định IRQ và dữ liệu nền tảng
nếu cần.

Đôi khi bạn biết rằng một thiết bị được kết nối với bus I2C nhất định, nhưng bạn
không biết địa chỉ chính xác mà nó sử dụng.  Điều này xảy ra trên bộ điều hợp TV cho
ví dụ, trong đó cùng một trình điều khiển hỗ trợ hàng chục phần mềm hơi khác nhau
kiểu máy và địa chỉ thiết bị I2C thay đổi từ kiểu máy này sang kiểu máy tiếp theo.  trong
trong trường hợp đó, bạn có thể sử dụng biến thể i2c_new_scanned_device(), đó là
tương tự như i2c_new_client_device(), ngoại trừ việc nó cần thêm một danh sách
địa chỉ I2C có thể để thăm dò.  Một thiết bị được tạo ra lần đầu tiên
địa chỉ đáp ứng trong danh sách.  Nếu bạn mong đợi có nhiều hơn một thiết bị
có trong dải địa chỉ, chỉ cần gọi i2c_new_scanned_device()
nhiều lần.

Cuộc gọi tới i2c_new_client_device() hoặc i2c_new_scanned_device() thường
xảy ra trong trình điều khiển xe buýt I2C. Bạn có thể muốn lưu i2c_client được trả về
tài liệu tham khảo để sử dụng sau này.


Phát hiện thiết bị
------------------

Cơ chế phát hiện thiết bị có một số nhược điểm.
Bạn cần một số cách đáng tin cậy để xác định các thiết bị được hỗ trợ
(thường sử dụng các thanh ghi nhận dạng chuyên dụng, dành riêng cho thiết bị),
nếu không thì việc phát hiện sai có thể xảy ra và mọi thứ có thể sai sót
nhanh chóng.  Hãy nhớ rằng giao thức I2C không bao gồm bất kỳ
cách tiêu chuẩn để phát hiện sự hiện diện của một con chip tại một địa chỉ nhất định, hãy
một cách tiêu chuẩn để xác định thiết bị.  Tệ hơn nữa là việc thiếu
ngữ nghĩa liên quan đến việc chuyển xe buýt, có nghĩa là giống nhau
việc truyền dữ liệu có thể được coi là thao tác đọc của chip và là thao tác ghi
hoạt động bởi một chip khác.  Vì những lý do này, việc phát hiện thiết bị là
được coi là cơ chế kế thừa và không nên được sử dụng trong mã mới.


Xóa thiết bị
---------------

Mỗi thiết bị I2C đã được tạo bằng i2c_new_client_device()
hoặc i2c_new_scanned_device() có thể được hủy đăng ký bằng cách gọi
i2c_unregister_device().  Nếu bạn không gọi nó một cách rõ ràng, nó sẽ là
được gọi tự động trước khi bus I2C bên dưới bị xóa,
vì thiết bị không thể tồn tại ở thiết bị gốc trong mô hình trình điều khiển thiết bị.


Đang khởi tạo trình điều khiển
==============================

Khi kernel được khởi động hoặc khi mô-đun trình điều khiển foo của bạn được chèn vào,
bạn phải thực hiện một số khởi tạo. May mắn thay, chỉ cần đăng ký
mô-đun trình điều khiển thường là đủ.

::

int tĩnh __init foo_init(void)
  {
	trả về i2c_add_driver(&foo_driver);
  }
  module_init(foo_init);

khoảng trống tĩnh __exit foo_cleanup(void)
  {
	i2c_del_driver(&foo_driver);
  }
  module_exit(foo_cleanup);

Macro module_i2c_driver() có thể được sử dụng để giảm mã ở trên.

module_i2c_driver(foo_driver);

Lưu ý rằng một số chức năng được đánh dấu bằng ZZ0000ZZ.  Những chức năng này có thể
sẽ bị xóa sau khi quá trình khởi động kernel (hoặc tải mô-đun) hoàn tất.
Tương tự như vậy, các hàm được đánh dấu bằng ZZ0001ZZ sẽ bị trình biên dịch loại bỏ khi
mã được tích hợp vào kernel, vì chúng sẽ không bao giờ được gọi.


Thông tin tài xế
==================

::

/* Thay thế tên và địa chỉ email của bạn */
  MODULE_AUTHOR("Frodo Looijaard <frodol@dds.nl>"
  MODULE_DESCRIPTION("Trình điều khiển cho thiết bị Barf Inc. Foo I2C");

/* một số loại giấy phép không phải GPL cũng được cho phép */
  MODULE_LICENSE("GPL");


Quản lý nguồn điện
==================

Nếu thiết bị I2C của bạn cần xử lý đặc biệt khi hệ thống ở mức thấp
trạng thái nguồn - như đặt bộ thu phát vào chế độ năng lượng thấp hoặc
kích hoạt cơ chế đánh thức hệ thống -- thực hiện điều đó bằng cách triển khai
các lệnh gọi lại thích hợp cho dev_pm_ops của trình điều khiển (như tạm dừng
và tiếp tục).

Đây là các lệnh gọi mô hình trình điều khiển tiêu chuẩn và chúng hoạt động giống như chúng
sẽ dành cho bất kỳ ngăn xếp trình điều khiển nào khác.  Các cuộc gọi có thể ngủ và có thể sử dụng
Tin nhắn I2C tới thiết bị đang bị treo hoặc tiếp tục lại (vì chúng
Bộ điều hợp I2C gốc hoạt động khi các cuộc gọi này được thực hiện và IRQ
vẫn được kích hoạt).


Tắt hệ thống
===============

Nếu thiết bị I2C của bạn cần xử lý đặc biệt khi hệ thống tắt
hoặc khởi động lại (bao gồm kexec) -- như tắt một cái gì đó -- hãy sử dụng
phương thức tắt máy().

Một lần nữa, đây là lệnh gọi mô hình trình điều khiển tiêu chuẩn, hoạt động giống như vậy
đối với bất kỳ ngăn xếp trình điều khiển nào khác: các cuộc gọi có thể ở chế độ ngủ và có thể sử dụng
Tin nhắn I2C.


Chức năng lệnh
================

Hỗ trợ chức năng gọi lại giống như ioctl chung. Bạn sẽ hiếm khi
cần cái này, và việc sử dụng nó dù sao cũng không được dùng nữa, vì vậy thiết kế mới hơn sẽ không
sử dụng nó.


Gửi và nhận
=====================

Nếu bạn muốn giao tiếp với thiết bị của mình, có một số chức năng
để làm điều này Bạn có thể tìm thấy tất cả chúng trong <linux/i2c.h>.

Nếu bạn có thể chọn giữa giao tiếp I2C đơn giản và cấp độ SMBus
thông tin liên lạc, xin vui lòng sử dụng sau này. Tất cả các bộ điều hợp đều hiểu cấp độ SMBus
các lệnh, nhưng chỉ một số trong số chúng hiểu được I2C đơn giản!


Giao tiếp I2C đơn giản
-----------------------

::

int i2c_master_send(struct i2c_client *client, const char *buf,
			    số int);
	int i2c_master_recv(struct i2c_client *client, char *buf, số int);

Các thói quen này đọc và ghi một số byte từ/đến máy khách. khách hàng
chứa địa chỉ I2C, do đó bạn không cần phải đưa nó vào. thứ hai
tham số chứa các byte để đọc/ghi, số byte thứ ba
để đọc/ghi (phải nhỏ hơn độ dài của bộ đệm, đồng thời phải
nhỏ hơn 64k vì msg.len là u16.) Trả về là số byte thực tế
đọc/viết.

::

int i2c_transfer(struct i2c_adapter *adap, struct i2c_msg *msg,
			 int số);

Điều này sẽ gửi một loạt tin nhắn. Mỗi tin nhắn có thể được đọc hoặc viết,
và chúng có thể được trộn lẫn theo bất kỳ cách nào. Các giao dịch được kết hợp: không
điều kiện dừng được ban hành giữa giao dịch. Cấu trúc i2c_msg
chứa cho mỗi tin nhắn địa chỉ máy khách, số byte của
tin nhắn và chính dữ liệu tin nhắn.

Bạn có thể đọc tệp i2c-protocol.rst để biết thêm thông tin về
giao thức I2C thực tế.


Truyền thông SMBus
-------------------

::

s32 i2c_smbus_xfer(struct i2c_adapter *adapter, u16 addr,
			   cờ ngắn không dấu, char read_write, lệnh u8,
			   kích thước int, liên kết i2c_smbus_data *data);

Đây là chức năng SMBus chung. Tất cả các chức năng dưới đây được thực hiện
về mặt nó. Không bao giờ sử dụng chức năng này trực tiếp!

::

s32 i2c_smbus_read_byte(struct i2c_client *client);
	s32 i2c_smbus_write_byte(struct i2c_client *client, giá trị u8);
	s32 i2c_smbus_read_byte_data(struct i2c_client *client, lệnh u8);
	s32 i2c_smbus_write_byte_data(struct i2c_client *client,
				      lệnh u8, giá trị u8);
	s32 i2c_smbus_read_word_data(struct i2c_client *client, lệnh u8);
	s32 i2c_smbus_write_word_data(struct i2c_client *client,
				      lệnh u8, giá trị u16);
	s32 i2c_smbus_read_block_data(struct i2c_client *client,
				      lệnh u8, giá trị u8 *);
	s32 i2c_smbus_write_block_data(struct i2c_client *client,
				       lệnh u8, độ dài u8, giá trị const u8 *);
	s32 i2c_smbus_read_i2c_block_data(struct i2c_client *client,
					  lệnh u8, độ dài u8, giá trị u8 *);
	s32 i2c_smbus_write_i2c_block_data(struct i2c_client *client,
					   lệnh u8, độ dài u8,
					   giá trị const u8 *);

Những cái này đã bị xóa khỏi i2c-core vì chúng không có người dùng, nhưng có thể
sẽ được thêm lại sau nếu cần::

s32 i2c_smbus_write_quick(struct i2c_client *client, giá trị u8);
	s32 i2c_smbus_process_call(struct i2c_client *client,
				   lệnh u8, giá trị u16);
	s32 i2c_smbus_block_process_call(struct i2c_client *client,
					 lệnh u8, độ dài u8, giá trị u8 *);

Tất cả các giao dịch này trả về giá trị lỗi âm khi thất bại. Việc 'viết'
giao dịch trả về 0 khi thành công; các giao dịch 'đã đọc' trả về kết quả đã đọc
giá trị, ngoại trừ các giao dịch khối, trả về số lượng giá trị
đọc. Bộ đệm khối không cần dài hơn 32 byte.

Bạn có thể đọc tệp smbus-protocol.rst để biết thêm thông tin về
giao thức SMBus thực tế.


Thói quen mục đích chung
========================

Dưới đây tất cả các thói quen mục đích chung được liệt kê, chưa được đề cập
trước::

/* Trả về số bộ điều hợp cho bộ điều hợp cụ thể */
	int i2c_adapter_id(struct i2c_adapter *adap);
