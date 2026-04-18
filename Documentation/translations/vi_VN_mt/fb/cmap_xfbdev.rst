.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fb/cmap_xfbdev.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
Hiểu cmap của fbdev
==========================

Những ghi chú này giải thích cách lớp dix của X sử dụng cấu trúc cmap của fbdev.

- ví dụ về các cấu trúc có liên quan trong fbdev được sử dụng cho cmap thang độ xám 3 bit::

cấu trúc fb_var_screeninfo {
	    .bits_per_pixel = 8,
	    .grayscale = 1,
	    .red = { 4, 3, 0 },
	    .green = { 0, 0, 0 },
	    .blue = { 0, 0, 0 },
    }
    cấu trúc fb_fix_screeninfo {
	    .visual = FB_VISUAL_STATIC_PSEUDOCOLOR,
    }
    vì (i = 0; i < 8; i++)
	info->cmap.red[i] = (((2*i)+1)*(0xFFFF))/16;
    memcpy(thông tin->cmap.green, thông tin->cmap.red, sizeof(u16)*8);
    memcpy(thông tin->cmap.blue, thông tin->cmap.red, sizeof(u16)*8);

- Ứng dụng X11 thực hiện những việc như sau khi thử sử dụng thang độ xám::

cho (i=0; i < 8; i++) {
	char màu sắc[64];
	bộ nhớ (colorspec,0,64);
	sprintf(colorspec, "rgb:%x/%x/%x", i*36,i*36,i*36);
	if (!XparseColor(outputDisplay, testColormap, colorspec, &wantedColor))
		printf("Không lấy được màu %s\n",colorspec);
	XAllocColor(outputDisplay, testColormap, &wantedColor);
	Grays[i] = WantColor;
    }

Ngoài ra còn có các tên tương đương như grey1..x miễn là bạn có rgb.txt.

Ở đâu đó trong chuỗi lệnh gọi của X, điều này dẫn đến lệnh gọi tới mã X xử lý
colormap. Ví dụ: Xfbdev đạt được các mục sau:

xc-011010/programs/Xserver/dix/colormap.c::

FindBestPixel(pentFirst, kích thước, prgb, kênh)

dr = (dài) pent->co.local.red - prgb->red;
  dg = (dài) pent->co.local.green - prgb->green;
  db = (dài) pent->co.local.blue - prgb->blue;
  sq = dr * dr;
  UnsignedToBigNum (sq, &sum);
  BigNumAdd (&sum, &temp, &sum);

co.local.red là các mục được đưa vào thông qua FBIOGETCMAP
trực tiếp từ info->cmap.red được liệt kê ở trên. Prgb là rgb
mà ứng dụng muốn khớp. Đoạn mã trên đang thực hiện những gì trông giống như ít nhất
chức năng khớp hình vuông. Đó là lý do tại sao các mục cmap không thể được đặt ở bên trái
ranh giới bên tay của một dải màu.
