.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/tracepoint.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==================================
Điểm theo dõi hạt nhân Linux API
===============================

:Tác giả: Jason Baron
:Tác giả: William Cohen

Giới thiệu
============

Dấu vết là các điểm thăm dò tĩnh nằm ở các điểm chiến lược
khắp hạt nhân. 'Thăm dò' đăng ký/hủy đăng ký với các điểm theo dõi thông qua
một cơ chế gọi lại. 'Thăm dò' là các hàm được định kiểu nghiêm ngặt
đã chuyển một bộ tham số duy nhất được xác định bởi mỗi điểm theo dõi.

Từ cơ chế gọi lại đơn giản này, 'thăm dò' có thể được sử dụng để lập hồ sơ,
gỡ lỗi và hiểu hành vi của kernel. Có một số công cụ
cung cấp một khuôn khổ cho việc sử dụng 'thăm dò'. Những công cụ này bao gồm Systemtap,
ftrace và LTTng.

Dấu vết được xác định trong một số tệp tiêu đề thông qua các macro khác nhau.
Vì vậy, mục đích của tài liệu này là cung cấp sự giải thích rõ ràng về
các dấu vết có sẵn. Mục đích là để hiểu không chỉ những gì
các điểm theo dõi có sẵn nhưng cũng để hiểu được tương lai ở đâu
dấu vết có thể được thêm vào.

API được trình bày có các chức năng có dạng:
ZZ0000ZZ. Đây là những dấu vết
các cuộc gọi lại được tìm thấy trong toàn bộ mã. Đăng ký và
việc hủy đăng ký thăm dò với các trang web gọi lại này được đề cập trong
Thư mục ZZ0001ZZ.

IRQ
===

.. kernel-doc:: include/trace/events/irq.h
   :internal:

SIGNAL
======

.. kernel-doc:: include/trace/events/signal.h
   :internal:

Chặn IO
========

.. kernel-doc:: include/trace/events/block.h
   :internal:

Hàng làm việc
=========

.. kernel-doc:: include/trace/events/workqueue.h
   :internal:
