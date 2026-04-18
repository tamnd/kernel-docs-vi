.. SPDX-License-Identifier: BSD-3-Clause

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/netlink.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _kernel_netlink:

======================================
Ghi chú Netlink dành cho nhà phát triển kernel
===================================

Hướng dẫn chung
================

enum thuộc tính
---------------

Các dòng cũ hơn thường định nghĩa các thuộc tính và lệnh "null" có giá trị
của ZZ0000ZZ và được đặt tên là ZZ0001ZZ. Điều này được hỗ trợ (ZZ0002ZZ)
nhưng nên tránh ở những gia đình mới. Các giá trị enum ZZ0003ZZ là
không được sử dụng trong thực tế, vì vậy chỉ đặt giá trị của thuộc tính đầu tiên thành ZZ0004ZZ.

enum tin nhắn
-------------

Sử dụng cùng một ID lệnh cho yêu cầu và phản hồi. Điều này làm cho nó dễ dàng hơn
để khớp chúng và chúng tôi có nhiều không gian ID.

Sử dụng ID lệnh riêng cho thông báo. Điều này làm cho nó dễ dàng hơn để
sắp xếp các thông báo từ các câu trả lời (và hiển thị chúng cho người dùng
ứng dụng thông qua API khác với thư trả lời).

Trả lời yêu cầu
---------------

Các gia đình lớn tuổi hơn không trả lời tất cả các lệnh, đặc biệt là NEW / ADD
lệnh. Người dùng chỉ nhận được thông tin liệu thao tác thành công hay
không thông qua ACK. Cố gắng tìm dữ liệu hữu ích để trả về. Một khi lệnh được
đã thêm liệu nó có trả lời bằng tin nhắn đầy đủ hay chỉ ACK là uAPI và
không thể thay đổi được. Tốt hơn hết là bạn nên trả lời sai.

Cụ thể các lệnh NEW và ADD sẽ trả lời kèm theo thông tin nhận dạng
đối tượng được tạo chẳng hạn như ID của đối tượng được phân bổ (mà không cần phải
sử dụng ZZ0000ZZ).

NLM_F_ECHO
----------

Đảm bảo chuyển thông tin yêu cầu tới genl_notify() để cho phép ZZ0000ZZ
để có hiệu lực.  Điều này hữu ích cho các chương trình cần phản hồi chính xác
từ kernel (ví dụ cho mục đích ghi nhật ký).

Hỗ trợ tính nhất quán của kết xuất
------------------------

Nếu lặp lại các đối tượng trong quá trình kết xuất có thể bỏ qua các đối tượng hoặc lặp lại
chúng - đảm bảo báo cáo kết xuất không nhất quán với ZZ0000ZZ.
Điều này thường được thực hiện bằng cách duy trì id thế hệ cho
cấu trúc và ghi nó vào thành viên ZZ0001ZZ của struct netlink_callback.

Đặc điểm kỹ thuật liên kết mạng
=====================

Tài liệu về các phần đặc tả Netlink chỉ liên quan
vào không gian hạt nhân.

Quả cầu
-------

chính sách hạt nhân
~~~~~~~~~~~~~

Xác định xem chính sách xác thực kernel có phải là ZZ0000ZZ hay không, tức là giống nhau cho tất cả
các hoạt động của họ, được xác định cho từng hoạt động riêng lẻ - ZZ0001ZZ,
hoặc riêng cho từng thao tác và loại thao tác (do vs dump) - ZZ0002ZZ.
Các gia đình mới nên sử dụng ZZ0003ZZ (mặc định) để có thể thu hẹp phạm vi
các thuộc tính được chấp nhận bởi một lệnh cụ thể.

séc
------

Tài liệu về các phần phụ ZZ0000ZZ của thông số kỹ thuật thuộc tính.

kết thúc-ok
~~~~~~~~~~~~~~~

Chấp nhận các chuỗi không có dấu kết thúc null (chỉ dành cho các dòng kế thừa).
Chuyển từ loại chính sách ZZ0000ZZ sang ZZ0001ZZ.

ống kính tối đa
~~~~~~~

Xác định độ dài tối đa cho thuộc tính nhị phân hoặc chuỗi (tương ứng
tới thành viên ZZ0000ZZ của struct nla_policy). Đối với thuộc tính chuỗi kết thúc
ký tự null không được tính vào ZZ0001ZZ.

Trường này có thể là một giá trị nguyên bằng chữ hoặc là tên của một đối tượng được xác định
hằng số. Các kiểu chuỗi có thể giảm hằng số đi một
(tức là chỉ định ZZ0000ZZ) để dành chỗ cho việc kết thúc
ký tự nên việc triển khai sẽ nhận ra mẫu đó.

min-len
~~~~~~~

Tương tự như ZZ0000ZZ nhưng xác định độ dài tối thiểu.