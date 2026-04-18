.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/video.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _video:

*************************
Đầu vào và đầu ra video
*************************

Đầu vào và đầu ra video là các đầu nối vật lý của thiết bị. Những cái này có thể
ví dụ: Đầu nối RF (ăng-ten/cáp), CVBS hay còn gọi là Composite
Đầu nối Video, S-Video và RGB. Cảm biến máy ảnh cũng được coi là
trở thành đầu vào video. Thiết bị quay video và VBI có đầu vào. Video và
Thiết bị đầu ra VBI có ít nhất một đầu ra. Thiết bị vô tuyến có
không có đầu vào hoặc đầu ra video.

Để tìm hiểu về số lượng và thuộc tính của các đầu vào có sẵn và
các ứng dụng đầu ra có thể liệt kê chúng bằng
ZZ0000ZZ và
ZZ0001ZZ ioctl tương ứng. các
struct ZZ0002ZZ được trả về bởi
ZZ0003ZZ ioctl cũng chứa tín hiệu
thông tin trạng thái áp dụng khi truy vấn đầu vào video hiện tại.

ZZ0000ZZ và
ZZ0001ZZ ioctls trả về chỉ mục của
đầu vào hoặc đầu ra video hiện tại. Để chọn đầu vào hoặc đầu ra khác
các ứng dụng gọi ZZ0002ZZ và
ZZ0003ZZ ioctls. Người lái xe phải
triển khai tất cả ioctls đầu vào khi thiết bị có một hoặc nhiều đầu vào,
tất cả các ioctls đầu ra khi thiết bị có một hoặc nhiều đầu ra.

Ví dụ: Thông tin về đầu vào video hiện tại
==================================================

.. code-block:: c

    struct v4l2_input input;
    int index;

    if (-1 == ioctl(fd, VIDIOC_G_INPUT, &index)) {
	perror("VIDIOC_G_INPUT");
	exit(EXIT_FAILURE);
    }

    memset(&input, 0, sizeof(input));
    input.index = index;

    if (-1 == ioctl(fd, VIDIOC_ENUMINPUT, &input)) {
	perror("VIDIOC_ENUMINPUT");
	exit(EXIT_FAILURE);
    }

    printf("Current input: %s\\n", input.name);


Ví dụ: Chuyển sang đầu vào video đầu tiên
===========================================

.. code-block:: c

    int index;

    index = 0;

    if (-1 == ioctl(fd, VIDIOC_S_INPUT, &index)) {
	perror("VIDIOC_S_INPUT");
	exit(EXIT_FAILURE);
    }