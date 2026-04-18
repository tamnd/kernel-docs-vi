.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/rc/lirc-set-transmitter-mask.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: RC

.. _lirc_set_transmitter_mask:

*******************************
ioctl LIRC_SET_TRANSMITTER_MASK
*******************************

Tên
====

LIRC_SET_TRANSMITTER_MASK - Cho phép gửi mã trên một bộ máy phát nhất định

Tóm tắt
========

.. c:macro:: LIRC_SET_TRANSMITTER_MASK

ZZ0000ZZ

Đối số
=========

ZZ0000ZZ
    Bộ mô tả tệp được trả về bởi open().

ZZ0000ZZ
    Mặt nạ với các kênh để kích hoạt tx. Kênh 0 là bit ít quan trọng nhất.

Sự miêu tả
===========

Một số thiết bị IR TX có nhiều kênh đầu ra, trong trường hợp đó,
ZZ0000ZZ là
được trả về qua ZZ0001ZZ và ioctl này đặt những kênh nào sẽ
gửi mã IR.

Ioctl này cho phép tập hợp các máy phát nhất định. Máy phát đầu tiên là
được mã hóa bằng bit ít quan trọng nhất, v.v.

Khi mặt nạ bit không hợp lệ được cung cấp, tức là một bit được đặt, mặc dù thiết bị
không có quá nhiều bộ chuyển đổi thì ioctl này trả về số lượng
các bộ chuyển tiếp có sẵn và không làm gì khác.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.