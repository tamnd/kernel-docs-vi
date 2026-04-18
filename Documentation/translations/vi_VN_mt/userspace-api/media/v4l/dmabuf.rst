.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/dmabuf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _dmabuf:

*************************************
Truyền phát I/O (nhập bộ đệm DMA)
*************************************

Khung DMABUF cung cấp một phương thức chung để chia sẻ bộ đệm
giữa nhiều thiết bị. Trình điều khiển thiết bị hỗ trợ DMABUF có thể xuất
bộ đệm DMA cho không gian người dùng dưới dạng bộ mô tả tệp (được gọi là bộ xuất
vai trò), nhập bộ đệm DMA từ không gian người dùng bằng cách sử dụng bộ mô tả tệp
đã được xuất trước đó cho một thiết bị khác hoặc cùng một thiết bị (được gọi là
vai trò nhà nhập khẩu) hoặc cả hai. Phần này mô tả vai trò nhập khẩu DMABUF
API trong V4L2.

Tham khảo ZZ0000ZZ để biết chi tiết về
xuất bộ đệm V4L2 dưới dạng bộ mô tả tệp DMABUF.

Các thiết bị đầu vào và đầu ra hỗ trợ phương thức I/O truyền phát khi
Cờ ZZ0003ZZ trong trường ZZ0004ZZ của cấu trúc
ZZ0000ZZ được trả lại bởi
ZZ0001ZZ ioctl được thiết lập. liệu
hỗ trợ nhập bộ đệm DMA thông qua bộ mô tả tệp DMABUF
được xác định bằng cách gọi ZZ0002ZZ
ioctl với loại bộ nhớ được đặt thành ZZ0005ZZ.

Phương thức I/O này được dành riêng để chia sẻ bộ đệm DMA giữa các
các thiết bị, có thể là thiết bị V4L hoặc các thiết bị liên quan đến video khác (ví dụ:
DRM). Bộ đệm (mặt phẳng) được phân bổ bởi người lái xe thay mặt cho
ứng dụng. Tiếp theo, các bộ đệm này được xuất sang ứng dụng dưới dạng tệp
bộ mô tả bằng cách sử dụng API dành riêng cho trình điều khiển cấp phát. Chỉ
bộ mô tả tập tin như vậy được trao đổi. Các mô tả và siêu thông tin
được truyền vào struct ZZ0000ZZ (hoặc trong struct
ZZ0001ZZ trong trường hợp API đa mặt phẳng). các
trình điều khiển phải được chuyển sang chế độ I/O DMABUF bằng cách gọi
ZZ0002ZZ với loại bộ đệm mong muốn.

Ví dụ: Bắt đầu truyền phát I/O bằng bộ mô tả tệp DMABUF
==============================================================

.. code-block:: c

    struct v4l2_requestbuffers reqbuf;

    memset(&reqbuf, 0, sizeof (reqbuf));
    reqbuf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    reqbuf.memory = V4L2_MEMORY_DMABUF;
    reqbuf.count = 1;

    if (ioctl(fd, VIDIOC_REQBUFS, &reqbuf) == -1) {
	if (errno == EINVAL)
	    printf("Video capturing or DMABUF streaming is not supported\\n");
	else
	    perror("VIDIOC_REQBUFS");

	exit(EXIT_FAILURE);
    }

Bộ mô tả tệp bộ đệm (mặt phẳng) được truyền nhanh chóng với
ZZ0000ZZ ioctl. Trong trường hợp đa mặt phẳng
bộ đệm, mỗi mặt phẳng có thể được liên kết với một DMABUF khác nhau
mô tả. Mặc dù bộ đệm thường được tuần hoàn nhưng các ứng dụng có thể vượt qua
một bộ mô tả DMABUF khác nhau ở mỗi lệnh gọi ZZ0001ZZ.

Ví dụ: Xếp hàng DMABUF sử dụng mặt phẳng đơn API
================================================

