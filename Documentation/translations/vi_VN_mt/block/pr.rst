.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/block/pr.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================================
Hỗ trợ lớp khối cho Đặt chỗ liên tục
===============================================

Nhân Linux hỗ trợ giao diện không gian người dùng để đơn giản hóa
Đặt chỗ liên tục ánh xạ để chặn các thiết bị hỗ trợ
những cái này (như SCSI). Đặt chỗ liên tục cho phép hạn chế
quyền truy cập để chặn các thiết bị đối với những người khởi tạo cụ thể trong bộ nhớ dùng chung
thiết lập.

Tài liệu này cung cấp cái nhìn tổng quan chung về các lệnh ioctl hỗ trợ.
Để tham khảo chi tiết hơn, vui lòng tham khảo SCSI Primary
Lệnh tiêu chuẩn, cụ thể là phần Đặt chỗ và
Lệnh "PERSISTENT RESERVE IN" và "PERSISTENT RESERVE OUT".

Tất cả các hoạt động triển khai đều được kỳ vọng sẽ đảm bảo các lượt đặt trước tồn tại
mất điện và bao phủ tất cả các kết nối trong môi trường đa đường dẫn.
Những hành vi này là tùy chọn trong SPC nhưng sẽ được áp dụng tự động
bởi Linux.


Các loại đặt chỗ sau được hỗ trợ:
--------------------------------------------------

-PR_WRITE_EXCLUSIVE
	Chỉ người khởi xướng sở hữu đặt chỗ mới có thể viết thư cho
	thiết bị.  Bất kỳ người khởi xướng nào cũng có thể đọc từ thiết bị.

-PR_EXCLUSIVE_ACCESS
	Chỉ người khởi xướng sở hữu đặt chỗ mới có thể truy cập
	thiết bị.

-PR_WRITE_EXCLUSIVE_REG_ONLY
	Chỉ những người khởi tạo có khóa đã đăng ký mới có thể ghi vào thiết bị,
	Bất kỳ người khởi xướng nào cũng có thể đọc từ thiết bị.

-PR_EXCLUSIVE_ACCESS_REG_ONLY
	Chỉ những người khởi tạo có khóa đã đăng ký mới có thể truy cập thiết bị.

-PR_WRITE_EXCLUSIVE_ALL_REGS

Chỉ những người khởi tạo có khóa đã đăng ký mới có thể ghi vào thiết bị,
	Bất kỳ người khởi xướng nào cũng có thể đọc từ thiết bị.
	Tất cả những người khởi tạo có khóa đã đăng ký đều được coi là đặt trước
	người nắm giữ.
	Vui lòng tham khảo thông số SPC về ý nghĩa của việc đặt chỗ
	chủ nếu bạn muốn sử dụng loại này.

-PR_EXCLUSIVE_ACCESS_ALL_REGS
	Chỉ những người khởi tạo có khóa đã đăng ký mới có thể truy cập thiết bị.
	Tất cả những người khởi tạo có khóa đã đăng ký đều được coi là đặt trước
	người nắm giữ.
	Vui lòng tham khảo thông số SPC về ý nghĩa của việc đặt chỗ
	chủ nếu bạn muốn sử dụng loại này.


Các ioctl sau được hỗ trợ:
----------------------------------

1. IOC_PR_REGISTER
^^^^^^^^^^^^^^^^^^

Lệnh ioctl này đăng ký đặt chỗ mới nếu đối số new_key
là không rỗng.  Nếu hiện tại không có đặt chỗ nào old_key phải bằng 0,
nếu đặt chỗ hiện tại cần được thay thế old_key phải chứa
chìa khóa đặt chỗ cũ.

Nếu đối số new_key là 0 thì nó sẽ hủy đăng ký phần đặt chỗ hiện có đã được thông qua
trong old_key.


2. IOC_PR_RESERVE
^^^^^^^^^^^^^^^^^

Lệnh ioctl này bảo lưu thiết bị và do đó hạn chế quyền truy cập cho các thiết bị khác
thiết bị dựa trên đối số loại.  Đối số chính phải là hiện tại
khóa đặt trước cho thiết bị được IOC_PR_REGISTER mua lại,
Các lệnh IOC_PR_REGISTER_IGNORE, IOC_PR_PREEMPT hoặc IOC_PR_PREEMPT_ABORT.


3. IOC_PR_RELEASE
^^^^^^^^^^^^^^^^^

Lệnh ioctl này giải phóng phần đặt trước được chỉ định bởi khóa và cờ
và do đó loại bỏ mọi hạn chế truy cập được ngụ ý bởi nó.


4. IOC_PR_PREEMPT
^^^^^^^^^^^^^^^^^

Lệnh ioctl này giải phóng phần đặt chỗ hiện có được đề cập bởi
old_key và thay thế nó bằng loại dành riêng mới cho
khóa đặt trước new_key.


5. IOC_PR_PREEMPT_ABORT
^^^^^^^^^^^^^^^^^^^^^^^

Lệnh ioctl này hoạt động giống như IOC_PR_PREEMPT ngoại trừ việc nó cũng hủy bỏ
bất kỳ lệnh chưa xử lý nào được gửi qua kết nối được xác định bởi old_key.

6. IOC_PR_CLEAR
^^^^^^^^^^^^^^^

Lệnh ioctl này hủy đăng ký cả khóa và bất kỳ khóa đặt trước nào khác
đã đăng ký với thiết bị và loại bỏ mọi đặt chỗ hiện có.


Cờ
-----

Tất cả các ioctls đều có trường cờ.  Hiện tại chỉ có một cờ được hỗ trợ:

-PR_FL_IGNORE_KEY
	Bỏ qua khóa đặt chỗ hiện có.  Điều này thường được hỗ trợ cho
	IOC_PR_REGISTER và một số triển khai có thể hỗ trợ cờ cho
	IOC_PR_RESERVE.

Đối với tất cả các cờ không xác định, kernel sẽ trả về -EOPNOTSUPP.
