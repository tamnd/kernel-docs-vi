.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/leds/leds-class.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Xử lý LED trong Linux
===========================

Ở dạng đơn giản nhất, lớp LED chỉ cho phép điều khiển đèn LED từ
không gian người dùng. Đèn LED xuất hiện trong /sys/class/leds/. Độ sáng tối đa của
LED được xác định trong tệp max_brightness. Tệp độ sáng sẽ đặt độ sáng
của LED (lấy giá trị 0-max_brightness). Hầu hết các đèn LED không có phần cứng
hỗ trợ độ sáng nên sẽ chỉ được bật cho cài đặt độ sáng khác 0.

Lớp học cũng giới thiệu khái niệm tùy chọn về trình kích hoạt LED. Trình kích hoạt
là một nguồn dựa trên hạt nhân của các sự kiện dẫn đầu. Kích hoạt có thể đơn giản hoặc
phức tạp. Một trình kích hoạt đơn giản không thể cấu hình được và được thiết kế để cắm vào
các hệ thống con hiện có với mã bổ sung tối thiểu. Ví dụ như hoạt động của đĩa,
kích hoạt nand-disk và Sharpsl-charge. Khi trình kích hoạt đèn LED bị vô hiệu hóa, mã
tối ưu hóa đi.

Bộ kích hoạt phức tạp có sẵn cho tất cả các đèn LED có LED cụ thể
các tham số và hoạt động trên cơ sở mỗi LED. Trình kích hoạt hẹn giờ là một ví dụ.
Bộ kích hoạt hẹn giờ sẽ thay đổi định kỳ độ sáng của LED giữa
LED_OFF và cài đặt độ sáng hiện tại. Thời gian "bật" và "tắt" có thể
được chỉ định thông qua /sys/class/leds/<device>/delay_{on,off} tính bằng mili giây.
Bạn có thể thay đổi giá trị độ sáng của LED độc lập với bộ hẹn giờ
kích hoạt. Tuy nhiên, nếu bạn đặt giá trị độ sáng thành LED_OFF thì nó sẽ
cũng vô hiệu hóa kích hoạt hẹn giờ.

Bạn có thể thay đổi trình kích hoạt theo cách tương tự như cách bộ lập lịch IO
được chọn (thông qua /sys/class/leds/<device>/trigger). Trình kích hoạt cụ thể
các tham số có thể xuất hiện trong /sys/class/leds/<device> sau khi trình kích hoạt nhất định được kích hoạt
đã chọn.


Triết lý thiết kế
=================

Triết lý thiết kế cơ bản là sự đơn giản. Đèn LED là thiết bị đơn giản
và mục đích là giữ lại một lượng nhỏ mã cung cấp càng nhiều chức năng càng tốt
càng tốt.  Hãy ghi nhớ điều này khi đề xuất cải tiến.


Đặt tên thiết bị LED
=================

Hiện tại có dạng:

"tên thiết bị:màu:chức năng"

- tên thiết bị:
        nó phải đề cập đến một mã định danh duy nhất được tạo bởi kernel,
        như ví dụ phyN cho thiết bị mạng hoặc inputN cho thiết bị đầu vào, thay vào đó
        hơn là phần cứng; thông tin liên quan đến sản phẩm và xe buýt
        thiết bị nào được kết nối có sẵn trong sysfs và có thể
        được truy xuất bằng tập lệnh get_led_device_info.sh từ các công cụ/đèn led; nói chung
        phần này được mong đợi chủ yếu dành cho đèn LED được liên kết bằng cách nào đó với
        các thiết bị khác.

- màu sắc:
        một trong các định nghĩa LED_COLOR_ID_* từ tiêu đề
        bao gồm/dt-binds/leds/common.h.

-chức năng:
        một trong các định nghĩa LED_FUNCTION_* từ tiêu đề
        bao gồm/dt-binds/leds/common.h.

Nếu thiếu màu sắc hoặc chức năng cần thiết, vui lòng gửi bản vá
tới linux-leds@vger.kernel.org.

Có thể sẽ có nhiều hơn một chiếc LED có cùng màu sắc và chức năng
được yêu cầu cho nền tảng nhất định, chỉ khác nhau ở số thứ tự.
Trong trường hợp này, tốt nhất là chỉ ghép LED_FUNCTION_* được xác định trước
tên có hậu tố "-N" bắt buộc trong trình điều khiển. trình điều khiển dựa trên fwnode có thể sử dụng
thuộc tính liệt kê hàm cho điều đó và sau đó phép nối sẽ được xử lý
tự động bởi lõi LED khi đăng ký thiết bị lớp LED.

Hệ thống con LED cũng có cơ chế bảo vệ chống xung đột tên, điều đó có thể xảy ra
khi thiết bị lớp LED được tạo bởi trình điều khiển của thiết bị có thể cắm nóng và
nó không cung cấp phần tên thiết bị duy nhất. Trong trường hợp này số
hậu tố (ví dụ: "_1", "_2", "_3", v.v.) được thêm vào lớp LED được yêu cầu
tên thiết bị.

