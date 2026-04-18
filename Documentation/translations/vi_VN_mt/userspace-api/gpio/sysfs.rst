.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/gpio/sysfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Giao diện Sysfs GPIO cho không gian người dùng
==================================

.. warning::
   This API is obsoleted by the chardev.rst and the ABI documentation has
   been moved to Documentation/ABI/obsolete/sysfs-gpio.

   New developments should use the chardev.rst, and existing developments are
   encouraged to migrate as soon as possible, as this API will be removed
   in the future.

   This interface will continue to be maintained for the migration period,
   but new features will only be added to the new API.

Hệ thống lỗi thời ABI
----------------------
Các nền tảng sử dụng khung triển khai "gpiolib" có thể chọn
định cấu hình giao diện người dùng sysfs cho GPIO. Điều này khác với
debugfs giao diện, vì nó cung cấp khả năng kiểm soát hướng GPIO và
value thay vì chỉ hiển thị tóm tắt trạng thái gpio. Thêm nữa, nó có thể là
hiện diện trên hệ thống sản xuất mà không hỗ trợ gỡ lỗi.

Với tài liệu phần cứng thích hợp cho hệ thống, không gian người dùng có thể
ví dụ: biết rằng GPIO #23 kiểm soát dòng bảo vệ ghi được sử dụng để
bảo vệ các phân đoạn bộ tải khởi động trong bộ nhớ flash. Thủ tục nâng cấp hệ thống
có thể cần phải tạm thời loại bỏ tính năng bảo vệ đó, trước tiên hãy nhập GPIO,
sau đó thay đổi trạng thái đầu ra, sau đó cập nhật mã trước khi kích hoạt lại
việc bảo vệ ghi. Trong sử dụng bình thường, GPIO #23 sẽ không bao giờ được chạm vào,
và kernel sẽ không cần phải biết về nó.

Một lần nữa tùy thuộc vào tài liệu phần cứng thích hợp, trên một số hệ thống
không gian người dùng GPIO có thể được sử dụng để xác định dữ liệu cấu hình hệ thống
hạt nhân tiêu chuẩn sẽ không biết về. Và đối với một số tác vụ, không gian người dùng đơn giản
Trình điều khiển GPIO có thể là tất cả những gì hệ thống thực sự cần.

.. note::
   Do NOT abuse sysfs to control hardware that has proper kernel drivers.
   Please read Documentation/driver-api/gpio/drivers-on-gpio.rst
   to avoid reinventing kernel wheels in userspace.

   I MEAN IT. REALLY.

Đường dẫn trong Sysfs
--------------
Có ba loại mục trong /sys/class/gpio:

- Giao diện điều khiển được sử dụng để kiểm soát không gian người dùng đối với GPIO;

- Bản thân GPIO; Và

- Bộ điều khiển GPIO phiên bản ("gpio_chip").

Đó là ngoài các tệp tiêu chuẩn bao gồm liên kết tượng trưng "thiết bị".

Các giao diện điều khiển chỉ ghi:

/sys/class/gpio/

"xuất khẩu"...
		Không gian người dùng có thể yêu cầu kernel xuất quyền kiểm soát
		GPIO vào không gian người dùng bằng cách ghi số của nó vào tệp này.

Ví dụ: "echo 19 > xuất" sẽ tạo nút "gpio19"
		đối với GPIO #19, nếu mã hạt nhân không yêu cầu điều đó.

"không xuất khẩu"...
		Đảo ngược tác dụng của việc xuất sang không gian người dùng.

Ví dụ: "echo 19 > unexport" sẽ xóa "gpio19"
		nút được xuất bằng tệp "xuất".

