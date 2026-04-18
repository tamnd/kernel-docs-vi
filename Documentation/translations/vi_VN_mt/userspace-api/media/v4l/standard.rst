.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/standard.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _standard:

****************
Tiêu chuẩn Video
****************

Các thiết bị video thường hỗ trợ một hoặc nhiều tiêu chuẩn video khác nhau hoặc
các biến thể của tiêu chuẩn. Mỗi đầu vào và đầu ra video có thể hỗ trợ một đầu vào khác
bộ tiêu chuẩn. Tập hợp này được báo cáo bởi trường ZZ0004ZZ của struct
ZZ0000ZZ và cấu trúc
ZZ0001ZZ được trả lại bởi
ZZ0002ZZ và
ZZ0003ZZ ioctls tương ứng.

V4L2 xác định một bit cho mỗi tiêu chuẩn video analog hiện đang được sử dụng
trên toàn thế giới và dành riêng các bit cho các tiêu chuẩn do trình điều khiển xác định, e. g.
tiêu chuẩn lai để xem băng video NTSC trên TV PAL và ngược lại.
Các ứng dụng có thể sử dụng các bit được xác định trước để chọn một
tiêu chuẩn, mặc dù việc trình bày cho người dùng một menu các tiêu chuẩn được hỗ trợ là
ưa thích. Để liệt kê và truy vấn các thuộc tính của hỗ trợ
các ứng dụng tiêu chuẩn sử dụng ZZ0000ZZ
ioctl.

Nhiều tiêu chuẩn được xác định trên thực tế chỉ là những biến thể của một vài tiêu chuẩn
tiêu chuẩn lớn. Trên thực tế, phần cứng có thể không phân biệt được chúng,
hoặc làm như vậy nội bộ và tự động chuyển đổi. Vì thế liệt kê
các tiêu chuẩn cũng chứa các tập hợp một hoặc nhiều bit tiêu chuẩn.

