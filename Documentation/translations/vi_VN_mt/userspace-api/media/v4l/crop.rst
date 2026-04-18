.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/crop.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _crop:

*******************************************************
Cắt, chèn và chia tỷ lệ hình ảnh -- CROP API
*******************************************************

.. note::

   The CROP API is mostly superseded by the newer :ref:`SELECTION API
   <selection-api>`. The new API should be preferred in most cases,
   with the exception of pixel aspect ratio detection, which is
   implemented by :ref:`VIDIOC_CROPCAP <VIDIOC_CROPCAP>` and has no
   equivalent in the SELECTION API. See :ref:`selection-vs-crop` for a
   comparison of the two APIs.

Một số thiết bị quay video có thể lấy mẫu một phần nhỏ của hình ảnh và
thu nhỏ hoặc phóng to nó thành một hình ảnh có kích thước tùy ý. Chúng tôi gọi đây là
khả năng cắt xén và nhân rộng. Một số thiết bị đầu ra video có thể mở rộng quy mô
ảnh lên hoặc xuống rồi chèn vào đường quét tùy ý và ngang
offset thành tín hiệu video.

Các ứng dụng có thể sử dụng API sau để chọn một vùng trong video
tín hiệu, truy vấn khu vực mặc định và giới hạn phần cứng.

.. note::

   Despite their name, the :ref:`VIDIOC_CROPCAP <VIDIOC_CROPCAP>`,
   :ref:`VIDIOC_G_CROP <VIDIOC_G_CROP>` and :ref:`VIDIOC_S_CROP
   <VIDIOC_G_CROP>` ioctls apply to input as well as output devices.

Việc mở rộng quy mô đòi hỏi một nguồn và một mục tiêu. Trên bản quay video hoặc lớp phủ
thiết bị nguồn là tín hiệu video và ioctls cắt xén xác định
khu vực thực sự được lấy mẫu. Mục tiêu là những hình ảnh được ứng dụng đọc
hoặc phủ lên màn hình đồ họa. Kích thước của chúng (và vị trí của một
lớp phủ) được đàm phán với ZZ0000ZZ
và ZZ0001ZZ ioctls.

Trên thiết bị đầu ra video, nguồn là những hình ảnh được truyền vào bởi
ứng dụng, và kích thước của chúng một lần nữa được thương lượng với
ZZ0000ZZ và ZZ0001ZZ
ioctls hoặc có thể được mã hóa trong luồng video nén. Mục tiêu là
tín hiệu video và ioctls cắt xén xác định khu vực nơi
hình ảnh được chèn vào.

Hình chữ nhật nguồn và đích được xác định ngay cả khi thiết bị không
hỗ trợ mở rộng quy mô hoặc ZZ0000ZZ và
ZZ0001ZZ ioctls. Kích thước của chúng (và vị trí
nếu có) sẽ được khắc phục trong trường hợp này.

.. note::

   All capture and output devices that support the CROP or SELECTION
   API will also support the :ref:`VIDIOC_CROPCAP <VIDIOC_CROPCAP>`
   ioctl.

Cấu trúc cắt xén
===================


.. _crop-scale:

.. kernel-figure:: crop.svg
    :alt:    crop.svg
    :align:  center

    Image Cropping, Insertion and Scaling

    The cropping, insertion and scaling process



Đối với các thiết bị chụp, tọa độ của góc trên cùng bên trái, chiều rộng và
chiều cao của khu vực có thể lấy mẫu được đưa ra bởi ZZ0005ZZ
cấu trúc con của cấu trúc ZZ0000ZZ được trả về
bởi ZZ0001ZZ ioctl. Để hỗ trợ rộng rãi
phạm vi phần cứng, thông số kỹ thuật này không xác định nguồn gốc hoặc đơn vị.
Tuy nhiên, theo quy ước, trình điều khiển nên đếm các mẫu chưa được chia tỷ lệ theo chiều ngang
so với 0H (cạnh đầu của xung đồng bộ ngang, xem
ZZ0002ZZ). Số dòng ITU-R theo chiều dọc của trường đầu tiên
(xem đánh số dòng ITU R-525 cho ZZ0003ZZ và cho
ZZ0004ZZ), nhân hai nếu người lái xe
có thể chụp cả hai trường.

Góc trên cùng bên trái, chiều rộng và chiều cao của hình chữ nhật nguồn, tức là
khu vực thực sự được lấy mẫu, được cho bởi struct
ZZ0000ZZ sử dụng cùng hệ tọa độ như
cấu trúc ZZ0001ZZ. Các ứng dụng có thể sử dụng
ZZ0002ZZ và ZZ0003ZZ
ioctls để lấy và đặt hình chữ nhật này. Nó phải nằm hoàn toàn trong
nắm bắt ranh giới và trình điều khiển có thể điều chỉnh thêm kích thước được yêu cầu
và/hoặc vị trí theo giới hạn phần cứng.

