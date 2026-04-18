.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/driver-model/platform.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================
Thiết bị và trình điều khiển nền tảng
=====================================

Xem <linux/platform_device.h> để biết giao diện mô hình trình điều khiển cho
bus nền tảng: platform_device và platform_driver.  Xe buýt giả này
được sử dụng để kết nối các thiết bị trên xe buýt với cơ sở hạ tầng tối thiểu,
giống như những thứ được sử dụng để tích hợp các thiết bị ngoại vi trên nhiều hệ thống trên chip
bộ xử lý hoặc một số kết nối PC "cũ"; trái ngược với lớn
những cái được chỉ định chính thức như PCI hoặc USB.


Thiết bị nền tảng
~~~~~~~~~~~~~~~~
Thiết bị nền tảng là thiết bị thường xuất hiện dưới dạng tự trị
các thực thể trong hệ thống. Điều này bao gồm các thiết bị dựa trên cổng cũ và
cầu nối máy chủ với các xe buýt ngoại vi và hầu hết các bộ điều khiển được tích hợp
vào các nền tảng hệ thống trên chip.  Họ thường có điểm gì chung
là địa chỉ trực tiếp từ bus CPU.  Hiếm khi, một platform_device sẽ
được kết nối qua một đoạn của loại xe buýt khác; nhưng nó
các thanh ghi vẫn có thể được định địa chỉ trực tiếp.

Các thiết bị nền tảng được đặt tên, được sử dụng trong liên kết trình điều khiển và
danh sách các tài nguyên như địa chỉ và IRQ::

cấu trúc platform_device {
	const char *tên;
	id u32;
	nhà phát triển thiết bị cấu trúc;
	u32 num_resource;
	tài nguyên cấu trúc * tài nguyên;
  };


Trình điều khiển nền tảng
~~~~~~~~~~~~~~~~
Trình điều khiển nền tảng tuân theo quy ước mô hình trình điều khiển tiêu chuẩn, trong đó
việc khám phá/liệt kê được xử lý bên ngoài trình điều khiển và trình điều khiển
cung cấp các phương thức thăm dò() và loại bỏ().  Họ hỗ trợ quản lý năng lượng
và tắt thông báo bằng cách sử dụng các quy ước tiêu chuẩn ::

cấu trúc platform_driver {
	int (ZZ0000ZZ);
	khoảng trống (ZZ0001ZZ);
	khoảng trống (ZZ0002ZZ);
	int (trạng thái ZZ0003ZZ, pm_message_t);
	int (ZZ0004ZZ);
	trình điều khiển struct device_driver;
	const struct platform_device_id *id_table;
	bool ngăn_deferred_probe;
	bool driver_managed_dma;
  };

Lưu ý rằng thăm dò() nói chung phải xác minh rằng phần cứng thiết bị được chỉ định
thực sự tồn tại; đôi khi mã thiết lập nền tảng không thể chắc chắn.  Việc thăm dò
có thể sử dụng tài nguyên thiết bị, bao gồm đồng hồ và dữ liệu platform_data của thiết bị.

Trình điều khiển nền tảng tự đăng ký theo cách thông thường::

int platform_driver_register(struct platform_driver *drv);

Hoặc, trong các tình huống thông thường khi thiết bị được biết là không thể cắm nóng,
quy trình thăm dò() có thể nằm trong phần init để giảm bớt sự khó khăn của trình điều khiển.
Dấu chân bộ nhớ thời gian chạy::

int platform_driver_probe(struct platform_driver *drv,
			  int (ZZ0000ZZ))

Các mô-đun hạt nhân có thể bao gồm một số trình điều khiển nền tảng. Cốt lõi nền tảng
cung cấp trợ giúp để đăng ký và hủy đăng ký một loạt trình điều khiển ::

int __platform_register_drivers(struct platform_driver * const *drivers,
				      số int không dấu, mô-đun cấu trúc * chủ sở hữu);
	void platform_unregister_drivers(struct platform_driver * const *drivers,
					 số int không dấu);

Nếu một trong các trình điều khiển không đăng ký được, tất cả các trình điều khiển đã đăng ký đó
điểm sẽ được hủy đăng ký theo thứ tự ngược lại. Lưu ý rằng có một sự thuận tiện
macro chuyển THIS_MODULE làm tham số chủ sở hữu::

#define platform_register_drivers(trình điều khiển, số lượng)


Liệt kê thiết bị
~~~~~~~~~~~~~~~~~~
Theo quy định, mã thiết lập dành riêng cho nền tảng (và thường dành riêng cho bo mạch) sẽ
đăng ký thiết bị nền tảng::

int platform_device_register(struct platform_device *pdev);

int platform_add_devices(struct platform_device **pdevs, int ndev);

Nguyên tắc chung là chỉ đăng ký những thiết bị thực sự tồn tại,
nhưng trong một số trường hợp, các thiết bị bổ sung có thể được đăng ký.  Ví dụ, một hạt nhân
có thể được cấu hình để hoạt động với bộ điều hợp mạng bên ngoài có thể không
được đưa vào tất cả các bảng hoặc tương tự để hoạt động với bộ điều khiển tích hợp
rằng một số bo mạch có thể không kết nối được với bất kỳ thiết bị ngoại vi nào.

