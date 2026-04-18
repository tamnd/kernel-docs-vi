.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fb/intel810.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================================
Trình điều khiển bộ đệm khung Intel 810/815
===========================================

Tony Daplas <adaplas@pol.net>

ZZ0000ZZ

Ngày 17 tháng 3 năm 2002

Phát hành lần đầu: Tháng 7 năm 2001
Cập nhật lần cuối: ngày 12 tháng 9 năm 2005

A. Giới thiệu
===============

Đây là trình điều khiển bộ đệm khung cho nhiều loại tương thích Intel 810/815
	các thiết bị đồ họa.  Chúng bao gồm:

- Intel 810
	- Intel 810E
	-Intel 810-DC100
	- Chỉ đồ họa bên trong Intel 815, 100Mhz FSB
	- Chỉ đồ họa nội bộ Intel 815
	- Đồ họa nội bộ Intel 815 và AGP

B. Tính năng
============

- Lựa chọn sử dụng Định giờ video rời rạc, Định giờ tổng quát VESA
	  Công thức hoặc cơ sở dữ liệu cụ thể về bộ đệm khung để đặt chế độ video

- Hỗ trợ nhiều loại độ phân giải ngang và dọc và
	  tốc độ làm mới theo chiều dọc nếu Công thức tính thời gian tổng quát VESA là
	  đã bật.

- Hỗ trợ độ sâu màu 8, 16, 24 và 32 bit cho mỗi pixel

- Hỗ trợ hình ảnh giả màu, màu trực tiếp hoặc màu thật

- Tăng tốc phần cứng đầy đủ và tối ưu ở mức 8, 16 và 24 bpp

- Lưu và khôi phục trạng thái video mạnh mẽ

- Hỗ trợ MTRR

- Sử dụng thông số kỹ thuật màn hình do người dùng nhập để tự động
	  tính toán các thông số chế độ video cần thiết.

- Có thể chạy đồng thời với xfree86 chạy với driver i810 gốc

- Hỗ trợ con trỏ phần cứng

- Hỗ trợ thăm dò EDID bằng DDC/I2C hoặc thông qua BIOS

C. Danh sách các tùy chọn có sẵn
=============================

Một. "video=i810fb"
	kích hoạt trình điều khiển i810

Khuyến nghị: bắt buộc

b. "xres:<giá trị>"
	chọn độ phân giải ngang tính bằng pixel. (Thông số này sẽ được
	bị bỏ qua nếu 'mode_option' được chỉ định.  Xem 'o' bên dưới).

Khuyến nghị: sở thích của người dùng
	(mặc định = 640)

c. "yres:<value>"
	chọn độ phân giải dọc trong dòng quét. Nếu thời gian video rời rạc
	được bật, giá trị này sẽ bị bỏ qua và được tính là 3*xres/4.  (Cái này
	tham số sẽ bị bỏ qua nếu 'mode_option' được chỉ định.  Xem 'o'
	bên dưới)

Khuyến nghị: sở thích của người dùng
	(mặc định = 480)

d. "vyres:<giá trị>"
	chọn độ phân giải dọc ảo trong dòng quét. Nếu (0) hoặc không có
	được chỉ định, điều này sẽ được tính toán dựa trên bộ nhớ khả dụng tối đa.

Khuyến nghị: không đặt
	(mặc định = 480)

đ. "vram:<giá trị>"
	chọn dung lượng hệ thống RAM tính bằng MB để phân bổ cho bộ nhớ video

Khuyến nghị: 1 - 4 MB.
	(mặc định = 4)

f. "bpp:<giá trị>"
	chọn độ sâu pixel mong muốn

Khuyến nghị: 8
	(mặc định = 8)

g. "hsync1/hsync2:<giá trị>"
	chọn Tần số đồng bộ ngang tối thiểu và tối đa của
	giám sát bằng kHz.  Nếu sử dụng màn hình tần số cố định, hsync1 phải
	bằng hsync2. Nếu việc thăm dò EDID thành công, đây sẽ là
	bị bỏ qua và các giá trị sẽ được lấy từ khối EDID.

Khuyến nghị: kiểm tra hướng dẫn sử dụng màn hình để biết giá trị chính xác
	(mặc định = 29/30)

h. "vsync1/vsync2:<giá trị>"
	chọn Tần số đồng bộ dọc tối thiểu và tối đa của màn hình
	tính bằng Hz. Bạn cũng có thể sử dụng tùy chọn này để khóa quá trình làm mới màn hình của mình
	tỷ lệ. Nếu việc thăm dò EDID thành công, những giá trị này sẽ bị bỏ qua và
	sẽ được lấy từ khối EDID.

