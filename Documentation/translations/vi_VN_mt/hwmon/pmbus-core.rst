.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/pmbus-core.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================================
Trình điều khiển lõi PMBus và API bên trong
===========================================

Giới thiệu
============

[từ pmbus.org] Bus quản lý nguồn (PMBus) là một tiêu chuẩn mở
giao thức quản lý năng lượng với ngôn ngữ lệnh được xác định đầy đủ tạo điều kiện thuận lợi
giao tiếp với các bộ chuyển đổi nguồn và các thiết bị khác trong hệ thống điện. các
giao thức được triển khai trên giao diện nối tiếp SMBus tiêu chuẩn công nghiệp và
cho phép lập trình, điều khiển và giám sát thời gian thực về nguồn điện tuân thủ
sản phẩm chuyển đổi. Tiêu chuẩn linh hoạt và có tính linh hoạt cao này cho phép
giao tiếp giữa các thiết bị dựa trên cả công nghệ analog và kỹ thuật số, và
cung cấp khả năng tương tác thực sự sẽ làm giảm độ phức tạp của thiết kế và rút ngắn
thời gian tiếp thị cho các nhà thiết kế hệ thống điện. Tiên phong dẫn đầu về cung cấp điện và
các công ty bán dẫn, tiêu chuẩn hệ thống điện mở này được duy trì và
được thúc đẩy bởi Diễn đàn người triển khai PMBus (PMBus-IF), bao gồm hơn 30 người áp dụng
với mục tiêu cung cấp hỗ trợ và tạo điều kiện thuận lợi cho việc áp dụng giữa những người dùng.

Thật không may, mặc dù các lệnh PMBus được chuẩn hóa nhưng không có lệnh bắt buộc nào
lệnh và nhà sản xuất có thể thêm bao nhiêu lệnh không chuẩn tùy thích.
Ngoài ra, các thiết bị PMBU khác nhau sẽ hoạt động khác nhau nếu có các lệnh không được hỗ trợ.
bị xử tử. Một số thiết bị trả về lỗi, một số thiết bị trả về 0xff hoặc 0xffff và
đặt cờ lỗi trạng thái và một số thiết bị có thể bị treo.

Bất chấp tất cả những khó khăn đó, trình điều khiển thiết bị PMBus chung vẫn hữu ích
và được hỗ trợ kể từ phiên bản kernel 2.6.39. Tuy nhiên cần phải hỗ trợ
các phần mở rộng dành riêng cho thiết bị ngoài trình điều khiển PMBus cốt lõi, vì nó
đơn giản là không biết chức năng cụ thể của thiết bị mới Các nhà phát triển thiết bị PMBus
nghĩ ra tiếp theo.

Để tạo các tiện ích mở rộng dành riêng cho thiết bị có khả năng mở rộng tối đa có thể và để tránh gặp phải
để sửa đổi trình điều khiển PMBus lõi nhiều lần cho các thiết bị mới, trình điều khiển PMBus được
chia thành mã lõi, mã chung và mã cụ thể của thiết bị. Mã lõi (trong
pmbus_core.c) cung cấp chức năng chung. Mã chung (trong pmbus.c)
cung cấp hỗ trợ cho các thiết bị PMBus chung. Mã cụ thể của thiết bị chịu trách nhiệm
để khởi tạo cụ thể cho thiết bị và, nếu cần, lập bản đồ cụ thể cho thiết bị
chức năng thành chức năng chung. Điều này ở một mức độ nào đó có thể so sánh được
sang mã PCI, trong đó mã chung được tăng cường khi cần với các đặc điểm riêng cho tất cả các loại
của các thiết bị.

Khả năng tự động phát hiện của thiết bị PMBus
=============================================

Đối với các thiết bị PMBus chung, mã trong pmbus.c sẽ cố gắng tự động phát hiện tất cả các thiết bị được hỗ trợ
Lệnh PMBus. Tính năng tự động phát hiện có phần hạn chế vì đơn giản là có quá
nhiều biến để xem xét. Ví dụ, gần như không thể tự động phát hiện
lệnh PMBus nào được phân trang và lệnh nào được sao chép trên tất cả
các trang (xem đặc tả PMBus để biết chi tiết về các thiết bị PMBus nhiều trang).

Vì lý do này, việc cung cấp trình điều khiển cụ thể cho thiết bị thường là hợp lý nếu không.
tất cả các lệnh có thể được tự động phát hiện. Cấu trúc dữ liệu trong trình điều khiển này có thể
được sử dụng để thông báo cho trình điều khiển cốt lõi về chức năng được hỗ trợ bởi từng cá nhân
chip.

