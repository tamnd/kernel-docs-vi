.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fb/modedb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
hỗ trợ chế độ video mặc định của moddb
=================================


Hiện tại tất cả các trình điều khiển thiết bị đệm khung đều có cơ sở dữ liệu chế độ video riêng,
đó là một sự lộn xộn và lãng phí tài nguyên. Ý tưởng chính của moddb là có

- một quy trình để thăm dò các chế độ video, chế độ này có thể được sử dụng bởi tất cả bộ đệm khung
    thiết bị
  - một cơ sở dữ liệu chế độ video chung với số lượng videomode tiêu chuẩn hợp lý
    (lấy từ XFree86)
  - khả năng cung cấp cơ sở dữ liệu chế độ của riêng bạn cho phần cứng đồ họa
    cần các chế độ không chuẩn, như trình điều khiển bộ đệm khung amifb và Mac (mà
    sử dụng macmodes.c)

Khi một thiết bị đệm khung nhận được tùy chọn video= mà nó không biết, nó sẽ
coi đó là một tùy chọn chế độ video. Nếu không có thiết bị đệm khung nào được chỉ định
trong tùy chọn video=, fbmem coi đó là tùy chọn chế độ video chung.

Bộ xác định chế độ hợp lệ (đối số mode_option)::

<xres>x<yres>[M][R][-<bpp>][@<refresh>][i][m][eDd]
    <name>[-<bpp>][@<refresh>]

với các số thập phân <xres>, <yres>, <bpp> và <refresh> và <name> một chuỗi.
Những điều giữa dấu ngoặc vuông là tùy chọn.

Tên hợp lệ là::

- NSTC: đầu ra 480i, với chế độ TV CCIR System-M và mã hóa màu NTSC
  - NTSC-J: đầu ra 480i, với chế độ TV CCIR System-M, màu NTSC
    mã hóa và mức độ đen bằng mức độ trống.
  - Đầu ra PAL: 576i, với chế độ TV CCIR System-B và mã hóa màu PAL
  - PAL-M: đầu ra 480i, với chế độ TV CCIR System-M và mã hóa màu PAL

Nếu 'M' được chỉ định trong đối số mode_option (sau <yres> và trước
<bpp> và <refresh>, nếu được chỉ định), thời gian sẽ được tính bằng cách sử dụng
VESA(TM) Thời gian video phối hợp thay vì tra cứu chế độ từ bảng.
Nếu 'R' được chỉ định, hãy thực hiện phép tính 'giảm khoảng trống' cho màn hình kỹ thuật số.
Nếu 'i' được chỉ định, hãy tính toán cho chế độ xen kẽ.  Và nếu 'm' là
được chỉ định, hãy thêm lề vào phép tính (1,8% xres được làm tròn xuống 8
pixel và 1,8% số năm).

Cách sử dụng mẫu: 1024x768M@60m - Thời gian CVT có lề

Trình điều khiển DRM cũng thêm các tùy chọn để bật hoặc tắt đầu ra:

'e' sẽ buộc bật màn hình, tức là nó sẽ ghi đè phát hiện
nếu một màn hình được kết nối. 'D' sẽ buộc màn hình được bật và sử dụng
đầu ra kỹ thuật số. Điều này hữu ích cho các đầu ra có cả analog và kỹ thuật số
tín hiệu (ví dụ HDMI và DVI-I). Đối với các đầu ra khác, nó hoạt động giống như 'e'. Nếu 'd'
được chỉ định thì đầu ra bị vô hiệu hóa.

Ngoài ra, bạn có thể chỉ định đầu ra nào phù hợp với các tùy chọn.
Để buộc bật đầu ra VGA và điều khiển một chế độ cụ thể, hãy nói::

video=VGA-1:1280x1024@60me

Có thể chỉ định tùy chọn nhiều lần cho các cổng khác nhau, ví dụ::

video=LVDS-1:d video=HDMI-1:D

Các tùy chọn cũng có thể được chuyển sau chế độ này, sử dụng dấu phẩy làm dấu phân cách.

Cách sử dụng mẫu: chế độ 720x480,rotate=180 - 720x480, xoay 180 độ

Các tùy chọn hợp lệ là::

- lề_top, lề_bottom, lề_left, lề_right (số nguyên):
    Số lượng pixel ở lề, thường để xử lý tình trạng quét quá mức trên TV
  - Reflect_x(boolean): Thực hiện đối xứng trục trên trục X
  - Reflect_y(boolean): Thực hiện đối xứng trục trên trục Y
  - xoay (số nguyên): Xoay bộ đệm khung ban đầu theo x
    độ. Các giá trị hợp lệ là 0, 90, 180 và 270.
  - tv_mode: Chế độ truyền hình Analog. Một trong các "NTSC", "NTSC-443", "NTSC-J", "PAL",
    "PAL-M", "PAL-N" hoặc "SECAM".
  - panel_orientation, một trong những "bình thường", "upside_down", "left_side_up" hoặc
    "right_side_up". Chỉ dành cho trình điều khiển KMS, điều này sẽ đặt "hướng bảng điều khiển"
    thuộc tính trên trình kết nối km làm gợi ý cho người dùng km.


-----------------------------------------------------------------------------

Thời gian video phối hợp VESA(TM) (CVT) là gì?
=====================================================

Từ trang web VESA(TM):

"Mục đích của CVT là cung cấp một phương pháp tạo ra sự nhất quán
      và tập hợp các định dạng tiêu chuẩn, tốc độ làm mới màn hình và
      thông số kỹ thuật về thời gian cho các sản phẩm màn hình máy tính, cả những sản phẩm đó
      sử dụng CRT và những công nghệ sử dụng công nghệ hiển thị khác. các
      mục đích của CVT là cung cấp cho cả nhà sản xuất nguồn và màn hình một
      bộ công cụ chung để cho phép phát triển thời gian mới theo cách
      cách nhất quán để đảm bảo khả năng tương thích cao hơn."

