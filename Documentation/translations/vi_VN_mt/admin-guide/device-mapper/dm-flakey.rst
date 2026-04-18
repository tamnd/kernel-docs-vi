.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/dm-flakey.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========
dm-flakey
=========

Mục tiêu này giống như mục tiêu tuyến tính ngoại trừ việc nó thể hiện
hành vi không đáng tin cậy theo định kỳ.  Nó được thấy là hữu ích trong việc mô phỏng
thiết bị hỏng nhằm mục đích thử nghiệm.

Bắt đầu từ thời điểm bảng được tải, thiết bị có sẵn để
<up interval> giây, sau đó thể hiện hành vi không đáng tin cậy đối với <down interval>
khoảng> giây và sau đó chu kỳ này lặp lại.

Ngoài ra, hãy cân nhắc việc sử dụng kết hợp với mục tiêu dm-delay,
có thể trì hoãn việc đọc và ghi và/hoặc gửi chúng đến các
các thiết bị cơ bản.

Tham số bảng
----------------

::

<đường dẫn dev> <offset> <khoảng thời gian lên> <khoảng thời gian xuống> \
    [<num_features> [<đối số tính năng>]]

Các thông số bắt buộc:

<đường dẫn nhà phát triển>:
        Tên đường dẫn đầy đủ đến thiết bị khối cơ bản hoặc
        số thiết bị "chính:nhỏ".
    <bù đắp>:
        Khu vực bắt đầu trong thiết bị.
    <khoảng tăng>:
        Số giây thiết bị có sẵn.
    <khoảng thời gian xuống>:
        Số giây thiết bị trả về lỗi.

Các thông số tính năng tùy chọn:

Nếu không có tham số tính năng nào, trong khoảng thời gian
  không đáng tin cậy, tất cả I/O đều trả về lỗi.

error_reads:
	Tất cả I/O đọc đều không thành công và có tín hiệu lỗi.
	Ghi I/O được xử lý chính xác.

drop_writes:
	Tất cả thao tác ghi I/O đều được âm thầm bỏ qua.
	Đọc I/O được xử lý chính xác.

error_writes:
	Tất cả thao tác ghi I/O đều không thành công và có tín hiệu lỗi.
	Đọc I/O được xử lý chính xác.

tham nhũng_bio_byte <Nth_byte> <hướng> <giá trị> <cờ>:
	Trong <khoảng thời gian ngừng hoạt động>, hãy thay thế <Nth_byte> dữ liệu của
	mỗi tiểu sử phù hợp với <giá trị>.

<Nth_byte>:
	Phần bù của byte cần thay thế.
	Việc đếm bắt đầu từ 1, để thay thế byte đầu tiên.
    <hướng>:
	Hoặc 'r' để đọc bị hỏng hoặc 'w' để ghi bị hỏng.
	'w' không tương thích với drop_writes.
    <giá trị>:
	Giá trị (từ 0-255) để ghi.
    <cờ>:
	Chỉ thực hiện thay thế nếu bio->bi_opf có tất cả
	cờ đã chọn được đặt.

ngẫu nhiên_read_corrupt <xác suất>
	Trong <khoảng thời gian ngừng hoạt động>, hãy thay thế byte ngẫu nhiên trong tiểu sử đã đọc
	với một giá trị ngẫu nhiên. xác suất là một số nguyên giữa
	0 và 1000000000 nghĩa là xác suất tham nhũng từ 0% đến 100%.

ngẫu nhiên_write_corrupt <xác suất>
	Trong <khoảng thời gian ngừng hoạt động>, hãy thay thế byte ngẫu nhiên trong tiểu sử ghi
	với một giá trị ngẫu nhiên. xác suất là một số nguyên giữa
	0 và 1000000000 nghĩa là xác suất tham nhũng từ 0% đến 100%.

Ví dụ:

Thay thế byte thứ 32 của bios READ bằng giá trị 1::

tham nhũng_bio_byte 32 r 1 0

Thay thế byte thứ 224 của bios REQ_META (=32) bằng giá trị 0::

tham nhũng_bio_byte 224 w 0 32
