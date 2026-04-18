.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/usb/callbacks.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Lệnh gọi lại lõi USB
~~~~~~~~~~~~~~~~~~

USBcore sẽ thực hiện những cuộc gọi lại nào?
===============================

Usbcore sẽ gọi tới trình điều khiển thông qua các lệnh gọi lại được xác định trong trình điều khiển
cấu trúc và thông qua trình xử lý hoàn thành của URB mà trình điều khiển gửi.
Chỉ những điều đầu tiên mới nằm trong phạm vi của tài liệu này. Hai loại này
các cuộc gọi lại hoàn toàn độc lập với nhau. Thông tin về
cuộc gọi lại hoàn thành có thể được tìm thấy trong ZZ0000ZZ.

Các cuộc gọi lại được xác định trong cấu trúc trình điều khiển là:

1. Lệnh gọi lại cắm nóng:

- @thăm dò:
	Được gọi để xem tài xế có sẵn sàng quản lý một công việc cụ thể không
	giao diện trên một thiết bị.

- @ngắt kết nối:
	Được gọi khi giao diện không còn truy cập được nữa, thường là
	vì thiết bị của nó đã (hoặc đang) bị ngắt kết nối hoặc
	mô-đun trình điều khiển đang được dỡ xuống.

2. Backdoor lẻ qua usbfs:

- @ioctl:
	Được sử dụng cho các trình điều khiển muốn nói chuyện với không gian người dùng thông qua
	hệ thống tập tin "usbfs".  Điều này cho phép các thiết bị cung cấp cách để
	hiển thị thông tin tới không gian người dùng bất kể họ ở đâu
	làm (hoặc không) hiển thị khác trong hệ thống tập tin.

3. Lệnh gọi lại quản lý nguồn (PM):

- @đình chỉ:
	Được gọi khi thiết bị sắp bị treo.

- @sơ yếu lý lịch:
	Được gọi khi thiết bị đang được tiếp tục.

- @reset_resume:
	Được gọi khi thiết bị bị treo đã được đặt lại
	về việc được nối lại.

4. Hoạt động ở cấp độ thiết bị:

- @pre_reset:
	Được gọi khi thiết bị sắp được reset.

- @post_reset:
	Được gọi sau khi thiết bị đã được đặt lại

Giao diện ioctl (2) chỉ nên được sử dụng nếu bạn có giao diện rất tốt
lý do. Sysfs được ưa thích những ngày này. Các cuộc gọi lại PM được bảo hiểm
riêng biệt trong ZZ0000ZZ.

Quy ước gọi điện
===================

Tất cả các cuộc gọi lại đều loại trừ lẫn nhau. Không cần phải khóa
chống lại các lệnh gọi lại USB khác. Tất cả các cuộc gọi lại được gọi từ một tác vụ
bối cảnh. Bạn có thể ngủ. Tuy nhiên, điều quan trọng là tất cả các giấc ngủ đều có
giới hạn trên cố định nhỏ về thời gian. Đặc biệt bạn không được gọi
không gian người dùng và chờ kết quả.

Cắm lại cuộc gọi lại
=====================

Những cuộc gọi lại này nhằm mục đích liên kết và tách rời trình điều khiển với
một giao diện. Mối liên kết của trình điều khiển với một giao diện là độc quyền.

Cuộc gọi lại thăm dò()
--------------------

::

int (*probe) (struct usb_interface *intf,
		const struct usb_device_id *id);

Chấp nhận hoặc từ chối một giao diện. Nếu bạn chấp nhận thiết bị trả về 0,
nếu không thì -ENODEV hoặc -ENXIO. Các mã lỗi khác chỉ nên được sử dụng nếu
đã xảy ra lỗi thực sự trong quá trình khởi tạo khiến trình điều khiển không thể thực hiện được
từ việc chấp nhận một thiết bị mà lẽ ra đã được chấp nhận.
Bạn được khuyến khích sử dụng tiện ích của usbcore,
usb_set_intfdata(), để liên kết cấu trúc dữ liệu với giao diện, vì vậy
rằng bạn biết trạng thái nội bộ và danh tính nào bạn liên kết với một
giao diện cụ thể. Thiết bị sẽ không bị treo và bạn có thể thực hiện IO
đến giao diện bạn được gọi và điểm cuối 0 của thiết bị. Thiết bị
việc khởi tạo không mất quá nhiều thời gian là một ý tưởng hay ở đây.

Lệnh gọi lại ngắt kết nối()
-------------------------

::

khoảng trống (*disconnect) (struct usb_interface *intf);

Cuộc gọi lại này là một tín hiệu để ngắt mọi kết nối với một giao diện.
Bạn không được phép bất kỳ IO nào vào thiết bị sau khi trở về từ thiết bị này
gọi lại. Bạn cũng không được thực hiện bất kỳ thao tác nào khác có thể ảnh hưởng đến
với một trình điều khiển khác được liên kết với giao diện, vd. quản lý năng lượng
hoạt động. Các thao tác còn tồn đọng trên thiết bị phải được hoàn thành hoặc
bị hủy bỏ trước khi lệnh gọi lại này có thể quay trở lại.

Nếu bạn được gọi do mất kết nối vật lý, tất cả URB của bạn sẽ bị mất
bị giết bởi usbcore. Lưu ý rằng trong trường hợp này việc ngắt kết nối sẽ được gọi là một số
thời gian sau khi ngắt kết nối vật lý. Vì vậy tài xế của bạn phải chuẩn bị
để xử lý lỗi IO ngay cả trước khi gọi lại.

Lệnh gọi lại cấp thiết bị
======================

pre_reset
---------

::

int (*pre_reset)(struct usb_interface *intf);

Trình điều khiển hoặc không gian người dùng đang kích hoạt thiết lập lại trên thiết bị.
chứa giao diện được truyền dưới dạng đối số. Dừng IO, đợi tất cả
các URB còn tồn đọng để hoàn thành và lưu mọi trạng thái thiết bị bạn cần
khôi phục.  Không thể gửi thêm URB nào cho đến khi phương thức post_reset
được gọi.

Nếu bạn cần phân bổ bộ nhớ ở đây, hãy sử dụng GFP_NOIO hoặc GFP_ATOMIC, nếu bạn
đang ở trong bối cảnh nguyên tử.

post_reset
----------

::

int (*post_reset)(struct usb_interface *intf);

Việc thiết lập lại đã hoàn tất.  Khôi phục mọi trạng thái thiết bị đã lưu và bắt đầu
sử dụng lại thiết bị.

Nếu bạn cần phân bổ bộ nhớ ở đây, hãy sử dụng GFP_NOIO hoặc GFP_ATOMIC, nếu bạn
đang ở trong bối cảnh nguyên tử.

Chuỗi cuộc gọi
==============

Không có cuộc gọi lại nào ngoài thăm dò sẽ được gọi cho một giao diện
điều đó không bị ràng buộc với trình điều khiển của bạn.

Thăm dò sẽ không bao giờ được gọi cho giao diện được liên kết với trình điều khiển.
Do đó sau khi thăm dò thành công, ngắt kết nối sẽ được gọi
trước khi có một đầu dò khác cho cùng một giao diện.

Sau khi trình điều khiển của bạn được liên kết với một giao diện, bạn có thể ngắt kết nối
được gọi bất cứ lúc nào ngoại trừ giữa pre_reset và post_reset.
pre_reset luôn được theo sau bởi post_reset, ngay cả khi reset
không thành công hoặc thiết bị đã bị rút phích cắm.

tạm dừng luôn được theo sau bởi một trong các: sơ yếu lý lịch, reset_resume hoặc
ngắt kết nối.
