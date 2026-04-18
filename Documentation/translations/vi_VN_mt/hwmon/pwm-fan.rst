.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/pwm-fan.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân pwm-fan
=====================

Trình điều khiển này cho phép sử dụng mô-đun PWM để điều khiển quạt. Nó sử dụng
giao diện PWM chung do đó nó độc lập với phần cứng. Nó có thể được sử dụng trên
nhiều SoC, miễn là SoC cung cấp trình điều khiển dòng PWM hiển thị
PWM API chung.

Tác giả: Kamil Debski <k.debski@samsung.com>

Sự miêu tả
-----------

Trình điều khiển thực hiện một giao diện đơn giản để điều khiển quạt được kết nối với
một đầu ra PWM. Nó sử dụng giao diện PWM chung, do đó nó có thể được sử dụng với
một loạt SoC. Trình điều khiển đưa quạt ra không gian người dùng thông qua
giao diện sysfs của hwmon.

Tốc độ quay của quạt được trả về thông qua 'fan1_input' tùy chọn được ngoại suy
từ các ngắt được lấy mẫu từ tín hiệu máy đo tốc độ trong vòng 1 giây.

Trình điều khiển cung cấp các quyền truy cập cảm biến sau trong sysfs:

====================== =============================================================
fan1_input ro máy đo tốc độ quạt trong RPM
pwm1_enable rw giữ chế độ kích hoạt, xác định hành vi khi pwm1=0
			0 -> tắt pwm và bộ điều chỉnh
			1 -> bật pwm; nếu pwm==0, tắt pwm, bật bộ điều chỉnh
			2 -> bật pwm; nếu pwm==0, hãy bật pwm và bộ điều chỉnh
			3 -> bật pwm; nếu pwm==0, tắt pwm và bộ điều chỉnh
pwm1 rw tốc độ tương đối (0-255), 255=max. tốc độ.
====================== =============================================================
