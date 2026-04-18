.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/laptops/thinkpad-acpi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Trình điều khiển bổ sung ThinkPad ACPI
===========================

Phiên bản 0,25

Ngày 16 tháng 10 năm 2013

- Borislav Deianov <borislav@users.sf.net>
- Henrique de Moraes Holschuh <hmh@hmh.eng.br>

ZZ0000ZZ

Đây là trình điều khiển Linux dành cho máy tính xách tay IBM và Lenovo ThinkPad. Nó
hỗ trợ các tính năng khác nhau của những máy tính xách tay này có thể truy cập được
thông qua khung ACPI và ACPI EC, nhưng không đầy đủ
được hỗ trợ bởi trình điều khiển Linux ACPI chung.

Trình điều khiển này từng được đặt tên là ibm-acpi cho đến kernel 2.6.21 và phát hành
0,13-20070314.  Nó từng nằm trong cây trình điều khiển/acpi, nhưng nó đã
đã chuyển đến cây trình điều khiển/linh tinh và đổi tên thành thinkpad-acpi cho kernel
2.6.22 và phát hành 0.14.  Nó đã được chuyển sang trình điều khiển/nền tảng/x86 cho
kernel 2.6.29 và phát hành 0.22.

Trình điều khiển có tên là "thinkpad-acpi".  Ở một số nơi, như mô-đun
tên và thông điệp tường trình, "thinkpad_acpi" được sử dụng vì không gian người dùng
vấn đề.

"tpacpi" được sử dụng như một cách viết tắt trong đó "thinkpad-acpi" cũng vậy
dài do giới hạn độ dài trên một số phiên bản nhân Linux.

Trạng thái
------

Các tính năng hiện được hỗ trợ như sau (xem bên dưới để biết
mô tả chi tiết):

- Tổ hợp phím Fn
	- Bật và tắt Bluetooth
	- chuyển đổi đầu ra video, kiểm soát mở rộng
	- Bật và tắt ThinkLight
	- Điều khiển CMOS/UCMS
	- Điều khiển LED
	- Âm thanh ACPI
	- cảm biến nhiệt độ
	- Thử nghiệm: kết xuất thanh ghi bộ điều khiển nhúng
	- Điều khiển độ sáng LCD
	- Điều khiển âm lượng
	- Điều khiển và giám sát quạt: tốc độ quạt, bật/tắt quạt
	- Kích hoạt và vô hiệu hóa WAN
	- Kích hoạt và vô hiệu hóa UWB
	- Bật và tắt LCD Shadow (PrivacyGuard)
	- Cảm biến chế độ vòng chạy
	- Cài đặt ngôn ngữ bàn phím
	- Loại anten WWAN
	- Auxmac
	- Khả năng phát hiện hư hỏng phần cứng

Bảng tương thích theo kiểu máy và tính năng được duy trì trên web
trang web, ZZ0000ZZ Tôi đánh giá cao bất kỳ thành công hay thất bại nào
báo cáo, đặc biệt nếu chúng bổ sung hoặc sửa bảng tương thích.
Vui lòng bao gồm các thông tin sau trong báo cáo của bạn:

- Tên model ThinkPad
	- một bản sao các bảng ACPI của bạn, sử dụng tiện ích "acpidump"
	- một bản sao đầu ra của dmidecode, có số sê-ri
	  và UUID bị che giấu
	- tính năng nào của trình điều khiển hoạt động và tính năng nào không
	- hành vi được quan sát của các tính năng không hoạt động

Bất kỳ nhận xét hoặc bản vá nào khác cũng được chào đón nhiều hơn.


Cài đặt
------------

Nếu bạn đang biên dịch trình điều khiển này như được bao gồm trong nhân Linux
nguồn, hãy tìm tùy chọn CONFIG_THINKPAD_ACPI Kconfig.
Nó nằm trên đường dẫn menu: "Trình điều khiển thiết bị" -> "Nền tảng X86
Trình điều khiển thiết bị cụ thể" -> "Phần bổ sung dành cho máy tính xách tay ThinkPad ACPI".


Đặc trưng
--------

Trình điều khiển xuất hai giao diện khác nhau sang không gian người dùng, có thể
được sử dụng để truy cập các tính năng mà nó cung cấp.  Một là dựa trên Procfs kế thừa
giao diện này sẽ bị xóa vào một thời điểm nào đó trong tương lai.  Cái khác
là một giao diện dựa trên sysfs mới chưa hoàn thiện.

Giao diện Procfs tạo thư mục /proc/acpi/ibm.  có một
tập tin trong thư mục đó cho từng tính năng mà nó hỗ trợ.  các quy trình
giao diện hầu như bị đóng băng và sẽ thay đổi rất ít nếu có: nó
thay vào đó sẽ không được mở rộng để thêm bất kỳ chức năng mới nào vào trình điều khiển
tất cả chức năng mới sẽ được triển khai trên giao diện sysfs.

Giao diện sysfs cố gắng hòa trộn trong các hệ thống con sysfs Linux chung
và các lớp học nhiều nhất có thể.  Vì một số hệ thống con này không
chưa sẵn sàng hoặc đã ổn định, dự kiến giao diện này sẽ thay đổi,
và bất kỳ và tất cả các chương trình không gian người dùng đều phải xử lý nó.


Lưu ý về giao diện sysfs
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Không giống như những gì đã được thực hiện với giao diện Procfs, tính chính xác khi nói chuyện
đối với các giao diện sysfs sẽ được thực thi, cũng như tính chính xác trong
việc triển khai các giao diện sysfs của thinkpad-acpi.

Ngoài ra, bất kỳ lỗi nào trong mã trình điều khiển thinkpad-acpi sysfs hoặc trong
Việc triển khai giao diện sysfs của thinkpad-acpi sẽ được khắc phục cho
độ chính xác tối đa, ngay cả khi điều đó có nghĩa là phải thay đổi giao diện trong
những cách không tương thích.  Khi các giao diện này trưởng thành cả trong kernel và
trong thinkpad-acpi, những thay đổi như vậy sẽ trở nên khá hiếm.

Các ứng dụng giao tiếp với giao diện sysfs thinkpad-acpi phải
tuân theo tất cả các hướng dẫn của sysfs và xử lý chính xác tất cả các lỗi (tệp sysfs
giao diện sử dụng nhiều lỗi).  Bộ mô tả tệp và mở /
các hoạt động đóng đối với các nút sysfs cũng phải được thực hiện đúng cách.

Phiên bản giao diện sysfs của thinkpad-acpi được driver xuất ra
làm thuộc tính trình điều khiển (xem bên dưới).

Thuộc tính trình điều khiển Sysfs nằm trên không gian thuộc tính sysfs của trình điều khiển,
đối với phiên bản 2.6.23+ thì đây là /sys/bus/platform/drivers/thinkpad_acpi/ và
/sys/bus/platform/drivers/thinkpad_hwmon/

Thuộc tính thiết bị Sysfs nằm trên thuộc tính sysfs của thiết bị thinkpad_acpi
không gian, đối với phiên bản 2.6.23+ thì đây là /sys/devices/platform/thinkpad_acpi/.

Thuộc tính thiết bị Sysfs cho cảm biến và quạt nằm trên
không gian thuộc tính sysfs của thiết bị thinkpad_hwmon, nhưng bạn nên xác định vị trí của nó
đang tìm kiếm một thiết bị hwmon có thuộc tính tên là "thinkpad" hoặc
tốt hơn nữa là thông qua libsensors. Đối với các thuộc tính sysfs 4.14+ đã được chuyển sang
thiết bị hwmon (/sys/bus/platform/devices/thinkpad_hwmon/hwmon/hwmon? hoặc
/sys/class/hwmon/hwmon?).

Phiên bản trình điều khiển
--------------

Procfs: /proc/acpi/ibm/driver

Thuộc tính trình điều khiển sysfs: phiên bản

Tên trình điều khiển và phiên bản. Không có lệnh nào có thể được ghi vào tập tin này.


Phiên bản giao diện Sysfs
-----------------------

Thuộc tính trình điều khiển sysfs: giao diện_version

Phiên bản của giao diện thinkpad-acpi sysfs, dưới dạng dài không dấu
(đầu ra ở định dạng hex: 0xAAAABBCC), trong đó:

AAAA
	  - sửa đổi lớn
	BB
	  - sửa đổi nhỏ
	CC
	  - sửa lỗi sửa lỗi

Bạn có thể tìm thấy nhật ký thay đổi phiên bản giao diện sysfs cho trình điều khiển tại
cuối tài liệu này.  Những thay đổi đối với giao diện sysfs được thực hiện bởi kernel
các hệ thống con không được ghi lại ở đây và chúng cũng không được theo dõi bởi điều này
thuộc tính.

Những thay đổi đối với giao diện thinkpad-acpi sysfs chỉ được xem xét
phi thử nghiệm khi chúng được gửi tới dòng chính của Linux, tại đó
chỉ ra những thay đổi trong giao diện này được ghi lại và giao diện_version
có thể được cập nhật.  Nếu bạn chưa sử dụng bất kỳ tính năng nào của thinkpad-acpi
được gửi đến đường dây chính để hợp nhất, bạn tự chịu rủi ro khi làm như vậy: những tính năng này
có thể biến mất hoặc được thực hiện theo cách khác và không tương thích bởi
thời điểm chúng được hợp nhất trong dòng chính của Linux.

Những thay đổi có bản chất tương thích ngược (ví dụ: việc bổ sung
các thuộc tính không thay đổi cách thức hoạt động của các thuộc tính khác) thì không
luôn đảm bảo cập nhật giao diện_version.  Vì vậy, người ta phải
mong đợi rằng một thuộc tính có thể không có ở đó và xử lý nó đúng cách
(một thuộc tính không có ở đó ZZ0000ZZ là một cách hợp lệ để làm rõ rằng một
tính năng này không có sẵn trong sysfs).


Phím nóng
--------

Procfs: /proc/acpi/ibm/hotkey

Thuộc tính thiết bị sysfs: hotkey_*

Trong ThinkPad, bộ xử lý ACPI HKEY chịu trách nhiệm liên lạc
một số sự kiện quan trọng và cả việc nhấn phím nóng trên bàn phím để điều hành
hệ thống.  Việc kích hoạt chức năng phím nóng của thinkpad-acpi sẽ báo hiệu
chương trình cơ sở có trình điều khiển như vậy hiện diện và sửa đổi cách ThinkPad
firmware sẽ hoạt động trong nhiều tình huống.

Trình điều khiển cho phép tự động báo cáo sự kiện HKEY ("phím nóng")
khi được tải và vô hiệu hóa nó khi gỡ bỏ.

Trình điều khiển sẽ báo cáo các sự kiện HKEY theo định dạng sau::

ibm/phím nóng HKEY 00000080 0000xxxx

Một số sự kiện này đề cập đến việc nhấn phím nóng, nhưng không phải tất cả chúng.

Trình điều khiển sẽ tạo các sự kiện trên lớp đầu vào cho các phím nóng và
chuyển mạch vô tuyến và qua lớp liên kết mạng ACPI cho các sự kiện khác.  các
hỗ trợ lớp đầu vào chấp nhận IOCTL tiêu chuẩn để ánh xạ lại mã khóa
được gán cho mỗi phím nóng.

