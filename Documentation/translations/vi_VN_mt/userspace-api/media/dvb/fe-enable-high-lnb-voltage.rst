.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/fe-enable-high-lnb-voltage.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.fe

.. _FE_ENABLE_HIGH_LNB_VOLTAGE:

********************************
ioctl FE_ENABLE_HIGH_LNB_VOLTAGE
********************************

Tên
====

FE_ENABLE_HIGH_LNB_VOLTAGE - Chọn mức DC đầu ra giữa điện áp LNBf bình thường hoặc điện áp LNBf cao hơn.

Tóm tắt
========

.. c:macro:: FE_ENABLE_HIGH_LNB_VOLTAGE

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ
    Cờ hợp lệ:

- 0 - bình thường 13V và 18V.

- >0 - cho phép điện áp cao hơn một chút thay vì 13/18V, theo thứ tự
       để bù đắp cho cáp ăng-ten dài.

Sự miêu tả
===========

Chọn mức DC đầu ra giữa điện áp LNBf bình thường hoặc LNBf cao hơn
điện áp trong khoảng 0 (bình thường) hoặc giá trị cao hơn 0 đối với mức cao hơn
điện áp.

Giá trị trả về
==============

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.