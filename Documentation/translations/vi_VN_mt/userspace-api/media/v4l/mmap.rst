.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/mmap.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _mmap:

*******************************
Truyền phát I/O (Ánh xạ bộ nhớ)
*******************************

Các thiết bị đầu vào và đầu ra hỗ trợ phương thức I/O này khi
Cờ ZZ0003ZZ trong trường ZZ0004ZZ của cấu trúc
ZZ0000ZZ được trả lại bởi
ZZ0001ZZ ioctl được thiết lập. Có hai
phương pháp phát trực tuyến, để xác định xem hương vị ánh xạ bộ nhớ có
các ứng dụng được hỗ trợ phải gọi ZZ0002ZZ ioctl
với loại bộ nhớ được đặt thành ZZ0005ZZ.

Truyền phát là một phương thức I/O trong đó chỉ trao đổi con trỏ tới bộ đệm
giữa ứng dụng và trình điều khiển, dữ liệu sẽ không được sao chép. Bộ nhớ
ánh xạ chủ yếu nhằm mục đích ánh xạ bộ đệm trong bộ nhớ thiết bị vào
không gian địa chỉ của ứng dụng. Bộ nhớ thiết bị có thể là video chẳng hạn
bộ nhớ trên card đồ họa có tiện ích quay video. Tuy nhiên, đang
phương pháp I/O hiệu quả nhất hiện có trong thời gian dài, nhiều phương pháp khác
trình điều khiển cũng hỗ trợ phát trực tuyến, phân bổ bộ đệm trong chính có thể hỗ trợ DMA
trí nhớ.

