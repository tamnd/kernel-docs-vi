.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fb/ep93xx-fb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================
Trình điều khiển cho bộ điều khiển EP93xx LCD
================================

Bộ điều khiển EP93xx LCD có thể điều khiển cả màn hình máy tính để bàn tiêu chuẩn và
màn hình LCD được nhúng. Nếu bạn có một màn hình máy tính để bàn tiêu chuẩn thì bạn
có thể sử dụng cơ sở dữ liệu chế độ video tiêu chuẩn của Linux. Trong tập tin bảng của bạn::

cấu trúc tĩnh ep93xxfb_mach_info some_board_fb_info = {
		.num_modes = EP93XXFB_USE_MODEDB,
		.bpp = 16,
	};

Nếu bạn có màn hình LCD được nhúng thì bạn cần xác định video
chế độ cho nó như sau::

cấu trúc tĩnh fb_videomode some_board_video_modes[] = {
		{
			.name = "some_lcd_name",
			/* Đồng hồ pixel, hiên nhà, v.v. */
		},
	};

Lưu ý rằng giá trị đồng hồ pixel tính bằng pico-giây. Bạn có thể sử dụng
Macro KHZ2PICOS để chuyển đổi giá trị đồng hồ pixel. Hầu hết các giá trị khác
đều ở dạng đồng hồ pixel. Xem Documentation/fb/framebuffer.rst để biết thêm
chi tiết.

Cấu trúc ep93xxfb_mach_info cho bo mạch của bạn sẽ trông giống như
sau đây::

cấu trúc tĩnh ep93xxfb_mach_info some_board_fb_info = {
		.num_modes = ARRAY_SIZE(some_board_video_modes),
		.modes = some_board_video_modes,
		.default_mode = &some_board_video_modes[0],
		.bpp = 16,
	};

Thiết bị bộ đệm khung có thể được đăng ký bằng cách thêm thông tin sau vào
chức năng khởi tạo bảng của bạn::

ep93xx_register_fb(&some_board_fb_info);

Cờ thuộc tính video
=====================

Cấu trúc ep93xxfb_mach_info có trường flags có thể được sử dụng
để cấu hình bộ điều khiển. Các cờ thuộc tính video đầy đủ
được ghi lại trong phần 7 của hướng dẫn sử dụng EP93xx. Sau đây
cờ có sẵn:

==============================================================================
EP93XXFB_PCLK_FALLING Dữ liệu đồng hồ ở cạnh xuống của
				đồng hồ pixel. Mặc định là đồng hồ
				dữ liệu ở cạnh tăng.

EP93XXFB_SYNC_BLANK_HIGH Tín hiệu trống đang hoạt động ở mức cao. Bởi
				mặc định tín hiệu trống đang hoạt động ở mức thấp.

EP93XXFB_SYNC_HORIZ_HIGH Đồng bộ hóa ngang đang hoạt động ở mức cao. Bởi
				mặc định đồng bộ hóa ngang đang hoạt động ở mức thấp.

EP93XXFB_SYNC_VERT_HIGH Đồng bộ dọc đang hoạt động ở mức cao. Bởi
				mặc định đồng bộ dọc đang hoạt động ở mức cao.
==============================================================================

Địa chỉ vật lý của bộ đệm khung có thể được kiểm soát bằng cách sử dụng
cờ sau:

==========================================================================
EP93XXFB_USE_SDCSN0 Sử dụng SDCSn[0] cho bộ đệm khung. Cái này
				là cài đặt mặc định.

EP93XXFB_USE_SDCSN1 Sử dụng SDCSn[1] cho bộ đệm khung.

EP93XXFB_USE_SDCSN2 Sử dụng SDCSn[2] cho bộ đệm khung.

EP93XXFB_USE_SDCSN3 Sử dụng SDCSn[3] cho bộ đệm khung.
==========================================================================

Lệnh gọi lại nền tảng
==================

Trình điều khiển bộ đệm khung EP93xx hỗ trợ ba nền tảng tùy chọn
cuộc gọi lại: thiết lập, chia nhỏ và để trống. Chức năng thiết lập và phân tách
được gọi khi trình điều khiển bộ đệm khung được cài đặt và gỡ bỏ
tương ứng. Hàm trống được gọi bất cứ khi nào màn hình hiển thị
được để trống hoặc không được để trống.

Các thiết bị thiết lập và chia nhỏ vượt qua cấu trúc platform_device dưới dạng
một cuộc tranh luận. Cấu trúc fb_info và ep93xxfb_mach_info có thể
thu được như sau::

int tĩnh some_board_fb_setup(struct platform_device *pdev)
	{
		cấu trúc ep93xxfb_mach_info *mach_info = pdev->dev.platform_data;
		cấu trúc fb_info *fb_info = platform_get_drvdata(pdev);

/* Thiết lập bộ đệm khung cụ thể cho bảng */
	}

Cài đặt chế độ video
======================

Chế độ video được đặt bằng cú pháp sau ::

video=XRESxYRES[-BPP][@REFRESH]

Nếu trình điều khiển video EP93xx được tích hợp sẵn thì chế độ video được bật
dòng lệnh nhân Linux, ví dụ::

video=ep93xx-fb:800x600-16@60

Nếu trình điều khiển video EP93xx được xây dựng dưới dạng mô-đun thì chế độ video sẽ là
được đặt khi mô-đun được cài đặt::

modprobe ep93xx-fb video=320x240

Lỗi trang màn hình
==============

Ít nhất trên EP9315 có một lỗi silicon gây ra bit 27
VIDSCRNPAGE (độ lệch vật lý của bộ đệm khung) được buộc ở mức thấp. có
một lỗi không chính thức cho lỗi này tại::

ZZ0000ZZ

Theo mặc định, trình điều khiển bộ đệm khung EP93xx sẽ kiểm tra xem vùng vật lý được phân bổ có
địa chỉ có bit 27 được thiết lập. Nếu đúng như vậy thì bộ nhớ sẽ được giải phóng và
lỗi được trả về. Việc kiểm tra có thể bị vô hiệu hóa bằng cách thêm vào như sau
tùy chọn khi tải trình điều khiển::

ep93xx-fb.check_screenpage_bug=0

Trong một số trường hợp, có thể cấu hình lại bố cục SDRAM của bạn để
tránh lỗi này. Xem phần 13 của hướng dẫn sử dụng EP93xx để biết chi tiết.
