.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/pnp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================
Tài liệu cắm và chạy Linux
=================================

:Tác giả: Adam Belay <ambx1@neo.rr.com>
:Cập nhật lần cuối: Ngày 16 tháng 10 năm 2002


Tổng quan
--------

Plug and Play cung cấp phương tiện phát hiện và thiết lập tài nguyên cho các thiết bị cũ hoặc
nếu không thì các thiết bị không thể cấu hình được.  Lớp Plug and Play của Linux cung cấp những 
dịch vụ cho các trình điều khiển tương thích.


Giao diện người dùng
------------------

Giao diện người dùng Plug and Play của Linux cung cấp phương tiện để kích hoạt các thiết bị PnP
dành cho trình điều khiển cấp độ người dùng và cũ không hỗ trợ Linux Plug and Play.  các 
giao diện người dùng được tích hợp vào sysfs.

Ngoài tệp sysfs tiêu chuẩn, các tệp sau đây được tạo trong mỗi
thư mục của thiết bị:
- id - hiển thị danh sách ID EISA hỗ trợ
- tùy chọn - hiển thị các cấu hình tài nguyên có thể
- tài nguyên - hiển thị tài nguyên hiện được phân bổ và cho phép thay đổi tài nguyên

kích hoạt một thiết bị
^^^^^^^^^^^^^^^^^^^

::

# echo "tự động" > tài nguyên

điều này sẽ gọi hệ thống cấu hình tài nguyên tự động để kích hoạt thiết bị

kích hoạt thiết bị theo cách thủ công
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

# echo "thủ công <depnum> <mode>" > tài nguyên

<depnum> - số cấu hình
	<chế độ> - tĩnh hoặc động
		 tĩnh = cho lần khởi động tiếp theo
		 năng động = bây giờ

vô hiệu hóa một thiết bị
^^^^^^^^^^^^^^^^^^

::

# echo "vô hiệu hóa" > tài nguyên


EXAMPLE:

Giả sử bạn cần kích hoạt bộ điều khiển đĩa mềm.

1. thay đổi thư mục thích hợp, trong trường hợp của tôi là
   /driver/bus/pnp/devices/00:0f::

# cd /driver/bus/pnp/devices/00:0f
	Tên # cat
	Bộ điều khiển đĩa mềm tiêu chuẩn PC

2. kiểm tra xem thiết bị đã hoạt động chưa::

Tài nguyên # cat
	DISABLED

- Chú ý chuỗi “DISABLED”.  Điều này có nghĩa là thiết bị không hoạt động.

3. kiểm tra cấu hình có thể có của thiết bị (tùy chọn)::

Tùy chọn # cat
	Người phụ thuộc: 01 - Được ưu tiên chấp nhận
	    cổng 0x3f0-0x3f0, căn chỉnh 0x7, kích thước 0x6, giải mã địa chỉ 16 bit
	    cổng 0x3f7-0x3f7, căn chỉnh 0x0, kích thước 0x1, giải mã địa chỉ 16 bit
	    iq 6
	    tương thích DMA 2 8-bit
	Người phụ thuộc: 02 - Được ưu tiên chấp nhận
	    cổng 0x370-0x370, căn chỉnh 0x7, kích thước 0x6, giải mã địa chỉ 16 bit
	    cổng 0x377-0x377, căn chỉnh 0x0, kích thước 0x1, giải mã địa chỉ 16 bit
	    iq 6
	    tương thích DMA 2 8-bit

4. bây giờ kích hoạt thiết bị::

# echo "tự động" > tài nguyên

5. cuối cùng kiểm tra xem thiết bị có hoạt động không ::

Tài nguyên # cat
	io 0x3f0-0x3f5
	io 0x3f7-0x3f7
	iq 6
	dma 2

Ngoài ra còn có một loạt các tham số kernel ::

pnp_reserve_irq=irq1[,irq2] ....
	pnp_reserve_dma=dma1[,dma2] ....
	pnp_reserve_io=io1,size1[,io2,size2] ....
	pnp_reserve_mem=mem1,size1[,mem2,size2] ....



Lớp cắm và chạy hợp nhất
-------------------------------

Tất cả các trình điều khiển, giao thức và dịch vụ Plug and Play đều gặp nhau ở một vị trí trung tâm
được gọi là Lớp Plug and Play.  Tầng này chịu trách nhiệm trao đổi 
thông tin giữa trình điều khiển PnP và giao thức PnP.  Vì thế nó tự động 
chuyển tiếp các lệnh đến giao thức thích hợp.  Điều này làm cho việc viết trình điều khiển PnP 
dễ dàng hơn đáng kể.

Các chức năng sau có sẵn từ Lớp Plug and Play:

pnp_get_protocol
  tăng số lần sử dụng lên một

pnp_put_protocol
  giảm số lần sử dụng đi một

pnp_register_protocol
  sử dụng cái này để đăng ký giao thức PnP mới

pnp_register_driver
  thêm trình điều khiển PnP vào Lớp Plug and Play

