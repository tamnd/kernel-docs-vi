.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/parser.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================
Trình phân tích cú pháp chung
==============

Tổng quan
========

Trình phân tích cú pháp chung là một trình phân tích cú pháp đơn giản để phân tích các tùy chọn gắn kết,
tùy chọn hệ thống tập tin, tùy chọn trình điều khiển, tùy chọn hệ thống con, v.v.

Trình phân tích cú pháp API
==========

.. kernel-doc:: lib/parser.c
   :export: