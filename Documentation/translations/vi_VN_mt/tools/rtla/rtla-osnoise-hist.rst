.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/tools/rtla/rtla-osnoise-hist.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. |tool| replace:: osnoise hist

=====================
rtla-osnoise-hist
===================
------------------------------------------------------
Hiển thị biểu đồ của các mẫu đánh dấu âm thanh
------------------------------------------------------

:Phần hướng dẫn sử dụng: 1

SYNOPSIS
========
ZZ0000ZZ [ZZ0001ZZ]

DESCRIPTION
===========
.. include:: common_osnoise_description.txt

Công cụ ZZ0000ZZ thu thập tất cả ZZ0001ZZ
xuất hiện trong biểu đồ, hiển thị kết quả theo cách thân thiện với người dùng.
Công cụ này cũng cho phép nhiều cấu hình của bộ theo dõi ZZ0002ZZ và
bộ sưu tập đầu ra của bộ theo dõi.

OPTIONS
=======
.. include:: common_osnoise_options.txt

.. include:: common_hist_options.txt

.. include:: common_options.txt

EXAMPLE
=======
Trong ví dụ bên dưới, các luồng theo dõi ZZ0001ZZ được thiết lập để chạy với thời gian thực
ưu tiên ZZ0002ZZ, trên CPU ZZ0003ZZ, cho ZZ0004ZZ ở mỗi thời kỳ (ZZ0005ZZ theo
mặc định). Lý do giảm thời gian chạy là để tránh việc chết đói
Công cụ ZZ0000ZZ. Công cụ này cũng được thiết lập để chạy cho ZZ0006ZZ. Đầu ra
biểu đồ được đặt thành nhóm đầu ra trong nhóm mục nhập ZZ0007ZZ và ZZ0008ZZ::

[root@f34 ~/]# rtla lịch sử nhiễu -P F:1 -c 0-11 -r 900000 -d 1M -b 10 -E 25
  Biểu đồ nhiễu # ZZ0000ZZ
  Đơn vị # Time là micro giây (chúng tôi)
  # Duration: 0 00:01:00
  Chỉ mục CPU-000 CPU-001 CPU-002 CPU-003 CPU-004 CPU-005 CPU-006 CPU-007 CPU-008 CPU-009 CPU-010 CPU-011
  0 42982 46287 51779 53740 52024 44817 49898 36500 50408 50128 49523 52377
  10 12224 8356 2912 878 2667 10155 4573 18894 4214 4836 5708 2413
  20 8 5 12 2 13 24 20 41 29 53 39 39
  30 1 1 0 0 10 3 6 19 15 31 30 38
  40 0 0 0 0 0 4 2 7 2 3 8 11
  50 0 0 0 0 0 0 0 0 0 1 1 2
  trên: 0 0 0 0 0 0 0 0 0 0 0 0
  số lượng: 55215 54649 54703 54620 54714 55003 54499 55461 54668 55052 55309 54880
  phút: 0 0 0 0 0 0 0 0 0 0 0 0
  trung bình: 0 0 0 0 0 0 0 0 0 0 0 0
  tối đa: 30 30 20 20 30 40 40 40 40 50 50 50

SEE ALSO
========
ZZ0000ZZ\(1), ZZ0001ZZ\(1)

ZZ0000ZZ

AUTHOR
======
Viết bởi Daniel Bristot de Oliveira <bristot@kernel.org>

.. include:: common_appendix.txt
