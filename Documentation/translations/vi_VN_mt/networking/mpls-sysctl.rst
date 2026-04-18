.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/mpls-sysctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Biến hệ thống MPLS
======================

/proc/sys/net/mpls/* Các biến:
===============================

platform_labels - INTEGER
	Số mục trong bảng nhãn nền tảng.  Nó không phải
	có thể định cấu hình chuyển tiếp cho các giá trị nhãn bằng hoặc
	lớn hơn số lượng nhãn nền tảng.

Việc sử dụng dày đặc các mục trong bảng nhãn nền tảng
	có thể thực hiện được và được mong đợi vì các nhãn nền tảng đều có tính chất cục bộ
	được phân bổ.

Nếu số mục trong bảng nhãn nền tảng được đặt thành 0 thì không
	nhãn sẽ được hạt nhân nhận ra và chuyển tiếp mpls
	sẽ bị vô hiệu hóa.

Việc giảm giá trị này sẽ loại bỏ tất cả các mục định tuyến nhãn
	không còn vừa với bàn nữa.

Các giá trị có thể có: 0 - 1048575

Mặc định: 0

ip_ttl_propagate - BOOL
	Kiểm soát xem TTL có được truyền từ tiêu đề IPv4/IPv6 tới
	tiêu đề MPLS trên các nhãn áp đặt và được truyền từ
	Tiêu đề MPLS đến tiêu đề IPv4/IPv6 khi bật nhãn cuối cùng.

Nếu bị tắt, mạng truyền tải MPLS sẽ xuất hiện dưới dạng
	một bước nhảy để chuyển giao lưu lượng.

* 0 - bị vô hiệu hóa / Model ống RFC 3443 [Ngắn]
	* 1 - đã bật / Mẫu đồng phục RFC 3443 (mặc định)

mặc định_ttl - INTEGER
	Giá trị TTL mặc định để sử dụng cho các gói MPLS khi không thể sử dụng được
	được truyền từ một tiêu đề IP, bởi vì nó không xuất hiện
	hoặc ip_ttl_propagate đã bị vô hiệu hóa.

Các giá trị có thể có: 1 - 255

Mặc định: 255

conf/<giao diện>/đầu vào - BOOL
	Kiểm soát xem các gói có thể được nhập vào giao diện này hay không.

Nếu bị tắt, các gói sẽ bị loại bỏ mà không cần thêm
	xử lý.

* 0 - bị tắt (mặc định)
	* không phải 0 - đã bật