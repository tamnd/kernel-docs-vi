.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/control.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _control:

*************
Kiểm soát người dùng
*************

Các thiết bị thường có một số điều khiển mà người dùng có thể cài đặt như
độ sáng, độ bão hòa, v.v. sẽ được hiển thị cho người dùng
trên giao diện người dùng đồ họa. Tuy nhiên, các thiết bị khác nhau sẽ có
các biện pháp kiểm soát khác nhau có sẵn, và hơn nữa, phạm vi có thể
giá trị và giá trị mặc định sẽ khác nhau tùy theo thiết bị. các
ioctls kiểm soát cung cấp thông tin và cơ chế để tạo ra một hệ thống tốt đẹp
giao diện người dùng cho các điều khiển này sẽ hoạt động chính xác với bất kỳ
thiết bị.

Tất cả các điều khiển được truy cập bằng giá trị ID. V4L2 xác định một số ID
cho các mục đích cụ thể. Trình điều khiển cũng có thể thực hiện tùy chỉnh của riêng họ
điều khiển bằng ZZ0001ZZ [#f1]_ và các giá trị cao hơn. các
ID điều khiển được xác định trước có tiền tố ZZ0002ZZ và được liệt kê trong
ZZ0000ZZ. ID được sử dụng khi truy vấn các thuộc tính của một
điều khiển và khi nhận hoặc thiết lập giá trị hiện tại.

Nói chung các ứng dụng phải đưa ra các điều khiển cho người dùng mà không cần
giả định về mục đích của họ. Mỗi điều khiển đi kèm với một chuỗi tên
người dùng phải hiểu. Khi mục đích không trực quan
người viết trình điều khiển phải cung cấp hướng dẫn sử dụng, trình cắm giao diện người dùng
hoặc một ứng dụng bảng điều khiển cụ thể. ID được xác định trước đã được giới thiệu
để thay đổi một số điều khiển theo chương trình, ví dụ như tắt tiếng thiết bị
trong quá trình chuyển kênh.

Trình điều khiển có thể liệt kê các điều khiển khác nhau sau khi chuyển đổi dòng điện
đầu vào hoặc đầu ra video, bộ chỉnh hoặc bộ điều biến hoặc đầu vào hoặc đầu ra âm thanh.
Khác nhau về ý nghĩa của các giới hạn khác, một mặc định và hiện tại khác
giá trị, kích thước bước hoặc các mục menu khác. Điều khiển với ZZ0000ZZ nhất định
ID cũng có thể thay đổi tên và loại.

Nếu một điều khiển không áp dụng được cho cấu hình hiện tại của
thiết bị (ví dụ: nó không áp dụng cho đầu vào video hiện tại)
trình điều khiển đặt cờ ZZ0000ZZ.

Các giá trị điều khiển được lưu trữ trên toàn cầu, chúng không thay đổi khi chuyển đổi
ngoại trừ việc ở trong giới hạn được báo cáo. Họ cũng không thay đổi e. g.
khi thiết bị được mở hoặc đóng, khi tần số vô tuyến của bộ dò sóng
đã thay đổi hoặc nói chung là không bao giờ nếu không có yêu cầu ứng dụng.

V4L2 chỉ định cơ chế sự kiện để thông báo cho ứng dụng khi điều khiển
thay đổi giá trị (xem
ZZ0000ZZ, sự kiện
ZZ0001ZZ), các ứng dụng bảng điều khiển có thể muốn tận dụng điều đó
để luôn phản ánh đúng giá trị kiểm soát.

Tất cả các điều khiển đều sử dụng độ bền của máy.


.. _control-id:

ID kiểm soát
===========

ZZ0000ZZ
    ID được xác định trước đầu tiên, bằng ZZ0001ZZ.

ZZ0000ZZ
    Từ đồng nghĩa của ZZ0001ZZ.

ZZ0000ZZ ZZ0001ZZ
    Độ sáng của hình ảnh, hay chính xác hơn là mức độ màu đen.

ZZ0000ZZ ZZ0001ZZ
    Độ tương phản hình ảnh hoặc tăng độ sáng.

ZZ0000ZZ ZZ0001ZZ
    Độ bão hòa màu của hình ảnh hoặc tăng sắc độ.

ZZ0000ZZ ZZ0001ZZ
    Cân bằng màu sắc hoặc màu sắc.

ZZ0000ZZ ZZ0001ZZ
    Âm lượng tổng thể. Lưu ý một số trình điều khiển cũng cung cấp OSS hoặc ALSA
    giao diện máy trộn.

ZZ0000ZZ ZZ0001ZZ
    Cân bằng âm thanh nổi. Tối thiểu tương ứng với tất cả các cách còn lại,
    tối đa sang phải.

ZZ0000ZZ ZZ0001ZZ
    Điều chỉnh âm trầm.

ZZ0000ZZ ZZ0001ZZ
    Điều chỉnh âm thanh treble.

ZZ0000ZZ ZZ0001ZZ
    Tắt tiếng âm thanh, tôi. đ. tuy nhiên, đặt âm lượng về 0 mà không ảnh hưởng
    ZZ0002ZZ. Giống như trình điều khiển ALSA, trình điều khiển V4L2 phải tắt tiếng
    tại thời điểm tải để tránh tiếng ồn quá mức. Trên thực tế toàn bộ thiết bị
    nên được đặt lại về trạng thái tiêu thụ điện năng thấp.

ZZ0000ZZ ZZ0001ZZ
    Chế độ âm lượng (tăng âm trầm).

ZZ0000ZZ ZZ0001ZZ
    Một tên khác cho độ sáng (không phải là từ đồng nghĩa với
    ZZ0002ZZ). Kiểm soát này không được dùng nữa và không nên
    được sử dụng trong các trình điều khiển và ứng dụng mới.

ZZ0000ZZ ZZ0001ZZ
    Cân bằng trắng tự động (máy ảnh).

ZZ0000ZZ ZZ0001ZZ
    Đây là một điều khiển hành động. Khi được đặt (giá trị bị bỏ qua),
    thiết bị sẽ thực hiện cân bằng trắng và sau đó giữ cài đặt hiện tại.
    Ngược lại điều này với boolean ZZ0002ZZ,
    mà khi được kích hoạt sẽ tiếp tục điều chỉnh cân bằng trắng.

ZZ0000ZZ ZZ0001ZZ
    Cân bằng sắc độ màu đỏ.

ZZ0000ZZ ZZ0001ZZ
    Cân bằng sắc độ màu xanh.

ZZ0000ZZ ZZ0001ZZ
    Điều chỉnh gamma

ZZ0000ZZ ZZ0001ZZ
    Độ trắng cho các thiết bị có thang màu xám. Đây là từ đồng nghĩa với
    ZZ0002ZZ. Kiểm soát này không được dùng nữa và không nên
    được sử dụng trong các trình điều khiển và ứng dụng mới.

ZZ0000ZZ ZZ0001ZZ
    Độ phơi sáng (máy ảnh). [Đơn vị?]

ZZ0000ZZ ZZ0001ZZ
    Điều khiển khuếch đại/phơi sáng tự động.

ZZ0000ZZ ZZ0001ZZ
    Giành quyền kiểm soát.

Chủ yếu được sử dụng để kiểm soát mức tăng trên ví dụ: bộ điều chỉnh TV nhưng cũng bật
    webcam. Hầu hết các thiết bị chỉ kiểm soát mức tăng kỹ thuật số bằng điều khiển này
    nhưng trên một số điều này cũng có thể bao gồm cả mức tăng tương tự. Các thiết bị đó
    nhận ra sự khác biệt giữa việc sử dụng khuếch đại kỹ thuật số và tương tự
    điều khiển ZZ0000ZZ và ZZ0001ZZ.

.. _v4l2-cid-hflip:

ZZ0000ZZ ZZ0001ZZ
    Phản chiếu hình ảnh theo chiều ngang.

.. _v4l2-cid-vflip:

ZZ0000ZZ ZZ0001ZZ
    Phản chiếu hình ảnh theo chiều dọc.

.. _v4l2-power-line-frequency:

ZZ0000ZZ ZZ0001ZZ
    Bật bộ lọc tần số đường dây điện để tránh nhấp nháy. Có thể
    các giá trị cho ZZ0002ZZ là:

============================================= ==
    ZZ0000ZZ 0
    ZZ0001ZZ 1
    ZZ0002ZZ 2
    ZZ0003ZZ 3
    ============================================= ==

ZZ0000ZZ ZZ0001ZZ
    Cho phép điều khiển màu sắc tự động bằng thiết bị. Tác dụng của việc thiết lập
    ZZ0002ZZ khi điều khiển màu sắc tự động được bật
    không xác định, trình điều khiển nên bỏ qua yêu cầu đó.

ZZ0000ZZ ZZ0001ZZ
    Điều khiển này chỉ định cài đặt cân bằng trắng dưới dạng màu
    nhiệt độ ở Kelvin. Một người lái xe phải có tối thiểu 2800
    (sợi đốt) đến 6500 (ánh sáng ban ngày). Để biết thêm thông tin về màu sắc
    xem nhiệt độ
    ZZ0002ZZ.

ZZ0000ZZ ZZ0001ZZ
    Điều chỉnh bộ lọc độ sắc nét trong máy ảnh. Giá trị tối thiểu
    vô hiệu hóa các bộ lọc, giá trị cao hơn sẽ mang lại hình ảnh sắc nét hơn.

ZZ0000ZZ ZZ0001ZZ
    Điều chỉnh bù ánh sáng nền trong máy ảnh. Giá trị tối thiểu
    vô hiệu hóa bù đèn nền.

ZZ0000ZZ ZZ0001ZZ
    Điều khiển khuếch đại tự động Chroma.

ZZ0000ZZ ZZ0001ZZ
    Điều chỉnh điều khiển khuếch đại sắc độ (để sử dụng khi sắc độ AGC
    bị vô hiệu hóa).

ZZ0000ZZ ZZ0001ZZ
    Kích hoạt tính năng khử màu (tức là buộc hình ảnh đen trắng trong trường hợp
    tín hiệu video yếu).

.. _v4l2-colorfx:

ZZ0000ZZ ZZ0001ZZ
    Chọn hiệu ứng màu. Các giá trị sau được xác định:



.. tabularcolumns:: |p{5.7cm}|p{11.8cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths: 11 24

    * - ``V4L2_COLORFX_NONE``
      - Color effect is disabled.
    * - ``V4L2_COLORFX_ANTIQUE``
      - An aging (old photo) effect.
    * - ``V4L2_COLORFX_ART_FREEZE``
      - Frost color effect.
    * - ``V4L2_COLORFX_AQUA``
      - Water color, cool tone.
    * - ``V4L2_COLORFX_BW``
      - Black and white.
    * - ``V4L2_COLORFX_EMBOSS``
      - Emboss, the highlights and shadows replace light/dark boundaries
	and low contrast areas are set to a gray background.
    * - ``V4L2_COLORFX_GRASS_GREEN``
      - Grass green.
    * - ``V4L2_COLORFX_NEGATIVE``
      - Negative.
    * - ``V4L2_COLORFX_SEPIA``
      - Sepia tone.
    * - ``V4L2_COLORFX_SKETCH``
      - Sketch.
    * - ``V4L2_COLORFX_SKIN_WHITEN``
      - Skin whiten.
    * - ``V4L2_COLORFX_SKY_BLUE``
      - Sky blue.
    * - ``V4L2_COLORFX_SOLARIZATION``
      - Solarization, the image is partially reversed in tone, only color
	values above or below a certain threshold are inverted.
    * - ``V4L2_COLORFX_SILHOUETTE``
      - Silhouette (outline).
    * - ``V4L2_COLORFX_VIVID``
      - Vivid colors.
    * - ``V4L2_COLORFX_SET_CBCR``
      - The Cb and Cr chroma components are replaced by fixed coefficients
	determined by ``V4L2_CID_COLORFX_CBCR`` control.
    * - ``V4L2_COLORFX_SET_RGB``
      - The RGB components are replaced by the fixed RGB components determined
        by ``V4L2_CID_COLORFX_RGB`` control.


ZZ0000ZZ ZZ0001ZZ
    Xác định các hệ số Red, Green và Blue cho
    Hiệu ứng màu ZZ0002ZZ.
    Các bit [7:0] của giá trị 32 bit được cung cấp được hiểu là thành phần Xanh lam,
    bit [15:8] là thành phần Xanh lục, bit [23:16] là thành phần Đỏ và
    bit [31:24] phải bằng 0.

ZZ0000ZZ ZZ0001ZZ
    Xác định hệ số Cb và Cr cho ZZ0002ZZ
    hiệu ứng màu sắc. Các bit [7:0] của giá trị 32 bit được cung cấp là
    được hiểu là thành phần Cr, bit [15:8] là thành phần Cb và bit
    [31:16] phải bằng không.

ZZ0000ZZ ZZ0001ZZ
    Bật độ sáng tự động.

ZZ0001ZZ ZZ0002ZZ
    Xoay hình ảnh theo góc được chỉ định. Các góc chung là 90, 270 và
    180. Xoay ảnh về 90 và 270 sẽ đảo chiều cao và
    chiều rộng của cửa sổ hiển thị. Cần thiết lập chiều cao mới
    và chiều rộng của hình ảnh bằng cách sử dụng
    ZZ0000ZZ ioctl theo
    góc quay đã chọn.

ZZ0000ZZ ZZ0001ZZ
    Đặt màu nền trên thiết bị đầu ra hiện tại. Nền
    màu sắc cần được chỉ định ở định dạng RGB24. 32 bit được cung cấp
    giá trị được hiểu là bit 0-7 Thông tin màu đỏ, bit 8-15
    Thông tin màu xanh lục, bit 16-23 Thông tin và bit màu xanh lam
    24-31 phải bằng 0.

ZZ0000ZZ ZZ0001ZZ
    Bật hoặc tắt đèn 1 hoặc 2 của thiết bị (thường là đèn
    kính hiển vi).

ZZ0000ZZ ZZ0001ZZ
    Đây là điều khiển chỉ đọc mà ứng dụng có thể đọc và
    được sử dụng như một gợi ý để xác định số lượng bộ đệm CAPTURE cần chuyển tới
    REQBUFS. Giá trị là số lượng bộ đệm CAPTURE tối thiểu
    cần thiết để phần cứng hoạt động. Kiểm soát này là cần thiết cho trạng thái
    bộ giải mã.

ZZ0000ZZ ZZ0001ZZ
    Đây là điều khiển chỉ đọc mà ứng dụng có thể đọc và
    được sử dụng như một gợi ý để xác định số lượng bộ đệm OUTPUT cần chuyển tới
    REQBUFS. Giá trị là số lượng bộ đệm OUTPUT tối thiểu
    cần thiết để phần cứng hoạt động. Kiểm soát này là cần thiết cho trạng thái
    bộ mã hóa.

.. _v4l2-alpha-component:

ZZ0001ZZ ZZ0002ZZ
    Đặt thành phần màu alpha. Khi một thiết bị chụp (hoặc chụp
    hàng đợi của thiết bị mem-to-mem) tạo ra định dạng khung bao gồm
    một thành phần alpha (ví dụ:
    ZZ0000ZZ) và giá trị alpha
    không được xác định bởi thiết bị hoặc dữ liệu đầu vào mem-to-mem này
    điều khiển cho phép bạn chọn giá trị thành phần alpha của tất cả các pixel.
    Khi một thiết bị đầu ra (hoặc hàng đợi đầu ra của thiết bị mem-to-mem)
    sử dụng định dạng khung không bao gồm thành phần alpha và
    thiết bị hỗ trợ xử lý kênh alpha, điều khiển này cho phép bạn
    đặt giá trị thành phần alpha của tất cả các pixel để xử lý thêm
    trong thiết bị.

ZZ0000ZZ
    Kết thúc ID kiểm soát được xác định trước (hiện tại
    ZZ0001ZZ + 1).

ZZ0001ZZ
    ID của điều khiển tùy chỉnh đầu tiên (trình điều khiển cụ thể). Ứng dụng
    tùy thuộc vào điều khiển tùy chỉnh cụ thể nên kiểm tra tên trình điều khiển
    và phiên bản, xem ZZ0000ZZ.

Các ứng dụng có thể liệt kê các điều khiển có sẵn bằng
ZZ0000ZZ và
ZZ0001ZZ ioctls, nhận và thiết lập
giá trị điều khiển với ZZ0002ZZ và
ZZ0003ZZ ioctls. Người lái xe phải thực hiện
ZZ0004ZZ, ZZ0005ZZ và ZZ0006ZZ khi
thiết bị có một hoặc nhiều điều khiển, ZZ0007ZZ khi có một hoặc
nhiều điều khiển loại menu hơn.


.. _enum_all_controls:

Ví dụ: Liệt kê tất cả các điều khiển
=================================

.. code-block:: c

    struct v4l2_queryctrl queryctrl;
    struct v4l2_querymenu querymenu;

    static void enumerate_menu(__u32 id)
    {
	printf("  Menu items:\\n");

	memset(&querymenu, 0, sizeof(querymenu));
	querymenu.id = id;

	for (querymenu.index = queryctrl.minimum;
	     querymenu.index <= queryctrl.maximum;
	     querymenu.index++) {
	    if (0 == ioctl(fd, VIDIOC_QUERYMENU, &querymenu)) {
		printf("  %s\\n", querymenu.name);
	    }
	}
    }

    memset(&queryctrl, 0, sizeof(queryctrl));

    queryctrl.id = V4L2_CTRL_FLAG_NEXT_CTRL;
    while (0 == ioctl(fd, VIDIOC_QUERYCTRL, &queryctrl)) {
	if (!(queryctrl.flags & V4L2_CTRL_FLAG_DISABLED)) {
	    printf("Control %s\\n", queryctrl.name);

	    if (queryctrl.type == V4L2_CTRL_TYPE_MENU)
	        enumerate_menu(queryctrl.id);
        }

	queryctrl.id |= V4L2_CTRL_FLAG_NEXT_CTRL;
    }
    if (errno != EINVAL) {
	perror("VIDIOC_QUERYCTRL");
	exit(EXIT_FAILURE);
    }

Ví dụ: Liệt kê tất cả các điều khiển bao gồm các điều khiển kết hợp
=============================================================

.. code-block:: c

    struct v4l2_query_ext_ctrl query_ext_ctrl;

    memset(&query_ext_ctrl, 0, sizeof(query_ext_ctrl));

    query_ext_ctrl.id = V4L2_CTRL_FLAG_NEXT_CTRL | V4L2_CTRL_FLAG_NEXT_COMPOUND;
    while (0 == ioctl(fd, VIDIOC_QUERY_EXT_CTRL, &query_ext_ctrl)) {
	if (!(query_ext_ctrl.flags & V4L2_CTRL_FLAG_DISABLED)) {
	    printf("Control %s\\n", query_ext_ctrl.name);

	    if (query_ext_ctrl.type == V4L2_CTRL_TYPE_MENU)
	        enumerate_menu(query_ext_ctrl.id);
        }

	query_ext_ctrl.id |= V4L2_CTRL_FLAG_NEXT_CTRL | V4L2_CTRL_FLAG_NEXT_COMPOUND;
    }
    if (errno != EINVAL) {
	perror("VIDIOC_QUERY_EXT_CTRL");
	exit(EXIT_FAILURE);
    }

Ví dụ: Liệt kê tất cả các điều khiển của người dùng (kiểu cũ)
==================================================

.. code-block:: c


    memset(&queryctrl, 0, sizeof(queryctrl));

    for (queryctrl.id = V4L2_CID_BASE;
	 queryctrl.id < V4L2_CID_LASTP1;
	 queryctrl.id++) {
	if (0 == ioctl(fd, VIDIOC_QUERYCTRL, &queryctrl)) {
	    if (queryctrl.flags & V4L2_CTRL_FLAG_DISABLED)
		continue;

	    printf("Control %s\\n", queryctrl.name);

	    if (queryctrl.type == V4L2_CTRL_TYPE_MENU)
		enumerate_menu(queryctrl.id);
	} else {
	    if (errno == EINVAL)
		continue;

	    perror("VIDIOC_QUERYCTRL");
	    exit(EXIT_FAILURE);
	}
    }

    for (queryctrl.id = V4L2_CID_PRIVATE_BASE;;
	 queryctrl.id++) {
	if (0 == ioctl(fd, VIDIOC_QUERYCTRL, &queryctrl)) {
	    if (queryctrl.flags & V4L2_CTRL_FLAG_DISABLED)
		continue;

	    printf("Control %s\\n", queryctrl.name);

	    if (queryctrl.type == V4L2_CTRL_TYPE_MENU)
		enumerate_menu(queryctrl.id);
	} else {
	    if (errno == EINVAL)
		break;

	    perror("VIDIOC_QUERYCTRL");
	    exit(EXIT_FAILURE);
	}
    }


Ví dụ: Thay đổi điều khiển
==========================

.. code-block:: c

    struct v4l2_queryctrl queryctrl;
    struct v4l2_control control;

    memset(&queryctrl, 0, sizeof(queryctrl));
    queryctrl.id = V4L2_CID_BRIGHTNESS;

    if (-1 == ioctl(fd, VIDIOC_QUERYCTRL, &queryctrl)) {
	if (errno != EINVAL) {
	    perror("VIDIOC_QUERYCTRL");
	    exit(EXIT_FAILURE);
	} else {
	    printf("V4L2_CID_BRIGHTNESS is not supported\n");
	}
    } else if (queryctrl.flags & V4L2_CTRL_FLAG_DISABLED) {
	printf("V4L2_CID_BRIGHTNESS is not supported\n");
    } else {
	memset(&control, 0, sizeof (control));
	control.id = V4L2_CID_BRIGHTNESS;
	control.value = queryctrl.default_value;

	if (-1 == ioctl(fd, VIDIOC_S_CTRL, &control)) {
	    perror("VIDIOC_S_CTRL");
	    exit(EXIT_FAILURE);
	}
    }

    memset(&control, 0, sizeof(control));
    control.id = V4L2_CID_CONTRAST;

    if (0 == ioctl(fd, VIDIOC_G_CTRL, &control)) {
	control.value += 1;

	/* The driver may clamp the value or return ERANGE, ignored here */

	if (-1 == ioctl(fd, VIDIOC_S_CTRL, &control)
	    && errno != ERANGE) {
	    perror("VIDIOC_S_CTRL");
	    exit(EXIT_FAILURE);
	}
    /* Ignore if V4L2_CID_CONTRAST is unsupported */
    } else if (errno != EINVAL) {
	perror("VIDIOC_G_CTRL");
	exit(EXIT_FAILURE);
    }

    control.id = V4L2_CID_AUDIO_MUTE;
    control.value = 1; /* silence */

    /* Errors ignored */
    ioctl(fd, VIDIOC_S_CTRL, &control);

.. [#f1]
   The use of ``V4L2_CID_PRIVATE_BASE`` is problematic because different
   drivers may use the same ``V4L2_CID_PRIVATE_BASE`` ID for different
   controls. This makes it hard to programmatically set such controls
   since the meaning of the control with that ID is driver dependent. In
   order to resolve this drivers use unique IDs and the
   ``V4L2_CID_PRIVATE_BASE`` IDs are mapped to those unique IDs by the
   kernel. Consider these ``V4L2_CID_PRIVATE_BASE`` IDs as aliases to
   the real IDs.

   Many applications today still use the ``V4L2_CID_PRIVATE_BASE`` IDs
   instead of using :ref:`VIDIOC_QUERYCTRL` with
   the ``V4L2_CTRL_FLAG_NEXT_CTRL`` flag to enumerate all IDs, so
   support for ``V4L2_CID_PRIVATE_BASE`` is still around.