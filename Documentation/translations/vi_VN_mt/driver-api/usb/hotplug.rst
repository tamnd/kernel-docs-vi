.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/usb/hotplug.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Cắm nóng USB
~~~~~~~~~~~~~~~

Cắm nóng Linux
=================


Trong các xe buýt có thể cắm nóng như USB (và Cardbus PCI), các thiết bị cắm của người dùng cuối
vào xe buýt khi bật nguồn.  Trong hầu hết các trường hợp, người dùng mong đợi các thiết bị sẽ trở nên
có thể sử dụng được ngay.  Điều đó có nghĩa là hệ thống phải thực hiện nhiều việc, bao gồm:

- Tìm driver có thể xử lý được thiết bị.  Điều đó có thể liên quan
      tải mô-đun hạt nhân; trình điều khiển mới hơn có thể sử dụng công cụ mô-đun-init
      để xuất bản hỗ trợ thiết bị (và lớp) của họ tới các tiện ích của người dùng.

- Liên kết trình điều khiển với thiết bị đó.  Khung xe buýt thực hiện điều đó bằng cách sử dụng một
      thói quen thăm dò() của trình điều khiển thiết bị.

- Yêu cầu các hệ thống con khác cấu hình thiết bị mới.  In
      hàng đợi có thể cần được kích hoạt, mạng được đưa lên, đĩa
      phân vùng được gắn kết, v.v.  Trong một số trường hợp những điều này sẽ
      là hành động cụ thể của người lái xe.

Điều này liên quan đến sự kết hợp giữa chế độ kernel và các hành động ở chế độ người dùng.  Làm thiết bị
có thể sử dụng được ngay lập tức có nghĩa là mọi hành động ở chế độ người dùng đều không thể đợi
quản trị viên thực hiện chúng: hạt nhân phải kích hoạt chúng một cách thụ động
(kích hoạt một số trình nền giám sát để gọi chương trình trợ giúp) hoặc
tích cực (gọi trực tiếp chương trình trợ giúp chế độ người dùng như vậy).

Những hành động được kích hoạt đó phải hỗ trợ các chính sách quản trị của hệ thống;
những chương trình như vậy ở đây được gọi là "đại lý chính sách".  Thông thường chúng liên quan đến
các tập lệnh shell gửi đến các công cụ quản trị quen thuộc hơn.

Bởi vì một số hành động đó dựa vào thông tin về trình điều khiển (siêu dữ liệu)
hiện chỉ khả dụng khi trình điều khiển được liên kết động,
bạn có được khả năng cắm nóng tốt nhất khi định cấu hình một hệ thống có tính mô-đun cao.

Trình trợ giúp cắm nóng hạt nhân (ZZ0000ZZ)
=========================================

Có một tham số kernel: ZZ0000ZZ, thông thường
giữ tên đường dẫn ZZ0001ZZ.  Tham số đó đặt tên cho một chương trình
mà kernel có thể gọi vào nhiều thời điểm khác nhau.

Chương trình /sbin/hotplug có thể được gọi bởi bất kỳ hệ thống con nào như một phần của nó
phản ứng với sự thay đổi cấu hình, từ một luồng trong hệ thống con đó.
Chỉ cần một tham số: tên của hệ thống con được thông báo
một số sự kiện hạt nhân.  Tên đó được sử dụng làm khóa đầu tiên cho sự kiện tiếp theo
công văn; bất kỳ tham số đối số và môi trường nào khác được chỉ định bởi
hệ thống con thực hiện lệnh gọi đó.

Phần mềm Hotplug và các tài nguyên khác có sẵn tại:

ZZ0000ZZ

Thông tin danh sách gửi thư cũng có sẵn tại trang web đó.


Đại lý chính sách USB
================

Hệ thống con USB hiện gọi ZZ0000ZZ khi các thiết bị USB
được thêm vào hoặc xóa khỏi hệ thống.  Việc gọi được thực hiện bởi kernel
hàng đợi công việc trung tâm [hub_wq] hoặc nếu không thì là một phần của quá trình khởi tạo trung tâm gốc
(được thực hiện bởi init, modprobe, kapmd, v.v.).  Tham số dòng lệnh duy nhất của nó
là chuỗi "usb" và nó chuyển các biến môi trường sau:

===========================================================
ACTION ZZ0000ZZ, ZZ0001ZZ
Mã nhà cung cấp, sản phẩm và phiên bản PRODUCT USB (hex)
Mã lớp thiết bị TYPE (thập phân)
Giao diện INTERFACE 0 mã lớp (thập phân)
===========================================================

