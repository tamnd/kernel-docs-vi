.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/dmx-mmap.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.dmx

.. _dmx-mmap:

******************************
Truyền hình kỹ thuật số mmap()
******************************

Tên
====

dmx-mmap - Ánh xạ bộ nhớ thiết bị vào không gian địa chỉ ứng dụng

.. warning:: this API is still experimental

Tóm tắt
========

.. code-block:: c

    #include <unistd.h>
    #include <sys/mman.h>

.. c:function:: void *mmap( void *start, size_t length, int prot, int flags, int fd, off_t offset )

Đối số
=========

ZZ0000ZZ
    Ánh xạ bộ đệm tới địa chỉ này trong không gian địa chỉ của ứng dụng.
    Khi cờ ZZ0001ZZ được chỉ định, ZZ0002ZZ phải là
    nhiều kích thước trang và mmap sẽ thất bại khi được chỉ định
    địa chỉ không thể được sử dụng Việc sử dụng tùy chọn này không được khuyến khích;
    các ứng dụng chỉ nên chỉ định con trỏ ZZ0003ZZ tại đây.

ZZ0000ZZ
    Độ dài của vùng nhớ cần ánh xạ. Đây phải là bội số của
    Độ dài gói DVB (188, trên hầu hết các trình điều khiển).

ZZ0000ZZ
    Đối số ZZ0001ZZ mô tả cách bảo vệ bộ nhớ mong muốn.
    Bất kể loại thiết bị và hướng trao đổi dữ liệu
    nên được đặt thành ZZ0002ZZ | ZZ0003ZZ, cho phép đọc
    và ghi quyền truy cập vào bộ đệm hình ảnh. Trình điều khiển nên hỗ trợ ít nhất
    sự kết hợp của các lá cờ này.

ZZ0000ZZ
    Tham số ZZ0001ZZ chỉ định loại đối tượng được ánh xạ,
    các tùy chọn ánh xạ và liệu các sửa đổi được thực hiện đối với bản sao được ánh xạ của
    trang này là riêng tư đối với quy trình hoặc sẽ được chia sẻ với người khác
    tài liệu tham khảo.

ZZ0001ZZ yêu cầu trình điều khiển không chọn địa chỉ nào khác ngoài
    cái được chỉ định. Nếu địa chỉ được chỉ định không thể được sử dụng,
    ZZ0000ZZ sẽ thất bại. Nếu ZZ0002ZZ được chỉ định,
    ZZ0003ZZ phải là bội số của kích thước trang. Việc sử dụng tùy chọn này là
    chán nản.

Một trong các cờ ZZ0000ZZ hoặc ZZ0001ZZ phải được đặt.
    ZZ0002ZZ cho phép các ứng dụng chia sẻ bộ nhớ được ánh xạ với
    các quy trình khác (ví dụ: con-).

    .. note::

       The Linux Digital TV applications should not set the
       ``MAP_PRIVATE``, ``MAP_DENYWRITE``, ``MAP_EXECUTABLE`` or ``MAP_ANON``
       flags.

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Độ lệch của bộ đệm trong bộ nhớ thiết bị, được trả về bởi
    ZZ0000ZZ ioctl.

Sự miêu tả
===========

Hàm ZZ0000ZZ yêu cầu ánh xạ các byte ZZ0001ZZ bắt đầu từ
ZZ0002ZZ trong bộ nhớ của thiết bị được ZZ0003ZZ chỉ định vào
không gian địa chỉ ứng dụng, tốt nhất là ở địa chỉ ZZ0004ZZ. Cái sau này
địa chỉ chỉ là gợi ý và thường được chỉ định là 0.

Các tham số độ dài và offset phù hợp được truy vấn bằng
ZZ0000ZZ ioctl. Bộ đệm phải được cấp phát bằng
ZZ0001ZZ ioctl trước khi chúng có thể được truy vấn.

Để hủy ánh xạ bộ đệm, chức năng ZZ0000ZZ được sử dụng.

Giá trị trả về
==============

Khi thành công, ZZ0000ZZ trả về một con trỏ tới bộ đệm được ánh xạ. Bật
lỗi ZZ0001ZZ (-1) được trả về và biến ZZ0002ZZ được đặt
một cách thích hợp. Các mã lỗi có thể xảy ra là:

EBADF
    ZZ0000ZZ không phải là bộ mô tả tệp hợp lệ.

EACCES
    ZZ0000ZZ không mở để đọc và viết.

EINVAL
    ZZ0000ZZ hoặc ZZ0001ZZ hoặc ZZ0002ZZ không phù hợp. (Ví dụ:
    chúng quá lớn hoặc không được căn chỉnh trên ranh giới ZZ0003ZZ.)

Giá trị ZZ0000ZZ hoặc ZZ0001ZZ không được hỗ trợ.

Không có bộ đệm nào được phân bổ với
    ZZ0000ZZ ioctl.

ENOMEM
    Không có đủ bộ nhớ vật lý hoặc ảo để hoàn thành
    yêu cầu.