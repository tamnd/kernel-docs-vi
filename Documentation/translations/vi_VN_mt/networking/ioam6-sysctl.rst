.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/ioam6-sysctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Biến hệ thống IOAM6
=====================


Các biến /proc/sys/net/conf/<iface>/ioam6_*:
=============================================

ioam6_enabled - BOOL
        Chấp nhận (= đã bật) hoặc bỏ qua (= đã tắt) tùy chọn IPv6 IOAM khi xâm nhập
        cho giao diện này.

* 0 - bị tắt (mặc định)
        * 1 - đã bật

ioam6_id - SHORT INTEGER
        Xác định id IOAM của giao diện này.

Mặc định là ~0.

ioam6_id_wide - INTEGER
        Xác định id IOAM rộng của giao diện này.

Mặc định là ~0.