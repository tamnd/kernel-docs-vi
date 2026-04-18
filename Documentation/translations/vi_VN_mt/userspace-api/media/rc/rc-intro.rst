.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/rc/rc-intro.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _Remote_controllers_Intro:

************
Giới thiệu
************

Hiện nay, hầu hết các thiết bị analog và kỹ thuật số đều có đầu vào Hồng ngoại cho
bộ điều khiển từ xa. Mỗi nhà sản xuất có loại điều khiển riêng. Nó
không phải là hiếm khi cùng một nhà sản xuất vận chuyển các loại khác nhau
điều khiển, tùy thuộc vào thiết bị.

Giao diện Bộ điều khiển từ xa được ánh xạ dưới dạng evdev/đầu vào bình thường
giao diện giống như bàn phím hoặc chuột. Vì vậy, nó sử dụng tất cả ioctls
đã được xác định cho bất kỳ thiết bị đầu vào nào khác.

Tuy nhiên, bộ điều khiển loại bỏ linh hoạt hơn đầu vào thông thường
thiết bị, vì bộ thu IR (và/hoặc bộ phát) có thể được sử dụng trong
kết hợp với nhiều loại điều khiển từ xa IR khác nhau.

Để cho phép linh hoạt, hệ thống con Điều khiển từ xa cho phép
kiểm soát các thuộc tính dành riêng cho RC thông qua
ZZ0000ZZ.