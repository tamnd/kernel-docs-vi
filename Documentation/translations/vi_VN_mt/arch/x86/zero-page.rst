.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/zero-page.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========
Trang không
===========
Các trường bổ sung trong struct boot_params như một phần của boot 32-bit
giao thức của kernel. Những thứ này phải được lấp đầy bởi bootloader hoặc 16-bit
mã thiết lập chế độ thực của kernel. Tài liệu tham khảo/cài đặt cho nó chủ yếu
đang ở::

Arch/x86/include/uapi/asm/bootparam.h

============ ===== ==============================================================================
Bù đắp/Kích thước Ý nghĩa tên nguyên mẫu

000/040 ALL screen_info Thông tin về chế độ văn bản hoặc bộ đệm khung
						(cấu trúc screen_info)
040/014 ALL apm_bios_info Thông tin APM BIOS (struct apm_bios_info)
058/008 ALL tboot_addr Địa chỉ vật lý của trang chia sẻ tboot
060/010 ALL ist_info Thông tin hỗ trợ Intel SpeedStep (IST) BIOS
						(cấu trúc ist_info)
070/008 ALL acpi_rsdp_addr Địa chỉ vật lý của bảng ACPI RSDP
080/010 ALL hd0_info thông số đĩa hd0, OBSOLETE!!
090/010 ALL hd1_info thông số đĩa hd1, OBSOLETE!!
0A0/010 ALL sys_desc_table Bảng mô tả hệ thống (struct sys_desc_table),
						OBSOLETE!!
0B0/010 ALL olpc_ofw_header OLPC's OpenFirmware CIF và những người bạn
0C0/004 ALL ext_ramdisk_image ramdisk_image cao 32bit
0C4/004 ALL ext_ramdisk_size ramdisk_size cao 32bit
0C8/004 ALL ext_cmd_line_ptr cmd_line_ptr cao 32bit
13C/004 ALL cc_blob_address Địa chỉ vật lý của blob Máy tính bí mật
140/080 ALL edid_info Thiết lập chế độ video (struct edid_info)
Thông tin 1C0/020 ALL efi_info EFI 32 (struct efi_info)
1E0/004 ALL alt_mem_k Kiểm tra mem thay thế, tính bằng KB
1E4/004 ALL Scratch Trường cào cho mã thiết lập kernel
1E8/001 ALL e820_entries Số mục trong bảng e820_(bên dưới)
1E9/001 ALL eddbuf_entries Số mục trong eddbuf (bên dưới)
1EA/001 ALL edd_mbr_sig_buf_entries Số mục trong edd_mbr_sig_buffer
						(bên dưới)
1EB/001 ALL kbd_status Numlock được bật
1EC/001 ALL safe_boot Khởi động an toàn được bật trong chương trình cơ sở
1EF/001 ALL trọng điểm Được sử dụng để phát hiện bộ nạp khởi động bị hỏng
290/040 ALL edd_mbr_sig_buffer EDD MBR chữ ký
Bảng sơ đồ bộ nhớ 2D0/A00 ALL e820_table E820
						(mảng cấu trúc e820_entry)
Dữ liệu D00/1EC ALL eddbuf EDD (mảng cấu trúc edd_info)
============ ===== ==============================================================================