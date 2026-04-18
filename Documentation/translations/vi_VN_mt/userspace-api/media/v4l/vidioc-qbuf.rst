.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-qbuf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_QBUF:

*******************************
ioctl VIDIOC_QBUF, VIDIOC_DQBUF
*******************************

Tên
====

VIDIOC_QBUF - VIDIOC_DQBUF - Trao đổi bộ đệm với trình điều khiển

Tóm tắt
========

.. c:macro:: VIDIOC_QBUF

ZZ0000ZZ

.. c:macro:: VIDIOC_DQBUF

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Các ứng dụng gọi ZZ0000ZZ ioctl để xếp hàng trống
Bộ đệm (chụp) hoặc đầy (đầu ra) trong hàng đợi đến của trình điều khiển.
Ngữ nghĩa phụ thuộc vào phương pháp I/O đã chọn.

Để xếp hàng các ứng dụng bộ đệm, hãy đặt trường ZZ0010ZZ của cấu trúc
ZZ0000ZZ sang cùng loại bộ đệm như cũ
trước đây được sử dụng với cấu trúc ZZ0001ZZ ZZ0011ZZ
và cấu trúc ZZ0002ZZ ZZ0012ZZ.
Các ứng dụng cũng phải đặt trường ZZ0013ZZ. Số chỉ mục hợp lệ
phạm vi từ 0 đến số lượng bộ đệm được phân bổ với
ZZ0003ZZ (cấu trúc
ZZ0004ZZ ZZ0014ZZ) trừ
một. Nội dung của struct ZZ0005ZZ được trả về
bởi ZZ0006ZZ ioctl cũng sẽ làm được.
Khi bộ đệm được dành cho đầu ra (ZZ0015ZZ là
ZZ0016ZZ, ZZ0017ZZ,
hoặc ZZ0018ZZ) cũng phải khởi tạo
Các trường ZZ0019ZZ, ZZ0020ZZ và ZZ0021ZZ, xem ZZ0007ZZ
để biết chi tiết. Các ứng dụng cũng phải đặt ZZ0022ZZ thành 0.
Các trường ZZ0023ZZ và ZZ0024ZZ phải được đặt thành 0. Khi sử dụng
ZZ0008ZZ, trường ZZ0025ZZ phải
chứa một con trỏ không gian người dùng tới một mảng cấu trúc được điền đầy đủ
Phải đặt trường ZZ0009ZZ và ZZ0026ZZ
số phần tử trong mảng đó.

Để xếp hàng các ứng dụng bộ đệm ZZ0000ZZ, hãy đặt
trường ZZ0001ZZ đến ZZ0002ZZ. Khi ZZ0003ZZ được gọi
với một con trỏ tới cấu trúc này, trình điều khiển sẽ thiết lập
Cờ và xóa ZZ0004ZZ và ZZ0005ZZ
cờ ZZ0006ZZ trong trường ZZ0007ZZ hoặc nó trả về một
Mã lỗi ZZ0008ZZ.

Để xếp hàng các ứng dụng bộ đệm ZZ0000ZZ, hãy đặt
Trường ZZ0004ZZ thành ZZ0005ZZ, trường ZZ0006ZZ thành
địa chỉ của bộ đệm và ZZ0007ZZ theo kích thước của nó. Khi
API đa mặt phẳng được sử dụng, các thành viên ZZ0008ZZ và ZZ0009ZZ của
mảng cấu trúc ZZ0001ZZ đã truyền phải được sử dụng
thay vào đó. Khi ZZ0010ZZ được gọi với một con trỏ tới cấu trúc này
trình điều khiển đặt cờ ZZ0011ZZ và xóa
Cờ ZZ0012ZZ và ZZ0013ZZ trong
Trường ZZ0014ZZ hoặc nó sẽ trả về mã lỗi. Ioctl này khóa
các trang bộ nhớ của bộ đệm trong bộ nhớ vật lý, chúng không thể hoán đổi được
ra đĩa. Bộ đệm vẫn bị khóa cho đến khi được xếp hàng đợi, cho đến khi
ZZ0002ZZ hoặc
ZZ0003ZZ ioctl được gọi hoặc cho đến khi
thiết bị đã đóng.

Để xếp hàng các ứng dụng bộ đệm ZZ0000ZZ, hãy đặt
Trường ZZ0004ZZ thành ZZ0005ZZ và trường ZZ0006ZZ thành a
bộ mô tả tệp được liên kết với bộ đệm DMABUF. Khi đa mặt phẳng
API được sử dụng các trường ZZ0007ZZ của mảng cấu trúc đã truyền
ZZ0001ZZ phải được sử dụng thay thế. Khi nào
ZZ0008ZZ được gọi bằng một con trỏ tới cấu trúc này của trình điều khiển
đặt cờ ZZ0009ZZ và xóa
Cờ ZZ0010ZZ và ZZ0011ZZ trong
Trường ZZ0012ZZ hoặc trường này sẽ trả về mã lỗi. Ioctl này khóa
bộ đệm. Khóa bộ đệm có nghĩa là chuyển nó tới trình điều khiển cho phần cứng
truy cập (thường là DMA). Nếu một ứng dụng truy cập (đọc/ghi) một
đệm thì kết quả không được xác định. Bộ đệm vẫn bị khóa cho đến khi
được xếp hàng đợi, cho đến ZZ0002ZZ hoặc
ZZ0003ZZ ioctl được gọi hoặc cho đến khi
thiết bị đã đóng.