Mỗi thiết bị chụp có một hình chữ nhật nguồn mặc định, được cung cấp bởi
Cấu trúc con ZZ0001ZZ của cấu trúc
ZZ0000ZZ. Tâm của hình chữ nhật này
phải căn chỉnh với tâm của vùng hình ảnh đang hoạt động của video
tín hiệu và bao gồm những gì người viết trình điều khiển coi là bức tranh hoàn chỉnh.
Trình điều khiển sẽ đặt lại hình chữ nhật nguồn về mặc định khi trình điều khiển
được tải đầu tiên, nhưng không được tải sau.

Đối với các thiết bị đầu ra, các cấu trúc và ioctls này được sử dụng tương ứng,
xác định hình chữ nhật ZZ0000ZZ nơi hình ảnh sẽ được chèn vào
tín hiệu video.


Điều chỉnh tỷ lệ
===================

Phần cứng video có thể có nhiều cách cắt, chèn và chia tỷ lệ khác nhau
những hạn chế. Nó chỉ có thể tăng hoặc giảm tỷ lệ, chỉ hỗ trợ tỷ lệ rời rạc
các yếu tố hoặc có khả năng mở rộng quy mô khác nhau theo chiều ngang và chiều dọc
hướng. Ngoài ra, nó có thể không hỗ trợ mở rộng quy mô. Đồng thời các
struct ZZ0000ZZ hình chữ nhật có thể phải được căn chỉnh,
và cả hình chữ nhật nguồn và đích có thể có phần trên và phần tùy ý
giới hạn kích thước thấp hơn. Đặc biệt là ZZ0003ZZ và ZZ0004ZZ tối đa trong
struct ZZ0001ZZ có thể nhỏ hơn struct
ZZ0002ZZ. Khu vực ZZ0005ZZ. Vì vậy, như
Thông thường, người lái xe phải điều chỉnh các thông số được yêu cầu và
trả về giá trị thực tế đã chọn.

Các ứng dụng có thể thay đổi hình chữ nhật nguồn hoặc đích trước tiên, như
họ có thể thích một kích thước hình ảnh cụ thể hoặc một khu vực nhất định trong video
tín hiệu. Nếu driver phải chỉnh cả 2 để thỏa mãn phần cứng
hạn chế, hình chữ nhật được yêu cầu cuối cùng sẽ được ưu tiên và
người lái xe tốt nhất nên điều chỉnh cái ngược lại. các
Tuy nhiên, ZZ0000ZZ ioctl sẽ không thay đổi
trạng thái trình điều khiển và do đó chỉ điều chỉnh hình chữ nhật được yêu cầu.

Giả sử tỷ lệ trên thiết bị quay video bị giới hạn ở hệ số 1:1
hoặc 2:1 theo một trong hai hướng và kích thước hình ảnh mục tiêu phải là bội số
có kích thước 16 × 16 pixel. Hình chữ nhật cắt nguồn được đặt thành mặc định,
cũng là giới hạn trên trong ví dụ này, là 640 × 400 pixel tại
offset 0, 0. Một ứng dụng yêu cầu kích thước hình ảnh là 300 × 225 pixel,
giả sử video sẽ được thu nhỏ lại từ "hình ảnh đầy đủ" tương ứng.
Trình điều khiển đặt kích thước hình ảnh ở giá trị gần nhất có thể là 304 × 224,
sau đó chọn hình chữ nhật cắt xén gần nhất với kích thước được yêu cầu,
là 608 × 224 (224 × 2:1 sẽ vượt quá giới hạn 400). Độ lệch 0, 0 là
vẫn còn hiệu lực nên chưa được sửa đổi. Cho hình chữ nhật cắt xén mặc định
được báo cáo bởi ZZ0000ZZ ứng dụng có thể
dễ dàng đề xuất một khoảng lệch khác để căn giữa hình chữ nhật cắt xén.

Bây giờ ứng dụng có thể yêu cầu bao phủ một khu vực bằng hình ảnh
tỷ lệ khung hình gần với yêu cầu ban đầu hơn nên nó yêu cầu cắt xén
hình chữ nhật có kích thước 608 × 456 pixel. Giới hạn hệ số tỷ lệ hiện tại
cắt xén thành 640×384 nên driver trả về kích thước cắt 608×384
và điều chỉnh kích thước hình ảnh gần nhất có thể là 304 × 192.


Ví dụ
========

Các hình chữ nhật nguồn và đích sẽ không thay đổi khi đóng và
mở lại một thiết bị, như vậy việc truyền dữ liệu vào hoặc ra khỏi thiết bị sẽ
làm việc mà không có sự chuẩn bị đặc biệt. Các ứng dụng nâng cao hơn nên
đảm bảo các tham số phù hợp trước khi bắt đầu I/O.

