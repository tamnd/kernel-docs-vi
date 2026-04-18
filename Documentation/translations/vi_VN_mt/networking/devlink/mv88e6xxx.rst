.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/mv88e6xxx.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
hỗ trợ liên kết phát triển mv88e6xxx
=========================

Tài liệu này mô tả các tính năng của devlink được ZZ0000ZZ triển khai
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
   * - ``ATU_hash``
     - u8
     - runtime
     - Select one of four possible hashing algorithms for MAC addresses in
       the Address Translation Unit. A value of 3 may work better than the
       default of 1 when many MAC addresses have the same OUI. Only the
       values 0 to 3 are valid for this parameter.