.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fb/internals.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================================
Nội bộ của thiết bị Bộ đệm khung
=============================

Đây là bước khởi đầu đầu tiên cho một số tài liệu về thiết bị đệm khung
nội bộ.

tác giả:

- Geert Uytterhoeven <geert@linux-m68k.org>, ngày 21 tháng 7 năm 1998
- James Simmons <jsimmons@user.sf.net>, ngày 26 tháng 11 năm 2002

--------------------------------------------------------------------------------

Các cấu trúc được sử dụng bởi thiết bị đệm khung API
==============================================

Các cấu trúc sau đây đóng một vai trò trong trò chơi của các thiết bị đệm khung. Họ
được định nghĩa trong <linux/fb.h>.

1. Bên ngoài kernel (không gian người dùng)

- cấu trúc fb_fix_screeninfo

Thông tin không thể thay đổi độc lập với thiết bị về thiết bị đệm khung và
    một chế độ video cụ thể. Điều này có thể đạt được bằng cách sử dụng FBIOGET_FSCREENINFO
    ioctl.

- struct fb_var_screeninfo

Thông tin có thể thay đổi độc lập với thiết bị về thiết bị đệm khung và
    chế độ video cụ thể. Điều này có thể đạt được bằng cách sử dụng FBIOGET_VSCREENINFO
    ioctl và được cập nhật với FBIOPUT_VSCREENINFO ioctl. Nếu bạn muốn xoay
    chỉ có màn hình, bạn có thể sử dụng FBIOPAN_DISPLAY ioctl.

- cấu trúc fb_cmap

Thông tin bản đồ màu độc lập với thiết bị. Bạn có thể lấy và thiết lập bản đồ màu
    bằng cách sử dụng ioctls FBIOGETCMAP và FBIOPUTCMAP.


2. Bên trong hạt nhân

- cấu trúc fb_info

Thông tin chung, API và thông tin cấp thấp về một khung cụ thể
    phiên bản thiết bị đệm (số khe, địa chỉ bảng, ...).

- cấu trúc ZZ0000ZZ

Thông tin phụ thuộc vào thiết bị xác định duy nhất chế độ video cho việc này
    phần cứng cụ thể.


Hình ảnh được sử dụng bởi thiết bị đệm khung API
===========================================


Đơn sắc (FB_VISUAL_MONO01 và FB_VISUAL_MONO10)
--------------------------------------------------
Mỗi pixel có màu đen hoặc trắng.


Màu giả (FB_VISUAL_PSEUDOCOLOR và FB_VISUAL_STATIC_PSEUDOCOLOR)
---------------------------------------------------------------------
Toàn bộ giá trị pixel được cung cấp thông qua bảng tra cứu có thể lập trình có một
màu sắc (bao gồm cường độ màu đỏ, xanh lục và xanh lam) cho mỗi pixel có thể
giá trị và màu đó được hiển thị.


Màu sắc trung thực (FB_VISUAL_TRUECOLOR)
--------------------------------
Giá trị pixel được chia thành các trường màu đỏ, xanh lục và xanh lam.


Màu trực tiếp (FB_VISUAL_DIRECTCOLOR)
------------------------------------
Giá trị pixel được chia thành các trường màu đỏ, xanh lục và xanh lam, mỗi trường
được tra cứu trong các bảng tra cứu màu đỏ, xanh lá cây và xanh dương riêng biệt.


Màn hình thang độ xám
------------------
Thang độ xám và thang độ xám tĩnh là các biến thể đặc biệt của màu giả và thang độ tĩnh.
màu giả, trong đó các thành phần màu đỏ, xanh lá cây và xanh dương luôn bằng nhau
lẫn nhau.
