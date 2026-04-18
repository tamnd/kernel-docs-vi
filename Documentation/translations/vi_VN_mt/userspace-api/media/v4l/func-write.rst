.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/func-write.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _func-write:

*************
V4L2 viết()
*************

Tên
====

v4l2-write - Ghi vào thiết bị V4L2

Tóm tắt
========

.. code-block:: c

    #include <unistd.h>

.. c:function:: ssize_t write( int fd, void *buf, size_t count )

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ
     Bộ đệm chứa dữ liệu cần ghi

ZZ0000ZZ
    Số byte tại bộ đệm

Sự miêu tả
===========

ZZ0000ZZ ghi tối đa ZZ0002ZZ byte vào thiết bị
được tham chiếu bởi bộ mô tả tệp ZZ0003ZZ từ bộ đệm bắt đầu từ
ZZ0004ZZ. Khi đầu ra phần cứng chưa hoạt động, chức năng này
cho phép họ. Khi ZZ0005ZZ bằng 0, ZZ0001ZZ trả về 0
mà không có bất kỳ tác dụng nào khác.

Khi ứng dụng không cung cấp thêm dữ liệu kịp thời, dữ liệu trước đó
khung hình video, hình ảnh VBI thô, dữ liệu VPS hoặc WSS được cắt lát được hiển thị lại.
Dữ liệu Teletext hoặc Closed Caption không được lặp lại, trình điều khiển
thay vào đó sẽ chèn một dòng trống.

Giá trị trả về
==============

Khi thành công, số byte được ghi sẽ được trả về. Số không biểu thị
không có gì được viết. Nếu có lỗi, -1 được trả về và ZZ0000ZZ
biến được đặt phù hợp. Trong trường hợp này lần ghi tiếp theo sẽ bắt đầu lúc
sự bắt đầu của một khung mới. Các mã lỗi có thể xảy ra là:

EAGAIN
    I/O không chặn đã được chọn bằng cách sử dụng
    Cờ ZZ0000ZZ và không có dung lượng bộ đệm
    sẵn sàng để ghi dữ liệu ngay lập tức.

EBADF
    ZZ0000ZZ không phải là bộ mô tả tệp hợp lệ hoặc không mở để ghi.

EBUSY
    Trình điều khiển không hỗ trợ nhiều luồng ghi và thiết bị
    đã được sử dụng.

EFAULT
    ZZ0000ZZ tham chiếu vùng bộ nhớ không thể truy cập.

EINTR
    Cuộc gọi bị gián đoạn bởi một tín hiệu trước khi bất kỳ dữ liệu nào được ghi.

EIO
    Lỗi vào/ra. Điều này cho thấy một số vấn đề phần cứng.

EINVAL
    Chức năng ZZ0000ZZ không được trình điều khiển này hỗ trợ,
    không có trên thiết bị này hoặc nói chung là không có trên loại thiết bị này.