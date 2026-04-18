.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hid/hiddev.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================================
Chăm sóc và cung cấp thiết bị giao diện con người của bạn
================================================

Giới thiệu
============

Ngoài các thiết bị HID loại đầu vào thông thường, USB còn sử dụng
giao thức thiết bị giao diện con người cho những thứ không thực sự là con người
giao diện, nhưng có loại nhu cầu giao tiếp tương tự. Hai cái lớn
ví dụ cho điều này là các thiết bị điện (đặc biệt là nguồn điện liên tục
vật tư) và điều khiển màn hình trên màn hình cao cấp hơn.

Để hỗ trợ các yêu cầu khác nhau này, hệ thống Linux USB cung cấp
Sự kiện HID thành hai giao diện riêng biệt:
* hệ thống con đầu vào, chuyển đổi các sự kiện HID thành đầu vào bình thường
giao diện thiết bị (chẳng hạn như bàn phím, chuột và cần điều khiển) và
giao diện sự kiện được chuẩn hóa - xem Tài liệu/input/input.rst
* giao diện hiddev, cung cấp các sự kiện HID khá thô

Luồng dữ liệu cho sự kiện HID do thiết bị tạo ra giống như
sau đây::

usb.c ---> hid-core.c ----> hid-input.c ----> [bàn phím/chuột/cần điều khiển/sự kiện]
                         |
                         |
                          --> hiddev.c ----> POWER / MONITOR CONTROL

Ngoài ra, các hệ thống con khác (ngoài USB) có khả năng cung cấp
các sự kiện vào hệ thống con đầu vào, nhưng chúng không ảnh hưởng đến HID
giao diện thiết bị.

Sử dụng giao diện thiết bị HID
==============================

Giao diện hiddev là giao diện char sử dụng USB chính thông thường,
với các số phụ bắt đầu từ 96 và kết thúc ở 111. Do đó,
bạn cần các lệnh sau ::

mknod /dev/usb/hiddev0 c 180 96
	mknod /dev/usb/hiddev1 c 180 97
	mknod /dev/usb/hiddev2 c 180 98
	mknod /dev/usb/hiddev3 c 180 99
	mknod /dev/usb/hiddev4 c 180 100
	mknod /dev/usb/hiddev5 c 180 101
	mknod /dev/usb/hiddev6 c 180 102
	mknod /dev/usb/hiddev7 c 180 103
	mknod /dev/usb/hiddev8 c 180 104
	mknod /dev/usb/hiddev9 c 180 105
	mknod /dev/usb/hiddev10 c 180 106
	mknod /dev/usb/hiddev11 c 180 107
	mknod /dev/usb/hiddev12 c 180 108
	mknod /dev/usb/hiddev13 c 180 109
	mknod /dev/usb/hiddev14 c 180 110
	mknod /dev/usb/hiddev15 c 180 111

Vì vậy, bạn trỏ chương trình không gian người dùng tuân thủ hiddev của mình vào đúng
giao diện cho thiết bị của bạn và tất cả đều hoạt động.

Giả sử rằng bạn có một chương trình không gian người dùng tuân thủ hiddev, trong số
tất nhiên. Nếu bạn cần viết một cái, hãy đọc tiếp.


HIDDEV API
==============

Mô tả này nên được đọc cùng với HID
đặc điểm kỹ thuật, có sẵn miễn phí từ ZZ0000ZZ và
liên kết thuận tiện của ZZ0001ZZ

Hiddev API sử dụng giao diện read() và một tập hợp các lệnh gọi ioctl().

Thiết bị HID trao đổi dữ liệu với máy chủ bằng dữ liệu
gói được gọi là "báo cáo".  Mỗi báo cáo được chia thành các "trường",
mỗi trong số đó có thể có một hoặc nhiều "công dụng".  Trong lõi ẩn,
mỗi cách sử dụng này có một giá trị 32 bit được ký.

đọc():
-------

Đây là giao diện sự kiện.  Khi trạng thái của thiết bị HID thay đổi,
nó thực hiện truyền ngắt có chứa một báo cáo chứa
giá trị đã thay đổi.  Mô-đun hid-core.c phân tích báo cáo và
trả về hiddev.c các cách sử dụng riêng lẻ đã thay đổi trong
bản báo cáo.  Ở chế độ cơ bản, hiddev sẽ khiến những cá nhân này
những thay đổi về cách sử dụng có sẵn cho người đọc bằng cách sử dụng cấu trúc hiddev_event::

