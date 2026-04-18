.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/allocation/hugepages.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========
Trang lớn
==========

Bộ cấp phát bộ nhớ liền kề
===========================
CXL Bộ nhớ trực tuyến dưới dạng SystemRAM trong quá trình khởi động sớm có đủ điều kiện để CMA sử dụng,
vì nút NUMA lưu trữ dung lượng đó sẽ là ZZ0000ZZ tại thời điểm CMA
khắc ra năng lực liền kề.

Bộ nhớ CXL được chuyển sang Trình điều khiển CXL để cấu hình không thể có
dung lượng được phân bổ bởi CMA - vì nút NUMA lưu trữ dung lượng là ZZ0001ZZ
tại thời điểm ZZ0000ZZ - khi CMA khai thác hết công suất liền kề.

TLB lớn
=======
Kích thước trang lớn khác nhau cho phép cấu hình bộ nhớ khác nhau.

Trang lớn 2MB
--------------
Tất cả dung lượng CXL bất kể thời gian cấu hình hoặc vùng bộ nhớ đều đủ điều kiện
để sử dụng như các trang lớn 2 MB.

Trang lớn 1GB
--------------
Dung lượng CXL trực tuyến trong ZZ0000ZZ đủ điều kiện nhận Trang khổng lồ 1GB
phân bổ.

Dung lượng CXL trực tuyến trong ZZ0000ZZ không đủ điều kiện nhận 1GB Gigantic
Phân bổ trang.