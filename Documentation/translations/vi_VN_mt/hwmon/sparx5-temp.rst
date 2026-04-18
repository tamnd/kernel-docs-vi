.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/sparx5-temp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

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