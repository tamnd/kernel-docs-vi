.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/input/input.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

=============
Giới thiệu
=============

:Bản quyền: ZZ0000ZZ 1999-2001 Vojtech Pavlik <vojtech@ucw.cz> - Được tài trợ bởi SuSE

Ngành kiến ​​​​trúc
===================

Hệ thống con đầu vào là một tập hợp các trình điều khiển được thiết kế để hỗ trợ
tất cả các thiết bị đầu vào trong Linux. Hầu hết các tài xế đều cư trú tại
trình điều khiển/đầu vào, mặc dù khá nhiều trong số đó nằm trong trình điều khiển/ẩn và
trình điều khiển/nền tảng.

Cốt lõi của hệ thống con đầu vào là mô-đun đầu vào, phải được
được tải trước bất kỳ mô-đun đầu vào nào khác - nó phục vụ như một cách
Giao tiếp giữa hai nhóm mô-đun:

Trình điều khiển thiết bị
-------------------------

Các mô-đun này giao tiếp với phần cứng (ví dụ qua USB) và cung cấp
các sự kiện (tổ hợp phím, di chuyển chuột) vào mô-đun đầu vào.

Trình xử lý sự kiện
-------------------

Các mô-đun này nhận các sự kiện từ lõi đầu vào và chuyển chúng khi cần thiết
thông qua các giao diện khác nhau - nhấn phím vào kernel, di chuyển chuột qua
giao diện PS/2 mô phỏng cho GPM và X, v.v.

Cách sử dụng đơn giản
=====================

Đối với cấu hình thông thường nhất, với một con chuột USB và một bàn phím USB,
bạn sẽ phải tải các mô-đun sau (hoặc tích hợp chúng vào
hạt nhân)::

đầu vào
	mousedev
	lõi usb
	uhci_hcd hoặc ohci_hcd hoặc ehci_hcd
	usbhid
	hid_generic

Sau đó, bàn phím USB sẽ hoạt động ngay và chuột USB
sẽ có sẵn dưới dạng thiết bị nhân vật trên cung 13, thứ 63::

crw-r--r-- 1 gốc gốc 13, 63 28 tháng 3 22:45 chuột

Thiết bị này thường được hệ thống tạo tự động. Các lệnh
để tạo nó bằng tay là::

cd /dev
	đầu vào mkdir
	đầu vào mknod/chuột c 13 63

Sau đó, bạn phải trỏ GPM (công cụ cắt và dán chuột ở chế độ văn bản) và
XFree cho thiết bị này để sử dụng nó - GPM nên được gọi như sau::

gpm -t ps2 -m /dev/input/chuột

Và trong X::

Phần "Con trỏ"
	    Giao thức "ImPS/2"
	    Thiết bị "/dev/input/chuột"
	    Bản đồ trục Z 4 5
	Phần cuối

Khi thực hiện tất cả những điều trên, bạn có thể sử dụng chuột và bàn phím USB của mình.

Mô tả chi tiết
====================

Trình xử lý sự kiện
-------------------

Trình xử lý sự kiện phân phối các sự kiện từ thiết bị đến không gian người dùng và
người tiêu dùng trong hạt nhân, khi cần thiết.

evdev
~~~~~

ZZ0000ZZ là giao diện sự kiện đầu vào chung. Nó vượt qua các sự kiện
được tạo trong kernel thẳng vào chương trình, có dấu thời gian. các
mã sự kiện giống nhau trên tất cả các kiến trúc và là phần cứng
độc lập.

Đây là giao diện ưa thích cho không gian người dùng để người dùng sử dụng
đầu vào và tất cả khách hàng được khuyến khích sử dụng nó.

Xem ZZ0000ZZ để biết ghi chú về API.

Các thiết bị nằm trong /dev/input::

crw-r--r-- 1 gốc gốc 13, 64 ngày 1 tháng 4 10:49 sự kiện0
	crw-r--r-- 1 gốc gốc 13, 65 ngày 1 tháng 4 10:50 sự kiện1
	crw-r--r-- 1 gốc gốc 13, 66 Ngày 1 tháng 4 10:50 sự kiện2
	crw-r--r-- 1 gốc gốc 13, 67 ngày 1 tháng 4 10:50 sự kiện3
	...

Có hai phạm vi trẻ vị thành niên: 64 đến 95 là di sản tĩnh
phạm vi. Nếu có nhiều hơn 32 thiết bị đầu vào trong một hệ thống,
các nút evdev được tạo bằng các nút vị thành niên bắt đầu bằng 256.

bàn phím
~~~~~~~~

ZZ0000ZZ là trình xử lý đầu vào trong kernel và là một phần của mã VT. Nó
sử dụng các lần nhấn phím trên bàn phím và xử lý thông tin đầu vào của người dùng cho bảng điều khiển VT.