cấu trúc hiddev_event {
           ẩn không dấu;
           giá trị int đã ký;
       };

chứa mã định danh sử dụng HID cho trạng thái đã thay đổi và
giá trị mà nó đã được thay đổi thành. Lưu ý rằng cấu trúc được xác định
trong <linux/hiddev.h>, cùng với một số #defines hữu ích khác và
các cấu trúc.  Mã định danh sử dụng HID là sự kết hợp của cách sử dụng HID
trang đã chuyển sang 16 bit bậc cao HOẶC với mã sử dụng.  các
hành vi của hàm read() có thể được sửa đổi bằng HIDIOCSFLAG
ioctl() được mô tả bên dưới.


ioctl():
--------

Đây là giao diện điều khiển. Có một số điều khiển:

HIDIOCGVERSION
  - int (đọc)

Lấy mã phiên bản ra khỏi trình điều khiển hiddev.

HIDIOCAPPLICATION
  - (không có)

Cuộc gọi ioctl này trả về việc sử dụng ứng dụng HID được liên kết với
Thiết bị HID. Đối số thứ ba của ioctl() chỉ định ứng dụng nào
chỉ mục để có được. Điều này rất hữu ích khi thiết bị có nhiều hơn một
bộ sưu tập ứng dụng. Nếu chỉ mục không hợp lệ (lớn hơn hoặc bằng
số lượng bộ sưu tập ứng dụng mà thiết bị này có) ioctl
trả về -1. Bạn có thể tìm hiểu trước có bao nhiêu ứng dụng
các bộ sưu tập mà thiết bị có từ trường num_applications từ
cấu trúc hiddev_devinfo.

HIDIOCGCOLLECTIONINFO
  - struct hiddev_collection_info (đọc/ghi)

Điều này trả về một siêu thông tin ở trên, không chỉ cung cấp
bộ sưu tập ứng dụng, nhưng tất cả các bộ sưu tập mà thiết bị có.  Nó
cũng trả về cấp độ của bộ sưu tập trong hệ thống phân cấp.
Người dùng chuyển vào cấu trúc hiddev_collection_info với chỉ mục
trường được đặt thành chỉ mục cần được trả về.  ioctl điền vào
các lĩnh vực khác.  Nếu chỉ mục lớn hơn bộ sưu tập cuối cùng
chỉ mục, ioctl trả về -1 và đặt errno thành -EINVAL.

HIDIOCGDEVINFO
  - struct hiddev_devinfo (đọc)

Nhận cấu trúc hiddev_devinfo mô tả thiết bị.

HIDIOCGSTRING
  - struct hiddev_string_descriptor (đọc/ghi)

Nhận một bộ mô tả chuỗi từ thiết bị. Người gọi phải điền vào
trường "chỉ mục" để cho biết bộ mô tả nào sẽ được trả về.

HIDIOCINITREPORT
  - (không có)

Hướng dẫn kernel truy xuất tất cả các giá trị báo cáo đầu vào và tính năng
từ thiết bị. Tại thời điểm này, tất cả các cấu trúc sử dụng sẽ chứa
giá trị hiện tại cho thiết bị và sẽ duy trì nó như thiết bị
những thay đổi.  Lưu ý rằng việc sử dụng ioctl này nói chung là không cần thiết,
vì các hạt nhân sau này sẽ tự động khởi tạo các báo cáo từ
thiết bị tại thời điểm đính kèm.

HIDIOCGNAME
  - chuỗi (độ dài thay đổi)

Lấy tên thiết bị

HIDIOCGREPORT
  - struct hiddev_report_info (viết)

Hướng dẫn kernel lấy một tính năng hoặc báo cáo đầu vào từ thiết bị,
nhằm cập nhật có chọn lọc cơ cấu sử dụng (ngược lại với
INITREPORT).

HIDIOCSREPORT
  - struct hiddev_report_info (viết)

Hướng dẫn kernel gửi báo cáo đến thiết bị. Báo cáo này có thể
được người dùng điền thông qua lệnh gọi HIDIOCSUSAGE (bên dưới) để điền vào
giá trị sử dụng riêng lẻ trong báo cáo trước khi gửi báo cáo đầy đủ
tới thiết bị.

