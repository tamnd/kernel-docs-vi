.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fb/arkfb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

============================================
arkfb - trình điều khiển fbdev cho chip Logic ARK
========================================


Phần cứng được hỗ trợ
==================

Chip ARK 2000PV
	ICS 5342 ramdac

- chỉ hỗ trợ các thiết bị BIOS đã khởi tạo BIOS
	- có thể không hoạt động trên big endian


Các tính năng được hỗ trợ
==================

* 4 chế độ màu giả bpp (với bảng màu 18bit, hai biến thể)
	* Chế độ giả màu 8 bpp (với bảng màu 18 bit)
	* Chế độ truecolor 16 bpp (RGB 555 và RGB 565)
	* Chế độ màu thật 24 bpp (RGB 888)
	* Chế độ màu thật 32 bpp (RGB 888)
	* chế độ văn bản (được kích hoạt bởi bpp = 0)
	* biến thể chế độ quét kép (không khả dụng ở chế độ văn bản)
	* xoay theo cả hai hướng
	* tạm dừng/tiếp tục hỗ trợ

Chế độ văn bản được hỗ trợ ngay cả ở độ phân giải cao hơn, nhưng có hạn chế đối với
pixclock thấp hơn (tôi đạt tối đa khoảng 70 MHz, nó phụ thuộc vào cụ thể
phần cứng). Giới hạn này không được thực thi bởi trình điều khiển. Chế độ văn bản hỗ trợ 8bit
chỉ phông chữ rộng (giới hạn phần cứng) và phông chữ cao 16 bit (trình điều khiển
hạn chế). Thật không may, các thuộc tính ký tự (như màu sắc) ở chế độ văn bản lại bị
bị hỏng không rõ lý do nên tính hữu dụng của nó bị hạn chế.

Có hai chế độ 4 bpp. Chế độ đầu tiên (được chọn nếu không chuẩn == 0) là chế độ có
pixel đóng gói, nibble cao đầu tiên. Chế độ thứ hai (được chọn nếu không chuẩn == 1) là chế độ
với các mặt phẳng xen kẽ (xen kẽ 1 byte), trước tiên là MSB. Cả hai chế độ đều hỗ trợ
Chỉ phông chữ rộng 8 bit (giới hạn trình điều khiển).

Tạm dừng/tiếp tục hoạt động trên các hệ thống khởi tạo card video trong quá trình tiếp tục và
nếu thiết bị đang hoạt động (ví dụ: được sử dụng bởi fbcon).


Thiếu tính năng
================
(bí danh danh sách TODO)

* hỗ trợ thiết bị phụ (không được khởi tạo bởi BIOS)
	* hỗ trợ endian lớn
	* Hỗ trợ DPMS
	* Hỗ trợ MMIO
	* biến thể chế độ xen kẽ
	* hỗ trợ cho độ rộng phông chữ != 8 ở chế độ 4 bpp
	* hỗ trợ chiều cao phông chữ != 16 ở chế độ văn bản
	* con trỏ phần cứng
	* đồng bộ hóa vsync
	* hỗ trợ kết nối tính năng
	* hỗ trợ tăng tốc (2D giống 8514)


Lỗi đã biết
==========

* Thuộc tính ký tự (và con trỏ) ở chế độ văn bản bị hỏng

--
Ondrej Zajicek <santiago@crfreenet.org>