Nếu "usbdevfs" được định cấu hình, DEVICE và DEVFS cũng được chuyển.  DEVICE là
tên đường dẫn của thiết bị và hữu ích cho các thiết bị có nhiều và/hoặc
giao diện thay thế làm phức tạp việc lựa chọn trình điều khiển.  Theo thiết kế, USB
cắm nóng độc lập với ZZ0000ZZ: bạn có thể thực hiện hầu hết các phần thiết yếu
thiết lập thiết bị USB mà không sử dụng hệ thống tập tin đó và không chạy chương trình
daemon chế độ người dùng để phát hiện những thay đổi trong cấu hình hệ thống.

Việc triển khai tác nhân chính sách hiện có có thể tải trình điều khiển cho
mô-đun và có thể gọi các tập lệnh thiết lập dành riêng cho trình điều khiển.  Những cái mới nhất
tận dụng hỗ trợ công cụ khởi tạo mô-đun USB.  Các đại lý sau này có thể dỡ trình điều khiển.


Hỗ trợ các modutils USB
====================

Các phiên bản hiện tại của module-init-tools sẽ tạo tệp ZZ0000ZZ
chứa các mục từ ZZ0001ZZ của mỗi trình điều khiển.  Như vậy
các tập tin có thể được sử dụng bởi nhiều tác nhân chính sách chế độ người dùng khác nhau để đảm bảo tất cả
mô-đun trình điều khiển phù hợp sẽ được tải vào lúc khởi động hoặc muộn hơn.

Xem ZZ0000ZZ để biết thông tin đầy đủ về các mục trong bảng đó; hoặc nhìn
tại các trình điều khiển hiện có.  Mỗi mục trong bảng mô tả một hoặc nhiều tiêu chí để
được sử dụng khi khớp trình điều khiển với một thiết bị hoặc loại thiết bị.  các
tiêu chí cụ thể được xác định bằng các bit được đặt trong "match_flags", được ghép nối
với các giá trị trường.  Bạn có thể xây dựng các tiêu chí một cách trực tiếp hoặc bằng
các macro như thế này và sử dụng driver_info để lưu trữ thêm thông tin ::

USB_DEVICE (Id nhà cung cấp, Id sản phẩm)
	... matching devices with specified vendor and product ids
    USB_DEVICE_VER (vendorId, productId, lo, hi)
	... like USB_DEVICE with lo <= productversion <= hi
    USB_INTERFACE_INFO (class, subclass, protocol)
	... matching specified interface class info
    USB_DEVICE_INFO (class, subclass, protocol)
	... matching specified device class info

Một ví dụ ngắn về trình điều khiển hỗ trợ một số thiết bị USB cụ thể
và những điều kỳ quặc của họ, có thể có MODULE_DEVICE_TABLE như thế này::

const tĩnh struct usb_device_id mydriver_id_table[] = {
	{ USB_DEVICE (0x9999, 0xaaaa), driver_info: QUIRK_X },
	{ USB_DEVICE (0xbbbb, 0x8888), driver_info: QUIRK_Y|QUIRK_Z },
	...
{ } /* kết thúc bằng mục nhập toàn số 0 */
    };
    MODULE_DEVICE_TABLE(usb, mydriver_id_table);

Hầu hết các trình điều khiển thiết bị USB phải chuyển các bảng này tới hệ thống con USB dưới dạng
cũng như hệ thống con quản lý mô-đun.  Tuy nhiên, không phải tất cả: một số tài xế
các khung kết nối bằng cách sử dụng các giao diện được xếp lớp trên USB và vì vậy chúng sẽ không
cần một cấu trúc usb_driver như vậy.

Cần khai báo các driver kết nối trực tiếp với hệ thống con USB
một cái gì đó như thế này::

cấu trúc tĩnh usb_driver mydriver = {
	.name = "mydriver",
	.id_table = mydriver_id_table,
	.probe = my_probe,
	.disconnect = my_disconnect,

/*
	nếu sử dụng khung usb chardev:
	    .minor = MY_USB_MINOR_START,
	    .fops = my_file_ops,
	nếu phơi bày bất kỳ hoạt động nào thông qua usbdevfs:
	    .ioctl = my_ioctl,
	*/
    };

Khi hệ thống con USB biết về bảng ID thiết bị của trình điều khiển, nó sẽ được sử dụng khi
chọn trình điều khiển để thăm dò().  Chuỗi thực hiện kiểm tra xử lý thiết bị mới
mục nhập ID thiết bị của trình điều khiển từ ZZ0000ZZ dựa trên giao diện
và mô tả thiết bị cho thiết bị.  Nó sẽ chỉ gọi ZZ0001ZZ nếu có
là một kết quả trùng khớp và đối số thứ ba cho ZZ0002ZZ sẽ là mục nhập
khớp.

Nếu bạn không cung cấp ZZ0000ZZ cho trình điều khiển của mình thì trình điều khiển của bạn có thể nhận được
được thăm dò cho từng thiết bị mới; tham số thứ ba cho ZZ0001ZZ sẽ là
ZZ0002ZZ.
