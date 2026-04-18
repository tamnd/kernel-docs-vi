.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/qed.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================
hỗ trợ liên kết nhà phát triển qed
===================

Tài liệu này mô tả các tính năng liên kết nhà phát triển được triển khai bởi lõi ZZ0000ZZ
trình điều khiển thiết bị.

Thông số
==========

Trình điều khiển ZZ0000ZZ triển khai các tham số dành riêng cho trình điều khiển sau.

.. list-table:: Driver-specific parameters implemented
   :widths: 5 5 5 85

   * - Name
     - Type
     - Mode
     - Description
   * - ``iwarp_cmt``
     - Boolean
     - runtime
     - Enable iWARP functionality for 100g devices. Note that this impacts
       L2 performance, and is therefore not enabled by default.