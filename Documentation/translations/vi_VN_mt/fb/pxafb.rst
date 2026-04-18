.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fb/pxafb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================
Trình điều khiển cho bộ điều khiển PXA25x LCD
=============================================

Trình điều khiển hỗ trợ các tùy chọn sau, thông qua
options=<OPTIONS> khi ở chế độ mô-đun hoặc video=pxafb:<OPTIONS> khi được tích hợp sẵn.

Ví dụ::

tùy chọn modprobe pxafb=vmem:2M,chế độ:640x480-8,thụ động

hoặc trên dòng lệnh kernel ::

video=pxafb:vmem:2M,chế độ:640x480-8,thụ động

vmem: VIDEO_MEM_SIZE

Dung lượng bộ nhớ video cần phân bổ (có thể gắn với K hoặc M
	cho kilobyte hoặc megabyte)

chế độ:XRESxYRES[-BPP]

XRES == LCCR1_PPL + 1

YRES == LLCR2_LPP + 1

Độ phân giải của màn hình tính bằng pixel

BPP == Độ sâu bit. Các giá trị hợp lệ là 1, 2, 4, 8 và 16.

đồng hồ điểm ảnh:PIXCLOCK

Đồng hồ pixel tính bằng pico giây

trái:LEFT == LCCR1_BLW + 1

đúng:RIGHT == LCCR1_ELW + 1

hsynclen:HSYNC == LCCR1_HSW + 1

phía trên:UPPER == LCCR2_BFW

thấp hơn:LOWER == LCCR2_EFR

vsynclen:VSYNC == LCCR2_VSW + 1

Hiển thị lề và thời gian đồng bộ

màu sắc | đơn sắc => LCCR0_CMS

ừm...

hoạt động | bị động => LCCR0_PAS

Hiển thị chủ động (TFT) hoặc thụ động (STN)

độc thân | kép => LCCR0_SDS

Màn hình thụ động bảng đơn hoặc kép

4 điểm ảnh | 8pix => LCCR0_DPD

Dữ liệu bảng đơn đơn sắc 4 hoặc 8 pixel

hsync:HSYNC, vsync:VSYNC

Đồng bộ ngang và dọc. 0 => hoạt động ở mức thấp, 1 => hoạt động
	cao.

dpc:DPC

Đồng hồ pixel đôi. 1=>đúng, 0=>sai

đầu ra:POLARITY

Đầu ra cho phép phân cực. 0 => hoạt động ở mức thấp, 1 => hoạt động ở mức cao

pixclockpol:POLARITY

phân cực đồng hồ pixel
	0 => cạnh giảm, 1 => cạnh tăng


Hỗ trợ lớp phủ cho bộ điều khiển PXA27x và LCD mới hơn
====================================================

Bộ xử lý PXA27x và mới hơn hỗ trợ lớp phủ1 và lớp phủ2 ở trên cùng của
  bộ đệm khung cơ sở (mặc dù cũng có thể ở bên dưới cơ sở). Họ
  hỗ trợ các định dạng RGB bảng màu và không bảng màu, cũng như các định dạng YUV (chỉ
  có sẵn trên lớp phủ2). Các lớp phủ này có các kênh DMA chuyên dụng và
  hoạt động theo cách tương tự như bộ đệm khung.

Tuy nhiên, có một số khác biệt giữa các bộ đệm khung lớp phủ này
  và bộ đệm khung thông thường, như được liệt kê dưới đây:

1. lớp phủ có thể bắt đầu ở vị trí căn chỉnh từ 32 bit trong cơ sở
     bộ đệm khung, nghĩa là chúng có điểm bắt đầu (x, y). Thông tin này
     được mã hóa thành var->nonstd (không, var->xoffset và var->yoffset là
     không nhằm mục đích đó).

2. Bộ đệm khung lớp phủ được phân bổ động theo quy định
     'struct fb_var_screeninfo', số tiền được quyết định bởi::

var->xres_virtual * var->yres_virtual * bpp

bpp = 16 -- đối với RGB565 hoặc RGBT555

bpp = 24 -- đối với YUV444 được đóng gói

bpp = 24 -- đối với mặt phẳng YUV444

bpp = 16 -- đối với mặt phẳng YUV422 (1 pixel = 1 Y + 1/2 Cb + 1/2 Cr)

bpp = 12 -- đối với mặt phẳng YUV420 (1 pixel = 1 Y + 1/4 Cb + 1/4 Cr)

NOTE:

Một. lớp phủ không hỗ trợ xoay theo hướng x, do đó
	var->xres_virtual sẽ luôn bằng var->xres

b. độ dài dòng của (các) lớp phủ phải nằm trên ranh giới từ 32 bit,
	đối với chế độ phẳng YUV, đó là yêu cầu đối với thành phần
	với số bit tối thiểu trên mỗi pixel, ví dụ: cho thành phần YUV420, Cr
	đối với một pixel thực tế là 2 bit, điều đó có nghĩa là độ dài dòng
	phải là bội số của 16 pixel

c. vị trí bắt đầu nằm ngang (XPOS) sẽ bắt đầu trên 32-bit
	ranh giới từ, nếu không fb_check_var() sẽ không thành công.

d. hình chữ nhật của lớp phủ phải nằm trong mặt phẳng cơ sở,
	nếu không thì thất bại

Các ứng dụng phải tuân theo trình tự bên dưới để vận hành lớp phủ
     bộ đệm khung:

Một. open("/dev/fb[1-2]", ...)
	 b. ioctl(fd, FBIOGET_VSCREENINFO, ...)
	 c. sửa đổi 'var' với các tham số mong muốn:

1) var->xres và var->yres
	    2) var->yres_virtual lớn hơn nếu cần nhiều bộ nhớ hơn,
	       thường để đệm đôi
	    3) var->nonstd để bắt đầu (x, y) và định dạng màu
	    4) var->{red, green, blue, transp} nếu chế độ RGB được sử dụng

d. ioctl(fd, FBIOPUT_VSCREENINFO, ...)
	 đ. ioctl(fd, FBIOGET_FSCREENINFO, ...)
	 f. mmap
	 g. ...

3. đối với các định dạng phẳng YUV, những định dạng này thực sự không được hỗ trợ trong
     khung đệm khung, ứng dụng phải xử lý phần bù
     và độ dài của từng thành phần trong bộ đệm khung.

4. var->nonstd được sử dụng để chuyển vị trí bắt đầu (x, y) và định dạng màu,
     các trường bit chi tiết được hiển thị bên dưới::

31 23 20 10 0
       +--------+---+----------+----------+
       ZZ0000ZZFORZZ0001ZZ YPOS |
       +--------+---+----------+----------+

FOR - định dạng màu, như được xác định bởi OVERLAY_FORMAT_* trong pxafb.h

- 0 - RGB
	  -1-YUV444 PACKED
	  - 2 - YUV444 PLANAR
	  - 3 - YUV422 PLANAR
	  - 4 - YUR420 PLANAR

XPOS - vị trí bắt đầu nằm ngang

YPOS - vị trí bắt đầu thẳng đứng