Tín hiệu GPIO có các đường dẫn như /sys/class/gpio/gpio42/ (đối với GPIO #42)
và có các thuộc tính đọc/ghi sau:

/sys/class/gpio/gpioN/

"hướng"...
		đọc là "vào" hoặc "ra". Giá trị này có thể
		thường được viết. Viết là "ra" mặc định là
		khởi tạo giá trị ở mức thấp. Để đảm bảo trục trặc miễn phí
		hoạt động, các giá trị "thấp" và "cao" có thể được ghi vào
		định cấu hình GPIO làm đầu ra với giá trị ban đầu đó.

Lưu ý rằng thuộc tính ZZ0000ZZ này nếu kernel
		không hỗ trợ thay đổi hướng của GPIO hoặc
		nó đã được xuất bằng mã hạt nhân mà không rõ ràng
		cho phép không gian người dùng cấu hình lại hướng của GPIO này.

"giá trị"...
		đọc là 0 (không hoạt động) hoặc 1 (hoạt động). Nếu GPIO
		được cấu hình làm đầu ra, giá trị này có thể được ghi;
		mọi giá trị khác 0 đều được coi là hoạt động.

Nếu chân có thể được cấu hình là ngắt tạo ngắt
		và liệu nó có được cấu hình để tạo ra các ngắt hay không (xem phần
		mô tả về "cạnh"), bạn có thể thăm dò ý kiến (2) trên tệp đó và
		poll(2) sẽ quay trở lại bất cứ khi nào ngắt được kích hoạt. Nếu
		bạn sử dụng cuộc thăm dò ý kiến (2), đặt các sự kiện POLLPRI và POLLERR. Nếu bạn
		sử dụng select(2), đặt bộ mô tả tệp trong ngoại trừfds. Sau
		poll(2) trả về, sử dụng pre(2) để đọc giá trị tại offset
		không. Ngoài ra, hãy lseek(2) vào đầu
		sysfs và đọc giá trị mới hoặc đóng tệp và
		mở lại nó để đọc giá trị.

"cạnh"...
		đọc là "không", "tăng", "giảm" hoặc
		"cả hai". Viết các chuỗi này để chọn (các) cạnh tín hiệu
		điều đó sẽ khiến cuộc thăm dò (2) trên tệp "giá trị" trở lại.

Tập tin này chỉ tồn tại nếu pin có thể được cấu hình như một
		ngắt tạo ra chân đầu vào.

"hoạt động_thấp" ...
		đọc là 0 (sai) hoặc 1 (đúng). Viết
		bất kỳ giá trị khác 0 nào để đảo ngược cả thuộc tính giá trị
		để đọc và viết. Hiện tại và tiếp theo
		cấu hình hỗ trợ poll(2) thông qua thuộc tính edge
		đối với các cạnh "tăng" và "giảm" sẽ tuân theo điều này
		thiết lập.

Bộ điều khiển GPIO có các đường dẫn như /sys/class/gpio/gpiochip42/ (đối với
bộ điều khiển triển khai GPIO bắt đầu từ #42) và có các mục sau
thuộc tính chỉ đọc:

/sys/class/gpio/gpiochipN/

"cơ sở"...
		giống như N, GPIO đầu tiên được quản lý bởi con chip này

"nhãn"...
		được cung cấp cho chẩn đoán (không phải lúc nào cũng duy nhất)

"ngpio"...
		nó quản lý bao nhiêu GPIO (N đến N + ngpio - 1)

Trong hầu hết các trường hợp, tài liệu của hội đồng phải đề cập đến mục đích sử dụng GPIO
mục đích gì. Tuy nhiên, những con số đó không phải lúc nào cũng ổn định; GPIO đang bật
thẻ con có thể khác nhau tùy thuộc vào bo mạch chủ được sử dụng,
hoặc các thẻ khác trong ngăn xếp. Trong những trường hợp như vậy, bạn có thể cần sử dụng
các nút gpiochip (có thể kết hợp với sơ đồ) để xác định
số GPIO chính xác để sử dụng cho một tín hiệu nhất định.


Xuất từ ​​mã hạt nhân
--------------------------
Mã hạt nhân có thể quản lý rõ ràng việc xuất GPIO đã được
được yêu cầu sử dụng gpio_request()::

/* xuất GPIO sang không gian người dùng */
	int gpiod_export(struct gpio_desc *desc, bool Direction_may_change);

/* đảo ngược gpiod_export() */
	void gpiod_unexport(struct gpio_desc *desc);

/* tạo liên kết sysfs tới nút GPIO đã xuất */
	int gpiod_export_link(thiết bị cấu trúc *dev, const char *name,
		      cấu trúc gpio_desc *desc);

Sau khi trình điều khiển hạt nhân yêu cầu GPIO, nó chỉ có thể được cung cấp ở
giao diện sysfs bởi gpiod_export(). Người lái xe có thể kiểm soát xem
hướng tín hiệu có thể thay đổi. Điều này giúp trình điều khiển ngăn chặn mã không gian người dùng
do vô tình làm tắc nghẽn trạng thái hệ thống quan trọng.

Việc xuất rõ ràng này có thể giúp gỡ lỗi (bằng cách tạo một số loại
của các thử nghiệm dễ dàng hơn) hoặc có thể cung cấp giao diện luôn ở đó
thích hợp để ghi lại như một phần của gói hỗ trợ hội đồng quản trị.

Sau khi GPIO được xuất, gpiod_export_link() cho phép tạo
liên kết tượng trưng từ nơi khác trong sysfs đến nút sysfs GPIO. Người lái xe có thể
sử dụng điều này để cung cấp giao diện theo thiết bị của riêng họ trong sysfs với
một cái tên mô tả.
