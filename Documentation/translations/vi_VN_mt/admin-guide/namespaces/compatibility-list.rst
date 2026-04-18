.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/namespaces/compatibility-list.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Danh sách tương thích không gian tên
=============================

Tài liệu này chứa thông tin về các vấn đề mà người dùng gặp phải
có thể có khi tạo các tác vụ trong các không gian tên khác nhau.

Đây là bản tóm tắt. Ma trận này hiển thị các vấn đề đã biết, đó là
xảy ra khi các tác vụ chia sẻ một số không gian tên (các cột) khi đang hoạt động
trong các không gian tên khác (các hàng):

==== === === === === ==== ===
- Mạng người dùng UTS IPC VFS PID
==== === === === === ==== ===
UTS X
IPC X 1
VFS X
PID 1 1 X
Người dùng 2 2 X
Mạng X
==== === === === === ==== ===

1. Cả hai không gian tên IPC và PID đều cung cấp ID để giải quyết
   đối tượng bên trong kernel. Ví dụ. semaphore với IPCID hoặc
   nhóm quy trình với pid.

Trong cả hai trường hợp, tác vụ không nên thử hiển thị ID này cho một số người.
   tác vụ khác sống trong một không gian tên khác thông qua hệ thống tệp được chia sẻ
   hoặc tin nhắn/tin nhắn IPC. Thực tế là ID này chỉ có giá trị
   trong không gian tên mà nó được lấy và có thể đề cập đến một số
   đối tượng khác trong một không gian tên khác.

2. Cố ý tạo ra hai ID người dùng bằng nhau trong các vùng tên người dùng khác nhau
   không nên bằng nhau theo quan điểm VFS. Ở nơi khác
   từ, người dùng 10 trong một không gian tên người dùng không được giống nhau
   quyền truy cập vào các tập tin, thuộc về người dùng 10 ở một nơi khác
   không gian tên.

Điều tương tự cũng đúng đối với các không gian tên IPC được chia sẻ - hai người dùng
   từ các không gian tên người dùng khác nhau sẽ không truy cập vào cùng một đối tượng IPC
   thậm chí có UID bằng nhau.

Nhưng hiện tại thì không phải vậy.
