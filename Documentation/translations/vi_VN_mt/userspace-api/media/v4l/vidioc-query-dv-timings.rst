.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-query-dv-timings.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_QUERY_DV_TIMINGS:

*****************************
ioctl VIDIOC_QUERY_DV_TIMINGS
*****************************

Tên
====

VIDIOC_QUERY_DV_TIMINGS - VIDIOC_SUBDEV_QUERY_DV_TIMINGS - Nhận biết giá trị đặt trước DV mà đầu vào hiện tại nhận được

Tóm tắt
========

.. c:macro:: VIDIOC_QUERY_DV_TIMINGS

ZZ0000ZZ

.. c:macro:: VIDIOC_SUBDEV_QUERY_DV_TIMINGS

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Phần cứng có thể tự động phát hiện thời gian DV hiện tại,
tương tự như cảm nhận tiêu chuẩn video. Để làm như vậy, các ứng dụng gọi
ZZ0000ZZ với một con trỏ tới cấu trúc
ZZ0001ZZ. Một khi phần cứng phát hiện
thời gian, nó sẽ điền vào cấu trúc thời gian.

.. note::

   Drivers shall *not* switch timings automatically if new
   timings are detected. Instead, drivers should send the
   ``V4L2_EVENT_SOURCE_CHANGE`` event (if they support this) and expect
   that userspace will take action by calling :ref:`VIDIOC_QUERY_DV_TIMINGS`.
   The reason is that new timings usually mean different buffer sizes as
   well, and you cannot change buffer sizes on the fly. In general,
   applications that receive the Source Change event will have to call
   :ref:`VIDIOC_QUERY_DV_TIMINGS`, and if the detected timings are valid they
   will have to stop streaming, set the new timings, allocate new buffers
   and start streaming again.

Nếu không thể phát hiện được thời gian vì không có tín hiệu thì
ENOLINK được trả lại. Nếu một tín hiệu được phát hiện nhưng nó không ổn định và
bộ thu không thể khóa tín hiệu, sau đó ZZ0001ZZ sẽ được trả về. Nếu
máy thu có thể khóa tín hiệu nhưng định dạng không được hỗ trợ
(ví dụ: vì pixelclock nằm ngoài phạm vi của phần cứng
khả năng), sau đó trình điều khiển sẽ điền vào bất kỳ khoảng thời gian nào nó có thể tìm thấy
và trả về ZZ0002ZZ. Trong trường hợp đó ứng dụng có thể gọi
ZZ0000ZZ để so sánh
tìm thấy thời gian với khả năng của phần cứng để cung cấp thêm
phản hồi chính xác cho người dùng.

Giá trị trả về
==============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

ENODATA
    Định giờ video kỹ thuật số không được hỗ trợ cho đầu vào hoặc đầu ra này.

ENOLINK
    Không thể phát hiện thời gian vì không tìm thấy tín hiệu.

ENOLCK
    Tín hiệu không ổn định và phần cứng không thể khóa tín hiệu.

ERANGE
    Đã tìm thấy thời gian nhưng chúng nằm ngoài phạm vi của phần cứng
    khả năng.