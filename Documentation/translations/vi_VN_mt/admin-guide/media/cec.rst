.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/cec.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========
HDMI CEC
========

Phần cứng được hỗ trợ trong tuyến chính
==============================

Máy phát HDMI:

- Exynos4
- Exynos5
- STIH4xx HDMI CEC
- V4L2 adv7511 (cùng HW, nhưng trình điều khiển khác với drm adv7511)
- stm32
- Allwinner A10 (sun4i)
- Raspberry Pi
- dw-hdmi (IP tóm tắt)
- amlogic (meson ao-cec và ao-cec-g12a)
- drm Adv7511/adv7533
- omap4
- tegra
- rk3288, rk3399
- tda998x
- DisplayPort CEC-Tunneling-over-AUX trên i915, nouveau và amdgpu
- ChromeOS EC CEC
- CEC dành cho bo mạch SECO (UDOO x86).
- Chrontel CH7322


Bộ thu HDMI:

- Adv7604/11/12
- Adv7842
- tc358743

USB Dongle (xem bên dưới để biết thêm thông tin về cách sử dụng các thiết bị này
dongle):

- Pulse-Eight: trình điều khiển Pulse8-cec thực hiện tùy chọn mô-đun sau:
  ZZ0000ZZ: theo mặc định thì tính năng này tắt, nhưng khi đặt thành 1 thì trình điều khiển
  sẽ lưu trữ các cài đặt hiện tại vào eeprom bên trong của thiết bị và khôi phục
  vào lần tiếp theo thiết bị được kết nối với cổng USB.

- Công nghệ RainShadow. Lưu ý: trình điều khiển này không hỗ trợ Persist_config
  tùy chọn mô-đun của trình điều khiển Pulse-Eight. Phần cứng hỗ trợ nó, nhưng tôi
  không có kế hoạch thêm tính năng này. Nhưng tôi chấp nhận các bản vá :-)

- Khuếch đại phân phối Extron DA HD 4K PLUS HDMI. Xem
  ZZ0000ZZ để biết thêm thông tin.

Khác:

- sống động: mô phỏng bộ thu CEC và bộ phát CEC.
  Có thể được sử dụng để kiểm tra các ứng dụng CEC mà không cần phần cứng CEC thực tế.

- cec-gpio. Nếu chân CEC được nối với chân GPIO thì
  bạn có thể điều khiển dòng CEC thông qua trình điều khiển này. Lỗi hỗ trợ này
  tiêm cũng vậy.

- cec-gpio và Allwinner A10 (hoặc bất kỳ trình điều khiển nào khác sử dụng chân CEC
  khung để điều khiển trực tiếp chân CEC): khung chân CEC sử dụng
  bộ đếm thời gian có độ phân giải cao. Những bộ tính giờ này bị ảnh hưởng bởi daemon NTP
  tăng tốc hoặc làm chậm đồng hồ để đồng bộ với thời gian chính thức. các
  máy chủ chronyd theo mặc định sẽ tăng hoặc giảm đồng hồ theo
  1/12. Điều này sẽ khiến thời gian của CEC không đạt thông số kỹ thuật. Để khắc phục điều này,
  thêm dòng 'maxslewrate 40000' vào chronyd.conf. Điều này hạn chế đồng hồ
  thay đổi tần số thành 1/25, giúp giữ cho thời gian CEC nằm trong thông số kỹ thuật.


Tiện ích
=========

Tiện ích có sẵn tại đây: ZZ0000ZZ

ZZ0000ZZ: điều khiển thiết bị CEC

ZZ0000ZZ: kiểm tra sự tuân thủ của thiết bị CEC từ xa

ZZ0000ZZ: mô phỏng thiết bị theo dõi CEC

Lưu ý rằng ZZ0000ZZ có hỗ trợ cho Hồ sơ khách sạn CEC
được sử dụng trong một số trưng bày của khách sạn. Xem ZZ0001ZZ

