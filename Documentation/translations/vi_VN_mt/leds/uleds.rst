.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/leds/uleds.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
Đèn LED không gian người dùng
=============================

Trình điều khiển uleds hỗ trợ đèn LED không gian người dùng. Điều này có thể hữu ích cho việc thử nghiệm
kích hoạt và cũng có thể được sử dụng để triển khai đèn LED ảo.


Cách sử dụng
============

Khi trình điều khiển được tải, một thiết bị ký tự sẽ được tạo tại /dev/uleds. Đến
tạo một thiết bị lớp LED mới, mở /dev/uleds và viết uleds_user_dev
cấu trúc của nó (được tìm thấy trong tệp tiêu đề công khai kernel linux/uleds.h)::

#define LED_MAX_NAME_SIZE 64

cấu trúc uleds_user_dev {
	tên char[LED_MAX_NAME_SIZE];
    };

Một thiết bị lớp LED mới sẽ được tạo với tên đã cho. Tên có thể là
bất kỳ tên nút thiết bị sysfs hợp lệ nào, nhưng hãy cân nhắc sử dụng cách đặt tên lớp LED
quy ước "tên thiết bị: màu: hàm".

Độ sáng hiện tại được tìm thấy bằng cách đọc một byte từ ký tự
thiết bị. Các giá trị không dấu: 0 đến 255. Việc đọc sẽ bị chặn cho đến khi độ sáng
những thay đổi. Nút thiết bị cũng có thể được thăm dò để thông báo khi giá trị độ sáng
những thay đổi.

Thiết bị lớp LED sẽ bị xóa khi tệp đang mở xử lý tới /dev/uleds
đã đóng cửa.

Nhiều thiết bị lớp LED được tạo bằng cách mở các thẻ điều khiển tệp bổ sung để
/dev/uleds.

Xem tools/leds/uledmon.c để biết ví dụ về chương trình không gian người dùng.
