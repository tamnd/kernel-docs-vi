.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/mediactl/request-api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: MC

.. _media-request-api:

Yêu cầu API
===========

Yêu cầu API đã được thiết kế để cho phép V4L2 giải quyết các yêu cầu của
các thiết bị hiện đại (codec không trạng thái, đường ống camera phức tạp, ...) và API
(Bộ giải mã Android v2). Một yêu cầu như vậy là khả năng của các thiết bị thuộc về
cùng một quy trình để cấu hình lại và cộng tác chặt chẽ trên cơ sở từng khung hình.
Một cách khác là hỗ trợ các codec không trạng thái, yêu cầu áp dụng các biện pháp kiểm soát
vào các khung hình cụ thể (còn gọi là 'điều khiển trên mỗi khung hình') để được sử dụng hiệu quả.

Mặc dù trường hợp sử dụng ban đầu là V4L2 nhưng nó có thể được mở rộng sang các hệ thống con khác
cũng được, miễn là họ sử dụng bộ điều khiển phương tiện.

Không phải lúc nào cũng có thể hỗ trợ các tính năng này mà không có Yêu cầu API và nếu
đúng vậy, nó cực kỳ kém hiệu quả: không gian người dùng sẽ phải xóa tất cả hoạt động
trên đường dẫn truyền thông, hãy cấu hình lại nó cho khung tiếp theo, xếp hàng các bộ đệm vào
được xử lý với cấu hình đó và đợi cho đến khi tất cả chúng đều sẵn sàng cho
dequeuing trước khi xem xét khung tiếp theo. Điều này làm mất đi mục đích của việc có
hàng đợi bộ đệm vì trong thực tế chỉ có một bộ đệm được xếp hàng đợi tại một thời điểm.

Yêu cầu API cho phép cấu hình cụ thể của đường dẫn (phương tiện
cấu trúc liên kết bộ điều khiển + cấu hình cho từng thực thể phương tiện) được liên kết với
bộ đệm cụ thể. Điều này cho phép không gian người dùng lên lịch một số tác vụ ("yêu cầu")
với các cấu hình khác nhau trước, biết rằng cấu hình đó sẽ
áp dụng khi cần thiết để có được kết quả mong đợi. Giá trị cấu hình tại thời điểm đó
hoàn thành yêu cầu cũng có sẵn để đọc.

Cách sử dụng chung
------------------

Yêu cầu API mở rộng Bộ điều khiển phương tiện API và hợp tác với
API dành riêng cho hệ thống con để hỗ trợ việc sử dụng yêu cầu. Tại Bộ điều khiển phương tiện
cấp độ, các yêu cầu được phân bổ từ thiết bị Bộ điều khiển phương tiện hỗ trợ
nút. Vòng đời của chúng sau đó được quản lý thông qua các bộ mô tả tệp yêu cầu trong
một cách mờ ám. Dữ liệu cấu hình, xử lý bộ đệm và kết quả xử lý
được lưu trữ trong các yêu cầu được truy cập thông qua các API dành riêng cho hệ thống con được mở rộng cho
yêu cầu hỗ trợ, chẳng hạn như API V4L2 có ZZ0000ZZ rõ ràng
tham số.

Yêu cầu phân bổ
------------------

Không gian người dùng phân bổ các yêu cầu bằng ZZ0000ZZ
cho nút thiết bị đa phương tiện. Điều này trả về một bộ mô tả tập tin đại diện cho
yêu cầu. Thông thường, một số yêu cầu như vậy sẽ được phân bổ.

Yêu cầu chuẩn bị
-------------------

Sau đó, các ioctls V4L2 tiêu chuẩn có thể nhận được bộ mô tả tệp yêu cầu để thể hiện
thực tế là ioctl là một phần của yêu cầu nói trên và không được áp dụng
ngay lập tức. Xem ZZ0000ZZ để biết danh sách các ioctls
ủng hộ điều này. Các cấu hình được đặt với tham số ZZ0001ZZ được lưu trữ
thay vì được áp dụng ngay lập tức và các bộ đệm được xếp hàng theo yêu cầu thì không
nhập hàng đợi bộ đệm thông thường cho đến khi chính yêu cầu đó được xếp hàng đợi.

Yêu cầu gửi
------------------

Khi cấu hình và vùng đệm của yêu cầu được chỉ định, nó có thể
được xếp hàng đợi bằng cách gọi ZZ0000ZZ trên bộ mô tả tệp yêu cầu.
Một yêu cầu phải chứa ít nhất một bộ đệm, nếu không thì ZZ0001ZZ sẽ được trả về.
Một yêu cầu được xếp hàng đợi không thể sửa đổi được nữa.

