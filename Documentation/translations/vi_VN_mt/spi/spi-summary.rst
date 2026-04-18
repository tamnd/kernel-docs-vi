.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/spi/spi-summary.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
Tổng quan về hỗ trợ nhân Linux SPI
====================================

02-02-2012

SPI là gì?
------------
"Giao diện ngoại vi nối tiếp" (SPI) là giao diện nối tiếp bốn dây đồng bộ
liên kết được sử dụng để kết nối bộ vi điều khiển với cảm biến, bộ nhớ và thiết bị ngoại vi.
Đó là một tiêu chuẩn "thực tế" đơn giản, không đủ phức tạp để có được một
cơ quan tiêu chuẩn hóa  SPI sử dụng cấu hình máy chủ/đích.

Ba dây tín hiệu chứa đồng hồ (SCK, thường ở mức 10 MHz),
và các đường dữ liệu song song với "Master Out, Slave In" (MOSI) hoặc "Master In,
Tín hiệu Slave Out" (MISO).  (Các tên khác cũng được sử dụng.) Có bốn
chế độ xung nhịp mà qua đó dữ liệu được trao đổi; chế độ-0 và chế độ-3 là nhiều nhất
thường được sử dụng.  Mỗi chu kỳ đồng hồ sẽ chuyển dữ liệu ra và dữ liệu vào; đồng hồ
không quay vòng trừ khi có một bit dữ liệu cần dịch chuyển.  Không phải tất cả các bit dữ liệu
mặc dù được sử dụng; không phải mọi giao thức đều sử dụng các khả năng song công hoàn toàn đó.

Máy chủ SPI sử dụng dòng "chọn chip" thứ tư để kích hoạt mục tiêu SPI nhất định
thiết bị, do đó ba dây tín hiệu đó có thể được kết nối với một số chip
song song.  Tất cả các mục tiêu SPI đều hỗ trợ lựa chọn chip; họ thường hoạt động
tín hiệu thấp, được gắn nhãn nCSx cho mục tiêu 'x' (ví dụ: nCS0).  Một số thiết bị có
các tín hiệu khác, thường bao gồm cả ngắt tới máy chủ.

Không giống như các bus nối tiếp như USB hoặc SMBus, ngay cả các giao thức cấp thấp cho
Các chức năng mục tiêu SPI thường không tương thích được giữa các nhà cung cấp
(trừ các mặt hàng như chip nhớ SPI).

- SPI có thể được sử dụng cho các giao thức thiết bị kiểu yêu cầu/phản hồi, như với
    cảm biến màn hình cảm ứng và chip bộ nhớ.

- Nó cũng có thể được sử dụng để truyền dữ liệu theo một trong hai hướng (bán song công),
    hoặc cả hai cùng một lúc (song công hoàn toàn).

- Một số thiết bị có thể sử dụng từ 8 bit.  Những người khác có thể sử dụng từ khác
    độ dài, chẳng hạn như luồng mẫu kỹ thuật số 12 bit hoặc 20 bit.

- Các từ thường được gửi với bit có ý nghĩa nhất (MSB) trước tiên,
    nhưng đôi khi bit ít quan trọng nhất (LSB) lại được đặt trước.

- Đôi khi SPI được sử dụng cho các thiết bị chuỗi nối tiếp, như thanh ghi thay đổi.

Theo cách tương tự, các mục tiêu SPI sẽ hiếm khi hỗ trợ bất kỳ loại tự động nào
giao thức khám phá/liệt kê. Cây thiết bị mục tiêu có thể truy cập từ
bộ điều khiển máy chủ SPI nhất định thường sẽ được thiết lập thủ công, với
các bảng cấu hình.

