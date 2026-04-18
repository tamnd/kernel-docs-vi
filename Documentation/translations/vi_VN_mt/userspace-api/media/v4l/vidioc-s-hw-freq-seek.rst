.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-s-hw-freq-seek.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_S_HW_FREQ_SEEK:

****************************
ioctl VIDIOC_S_HW_FREQ_SEEK
***************************

Tên
====

VIDIOC_S_HW_FREQ_SEEK - Thực hiện tìm kiếm tần số phần cứng

Tóm tắt
========

.. c:macro:: VIDIOC_S_HW_FREQ_SEEK

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Bắt đầu tìm kiếm tần số phần cứng từ tần số hiện tại. Để làm điều này
các ứng dụng khởi tạo ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ,
Các trường ZZ0004ZZ, ZZ0005ZZ, ZZ0006ZZ và ZZ0007ZZ, và
loại bỏ mảng ZZ0008ZZ của cấu trúc
ZZ0000ZZ và gọi
ZZ0009ZZ ioctl với một con trỏ tới cấu trúc này.

Các trường ZZ0003ZZ và ZZ0004ZZ có thể được đặt thành giá trị khác 0
để yêu cầu người lái xe tìm kiếm một ban nhạc cụ thể. Nếu cấu trúc
Trường ZZ0000ZZ ZZ0005ZZ có
Đã đặt cờ ZZ0006ZZ, các giá trị này phải giảm
trong một trong các dải được trả về bởi
ZZ0001ZZ. Nếu
Cờ ZZ0007ZZ không được đặt thì các giá trị này
phải khớp chính xác với các dải của một trong các dải được trả về bởi
ZZ0002ZZ. Nếu
tần số hiện tại của bộ điều chỉnh không nằm trong dải đã chọn
sẽ được kẹp để vừa với dải trước khi bắt đầu tìm kiếm.

Nếu trả về lỗi thì tần số ban đầu sẽ được khôi phục.

Ioctl này được hỗ trợ nếu khả năng ZZ0000ZZ là
thiết lập.

Nếu ioctl này được gọi từ tước hiệu tệp không chặn thì ZZ0000ZZ
mã lỗi được trả về và không có quá trình tìm kiếm nào diễn ra.

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. c:type:: v4l2_hw_freq_seek

.. flat-table:: struct v4l2_hw_freq_seek
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``tuner``
      - The tuner index number. This is the same value as in the struct
	:c:type:`v4l2_input` ``tuner`` field and the struct
	:c:type:`v4l2_tuner` ``index`` field.
    * - __u32
      - ``type``
      - The tuner type. This is the same value as in the struct
	:c:type:`v4l2_tuner` ``type`` field. See
	:c:type:`v4l2_tuner_type`
    * - __u32
      - ``seek_upward``
      - If non-zero, seek upward from the current frequency, else seek
	downward.
    * - __u32
      - ``wrap_around``
      - If non-zero, wrap around when at the end of the frequency range,
	else stop seeking. The struct :c:type:`v4l2_tuner`
	``capability`` field will tell you what the hardware supports.
    * - __u32
      - ``spacing``
      - If non-zero, defines the hardware seek resolution in Hz. The
	driver selects the nearest value that is supported by the device.
	If spacing is zero a reasonable default value is used.
    * - __u32
      - ``rangelow``
      - If non-zero, the lowest tunable frequency of the band to search in
	units of 62.5 kHz, or if the struct
	:c:type:`v4l2_tuner` ``capability`` field has the
	``V4L2_TUNER_CAP_LOW`` flag set, in units of 62.5 Hz or if the
	struct :c:type:`v4l2_tuner` ``capability`` field has
	the ``V4L2_TUNER_CAP_1HZ`` flag set, in units of 1 Hz. If
	``rangelow`` is zero a reasonable default value is used.
    * - __u32
      - ``rangehigh``
      - If non-zero, the highest tunable frequency of the band to search
	in units of 62.5 kHz, or if the struct
	:c:type:`v4l2_tuner` ``capability`` field has the
	``V4L2_TUNER_CAP_LOW`` flag set, in units of 62.5 Hz or if the
	struct :c:type:`v4l2_tuner` ``capability`` field has
	the ``V4L2_TUNER_CAP_1HZ`` flag set, in units of 1 Hz. If
	``rangehigh`` is zero a reasonable default value is used.
    * - __u32
      - ``reserved``\ [5]
      - Reserved for future extensions. Applications must set the array to
	zero.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Chỉ số ZZ0000ZZ nằm ngoài giới hạn, giá trị ZZ0001ZZ là
    không được hỗ trợ hoặc một trong các giá trị trong ZZ0002ZZ, ZZ0003ZZ hoặc
    Các trường ZZ0004ZZ sai.

EAGAIN
    Đã cố gọi ZZ0000ZZ bằng tước hiệu tệp trong
    chế độ không chặn.

ENODATA
    Tìm kiếm phần cứng không tìm thấy kênh nào.

EBUSY
    Một cuộc tìm kiếm phần cứng khác đang được tiến hành.