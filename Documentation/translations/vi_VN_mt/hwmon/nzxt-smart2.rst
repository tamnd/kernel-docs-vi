.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/nzxt-smart2.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân nzxt-smart2
=========================

Các thiết bị được hỗ trợ:

- NZXT RGB & Bộ điều khiển quạt
- Thiết bị thông minh NZXT v2

Sự miêu tả
-----------

Driver này thực hiện chức năng giám sát và điều khiển quạt cắm vào thiết bị.
Bên cạnh việc giám sát tốc độ điển hình và điều khiển chu kỳ nhiệm vụ PWM, điện áp và dòng điện
được báo cáo cho mọi người hâm mộ.

Thiết bị còn có hai đầu nối cho đèn LED RGB; hỗ trợ cho họ không phải là
được triển khai (chủ yếu vì không có giao diện sysfs được tiêu chuẩn hóa).

Ngoài ra máy còn có cảm biến chống ồn nhưng hình như cảm biến này hoàn toàn không có.
vô dụng (và rất không chính xác), vì vậy việc hỗ trợ cho nó cũng không được triển khai.

Ghi chú sử dụng
-----------

Thiết bị sẽ được tự động phát hiện và trình điều khiển sẽ tự động tải.

Nếu quạt được cắm/rút phích cắm trong khi hệ thống đang bật, trình điều khiển
phải được tải lại để phát hiện các thay đổi về cấu hình; nếu không, người hâm mộ mới không thể
được kiểm soát (các thay đổi của ZZ0001ZZ sẽ bị bỏ qua). Nó là cần thiết bởi vì
thiết bị có lệnh "phát hiện quạt" chuyên dụng và hiện tại lệnh này chỉ được thực thi
trong quá trình khởi tạo. Giám sát tốc độ, điện áp, dòng điện sẽ hoạt động ngay cả khi không có
tải lại. Để thay thế cho việc tải lại mô-đun, một công cụ không gian người dùng (như
ZZ0000ZZ) có thể được sử dụng để chạy lệnh "phát hiện quạt" thông qua giao diện hidraw.

Trình điều khiển cùng tồn tại với các công cụ không gian người dùng truy cập thiết bị thông qua hidraw
giao diện không có vấn đề được biết đến.

.. _liquidctl: https://github.com/liquidctl/liquidctl

Mục nhập hệ thống
-------------

=====================================================================================
fan[1-3]_input Giám sát tốc độ quạt (tính bằng vòng/phút).
curr[1-3]_input Dòng điện cung cấp cho quạt (tính bằng miliampe).
in[0-2]_input Điện áp cung cấp cho quạt (tính bằng milivolt).
pwm[1-3] Điều khiển tốc độ quạt: Chu kỳ hoạt động PWM dành cho điều khiển PWM
			quạt, điện áp cho các quạt khác. Điện áp có thể thay đổi trong
			Phạm vi 9-12 V, nhưng giá trị của thuộc tính sysfs là
			luôn ở phạm vi 0-255 (1 = 9V, 255 = 12V). Thiết lập
			thuộc tính về 0 sẽ tắt quạt hoàn toàn.
pwm[1-3]_enable 1 nếu quạt có thể được điều khiển bằng cách ghi vào
			thuộc tính pwm* tương ứng, 0 nếu không. thiết bị
			chỉ có thể điều khiển những chiếc quạt mà nó tự phát hiện, vì vậy
			thuộc tính chỉ đọc.
pwm[1-3]_mode Chỉ đọc, 1 cho quạt được điều khiển PWM, 0 cho các quạt khác
			(hoặc nếu không có quạt kết nối).
update_interval Khoảng thời gian mà tất cả đầu vào được cập nhật (trong
			mili giây). Mặc định là 1000ms. Tối thiểu là 250ms.
=====================================================================================