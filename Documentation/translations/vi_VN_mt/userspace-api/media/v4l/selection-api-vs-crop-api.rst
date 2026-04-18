.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/selection-api-vs-crop-api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _selection-vs-crop:

********************************
So sánh với API cắt xén cũ
********************************

Lựa chọn API được giới thiệu để giải quyết những thiếu sót của
ZZ0000ZZ cũ hơn, được thiết kế để điều khiển đơn giản
các thiết bị chụp. Sau đó, API cắt xén đã được áp dụng cho đầu ra video
trình điều khiển. Các ioctls được sử dụng để chọn một phần của màn hình
tín hiệu video được chèn vào. Nó nên được coi là lạm dụng API
bởi vì thao tác được mô tả thực chất là soạn thảo. các
lựa chọn API phân biệt rõ ràng giữa soạn thảo và cắt xén
hoạt động bằng cách thiết lập các mục tiêu thích hợp.

CROP API không có bất kỳ hỗ trợ nào cho việc soạn thảo và cắt xén từ một
hình ảnh bên trong bộ nhớ đệm. Ứng dụng có thể cấu hình một
thiết bị chụp để chỉ lấp đầy một phần hình ảnh bằng cách lạm dụng V4L2
API. Việc cắt xén một hình ảnh nhỏ hơn từ một hình ảnh lớn hơn được thực hiện bằng cách cài đặt
trường ZZ0003ZZ tại cấu trúc ZZ0000ZZ.
Việc giới thiệu độ lệch hình ảnh có thể được thực hiện bằng cách sửa đổi trường
ZZ0004ZZ tại struct ZZ0001ZZ trước khi gọi
ZZ0002ZZ. Những hoạt động đó nên tránh
bởi vì chúng không có tính di động (độ bền) và không hoạt động cho
định dạng macroblock và Bayer và bộ đệm mmap.

Việc lựa chọn API liên quan đến cấu hình bộ đệm
cắt xén/sáng tác một cách rõ ràng, trực quan và di động. Tiếp theo, với
lựa chọn API các khái niệm về mục tiêu được đệm và các ràng buộc
cờ được giới thiệu. Cuối cùng, struct ZZ0000ZZ và struct
ZZ0001ZZ không có trường dành riêng. Vì thế không có
cách để mở rộng chức năng của họ. Cấu trúc mới
ZZ0002ZZ cung cấp nhiều không gian cho tương lai
phần mở rộng.

Các nhà phát triển trình điều khiển được khuyến khích chỉ triển khai lựa chọn API. các
API cắt xén trước đây sẽ được mô phỏng bằng cách sử dụng API mới.