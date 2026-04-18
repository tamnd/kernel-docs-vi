.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/rc/rc-table-change.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

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