Lưu ý rằng thư viện libcec (ZZ0000ZZ hỗ trợ
khung công tác linux CEC.

Nếu bạn muốn biết thông số kỹ thuật CEC, hãy xem Tài liệu tham khảo của
trang wikipedia HDMI: ZZ0000ZZ CEC là một phần
của đặc điểm kỹ thuật HDMI. HDMI 1.3 được cung cấp miễn phí (rất giống với
HDMI 1.4 w.r.t. CEC) và đủ tốt cho hầu hết mọi thứ.


Bộ điều hợp DisplayPort sang HDMI với CEC đang hoạt động
=============================================

Bối cảnh: hầu hết các bộ điều hợp không hỗ trợ tính năng Đường hầm CEC,
và trong số đó, nhiều thứ không thực sự kết nối với chân CEC.
Thật không may, điều này có nghĩa là trong khi thiết bị CEC được tạo, nó
thực sự là cô đơn trên thế giới và sẽ không bao giờ có thể nhìn thấy người khác
Thiết bị CEC.

Đây là danh sách các bộ điều hợp hoạt động đã biết có CEC Đường hầm AND
đã kết nối đúng chân CEC. Nếu bạn thấy bộ điều hợp hoạt động
nhưng không có trong danh sách này thì hãy gửi cho tôi một ghi chú.

Để kiểm tra: hãy kết nối bộ chuyển đổi DP-to-HDMI của bạn với thiết bị có khả năng CEC
(thường là TV), sau đó chạy::

cec-ctl --playback # Configure PC dưới dạng thiết bị phát lại CEC
	cec-ctl -S # Show cấu trúc liên kết CEC

Lệnh ZZ0000ZZ sẽ hiển thị ít nhất hai thiết bị CEC,
chúng tôi và thiết bị CEC mà bạn kết nối (tức là thường là TV).

Lưu ý chung: Tôi chỉ thấy tính năng này hoạt động với Parade PS175, PS176 và
Chipset PS186 và MegaChips 2900. Trong khi MegaChips 28x0 tuyên bố hỗ trợ CEC,
Tôi chưa bao giờ thấy nó hoạt động.

USB-C đến HDMI
-------------

Bộ chuyển đổi đa cổng Samsung EE-PW700: ZZ0000ZZ

Kramer ADC-U31C/HF: ZZ0000ZZ

Club3D CAC-2504: ZZ0000ZZ

DisplayPort sang HDMI
-------------------

Club3D CAC-1080: ZZ0000ZZ

Tạo cáp (SKU: CD0712): ZZ0000ZZ

Bộ chuyển đổi HP DisplayPort sang HDMI True 4k (P/N 2JA63AA): ZZ0000ZZ

Mini-DisplayPort tới HDMI
------------------------

Club3D CAC-1180: ZZ0000ZZ

Lưu ý rằng bộ điều hợp thụ động sẽ không bao giờ hoạt động, bạn cần có bộ điều hợp hoạt động.

Các bộ điều hợp Club3D trong danh sách này đều dựa trên MegaChips 2900. Bộ điều hợp Club3D khác
dựa trên PS176 và NOT có chân CEC được nối với nhau không, vì vậy chỉ có ba Club3D
bộ điều hợp ở trên được biết là hoạt động.

Tôi nghi ngờ rằng các thiết kế dựa trên MegaChips 2900 nói chung có khả năng hoạt động
trong khi với PS176 thì nó dễ bị trượt hơn (chủ yếu là trượt). PS186 là
có khả năng đã nối chân CEC, có vẻ như họ đã thay đổi tham chiếu
thiết kế cho chipset đó.


Khóa USB CEC
===============

Các dongle này xuất hiện dưới dạng thiết bị ZZ0000ZZ và cần ZZ0001ZZ
tiện ích để tạo các thiết bị ZZ0002ZZ. Hỗ trợ cho Pulse-Eight
đã được thêm vào ZZ0003ZZ 1.6.0. Hỗ trợ cho Rainshadow Tech có
đã được thêm vào ZZ0004ZZ 1.6.1.

Bạn cũng cần các quy tắc udev để tự động khởi động các dịch vụ systemd ::

SUBSYSTEM=="tty", KERNEL=="ttyACM[0-9]*", ATTRS{idVendor}=="2548", ATTRS{idProduct}=="1002", ACTION=="thêm", TAG+="systemd", ENV{SYSTEMD_WANTS}+="pulse8-cec-inputattach@%k.service"
	SUBSYSTEM=="tty", KERNEL=="ttyACM[0-9]*", ATTRS{idVendor}=="2548", ATTRS{idProduct}=="1001", ACTION=="thêm", TAG+="systemd", ENV{SYSTEMD_WANTS}+="pulse8-cec-inputattach@%k.service"
	SUBSYSTEM=="tty", KERNEL=="ttyACM[0-9]*", ATTRS{idVendor}=="04d8", ATTRS{idProduct}=="ff59", ACTION=="thêm", TAG+="systemd", ENV{SYSTEMD_WANTS}+="rainshadow-cec-inputattach@%k.service"

và các dịch vụ systemd này:

Đối với Pulse-Eight, hãy tạo /lib/systemd/system/pulse8-cec-inputattach@.service::

[Đơn vị]
	Mô tả=inputattach cho thiết bị Pulse8-cec trên %I

[Dịch vụ]
	Loại=đơn giản
	ExecStart=/usr/bin/inputattach --pulse8-cec /dev/%I

Đối với RainShadow Tech, hãy tạo /lib/systemd/system/rainshadow-cec-inputattach@.service::

[Đơn vị]
	Description=inputattach cho thiết bị rainshadow-cec trên %I

[Dịch vụ]
	Loại=đơn giản
	ExecStart=/usr/bin/inputattach --rainshadow-cec /dev/%I


Để được hỗ trợ tạm dừng/tiếp tục thích hợp, hãy tạo: /lib/systemd/system/restart-cec-inputattach.service::

[Đơn vị]
	Mô tả=khởi động lại đầu vào đính kèm cho thiết bị cec
	Sau=suspend.target

[Dịch vụ]
	Loại=rẽ nhánh
	ExecStart=/bin/bash -c 'for d in /dev/serial/by-id/usb-Pulse-Eight*; do /usr/bin/inputattach --daemon --pulse8-cec $d; done; for d in /dev/serial/by-id/usb-RainShadow_Tech*; làm /usr/bin/inputattach --daemon --rainshadow-cec $d; xong'

[Cài đặt]
	WantedBy=suspend.target

Và chạy ZZ0000ZZ.

Để tự động đặt địa chỉ vật lý của thiết bị CEC bất cứ khi nào
EDID thay đổi, bạn có thể sử dụng ZZ0000ZZ với tùy chọn ZZ0001ZZ::

cec-ctl -E /sys/class/drm/card0-DP-1/edid

Điều này giả sử dongle được kết nối với đầu ra card0-DP-1 (ZZ0000ZZ sẽ cho biết
cho bạn biết đầu ra nào được sử dụng) và nó sẽ thăm dò các thay đổi đối với EDID và cập nhật
Địa chỉ vật lý bất cứ khi nào chúng xảy ra.

Để tự động chạy lệnh này, bạn có thể sử dụng cron. Chỉnh sửa crontab với
ZZ0000ZZ và thêm dòng này ::

@reboot /usr/local/bin/cec-ctl -E /sys/class/drm/card0-DP-1/edid

Điều này chỉ hoạt động đối với trình điều khiển hiển thị hiển thị EDID trong ZZ0000ZZ,
chẳng hạn như trình điều khiển i915.


CEC Không có HPD
===============

Một số màn hình khi ở chế độ chờ không có tín hiệu Phát hiện phích cắm nóng HDMI, nhưng
CEC vẫn được bật để các thiết bị được kết nối có thể gửi <Image View On> CEC
tin nhắn để đánh thức các màn hình như vậy. Thật không may, không phải tất cả CEC
bộ điều hợp có thể hỗ trợ điều này. Một ví dụ là Odroid-U3 SBC có
bộ chuyển đổi mức bị tắt khi tín hiệu HPD ở mức thấp, do đó
chặn chân CEC. Mặc dù SoC có thể sử dụng CEC mà không cần HPD,
bộ chuyển đổi cấp độ sẽ ngăn điều này hoạt động.

Có cờ khả năng CEC để báo hiệu điều này: ZZ0000ZZ.
Nếu được đặt thì phần cứng không thể đánh thức màn hình với hành vi này.

Lưu ý đối với người triển khai ứng dụng CEC: phải có thông báo <Image View On>
là tin nhắn đầu tiên bạn gửi, đừng gửi bất kỳ tin nhắn nào khác trước đó.
Một số triển khai CEC rất tệ nhưng tiếc là không phổ biến
sẽ rất bối rối nếu họ nhận được bất cứ điều gì khác ngoài tin nhắn này và
họ sẽ không thức dậy.

Khi viết một trình điều khiển, việc kiểm tra điều này có thể khó khăn. Có hai
cách để làm điều này:

1) Nhận một dongle Pulse-Eight USB CEC, kết nối cáp HDMI từ
   thiết bị với Pulse-Eight, nhưng không kết nối Pulse-Eight với
   màn hình.

Bây giờ hãy định cấu hình khóa Pulse-Eight ::

cec-ctl -p0.0.0.0 --tv

và bắt đầu theo dõi::

Sudo cec-ctl -M

Trên thiết bị bạn đang chạy thử::

cec-ctl --phát lại

Nó sẽ báo cáo một địa chỉ vật lý của f.f.f.f. Bây giờ hãy chạy cái này
   lệnh::

cec-ctl -t0 --xem hình ảnh trên

Pulse-Eight sẽ thấy thông báo <Image View On>. Nếu không,
   thì có thứ gì đó (phần cứng và/hoặc phần mềm) đang ngăn CEC
   tin nhắn từ đi ra ngoài.

Để chắc chắn rằng bạn nối dây đúng, chỉ cần kết nối
   Pulse-Eight tới màn hình hỗ trợ CEC và chạy lệnh tương tự
   trên thiết bị của bạn: hiện đã có HPD, vì vậy bạn sẽ thấy lệnh
   đến Pulse-Eight.

2) Nếu bạn có một thiết bị linux khác hỗ trợ CEC mà không có HPD thì
   bạn chỉ có thể kết nối thiết bị của mình với thiết bị đó. Có, bạn có thể kết nối
   hai đầu ra HDMI cùng nhau. Bạn sẽ không có HPD (đó là những gì chúng tôi
   muốn thử nghiệm này), nhưng thiết bị thứ hai có thể giám sát chân CEC.

