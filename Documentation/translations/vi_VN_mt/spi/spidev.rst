.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/spi/spidev.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Không gian người dùng SPI API
=================

Các thiết bị SPI có không gian người dùng hạn chế API, hỗ trợ chế độ bán song công cơ bản
quyền truy cập read() và write() vào các thiết bị phụ SPI.  Sử dụng các yêu cầu ioctl(),
chuyển song công hoàn toàn và cấu hình I/O thiết bị cũng có sẵn.

::

#include <fcntl.h>
	#include <unistd.h>
	#include <sys/ioctl.h>
	#include <linux/types.h>
	#include <linux/spi/spidev.h>

Một số lý do bạn có thể muốn sử dụng giao diện lập trình này bao gồm:

* Tạo mẫu trong môi trường không dễ xảy ra sự cố; con trỏ đi lạc
   trong không gian người dùng thường sẽ không làm sập bất kỳ hệ thống Linux nào.

* Phát triển các giao thức đơn giản dùng để giao tiếp với vi điều khiển hoạt động
   như SPI nô lệ, bạn có thể cần phải thay đổi khá thường xuyên.

Tất nhiên có những trình điều khiển không bao giờ có thể được ghi vào không gian người dùng, bởi vì
họ cần truy cập vào các giao diện kernel (chẳng hạn như trình xử lý IRQ hoặc các lớp khác
của ngăn xếp trình điều khiển) không thể truy cập được vào không gian người dùng.


DEVICE CREATION, DRIVER BINDING
===============================

Trình điều khiển spidev chứa danh sách các thiết bị SPI được hỗ trợ cho
các biểu diễn cấu trúc liên kết phần cứng khác nhau.

Sau đây là các bảng thiết bị SPI được trình điều khiển spidev hỗ trợ:

- struct spi_device_id spidev_spi_ids[]: danh sách các thiết bị có thể
      bị ràng buộc khi chúng được xác định bằng cấu trúc spi_board_info với
      Trường .modalias khớp với một trong các mục trong bảng.

- struct of_device_id spidev_dt_ids[]: danh sách các thiết bị có thể
      bị ràng buộc khi chúng được xác định bằng nút Cây thiết bị có
      chuỗi tương thích khớp với một trong các mục trong bảng.

- struct acpi_device_id spidev_acpi_ids[]: danh sách các thiết bị có thể
      bị ràng buộc khi chúng được xác định bằng cách sử dụng đối tượng thiết bị ACPI với
      _HID khớp với một trong các mục trong bảng.

Bạn được khuyến khích thêm mục nhập cho tên thiết bị SPI của mình vào các mục liên quan
các bảng, nếu những bảng này chưa có mục nhập cho thiết bị. Để làm điều đó,
đăng bản vá cho spidev lên danh sách gửi thư linux-spi@vger.kernel.org.

Nó từng được hỗ trợ để xác định thiết bị SPI bằng tên "spidev".
Ví dụ như .modalias="spidev" hoặc tương thích = "spidev".  Nhưng điều này
không còn được nhân Linux hỗ trợ nữa và thay vào đó là thiết bị SPI thực sự
tên như được liệt kê trong một trong các bảng phải được sử dụng.

Không có tên thiết bị SPI thực sẽ dẫn đến lỗi khi in và
trình điều khiển spidev không thăm dò được.

Sysfs cũng hỗ trợ việc liên kết/hủy liên kết các trình điều khiển theo không gian người dùng với
các thiết bị không tự động liên kết bằng một trong các bảng trên.
Để làm cho trình điều khiển spidev liên kết với một thiết bị như vậy, hãy sử dụng cách sau::

echo spidev > /sys/bus/spi/devices/spiB.C/driver_override
    echo spiB.C > /sys/bus/spi/drivers/spidev/bind

Khi trình điều khiển spidev được liên kết với thiết bị SPI, nút sysfs cho
thiết bị sẽ bao gồm một nút thiết bị con có thuộc tính "dev" sẽ
được hiểu bởi udev hoặc mdev (thay thế udev từ BusyBox; nó ít hơn
đặc sắc, nhưng thường là đủ).

Đối với thiết bị SPI có chipselect C trên bus B, bạn sẽ thấy:

/dev/spidevB.C ...
	thiết bị ký tự đặc biệt, số chính 153 với
	số thiết bị phụ được chọn động.  Đây là nút
	các chương trình trong không gian người dùng sẽ mở ra, được tạo bởi "udev" hoặc "mdev".

/sys/thiết bị/.../spiB.C ...
	như thường lệ, nút thiết bị SPI sẽ
	là con của bộ điều khiển chính SPI.

/sys/class/spidev/spidevB.C ...
	được tạo khi trình điều khiển "spdev"
	liên kết với thiết bị đó.  (Thư mục hoặc liên kết tượng trưng, dựa trên việc
	hay không, bạn đã bật tùy chọn Kconfig "tệp sysfs không dùng nữa".)

Đừng cố quản lý các nút tệp đặc biệt của thiết bị ký tự /dev bằng tay.
Điều đó dễ xảy ra lỗi và bạn cần chú ý cẩn thận đến hệ thống
vấn đề an ninh; udev/mdev phải được cấu hình an toàn.

Nếu bạn hủy liên kết trình điều khiển "spidev" khỏi thiết bị đó, hai nút "spidev" đó sẽ
(trong sysfs và trong /dev) sẽ tự động bị xóa (tương ứng bởi
kernel và bởi udev/mdev).  Bạn có thể hủy liên kết bằng cách xóa trình điều khiển "spidev"
module, điều này sẽ ảnh hưởng đến tất cả các thiết bị sử dụng trình điều khiển này.  Bạn cũng có thể hủy liên kết
bằng cách yêu cầu mã hạt nhân xóa thiết bị SPI, có thể bằng cách xóa trình điều khiển
cho bộ điều khiển SPI của nó (vì vậy spi_master của nó biến mất).

Vì đây là trình điều khiển thiết bị Linux tiêu chuẩn -- mặc dù nó chỉ xảy ra
để hiển thị API cấp thấp cho không gian người dùng -- nó có thể được liên kết với bất kỳ số nào
của các thiết bị tại một thời điểm.  Chỉ cần cung cấp một bản ghi spi_board_info cho mỗi bản ghi đó
Thiết bị SPI và bạn sẽ nhận được nút thiết bị/dev cho mỗi thiết bị.


BASIC CHARACTER DEVICE API
==========================
Các thao tác open() và close() thông thường trên các tệp /dev/spidevB.D hoạt động giống như bạn
sẽ mong đợi.

Các thao tác đọc() và ghi() tiêu chuẩn rõ ràng chỉ là bán song công và
chipselect bị vô hiệu hóa giữa các hoạt động đó.  Truy cập song công hoàn toàn,
và hoạt động tổng hợp mà không cần hủy kích hoạt chipselect, có sẵn bằng cách sử dụng
yêu cầu SPI_IOC_MESSAGE(N).

Một số yêu cầu ioctl() cho phép trình điều khiển của bạn đọc hoặc ghi đè thông số hiện tại của thiết bị
cài đặt cho các tham số truyền dữ liệu:

SPI_IOC_RD_MODE, SPI_IOC_WR_MODE ...
	chuyển một con trỏ tới một byte sẽ
	trả về (RD) hoặc gán (WR) chế độ truyền SPI.  Sử dụng các hằng số
	SPI_MODE_0..SPI_MODE_3; hoặc nếu thích bạn có thể kết hợp SPI_CPOL
	(cực đồng hồ, không hoạt động ở mức cao nếu cài đặt này) hoặc SPI_CPHA (pha đồng hồ,
	mẫu ở cạnh cuối nếu điều này được đặt) cờ.
	Lưu ý rằng yêu cầu này được giới hạn ở các cờ chế độ SPI phù hợp với
	byte đơn.

