.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/cec/cec-func-poll.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: CEC

.. _cec-func-poll:

******************
cuộc thăm dò cec()
******************

Tên
====

cec-poll - Đợi một số sự kiện trên bộ mô tả tệp

Tóm tắt
========

.. code-block:: c

    #include <sys/poll.h>

.. c:function:: int poll( struct pollfd *ufds, unsigned int nfds, int timeout )

Đối số
=========

ZZ0000ZZ
   Danh sách các sự kiện FD cần theo dõi

ZZ0000ZZ
   Số sự kiện FD tại mảng \*ufds

ZZ0000ZZ
   Hết thời gian chờ sự kiện

Sự miêu tả
===========

Với chức năng ZZ0000ZZ, các ứng dụng có thể đợi CEC
sự kiện.

Khi thành công ZZ0000ZZ trả về số lượng bộ mô tả tệp
đã được chọn (nghĩa là các bộ mô tả tệp mà
Trường ZZ0002ZZ của cấu trúc ZZ0001ZZ tương ứng
là khác không). Các thiết bị CEC đặt cờ ZZ0003ZZ và ZZ0004ZZ trong
trường ZZ0005ZZ nếu có tin nhắn trong hàng đợi nhận. Nếu
hàng đợi truyền có chỗ cho các tin nhắn mới, ZZ0006ZZ và
Cờ ZZ0007ZZ được đặt. Nếu có sự kiện trong hàng đợi sự kiện,
sau đó cờ ZZ0008ZZ được đặt. Khi chức năng hết thời gian, nó sẽ trả về
giá trị bằng 0, nếu thất bại nó trả về -1 và biến ZZ0009ZZ là
thiết lập một cách thích hợp.

Để biết thêm chi tiết, hãy xem trang hướng dẫn sử dụng ZZ0000ZZ.

Giá trị trả về
==============

Khi thành công, ZZ0000ZZ trả về cấu trúc số có
các trường ZZ0001ZZ khác 0 hoặc 0 nếu cuộc gọi đã hết thời gian. Do lỗi -1
được trả về và biến ZZ0002ZZ được đặt thích hợp:

ZZ0000ZZ
    Một hoặc nhiều thành viên ZZ0001ZZ chỉ định tệp không hợp lệ
    mô tả.

ZZ0000ZZ
    ZZ0001ZZ tham chiếu vùng bộ nhớ không thể truy cập.

ZZ0000ZZ
    Cuộc gọi bị gián đoạn bởi một tín hiệu.

ZZ0000ZZ
    Giá trị ZZ0001ZZ vượt quá giá trị ZZ0002ZZ. sử dụng
    ZZ0003ZZ để có được giá trị này.