Trường ZZ0001ZZ có thể được sử dụng với ZZ0002ZZ ioctl để chỉ định
bộ mô tả tập tin của ZZ0000ZZ, nếu có yêu cầu
đang sử dụng. Đặt nó có nghĩa là bộ đệm sẽ không được chuyển đến trình điều khiển
cho đến khi yêu cầu được xếp hàng đợi. Ngoài ra, người lái xe sẽ áp dụng bất kỳ
cài đặt liên quan đến yêu cầu cho bộ đệm này. Trường này sẽ
bị bỏ qua trừ khi cờ ZZ0003ZZ được đặt.
Nếu thiết bị không hỗ trợ yêu cầu thì ZZ0004ZZ sẽ được trả về.
Nếu yêu cầu được hỗ trợ nhưng mô tả tệp yêu cầu không hợp lệ được cung cấp,
sau đó ZZ0005ZZ sẽ được trả lại.

.. caution::
   It is not allowed to mix queuing requests with queuing buffers directly.
   ``EBUSY`` will be returned if the first buffer was queued directly and
   then the application tries to queue a request, or vice versa. After
   closing the file descriptor, calling
   :ref:`VIDIOC_STREAMOFF <VIDIOC_STREAMON>` or calling :ref:`VIDIOC_REQBUFS`
   the check for this will be reset.

   For :ref:`memory-to-memory devices <mem2mem>` you can specify the
   ``request_fd`` only for output buffers, not for capture buffers. Attempting
   to specify this for a capture buffer will result in an ``EBADR`` error.

Các ứng dụng gọi ZZ0001ZZ ioctl để loại bỏ một
Bộ đệm (chụp) hoặc hiển thị (đầu ra) từ đầu ra của trình điều khiển
xếp hàng. Họ chỉ đặt các trường ZZ0002ZZ, ZZ0003ZZ và ZZ0004ZZ của
một cấu trúc ZZ0000ZZ như trên, khi
ZZ0005ZZ được gọi bằng một con trỏ tới cấu trúc này của trình điều khiển
điền vào tất cả các trường còn lại hoặc trả về mã lỗi. Người lái xe cũng có thể
đặt ZZ0006ZZ trong trường ZZ0007ZZ. Nó chỉ ra một
lỗi phát trực tuyến không nghiêm trọng (có thể phục hồi). Trong trường hợp như vậy ứng dụng
có thể tiếp tục như bình thường, nhưng cần lưu ý rằng dữ liệu trong
bộ đệm có thể bị hỏng. Khi sử dụng API đa mặt phẳng, các mặt phẳng
mảng cũng phải được truyền vào.

Nếu ứng dụng đặt trường ZZ0002ZZ thành ZZ0003ZZ để
loại bỏ bộ đệm ZZ0000ZZ, trình điều khiển sẽ điền vào trường ZZ0004ZZ
với bộ mô tả tệp về mặt số lượng giống với bộ mô tả được cung cấp cho ZZ0005ZZ
khi bộ đệm được xếp vào hàng đợi. Không có bộ mô tả tệp mới nào được tạo tại thời điểm dequeue
và giá trị chỉ dành cho sự thuận tiện cho ứng dụng. Khi đa mặt phẳng
API được sử dụng các trường ZZ0006ZZ của mảng cấu trúc đã truyền
Thay vào đó, ZZ0001ZZ được điền vào.

Theo mặc định, ZZ0001ZZ sẽ chặn khi không có bộ đệm ở đầu ra
xếp hàng. Khi cờ ZZ0002ZZ được trao cho
Hàm ZZ0000ZZ, trả về ZZ0003ZZ
ngay lập tức kèm theo mã lỗi ZZ0004ZZ khi không có bộ đệm.

Cấu trúc ZZ0000ZZ được chỉ định trong
ZZ0001ZZ.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EAGAIN
    I/O không chặn đã được chọn bằng ZZ0000ZZ và không
    bộ đệm nằm trong hàng đợi gửi đi.

EINVAL
    Bộ đệm ZZ0000ZZ không được hỗ trợ hoặc ZZ0001ZZ đã hết
    giới hạn hoặc chưa có bộ đệm nào được phân bổ hoặc ZZ0002ZZ hoặc
    ZZ0003ZZ không hợp lệ hoặc cờ ZZ0004ZZ bị
    được đặt nhưng ZZ0005ZZ đã cho không hợp lệ hoặc ZZ0006ZZ đã được đặt
    bộ mô tả tệp DMABUF không hợp lệ.

EIO
    ZZ0000ZZ không thành công do lỗi nội bộ. Cũng có thể chỉ ra
    các vấn đề tạm thời như mất tín hiệu.

    .. note::

       The driver might dequeue an (empty) buffer despite returning
       an error, or even stop capturing. Reusing such buffer may be unsafe
       though and its details (e.g. ``index``) may not be returned either.
       It is recommended that drivers indicate recoverable errors by setting
       the ``V4L2_BUF_FLAG_ERROR`` and returning 0 instead. In that case the
       application should be able to safely reuse the buffer and continue
       streaming.

EPIPE
    ZZ0000ZZ trả về cái này trên hàng đợi chụp trống cho mem2mem
    codec nếu đã có bộ đệm với ZZ0001ZZ
    đã được loại bỏ hàng đợi và dự kiến sẽ không có bộ đệm mới.

EBADR
    Cờ ZZ0000ZZ đã được đặt nhưng thiết bị thì không
    yêu cầu hỗ trợ cho loại bộ đệm nhất định hoặc
    cờ ZZ0001ZZ chưa được đặt nhưng thiết bị yêu cầu
    rằng bộ đệm là một phần của yêu cầu.

EBUSY
    Bộ đệm đầu tiên được xếp hàng đợi thông qua một yêu cầu, nhưng hiện tại ứng dụng sẽ thử
    xếp hàng trực tiếp hoặc ngược lại (không được phép trộn lẫn cả hai
    API).