.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/eisa.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==================
Hỗ trợ xe buýt EISA
================

:Tác giả: Marc Zyngier <maz@wild-wind.fr.eu.org>

Tài liệu này nhóm các ghi chú ngẫu nhiên về việc chuyển trình điều khiển EISA sang
EISA/sysfs API mới.

Bắt đầu từ phiên bản 2.5.59, bus EISA gần như được cung cấp giống nhau
trạng thái như các xe buýt phổ thông khác như PCI hoặc USB. Cái này
đã có thể thực hiện được thông qua sysfs, nó xác định một tập hợp đủ tốt các
trừu tượng để quản lý xe buýt, thiết bị và trình điều khiển.

Mặc dù API mới sử dụng khá đơn giản, nhưng việc chuyển đổi hiện có
trình điều khiển cho cơ sở hạ tầng mới không phải là một nhiệm vụ dễ dàng (chủ yếu là do
mã phát hiện thường được sử dụng để thăm dò thẻ ISA). Hơn nữa,
hầu hết các trình điều khiển EISA đều nằm trong số các trình điều khiển Linux lâu đời nhất, vì vậy, bạn có thể
hãy tưởng tượng, một số bụi đã lắng đọng ở đây trong những năm qua.

Cơ sở hạ tầng EISA được tạo thành từ ba phần:

- Mã bus thực hiện hầu hết các mã chung. Nó được chia sẻ
      trong số tất cả các kiến trúc mà mã EISA chạy trên đó. Nó
      thực hiện thăm dò xe buýt (phát hiện thẻ EISA có sẵn trên xe buýt),
      phân bổ tài nguyên I/O, cho phép đặt tên ưa thích thông qua sysfs và
      cung cấp giao diện để tài xế đăng ký.

- Bus root driver thực hiện việc gắn kết phần cứng của bus
      và mã bus chung. Nó có trách nhiệm tìm ra
      thiết bị triển khai bus và thiết lập nó để được thăm dò sau
      bằng mã xe buýt. Điều này có thể bắt đầu từ một việc đơn giản như việc đặt trước
      vùng I/O trên x86, đến vùng khá phức tạp hơn, như hppa
      Mã EISA. Đây là phần cần thực hiện để có EISA
      chạy trên nền tảng "mới".

- Người lái xe cung cấp cho xe buýt danh sách các thiết bị mà mình quản lý và
      thực hiện các lệnh gọi lại cần thiết để thăm dò và giải phóng thiết bị
      bất cứ khi nào được bảo.

Mọi chức năng/cấu trúc bên dưới đều tồn tại trong <linux/eisa.h>, điều này phụ thuộc vào
chủ yếu dựa vào <linux/device.h>.

Trình điều khiển gốc xe buýt
===============

::

int eisa_root_register (struct eisa_root_device *root);

Hàm eisa_root_register được sử dụng để khai báo một thiết bị là
gốc của xe buýt EISA. Cấu trúc eisa_root_device chứa một tham chiếu
cho thiết bị này, cũng như một số thông số cho mục đích thăm dò::

cấu trúc eisa_root_device {
		thiết bị cấu trúc ZZ0000ZZ Con trỏ tới thiết bị cầu nối */
		tài nguyên cấu trúc *res;
		bus_base_addr dài không dấu;
		khe int;  /* Số lượng vị trí tối đa */
		int lực_thăm dò; /* Thăm dò ngay cả khi không có slot 0 */
		u64 dma_mask; /* từ thiết bị bridge */
		int bus_nr; /* Đặt bởi eisa_root_register */
		tài nguyên cấu trúc eisa_root_res;	/*cũng như vậy*/
	};

============== ===========================================================
nút được sử dụng cho mục đích nội bộ eisa_root_register
con trỏ dev tới thiết bị gốc
tài nguyên I/O của thiết bị gốc res
địa chỉ bus_base_addr slot 0 trên xe buýt này
số khe cắm tối đa để thăm dò
Force_probe Thăm dò ngay cả khi khe 0 trống (không có bo mạch chính EISA)
dma_mask Mặt nạ DMA mặc định. Thông thường thiết bị cầu nối dma_mask.
bus_nr id bus duy nhất, được đặt bởi eisa_root_register
============== ===========================================================

Tài xế
======

::

int eisa_driver_register (struct eisa_driver *edrv);
	void eisa_driver_unregister (struct eisa_driver *edrv);

Đủ rõ ràng chưa?

::

cấu trúc eisa_device_id {
		ký tự sig[EISA_SIG_LEN];
		driver_data dài không dấu;
	};

cấu trúc eisa_driver {
		const struct eisa_device_id *id_table;
		trình điều khiển struct device_driver;
	};

========================================================================
id_table một mảng các chuỗi id NULL đã kết thúc EISA,
		theo sau là một chuỗi trống. Mỗi chuỗi có thể
		tùy chọn được ghép nối với một giá trị phụ thuộc vào trình điều khiển
		(dữ liệu trình điều khiển).

trình điều khiển một trình điều khiển chung, chẳng hạn như được mô tả trong
		Tài liệu/driver-api/driver-model/driver.rst. Chỉ .name,
		Các thành viên .probe và .remove là bắt buộc.
========================================================================

Một ví dụ là trình điều khiển 3c59x::