mousedev
~~~~~~~~

ZZ0000ZZ là một bản hack để tạo các chương trình cũ sử dụng đầu vào chuột
làm việc. Nó nhận các sự kiện từ chuột hoặc bộ số hóa/máy tính bảng và thực hiện
thiết bị chuột kiểu PS/2 (a la /dev/psaux) có sẵn cho
đất người dùng.

Các thiết bị Mousedev trong /dev/input (như được hiển thị ở trên) là::

crw-r--r-- 1 gốc gốc 13, 32 28 tháng 3 22:45 mouse0
	crw-r--r-- 1 gốc gốc 13, 33 29 tháng 3 00:41 mouse1
	crw-r--r-- 1 gốc gốc 13, 34 29 tháng 3 00:41 mouse2
	crw-r--r-- 1 gốc gốc 13, 35 ngày 1 tháng 4 10:50 mouse3
	...
	...
crw-r--r-- 1 gốc gốc 13, 62 Ngày 1 tháng 4 10:50 mouse30
	crw-r--r-- 1 gốc gốc 13, 63 1 tháng 4 10:50 chuột

Mỗi thiết bị ZZ0000ZZ được gán cho một con chuột hoặc bộ số hóa, ngoại trừ
cái cuối cùng - ZZ0001ZZ. Thiết bị ký tự đơn này được chia sẻ bởi tất cả
chuột và bộ số hóa, và ngay cả khi không có thiết bị nào được kết nối, thiết bị vẫn
hiện tại.  Điều này rất hữu ích cho việc cắm nóng chuột USB, để các chương trình cũ hơn
không xử lý được hotplug có thể mở được thiết bị ngay cả khi không có chuột
hiện tại.

CONFIG_INPUT_MOUSEDEV_SCREEN_[XY] trong cấu hình kernel là
kích thước màn hình của bạn (tính bằng pixel) trong XFree86. Điều này là cần thiết nếu bạn
muốn sử dụng bộ số hóa của bạn trong X, vì chuyển động của nó được gửi đến X
thông qua chuột PS/2 ảo và do đó cần phải được thu nhỏ lại
tương ứng. Những giá trị này sẽ không được sử dụng nếu bạn chỉ sử dụng chuột.

Mousedev sẽ tạo PS/2, ImPS/2 (Microsoft IntelliMouse) hoặc
Giao thức ExplorerPS/2 (IntelliMouse Explorer), tùy thuộc vào
chương trình đọc dữ liệu mong muốn. Bạn có thể đặt GPM và X thành bất kỳ
những cái này. Bạn sẽ cần ImPS/2 nếu bạn muốn sử dụng bánh xe trên USB
chuột và ExplorerPS/2 nếu bạn muốn sử dụng thêm (tối đa 5) nút.

joydev
~~~~~~

ZZ0001ZZ triển khai cần điều khiển Linux v0.x và v1.x API. Xem
ZZ0000ZZ để biết chi tiết.

Ngay sau khi bất kỳ cần điều khiển nào được kết nối, nó có thể được truy cập trong /dev/input trên::

crw-r--r-- 1 gốc gốc 13, 0 1 tháng 4 10:50 js0
	crw-r--r-- 1 gốc gốc 13, 1 ngày 1 tháng 4 10:50 js1
	crw-r--r-- 1 gốc gốc 13, 2 ngày 1 tháng 4 10:50 js2
	crw-r--r-- 1 gốc gốc 13, 3 ngày 1 tháng 4 10:50 js3
	...

Và cứ tiếp tục như vậy cho đến js31 trong phạm vi kế thừa và các nút bổ sung có phụ
trên 256 nếu có nhiều thiết bị cần điều khiển hơn.

Trình điều khiển thiết bị
-------------------------

Trình điều khiển thiết bị là các mô-đun tạo ra sự kiện.

chung chung
~~~~~~~~~~~

ZZ0000ZZ là một trong những trình điều khiển lớn nhất và phức tạp nhất của
toàn bộ bộ. Nó xử lý tất cả các thiết bị HID và vì có rất nhiều
chúng rất đa dạng và vì thông số kỹ thuật USB HID không
đơn giản, nó cần phải lớn thế này.

Hiện tại, nó xử lý chuột USB, cần điều khiển, gamepad, vô lăng,
bàn phím, bi xoay và bộ số hóa.

Tuy nhiên, USB cũng sử dụng HID để điều khiển màn hình, điều khiển loa, UPS,
LCD và nhiều mục đích khác.