Mặt nạ bit phím nóng cho phép kiểm soát một số phím nóng nào tạo ra
sự kiện.  Nếu một khóa bị "che giấu" (bit được đặt thành 0 trong mặt nạ), phần sụn
sẽ xử lý nó.  Nếu nó bị "vạch mặt", nó sẽ báo hiệu cho phần sụn rằng
thinkpad-acpi muốn xử lý nó hơn, nếu phần sụn như vậy
thật tử tế khi cho phép điều đó (và thường là không!).

Không phải tất cả các bit trong mặt nạ đều có thể được sửa đổi.  Không phải tất cả các bit có thể
sửa đổi làm bất cứ điều gì.  Không phải tất cả các phím nóng đều có thể được điều khiển riêng lẻ
bằng mặt nạ.  Một số mẫu hoàn toàn không hỗ trợ mặt nạ.  Hành vi
do đó, mặt nạ phụ thuộc nhiều vào kiểu máy ThinkPad.

Trình điều khiển sẽ lọc ra mọi phím nóng bị lộ, vì vậy ngay cả khi phần sụn
không cho phép tắt một phím nóng cụ thể, trình điều khiển sẽ không báo cáo
sự kiện cho các phím nóng bị lộ.

Lưu ý rằng việc vạch mặt một số khóa sẽ ngăn chặn hành vi mặc định của chúng.  cho
ví dụ: nếu Fn+F5 bị lộ, phím đó sẽ không bật/tắt nữa
Bluetooth tự nó có trong firmware.

Cũng lưu ý rằng không phải tất cả các tổ hợp phím Fn đều được hỗ trợ thông qua ACPI
tùy thuộc vào kiểu máy ThinkPad và phiên bản phần sụn.  Trên những cái đó
ThinkPads, vẫn có thể hỗ trợ thêm một số phím nóng bằng cách
thăm dò "CMOS NVRAM" ít nhất 10 lần mỗi giây.  Người lái xe
cố gắng kích hoạt chức năng này một cách tự động khi được yêu cầu.

ghi chú procfs
^^^^^^^^^^^^

Các lệnh sau có thể được ghi vào tệp /proc/acpi/ibm/hotkey::

echo 0xffffffff > /proc/acpi/ibm/hotkey - bật tất cả các phím nóng
	echo 0 > /proc/acpi/ibm/hotkey - tắt tất cả các phím nóng có thể
	... any other 8-hex-digit mask ...
echo reset > /proc/acpi/ibm/hotkey -- khôi phục mặt nạ được đề xuất

Các lệnh sau không được dùng nữa và sẽ khiến kernel bị lỗi
để ghi lại cảnh báo::

echo Enable > /proc/acpi/ibm/hotkey -- không làm gì cả
	vô hiệu hóa tiếng vang > /proc/acpi/ibm/hotkey -- trả về lỗi

Giao diện Procfs không hỗ trợ kiểm soát bỏ phiếu NVRAM.  Vì vậy để
duy trì khả năng tương thích giữa các lỗi tối đa, nó không báo cáo bất kỳ mặt nạ nào,
nó cũng không cho phép người ta thao tác với mặt nạ phím nóng khi phần sụn
hoàn toàn không hỗ trợ mặt nạ, ngay cả khi tính năng bỏ phiếu NVRAM đang được sử dụng.

ghi chú sysfs
^^^^^^^^^^^

hotkey_bios_enabled:
		DEPRECATED, WILL LÀ REMOVED SOON.

Trả về 0.

hotkey_bios_mask:
		DEPRECATED, DON'T USE, WILL ĐƯỢC REMOVED TRONG THE FUTURE.

Trả về mặt nạ phím nóng khi thinkpad-acpi được tải.
		Sau khi dỡ mô-đun, mặt nạ phím nóng sẽ được khôi phục
		đến giá trị này.   Đây luôn là 0x80c, bởi vì đó là
		các phím nóng được hỗ trợ bởi phần mềm cổ xưa
		không có sự hỗ trợ của mặt nạ.

hotkey_enable:
		DEPRECATED, WILL LÀ REMOVED SOON.

0: trả về -EPERM
		1: không làm gì cả

hotkey_mask:
		mặt nạ bit để bật báo cáo (và tùy thuộc vào
		phần sụn, tạo sự kiện ACPI) cho mỗi phím nóng
		(xem ở trên).  Trả về trạng thái hiện tại của phím nóng
		mặt nạ và cho phép người ta sửa đổi nó.

hotkey_all_mask:
		mặt nạ bit sẽ cho phép báo cáo sự kiện cho tất cả
		các phím nóng được hỗ trợ, khi được lặp lại với hotkey_mask ở trên.
		Trừ khi bạn biết sự kiện nào cần được xử lý
		một cách thụ động (vì phần sụn ZZ0000ZZ xử lý chúng
		dù sao đi nữa), ZZ0001ZZ có sử dụng hotkey_all_mask không.  sử dụng
		thay vào đó, hotkey_recommending_mask. Bạn đã được cảnh báo.

hotkey_recommending_mask:
		mặt nạ bit sẽ cho phép báo cáo sự kiện cho tất cả
		các phím nóng được hỗ trợ, ngoại trừ những phím luôn
		dù sao cũng được xử lý bởi phần sụn.  Echo nó tới
		hotkey_mask ở trên để sử dụng.  Đây là mặt nạ mặc định
		người lái xe sử dụng.

hotkey_source_mask:
		mặt nạ bit chọn phím nóng nào sẽ dành cho trình điều khiển
		thăm dò ý kiến ​​NVRAM.  Điều này được trình điều khiển tự động phát hiện
		dựa trên các khả năng được báo cáo bởi phần sụn ACPI,
		nhưng nó có thể bị ghi đè khi chạy.

Các phím nóng có bit được đặt trong hotkey_source_mask là
		được thăm dò trong NVRAM và được báo cáo là sự kiện phím nóng nếu
		được bật trong hotkey_mask.  Chỉ có một số phím nóng
		có sẵn thông qua bỏ phiếu CMOS NVRAM.

Cảnh báo: khi ở chế độ NVRAM, tăng/giảm/tắt âm lượng
		các phím được tổng hợp theo những thay đổi trong bộ trộn,
		sử dụng một phím nóng tăng hoặc giảm âm lượng
		nhấn để bật tiếng, theo người dùng bộ trộn âm lượng ThinkPad
		giao diện.  Khi ở chế độ sự kiện ACPI, tăng/giảm/tắt âm lượng
		các sự kiện được phần mềm cơ sở báo cáo và có thể hoạt động
		khác nhau (và hành vi đó thay đổi theo phần sụn
		phiên bản -- không chỉ với các mẫu phần mềm -- cũng như
		Trạng thái OSI(Linux)).

hotkey_poll_freq:
		tần số tính bằng Hz cho việc bỏ phiếu bằng phím nóng. Nó phải ở giữa
		0 và 25Hz.  Việc bỏ phiếu chỉ được thực hiện khi nghiêm túc
		cần thiết.

Đặt hotkey_poll_freq thành 0 sẽ vô hiệu hóa việc bỏ phiếu và
		sẽ gây ra các thao tác nhấn phím nóng yêu cầu bỏ phiếu NVRAM
		để không bao giờ được báo cáo.

Đặt hotkey_poll_freq quá thấp có thể gây ra lặp lại
		việc nhấn cùng một phím nóng sẽ bị báo cáo sai là
		nhấn một phím hoặc thậm chí không bị phát hiện.
		Tần số bỏ phiếu được đề xuất là 10Hz.

hotkey_radio_sw:
		Nếu ThinkPad có bộ chuyển mạch radio phần cứng thì điều này
		thuộc tính sẽ đọc 0 nếu công tắc ở trong "radio
		vị trí bị vô hiệu hóa" và 1 nếu công tắc ở vị trí
		vị trí "bật radio".

Thuộc tính này có hỗ trợ poll()/select().

hotkey_tablet_mode:
		Nếu ThinkPad có khả năng của máy tính bảng, thuộc tính này
		sẽ đọc 0 nếu ThinkPad ở chế độ bình thường và
		1 nếu ThinkPad ở chế độ máy tính bảng.

Thuộc tính này có hỗ trợ poll()/select().

Wakeup_reason:
		Đặt thành 1 nếu hệ thống thức dậy vì người dùng
		đã yêu cầu phóng vịnh.  Đặt thành 2 nếu hệ thống
		thức dậy vì người dùng yêu cầu hệ thống
		tháo dây.  Đặt về 0 cho chế độ đánh thức hoặc đánh thức thông thường
		vì lý do không rõ.

Thuộc tính này có hỗ trợ poll()/select().

Wakeup_hotunplug_complete:
		Đặt thành 1 nếu hệ thống được đánh thức vì một
		yêu cầu tháo rời hoặc tháo dỡ và yêu cầu đó
		đã được hoàn thành thành công.  Tại thời điểm này, có thể
		hữu ích trong việc đưa hệ thống trở lại chế độ ngủ vào lúc
		sự lựa chọn của người dùng.  Tham khảo các sự kiện HKEY 0x4003 và
		0x3003, bên dưới.

Thuộc tính này có hỗ trợ poll()/select().

ghi chú lớp đầu vào
^^^^^^^^^^^^^^^^^

Phím nóng được ánh xạ tới một sự kiện EV_KEY của lớp đầu vào duy nhất, có thể
theo sau là sự kiện EV_MSC MSC_SCAN sẽ chứa quá trình quét của khóa đó
mã.  Một sự kiện EV_SYN sẽ luôn được tạo ra để đánh dấu sự kết thúc của
khối sự kiện.

Không sử dụng các sự kiện EV_MSC MSC_SCAN để xử lý khóa.  Họ phải là
chỉ được sử dụng như một trợ giúp để ánh xạ lại các phím.  Chúng đặc biệt hữu ích khi
ánh xạ lại các phím KEY_UNKNOWN.

Các sự kiện có sẵn trong một thiết bị đầu vào, với id sau:

================================================
	Xe buýt BUS_HOST
	nhà cung cấp 0x1014 (PCI_VENDOR_ID_IBM) hoặc
			0x17aa (PCI_VENDOR_ID_LENOVO)
	sản phẩm 0x5054 ("TP")
	phiên bản 0x4101
	================================================

Phiên bản sẽ tăng LSB nếu sơ đồ bàn phím thay đổi theo
cách tương thích ngược.  MSB sẽ luôn là 0x41 cho đầu vào này
thiết bị.  Nếu MSB không phải là 0x41, không sử dụng thiết bị như mô tả trong
phần này, vì nó là một thứ khác (ví dụ: một thiết bị đầu vào khác
được xuất bởi trình điều khiển thinkpad, chẳng hạn như HDAPS) hoặc chức năng của nó có
đã được thay đổi theo cách không tương thích ngược.

Việc thêm các loại sự kiện khác cho các chức năng khác sẽ được coi là một
thay đổi tương thích ngược cho thiết bị đầu vào này.

Bản đồ sự kiện Thinkpad-acpi Hot Key (phiên bản 0x4101):

============== =================================================================
Quét ACPI
mã sự kiện Ghi chú chính
============== =================================================================
0x1001 0x00FN+F1 -

0x1002 0x01 FN+F2 IBM: pin (hiếm)
				Lenovo: Khóa màn hình

0x1003 0x02 FN+F3 Nhiều mẫu IBM luôn báo cáo
				phím nóng này, kể cả với phím nóng
				bị vô hiệu hóa hoặc bị che Fn+F3
				tắt
				IBM: khóa màn hình, thường xuyên quay
				tắt ThinkLight là tác dụng phụ
				Lenovo: pin

