.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/mediactl/request-func-poll.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: MC

.. _request-func-poll:

**************
yêu cầu thăm dò ý kiến()
**************

Tên
====

yêu cầu thăm dò ý kiến ​​- Đợi một số sự kiện trên bộ mô tả tệp

Tóm tắt
========

.. code-block:: c

    #include <sys/poll.h>

.. c:function:: int poll( struct pollfd *ufds, unsigned int nfds, int timeout )

Đối số
=========

ZZ0000ZZ
   Danh sách các sự kiện mô tả tập tin sẽ được theo dõi

ZZ0000ZZ
   Số sự kiện mô tả tệp tại mảng \*ufds

ZZ0000ZZ
   Hết thời gian chờ sự kiện

Sự miêu tả
===========

Với chức năng ZZ0000ZZ, các ứng dụng có thể chờ
để hoàn thành một yêu cầu.

Khi thành công ZZ0000ZZ trả về số lượng tệp
các bộ mô tả đã được chọn (nghĩa là các bộ mô tả tệp mà
Trường ZZ0002ZZ của cấu trúc ZZ0001ZZ tương ứng
là khác không). Bộ mô tả tệp yêu cầu đặt cờ ZZ0003ZZ trong ZZ0004ZZ
khi yêu cầu được hoàn thành.  Khi chức năng hết thời gian, nó sẽ trả về
giá trị bằng 0, nếu thất bại nó trả về -1 và biến ZZ0005ZZ là
thiết lập một cách thích hợp.

Cố gắng thăm dò ý kiến ​​cho một yêu cầu chưa được xếp hàng đợi sẽ
đặt cờ ZZ0000ZZ trong ZZ0001ZZ.

Giá trị trả về
============

Khi thành công, ZZ0000ZZ trả về số lượng
các cấu trúc có trường ZZ0001ZZ khác 0 hoặc bằng 0 nếu lệnh gọi
đã hết thời gian. Khi có lỗi -1 được trả về và biến ZZ0002ZZ được đặt
một cách thích hợp:

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