Bộ điều khiển màn hình và loa phải dễ dàng thêm vào phần ẩn/đầu vào
giao diện, nhưng đối với UPS và LCD thì điều đó không có nhiều ý nghĩa. Đối với điều này,
giao diện hiddev đã được thiết kế. Xem Tài liệu/hid/hiddev.rst
để biết thêm thông tin về nó.

Cách sử dụng mô-đun usbhid rất đơn giản, không cần tham số,
tự động phát hiện mọi thứ và khi lắp thiết bị HID, nó
phát hiện nó một cách thích hợp.

Tuy nhiên, vì các thiết bị rất khác nhau nên bạn có thể gặp phải một
thiết bị hoạt động không tốt. Trong trường hợp đó #define DEBUG lúc đầu
của hid-core.c và gửi cho tôi dấu vết nhật ký hệ thống.

chuột USB
~~~~~~~~~

Đối với các hệ thống nhúng, đối với chuột có bộ mô tả HID bị hỏng và bất kỳ
mục đích sử dụng khác khi usbhid lớn không phải là một lựa chọn tốt, có
trình điều khiển chuột usb. Nó chỉ xử lý chuột USB. Nó sử dụng HIDBP đơn giản hơn
giao thức. Điều này cũng có nghĩa là chuột phải hỗ trợ giao thức đơn giản hơn này. Không
tất cả đều làm được. Nếu bạn không có lý do chính đáng nào để sử dụng mô-đun này, hãy sử dụng usbhid
thay vào đó.

usbkbd
~~~~~~

Giống như usbmouse, mô-đun này giao tiếp với bàn phím bằng cách đơn giản hóa
Giao thức HIDBP. Nó nhỏ hơn nhưng không hỗ trợ thêm bất kỳ phím đặc biệt nào.
Thay vào đó hãy sử dụng usbhid nếu không có lý do đặc biệt nào để sử dụng cái này.

psmouse
~~~~~~~

Đây là trình điều khiển cho tất cả các phiên bản của thiết bị trỏ sử dụng PS/2
giao thức, bao gồm bàn di chuột Synaptics và ALPS, Intellimouse
Thiết bị Explorer, chuột Logitech PS/2, v.v.

atkbd
~~~~~

Đây là trình điều khiển cho bàn phím PS/2 (AT).

lực lượng
~~~~~~~~~

Trình điều khiển cho cần điều khiển và bánh xe I-Force, cả trên USB và RS232.
Nó hiện bao gồm hỗ trợ Force Phản hồi, mặc dù Immersion
Corp. coi giao thức là bí mật thương mại và sẽ không tiết lộ một lời nào
về nó.

Xác minh nếu nó hoạt động
=========================

Gõ một vài phím trên bàn phím là đủ để kiểm tra xem
bàn phím hoạt động và được kết nối chính xác với bàn phím kernel
người lái xe.

Thực hiện ZZ0000ZZ (c, 13, 32) sẽ xác minh rằng chuột
cũng được mô phỏng; các ký tự sẽ xuất hiện nếu bạn di chuyển nó.

Bạn có thể kiểm tra mô phỏng cần điều khiển bằng tiện ích ZZ0001ZZ,
có sẵn trong gói cần điều khiển (xem ZZ0000ZZ).

Bạn có thể kiểm tra các thiết bị sự kiện bằng tiện ích ZZ0000ZZ.

.. _event-interface:

Giao diện sự kiện
=================

Bạn có thể sử dụng các lần đọc chặn và không chặn, đồng thời cũng có thể chọn() trên
/dev/input/eventX và bạn sẽ luôn nhận được toàn bộ số lượng đầu vào
sự kiện trên một lần đọc. Bố cục của họ là::

cấu trúc đầu vào_sự kiện {
	    cấu trúc thời gian thời gian;
	    loại ngắn không dấu;
	    mã ngắn không dấu;
	    giá trị int;
    };

ZZ0000ZZ là dấu thời gian, nó trả về thời gian xảy ra sự kiện.
Ví dụ, loại là EV_REL để di chuyển tương đối, EV_KEY để nhấn phím hoặc
thả ra. Nhiều loại khác được định nghĩa trong include/uapi/linux/input-event-codes.h.

ZZ0000ZZ là mã sự kiện, ví dụ REL_X hoặc KEY_BACKSPACE, một lần nữa là mã sự kiện hoàn chỉnh
danh sách nằm trong include/uapi/linux/input-event-codes.h.

ZZ0000ZZ là giá trị mà sự kiện mang lại. Hoặc là một sự thay đổi tương đối cho
EV_REL, giá trị mới tuyệt đối cho EV_ABS (cần điều khiển ...) hoặc 0 cho EV_KEY cho
phát hành, 1 cho nhấn phím và 2 cho tự động lặp lại.

Xem ZZ0000ZZ để biết thêm thông tin về các mã sự kiện khác nhau.