0x1004 0x03 FN+F4 Nút ngủ (Nút ngủ ACPI
				ngữ nghĩa, tức là ngủ tới RAM).
				Nó luôn tạo ra một số loại
				của sự kiện, hoặc là phím nóng
				sự kiện hoặc nút ngủ ACPI
				sự kiện. Phần sụn có thể
				từ chối tạo thêm FN+F4
				nhấn phím cho đến khi S3 hoặc S4 ACPI
				chu kỳ giấc ngủ được thực hiện hoặc một số
				thời gian trôi qua.

Đài phát thanh 0x1005 0x04 FN + F5.  Bật/tắt
				phần cứng Bluetooth bên trong
				và thẻ W-WAN nếu được kiểm soát
				của phần sụn.  Không ảnh hưởng
				thẻ WLAN.
				Nên dùng để bật/tắt tất cả
				bộ đàm (Bluetooth+W-WAN+WLAN),
				thực sự.

0x1006 0x05FN+F6 -

0x1007 0x06 FN+F7 Chu kỳ đầu ra video.
				Hôm nay bạn có cảm thấy may mắn không?

0x1008 0x07 FN+F8 IBM: mở rộng màn hình chuyển đổi
				Lenovo: cấu hình UltraNav,
				hoặc chuyển đổi màn hình mở rộng.
				Trên nền tảng 2024 được thay thế bằng
				0x131f (xem bên dưới) và mới hơn
				mã khóa nền tảng (2025 +) là
				được thay thế bằng 0x1401 (xem bên dưới).

0x1009 0x08FN+F9 -

...	...	...		...

0x100B 0x0A FN+F11 -

0x100C 0x0B FN+F12 Ngủ trên đĩa.  Bạn luôn luôn
				lẽ ra phải tự mình giải quyết,
				thông qua sự kiện ACPI,
				hoặc thông qua một sự kiện phím nóng.
				Phần sụn có thể từ chối
				tạo thêm khóa FN+F12
				nhấn sự kiện cho đến S3 hoặc S4
				Chu kỳ ngủ ACPI được thực hiện,
				hoặc một thời gian nào đó trôi qua.

0x100D 0x0C FN+BACKSPACE -
0x100E 0x0D FN+INSERT -
0x100F 0x0E FN+DELETE -

0x1010 0x0F FN+HOME Tăng độ sáng.  Chìa khóa này là
				luôn được xử lý bởi phần sụn
				trong IBM ThinkPads, ngay cả khi
				lộ mặt.  Cứ để nó yên.
				Dành cho Lenovo ThinkPads với tính năng mới
				BIOS, nó cũng phải được xử lý
				bởi ACPI OSI hoặc theo không gian người dùng.
				Lái xe làm đúng rồi
				không bao giờ lộn xộn với điều này.
0x1011 0x10 FN+END Giảm độ sáng.  Xem độ sáng
				lên để biết chi tiết.

Chuyển đổi ThinkLight 0x1012 0x11 FN+PGUP.  Chìa khóa này là
				luôn được xử lý bởi phần sụn,
				ngay cả khi bị vạch trần.

0x1013 0x12FN+PGDOWN -

0x1014 0x13 FN+SPACE Phím thu phóng

0x1015 0x14 VOLUME UP Tăng âm lượng bộ trộn bên trong. Cái này
				khóa luôn được xử lý bởi
				phần sụn, ngay cả khi bị lộ.
				NOTE: Lenovo dường như đang thay đổi
				cái này.
0x1016 0x15 VOLUME DOWN Tăng âm lượng bộ trộn bên trong. Cái này
				khóa luôn được xử lý bởi
				phần sụn, ngay cả khi bị lộ.
				NOTE: Lenovo dường như đang thay đổi
				cái này.
0x1017 0x16 MUTE Tắt tiếng bộ trộn bên trong. Cái này
				khóa luôn được xử lý bởi
				phần sụn, ngay cả khi bị lộ.

0x1018 0x17 THINKPAD Phím ThinkPad/Truy cập IBM/Lenovo

0x1019 0x18 không xác định

0x131f ... Thay đổi Chế độ nền tảng FN+F8 (hệ thống 2024).
				Thực hiện trong trình điều khiển.

0x1401 ... Thay đổi Chế độ nền tảng FN+F8 (hệ thống 2025 +).
				Thực hiện trong trình điều khiển.
...	...	...

0x1020 0x1F không xác định
============== =================================================================

Firmware của ThinkPad không cho phép phân biệt khi nào nóng nhất
các phím được nhấn hoặc nhả (hoặc là vậy, hoặc chúng tôi chưa biết cách thực hiện).
Đối với các phím này, trình điều khiển tạo ra một tập hợp các sự kiện cho một lần nhấn phím và
ngay lập tức đưa ra cùng một tập hợp các sự kiện cho một bản phát hành chính.  Đó là
trình điều khiển không xác định liệu phần sụn ThinkPad có kích hoạt những sự kiện này trên
nhấn hoặc nhả phím nóng, nhưng phần sụn sẽ thực hiện việc đó cho một trong hai chứ không phải
cả hai.

Nếu một khóa được ánh xạ tới KEY_RESERVED, nó sẽ không tạo ra sự kiện đầu vào nào cả.
Nếu một khóa được ánh xạ tới KEY_UNKNOWN, nó sẽ tạo ra một sự kiện đầu vào
bao gồm một mã quét.  Nếu một khóa được ánh xạ tới bất cứ thứ gì khác, nó sẽ
tạo ra các sự kiện EV_KEY của thiết bị đầu vào.

Ngoài sự kiện EV_KEY, thinkpad-acpi cũng có thể phát hành EV_SW
sự kiện cho switch:

=================================================================
SW_RFKILL_ALL T60 và công tắc rocker rfkill phần cứng mới hơn
SW_TABLET_MODE Tablet ThinkPads HKEY sự kiện 0x5009 và 0x500A
=================================================================

Bản đồ sự kiện ACPI HKEY không phải phím nóng
------------------------------

Các sự kiện không bao giờ được truyền bá bởi trình điều khiển:

====== =======================================================
0x2304 Hệ thống đang thức dậy từ trạng thái tạm dừng đến khi tháo gỡ
0x2305 Hệ thống đang thức dậy từ trạng thái tạm dừng đến khoang đẩy ra
0x2404 Hệ thống đang thức dậy từ chế độ ngủ đông đến tháo gỡ
0x2405 Hệ thống đang thức dậy từ trạng thái ngủ đông đến khoang đẩy ra
0x5001 Nắp đóng
0x5002 Nắp đã mở
0x5009 Xoay máy tính bảng: chuyển sang chế độ máy tính bảng
Xoay máy tính bảng 0x500A: chuyển sang chế độ bình thường
0x5010 Sự kiện kiểm soát/thay đổi mức độ sáng
0x6000 KEYBOARD: Đã nhấn phím Numlock
0x6005 KEYBOARD: Nhấn phím Fn (TO BE VERIFIED)
Công tắc vô tuyến 0x7000 có thể đã thay đổi trạng thái
====== =======================================================


Các sự kiện được trình điều khiển truyền tới không gian người dùng:

====== ==========================================================
0x2313 ALARM: Hệ thống đang thức dậy sau khi tạm dừng vì
		pin gần hết
0x2413 ALARM: Hệ thống đang thức dậy sau chế độ ngủ đông vì
		pin gần hết
Quá trình phóng 0x3003 Bay (xem 0x2x05) đã hoàn tất, có thể ngủ lại
Yêu cầu cắm nóng 0x3006 Bay (gợi ý cấp nguồn cho liên kết SATA khi
		khay ổ đĩa quang được đẩy ra)
0x4003 Đã được tháo neo (xem 0x2x04), có thể ngủ lại
0x4010 Được gắn vào bộ sao chép cổng hotplug (đế cắm không phải ACPI)
0x4011 Đã được tháo khỏi bộ sao chép cổng cắm nóng (đế cắm không phải ACPI)
0x500B Bút máy tính bảng được lắp vào khoang lưu trữ của nó
Bút máy tính bảng 0x500C được lấy ra khỏi khoang lưu trữ
0x6011 ALARM: pin quá nóng
0x6012 ALARM: pin cực nóng
0x6021 ALARM: cảm biến quá nóng
0x6022 ALARM: cảm biến cực kỳ nóng
0x6030 Bảng nhiệt hệ thống đã thay đổi
Hoàn thành bộ lệnh điều khiển nhiệt 0x6032 (DYTC, Windows)
0x6040 Nvidia Optimus/bộ chuyển đổi AC liên quan (TO BE VERIFIED)
0x60C0 X1 Yoga 2016, trạng thái chế độ máy tính bảng đã thay đổi
Biến đổi nhiệt 0x60F0 đã thay đổi (GMTS, Windows)
====== ==========================================================

Báo động gần hết pin là nỗ lực cuối cùng để có được
hệ điều hành ngủ đông hoặc tắt máy hoàn toàn (0x2313) hoặc tắt máy
sạch sẽ (0x2413) trước khi mất điện.  Chúng phải được xử lý, với tư cách là
việc thức dậy do phần sụn gây ra sẽ vô hiệu hóa hầu hết các mạng lưới an toàn...

Theo người dùng Lenovo, khi xảy ra bất kỳ cảnh báo "quá nóng" nào
nên tạm dừng hoặc ngủ đông máy tính xách tay (và trong trường hợp hết pin
báo động, hãy rút phích cắm bộ đổi nguồn AC) để nguội.  Những báo động này làm
báo hiệu rằng có điều gì đó không ổn, chúng sẽ không bao giờ xảy ra một cách bình thường
điều kiện hoạt động.

Báo động "cực nóng" là trường hợp khẩn cấp.  Theo Lenovo,
hệ điều hành buộc phải tạm dừng ngay lập tức hoặc ngủ đông
chu kỳ hoặc tắt hệ thống.  Rõ ràng là có điều gì đó không ổn nếu điều này
xảy ra.


Ghi chú phím nóng độ sáng
^^^^^^^^^^^^^^^^^^^^^^^

Đừng lộn xộn với các phím nóng độ sáng trong Thinkpad.  Nếu bạn muốn
thông báo cho OSD, hãy sử dụng hỗ trợ sự kiện lớp đèn nền sysfs.

Trình điều khiển sẽ đưa ra các sự kiện KEY_BRIGHTNESS_UP và KEY_BRIGHTNESS_DOWN
tự động đối với các trường hợp không gian người dùng phải làm gì đó để
thực hiện thay đổi độ sáng.  Khi bạn ghi đè những sự kiện này, bạn sẽ
hoặc không xử lý đúng cách các ThinkPad yêu cầu rõ ràng
hành động để thay đổi độ sáng đèn nền hoặc những chiếc ThinkPad yêu cầu
rằng không có hành động nào được thực hiện để hoạt động đúng cách.


Bluetooth
---------

giao thức: /proc/acpi/ibm/bluetooth

Thuộc tính thiết bị sysfs: bluetooth_enable (không dùng nữa)

Lớp rfkill sysfs: chuyển "tpacpi_bluetooth_sw"

Tính năng này cho thấy sự hiện diện và trạng thái hiện tại của ThinkPad
Thiết bị Bluetooth trong khe cắm ThinkPad CDC bên trong.

Nếu ThinkPad hỗ trợ nó, trạng thái Bluetooth sẽ được lưu trữ trong NVRAM,
vì vậy nó được giữ trong suốt quá trình khởi động lại và tắt nguồn.

Ghi chú của Procfs
^^^^^^^^^^^^

