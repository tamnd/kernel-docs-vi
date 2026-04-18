.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-g-audio.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_G_AUDIO:

*************************************
ioctl VIDIOC_G_AUDIO, VIDIOC_S_AUDIO
************************************

Tên
====

VIDIOC_G_AUDIO - VIDIOC_S_AUDIO - Truy vấn hoặc chọn đầu vào âm thanh hiện tại và các thuộc tính của nó

Tóm tắt
========

.. c:macro:: VIDIOC_G_AUDIO

ZZ0000ZZ

.. c:macro:: VIDIOC_S_AUDIO

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Để truy vấn các ứng dụng đầu vào âm thanh hiện tại, hãy loại bỏ ZZ0002ZZ
mảng của cấu trúc ZZ0000ZZ và gọi
ZZ0001ZZ ioctl với một con trỏ tới cấu trúc này. Trình điều khiển điền
phần còn lại của cấu trúc hoặc trả về mã lỗi ZZ0003ZZ khi thiết bị
không có đầu vào âm thanh hoặc không có đầu vào nào kết hợp với đầu vào video hiện tại.

Đầu vào âm thanh có một thuộc tính có thể ghi được, đó là chế độ âm thanh. Để chọn
đầu vào âm thanh hiện tại ZZ0005ZZ thay đổi chế độ âm thanh, khởi chạy ứng dụng
các trường ZZ0002ZZ và ZZ0003ZZ và mảng ZZ0004ZZ của một
cấu trúc ZZ0000ZZ và gọi ZZ0001ZZ
ioctl. Trình điều khiển có thể chuyển sang chế độ âm thanh khác nếu có yêu cầu
không thể hài lòng được. Tuy nhiên, đây là ioctl chỉ ghi, nó không
trả lại chế độ âm thanh mới thực tế.

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. c:type:: v4l2_audio

.. flat-table:: struct v4l2_audio
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``index``
      - Identifies the audio input, set by the driver or application.
    * - __u8
      - ``name``\ [32]
      - Name of the audio input, a NUL-terminated ASCII string, for
	example: "Line In". This information is intended for the user,
	preferably the connector label on the device itself.
    * - __u32
      - ``capability``
      - Audio capability flags, see :ref:`audio-capability`.
    * - __u32
      - ``mode``
      - Audio mode flags set by drivers and applications (on
	:ref:`VIDIOC_S_AUDIO <VIDIOC_G_AUDIO>` ioctl), see :ref:`audio-mode`.
    * - __u32
      - ``reserved``\ [2]
      - Reserved for future extensions. Drivers and applications must set
	the array to zero.


.. tabularcolumns:: |p{6.6cm}|p{2.2cm}|p{8.5cm}|

.. _audio-capability:

.. flat-table:: Audio Capability Flags
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * - ``V4L2_AUDCAP_STEREO``
      - 0x00001
      - This is a stereo input. The flag is intended to automatically
	disable stereo recording etc. when the signal is always monaural.
	The API provides no means to detect if stereo is *received*,
	unless the audio input belongs to a tuner.
    * - ``V4L2_AUDCAP_AVL``
      - 0x00002
      - Automatic Volume Level mode is supported.


.. tabularcolumns:: |p{6.6cm}|p{2.2cm}|p{8.5cm}|

.. _audio-mode:

.. flat-table:: Audio Mode Flags
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * - ``V4L2_AUDMODE_AVL``
      - 0x00001
      - AVL mode is on.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Không có đầu vào âm thanh nào kết hợp với đầu vào video hiện tại hoặc số
    của đầu vào âm thanh đã chọn nằm ngoài giới hạn hoặc không kết hợp.