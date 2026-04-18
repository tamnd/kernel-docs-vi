.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/ipsec.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====
IPsec
=====


Ở đây ghi lại các trường hợp góc IPsec đã biết cần được ghi nhớ khi
triển khai các cấu hình IPsec khác nhau trong môi trường sản xuất thế giới thực.

1. IPcomp:
	   Gói IP nhỏ sẽ không được nén ở người gửi và không thực hiện được
	   kiểm tra chính sách trên máy thu.

Trích dẫn từ RFC3173::

2.2. Chính sách không mở rộng

Nếu tổng kích thước của tải trọng nén và tiêu đề IPComp, như
   được xác định ở mục 3, không nhỏ hơn kích thước của bản gốc
   tải trọng, gói dữ liệu IP MUST được gửi ở dạng không nén ban đầu
   hình thức.  Để làm rõ: Nếu một datagram IP được gửi không nén, không

Tiêu đề IPComp được thêm vào datagram.  Chính sách này đảm bảo tiết kiệm
   chu trình xử lý giải nén và tránh phát sinh IP
   phân mảnh datagram khi datagram được mở rộng lớn hơn datagram
   MTU.

Các gói dữ liệu IP nhỏ có khả năng mở rộng do bị nén.
   Do đó, nên áp dụng ngưỡng số trước khi nén,
   trong đó các gói dữ liệu IP có kích thước nhỏ hơn ngưỡng được gửi trong
   dạng ban đầu mà không cần cố gắng nén.  Ngưỡng số
   phụ thuộc vào việc triển khai.

Việc triển khai IPComp hiện tại thực sự được thực hiện theo sách, trong khi thực tế
khi gửi gói không nén tới thiết bị ngang hàng (có hoặc không gói len
nhỏ hơn ngưỡng hoặc ống kính nén lớn hơn ban đầu
gói len), gói sẽ bị loại bỏ khi kiểm tra chính sách vì gói này
khớp với bộ chọn nhưng không đến từ bất kỳ lớp XFRM nào, tức là không có
đường dẫn an ninh. Gói trần trụi như vậy cuối cùng sẽ không được đưa lên lớp trên.
Kết quả là người dùng được kết nối nhiều hơn khi ping ngang hàng với các thiết bị khác nhau.
chiều dài tải trọng.

Một cách giải quyết khác là cố gắng đặt "mức sử dụng" cho từng chính sách nếu người dùng quan sát thấy
kịch bản trên. Hậu quả của việc làm như vậy là gói nhỏ (không nén)
sẽ bỏ qua việc kiểm tra chính sách ở phía người nhận.