.. caution::
   For :ref:`memory-to-memory devices <mem2mem>` you can use requests only for
   output buffers, not for capture buffers. Attempting to add a capture buffer
   to a request will result in an ``EBADR`` error.

Nếu yêu cầu chứa cấu hình cho nhiều thực thể, trình điều khiển riêng lẻ
có thể đồng bộ hóa để cấu trúc liên kết của đường dẫn được yêu cầu được áp dụng trước khi
bộ đệm được xử lý. Trình điều khiển bộ điều khiển phương tiện thực hiện nỗ lực tốt nhất
vì tính nguyên tử hoàn hảo có thể không thực hiện được do hạn chế về phần cứng.

.. caution::

   It is not allowed to mix queuing requests with directly queuing buffers:
   whichever method is used first locks this in place until
   :ref:`VIDIOC_STREAMOFF <VIDIOC_STREAMON>` is called or the device is
   :ref:`closed <func-close>`. Attempts to directly queue a buffer when earlier
   a buffer was queued via a request or vice versa will result in an ``EBUSY``
   error.

Các biện pháp kiểm soát vẫn có thể được đặt mà không cần yêu cầu và được áp dụng ngay lập tức,
bất kể yêu cầu có được sử dụng hay không.

.. caution::

   Setting the same control through a request and also directly can lead to
   undefined behavior!

Không gian người dùng có thể ZZ0000ZZ một bộ mô tả tệp yêu cầu trong
để chờ cho đến khi yêu cầu hoàn thành. Một yêu cầu được coi là hoàn thành
khi tất cả các bộ đệm liên quan của nó có sẵn để loại bỏ hàng đợi và tất cả
các điều khiển liên quan đã được cập nhật với các giá trị tại thời điểm hoàn thành.
Lưu ý rằng không gian người dùng không cần đợi yêu cầu hoàn thành
loại bỏ bộ đệm của nó: bộ đệm có sẵn giữa chừng trong yêu cầu có thể
được xếp hàng độc lập với trạng thái của yêu cầu.

Một yêu cầu đã hoàn thành chứa trạng thái của thiết bị sau khi yêu cầu được thực hiện.
bị xử tử. Không gian người dùng có thể truy vấn trạng thái đó bằng cách gọi
ZZ0000ZZ với tệp yêu cầu
mô tả. Gọi ZZ0001ZZ để biết
yêu cầu đã được xếp hàng nhưng chưa hoàn thành sẽ trả về ZZ0002ZZ
vì các giá trị điều khiển có thể được người lái xe thay đổi bất cứ lúc nào trong khi
yêu cầu đang được thực hiện.

.. _media-request-life-time:

Tái chế và tiêu hủy
-------------------------

Cuối cùng, một yêu cầu đã hoàn thành có thể bị loại bỏ hoặc được sử dụng lại. Đang gọi
ZZ0000ZZ trên bộ mô tả tệp yêu cầu sẽ tạo ra
bộ mô tả tập tin đó không sử dụng được và yêu cầu sẽ được giải phóng khi không còn nữa
được sử dụng lâu hơn bởi kernel. Nghĩa là, nếu yêu cầu được xếp hàng đợi và sau đó
bộ mô tả tập tin bị đóng, sau đó nó sẽ không được giải phóng cho đến khi trình điều khiển hoàn thành
yêu cầu.

ZZ0000ZZ sẽ xóa trạng thái của yêu cầu và thực hiện yêu cầu đó
lại có sẵn. Hoạt động này không giữ lại trạng thái nào: yêu cầu giống như
nếu nó vừa được phân bổ.

Ví dụ về thiết bị Codec
--------------------------

Đối với các trường hợp sử dụng như ZZ0000ZZ, có thể sử dụng yêu cầu API
để liên kết các biện pháp kiểm soát cụ thể với
được trình điều khiển áp dụng cho bộ đệm OUTPUT, cho phép không gian người dùng
để xếp hàng trước nhiều bộ đệm như vậy. Nó cũng có thể lợi dụng các yêu cầu'
khả năng nắm bắt trạng thái điều khiển khi yêu cầu hoàn thành để đọc lại
thông tin có thể bị thay đổi.

Đưa vào mã, sau khi nhận được yêu cầu, không gian người dùng có thể gán các điều khiển và một
Bộ đệm OUTPUT cho nó:

