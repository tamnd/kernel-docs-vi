.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hid/hidraw.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================================================
HIDRAW - Quyền truy cập thô vào USB và thiết bị giao diện con người Bluetooth
=============================================================================

Trình điều khiển hidraw cung cấp giao diện thô cho USB và Bluetooth Human
Thiết bị giao diện (HID).  Nó khác với hiddev ở chỗ các báo cáo được gửi và
nhận được không được phân tích cú pháp bởi trình phân tích cú pháp HID, nhưng được gửi đến và nhận từ
thiết bị chưa được sửa đổi.

Nên sử dụng Hidraw nếu ứng dụng không gian người dùng biết chính xác cách
giao tiếp với thiết bị phần cứng và có thể xây dựng HID
báo cáo một cách thủ công.  Điều này thường xảy ra khi tạo trình điều khiển không gian người dùng cho
thiết bị HID tùy chỉnh.

Hidraw cũng hữu ích để liên lạc với các thiết bị HID không phù hợp
gửi và nhận dữ liệu theo cách không phù hợp với báo cáo của họ
những người mô tả.  Bởi vì hiddev phân tích các báo cáo được gửi và nhận
thông qua nó, kiểm tra chúng dựa trên bộ mô tả báo cáo của thiết bị, chẳng hạn như
không thể liên lạc với các thiết bị không phù hợp này bằng cách sử dụng hiddev.
Hidraw là giải pháp thay thế duy nhất, ngoài việc viết trình điều khiển hạt nhân tùy chỉnh, dành cho
những thiết bị không phù hợp này.

Lợi ích của hidraw là việc sử dụng nó bởi các ứng dụng không gian người dùng là độc lập.
của loại phần cứng cơ bản.  Hiện tại, hidraw được triển khai cho USB
và Bluetooth.  Trong tương lai, khi các loại bus phần cứng mới được phát triển,
sử dụng thông số kỹ thuật HID, hidraw sẽ được mở rộng để thêm hỗ trợ cho những thông số này
các loại xe buýt mới.

Hidraw sử dụng số chính động, nghĩa là nên dựa vào udev để
tạo các nút thiết bị ẩn.  Udev thường sẽ tạo các nút thiết bị
ngay dưới/dev (ví dụ:/dev/hidraw0).  Vì vị trí này là nơi phân phối-
và phụ thuộc vào quy tắc udev, các ứng dụng nên sử dụng libudev để định vị hidraw
các thiết bị gắn vào hệ thống.  Có một hướng dẫn về libudev với
ví dụ làm việc tại::

ZZ0000ZZ
	ZZ0001ZZ

HIDRAW API
---------------

đọc()
-------
read() sẽ đọc báo cáo xếp hàng nhận được từ thiết bị HID. Trên USB
thiết bị, các báo cáo được đọc bằng read() là các báo cáo được gửi từ thiết bị
trên điểm cuối INTERRUPT IN.  Theo mặc định, read() sẽ chặn cho đến khi có
một báo cáo có sẵn để đọc  read() có thể được thực hiện không bị chặn bằng cách chuyển
cờ O_NONBLOCK thành open() hoặc bằng cách đặt cờ O_NONBLOCK bằng cách sử dụng
fcntl().

Trên thiết bị sử dụng báo cáo được đánh số, byte đầu tiên của dữ liệu được trả về
sẽ là số báo cáo; dữ liệu báo cáo tiếp theo, bắt đầu từ phần thứ hai
byte.  Đối với các thiết bị không sử dụng báo cáo được đánh số, dữ liệu báo cáo
sẽ bắt đầu ở byte đầu tiên.

viết()
-------
Hàm write() sẽ viết báo cáo cho thiết bị. Đối với thiết bị USB, nếu
thiết bị có điểm cuối INTERRUPT OUT, báo cáo sẽ được gửi trên đó
điểm cuối. Nếu không, báo cáo sẽ được gửi qua điểm cuối kiểm soát,
sử dụng chuyển SET_REPORT.

Byte đầu tiên của bộ đệm được chuyển tới write() phải được đặt thành báo cáo
số.  Nếu thiết bị không sử dụng các báo cáo được đánh số thì byte đầu tiên sẽ
được đặt thành 0. Bản thân dữ liệu báo cáo sẽ bắt đầu ở byte thứ hai.

ioctl()
-------
Hidraw hỗ trợ các ioctls sau:

HIDIOCGRDESCSIZE:
	Nhận kích thước mô tả báo cáo

Ioctl này sẽ lấy kích thước của bộ mô tả báo cáo của thiết bị.

HIDIOCGRDESC:
	Nhận mô tả báo cáo

Ioctl này trả về bộ mô tả báo cáo của thiết bị bằng cách sử dụng
cấu trúc hidraw_report_descriptor.  Đảm bảo đặt trường kích thước của
cấu trúc hidraw_report_descriptor thành kích thước được trả về từ HIDIOCGRDESCSIZE.

HIDIOCGRAWINFO:
	Nhận thông tin thô

Ioctl này sẽ trả về cấu trúc hidraw_devinfo chứa loại bus,
ID nhà cung cấp (VID) và ID sản phẩm (PID) của thiết bị. Loại xe buýt có thể là một
của::

-BUS_USB
	-BUS_HIL
	-BUS_BLUETOOTH
	-BUS_VIRTUAL

được định nghĩa trong uapi/linux/input.h.

HIDIOCGRAWNAME(len):
	Nhận tên thô

