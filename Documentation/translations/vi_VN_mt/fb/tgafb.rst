.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fb/tgafb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================================
tgafb - Trình điều khiển bộ đệm khung đồ họa TGA
================================================

Đây là trình điều khiển cho bộ đệm khung đồ họa dựa trên DECChip 21030, hay còn gọi là TGA
thẻ, thường được tìm thấy trong các hệ thống Digital Alpha cũ hơn. các
mô hình sau đây được hỗ trợ:

- ZLxP-E1 (8bpp, 2 MB VRAM)
- ZLxP-E2 (32bpp, 8 MB VRAM)
- ZLxP-E3 (32bpp, 16 MB VRAM, Zbuffer)

Phiên bản này là bản viết lại gần như hoàn chỉnh của mã được viết bởi Geert
Uytterhoeven, dựa trên mã bảng điều khiển TGA ban đầu được viết bởi
Jay Estabrook.

Các tính năng mới chính kể từ Linux 2.0.x:

* Hỗ trợ nhiều độ phân giải
 * Hỗ trợ cho màn hình tần số cố định và các màn hình kỳ quặc khác
   (bằng cách cho phép cài đặt chế độ video khi khởi động)

Những thay đổi mà người dùng có thể nhìn thấy kể từ Linux 2.2.x:

* Đồng bộ hóa trên màu xanh lá cây hiện đã được xử lý đúng cách
 * Nhiều thông tin hữu ích hơn được in khi khởi động
   (điều này sẽ hữu ích nếu mọi người gặp vấn đề)

Trình điều khiển này chưa (chưa) hỗ trợ dòng bộ đệm khung TGA2, vì vậy
Thẻ PowerStorm 3D30/4D20 (còn được gọi là PBXGB) không được hỗ trợ. Những cái này
tuy nhiên có thể được sử dụng với trình điều khiển Bảng điều khiển văn bản VGA tiêu chuẩn.


Cấu hình
=============

Bạn có thể chuyển các tùy chọn dòng lệnh kernel cho tgafb bằng
ZZ0000ZZ (nên có nhiều tùy chọn
được phân tách bằng dấu phẩy, các giá trị được phân tách khỏi các tùy chọn bằng ZZ0001ZZ).

Tùy chọn được chấp nhận:

============================================================================
font:X phông chữ mặc định để sử dụng. Tất cả các phông chữ đều được hỗ trợ, bao gồm cả
	    Phông chữ SUN12x22 rất đẹp ở độ phân giải cao.

mode:X chế độ video mặc định. Các chế độ video sau được hỗ trợ:
	    640x480-60, 800x600-56, 640x480-72, 800x600-60, 800x600-72,
	    1024x768-60, 1152x864-60, 1024x768-70, 1024x768-76,
	    1152x864-70, 1280x1024-61, 1024x768-85, 1280x1024-70,
	    1152x864-84, 1280x1024-76, 1280x1024-85
============================================================================


Sự cố đã biết
=============

Máy chủ XFree86 FBDev đã được báo cáo là không hoạt động, vì tgafb không hoạt động
mmap(). Chạy máy chủ XF86_TGA tiêu chuẩn từ XFree86 3.3.x hoạt động tốt với
tôi, tuy nhiên máy chủ này không thực hiện tăng tốc, điều này thực hiện một số thao tác nhất định
khá chậm. Hỗ trợ tăng tốc đang được tích hợp dần dần trong
XFree86 4.x.

Khi chạy tgafb ở độ phân giải cao hơn 640x480, khi chuyển VC từ
tgafb sang XF86_TGA 3.3.x, toàn bộ màn hình không được vẽ lại mà phải vẽ thủ công
được làm mới. Đây là sự cố máy chủ X, không phải sự cố tgafb và đã được khắc phục trong
XFree86 4.0.

Thưởng thức!

Martin Lucina <mato@kotelna.sk>
