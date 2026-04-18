.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/xdpe152c4.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân xdpe152
=====================

Chip được hỗ trợ:

* Infineon XDPE152C4

Tiền tố: 'xdpe152c4'

* Infineon XDPE15284

Tiền tố: 'xdpe15284'

tác giả:

Greg Schwendimann <greg.schwendimann@infineon.com>

Sự miêu tả
-----------

Trình điều khiển này triển khai hỗ trợ cho Bộ điều khiển nhiều pha kỹ thuật số Infineon
Bộ điều chỉnh điện áp vòng kép XDPE152C4 và XDPE15284.
Các thiết bị tuân thủ:

- Intel VR13, VR13HC và VR14 phiên bản 1.86
  đặc điểm kỹ thuật của bộ chuyển đổi.
- Intel SVID phiên bản 1.93. giao thức.
- Giao diện PMBus rev 1.3.1.

Thiết bị hỗ trợ định dạng tuyến tính để đọc điện áp đầu vào và đầu ra, đầu vào
và dòng điện đầu ra, công suất đầu vào và đầu ra và nhiệt độ.

Thiết bị hỗ trợ hai trang để đo từ xa.

Trình điều khiển cung cấp các ngưỡng hiện tại: đầu vào, tối đa và tới hạn
và các cảnh báo tối đa và quan trọng. Ngưỡng tới hạn thấp và báo động tới hạn thấp là
chỉ được hỗ trợ cho đầu ra hiện tại.
Trình điều khiển xuất các thuộc tính sau qua tệp sysfs, trong đó
chỉ số 1, 2 dành cho "iin" và 3, 4 dành cho "iout":

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

Trình điều khiển cung cấp điện áp: ngưỡng đầu vào, ngưỡng tới hạn và ngưỡng tới hạn thấp
và các báo động tới hạn và thấp tới hạn.
Trình điều khiển xuất các thuộc tính sau qua tệp sysfs, trong đó
chỉ số 1, 2 dành cho "vin" và 3, 4 dành cho "vout":

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

Trình điều khiển cung cấp năng lượng: đầu vào và cảnh báo.
Trình điều khiển xuất các thuộc tính sau qua tệp sysfs, trong đó
chỉ số 1, 2 dành cho "pin" và 3, 4 dành cho "bĩu môi":

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

Trình điều khiển cung cấp nhiệt độ: ngưỡng đầu vào, ngưỡng tối đa và tới hạn
và các cảnh báo tối đa và quan trọng.
Trình điều khiển xuất các thuộc tính sau qua tệp sysfs:

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