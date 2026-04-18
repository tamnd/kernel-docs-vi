.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/dmx-fclose.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: DTV.dmx

.. _dmx_fclose:

===========================
Đóng demux TV kỹ thuật số()
========================

Tên
----

Đóng demux TV kỹ thuật số()

Tóm tắt
--------

.. c:function:: int close(int fd)

Đối số
---------

ZZ0001ZZ
  Bộ mô tả tệp được trả về bởi lệnh gọi trước tới
  ZZ0000ZZ.

Sự miêu tả
-----------

Lệnh gọi hệ thống này sẽ hủy kích hoạt và giải phóng bộ lọc đã được
được phân bổ trước đó thông qua lệnh gọi ZZ0000ZZ.

Giá trị trả về
------------

Khi thành công 0 được trả về.

Nếu có lỗi, -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.