.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/rfkill.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================================
rfkill - Hỗ trợ chuyển đổi tiêu diệt RF
=======================================


.. contents::
   :depth: 2

Giới thiệu
============

Hệ thống con rfkill cung cấp một giao diện chung để vô hiệu hóa bất kỳ đài phát thanh nào
máy phát trong hệ thống. Khi một máy phát bị chặn, nó sẽ không
tỏa ra bất kỳ sức mạnh nào.

Hệ thống con cũng cung cấp khả năng phản ứng khi nhấn nút và
vô hiệu hóa tất cả các máy phát thuộc một loại nhất định (hoặc tất cả). Điều này là dành cho
các tình huống cần phải tắt máy phát, ví dụ như bật
máy bay.

Hệ thống con rfkill có khái niệm về khối "cứng" và "mềm".
khác nhau một chút về ý nghĩa của chúng (tắt == bộ phát) mà thay vào đó là ở
liệu chúng có thể được thay đổi hay không:

- khối cứng
	Khối radio chỉ đọc không thể bị ghi đè bằng phần mềm

- khối mềm
	khối radio có thể ghi (không cần phải đọc được) được thiết lập bởi
        phần mềm hệ thống.

Hệ thống con rfkill có hai tham số, rfkill.default_state và
rfkill.master_switch_mode, được ghi lại trong
quản trị-guide/kernel-parameter.rst.


Chi tiết triển khai
======================

Hệ thống con rfkill bao gồm ba thành phần chính:

* lõi rfkill,
 * mô-đun rfkill-input không được dùng nữa (một trình xử lý lớp đầu vào, đang được
   được thay thế bằng mã chính sách không gian người dùng) và
 * trình điều khiển rfkill.

Lõi rfkill cung cấp API để trình điều khiển kernel đăng ký radio của họ
máy phát với hạt nhân, các phương pháp bật và tắt nó cũng như cho phép
hệ thống biết về các trạng thái phần cứng bị vô hiệu hóa có thể được triển khai trên
thiết bị.

Mã lõi rfkill cũng thông báo cho không gian người dùng về những thay đổi trạng thái và cung cấp
cách để không gian người dùng truy vấn trạng thái hiện tại. Xem phần "Hỗ trợ không gian người dùng"
phần bên dưới.

Khi thiết bị bị chặn cứng (bằng cách gọi tới rfkill_set_hw_state()
hoặc từ query_hw_block), set_block() sẽ được gọi cho phần mềm bổ sung
chặn, nhưng trình điều khiển có thể bỏ qua lệnh gọi phương thức vì họ có thể sử dụng lệnh return
giá trị của hàm rfkill_set_hw_state() để đồng bộ trạng thái phần mềm
thay vì theo dõi các cuộc gọi đến set_block(). Trên thực tế, người lái xe nên
sử dụng giá trị trả về của rfkill_set_hw_state() trừ khi phần cứng thực sự
theo dõi khối mềm và khối cứng riêng biệt.


Hạt nhân API
============

Trình điều khiển cho máy phát vô tuyến thường triển khai trình điều khiển rfkill.

Trình điều khiển nền tảng có thể triển khai các thiết bị đầu vào nếu nút rfkill chỉ
đó, một nút. Nếu nút đó ảnh hưởng đến phần cứng thì bạn cần phải
thay vào đó hãy triển khai trình điều khiển rfkill. Điều này cũng áp dụng nếu nền tảng cung cấp
một cách để bật/tắt (các) máy phát.

Đối với một số nền tảng, có thể trạng thái phần cứng thay đổi trong quá trình
tạm dừng/ngủ đông, trong trường hợp đó cần phải cập nhật rfkill
cốt lõi với trạng thái hiện tại tại thời điểm tiếp tục.

Để tạo trình điều khiển rfkill, Kconfig của trình điều khiển cần có::

phụ thuộc vào RFKILL || !RFKILL

để đảm bảo không thể tích hợp trình điều khiển khi rfkill ở dạng mô-đun. !RFKILL
trường hợp cho phép xây dựng trình điều khiển khi rfkill không được cấu hình, trong đó
trường hợp tất cả rfkill API vẫn có thể được sử dụng nhưng sẽ được cung cấp bởi nội tuyến tĩnh
mà biên dịch thành hầu như không có gì.

Việc gọi rfkill_set_hw_state() khi xảy ra thay đổi trạng thái là bắt buộc từ
trình điều khiển rfkill điều khiển các thiết bị có thể bị chặn cứng trừ khi chúng cũng bị chặn
chỉ định cuộc gọi lại poll_hw_block() (sau đó lõi rfkill sẽ thăm dò ý kiến
thiết bị). Đừng làm điều này trừ khi bạn không thể có được sự kiện theo bất kỳ cách nào khác.

rfkill cung cấp bộ kích hoạt LED trên mỗi công tắc, có thể được sử dụng để điều khiển đèn LED
theo trạng thái chuyển đổi (LED_FULL khi bị chặn, nếu không thì LED_OFF).


Hỗ trợ không gian người dùng
============================

Giao diện không gian người dùng được đề xuất sử dụng là /dev/rfkill, đây là một giao diện linh tinh
thiết bị ký tự cho phép không gian người dùng lấy và thiết lập trạng thái rfkill
thiết bị và bộ thiết bị. Nó cũng thông báo cho không gian người dùng về việc bổ sung thiết bị
và loại bỏ. API là API đọc/ghi đơn giản được xác định trong
linux/rfkill.h, với một ioctl cho phép tắt đầu vào không được dùng nữa
trình xử lý trong kernel cho giai đoạn chuyển tiếp.

Ngoại trừ ioctl, việc giao tiếp với kernel được thực hiện thông qua read()
và write() của các phiên bản của 'struct rfkill_event'. Trong cấu trúc này,
khối mềm và cứng được phân tách chính xác (không giống như sysfs, xem bên dưới) và
không gian người dùng có thể có được ảnh chụp nhanh nhất quán của tất cả các thiết bị rfkill trong
hệ thống. Ngoài ra, có thể chuyển đổi tất cả các trình điều khiển rfkill (hoặc tất cả các trình điều khiển của
một loại được chỉ định) sang trạng thái cũng cập nhật trạng thái mặc định cho
các thiết bị cắm nóng.

Sau khi một ứng dụng mở/dev/rfkill, nó có thể đọc trạng thái hiện tại của tất cả
thiết bị. Những thay đổi có thể đạt được bằng cách thăm dò bộ mô tả cho
hotplug hoặc các sự kiện thay đổi trạng thái hoặc bằng cách lắng nghe các sự kiện phát ra từ
khung lõi rfkill.

Ngoài ra, mỗi thiết bị rfkill được đăng ký trong sysfs và phát ra các sự kiện.

Các thiết bị rfkill đưa ra các sự kiện (với hành động "thay đổi"), với thông tin sau
bộ biến môi trường::

RFKILL_NAME
	RFKILL_STATE
	RFKILL_TYPE

Nội dung của các biến này tương ứng với “tên”, “trạng thái” và
"gõ" các tệp sysfs đã được giải thích ở trên.

Để biết thêm chi tiết, hãy tham khảo Tài liệu/ABI/ổn định/sysfs-class-rfkill.
