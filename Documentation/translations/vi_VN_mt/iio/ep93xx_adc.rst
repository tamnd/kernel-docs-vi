.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/iio/ep93xx_adc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
Trình điều khiển Cirrus Logic EP93xx ADC
========================================

1. Tổng quan
============

Trình điều khiển được thiết kế để hoạt động trên cả hai thiết bị cấp thấp (EP9301, EP9302) với
ADC 5 kênh và các thiết bị cao cấp (EP9307, EP9312, EP9315) 10 kênh
màn hình cảm ứng/mô-đun ADC.

2. Đánh số kênh
====================

Sơ đồ đánh số cho các kênh 0..4 được xác định trong bảng dữ liệu EP9301 và EP9302.
EP9307, EP9312 và EP9315 có thêm 3 kênh (tổng cộng 8), nhưng việc đánh số là
không được xác định. Vì vậy, giả sử ba số cuối cùng được đánh số ngẫu nhiên.

Giả sử ep93xx_adc là IIO device0, bạn sẽ tìm thấy các mục sau trong
/sys/bus/iio/devices/iio:device0/:

+--------+--------------+
  Tên bóng/pin ZZ0000ZZ |
  +=====================================+
  ZZ0001ZZ YM |
  +--------+--------------+
  ZZ0002ZZ SXP |
  +--------+--------------+
  ZZ0003ZZ SXM |
  +--------+--------------+
  ZZ0004ZZ SYP |
  +--------+--------------+
  ZZ0005ZZ SYM |
  +--------+--------------+
  ZZ0006ZZ XP |
  +--------+--------------+
  ZZ0007ZZ XM |
  +--------+--------------+
  ZZ0008ZZ YP |
  +--------+--------------+
