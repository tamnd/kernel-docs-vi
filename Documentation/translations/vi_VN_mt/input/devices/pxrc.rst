.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/input/devices/pxrc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================================================
pxrc - Bộ điều hợp điều khiển chuyến bay PhoenixRC
=======================================================

:Tác giả: Marcus Folkesson <marcus.folkesson@gmail.com>

Trình điều khiển này cho phép bạn sử dụng bộ điều khiển RC của riêng mình được cắm vào
bộ chuyển đổi đi kèm với PhoenixRC hoặc các bộ chuyển đổi tương thích khác.

Bộ chuyển đổi hỗ trợ 7 kênh analog và 1 công tắc đầu vào kỹ thuật số.

Ghi chú
=====

Nhiều bộ điều khiển RC có thể định cấu hình thanh nào đi đến kênh nào.
Điều này cũng có thể được cấu hình trong hầu hết các trình mô phỏng, do đó không cần thiết phải khớp.

Trình điều khiển đang tạo sự kiện đầu vào sau cho các kênh analog:

+----------+-------+
Sự kiện ZZ0000ZZ |
+===========+==================+
ZZ0001ZZ ABS_X |
+----------+-------+
ZZ0002ZZ ABS_Y |
+----------+-------+
ZZ0003ZZ ABS_RX |
+----------+-------+
ZZ0004ZZ ABS_RY |
+----------+-------+
ZZ0005ZZ ABS_RUDDER |
+----------+-------+
ZZ0006ZZ ABS_THROTTLE |
+----------+-------+
ZZ0007ZZ ABS_MISC |
+----------+-------+

Công tắc đầu vào kỹ thuật số được tạo dưới dạng sự kiện ZZ0000ZZ.

Kiểm tra thủ công
==============

Để kiểm tra chức năng của trình điều khiển này, bạn có thể sử dụng ZZ0000ZZ, một phần của
bộ ZZ0001ZZ [1]_.

Ví dụ::

> modprobe pxrc
    > sự kiện đầu vào <devnr>

Để in tất cả các sự kiện đầu vào từ đầu vào ZZ0000ZZ.

Tài liệu tham khảo
==========

.. [1] https://www.kraxel.org/cgit/input/
