.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/query-dvb-frontend-info.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _query-dvb-frontend-info:

*****************************
Truy vấn thông tin giao diện người dùng
*****************************

Thông thường, việc đầu tiên cần làm khi mở giao diện người dùng là kiểm tra
khả năng của giao diện người dùng. Việc này được thực hiện bằng cách sử dụng
ZZ0000ZZ. Ioctl này sẽ liệt kê
Phiên bản TV kỹ thuật số API và các đặc điểm khác về giao diện người dùng và có thể
được mở ở chế độ chỉ đọc hoặc đọc/ghi.