SPI chỉ là một trong những cái tên được sử dụng bởi các giao thức bốn dây như vậy và
hầu hết các bộ điều khiển đều không gặp vấn đề gì khi xử lý "MicroWire" (hãy coi nó như
bán song công SPI, dành cho các giao thức yêu cầu/phản hồi), SSP ("Đồng bộ
Giao thức nối tiếp"), PSP ("Giao thức nối tiếp có thể lập trình") và các giao thức khác
các giao thức liên quan.

Một số chip loại bỏ đường tín hiệu bằng cách kết hợp MOSI và MISO, và
tự giới hạn ở chế độ bán song công ở cấp độ phần cứng.  Trên thực tế
một số chip SPI có chế độ tín hiệu này như một tùy chọn buộc dây.  Những cái này
có thể được truy cập bằng giao diện lập trình giống như SPI, nhưng
tất nhiên họ sẽ không xử lý việc chuyển giao song công hoàn toàn.  Bạn có thể tìm thấy như vậy
các chip được mô tả là sử dụng tín hiệu "ba dây": SCK, data, nCSx.
(Dòng dữ liệu đó đôi khi được gọi là MOMI hoặc SISO.)

Bộ vi điều khiển thường hỗ trợ cả phía chủ và phía đích của SPI
giao thức.  Tài liệu này (và Linux) hỗ trợ cả máy chủ và máy đích
các mặt của tương tác SPI.


Ai sử dụng nó?  Trên những loại hệ thống?
---------------------------------------
Các nhà phát triển Linux sử dụng SPI có thể đang viết trình điều khiển thiết bị cho các ứng dụng nhúng
các bảng hệ thống.  SPI được sử dụng để điều khiển các chip bên ngoài và nó cũng là một
giao thức được hỗ trợ bởi mọi thẻ nhớ MMC hoặc SD.  ("DataFlash" cũ hơn
thẻ, có trước thẻ MMC nhưng sử dụng cùng đầu nối và hình dạng thẻ,
chỉ hỗ trợ SPI.) Một số phần cứng PC sử dụng đèn flash SPI cho mã BIOS.

Các chip mục tiêu SPI bao gồm các bộ chuyển đổi kỹ thuật số/analog được sử dụng cho analog
cảm biến và codec, bộ nhớ, đến các thiết bị ngoại vi như bộ điều khiển USB
hoặc bộ điều hợp Ethernet; và hơn thế nữa.

Hầu hết các hệ thống sử dụng SPI sẽ tích hợp một vài thiết bị trên bo mạch chính.
Một số cung cấp liên kết SPI trên đầu nối mở rộng; trong những trường hợp không
Bộ điều khiển SPI chuyên dụng tồn tại, các chân GPIO có thể được sử dụng để tạo
bộ chuyển đổi "bitbanging" tốc độ thấp.  Rất ít hệ thống sẽ "cắm nóng" SPI
bộ điều khiển; lý do nên sử dụng SPI tập trung vào chi phí thấp và vận hành đơn giản,
và nếu việc cấu hình lại động là quan trọng, USB thường sẽ phù hợp hơn
bus ngoại vi có số pin thấp thích hợp.

Nhiều bộ vi điều khiển có thể chạy Linux tích hợp một hoặc nhiều I/O
giao diện với các chế độ SPI.  Với sự hỗ trợ của SPI, họ có thể sử dụng MMC hoặc SD
thẻ mà không cần bộ điều khiển MMC/SD/SDIO cho mục đích đặc biệt.


Tôi đang bối rối.  Bốn "chế độ đồng hồ" SPI này là gì?
-----------------------------------------------------
Ở đây rất dễ bị nhầm lẫn và tài liệu của nhà cung cấp bạn sẽ
find không nhất thiết phải hữu ích.  Bốn chế độ kết hợp hai bit chế độ:

- CPOL biểu thị cực tính đồng hồ ban đầu.  CPOL=0 có nghĩa là
   đồng hồ bắt đầu ở mức thấp, do đó cạnh đầu tiên (dẫn đầu) tăng lên và
   cạnh thứ hai (cuối) đang rơi xuống.  CPOL=1 có nghĩa là đồng hồ
   bắt đầu ở mức cao, do đó cạnh đầu tiên (dẫn đầu) sẽ giảm xuống.

- CPHA cho biết pha xung nhịp được sử dụng để lấy mẫu dữ liệu; CPHA=0 nói
   mẫu ở cạnh đầu, CPHA=1 có nghĩa là cạnh sau.

Vì tín hiệu cần ổn định trước khi được lấy mẫu nên CPHA=0
   ngụ ý rằng dữ liệu của nó được ghi nửa đồng hồ trước thời điểm đầu tiên
   cạnh đồng hồ.  Chipselect có thể đã làm cho nó có sẵn.

Thông số kỹ thuật của chip không phải lúc nào cũng nói "sử dụng SPI chế độ X" bằng nhiều từ,
nhưng sơ đồ thời gian của chúng sẽ làm cho chế độ CPOL và CPHA trở nên rõ ràng.

Trong số chế độ SPI, CPOL là bit bậc cao và CPHA là bit
bit bậc thấp.  Vì vậy, khi biểu đồ thời gian của chip hiển thị đồng hồ
bắt đầu ở mức thấp (CPOL=0) và dữ liệu được ổn định để lấy mẫu trong quá trình
cạnh đồng hồ sau (CPHA=1), đó là chế độ SPI 1.

Lưu ý rằng chế độ đồng hồ có liên quan ngay khi chipselect hoạt động
hoạt động.  Vì vậy chủ nhà phải đặt đồng hồ ở chế độ không hoạt động trước khi chọn
một mục tiêu và mục tiêu có thể cho biết cực đã chọn bằng cách lấy mẫu
mức đồng hồ khi dòng chọn của nó hoạt động.  Đó là lý do tại sao nhiều thiết bị
hỗ trợ ví dụ cả hai chế độ 0 và 3: chúng không quan tâm đến cực tính,
và luôn đồng hồ vào/ra dữ liệu trên các cạnh đồng hồ tăng.


Các giao diện lập trình trình điều khiển này hoạt động như thế nào?
------------------------------------------------
Tệp tiêu đề <linux/spi/spi.h> bao gồm kerneldoc, cũng như
mã nguồn chính, và bạn chắc chắn nên đọc chương đó của
tài liệu hạt nhân API.  Đây chỉ là một cái nhìn tổng quan, vì vậy bạn sẽ có được cái nhìn tổng quát
hình ảnh trước những chi tiết đó.

Các yêu cầu SPI luôn được đưa vào hàng đợi I/O.  Yêu cầu đối với một thiết bị SPI nhất định
luôn được thực thi theo thứ tự FIFO và hoàn thành không đồng bộ thông qua
cuộc gọi lại hoàn thành.  Ngoài ra còn có một số trình bao bọc đồng bộ đơn giản
cho những cuộc gọi đó, bao gồm cả những cuộc gọi dành cho các loại giao dịch phổ biến như viết thư
một lệnh và sau đó đọc phản hồi của nó.

Có hai loại trình điều khiển SPI, ở đây được gọi là:

Trình điều khiển...
        bộ điều khiển có thể được tích hợp vào System-On-Chip
	bộ xử lý và thường hỗ trợ cả vai trò Người điều khiển và mục tiêu.
	Các trình điều khiển này chạm vào các thanh ghi phần cứng và có thể sử dụng DMA.
	Hoặc chúng có thể là bitbanger PIO, chỉ cần các chân GPIO.

Trình điều khiển giao thức ...
        những tin nhắn này chuyển qua bộ điều khiển
	trình điều khiển để giao tiếp với thiết bị mục tiêu hoặc Bộ điều khiển trên
	phía bên kia của liên kết SPI.

Vì vậy, ví dụ một trình điều khiển giao thức có thể giao tiếp với lớp MTD để xuất
dữ liệu vào hệ thống tập tin được lưu trữ trên flash SPI như DataFlash; và những người khác có thể
điều khiển giao diện âm thanh, hiển thị cảm biến màn hình cảm ứng làm giao diện đầu vào,
hoặc theo dõi mức nhiệt độ và điện áp trong quá trình xử lý công nghiệp.
Và tất cả những thứ đó có thể đang chia sẻ cùng một trình điều khiển bộ điều khiển.

Một "struct spi_device" đóng gói giao diện phía bộ điều khiển giữa
hai loại trình điều khiển đó.

Có một lõi tối thiểu của giao diện lập trình SPI, tập trung vào
sử dụng mô hình trình điều khiển để kết nối trình điều khiển bộ điều khiển và giao thức bằng cách sử dụng
bảng thiết bị được cung cấp bởi mã khởi tạo cụ thể của bảng.  SPI
hiển thị trong sysfs ở một số vị trí ::

/sys/devices/.../CTLR ... nút vật lý cho bộ điều khiển SPI nhất định

/sys/devices/.../CTLR/spiB.C ... spi_device trên xe buýt "B",
	chipselect C, được truy cập thông qua CTLR.

/sys/bus/spi/devices/spiB.C ... liên kết tượng trưng đến vật lý đó
	.../CTLR/spiB.C device

   /sys/devices/.../CTLR/spiB.C/modalias ... identifies the driver
nên được sử dụng với thiết bị này (đối với phích cắm nóng/coldplug)

/sys/bus/spi/drivers/D ... trình điều khiển cho một hoặc nhiều thiết bị spi*.*

/sys/class/spi_master/spiB ... liên kết tượng trưng đến một nút logic có thể chứa
	trạng thái liên quan đến lớp cho bộ điều khiển máy chủ SPI quản lý bus "B".
	Tất cả các thiết bị spiB.* đều dùng chung một đoạn bus SPI vật lý, với SCLK,
	MOSI và MISO.

/sys/devices/.../CTLR/slave ... tệp ảo để (hủy) đăng ký
	thiết bị mục tiêu cho bộ điều khiển mục tiêu SPI.
	Viết tên trình điều khiển của trình xử lý mục tiêu SPI vào tệp này
	đăng ký thiết bị mục tiêu; viết "(null)" hủy đăng ký mục tiêu
	thiết bị.
	Đọc từ tệp này sẽ hiển thị tên của thiết bị đích ("(null)"
	nếu chưa đăng ký).

/sys/class/spi_slave/spiB ... liên kết tượng trưng đến một nút logic có thể chứa
	trạng thái liên quan đến lớp cho bộ điều khiển mục tiêu SPI trên bus "B".  Khi nào
	đã đăng ký, một thiết bị spiB.* duy nhất hiện diện ở đây, có thể chia sẻ
	đoạn bus SPI vật lý với các thiết bị mục tiêu SPI khác.

Tại thời điểm này, trạng thái cụ thể của lớp duy nhất là số xe buýt ("B" trong "spiB"),
vì vậy các mục /sys/class đó chỉ hữu ích để nhanh chóng xác định các bus.


Mã init dành riêng cho bảng khai báo các thiết bị SPI như thế nào?
------------------------------------------------------
Linux cần một số loại thông tin để cấu hình đúng các thiết bị SPI.
Thông tin đó thường được cung cấp bởi mã dành riêng cho từng bảng, ngay cả đối với
các chip hỗ trợ một số tính năng khám phá/liệt kê tự động.

Khai báo bộ điều khiển
^^^^^^^^^^^^^^^^^^^

Loại thông tin đầu tiên là danh sách những bộ điều khiển SPI tồn tại.
Đối với các bo mạch dựa trên System-on-Chip (SOC), đây thường là nền tảng
thiết bị và bộ điều khiển có thể cần một số platform_data để
hoạt động đúng cách.  "struct platform_device" sẽ bao gồm các tài nguyên
giống như địa chỉ vật lý của thanh ghi đầu tiên của bộ điều khiển và IRQ của nó.

Các nền tảng thường sẽ trừu tượng hóa hoạt động "đăng ký bộ điều khiển SPI",
có thể ghép nó với mã để khởi tạo cấu hình chân, để
các tệp Arch/.../mach-ZZ0000ZZ.c cho một số bảng đều có thể chia sẻ
cùng mã thiết lập bộ điều khiển cơ bản.  Điều này là do hầu hết các SOC đều có một số
Bộ điều khiển có khả năng SPI và chỉ những bộ điều khiển thực sự có thể sử dụng được trên một thiết bị nhất định
hội đồng quản trị thường phải được thành lập và đăng ký.

Vì vậy, ví dụ: tệp Arch/.../mach-ZZ0000ZZ.c có thể có mã như::

#include <mach/spi.h> /* cho mysoc_spi_data */

/* nếu cơ sở hạ tầng mach-* của bạn không hỗ trợ các hạt nhân có thể
	 * chạy trên nhiều bảng, pdata sẽ không được hưởng lợi từ "__init".
	 */
	cấu trúc tĩnh mysoc_spi_data pdata __initdata = { ... };

tĩnh __init board_init(void)
	{
		...
/* bo mạch này chỉ sử dụng bộ điều khiển SPI #2 */
		mysoc_register_spi(2, &pdata);
		...
	}

Và mã tiện ích dành riêng cho SOC có thể trông giống như ::

#include <mach/spi.h>

cấu trúc tĩnh platform_device spi2 = { ... };

void mysoc_register_spi(unsigned n, struct mysoc_spi_data *pdata)
	{
		cấu trúc mysoc_spi_data *pdata2;

pdata2 = kmalloc(sizeof *pdata2, GFP_KERNEL);
		*pdata2 = pdata;
		...
nếu (n == 2) {
			spi2->dev.platform_data = pdata2;
			register_platform_device(&spi2);

/* đồng thời: thiết lập các chế độ chân để tín hiệu spi2 được
			 * hiển thị trên các chân có liên quan ... bộ nạp khởi động trên
			 * ban sản xuất có thể đã làm việc này rồi, nhưng
			 * hội đồng nhà phát triển thường sẽ cần Linux để làm việc đó.
			 */
		}
		...
	}

Lưu ý rằng platform_data cho các bảng có thể khác nhau như thế nào, ngay cả khi
cùng bộ điều khiển SOC được sử dụng.  Ví dụ: trên một bảng SPI có thể sử dụng
một đồng hồ bên ngoài, trong đó một đồng hồ khác lấy đồng hồ SPI từ hiện tại
cài đặt của một số đồng hồ chính.

Khai báo thiết bị mục tiêu
^^^^^^^^^^^^^^^^^^^^^^

Loại thông tin thứ hai là danh sách những thiết bị mục tiêu SPI tồn tại
trên bảng mục tiêu, thường có một số dữ liệu dành riêng cho bảng cần thiết cho
trình điều khiển hoạt động chính xác.

Thông thường, các tệp Arch/.../mach-ZZ0000ZZ.c của bạn sẽ cung cấp một bảng nhỏ
liệt kê các thiết bị SPI trên mỗi bảng.  (Điều này thường chỉ là một
số ít.) Nó có thể trông giống như::

cấu trúc tĩnh ads7846_platform_data ads_info = {
		.vref_delay_usecs = 100,
		.x_plate_ohms = 580,
		.y_plate_ohms = 410,
	};

cấu trúc tĩnh spi_board_info spi_board_info[] __initdata = {
	{
		.modalias = "ads7846",
		.platform_data = &ads_info,
		.mode = SPI_MODE_0,
		.irq = GPIO_IRQ(31),
		.max_speed_hz = 120000 /* tốc độ lấy mẫu tối đa ở 3V ZZ0000ZZ 16,
		.bus_num = 1,
		.chip_select = 0,
	},
	};

Một lần nữa, hãy chú ý cách cung cấp thông tin cụ thể cho từng hội đồng; mỗi con chip có thể cần
một số loại.  Ví dụ này hiển thị các ràng buộc chung như SPI nhanh nhất
đồng hồ để cho phép (một chức năng của điện áp bảng trong trường hợp này) hoặc cách chân IRQ
có dây, cộng với các hạn chế dành riêng cho chip như độ trễ quan trọng
thay đổi bởi điện dung ở một chân.

(Ngoài ra còn có "controller_data", thông tin có thể hữu ích cho
trình điều khiển.  Một ví dụ sẽ là điều chỉnh DMA dành riêng cho thiết bị ngoại vi
dữ liệu hoặc lệnh gọi lại chipselect.  Điều này sẽ được lưu trữ trong spi_device sau.)

board_info phải cung cấp đủ thông tin để hệ thống hoạt động
mà không cần tải trình điều khiển của chip.  Khía cạnh rắc rối nhất của
đó có thể là bit SPI_CS_HIGH trong trường spi_device.mode, vì
chia sẻ xe buýt với một thiết bị diễn giải chipselect "ngược" là
không thể thực hiện được cho đến khi cơ sở hạ tầng biết cách bỏ chọn nó.

Sau đó, mã khởi tạo bảng của bạn sẽ đăng ký bảng đó với SPI
cơ sở hạ tầng để nó khả dụng sau này khi bộ điều khiển máy chủ SPI
tài xế đã được đăng ký::

spi_register_board_info(spi_board_info, ARRAY_SIZE(spi_board_info));

Giống như các thiết lập dành riêng cho bảng tĩnh khác, bạn sẽ không hủy đăng ký những thiết lập đó.

Các máy tính kiểu "thẻ" được sử dụng rộng rãi có bộ nhớ, CPU và một số thứ khác
trên một tấm thẻ có diện tích chỉ 30 cm vuông.  Trên các hệ thống như vậy,
tệp ZZ0000ZZ của bạn chủ yếu sẽ cung cấp thông tin
về các thiết bị trên bo mạch chính mà thẻ đó được cắm vào.  Đó
chắc chắn bao gồm các thiết bị SPI được nối qua đầu nối thẻ!


Cấu hình không tĩnh
^^^^^^^^^^^^^^^^^^^^^^^^^

Khi Linux bao gồm hỗ trợ cho thẻ MMC/SD/SDIO/DataFlash thông qua SPI, những thẻ đó
cấu hình cũng sẽ năng động.  May mắn thay, các thiết bị như vậy đều hỗ trợ
đầu dò nhận dạng thiết bị cơ bản, vì vậy chúng sẽ cắm nóng bình thường.


Làm cách nào để viết "Trình điều khiển giao thức SPI"?
----------------------------------------
Hầu hết các trình điều khiển SPI hiện nay đều là trình điều khiển kernel, nhưng cũng có hỗ trợ
cho trình điều khiển không gian người dùng.  Ở đây chúng ta chỉ nói về trình điều khiển kernel.

Trình điều khiển giao thức SPI hơi giống với trình điều khiển thiết bị nền tảng::

cấu trúc tĩnh spi_driver CHIP_driver = {
		.driver = {
			.name = "CHIP",
			.pm = &CHIP_pm_ops,
		},

.probe = CHIP_probe,
		.remove = CHIP_remove,
	};

Lõi trình điều khiển sẽ tự động cố gắng liên kết trình điều khiển này với bất kỳ SPI nào
thiết bị có board_info cung cấp phương thức "CHIP".  Mã thăm dò() của bạn
có thể trông như thế này trừ khi bạn đang tạo một thiết bị đang quản lý
một chiếc xe buýt (xuất hiện dưới /sys/class/spi_master).

::

int tĩnh CHIP_probe(struct spi_device *spi)
	{
		cấu trúc CHIP *chip;
		cấu trúc CHIP_platform_data *pdata;

/* giả sử trình điều khiển yêu cầu dữ liệu dành riêng cho bo mạch: */
		pdata = &spi->dev.platform_data;
		nếu (!pdata)
			trả về -ENODEV;

/* lấy bộ nhớ cho trạng thái trên mỗi chip của trình điều khiển */
		chip = kzalloc(sizeof *chip, GFP_KERNEL);
		nếu (!chip)
			trả về -ENOMEM;
		spi_set_drvdata(spi, chip);

		... etc
trả về 0;
	}

Ngay khi nó đi vào thăm dò(), trình điều khiển có thể đưa ra các yêu cầu I/O tới
thiết bị SPI sử dụng "struct spi_message".  Khi Remove() trả về,
hoặc sau khi thăm dò() không thành công, trình điều khiển đảm bảo rằng nó sẽ không gửi
bất kỳ tin nhắn như vậy nữa.

- Một thông điệp spi là một chuỗi các thao tác giao thức, được thực hiện
    như một chuỗi nguyên tử.  Điều khiển trình điều khiển SPI bao gồm:

+ khi bắt đầu đọc và ghi hai chiều ... bằng cách
        trình tự yêu cầu spi_transfer được sắp xếp;

+ bộ đệm I/O nào được sử dụng ... mỗi spi_transfer bao bọc một
        bộ đệm cho từng hướng truyền, hỗ trợ song công hoàn toàn
        (hai con trỏ, có thể giống nhau trong cả hai trường hợp) và một nửa
        truyền song công (một con trỏ là NULL);

+ tùy chọn xác định độ trễ ngắn sau khi chuyển ... sử dụng
        cài đặt spi_transfer.delay.value (độ trễ này có thể là
        chỉ có hiệu lực giao thức, nếu độ dài bộ đệm bằng 0) ...
        khi chỉ định độ trễ này, spi_transfer.delay.unit mặc định
        là micro giây, tuy nhiên giá trị này có thể được điều chỉnh theo chu kỳ xung nhịp
        hoặc nano giây nếu cần;

+ liệu chipselect có trở nên không hoạt động sau khi truyền hay không và
        bất kỳ sự chậm trễ nào... bằng cách sử dụng cờ spi_transfer.cs_change;

+ gợi ý liệu tin nhắn tiếp theo có khả năng đi đến cùng địa chỉ này hay không
        thiết bị ... sử dụng cờ spi_transfer.cs_change ở lần cuối
	chuyển trong nhóm nguyên tử đó và có khả năng tiết kiệm chi phí
	cho các hoạt động bỏ chọn và chọn chip.

- Tuân theo các quy tắc kernel tiêu chuẩn và cung cấp bộ đệm an toàn DMA trong
    tin nhắn của bạn.  Bằng cách đó, trình điều khiển bộ điều khiển sử dụng DMA không bị ép buộc
    để tạo thêm bản sao trừ khi phần cứng yêu cầu (ví dụ: đang hoạt động
    xung quanh lỗi phần cứng buộc phải sử dụng bộ đệm thoát).

- Nguyên hàm I/O cơ bản là spi_async().  Các yêu cầu không đồng bộ có thể
    được ban hành trong bất kỳ bối cảnh nào (trình xử lý IRQ, nhiệm vụ, v.v.) và việc hoàn thành
    được báo cáo bằng cách sử dụng lệnh gọi lại được cung cấp cùng với tin nhắn.
    Sau khi phát hiện bất kỳ lỗi nào, chip sẽ được bỏ chọn và xử lý
    tin nhắn spi_ đó bị hủy bỏ.

- Ngoài ra còn có các trình bao bọc đồng bộ như spi_sync() và các trình bao bọc
    như spi_read(), spi_write() và spi_write_then_read().  Những cái này
    chỉ có thể được phát hành trong các bối cảnh có thể ngủ và tất cả chúng đều
    các lớp sạch (và nhỏ và "tùy chọn") trên spi_async().

- Lệnh gọi spi_write_then_read() và các gói tiện ích xung quanh
    nó, chỉ nên được sử dụng với lượng nhỏ dữ liệu trong đó
    chi phí của một bản sao bổ sung có thể được bỏ qua.  Nó được thiết kế để hỗ trợ
    các yêu cầu kiểu RPC phổ biến, chẳng hạn như viết lệnh 8 bit
    và đọc phản hồi 16 bit -- spi_w8r16() là một trong số đó
    giấy gói, thực hiện chính xác điều đó.

Một số trình điều khiển có thể cần sửa đổi các đặc điểm spi_device như
chế độ truyền, kích thước từ hoặc tốc độ đồng hồ.  Việc này được thực hiện bằng spi_setup(),
thường được gọi từ thăm dò() trước khi I/O đầu tiên được thực hiện
được thực hiện cho thiết bị.  Tuy nhiên, điều đó cũng có thể được gọi bất cứ lúc nào
rằng không có tin nhắn nào đang chờ xử lý cho thiết bị đó.

Trong khi "spi_device" sẽ là giới hạn dưới cùng của trình điều khiển, thì
ranh giới trên có thể bao gồm sysfs (đặc biệt là để đọc cảm biến),
lớp đầu vào, ALSA, mạng, MTD, khung thiết bị ký tự,
hoặc các hệ thống con Linux khác.

Lưu ý rằng có hai loại bộ nhớ mà trình điều khiển của bạn phải quản lý như một phần
tương tác với các thiết bị SPI.

- Bộ đệm I/O sử dụng các quy tắc Linux thông thường và phải an toàn với DMA.
    Thông thường bạn sẽ phân bổ chúng từ vùng heap hoặc nhóm trang miễn phí.
    Không sử dụng ngăn xếp hoặc bất kỳ thứ gì được khai báo là "tĩnh".

- Siêu dữ liệu spi_message và spi_transfer được sử dụng để gắn kết chúng
    Bộ đệm I/O vào một nhóm giao dịch giao thức.  Những cái này có thể
    được phân bổ ở bất kỳ nơi nào thuận tiện, kể cả như một phần của
    các cấu trúc dữ liệu trình điều khiển phân bổ một lần khác.  Không khởi tạo những thứ này.

Nếu bạn thích, spi_message_alloc() và spi_message_free() tiện lợi
các quy trình có sẵn để phân bổ và khởi tạo một tin nhắn spi_message
với một số lần chuyển tiền.


Làm cách nào để viết "Trình điều khiển bộ điều khiển SPI"?
-------------------------------------------------
Bộ điều khiển SPI có thể sẽ được đăng ký trên platform_bus; viết
một trình điều khiển để liên kết với thiết bị, bất kể xe buýt nào có liên quan.

Nhiệm vụ chính của loại trình điều khiển này là cung cấp một "spi_controller".
Sử dụng spi_alloc_host() để phân bổ bộ điều khiển máy chủ và
spi_controller_get_devdata() để lấy dữ liệu riêng tư của trình điều khiển được phân bổ cho việc đó
thiết bị.

::

struct spi_controller *ctlr;
	cấu trúc CONTROLLER *c;

ctlr = spi_alloc_host(dev, sizeof *c);
	nếu (!ctlr)
		trả về -ENODEV;

c = spi_controller_get_devdata(ctlr);

Trình điều khiển sẽ khởi tạo các trường của bộ điều khiển spi_controller đó, bao gồm cả bus
số (có thể giống với ID thiết bị nền tảng) và ba phương pháp được sử dụng để
tương tác với lõi SPI và trình điều khiển giao thức SPI.  Nó cũng sẽ khởi tạo
trạng thái bên trong của chính nó.  (Xem bên dưới về cách đánh số xe buýt và các phương pháp đó.)

Sau khi bạn khởi tạo spi_controller, hãy sử dụng spi_register_controller() để
xuất bản nó tới phần còn lại của hệ thống. Vào thời điểm đó, các nút thiết bị cho
bộ điều khiển và mọi thiết bị spi được khai báo trước sẽ được cung cấp và
lõi mô hình trình điều khiển sẽ đảm nhiệm việc liên kết chúng với trình điều khiển.

Nếu bạn cần xóa trình điều khiển bộ điều khiển SPI của mình, spi_unregister_controller()
sẽ đảo ngược tác dụng của spi_register_controller().


Đánh số xe buýt
^^^^^^^^^^^^^

Việc đánh số bus rất quan trọng vì đó là cách Linux xác định một
Xe buýt SPI (chia sẻ SCK, MOSI, MISO).  Số xe buýt hợp lệ bắt đầu từ số 0.  Bật
Hệ thống SOC, số bus phải khớp với số do chip xác định
nhà sản xuất.  Ví dụ: bộ điều khiển phần cứng SPI2 sẽ là bus số 2,
và spi_board_info cho các thiết bị được kết nối với nó sẽ sử dụng số đó.

Nếu bạn không có số xe buýt được chỉ định bằng phần cứng đó và vì lý do nào đó
bạn không thể chỉ định chúng, sau đó cung cấp số xe buýt âm.  Điều đó sẽ
sau đó được thay thế bằng một số được gán động. Sau đó bạn sẽ cần phải điều trị
đây là cấu hình không tĩnh (xem ở trên).


Phương pháp điều khiển máy chủ SPI
^^^^^^^^^^^^^^^^^^^^^^^^^^^

ZZ0000ZZ
	Việc này thiết lập tốc độ xung nhịp của thiết bị, chế độ SPI và kích thước từ.
	Trình điều khiển có thể thay đổi các giá trị mặc định do board_info cung cấp, sau đó
	gọi spi_setup(spi) để gọi thủ tục này.  Nó có thể ngủ.

Trừ khi mỗi mục tiêu SPI có các thanh ghi cấu hình riêng, không
	thay đổi chúng ngay lập tức ... nếu không trình điều khiển có thể làm hỏng I/O
	điều đó đang được thực hiện cho các thiết bị SPI khác.

	.. note::

		BUG ALERT:  for some reason the first version of
		many spi_controller drivers seems to get this wrong.
		When you code setup(), ASSUME that the controller
		is actively processing transfers for another device.

ZZ0000ZZ
	Trình điều khiển bộ điều khiển của bạn có thể sử dụng spi_device.controller_state để giữ
	nêu rõ nó liên kết động với thiết bị đó.  Nếu bạn làm điều đó,
	hãy đảm bảo cung cấp phương thức cleanup() để giải phóng trạng thái đó.

ZZ0000ZZ
	Điều này sẽ được cơ chế xếp hàng gọi để báo hiệu cho tài xế
	rằng một tin nhắn sẽ sớm đến, vì vậy hệ thống con yêu cầu
	trình điều khiển chuẩn bị phần cứng chuyển bằng cách thực hiện cuộc gọi này.
	Điều này có thể ngủ.

ZZ0000ZZ
	Điều này sẽ được cơ chế xếp hàng gọi để báo hiệu cho tài xế
	rằng không còn tin nhắn nào đang chờ xử lý trong hàng đợi và nó có thể
	thư giãn phần cứng (ví dụ: bằng các lệnh gọi quản lý nguồn). Điều này có thể ngủ.

ZZ0000ZZ
	Hệ thống con gọi trình điều khiển để chuyển một tin nhắn trong khi
	xếp hàng chuyển khoản đến trong thời gian chờ đợi. Khi người lái xe đang
	kết thúc với tin nhắn này, nó phải gọi
	spi_finalize_current_message() để hệ thống con có thể đưa ra lệnh tiếp theo
	tin nhắn. Điều này có thể ngủ.

ZZ0000ZZ
	Hệ thống con gọi trình điều khiển để chuyển một lần truyền trong khi
	xếp hàng chuyển khoản đến trong thời gian chờ đợi. Khi người lái xe đang
	kết thúc việc chuyển giao này, nó phải gọi
	spi_finalize_current_transfer() để hệ thống con có thể phát hành lệnh tiếp theo
	chuyển nhượng. Điều này có thể ngủ. Lưu ý: transfer_one và transfer_one_message
	loại trừ lẫn nhau; khi cả hai được thiết lập, hệ thống con chung sẽ thực hiện
	không gọi lại cuộc gọi lại transfer_one của bạn.

Giá trị trả về:

* errno tiêu cực: lỗi
	* 0: quá trình truyền hoàn tất
	* 1: quá trình chuyển vẫn đang được tiến hành

ZZ0000ZZ
	Phương pháp này cho phép trình điều khiển máy khách SPI yêu cầu bộ điều khiển máy chủ SPI
	để định cấu hình thiết lập CS cụ thể, thời gian giữ và không hoạt động của thiết bị
	yêu cầu.

Phương pháp không dùng nữa
^^^^^^^^^^^^^^^^^^

ZZ0000ZZ
	Điều này không được ngủ. Trách nhiệm của nó là sắp xếp để
	quá trình chuyển giao xảy ra và lệnh gọi lại Complete() của nó được phát hành. hai
	thường sẽ xảy ra sau đó, sau khi các lần chuyển khác hoàn tất và
	nếu bộ điều khiển không hoạt động thì nó sẽ cần được khởi động. Cái này
	phương thức không được sử dụng trên bộ điều khiển xếp hàng đợi và phải là NULL nếu
	transfer_one_message() và (un)prepare_transfer_hardware() là
	được thực hiện.


Hàng đợi tin nhắn SPI
^^^^^^^^^^^^^^^^^

Nếu bạn hài lòng với cơ chế xếp hàng tiêu chuẩn do
Hệ thống con SPI, chỉ cần triển khai các phương thức xếp hàng được chỉ định ở trên. sử dụng
hàng đợi tin nhắn có ưu điểm là tập trung nhiều mã và
cung cấp việc thực thi các phương thức trong bối cảnh quy trình thuần túy. Hàng đợi tin nhắn
cũng có thể được nâng lên mức ưu tiên thời gian thực đối với lưu lượng truy cập SPI có mức ưu tiên cao.

Trừ khi cơ chế xếp hàng trong hệ thống con SPI được chọn, phần lớn
của trình điều khiển sẽ quản lý hàng đợi I/O được cung cấp bởi trình điều khiển hiện không còn được dùng nữa
chuyển hàm().

Hàng đợi đó có thể hoàn toàn là khái niệm.  Ví dụ, một trình điều khiển chỉ được sử dụng
để truy cập cảm biến tần số thấp có thể ổn khi sử dụng PIO đồng bộ.

Nhưng hàng đợi có thể sẽ rất thực, sử dụng tin nhắn->hàng đợi, PIO,
thường là DMA (đặc biệt nếu hệ thống tập tin gốc nằm trong flash SPI) và
bối cảnh thực thi như trình xử lý IRQ, tác vụ nhỏ hoặc hàng công việc (chẳng hạn như
như keventd).  Trình điều khiển của bạn có thể cầu kỳ hoặc đơn giản tùy theo nhu cầu của bạn.
Phương thức transfer() như vậy thường chỉ thêm thông báo vào một
xếp hàng, sau đó khởi động một số công cụ truyền tải không đồng bộ (trừ khi nó
đã chạy rồi).


Phần mở rộng cho giao thức SPI
------------------------------
Thực tế là SPI không có thông số kỹ thuật chính thức hoặc tiêu chuẩn cho phép chip
các nhà sản xuất triển khai giao thức SPI theo những cách hơi khác nhau. Trong hầu hết
trường hợp, việc triển khai giao thức SPI từ các nhà cung cấp khác nhau tương thích giữa
lẫn nhau. Ví dụ: ở chế độ SPI 0 (CPOL=0, CPHA=0), các tuyến xe buýt có thể hoạt động
như sau:

::

nCSx ___ ___
          \_________________________________________________________________/
          • •
          • •
  SCLK ___ ___ ___ ___ ___ ___ ___ ___
       _______/ \___/ \___/ \___/ \___/ \___/ \___/ \___/ \_____
          • : ;   : ;   : ;   : ;   : ;   : ;   : ;   : ; •
          • : ;   : ;   : ;   : ;   : ;   : ;   : ;   : ; •
  MOSI XXX__________ _______ _______ ________XXX
  0xA5 XXX__/ 1 \_0_____/ 1 \_0_______0_____/ 1 \_0_____/ 1 \_XXX
          • ;       ;       ;       ;       ;       ;       ;       ; •
          • ;       ;       ;       ;       ;       ;       ;       ; •
  MISO XXX__________ _______________________ _______ XXX
  0xBA XXX__/ 1 \_____0_/ 1 1 1 \_____0__/ 1 \____0__XXX

Huyền thoại::

• đánh dấu sự bắt đầu/kết thúc quá trình truyền;
  : đánh dấu khi dữ liệu được đưa vào thiết bị ngoại vi;
  ; đánh dấu khi dữ liệu được đưa vào bộ điều khiển;
  Dấu X khi trạng thái dòng không được chỉ định.

Trong một số trường hợp, chip mở rộng giao thức SPI bằng cách chỉ định hành vi đường truyền
mà các giao thức SPI khác không có (ví dụ: trạng thái dòng dữ liệu khi CS không
khẳng định). Các giao thức, chế độ và cấu hình SPI riêng biệt đó được hỗ trợ
bởi các cờ chế độ SPI khác nhau.

Cấu hình trạng thái nhàn rỗi MOSI
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Việc triển khai giao thức SPI phổ biến không chỉ định bất kỳ trạng thái hoặc hành vi nào cho
Dòng MOSI khi bộ điều khiển không hết giờ dữ liệu. Tuy nhiên, có tồn tại
các thiết bị ngoại vi yêu cầu trạng thái dòng MOSI cụ thể khi dữ liệu không được bấm giờ
ra ngoài. Ví dụ: nếu thiết bị ngoại vi mong đợi đường MOSI ở mức cao khi
bộ điều khiển không hết giờ dữ liệu (ZZ0000ZZ), sau đó truyền dữ liệu vào
SPI chế độ 0 sẽ trông như sau:

::

nCSx ___ ___
          \_________________________________________________________________/
          • •
          • •
  SCLK ___ ___ ___ ___ ___ ___ ___ ___
       _______/ \___/ \___/ \___/ \___/ \___/ \___/ \___/ \_____
          • : ;   : ;   : ;   : ;   : ;   : ;   : ;   : ; •
          • : ;   : ;   : ;   : ;   : ;   : ;   : ;   : ; •
  MOSI _____ _______ _______ _______________ ___
  0x56 \_0_____/ 1 \_0_____/ 1 \_0_____/ 1 1 \_0_____/
          • ;       ;       ;       ;       ;       ;       ;       ; •
          • ;       ;       ;       ;       ;       ;       ;       ; •
  MISO XXX__________ _______________________ _______ XXX
  0xBA XXX__/ 1 \_____0_/ 1 1 1 \_____0__/ 1 \____0__XXX

Huyền thoại::

• đánh dấu sự bắt đầu/kết thúc quá trình truyền;
  : đánh dấu khi dữ liệu được đưa vào thiết bị ngoại vi;
  ; đánh dấu khi dữ liệu được đưa vào bộ điều khiển;
  Dấu X khi trạng thái dòng không được chỉ định.

Trong phần mở rộng này của giao thức SPI thông thường, trạng thái dòng MOSI được chỉ định cho
được giữ ở mức cao khi CS được xác nhận nhưng bộ điều khiển không hết giờ dữ liệu
thiết bị ngoại vi và cả khi CS không được xác nhận.

Các thiết bị ngoại vi yêu cầu tiện ích mở rộng này phải yêu cầu bằng cách đặt
ZZ0000ZZ bit vào thuộc tính mode của ZZ0001ZZ của họ và gọi spi_setup(). Bộ điều khiển hỗ trợ tiện ích mở rộng này
nên chỉ ra điều đó bằng cách đặt ZZ0002ZZ trong thuộc tính mode_bits
ZZ0003ZZ của họ. Cấu hình ở mức không tải MOSI ở mức thấp là
tương tự nhưng sử dụng bit chế độ ZZ0004ZZ.


THANKS ĐẾN
---------
Những người đóng góp cho các cuộc thảo luận Linux-SPI bao gồm (theo thứ tự bảng chữ cái,
theo họ):

- Mark Brown
- David Brownell
- Vua Russell
- Có khả năng cấp
- Dmitry Pervushin
- Phố Stephen
- Mark Underwood
- Andrew Victor
- Linus Walleij
- Len Vitaly
