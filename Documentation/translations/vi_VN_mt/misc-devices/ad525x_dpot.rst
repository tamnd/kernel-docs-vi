.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/misc-devices/ad525x_dpot.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================================
Chiết áp kỹ thuật số AD525x
=============================

Trình điều khiển ad525x_dpot xuất giao diện sysfs đơn giản.  Điều này cho phép bạn
làm việc với các cài đặt kháng cự ngay lập tức cũng như cập nhật phần khởi động đã lưu
cài đặt.  Quyền truy cập vào dung sai được lập trình của nhà máy cũng được cung cấp, nhưng
ứng dụng cuối yêu cầu giải thích cài đặt này theo
phần cụ thể được sử dụng.

Tập tin
=====

Mỗi thiết bị dpot sẽ có một bộ tệp eeprom, rdac và dung sai.  Làm thế nào
nhiều phụ thuộc vào phần thực tế bạn có, cũng như phạm vi giá trị được phép.

Các tệp eeprom được sử dụng để lập trình giá trị khởi động của thiết bị.

Các tệp rdac được sử dụng để lập trình giá trị tức thời của thiết bị.

Các tệp dung sai là các cài đặt dung sai được lập trình tại nhà máy chỉ đọc
và có thể khác nhau rất nhiều tùy theo từng phần.  Để giải thích chính xác về
trường này, vui lòng tham khảo bảng dữ liệu cho phần của bạn.  Điều này được trình bày
dưới dạng tệp hex để phân tích cú pháp dễ dàng hơn.

Ví dụ
=======

Xác định vị trí thiết bị trong cây sysfs của bạn.  Điều này có lẽ dễ dàng nhất bằng cách đi vào
thư mục i2c chung và định vị thiết bị theo địa chỉ nô lệ i2c ::

# ls /sys/bus/i2c/thiết bị/
	0-0022 0-0027 0-002f

Vì vậy, giả sử thiết bị được đề cập nằm trên bus i2c đầu tiên và có thiết bị phụ
địa chỉ 0x2f, chúng tôi đi xuống (các mục sysfs không liên quan đã bị cắt bớt)::

# ls /sys/bus/i2c/devices/0-002f/
	eeprom0 rdac0 dung sai0

Bạn có thể sử dụng cách đọc/ghi đơn giản để truy cập các tệp này ::

# cd /sys/bus/i2c/devices/0-002f/

# cat eeprom0
	0
	# echo 10 > eeprom0
	# cat eeprom0
	10

# catrdac0
	5
	# echo 3 > rdac0
	# cat rdac0
	3