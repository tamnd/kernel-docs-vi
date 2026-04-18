.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/pwm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================================
Giao diện điều chế độ rộng xung (PWM)
=========================================

Điều này cung cấp cái nhìn tổng quan về giao diện Linux PWM

PWM thường được sử dụng để điều khiển đèn LED, quạt hoặc bộ rung trong
điện thoại di động. CácPWM có mục đích cố định không cần triển khai
Linux PWM API (mặc dù chúng có thể). Tuy nhiên,PWM thường
được tìm thấy dưới dạng các thiết bị riêng biệt trên SoC không có mục đích cố định. Đó là
tùy thuộc vào nhà thiết kế bảng để kết nối chúng với đèn LED hoặc quạt. Để cung cấp
loại linh hoạt này tồn tại PWM API chung.

Xác định các xung điện
----------------------

Người dùng PWM API cũ sử dụng ID duy nhất để chỉ các thiết bị PWM.

Thay vì đề cập đến thiết bị PWM thông qua ID duy nhất của nó, mã thiết lập bảng
thay vào đó nên đăng ký ánh xạ tĩnh có thể được sử dụng để khớp với PWM
người tiêu dùng đến nhà cung cấp, như được đưa ra trong ví dụ sau::

cấu trúc tĩnh pwm_lookup board_pwm_lookup[] = {
		PWM_LOOKUP("tegra-pwm", 0, "đèn nền pwm", NULL,
			   50000, PWM_POLARITY_NORMAL),
	};

khoảng trống tĩnh __init board_init(void)
	{
		...
pwm_add_table(board_pwm_lookup, ARRAY_SIZE(board_pwm_lookup));
		...
	}

Sử dụngPWM
----------

Người tiêu dùng sử dụng hàm pwm_get() và chuyển tới nó thiết bị tiêu dùng hoặc
tên người tiêu dùng. pwm_put() được sử dụng để giải phóng thiết bị PWM. Các biến thể được quản lý của
getter, devm_pwm_get() và devm_fwnode_pwm_get(), cũng tồn tại.

Sau khi được yêu cầu, PWM phải được định cấu hình bằng cách sử dụng::

int pwm_apply_might_sleep(struct pwm_device *pwm, struct pwm_state *state);

API này điều khiển cả cấu hình chu kỳ/nhiệm vụ PWM và
trạng thái bật/tắt.

Các thiết bị PWM có thể được sử dụng từ bối cảnh nguyên tử, nếu PWM không ở chế độ ngủ. bạn
có thể kiểm tra xem đây có phải là trường hợp với ::

bool pwm_might_sleep(struct pwm_device *pwm);

Nếu sai, PWM cũng có thể được định cấu hình từ ngữ cảnh nguyên tử với::

int pwm_apply_atomic(struct pwm_device *pwm, struct pwm_state *state);

Với tư cách là người tiêu dùng, đừng dựa vào trạng thái đầu ra để biết PWM bị vô hiệu hóa. Nếu nó
dễ dàng có thể, trình điều khiển được cho là sẽ phát ra trạng thái không hoạt động, nhưng một số
trình điều khiển không thể. Nếu bạn mong muốn nhận được trạng thái không hoạt động, hãy sử dụng .duty_cycle=0,
.enable=true.

Ngoài ra còn có cài đặt use_power: Nếu được đặt, trình điều khiển PWM chỉ được yêu cầu để
duy trì công suất đầu ra nhưng có nhiều tự do hơn về dạng tín hiệu.
Nếu được trình điều khiển hỗ trợ, tín hiệu có thể được tối ưu hóa, ví dụ như cải thiện
EMI bằng cách dịch pha các kênh riêng lẻ của chip.

Các hàm pwm_config(), pwm_enable() và pwm_disable() chỉ là các hàm bao
xung quanh pwm_apply_might_sleep() và không nên sử dụng nếu người dùng muốn thay đổi
nhiều tham số cùng một lúc. Ví dụ: nếu bạn thấy pwm_config() và
pwm_{enable,disable}() gọi trong cùng một chức năng, điều này có thể có nghĩa là bạn
nên chuyển sang pwm_apply_might_sleep().

Người dùng PWM API cũng cho phép một người truy vấn trạng thái PWM đã được chuyển tới
lệnh gọi cuối cùng của pwm_apply_might_sleep() bằng pwm_get_state(). Lưu ý đây là
khác với những gì trình điều khiển đã thực sự triển khai nếu yêu cầu không thể thực hiện được
hài lòng chính xác với phần cứng đang sử dụng. Hiện tại không có cách nào để
người tiêu dùng để có được các cài đặt thực tế được triển khai.

Ngoài trạng thái PWM, PWM API còn hiển thị các đối số PWM, trong đó
là cấu hình PWM tham chiếu mà bạn nên sử dụng trên PWM này.
Các đối số PWM thường dành riêng cho nền tảng và cho phép người dùng PWM chỉ
quan tâm đến chu kỳ thuế tương đối trong toàn bộ thời gian (chẳng hạn như thuế = 50% của
kỳ). struct pwm_args chứa 2 trường (chu kỳ và phân cực) và nên
được sử dụng để đặt cấu hình PWM ban đầu (thường được thực hiện trong chức năng thăm dò
của người dùng PWM). Các đối số PWM được truy xuất bằng pwm_get_args().

Tất cả người tiêu dùng thực sự nên cấu hình lại PWM khi tiếp tục
thích hợp. Đây là cách duy nhất để đảm bảo rằng mọi thứ được tiếp tục trong
đúng thứ tự.

Sử dụngPWM với giao diện sysfs
-----------------------------------

