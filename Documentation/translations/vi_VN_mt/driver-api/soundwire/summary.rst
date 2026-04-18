.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/soundwire/summary.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==============================
Tóm tắt hệ thống con SoundWire
===========================

SoundWire là giao diện mới được Liên minh MIPI phê chuẩn vào năm 2015.
SoundWire được sử dụng để truyền dữ liệu thường liên quan đến âm thanh
chức năng. Giao diện SoundWire được tối ưu hóa để tích hợp các thiết bị âm thanh trong
hệ thống lấy cảm hứng từ thiết bị di động hoặc thiết bị di động.

SoundWire là giao diện đa điểm 2 chân với đường dữ liệu và đồng hồ. Nó
tạo điều kiện phát triển các hệ thống chi phí thấp, hiệu quả, hiệu suất cao.
Các tính năng chính ở cấp độ rộng của giao diện SoundWire bao gồm:

(1) Vận chuyển tất cả các kênh dữ liệu tải trọng, thông tin điều khiển và thiết lập
     lệnh qua một giao diện hai chân duy nhất.

(2) Tần số xung nhịp thấp hơn và do đó tiêu thụ điện năng thấp hơn bằng cách sử dụng DDR
     Truyền dữ liệu (Tốc độ dữ liệu kép).

(3) Chia tỷ lệ đồng hồ và nhiều làn dữ liệu tùy chọn để mang lại sự linh hoạt rộng rãi
     tốc độ dữ liệu phù hợp với yêu cầu của hệ thống.

(4) Giám sát trạng thái thiết bị, bao gồm cảnh báo kiểu ngắt cho Thuyền trưởng.

Giao thức SoundWire hỗ trợ tối đa 11 giao diện Slave. Tất cả
các giao diện chia sẻ Bus chung chứa dữ liệu và đường đồng hồ. Mỗi trong số
Slave có thể hỗ trợ tối đa 14 Cổng dữ liệu. 13 cổng dữ liệu dành riêng cho âm thanh
vận chuyển. Cổng dữ liệu0 được dành riêng để vận chuyển thông tin điều khiển hàng loạt,
mỗi Cổng dữ liệu âm thanh (1..14) có thể hỗ trợ tối đa 8 Kênh trong
chế độ truyền hoặc nhận (thường là hướng cố định nhưng có thể định cấu hình
hướng được kích hoạt bởi đặc điểm kỹ thuật).  Hạn chế về băng thông đối với
Tuy nhiên, ~19.2..24.576Mbits/s không cho phép sử dụng các kênh 11*13*8
được truyền đi đồng thời.

Hình dưới đây minh họa ví dụ về khả năng kết nối giữa SoundWire Master và
hai thiết bị Slave. ::

+--------------+ +--------------+
        Tín hiệu đồng hồ ZZ0000ZZ ZZ0001ZZ
        ZZ0002ZZ-------+-------------------------------ZZ0003ZZ
        ZZ0004ZZ ZZ0005ZZ Giao diện 1 |
        ZZ0006ZZ-------ZZ0007ZZ |
        +--------------+ ZZ0008ZZ +--------------+
                                ZZ0009ZZ
                                ZZ0010ZZ
                                ZZ0011ZZ
                             +--+-------+--+
                             ZZ0012ZZ
                             ZZ0013ZZ
                             ZZ0014ZZ
                             ZZ0015ZZ
                             +-------------+


Thuật ngữ
===========

Đặc tả MIPI SoundWire sử dụng thuật ngữ 'thiết bị' để chỉ Master
hoặc giao diện Slave, tất nhiên điều này có thể gây nhầm lẫn. Trong bản tóm tắt này và
mã chúng tôi chỉ sử dụng thuật ngữ giao diện để chỉ phần cứng. Chúng tôi làm theo
Mô hình thiết bị Linux bằng cách ánh xạ từng giao diện Slave được kết nối trên bus dưới dạng
thiết bị được quản lý bởi một trình điều khiển cụ thể. Hệ thống con Linux SoundWire cung cấp
một khung để triển khai trình điều khiển SoundWire Slave với API cho phép
Nhà cung cấp bên thứ 3 kích hoạt chức năng do triển khai xác định trong khi
các tác vụ thiết lập/cấu hình chung được xử lý bởi bus.

Xe buýt:
Triển khai SoundWire Linux Bus xử lý giao thức SoundWire.
Lập trình tất cả các thanh ghi Slave do MIPI xác định. Đại diện cho SoundWire
Thầy ơi. Nhiều phiên bản của Bus có thể có mặt trong một hệ thống.

Nô lệ:
Đăng ký làm thiết bị SoundWire Slave (Thiết bị Linux). Nhiều thiết bị Slave
có thể đăng ký một phiên bản Bus.

Lái xe nô lệ:
Trình điều khiển điều khiển thiết bị Slave. Các thanh ghi do MIPI chỉ định được kiểm soát
trực tiếp bằng Bus (và được truyền qua trình điều khiển/giao diện Master).
Mọi thanh ghi Slave do triển khai xác định đều được điều khiển bởi trình điều khiển Slave. trong
thực tế, người ta hy vọng rằng trình điều khiển Slave sẽ dựa vào regmap và không
yêu cầu truy cập đăng ký trực tiếp.

Giao diện lập trình (Trình điều khiển giao diện SoundWire Master)
==========================================================

SoundWire Bus hỗ trợ giao diện lập trình cho SoundWire Master
triển khai và các thiết bị SoundWire Slave. Tất cả mã đều sử dụng "sdw"
tiền tố thường được các nhà thiết kế SoC và nhà cung cấp bên thứ 3 sử dụng.

