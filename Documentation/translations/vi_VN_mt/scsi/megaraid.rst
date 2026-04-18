.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/megaraid.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Mô-đun quản lý chung Megaraid
=================================

Tổng quan
--------

Các lớp bộ điều khiển khác nhau từ LSI Logic chấp nhận và phản hồi
ứng dụng của người dùng theo cách tương tự. Họ hiểu cách kiểm soát phần sụn giống nhau
lệnh. Hơn nữa, các ứng dụng cũng có thể xử lý các lớp khác nhau của
các bộ điều khiển một cách thống nhất. Do đó, thật hợp lý khi có một mô-đun duy nhất
giao diện với các ứng dụng ở một bên và tất cả các trình điều khiển cấp thấp
mặt khác.

Những lợi thế, mặc dù rõ ràng, được liệt kê cho đầy đủ:

Tôi.	Tránh trùng lặp mã từ trình điều khiển cấp thấp.
	ii.	Giải phóng các trình điều khiển cấp thấp khỏi việc phải xuất tệp
		thiết bị nút ký tự và xử lý liên quan.
	iii.	Thực hiện bất kỳ cơ chế chính sách nào ở một nơi.
	iv.	Các ứng dụng chỉ phải giao tiếp với mô-đun thay vì
		nhiều trình điều khiển cấp thấp.

Hiện tại mô-đun này (được gọi là Mô-đun quản lý chung) chỉ được sử dụng để phát hành
lệnh ioctl. Nhưng mô-đun này được hình dung để xử lý mọi cấp độ không gian của người dùng
tương tác. Vì vậy, mọi triển khai 'proc', 'sysfs' sẽ được bản địa hóa trong này
mô-đun chung.

Tín dụng
-------

::

"Mã chia sẻ trong mô-đun thứ ba, "mô-đun thư viện", có thể chấp nhận được
	giải pháp. modprobe tự động tải các mô-đun phụ thuộc, vì vậy người dùng
	chạy "modprobe driver1" hoặc "modprobe driver2" sẽ tự động
	tải mô-đun thư viện dùng chung."

- Jeff Garzik (jgarzik@pobox.com), 25.02.2004 LKML

::

"Như Jeff đã gợi ý, nếu không gian người dùng<->trình điều khiển API của bạn nhất quán giữa
	bộ điều khiển RAID dựa trên MPT mới và trình điều khiển megaraid hiện có của bạn,
	thì có lẽ bạn cần một mô-đun trợ giúp nhỏ (lsiioctl hoặc một số
	tên hay hơn), được tải tự động bởi cả mptraid và megaraid,
	xử lý việc đăng ký nút /dev/megaraid một cách linh hoạt. Trong trường hợp này,
	cả mptraid và megaraid sẽ đăng ký với lsiioctl cho mỗi loại
	bộ chuyển đổi được phát hiện và lsiioctl về cơ bản sẽ là một công tắc,
	chuyển hướng ioctls công cụ không gian người dùng sang trình điều khiển thích hợp."

- Matt Domsch, (Matt_Domsch@dell.com), 25.02.2004 LKML

Thiết kế
------

Mô-đun quản lý chung được triển khai trong tệp megaaid_mm.[ch]. Cái này
mô-đun hoạt động như một cơ quan đăng ký cho trình điều khiển hba cấp thấp. Trình điều khiển cấp thấp
(hiện chỉ có megaraid) đăng ký từng bộ điều khiển với mô-đun chung.

Giao diện ứng dụng với mô-đun chung thông qua thiết bị ký tự
nút được mô-đun xuất.

Các trình điều khiển cấp thấp hơn hiện chỉ hiểu gói ioctl cải tiến mới được gọi là
uioc_t. Mô-đun quản lý chuyển đổi các gói ioctl cũ hơn từ gói cũ hơn
ứng dụng vào uioc_t. Sau khi trình điều khiển xử lý uioc_t, mô-đun chung
sẽ chuyển đổi lại thành định dạng cũ trước khi quay lại ứng dụng.

Khi các ứng dụng mới phát triển và thay thế các ứng dụng cũ, định dạng gói cũ sẽ
sẽ nghỉ hưu.

Mô-đun chung dành một gói uioc_t cho mỗi bộ điều khiển đã đăng ký. Cái này
có thể dễ dàng có nhiều hơn một. Nhưng vì megaraid là trình điều khiển cấp thấp duy nhất
ngày nay và nó chỉ có thể xử lý một ioctl, không có lý do gì để có nhiều hơn. Nhưng
khi các lớp trình điều khiển mới được thêm vào, điều này sẽ được điều chỉnh cho phù hợp.