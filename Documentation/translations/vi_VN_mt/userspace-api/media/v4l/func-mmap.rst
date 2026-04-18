.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/func-mmap.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _func-mmap:

*************
V4L2 mmap()
*************

Tên
====

v4l2-mmap - Ánh xạ bộ nhớ thiết bị vào không gian địa chỉ ứng dụng

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

ZZ0002ZZ
    Độ dài của vùng nhớ cần ánh xạ. Giá trị này phải giống với giá trị
    được trả về bởi trình điều khiển trong cấu trúc
    Trường ZZ0000ZZ ZZ0003ZZ dành cho
    API một mặt phẳng và có cùng giá trị được trình điều khiển trả về trong
    trường struct ZZ0001ZZ ZZ0004ZZ cho
    API đa mặt phẳng.

ZZ0000ZZ
    Đối số ZZ0001ZZ mô tả cách bảo vệ bộ nhớ mong muốn.
    Bất kể loại thiết bị và hướng trao đổi dữ liệu
    nên được đặt thành ZZ0002ZZ | ZZ0003ZZ, cho phép đọc
    và ghi quyền truy cập vào bộ đệm hình ảnh. Trình điều khiển nên hỗ trợ ít nhất
    sự kết hợp của các lá cờ này.

    .. note::

      #. The Linux ``videobuf`` kernel module, which is used by some
trình điều khiển chỉ hỗ trợ ZZ0001ZZ | ZZ0002ZZ. Khi
	 trình điều khiển không hỗ trợ sự bảo vệ mong muốn,
	 Chức năng ZZ0000ZZ không thành công.

#. Truy cập bộ nhớ thiết bị (ví dụ: bộ nhớ trên card đồ họa
	 với phần cứng quay video) có thể bị phạt hiệu suất
	 so với truy cập bộ nhớ chính hoặc đọc có thể đáng kể
	 chậm hơn so với viết hoặc ngược lại. Các phương pháp I/O khác có thể nhiều hơn
	 hiệu quả trong trường hợp như vậy.

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

       The Linux ``videobuf`` module  which is used by some
       drivers supports only ``MAP_SHARED``. ``MAP_PRIVATE`` requests
       copy-on-write semantics. V4L2 applications should not set the
       ``MAP_PRIVATE``, ``MAP_DENYWRITE``, ``MAP_EXECUTABLE`` or ``MAP_ANON``
       flags.

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0002ZZ
    Bù đắp bộ đệm trong bộ nhớ thiết bị. Giá trị này phải có cùng giá trị
    được trả về bởi trình điều khiển trong cấu trúc
    Trường ZZ0000ZZ ZZ0003ZZ liên kết ZZ0004ZZ cho
    API mặt phẳng đơn và cùng giá trị được trình điều khiển trả về
    trong liên minh struct ZZ0001ZZ ZZ0005ZZ
    Trường ZZ0006ZZ cho API đa mặt phẳng.

Sự miêu tả
===========

Hàm ZZ0000ZZ yêu cầu ánh xạ các byte ZZ0001ZZ bắt đầu từ
ZZ0002ZZ trong bộ nhớ của thiết bị được ZZ0003ZZ chỉ định vào
không gian địa chỉ ứng dụng, tốt nhất là ở địa chỉ ZZ0004ZZ. Cái sau này
địa chỉ chỉ là gợi ý và thường được chỉ định là 0.

Các tham số độ dài và offset phù hợp được truy vấn bằng
ZZ0000ZZ ioctl. Bộ đệm phải được
được phân bổ bằng ZZ0001ZZ ioctl
trước khi họ có thể được truy vấn.

Để hủy ánh xạ bộ đệm, chức năng ZZ0000ZZ được sử dụng.

Giá trị trả về
============

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