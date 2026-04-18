.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fb/api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Thiết bị đệm khung API
==============================

Sửa đổi lần cuối: ngày 21 tháng 6 năm 2011


0. Giới thiệu
---------------

Tài liệu này mô tả bộ đệm khung API được các ứng dụng sử dụng để tương tác
với các thiết bị đệm khung. API trong hạt nhân giữa trình điều khiển thiết bị và khung
lõi đệm không được mô tả.

Do thiếu tài liệu trong bộ đệm khung gốc API, trình điều khiển
hành vi khác nhau theo những cách tinh tế (và không quá tinh tế). Tài liệu này mô tả
triển khai API được đề xuất, nhưng các ứng dụng nên được chuẩn bị để
xử lý các hành vi khác nhau.


1. Khả năng
---------------

Khả năng của thiết bị và trình điều khiển được báo cáo trong thông tin màn hình cố định
lĩnh vực năng lực::

cấu trúc fb_fix_screeninfo {
	...
__u16 khả năng;		/* xem FB_CAP_* */
	...
  };

Ứng dụng nên sử dụng những khả năng đó để tìm hiểu xem chúng có thể sử dụng những tính năng nào
mong đợi từ thiết bị và trình điều khiển.

-FB_CAP_FOURCC

Trình điều khiển hỗ trợ cài đặt định dạng dựa trên mã bốn ký tự (FOURCC) API.
Khi được hỗ trợ, các định dạng được định cấu hình bằng FOURCC thay vì thủ công
chỉ định bố cục thành phần màu.


2. Thể loại và hình ảnh
--------------------

Các pixel được lưu trữ trong bộ nhớ ở các định dạng phụ thuộc vào phần cứng. Ứng dụng cần
biết về định dạng lưu trữ pixel để ghi dữ liệu hình ảnh vào
bộ nhớ đệm khung theo định dạng mà phần cứng mong đợi.

Các định dạng được mô tả bằng loại bộ đệm khung và hình ảnh. Một số hình ảnh yêu cầu
thông tin bổ sung, được lưu trữ trong thông tin màn hình biến
các trường bit_per_pixel, thang độ xám, đỏ, lục, lam và xuyên.

Hình ảnh mô tả cách thông tin màu sắc được mã hóa và tập hợp để tạo ra
macropixel. Các loại mô tả cách macropixel được lưu trữ trong bộ nhớ. Sau đây
các loại và hình ảnh được hỗ trợ.

-FB_TYPE_PACKED_PIXELS

Macropixel được lưu trữ liên tục trong một mặt phẳng. Nếu số bit
mỗi macropixel không phải là bội số của 8, cho dù macropixel có được đệm vào hay không
bội số tiếp theo của 8 bit hoặc được đóng gói thành byte tùy thuộc vào hình ảnh.

Phần đệm ở cuối dòng có thể xuất hiện và sau đó được báo cáo thông qua phần cố định
thông tin màn hình trường line_length.

-FB_TYPE_PLANES

Macropixel được chia thành nhiều mặt phẳng. Số mặt phẳng bằng
số bit trên mỗi macropixel, với mặt phẳng thứ i lưu trữ bit thứ i từ tất cả
macropixel.

Các mặt phẳng được đặt liền kề trong bộ nhớ.

-FB_TYPE_INTERLEAVED_PLANES

Macropixel được chia thành nhiều mặt phẳng. Số mặt phẳng bằng
số bit trên mỗi macropixel, với mặt phẳng thứ i lưu trữ bit thứ i từ tất cả
macropixel.

Các mặt phẳng được xen kẽ trong bộ nhớ. Hệ số xen kẽ, được định nghĩa là
khoảng cách tính bằng byte giữa điểm bắt đầu của hai khối xen kẽ liên tiếp
thuộc các mặt phẳng khác nhau, được lưu trữ trong thông tin màn hình cố định
trường type_aux.

-FB_TYPE_FOURCC

Macropixel được lưu trữ trong bộ nhớ như được mô tả bởi định dạng FOURCC
được lưu trữ trong trường thang độ xám thông tin màn hình thay đổi.

-FB_VISUAL_MONO01

Các pixel có màu đen hoặc trắng và được lưu trữ trên một số bit (thường là một)
được chỉ định bởi trường bpp thông tin màn hình biến đổi.

Pixel đen được biểu thị bằng tất cả các bit được đặt thành 1 và pixel trắng được biểu thị bằng tất cả các bit
được đặt thành 0. Khi số bit trên mỗi pixel nhỏ hơn 8, một vài pixel
được đóng gói cùng nhau trong một byte.