cấu trúc tĩnh eisa_device_id vortex_eisa_ids[] = {
		{ "TCM5920", EISA_3C592_OFFSET },
		{ "TCM5970", EISA_3C597_OFFSET },
		{ "" }
	};

cấu trúc tĩnh eisa_driver vortex_eisa_driver = {
		.id_table = xoáy_eisa_ids,
		.driver = {
			.name = "3c59x",
			.probe = xoáy_eisa_probe,
			.remove = xoáy_eisa_remove
		}
	};

Thiết bị
======

Khung sysfs gọi các hàm .probe và .remove trên thiết bị
phát hiện và loại bỏ (lưu ý rằng hàm .remove chỉ được gọi
khi trình điều khiển được xây dựng dưới dạng mô-đun).

Cả hai hàm đều được chuyển một con trỏ tới một 'thiết bị cấu trúc', đó là
được gói gọn trong 'struct eisa_device' được mô tả như sau::

cấu trúc eisa_device {
		cấu trúc eisa_device_id id;
		khe int;
		trạng thái int;
		base_addr dài không dấu;
		cấu trúc tài nguyên res[EISA_MAX_RESOURCES];
		u64 dma_mask;
		nhà phát triển thiết bị cấu trúc; /*thiết bị chung */
	};

==========================================================================
id EISA id, được đọc từ thiết bị. id.driver_data được đặt từ
	 trình điều khiển phù hợp id EISA.
số khe cắm mà thiết bị được phát hiện trên đó
tập hợp các cờ biểu thị trạng thái của thiết bị. hiện tại
	 cờ là EISA_CONFIG_ENABLED và EISA_CONFIG_FORCED.
tập hợp res gồm bốn vùng I/O 256 byte được phân bổ cho thiết bị này
Bộ mặt nạ dma_mask DMA từ thiết bị mẹ.
thiết bị chung dành cho nhà phát triển (xem Tài liệu/driver-api/driver-model/device.rst)
==========================================================================

Bạn có thể lấy 'struct eisa_device' từ 'struct device' bằng cách sử dụng
macro 'to_eisa_device'.

Những thứ linh tinh
==========

::

void eisa_set_drvdata (struct eisa_device *edev, void *data);

Lưu trữ dữ liệu vào vùng driver_data của thiết bị.

::

khoảng trống *eisa_get_drvdata (struct eisa_device *edev):

Lấy con trỏ được lưu trước đó vào vùng driver_data của thiết bị.

::

int eisa_get_khu vực_index (void *addr);

Trả về số vùng (0 <= x < EISA_MAX_RESOURCES) của một vùng nhất định
địa chỉ.

Thông số hạt nhân
=================

eisa_bus.enable_dev
	Một danh sách các khe được phân tách bằng dấu phẩy sẽ được bật, ngay cả khi phần sụn
	đặt thẻ là bị vô hiệu hóa. Người lái xe phải có khả năng thực hiện đúng
	khởi tạo thiết bị trong điều kiện như vậy.

eisa_bus.disable_dev
	Danh sách các khe được phân tách bằng dấu phẩy sẽ bị tắt, ngay cả khi phần sụn
	đặt thẻ ở trạng thái đã bật. Người lái xe sẽ không được gọi để xử lý việc này
	thiết bị.

virtual_root.force_probe
	Buộc mã thăm dò thăm dò các khe EISA ngay cả khi nó không thể tìm thấy
	Bo mạch chính tương thích EISA (không có gì xuất hiện trên khe 0). Mặc định là 0
	(không ép buộc) và đặt thành 1 (bắt buộc thăm dò) khi
	CONFIG_EISA_VLB_PRIMING được thiết lập.

ghi chú ngẫu nhiên
============

Việc chuyển đổi trình điều khiển EISA sang API mới chủ yếu liên quan đến ZZ0000ZZ
mã (vì việc thăm dò hiện nằm trong mã EISA cốt lõi). Thật không may, hầu hết
các trình điều khiển chia sẻ thói quen thăm dò của họ giữa ISA và EISA. Đặc biệt
phải cẩn thận khi trích xuất mã EISA, vì vậy các xe buýt khác
sẽ không phải chịu đựng những cuộc phẫu thuật này...

Bạn ZZ0000ZZ mong đợi mọi thiết bị EISA sẽ được phát hiện khi quay lại
từ eisa_driver_register, vì rất có thể xe buýt chưa
vẫn bị thăm dò. Trên thực tế, đó là điều thường xuyên xảy ra (
trình điều khiển gốc bus thường khởi động khá muộn trong quá trình khởi động).
Thật không may, hầu hết các tài xế đều tự mình kiểm tra và
mong đợi đã khám phá toàn bộ cỗ máy khi họ thoát khỏi đầu dò
thường lệ.

Ví dụ: chuyển thẻ EISA SCSI yêu thích của bạn sang "hotplug"
mô hình là "điều đúng đắn"(tm).

Cảm ơn
======

Tôi muốn cảm ơn những người sau đây vì sự giúp đỡ của họ:

- Xavier Benigni đã cho tôi mượn một chiếc Alpha Jensen tuyệt vời,
- James Bottomley, Jeff Garzik vì đã đưa những thứ này vào kernel,
- Andries Brouwer vì đã đóng góp nhiều id EISA,
- Catrin Jones vì đã xử lý quá nhiều máy móc ở nhà.
