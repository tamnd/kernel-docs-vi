.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/loongarch/booting.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========================
Khởi động Linux/LoongArch
=======================

:Tác giả: Yanteng Si <siyanteng@loongson.cn>
:Ngày: 18 tháng 11 năm 2022

Thông tin được truyền từ BootLoader tới kernel
============================================

LoongArch hỗ trợ ACPI và FDT. Thông tin cần được thông qua
vào kernel bao gồm memmap, initrd, dòng lệnh, tùy chọn
các bảng ACPI/FDT, v.v.

Hạt nhân được truyền các đối số sau trên ZZ0000ZZ :

- a0 = efi_boot: ZZ0000ZZ là cờ cho biết có
        môi trường khởi động này hoàn toàn tuân thủ UEFI.

- a1=cmdline: ZZ0000ZZ là con trỏ tới dòng lệnh kernel.

- a2 = systemtable: ZZ0000ZZ trỏ tới bảng hệ thống EFI.
        Tất cả các con trỏ liên quan ở giai đoạn này đều ở địa chỉ vật lý.

Tiêu đề của hình ảnh hạt nhân Linux/LoongArch
=======================================

Hình ảnh hạt nhân Linux/LoongArch là hình ảnh EFI. Là tập tin PE, họ có
tiêu đề 64 byte có cấu trúc như::

u32 MZ_MAGIC /* "MZ", tiêu đề MS-DOS */
	u32 res0 = 0 /* Dành riêng */
	u64 kernel_entry /* Điểm vào kernel */
	u64 _end - _text /* Kích thước hiệu dụng của hình ảnh hạt nhân */
	u64 Load_offset /* Độ lệch tải hình ảnh hạt nhân từ đầu RAM */
	u64 res1 = 0 /* Dành riêng */
	u64 res2 = 0 /* Dành riêng */
	u64 res3 = 0 /* Dành riêng */
	u32 LINUX_PE_MAGIC /* Số ma thuật */
	u32 pe_header - _head /* Offset cho tiêu đề PE */