.. note::

   On the next two examples, a video capture device is assumed;
   change ``V4L2_BUF_TYPE_VIDEO_CAPTURE`` for other types of device.

Ví dụ: Đặt lại thông số cắt ảnh
==========================================

.. code-block:: c

    struct v4l2_cropcap cropcap;
    struct v4l2_crop crop;

    memset (&cropcap, 0, sizeof (cropcap));
    cropcap.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;

    if (-1 == ioctl (fd, VIDIOC_CROPCAP, &cropcap)) {
	perror ("VIDIOC_CROPCAP");
	exit (EXIT_FAILURE);
    }

    memset (&crop, 0, sizeof (crop));
    crop.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    crop.c = cropcap.defrect;

    /* Ignore if cropping is not supported (EINVAL). */

    if (-1 == ioctl (fd, VIDIOC_S_CROP, &crop)
	&& errno != EINVAL) {
	perror ("VIDIOC_S_CROP");
	exit (EXIT_FAILURE);
    }


Ví dụ: Thu nhỏ đơn giản
===========================

.. code-block:: c

    struct v4l2_cropcap cropcap;
    struct v4l2_format format;

    reset_cropping_parameters ();

    /* Scale down to 1/4 size of full picture. */

    memset (&format, 0, sizeof (format)); /* defaults */

    format.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;

    format.fmt.pix.width = cropcap.defrect.width >> 1;
    format.fmt.pix.height = cropcap.defrect.height >> 1;
    format.fmt.pix.pixelformat = V4L2_PIX_FMT_YUYV;

    if (-1 == ioctl (fd, VIDIOC_S_FMT, &format)) {
	perror ("VIDIOC_S_FORMAT");
	exit (EXIT_FAILURE);
    }

    /* We could check the actual image size now, the actual scaling factor
       or if the driver can scale at all. */

Ví dụ: Chọn vùng đầu ra
=================================

.. note:: This example assumes an output device.

.. code-block:: c

    struct v4l2_cropcap cropcap;
    struct v4l2_crop crop;

    memset (&cropcap, 0, sizeof (cropcap));
    cropcap.type = V4L2_BUF_TYPE_VIDEO_OUTPUT;

    if (-1 == ioctl (fd, VIDIOC_CROPCAP;, &cropcap)) {
	perror ("VIDIOC_CROPCAP");
	exit (EXIT_FAILURE);
    }

    memset (&crop, 0, sizeof (crop));

    crop.type = V4L2_BUF_TYPE_VIDEO_OUTPUT;
    crop.c = cropcap.defrect;

    /* Scale the width and height to 50 % of their original size
       and center the output. */

    crop.c.width /= 2;
    crop.c.height /= 2;
    crop.c.left += crop.c.width / 2;
    crop.c.top += crop.c.height / 2;

    /* Ignore if cropping is not supported (EINVAL). */

    if (-1 == ioctl (fd, VIDIOC_S_CROP, &crop)
	&& errno != EINVAL) {
	perror ("VIDIOC_S_CROP");
	exit (EXIT_FAILURE);
    }

Ví dụ: Hệ số tỷ lệ hiện tại và khía cạnh pixel
================================================

.. note:: This example assumes a video capture device.

.. code-block:: c

    struct v4l2_cropcap cropcap;
    struct v4l2_crop crop;
    struct v4l2_format format;
    double hscale, vscale;
    double aspect;
    int dwidth, dheight;

    memset (&cropcap, 0, sizeof (cropcap));
    cropcap.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;

    if (-1 == ioctl (fd, VIDIOC_CROPCAP, &cropcap)) {
	perror ("VIDIOC_CROPCAP");
	exit (EXIT_FAILURE);
    }

    memset (&crop, 0, sizeof (crop));
    crop.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;

    if (-1 == ioctl (fd, VIDIOC_G_CROP, &crop)) {
	if (errno != EINVAL) {
	    perror ("VIDIOC_G_CROP");
	    exit (EXIT_FAILURE);
	}

	/* Cropping not supported. */
	crop.c = cropcap.defrect;
    }

    memset (&format, 0, sizeof (format));
    format.fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;

    if (-1 == ioctl (fd, VIDIOC_G_FMT, &format)) {
	perror ("VIDIOC_G_FMT");
	exit (EXIT_FAILURE);
    }

    /* The scaling applied by the driver. */

    hscale = format.fmt.pix.width / (double) crop.c.width;
    vscale = format.fmt.pix.height / (double) crop.c.height;

    aspect = cropcap.pixelaspect.numerator /
	 (double) cropcap.pixelaspect.denominator;
    aspect = aspect * hscale / vscale;

    /* Devices following ITU-R BT.601 do not capture
       square pixels. For playback on a computer monitor
       we should scale the images to this size. */

    dwidth = format.fmt.pix.width / aspect;
    dheight = format.fmt.pix.height;