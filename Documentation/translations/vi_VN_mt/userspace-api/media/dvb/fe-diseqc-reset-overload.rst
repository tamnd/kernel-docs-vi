.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/fe-diseqc-reset-overload.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.fe

.. _FE_DISEQC_RESET_OVERLOAD:

*******************************
ioctl FE_DISEQC_RESET_OVERLOAD
*******************************

Tên
====

FE_DISEQC_RESET_OVERLOAD - Khôi phục nguồn điện cho hệ thống con ăng-ten nếu hệ thống này bị tắt do quá tải điện.

Tóm tắt
========

.. c:macro:: FE_DISEQC_RESET_OVERLOAD

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

Sự miêu tả
===========

Nếu xe buýt tự động tắt nguồn do quá tải điện,
cuộc gọi ioctl này sẽ khôi phục nguồn điện cho xe buýt. Cuộc gọi yêu cầu
quyền truy cập đọc/ghi vào thiết bị. Cuộc gọi này không có hiệu lực nếu thiết bị
được tắt nguồn bằng tay. Không phải tất cả các bộ điều hợp TV kỹ thuật số đều hỗ trợ ioctl này.

Giá trị trả về
============

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.