SPI_IOC_RD_MODE32, SPI_IOC_WR_MODE32 ...
	chuyển một con trỏ tới uin32_t
	sẽ trả về (RD) hoặc gán (WR) chế độ truyền SPI đầy đủ,
	không giới hạn ở các bit vừa với một byte.

SPI_IOC_RD_LSB_FIRST, SPI_IOC_WR_LSB_FIRST ...
	chuyển một con trỏ tới một byte
	sẽ trả về (RD) hoặc gán (WR) độ căn chỉnh bit được sử dụng để
	chuyển từ SPI.  Số 0 biểu thị MSB-đầu tiên; các giá trị khác chỉ ra
	mã hóa đầu tiên LSB ít phổ biến hơn.  Trong cả hai trường hợp, giá trị được chỉ định
	được căn phải trong mỗi từ, sao cho không được sử dụng (TX) hoặc không xác định (RX)
	các bit nằm trong MSB.

SPI_IOC_RD_BITS_PER_WORD, SPI_IOC_WR_BITS_PER_WORD ...
	chuyển một con trỏ tới
	một byte sẽ trả về (RD) hoặc gán (WR) số bit trong
	mỗi từ chuyển SPI.  Giá trị 0 biểu thị tám bit.

SPI_IOC_RD_MAX_SPEED_HZ, SPI_IOC_WR_MAX_SPEED_HZ ...
	chuyển một con trỏ tới một
	u32 sẽ trả về (RD) hoặc gán (WR) mức truyền SPI tối đa
	tốc độ, tính bằng Hz.  Bộ điều khiển không nhất thiết phải chỉ định cụ thể đó
	tốc độ đồng hồ.

NOTES:

- Tại thời điểm này không có hỗ trợ I/O không đồng bộ; mọi thứ đều thuần túy
      đồng bộ.

- Hiện tại không có cách nào để báo cáo tốc độ bit thực tế được sử dụng
      chuyển dữ liệu đến/từ một thiết bị nhất định.

- Từ không gian người dùng, hiện tại bạn không thể thay đổi cực chọn chip;
      điều đó có thể làm hỏng quá trình truyền tới các thiết bị khác chia sẻ bus SPI.
      Mỗi thiết bị SPI được bỏ chọn khi không được sử dụng, cho phép
      trình điều khiển khác để nói chuyện với các thiết bị khác.

- Có giới hạn về số byte mà mỗi yêu cầu I/O có thể chuyển
      đến thiết bị SPI.  Nó mặc định là một trang, nhưng có thể thay đổi
      sử dụng tham số mô-đun.

- Vì SPI không có xác nhận chuyển khoản cấp thấp nên bạn thường
      sẽ không thấy bất kỳ lỗi I/O nào khi nói chuyện với một thiết bị không tồn tại.


FULL DUPLEX CHARACTER DEVICE API
================================

Xem chương trình mẫu spidev_fdx.c để biết ví dụ về cách sử dụng
giao diện lập trình song công hoàn toàn.  (Mặc dù nó không thực hiện chế độ song công hoàn toàn
transfer.) Mô hình này giống với mô hình được sử dụng trong kernel spi_sync()
yêu cầu; các lần chuyển tiền riêng lẻ cung cấp các khả năng tương tự như
có sẵn cho trình điều khiển hạt nhân (ngoại trừ việc nó không đồng bộ).

Ví dụ này hiển thị một thông báo yêu cầu và phản hồi kiểu bán song công RPC.
Những yêu cầu này thường yêu cầu chip không được bỏ chọn giữa
yêu cầu và phản hồi.  Một số yêu cầu như vậy có thể được xâu chuỗi thành
một yêu cầu kernel duy nhất, thậm chí cho phép bỏ chọn chip sau
mỗi phản hồi.  (Các tùy chọn giao thức khác bao gồm thay đổi kích thước từ
và tốc độ bit cho từng phân đoạn truyền.)

Để thực hiện một yêu cầu song công hoàn toàn, hãy cung cấp cả rx_buf và tx_buf cho
chuyển giao tương tự.  Thậm chí còn ổn nếu đó là cùng một bộ đệm.
