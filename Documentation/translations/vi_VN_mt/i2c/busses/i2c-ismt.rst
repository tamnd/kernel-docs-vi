.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/i2c/busses/i2c-ismt.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================
Trình điều khiển hạt nhân i2c-ismt
==================================


Bộ điều hợp được hỗ trợ:
  * SOC dòng Intel S12xx

tác giả:
	Bill Brown <bill.e. brown@intel.com>


Thông số mô-đun
-----------------

* bus_speed (unsign int)

Cho phép thay đổi tốc độ xe buýt.  Thông thường, tốc độ bus được đặt bởi BIOS
và không bao giờ cần phải thay đổi.  Tuy nhiên, một số máy phân tích SMBus quá chậm để
giám sát bus trong quá trình gỡ lỗi, do đó cần có tham số mô-đun này.
Chỉ định tốc độ bus tính bằng kHz.

Cài đặt tần số bus có sẵn:

==== ==========
  0 không thay đổi
  80 kHz
  100 kHz
  400 kHz
  1000 kHz
  ==== ==========


Sự miêu tả
-----------

Dòng SOC S12xx có một cặp bộ điều khiển SMBus 2.0 tích hợp
nhắm mục tiêu chủ yếu vào thị trường máy chủ vi mô và lưu trữ.

Dòng S12xx chứa một cặp chức năng PCI.  Một đầu ra của lspci sẽ hiển thị
một cái gì đó tương tự như sau ::

00:13.0 Hệ thống ngoại vi: Intel Corporation Centerton SMBus 2.0 Bộ điều khiển 0
  00:13.1 Hệ thống ngoại vi: Intel Corporation Centerton SMBus 2.0 Bộ điều khiển 1
