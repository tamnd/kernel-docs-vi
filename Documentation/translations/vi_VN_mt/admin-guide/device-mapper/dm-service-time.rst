.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/dm-service-time.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================
dm-thời gian phục vụ
====================

dm-service-time là mô-đun chọn đường dẫn cho các mục tiêu của trình ánh xạ thiết bị,
trong đó chọn đường đi có thời gian phục vụ ước tính ngắn nhất cho
I/O đến.

Thời gian phục vụ cho mỗi đường dẫn được ước tính bằng cách chia tổng kích thước
của I/O đang hoạt động trên một đường dẫn có giá trị hiệu suất của đường dẫn.
Giá trị hiệu suất là giá trị thông lượng tương đối giữa tất cả các đường dẫn
trong một nhóm đường dẫn và nó có thể được chỉ định làm đối số bảng.

Tên bộ chọn đường dẫn là 'thời gian phục vụ'.

Bảng tham số cho từng đường dẫn:

[<repeat_count> [<relative_throughput>]]
	<repeat_count>:
			Số lượng I/O được gửi đi bằng cách sử dụng đã chọn
			đường dẫn trước khi chuyển sang đường dẫn tiếp theo.
			Nếu không được đưa ra, mặc định nội bộ sẽ được sử dụng.  Để kiểm tra
			giá trị mặc định, xem bảng kích hoạt.
	<relative_throughput>:
			Giá trị thông lượng tương đối của đường dẫn
			trong số tất cả các đường dẫn trong nhóm đường dẫn.
			Phạm vi hợp lệ là 0-100.
			Nếu không được cung cấp, giá trị tối thiểu '1' sẽ được sử dụng.
			Nếu '0' được đưa ra, đường dẫn không được chọn trong khi
			các đường dẫn khác có giá trị dương có sẵn.

Trạng thái cho mỗi đường dẫn:

<trạng thái> <đếm lỗi> <kích thước trong chuyến bay> <relative_throughput>
	<trạng thái>:
		'A' nếu đường dẫn đang hoạt động, 'F' nếu đường dẫn bị lỗi.
	<đếm lỗi>:
		Số lượng đường dẫn bị lỗi.
	<kích thước trên chuyến bay>:
		Kích thước của I/O trong chuyến bay trên đường dẫn.
	<relative_throughput>:
		Giá trị thông lượng tương đối của đường dẫn
		trong số tất cả các đường dẫn trong nhóm đường dẫn.


Thuật toán
=========

dm-service-time thêm kích thước I/O vào 'kích thước trong chuyến bay' khi I/O được
được gửi đi và trừ đi khi hoàn thành.
Về cơ bản, dm-service-time chọn đường dẫn có thời gian phục vụ tối thiểu
được tính bằng::

('kích thước trong chuyến bay' + 'kích thước của-io-đến') / 'relative_throughput'

Tuy nhiên, một số tối ưu hóa dưới đây được sử dụng để giảm bớt việc tính toán
càng nhiều càng tốt.

1. Nếu các đường dẫn có cùng 'relative_throughput', hãy bỏ qua
	   phân chia và chỉ so sánh 'kích thước trên chuyến bay'.

2. Nếu các đường dẫn có cùng 'kích thước trên chuyến bay', hãy bỏ qua phép chia
	   và chỉ so sánh 'relative_throughput'.

3. Nếu một số đường dẫn có 'relative_throughput' khác 0 và các đường dẫn khác
	   không có 'relative_throughput', bỏ qua những đường dẫn bằng 0
	   'tương đối_thông lượng'.

Nếu không thể áp dụng những tối ưu hóa đó, hãy tính thời gian phục vụ và
so sánh thời gian phục vụ
Nếu thời gian phục vụ được tính bằng nhau thì đường đi có giá trị tối đa
'Rative_throughput' có thể tốt hơn.  Vì vậy hãy so sánh 'relative_throughput'
sau đó.


Ví dụ
========
Trong trường hợp 2 đường dẫn (sda và sdb) được sử dụng với loop_count == 128
và sda có thông lượng trung bình 1GB/s và sdb có 4GB/s,
Giá trị 'relative_throughput' có thể là '1' cho sda và '4' cho sdb::

# echo "0 10 đa đường 0 0 1 1 thời gian phục vụ 0 2 2 8:0 128 1 8:16 128 4" \
    dmsetup tạo thử nghiệm
  #
  Bàn # dmsetup
  kiểm tra: 0 10 đa đường 0 0 1 1 thời gian phục vụ 0 2 2 8:0 128 1 8:16 128 4
  #
  Trạng thái # dmsetup
  kiểm tra: 0 10 đa đường 2 0 0 0 1 1 E 0 2 2 8:0 A 0 0 1 8:16 A 0 0 4


Hoặc '2' cho sda và '8' cho sdb cũng đúng ::

# echo "0 10 đa đường 0 0 1 1 thời gian phục vụ 0 2 2 8:0 128 2 8:16 128 8" \
    dmsetup tạo thử nghiệm
  #
  Bàn # dmsetup
  kiểm tra: 0 10 đa đường 0 0 1 1 thời gian phục vụ 0 2 2 8:0 128 2 8:16 128 8
  #
  Trạng thái # dmsetup
  kiểm tra: 0 10 đa đường 2 0 0 0 1 1 E 0 2 2 8:0 A 0 0 2 8:16 A 0 0 8
