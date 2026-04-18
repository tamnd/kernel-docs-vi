.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/ipv6.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====
IPv6
====


Các tùy chọn cho mô-đun ipv6 được cung cấp dưới dạng tham số khi tải.

Các tùy chọn mô-đun có thể được cung cấp dưới dạng đối số dòng lệnh cho insmod
hoặc lệnh modprobe, nhưng thường được chỉ định trong một trong hai
Các tệp cấu hình ZZ0000ZZ hoặc trong một bản phân phối cụ thể
tập tin cấu hình.

Các tham số mô-đun ipv6 có sẵn được liệt kê bên dưới.  Nếu một tham số
không được chỉ định giá trị mặc định được sử dụng.

Các thông số như sau:

vô hiệu hóa

Chỉ định có tải mô-đun IPv6 hay không nhưng tắt tất cả
	chức năng của nó.  Điều này có thể được sử dụng khi một mô-đun khác
	có sự phụ thuộc vào mô-đun IPv6 đang được tải, nhưng không
	Địa chỉ hoặc hoạt động IPv6 được mong muốn.

Các giá trị có thể có và tác dụng của chúng là:

0
		IPv6 được kích hoạt.

Đây là giá trị mặc định.

1
		IPv6 bị vô hiệu hóa.

Sẽ không có địa chỉ IPv6 nào được thêm vào giao diện và
		sẽ không thể mở ổ cắm IPv6.

Cần phải khởi động lại để kích hoạt IPv6.

tự động cấu hình

Chỉ định xem có bật tính năng tự động cấu hình địa chỉ IPv6 hay không
	trên mọi giao diện.  Điều này có thể được sử dụng khi người ta không muốn
	để các địa chỉ được tạo tự động từ tiền tố
	nhận được trong Quảng cáo bộ định tuyến.

Các giá trị có thể có và tác dụng của chúng là:

0
		Tính năng tự động cấu hình địa chỉ IPv6 bị tắt trên tất cả các giao diện.

Chỉ địa chỉ loopback IPv6 (::1) và địa chỉ liên kết cục bộ
		sẽ được thêm vào giao diện.

1
		Tự động cấu hình địa chỉ IPv6 được bật trên tất cả các giao diện.

Đây là giá trị mặc định.

vô hiệu hóa_ipv6

Chỉ định xem có tắt IPv6 trên tất cả các giao diện hay không.
	Điều này có thể được sử dụng khi không cần địa chỉ IPv6.

Các giá trị có thể có và tác dụng của chúng là:

0
		IPv6 được kích hoạt trên tất cả các giao diện.

Đây là giá trị mặc định.

1
		IPv6 bị vô hiệu hóa trên tất cả các giao diện.

Không có địa chỉ IPv6 nào sẽ được thêm vào giao diện.
