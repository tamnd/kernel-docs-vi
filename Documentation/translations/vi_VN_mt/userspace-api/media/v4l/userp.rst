.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/userp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _userp:

*****************************
Truyền phát I/O (Con trỏ người dùng)
*****************************

Các thiết bị đầu vào và đầu ra hỗ trợ phương thức I/O này khi
Cờ ZZ0003ZZ trong trường ZZ0004ZZ của cấu trúc
ZZ0000ZZ được trả lại bởi
ZZ0001ZZ ioctl được thiết lập. Nếu
phương thức con trỏ người dùng cụ thể (không chỉ ánh xạ bộ nhớ) được hỗ trợ
phải được xác định bằng cách gọi ZZ0002ZZ ioctl
với loại bộ nhớ được đặt thành ZZ0005ZZ.

Phương thức I/O này kết hợp các ưu điểm của việc đọc/ghi và ánh xạ bộ nhớ.
phương pháp. Bộ đệm (mặt phẳng) được phân bổ bởi chính ứng dụng và
có thể cư trú ví dụ trong bộ nhớ ảo hoặc chia sẻ. Chỉ con trỏ tới
dữ liệu được trao đổi, các con trỏ và thông tin meta này được chuyển vào
struct ZZ0000ZZ (hoặc trong struct
ZZ0001ZZ trong trường hợp API đa mặt phẳng). các
trình điều khiển phải được chuyển sang chế độ I/O con trỏ người dùng bằng cách gọi
ZZ0002ZZ với loại bộ đệm mong muốn.
Không có bộ đệm (mặt phẳng) nào được phân bổ trước, do đó chúng không được
được lập chỉ mục và không thể được truy vấn như bộ đệm được ánh xạ với
ZZ0003ZZ ioctl.

Ví dụ: Bắt đầu truyền I/O bằng con trỏ người dùng
====================================================

.. code-block:: c

    struct v4l2_requestbuffers reqbuf;

    memset (&reqbuf, 0, sizeof (reqbuf));
    reqbuf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    reqbuf.memory = V4L2_MEMORY_USERPTR;

    if (ioctl (fd, VIDIOC_REQBUFS, &reqbuf) == -1) {
	if (errno == EINVAL)
	    printf ("Video capturing or user pointer streaming is not supported\\n");
	else
	    perror ("VIDIOC_REQBUFS");

	exit (EXIT_FAILURE);
    }

Địa chỉ và kích thước bộ đệm (mặt phẳng) được truyền nhanh chóng bằng
ZZ0000ZZ ioctl. Mặc dù bộ đệm thường được sử dụng
theo chu kỳ, các ứng dụng có thể chuyển các địa chỉ và kích thước khác nhau tại mỗi địa chỉ
Cuộc gọi ZZ0001ZZ. Nếu phần cứng yêu cầu
trình điều khiển hoán đổi các trang bộ nhớ trong bộ nhớ vật lý để tạo ra một liên tục
vùng bộ nhớ. Điều này xảy ra một cách minh bạch đối với ứng dụng trong
hệ thống con bộ nhớ ảo của kernel. Khi các trang đệm đã được
được hoán đổi vào đĩa, chúng được đưa trở lại và cuối cùng bị khóa trong vật lý
bộ nhớ cho DMA. [#f1]_

Bộ đệm đã đầy hoặc được hiển thị sẽ được loại bỏ bằng
ZZ0000ZZ ioctl. Người lái xe có thể mở khóa
các trang bộ nhớ bất kỳ lúc nào từ khi hoàn thành DMA cho đến khi hoàn thành
ioctl. Bộ nhớ cũng được mở khóa khi
ZZ0001ZZ được gọi là,
ZZ0002ZZ hoặc khi đóng thiết bị.
Các ứng dụng phải cẩn thận để không giải phóng bộ đệm mà không loại bỏ hàng đợi.
Thứ nhất, bộ đệm bị khóa lâu hơn, gây lãng phí bộ nhớ vật lý.
Thứ hai, trình điều khiển sẽ không được thông báo khi bộ nhớ được trả về
danh sách miễn phí của ứng dụng và sau đó được sử dụng lại cho các mục đích khác,
có thể hoàn thành DMA được yêu cầu và ghi đè dữ liệu có giá trị.

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
mã lỗi khi không có bộ đệm. Chức năng ZZ0003ZZ hoặc ZZ0004ZZ luôn được
có sẵn.

Để bắt đầu và dừng việc chụp hoặc xuất các ứng dụng, hãy gọi phương thức
ZZ0000ZZ và
ZZ0001ZZ ioctl.

.. note::

   :ref:`VIDIOC_STREAMOFF <VIDIOC_STREAMON>` removes all buffers from
   both queues and unlocks all buffers as a side effect. Since there is no
   notion of doing anything "now" on a multitasking system, if an
   application needs to synchronize with another event it should examine
   the struct :c:type:`v4l2_buffer` ``timestamp`` of captured or
   outputted buffers.

Trình điều khiển triển khai I/O con trỏ người dùng phải hỗ trợ
ZZ0000ZZ, ZZ0001ZZ,
ZZ0002ZZ, ZZ0003ZZ
và ZZ0004ZZ ioctls,
Chức năng ZZ0005ZZ và ZZ0006ZZ. [#f2]_

.. [#f1]
   We expect that frequently used buffers are typically not swapped out.
   Anyway, the process of swapping, locking or generating scatter-gather
   lists may be time consuming. The delay can be masked by the depth of
   the incoming buffer queue, and perhaps by maintaining caches assuming
   a buffer will be soon enqueued again. On the other hand, to optimize
   memory usage drivers can limit the number of buffers locked in
   advance and recycle the most recently used buffers first. Of course,
   the pages of empty buffers in the incoming queue need not be saved to
   disk. Output buffers must be saved on the incoming and outgoing queue
   because an application may share them with other processes.

.. [#f2]
   At the driver level :c:func:`select()` and :c:func:`poll()` are
   the same, and :c:func:`select()` is too important to be optional.
   The rest should be evident.