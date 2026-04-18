.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/i2c/instantiating-devices.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================
Cách khởi tạo thiết bị I2C
=================================

Không giống như các thiết bị PCI hoặc USB, các thiết bị I2C không được liệt kê ở phần cứng
cấp độ. Thay vào đó, phần mềm phải biết thiết bị nào được kết nối trên mỗi thiết bị.
Phân đoạn xe buýt I2C và địa chỉ mà các thiết bị này đang sử dụng. Vì điều này
lý do, mã hạt nhân phải khởi tạo rõ ràng các thiết bị I2C. có
một số cách để đạt được điều này, tùy thuộc vào bối cảnh và yêu cầu.


Cách 1: Khai báo tĩnh các thiết bị I2C
--------------------------------------------

Phương pháp này phù hợp khi bus I2C là bus hệ thống như trường hợp này
cho nhiều hệ thống nhúng. Trên các hệ thống như vậy, mỗi bus I2C có một số
được biết trước. Do đó có thể khai báo trước các thiết bị I2C
sống trên xe buýt này.

Thông tin này được cung cấp cho kernel theo một cách khác trên các
kiến trúc: cây thiết bị, ACPI hoặc các tập tin bảng mạch.

Khi bus I2C được đề cập được đăng ký, các thiết bị I2C sẽ được
được khởi tạo tự động bởi i2c-core. Các thiết bị sẽ được tự động
không bị ràng buộc và bị phá hủy khi xe buýt I2C mà họ ngồi biến mất (nếu có).


Khai báo các thiết bị I2C thông qua devicetree
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Trên các nền tảng sử dụng devicetree, việc khai báo thiết bị I2C được thực hiện trong
các nút con của bộ điều khiển chính.

Ví dụ:

.. code-block:: dts

	i2c1: i2c@400a0000 {
		/* ... master properties skipped ... */
		clock-frequency = <100000>;

		flash@50 {
			compatible = "atmel,24c256";
			reg = <0x50>;
		};

		pca9532: gpio@60 {
			compatible = "nxp,pca9532";
			gpio-controller;
			#gpio-cells = <2>;
			reg = <0x60>;
		};
	};

Ở đây, hai thiết bị được gắn vào bus sử dụng tốc độ 100kHz. cho
các thuộc tính bổ sung có thể cần thiết để thiết lập thiết bị, vui lòng tham khảo
vào tài liệu devicetree của nó trong Documentation/devicetree/binds/.


Khai báo các thiết bị I2C qua ACPI
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

ACPI cũng có thể mô tả các thiết bị I2C. Có tài liệu đặc biệt cho việc này
hiện được đặt tại Documentation/firmware-guide/acpi/enumeration.rst.


Khai báo các thiết bị I2C trong file board
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Trong nhiều kiến trúc nhúng, devicetree đã thay thế phần cứng cũ
mô tả dựa trên các tập tin bảng, nhưng cái sau vẫn được sử dụng trong phiên bản cũ
mã. Việc khởi tạo các thiết bị I2C thông qua các tập tin bảng được thực hiện với một loạt
struct i2c_board_info được đăng ký bằng cách gọi
i2c_register_board_info().

Ví dụ (từ omap2 h4):

.. code-block:: c

  static struct i2c_board_info h4_i2c_board_info[] __initdata = {
	{
		I2C_BOARD_INFO("isp1301_omap", 0x2d),
		.irq		= OMAP_GPIO_IRQ(125),
	},
	{	/* EEPROM on mainboard */
		I2C_BOARD_INFO("24c01", 0x52),
		.platform_data	= &m24c01,
	},
	{	/* EEPROM on cpu card */
		I2C_BOARD_INFO("24c01", 0x57),
		.platform_data	= &m24c01,
	},
  };

  static void __init omap_h4_init(void)
  {
	(...)
	i2c_register_board_info(1, h4_i2c_board_info,
			ARRAY_SIZE(h4_i2c_board_info));
	(...)
  }

Đoạn mã trên khai báo 3 thiết bị trên bus 1 I2C, bao gồm cả các thiết bị tương ứng
địa chỉ và dữ liệu tùy chỉnh cần thiết cho trình điều khiển của họ.


Phương pháp 2: Khởi tạo thiết bị một cách rõ ràng
-------------------------------------------------

Phương pháp này phù hợp khi một thiết bị lớn hơn sử dụng bus I2C cho
giao tiếp nội bộ. Một trường hợp điển hình là bộ điều hợp TV. Những thứ này có thể có một
bộ điều chỉnh, bộ giải mã video, bộ giải mã âm thanh, v.v. thường được kết nối với
chip chính bằng bus I2C. Bạn sẽ không biết số I2C
bus trước nên không thể sử dụng phương pháp 1 được mô tả ở trên. Thay vào đó,
bạn có thể khởi tạo các thiết bị I2C của mình một cách rõ ràng. Điều này được thực hiện bằng cách điền
một cấu trúc i2c_board_info và gọi i2c_new_client_device().