Một số lệnh luôn được tự động phát hiện. Điều này áp dụng cho tất cả các lệnh giới hạn
(thuộc tính lcrit, min, max và crit) cũng như các thuộc tính cảnh báo liên quan.
Các giới hạn và thuộc tính cảnh báo được tự động phát hiện vì đơn giản là có quá nhiều
các kết hợp có thể có để cung cấp giao diện cấu hình thủ công.

PMBus nội bộ API
==================

API giữa mã PMBus lõi và thiết bị cụ thể được xác định trong
trình điều khiển/hwmon/pmbus/pmbus.h. Ngoài API nội bộ, pmbus.h còn định nghĩa
lệnh PMBus tiêu chuẩn và lệnh PMBus ảo.

Các lệnh PMBus tiêu chuẩn
-------------------------

Các lệnh PMBUs tiêu chuẩn (giá trị lệnh 0x00 đến 0xff) được xác định trong PMBU
đặc điểm kỹ thuật.

Các lệnh PMBus ảo
----------------------

Các lệnh PMBus ảo được cung cấp để cho phép hỗ trợ cho các hệ thống không chuẩn
chức năng đã được triển khai bởi một số nhà cung cấp chip và do đó
mong muốn được hỗ trợ.

Các lệnh PMBus ảo bắt đầu bằng giá trị lệnh 0x100 và do đó có thể dễ dàng được thực hiện
phân biệt với các lệnh PMBus tiêu chuẩn (không thể có giá trị lớn hơn
hơn 0xff). Hỗ trợ các lệnh PMBus ảo tùy theo thiết bị cụ thể và do đó có
được thực hiện trong mã cụ thể của thiết bị.

Các lệnh ảo được đặt tên là PMBUS_VIRT_xxx và bắt đầu bằng PMBUS_VIRT_BASE. Tất cả
lệnh ảo có kích thước từ.

Hiện tại có hai loại lệnh ảo.

- Các lệnh READ ở dạng chỉ đọc; việc ghi bị bỏ qua hoặc trả về lỗi.
- Lệnh RESET đọc/ghi. Đọc các thanh ghi thiết lập lại trả về 0
  (được sử dụng để phát hiện), việc ghi bất kỳ giá trị nào sẽ khiến lịch sử liên quan bị
  đặt lại.

Các lệnh ảo phải được xử lý trong mã trình điều khiển cụ thể của thiết bị. Trình điều khiển chip
mã trả về các giá trị không âm nếu lệnh ảo được hỗ trợ hoặc
mã lỗi tiêu cực nếu không. Trình điều khiển chip có thể trả về -ENODATA hoặc bất kỳ trình điều khiển nào khác
Mã lỗi Linux trong trường hợp này, mặc dù mã lỗi khác -ENODATA là
xử lý hiệu quả hơn và do đó được ưa thích. Dù thế nào đi nữa, PMBus đang gọi
mã lõi sẽ hủy nếu trình điều khiển chip trả về mã lỗi khi đọc
hoặc ghi các thanh ghi ảo (nói cách khác, mã lõi PMBus sẽ không bao giờ
gửi lệnh ảo đến chip).

Thông tin trình điều khiển PMBus
--------------------------------

Thông tin trình điều khiển PMBus, được xác định trong struct pmbus_driver_info, là phương tiện chính
để trình điều khiển dành riêng cho thiết bị truyền thông tin đến trình điều khiển PMBus cốt lõi.
Cụ thể, nó cung cấp các thông tin sau.

- Đối với các thiết bị hỗ trợ dữ liệu của nó ở Định dạng dữ liệu trực tiếp, nó cung cấp các hệ số
  để chuyển đổi các giá trị đăng ký thành dữ liệu chuẩn hóa. Dữ liệu này thường
  được cung cấp bởi các nhà sản xuất chip trong bảng dữ liệu thiết bị.
- Chức năng chip được hỗ trợ có thể được cung cấp cho trình điều khiển lõi. Đây có thể là
  cần thiết cho các chip phản ứng xấu nếu các lệnh không được hỗ trợ được thực thi,
  và/hoặc để tăng tốc độ phát hiện và khởi tạo thiết bị.
- Một số điểm vào chức năng được cung cấp để hỗ trợ ghi đè và/hoặc
  tăng cường thực hiện lệnh chung. Chức năng này có thể được sử dụng để lập bản đồ
  các lệnh PMBus không chuẩn thành các lệnh tiêu chuẩn hoặc để tăng cường tiêu chuẩn
  lệnh trả về giá trị với thông tin cụ thể của thiết bị.

Hỗ trợ PEC
===========

