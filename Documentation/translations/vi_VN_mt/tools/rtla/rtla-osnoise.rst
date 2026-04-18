.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/tools/rtla/rtla-osnoise.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================
rtla-osnoise
===============
------------------------------------------------------------------
Đo tiếng ồn của hệ điều hành
------------------------------------------------------------------

:Phần hướng dẫn sử dụng: 1

SYNOPSIS
========
ZZ0000ZZ [ZZ0001ZZ] ...

DESCRIPTION
===========

.. include:: common_osnoise_description.txt

Trình theo dõi ZZ0004ZZ xuất thông tin theo hai cách. Nó in định kỳ
bản tóm tắt về tiếng ồn của hệ điều hành, bao gồm cả bộ đếm của
sự xuất hiện của nguồn nhiễu. Nó cũng cung cấp thông tin
cho mỗi tiếng ồn thông qua các điểm theo dõi ZZ0000ZZ. ZZ0001ZZ
chế độ hiển thị thông tin về bản tóm tắt định kỳ từ công cụ theo dõi ZZ0005ZZ.
Chế độ ZZ0002ZZ hiển thị thông tin về tiếng ồn bằng cách sử dụng
điểm theo dõi ZZ0003ZZ. Để biết thêm chi tiết, vui lòng tham khảo
trang man tương ứng.

MODES
=====
ZZ0000ZZ

In bản tóm tắt từ osnoise tracer.

ZZ0000ZZ

In biểu đồ của các mẫu nhiễu.

Nếu không có MODE nào được đưa ra, chế độ trên cùng sẽ được gọi, truyền các đối số.

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
