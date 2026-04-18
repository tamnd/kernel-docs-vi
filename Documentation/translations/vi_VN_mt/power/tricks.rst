.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/power/tricks.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
thủ thuật swsusp/S3
===================

Pavel Machek <pavel@ucw.cz>

Nếu bạn muốn đánh lừa swsusp/S3 hoạt động, bạn có thể thử:

* đi với cấu hình tối thiểu, tắt các trình điều khiển như USB, AGP bạn không
  thực sự cần

* tắt APIC và ưu tiên

* sử dụng ext2. Ít nhất nó có fsck hoạt động. [Nếu có điều gì đó có vẻ không ổn
  sai rồi, buộc fsck khi bạn có cơ hội]

* tắt mô-đun

* sử dụng bảng điều khiển văn bản vga, tắt X. [Nếu bạn thực sự muốn X, bạn có thể
  muốn thử vesafb sau]

* thử chạy càng ít tiến trình càng tốt, tốt nhất là chuyển sang một tiến trình
  chế độ người dùng.

* do vấn đề về video, nên swsusp sẽ dễ dàng hoạt động hơn
  S3. Hãy thử điều đó đầu tiên.

Khi bạn làm cho nó hoạt động, hãy cố gắng tìm hiểu xem chính xác cái gì đã hỏng
tạm dừng và tốt nhất là khắc phục điều đó.