Nhiều thiết bị PMBus hỗ trợ SMBus PEC (Kiểm tra lỗi gói). Nếu được hỗ trợ
bởi cả bộ chuyển đổi I2C và chip PMBus, nó được bật theo mặc định.
Nếu PEC được hỗ trợ, trình điều khiển lõi PMBus sẽ thêm thuộc tính có tên 'pec' vào
thiết bị I2C. Thuộc tính này có thể được sử dụng để kiểm soát sự hỗ trợ của PEC trong
giao tiếp với chip PMBus.

Chức năng API
=============

Chức năng được cung cấp bởi trình điều khiển chip
-------------------------------------------------

Tất cả các hàm trả về giá trị trả về của lệnh (đọc) hoặc 0 (ghi) nếu
thành công. Giá trị trả về -ENODATA cho biết không có nhà sản xuất
lệnh cụ thể, nhưng lệnh PMBus tiêu chuẩn có thể tồn tại. Bất kỳ cái nào khác
giá trị trả về âm cho biết rằng các lệnh không tồn tại cho việc này
chip và không nên cố gắng đọc hoặc ghi tiêu chuẩn
lệnh.

Như đã đề cập ở trên, một ngoại lệ cho quy tắc này áp dụng cho các lệnh ảo,
ZZ0000ZZ nào được xử lý trong mã trình điều khiển cụ thể. Xem "Các lệnh PMBus ảo"
ở trên để biết thêm chi tiết.

Việc thực thi lệnh trong mã trình điều khiển PMBus lõi như sau::

nếu (chip_access_function) {
		trạng thái = chip_access_function();
		nếu (trạng thái != -ENODATA)
			trạng thái trả lại;
	}
	if (lệnh >= PMBUS_VIRT_BASE) /* Chỉ dành cho lệnh word/đăng ký */
		trả về -EINVAL;
	trả về generic_access();

Trình điều khiển chip có thể cung cấp con trỏ tới các hàm sau trong struct
pmbus_driver_info. Tất cả các chức năng là tùy chọn.

::

int (*read_byte_data)(struct i2c_client *client, trang int, int reg);

Đọc byte từ trang <trang>, đăng ký <reg>.
<trang> có thể là -1, nghĩa là "trang hiện tại".


::

int (*read_word_data)(struct i2c_client *client, trang int, pha int,
                        int reg);

Đọc từ từ trang <trang>, giai đoạn <phase>, đăng ký <reg>. Nếu chip không
hỗ trợ nhiều pha, tham số pha có thể bị bỏ qua. Nếu con chip
hỗ trợ nhiều pha, giá trị pha 0xff biểu thị tất cả các pha.

::

int (*write_word_data)(struct i2c_client *client, trang int, int reg,
			 từ u16);

Viết word vào trang <page>, đăng ký <reg>.

::

int (*write_byte)(struct i2c_client *client, trang int, giá trị u8);

Ghi byte vào trang <page>, đăng ký <reg>.
<trang> có thể là -1, nghĩa là "trang hiện tại".

::

int (*identify)(struct i2c_client *client, struct pmbus_driver_info *thông tin);

Xác định chức năng PMBus được hỗ trợ. Chức năng này chỉ cần thiết
nếu trình điều khiển chip hỗ trợ nhiều chip và chức năng của chip không
được xác định trước. Nó hiện chỉ được sử dụng bởi trình điều khiển pmbus chung
(pmbus.c).

Các chức năng được xuất bởi trình điều khiển lõi
------------------------------------------------

Trình điều khiển chip dự kiến sẽ sử dụng các chức năng sau để đọc hoặc ghi
Đăng ký PMBus. Trình điều khiển chip cũng có thể sử dụng lệnh I2C trực tiếp. Nếu trực tiếp I2C
lệnh được sử dụng, mã trình điều khiển chip không được sửa đổi trực tiếp hiện tại
trang, vì trang đã chọn được lưu vào bộ nhớ đệm trong trình điều khiển lõi và trình điều khiển lõi
sẽ cho rằng nó đã được chọn. Sử dụng pmbus_set_page() để chọn trang mới
là bắt buộc.

::

int pmbus_set_page(struct i2c_client *client, trang u8, giai đoạn u8);

Đặt thanh ghi trang PMBus thành <page> và <phase> cho các lệnh tiếp theo.
Nếu chip không hỗ trợ nhiều pha, tham số pha là
bị phớt lờ. Ngược lại, giá trị pha 0xff sẽ chọn tất cả các pha.

::

int pmbus_read_word_data(struct i2c_client *client, trang u8, giai đoạn u8,
                           đăng ký u8);