Nếu Bluetooth được cài đặt, có thể sử dụng các lệnh sau ::

bật tiếng vang> /proc/acpi/ibm/bluetooth
	vô hiệu hóa tiếng vang> /proc/acpi/ibm/bluetooth

Ghi chú hệ thống
^^^^^^^^^^^

Nếu thẻ Bluetooth CDC được cài đặt, nó có thể được bật /
	bị vô hiệu hóa thông qua thiết bị thinkpad-acpi "bluetooth_enable"
	thuộc tính và trạng thái hiện tại của nó cũng có thể được truy vấn.

cho phép:

- 0: vô hiệu hóa Bluetooth / Bluetooth bị vô hiệu hóa
		- 1: bật Bluetooth / Bluetooth được bật.

Lưu ý: giao diện này đã được thay thế bằng rfkill chung
	lớp học.  Nó không được dùng nữa và sẽ bị xóa sau năm
	2010.

công tắc bộ điều khiển rfkill "tpacpi_bluetooth_sw": tham khảo
	Tài liệu/driver-api/rfkill.rst để biết chi tiết.


Kiểm soát đầu ra video -- /proc/acpi/ibm/video
--------------------------------------------

Tính năng này cho phép kiểm soát các thiết bị được sử dụng để xuất video -
LCD, CRT hoặc DVI (nếu có). Các lệnh sau có sẵn::

echo lcd_enable > /proc/acpi/ibm/video
	echo lcd_disable > /proc/acpi/ibm/video
	echo crt_enable > /proc/acpi/ibm/video
	echo crt_disable > /proc/acpi/ibm/video
	echo dvi_enable > /proc/acpi/ibm/video
	echo dvi_disable > /proc/acpi/ibm/video
	echo auto_enable > /proc/acpi/ibm/video
	echo auto_disable > /proc/acpi/ibm/video
	echo Expand_toggle > /proc/acpi/ibm/video
	echo video_switch > /proc/acpi/ibm/video

NOTE:
  Quyền truy cập vào tính năng này bị hạn chế đối với các quy trình sở hữu
  Khả năng của CAP_SYS_ADMIN vì lý do an toàn, vì nó có thể tương tác xấu
  đủ với một số phiên bản X.org để làm hỏng nó.

Mỗi thiết bị đầu ra video có thể được bật hoặc tắt riêng lẻ.
Đọc /proc/acpi/ibm/video hiển thị trạng thái của từng thiết bị.

Chuyển đổi video tự động có thể được bật hoặc tắt.  Khi tự động
chuyển đổi video được bật, một số sự kiện nhất định (ví dụ: mở nắp,
gắn hoặc tháo đế) khiến thiết bị đầu ra video thay đổi
tự động. Mặc dù điều này có thể hữu ích nhưng nó cũng gây ra hiện tượng nhấp nháy
và trên X40, video bị hỏng. Bằng cách vô hiệu hóa chuyển đổi tự động,
có thể tránh được hiện tượng nhấp nháy hoặc hỏng video.

Lệnh video_switch chuyển qua các đầu ra video có sẵn
(nó mô phỏng hành vi của Fn-F7).

Việc mở rộng video có thể được chuyển đổi thông qua tính năng này. Điều khiển này
liệu màn hình có được mở rộng để lấp đầy toàn bộ màn hình LCD hay không khi
chế độ có độ phân giải nhỏ hơn đầy đủ được sử dụng. Lưu ý rằng hiện tại
Không thể xác định trạng thái mở rộng video thông qua tính năng này.

Lưu ý rằng trên nhiều mẫu máy (đặc biệt là những mẫu sử dụng đồ họa Radeon
chip), trình điều khiển X định cấu hình card màn hình theo cách ngăn chặn
Fn-F7 không hoạt động. Điều này cũng vô hiệu hóa việc chuyển đổi đầu ra video
tính năng của trình điều khiển này, vì nó sử dụng các phương pháp ACPI tương tự như
Fn-F7. Chuyển đổi video trên bảng điều khiển vẫn hoạt động.

UPDATE: tham khảo ZZ0000ZZ


Điều khiển ThinkLight
------------------

giao thức: /proc/acpi/ibm/light

Thuộc tính sysfs: theo lớp LED, dành cho "tpacpi::thinklight" LED

ghi chú procfs
^^^^^^^^^^^^

Trạng thái ThinkLight có thể được đọc và thiết lập thông qua giao diện Procfs.  A
một số mẫu máy không có sẵn trạng thái sẽ hiển thị ThinkLight
trạng thái là "không xác định". Các lệnh có sẵn là::

bật lại > /proc/acpi/ibm/light
	tắt tiếng vang > /proc/acpi/ibm/light

ghi chú sysfs
^^^^^^^^^^^

Giao diện sysfs ThinkLight được ghi lại bởi lớp LED
tài liệu, trong Documentation/leds/leds-class.rst.  Tên ThinkLight LED
là "tpacpi::thinklight".

Do những hạn chế trong lớp LED của sysfs, nếu trạng thái của ThinkLight
không thể đọc được hoặc nếu không xác định được, thinkpad-acpi sẽ báo cáo là "tắt".
Không thể biết trạng thái được trả về thông qua sysfs có hợp lệ hay không.


Điều khiển CMOS/UCMS
-----------------

giao thức: /proc/acpi/ibm/cmos

Thuộc tính thiết bị sysfs: cmos_command

Tính năng này chủ yếu được sử dụng nội bộ bởi phần sụn ACPI để duy trì tính kế thừa
Các bit CMOS NVRAM đồng bộ với trạng thái máy hiện tại và để ghi lại điều này
trạng thái để ThinkPad sẽ giữ lại các cài đặt như vậy trong suốt quá trình khởi động lại.

Một số lệnh này thực sự thực hiện các hành động trong một số kiểu máy ThinkPad, nhưng
điều này dự kiến sẽ ngày càng biến mất trong các mẫu máy mới hơn.  Như một ví dụ, trong
T43 và trong X40, lệnh 12 và 13 vẫn kiểm soát trạng thái ThinkLight cho
có thật, nhưng các lệnh từ 0 đến 2 không điều khiển bộ trộn nữa (chúng đã được
loại bỏ) và chỉ cập nhật NVRAM.

Phạm vi số lệnh cmos hợp lệ là từ 0 đến 21, nhưng không phải tất cả đều có
hiệu ứng và hành vi khác nhau tùy theo mô hình.  Đây là hành vi
trên X40 (tpb là tiện ích Nút ThinkPad):

- 0 - Liên quan đến việc nhấn phím "Giảm âm lượng"
	- 1 - Liên quan đến việc nhấn phím "Tăng âm lượng"
	- 2 - Liên quan đến việc nhấn phím "Mute on"
	- 3 - Liên quan đến thao tác nhấn phím "Access IBM"
	- 4 - Liên quan đến thao tác nhấn phím "LCD tăng độ sáng"
	- 5 - Liên quan đến thao tác nhấn phím "Giảm độ sáng LCD"
	- 11 - Liên quan đến chức năng/bấm phím "chuyển đổi mở rộng màn hình"
	- 12 - Liên quan đến "Bật ThinkLight"
	- 13 - Liên quan đến "Tắt ThinkLight"
	- 14 - Liên quan đến thao tác bấm phím "ThinkLight" (chuyển đổi ThinkLight)

Giao diện lệnh cmos dễ gặp phải các vấn đề về phân chia phần sụn, như
trong những chiếc ThinkPad mới hơn, nó chỉ là một lớp tương thích.  Đừng sử dụng nó, nó là
được xuất giống như một công cụ gỡ lỗi.


Điều khiển LED
-----------

giao thức: /proc/acpi/ibm/led
thuộc tính sysfs: theo lớp LED, xem bên dưới để biết tên

Một số chỉ báo LED có thể được điều khiển thông qua tính năng này.  Bật
một số mẫu ThinkPad cũ hơn, có thể truy vấn trạng thái của
Các chỉ báo LED cũng vậy.  ThinkPad mới hơn không thể truy vấn trạng thái thực
của các chỉ số LED.

Bởi vì việc sử dụng sai đèn LED có thể khiến người dùng không nhận thức được thực hiện
các hành động nguy hiểm (như tháo đế hoặc đẩy thiết bị bay ra trong khi
xe buýt vẫn đang hoạt động), hoặc che giấu một báo động quan trọng (chẳng hạn như gần
hết pin hoặc pin bị hỏng), khả năng truy cập vào hầu hết các đèn LED là
bị hạn chế.

Quyền truy cập không hạn chế vào tất cả các đèn LED yêu cầu thinkpad-acpi phải
được biên dịch với tùy chọn CONFIG_THINKPAD_ACPI_UNSAFE_LEDS được bật.
Các bản phân phối không bao giờ được kích hoạt tùy chọn này.  Người dùng cá nhân mà
nhận thức được hậu quả đều được hoan nghênh khi kích hoạt nó.

Đèn LED tắt âm thanh và tắt tiếng micrô được hỗ trợ, nhưng hiện tại thì không
hiển thị với không gian người dùng. Chúng được sử dụng bởi trình điều khiển âm thanh snd-hda-intel.

ghi chú procfs
^^^^^^^^^^^^

Các lệnh có sẵn là::

echo '<LED number> on' >/proc/acpi/ibm/led
	echo '<LED number> tắt' >/proc/acpi/ibm/led
	echo '<LED number> nhấp nháy' >/proc/acpi/ibm/led

Phạm vi <LED number> là từ 0 đến 15. Bộ đèn LED có thể
được kiểm soát khác nhau tùy theo mô hình. Đây là ThinkPad thông dụng
lập bản đồ:

- 0 - nguồn
	- 1 - pin (màu cam)
	- 2 - pin (xanh)
	- 3 - UltraBase/dock
	- 4 - UltraBay
	- 5 - Khe cắm pin UltraBase
	- 6 - (không rõ)
	- 7 - chờ
	- 8 - trạng thái bến tàu 1
	- 9 - trạng thái bến tàu 2
	- 10, 11 - (không rõ)
	- 12 - suy nghĩ
	- 13, 14, 15 - (không rõ)

Tất cả những điều trên có thể được bật và tắt và có thể được thực hiện để nhấp nháy.

ghi chú sysfs
^^^^^^^^^^^

Giao diện sysfs của ThinkPad LED được mô tả chi tiết theo lớp LED
tài liệu, trong Documentation/leds/leds-class.rst.

Các đèn LED được đặt tên (theo thứ tự ID LED, từ 0 đến 12):
"tpacpi::power", "tpacpi:orange:batt", "tpacpi:green:batt",
"tpacpi::dock_active", "tpacpi::bay_active", "tpacpi::dock_batt",
"tpacpi::unknown_led", "tpacpi::standby", "tpacpi::dock_status1",
"tpacpi::dock_status2", "tpacpi::unknown_led2", "tpacpi::unknown_led3",
"tpacpi::thinkvantage".

Do những hạn chế trong lớp LED của sysfs, nếu trạng thái của LED
không thể đọc được các chỉ báo do lỗi, thinkpad-acpi sẽ báo cáo là
độ sáng bằng 0 (giống như tắt LED).

Nếu chương trình cơ sở thinkpad không hỗ trợ đọc trạng thái hiện tại,
cố gắng đọc độ sáng LED hiện tại sẽ trả về bất cứ thứ gì
độ sáng được ghi lần cuối vào thuộc tính đó.