Giả sử một bộ điều chỉnh giả định có khả năng giải điều chế B/PAL, G/PAL và I/PAL
tín hiệu. Tiêu chuẩn được liệt kê đầu tiên là một bộ B và G/PAL, được chuyển đổi
tự động tùy thuộc vào tần số vô tuyến đã chọn trong UHF hoặc VHF
ban nhạc. Việc liệt kê đưa ra lựa chọn "PAL-B/G" hoặc "PAL-I". Tương tự một
Đầu vào tổng hợp có thể thu gọn các tiêu chuẩn, liệt kê "PAL-B/G/H/I",
"NTSC-M" và "SECAM-D/K". [#f1]_

Để truy vấn và chọn tiêu chuẩn được sử dụng bởi đầu vào video hiện tại hoặc
các ứng dụng đầu ra gọi ZZ0000ZZ và
ZZ0001ZZ ioctl tương ứng. các
Tiêu chuẩn ZZ0003ZZ có thể được cảm nhận bằng
ZZ0002ZZ ioctl.

.. note::

   The parameter of all these ioctls is a pointer to a
   :ref:`v4l2_std_id <v4l2-std-id>` type (a standard set), *not* an
   index into the standard enumeration. Drivers must implement all video
   standard ioctls when the device has one or more video inputs or outputs.

Các quy tắc đặc biệt áp dụng cho các thiết bị như máy ảnh USB trong đó khái niệm về
tiêu chuẩn video không có nhiều ý nghĩa. Tổng quát hơn cho bất kỳ việc chụp hoặc
thiết bị đầu ra đó là:

- không có khả năng chụp các trường hoặc khung ở tốc độ danh nghĩa của
   tiêu chuẩn video, hoặc

- điều đó hoàn toàn không hỗ trợ các định dạng tiêu chuẩn video.

Ở đây, trình điều khiển sẽ đặt trường ZZ0006ZZ của cấu trúc
ZZ0000ZZ và cấu trúc
ZZ0001ZZ về 0 và ZZ0002ZZ,
ZZ0003ZZ, ZZ0004ZZ và ZZ0005ZZ ioctls
sẽ trả về mã lỗi ZZ0007ZZ hoặc mã lỗi ZZ0008ZZ.

Các ứng dụng có thể sử dụng ZZ0000ZZ và
Cờ ZZ0001ZZ để xác định xem video có
ioctls tiêu chuẩn có thể được sử dụng với đầu vào hoặc đầu ra nhất định.

Ví dụ: Thông tin về chuẩn video hiện tại
=====================================================

.. code-block:: c

    v4l2_std_id std_id;
    struct v4l2_standard standard;

    if (-1 == ioctl(fd, VIDIOC_G_STD, &std_id)) {
	/* Note when VIDIOC_ENUMSTD always returns ENOTTY this
	   is no video device or it falls under the USB exception,
	   and VIDIOC_G_STD returning ENOTTY is no error. */

	perror("VIDIOC_G_STD");
	exit(EXIT_FAILURE);
    }

    memset(&standard, 0, sizeof(standard));
    standard.index = 0;

    while (0 == ioctl(fd, VIDIOC_ENUMSTD, &standard)) {
	if (standard.id & std_id) {
	       printf("Current video standard: %s\\n", standard.name);
	       exit(EXIT_SUCCESS);
	}

	standard.index++;
    }

    /* EINVAL indicates the end of the enumeration, which cannot be
       empty unless this device falls under the USB exception. */

    if (errno == EINVAL || standard.index == 0) {
	perror("VIDIOC_ENUMSTD");
	exit(EXIT_FAILURE);
    }

Ví dụ: Liệt kê các tiêu chuẩn video được hỗ trợ bởi đầu vào hiện tại
===================================================================

.. code-block:: c

    struct v4l2_input input;
    struct v4l2_standard standard;

    memset(&input, 0, sizeof(input));

    if (-1 == ioctl(fd, VIDIOC_G_INPUT, &input.index)) {
	perror("VIDIOC_G_INPUT");
	exit(EXIT_FAILURE);
    }

    if (-1 == ioctl(fd, VIDIOC_ENUMINPUT, &input)) {
	perror("VIDIOC_ENUM_INPUT");
	exit(EXIT_FAILURE);
    }

    printf("Current input %s supports:\\n", input.name);

    memset(&standard, 0, sizeof(standard));
    standard.index = 0;

    while (0 == ioctl(fd, VIDIOC_ENUMSTD, &standard)) {
	if (standard.id & input.std)
	    printf("%s\\n", standard.name);

	standard.index++;
    }

    /* EINVAL indicates the end of the enumeration, which cannot be
       empty unless this device falls under the USB exception. */

    if (errno != EINVAL || standard.index == 0) {
	perror("VIDIOC_ENUMSTD");
	exit(EXIT_FAILURE);
    }

Ví dụ: Chọn chuẩn video mới
=======================================

.. code-block:: c

    struct v4l2_input input;
    v4l2_std_id std_id;

    memset(&input, 0, sizeof(input));

    if (-1 == ioctl(fd, VIDIOC_G_INPUT, &input.index)) {
	perror("VIDIOC_G_INPUT");
	exit(EXIT_FAILURE);
    }

    if (-1 == ioctl(fd, VIDIOC_ENUMINPUT, &input)) {
	perror("VIDIOC_ENUM_INPUT");
	exit(EXIT_FAILURE);
    }

    if (0 == (input.std & V4L2_STD_PAL_BG)) {
	fprintf(stderr, "Oops. B/G PAL is not supported.\\n");
	exit(EXIT_FAILURE);
    }

    /* Note this is also supposed to work when only B
       or G/PAL is supported. */

    std_id = V4L2_STD_PAL_BG;

    if (-1 == ioctl(fd, VIDIOC_S_STD, &std_id)) {
	perror("VIDIOC_S_STD");
	exit(EXIT_FAILURE);
    }

.. [#f1]
   Some users are already confused by technical terms PAL, NTSC and
   SECAM. There is no point asking them to distinguish between B, G, D,
   or K when the software or hardware can do that automatically.