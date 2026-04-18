.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/aquacomputer_d5next.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân aquacomputer-d5next
=================================

Các thiết bị được hỗ trợ:

* Bộ điều khiển quạt Aquacomputer Aquaero 5/6
* Máy bơm giải nhiệt nước Aquacomputer D5 Next
* Bộ điều khiển Aquacomputer Farbwerk RGB
* Bộ điều khiển Aquacomputer Farbwerk 360 RGB
* Bộ điều khiển quạt Aquacomputer Octo
* Bộ điều khiển quạt Aquacomputer Quadro
* Cảm biến Aquacomputer High Flow Next
* Hệ thống chống rò rỉ Aquacomputer Leakshield
* Máy bơm giải nhiệt nước Aquacomputer Aquastream XT
* Máy bơm giải nhiệt nước Aquacomputer Aquastream Ultimate
* Bộ điều khiển quạt Aquacomputer Powerjust 3
* Máy đo lưu lượng dòng chảy cao USB của Aquacomputer
* Thiết bị Aquacomputer MPS Flow

Tác giả: Aleksa Savic

Sự miêu tả
-----------

Trình điều khiển này hiển thị các cảm biến phần cứng của các thiết bị Aquacomputer được liệt kê,
giao tiếp thông qua các giao thức USB HID độc quyền.

Các thiết bị Aquaero hiển thị tám vật lý, tám ảo và bốn tính toán
cảm biến nhiệt độ ảo, cũng như hai cảm biến lưu lượng. Người hâm mộ bộc lộ
tốc độ (trong RPM), công suất, điện áp và dòng điện. Bù nhiệt độ và tốc độ quạt
có thể được kiểm soát.

Đối với máy bơm D5 Next, các cảm biến có sẵn là tốc độ bơm và quạt, công suất, điện áp
và dòng điện, cũng như nhiệt độ nước làm mát và tám cảm biến nhiệt độ ảo. Ngoài ra
có sẵn thông qua debugfs là số sê-ri, phiên bản chương trình cơ sở và bật nguồn
đếm. Việc gắn quạt vào nó là tùy chọn và cho phép điều khiển quạt bằng cách sử dụng
đường cong nhiệt độ trực tiếp từ máy bơm. Nếu nó không được kết nối, liên quan đến quạt
cảm biến sẽ báo cáo số không.

Máy bơm có thể được cấu hình thông qua phần mềm hoặc thông qua vật lý của nó.
giao diện. Việc định cấu hình máy bơm thông qua trình điều khiển này không được triển khai vì nó
dường như yêu cầu gửi cho nó một cấu hình hoàn chỉnh. Điều đó bao gồm địa chỉ
Đèn LED RGB, không có giao diện sysfs tiêu chuẩn. Như vậy nhiệm vụ đó
phù hợp hơn với các công cụ không gian người dùng.

Octo có bốn cảm biến nhiệt độ vật lý và mười sáu cảm biến nhiệt độ ảo, một cảm biến lưu lượng
cũng như tám quạt có thể điều khiển PWM, cùng với tốc độ của chúng (trong RPM), nguồn điện, điện áp
và hiện tại. Xung cảm biến lưu lượng cũng có sẵn.

Quadro hiển thị bốn cảm biến nhiệt độ vật lý và mười sáu cảm biến nhiệt độ ảo, một luồng
cảm biến và bốn quạt có thể điều khiển PWM, cùng với tốc độ của chúng (trong RPM), công suất,
điện áp và dòng điện. Xung cảm biến lưu lượng cũng có sẵn.

Farbwerk và Farbwerk 360 có bốn cảm biến nhiệt độ. Ngoài ra,
16 cảm biến nhiệt độ ảo của Farbwerk 360 bị lộ.

High Flow Next hiển thị điện áp +5V, chất lượng nước, độ dẫn điện và chỉ số lưu lượng.
Một cảm biến nhiệt độ có thể được kết nối với nó, trong trường hợp đó nó cung cấp kết quả đọc
và ước tính công suất tiêu tán/hấp thụ trong vòng làm mát bằng chất lỏng.

Leakshield hiển thị hai cảm biến nhiệt độ và áp suất chất làm mát (dòng điện, tối thiểu, tối đa và
số đọc mục tiêu). Nó cũng cho thấy thể tích hồ chứa ước tính và bao nhiêu trong số đó
chứa đầy chất làm mát. Bơm RPM và lưu lượng có thể được thiết lập để nâng cao khả năng tính toán trên thiết bị,
nhưng điều này vẫn chưa được thực hiện ở đây.

Máy bơm Aquastream XT hiển thị số đọc nhiệt độ của chất làm mát, cảm biến bên ngoài
và IC quạt. Nó cũng hiển thị tốc độ bơm và quạt (trong RPM), điện áp cũng như thông số bơm
hiện tại.

Máy bơm Aquastream Ultimate hiển thị nhiệt độ nước làm mát và cảm biến nhiệt độ bên ngoài, cùng với
với tốc độ, công suất, điện áp và dòng điện của cả máy bơm và quạt được kết nối tùy chọn.
Nó cũng cho thấy áp suất và tốc độ dòng chảy.

Bộ điều khiển Powerjust 3 có một cảm biến nhiệt độ bên ngoài.

USB lưu lượng cao có cảm biến nhiệt độ bên trong và bên ngoài cũng như đồng hồ đo lưu lượng.

Các thiết bị MPS Flow hiển thị các mục tương tự như USB Flow cao vì chúng có
ID sản phẩm USB giống nhau và cảm biến báo cáo tương đương.

Tùy thuộc vào thiết bị, không phải tất cả các mục sysfs và debugfs đều khả dụng.
Việc ghi vào cảm biến nhiệt độ ảo hiện không được hỗ trợ.

ghi chú sử dụng
-----------

Các thiết bị giao tiếp qua báo cáo HID. Trình điều khiển được tải tự động bởi
kernel và hỗ trợ hotswapping.

Mục nhập hệ thống
-------------

=====================================================================================
temp[1-20]_input Cảm biến nhiệt độ vật lý/ảo (tính bằng mili độ C)
temp[1-8]_offset Độ lệch hiệu chỉnh cảm biến nhiệt độ (tính bằng mili độ C)
fan[1-9]_input Tốc độ bơm/quạt (tính bằng RPM) / Tốc độ dòng chảy (tính bằng dL/h)
fan1_min Tốc độ quạt tối thiểu (trong RPM)
fan1_max Tốc độ quạt tối đa (trong RPM)
fan1_target Tốc độ quạt mục tiêu (trong RPM)
fan5_pulses Xung cảm biến lưu lượng Quadro
fan9_pulses Xung cảm biến lưu lượng Octo
power[1-8]_input Công suất bơm/quạt (tính bằng micro Watts)
in[0-7]_input Điện áp bơm/quạt (tính bằng mili Vôn)
curr[1-8]_input Dòng điện của bơm/quạt (tính bằng mili Ampe)
pwm[1-8] Quạt PWM (0 - 255)
=====================================================================================

Mục gỡ lỗi
---------------

=======================================================================
serial_number Số serial của thiết bị
firmware_version Phiên bản của phần sụn đã cài đặt
power_cycles Đếm số lần thiết bị được bật nguồn
=======================================================================