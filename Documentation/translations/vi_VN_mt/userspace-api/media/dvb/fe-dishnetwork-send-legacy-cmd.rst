.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/fe-dishnetwork-send-legacy-cmd.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.fe

.. _FE_DISHNETWORK_SEND_LEGACY_CMD:

*******************************
FE_DISHNETWORK_SEND_LEGACY_CMD
*******************************

Tên
====

FE_DISHNETWORK_SEND_LEGACY_CMD

Tóm tắt
========

.. c:macro:: FE_DISHNETWORK_SEND_LEGACY_CMD

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ
    Gửi cmd thô được chỉ định tới đĩa thông qua DISEqC.

Sự miêu tả
===========

.. warning::
   This is a very obscure legacy command, used only at stv0299
   driver. Should not be used on newer drivers.

Nó cung cấp một phương pháp không chuẩn để chọn điện áp Diseqc trên
giao diện người dùng, dành cho các thiết bị chuyển mạch kế thừa của Dish Network.

Vì sự hỗ trợ cho ioctl này đã được thêm vào năm 2004, điều này có nghĩa là
các món ăn đã trở thành di sản vào năm 2004.

Giá trị trả về
============

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.