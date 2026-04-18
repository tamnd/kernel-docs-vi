.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-g-enc-index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_G_ENC_INDEX:

*************************
ioctl VIDIOC_G_ENC_INDEX
************************

Tên
====

VIDIOC_G_ENC_INDEX - Nhận dữ liệu meta về luồng video nén

Tóm tắt
========

.. c:macro:: VIDIOC_G_ENC_INDEX

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

ZZ0000ZZ ioctl cung cấp dữ liệu meta về nén
luồng video tương tự hoặc ứng dụng khác hiện đang đọc từ
trình điều khiển, rất hữu ích cho việc truy cập ngẫu nhiên vào luồng mà không cần
giải mã nó.

Để đọc các ứng dụng dữ liệu phải gọi ZZ0000ZZ bằng một
con trỏ tới cấu trúc ZZ0001ZZ. Về thành công
trình điều khiển điền vào mảng ZZ0002ZZ, lưu trữ số phần tử
được viết trong trường ZZ0003ZZ và khởi tạo ZZ0004ZZ
lĩnh vực.

Mỗi phần tử của mảng ZZ0001ZZ chứa siêu dữ liệu về một
hình ảnh. Cuộc gọi ZZ0000ZZ đọc tối đa
Các mục nhập ZZ0002ZZ từ bộ đệm trình điều khiển, có thể chứa
vào các mục ZZ0003ZZ. Con số này có thể thấp hơn hoặc cao hơn
ZZ0004ZZ, nhưng không phải bằng không. Khi ứng dụng không thành công
đọc dữ liệu meta kịp thời, các mục cũ nhất sẽ bị mất. Khi
bộ đệm trống hoặc không có quá trình thu thập/mã hóa, ZZ0005ZZ
sẽ bằng không.

Hiện tại ioctl này chỉ được xác định cho các luồng chương trình MPEG-2 và
các luồng cơ bản video.

.. tabularcolumns:: |p{4.2cm}|p{6.2cm}|p{6.9cm}|

.. c:type:: v4l2_enc_idx

.. flat-table:: struct v4l2_enc_idx
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 3 8

    * - __u32
      - ``entries``
      - The number of entries the driver stored in the ``entry`` array.
    * - __u32
      - ``entries_cap``
      - The number of entries the driver can buffer. Must be greater than
	zero.
    * - __u32
      - ``reserved``\ [4]
      - Reserved for future extensions. Drivers must set the
	array to zero.
    * - struct :c:type:`v4l2_enc_idx_entry`
      - ``entry``\ [``V4L2_ENC_IDX_ENTRIES``]
      - Meta data about a compressed video stream. Each element of the
	array corresponds to one picture, sorted in ascending order by
	their ``offset``.


.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. c:type:: v4l2_enc_idx_entry

.. flat-table:: struct v4l2_enc_idx_entry
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u64
      - ``offset``
      - The offset in bytes from the beginning of the compressed video
	stream to the beginning of this picture, that is a *PES packet
	header* as defined in :ref:`mpeg2part1` or a *picture header* as
	defined in :ref:`mpeg2part2`. When the encoder is stopped, the
	driver resets the offset to zero.
    * - __u64
      - ``pts``
      - The 33 bit *Presentation Time Stamp* of this picture as defined in
	:ref:`mpeg2part1`.
    * - __u32
      - ``length``
      - The length of this picture in bytes.
    * - __u32
      - ``flags``
      - Flags containing the coding type of this picture, see
	:ref:`enc-idx-flags`.
    * - __u32
      - ``reserved``\ [2]
      - Reserved for future extensions. Drivers must set the array to
	zero.

.. tabularcolumns:: |p{6.6cm}|p{2.2cm}|p{8.5cm}|

.. _enc-idx-flags:

.. flat-table:: Index Entry Flags
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * - ``V4L2_ENC_IDX_FRAME_I``
      - 0x00
      - This is an Intra-coded picture.
    * - ``V4L2_ENC_IDX_FRAME_P``
      - 0x01
      - This is a Predictive-coded picture.
    * - ``V4L2_ENC_IDX_FRAME_B``
      - 0x02
      - This is a Bidirectionally predictive-coded picture.
    * - ``V4L2_ENC_IDX_FRAME_MASK``
      - 0x0F
      - *AND* the flags field with this mask to obtain the picture coding
	type.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.