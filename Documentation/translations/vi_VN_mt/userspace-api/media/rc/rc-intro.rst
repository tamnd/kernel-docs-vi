.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/rc/rc-intro.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

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