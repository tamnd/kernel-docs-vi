.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/PCI/endpoint/function/binding/pci-ntb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================
Chức năng điểm cuối PCI NTB
==========================

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