Những đèn LED này có thể nhấp nháy bằng cách tăng tốc phần cứng.  Để yêu cầu rằng một
Đèn báo ThinkPad LED sẽ nhấp nháy ở chế độ tăng tốc phần cứng, hãy sử dụng
kích hoạt "hẹn giờ" và đặt tham số delay_on và delay_off thành
0 (để yêu cầu tự động phát hiện tăng tốc phần cứng).

Đèn LED được biết là không tồn tại trong một mẫu ThinkPad cụ thể thì không
được cung cấp thông qua giao diện sysfs.  Nếu bạn có một bến tàu và bạn
lưu ý rằng có những đèn LED được liệt kê cho ThinkPad của bạn không tồn tại (và
không có trong đế) hoặc nếu bạn nhận thấy thiếu đèn LED,
báo cáo tới ibm-acpi-devel@lists.sourceforge.net được đánh giá cao.


Âm thanh ACPI -- /proc/acpi/ibm/beep
----------------------------------

Phương pháp BEEP được sử dụng nội bộ bởi phần sụn ACPI để cung cấp
cảnh báo bằng âm thanh trong các tình huống khác nhau. Tính năng này cho phép tương tự
âm thanh được kích hoạt bằng tay.

Các lệnh là số nguyên không âm::

echo <number> >/proc/acpi/ibm/beep

Phạm vi <number> hợp lệ là từ 0 đến 17. Không phải tất cả các số đều phát ra âm thanh
và âm thanh khác nhau tùy theo mẫu máy. Đây là hành vi trên
X40:

- 0 - dừng âm thanh đang diễn ra (nhưng sử dụng 17 để dừng 16)
	- 2 - hai tiếng bíp, tạm dừng, tiếng bíp thứ ba ("pin yếu")
	- 3 - tiếng bíp đơn
	- 4 - cao, theo sau là tiếng bíp nhỏ ("không thể")
	- 5 - tiếng bíp đơn
	- 6 - rất cao, theo sau là tiếng bíp the thé ("AC/DC")
	- 7 - tiếng bíp the thé
	- 9 - ba tiếng bíp ngắn
	- 10 - tiếng bíp rất dài
	- 12 - tiếng bíp trầm
	- 15 - ba tiếng bíp the thé lặp đi lặp lại liên tục, dừng lại ở số 0
	- 16 - một tiếng bíp vừa phải lặp đi lặp lại liên tục, dừng ở số 17
	- 17 - dừng 16


Cảm biến nhiệt độ
-------------------

Procfs: /proc/acpi/ibm/thermal

Thuộc tính thiết bị sysfs: (hwmon "thinkpad") temp*_input

Hầu hết các ThinkPad đều có sáu cảm biến nhiệt độ riêng biệt trở lên nhưng chỉ
phơi bày nhiệt độ CPU thông qua các phương pháp ACPI tiêu chuẩn.  Cái này
tính năng hiển thị số đọc từ tối đa tám cảm biến khác nhau trên thiết bị cũ hơn
ThinkPad và tới 16 cảm biến khác nhau trên ThinkPad mới hơn.

Ví dụ: trên X40, đầu ra thông thường có thể là:

nhiệt độ:
	42 42 45 41 36 -128 33 -128

Trên T43/p, đầu ra thông thường có thể là:

nhiệt độ:
	48 48 36 52 38 -128 31 -128 48 52 48 -128 -128 -128 -128 -128

Việc ánh xạ các cảm biến nhiệt tới các vị trí vật lý khác nhau tùy thuộc vào
mô hình bo mạch hệ thống (và do đó, trên mô hình ThinkPad).

ZZ0000ZZ là một trang wiki công cộng
cố gắng theo dõi các vị trí này cho các mô hình khác nhau.

Hầu hết các mô hình (mới hơn?) dường như tuân theo mô hình này:

-1: CPU
- 2: (tùy model)
- 3: (tùy model)
- 4: GPU
- 5: Pin chính: cảm biến chính
- 6: Bay pin: cảm biến chính
- 7: Pin chính: cảm biến phụ
- 8: Bay pin: cảm biến phụ
- 9-15: (tùy mẫu)

Đối với R51 (nguồn: Thomas Gruber):

- 2: Mini-PCI
- 3: HDD nội bộ

Dành cho T43, T43/p (nguồn: Shmidoax/Thinkwiki.org)
ZZ0000ZZ

- 2: Bo mạch hệ thống, bên trái (gần khe PCMCIA), báo cáo là nhiệt độ HDAPS
- 3: Khe PCMCIA
- 9: MCH (cầu bắc) tới xe buýt DRAM
- 10: Clock-generator, mini-pci card và ICH (southbridge), thuộc Mini-PCI
      thẻ, dưới bàn di chuột
- 11: Bộ điều chỉnh nguồn, mặt dưới bo mạch hệ thống, phía dưới phím F2

