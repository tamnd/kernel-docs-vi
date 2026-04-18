.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/mei/nfc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

MEI NFC
-------

Một số chipset Intel 8 và 9 Series hỗ trợ các thiết bị NFC được kết nối phía sau
bộ điều khiển Công cụ quản lý Intel.
Bus khách MEI hiển thị các chip NFC dưới dạng thiết bị phy NFC và cho phép
liên kết với trình điều khiển thiết bị Microread và NXP PN544 NFC từ Linux NFC
hệ thống con.

.. kernel-render:: DOT
   :alt: MEI NFC digraph
   :caption: **MEI NFC** Stack

   digraph NFC {
    cl_nfc -> me_cl_nfc;
    "drivers/nfc/mei_phy" -> cl_nfc [lhead=bus];
    "drivers/nfc/microread/mei" -> cl_nfc;
    "drivers/nfc/microread/mei" -> "drivers/nfc/mei_phy";
    "drivers/nfc/pn544/mei" -> cl_nfc;
    "drivers/nfc/pn544/mei" -> "drivers/nfc/mei_phy";
    "net/nfc" -> "drivers/nfc/microread/mei";
    "net/nfc" -> "drivers/nfc/pn544/mei";
    "neard" -> "net/nfc";
    cl_nfc [label="mei/bus(nfc)"];
    me_cl_nfc [label="me fw (nfc)"];
   }