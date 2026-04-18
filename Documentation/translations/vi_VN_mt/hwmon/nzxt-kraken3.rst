.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/nzxt-kraken3.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân nzxt-kraken3
==========================

Các thiết bị được hỗ trợ:

* NZXT Kraken X53
* NZXT Kraken X63
* NZXT Kraken X73
* NZXT Kraken Z53
* NZXT Kraken Z63
* NZXT Kraken Z73
* NZXT Kraken 2023
* NZXT Kraken 2023 Ưu tú

Tác giả: Jonas Malaco, Aleksa Savic

Sự miêu tả
-----------

Trình điều khiển này cho phép hỗ trợ giám sát phần cứng cho NZXT Kraken X53/X63/X73,
Bộ làm mát chất lỏng tất cả trong một Z53/Z63/Z73 và Kraken 2023 (tiêu chuẩn và Elite).
Tất cả các kiểu máy đều hiển thị nhiệt độ chất lỏng và tốc độ bơm (trong RPM), cũng như PWM
điều khiển (dưới dạng giá trị cố định hoặc thông qua đường cong temp-PWM). Dòng Z và
Các mô hình Kraken 2023 cũng cho thấy tốc độ và nhiệm vụ của một kết nối tùy chọn
quạt, có cùng khả năng điều khiển PWM.

Chế độ điều khiển hoạt động của bơm và quạt có thể được đặt thông qua pwm[1-2]_enable, trong đó 1 là
đối với chế độ điều khiển thủ công và 2 dành cho chế độ đường cong nhiệt độ chất lỏng đến PWM.
Viết số 0 sẽ vô hiệu hóa khả năng điều khiển kênh thông qua trình điều khiển sau khi cài đặt
nghĩa vụ đến 100%.

Nhiệt độ của các đường cong liên quan đến phạm vi [20-59] cố định, tương quan với
nhiệt độ chất lỏng được phát hiện Chỉ có thể đặt các giá trị PWM (trong khoảng từ 0-255).
Nếu ở chế độ đường cong, các giá trị điểm cài đặt phải được thực hiện ở mức độ vừa phải - thiết bị
yêu cầu gửi các đường cong hoàn chỉnh cho mỗi thay đổi; họ có thể khóa hoặc loại bỏ
những thay đổi nếu chúng quá nhiều cùng một lúc. Đề xuất là đặt chúng trong khi
ở chế độ khác, sau đó áp dụng chúng bằng cách chuyển sang đường cong.

Các thiết bị có thể báo cáo nếu chúng bị lỗi. Tài xế ủng hộ tình huống đó
và sẽ đưa ra cảnh báo. Điều này cũng có thể xảy ra khi cáp USB được kết nối,
nhưng nguồn SATA thì không.

Đèn LED RGB có địa chỉ và màn hình LCD (chỉ có trên các mẫu Z-series và Kraken 2023)
không được hỗ trợ trong trình điều khiển này nhưng có thể được điều khiển thông qua không gian người dùng hiện có
công cụ, chẳng hạn như ZZ0000ZZ.

.. _liquidctl: https://github.com/liquidctl/liquidctl

Ghi chú sử dụng
-----------

Vì đây là các USB HID nên trình điều khiển có thể được tải tự động bởi kernel và
hỗ trợ trao đổi nóng.

Các giá trị pwm_enable có thể có là:

====== ================================================================================
0 Đặt quạt ở mức 100%
1 Chế độ PWM trực tiếp (áp dụng giá trị trong mục nhập PWM tương ứng)
2 Chế độ điều khiển đường cong (áp dụng đường cong nhiệm vụ temp-PWM dựa trên nhiệt độ chất làm mát)
====== ================================================================================

Mục nhập hệ thống
-------------

=======================================================================================================
fan1_input Tốc độ bơm (tính bằng vòng/phút)
fan2_input Tốc độ quạt (tính bằng vòng/phút)
temp1_input Nhiệt độ nước làm mát (tính bằng mili độ C)
pwm1 Nhiệm vụ của máy bơm (giá trị trong khoảng 0-255)
pwm1_enable Chế độ điều khiển nhiệm vụ bơm (0: tắt, 1: thủ công, 2: đường cong)
pwm2 Nhiệm vụ của quạt (giá trị trong khoảng 0-255)
pwm2_enable Chế độ điều khiển nhiệm vụ quạt (0: tắt, 1: thủ công, 2: đường cong)
temp[1-2]_auto_point[1-40]_pwm Đường cong công suất Temp-PWM (đối với máy bơm và quạt), liên quan đến nhiệt độ nước làm mát
=======================================================================================================