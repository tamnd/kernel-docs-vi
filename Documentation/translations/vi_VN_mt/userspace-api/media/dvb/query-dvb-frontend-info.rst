.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/query-dvb-frontend-info.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _query-dvb-frontend-info:

*****************************
Truy vấn thông tin giao diện người dùng
*****************************

Thông thường, việc đầu tiên cần làm khi mở giao diện người dùng là kiểm tra
khả năng của giao diện người dùng. Việc này được thực hiện bằng cách sử dụng
ZZ0000ZZ. Ioctl này sẽ liệt kê
Phiên bản TV kỹ thuật số API và các đặc điểm khác về giao diện người dùng và có thể
được mở ở chế độ chỉ đọc hoặc đọc/ghi.