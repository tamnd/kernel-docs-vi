.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/watchdog/watchdog-pm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================================
Hướng dẫn quản lý nguồn điện của bộ hẹn giờ WatchDog Linux
===============================================

Đánh giá lần cuối: 17-12-2018

Wolfram Sang <wsa+renesas@sang-engineering.com>

Giới thiệu
------------
Tài liệu này nêu các quy tắc về thiết bị giám sát và quản lý năng lượng của chúng
xử lý để đảm bảo hành vi thống nhất cho các hệ thống Linux.


Ping trên sơ yếu lý lịch
--------------
Khi tiếp tục, bộ đếm thời gian theo dõi sẽ được đặt lại về giá trị đã chọn để cung cấp
không gian người dùng đủ thời gian để tiếp tục. [1] [2]

[1] ZZ0000ZZ

[2] ZZ0000ZZ