.. code-block:: c

    int buffer_queue(int v4lfd, int index, int dmafd)
    {
	struct v4l2_buffer buf;

	memset(&buf, 0, sizeof buf);
	buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
	buf.memory = V4L2_MEMORY_DMABUF;
	buf.index = index;
	buf.m.fd = dmafd;

	if (ioctl(v4lfd, VIDIOC_QBUF, &buf) == -1) {
	    perror("VIDIOC_QBUF");
	    return -1;
	}

	return 0;
    }

Ví dụ 3.6. Xếp hàng DMABUF sử dụng nhiều mặt phẳng API
======================================================

.. code-block:: c

    int buffer_queue_mp(int v4lfd, int index, int dmafd[], int n_planes)
    {
	struct v4l2_buffer buf;
	struct v4l2_plane planes[VIDEO_MAX_PLANES];
	int i;

	memset(&buf, 0, sizeof buf);
	buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
	buf.memory = V4L2_MEMORY_DMABUF;
	buf.index = index;
	buf.m.planes = planes;
	buf.length = n_planes;

	memset(&planes, 0, sizeof planes);

	for (i = 0; i < n_planes; ++i)
	    buf.m.planes[i].m.fd = dmafd[i];

	if (ioctl(v4lfd, VIDIOC_QBUF, &buf) == -1) {
	    perror("VIDIOC_QBUF");
	    return -1;
	}

	return 0;
    }

Bộ đệm được chụp hoặc hiển thị sẽ được loại bỏ bằng
ZZ0000ZZ ioctl. Người lái xe có thể mở khóa
đệm bất cứ lúc nào từ khi hoàn thành DMA đến ioctl này. các
bộ nhớ cũng được mở khóa khi
ZZ0001ZZ được gọi là,
ZZ0002ZZ hoặc khi đóng thiết bị.

Để thu thập các ứng dụng, người ta thường xếp một số khoảng trống vào hàng đợi
bộ đệm, để bắt đầu thu thập và vào vòng lặp đọc. Đây là
ứng dụng đợi cho đến khi bộ đệm đầy có thể được loại bỏ và sắp xếp lại
bộ đệm khi dữ liệu không còn cần thiết nữa. Ứng dụng đầu ra điền vào
và bộ đệm enqueue, khi đủ bộ đệm được xếp chồng lên nhau thì kết quả là
bắt đầu. Trong vòng lặp ghi, khi ứng dụng hết dung lượng trống
bộ đệm, nó phải đợi cho đến khi bộ đệm trống có thể được loại bỏ và sử dụng lại.
Có hai phương pháp để tạm dừng thực thi ứng dụng cho đến khi một hoặc
nhiều bộ đệm hơn có thể được loại bỏ. Theo mặc định, ZZ0000ZZ chặn khi không có bộ đệm trong hàng đợi gửi đi. Khi
Cờ ZZ0005ZZ được cấp cho hàm ZZ0001ZZ,
ZZ0002ZZ trở lại ngay lập tức với ZZ0006ZZ
mã lỗi khi không có bộ đệm. các
ZZ0003ZZ và ZZ0004ZZ
các chức năng luôn có sẵn.

Để bắt đầu và dừng chụp hoặc hiển thị các ứng dụng, hãy gọi
ZZ0000ZZ và
ZZ0001ZZ ioctls.

.. note::

   :ref:`VIDIOC_STREAMOFF <VIDIOC_STREAMON>` removes all buffers from
   both queues and unlocks all buffers as a side effect. Since there is no
   notion of doing anything "now" on a multitasking system, if an
   application needs to synchronize with another event it should examine
   the struct :c:type:`v4l2_buffer` ``timestamp`` of captured or
   outputted buffers.

Trình điều khiển triển khai DMABUF nhập I/O phải hỗ trợ
ZZ0000ZZ, ZZ0001ZZ,
ZZ0002ZZ, ZZ0003ZZ và ZZ0004ZZ ioctls,
và ZZ0005ZZ và ZZ0006ZZ
chức năng.