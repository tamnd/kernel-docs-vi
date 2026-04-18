.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/powerz.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân POWERZ
====================

Chip được hỗ trợ:

* Bộ sạcLAB POWER-Z KM003C

Tiền tố: 'powerz'

Địa chỉ được quét: -

Tác giả:

- Thomas Weißschuh <linux@weissschuh.net>

Sự miêu tả
-----------

Trình điều khiển này triển khai hỗ trợ cho thử nghiệm nguồn ChargerLAB POWER-Z USB-C
gia đình.

Thiết bị giao tiếp với giao thức tùy chỉnh qua USB.

Các nhãn kênh được hiển thị qua hwmon khớp với các nhãn được sử dụng trên thiết bị
hiển thị và phần mềm PC POWER-Z chính thức.

Vì dòng điện có thể chạy theo cả hai hướng qua máy thử nên dấu của
kênh "curr1_input" (nhãn "IBUS") cho biết hướng.