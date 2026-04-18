.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/ext4/inlinedata.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Dữ liệu nội tuyến
-----------------

Tính năng dữ liệu nội tuyến được thiết kế để xử lý trường hợp một tập tin
dữ liệu rất nhỏ nên nó dễ dàng nằm gọn trong inode, điều này
(về mặt lý thuyết) làm giảm mức tiêu thụ khối đĩa và giảm tìm kiếm. Nếu
tệp nhỏ hơn 60 byte thì dữ liệu được lưu trữ nội tuyến trong
ZZ0000ZZ. Nếu phần còn lại của tập tin vừa với phần mở rộng
không gian thuộc tính thì nó có thể được tìm thấy như một thuộc tính mở rộng
“system.data” trong phần thân inode (“ibody EA”). Tất nhiên điều này
hạn chế số lượng thuộc tính mở rộng mà người ta có thể gắn vào một nút.
Nếu kích thước dữ liệu tăng vượt quá i_block + ibody EA, một khối thông thường
được phân bổ và nội dung được chuyển đến khối đó.

Đang chờ thay đổi để thu gọn khóa thuộc tính mở rộng được sử dụng để lưu trữ
dữ liệu nội tuyến, người ta phải có khả năng lưu trữ 160 byte dữ liệu trong một
Inode 256 byte (kể từ tháng 6 năm 2015, khi i_extra_isize là 28). Trước khi
rằng, giới hạn là 156 byte do việc sử dụng không gian inode không hiệu quả.

Tính năng dữ liệu nội tuyến yêu cầu sự hiện diện của thuộc tính mở rộng
đối với “system.data”, ngay cả khi giá trị thuộc tính có độ dài bằng 0.

Thư mục nội tuyến
~~~~~~~~~~~~~~~~~~

Bốn byte đầu tiên của i_block là số inode của cha
thư mục. Theo sau đó là không gian 56 byte cho một mảng thư mục
mục; xem ZZ0000ZZ. Nếu có “system.data”
thuộc tính trong phần thân inode, giá trị EA là một mảng
ZZ0001ZZ cũng vậy. Lưu ý rằng đối với các thư mục nội tuyến,
Không gian i_block và EA được coi là các khối trực tiếp riêng biệt; thư mục
các mục không thể kéo dài cả hai.

Các mục nhập thư mục nội tuyến không được kiểm tra tổng, vì tổng kiểm tra inode
nên bảo vệ tất cả nội dung dữ liệu nội tuyến.