.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/fsp-3y.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân fsp3y
===============================
Các thiết bị được hỗ trợ:
  * 3Y POWER YH-5151E
  * 3Y POWER YM-2151E

Tác giả: Václav Kubernát <kubernat@cesnet.cz>

Sự miêu tả
-----------
Trình điều khiển này triển khai hỗ trợ hạn chế cho hai thiết bị 3Y POWER.

Mục nhập hệ thống
-----------------
* điện áp đầu vào in1_input
  * in2_input điện áp đầu ra 12V
  * in3_input điện áp đầu ra 5V
  * dòng điện đầu vào curr1_input
  *curr2_input dòng điện đầu ra 12V
  * Dòng điện đầu ra curr3_input 5V
  * fan1_vòng quay quạt đầu vào
  * temp1_nhiệt độ đầu vào 1
  * temp2_nhiệt độ đầu vào 2
  * temp3_nhiệt độ đầu vào 3
  * power1_nguồn đầu vào
  * power2_input công suất đầu ra