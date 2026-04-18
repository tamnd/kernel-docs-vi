.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/dmx-fwrite.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.dmx

.. _dmx_fwrite:

===================================
Ghi demux truyền hình kỹ thuật số()
===================================

Tên
----

Ghi demux truyền hình kỹ thuật số()

Tóm tắt
--------

.. c:function:: ssize_t write(int fd, const void *buf, size_t count)

Đối số
---------

ZZ0001ZZ
  Bộ mô tả tệp được trả về bởi lệnh gọi trước tới ZZ0000ZZ.

ZZ0000ZZ
     Bộ đệm chứa dữ liệu cần ghi

ZZ0000ZZ
    Số byte tại bộ đệm

Sự miêu tả
-----------

Cuộc gọi hệ thống này chỉ được cung cấp bởi thiết bị logic
ZZ0000ZZ, được liên kết với thiết bị demux vật lý
cung cấp chức năng DVR thực tế. Nó được sử dụng để phát lại một
Luồng truyền tải được ghi lại bằng kỹ thuật số. Bộ lọc phù hợp phải được xác định
trong thiết bị demux vật lý tương ứng, ZZ0001ZZ.
Lượng dữ liệu được truyền được ngụ ý bằng số lượng.

Giá trị trả về
------------

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

.. tabularcolumns:: |p{2.5cm}|p{15.0cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths: 1 16

    -  -  ``EWOULDBLOCK``
       -  No data was written. This might happen if ``O_NONBLOCK`` was
	  specified and there is no more buffer space available (if
	  ``O_NONBLOCK`` is not specified the function will block until buffer
	  space is available).

    -  -  ``EBUSY``
       -  This error code indicates that there are conflicting requests. The
	  corresponding demux device is setup to receive data from the
	  front- end. Make sure that these filters are stopped and that the
	  filters with input set to ``DMX_IN_DVR`` are started.

Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.