A31 có bố cục rất không điển hình cho cảm biến nhiệt
(nguồn: Milos Popovic, ZZ0000ZZ

-1: CPU
- 2: Pin chính: cảm biến chính
- 3: Bộ chuyển đổi nguồn
- 4: Bay Pin: cảm biến chính
- 5: MCH (cầu bắc)
- 6: PCMCIA/môi trường xung quanh
- 7: Pin chính: cảm biến phụ
- 8: Bay Pin: cảm biến phụ


Ghi chú của Procfs
^^^^^^^^^^^^

Các kết quả đọc từ cảm biến không có sẵn sẽ trả về -128.
	Không có lệnh nào có thể được ghi vào tập tin này.

Ghi chú hệ thống
^^^^^^^^^^^

Các cảm biến không khả dụng sẽ trả về lỗi ENXIO.  Cái này
	trạng thái có thể thay đổi trong thời gian chạy, vì có phích cắm nhiệt
	cảm biến, giống như những cảm biến bên trong pin và đế cắm.

cảm biến nhiệt thinkpad-acpi được báo cáo thông qua hwmon
	hệ thống con và tuân theo tất cả các hướng dẫn của hwmon tại
	Tài liệu/hwmon.

EXPERIMENTAL: Kết xuất thanh ghi bộ điều khiển nhúng
-----------------------------------------------

Tính năng này không còn có trong trình điều khiển thinkpad nữa.
Thay vào đó, EC có thể được truy cập thông qua /sys/kernel/debug/ec với
một công cụ không gian người dùng có thể tìm thấy ở đây:
ftp://ftp.suse.com/pub/people/trenn/sources/ec

Sử dụng nó để xác định thanh ghi giữ quạt
tốc độ trên một số mô hình. Để làm điều đó, hãy làm như sau:

- đảm bảo pin đã được sạc đầy
	- đảm bảo quạt đang chạy
	- sử dụng công cụ được đề cập ở trên để đọc EC

Thông thường giá trị quạt và nhiệt độ khác nhau giữa
bài đọc. Vì nhiệt độ không thay đổi nhanh nên bạn có thể lấy
một số bãi chứa nhanh chóng để loại bỏ chúng.

Bạn có thể sử dụng phương pháp tương tự để tìm ra ý nghĩa của các từ khác
thanh ghi bộ điều khiển nhúng - ví dụ: đảm bảo không có gì khác thay đổi
ngoại trừ việc sạc hoặc xả pin để xác định
các thanh ghi chứa dung lượng pin hiện tại, v.v. Nếu bạn thử nghiệm
với điều này, hãy gửi cho tôi kết quả của bạn (bao gồm một số kết xuất hoàn chỉnh với
mô tả về các điều kiện khi chúng được thực hiện.)


Điều khiển độ sáng LCD
----------------------

Procfs: /proc/acpi/ibm/brightness

thiết bị đèn nền sysfs "thinkpad_screen"

Tính năng này cho phép phần mềm kiểm soát độ sáng LCD trên ThinkPad
những mẫu máy không có thanh trượt độ sáng phần cứng.

Nó có một số hạn chế: đèn nền LCD thực sự không thể bật được
bật hoặc tắt bằng giao diện này, nó chỉ điều khiển độ sáng của đèn nền
cấp độ.

Trên IBM (và một số dòng Lenovo trước đó), điều khiển đèn nền
có tám mức độ sáng, từ 0 đến 7. Một số mức
có thể không khác biệt.  Các mẫu Lenovo sau này triển khai ACPI
phương pháp kiểm soát độ sáng đèn nền màn hình có 16 cấp độ, khác nhau.
từ 0 đến 15.

Đối với IBM ThinkPad, có hai giao diện với phần sụn để trực tiếp
kiểm soát độ sáng, EC và UCMS (hoặc CMOS).  Để chọn cái nào nên
được sử dụng, hãy sử dụng tham số mô-đun độ sáng_mode: độ sáng_mode=1 chọn
Chế độ EC, độ sáng_mode=2 chọn chế độ UCMS, độ sáng_mode=3 chọn EC
chế độ có hỗ trợ NVRAM (để ghi nhớ những thay đổi về độ sáng trên
tắt/khởi động lại).

Trình điều khiển cố gắng chọn giao diện nào sẽ sử dụng từ bảng
mặc định cho từng kiểu máy ThinkPad.  Nếu chọn sai xin vui lòng
báo cáo đây là lỗi để chúng tôi có thể khắc phục.

Lenovo ThinkPad chỉ hỗ trợ độ sáng_mode=2 (UCMS).

Khi điều khiển độ sáng đèn nền màn hình có sẵn thông qua
giao diện ACPI tiêu chuẩn, tốt nhất nên sử dụng nó thay vì giao diện trực tiếp này
Giao diện dành riêng cho ThinkPad.  Trình điều khiển sẽ vô hiệu hóa bản gốc của nó
giao diện điều khiển độ sáng đèn nền nếu phát hiện ra rằng tiêu chuẩn
Giao diện ACPI có sẵn trong ThinkPad.

Nếu bạn muốn sử dụng điều khiển độ sáng đèn nền thinkpad-acpi
thay vì điều khiển độ sáng đèn nền video ACPI chung cho một số
lý do, bạn nên sử dụng tham số kernel acpi_backlight=vendor.

Tham số mô-đun độ sáng_enable có thể được sử dụng để kiểm soát xem
tính năng kiểm soát độ sáng LCD sẽ được bật khi khả dụng.
độ sáng_enable=0 buộc nó phải bị vô hiệu hóa.  độ sáng_enable=1
buộc nó phải được kích hoạt khi có sẵn, ngay cả khi ACPI tiêu chuẩn
giao diện cũng có sẵn.

Ghi chú của Procfs
^^^^^^^^^^^^

Các lệnh có sẵn là::

echo up >/proc/acpi/ibm/brightness
	echo down >/proc/acpi/ibm/độ sáng
	echo 'level <level>' >/proc/acpi/ibm/brightness

Ghi chú hệ thống
^^^^^^^^^^^

Giao diện được triển khai thông qua lớp sysfs đèn nền, đó là
tài liệu kém vào thời điểm này.

Xác định vị trí thiết bị thinkpad_screen trong /sys/class/backlight và bên trong
nó sẽ có các thuộc tính sau:

độ sáng tối đa:
		Đọc độ sáng tối đa mà phần cứng có thể được đặt thành.
		Mức tối thiểu luôn bằng không.

độ sáng thực tế:
		Đọc độ sáng màn hình được đặt ở thời điểm này.

độ sáng:
		Viết yêu cầu trình điều khiển thay đổi độ sáng thành
		giá trị đã cho.  Các lần đọc sẽ cho bạn biết độ sáng của
		trình điều khiển đang cố gắng đặt màn hình thành khi "nguồn" được đặt
		về 0 và màn hình không bị làm mờ bởi hạt nhân
		sự kiện quản lý năng lượng

quyền lực:
		chế độ quản lý năng lượng, trong đó 0 là "bật hiển thị" và 1 đến 3
		sẽ làm mờ đèn nền màn hình về mức độ sáng 0
		bởi vì thinkpad-acpi thực sự không thể bật đèn nền
		tắt.  Các sự kiện quản lý năng lượng hạt nhân có thể tạm thời
		tăng mức độ quản lý năng lượng hiện tại, tức là họ có thể
		làm mờ màn hình.


WARNING:

Dù bạn làm gì, NOT có bao giờ yêu cầu thay đổi mức độ đèn nền của thinkpad-acpi không
    giao diện và giao diện thay đổi mức độ đèn nền dựa trên ACPI
    (có sẵn trên các BIOS mới hơn và được điều khiển bởi trình điều khiển video Linux ACPI)
    cùng một lúc.  Cả hai sẽ tương tác theo cách xấu, làm những điều buồn cười,
    và có thể làm giảm tuổi thọ của đèn nền bằng cách đá không cần thiết
    mức độ của nó lên xuống ở mọi thay đổi.


Điều khiển âm lượng (Điều khiển âm thanh bảng điều khiển)
--------------------------------------

giao thức: /proc/acpi/ibm/volume

ALSA: "Điều khiển âm thanh bảng điều khiển ThinkPad", ID mặc định: "ThinkPadEC"

NOTE: theo mặc định, giao diện điều khiển âm lượng hoạt động ở chế độ chỉ đọc
chế độ, vì nó được cho là được sử dụng cho mục đích hiển thị trên màn hình.
Chế độ đọc/ghi có thể được kích hoạt thông qua việc sử dụng
Tham số mô-đun "volume_control=1".

NOTE: các bản phân phối được yêu cầu không bật Volume_control theo mặc định, điều này
chỉ nên được thực hiện bởi quản trị viên địa phương.  Giao diện người dùng ThinkPad dành cho
việc điều khiển âm thanh của bảng điều khiển chỉ được thực hiện thông qua các phím âm lượng và đối với
môi trường máy tính để bàn chỉ cung cấp phản hồi trên màn hình hiển thị.
Điều khiển âm lượng phần mềm chỉ nên được thực hiện trong AC97/HDA chính
máy trộn.


Giới thiệu về điều khiển âm thanh của Bảng điều khiển ThinkPad
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

ThinkPad có bộ khuếch đại và mạch tắt tiếng tích hợp để điều khiển
điều khiển tai nghe và loa.  Mạch này nằm sau AC97 chính
hoặc bộ trộn HDA trong đường dẫn âm thanh và dưới sự kiểm soát độc quyền của
phần sụn.

ThinkPad có ba phím nóng đặc biệt để tương tác với bảng điều khiển
Điều khiển âm thanh: tăng âm lượng, giảm âm lượng và tắt tiếng.

Điều đáng lưu ý là chức năng tắt tiếng hoạt động theo cách thông thường (trên
Những chiếc ThinkPad không có "LED tắt tiếng") là:

1. Nhấn tắt tiếng để tắt tiếng.  Nó sẽ tắt tiếng ZZ0000ZZ, bạn có thể nhấn nó như
   nhiều lần tùy thích và âm thanh sẽ bị tắt.

2. Nhấn phím âm lượng để bật tiếng của ThinkPad (nó sẽ _không_
   thay đổi âm lượng, nó sẽ chỉ bật tiếng).

Đây là một thiết kế rất ưu việt khi so sánh với các thiết bị chỉ có phần mềm giá rẻ
giải pháp tắt tiếng được tìm thấy trên máy tính xách tay tiêu dùng thông thường: bạn có thể
hoàn toàn chắc chắn ThinkPad sẽ không gây ra tiếng ồn nếu bạn nhấn nút tắt tiếng
nút, bất kể trạng thái trước đó.

ThinkPad IBM và Lenovo ThinkPad trước đó có mức tăng thay đổi
bộ khuếch đại điều khiển đầu ra loa và tai nghe cũng như phần sụn
cũng xử lý việc điều khiển âm lượng cho tai nghe và loa trên các thiết bị này
ThinkPads không có bất kỳ sự trợ giúp nào từ hệ điều hành (tập sách này
giai đoạn điều khiển tồn tại sau bộ trộn AC97 hoặc HDA chính trong âm thanh
đường dẫn).

Các mẫu Lenovo mới hơn chỉ có tính năng điều khiển tắt tiếng phần sụn và phụ thuộc vào
bộ trộn HDA chính để thực hiện điều khiển âm lượng (được thực hiện bởi người vận hành
hệ thống).  Trong trường hợp này, các phím âm lượng được lọc ra để bật tiếng
nhấn phím (có một số lỗi phần sụn trong khu vực này) và được gửi dưới dạng
nhấn phím thông thường vào hệ điều hành (thinkpad-acpi thì không
có liên quan).


Điều khiển âm lượng ThinkPad-ACPI
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Cách ưa thích để tương tác với điều khiển Console Audio là
Giao diện ALSA.

Giao diện Procfs kế thừa cho phép một người đọc trạng thái hiện tại,
và nếu điều khiển âm lượng được bật, hãy chấp nhận các lệnh sau ::

vang lên >/proc/acpi/ibm/volume
	echo down >/proc/acpi/ibm/volume
	tắt tiếng vang >/proc/acpi/ibm/volume
	bật tiếng vang >/proc/acpi/ibm/volume
	echo 'level <level>' >/proc/acpi/ibm/volume

Phạm vi số <level> là từ 0 đến 14 mặc dù không phải tất cả chúng đều có thể
khác biệt. Để bật âm lượng sau lệnh tắt tiếng, hãy sử dụng
lệnh tăng hoặc giảm (lệnh mức sẽ không bật âm lượng) hoặc
lệnh bật tiếng.

Bạn có thể sử dụng tham số Volume_capabilities để thông báo cho trình điều khiển
liệu thinkpad của bạn có điều khiển âm lượng hay điều khiển chỉ tắt tiếng:
Volume_capabilities=1 dành cho bộ trộn có điều khiển tắt tiếng và âm lượng,
Volume_capabilities=2 dành cho máy trộn chỉ có điều khiển tắt tiếng.

Nếu trình điều khiển phát hiện sai các khả năng dành cho kiểu máy ThinkPad của bạn,
vui lòng báo cáo vấn đề này tới ibm-acpi-devel@lists.sourceforge.net để chúng tôi
có thể cập nhật trình điều khiển.

Có hai chiến lược để kiểm soát âm lượng.  Để chọn cái nào
nên được sử dụng, hãy sử dụng tham số mô-đun Volume_mode: Volume_mode=1
chọn chế độ EC và Volume_mode=3 chọn chế độ EC có hỗ trợ NVRAM
(để các thay đổi về âm lượng/tắt tiếng được ghi nhớ khi tắt máy/khởi động lại).

Trình điều khiển sẽ hoạt động ở chế độ Volume_mode=3 theo mặc định. Nếu điều đó không
hoạt động tốt trên mẫu ThinkPad của bạn, vui lòng báo cáo điều này với
ibm-acpi-devel@lists.sourceforge.net.

Trình điều khiển hỗ trợ các tham số mô-đun ALSA tiêu chuẩn.  Nếu ALSA
bộ trộn bị tắt, trình điều khiển sẽ tắt tất cả chức năng âm lượng.


Điều khiển và giám sát quạt: tốc độ quạt, bật/tắt quạt
---------------------------------------------------------

giao thức: /proc/acpi/ibm/fan

Thuộc tính thiết bị sysfs: (hwmon "thinkpad") fan1_input, pwm1, pwm1_enable, fan2_input

Thuộc tính trình điều khiển sysfs hwmon: fan_watchdog

NOTE NOTE NOTE:
   hoạt động điều khiển quạt bị tắt theo mặc định đối với
   lý do an toàn.  Để kích hoạt chúng, tham số mô-đun "fan_control=1"
   phải được trao cho thinkpad-acpi.

Tính năng này cố gắng hiển thị tốc độ quạt hiện tại, chế độ điều khiển và
dữ liệu người hâm mộ khác có thể có sẵn.  Tốc độ được đọc trực tiếp
từ các thanh ghi phần cứng của bộ điều khiển nhúng.  Điều này được biết
để hoạt động trên các dòng ThinkPad R, T, X và Z sau này nhưng có thể hiển thị lỗi không có thật
giá trị trên các mô hình khác.

Một số Lenovo ThinkPad hỗ trợ quạt phụ.  Chiếc quạt này không thể
được điều khiển riêng biệt, nó chia sẻ điều khiển quạt chính.

Cấp độ quạt
^^^^^^^^^^

Hầu hết người hâm mộ ThinkPad đều hoạt động theo "cấp độ" trên giao diện phần sụn.  Cấp 0
quạt dừng lại.  Cấp độ càng cao thì tốc độ quạt càng cao, tuy nhiên
các cấp độ liền kề thường ánh xạ tới cùng tốc độ quạt.  7 là cao nhất
mức mà quạt đạt đến tốc độ tối đa được khuyến nghị.

Mức "tự động" có nghĩa là EC thay đổi mức quạt theo một số
thuật toán nội bộ, thường dựa trên kết quả đọc từ cảm biến nhiệt.

Ngoài ra còn có mức "tốc độ tối đa", còn được gọi là mức "thảnh thơi".
Ở cấp độ này, EC vô hiệu hóa điều khiển quạt vòng kín có khóa tốc độ,
và điều khiển quạt nhanh nhất có thể, có thể vượt quá tốc độ phần cứng
giới hạn, vì vậy hãy sử dụng mức này một cách thận trọng.

Quạt thường tăng hoặc giảm tốc độ từ từ từ tốc độ này sang tốc độ khác, và
việc EC mất vài giây để phản ứng với quạt là điều bình thường
lệnh.  Mức tốc độ tối đa có thể mất tới hai phút để tăng lên
tốc độ tối đa và ở một số máy ThinkPad, số liệu của máy đo tốc độ trở nên cũ kỹ
trong khi EC đang chuyển sang mức tốc độ tối đa.

WARNING WARNING WARNING: không tắt quạt trừ khi bạn
theo dõi tất cả các chỉ số cảm biến nhiệt độ và bạn đã sẵn sàng
kích hoạt nó nếu cần thiết để tránh quá nóng.

Quạt được bật ở mức "tự động" có thể ngừng quay nếu EC quyết định
ThinkPad đủ mát và không cần thêm luồng khí.  Đây là
bình thường và EC sẽ quay quạt nếu các chỉ số nhiệt khác nhau
tăng quá nhiều.

Trên X40, điều này dường như phụ thuộc vào nhiệt độ CPU và HDD.
Cụ thể, quạt được bật khi nhiệt độ CPU
tăng lên 56 độ hoặc nhiệt độ HDD tăng lên 46 độ.  các
quạt tắt khi nhiệt độ CPU giảm xuống 49 độ và
Nhiệt độ HDD giảm xuống 41 độ.  Những ngưỡng này không thể
hiện được kiểm soát.

Mã ACPI DSDT của ThinkPad sẽ tự lập trình lại quạt khi
điều kiện nhất định được đáp ứng.  Nó sẽ ghi đè mọi chương trình quạt được thực hiện
thông qua thinkpad-acpi.

Trình điều khiển kernel thinkpad-acpi có thể được lập trình để hoàn nguyên quạt
chuyển sang cài đặt an toàn nếu không gian người dùng không đưa ra một trong các quy trình
lệnh của người hâm mộ: "bật", "tắt", "cấp độ" hoặc "cơ quan giám sát" hoặc nếu có
không ghi vào pwm1_enable (hoặc vào pwm1 ZZ0000ZZ pwm1_enable là
đặt thành 1, chế độ thủ công) trong khoảng thời gian có thể định cấu hình lên tới
120 giây.  Chức năng này được gọi là cơ quan giám sát an toàn quạt.

Lưu ý rằng bộ đếm thời gian theo dõi sẽ dừng sau khi bật quạt.  Nó sẽ là
được tự động tái trang bị lại (sử dụng cùng khoảng thời gian) khi một trong các
lệnh của quạt đã đề cập ở trên được nhận.  Cơ quan giám sát người hâm mộ là,
do đó, không phù hợp để bảo vệ khỏi những thay đổi chế độ quạt được thực hiện thông qua
có nghĩa là không phải là quạt Procfs "bật", "vô hiệu hóa" và "cấp độ"
các lệnh hoặc giao diện sysfs điều khiển quạt hwmon.

Ghi chú của Procfs
^^^^^^^^^^^^

Quạt có thể được bật hoặc tắt bằng các lệnh sau::

bật tiếng vang >/proc/acpi/ibm/fan
	vô hiệu hóa tiếng vang >/proc/acpi/ibm/fan

Đặt quạt ở mức 0 cũng giống như tắt nó.  Bật quạt
sẽ cố gắng đặt nó ở mức an toàn nếu nó quá chậm hoặc bị vô hiệu hóa.

Mức độ quạt có thể được điều khiển bằng lệnh::

echo 'level <level>' > /proc/acpi/ibm/fan

Trong đó <level> là số nguyên từ 0 đến 7 hoặc một trong các từ "auto" hoặc
"tốc độ tối đa" (không có dấu ngoặc kép).  Không phải tất cả ThinkPad đều hỗ trợ chế độ "tự động"
và mức độ "tốc độ tối đa".  Người lái xe chấp nhận "thảnh thơi" làm bí danh cho
"tốc độ tối đa" và báo cáo là "đã thảnh thơi" khi quay ngược
khả năng tương thích.

Trên X31 và X40 (và ONLY trên các mẫu đó), tốc độ quạt có thể là
được kiểm soát ở một mức độ nhất định.  Sau khi quạt chạy, có thể
buộc phải chạy nhanh hơn hoặc chậm hơn bằng lệnh sau ::

echo 'tốc độ <tốc độ>' > /proc/acpi/ibm/fan

Phạm vi tốc độ quạt bền vững trên X40 dường như là từ khoảng
3700 đến khoảng 7350. Các giá trị ngoài phạm vi này không có bất kỳ giá trị nào
hiệu ứng hoặc tốc độ quạt cuối cùng sẽ ổn định ở đâu đó trong phạm vi đó.  các
không thể dừng hoặc khởi động quạt bằng lệnh này.  Chức năng này
chưa đầy đủ và không có sẵn thông qua giao diện sysfs.

Để lập trình cơ quan giám sát an toàn, hãy sử dụng lệnh "watchdog"::

echo 'watchdog <khoảng thời gian tính bằng giây>' > /proc/acpi/ibm/fan

Nếu bạn muốn tắt cơ quan giám sát, hãy sử dụng 0 làm khoảng thời gian.

Ghi chú hệ thống
^^^^^^^^^^^

Giao diện sysfs tuân theo các hướng dẫn của hệ thống con hwmon hầu hết
một phần, và ngoại lệ là cơ quan giám sát an toàn quạt.

Việc ghi vào bất kỳ thuộc tính sysfs nào có thể trả về lỗi EINVAL nếu
thao tác đó không được hỗ trợ trong ThinkPad nhất định hoặc nếu tham số
nằm ngoài giới hạn và EPERM nếu bị cấm.  Họ cũng có thể quay lại
EINTR (cuộc gọi hệ thống bị gián đoạn) và EIO (lỗi I/O khi cố gắng nói chuyện
vào phần sụn).

Các tính năng chưa được trình điều khiển triển khai trả về ENOSYS.

Thuộc tính thiết bị hwmon pwm1_enable:
	- 0: PWM offline (quạt được đặt ở chế độ tốc độ tối đa)
	- 1: Điều khiển PWM thủ công (dùng pwm1 để cài đặt mức quạt)
	- 2: Điều khiển PWM phần cứng (chế độ EC "tự động")
	- 3: dành riêng (Phần mềm điều khiển PWM, chưa triển khai)

Chế độ 0 và 2 không được tất cả ThinkPad hỗ trợ và
	không phải lúc nào người lái xe cũng có thể phát hiện ra điều này.  Nếu nó biết một
	chế độ không được hỗ trợ, nó sẽ trả về -EINVAL.

thuộc tính thiết bị hwmon pwm1:
	Cấp độ quạt, được chia tỷ lệ từ giá trị phần sụn từ 0-7 đến hwmon
	thang đo 0-255.  0 có nghĩa là quạt đã dừng, 255 có nghĩa là mức bình thường cao nhất
	tốc độ (cấp 7).

Thuộc tính này chỉ ra lệnh cho quạt nếu pmw1_enable được đặt thành 1
	(điều khiển PWM thủ công).

Thuộc tính thiết bị hwmon fan1_input:
	Đọc tốc độ kế của quạt, trong RPM.  Có thể trở nên cũ kỹ
	ThinkPad trong khi EC chuyển PWM sang chế độ ngoại tuyến,
	có thể mất đến hai phút.  Có thể trả lại rác cũ
	ThinkPad.

Thuộc tính thiết bị hwmon fan2_input:
	Số đọc của máy đo tốc độ quạt, ở dạng RPM, dành cho quạt phụ.
	Chỉ có trên một số ThinkPad.  Nếu quạt phụ
	chưa được cài đặt, sẽ luôn đọc 0.

Thuộc tính trình điều khiển hwmon fan_watchdog:
	Khoảng thời gian hẹn giờ của cơ quan giám sát an toàn quạt, tính bằng giây.  Tối thiểu là
	1 giây, tối đa là 120 giây.  0 vô hiệu hóa cơ quan giám sát.

Để dừng quạt: đặt pwm1 thành 0 và pwm1_enable thành 1.

Để khởi động quạt ở chế độ an toàn: đặt pwm1_enable thành 2. Nếu không thành công
với EINVAL, hãy thử đặt pwm1_enable thành 1 và pwm1 thành ít nhất 128 (255
Tuy nhiên, sẽ là sự lựa chọn an toàn nhất).


WAN
---

giao thức: /proc/acpi/ibm/wan

Thuộc tính thiết bị sysfs: wwan_enable (không dùng nữa)

Lớp rfkill sysfs: chuyển "tpacpi_wwan_sw"

Tính năng này cho thấy sự hiện diện và trạng thái hiện tại của phần mềm tích hợp
Thiết bị WAN không dây.

Nếu ThinkPad hỗ trợ nó, trạng thái WWAN sẽ được lưu trữ trong NVRAM,
vì vậy nó được giữ trong suốt quá trình khởi động lại và tắt nguồn.

Nó đã được thử nghiệm trên Lenovo ThinkPad X60. Nó có lẽ sẽ hoạt động trên các thiết bị khác
Các mẫu ThinkPad được cài đặt mô-đun này.

Ghi chú của Procfs
^^^^^^^^^^^^

Nếu thẻ W-WAN được cài đặt, có thể sử dụng các lệnh sau ::

bật tiếng vang> /proc/acpi/ibm/wan
	vô hiệu hóa tiếng vang> /proc/acpi/ibm/wan

Ghi chú hệ thống
^^^^^^^^^^^

Nếu thẻ W-WAN được cài đặt, nó có thể được kích hoạt /
	bị vô hiệu hóa thông qua thiết bị thinkpad-acpi "wwan_enable"
	thuộc tính và trạng thái hiện tại của nó cũng có thể được truy vấn.

kích hoạt:
		- 0: vô hiệu hóa thẻ WWAN / thẻ WWAN bị vô hiệu hóa
		- 1: bật thẻ WWAN / thẻ WWAN được bật.

Lưu ý: giao diện này đã được thay thế bằng rfkill chung
	lớp học.  Nó không được dùng nữa và sẽ bị xóa sau năm
	2010.

công tắc bộ điều khiển rfkill "tpacpi_wwan_sw": tham khảo
	Tài liệu/driver-api/rfkill.rst để biết chi tiết.


LCD Kiểm soát bóng
------------------

giao thức: /proc/acpi/ibm/lcdshadow

Một số ThinkPad T480 và T490 mới hơn cung cấp một tính năng gọi là
Bảo vệ quyền riêng tư. Bằng cách bật tính năng này, chiều dọc và
góc nhìn ngang của LCD có thể bị hạn chế (như thể một số quyền riêng tư
màn hình được áp dụng thủ công ở phía trước màn hình).

ghi chú procfs
^^^^^^^^^^^^

Các lệnh có sẵn là::

echo '0' >/proc/acpi/ibm/lcdshadow
	echo '1' >/proc/acpi/ibm/lcdshadow

Lệnh đầu tiên đảm bảo góc nhìn tốt nhất và lệnh sau quay
về tính năng, hạn chế góc nhìn.


Cảm biến Lapmode DYTC
-------------------

sysfs: dytc_lapmode

Các thinkpad và máy trạm di động mới hơn có khả năng xác định xem
thiết bị đang ở chế độ bàn hoặc lapmode. Tính năng này được sử dụng bởi không gian người dùng
để quyết định xem việc truyền WWAN có thể được tăng lên công suất tối đa hay không và
cũng hữu ích để hiểu các chế độ nhiệt khác nhau có sẵn như
chúng khác nhau giữa chế độ bàn và chế độ lòng.

Thuộc tính chỉ đọc. Nếu nền tảng không hỗ trợ sysfs
lớp không được tạo ra.

EXPERIMENTAL: UWB
-----------------

Tính năng này được coi là EXPERIMENTAL vì nó chưa được phổ biến rộng rãi
đã được thử nghiệm và xác nhận trên nhiều mẫu ThinkPad khác nhau.  Tính năng này có thể không
làm việc như mong đợi. USE WITH CAUTION! Để sử dụng tính năng này, bạn cần cung cấp
tham số thử nghiệm = 1 khi tải mô-đun.

Lớp rfkill sysfs: chuyển "tpacpi_uwb_sw"

Tính năng này xuất bộ điều khiển rfkill cho thiết bị UWB, nếu có
hiện diện và kích hoạt trong BIOS.

Ghi chú hệ thống
^^^^^^^^^^^

công tắc bộ điều khiển rfkill "tpacpi_uwb_sw": tham khảo
	Tài liệu/driver-api/rfkill.rst để biết chi tiết.


Cài đặt ngôn ngữ bàn phím
-------------------------

sysfs: bàn phím_lang

Tính năng này được sử dụng để đặt ngôn ngữ bàn phím thành ECFW bằng giao diện ASL.
Ít mẫu thinkpad hơn như T580 , T590 , T15 Gen 1, v.v. có "=", "(',
")" các phím số không hiển thị chính xác khi ngôn ngữ bàn phím
không phải là "tiếng Anh". Điều này là do ngôn ngữ bàn phím mặc định trong ECFW
được đặt là "tiếng Anh". Do đó, bằng cách sử dụng sysfs này, người dùng có thể đặt bàn phím chính xác
ngôn ngữ sang ECFW và sau đó các phím này sẽ hoạt động chính xác.

Ví dụ về lệnh đặt ngôn ngữ bàn phím được đề cập dưới đây ::

echo jp > /sys/devices/platform/thinkpad_acpi/keyboard_lang

Văn bản tương ứng với bố cục bàn phím được đặt trong sysfs là: be(Belgian),
cz(Séc), da(Đan Mạch), de(tiếng Đức), en(tiếng Anh), es(Tây Ban Nha), et(tiếng Estonia),
fr(tiếng Pháp), fr-ch(tiếng Pháp(Thụy Sĩ)), hu(Hungary), it(Ý), jp (Nhật Bản),
nl(tiếng Hà Lan), nn(Na Uy), pl(tiếng Ba Lan), pt(tiếng Bồ Đào Nha), sl(tiếng Slovenia), sv(Thụy Điển),
tr(Thổ Nhĩ Kỳ)

Loại ăng-ten WWAN
-----------------

sysfs: wwan_antenna_type

Trên một số Thinkpad mới hơn chúng ta cần đặt giá trị SAR dựa trên ăng-ten
loại. Giao diện này sẽ được không gian người dùng sử dụng để lấy loại ăng-ten
và đặt giá trị SAR tương ứng, như được yêu cầu cho chứng nhận FCC.

Các lệnh có sẵn là::

mèo /sys/devices/platform/thinkpad_acpi/wwan_antenna_type

Hiện tại có 2 loại ăng-ten được hỗ trợ như được đề cập dưới đây:
- gõ một
- loại b

Thuộc tính chỉ đọc. Nếu nền tảng không hỗ trợ sysfs
lớp không được tạo ra.

Auxmac
------

sysfs: auxmac

Một số Thinkpad mới hơn có một tính năng gọi là Truyền qua địa chỉ MAC. Cái này
tính năng được triển khai bởi phần sụn hệ thống để cung cấp một hệ thống MAC duy nhất,
có thể ghi đè đế cắm hoặc khóa ethernet USB MAC, khi được kết nối với
mạng. Thuộc tính này cho phép không gian người dùng dễ dàng xác định địa chỉ MAC
nếu tính năng này được kích hoạt.

Các giá trị của MAC phụ trợ này là:

mèo/sys/thiết bị/nền tảng/thinkpad_acpi/auxmac

Nếu tính năng này bị tắt, giá trị sẽ bị 'vô hiệu hóa'.

Thuộc tính này là chỉ đọc.

Bàn phím thích ứng
-----------------

Thuộc tính thiết bị sysfs: Adaptive_kbd_mode

Thuộc tính sysfs này điều khiển "mặt" bàn phím sẽ được hiển thị trên
Bàn phím thích ứng của Lenovo X1 Carbon thế hệ 2 (2014). Giá trị có thể được đọc
và thiết lập.

- 0 = Chế độ ở nhà
- 1 = Chế độ trình duyệt web
- 2 = Chế độ hội thảo trên web
- 3 = Chế độ chức năng
- 4 = Chế độ Layflat

Để biết thêm chi tiết về những nút nào sẽ xuất hiện tùy theo chế độ, vui lòng
xem lại hướng dẫn sử dụng máy tính xách tay:
ZZ0000ZZ

Kiểm soát sạc pin
----------------------

thuộc tính sysfs:
/sys/class/power_supply/BAT*/charge_control_{start,end__threshold

Hai thuộc tính này được tạo cho những loại pin được hỗ trợ bởi
người lái xe. Chúng cho phép người dùng kiểm soát ngưỡng sạc pin của
pin đã cho. Cả hai giá trị có thể được đọc và thiết lập. ZZ0000ZZ
chấp nhận số nguyên từ 0 đến 99 (bao gồm); giá trị này đại diện cho pin
mức phần trăm, dưới mức đó việc tính phí sẽ bắt đầu. ZZ0001ZZ
chấp nhận số nguyên từ 1 đến 100 (đã bao gồm); giá trị này đại diện cho pin
mức phần trăm, trên đó việc sạc sẽ dừng lại.

Ngữ nghĩa chính xác của các thuộc tính có thể được tìm thấy trong
Tài liệu/ABI/thử nghiệm/sysfs-class-power.

Khả năng phát hiện hư hỏng phần cứng
------------------------------------

thuộc tính sysfs: hwdd_status, hwdd_detail

Thinkpad đang bổ sung thêm khả năng phát hiện và báo cáo hư hỏng phần cứng.
Thêm giao diện sysfs mới để xác định trạng thái thiết bị bị hỏng.
Hỗ trợ ban đầu có sẵn cho đầu nối có thể thay thế USB-C.

Lệnh kiểm tra tình trạng hư hỏng của thiết bị là::

mèo /sys/devices/platform/thinkpad_acpi/hwdd_status

Giá trị này hiển thị trạng thái thiết bị bị hỏng.

- 0 = Không bị hư hỏng
- 1 = Hư hỏng

Lệnh kiểm tra vị trí của thiết bị bị hỏng là::

mèo /sys/devices/platform/thinkpad_acpi/hwdd_detail

Giá trị này hiển thị vị trí của thiết bị bị hỏng có 1 dòng cho mỗi "mục" bị hỏng.
Ví dụ:

nếu không phát hiện thấy hư hỏng:

- Không phát hiện hư hỏng

nếu phát hiện hư hỏng:

- TYPE-C: Chân đế, Bên phải, Cổng trung tâm

Thuộc tính chỉ đọc. Nếu tính năng không được hỗ trợ thì sysfs
thuộc tính không được tạo.

Nhiều lệnh, tham số mô-đun
------------------------------------

Nhiều lệnh có thể được ghi vào tệp Proc trong một lần chụp bằng cách
phân tách chúng bằng dấu phẩy, ví dụ::

bật tiếng vang, 0xffff > /proc/acpi/ibm/phím nóng
	echo lcd_disable,crt_enable > /proc/acpi/ibm/video

Các lệnh cũng có thể được chỉ định khi tải mô-đun thinkpad-acpi,
ví dụ::

modprobe thinkpad_acpi hotkey=bật,0xffff video=auto_disable


Kích hoạt đầu ra gỡ lỗi
-------------------------

Mô-đun này có một tham số gỡ lỗi có thể được sử dụng để chọn lọc
kích hoạt các lớp đầu ra gỡ lỗi khác nhau, ví dụ::

modprobe thinkpad_acpi debug=0xffff

sẽ cho phép tất cả các lớp đầu ra gỡ lỗi.  Phải mất một bitmask, vì vậy
để kích hoạt nhiều lớp đầu ra, chỉ cần thêm giá trị của chúng.

=======================================================
	Gỡ lỗi mặt nạ bit Mô tả
	=======================================================
	0x8000 Tiết lộ PID của các chương trình không gian người dùng
				truy cập một số chức năng của trình điều khiển
	0x0001 Khởi tạo và thăm dò
	Loại bỏ 0x0002
	Điều khiển máy phát RF 0x0004 (RFKILL)
				(bluetooth, WWAN, UWB...)
	Giao diện sự kiện 0x0008 HKEY, phím nóng
	0x0010 Điều khiển quạt
	Độ sáng đèn nền 0x0020
	0x0040 Bộ trộn âm thanh/điều khiển âm lượng
	=======================================================

Ngoài ra còn có tùy chọn xây dựng kernel để cho phép gỡ lỗi nhiều hơn
thông tin có thể cần thiết để gỡ lỗi các vấn đề về trình điều khiển.

Mức độ thông tin gỡ lỗi của trình điều khiển có thể được thay đổi
trong thời gian chạy thông qua sysfs, sử dụng thuộc tính trình điều khiển debug_level.  các
thuộc tính có cùng mặt nạ bit với tham số mô-đun gỡ lỗi ở trên.


Buộc tải mô-đun
-----------------------

Nếu thinkpad-acpi từ chối phát hiện ThinkPad của bạn, bạn có thể thử chỉ định
tham số mô-đun Force_load=1.  Bất kể điều này có hiệu quả hay không
không, vui lòng liên hệ với ibm-acpi-devel@lists.sourceforge.net để gửi báo cáo.


Nhật ký thay đổi giao diện Sysfs
^^^^^^^^^^^^^^^^^^^^^^^^^

==============================================================================
0x000100: Hỗ trợ sysfs ban đầu, dưới dạng trình điều khiển nền tảng duy nhất và
		thiết bị.
0x000200: Hỗ trợ phím nóng cho 32 phím nóng và chuyển đổi thanh trượt radio
		hỗ trợ.
0x010000: Các phím nóng hiện được xử lý theo mặc định trên đầu vào
		lớp, bộ chuyển mạch vô tuyến tạo ra sự kiện đầu vào EV_RADIO,
		và trình điều khiển cho phép xử lý phím nóng theo mặc định trong
		phần sụn.

0x020000: Sửa lỗi ABI: đã thêm một thiết bị nền tảng hwmon riêng và
		trình điều khiển, phải được định vị theo tên (thinkpad)
		và lớp hwmon cho libsensors4 (lm-sensors 3)
		khả năng tương thích.  Đã chuyển tất cả các thuộc tính hwmon sang đây
		thiết bị nền tảng mới.

0x020100: Điểm đánh dấu cho thinkpad-acpi bằng phím nóng NVRAM bỏ phiếu
		hỗ trợ.  Nếu bạn phải, hãy sử dụng nó để biết bạn không nên
		khởi động trình thăm dò không gian người dùng NVRAM (cho phép phát hiện khi nào
		NVRAM được người dùng biên soạn vì nó
		không cần thiết/không mong muốn ngay từ đầu).
0x020101: Điểm đánh dấu cho thinkpad-acpi bằng phím nóng NVRAM bỏ phiếu
		và ngữ nghĩa hotkey_mask thích hợp (phiên bản 8 của
		Bản vá bỏ phiếu NVRAM).  Một số ảnh chụp nhanh quá trình phát triển của
		0.18 có một phiên bản trước đó đã làm những điều kỳ lạ
		tới hotkey_mask.

0x020200: Thêm hỗ trợ poll()/select() cho các thuộc tính sau:
		hotkey_radio_sw, Wakeup_hotunplug_complete, Wakeup_reason

0x020300: loại bỏ hỗ trợ bật/tắt phím nóng, thuộc tính
		hotkey_bios_enabled và hotkey_enable không được dùng nữa và
		được đánh dấu để loại bỏ.

0x020400: Điểm đánh dấu hỗ trợ 16 đèn LED.  Ngoài ra, đèn LED được biết đến
		không tồn tại trong một mô hình nhất định không được đăng ký với
		lớp sysfs LED nữa.

0x020500: Đã cập nhật driver hotkey, hotkey_mask luôn có sẵn
		và nó luôn có thể vô hiệu hóa các phím nóng.  Rất cũ
		thinkpad được hỗ trợ đúng cách.  hotkey_bios_mask
		không được dùng nữa và được đánh dấu để xóa.

0x020600: Điểm đánh dấu để hỗ trợ sự kiện thay đổi đèn nền.

0x020700: Hỗ trợ bộ trộn chỉ tắt tiếng.
		Điều khiển âm lượng ở chế độ chỉ đọc theo mặc định.
		Điểm đánh dấu để hỗ trợ bộ trộn ALSA.

0x030000: Thuộc tính hệ thống nhiệt và quạt đã được chuyển sang hwmon
		thiết bị thay vì được gắn vào nền tảng hỗ trợ
		thiết bị.
==============================================================================
