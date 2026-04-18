.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fault-injection/provoke-crashes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================================================
Gây ra sự cố với Mô-đun kiểm tra kết xuất hạt nhân Linux (LKDTM)
=================================================================

Mô-đun lkdtm cung cấp giao diện để phá vỡ (và thường gặp sự cố)
kernel tại các vị trí mã được xác định trước để đánh giá độ tin cậy của
xử lý ngoại lệ của kernel và kiểm tra các kết xuất sự cố thu được bằng cách sử dụng
giải pháp đổ thải khác nhau. Mô-đun này sử dụng KPROBE để điều khiển
vị trí kích hoạt, nhưng cũng có thể kích hoạt kernel trực tiếp mà không cần KPROBE
hỗ trợ thông qua debugfs.

Bạn có thể chọn vị trí của trình kích hoạt ("tên điểm sự cố") và
loại hành động ("loại điểm sự cố") thông qua các đối số mô-đun khi
chèn mô-đun hoặc thông qua giao diện debugfs.

Cách sử dụng::

insmod lkdtm.ko [recur_count={>0}] cpoint_name=<> cpoint_type=<>
			[cpoint_count={>0}]

số lần tái diễn
	Mức đệ quy cho kiểm tra tràn ngăn xếp. Theo mặc định đây là
	được tính toán động dựa trên cấu hình kernel, với
	mục tiêu là đủ lớn để làm cạn kiệt ngăn xếp hạt nhân. các
	giá trị có thể được nhìn thấy tại ZZ0000ZZ.

cpoint_name
	Vị trí trong kernel để kích hoạt hành động. Nó có thể
	một trong những INT_HARDWARE_ENTRY, INT_HW_IRQ_EN, INT_TASKLET_ENTRY,
	FS_SUBMIT_BH, MEM_SWAPOUT, TIMERADD, SCSI_QUEUE_RQ hoặc DIRECT.

cpoint_type
	Cho biết hành động cần thực hiện khi chạm vào điểm va chạm.
	Đây là rất nhiều và được truy vấn trực tiếp tốt nhất từ ​​debugfs. Một số
	trong số những cái phổ biến là PANIC, BUG, EXCEPTION, LOOP và OVERFLOW.
	Xem nội dung của ZZ0000ZZ để biết
	một danh sách đầy đủ

cpoint_count
	Cho biết số lần điểm va chạm sẽ bị va chạm
	trước khi kích hoạt hành động. Mặc định là 10 (ngoại trừ
	DIRECT, luôn kích hoạt ngay lập tức).

Bạn cũng có thể gây ra lỗi bằng cách gắn debugfs và ghi kiểu vào
<debugfs>/provoke-crash/<crashpoint>. Ví dụ.::

mount -t debugfs debugfs/sys/kernel/debug
  echo EXCEPTION > /sys/kernel/debug/provoke-crash/INT_HARDWARE_ENTRY

Tệp đặc biệt ZZ0000ZZ sẽ thực hiện hành động trực tiếp mà không cần KPROBE
thiết bị đo đạc. Chế độ này là chế độ duy nhất khả dụng khi mô-đun được
được xây dựng cho kernel không hỗ trợ KPROBE::

# Instead về việc để BUG giết vỏ của bạn, hãy để nó giết "con mèo":
  mèo <(echo WRITE_RO) >/sys/kernel/debug/provoke-crash/DIRECT