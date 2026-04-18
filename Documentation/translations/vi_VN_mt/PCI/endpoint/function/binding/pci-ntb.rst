.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/PCI/endpoint/function/binding/pci-ntb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
Chức năng điểm cuối PCI NTB
=============================

1) Tạo thư mục con cho thư mục pci_epf_ntb trong configfs.

Các trường có thể định cấu hình EPF tiêu chuẩn:

==================================================================================
nhà cung cấp phải là 0x104c
deviceid phải là 0xb00d cho SoC J721E của TI
revid không quan tâm
progif_code không quan tâm
subclass_code phải là 0x00
baseclass_code phải là 0x5
cache_line_size không quan tâm
subsys_vendor_id không quan tâm
subsys_id không quan tâm
ngắt_pin không quan tâm
msi_interrupt không quan tâm
msix_interrupts không quan tâm
==================================================================================

2) Tạo thư mục con vào thư mục đã tạo ở 1

Các trường có thể cấu hình cụ thể của NTB EPF:

==================================================================================
db_count Số lượng chuông cửa; mặc định = 4
mw1 kích thước của cửa sổ bộ nhớ1
kích thước mw2 của cửa sổ bộ nhớ2
mw3 kích thước của cửa sổ bộ nhớ3
mw4 kích thước của bộ nhớ window4
num_mws Số lượng cửa sổ bộ nhớ; tối đa = 4
spad_count Số lượng thanh ghi Scratchpad; mặc định = 64
==================================================================================