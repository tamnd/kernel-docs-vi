.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/func-munmap.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _func-munmap:

*************
V4L2 munmap()
*************

Tên
====

v4l2-munmap - Unmap bộ nhớ thiết bị

Tóm tắt
========

.. code-block:: c

    #include <unistd.h>
    #include <sys/mman.h>

.. c:function:: int munmap( void *start, size_t length )

Đối số
=========

ZZ0001ZZ
    Địa chỉ của bộ đệm được ánh xạ được trả về bởi
    Chức năng ZZ0000ZZ.

ZZ0003ZZ
    Độ dài của bộ đệm được ánh xạ. Giá trị này phải giống với giá trị được đưa ra cho
    ZZ0000ZZ và được trình điều khiển trả về trong cấu trúc
    Trường ZZ0001ZZ ZZ0004ZZ dành cho
    API đơn phẳng và trong cấu trúc
    Trường ZZ0002ZZ ZZ0005ZZ dành cho
    đa mặt phẳng API.

Sự miêu tả
===========

Hủy ánh xạ trước đó với hàm ZZ0000ZZ được ánh xạ
đệm và giải phóng nó, nếu có thể.

Giá trị trả về
============

Khi thành công ZZ0000ZZ trả về 0, nếu thất bại -1 và
Biến ZZ0001ZZ được đặt phù hợp:

EINVAL
    ZZ0000ZZ hoặc ZZ0001ZZ không chính xác hoặc không có bộ đệm nào được cài đặt
    đã lập bản đồ chưa.