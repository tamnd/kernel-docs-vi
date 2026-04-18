.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/dm-queue-length.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================
chiều dài hàng đợi dm
=====================

dm-queue-length là mô-đun chọn đường dẫn cho các mục tiêu của trình ánh xạ thiết bị,
trong đó chọn một đường dẫn có số lượng I/O trong chuyến bay ít nhất.
Tên bộ chọn đường dẫn là 'độ dài hàng đợi'.

Bảng tham số cho từng đường dẫn: [<repeat_count>]

::

<repeat_count>: Số lượng I/O được gửi đi bằng cách sử dụng
			đường dẫn trước khi chuyển sang đường dẫn tiếp theo.
			Nếu không được đưa ra, mặc định nội bộ sẽ được sử dụng. Để kiểm tra
			giá trị mặc định, xem bảng kích hoạt.

Trạng thái cho mỗi đường dẫn: <status> <fail-count> <in-flight>

::

<status>: 'A' nếu đường dẫn đang hoạt động, 'F' nếu đường dẫn không thành công.
	<fail-count>: Số lượng đường dẫn bị lỗi.
	<in-flight>: Số lượng I/O trong chuyến bay trên đường dẫn.


Thuật toán
==========

dm-queue-length tăng/giảm 'trong chuyến bay' khi I/O được thực hiện
được gửi/hoàn thành tương ứng.
dm-queue-length chọn một đường dẫn có 'trong chuyến bay' tối thiểu.


Ví dụ
========
Trong trường hợp 2 đường dẫn (sda và sdb) được sử dụng với loop_count == 128.

::

# echo "0 10 đa đường 0 0 1 1 độ dài hàng đợi 0 2 1 8:0 128 8:16 128" \
    dmsetup tạo thử nghiệm
  #
  Bàn # dmsetup
  kiểm tra: 0 10 đa đường 0 0 1 1 độ dài hàng đợi 0 2 1 8:0 128 8:16 128
  #
  Trạng thái # dmsetup
  kiểm tra: 0 10 đa đường 2 0 0 0 1 1 E 0 2 1 8:0 A 0 0 8:16 A 0 0