Trong một số trường hợp, boot firmware sẽ xuất các bảng mô tả thiết bị
được điền vào một bảng nhất định.   Nếu không có những bảng như vậy, thường thì
cách duy nhất để mã thiết lập hệ thống thiết lập đúng thiết bị là xây dựng
một hạt nhân cho một bảng mục tiêu cụ thể.  Các hạt nhân dành riêng cho bo mạch như vậy là
phổ biến với việc phát triển hệ thống nhúng và tùy chỉnh.

Trong nhiều trường hợp, bộ nhớ và tài nguyên IRQ được liên kết với nền tảng
thiết bị không đủ để cho trình điều khiển của thiết bị hoạt động.  Mã thiết lập bảng
thường sẽ cung cấp thông tin bổ sung bằng cách sử dụng platform_data của thiết bị
trường để chứa thông tin bổ sung.

Các hệ thống nhúng thường xuyên cần một hoặc nhiều đồng hồ cho các thiết bị nền tảng,
thường được tắt cho đến khi thực sự cần thiết (để tiết kiệm điện).
Thiết lập hệ thống cũng liên kết những đồng hồ đó với thiết bị để
các cuộc gọi tới clk_get(&pdev->dev, clock_name) trả lại chúng nếu cần.


Trình điều khiển kế thừa: Thăm dò thiết bị
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Một số trình điều khiển không được chuyển đổi hoàn toàn sang mô hình trình điều khiển vì chúng chiếm
với vai trò không phải là người lái xe: người lái xe đăng ký thiết bị nền tảng của mình, thay vì
để lại điều đó cho cơ sở hạ tầng hệ thống.  Những trình điều khiển như vậy không thể được cắm nóng
hoặc được cắm nguội, vì các cơ chế đó yêu cầu việc tạo thiết bị phải ở trạng thái
thành phần hệ thống khác với trình điều khiển.

Lý do "chính đáng" duy nhất cho việc này là để xử lý các thiết kế hệ thống cũ hơn, như
PC IBM nguyên bản, dựa vào các mẫu phần cứng "thăm dò phần cứng" dễ bị lỗi
cấu hình.  Các hệ thống mới hơn phần lớn đã từ bỏ mô hình đó để ủng hộ
hỗ trợ cấp độ bus cho cấu hình động (PCI, USB) hoặc bảng thiết bị
được cung cấp bởi chương trình cơ sở khởi động (ví dụ: PNPACPI trên x86).  Có quá nhiều
những lựa chọn trái ngược nhau về những gì có thể ở đâu, và thậm chí cả những phỏng đoán có căn cứ của
một hệ điều hành sẽ thường xuyên bị lỗi đến mức gây rắc rối.

Phong cách lái xe này không được khuyến khích.  Nếu bạn đang cập nhật trình điều khiển như vậy,
vui lòng thử di chuyển bảng liệt kê thiết bị đến vị trí thích hợp hơn,
ngoài người lái xe.  Điều này thường sẽ được dọn dẹp, vì các trình điều khiển như vậy
có xu hướng đã có sẵn các chế độ "bình thường", chẳng hạn như chế độ sử dụng các nút thiết bị
được tạo bởi PNP hoặc bằng cách thiết lập thiết bị nền tảng.

Dù sao đi nữa, vẫn có một số API hỗ trợ các trình điều khiển cũ như vậy.  Tránh
sử dụng các lệnh gọi này ngoại trừ với các trình điều khiển thiếu trình cắm nóng như vậy::

struct platform_device *platform_device_alloc(
			const char *tên, int id);

Bạn có thể sử dụng platform_device_alloc() để phân bổ động một thiết bị,
sau đó bạn sẽ khởi tạo với tài nguyên và platform_device_register().
Một giải pháp tốt hơn thường là::

struct platform_device *platform_device_register_simple(
			const char *tên, int id,
			tài nguyên cấu trúc *res, unsigned int nres);

Bạn có thể sử dụng platform_device_register_simple() làm lệnh gọi một bước để phân bổ
và đăng ký một thiết bị.


Đặt tên thiết bị và liên kết trình điều khiển
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
platform_device.dev.bus_id là tên chuẩn của thiết bị.
Nó được xây dựng từ hai thành phần:

* platform_device.name ... cũng được sử dụng để khớp trình điều khiển.

* platform_device.id ... số phiên bản thiết bị, nếu không thì "-1"
      để chỉ ra rằng chỉ có một.

Chúng được nối với nhau, do đó tên/id "serial"/0 biểu thị bus_id "serial.0" và
"serial/3" biểu thị bus_id "serial.3"; cả hai sẽ sử dụng platform_driver
được đặt tên là "nối tiếp".  Trong khi "my_rtc"/-1 sẽ là bus_id "my_rtc" (không có id phiên bản)
và sử dụng platform_driver có tên là "my_rtc".