Nếu CONFIG_SYSFS được bật trong cấu hình kernel của bạn, một sysfs đơn giản
giao diện được cung cấp để sử dụng các xung từ không gian người dùng. Nó được phơi bày tại
/sys/class/pwm/. Mỗi bộ điều khiển/chip PWM được thăm dò sẽ được xuất dưới dạng
pwmchipN, trong đó N là nền tảng của chip PWM. Bên trong thư mục bạn
sẽ tìm thấy:

npwm
    Số lượng kênh PWM mà chip này hỗ trợ (chỉ đọc).

xuất khẩu
    Xuất kênh PWM để sử dụng với sysfs (chỉ ghi).

không xuất khẩu
   Hủy xuất kênh PWM khỏi sysfs (chỉ ghi).

Các kênh PWM được đánh số bằng chỉ số trên mỗi chip từ 0 đến npwm-1.

Khi kênh PWM được xuất, thư mục pwmX sẽ được tạo trong
thư mục pwmchipN mà nó liên kết với, trong đó X là số lượng
kênh đã được xuất khẩu. Các thuộc tính sau đây sẽ có sẵn:

thời kỳ
    Tổng thời gian của tín hiệu PWM (đọc/ghi).
    Giá trị tính bằng nano giây và là tổng của hoạt động và không hoạt động
    thời gian của PWM.

nhiệm vụ_chu kỳ
    Thời gian hoạt động của tín hiệu PWM (đọc/ghi).
    Giá trị tính bằng nano giây và phải nhỏ hơn hoặc bằng khoảng thời gian.

sự phân cực
    Thay đổi cực tính của tín hiệu PWM (đọc/ghi).
    Việc ghi vào thuộc tính này chỉ hoạt động nếu chip PWM hỗ trợ thay đổi
    sự phân cực.
    Giá trị là chuỗi "bình thường" hoặc "đảo ngược".

kích hoạt
    Bật/tắt tín hiệu PWM (đọc/ghi).

- 0 - bị vô hiệu hóa
	- 1 - đã bật

Triển khai trình điều khiển PWM
-------------------------------

Hiện tại có hai cách để triển khai trình điều khiển pwm. Theo truyền thống
chỉ có API barebone nghĩa là mỗi trình điều khiển đều có
để tự triển khai các hàm pwm_*(). Điều này có nghĩa là không thể
để có nhiều trình điều khiển PWM trong hệ thống. Vì lý do này, nó bắt buộc
dành cho các trình điều khiển mới sử dụng khung PWM chung.

Bộ điều khiển/chip PWM mới có thể được phân bổ bằng pwmchip_alloc(), sau đó
đã đăng ký bằng pwmchip_add() và xóa lại bằng pwmchip_remove(). Để hoàn tác
pwmchip_alloc() sử dụng pwmchip_put(). pwmchip_add() lấy một cấu trúc được điền
pwm_chip làm đối số cung cấp mô tả về chip PWM, số
của các thiết bị PWM do chip cung cấp và việc triển khai dành riêng cho chip
hỗ trợ các hoạt động PWM vào khung.

Khi triển khai hỗ trợ phân cực trong trình điều khiển PWM, hãy đảm bảo tôn trọng
quy ước tín hiệu trong khung PWM. Theo định nghĩa, cực tính bình thường
đặc trưng cho tín hiệu bắt đầu ở mức cao trong suốt chu kỳ nhiệm vụ và
ở mức thấp trong thời gian còn lại. Ngược lại, một tín hiệu nghịch đảo
cực tính bắt đầu ở mức thấp trong suốt chu kỳ nhiệm vụ và lên cao trong
thời gian còn lại.

Trình điều khiển được khuyến khích triển khai ->apply() thay vì kế thừa
->enable(), ->disable() và ->config() các phương thức. Việc làm đó sẽ cung cấp
tính nguyên tử trong quy trình cấu hình PWM, được yêu cầu khi điều khiển PWM
một thiết bị quan trọng (như bộ điều chỉnh).

Việc triển khai ->get_state() (một phương thức được sử dụng để truy xuất PWM ban đầu
state) cũng được khuyến khích vì lý do tương tự: cho người dùng PWM biết
về trạng thái PWM hiện tại sẽ cho phép anh ta tránh được những trục trặc.

Trình điều khiển không nên thực hiện bất kỳ quản lý năng lượng nào. Nói cách khác,
người tiêu dùng nên triển khai nó như được mô tả trong phần "Sử dụng xung điều khiển".

Khóa
-------

Các thao tác trong danh sách lõi PWM được bảo vệ bởi một mutex, vì vậy pwm_get()
và pwm_put() có thể không được gọi từ ngữ cảnh nguyên tử.
Hầu hết các chức năng trong PWM tiêu dùng API có thể ngủ và do đó không được gọi
từ bối cảnh nguyên tử. Ngoại lệ đáng chú ý là pwm_apply_atomic() có
ngữ nghĩa tương tự như pwm_apply_might_sleep() nhưng có thể được gọi từ ngữ cảnh nguyên tử.
(Cái giá của điều đó là nó không hoạt động cho tất cả các thiết bị PWM, hãy sử dụng
pwm_might_sleep() để kiểm tra xem PWM nhất định có hỗ trợ hoạt động nguyên tử hay không.

Khóa trong lõi PWM đảm bảo rằng các cuộc gọi lại liên quan đến một chip đơn lẻ được thực hiện
được đăng nhiều kỳ.

Người trợ giúp
--------------

Hiện tại PWM chỉ có thể được định cấu hình với Period_ns và Duty_ns. Đối với một số
trường hợp sử dụng freq_hz và Duty_percent có thể tốt hơn. Thay vì tính toán
điều này trong trình điều khiển của bạn, vui lòng xem xét thêm những người trợ giúp thích hợp vào khung.