Một trình điều khiển có thể hỗ trợ nhiều bộ đệm. Mỗi tập hợp được xác định bởi một
giá trị loại bộ đệm duy nhất. Các bộ độc lập và mỗi bộ có thể chứa
một loại dữ liệu khác. Để truy cập các bộ khác nhau cùng một lúc
phải sử dụng các mô tả tập tin khác nhau. [#f1]_

Để phân bổ bộ đệm thiết bị, các ứng dụng hãy gọi
ZZ0000ZZ ioctl với số lượng mong muốn
bộ đệm và loại bộ đệm, ví dụ ZZ0001ZZ.
Ioctl này cũng có thể được sử dụng để thay đổi số lượng bộ đệm hoặc giải phóng
bộ nhớ được phân bổ, miễn là không có bộ đệm nào còn được ánh xạ.

Trước khi các ứng dụng có thể truy cập vào bộ đệm, chúng phải ánh xạ chúng vào
không gian địa chỉ với chức năng ZZ0000ZZ. các
vị trí của bộ đệm trong bộ nhớ thiết bị có thể được xác định bằng
ZZ0001ZZ ioctl. Trong mặt phẳng đơn
Vỏ API, ZZ0008ZZ và ZZ0009ZZ được trả về trong một cấu trúc
ZZ0002ZZ được xếp ở vị trí thứ sáu và thứ hai
tham số cho hàm ZZ0003ZZ. Khi sử dụng
API đa mặt phẳng, cấu trúc ZZ0004ZZ chứa một
mảng cấu trúc ZZ0005ZZ, mỗi cấu trúc
chứa ZZ0010ZZ và ZZ0011ZZ của chính nó. Khi sử dụng
đa mặt phẳng API, mọi mặt phẳng của mọi bộ đệm phải được ánh xạ
riêng biệt nên số lượng cuộc gọi đến ZZ0006ZZ sẽ
bằng số lượng bộ đệm nhân với số mặt phẳng trong mỗi bộ đệm. các
giá trị offset và độ dài không được sửa đổi. Hãy nhớ rằng, bộ đệm là
được phân bổ trong bộ nhớ vật lý, trái ngược với bộ nhớ ảo, có thể
được hoán đổi vào đĩa. Các ứng dụng sẽ giải phóng bộ đệm ngay khi
có thể thực hiện được với chức năng ZZ0007ZZ.

Ví dụ: Ánh xạ bộ đệm trong API đơn phẳng
=================================================

.. code-block:: c

    struct v4l2_requestbuffers reqbuf;
    struct {
	void *start;
	size_t length;
    } *buffers;
    unsigned int i;

    memset(&reqbuf, 0, sizeof(reqbuf));
    reqbuf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    reqbuf.memory = V4L2_MEMORY_MMAP;
    reqbuf.count = 20;

    if (-1 == ioctl (fd, VIDIOC_REQBUFS, &reqbuf)) {
	if (errno == EINVAL)
	    printf("Video capturing or mmap-streaming is not supported\\n");
	else
	    perror("VIDIOC_REQBUFS");

	exit(EXIT_FAILURE);
    }

    /* We want at least five buffers. */

    if (reqbuf.count < 5) {
	/* You may need to free the buffers here. */
	printf("Not enough buffer memory\\n");
	exit(EXIT_FAILURE);
    }

    buffers = calloc(reqbuf.count, sizeof(*buffers));
    assert(buffers != NULL);

    for (i = 0; i < reqbuf.count; i++) {
	struct v4l2_buffer buffer;

	memset(&buffer, 0, sizeof(buffer));
	buffer.type = reqbuf.type;
	buffer.memory = V4L2_MEMORY_MMAP;
	buffer.index = i;

	if (-1 == ioctl (fd, VIDIOC_QUERYBUF, &buffer)) {
	    perror("VIDIOC_QUERYBUF");
	    exit(EXIT_FAILURE);
	}

	buffers[i].length = buffer.length; /* remember for munmap() */

	buffers[i].start = mmap(NULL, buffer.length,
		    PROT_READ | PROT_WRITE, /* recommended */
		    MAP_SHARED,             /* recommended */
		    fd, buffer.m.offset);

	if (MAP_FAILED == buffers[i].start) {
	    /* If you do not exit here you should unmap() and free()
	       the buffers mapped so far. */
	    perror("mmap");
	    exit(EXIT_FAILURE);
	}
    }

    /* Cleanup. */

    for (i = 0; i < reqbuf.count; i++)
	munmap(buffers[i].start, buffers[i].length);

Ví dụ: Ánh xạ bộ đệm trong API đa mặt phẳng
================================================

.. code-block:: c

    struct v4l2_requestbuffers reqbuf;
    /* Our current format uses 3 planes per buffer */
    #define FMT_NUM_PLANES = 3

    struct {
	void *start[FMT_NUM_PLANES];
	size_t length[FMT_NUM_PLANES];
    } *buffers;
    unsigned int i, j;

    memset(&reqbuf, 0, sizeof(reqbuf));
    reqbuf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
    reqbuf.memory = V4L2_MEMORY_MMAP;
    reqbuf.count = 20;

    if (ioctl(fd, VIDIOC_REQBUFS, &reqbuf) < 0) {
	if (errno == EINVAL)
	    printf("Video capturing or mmap-streaming is not supported\\n");
	else
	    perror("VIDIOC_REQBUFS");

	exit(EXIT_FAILURE);
    }

    /* We want at least five buffers. */

    if (reqbuf.count < 5) {
	/* You may need to free the buffers here. */
	printf("Not enough buffer memory\\n");
	exit(EXIT_FAILURE);
    }

    buffers = calloc(reqbuf.count, sizeof(*buffers));
    assert(buffers != NULL);

    for (i = 0; i < reqbuf.count; i++) {
	struct v4l2_buffer buffer;
	struct v4l2_plane planes[FMT_NUM_PLANES];

	memset(&buffer, 0, sizeof(buffer));
	buffer.type = reqbuf.type;
	buffer.memory = V4L2_MEMORY_MMAP;
	buffer.index = i;
	/* length in struct v4l2_buffer in multi-planar API stores the size
	 * of planes array. */
	buffer.length = FMT_NUM_PLANES;
	buffer.m.planes = planes;

	if (ioctl(fd, VIDIOC_QUERYBUF, &buffer) < 0) {
	    perror("VIDIOC_QUERYBUF");
	    exit(EXIT_FAILURE);
	}

	/* Every plane has to be mapped separately */
	for (j = 0; j < FMT_NUM_PLANES; j++) {
	    buffers[i].length[j] = buffer.m.planes[j].length; /* remember for munmap() */

	    buffers[i].start[j] = mmap(NULL, buffer.m.planes[j].length,
		     PROT_READ | PROT_WRITE, /* recommended */
		     MAP_SHARED,             /* recommended */
		     fd, buffer.m.planes[j].m.mem_offset);

	    if (MAP_FAILED == buffers[i].start[j]) {
		/* If you do not exit here you should unmap() and free()
		   the buffers and planes mapped so far. */
		perror("mmap");
		exit(EXIT_FAILURE);
	    }
	}
    }

    /* Cleanup. */

    for (i = 0; i < reqbuf.count; i++)
	for (j = 0; j < FMT_NUM_PLANES; j++)
	    munmap(buffers[i].start[j], buffers[i].length[j]);

Trình điều khiển phát trực tuyến theo khái niệm duy trì hai hàng đợi bộ đệm, một hàng đợi đến
và một hàng đợi đi. Họ tách riêng việc chụp hoặc đầu ra đồng bộ
hoạt động bị khóa với đồng hồ video từ ứng dụng chịu sự điều chỉnh
đến sự chậm trễ ngẫu nhiên của đĩa hoặc mạng và sự ưu tiên của các quy trình khác,
do đó làm giảm khả năng mất dữ liệu. Các hàng đợi được tổ chức
dưới dạng FIFO, bộ đệm sẽ được xuất ra theo thứ tự được xếp hàng trong dữ liệu đến
FIFO và được ghi lại theo thứ tự được xếp hàng từ FIFO gửi đi.

Trình điều khiển có thể luôn yêu cầu số lượng bộ đệm tối thiểu được xếp hàng đợi
để hoạt động, ngoài điều này không có giới hạn nào về số lượng bộ đệm
các ứng dụng có thể được xếp hàng trước hoặc xếp hàng và xử lý. Họ có thể
cũng được sắp xếp theo thứ tự khác với bộ đệm đã được xếp hàng và
trình điều khiển có thể đưa ZZ0002ZZ vào hàng đợi bộ đệm ZZ0003ZZ theo bất kỳ thứ tự nào.  [#f2]_
số chỉ mục của bộ đệm (struct ZZ0000ZZ
ZZ0001ZZ) không có vai trò gì ở đây, nó chỉ xác định bộ đệm.

Ban đầu tất cả các bộ đệm được ánh xạ đều ở trạng thái đã được loại bỏ hàng đợi, không thể truy cập được bởi
người lái xe. Để thu thập các ứng dụng, thông thường trước tiên hãy xếp tất cả
bộ đệm được ánh xạ, sau đó bắt đầu thu thập và nhập vòng lặp đọc. đây
ứng dụng sẽ đợi cho đến khi bộ đệm đầy có thể được loại bỏ và
sắp xếp lại bộ đệm khi dữ liệu không còn cần thiết nữa. đầu ra
các ứng dụng điền và xếp hàng các bộ đệm, khi có đủ bộ đệm được xếp chồng lên nhau
lên, đầu ra được bắt đầu với ZZ0000ZZ.
Trong vòng lặp ghi, khi ứng dụng hết bộ đệm trống, nó sẽ
phải đợi cho đến khi bộ đệm trống có thể được loại bỏ và sử dụng lại.

Để liệt kê và loại bỏ một ứng dụng bộ đệm, hãy sử dụng
ZZ0000ZZ và ZZ0001ZZ
ioctl. Trạng thái của bộ đệm đang được ánh xạ, được xếp vào hàng đợi, đầy hoặc trống có thể
được xác định bất cứ lúc nào bằng cách sử dụng ZZ0002ZZ ioctl. Hai
tồn tại các phương thức để tạm dừng thực thi ứng dụng cho đến khi một hoặc nhiều
bộ đệm có thể được loại bỏ.  Theo mặc định ZZ0003ZZ
chặn khi không có bộ đệm trong hàng đợi gửi đi. Khi ZZ0008ZZ
cờ đã được trao cho hàm ZZ0004ZZ,
ZZ0005ZZ trở lại ngay lập tức với ZZ0009ZZ
mã lỗi khi không có bộ đệm. ZZ0006ZZ
hoặc các chức năng ZZ0007ZZ luôn có sẵn.

Để bắt đầu và dừng việc chụp hoặc xuất các ứng dụng, hãy gọi phương thức
ZZ0000ZZ và ZZ0001ZZ ioctl.

.. note:::ref:`VIDIOC_STREAMOFF <VIDIOC_STREAMON>`
   removes all buffers from both queues as a side effect. Since there is
   no notion of doing anything "now" on a multitasking system, if an
   application needs to synchronize with another event it should examine
   the struct ::c:type:`v4l2_buffer` ``timestamp`` of captured
   or outputted buffers.

Trình điều khiển triển khai I/O ánh xạ bộ nhớ phải hỗ trợ
ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ
và ZZ0005ZZ ioctls, chức năng ZZ0006ZZ, ZZ0007ZZ, ZZ0008ZZ và ZZ0009ZZ. [#f3]_

[chụp ví dụ]

.. [#f1]
   One could use one file descriptor and set the buffer type field
   accordingly when calling :ref:`VIDIOC_QBUF` etc.,
   but it makes the :c:func:`select()` function ambiguous. We also
   like the clean approach of one file descriptor per logical stream.
   Video overlay for example is also a logical stream, although the CPU
   is not needed for continuous operation.

.. [#f2]
   Random enqueue order permits applications processing images out of
   order (such as video codecs) to return buffers earlier, reducing the
   probability of data loss. Random fill order allows drivers to reuse
   buffers on a LIFO-basis, taking advantage of caches holding
   scatter-gather lists and the like.

.. [#f3]
   At the driver level :c:func:`select()` and :c:func:`poll()` are
   the same, and :c:func:`select()` is too important to be optional.
   The rest should be evident.