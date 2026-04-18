.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/ca-get-slot-info.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.ca

.. _CA_GET_SLOT_INFO:

==================
CA_GET_SLOT_INFO
==================

Tên
----

CA_GET_SLOT_INFO

Tóm tắt
--------

.. c:macro:: CA_GET_SLOT_INFO

ZZ0000ZZ

Đối số
---------

ZZ0001ZZ
  Bộ mô tả tệp được trả về bởi lệnh gọi trước tới ZZ0000ZZ.

ZZ0001ZZ
  Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
-----------

Trả về thông tin về một khe CA được xác định bởi
ZZ0000ZZ.slot_num.

Giá trị trả về
------------

Khi thành công, 0 được trả về và ZZ0000ZZ được điền.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

.. tabularcolumns:: |p{2.5cm}|p{15.0cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths: 1 16

    -  -  ``ENODEV``
       -  the slot is not available.

Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.