Đọc dữ liệu word từ <page>, <phase>, <reg>. Tương tự như
i2c_smbus_read_word_data(), nhưng chọn trang và giai đoạn trước. Nếu con chip làm như vậy
không hỗ trợ nhiều pha, tham số pha sẽ bị bỏ qua. Ngược lại, một giai đoạn
giá trị 0xff chọn tất cả các giai đoạn.

::

int pmbus_write_word_data(struct i2c_client *client, trang u8, u8 reg,
			    từ u16);

Ghi dữ liệu word vào <page>, <reg>. Tương tự như i2c_smbus_write_word_data(), nhưng
chọn trang đầu tiên.

::

int pmbus_read_byte_data(struct i2c_client *client, trang int, u8 reg);

Đọc dữ liệu byte từ <page>, <reg>. Tương tự như i2c_smbus_read_byte_data(), nhưng
chọn trang đầu tiên. <trang> có thể là -1, nghĩa là "trang hiện tại".

::

int pmbus_write_byte(struct i2c_client *client, trang int, giá trị u8);

Ghi dữ liệu byte vào <page>, <reg>. Tương tự như i2c_smbus_write_byte(), nhưng
chọn trang đầu tiên. <trang> có thể là -1, nghĩa là "trang hiện tại".

::

void pmbus_clear_faults(struct i2c_client *client);

Thực thi lệnh "Xóa lỗi" PMBus trên tất cả các trang chip.
Hàm này gọi hàm write_byte cụ thể của thiết bị nếu được xác định.
Vì vậy, nó phải _not_ được gọi từ hàm đó.

::

bool pmbus_check_byte_register(struct i2c_client *client, int page, int reg);

Kiểm tra xem thanh ghi byte có tồn tại không. Trả về true nếu thanh ghi tồn tại, false
mặt khác.
Hàm này gọi hàm write_byte dành riêng cho thiết bị nếu được xác định là
có được trạng thái chip. Vì vậy, nó phải _not_ được gọi từ hàm đó.

::

bool pmbus_check_word_register(struct i2c_client *client, int page, int reg);

Kiểm tra xem thanh ghi từ có tồn tại không. Trả về true nếu thanh ghi tồn tại, false
mặt khác.
Hàm này gọi hàm write_byte dành riêng cho thiết bị nếu được xác định là
có được trạng thái chip. Vì vậy, nó phải _not_ được gọi từ hàm đó.

::

int pmbus_do_probe(struct i2c_client *client, struct pmbus_driver_info *info);

Thực hiện chức năng thăm dò. Tương tự như chức năng thăm dò tiêu chuẩn cho các trình điều khiển khác,
với con trỏ tới struct pmbus_driver_info làm đối số bổ sung. Cuộc gọi
xác định chức năng nếu được hỗ trợ. Chỉ được gọi từ đầu dò thiết bị
chức năng.

::

const cấu trúc pmbus_driver_info
	*pmbus_get_driver_info(struct i2c_client *client);

Trả về con trỏ tới struct pmbus_driver_info khi được chuyển tới pmbus_do_probe().


Dữ liệu nền tảng trình điều khiển PMBus
=======================================

Dữ liệu nền tảng PMBus được xác định trong include/linux/pmbus.h. Dữ liệu nền tảng
hiện cung cấp trường cờ với bốn bit được sử dụng ::

#define PMBUS_SKIP_STATUS_CHECK BIT(0)

#define PMBUS_WRITE_PROTECTED BIT(1)

#define PMBUS_NO_CAPABILITY BIT(2)

#define PMBUS_READ_STATUS_AFTER_FAILED_CHECK BIT(3)

#define PMBUS_NO_WRITE_PROTECT BIT(4)

#define PMBUS_USE_COEFFICIENTS_CMD BIT(5)

#define PMBUS_OP_PROTECTED BIT(6)

#define PMBUS_VOUT_PROTECTED BIT(7)

cấu trúc pmbus_platform_data {
		cờ u32;              /* Cờ cụ thể của thiết bị */

/*hỗ trợ bộ điều chỉnh */
		int num_regulators;
		cấu trúc điều chỉnh_init_data *reg_init_data;
	};


Cờ
-----

PMBUS_SKIP_STATUS_CHECK

Trong quá trình phát hiện đăng ký, bỏ qua việc kiểm tra thanh ghi trạng thái cho
lỗi giao tiếp hoặc lệnh.