Ví dụ (từ trình điều khiển mạng sfe4001):

.. code-block:: c

  static struct i2c_board_info sfe4001_hwmon_info = {
	I2C_BOARD_INFO("max6647", 0x4e),
  };

  int sfe4001_init(struct efx_nic *efx)
  {
	(...)
	efx->board_info.hwmon_client =
		i2c_new_client_device(&efx->i2c_adap, &sfe4001_hwmon_info);

	(...)
  }

Đoạn mã trên khởi tạo 1 thiết bị I2C trên bus I2C nằm trên
bộ điều hợp mạng được đề cập.

Một biến thể của trường hợp này là khi bạn không biết chắc liệu thiết bị I2C có
có hay không (ví dụ đối với một tính năng tùy chọn không có
trên các biến thể bảng rẻ tiền nhưng bạn không có cách nào để phân biệt chúng), hoặc
nó có thể có các địa chỉ khác nhau từ bảng này sang bảng khác (nhà sản xuất
thay đổi thiết kế của nó mà không cần thông báo trước). Trong trường hợp này, bạn có thể gọi
i2c_new_scanned_device() thay vì i2c_new_client_device().

Ví dụ (từ trình điều khiển nxp OHCI):

.. code-block:: c

  static const unsigned short normal_i2c[] = { 0x2c, 0x2d, I2C_CLIENT_END };

  static int usb_hcd_nxp_probe(struct platform_device *pdev)
  {
	(...)
	struct i2c_adapter *i2c_adap;
	struct i2c_board_info i2c_info;

	(...)
	i2c_adap = i2c_get_adapter(2);
	memset(&i2c_info, 0, sizeof(struct i2c_board_info));
	strscpy(i2c_info.type, "isp1301_nxp", sizeof(i2c_info.type));
	isp1301_i2c_client = i2c_new_scanned_device(i2c_adap, &i2c_info,
						    normal_i2c, NULL);
	i2c_put_adapter(i2c_adap);
	(...)
  }

Đoạn mã trên khởi tạo tối đa 1 thiết bị I2C trên bus I2C đang bật
bộ chuyển đổi OHCI được đề cập. Đầu tiên nó thử ở địa chỉ 0x2c, nếu không có gì
được tìm thấy ở đó, nó sẽ thử địa chỉ 0x2d và nếu vẫn không tìm thấy gì, nó sẽ thử
chỉ đơn giản là từ bỏ.

Trình điều khiển khởi tạo thiết bị I2C chịu trách nhiệm hủy
nó khi dọn dẹp. Điều này được thực hiện bằng cách gọi i2c_unregister_device() trên
con trỏ được trả về trước đó bởi i2c_new_client_device() hoặc
i2c_new_scanned_device().


Phương pháp 3: Thăm dò bus I2C cho một số thiết bị nhất định
------------------------------------------------------------

Đôi khi bạn không có đủ thông tin về thiết bị I2C, thậm chí không
để gọi i2c_new_scanned_device(). Trường hợp điển hình là giám sát phần cứng
chip trên bo mạch chủ PC. Có vài chục mô hình, có thể sống
tại 25 địa chỉ khác nhau. Với số lượng lớn các bo mạch chủ hiện có,
gần như không thể xây dựng được một danh sách đầy đủ các phần cứng
chip giám sát đang được sử dụng. May mắn thay, hầu hết các con chip này đều có
đăng ký ID nhà sản xuất và thiết bị, để chúng có thể được xác định bởi
thăm dò.

Trong trường hợp đó, các thiết bị I2C không được khai báo cũng như không được khởi tạo
một cách rõ ràng. Thay vào đó, i2c-core sẽ thăm dò các thiết bị đó ngay khi chúng
trình điều khiển đã được tải và nếu tìm thấy bất kỳ trình điều khiển nào, thiết bị I2C sẽ được
được khởi tạo tự động. Để ngăn chặn mọi hành vi sai trái này
cơ chế, các hạn chế sau sẽ được áp dụng:

* Trình điều khiển thiết bị I2C phải triển khai phương thức detect(), phương thức này
  xác định một thiết bị được hỗ trợ bằng cách đọc từ các thanh ghi tùy ý.
* Chỉ những xe buýt có khả năng có thiết bị được hỗ trợ và đồng ý
  bị thăm dò, sẽ bị thăm dò. Ví dụ, điều này tránh việc thăm dò phần cứng
  chip giám sát trên bộ chuyển đổi TV.

Ví dụ:
Xem lm90_driver và lm90_ detect() trong driver/hwmon/lm90.c

