.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/tools/rtla/rtla-timerlat.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==================
rtla-timerlat
================
-------------------------------------------
Đo độ trễ hẹn giờ của hệ điều hành
-------------------------------------------

:Phần hướng dẫn sử dụng: 1

SYNOPSIS
========
ZZ0000ZZ [ZZ0001ZZ] ...

DESCRIPTION
===========

.. include:: common_timerlat_description.txt

Chế độ ZZ0000ZZ hiển thị tóm tắt đầu ra định kỳ
từ thiết bị theo dõi ZZ0002ZZ. Chế độ ZZ0001ZZ hiển thị
biểu đồ của mỗi lần xuất hiện sự kiện theo dõi. Để biết thêm chi tiết, vui lòng
tham khảo trang man tương ứng.

MODES
=====
ZZ0000ZZ

In bản tóm tắt từ bộ theo dõi ZZ0000ZZ.

ZZ0000ZZ

In biểu đồ của các mẫu timelat.

Nếu không có ZZ0000ZZ nào được đưa ra, chế độ trên cùng sẽ được gọi, truyền các đối số.

OPTIONS
=======
ZZ0000ZZ, ZZ0001ZZ

Hiển thị văn bản trợ giúp.

Đối với các tùy chọn khác, hãy xem trang man để biết chế độ tương ứng.

SEE ALSO
========
ZZ0000ZZ\(1), ZZ0001ZZ\(1)

ZZ0000ZZ

AUTHOR
======
Viết bởi Daniel Bristot de Oliveira <bristot@kernel.org>

.. include:: common_appendix.txt
