.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/livepatch/api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===================
API bản vá trực tiếp
=================

Hỗ trợ Livepatch
====================

.. kernel-doc:: kernel/livepatch/core.c
   :export:


Biến bóng
================

.. kernel-doc:: kernel/livepatch/shadow.c
   :export:

Thay đổi trạng thái hệ thống
====================

.. kernel-doc:: kernel/livepatch/state.c
   :export:

Các loại đối tượng
============

.. kernel-doc:: include/linux/livepatch.h
   :identifiers: klp_patch klp_object klp_func klp_callbacks klp_state