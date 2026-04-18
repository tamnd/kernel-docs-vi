.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/fsp-3y.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân fsp3y
======================
Các thiết bị được hỗ trợ:
  * 3Y POWER YH-5151E
  * 3Y POWER YM-2151E

Tác giả: Václav Kubernát <kubernat@cesnet.cz>

Sự miêu tả
-----------
Trình điều khiển này triển khai hỗ trợ hạn chế cho hai thiết bị 3Y POWER.

Mục nhập hệ thống
-------------
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