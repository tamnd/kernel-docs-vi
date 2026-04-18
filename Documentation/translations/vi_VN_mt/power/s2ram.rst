.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/power/s2ram.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
Làm cách nào để s2ram hoạt động
===============================

2006 Linus Torvalds
2006 Pavel Machek

1) Kiểm tra Suspend.sf.net, chương trình s2ram ở đó có danh sách trắng dài
   các máy "biết rồi", cùng với các thủ thuật để sử dụng trên từng máy.

2) Nếu cách đó không hiệu quả, hãy thử đọc Tricks.txt và
   video.txt. Có lẽ vấn đề chỉ đơn giản là mô-đun bị hỏng và
   việc dỡ bỏ mô-đun đơn giản có thể khắc phục nó.

3) Bạn có thể sử dụng cơ sở hạ tầng TRACE_RESUME của Linus, được mô tả bên dưới.

Sử dụng TRACE_RESUME
~~~~~~~~~~~~~~~~~~

Tôi đang nghiên cứu chế tạo những chiếc máy mà tôi có thể tạo ra STR, và gần như
luôn luôn là một trình điều khiển có lỗi. Cảm ơn Chúa vì đã tạm dừng/tiếp tục
gỡ lỗi - thứ mà Chuck đã cố gắng vô hiệu hóa. Đó thường là _chỉ_
cách gỡ lỗi những thứ này và nó thực sự khá mạnh mẽ (nhưng
tốn thời gian - phải chèn điểm đánh dấu TRACE_RESUME() vào thiết bị
trình điều khiển không tiếp tục và biên dịch lại và khởi động lại).

Dù sao, cách gỡ lỗi này dành cho những người quan tâm (có
máy không khởi động được) là:

- bật PM_DEBUG và PM_TRACE

- sử dụng tập lệnh như thế này ::

#!/bin/sh
	đồng bộ hóa
	echo 1 > /sys/power/pm_trace
	echo mem > /sys/power/state

đình chỉ

- nếu nó không hoạt động trở lại (thường là vấn đề), hãy khởi động lại bằng cách
   giữ nút nguồn và nhìn vào đầu ra dmesg để biết mọi thứ
   thích::

Con số kỳ diệu: 4:156:725
	hàm băm khớp với driver/base/power/resume.c:28
	hàm băm khớp với thiết bị 0000:01:00.0

điều đó có nghĩa là sự kiện theo dõi cuối cùng diễn ra ngay trước khi cố gắng tiếp tục
   thiết bị 0000:01:00.0. Sau đó tìm hiểu xem trình điều khiển nào đang điều khiển điều đó
   thiết bị (lspci và /sys/devices/pci* là bạn của bạn) và xem liệu bạn có thể
   sửa nó, vô hiệu hóa nó hoặc theo dõi chức năng tiếp tục của nó.

Nếu không có thiết bị nào khớp với hàm băm (hoặc bất kỳ kết quả khớp nào có vẻ là dương tính giả),
   thủ phạm có thể là một thiết bị từ mô-đun hạt nhân có thể tải nhưng chưa được tải
   cho đến sau khi hàm băm được kiểm tra. Bạn có thể kiểm tra hàm băm so với hiện tại
   thiết bị lại sau khi tải thêm mô-đun bằng sysfs::

mèo/sys/power/pm_trace_dev_match

Ví dụ: thiết bị trên là thiết bị VGA trên EVO của tôi, mà tôi
được sử dụng để chạy với "radeonfb" (đó là thiết bị di động ATI Radeon). Hóa ra
"radeonfb" đó đơn giản là không thể tiếp tục thiết bị đó - nó cố gắng đặt
Của PLL, và nó chỉ _treo_. Sử dụng bảng điều khiển VGA thông thường và cho phép X
tiếp tục nó thay vì hoạt động tốt.

NOTE
====
pm_trace sử dụng Đồng hồ thời gian thực của hệ thống (RTC) để lưu con số kỳ diệu.
Lý do cho điều này là RTC là thiết bị duy nhất có sẵn đáng tin cậy
phần cứng trong quá trình tiếp tục các hoạt động trong đó một giá trị có thể được đặt sẽ
sống sót sau khi khởi động lại.

pm_trace không tương thích với hệ thống treo không đồng bộ, vì vậy nó sẽ chuyển sang
tạm dừng không đồng bộ (có thể hoạt động theo thời gian hoặc
lỗi nhạy cảm với thứ tự).

Hậu quả là sau khi sơ yếu lý lịch (ngay cả khi thành công) hệ thống của bạn
đồng hồ sẽ có giá trị tương ứng với con số kỳ diệu thay vì
đúng ngày/giờ! Do đó, nên sử dụng chương trình như ntp-date
hoặc rdate để đặt lại ngày/giờ chính xác từ nguồn thời gian bên ngoài khi
sử dụng tùy chọn theo dõi này.

Khi đồng hồ tiếp tục tích tắc, điều cần thiết là phải thực hiện khởi động lại
nhanh chóng sau khi tiếp tục thất bại. Tùy chọn theo dõi không sử dụng giây
hoặc các bit thứ tự thấp trong số phút của RTC, nhưng độ trễ quá dài sẽ
làm hỏng giá trị kỳ diệu.