Đây là tiêu chuẩn thứ ba được VESA(TM) phê duyệt liên quan đến thời gian video.  các
đầu tiên là Định giờ video rời rạc (DVT), là tập hợp các
các chế độ được xác định trước được phê duyệt bởi VESA(TM).  Thứ hai là Thời gian tổng quát
Công thức (GTF) là một thuật toán để tính toán thời gian, cho trước
pixelclock, tần số đồng bộ hóa theo chiều ngang hoặc tốc độ làm mới theo chiều dọc.

GTF bị hạn chế bởi thực tế là nó được thiết kế chủ yếu cho màn hình CRT.
Nó tăng pixelclock một cách giả tạo vì khả năng xóa trống cao
yêu cầu. Điều này không phù hợp với giao diện hiển thị kỹ thuật số có độ phân giải cao.
tốc độ dữ liệu yêu cầu nó bảo tồn pixelclock càng nhiều càng tốt.
Ngoài ra, GTF không tính đến tỷ lệ khung hình của màn hình.

CVT giải quyết những hạn chế này.  Nếu được sử dụng với CRT, công thức được sử dụng
là một dẫn xuất của GTF với một vài sửa đổi.  Nếu sử dụng với kỹ thuật số
hiển thị, có thể sử dụng phép tính "giảm khoảng trống".

Từ góc độ hệ thống con bộ đệm khung, không cần thêm các định dạng mới
vào cơ sở dữ liệu chế độ chung bất cứ khi nào một chế độ mới được phát hành bằng màn hình
các nhà sản xuất. Việc chỉ định cho CVT sẽ hoạt động tương đối với hầu hết, nếu không nói là tất cả.
các màn hình CRT mới và có thể phù hợp với hầu hết các màn hình phẳng, nếu 'giảm khoảng trống'
tính toán được chỉ định.  (Khả năng tương thích CVT của màn hình có thể
được xác định từ EDID của nó. Phiên bản 1.3 của EDID có thêm 128 byte
các khối nơi đặt thông tin thời gian bổ sung.  Tính đến thời điểm này, có
chưa có hỗ trợ nào trong lớp để phân tích các khối bổ sung này.)

CVT cũng giới thiệu một quy ước đặt tên mới (có thể xem từ đầu ra dmesg)::

<pix>M<a>[-R]

trong đó: pix = tổng số pixel tính bằng MB (xres x yres)
	   M = luôn hiện diện
	   a = tỷ lệ khung hình (3 - 4:3; 4 - 5:4; 9 - 15:9, 16:9; A - 16:10)
	  -R = giảm khoảng trống

ví dụ: .48M3-R - 800x600 với khả năng xóa trống giảm

Lưu ý: VESA(TM) có các hạn chế về thời gian CVT tiêu chuẩn:

- tỷ lệ khung hình chỉ có thể là một trong các giá trị trên
      - tốc độ làm mới chấp nhận được chỉ là 50, 60, 70 hoặc 85 Hz
      - nếu giảm khoảng trống, tốc độ làm mới phải ở mức 60Hz

Nếu một trong những điều trên không được thỏa mãn, kernel sẽ in cảnh báo nhưng
thời gian vẫn sẽ được tính toán.

-----------------------------------------------------------------------------

Để tìm chế độ video phù hợp, bạn chỉ cần gọi::

int __init fb_find_mode(struct fb_var_screeninfo *var,
			  cấu trúc fb_info *info, const char *mode_option,
			  const struct fb_videomode *db, unsigned int dbsize,
			  const struct fb_videomode *default_mode,
			  unsigned int default_bpp)

với db/dbsize cơ sở dữ liệu chế độ video không chuẩn của bạn hoặc NULL để sử dụng
cơ sở dữ liệu chế độ video tiêu chuẩn.

fb_find_mode() trước tiên hãy thử chế độ video được chỉ định (hoặc bất kỳ chế độ nào phù hợp,
ví dụ: có thể có nhiều chế độ 640x480, mỗi chế độ đều được thử). Nếu đó
không thành công, chế độ mặc định sẽ được thử. Nếu thất bại, nó sẽ chuyển qua tất cả các chế độ.

Để chỉ định chế độ video khi khởi động, hãy sử dụng các tùy chọn khởi động sau::

video=<driver>:<xres>x<yres>[-<bpp>][@refresh]

trong đó <driver> là tên trong bảng bên dưới.  Các chế độ mặc định hợp lệ có thể
được tìm thấy trong driver/video/fbdev/core/modedb.c.  Kiểm tra tài liệu lái xe của bạn.
Có thể có nhiều chế độ hơn::

Trình điều khiển hỗ trợ tùy chọn khởi động modem
    Thẻ tên khởi động được hỗ trợ

amifb - Bộ đệm khung chipset Amiga
    aty128fb - Bộ đệm khung ATI Rage128 / Pro
    atyfb - Bộ đệm khung ATI Mach64
    pm2fb - Bộ đệm khung Permedia 2/2V
    pm3fb - Bộ đệm khung Permedia 3
    sstfb - Bộ đệm khung chipset Voodoo 1/2 (SST1)
    tdfxfb - Bộ đệm khung 3D Fx
    tridentfb - Bộ đệm khung chipset lưỡi Trident (Cyber)
    vt8623fb - Bộ đệm khung VIA 8623

BTW, hiện tại chỉ có một số trình điều khiển fb sử dụng tính năng này. Những người khác sẽ làm theo
(vui lòng gửi bản vá). Trình điều khiển DRM cũng hỗ trợ điều này.