Liên kết trình điều khiển được thực hiện tự động bởi lõi trình điều khiển, gọi
thăm dò trình điều khiển() sau khi tìm thấy sự trùng khớp giữa thiết bị và trình điều khiển.  Nếu
thăm dò() thành công, trình điều khiển và thiết bị sẽ bị ràng buộc như bình thường.  có
ba cách khác nhau để tìm kết quả phù hợp:

- Bất cứ khi nào một thiết bị được đăng ký, trình điều khiển của xe buýt đó sẽ
      đã kiểm tra các trận đấu.  Các thiết bị nền tảng nên được đăng ký rất
      sớm trong quá trình khởi động hệ thống.

- Khi trình điều khiển được đăng ký bằng platform_driver_register(), tất cả
      các thiết bị không liên kết trên xe buýt đó sẽ được kiểm tra xem có trùng khớp không.  Trình điều khiển
      thường đăng ký sau trong khi khởi động hoặc bằng cách tải mô-đun.

- Đăng ký trình điều khiển bằng platform_driver_probe() hoạt động giống như
      sử dụng platform_driver_register(), ngoại trừ việc trình điều khiển sẽ không
      được thăm dò sau nếu thiết bị khác đăng ký.  (Điều đó không sao cả, vì
      giao diện này chỉ để sử dụng với các thiết bị không thể cắm nóng.)


Trình điều khiển và thiết bị nền tảng ban đầu
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Các giao diện nền tảng ban đầu cung cấp dữ liệu nền tảng cho thiết bị nền tảng
trình điều khiển sớm trong quá trình khởi động hệ thống. Mã được xây dựng dựa trên
phân tích dòng lệnh Early_param() và có thể được thực thi từ rất sớm.

Ví dụ: Bảng điều khiển nối tiếp sớm lớp "earlyprintk" trong 6 bước

1. Đăng ký dữ liệu thiết bị nền tảng sớm
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Mã kiến trúc đăng ký dữ liệu thiết bị nền tảng bằng hàm
Early_platform_add_devices(). Trong trường hợp bảng điều khiển nối tiếp đời đầu, điều này
phải là cấu hình phần cứng cho cổng nối tiếp. Thiết bị đã đăng ký
tại thời điểm này sau này sẽ được so sánh với các trình điều khiển nền tảng ban đầu.

2. Phân tích dòng lệnh kernel
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Mã kiến trúc gọi Parse_early_param() để phân tích hạt nhân
dòng lệnh. Điều này sẽ thực thi tất cả các lệnh gọi lại Early_param() phù hợp.
Các thiết bị nền tảng ban đầu do người dùng chỉ định sẽ được đăng ký tại thời điểm này.
Đối với trường hợp bảng điều khiển nối tiếp đời đầu, người dùng có thể chỉ định cổng trên
dòng lệnh kernel là "earlyprintk=serial.0" trong đó "earlyprintk" là
chuỗi lớp, "serial" là tên của trình điều khiển nền tảng và
0 là id thiết bị nền tảng. Nếu id là -1 thì dấu chấm và
id có thể được bỏ qua.

3. Cài đặt trình điều khiển nền tảng sớm thuộc một lớp nhất định
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Mã kiến trúc có thể tùy ý buộc đăng ký tất cả các
trình điều khiển nền tảng thuộc một lớp nhất định bằng cách sử dụng hàm
Early_platform_driver_register_all(). Thiết bị do người dùng chỉ định từ
bước 2 được ưu tiên hơn những điều này. Bước này được bỏ qua bởi chuỗi
ví dụ về trình điều khiển vì mã trình điều khiển nối tiếp ban đầu sẽ bị tắt
trừ khi người dùng đã chỉ định cổng trên dòng lệnh kernel.

4. Đăng ký trình điều khiển nền tảng sớm
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Trình điều khiển nền tảng được biên dịch sử dụng Early_platform_init() là
được đăng ký tự động trong bước 2 hoặc 3. Ví dụ về trình điều khiển nối tiếp
nên sử dụng Early_platform_init("earlyprintk", &platform_driver).

5. Thăm dò các trình điều khiển nền tảng sớm thuộc một lớp nhất định
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Mã kiến trúc gọi Early_platform_driver_probe() để khớp
các thiết bị nền tảng đầu tiên đã đăng ký được liên kết với một lớp nhất định với
trình điều khiển nền tảng đã đăng ký sớm. Các thiết bị phù hợp sẽ được thăm dò().
Bước này có thể được thực hiện bất kỳ lúc nào trong quá trình khởi động sớm. càng sớm càng tốt
càng tốt có thể tốt cho trường hợp cổng nối tiếp.

6. Bên trong đầu dò trình điều khiển nền tảng đầu tiên()
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Mã trình điều khiển cần được chăm sóc đặc biệt trong quá trình khởi động sớm, đặc biệt là
khi nói đến việc cấp phát bộ nhớ và đăng ký ngắt. Mã
trong hàm thăm dò() có thể sử dụng is_early_platform_device() để kiểm tra xem
nó được gọi ở thiết bị nền tảng đầu tiên hoặc ở thiết bị nền tảng thông thường
thời gian. Trình điều khiển nối tiếp đầu tiên thực hiện register_console() tại thời điểm này.

Để biết thêm thông tin, hãy xem <linux/platform_device.h>.
