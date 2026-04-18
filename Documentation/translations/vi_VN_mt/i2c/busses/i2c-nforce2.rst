.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/i2c/busses/i2c-nforce2.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Trình điều khiển hạt nhân i2c-nforce2
=========================

Bộ điều hợp được hỗ trợ:
  * nForce2 MCP 10de:0064
  * nForce2 Ultra 400 MCP 10de:0084
  * nForce3 Pro150 MCP 10de:00D4
  * nForce3 250Gb MCP 10de:00E4
  * nForce4 MCP 10de:0052
  * nForce4 MCP-04 10de:0034
  * nForce MCP51 10de:0264
  * nForce MCP55 10de:0368
  * nForce MCP61 10de:03EB
  * nForce MCP65 10de:0446
  * nForce MCP67 10de:0542
  * nForce MCP73 10de:07D8
  * nForce MCP78S 10de:0752
  * nForce MCP79 10de:0AA2

Bảng dữ liệu:
           không có sẵn công khai, nhưng có vẻ tương tự như
           Bộ chuyển đổi AMD-8111 SMBus 2.0.

tác giả:
	- Hans-Frieder Vogt <hfvogt@gmx.net>,
	- Thomas Leibold <thomas@plx.com>,
        - Patrick Dreker <patrick@dreker.de>

Sự miêu tả
-----------

i2c-nforce2 là trình điều khiển dành cho SMBuses có trong nVidia nForce2 MCP.

Nếu danh sách ZZ0000ZZ của bạn hiển thị nội dung như sau::

00:01.1 SMBus: nVidia Corporation: Thiết bị không xác định 0064 (rev a2)
          Hệ thống con: Asustek Computer, Inc.: Thiết bị không xác định 0c11
          Cờ: 66Mhz, phát triển nhanh, IRQ 5
          Cổng I/O tại c000 [size=32]
          Khả năng: <chỉ có sẵn cho root>

thì trình điều khiển này sẽ hỗ trợ SMBuses trên bo mạch chủ của bạn.


Ghi chú
-----

Bộ điều hợp SMBus trong chipset nForce2 có vẻ rất giống với
Bộ chuyển đổi SMBus 2.0 trong cầu nam AMD-8111. Tuy nhiên, tôi chỉ có thể nhận được
trình điều khiển hoạt động với quyền truy cập I/O trực tiếp, khác với EC
giao diện của AMD-8111. Đã thử nghiệm trên Asus A7N8X. Bảng ACPI DSDT của
Asus A7N8X liệt kê hai SMBuses, cả hai đều được trình điều khiển này hỗ trợ.
