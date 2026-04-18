.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/ext4/about.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Về cuốn sách này
===============

Tài liệu này cố gắng mô tả định dạng trên đĩa cho ext4
hệ thống tập tin. Những ý tưởng chung tương tự nên áp dụng cho hệ thống tập tin ext2/3
cũng vậy, mặc dù chúng không hỗ trợ tất cả các tính năng mà ext4 hỗ trợ,
và các trường sẽ ngắn hơn.

ZZ0000ZZ: Đây là công việc đang được tiến hành, dựa trên ghi chú mà tác giả
(djwong) được thực hiện khi tách một hệ thống tập tin bằng tay. Dữ liệu
định nghĩa cấu trúc phải được cập nhật kể từ Linux 4.18 và
e2fsprogs-1.44. Mọi ý kiến đóng góp và chỉnh sửa đều được hoan nghênh vì có
chắc chắn có rất nhiều truyền thuyết có thể không được phản ánh trong bản mới
đã tạo ra các hệ thống tập tin trình diễn.

Giấy phép
-------
Cuốn sách này được cấp phép theo các điều khoản của Giấy phép Công cộng GNU, v2.

Thuật ngữ
-----------

ext4 chia thiết bị lưu trữ thành một mảng các khối logic để
giảm chi phí kế toán và tăng sản lượng bằng cách buộc quy mô lớn hơn
kích thước chuyển giao. Nói chung, kích thước khối sẽ là 4KiB (cùng kích thước với
các trang trên x86 và kích thước khối mặc định của lớp khối), mặc dù
kích thước thực tế được tính là 2 ^ (10 + ZZ0000ZZ) byte.
Trong suốt tài liệu này, các vị trí đĩa được đưa ra dưới dạng
khối logic, không phải LBA thô và không phải khối 1024 byte. Vì lợi ích của
thuận tiện, kích thước khối logic sẽ được gọi là
ZZ0001ZZ xuyên suốt phần còn lại của tài liệu.

Khi được tham chiếu trong các khối ZZ0000ZZ, ZZ0001ZZ đề cập đến các trường
trong siêu khối và ZZ0002ZZ đề cập đến các trường trong bảng inode
nhập cảnh.

Tài liệu tham khảo khác
----------------

Đồng thời xem ZZ0000ZZ để biết khá nhiều bộ sưu tập
thông tin về ext2/3. Đây là một tài liệu tham khảo cũ khác:
ZZ0001ZZ