điều này bao gồm tích hợp mô hình trình điều khiển
  trả về số 0 nếu thành công hoặc số lỗi âm nếu thất bại; đếm
  gọi phương thức .add() nếu bạn cần biết có bao nhiêu thiết bị liên kết với
  người lái xe

pnp_unregister_driver
  xóa trình điều khiển PnP khỏi Lớp Plug and Play



Giao thức cắm và chạy
-----------------------

Phần này chứa thông tin dành cho các nhà phát triển giao thức PnP.

Các giao thức sau hiện có sẵn trong thế giới điện toán:

-PNPBIOS:
    được sử dụng cho các thiết bị hệ thống như cổng nối tiếp và song song.
-ISAPNP:
    cung cấp hỗ trợ PnP cho bus ISA
-ACPI:
    trong số nhiều công dụng của nó, ACPI cung cấp thông tin về cấp độ hệ thống
    thiết bị.

Nó nhằm mục đích thay thế PNPBIOS.  Nó hiện không được Linux hỗ trợ
Plug and Play nhưng nó được lên kế hoạch trong tương lai gần.


Yêu cầu đối với giao thức Linux PnP:
1. giao thức phải sử dụng ID EISA
2. giao thức phải thông báo cho Lớp PnP về cấu hình hiện tại của thiết bị

- khả năng thiết lập tài nguyên là tùy chọn nhưng được ưu tiên.

Sau đây là các chức năng liên quan đến giao thức PnP:

pnp_add_device
  sử dụng chức năng này để thêm thiết bị PnP vào lớp PnP

chỉ gọi hàm này khi tất cả các giá trị mong muốn được đặt trong pnp_dev
  cấu trúc

pnp_init_device
  gọi cái này để khởi tạo cấu trúc PnP

pnp_remove_device
  gọi đây để xóa thiết bị khỏi Lớp Plug and Play.
  nó sẽ thất bại nếu thiết bị vẫn được sử dụng.
  tự động sẽ giải phóng mem được sử dụng bởi thiết bị và các cấu trúc liên quan

pnp_add_id
  thêm ID EISA vào danh sách ID được hỗ trợ cho thiết bị được chỉ định

Để biết thêm thông tin, hãy tham khảo nguồn của một giao thức như
/drivers/pnp/pnpbios/core.c.



Trình điều khiển Plug and Play Linux
---------------------------

Phần này chứa thông tin dành cho các nhà phát triển trình điều khiển Linux PnP.

Con đường mới
^^^^^^^^^^^

1. trước tiên hãy lập danh sách EISA IDS được hỗ trợ

bán tại::

cấu trúc const tĩnh pnp_id pnp_dev_table[] = {
		/* Cổng máy in LPT tiêu chuẩn */
		{.id = "PNP0400", .driver_data = 0},
		/* Cổng máy in ECP */
		{.id = "PNP0401", .driver_data = 0},
		{.id = ""}
	};

Xin lưu ý rằng ký tự 'X' có thể được sử dụng làm ký tự đại diện trong hàm
   phần (bốn ký tự cuối cùng).

bán tại::

/* Modem PnP không xác định */
	{ "PNPCXXX", UNKNOWN_DEV },

ID thẻ PnP được hỗ trợ có thể được xác định tùy ý.
   bán tại::

cấu trúc const tĩnh pnp_id pnp_card_table[] = {
		{ "ANYDEVS", 0 },
		{ "", 0 }
	};

2. Tùy chọn xác định chức năng thăm dò và loại bỏ.  Nó có thể có ý nghĩa nếu không
   xác định các chức năng này nếu trình điều khiển đã có phương pháp phát hiện đáng tin cậy
   các tài nguyên, chẳng hạn như trình điều khiển parport_pc.

bán tại::

int tĩnh
	serial_pnp_probe(struct pnp_dev * dev, const struct pnp_id *card_id, const
			cấu trúc pnp_id *dev_id)
	{
	. . .

bán tại::

static void serial_pnp_remove(struct pnp_dev * dev)
	{
	. . .

tham khảo /drivers/serial/8250_pnp.c để biết thêm thông tin.

3. tạo cấu trúc trình điều khiển

bán tại::

cấu trúc tĩnh pnp_driver serial_pnp_driver = {
		.name = "nối tiếp",
		.card_id_table = pnp_card_table,
		.id_table = pnp_dev_table,
		.probe = nối tiếp_pnp_probe,
		.remove = nối tiếp_pnp_remove,
	};

* tên và id_table không thể là NULL.

4. đăng ký tài xế

bán tại::

int tĩnh __init serial8250_pnp_init(void)
	{
		trả về pnp_register_driver(&serial_pnp_driver);
	}

Con đường cũ
^^^^^^^^^^^

Một loạt các chức năng tương thích đã được tạo ra để giúp bạn dễ dàng chuyển đổi
Trình điều khiển ISAPNP.  Chúng chỉ nên phục vụ như một giải pháp tạm thời.

Chúng như sau::

cấu trúc pnp_dev *pnp_find_dev(struct pnp_card *card,
				     nhà cung cấp ngắn không dấu,
				     chức năng ngắn không dấu,
				     cấu trúc pnp_dev *từ)