Có thể vẫn còn trình điều khiển lớp LED sử dụng tên nhà cung cấp hoặc tên sản phẩm
cho tên thiết bị, nhưng cách tiếp cận này hiện không được dùng nữa vì nó không truyền tải
bất kỳ giá trị gia tăng nào. Thông tin sản phẩm có thể được tìm thấy ở những nơi khác trong sysfs
(xem công cụ/đèn led/get_led_device_info.sh).

Ví dụ về tên LED thích hợp:

- "đỏ:đĩa"
  - "trắng: chớp"
  - "đỏ: chỉ báo"
  - "phy1:xanh:wlan"
  - "phy3::wlan"
  - ":kbd_backlight"
  - "input5::kbd_backlight"
  - "input3::numlock"
  - "input3::scrolllock"
  - "input3::capslock"
  - "mmc1::trạng thái"
  - "trắng:trạng thái"

Tập lệnh get_led_device_info.sh có thể được sử dụng để xác minh xem tên LED
đáp ứng các yêu cầu được chỉ ra ở đây. Nó thực hiện xác nhận lớp LED
phần tên thiết bị và đưa ra gợi ý về giá trị mong đợi cho một phần trong trường hợp
việc xác nhận không thành công cho nó. Cho đến nay tập lệnh hỗ trợ xác thực
mối liên hệ giữa đèn LED và các loại thiết bị sau:

- thiết bị đầu vào
        - thiết bị USB tương thích ieee80211

Tập lệnh được mở cho các phần mở rộng.

Đã có những yêu cầu về các thuộc tính LED như màu sắc được xuất dưới dạng
thuộc tính lớp dẫn đầu cá nhân. Là một giải pháp không phát sinh nhiều
trên không, tôi đề nghị những thứ này trở thành một phần của tên thiết bị. Sơ đồ đặt tên
ở trên để lại phạm vi cho các thuộc tính khác nếu cần. Nếu phần
của tên không áp dụng, chỉ để trống phần đó.


Cài đặt độ sáng API
======================

Lõi hệ thống con LED hiển thị API sau để cài đặt độ sáng:

- led_set_brightness:
		nó được đảm bảo không ngủ, vượt qua các điểm dừng LED_OFF
		nhấp nháy,

- led_set_brightness_sync:
		cho các trường hợp sử dụng khi muốn có hiệu quả ngay lập tức -
		nó có thể chặn người gọi trong thời gian cần thiết để truy cập
		thiết bị đăng ký và có thể ngủ, chuyển LED_OFF dừng phần cứng
		nhấp nháy, trả về -EBUSY nếu tính năng dự phòng nhấp nháy của phần mềm được bật.


LED đăng ký API
====================

Trình điều khiển muốn đăng ký classdev LED để các trình điều khiển khác sử dụng /
không gian người dùng cần phân bổ và điền vào cấu trúc led_classdev rồi gọi
ZZ0000ZZ. Nếu phiên bản không phải devm được sử dụng trình điều khiển
phải gọi led_classdev_unregister từ chức năng xóa của nó trước
giải phóng cấu trúc led_classdev.

Nếu trình điều khiển có thể phát hiện những thay đổi về độ sáng do phần cứng bắt đầu và do đó
muốn có thuộc tính độ sáng_hw_changed thì LED_BRIGHT_HW_CHANGED
cờ phải được đặt trong cờ trước khi đăng ký. Đang gọi
led_classdev_notify_brightness_hw_changed trên một classdev chưa được đăng ký với
cờ LED_BRIGHT_HW_CHANGED là một lỗi và sẽ kích hoạt WARN_ON.

Đèn LED nhấp nháy tăng tốc phần cứng
==================================

Một số đèn LED có thể được lập trình để nhấp nháy mà không có bất kỳ tương tác nào với CPU. Đến
hỗ trợ tính năng này, trình điều khiển LED có thể tùy chọn triển khai
Hàm blind_set() (xem <linux/leds.h>). Để đặt LED nhấp nháy,
tuy nhiên, tốt hơn nên sử dụng hàm API led_blink_set(), vì nó
sẽ kiểm tra và triển khai dự phòng phần mềm nếu cần thiết.

Để tắt nhấp nháy, hãy sử dụng hàm API led_brightness_set()
với giá trị độ sáng LED_OFF, giá trị này sẽ dừng mọi phần mềm
bộ hẹn giờ có thể được yêu cầu để nhấp nháy.

Hàm blind_set() sẽ chọn giá trị nhấp nháy thân thiện với người dùng
nếu nó được gọi với tham số ZZ0000ZZ && ZZ0001ZZ. Trong này
trường hợp trình điều khiển sẽ trả lại giá trị đã chọn thông qua delay_on và
tham số delay_off cho hệ thống con led.

Đặt độ sáng về 0 bằng chức năng gọi lại độ sáng_set()
nên tắt hoàn toàn LED và hủy chương trình đã lập trình trước đó
chức năng nhấp nháy phần cứng, nếu có.

Đèn LED điều khiển bằng phần cứng
====================

