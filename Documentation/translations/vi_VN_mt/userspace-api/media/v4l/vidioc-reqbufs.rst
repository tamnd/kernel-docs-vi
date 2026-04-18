.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-reqbufs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_REQBUFS:

********************
ioctl VIDIOC_REQBUFS
********************

Tên
====

VIDIOC_REQBUFS - Khởi tạo ánh xạ bộ nhớ, I/O con trỏ người dùng hoặc I/O bộ đệm DMA

Tóm tắt
========

.. c:macro:: VIDIOC_REQBUFS

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Ioctl này được sử dụng để khởi tạo ZZ0000ZZ,
I/O dựa trên ZZ0001ZZ hoặc ZZ0002ZZ.
Bộ đệm được ánh xạ bộ nhớ được đặt trong bộ nhớ thiết bị và phải được phân bổ
với ioctl này trước khi chúng có thể được ánh xạ vào địa chỉ của ứng dụng
không gian. Bộ đệm người dùng được phân bổ bởi chính ứng dụng và điều này
ioctl chỉ được sử dụng để chuyển trình điều khiển sang chế độ I/O con trỏ người dùng và
để thiết lập một số cấu trúc bên trong. Tương tự, bộ đệm DMABUF là
được phân bổ bởi các ứng dụng thông qua trình điều khiển thiết bị và chỉ ioctl này
định cấu hình trình điều khiển sang chế độ I/O DMABUF mà không thực hiện bất kỳ thao tác trực tiếp nào
phân bổ.

Để phân bổ bộ đệm thiết bị, các ứng dụng hãy khởi tạo tất cả các trường của
cấu trúc ZZ0000ZZ. Họ đặt ZZ0001ZZ
trường thành luồng hoặc loại bộ đệm tương ứng, trường ZZ0002ZZ thành
số lượng bộ đệm mong muốn, ZZ0003ZZ phải được đặt thành số lượng bộ đệm được yêu cầu
Phương thức I/O và mảng ZZ0004ZZ phải bằng 0. Khi ioctl là
được gọi bằng một con trỏ tới cấu trúc này, trình điều khiển sẽ cố gắng
phân bổ số lượng bộ đệm được yêu cầu và nó lưu trữ số lượng thực tế
được phân bổ trong trường ZZ0005ZZ. Nó có thể nhỏ hơn số
được yêu cầu, thậm chí bằng 0, khi trình điều khiển hết bộ nhớ trống. Một cái lớn hơn
số này cũng có thể thực hiện được khi trình điều khiển yêu cầu nhiều bộ đệm hơn để
hoạt động chính xác. Ví dụ: đầu ra video yêu cầu ít nhất hai
bộ đệm, một bộ đệm được hiển thị và một bộ đệm được ứng dụng lấp đầy.

Khi phương thức I/O không được hỗ trợ, ioctl sẽ trả về lỗi ZZ0000ZZ
mã.

Các ứng dụng có thể gọi lại ZZ0000ZZ để thay đổi số lượng
bộ đệm. Lưu ý rằng nếu bất kỳ bộ đệm nào vẫn được ánh xạ hoặc xuất qua DMABUF,
thì ZZ0001ZZ chỉ có thể thành công nếu
Khả năng ZZ0004ZZ được thiết lập. Nếu không
ZZ0002ZZ sẽ trả về mã lỗi ZZ0005ZZ.
Nếu ZZ0006ZZ được đặt thì các bộ đệm này sẽ
mồ côi và sẽ được giải phóng khi chúng không được ánh xạ hoặc khi DMABUF được xuất
fds đã đóng cửa. Giá trị ZZ0007ZZ bằng 0 sẽ giải phóng hoặc loại bỏ tất cả các bộ đệm, sau
hủy bỏ hoặc hoàn thiện bất kỳ DMA nào đang được thực hiện, một ẩn ý
ZZ0003ZZ.

.. c:type:: v4l2_requestbuffers

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. cssclass:: longtable

.. flat-table:: struct v4l2_requestbuffers
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``count``
      - The number of buffers requested or granted.
    * - __u32
      - ``type``
      - Type of the stream or buffers, this is the same as the struct
	:c:type:`v4l2_format` ``type`` field. See
	:c:type:`v4l2_buf_type` for valid values.
    * - __u32
      - ``memory``
      - Applications set this field to ``V4L2_MEMORY_MMAP``,
	``V4L2_MEMORY_DMABUF`` or ``V4L2_MEMORY_USERPTR``. See
	:c:type:`v4l2_memory`.
    * - __u32
      - ``capabilities``
      - Set by the driver. If 0, then the driver doesn't support
        capabilities. In that case all you know is that the driver is
	guaranteed to support ``V4L2_MEMORY_MMAP`` and *might* support
	other :c:type:`v4l2_memory` types. It will not support any other
	capabilities.

	If you want to query the capabilities with a minimum of side-effects,
	then this can be called with ``count`` set to 0, ``memory`` set to
	``V4L2_MEMORY_MMAP`` and ``type`` set to the buffer type. This will
	free any previously allocated buffers, so this is typically something
	that will be done at the start of the application.
    * - __u8
      - ``flags``
      - Specifies additional buffer management attributes.
	See :ref:`memory-flags`.
    * - __u8
      - ``reserved``\ [3]
      - Reserved for future extensions.

