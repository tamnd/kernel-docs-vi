.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-create-bufs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_CREATE_BUFS:

*************************
ioctl VIDIOC_CREATE_BUFS
*************************

Tên
====

VIDIOC_CREATE_BUFS - Tạo bộ đệm cho Bộ nhớ được ánh xạ hoặc Con trỏ người dùng hoặc I/O bộ đệm DMA

Tóm tắt
========

.. c:macro:: VIDIOC_CREATE_BUFS

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Ioctl này được sử dụng để tạo bộ đệm cho ZZ0000ZZ
hoặc I/O ZZ0001ZZ hoặc ZZ0002ZZ. Nó
có thể được sử dụng thay thế hoặc bổ sung cho
ZZ0003ZZ ioctl, khi kiểm soát chặt chẽ hơn
trên bộ đệm là cần thiết. Ioctl này có thể được gọi nhiều lần để
tạo bộ đệm có kích thước khác nhau.

Để phân bổ bộ đệm thiết bị, các ứng dụng phải khởi tạo các tập tin liên quan
các trường của cấu trúc ZZ0000ZZ. các
Trường ZZ0001ZZ phải được đặt thành số lượng bộ đệm được yêu cầu,
Trường ZZ0002ZZ chỉ định phương thức I/O được yêu cầu và ZZ0003ZZ
mảng phải bằng 0.

Trường ZZ0003ZZ chỉ định định dạng hình ảnh mà bộ đệm phải có
có khả năng xử lý. Ứng dụng phải điền vào cấu trúc này
ZZ0000ZZ. Thông thường việc này sẽ được thực hiện bằng cách sử dụng
ZZ0001ZZ hoặc
ZZ0002ZZ ioctls để đảm bảo rằng
định dạng được yêu cầu được hỗ trợ bởi trình điều khiển. Dựa vào định dạng của
Trường ZZ0004ZZ kích thước bộ đệm được yêu cầu (đối với mặt phẳng đơn) hoặc mặt phẳng
kích thước (đối với định dạng nhiều mặt phẳng) sẽ được sử dụng cho bộ đệm được phân bổ.
Trình điều khiển có thể trả về lỗi nếu (các) kích thước không được hỗ trợ bởi
phần cứng (thường là do chúng quá nhỏ).

Bộ đệm được tạo bởi ioctl này sẽ có kích thước tối thiểu bằng kích thước
được xác định bởi trường ZZ0000ZZ (hoặc trường tương ứng
các trường cho các loại định dạng khác). Thông thường nếu ZZ0001ZZ
trường nhỏ hơn mức tối thiểu được yêu cầu cho định dạng đã cho thì
lỗi sẽ được trả về vì trình điều khiển thường không cho phép điều này. Nếu
nó lớn hơn thì giá trị sẽ được sử dụng nguyên trạng. Nói cách khác, sự
trình điều khiển có thể từ chối kích thước được yêu cầu, nhưng nếu nó được chấp nhận thì trình điều khiển
sẽ sử dụng nó không thay đổi.

Khi ioctl được gọi với một con trỏ tới cấu trúc này, trình điều khiển
sẽ cố gắng phân bổ số lượng bộ đệm được yêu cầu và lưu trữ
số thực tế được phân bổ và chỉ mục bắt đầu trong ZZ0000ZZ và
các trường ZZ0001ZZ tương ứng. Khi trả lại ZZ0002ZZ có thể nhỏ hơn
hơn số lượng yêu cầu.

.. c:type:: v4l2_create_buffers

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. flat-table:: struct v4l2_create_buffers
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``index``
      - The starting buffer index, returned by the driver.
    * - __u32
      - ``count``
      - The number of buffers requested or granted. If count == 0, then
	:ref:`VIDIOC_CREATE_BUFS` will set ``index`` to the current number of
	created buffers, and it will check the validity of ``memory`` and
	``format.type``. If those are invalid -1 is returned and errno is
	set to ``EINVAL`` error code, otherwise :ref:`VIDIOC_CREATE_BUFS` returns
	0. It will never set errno to ``EBUSY`` error code in this particular
	case.
    * - __u32
      - ``memory``
      - Applications set this field to ``V4L2_MEMORY_MMAP``,
	``V4L2_MEMORY_DMABUF`` or ``V4L2_MEMORY_USERPTR``. See
	:c:type:`v4l2_memory`
    * - struct :c:type:`v4l2_format`
      - ``format``
      - Filled in by the application, preserved by the driver.
    * - __u32
      - ``capabilities``
      - Set by the driver. If 0, then the driver doesn't support
        capabilities. In that case all you know is that the driver is
	guaranteed to support ``V4L2_MEMORY_MMAP`` and *might* support
	other :c:type:`v4l2_memory` types. It will not support any other
	capabilities. See :ref:`here <v4l2-buf-capabilities>` for a list of the
	capabilities.

	If you want to just query the capabilities without making any
	other changes, then set ``count`` to 0, ``memory`` to
	``V4L2_MEMORY_MMAP`` and ``format.type`` to the buffer type.

    * - __u32
      - ``flags``
      - Specifies additional buffer management attributes.
	See :ref:`memory-flags`.
    * - __u32
      - ``max_num_buffers``
      - If the V4L2_BUF_CAP_SUPPORTS_MAX_NUM_BUFFERS capability flag is set
        this field indicates the maximum possible number of buffers
        for this queue.
    * - __u32
      - ``reserved``\ [5]
      - A place holder for future extensions. Drivers and applications
	must set the array to zero.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

ENOMEM
    Không có bộ nhớ để phân bổ bộ đệm cho I/O ZZ0000ZZ.

EINVAL
    Loại bộ đệm (trường ZZ0000ZZ), phương thức I/O được yêu cầu
    (ZZ0001ZZ) hoặc định dạng (trường ZZ0002ZZ) không hợp lệ.