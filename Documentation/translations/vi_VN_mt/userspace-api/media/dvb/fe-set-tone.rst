.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/fe-set-tone.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.fe

.. _FE_SET_TONE:

*****************
ioctl FE_SET_TONE
*****************

Tên
====

FE_SET_TONE - Đặt/đặt lại việc tạo âm 22kHz liên tục.

Tóm tắt
========

.. c:macro:: FE_SET_TONE

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Một giá trị liệt kê số nguyên được mô tả tại ZZ0000ZZ

Sự miêu tả
===========

Ioctl này được sử dụng để thiết lập việc tạo âm 22kHz liên tục.
Cuộc gọi này yêu cầu quyền đọc/ghi.

Thông thường, các hệ thống con ăng-ten vệ tinh yêu cầu thiết bị TV kỹ thuật số
để gửi âm 22kHz nhằm chọn giữa dải cao/thấp trên một số
LNBf băng tần kép. Nó cũng được sử dụng để gửi tín hiệu tới thiết bị DiSEqC, nhưng
việc này được thực hiện bằng cách sử dụng ioctls DiSEqC.

.. attention:: If more than one device is connected to the same antenna,
   setting a tone may interfere on other devices, as they may lose the
   capability of selecting the band. So, it is recommended that applications
   would change to SEC_TONE_OFF when the device is not used.

Giá trị trả về
==============

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.