Nếu không thì sử dụng các lệnh tương tự như trong 1.

Nếu tin nhắn CEC không xuất hiện khi không có HPD thì bạn
cần phải tìm hiểu tại sao. Thông thường, đó là một hạn chế về phần cứng
hoặc phần mềm tắt lõi CEC khi HPD ở mức thấp. các
tất nhiên là cái đầu tiên không thể sửa được, cái thứ hai có thể sẽ được yêu cầu
thay đổi trình điều khiển.


Vi điều khiển & CEC
======================

Chúng tôi đã thấy một số triển khai CEC trong màn hình sử dụng vi điều khiển
để lấy mẫu xe buýt. Đây không hẳn là một vấn đề, nhưng một số cách triển khai
có vấn đề về thời gian. Điều này khó phát hiện trừ khi bạn có thể kết nối một cấp độ thấp
Trình gỡ lỗi CEC (xem phần tiếp theo).

Bạn sẽ thấy các trường hợp bộ phát CEC giữ đường CEC ở mức cao hoặc thấp trong
lâu hơn mức cho phép. Đối với các tin nhắn được chỉ dẫn thì đây không phải là vấn đề vì
nếu điều đó xảy ra, tin nhắn sẽ không được xác nhận và sẽ được truyền lại.
Đối với tin nhắn quảng bá không tồn tại cơ chế như vậy.

Không rõ phải làm gì về điều này. Có lẽ là khôn ngoan khi truyền tải một số
phát tin nhắn hai lần để giảm khả năng chúng bị thất lạc. Cụ thể
<Standby> và <Active Source> là những ứng cử viên cho điều đó.


Tạo trình gỡ lỗi CEC
=====================

Bằng cách sử dụng Raspberry Pi 4B và một số linh kiện giá rẻ, bạn có thể tạo ra
trình gỡ lỗi CEC cấp thấp của riêng bạn.

Thành phần quan trọng là một trong những đầu nối chuyển tiếp nữ-nữ HDMI này
(hàn toàn bộ loại 1):

ZZ0000ZZ

Chất lượng video có thể thay đổi và chắc chắn không đủ để truyền qua 4kp60
(594 MHz) video. Bạn có thể hỗ trợ 4kp30, nhưng nhiều khả năng bạn sẽ làm được
được giới hạn ở 1080p60 (148,5 MHz). Nhưng đối với thử nghiệm CEC thì điều đó vẫn ổn.