.. _v4l2-buf-capabilities:
.. _V4L2-BUF-CAP-SUPPORTS-MMAP:
.. _V4L2-BUF-CAP-SUPPORTS-USERPTR:
.. _V4L2-BUF-CAP-SUPPORTS-DMABUF:
.. _V4L2-BUF-CAP-SUPPORTS-REQUESTS:
.. _V4L2-BUF-CAP-SUPPORTS-ORPHANED-BUFS:
.. _V4L2-BUF-CAP-SUPPORTS-M2M-HOLD-CAPTURE-BUF:
.. _V4L2-BUF-CAP-SUPPORTS-MMAP-CACHE-HINTS:
.. _V4L2-BUF-CAP-SUPPORTS-MAX-NUM-BUFFERS:
.. _V4L2-BUF-CAP-SUPPORTS-REMOVE-BUFS:

.. flat-table:: V4L2 Buffer Capabilities Flags
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * - ``V4L2_BUF_CAP_SUPPORTS_MMAP``
      - 0x00000001
      - This buffer type supports the ``V4L2_MEMORY_MMAP`` streaming mode.
    * - ``V4L2_BUF_CAP_SUPPORTS_USERPTR``
      - 0x00000002
      - This buffer type supports the ``V4L2_MEMORY_USERPTR`` streaming mode.
    * - ``V4L2_BUF_CAP_SUPPORTS_DMABUF``
      - 0x00000004
      - This buffer type supports the ``V4L2_MEMORY_DMABUF`` streaming mode.
    * - ``V4L2_BUF_CAP_SUPPORTS_REQUESTS``
      - 0x00000008
      - This buffer type supports :ref:`requests <media-request-api>`.
    * - ``V4L2_BUF_CAP_SUPPORTS_ORPHANED_BUFS``
      - 0x00000010
      - The kernel allows calling :ref:`VIDIOC_REQBUFS` while buffers are still
        mapped or exported via DMABUF. These orphaned buffers will be freed
        when they are unmapped or when the exported DMABUF fds are closed.
    * - ``V4L2_BUF_CAP_SUPPORTS_M2M_HOLD_CAPTURE_BUF``
      - 0x00000020
      - Only valid for stateless decoders. If set, then userspace can set the
        ``V4L2_BUF_FLAG_M2M_HOLD_CAPTURE_BUF`` flag to hold off on returning the
	capture buffer until the OUTPUT timestamp changes.
    * - ``V4L2_BUF_CAP_SUPPORTS_MMAP_CACHE_HINTS``
      - 0x00000040
      - This capability is set by the driver to indicate that the queue supports
        cache and memory management hints. However, it's only valid when the
        queue is used for :ref:`memory mapping <mmap>` streaming I/O. See
        :ref:`V4L2_BUF_FLAG_NO_CACHE_INVALIDATE <V4L2-BUF-FLAG-NO-CACHE-INVALIDATE>`,
        :ref:`V4L2_BUF_FLAG_NO_CACHE_CLEAN <V4L2-BUF-FLAG-NO-CACHE-CLEAN>` and
        :ref:`V4L2_MEMORY_FLAG_NON_COHERENT <V4L2-MEMORY-FLAG-NON-COHERENT>`.
    * - ``V4L2_BUF_CAP_SUPPORTS_MAX_NUM_BUFFERS``
      - 0x00000080
      - If set, then the ``max_num_buffers`` field in ``struct v4l2_create_buffers``
        is valid. If not set, then the maximum is ``VIDEO_MAX_FRAME`` buffers.
    * - ``V4L2_BUF_CAP_SUPPORTS_REMOVE_BUFS``
      - 0x00000100
      - If set, then ``VIDIOC_REMOVE_BUFS`` is supported.

.. _memory-flags:
.. _V4L2-MEMORY-FLAG-NON-COHERENT:

.. flat-table:: Memory Consistency Flags
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * - ``V4L2_MEMORY_FLAG_NON_COHERENT``
      - 0x00000001
      - A buffer is allocated either in coherent (it will be automatically
	coherent between the CPU and the bus) or non-coherent memory. The
	latter can provide performance gains, for instance the CPU cache
	sync/flush operations can be avoided if the buffer is accessed by the
	corresponding device only and the CPU does not read/write to/from that
	buffer. However, this requires extra care from the driver -- it must
	guarantee memory consistency by issuing a cache flush/sync when
	consistency is needed. If this flag is set V4L2 will attempt to
	allocate the buffer in non-coherent memory. The flag takes effect
	only if the buffer is used for :ref:`memory mapping <mmap>` I/O and the
	queue reports the :ref:`V4L2_BUF_CAP_SUPPORTS_MMAP_CACHE_HINTS
	<V4L2-BUF-CAP-SUPPORTS-MMAP-CACHE-HINTS>` capability.

.. raw:: latex

   \normalsize

Giá trị trả về
==============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Loại bộ đệm (trường ZZ0000ZZ) hoặc phương thức I/O được yêu cầu
    (ZZ0001ZZ) không được hỗ trợ.