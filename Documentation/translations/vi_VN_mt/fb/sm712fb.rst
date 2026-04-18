.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fb/sm712fb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===============================================================
sm712fb - Trình điều khiển bộ đệm khung đồ họa Silicon Motion SM712
==========================================================

Đây là trình điều khiển bộ đệm khung đồ họa cho bộ xử lý dựa trên Silicon Motion SM712.

Làm thế nào để sử dụng nó?
==============

Việc chuyển đổi chế độ được thực hiện bằng cách sử dụng tham số khởi động video=sm712fb:....

Ví dụ: nếu bạn muốn bật độ phân giải 1280x1024x24bpp, bạn nên
chuyển tới kernel dòng lệnh này: "video=sm712fb:0x31B".

Bạn không nên biên dịch vesafb.

Các chế độ video hiện được hỗ trợ là:

Chế độ đồ họa
-------------

=== ======= =============== ==========
bpp 640x480 800x600 1024x768 1280x1024
=== ======= =============== ==========
  8 0x301 0x303 0x305 0x307
 16 0x311 0x314 0x317 0x31A
 24 0x312 0x315 0x318 0x31B
=== ======= =============== ==========

Thiếu tính năng
================
(bí danh danh sách TODO)

* Tăng tốc 2D
	* Hỗ trợ hai đầu
