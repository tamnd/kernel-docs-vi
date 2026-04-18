.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/mem_alignment.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================
Căn chỉnh bộ nhớ
==================

Quá nhiều vấn đề xuất hiện do việc truy cập bộ nhớ bị sai lệch không được chú ý trong
mã hạt nhân gần đây.  Do đó, việc sửa lỗi căn chỉnh hiện nay là vô điều kiện
được cấu hình cho các mục tiêu dựa trên SA11x0.  Theo Alan Cox, đây là một
ý tưởng tồi để cấu hình nó, nhưng Russell King có một số lý do chính đáng để
làm như vậy trên một số kiến trúc ARM tồi tệ như EBSA110.  Tuy nhiên
đây không phải là trường hợp của nhiều thiết kế mà tôi biết, giống như tất cả các thiết kế dựa trên SA11x0
những cái đó.

Tất nhiên đây là một ý tưởng tồi nếu dựa vào bẫy căn chỉnh để thực hiện
truy cập bộ nhớ không được phân bổ nói chung.  Nếu những quyền truy cập đó có thể dự đoán được, bạn
tốt hơn nên sử dụng các macro được cung cấp bởi include/linux/unaligned.h.  các
bẫy căn chỉnh có thể khắc phục quyền truy cập bị sai lệch trong các trường hợp ngoại lệ, nhưng tại
chi phí hiệu suất cao.  Tốt hơn là nên hiếm.

Giờ đây, đối với các ứng dụng không gian người dùng, có thể định cấu hình căn chỉnh
bẫy vào SIGBUS bất kỳ mã nào thực hiện truy cập không được sắp xếp (tốt cho việc gỡ lỗi lỗi
code) hoặc thậm chí sửa lỗi truy cập bằng phần mềm như mã kernel.  Càng về sau
chế độ này không được khuyến nghị vì lý do hiệu suất (chỉ cần nghĩ về
mô phỏng dấu phẩy động hoạt động theo cùng một cách).  Sửa mã của bạn
thay vào đó!

Xin lưu ý rằng việc thay đổi hành vi một cách ngẫu nhiên mà không có suy nghĩ đúng đắn là
thực sự tệ - nó thay đổi hành vi của tất cả các hướng dẫn chưa được căn chỉnh trong người dùng
trống và có thể khiến các chương trình bị lỗi bất ngờ.

Để thay đổi hành vi bẫy căn chỉnh, chỉ cần lặp lại một số vào
/proc/cpu/căn chỉnh.  Số được tạo thành từ nhiều bit khác nhau:

=== =============================================================
hành vi bit khi được thiết lập
=== =============================================================
0 Một tiến trình người dùng thực hiện truy cập bộ nhớ không được phân bổ
		sẽ khiến kernel in một thông báo cho biết
		tên tiến trình, pid, pc, lệnh, địa chỉ và
		mã lỗi.

1 Kernel sẽ cố gắng khắc phục tiến trình của người dùng
		thực hiện truy cập không được căn chỉnh.  Đây là tất nhiên
		chậm (hãy nghĩ về trình mô phỏng dấu phẩy động) và
		không được khuyến khích sử dụng cho sản xuất.

2 Kernel sẽ gửi tín hiệu SIGBUS đến tiến trình người dùng
		thực hiện truy cập không được căn chỉnh.
=== =============================================================

Lưu ý rằng không phải tất cả các kết hợp đều được hỗ trợ - chỉ các giá trị từ 0 đến 5.
(6 và 7 không có ý nghĩa).

Ví dụ: thao tác sau sẽ bật cảnh báo nhưng không có
sửa chữa hoặc gửi tín hiệu SIGBUS::

echo 1 > /proc/cpu/căn chỉnh

Bạn cũng có thể đọc nội dung của cùng một tệp để có được số liệu thống kê
thông tin về các lần truy cập không được sắp xếp cộng với chế độ hiện tại của
hoạt động cho mã không gian người dùng.


Nicolas Pitre, 13 tháng 3 năm 2001. Russell King sửa đổi, 30 tháng 11 năm 2001.
