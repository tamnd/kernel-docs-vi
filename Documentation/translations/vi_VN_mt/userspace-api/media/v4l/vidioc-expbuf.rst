.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-expbuf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_EXPBUF:

*******************
ioctl VIDIOC_EXPBUF
*******************

Tên
====

VIDIOC_EXPBUF - Xuất bộ đệm dưới dạng bộ mô tả tệp DMABUF.

Tóm tắt
========

.. c:macro:: VIDIOC_EXPBUF

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Ioctl này là phần mở rộng cho I/O ZZ0000ZZ
phương pháp này, do đó nó chỉ có sẵn cho bộ đệm ZZ0002ZZ.
Nó có thể được sử dụng để xuất bộ đệm dưới dạng tệp DMABUF bất kỳ lúc nào sau đó.
bộ đệm đã được phân bổ với
ZZ0001ZZ ioctl.

Để xuất bộ đệm, các ứng dụng điền vào struct
ZZ0000ZZ. Trường ZZ0005ZZ là
được đặt thành cùng loại bộ đệm như đã được sử dụng trước đó với struct
ZZ0001ZZ ZZ0006ZZ.
Các ứng dụng cũng phải đặt trường ZZ0007ZZ. Số chỉ mục hợp lệ
phạm vi từ 0 đến số lượng bộ đệm được phân bổ với
ZZ0002ZZ (cấu trúc
ZZ0003ZZ ZZ0008ZZ) trừ
một. Đối với API đa mặt phẳng, các ứng dụng đặt trường ZZ0009ZZ thành
chỉ số của máy bay sẽ được xuất khẩu. Các mặt phẳng hợp lệ nằm trong khoảng từ 0 đến
số lượng mặt phẳng hợp lệ tối đa cho định dạng hiện đang hoạt động. cho
API đơn phẳng, các ứng dụng phải đặt ZZ0010ZZ về 0.
Các cờ bổ sung có thể được đăng trong trường ZZ0011ZZ. Tham khảo sách hướng dẫn
for open() để biết chi tiết. Hiện tại chỉ có O_CLOEXEC, O_RDONLY, O_WRONLY,
và O_RDWR được hỗ trợ. Tất cả các trường khác phải được đặt thành 0. trong
trường hợp API đa mặt phẳng, mỗi mặt phẳng được xuất riêng bằng cách sử dụng
nhiều cuộc gọi ZZ0004ZZ.

Sau khi gọi ZZ0000ZZ, trường ZZ0002ZZ sẽ được đặt bởi một
người lái xe. Đây là bộ mô tả tệp DMABUF. Ứng dụng có thể chuyển nó tới
các thiết bị nhận biết DMABUF khác. Tham khảo ZZ0001ZZ
để biết chi tiết về cách nhập tệp DMABUF vào các nút V4L2. Đó là
nên đóng tệp DMABUF khi nó không còn được sử dụng để cho phép
bộ nhớ liên quan cần được thu hồi.

Ví dụ
========

.. code-block:: c

    int buffer_export(int v4lfd, enum v4l2_buf_type bt, int index, int *dmafd)
    {
	struct v4l2_exportbuffer expbuf;

	memset(&expbuf, 0, sizeof(expbuf));
	expbuf.type = bt;
	expbuf.index = index;
	if (ioctl(v4lfd, VIDIOC_EXPBUF, &expbuf) == -1) {
	    perror("VIDIOC_EXPBUF");
	    return -1;
	}

	*dmafd = expbuf.fd;

	return 0;
    }

.. code-block:: c

    int buffer_export_mp(int v4lfd, enum v4l2_buf_type bt, int index,
	int dmafd[], int n_planes)
    {
	int i;

	for (i = 0; i < n_planes; ++i) {
	    struct v4l2_exportbuffer expbuf;

	    memset(&expbuf, 0, sizeof(expbuf));
	    expbuf.type = bt;
	    expbuf.index = index;
	    expbuf.plane = i;
	    if (ioctl(v4lfd, VIDIOC_EXPBUF, &expbuf) == -1) {
		perror("VIDIOC_EXPBUF");
		while (i)
		    close(dmafd[--i]);
		return -1;
	    }
	    dmafd[i] = expbuf.fd;
	}

	return 0;
    }

.. c:type:: v4l2_exportbuffer

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. flat-table:: struct v4l2_exportbuffer
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``type``
      - Type of the buffer, same as struct
	:c:type:`v4l2_format` ``type`` or struct
	:c:type:`v4l2_requestbuffers` ``type``, set
	by the application. See :c:type:`v4l2_buf_type`
    * - __u32
      - ``index``
      - Number of the buffer, set by the application. This field is only
	used for :ref:`memory mapping <mmap>` I/O and can range from
	zero to the number of buffers allocated with the
	:ref:`VIDIOC_REQBUFS` and/or
	:ref:`VIDIOC_CREATE_BUFS` ioctls.
    * - __u32
      - ``plane``
      - Index of the plane to be exported when using the multi-planar API.
	Otherwise this value must be set to zero.
    * - __u32
      - ``flags``
      - Flags for the newly created file, currently only ``O_CLOEXEC``,
	``O_RDONLY``, ``O_WRONLY``, and ``O_RDWR`` are supported, refer to
	the manual of open() for more details.
    * - __s32
      - ``fd``
      - The DMABUF file descriptor associated with a buffer. Set by the
	driver.
    * - __u32
      - ``reserved[11]``
      - Reserved field for future use. Drivers and applications must set
	the array to zero.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Hàng đợi không ở chế độ MMAP hoặc việc xuất DMABUF không được hỗ trợ hoặc
    Các trường ZZ0000ZZ hoặc ZZ0001ZZ hoặc ZZ0002ZZ hoặc ZZ0003ZZ không hợp lệ.