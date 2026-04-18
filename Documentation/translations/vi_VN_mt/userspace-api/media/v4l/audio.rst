.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/audio.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _audio:

*************************
Đầu vào và đầu ra âm thanh
************************

Đầu vào và đầu ra âm thanh là các đầu nối vật lý của thiết bị. Video
thiết bị chụp có đầu vào, thiết bị đầu ra có đầu ra, không hoặc nhiều hơn
mỗi cái. Thiết bị vô tuyến không có đầu vào hoặc đầu ra âm thanh. Họ có chính xác
một bộ chỉnh âm mà trên thực tế ZZ0000ZZ là một nguồn âm thanh, nhưng API này liên kết
bộ điều chỉnh chỉ có đầu vào hoặc đầu ra video và các thiết bị vô tuyến không có
những cái này. [#f1]_ Đầu nối trên card TV để lặp lại âm thanh đã nhận
tín hiệu tới card âm thanh không được coi là đầu ra âm thanh.

Đầu vào và đầu ra âm thanh và video được liên kết. Chọn một video
source cũng chọn một nguồn âm thanh. Điều này thể hiện rõ nhất khi video
và nguồn âm thanh là một bộ chỉnh âm. Các đầu nối âm thanh khác có thể kết hợp với
nhiều hơn một đầu vào hoặc đầu ra video. Giả sử có hai đầu vào video tổng hợp
và tồn tại hai đầu vào âm thanh, có thể có tối đa bốn kết hợp hợp lệ.
Mối quan hệ của các đầu nối video và âm thanh được xác định trong
Trường ZZ0002ZZ của cấu trúc tương ứng
ZZ0000ZZ hoặc cấu trúc
ZZ0001ZZ, trong đó mỗi bit đại diện cho chỉ mục
số, bắt đầu từ 0, của một đầu vào hoặc đầu ra âm thanh.

Để tìm hiểu về số lượng và thuộc tính của các đầu vào có sẵn và
các ứng dụng đầu ra có thể liệt kê chúng bằng
ZZ0000ZZ và
ZZ0001ZZ ioctl tương ứng.
Cấu trúc ZZ0002ZZ được trả về bởi
ZZ0003ZZ ioctl cũng chứa tín hiệu
thông tin trạng thái áp dụng khi truy vấn đầu vào âm thanh hiện tại.

ZZ0000ZZ và
ZZ0001ZZ ioctls báo cáo hiện tại
đầu vào và đầu ra âm thanh tương ứng.

.. note::

   Note that, unlike :ref:`VIDIOC_G_INPUT <VIDIOC_G_INPUT>` and
   :ref:`VIDIOC_G_OUTPUT <VIDIOC_G_OUTPUT>` these ioctls return a
   structure as :ref:`VIDIOC_ENUMAUDIO` and
   :ref:`VIDIOC_ENUMAUDOUT <VIDIOC_ENUMAUDOUT>` do, not just an index.

Để chọn đầu vào âm thanh và thay đổi các thuộc tính của nó, các ứng dụng hãy gọi
ZZ0000ZZ ioctl. Để chọn một âm thanh
lệnh gọi ứng dụng đầu ra (hiện tại không có thuộc tính có thể thay đổi)
ZZ0001ZZ ioctl.

Trình điều khiển phải triển khai tất cả ioctls đầu vào âm thanh khi thiết bị có
nhiều đầu vào âm thanh có thể lựa chọn, tất cả ioctls đầu ra âm thanh khi
thiết bị có nhiều đầu ra âm thanh có thể lựa chọn. Khi thiết bị có bất kỳ
đầu vào hoặc đầu ra âm thanh, trình điều khiển phải đặt cờ ZZ0002ZZ
trong cấu trúc ZZ0000ZZ được trả về bởi
ZZ0001ZZ ioctl.


Ví dụ: Thông tin về đầu vào âm thanh hiện tại
==================================================

.. code-block:: c

    struct v4l2_audio audio;

    memset(&audio, 0, sizeof(audio));

    if (-1 == ioctl(fd, VIDIOC_G_AUDIO, &audio)) {
	perror("VIDIOC_G_AUDIO");
	exit(EXIT_FAILURE);
    }

    printf("Current input: %s\\n", audio.name);


Ví dụ: Chuyển sang đầu vào âm thanh đầu tiên
===========================================

.. code-block:: c

    struct v4l2_audio audio;

    memset(&audio, 0, sizeof(audio)); /* clear audio.mode, audio.reserved */

    audio.index = 0;

    if (-1 == ioctl(fd, VIDIOC_S_AUDIO, &audio)) {
	perror("VIDIOC_S_AUDIO");
	exit(EXIT_FAILURE);
    }

.. [#f1]
   Actually struct :c:type:`v4l2_audio` ought to have a
   ``tuner`` field like struct :c:type:`v4l2_input`, not
   only making the API more consistent but also permitting radio devices
   with multiple tuners.