Bạn cần một breadboard và một số dây dẫn của breadboard:

ZZ0000ZZ

Nếu bạn cũng muốn giám sát các đường dây HPD và/hoặc 5V thì bạn cần một trong
các bộ chuyển đổi mức 5V đến 3,3V này:

ZZ0000ZZ

(Đây chỉ là nơi mình lấy các thành phần này thôi, còn nhiều nơi khác nữa bạn
có thể nhận được những thứ tương tự).

Chân nối đất của đầu nối HDMI cần được nối đất
tất nhiên là chân của Raspberry Pi.

Chân CEC của đầu nối HDMI cần được kết nối với các chân này:
GPIO 6 và GPIO 7. Chân HPD tùy chọn của đầu nối HDMI phải
được kết nối thông qua bộ dịch mức tới các chân này: GPIO 23 và GPIO 12.
Chân 5V tùy chọn của đầu nối HDMI phải được kết nối thông qua
bộ chuyển mức tới các chân này: GPIO 25 và GPIO 22. Giám sát HPD và
Đường dây 5V là không cần thiết, nhưng nó rất hữu ích.

Bổ sung cây thiết bị này trong ZZ0000ZZ
sẽ kết nối chính xác trình điều khiển cec-gpio ::

cec@6 {
		tương thích = "cec-gpio";
		cec-gpios = <&gpio 6 (GPIO_ACTIVE_HIGH|GPIO_OPEN_DRAIN)>;
		hpd-gpios = <&gpio 23 GPIO_ACTIVE_HIGH>;
		v5-gpios = <&gpio 25 GPIO_ACTIVE_HIGH>;
	};

cec@7 {
		tương thích = "cec-gpio";
		cec-gpios = <&gpio 7 (GPIO_ACTIVE_HIGH|GPIO_OPEN_DRAIN)>;
		hpd-gpios = <&gpio 12 GPIO_ACTIVE_HIGH>;
		v5-gpios = <&gpio 22 GPIO_ACTIVE_HIGH>;
	};

Nếu bạn chưa kết nối các đường HPD và/hoặc 5V thì chỉ cần xóa chúng đi
dòng.

Thay đổi dts này sẽ kích hoạt hai thiết bị cec GPIO: Tôi thường sử dụng một thiết bị để
gửi/nhận lệnh CEC và lệnh khác để giám sát. Nếu bạn theo dõi bằng cách sử dụng
một bộ điều hợp CEC chưa được định cấu hình thì nó sẽ sử dụng các ngắt GPIO, điều này tạo ra
giám sát rất chính xác.

Nếu bạn chỉ muốn giám sát lưu lượng truy cập thì một phiên bản duy nhất là đủ.
Cấu hình tối thiểu là một đầu nối chuyển tiếp nữ-nữ HDMI
và hai dây bảng mạch cái-cái: một để nối đất HDMI
ghim vào một chân nối đất trên Raspberry Pi và chân còn lại để kết nối HDMI
Ghim CEC vào GPIO 6 trên Raspberry Pi.

Tài liệu về cách sử dụng tính năng chèn lỗi có tại đây: ZZ0000ZZ.

ZZ0000ZZ sẽ thực hiện phân tích và đánh hơi bus CEC ở cấp độ thấp.
Bạn cũng có thể lưu trữ lưu lượng CEC vào tệp bằng ZZ0001ZZ và phân tích
sau này nó sử dụng ZZ0002ZZ.

Bạn cũng có thể sử dụng thiết bị này như một thiết bị CEC chính thức bằng cách định cấu hình nó
sử dụng ZZ0000ZZ hoặc ZZ0001ZZ.

.. _extron_da_hd_4k_plus:

Trình điều khiển bộ chuyển đổi Extron DA HD 4K PLUS CEC
=======================================

Trình điều khiển này dành cho dòng Extron DA HD 4K PLUS của HDMI Distribution
Bộ khuếch đại: ZZ0000ZZ

Các mô hình 2, 4 và 6 cổng được hỗ trợ.

Yêu cầu phiên bản phần sụn 1.02.0001 trở lên.

Lưu ý rằng các phiên bản phần cứng Extron cũ hơn có vấn đề với điện áp CEC,
điều đó có thể có nghĩa là CEC sẽ không hoạt động. Điều này đã được sửa trong bản sửa đổi phần cứng
E34814 trở lên.

