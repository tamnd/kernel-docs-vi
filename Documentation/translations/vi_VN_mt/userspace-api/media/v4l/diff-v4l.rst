.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/diff-v4l.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _diff-v4l:

********************************
Sự khác biệt giữa V4L và V4L2
********************************

Video For Linux API lần đầu tiên được giới thiệu trong Linux 2.1 để thống nhất và
thay thế các giao diện liên quan đến thiết bị TV và radio khác nhau, được phát triển
độc lập bởi các nhà văn lái xe trong những năm trước. Bắt đầu với Linux 2.5
V4L2 API được cải tiến nhiều sẽ thay thế V4L API. Sự hỗ trợ cho người cũ
Các cuộc gọi V4L đã bị xóa khỏi Kernel, nhưng thư viện ZZ0000ZZ
hỗ trợ chuyển đổi cuộc gọi hệ thống V4L API thành cuộc gọi hệ thống V4L2.

Thiết bị mở và đóng
===========================

Vì lý do tương thích, nên sử dụng tên tệp thiết bị ký tự
dành cho các thiết bị ghi video, lớp phủ, radio và vbi thô V4L2 đã làm
không thay đổi so với những gì được sử dụng bởi V4L. Chúng được liệt kê trong ZZ0000ZZ
trở xuống trong ZZ0001ZZ.

Các thiết bị teletext (phạm vi nhỏ 192-223) đã bị xóa trong V4L2 và
không còn tồn tại. Không còn phần cứng nào để xử lý nữa
teletext thuần túy. Thay vào đó, VBI sống hoặc thái lát được sử dụng.

Mô-đun V4L ZZ0000ZZ tự động gán các số nhỏ cho
trình điều khiển theo thứ tự tải, tùy thuộc vào loại thiết bị đã đăng ký. Chúng tôi
khuyến nghị các trình điều khiển V4L2 theo mặc định phải đăng ký các thiết bị có cùng
nhưng người quản trị hệ thống có thể gán các số phụ tùy ý
sử dụng các tùy chọn mô-đun trình điều khiển. Số thiết bị chính vẫn là 81.

.. _v4l-dev:

