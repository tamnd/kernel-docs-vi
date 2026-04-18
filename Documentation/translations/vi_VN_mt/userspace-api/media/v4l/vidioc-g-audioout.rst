.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-g-audioout.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_G_AUDOUT:

*************************************
ioctl VIDIOC_G_AUDOUT, VIDIOC_S_AUDOUT
**************************************

Tên
====

VIDIOC_G_AUDOUT - VIDIOC_S_AUDOUT - Truy vấn hoặc chọn đầu ra âm thanh hiện tại

Tóm tắt
========

.. c:macro:: VIDIOC_G_AUDOUT

ZZ0000ZZ

.. c:macro:: VIDIOC_S_AUDOUT

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Để truy vấn các ứng dụng đầu ra âm thanh hiện tại, hãy loại bỏ ZZ0001ZZ
mảng của cấu trúc ZZ0000ZZ và gọi
ZZ0002ZZ ioctl với một con trỏ tới cấu trúc này. Trình điều khiển điền
phần còn lại của cấu trúc hoặc trả về mã lỗi ZZ0003ZZ khi thiết bị
không có đầu vào âm thanh hoặc không có đầu vào nào kết hợp với video hiện tại
đầu ra.

Đầu ra âm thanh không có thuộc tính có thể ghi. Tuy nhiên, để lựa chọn
các ứng dụng đầu ra âm thanh hiện tại có thể khởi tạo trường ZZ0001ZZ và
Mảng ZZ0002ZZ (trong tương lai có thể chứa các thuộc tính có thể ghi)
của cấu trúc ZZ0000ZZ struct và gọi
ZZ0003ZZ ioctl. Trình điều khiển chuyển sang đầu ra được yêu cầu hoặc
trả về mã lỗi ZZ0004ZZ khi chỉ số nằm ngoài giới hạn. Đây là một
ioctl chỉ ghi, nó không trả về thuộc tính đầu ra âm thanh hiện tại
như ZZ0005ZZ.

.. note::

   Connectors on a TV card to loop back the received audio signal
   to a sound card are not audio outputs in this sense.

.. c:type:: v4l2_audioout

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. flat-table:: struct v4l2_audioout
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``index``
      - Identifies the audio output, set by the driver or application.
    * - __u8
      - ``name``\ [32]
      - Name of the audio output, a NUL-terminated ASCII string, for
	example: "Line Out". This information is intended for the user,
	preferably the connector label on the device itself.
    * - __u32
      - ``capability``
      - Audio capability flags, none defined yet. Drivers must set this
	field to zero.
    * - __u32
      - ``mode``
      - Audio mode, none defined yet. Drivers and applications (on
	``VIDIOC_S_AUDOUT``) must set this field to zero.
    * - __u32
      - ``reserved``\ [2]
      - Reserved for future extensions. Drivers and applications must set
	the array to zero.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Không có đầu ra âm thanh nào kết hợp với đầu ra video hiện tại hoặc
    số lượng đầu ra âm thanh đã chọn nằm ngoài giới hạn hoặc không
    kết hợp.