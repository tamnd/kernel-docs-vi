.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/PCI/endpoint/function/binding/pci-test.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
Chức năng điểm cuối kiểm tra PCI
==========================

Tên: Phải là "pci_epf_test" để liên kết với trình điều khiển pci_epf_test.

Các trường có thể định cấu hình:

==================================================================================
nhà cung cấp phải là 0x104c
deviceid phải là 0xb500 cho DRA74x và 0xb501 cho DRA72x
revid không quan tâm
progif_code không quan tâm
subclass_code không quan tâm
baseclass_code phải là 0xff
cache_line_size không quan tâm
subsys_vendor_id không quan tâm
subsys_id không quan tâm
ngắt_pin Nên là 1 - INTA, 2 - INTB, 3 - INTC, 4 -INTD
msi_interrupts Nên từ 1 đến 32 tùy thuộc vào số lượng ngắt MSI
		   để kiểm tra
msix_interrupts Nên từ 1 đến 2048 tùy thuộc vào số lượng MSI-X
		   ngắt để kiểm tra
==================================================================================