FB_VISUAL_MONO01 hiện chỉ được sử dụng với FB_TYPE_PACKED_PIXELS.

-FB_VISUAL_MONO10

Các pixel có màu đen hoặc trắng và được lưu trữ trên một số bit (thường là một)
được chỉ định bởi trường bpp thông tin màn hình biến đổi.

Pixel đen được biểu thị bằng tất cả các bit được đặt thành 0 và pixel trắng được biểu thị bằng tất cả các bit
được đặt thành 1. Khi số bit trên mỗi pixel nhỏ hơn 8, một vài pixel
được đóng gói cùng nhau trong một byte.

FB_VISUAL_MONO01 hiện chỉ được sử dụng với FB_TYPE_PACKED_PIXELS.

-FB_VISUAL_TRUECOLOR

Các điểm ảnh được chia thành các thành phần màu đỏ, lục và lam và mỗi thành phần
lập chỉ mục bảng tra cứu chỉ đọc cho giá trị tương ứng. Bảng tra cứu
phụ thuộc vào thiết bị và cung cấp các đường dốc tuyến tính hoặc phi tuyến tính.

Mỗi thành phần được lưu trữ trong một macropixel theo màn hình biến đổi
thông tin các trường màu đỏ, xanh lá cây, xanh dương và xuyên suốt.

- FB_VISUAL_PSEUDOCOLOR và FB_VISUAL_STATIC_PSEUDOCOLOR

Giá trị pixel được mã hóa dưới dạng chỉ số thành bản đồ màu lưu trữ màu đỏ, xanh lục và
thành phần màu xanh. Bản đồ màu chỉ đọc cho FB_VISUAL_STATIC_PSEUDOCOLOR
và đọc-ghi cho FB_VISUAL_PSEUDOCOLOR.

Mỗi giá trị pixel được lưu trữ theo số bit được báo cáo bởi biến
thông tin màn hình trường bit_per_pixel.

-FB_VISUAL_DIRECTCOLOR

Các điểm ảnh được chia thành các thành phần màu đỏ, lục và lam và mỗi thành phần
lập chỉ mục một bảng tra cứu có thể lập trình cho giá trị tương ứng.

Mỗi thành phần được lưu trữ trong một macropixel theo màn hình biến đổi
thông tin các trường màu đỏ, xanh lá cây, xanh dương và xuyên suốt.

-FB_VISUAL_FOURCC

Các điểm ảnh được mã hóa và diễn giải như được mô tả theo định dạng FOURCC
mã định danh được lưu trữ trong trường thang độ xám thông tin màn hình thay đổi.


3. Thông tin màn hình
---------------------

Thông tin màn hình được truy vấn bởi các ứng dụng sử dụng FBIOGET_FSCREENINFO
và FBIOGET_VSCREENINFO ioctls. Những ioctls đó đưa một con trỏ tới một
Cấu trúc fb_fix_screeninfo và fb_var_screeninfo tương ứng.

struct fb_fix_screeninfo lưu trữ thông tin không thể thay đổi độc lập với thiết bị
về thiết bị đệm khung và định dạng hiện tại. Những thông tin đó không thể
được sửa đổi trực tiếp bởi các ứng dụng, nhưng có thể được thay đổi bởi trình điều khiển khi
ứng dụng sửa đổi định dạng::

cấu trúc fb_fix_screeninfo {
	id ký tự [16];			/* chuỗi nhận dạng, ví dụ: "TT Builtin" */
	smem_start dài không dấu;	/* Bắt đầu bộ nhớ đệm khung */
					/* (địa chỉ vật lý) */
	__u32 smem_len;			/* Độ dài của bộ nhớ đệm khung */
	__u32 loại;			/* xem FB_TYPE_* */
	__u32 loại_aux;			/* Xen kẽ cho các mặt phẳng được xen kẽ */
	__u32 trực quan;			/* xem FB_VISUAL_* */
	__u16 xpanstep;			/* zero nếu không xoay phần cứng */
	__u16 ypanstep;			/* zero nếu không xoay phần cứng */
	__u16 ywrapstep;		/* zero nếu không có ywrap phần cứng */
	__u32 line_length;		/*độ dài của một dòng tính bằng byte */
	mmio_start dài không dấu;	/* Bắt đầu I/O được ánh xạ bộ nhớ */
					/* (địa chỉ vật lý) */
	__u32 mmio_len;			/* Độ dài bộ nhớ I/O được ánh xạ */
	__u32 tăng tốc;			/* Cho biết trình điều khiển nào */
					/* chip/thẻ cụ thể mà chúng tôi có */
	__u16 khả năng;		/* xem FB_CAP_* */
	__u16 dành riêng[2];		/* Dành riêng cho khả năng tương thích trong tương lai */
  };

