.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/func-close.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _func-close:

*************
V4L2 đóng()
*************

Tên
====

v4l2-close - Đóng thiết bị V4L2

Tóm tắt
========

.. code-block:: c

    #include <unistd.h>

.. c:function:: int close( int fd )

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

Sự miêu tả
===========

Đóng thiết bị. Mọi hoạt động I/O đang diễn ra đều bị chấm dứt và tài nguyên
được liên kết với bộ mô tả tập tin được giải phóng. Tuy nhiên định dạng dữ liệu
tham số, đầu vào hoặc đầu ra hiện tại, giá trị điều khiển hoặc các thuộc tính khác
vẫn không thay đổi.

Giá trị trả về
==============

Hàm trả về 0 nếu thành công, -1 nếu thất bại và ZZ0000ZZ là
thiết lập một cách thích hợp. Mã lỗi có thể xảy ra:

EBADF
    ZZ0000ZZ không phải là bộ mô tả tệp mở hợp lệ.