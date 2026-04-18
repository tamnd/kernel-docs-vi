.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/livepatch/api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

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