Mỗi giao diện SoundWire Master cần phải được đăng ký với Bus.
Bus triển khai API để đọc các thuộc tính Master MIPI tiêu chuẩn và cũng cung cấp
gọi lại trong Master ops để trình điều khiển Master thực hiện các chức năng riêng của nó
cung cấp thông tin về khả năng. Hỗ trợ DT không được triển khai tại thời điểm này
thời gian nhưng việc thêm vào không đáng kể vì các khả năng được bật bằng
ZZ0000ZZ API.

Giao diện Master cùng với các khả năng của giao diện Master là
được đăng ký dựa trên tập tin bảng, DT hoặc ACPI.

Sau đây là Bus API để đăng ký Bus SoundWire:

.. code-block:: c

	int sdw_bus_master_add(struct sdw_bus *bus,
				struct device *parent,
				struct fwnode_handle)
	{
		sdw_master_device_add(bus, parent, fwnode);

		mutex_init(&bus->lock);
		INIT_LIST_HEAD(&bus->slaves);

		/* Check ACPI for Slave devices */
		sdw_acpi_find_slaves(bus);

		/* Check DT for Slave devices */
		sdw_of_find_slaves(bus);

		return 0;
	}

Điều này sẽ khởi tạo đối tượng sdw_bus cho thiết bị Master. "sdw_master_ops" và
Các chức năng gọi lại "sdw_master_port_ops" được cung cấp cho Bus.

"sdw_master_ops" được Bus sử dụng để điều khiển Bus trong phần cứng cụ thể
cách. Nó bao gồm các chức năng điều khiển Bus như gửi SoundWire
đọc/ghi tin nhắn trên Bus, thiết lập tần số xung nhịp & Stream
Điểm đồng bộ hóa (SSP). Cấu trúc "sdw_master_ops" tóm tắt
chi tiết phần cứng của Master từ Bus.

"sdw_master_port_ops" được Bus sử dụng để thiết lập các tham số Cổng của
Cổng giao diện chính. Bản đồ đăng ký cổng giao diện chính không được xác định bởi
Đặc điểm kỹ thuật MIPI, do đó Bus gọi lệnh gọi lại "sdw_master_port_ops"
chức năng thực hiện các hoạt động của Cảng như "Chuẩn bị cổng", "Thông số vận chuyển cảng
set", "Bật và tắt cổng". Việc triển khai trình điều khiển Master có thể
sau đó thực hiện các cấu hình dành riêng cho phần cứng.

Giao diện lập trình (SoundWire Slave Driver)
===============================================

Đặc tả MIPI yêu cầu mỗi giao diện Slave hiển thị một giao diện duy nhất
Mã định danh 48 bit, được lưu trữ trong 6 thanh ghi dev_id chỉ đọc. Dev_id này
mã định danh chứa thông tin về nhà cung cấp và bộ phận, cũng như trường cho phép
để phân biệt các thành phần giống hệt nhau. Một trường lớp bổ sung là
hiện chưa được sử dụng. Trình điều khiển phụ được viết cho một nhà cung cấp và bộ phận cụ thể
mã định danh, Bus liệt kê thiết bị Slave dựa trên hai id này.
Việc so khớp thiết bị và trình điều khiển phụ được thực hiện dựa trên hai id này. thăm dò
của trình điều khiển Slave được Bus gọi khi khớp thành công giữa thiết bị và
id tài xế Mối quan hệ cha/con được thực thi giữa Master và Slave
thiết bị (biểu diễn logic được căn chỉnh phù hợp với thiết bị vật lý
kết nối).

Thông tin về các phần phụ thuộc Master/Slave được lưu trữ trong dữ liệu nền tảng,
tập tin bảng, ACPI hoặc DT. Đặc tả phần mềm MIPI xác định các
tham số link_id cho bộ điều khiển có nhiều giao diện Master. các
Các thanh ghi dev_id chỉ là duy nhất trong phạm vi của một liên kết và link_id
duy nhất trong phạm vi của bộ điều khiển. Cả dev_id và link_id đều không
nhất thiết phải là duy nhất ở cấp độ hệ thống nhưng thông tin cha/con là
được sử dụng để tránh sự mơ hồ.

.. code-block:: c

	static const struct sdw_device_id slave_id[] = {
	        SDW_SLAVE_ENTRY(0x025d, 0x700, 0),
	        {},
	};
	MODULE_DEVICE_TABLE(sdw, slave_id);

	static struct sdw_driver slave_sdw_driver = {
	        .driver = {
	                   .name = "slave_xxx",
	                   .pm = &slave_runtime_pm,
	                   },
		.probe = slave_sdw_probe,
		.remove = slave_sdw_remove,
		.ops = &slave_slave_ops,
		.id_table = slave_id,
	};


Đối với các khả năng, Bus triển khai API để đọc các thuộc tính Slave MIPI tiêu chuẩn
và cũng cung cấp chức năng gọi lại trong các hoạt động Slave để trình điều khiển Slave tự triển khai
chức năng cung cấp thông tin về khả năng. Xe buýt cần biết một bộ
Khả năng của Slave để lập trình các thanh ghi Slave và điều khiển Bus
các cấu hình lại.

Liên kết
=====

Thông số kỹ thuật SoundWire MIPI 1.1 có sẵn tại:
ZZ0000ZZ

Thông số kỹ thuật của SoundWire MIPI DisCo (Khám phá và Cấu hình) là
có sẵn tại:
ZZ0000ZZ

(có thể truy cập công khai bằng cách đăng ký hoặc có thể truy cập trực tiếp vào MIPI
thành viên)

Trang ID nhà sản xuất liên minh MIPI: mid.mipi.org
