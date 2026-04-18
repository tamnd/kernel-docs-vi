.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/ca-fopen.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.ca

.. _ca_fopen:

===============================
CA truyền hình kỹ thuật số mở()
===============================

Tên
----

CA truyền hình kỹ thuật số mở()

Tóm tắt
--------

.. c:function:: int open(const char *name, int flags)

Đối số
---------

ZZ0000ZZ
  Tên của thiết bị CA TV kỹ thuật số cụ thể.

ZZ0000ZZ
  Một chút HOẶC của các cờ sau:

.. tabularcolumns:: |p{2.5cm}|p{15.0cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths: 1 16

    -  - ``O_RDONLY``
       - read-only access

    -  - ``O_RDWR``
       - read/write access

    -  - ``O_NONBLOCK``
       - open in non-blocking mode
         (blocking mode is the default)

Sự miêu tả
-----------

Cuộc gọi hệ thống này sẽ mở một thiết bị ca có tên (ví dụ: ZZ0000ZZ)
để sử dụng tiếp theo.

Khi cuộc gọi ZZ0000ZZ thành công, thiết bị sẽ sẵn sàng để sử dụng. các
tầm quan trọng của chế độ chặn hoặc không chặn được mô tả trong
tài liệu cho các chức năng có sự khác biệt. Nó không
ảnh hưởng đến ngữ nghĩa của chính lệnh gọi ZZ0001ZZ. Một thiết bị được mở trong
chế độ chặn sau này có thể được chuyển sang chế độ không chặn (và ngược lại)
bằng cách sử dụng lệnh ZZ0002ZZ của lệnh gọi hệ thống ZZ0003ZZ. Đây là một
cuộc gọi hệ thống tiêu chuẩn, được ghi lại trong trang hướng dẫn Linux cho fcntl.
Chỉ một người dùng có thể mở Thiết bị CA ở chế độ ZZ0004ZZ. Tất cả khác
nỗ lực mở thiết bị ở chế độ này sẽ không thành công và mã lỗi
sẽ được trả lại.

Giá trị trả về
------------

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.