Một số đèn LED có thể được lập trình để điều khiển bằng phần cứng. Đây không phải là
giới hạn nhấp nháy mà còn có thể tự động tắt hoặc bật.
Để hỗ trợ tính năng này, LED cần triển khai nhiều tính năng bổ sung khác nhau
ops và cần khai báo hỗ trợ cụ thể cho các trình kích hoạt được hỗ trợ.

Với điều khiển hw, chúng tôi đề cập đến LED được điều khiển bởi phần cứng.

Trình điều khiển LED phải xác định giá trị sau để hỗ trợ điều khiển hw:

- hw_control_trigger:
               tên trình kích hoạt duy nhất được LED hỗ trợ trong điều khiển hw
               chế độ.

Trình điều khiển LED phải triển khai API sau để hỗ trợ điều khiển hw:
    - hw_control_is_supported:
                kiểm tra xem các cờ được trình kích hoạt được hỗ trợ chuyển qua có thể
                được phân tích cú pháp và kích hoạt điều khiển hw trên LED.

Trả về 0 nếu mặt nạ cờ đã truyền được hỗ trợ và
                có thể được đặt bằng hw_control_set().

Nếu mặt nạ cờ đã thông qua không được hỗ trợ -EOPNOTSUPP
                phải được trả lại, trình kích hoạt LED sẽ sử dụng phần mềm
                dự phòng trong trường hợp này.

Trả về lỗi âm trong trường hợp có bất kỳ lỗi nào khác như
                thiết bị chưa sẵn sàng hoặc hết thời gian chờ.

- hw_control_set:
                kích hoạt điều khiển hw. Trình điều khiển LED sẽ sử dụng trình điều khiển được cung cấp
                cờ được truyền từ trình kích hoạt được hỗ trợ, phân tích chúng thành
                một bộ chế độ và thiết lập LED để được điều khiển bằng phần cứng
                theo các chế độ được yêu cầu.

Đặt LED_OFF thông qua độ sáng_set để tắt điều khiển hw.

Trả về 0 nếu thành công, số lỗi âm khi không thực hiện được
                áp dụng cờ.

- hw_control_get:
                nhận các chế độ hoạt động từ LED đã có trong điều khiển hw, phân tích cú pháp
                chúng và đặt cờ các cờ hoạt động hiện tại cho
                kích hoạt được hỗ trợ.

Trả về 0 nếu thành công, số lỗi âm khi thất bại
                phân tích chế độ ban đầu.
                Lỗi từ chức năng này là NOT FATAL vì thiết bị có thể
                ở trạng thái ban đầu không được hỗ trợ bởi LED đính kèm
                kích hoạt.

- hw_control_get_device:
                trả lại thiết bị được liên kết với trình điều khiển LED trong
                kiểm soát thế nào. Trình kích hoạt có thể sử dụng điều này để khớp với
                thiết bị được trả về từ chức năng này với cấu hình
                thiết bị kích hoạt làm nguồn nhấp nháy
                sự kiện và kích hoạt chính xác điều khiển hw.
                (ví dụ: trình kích hoạt netdev được định cấu hình để nhấp nháy trong
                nhà phát triển cụ thể khớp với nhà phát triển được trả về từ get_device
                để thiết lập điều khiển hw)

Trả về con trỏ tới thiết bị cấu trúc hoặc NULL nếu không có gì
                hiện đang được đính kèm.

Trình điều khiển LED có thể kích hoạt các chế độ bổ sung theo mặc định để khắc phục sự cố
không thể hỗ trợ từng chế độ khác nhau trên trình kích hoạt được hỗ trợ.
Ví dụ như mã hóa cứng tốc độ chớp mắt thành một khoảng thời gian đã đặt, bật tính năng đặc biệt
tính năng như bỏ qua nhấp nháy nếu một số yêu cầu không được đáp ứng.

Trước tiên, trình kích hoạt phải kiểm tra xem API điều khiển hw có được LED hỗ trợ hay không
trình điều khiển và kiểm tra xem trình kích hoạt có được hỗ trợ hay không để xác minh xem có thể kiểm soát hw hay không,
sử dụng hw_control_is_supported để kiểm tra xem các cờ có được hỗ trợ hay không và chỉ tại
cuối cùng sử dụng hw_control_set để kích hoạt điều khiển hw.

Trình kích hoạt có thể sử dụng hw_control_get để kiểm tra xem LED đã có trong điều khiển hw chưa
và khởi tạo cờ của họ.

Khi LED ở chế độ điều khiển hw, không thể nhấp nháy phần mềm và thực hiện như vậy
sẽ vô hiệu hóa kiểm soát hw một cách hiệu quả.

Sự cố đã biết
============

Lõi kích hoạt LED không thể là một mô-đun như các chức năng kích hoạt đơn giản
sẽ gây ra vấn đề phụ thuộc ác mộng. Tôi thấy đây là một vấn đề nhỏ
so với những lợi ích mà chức năng kích hoạt đơn giản mang lại. các
phần còn lại của hệ thống con LED có thể được mô-đun hóa.
