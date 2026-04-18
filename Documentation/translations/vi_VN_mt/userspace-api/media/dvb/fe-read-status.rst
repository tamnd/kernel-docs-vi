.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/fe-read-status.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.fe

.. _FE_READ_STATUS:

********************
ioctl FE_READ_STATUS
********************

Tên
====

FE_READ_STATUS - Trả về thông tin trạng thái về giao diện người dùng. Cuộc gọi này chỉ yêu cầu - quyền truy cập chỉ đọc vào thiết bị

Tóm tắt
========

.. c:macro:: FE_READ_STATUS

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    con trỏ tới số nguyên bitmask chứa đầy các giá trị được xác định bởi enum
    ZZ0000ZZ.

Sự miêu tả
===========

Tất cả các thiết bị đầu cuối TV kỹ thuật số đều hỗ trợ ZZ0000ZZ ioctl. Đó là
được sử dụng để kiểm tra trạng thái khóa của giao diện người dùng sau khi được
điều chỉnh. ioctl lấy một con trỏ tới một số nguyên nơi trạng thái sẽ là
được viết.

.. note::

   The size of status is actually sizeof(enum fe_status), with
   varies according with the architecture. This needs to be fixed in the
   future.

int fe_status
=============

Tham số fe_status được sử dụng để biểu thị trạng thái hiện tại và/hoặc
thay đổi trạng thái của phần cứng giao diện người dùng. Nó được sản xuất bằng cách sử dụng enum
Giá trị ZZ0000ZZ trên mặt nạ bit

Giá trị trả về
==============

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.