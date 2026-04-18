.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fb/pvr2fb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================================
pvr2fb - Trình điều khiển bộ đệm khung đồ họa PowerVR 2
===============================================

Đây là trình điều khiển cho bộ đệm khung đồ họa dựa trên PowerVR 2, chẳng hạn như
một cái được tìm thấy trong Dreamcast.

Thuận lợi:

* Nó cung cấp một bảng điều khiển lớn đẹp mắt (128 cols + 48 dòng với 1024x768)
   không sử dụng phông chữ nhỏ, không thể đọc được (NOT trên Dreamcast)
 * Bạn có thể chạy XF86_FBDev trên /dev/fb0
 * Quan trọng nhất: logo khởi động :-)

Nhược điểm:

* Trình điều khiển phần lớn chưa được kiểm tra trên các hệ thống không phải Dreamcast.

Cấu hình
=============

Bạn có thể chuyển các tùy chọn dòng lệnh kernel cho pvr2fb bằng
ZZ0000ZZ (nên có nhiều tùy chọn
được phân tách bằng dấu phẩy, các giá trị được phân tách khỏi các tùy chọn bằng ZZ0001ZZ).

Tùy chọn được chấp nhận:

==================================================================================
font:X phông chữ mặc định để sử dụng. Tất cả các phông chữ đều được hỗ trợ, bao gồm cả
	    Phông chữ SUN12x22 rất đẹp ở độ phân giải cao.


mode:X chế độ video mặc định với định dạng [xres]x[yres]-<bpp>@<refresh rate>
	    Các chế độ video sau được hỗ trợ:
	    640x640-16@60, 640x480-24@60, 640x480-32@60. Dreamcast
	    mặc định là 640x480-16@60. Tại thời điểm viết bài
	    Chế độ 24bpp và 32bpp hoạt động kém. Làm việc để khắc phục điều đó
	    đang diễn ra

Lưu ý: chế độ 640x240 hiện bị hỏng và không nên
	    được sử dụng vì bất kỳ lý do gì. Nó chỉ được đề cập ở đây như một tài liệu tham khảo.

đảo ngược màu sắc trên màn hình (đối với màn hình LCD)

nomtrr vô hiệu hóa việc kết hợp ghi trên bộ đệm khung. Điều này làm chậm trình điều khiển
	    nhưng có báo cáo về sự không tương thích nhỏ giữa GUS DMA và
	    XFree dưới mức tải cao nếu tính năng kết hợp ghi được bật (âm thanh
	    bỏ học). MTRR được bật theo mặc định trên các hệ thống có nó
	    được cấu hình và hỗ trợ nó.

cáp:loại cáp X. Đây có thể là bất kỳ loại nào sau đây: vga, rgb và
	    tổng hợp. Nếu không có gì được chỉ định, chúng tôi đoán.

đầu ra: Loại đầu ra X. Đây có thể là bất kỳ tên nào sau đây: pal, ntsc và
	    vga. Nếu không có gì được chỉ định, chúng tôi đoán.
==================================================================================

X11
===

XF86_FBDev đã được chứng minh là hoạt động trên Dreamcast trong quá khứ - mặc dù chưa
trên bất kỳ hạt nhân dòng 2.6 nào.

Paul Mundt <lethal@linuxdc.org>

Được cập nhật bởi Adrian McMenamin <adrian@mcmen.demon.co.uk>