.. flat-table:: V4L Device Types, Names and Numbers
    :header-rows:  1
    :stub-columns: 0

    * - Device Type
      - File Name
      - Minor Numbers
    * - Video capture and overlay
      - ``/dev/video`` and ``/dev/bttv0``\  [#f1]_, ``/dev/video0`` to
	``/dev/video63``
      - 0-63
    * - Radio receiver
      - ``/dev/radio``\  [#f2]_, ``/dev/radio0`` to ``/dev/radio63``
      - 64-127
    * - Raw VBI capture
      - ``/dev/vbi``, ``/dev/vbi0`` to ``/dev/vbi31``
      - 224-255

V4L cấm (hoặc được sử dụng để cấm) mở nhiều tệp trên thiết bị.
Trình điều khiển V4L2 ZZ0001ZZ hỗ trợ mở nhiều lần, xem ZZ0000ZZ để biết chi tiết
và hậu quả.

Trình điều khiển V4L phản hồi ioctls V4L2 bằng mã lỗi ZZ0000ZZ.

Khả năng truy vấn
=====================

V4L ZZ0001ZZ ioctl tương đương với V4L2
ZZ0000ZZ.

Trường ZZ0002ZZ trong cấu trúc ZZ0003ZZ đã trở thành
ZZ0004ZZ trong cấu trúc ZZ0000ZZ, ZZ0005ZZ
đã được thay thế bởi ZZ0006ZZ. Lưu ý V4L2 không phân biệt giữa
loại thiết bị như thế này, tốt hơn hãy nghĩ đến đầu vào video cơ bản, đầu ra video
và các thiết bị vô tuyến hỗ trợ một tập hợp các chức năng liên quan như video
chụp, lớp phủ video và chụp VBI. Xem ZZ0001ZZ để biết
giới thiệu.

.. raw:: latex

   \small

.. tabularcolumns:: |p{5.3cm}|p{6.7cm}|p{5.3cm}|

.. cssclass:: longtable

.. flat-table::
    :header-rows:  1
    :stub-columns: 0

    * - ``struct video_capability`` ``type``
      - struct :c:type:`v4l2_capability`
	``capabilities`` flags
      - Purpose
    * - ``VID_TYPE_CAPTURE``
      - ``V4L2_CAP_VIDEO_CAPTURE``
      - The :ref:`video capture <capture>` interface is supported.
    * - ``VID_TYPE_TUNER``
      - ``V4L2_CAP_TUNER``
      - The device has a :ref:`tuner or modulator <tuner>`.
    * - ``VID_TYPE_TELETEXT``
      - ``V4L2_CAP_VBI_CAPTURE``
      - The :ref:`raw VBI capture <raw-vbi>` interface is supported.
    * - ``VID_TYPE_OVERLAY``
      - ``V4L2_CAP_VIDEO_OVERLAY``
      - The :ref:`video overlay <overlay>` interface is supported.
    * - ``VID_TYPE_CHROMAKEY``
      - ``V4L2_FBUF_CAP_CHROMAKEY`` in field ``capability`` of struct
	:c:type:`v4l2_framebuffer`
      - Whether chromakey overlay is supported. For more information on
	overlay see :ref:`overlay`.
    * - ``VID_TYPE_CLIPPING``
      - ``V4L2_FBUF_CAP_LIST_CLIPPING`` and
	``V4L2_FBUF_CAP_BITMAP_CLIPPING`` in field ``capability`` of
	struct :c:type:`v4l2_framebuffer`
      - Whether clipping the overlaid image is supported, see
	:ref:`overlay`.
    * - ``VID_TYPE_FRAMERAM``
      - ``V4L2_FBUF_CAP_EXTERNOVERLAY`` *not set* in field ``capability``
	of struct :c:type:`v4l2_framebuffer`
      - Whether overlay overwrites frame buffer memory, see
	:ref:`overlay`.
    * - ``VID_TYPE_SCALES``
      - ``-``
      - This flag indicates if the hardware can scale images. The V4L2 API
	implies the scale factor by setting the cropping dimensions and
	image size with the :ref:`VIDIOC_S_CROP <VIDIOC_G_CROP>` and
	:ref:`VIDIOC_S_FMT <VIDIOC_G_FMT>` ioctl, respectively. The
	driver returns the closest sizes possible. For more information on
	cropping and scaling see :ref:`crop`.
    * - ``VID_TYPE_MONOCHROME``
      - ``-``
      - Applications can enumerate the supported image formats with the
	:ref:`VIDIOC_ENUM_FMT` ioctl to determine if
	the device supports grey scale capturing only. For more
	information on image formats see :ref:`pixfmt`.
    * - ``VID_TYPE_SUBCAPTURE``
      - ``-``
      - Applications can call the :ref:`VIDIOC_G_CROP <VIDIOC_G_CROP>`
	ioctl to determine if the device supports capturing a subsection
	of the full picture ("cropping" in V4L2). If not, the ioctl
	returns the ``EINVAL`` error code. For more information on cropping
	and scaling see :ref:`crop`.
    * - ``VID_TYPE_MPEG_DECODER``
      - ``-``
      - Applications can enumerate the supported image formats with the
	:ref:`VIDIOC_ENUM_FMT` ioctl to determine if
	the device supports MPEG streams.
    * - ``VID_TYPE_MPEG_ENCODER``
      - ``-``
      - See above.
    * - ``VID_TYPE_MJPEG_DECODER``
      - ``-``
      - See above.
    * - ``VID_TYPE_MJPEG_ENCODER``
      - ``-``
      - See above.

.. raw:: latex

   \normalsize

Trường ZZ0002ZZ đã được thay thế bằng cờ ZZ0003ZZ
ZZ0004ZZ, cho biết ZZ0005ZZ thiết bị có bất kỳ đầu vào âm thanh hoặc
đầu ra. Để xác định số lượng ứng dụng của chúng có thể liệt kê âm thanh
đầu vào với ZZ0000ZZ ioctl. các
ioctls âm thanh được mô tả trong ZZ0001ZZ.

Các trường ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ và ZZ0005ZZ
đã được gỡ bỏ. Gọi ZZ0000ZZ hoặc
ZZ0001ZZ ioctl với mong muốn
kích thước trả về kích thước gần nhất có thể, có tính đến
các giới hạn về tiêu chuẩn video hiện tại, cắt xén và chia tỷ lệ.

Nguồn video
=============

V4L cung cấp ZZ0005ZZ và ZZ0006ZZ ioctl bằng cách sử dụng struct
ZZ0007ZZ để liệt kê các đầu vào video của V4L
thiết bị. Các ioctls V4L2 tương đương là
ZZ0000ZZ,
ZZ0001ZZ và
ZZ0002ZZ sử dụng cấu trúc
ZZ0003ZZ như đã thảo luận trong ZZ0004ZZ.

Đầu vào đếm trường ZZ0000ZZ được đổi tên thành ZZ0001ZZ,
các loại đầu vào video đã được đổi tên như sau:


.. flat-table::
    :header-rows:  1
    :stub-columns: 0

    * - struct ``video_channel`` ``type``
      - struct :c:type:`v4l2_input` ``type``
    * - ``VIDEO_TYPE_TV``
      - ``V4L2_INPUT_TYPE_TUNER``
    * - ``VIDEO_TYPE_CAMERA``
      - ``V4L2_INPUT_TYPE_CAMERA``

Không giống như trường ZZ0002ZZ thể hiện số lượng bộ điều chỉnh của
đầu vào, V4L2 giả định mỗi đầu vào video được kết nối với tối đa một bộ dò.
Tuy nhiên, bộ chỉnh tần có thể có nhiều đầu vào, tức là. đ. Đầu nối RF và một
thiết bị có thể có nhiều bộ điều chỉnh. Số chỉ mục của bộ điều chỉnh
liên kết với đầu vào, nếu có, được lưu trữ trong trường ZZ0003ZZ của
cấu trúc ZZ0000ZZ. Việc liệt kê các bộ điều chỉnh là
được thảo luận trong ZZ0001ZZ.

Cờ ZZ0001ZZ dư thừa đã bị loại bỏ. Đầu vào video
được liên kết với bộ chỉnh tần thuộc loại ZZ0002ZZ. các
Cờ ZZ0003ZZ đã được thay thế bằng trường ZZ0004ZZ. V4L2
xem xét các thiết bị có tối đa 32 đầu vào âm thanh. Mỗi bit được đặt trong
Trường ZZ0005ZZ đại diện cho một đầu vào âm thanh mà đầu vào video này kết hợp
với. Để biết thông tin về đầu vào âm thanh và cách chuyển đổi giữa chúng
xem ZZ0000ZZ.

Trường ZZ0001ZZ mô tả các tiêu chuẩn video được hỗ trợ đã được thay thế
bởi ZZ0002ZZ. Đặc tả V4L đề cập đến cờ ZZ0003ZZ
cho biết liệu tiêu chuẩn có thể được thay đổi hay không. Lá cờ này có sau này
phép cộng cùng với trường ZZ0004ZZ và đã bị xóa trong
trong lúc đó. V4L2 có cách tiếp cận tương tự nhưng toàn diện hơn
tiêu chuẩn video, xem ZZ0000ZZ để biết thêm thông tin.

điều chỉnh
==========

V4L ZZ0004ZZ và ZZ0005ZZ ioctl và struct
ZZ0006ZZ có thể được sử dụng để liệt kê các bộ điều chỉnh của một
V4L TV hoặc thiết bị radio. Các ioctls V4L2 tương đương là
ZZ0000ZZ và
ZZ0001ZZ sử dụng cấu trúc
ZZ0002ZZ. Bộ điều chỉnh được bao phủ trong ZZ0003ZZ.

Bộ điều chỉnh đếm trường ZZ0000ZZ được đổi tên thành ZZ0001ZZ. những cánh đồng
ZZ0002ZZ, ZZ0003ZZ và ZZ0004ZZ không thay đổi.

ZZ0002ZZ, ZZ0003ZZ và ZZ0004ZZ
cờ cho biết các tiêu chuẩn video được hỗ trợ đã bị loại bỏ. Cái này
thông tin hiện được chứa trong cấu trúc liên quan
ZZ0000ZZ. Không có sự thay thế nào tồn tại cho
Cờ ZZ0005ZZ cho biết liệu tiêu chuẩn video có thể được
đã chuyển đổi. Trường ZZ0006ZZ để chọn tiêu chuẩn video khác là
được thay thế bằng một tập hợp ioctls và cấu trúc hoàn toàn mới được mô tả trong
ZZ0001ZZ. Do tính phổ biến của nó nên phải nhắc đến BTTV
trình điều khiển hỗ trợ một số tiêu chuẩn ngoài tiêu chuẩn thông thường
ZZ0007ZZ (0), ZZ0008ZZ, ZZ0009ZZ và
ZZ0010ZZ (3). Cụ thể là N/PAL Argentina, M/PAL, N/PAL và NTSC
Nhật Bản với số 3-6 (sic).

Cờ ZZ0001ZZ cho biết khả năng thu âm thanh nổi đã trở thành
ZZ0002ZZ trong trường ZZ0003ZZ. Lĩnh vực này cũng
cho phép phát hiện âm thanh đơn âm và song ngữ, xem
định nghĩa của struct ZZ0000ZZ để biết chi tiết.
Hiện tại không có sự thay thế nào cho ZZ0004ZZ và
Cờ ZZ0005ZZ.

Cờ ZZ0001ZZ được đổi tên thành ZZ0002ZZ vào năm
trường cấu trúc ZZ0000ZZ ZZ0003ZZ.

ZZ0003ZZ và ZZ0004ZZ ioctl để thay đổi bộ chỉnh tần
tần số được đổi tên thành
ZZ0000ZZ và
ZZ0001ZZ. Họ lấy một con trỏ
thành cấu trúc ZZ0002ZZ thay vì
số nguyên dài không dấu.

.. _v4l-image-properties:

Thuộc tính hình ảnh
===================

V4L2 không có tương đương với ZZ0003ZZ và ZZ0004ZZ ioctl
và cấu trúc ZZ0005ZZ. Các trường sau đây có
được thay thế bằng các điều khiển V4L2 có thể truy cập bằng
ZZ0000ZZ,
ZZ0001ZZ và
ZZ0002ZZ ioctls:


.. flat-table::
    :header-rows:  1
    :stub-columns: 0

    * - struct ``video_picture``
      - V4L2 Control ID
    * - ``brightness``
      - ``V4L2_CID_BRIGHTNESS``
    * - ``hue``
      - ``V4L2_CID_HUE``
    * - ``colour``
      - ``V4L2_CID_SATURATION``
    * - ``contrast``
      - ``V4L2_CID_CONTRAST``
    * - ``whiteness``
      - ``V4L2_CID_WHITENESS``

Các điều khiển hình ảnh V4L được giả sử nằm trong khoảng từ 0 đến 65535 không có
giá trị đặt lại cụ thể. V4L2 API cho phép giới hạn tùy ý và
mặc định có thể được truy vấn với
ZZ0000ZZ ioctl. Dành cho chung
thông tin về điều khiển xem ZZ0001ZZ.

ZZ0001ZZ (số bit trung bình trên mỗi pixel) của hình ảnh video là
ngụ ý bởi định dạng hình ảnh đã chọn. V4L2 không cung cấp rõ ràng
thông tin như vậy giả sử các ứng dụng nhận dạng định dạng đều biết
về độ sâu hình ảnh và những người khác không cần biết. Trường ZZ0002ZZ đã được di chuyển
vào cấu trúc ZZ0000ZZ:


.. flat-table::
    :header-rows:  1
    :stub-columns: 0

    * - struct ``video_picture`` ``palette``
      - struct :c:type:`v4l2_pix_format` ``pixfmt``
    * - ``VIDEO_PALETTE_GREY``
      - :ref:`V4L2_PIX_FMT_GREY <V4L2-PIX-FMT-GREY>`
    * - ``VIDEO_PALETTE_HI240``
      - :ref:`V4L2_PIX_FMT_HI240 <pixfmt-reserved>` [#f3]_
    * - ``VIDEO_PALETTE_RGB565``
      - :ref:`V4L2_PIX_FMT_RGB565 <pixfmt-rgb>`
    * - ``VIDEO_PALETTE_RGB555``
      - :ref:`V4L2_PIX_FMT_RGB555 <pixfmt-rgb>`
    * - ``VIDEO_PALETTE_RGB24``
      - :ref:`V4L2_PIX_FMT_BGR24 <pixfmt-rgb>`
    * - ``VIDEO_PALETTE_RGB32``
      - :ref:`V4L2_PIX_FMT_BGR32 <pixfmt-rgb>` [#f4]_
    * - ``VIDEO_PALETTE_YUV422``
      - :ref:`V4L2_PIX_FMT_YUYV <V4L2-PIX-FMT-YUYV>`
    * - ``VIDEO_PALETTE_YUYV``\  [#f5]_
      - :ref:`V4L2_PIX_FMT_YUYV <V4L2-PIX-FMT-YUYV>`
    * - ``VIDEO_PALETTE_UYVY``
      - :ref:`V4L2_PIX_FMT_UYVY <V4L2-PIX-FMT-UYVY>`
    * - ``VIDEO_PALETTE_YUV420``
      - None
    * - ``VIDEO_PALETTE_YUV411``
      - :ref:`V4L2_PIX_FMT_Y41P <V4L2-PIX-FMT-Y41P>` [#f6]_
    * - ``VIDEO_PALETTE_RAW``
      - None [#f7]_
    * - ``VIDEO_PALETTE_YUV422P``
      - :ref:`V4L2_PIX_FMT_YUV422P <V4L2-PIX-FMT-YUV422P>`
    * - ``VIDEO_PALETTE_YUV411P``
      - :ref:`V4L2_PIX_FMT_YUV411P <V4L2-PIX-FMT-YUV411P>` [#f8]_
    * - ``VIDEO_PALETTE_YUV420P``
      - :ref:`V4L2_PIX_FMT_YVU420 <V4L2-PIX-FMT-YVU420>`
    * - ``VIDEO_PALETTE_YUV410P``
      - :ref:`V4L2_PIX_FMT_YVU410 <V4L2-PIX-FMT-YVU410>`

Các định dạng hình ảnh V4L2 được xác định trong ZZ0000ZZ. Định dạng hình ảnh có thể
được chọn bằng ZZ0001ZZ ioctl.

Âm thanh
========

ZZ0004ZZ và ZZ0005ZZ ioctl và struct
ZZ0006ZZ được sử dụng để liệt kê các đầu vào âm thanh
của thiết bị V4L. Các ioctls V4L2 tương đương là
ZZ0000ZZ và
ZZ0001ZZ sử dụng cấu trúc
ZZ0002ZZ như đã thảo luận trong ZZ0003ZZ.

Đầu vào âm thanh đếm trường "số kênh" ZZ0000ZZ đã được đổi tên
tới ZZ0001ZZ.

Trên ZZ0003ZZ, trường ZZ0004ZZ chọn ZZ0014ZZ của
ZZ0005ZZ, ZZ0006ZZ, ZZ0007ZZ hoặc
Chế độ giải điều chế âm thanh ZZ0008ZZ. Khi âm thanh hiện tại
tiêu chuẩn là BTSC ZZ0009ZZ đề cập đến SAP và
ZZ0010ZZ là vô nghĩa. Cũng không có giấy tờ trong V4L
đặc điểm kỹ thuật, không có cách nào để truy vấn chế độ đã chọn. Bật
ZZ0011ZZ trình điều khiển trả về âm thanh ZZ0015ZZ
các chương trình trong lĩnh vực này. Trong V4L2 API, thông tin này được lưu trữ trong
cấu trúc ZZ0000ZZ ZZ0012ZZ và
Các trường ZZ0013ZZ tương ứng. Xem ZZ0001ZZ để biết thêm
thông tin về bộ chỉnh âm. Liên quan đến cấu trúc chế độ âm thanh
ZZ0002ZZ cũng báo cáo đây là mono hay
đầu vào âm thanh nổi, bất kể nguồn đó có phải là bộ chỉnh âm hay không.

Các trường sau đây được thay thế bằng các điều khiển V4L2 có thể truy cập được bằng
ZZ0000ZZ,
ZZ0001ZZ và
ZZ0002ZZ ioctls:


.. flat-table::
    :header-rows:  1
    :stub-columns: 0

    * - struct ``video_audio``
      - V4L2 Control ID
    * - ``volume``
      - ``V4L2_CID_AUDIO_VOLUME``
    * - ``bass``
      - ``V4L2_CID_AUDIO_BASS``
    * - ``treble``
      - ``V4L2_CID_AUDIO_TREBLE``
    * - ``balance``
      - ``V4L2_CID_AUDIO_BALANCE``

Để xác định điều khiển nào trong số này được trình điều khiển V4L hỗ trợ
cung cấp ZZ0001ZZ ZZ0002ZZ, ZZ0003ZZ,
ZZ0004ZZ và ZZ0005ZZ. Trong V4L2 API,
ZZ0000ZZ ioctl báo cáo nếu
điều khiển tương ứng được hỗ trợ. Theo đó ZZ0006ZZ
và cờ ZZ0007ZZ được thay thế bằng boolean
Điều khiển ZZ0008ZZ.

Tất cả các điều khiển V4L2 đều có thuộc tính ZZ0002ZZ thay thế cấu trúc
Trường ZZ0003ZZ ZZ0004ZZ. Bộ điều khiển âm thanh V4L
được giả sử nằm trong khoảng từ 0 đến 65535 không có giá trị đặt lại cụ thể. các
V4L2 API cho phép các giới hạn và giá trị mặc định tùy ý có thể được truy vấn bằng
ZZ0000ZZ ioctl. Dành cho chung
thông tin về điều khiển xem ZZ0001ZZ.

Lớp phủ bộ đệm khung
====================

Các ioctls V4L2 tương đương với ZZ0005ZZ và ZZ0006ZZ là
ZZ0000ZZ và
ZZ0001ZZ. Trường ZZ0007ZZ của cấu trúc
ZZ0008ZZ vẫn không thay đổi, ngoại trừ V4L2 được xác định
một lá cờ để biểu thị lớp phủ không phá hủy thay vì ZZ0009ZZ
con trỏ. Tất cả các trường khác được chuyển vào cấu trúc
Cấu trúc cơ sở ZZ0002ZZ ZZ0010ZZ của
cấu trúc ZZ0003ZZ. ZZ0011ZZ
trường đã được thay thế bằng ZZ0012ZZ. Xem ZZ0004ZZ để biết
danh sách các định dạng RGB và độ sâu màu tương ứng của chúng.

Thay vì ioctls đặc biệt ZZ0004ZZ và ZZ0005ZZ V4L2
sử dụng ioctls đàm phán định dạng dữ liệu có mục đích chung
ZZ0000ZZ và
ZZ0001ZZ. Họ lấy một con trỏ tới một cấu trúc
ZZ0002ZZ làm đối số. Đây là thành viên ZZ0006ZZ
của liên minh ZZ0007ZZ được sử dụng, một cấu trúc
ZZ0003ZZ.

Các trường ZZ0004ZZ, ZZ0005ZZ, ZZ0006ZZ và ZZ0007ZZ của cấu trúc
ZZ0008ZZ đã chuyển sang cấu trúc
Cấu trúc nền ZZ0000ZZ ZZ0009ZZ của cấu trúc
ZZ0001ZZ. ZZ0010ZZ, ZZ0011ZZ và
Các trường ZZ0012ZZ không thay đổi. Cấu trúc
ZZ0013ZZ được đổi tên thành struct
ZZ0002ZZ, cũng chứa cấu trúc
ZZ0003ZZ, nhưng ngữ nghĩa vẫn giống nhau.

Cờ ZZ0001ZZ đã bị loại bỏ. Thay vào đó các ứng dụng
phải đặt trường ZZ0002ZZ thành ZZ0003ZZ hoặc
ZZ0004ZZ. Cờ ZZ0005ZZ đã được di chuyển
vào cấu trúc ZZ0000ZZ, theo cấu trúc mới
tên ZZ0006ZZ.

Trong V4L, lưu trữ con trỏ bitmap trong ZZ0001ZZ và cài đặt ZZ0002ZZ
tới ZZ0003ZZ (-1) yêu cầu cắt bitmap bằng cách sử dụng
bitmap kích thước 1024 × 625 bit. Cấu trúc ZZ0000ZZ
có trường con trỏ ZZ0004ZZ riêng cho mục đích này và bitmap
kích thước được xác định bởi ZZ0005ZZ và ZZ0006ZZ.

ZZ0001ZZ ioctl để bật hoặc tắt lớp phủ đã được đổi tên thành
ZZ0000ZZ.

Cắt xén
========

Để chỉ chụp một phần phụ của bức ảnh đầy đủ V4L xác định
ioctls ZZ0005ZZ và ZZ0006ZZ sử dụng struct
ZZ0007ZZ. Các ioctls V4L2 tương đương là
ZZ0000ZZ và
ZZ0001ZZ sử dụng cấu trúc
ZZ0002ZZ và các thông tin liên quan
ZZ0003ZZ ioctl. Đây là một điều khá
vấn đề phức tạp, xem ZZ0004ZZ để biết chi tiết.

Các trường ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ và ZZ0005ZZ đã được chuyển vào struct
Cấu trúc nền ZZ0000ZZ ZZ0006ZZ của cấu trúc
ZZ0001ZZ. Trường ZZ0007ZZ đã bị loại bỏ. trong
V4L2 API hệ số tỷ lệ được ngụ ý bởi kích thước cắt xén
hình chữ nhật và kích thước của hình ảnh được chụp hoặc phủ lên.

Cờ ZZ0003ZZ và ZZ0004ZZ để chụp
chỉ trường lẻ hoặc trường chẵn tương ứng được thay thế bằng
ZZ0005ZZ và ZZ0006ZZ trong trường có tên
ZZ0007ZZ của cấu trúc ZZ0000ZZ và
cấu trúc ZZ0001ZZ. Những cấu trúc này được sử dụng để
chọn định dạng chụp hoặc lớp phủ bằng
ZZ0002ZZ ioctl.

Đọc hình ảnh, lập bản đồ bộ nhớ
===============================

Chụp bằng phương pháp đọc
-------------------------------

Không có sự khác biệt cơ bản giữa việc đọc hình ảnh từ V4L hoặc
Thiết bị V4L2 sử dụng chức năng ZZ0000ZZ, tuy nhiên V4L2
trình điều khiển không bắt buộc phải hỗ trợ phương pháp I/O này. Ứng dụng có thể
xác định xem chức năng này có sẵn với
ZZ0001ZZ ioctl. Tất cả các thiết bị V4L2
trao đổi dữ liệu với các ứng dụng phải hỗ trợ
ZZ0002ZZ và ZZ0003ZZ
chức năng.

Để chọn định dạng và kích thước hình ảnh, V4L cung cấp ZZ0004ZZ và
ZZ0005ZZ ioctls. V4L2 sử dụng định dạng dữ liệu có mục đích chung
đàm phán ioctls ZZ0000ZZ và
ZZ0001ZZ. Họ lấy một con trỏ tới một cấu trúc
ZZ0002ZZ làm đối số, ở đây là cấu trúc
ZZ0003ZZ được đặt tên là ZZ0006ZZ của nó
Liên minh ZZ0007ZZ được sử dụng.

Để biết thêm thông tin về giao diện đọc V4L2, hãy xem ZZ0000ZZ.

Chụp bằng cách sử dụng ánh xạ bộ nhớ
------------------------------------

Ứng dụng có thể đọc từ thiết bị V4L bằng cách ánh xạ bộ đệm trong thiết bị
bộ nhớ hoặc thường chỉ là bộ đệm được phân bổ trong bộ nhớ hệ thống có khả năng DMA,
vào không gian địa chỉ của họ. Điều này tránh được chi phí sao chép dữ liệu của
phương pháp đọc. V4L2 cũng hỗ trợ ánh xạ bộ nhớ, với một số
sự khác biệt.


.. flat-table::
    :header-rows:  1
    :stub-columns: 0

    * - V4L
      - V4L2
    * -
      - The image format must be selected before buffers are allocated,
	with the :ref:`VIDIOC_S_FMT <VIDIOC_G_FMT>` ioctl. When no
	format is selected the driver may use the last, possibly by
	another application requested format.
    * - Applications cannot change the number of buffers. The it is built
	into the driver, unless it has a module option to change the
	number when the driver module is loaded.
      - The :ref:`VIDIOC_REQBUFS` ioctl allocates the
	desired number of buffers, this is a required step in the
	initialization sequence.
    * - Drivers map all buffers as one contiguous range of memory. The
	``VIDIOCGMBUF`` ioctl is available to query the number of buffers,
	the offset of each buffer from the start of the virtual file, and
	the overall amount of memory used, which can be used as arguments
	for the :c:func:`mmap()` function.
      - Buffers are individually mapped. The offset and size of each
	buffer can be determined with the
	:ref:`VIDIOC_QUERYBUF` ioctl.
    * - The ``VIDIOCMCAPTURE`` ioctl prepares a buffer for capturing. It
	also determines the image format for this buffer. The ioctl
	returns immediately, eventually with an ``EAGAIN`` error code if no
	video signal had been detected. When the driver supports more than
	one buffer applications can call the ioctl multiple times and thus
	have multiple outstanding capture requests.

	The ``VIDIOCSYNC`` ioctl suspends execution until a particular
	buffer has been filled.
      - Drivers maintain an incoming and outgoing queue.
	:ref:`VIDIOC_QBUF` enqueues any empty buffer into
	the incoming queue. Filled buffers are dequeued from the outgoing
	queue with the :ref:`VIDIOC_DQBUF <VIDIOC_QBUF>` ioctl. To wait
	until filled buffers become available this function,
	:c:func:`select()` or :c:func:`poll()` can
	be used. The :ref:`VIDIOC_STREAMON` ioctl
	must be called once after enqueuing one or more buffers to start
	capturing. Its counterpart
	:ref:`VIDIOC_STREAMOFF <VIDIOC_STREAMON>` stops capturing and
	dequeues all buffers from both queues. Applications can query the
	signal status, if known, with the
	:ref:`VIDIOC_ENUMINPUT` ioctl.

Để thảo luận sâu hơn về ánh xạ bộ nhớ và các ví dụ, hãy xem
ZZ0000ZZ.

Đọc dữ liệu VBI thô
====================

Ban đầu V4L API không chỉ định giao diện chụp VBI thô, chỉ
tệp thiết bị ZZ0000ZZ được dành riêng cho mục đích này. duy nhất
trình điều khiển hỗ trợ giao diện này là trình điều khiển BTTV, xác định trên thực tế
giao diện V4L VBI. Đọc từ thiết bị mang lại hình ảnh VBI thô
với các thông số sau:


.. flat-table::
    :header-rows:  1
    :stub-columns: 0

    * - struct :c:type:`v4l2_vbi_format`
      - V4L, BTTV driver
    * - sampling_rate
      - 28636363 Hz NTSC (or any other 525-line standard); 35468950 Hz PAL
	and SECAM (625-line standards)
    * - offset
      - ?
    * - samples_per_line
      - 2048
    * - sample_format
      - V4L2_PIX_FMT_GREY. The last four bytes (a machine endianness
	integer) contain a frame counter.
    * - start[]
      - 10, 273 NTSC; 22, 335 PAL and SECAM
    * - count[]
      - 16, 16 [#f9]_
    * - flags
      - 0

Không có giấy tờ trong đặc tả V4L, trong Linux 2.3,
ioctls ZZ0001ZZ và ZZ0002ZZ sử dụng struct
ZZ0003ZZ đã được thêm vào để xác định hình ảnh VBI
các thông số. Các ioctls này chỉ tương thích một phần với V4L2 VBI
giao diện được chỉ định trong ZZ0000ZZ.

Trường ZZ0001ZZ không tồn tại, ZZ0002ZZ được cho là
ZZ0003ZZ, tương đương với ZZ0004ZZ. các
các trường còn lại có thể tương đương với struct
ZZ0000ZZ.

Rõ ràng chỉ có trình điều khiển Zoran (ZR 36120) mới triển khai các ioctls này. các
ngữ nghĩa khác với ngữ nghĩa được chỉ định cho V4L2 theo hai cách. các
các tham số được đặt lại trên ZZ0000ZZ và
ZZ0001ZZ luôn trả về mã lỗi ZZ0002ZZ nếu các tham số
không hợp lệ.

Linh tinh
=============

V4L2 không có phiên bản tương đương với ZZ0001ZZ ioctl. Ứng dụng có thể
tìm thiết bị VBI được liên kết với thiết bị quay video (hoặc ngược lại
ngược lại) bằng cách mở lại thiết bị và yêu cầu dữ liệu VBI. Để biết chi tiết xem
ZZ0000ZZ.

Không có sự thay thế nào cho ZZ0001ZZ và V4L hoạt động cho
lập trình vi mã. Giao diện mới để nén và phát lại MPEG
thiết bị được ghi lại trong ZZ0000ZZ.

.. [#f1]
   According to Documentation/admin-guide/devices.rst these should be symbolic links
   to ``/dev/video0``. Note the original bttv interface is not
   compatible with V4L or V4L2.

.. [#f2]
   According to ``Documentation/admin-guide/devices.rst`` a symbolic link to
   ``/dev/radio0``.

.. [#f3]
   This is a custom format used by the BTTV driver, not one of the V4L2
   standard formats.

.. [#f4]
   Presumably all V4L RGB formats are little-endian, although some
   drivers might interpret them according to machine endianness. V4L2
   defines little-endian, big-endian and red/blue swapped variants. For
   details see :ref:`pixfmt-rgb`.

.. [#f5]
   ``VIDEO_PALETTE_YUV422`` and ``VIDEO_PALETTE_YUYV`` are the same
   formats. Some V4L drivers respond to one, some to the other.

.. [#f6]
   Not to be confused with ``V4L2_PIX_FMT_YUV411P``, which is a planar
   format.

.. [#f7]
   V4L explains this as: "RAW capture (BT848)"

.. [#f8]
   Not to be confused with ``V4L2_PIX_FMT_Y41P``, which is a packed
   format.

.. [#f9]
   Old driver versions used different values, eventually the custom
   ``BTTV_VBISIZE`` ioctl was added to query the correct values.