Một số chip PMBus phản hồi với dữ liệu hợp lệ khi cố đọc một dữ liệu không được hỗ trợ
đăng ký. Đối với những chip như vậy, việc kiểm tra thanh ghi trạng thái là bắt buộc khi
cố gắng xác định xem một thanh ghi chip có tồn tại hay không.
Các chip PMBus khác không hỗ trợ đăng ký STATUS_CML hoặc báo cáo
lỗi giao tiếp không có lý do giải thích được. Đối với những con chip như vậy, việc kiểm tra
thanh ghi trạng thái phải bị vô hiệu hóa.

Một số bộ điều khiển i2c không hỗ trợ các lệnh một byte (ghi lệnh bằng
không có dữ liệu, i2c_smbus_write_byte()). Với bộ điều khiển như vậy, việc xóa trạng thái
không thể đăng ký và phải đặt cờ PMBUS_SKIP_STATUS_CHECK.

PMBUS_WRITE_PROTECTED

Đặt nếu chip được bảo vệ ghi và không xác định được bảo vệ ghi
bằng lệnh WRITE_PROTECT tiêu chuẩn.

PMBUS_NO_CAPABILITY

Một số chip PMBus không phản hồi với dữ liệu hợp lệ khi đọc CAPABILITY
đăng ký. Đối với những chip như vậy, cờ này phải được đặt sao cho lõi PMBus
trình điều khiển không sử dụng CAPABILITY để xác định hành vi của nó.

PMBUS_READ_STATUS_AFTER_FAILED_CHECK

Đọc thanh ghi STATUS sau mỗi lần kiểm tra thanh ghi không thành công.

Một số chip PMBus kết thúc ở trạng thái không xác định khi cố đọc một
đăng ký không được hỗ trợ. Đối với những con chip như vậy, cần phải thiết lập lại
bộ điều khiển chip pmbus về trạng thái đã biết sau khi kiểm tra đăng ký không thành công.
Điều này có thể được thực hiện bằng cách đọc một sổ đăng ký đã biết. Bằng cách đặt cờ này
trình điều khiển sẽ cố đọc thanh ghi STATUS sau mỗi lần thất bại
đăng ký kiểm tra. Việc đọc này có thể thất bại nhưng nó sẽ đưa chip vào trạng thái
trạng thái đã biết.

PMBUS_NO_WRITE_PROTECT

Một số chip PMBus phản hồi với dữ liệu không hợp lệ khi đọc WRITE_PROTECT
đăng ký. Đối với những chip như vậy, cờ này phải được đặt sao cho lõi PMBus
trình điều khiển không sử dụng lệnh WRITE_PROTECT để xác định hành vi của nó.

PMBUS_USE_COEFFICIENTS_CMD

Khi cờ này được đặt, trình điều khiển lõi PMBus sẽ sử dụng COEFFICIENTS
đăng ký để khởi tạo các hệ số cho định dạng chế độ trực tiếp.

PMBUS_OP_PROTECTED

Đặt nếu lệnh chip OPERATION được bảo vệ và bảo vệ không
được xác định bằng lệnh WRITE_PROTECT tiêu chuẩn.

PMBUS_VOUT_PROTECTED

Đặt nếu lệnh chip VOUT_COMMAND được bảo vệ và bảo vệ không
được xác định bằng lệnh WRITE_PROTECT tiêu chuẩn.

Tham số mô-đun
----------------

pmbus_core.wp: Chế độ bắt buộc bảo vệ ghi PMBus

PMBus có thể đưa ra nhiều cấu hình bảo vệ ghi khác nhau.
'pmbus_core.wp' có thể được sử dụng nếu cần có biện pháp bảo vệ ghi cụ thể.
Khả năng thực sự thay đổi khả năng bảo vệ cũng có thể phụ thuộc vào con chip
vì vậy cấu hình bảo vệ ghi thời gian chạy thực tế có thể khác với
cái được yêu cầu. pmbus_core hiện hỗ trợ giá trị sau:

* 0: loại bỏ bảo vệ ghi.
* 1: Vô hiệu hóa tất cả việc ghi ngoại trừ WRITE_PROTECT, OPERATION,
  Các lệnh PAGE, ON_OFF_CONFIG và VOUT_COMMAND.
* 2: Vô hiệu hóa tất cả việc ghi ngoại trừ WRITE_PROTECT, OPERATION và
  Các lệnh PAGE.
* 3: Vô hiệu hóa tất cả việc ghi ngoại trừ lệnh WRITE_PROTECT. Lưu ý rằng
  bảo vệ nên bao gồm thanh ghi PAGE. Điều này có thể có vấn đề
  đối với các chip nhiều trang, nếu các chip tuân thủ nghiêm ngặt PMBus
  đặc điểm kỹ thuật, ngăn chặn chip thay đổi trang hoạt động.
