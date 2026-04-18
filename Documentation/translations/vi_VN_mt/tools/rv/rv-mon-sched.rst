.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/tools/rv/rv-mon-sched.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============
rv-mon-lịch
=============
------------------------------
Bộ sưu tập giám sát lịch trình
------------------------------

:Phần hướng dẫn sử dụng: 1

SYNOPSIS
========

ZZ0000ZZ [ZZ0001ZZ]

ZZ0000ZZ [ZZ0001ZZ]

ZZ0000ZZ [ZZ0001ZZ]

DESCRIPTION
===========

Bộ sưu tập màn hình lập lịch trình là nơi chứa một số màn hình để lập mô hình
hành vi của bộ lập lịch. Mỗi màn hình mô tả một thông số kỹ thuật
người lập lịch trình nên tuân theo.

Là nơi chứa màn hình, nó sẽ kích hoạt tất cả các màn hình lồng nhau và đặt chúng
theo OPTIONS.
Tuy nhiên, các màn hình lồng nhau cũng có thể được kích hoạt độc lập theo tên
và bằng cách chỉ định lịch: , ví dụ: để chỉ bật màn hình tss, bạn có thể thực hiện bất kỳ điều nào sau đây:

# rv lịch trình thứ hai:tss

# rv mon tss

Xem tài liệu kernel để biết thêm thông tin về màn hình này:
<ZZ0000ZZ

OPTIONS
=======

.. include:: common_ikm.rst

NESTED MONITOR
==============

Các màn hình lồng nhau có sẵn là:
  * scpd: lịch trình được gọi với quyền ưu tiên bị vô hiệu hóa
  * snep: lịch trình không cho phép ưu tiên
  * sncid: lịch trình không được gọi và ngắt bị vô hiệu hóa
  * snroc: đặt không thể chạy được trên ngữ cảnh của chính nó
  * sco: lập kế hoạch hoạt động theo ngữ cảnh
  * tss: chuyển đổi nhiệm vụ trong khi lên lịch

SEE ALSO
========

ZZ0000ZZ\(1), ZZ0001ZZ\(1)

Tài liệu ZZ0000ZZ của nhân Linux:
<ZZ0001ZZ

AUTHOR
======

Viết bởi Gabriele Monaco <gmonaco@redhat.com>

.. include:: common_appendix.rst