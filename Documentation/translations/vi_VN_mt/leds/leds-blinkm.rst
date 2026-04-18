.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/leds/leds-blinkm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================
Trình điều khiển Led BlinkM
==================

Trình điều khiển leds-blinkm hỗ trợ các thiết bị thuộc dòng BlinkM.

Chúng là các mô-đun RGB-LED được điều khiển bởi một bộ vi điều khiển cực nhỏ (AT) và
giao tiếp thông qua I2C. Địa chỉ mặc định của các module này là
0x09 nhưng điều này có thể được thay đổi thông qua lệnh. Bằng cách này bạn có thể
chuỗi cúc lên tới 127 BlinkM trên xe buýt I2C.

Thiết bị chấp nhận các giá trị màu RGB và HSB thông qua các lệnh riêng biệt.
Ngoài ra, bạn có thể lưu trữ các chuỗi nhấp nháy dưới dạng "tập lệnh" trong
bộ điều khiển và chạy chúng. Ngoài ra mờ dần là một lựa chọn.

Giao diện trình điều khiển này cung cấp gồm 3 phần:

a) Giao diện lớp nhiều màu LED để sử dụng với trình kích hoạt
#######################################################

Việc đăng ký thực hiện theo sơ đồ::

chớp mắt-<i2c-bus-nr>-<i2c-device-nr>:rgb:indicator

$ ls -h /sys/class/leds/blinkm-1-9:rgb:indicator
  thiết bị độ sáng max_brightness multi_index multi_intensity sự kiện kích hoạt hệ thống con nguồn

Màu sắc được điều khiển bởi tệp multi_intensity và độ sáng được điều khiển bởi
tập tin độ sáng.

Thứ tự ghi các giá trị cường độ có thể được tìm thấy trong multi_index.
Chính xác ba giá trị từ 0 đến 255 phải được ghi vào multi_intensity để
thay đổi màu sắc::

$ echo 255 100 50 > multi_intensity

Độ sáng tổng thể được thay đổi bằng cách viết giá trị từ 0 đến 255 vào
tập tin độ sáng.

b) Giao diện lớp LED để sử dụng với trình kích hoạt
############################################

Việc đăng ký thực hiện theo sơ đồ::

chớp mắt-<i2c-bus-nr>-<i2c-device-nr>-<color>

$ ls -h /sys/class/leds/blinkm-6-*
  /sys/class/leds/blinkm-6-9-blue:
  sự kiện kích hoạt hệ thống con nguồn max_brightness của thiết bị độ sáng

/sys/class/leds/blinkm-6-9-green:
  sự kiện kích hoạt hệ thống con nguồn max_brightness của thiết bị độ sáng

/sys/class/leds/blinkm-6-9-red:
  sự kiện kích hoạt hệ thống con nguồn max_brightness của thiết bị độ sáng

(tương tự với /sys/bus/i2c/devices/6-0009/leds)

Chúng ta có thể kiểm soát các màu được tách thành màu đỏ, xanh lá cây và xanh lam và
chỉ định kích hoạt trên mỗi màu.

Ví dụ.::

$ mèo chớp mắtm-6-9-xanh/độ sáng
  05

$ echo 200 > blinkm-6-9-blue/độ sáng
  $

$ modprobe ledtrig-nhịp tim
  $ echo nhịp tim > clickm-6-9-green/kích hoạt
  $


b) Nhóm Sysfs để điều khiển rgb, fade, hsb, script...
#####################################################

Giao diện mở rộng này có sẵn dưới dạng thư mục flashm
trong thư mục sysfs của thiết bị I2C.
Ví dụ. bên dưới /sys/bus/i2c/devices/6-0009/blinkm

$ ls -h /sys/bus/i2c/devices/6-0009/blinkm/
  thử nghiệm xanh xanh đỏ

Hiện tại được hỗ trợ chỉ là cài đặt màu đỏ, xanh lá cây, xanh dương
và một trình tự thử nghiệm.

Ví dụ.::

$ mèo *
  00
  00
  00
  #Write vào thử nghiệm để bắt đầu chuỗi thử nghiệm!#

$ echo 1 > kiểm tra
  $

$ echo 255 > đỏ
  $



kể từ ngày 07/2024

dl9pf <at> gmx <dot> de
jstrauss <at> hộp thư <dot> org
