.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/dev-radio.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _radio:

****************
Giao diện vô tuyến
***************

Giao diện này dành cho các máy thu radio AM và FM (analog) và
máy phát.

Thông thường các thiết bị vô tuyến V4L2 được truy cập thông qua thiết bị ký tự
các tập tin đặc biệt có tên ZZ0000ZZ và ZZ0001ZZ để
ZZ0002ZZ với số chính 81 và số phụ từ 64 đến 127.


Khả năng truy vấn
=====================

Các thiết bị hỗ trợ giao diện vô tuyến đặt ZZ0002ZZ và
Cờ ZZ0003ZZ hoặc ZZ0004ZZ trong
Trường cấu trúc ZZ0005ZZ
ZZ0000ZZ được trả lại bởi
ZZ0001ZZ ioctl. Sự kết hợp khác của
cờ khả năng được dành riêng cho các phần mở rộng trong tương lai.


Chức năng bổ sung
======================

Các thiết bị vô tuyến có thể hỗ trợ ZZ0000ZZ và phải hỗ trợ
ioctls ZZ0001ZZ.

Chúng không hỗ trợ đầu vào hoặc đầu ra video, đầu vào hoặc đầu ra âm thanh,
tiêu chuẩn video, cắt xén và chia tỷ lệ, nén và truyền phát
tham số hoặc lớp phủ ioctls. Tất cả các phương thức ioctls và I/O khác đều
dành riêng cho các phần mở rộng trong tương lai.


Lập trình
===========

Thiết bị vô tuyến có thể có một số bộ điều khiển âm thanh (như đã thảo luận trong phần
ZZ0000ZZ) chẳng hạn như điều khiển âm lượng, có thể là điều khiển tùy chỉnh.
Hơn nữa, tất cả các thiết bị vô tuyến đều có một bộ dò sóng hoặc bộ điều biến (đây là
đã thảo luận trong ZZ0001ZZ) với số chỉ số 0 để chọn đài
tần số và để xác định xem chương trình âm thanh nổi đơn âm hay FM
nhận/phát ra. Trình điều khiển tự động chuyển đổi giữa AM và FM
tùy thuộc vào tần số đã chọn. các
ZZ0002ZZ hoặc
ZZ0003ZZ ioctl báo cáo
dải tần được hỗ trợ.