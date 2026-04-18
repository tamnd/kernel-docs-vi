.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/ca-get-msg.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.ca

.. _CA_GET_MSG:

===========
CA_GET_MSG
==========

Tên
----

CA_GET_MSG

Tóm tắt
--------

.. c:macro:: CA_GET_MSG

ZZ0000ZZ

Đối số
---------

ZZ0001ZZ
  Bộ mô tả tệp được trả về bởi lệnh gọi trước tới ZZ0000ZZ.

ZZ0001ZZ
  Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
-----------

Nhận tin nhắn qua mô-đun CI CA.

.. note::

   Please notice that, on most drivers, this is done by reading from
   the /dev/adapter?/ca? device node.

Giá trị trả về
------------

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.