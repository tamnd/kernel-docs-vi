.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/rc/rc-table-change.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _Remote_controllers_table_change:

*******************************************
Thay đổi ánh xạ Bộ điều khiển từ xa mặc định
*******************************************

Giao diện sự kiện cung cấp hai ioctls được sử dụng để chống lại
/dev/input/event device, để cho phép thay đổi sơ đồ bàn phím mặc định.

Chương trình này trình bày cách thay thế các bảng sơ đồ bàn phím.


.. toctree::
    :maxdepth: 1

    keytable.c