.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/mediactl/media-func-open.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: MC

.. _media-func-open:

*************
phương tiện mở()
************

Tên
====

media-open - Mở thiết bị media

Tóm tắt
========

.. code-block:: c

    #include <fcntl.h>

.. c:function:: int open( const char *device_name, int flags )

Đối số
=========

ZZ0000ZZ
    Thiết bị cần mở.

ZZ0000ZZ
    Mở cờ. Chế độ truy cập phải là ZZ0001ZZ hoặc ZZ0002ZZ.
    Các cờ khác không có hiệu lực.

Sự miêu tả
===========

Để mở ứng dụng thiết bị đa phương tiện, hãy gọi ZZ0000ZZ bằng
tên thiết bị mong muốn. Chức năng này không có tác dụng phụ; thiết bị
cấu hình vẫn không thay đổi.

Khi thiết bị được mở ở chế độ chỉ đọc, hãy cố gắng sửa đổi
cấu hình sẽ dẫn đến lỗi và ZZ0000ZZ sẽ được đặt thành
EBADF.

Giá trị trả về
============

ZZ0000ZZ trả về bộ mô tả tệp mới nếu thành công. Do lỗi,
-1 được trả về và ZZ0001ZZ được đặt phù hợp. Mã lỗi có thể xảy ra
là:

EACCES
    Quyền truy cập được yêu cầu vào tệp không được phép.

EMFILE
    Quá trình này đã mở được số lượng tệp tối đa.

ENFILE
    Đã đạt đến giới hạn hệ thống về tổng số tệp đang mở.

ENOMEM
    Bộ nhớ kernel không đủ.

ENXIO
    Không có thiết bị nào tương ứng với tập tin đặc biệt của thiết bị này tồn tại.