HIDIOCGREPORTINFO
  - struct hiddev_report_info (đọc/ghi)

Điền vào cấu trúc hiddev_report_info cho người dùng. Báo cáo là
tra cứu theo loại (đầu vào, đầu ra hoặc tính năng) và id, vì vậy các trường này
người dùng phải điền vào. ID có thể tuyệt đối -- ID thực tế
id báo cáo do thiết bị báo cáo -- hoặc người thân --
HID_REPORT_ID_FIRST cho báo cáo đầu tiên và (HID_REPORT_ID_NEXT |
report_id) cho báo cáo tiếp theo sau report_id. Không có tiên nghiệm
thông tin về id báo cáo, cách đúng đắn để sử dụng ioctl này là
sử dụng các ID tương đối ở trên để liệt kê các ID hợp lệ. ioctl
trả về khác 0 khi không còn ID tiếp theo. ID báo cáo thực sự là
được điền vào cấu trúc hiddev_report_info được trả về.

HIDIOCGFIELDINFO
  - struct hiddev_field_info (đọc/ghi)

Trả về thông tin trường liên quan đến một báo cáo trong một
cấu trúc hiddev_field_info. Người dùng phải điền report_id và
report_type trong cấu trúc này, như trên. field_index cũng nên
được điền vào, phải là một số từ 0 và maxfield-1, như
được trả về từ cuộc gọi HIDIOCGREPORTINFO trước đó.

HIDIOCGUCODE
  - struct hiddev_usage_ref (đọc/ghi)

Trả về use_code trong cấu trúc hiddev_usage_ref, với điều kiện là
loại báo cáo, id báo cáo, chỉ mục trường và chỉ mục trong
trường đã được điền vào cấu trúc.

HIDIOCGUSAGE
  - struct hiddev_usage_ref (đọc/ghi)

Trả về giá trị sử dụng trong cấu trúc hiddev_usage_ref. các
mức sử dụng cần truy xuất có thể được chỉ định như trên hoặc người dùng có thể
chọn điền vào trường report_type và chỉ định report_id là
HID_REPORT_ID_UNKNOWN. Trong trường hợp này, hiddev_usage_ref sẽ là
điền vào báo cáo và thông tin trường liên quan đến điều này
sử dụng nếu nó được tìm thấy.

HIDIOCSUSAGE
  - struct hiddev_usage_ref (viết)

Đặt giá trị sử dụng trong báo cáo đầu ra.  Người dùng điền vào
cấu trúc hiddev_usage_ref như trên nhưng còn điền vào
trường giá trị.

HIDIOGCOLLECTIONINDEX
  - struct hiddev_usage_ref (viết)

Trả về chỉ mục bộ sưu tập được liên kết với cách sử dụng này.  Cái này
cho biết cách sử dụng này nằm ở đâu trong hệ thống phân cấp bộ sưu tập.

HIDIOCGFLAG
  - int (đọc)
HIDIOCSFLAG
  - int (viết)

Các hoạt động này lần lượt kiểm tra và thay thế các cờ chế độ
ảnh hưởng đến lệnh gọi read() ở trên.  Các lá cờ như sau:

HIDDEV_FLAG_UREF
      - các cuộc gọi read() bây giờ sẽ quay trở lại
        cấu trúc hiddev_usage_ref thay vì cấu trúc hiddev_event.
        Đây là một cấu trúc lớn hơn, nhưng trong những tình huống mà
        thiết bị có nhiều cách sử dụng trong các báo cáo của nó với
        cùng một mã sử dụng, chế độ này phục vụ để giải quyết vấn đề đó
        sự mơ hồ.

HIDDEV_FLAG_REPORT
      - Cờ này chỉ có thể được sử dụng kết hợp
        với HIDDEV_FLAG_UREF.  Với cờ này được đặt, khi thiết bị
        gửi báo cáo, cấu trúc hiddev_usage_ref sẽ được trả về
        để read() điền vào report_type và report_id, nhưng
        với field_index được đặt thành FIELD_INDEX_NONE.  Điều này phục vụ như
        thông báo bổ sung khi thiết bị đã gửi báo cáo.