Các thiết bị I2C được khởi tạo nhờ cuộc thăm dò thành công như vậy sẽ
tự động bị hủy khi trình điều khiển phát hiện chúng bị xóa,
hoặc khi bus I2C cơ bản bị phá hủy, tùy điều kiện nào xảy ra
đầu tiên.

Những ai đã quen thuộc với hệ thống con I2C gồm 2.4 kernel và 2.6 đời đầu
hạt nhân sẽ phát hiện ra rằng phương pháp 3 này về cơ bản tương tự như phương pháp
đã được thực hiện ở đó. Hai điểm khác biệt đáng kể là:

* Hiện tại, việc thăm dò chỉ là một cách để khởi tạo các thiết bị I2C, trong khi đó là
  chỉ còn cách quay lại lúc đó. Nếu có thể, nên ưu tiên phương pháp 1 và 2.
  Phương pháp 3 chỉ nên được sử dụng khi không còn cách nào khác, vì nó có thể có
  tác dụng phụ không mong muốn.
* Xe buýt I2C bây giờ phải nói rõ ràng lớp trình điều khiển I2C nào có thể thăm dò
  chúng (bằng phương tiện của bitfield lớp), trong khi tất cả các bus I2C đều
  được thăm dò theo mặc định vào thời điểm đó. Mặc định là một lớp trống có nghĩa là
  rằng không có sự thăm dò nào xảy ra. Mục đích của lớp bitfield là để hạn chế
  tác dụng phụ không mong muốn nêu trên.

Một lần nữa, nên tránh phương pháp 3 bất cứ khi nào có thể. thiết bị rõ ràng
khởi tạo (phương pháp 1 và 2) được ưa thích hơn nhiều vì nó an toàn hơn và
nhanh hơn.


Phương pháp 4: Khởi tạo từ không gian người dùng
------------------------------------------------

Nói chung, kernel nên biết thiết bị I2C nào được kết nối và
họ sống ở địa chỉ nào. Tuy nhiên, trong một số trường hợp nhất định thì không, vì vậy
Giao diện sysfs đã được thêm vào để cho phép người dùng cung cấp thông tin. Cái này
giao diện được tạo thành từ 2 tệp thuộc tính được tạo trong mỗi bus I2C
thư mục: ZZ0000ZZ và ZZ0001ZZ. Cả hai tập tin đều được ghi
duy nhất và bạn phải viết đúng thông số cho chúng để
khởi tạo, xóa tương ứng, một thiết bị I2C.

Tệp ZZ0000ZZ có 2 tham số: tên của thiết bị I2C (a
chuỗi) và địa chỉ của thiết bị I2C (một số, thường được biểu thị
ở dạng thập lục phân bắt đầu bằng 0x, nhưng cũng có thể được biểu thị bằng số thập phân.)

Tệp ZZ0000ZZ có một tham số duy nhất: địa chỉ của I2C
thiết bị. Vì không có hai thiết bị nào có thể tồn tại ở cùng một địa chỉ trên một I2C nhất định
phân đoạn, địa chỉ đủ để nhận dạng duy nhất thiết bị được
đã xóa.

Ví dụ::

# echo eeprom 0x50 > /sys/bus/i2c/devices/i2c-3/new_device

Mặc dù giao diện này chỉ nên được sử dụng khi khai báo thiết bị trong kernel
không thể thực hiện được, có nhiều trường hợp nó có thể hữu ích:

* Trình điều khiển I2C thường phát hiện các thiết bị (phương pháp 3 ở trên) nhưng bus
  phân đoạn thiết bị của bạn đang hoạt động không có tập bit lớp thích hợp và
  do đó phát hiện không kích hoạt.
* Trình điều khiển I2C thường phát hiện các thiết bị, nhưng thiết bị của bạn hoạt động ở chế độ
  địa chỉ bất ngờ.
* Trình điều khiển I2C thường phát hiện thiết bị, nhưng thiết bị của bạn không được phát hiện,
  hoặc vì quy trình phát hiện quá nghiêm ngặt hoặc vì
  thiết bị chưa được hỗ trợ chính thức nhưng bạn biết nó tương thích.
* Bạn đang phát triển trình điều khiển trên bảng thử nghiệm, nơi bạn đã hàn I2C
  tự mình thiết bị.

Giao diện này thay thế cho các tham số mô-đun Force_* của một số I2C
trình điều khiển thực hiện. Đang được triển khai trong i2c-core chứ không phải trong mỗi
trình điều khiển thiết bị riêng lẻ, nó hiệu quả hơn nhiều và cũng có
ưu điểm là bạn không phải tải lại trình điều khiển để thay đổi cài đặt.
Bạn cũng có thể khởi tạo thiết bị trước khi tải trình điều khiển hoặc thậm chí
có sẵn và bạn không cần biết thiết bị cần trình điều khiển gì.