Khuyến nghị: kiểm tra hướng dẫn sử dụng màn hình để biết giá trị chính xác
	(mặc định = 60/60)

IMPORTANT: Nếu bạn cần kiểm soát thời gian của mình, hãy thử đưa ra một số
	mất nhiều thời gian cho các lỗi tính toán (tràn/tràn).  Ví dụ: nếu
	sử dụng vsync1/vsync2 = 60/60, đảm bảo hsync1/hsync2 có ít nhất
	chênh lệch 1 đơn vị và ngược lại.

Tôi. "voffset:<value>"
	chọn mức chênh lệch tính bằng MB của bộ nhớ logic để phân bổ
	bộ nhớ đệm khung.  Mục đích là để tránh các khối bộ nhớ
	được sử dụng bởi các ứng dụng đồ họa tiêu chuẩn (XFree86).  Mặc định
	offset (16 MB cho khẩu độ 64 MB, 8 MB cho khẩu độ 32 MB) sẽ
	tránh sử dụng XFree86 và cho phép bộ đệm khung lên tới 7 MB/15 MB
	trí nhớ.  Tùy theo nhu cầu sử dụng mà điều chỉnh giá trị lên hoặc xuống
	(0 cho mức sử dụng tối đa, 31/63 MB cho mức sử dụng ít nhất).  Lưu ý, một
	cài đặt tùy ý có thể xung đột với XFree86.

Khuyến nghị: không đặt
	(mặc định = 8 hoặc 16 MB)

j. "tăng tốc"
	cho phép tăng tốc văn bản.  Điều này có thể được kích hoạt/kích hoạt lại bất cứ lúc nào
	bằng cách sử dụng 'fbset -accel true/false'.

Khuyến nghị: kích hoạt
	(mặc định = chưa được đặt)

k. "mtrr"
	kích hoạt MTRR.  Điều này cho phép truyền dữ liệu vào bộ nhớ đệm khung
	xảy ra theo đợt có thể làm tăng đáng kể hiệu suất.
	Không hữu ích lắm với i810/i815 vì 'bộ nhớ dùng chung'.

Khuyến nghị: không đặt
	(mặc định = chưa được đặt)

tôi. "extvga"
	nếu được chỉ định, đầu ra VGA thứ cấp/bên ngoài sẽ luôn được bật.
	Hữu ích nếu BIOS tắt cổng VGA khi không gắn màn hình.
	Sau đó, màn hình VGA bên ngoài có thể được gắn mà không cần khởi động lại.

Khuyến nghị: không đặt
	(mặc định = chưa được đặt)

m. "đồng bộ"
	Buộc công cụ phần cứng thực hiện "đồng bộ hóa" hoặc đợi phần cứng
	để kết thúc trước khi bắt đầu một lệnh khác. Điều này sẽ tạo ra một
	thiết lập ổn định hơn, nhưng sẽ chậm hơn.

Khuyến nghị: không đặt
	(mặc định = chưa được đặt)

N. "dcolor"
	Sử dụng directcolor visual thay vì truecolor để có độ sâu pixel lớn hơn
	hơn 8 bpp.  Hữu ích cho việc điều chỉnh màu sắc, chẳng hạn như kiểm soát gamma.

Khuyến nghị: không đặt
	(mặc định = chưa được đặt)

ồ. <xres>x<yres>[-<bpp>][@<refresh>]
	Trình điều khiển bây giờ sẽ chấp nhận đặc điểm kỹ thuật của tùy chọn chế độ khởi động.  Nếu điều này
	được chỉ định, các tùy chọn 'xres' và 'yres' sẽ bị bỏ qua. Xem
	Tài liệu/fb/modeb.rst để sử dụng.

D. Khởi động hạt nhân
=================

Phân tách từng tùy chọn/cặp tùy chọn bằng dấu phẩy (,) và tùy chọn khỏi giá trị của nó
bằng dấu hai chấm (:) như sau::

video=i810fb:option1,option2:value2

Cách sử dụng mẫu
------------

Trong /etc/lilo.conf, thêm dòng::

chắp thêm="video=i810fb:vram:2,xres:1024,yres:768,bpp:8,hsync1:30,hsync2:55, \
	  vsync1:50,vsync2:85,accel,mtrr"

