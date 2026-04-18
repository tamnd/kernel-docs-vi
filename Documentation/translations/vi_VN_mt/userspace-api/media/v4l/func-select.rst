.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/func-select.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _func-select:

*************
V4L2 chọn()
*************

Tên
====

v4l2-select - Ghép kênh I/O đồng bộ

Tóm tắt
========

.. code-block:: c

    #include <sys/time.h>
    #include <sys/types.h>
    #include <unistd.h>

.. c:function:: int select( int nfds, fd_set *readfds, fd_set *writefds, fd_set *exceptfds, struct timeval *timeout )

Đối số
=========

ZZ0000ZZ
  Bộ mô tả tệp được đánh số cao nhất trong bất kỳ bộ nào trong ba bộ, cộng thêm 1.

ZZ0000ZZ
  Mô tả tệp cần được theo dõi nếu lệnh gọi read() không bị chặn.

ZZ0000ZZ
  Mô tả tệp cần được theo dõi nếu lệnh write() không chặn.

ZZ0000ZZ
  Mô tả tệp cần theo dõi cho các sự kiện V4L2.

ZZ0000ZZ
  Thời gian chờ đợi tối đa.

Sự miêu tả
===========

Với chức năng ZZ0000ZZ, các ứng dụng có thể tạm dừng
thực thi cho đến khi trình điều khiển đã nắm bắt được dữ liệu hoặc sẵn sàng chấp nhận dữ liệu
cho đầu ra.

Khi luồng I/O đã được thương lượng, chức năng này sẽ đợi cho đến khi
bộ đệm đã được lấp đầy hoặc hiển thị và có thể được xếp hàng đợi bằng
ZZ0000ZZ ioctl. Khi bộ đệm đã có sẵn
hàng đợi đi của trình điều khiển, hàm sẽ trả về ngay lập tức.

Khi thành công, ZZ0000ZZ trả về tổng số bit được đặt trong
ZZ0005ZZ. Khi chức năng hết thời gian, nó sẽ trả về
một giá trị bằng không. Khi thất bại, nó trả về -1 và biến ZZ0006ZZ là
thiết lập một cách thích hợp. Khi ứng dụng không gọi
ZZ0001ZZ hoặc
ZZ0002ZZ và ZZ0003ZZ
chức năng thành công, thiết lập bit của bộ mô tả tệp trong ZZ0007ZZ
hoặc ZZ0008ZZ, nhưng tiếp theo là ZZ0004ZZ
cuộc gọi sẽ thất bại. [#f1]_

Khi việc sử dụng chức năng ZZ0000ZZ đã được thỏa thuận và
trình điều khiển chưa chụp, chức năng ZZ0001ZZ bắt đầu
chụp. Khi thất bại, ZZ0002ZZ trả về thành công và
cuộc gọi ZZ0003ZZ tiếp theo cũng cố gắng bắt đầu
chụp, sẽ trả về mã lỗi thích hợp. Khi người lái xe
chụp liên tục (ví dụ như trái ngược với hình ảnh tĩnh) và
dữ liệu đã có sẵn, hàm ZZ0004ZZ trả về
ngay lập tức.

Khi việc sử dụng chức năng ZZ0000ZZ đã được thỏa thuận,
Chức năng ZZ0001ZZ chỉ đợi cho đến khi trình điều khiển sẵn sàng
cuộc gọi ZZ0002ZZ không chặn.

Tất cả các trình điều khiển triển khai ZZ0000ZZ hoặc ZZ0001ZZ
chức năng hoặc truyền phát I/O cũng phải hỗ trợ ZZ0002ZZ
chức năng.

Để biết thêm chi tiết, hãy xem trang hướng dẫn sử dụng ZZ0000ZZ.

Giá trị trả về
============

Khi thành công, ZZ0000ZZ trả về số lượng bộ mô tả
chứa trong ba bộ mô tả được trả về, sẽ bằng 0 nếu
thời gian chờ đã hết. Khi có lỗi -1 được trả về và biến ZZ0001ZZ
được thiết lập phù hợp; các bộ và ZZ0002ZZ không được xác định. Có thể
mã lỗi là:

EBADF
    Một hoặc nhiều bộ mô tả tệp đã chỉ định một bộ mô tả tệp
    cái đó chưa mở.

EBUSY
    Trình điều khiển không hỗ trợ nhiều luồng đọc hoặc ghi và
    thiết bị đã được sử dụng.

EFAULT
    Con trỏ ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ hoặc ZZ0003ZZ
    tham chiếu một vùng bộ nhớ không thể truy cập được.

EINTR
    Cuộc gọi bị gián đoạn bởi một tín hiệu.

EINVAL
    Đối số ZZ0000ZZ nhỏ hơn 0 hoặc lớn hơn
    ZZ0001ZZ.

.. [#f1]
   The Linux kernel implements :c:func:`select()` like the
   :c:func:`poll()` function, but :c:func:`select()` cannot
   return a ``POLLERR``.