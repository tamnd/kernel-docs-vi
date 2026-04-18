.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/usb/misc_usbsevseg.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Màn hình số 7 đoạn USB
=============================

Được sản xuất bởi Delcom Engineering

Thông tin thiết bị
------------------
USB VENDOR_ID 0x0fc5
USB PRODUCT_ID 0x1227
Cả màn hình 6 ký tự và 8 ký tự đều có PRODUCT_ID,
và theo Delcom Engineering thì không có thông tin nào có thể truy vấn được
có thể được lấy từ thiết bị để phân biệt chúng.

Chế độ thiết bị
------------
Theo mặc định, trình điều khiển giả định màn hình chỉ có 6 ký tự
Chế độ cho 6 ký tự là:

MSB 0x06; LSB 0x3f

Đối với màn hình 8 ký tự:

MSB 0x08; LSB 0xff

Thiết bị có thể chấp nhận "văn bản" ở chế độ văn bản thô, hex hoặc ascii.
raw điều khiển từng phân đoạn theo cách thủ công,
hex mong đợi giá trị trong khoảng 0-15 cho mỗi ký tự,
ascii mong đợi giá trị nằm trong khoảng '0'-'9' và 'A'-'F'.
Mặc định là ascii.

Vận hành thiết bị
----------------
1. Bật thiết bị:
	echo 1 > /sys/bus/usb/.../được hỗ trợ
2. Cài đặt chế độ của thiết bị:
	echo $mode_msb > /sys/bus/usb/.../mode_msb
	echo $mode_lsb > /sys/bus/usb/.../mode_lsb
3. Đặt chế độ văn bản:
	echo $textmode > /sys/bus/usb/.../textmode
4. đặt văn bản (ví dụ):
	echo "123ABC" > /sys/bus/usb/.../text (ascii)
	echo "A1B2" > /sys/bus/usb/.../text (ascii)
	echo -ne "\x01\x02\x03" > /sys/bus/usb/.../text (hex)
5. Đặt số thập phân.
	Thiết bị có 6 hoặc 8 điểm thập phân.
	để đặt vị trí thập phân thứ n tính 10 ** n
	và lặp lại nó trong /sys/bus/usb/.../decimals
	Để đặt nhiều số thập phân, hãy tính tổng từng lũy thừa.
	Ví dụ: để đặt vị trí thập phân thứ 0 và thứ 3
	echo 1001 > /sys/bus/usb/.../số thập phân
