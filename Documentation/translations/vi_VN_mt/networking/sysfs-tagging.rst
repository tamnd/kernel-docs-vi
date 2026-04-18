.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/sysfs-tagging.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============
Gắn thẻ hệ thống
=============

(Gần như nguyên văn từ bản vá gắn thẻ mạng của Eric Biederman
tin nhắn cam kết)

Vấn đề.  Các thiết bị mạng hiển thị trong sysfs và với mạng
không gian tên đang hoạt động, nhiều thiết bị có cùng tên có thể hiển thị trong
cùng một thư mục, ôi!

Để tránh vấn đề đó và cho phép các ứng dụng hiện có trong mạng
không gian tên để xem giao diện tương tự hiện được trình bày trong
sysfs, sysfs hiện có hỗ trợ thư mục gắn thẻ.

Bằng cách sử dụng các con trỏ không gian tên mạng làm thẻ để phân tách
các mục trong thư mục sysfs chúng tôi đảm bảo rằng chúng tôi không có xung đột
trong các thư mục và ứng dụng chỉ thấy một bộ giới hạn
các thiết bị mạng.

Mỗi mục nhập thư mục sysfs có thể được gắn thẻ với một không gian tên thông qua
ZZ0000ZZ của ZZ0001ZZ của nó.  Nếu một mục thư mục được gắn thẻ,
thì ZZ0002ZZ sẽ có cờ giữa KOBJ_NS_TYPE_NONE
và KOBJ_NS_TYPES, và ns sẽ trỏ đến không gian tên mà nó
thuộc về.

Kernfs_super_info của mỗi siêu khối sysfs chứa một mảng
ZZ0000ZZ.  Khi một tác vụ trong không gian tên gắn thẻ
kobj_nstype lần đầu tiên gắn kết sysfs, một siêu khối mới được tạo.  Nó
sẽ được phân biệt với các mount sysfs khác bằng cách có
ZZ0001ZZ được đặt thành không gian tên mới.  Lưu ý rằng
thông qua việc gắn liên kết và truyền bá gắn kết, một tác vụ có thể dễ dàng xem
nội dung của các mount sysfs của không gian tên khác.  Vì thế, khi một
không gian tên thoát ra, nó sẽ gọi kobj_ns_exit() để vô hiệu hóa bất kỳ
con trỏ kernfs_node->ns trỏ tới nó.

Người sử dụng giao diện này:

- xác định một loại trong bảng liệt kê ZZ0000ZZ.
- gọi kobj_ns_type_register() bằng ZZ0001ZZ của nó có

- current_ns() trả về không gian tên của hiện tại
  - netlink_ns() trả về không gian tên của ổ cắm
  - init_ns() trả về không gian tên ban đầu

- gọi kobj_ns_exit() khi một thẻ riêng lẻ không còn hợp lệ