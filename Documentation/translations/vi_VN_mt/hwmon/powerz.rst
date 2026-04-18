.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/powerz.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân POWERZ
================================

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