struct fb_var_screeninfo lưu trữ thông tin có thể thay đổi độc lập với thiết bị
về thiết bị đệm khung, định dạng hiện tại và chế độ video của nó, cũng như
các thông số linh tinh khác::

cấu trúc fb_var_screeninfo {
	__u32 xres;			/*độ phân giải hiển thị */
	__u32 tuổi;
	__u32 xres_virtual;		/*độ phân giải ảo */
	__u32 năm_virtual;
	__u32 xoffset;			/* offset từ ảo sang hiển thị */
	__u32 yoffset;			/* nghị quyết			*/

__u32 bit_per_pixel;		/* đoán xem */
	__u32 thang độ xám;		/* 0 = màu, 1 = thang độ xám, */
					/* >1 = FOURCC */
	cấu trúc fb_bitfield màu đỏ;		/* bitfield trong fb mem nếu đúng màu, */
	cấu trúc fb_bitfield màu xanh lá cây;	/* nếu không thì chỉ có độ dài là đáng kể */
	cấu trúc fb_bitfield màu xanh;
	cấu trúc fb_bitfield transp;	/* trong suốt */

__u32 nonstd;			/* != 0 Định dạng pixel không chuẩn */

__u32 kích hoạt;			/* xem FB_ACTIVATE_* */

__u32 chiều cao;			/*chiều cao của ảnh tính bằng mm */
	__u32 chiều rộng;			/*Chiều rộng của ảnh tính bằng mm */

__u32 accel_flags;		/* (OBSOLETE) xem fb_info.flags */

/* Thời gian: Tất cả các giá trị tính bằng pixclock, ngoại trừ pixclock (tất nhiên) */
	__u32 pixclock;			/* đồng hồ pixel tính bằng ps (pico giây) */
	__u32 lề trái;		/*thời gian từ lúc đồng bộ sang hình ảnh */
	__u32 lề phải_lề;		/*thời gian từ lúc hình ảnh đến lúc đồng bộ */
	__u32 lề trên_lề;		/*thời gian từ lúc đồng bộ sang hình ảnh */
	__u32 low_margin;
	__u32 hsync_len;		/*độ dài đồng bộ ngang */
	__u32 vsync_len;		/*độ dài đồng bộ dọc */
	__u32 đồng bộ;			/* xem FB_SYNC_* */
	__u32 vmode;			/* xem FB_VMODE_* */
	__u32 xoay;			/* góc chúng ta xoay ngược chiều kim đồng hồ */
	__u32 không gian màu;		/* không gian màu cho các chế độ dựa trên FOURCC */
	__u32 dành riêng[4];		/* Dành riêng cho khả năng tương thích trong tương lai */
  };

Để sửa đổi thông tin biến, các ứng dụng gọi FBIOPUT_VSCREENINFO
ioctl bằng con trỏ tới cấu trúc fb_var_screeninfo. Nếu cuộc gọi là
thành công, driver sẽ cập nhật thông tin màn hình cố định tương ứng.

Thay vì điền cấu trúc fb_var_screeninfo hoàn chỉnh theo cách thủ công,
các ứng dụng nên gọi FBIOGET_VSCREENINFO ioctl và chỉ sửa đổi
lĩnh vực họ quan tâm.


4. Cấu hình định dạng
-----------------------

Các thiết bị đệm khung cung cấp hai cách để cấu hình định dạng bộ đệm khung:
API kế thừa và API dựa trên FOURCC.


API kế thừa là cấu hình định dạng bộ đệm khung duy nhất API cho
lâu dài nên được ứng dụng rộng rãi. Đó là API được đề xuất
dành cho các ứng dụng khi sử dụng định dạng RGB và thang độ xám, cũng như các định dạng kế thừa
các định dạng không chuẩn.

Để chọn định dạng, ứng dụng đặt trường fb_var_screeninfo bit_per_pixel
đến độ sâu bộ đệm khung mong muốn. Các giá trị lên tới 8 thường sẽ ánh xạ tới
hình ảnh đơn sắc, thang độ xám hoặc giả màu, mặc dù điều này không bắt buộc.