Điều này sẽ khởi tạo bộ đệm khung thành 1024x768 ở tốc độ 8bpp.  Bộ đệm khung
sẽ sử dụng 2 MB của Hệ thống RAM. Hỗ trợ MTRR sẽ được kích hoạt. Tốc độ làm mới
sẽ được tính toán dựa trên các giá trị hsync1/hsync2 và vsync1/vsync2.

IMPORTANT:
  Bạn phải bao gồm hsync1, hsync2, vsync1 và vsync2 để bật chế độ video
  tốt hơn 640x480 ở 60Hz. HOWEVER, nếu kết hợp chipset/màn hình của bạn
  hỗ trợ I2C và có khối EDID, bạn có thể loại trừ hsync1, hsync2,
  thông số vsync1 và vsync2.  Các thông số này sẽ được lấy từ EDID
  khối.

E. Tùy chọn mô-đun
==================

Các tham số module về cơ bản giống với kernel
các thông số. Sự khác biệt chính là bạn cần bao gồm giá trị Boolean
(1 cho TRUE và 0 cho FALSE) cho những tùy chọn không cần giá trị.

Ví dụ: để bật MTRR, hãy bao gồm "mtrr=1".

Cách sử dụng mẫu
------------

Sử dụng thiết lập tương tự như mô tả ở trên, tải mô-đun như sau::

modprobe i810fb vram=2 xres=1024 bpp=8 hsync1=30 hsync2=55 vsync1=50 \
		 vsync2=85 tăng tốc=1 mtrr=1

Hoặc chỉ cần thêm phần sau vào tệp cấu hình trong /etc/modprobe.d/::

tùy chọn i810fb vram=2 xres=1024 bpp=16 hsync1=30 hsync2=55 vsync1=50 \
	vsync2=85 tăng tốc=1 mtrr=1

và chỉ cần làm một::

modprobe i810fb


F. Thiết lập
=========

Một. Thực hiện phương pháp cấu hình kernel thông thường của bạn

tạo menuconfig/xconfig/config

b. Trong "Tùy chọn mức độ hoàn thiện mã", hãy bật "Nhắc nhở phát triển
	   và/hoặc mã/trình điều khiển không đầy đủ".

c. Bật hỗ trợ agpgart cho đồ họa tích hợp Intel 810/815.
	   Điều này là bắt buộc.  Tùy chọn nằm trong "Thiết bị ký tự".

d. Trong "Hỗ trợ đồ họa", chọn "Intel 810/815" một cách tĩnh
	   hoặc dưới dạng mô-đun.  Chọn "sử dụng Công thức tính thời gian tổng quát VESA" nếu
	   bạn cần tối đa hóa khả năng của màn hình.  Để có mặt trên
	   bên an toàn, bạn có thể bỏ chọn mục này.

đ. Nếu bạn muốn hỗ trợ cho việc thăm dò DDC/I2C (Màn hình cắm và chạy),
	   đặt 'Bật hỗ trợ DDC' thành 'y'. Để làm cho tùy chọn này xuất hiện, hãy đặt
	   'sử dụng Công thức tính thời gian tổng quát VESA' cho 'y'.

f. Nếu bạn muốn có bảng điều khiển có bộ đệm khung, hãy bật nó trong "Bảng điều khiển
	   Trình điều khiển".

g. Biên dịch hạt nhân của bạn.

h. Tải trình điều khiển như mô tả trong phần D và E.

Tôi.  Hãy thử DirectFB (ZZ0000ZZ + i810 gfxdriver
	    vá để xem chipset đang hoạt động (hoặc không hoạt động :-).

G. Lời cảm ơn:
===================

1. Geert Uytterhoeven - tài năng và kỹ thuật ảo tuyệt vời của anh ấy
	    mã trình điều khiển bộ đệm khung đã thực hiện được điều này.

2. Jeff Hartmann vì mã agpgart của anh ấy.

3. Các nhà phát triển X.  Thông tin chi tiết được cung cấp chỉ bằng cách đọc
	    Mã nguồn XFree86.

4. Intel(c).  Đối với trình điều khiển chipset định hướng giá trị này và đối với
	    cung cấp tài liệu.

5. Matt Sottek.  Những đóng góp và ý tưởng của ông đã giúp thực hiện một số
	   tối ưu hóa có thể.

H. Trang chủ:
==============

Thông tin đầy đủ hơn và có thể cập nhật được cung cấp tại
	ZZ0000ZZ

Tony
