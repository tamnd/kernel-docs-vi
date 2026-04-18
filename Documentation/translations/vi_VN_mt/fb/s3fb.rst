.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fb/s3fb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===============================================
s3fb - trình điều khiển fbdev cho chip S3 Trio/Virge
===========================================


Phần cứng được hỗ trợ
==================

Bộ ba S332
	S3 Trio64 (và các biến thể V+, UV+, V2/DX, V2/GX)
	S3 Virge (và các biến thể VX, DX, GX và GX2+)
	S3 Plato/PX (hoàn toàn chưa được kiểm tra)
	S3 Aurora64V+ (hoàn toàn chưa được kiểm tra)

- chỉ hỗ trợ xe buýt PCI
	- chỉ hỗ trợ các thiết bị VGA đã khởi tạo BIOS
	- có thể không hoạt động trên big endian

Tôi đã thử nghiệm s3fb trên Trio64 (trơn, V+ và V2/DX) và Virge (trơn, VX, DX),
tất cả trên i386.


Các tính năng được hỗ trợ
==================

* 4 chế độ màu giả bpp (với bảng màu 18bit, hai biến thể)
	* Chế độ giả màu 8 bpp (với bảng màu 18 bit)
	* Chế độ truecolor 16 bpp (RGB 555 và RGB 565)
	* Bật chế độ truecolor 24 bpp (RGB 888) (chỉ trên Virge VX)
	* Bật chế độ truecolor 32 bpp (RGB 888) (không phải trên Virge VX)
	* chế độ văn bản (được kích hoạt bởi bpp = 0)
	* biến thể chế độ xen kẽ (không có sẵn ở chế độ văn bản)
	* biến thể chế độ quét kép (không khả dụng ở chế độ văn bản)
	* xoay theo cả hai hướng
	* tạm dừng/tiếp tục hỗ trợ
	* Hỗ trợ DPMS

Chế độ văn bản được hỗ trợ ngay cả ở độ phân giải cao hơn, nhưng có hạn chế đối với
pixclock thấp hơn (thường tối đa là từ 50-60 MHz, tùy thuộc vào từng loại cụ thể)
phần cứng, tôi nhận được kết quả tốt nhất từ thẻ S3 Trio32 đơn giản - khoảng 75 MHz). Cái này
giới hạn không được thực thi bởi trình điều khiển. Chế độ văn bản chỉ hỗ trợ phông chữ rộng 8 bit
(giới hạn phần cứng) và phông chữ cao 16bit (giới hạn trình điều khiển). Chế độ văn bản
hỗ trợ bị hỏng trên S3 Trio64 V2/DX.

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
	* Hỗ trợ xe buýt Zorro
	* Hỗ trợ MMIO
	* Hỗ trợ chế độ 24 bpp trên nhiều thẻ hơn
	* hỗ trợ cho độ rộng phông chữ != 8 ở chế độ 4 bpp
	* hỗ trợ chiều cao phông chữ != 16 ở chế độ văn bản
	* đồng bộ hóa tổng hợp và bên ngoài (có ai có thể kiểm tra điều này không?)
	* con trỏ phần cứng
	* hỗ trợ lớp phủ video
	* đồng bộ hóa vsync
	* hỗ trợ kết nối tính năng
	* hỗ trợ tăng tốc (chuyển 2D, Virge 3D, busmaster giống như 8514)
	* giá trị tốt hơn cho một số thanh ghi ma thuật (vấn đề về hiệu suất)


Lỗi đã biết
==========

* vô hiệu hóa con trỏ ở chế độ văn bản không hoạt động
	* Chế độ văn bản bị hỏng trên S3 Trio64 V2/DX


--
Ondrej Zajicek <santiago@crfreenet.org>