- Đối với các định dạng thang độ xám, ứng dụng đặt trường thang độ xám thành một. Màu đỏ,
  các trường màu xanh lam, xanh lục và xuyên suốt phải được ứng dụng đặt thành 0 và bị bỏ qua bởi
  trình điều khiển. Người lái xe phải điền các phần bù màu đỏ, xanh lam và xanh lục thành 0 và độ dài
  đến giá trị bit_per_pixel.

- Đối với các định dạng giả màu, ứng dụng đặt trường thang độ xám về 0. các
  các trường màu đỏ, xanh lam, xanh lục và xuyên suốt phải được đặt thành 0 bởi các ứng dụng và
  bị tài xế bỏ qua. Người lái xe phải điền các offset màu đỏ, xanh lam và xanh lục về 0
  và độ dài đến giá trị bit_per_pixel.

- Đối với định dạng truecolor và directcolor, ứng dụng đặt trường thang độ xám
  về 0 và các trường màu đỏ, xanh lam, xanh lục và xuyên suốt để mô tả bố cục của
  thành phần màu trong bộ nhớ::

cấu trúc fb_bitfield {
	__u32 bù đắp;			/* phần đầu của trường bit */
	__u32 chiều dài;			/*độ dài của trường bit */
	__u32 msb_right;		/* != 0 : Bit quan trọng nhất là */
					/*đúng rồi*/
    };

Giá trị pixel có chiều rộng bit_per_pixel và được phân chia bằng màu đỏ không chồng chéo,
  các thành phần xanh lục, xanh lam và alpha (trong suốt). Vị trí và kích thước của mỗi
  thành phần trong giá trị pixel được mô tả bằng phần bù fb_bitfield và
  trường chiều dài. Offset được tính từ bên phải.

Pixel luôn được lưu trữ dưới dạng số nguyên byte. Nếu số lượng
  số bit trên mỗi pixel không phải là bội số của 8, giá trị pixel được đệm vào giá trị tiếp theo
  bội số của 8 bit.

Sau khi cấu hình định dạng thành công, trình điều khiển sẽ cập nhật fb_fix_screeninfo
các trường loại, hình ảnh và độ dài dòng tùy thuộc vào định dạng đã chọn.


API dựa trên FOURCC thay thế mô tả định dạng bằng bốn mã ký tự
(FOURCC). FOURCC là các mã định danh trừu tượng xác định duy nhất một định dạng
mà không mô tả nó một cách rõ ràng. Đây là API duy nhất hỗ trợ YUV
các định dạng. Các trình điều khiển cũng được khuyến khích triển khai API dựa trên FOURCC cho RGB
và các định dạng thang độ xám.

Các trình điều khiển hỗ trợ API dựa trên FOURCC báo cáo khả năng này bằng cách cài đặt
bit FB_CAP_FOURCC trong trường khả năng fb_fix_screeninfo.

Các định nghĩa FOURCC nằm trong tiêu đề linux/videodev2.h. Tuy nhiên, và
mặc dù bắt đầu bằng V4L2_PIX_FMT_prefix, chúng không bị giới hạn ở V4L2
và không yêu cầu sử dụng hệ thống con V4L2. Tài liệu FOURCC là
có sẵn trong Tài liệu/userspace-api/media/v4l/pixfmt.rst.

Để chọn định dạng, các ứng dụng đặt trường thang độ xám thành FOURCC mong muốn.
Đối với các định dạng YUV, họ cũng nên chọn không gian màu thích hợp bằng cách cài đặt
trường không gian màu thành một trong các không gian màu được liệt kê trong linux/videodev2.h và
được ghi lại trong Tài liệu/userspace-api/media/v4l/colorspaces.rst.

Các trường màu đỏ, lục, lam và xuyên thấu không được sử dụng với API dựa trên FOURCC.
Vì lý do tương thích về phía trước, các ứng dụng phải loại bỏ các trường đó và
người lái xe phải bỏ qua chúng. Các giá trị khác 0 có thể có ý nghĩa trong tương lai
phần mở rộng.

Sau khi cấu hình định dạng thành công, trình điều khiển sẽ cập nhật fb_fix_screeninfo
các trường loại, hình ảnh và độ dài dòng tùy thuộc vào định dạng đã chọn. Loại
và các trường trực quan được đặt tương ứng thành FB_TYPE_FOURCC và FB_VISUAL_FOURCC.
