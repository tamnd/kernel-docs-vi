.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/bfa.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================================
Trình điều khiển Linux cho bộ điều hợp Brocade FC/FCOE
======================================================

Phần cứng được hỗ trợ
------------------

Trình điều khiển bfa 3.0.2.2 hỗ trợ tất cả các bộ điều hợp Brocade FC/FCOE. Dưới đây là danh sách
các mẫu bộ điều hợp có PCIID tương ứng.

====================================================================
	Mẫu PCIID
	====================================================================
	1657:0013:1657:0014 Cổng kép 425 4Gbps FC HBA
	1657:0013:1657:0014 825 Cổng kép PCIe 8Gbps FC HBA
	1657:0013:103c:1742 Cổng PCIedual HP 82B 8Gbps FC HBA
	1657:0013:103c:1744 Cổng kép HP 42B 4Gbps FC HBA
	1657:0017:1657:0014 415 Cổng đơn 4Gbps FC HBA
	1657:0017:1657:0014 815 Cổng đơn 8Gbps FC HBA
	1657:0017:103c:1741 Cổng đơn HP 41B 4Gbps FC HBA
	1657:0017:103c 1743 Cổng đơn HP 81B 8Gbps FC HBA
	1657:0021:103c:1779 804 8Gbps FC HBA dành cho HP Bladesystem c-class

1657:0014:1657:0014 1010 Cổng đơn 10Gbps CNA - FCOE
	1657:0014:1657:0014 Cổng kép 1020 10Gbps CNA - FCOE
	1657:0014:1657:0014 1007 Cổng kép 10Gbps CNA - FCOE
	1657:0014:1657:0014 1741 Cổng kép 10Gbps CNA - FCOE

1657:0022:1657:0024 1860 16Gbps FC HBA
	1657:0022:1657:0022 1860 10Gbps CNA - FCOE
	====================================================================


Tải xuống chương trình cơ sở
-----------------

Bạn có thể tìm thấy gói Firmware mới nhất cho trình điều khiển bfa 3.0.2.2 tại:

ZZ0000ZZ

và sau đó nhấp vào liên kết gói sử dụng tương ứng sau:

======================================================================
	Liên kết phiên bản
	======================================================================
	v3.0.0.0 Gói chương trình cơ sở bộ điều hợp Linux dành cho RHEL 6.2, SLES 11SP2
	======================================================================


Tải xuống tiện ích Cấu hình & Quản lý
-------------------------------------------

Tiện ích quản lý và cấu hình trình điều khiển mới nhất dành cho trình điều khiển bfa 3.0.2.2 có thể
được tìm thấy tại:

ZZ0000ZZ

và sau đó nhấp vào liên kết gói sử dụng tương ứng

======================================================================
	Liên kết phiên bản
	======================================================================
	v3.0.2.0 Gói chương trình cơ sở bộ điều hợp Linux dành cho RHEL 6.2, SLES 11SP2
	======================================================================


Tài liệu
-------------

Hướng dẫn quản trị, Hướng dẫn cài đặt và tham khảo mới nhất,
Hướng dẫn khắc phục sự cố và Ghi chú phát hành cho hộp đựng tương ứng
trình điều khiển có thể được tìm thấy tại:

ZZ0000ZZ

và sử dụng ánh xạ phiên bản trình điều khiển sẵn có và hộp thư đến sau đây để tìm
tài liệu tương ứng:

==================================
	Phiên bản trong hộp thư đến Phiên bản ngoài hộp
	==================================
	v3.0.2.2 v3.0.0.0
	==================================

Ủng hộ
-------

Để biết thông tin chung về sản phẩm và hỗ trợ, hãy truy cập trang web Brocade tại:

ZZ0000ZZ