Hỗ trợ CEC có hai chế độ: chế độ đầu tiên là chế độ thủ công trong đó không gian người dùng có
để điều khiển thủ công CEC cho Đầu vào HDMI và tất cả Đầu ra HDMI. Trong khi điều này mang lại
toàn quyền kiểm soát, nó cũng phức tạp.

Chế độ thứ hai là chế độ tự động, được chọn nếu tùy chọn mô-đun
ZZ0000ZZ được thiết lập. Trong trường hợp đó, trình điều khiển sẽ điều khiển các thông báo CEC và CEC
nhận được ở đầu vào sẽ được phân phối đến đầu ra. Vẫn có thể
sử dụng các thiết bị /dev/cecX để nói chuyện trực tiếp với các thiết bị được kết nối, nhưng đó là
trình điều khiển cấu hình mọi thứ và xử lý những thứ như Hotplug Detect
những thay đổi.

Trình điều khiển cũng quản lý các EDID: các thiết bị /dev/videoX được tạo để
đọc EDID và (đối với cổng đầu vào HDMI) để đặt EDID.

Theo mặc định, không gian người dùng chịu trách nhiệm đặt EDID cho Đầu vào HDMI
theo EDID của màn hình được kết nối. Nhưng nếu ZZ0000ZZ
tùy chọn mô-đun được đặt, sau đó trình điều khiển sẽ đảm nhiệm việc cài đặt EDID
của Đầu vào HDMI dựa trên độ phân giải được hỗ trợ của màn hình được kết nối.
Hiện tại trình điều khiển chỉ hỗ trợ độ phân giải 1080p60 và 4kp60: nếu tất cả được kết nối
hiển thị hỗ trợ 4kp60, sau đó nó sẽ quảng cáo 4kp60 trên đầu vào HDMI, nếu không
nó sẽ quay trở lại EDID chỉ báo cáo 1080p60.

Trạng thái của Extron được báo cáo trong ZZ0000ZZ.

Trình điều khiển extron-da-hd-4k-plus triển khai các tùy chọn mô-đun sau:

ZZ0000ZZ
---------

Nếu được đặt thành 1 thì tất cả lưu lượng truy cập cổng nối tiếp sẽ được hiển thị.

ZZ0000ZZ
-------------

ID nhà cung cấp CEC để báo cáo cho các màn hình được kết nối.

Nếu được đặt, trình điều khiển sẽ đảm nhiệm việc phân phối các tin nhắn CEC nhận được
trên đầu vào cho đầu ra HDMI. Việc này được thực hiện cho các thông báo CEC sau:

- <Chế độ chờ>
- <Bật Xem Hình Ảnh> và <Bật Xem Văn Bản>
- <Cung cấp trạng thái nguồn cho thiết bị>
- <Đặt Chế Độ Âm Thanh Hệ Thống>
- <Yêu cầu độ trễ hiện tại>

Nếu không được đặt thì không gian người dùng sẽ chịu trách nhiệm về việc này và nó sẽ phải
định cấu hình thiết bị CEC cho Đầu vào HDMI và Đầu ra HDMI theo cách thủ công.

ZZ0000ZZ
---------------------

Tên nhà sản xuất gồm ba ký tự được sử dụng trong EDID cho HDMI
Đầu vào. Nếu không được đặt thì không gian người dùng chịu trách nhiệm định cấu hình EDID.
Nếu được đặt thì trình điều khiển sẽ tự động cập nhật EDID dựa trên
độ phân giải được hỗ trợ bởi màn hình được kết nối và sẽ không thể thực hiện được
nữa để đặt thủ công EDID cho Đầu vào HDMI.

ZZ0000ZZ
-----------------

Nếu được đặt thì chân Hotplug Detect của Đầu vào HDMI sẽ luôn ở mức cao,
ngay cả khi không có gì được kết nối với Đầu ra HDMI. Nếu không được đặt (mặc định)
thì chân Phát hiện phích cắm nóng của đầu vào HDMI sẽ ở mức thấp nếu tất cả các tín hiệu được phát hiện
Các chân Phát hiện phích cắm nóng của HDMI Đầu ra cũng ở mức thấp.

Tùy chọn này có thể được thay đổi linh hoạt.