.. code-block:: c

	struct v4l2_buffer buf;
	struct v4l2_ext_controls ctrls;
	int req_fd;
	...
	if (ioctl(media_fd, MEDIA_IOC_REQUEST_ALLOC, &req_fd))
		return errno;
	...
	ctrls.which = V4L2_CTRL_WHICH_REQUEST_VAL;
	ctrls.request_fd = req_fd;
	if (ioctl(codec_fd, VIDIOC_S_EXT_CTRLS, &ctrls))
		return errno;
	...
	buf.type = V4L2_BUF_TYPE_VIDEO_OUTPUT;
	buf.flags |= V4L2_BUF_FLAG_REQUEST_FD;
	buf.request_fd = req_fd;
	if (ioctl(codec_fd, VIDIOC_QBUF, &buf))
		return errno;

Lưu ý rằng không được phép sử dụng Yêu cầu API cho bộ đệm CAPTURE
vì không có cài đặt trên mỗi khung hình để báo cáo ở đó.

Sau khi yêu cầu được chuẩn bị đầy đủ, nó có thể được xếp hàng đợi tới trình điều khiển:

.. code-block:: c

	if (ioctl(req_fd, MEDIA_REQUEST_IOC_QUEUE))
		return errno;

Sau đó, không gian người dùng có thể đợi yêu cầu hoàn thành bằng cách gọi poll() trên
bộ mô tả tệp của nó hoặc bắt đầu loại bỏ bộ đệm CAPTURE. Rất có thể, nó sẽ
muốn nhận bộ đệm CAPTURE càng sớm càng tốt và điều này có thể được thực hiện bằng cách sử dụng
ZZ0000ZZ thông thường:

.. code-block:: c

	struct v4l2_buffer buf;

	memset(&buf, 0, sizeof(buf));
	buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
	if (ioctl(codec_fd, VIDIOC_DQBUF, &buf))
		return errno;

Lưu ý rằng ví dụ này giả định để đơn giản rằng với mọi bộ đệm OUTPUT
sẽ có một bộ đệm CAPTURE, nhưng điều này không nhất thiết phải như vậy.

Sau đó, chúng tôi có thể đảm bảo rằng yêu cầu được hoàn thành thông qua việc bỏ phiếu
bộ mô tả tệp yêu cầu, các giá trị kiểm soát truy vấn tại thời điểm hoàn thành thông qua
một cuộc gọi đến ZZ0000ZZ.
Điều này đặc biệt hữu ích cho các điều khiển dễ thay đổi mà chúng ta muốn
giá trị truy vấn ngay khi bộ đệm chụp được tạo ra.

.. code-block:: c

	struct pollfd pfd = { .events = POLLPRI, .fd = req_fd };
	poll(&pfd, 1, -1);
	...
	ctrls.which = V4L2_CTRL_WHICH_REQUEST_VAL;
	ctrls.request_fd = req_fd;
	if (ioctl(codec_fd, VIDIOC_G_EXT_CTRLS, &ctrls))
		return errno;

Khi chúng tôi không cần yêu cầu nữa, chúng tôi có thể tái chế nó để sử dụng lại với
ZZ0000ZZ...

.. code-block:: c

	if (ioctl(req_fd, MEDIA_REQUEST_IOC_REINIT))
		return errno;

... or close its file descriptor to completely dispose of it.

.. code-block:: c

	close(req_fd);

Example for a Simple Capture Device
-----------------------------------

With a simple capture device, requests can be used to specify controls to apply
for a given CAPTURE buffer.

.. code-block:: c

	struct v4l2_buffer buf;
	struct v4l2_ext_controls ctrls;
	int req_fd;
	...
	if (ioctl(media_fd, MEDIA_IOC_REQUEST_ALLOC, &req_fd))
		return errno;
	...
	ctrls.which = V4L2_CTRL_WHICH_REQUEST_VAL;
	ctrls.request_fd = req_fd;
	if (ioctl(camera_fd, VIDIOC_S_EXT_CTRLS, &ctrls))
		return errno;
	...
	buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
	buf.flags |= V4L2_BUF_FLAG_REQUEST_FD;
	buf.request_fd = req_fd;
	if (ioctl(camera_fd, VIDIOC_QBUF, &buf))
		return errno;

Once the request is fully prepared, it can be queued to the driver:

.. code-block:: c

	if (ioctl(req_fd, MEDIA_REQUEST_IOC_QUEUE))
		return errno;

User-space can then dequeue buffers, wait for the request completion, query
controls and recycle the request as in the M2M example above.