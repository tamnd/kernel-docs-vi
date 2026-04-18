.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/tools/rtla/rtla-osnoise-top.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. |tool| replace:: osnoise top

=====================
rtla-osnoise-top
=====================
-----------------------------------------------
Hiển thị tóm tắt tiếng ồn của hệ điều hành
-----------------------------------------------

:Phần hướng dẫn sử dụng: 1

SYNOPSIS
========
ZZ0000ZZ [ZZ0001ZZ]

DESCRIPTION
===========
.. include:: common_osnoise_description.txt

ZZ0000ZZ thu thập bản tóm tắt định kỳ từ công cụ theo dõi ZZ0001ZZ,
bao gồm cả bộ đếm sự xuất hiện của nguồn nhiễu,
hiển thị kết quả ở định dạng thân thiện với người dùng.

Công cụ này cũng cho phép nhiều cấu hình của bộ theo dõi ZZ0000ZZ và
bộ sưu tập đầu ra của bộ theo dõi.

OPTIONS
=======
.. include:: common_osnoise_options.txt

.. include:: common_top_options.txt

.. include:: common_options.txt

EXAMPLE
=======
Trong ví dụ bên dưới, công cụ ZZ0000ZZ được thiết lập để chạy với
ưu tiên thời gian thực ZZ0001ZZ, trên CPU ZZ0002ZZ, cho ZZ0003ZZ ở mỗi thời kỳ
(ZZ0004ZZ theo mặc định). Lý do giảm thời gian chạy là để tránh chết đói
công cụ rtla. Công cụ này cũng được thiết lập để chạy cho ZZ0005ZZ và hiển thị
tóm tắt báo cáo cuối buổi::

[root@f34 ~]# rtla tiếng ồn hàng đầu -P F:1 -c 0-3 -r 900000 -d 1M -q
                                          Tiếng ồn của hệ điều hành
  thời lượng: 0 00:01:00 | thời gian ở trong chúng ta
  CPU Tiếng ồn trong thời gian chạy % CPU Tiếng ồn tối đa aval Tối đa đơn HW NMI IRQ Softirq Chủ đề
    0 #59 53100000 304896 99.42580 6978 56 549 0 53111 1590 13
    1 #59 53100000 338339 99.36282 8092 24 399 0 53130 1448 31
    2 #59 53100000 290842 99.45227 6582 39 855 0 53110 1406 12
    3 #59 53100000 204935 99.61405 6251 33 290 0 53156 1460 12

SEE ALSO
========

ZZ0000ZZ\(1), ZZ0001ZZ\(1)

ZZ0000ZZ

AUTHOR
======
Viết bởi Daniel Bristot de Oliveira <bristot@kernel.org>

.. include:: common_appendix.txt
