.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/sparx5-temp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Vi mạch SparX-5 SoC
=====================

Chip được hỗ trợ:

* VSC7546, VSC7549, VSC755, VSC7556 và VSC7558 (dòng Sparx5)

Tiền tố: 'sparx5-temp'

Địa chỉ được quét: -

Bảng dữ liệu: Microchip cung cấp theo yêu cầu và theo NDA

Tác giả: Lars Povlsen <lars.povlsen@microchip.com>

Sự miêu tả
-----------

Sparx5 SoC chứa cảm biến nhiệt độ dựa trên MR74060
IP Moortec.

Cảm biến có phạm vi từ -40°C đến +125°C và độ chính xác +/- 5°C.

Mục nhập hệ thống
-------------

Các thuộc tính sau được hỗ trợ.

=====================================================================================
temp1_input Nhiệt độ khuôn (tính bằng mili độ C.)
=====================================================================================