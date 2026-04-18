.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/seg6-sysctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Các biến Sysfs của Seg6
====================


Các biến /proc/sys/net/conf/<iface>/seg6_*:
============================================

seg6_enabled - BOOL
	Chấp nhận hoặc loại bỏ các gói IPv6 hỗ trợ SR trên giao diện này.

Các gói có liên quan là những gói có SRH và DA = local.

* 0 - bị tắt (mặc định)
	* không phải 0 - đã bật

seg6_require_hmac - INTEGER
	Xác định chính sách HMAC để truy cập các gói hỗ trợ SR trên giao diện này.

* -1 - Bỏ qua trường HMAC
	* 0 - Chấp nhận các gói SR không có HMAC, xác thực các gói SR có HMAC
	* 1 - Bỏ các gói SR không có HMAC, xác thực các gói SR bằng HMAC

Mặc định là 0.

Các biến /proc/sys/net/ipv6/seg6_*:
====================================

seg6_flowlabel - INTEGER
	Kiểm soát hành vi tính toán nhãn luồng của bên ngoài
	Tiêu đề IPv6 trong trường hợp SR T.encaps

=============================================================
	 -1 đặt nhãn lưu lượng về 0.
	  0 sao chép nhãn luồng từ gói Bên trong trong trường hợp IPv6 Bên trong
	     (Đặt nhãn lưu lượng thành 0 trong trường hợp IPv4/L2)
	  1 Tính toán flowlabel bằng seg6_make_flowlabel()
	 =============================================================

Mặc định là 0.