.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/rc/lirc-read.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: RC

.. _lirc-read:

***********
LIRC read()
***********

Name
====

lirc-read - Read from a LIRC device

Synopsis
========

.. code-block:: c

    #include <unistd.h>

.. c:function:: ssize_t read( int fd, void *buf, size_t count )

Arguments
=========

ZZ0000ZZ
    Bộ mô tả tệp được trả về bởi ZZ0001ZZ.

ZZ0000ZZ
   Bộ đệm cần được lấp đầy

ZZ0000ZZ
   Số byte tối đa để đọc

Sự miêu tả
===========

ZZ0000ZZ cố gắng đọc tối đa ZZ0002ZZ byte từ tệp
bộ mô tả ZZ0003ZZ vào bộ đệm bắt đầu từ ZZ0004ZZ.  Nếu ZZ0005ZZ bằng 0,
ZZ0001ZZ trả về 0 và không có kết quả nào khác. Nếu ZZ0006ZZ
lớn hơn ZZ0007ZZ thì kết quả không được xác định.

Định dạng chính xác của dữ liệu phụ thuộc vào trình điều khiển ZZ0000ZZ
công dụng. Sử dụng ZZ0001ZZ để nhận chế độ được hỗ trợ và sử dụng
ZZ0002ZZ đặt chế độ hoạt động hiện tại.

Chế độ ZZ0000ZZ dành cho IR thô,
trong đó các gói chứa giá trị unsigned int mô tả tín hiệu IR
đọc từ chardev.

Ngoài ra, ZZ0000ZZ có thể có sẵn,
ở chế độ này, mã quét được giải mã bằng bộ giải mã phần mềm hoặc
bằng bộ giải mã phần cứng. Thành viên ZZ0001ZZ được đặt thành
ZZ0002ZZ
được sử dụng để truyền và ZZ0003ZZ cho mã quét được giải mã,
và ZZ0004ZZ được đặt thành mã khóa hoặc ZZ0005ZZ.

Giá trị trả về
============

Khi thành công, số byte đã đọc sẽ được trả về. Đó không phải là lỗi nếu
con số này nhỏ hơn số byte được yêu cầu hoặc số lượng
dữ liệu cần thiết cho một khung hình.  Nếu có lỗi, -1 được trả về và ZZ0000ZZ
biến được đặt phù hợp.