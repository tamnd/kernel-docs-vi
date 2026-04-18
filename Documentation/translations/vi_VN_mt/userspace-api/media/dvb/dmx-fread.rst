.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/dmx-fread.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.dmx

.. _dmx_fread:

============================
Đọc giải mã TV kỹ thuật số()
============================

Tên
----

Đọc giải mã TV kỹ thuật số()

Tóm tắt
--------

.. c:function:: size_t read(int fd, void *buf, size_t count)

Đối số
---------

ZZ0001ZZ
  Bộ mô tả tệp được trả về bởi lệnh gọi trước tới ZZ0000ZZ.

ZZ0000ZZ
   Bộ đệm cần được lấp đầy

ZZ0000ZZ
   Số byte tối đa để đọc

Sự miêu tả
-----------

Cuộc gọi hệ thống này trả về dữ liệu đã lọc, có thể là phần hoặc được đóng gói
Dữ liệu Dòng cơ bản (PES). Dữ liệu đã lọc được chuyển từ
bộ đệm tròn bên trong của trình điều khiển tới ZZ0000ZZ. Lượng dữ liệu tối đa
được chuyển giao được ngụ ý bởi số lượng.

.. note::

   if a section filter created with
   :c:type:`DMX_CHECK_CRC <dmx_sct_filter_params>` flag set,
   data that fails on CRC check will be silently ignored.

Giá trị trả về
--------------

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

.. tabularcolumns:: |p{2.5cm}|p{15.0cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths: 1 16

    -  -  ``EWOULDBLOCK``
       -  No data to return and ``O_NONBLOCK`` was specified.

    -  -  ``EOVERFLOW``
       -  The filtered data was not read from the buffer in due time,
	  resulting in non-read data being lost. The buffer is flushed.

    -  -  ``ETIMEDOUT``
       -  The section was not loaded within the stated timeout period.
          See ioctl :ref:`DMX_SET_FILTER` for how to set a timeout.

    -  -  ``EFAULT``
       -  The driver failed to write to the callers buffer due to an
          invalid \*buf pointer.

Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.