.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/opera-firmware.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Phần mềm Opera
==============

Tác giả: Marco Gittler <g.marco@freenet.de>

Để giải nén firmware cho Opera DVB-S1 USB-Box
bạn cần sao chép các tập tin:

2830SCap2.sys
2830SLoad2.sys

từ đĩa windriver vào thư mục này.

Sau đó chạy:

.. code-block:: none

	scripts/get_dvb_firmware opera1

và sau đó bạn có 2 file:

dvb-usb-opera-01.fw
dvb-usb-opera1-fpga-01.fw

ở đây.

Sao chép chúng vào /lib/firmware/ .

Sau đó trình điều khiển có thể tải firmware
(nếu bạn đã bật tính năng tải chương trình cơ sở
trong cấu hình kernel và chạy hotplug).