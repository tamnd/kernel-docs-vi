.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/mediactl/media-func-close.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: MC

.. _media-func-close:

******************
phương tiện đóng()
******************

Tên
====

media-close - Đóng thiết bị đa phương tiện

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

Đóng thiết bị đa phương tiện. Tài nguyên được liên kết với bộ mô tả tệp
được giải thoát. Cấu hình thiết bị không thay đổi.

Giá trị trả về
============

ZZ0000ZZ trả về 0 nếu thành công. Nếu có lỗi, -1 được trả về và
ZZ0001ZZ được đặt phù hợp. Các mã lỗi có thể xảy ra là:

EBADF
    ZZ0000ZZ không phải là bộ mô tả tệp mở hợp lệ.