.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/libv4l-introduction.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _libv4l-introduction:

************
Giới thiệu
************

libv4l là một tập hợp các thư viện có thêm một lớp trừu tượng mỏng
trên các thiết bị video4linux2. Mục đích của lớp (mỏng) này là
giúp người viết ứng dụng dễ dàng hỗ trợ nhiều loại
thiết bị mà không cần phải viết mã riêng cho các thiết bị khác nhau trong
cùng một lớp.

Một ví dụ về việc sử dụng libv4l được cung cấp bởi
ZZ0000ZZ.

libv4l bao gồm 3 thư viện khác nhau:

libv4lconvert
=============

libv4lconvert là một thư viện chuyển đổi một số định dạng pixel khác nhau
được tìm thấy trong trình điều khiển V4L2 ở một số định dạng RGB và YUY phổ biến.

Nó hiện chấp nhận các định dạng trình điều khiển V4L2 sau:
ZZ0000ZZ,
ZZ0001ZZ,
ZZ0002ZZ,
ZZ0003ZZ,
ZZ0004ZZ,
ZZ0005ZZ,
ZZ0006ZZ,
ZZ0007ZZ,
ZZ0008ZZ,
ZZ0009ZZ,
ZZ0010ZZ,
ZZ0011ZZ,
ZZ0012ZZ,
ZZ0013ZZ,
ZZ0014ZZ,
ZZ0015ZZ,
ZZ0016ZZ,
ZZ0017ZZ,
ZZ0018ZZ,
ZZ0019ZZ,
ZZ0020ZZ,
ZZ0021ZZ,
ZZ0022ZZ,
ZZ0023ZZ,
ZZ0024ZZ, và
ZZ0025ZZ.

Sau này libv4lconvert đã được mở rộng để có thể thực hiện nhiều video khác nhau
chức năng xử lý để cải thiện chất lượng video webcam. Video
quá trình xử lý được chia thành 2 phần: libv4lconvert/control và
libv4lconvert/xử lý.

Phần điều khiển được sử dụng để cung cấp các điều khiển video có thể được sử dụng để
kiểm soát các chức năng xử lý video được cung cấp bởi
libv4lconvert/xử lý. Các điều khiển này được lưu trữ trên toàn ứng dụng
(cho đến khi khởi động lại) bằng cách sử dụng đối tượng bộ nhớ dùng chung liên tục.

libv4lconvert/processing cung cấp khả năng xử lý video thực tế
chức năng.

libv4l1
=======

Thư viện này cung cấp các chức năng có thể được sử dụng để nhanh chóng tạo v4l1
ứng dụng hoạt động với các thiết bị v4l2. Các chức năng này hoạt động chính xác như
mở/đóng/vv bình thường, ngoại trừ libv4l1 thực hiện mô phỏng đầy đủ
api v4l1 trên trình điều khiển v4l2, trong trường hợp trình điều khiển v4l1, nó sẽ
chỉ cần chuyển cuộc gọi qua.

Vì các chức năng đó là mô phỏng của V4L1 API cũ nên không nên
được sử dụng cho các ứng dụng mới.

libv4l2
=======

Thư viện này nên được sử dụng cho tất cả các ứng dụng V4L2 hiện đại.

Nó cung cấp các điều khiển để gọi các phương thức V4L2 open/ioctl/close/polll. Thay vào đó
chỉ cung cấp đầu ra thô của thiết bị, nó sẽ tăng cường các cuộc gọi trong
có nghĩa là nó sẽ sử dụng libv4lconvert để cung cấp nhiều định dạng video hơn
và để nâng cao chất lượng hình ảnh.

Trong hầu hết các trường hợp, libv4l2 chỉ chuyển các cuộc gọi trực tiếp tới
trình điều khiển v4l2, chặn các cuộc gọi đến
ZZ0000ZZ,
ZZ0001ZZ,
ZZ0002ZZ,
ZZ0003ZZ và
ZZ0004ZZ trong
để mô phỏng các định dạng
ZZ0005ZZ,
ZZ0006ZZ,
ZZ0007ZZ, và
ZZ0008ZZ, nếu không
có sẵn trong trình điều khiển. ZZ0009ZZ
tiếp tục liệt kê các định dạng được phần cứng hỗ trợ, cộng với mô phỏng
định dạng được cung cấp bởi libv4l ở cuối.

.. _libv4l-ops:

Chức năng điều khiển thiết bị Libv4l
------------------------------------

Các phương thức thao tác tệp phổ biến được cung cấp bởi libv4l.

Các hàm đó hoạt động giống như hàm gcc ZZ0006ZZ và
Chức năng V4L2
ZZ0000ZZ, ZZ0001ZZ,
ZZ0002ZZ, ZZ0003ZZ,
ZZ0004ZZ và ZZ0005ZZ:

.. c:function:: int v4l2_open(const char *file, int oflag, ...)

   operates like the :c:func:`open()` function.

.. c:function:: int v4l2_close(int fd)

   operates like the :c:func:`close()` function.

.. c:function:: int v4l2_dup(int fd)

   operates like the libc ``dup()`` function, duplicating a file handler.

.. c:function:: int v4l2_ioctl (int fd, unsigned long int request, ...)

   operates like the :c:func:`ioctl()` function.

.. c:function:: int v4l2_read (int fd, void* buffer, size_t n)

   operates like the :c:func:`read()` function.

.. c:function:: void *v4l2_mmap(void *start, size_t length, int prot, int flags, int fd, int64_t offset);

   operates like the :c:func:`mmap()` function.

.. c:function:: int v4l2_munmap(void *_start, size_t length);

   operates like the :c:func:`munmap()` function.

Các chức năng này cung cấp khả năng kiểm soát bổ sung:

.. c:function:: int v4l2_fd_open(int fd, int v4l2_flags)

   opens an already opened fd for further use through v4l2lib and possibly
   modify libv4l2's default behavior through the ``v4l2_flags`` argument.
   Currently, ``v4l2_flags`` can be ``V4L2_DISABLE_CONVERSION``, to disable
   format conversion.

.. c:function:: int v4l2_set_control(int fd, int cid, int value)

   This function takes a value of 0 - 65535, and then scales that range to the
   actual range of the given v4l control id, and then if the cid exists and is
   not locked sets the cid to the scaled value.

.. c:function:: int v4l2_get_control(int fd, int cid)

   This function returns a value of 0 - 65535, scaled to from the actual range
   of the given v4l control id. when the cid does not exist, could not be
   accessed for some reason, or some error occurred 0 is returned.

thư viện trình bao bọc v4l1compat.so
====================================

Thư viện này chặn các cuộc gọi đến
ZZ0000ZZ, ZZ0001ZZ,
ZZ0002ZZ, ZZ0003ZZ và
ZZ0004ZZ
hoạt động và chuyển hướng chúng đến các đối tác libv4l, bằng cách sử dụng
ZZ0005ZZ. Nó cũng mô phỏng các cuộc gọi V4L1 qua V4L2
API.

Nó cho phép sử dụng các ứng dụng kế thừa nhị phân mà vẫn không sử dụng
libv4l.