ioctl này trả về một chuỗi chứa chuỗi nhà cung cấp và sản phẩm của
thiết bị.  Chuỗi trả về là Unicode, được mã hóa UTF-8.

HIDIOCGRAWPHYS(len):
	Nhận địa chỉ vật lý

Ioctl này trả về một chuỗi biểu thị địa chỉ vật lý của thiết bị.
Đối với thiết bị USB, chuỗi chứa đường dẫn vật lý đến thiết bị (
Bộ điều khiển USB, hub, cổng, v.v.).  Đối với các thiết bị Bluetooth, chuỗi
chứa địa chỉ phần cứng (MAC) của thiết bị.

HIDIOCSFEATURE(len):
	Gửi báo cáo tính năng

Ioctl này sẽ gửi báo cáo tính năng tới thiết bị.  Theo HID
đặc điểm kỹ thuật, báo cáo tính năng luôn được gửi bằng điểm cuối kiểm soát.
Đặt byte đầu tiên của bộ đệm được cung cấp thành số báo cáo.  Dành cho thiết bị
không sử dụng báo cáo được đánh số, đặt byte đầu tiên thành 0. Dữ liệu báo cáo
bắt đầu ở byte thứ hai. Đảm bảo đặt len phù hợp, thành một cái nữa
hơn độ dài của báo cáo (để tính số báo cáo).

HIDIOCGFEATURE(len):
	Nhận báo cáo tính năng

Ioctl này sẽ yêu cầu báo cáo tính năng từ thiết bị bằng cách sử dụng điều khiển
điểm cuối.  Byte đầu tiên của bộ đệm được cung cấp phải được đặt thành báo cáo
số báo cáo được yêu cầu.  Đối với các thiết bị không sử dụng số
báo cáo, đặt byte đầu tiên thành 0. Bộ đệm báo cáo được trả về sẽ chứa
số báo cáo trong byte đầu tiên, theo sau là dữ liệu báo cáo được đọc từ
thiết bị.  Đối với các thiết bị không sử dụng báo cáo được đánh số, dữ liệu báo cáo sẽ
bắt đầu ở byte đầu tiên của bộ đệm được trả về.

HIDIOCSINPUT(len):
	Gửi báo cáo đầu vào

Ioctl này sẽ gửi báo cáo đầu vào đến thiết bị, sử dụng điểm cuối điều khiển.
Trong hầu hết các trường hợp, việc đặt báo cáo HID đầu vào trên thiết bị là vô nghĩa và có
không có tác dụng, nhưng một số thiết bị có thể chọn sử dụng tính năng này để đặt hoặc đặt lại giá trị ban đầu
trạng thái của một báo cáo.  Định dạng của bộ đệm được phát hành cùng với báo cáo này giống hệt nhau
so với HIDIOCSFEATURE.

HIDIOCGINPUT(len):
	Nhận báo cáo đầu vào

Ioctl này sẽ yêu cầu báo cáo đầu vào từ thiết bị bằng cách sử dụng điều khiển
điểm cuối.  Tốc độ này chậm hơn trên hầu hết các thiết bị có điểm cuối In chuyên dụng
đối với các báo cáo đầu vào thông thường nhưng cho phép máy chủ yêu cầu giá trị của
số báo cáo cụ thể  Thông thường, điều này được sử dụng để yêu cầu trạng thái ban đầu của
báo cáo đầu vào của thiết bị, trước khi ứng dụng lắng nghe các báo cáo thông thường qua
giao diện read() của thiết bị thông thường.  Định dạng của bộ đệm được phát hành cùng với báo cáo này
giống hệt với HIDIOCGFEATURE.

HIDIOCSOUTPUT(len):
	Gửi báo cáo đầu ra

Ioctl này sẽ gửi báo cáo đầu ra tới thiết bị, sử dụng điểm cuối điều khiển.
Quá trình này chậm hơn trên hầu hết các thiết bị có điểm cuối Out chuyên dụng cho hoạt động thông thường.
báo cáo đầu ra, nhưng được bổ sung cho đầy đủ.  Thông thường, điều này được sử dụng để thiết lập
trạng thái ban đầu của báo cáo đầu ra của thiết bị, trước khi ứng dụng gửi
cập nhật thông qua giao diện write() của thiết bị thông thường. Định dạng của bộ đệm được phát hành
với báo cáo này giống hệt với báo cáo của HIDIOCSFEATURE.

HIDIOCGOUTPUT(len):
	Nhận báo cáo đầu ra

Ioctl này sẽ yêu cầu báo cáo đầu ra từ thiết bị bằng cách sử dụng điều khiển
điểm cuối.  Thông thường, điều này được sử dụng để lấy lại trạng thái ban đầu của
báo cáo đầu ra của thiết bị, trước khi ứng dụng cập nhật thiết bị đó khi cần thiết
thông qua yêu cầu HIDIOCSOUTPUT hoặc giao diện write() của thiết bị thông thường.  Định dạng
của bộ đệm được phát hành cùng với báo cáo này giống với bộ đệm của HIDIOCGFEATURE.

Ví dụ
-------
Trong samples/, tìm hid-example.c, hiển thị các ví dụ về read(), write(),
và tất cả ioctls cho hidraw.  Bất kỳ ai cũng có thể sử dụng mã này cho bất kỳ mục đích nào
mục đích và có thể đóng vai trò là điểm khởi đầu để phát triển các ứng dụng sử dụng
ẩn.

Tài liệu bởi:

Alan Ott <alan@signal11.us>, Phần mềm Tín hiệu 11
