.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/riscv/boot-image-header.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================
Tiêu đề hình ảnh khởi động trong RISC-V Linux
=================================

:Tác giả: Atish Patra <atish.patra@wdc.com>
:Ngày: 20 tháng 5 năm 2019

Tài liệu này chỉ mô tả chi tiết tiêu đề ảnh khởi động cho RISC-V Linux.

Tiêu đề 64 byte sau đây có trong ảnh nhân Linux đã giải nén::

mã u320;		  /*Mã thực thi được*/
	mã u321;		  /*Mã thực thi được*/
	văn bản u64_offset;	  /* Độ lệch tải ảnh, endian nhỏ */
	u64 image_size;		  /* Kích thước ảnh hiệu quả, little endian */
	cờ u64;		  /* cờ kernel, endian nhỏ */
	phiên bản u32;		  /* Phiên bản của tiêu đề này */
	u32 res1 = 0;		  /* Đã đặt trước */
	u64 res2 = 0;		  /* Đã đặt trước */
	u64 ma thuật = 0x5643534952; /* Con số kỳ diệu, endian nhỏ, "RISCV" */
	u32 magic2 = 0x05435352;  /* Số ma thuật 2, endian nhỏ, "RSC\x05" */
	u32 res3;		  /* Dành riêng cho offset PE COFF */

Định dạng tiêu đề này tương thích với tiêu đề PE/COFF và phần lớn được lấy cảm hứng từ
Tiêu đề ARM64. Do đó, cả tiêu đề ARM64 & RISC-V đều có thể được kết hợp thành một tiêu đề chung
tiêu đề trong tương lai.

Ghi chú
=====

- Tiêu đề này cũng được sử dụng lại để hỗ trợ sơ khai EFI cho RISC-V. Đặc điểm kỹ thuật EFI
  cần tiêu đề hình ảnh PE/COFF ở phần đầu của hình ảnh hạt nhân để
  tải nó dưới dạng ứng dụng EFI. Để hỗ trợ sơ khai EFI, code0 được thay thế
  với chuỗi ma thuật "MZ" và res3 (ở offset 0x3c) trỏ đến phần còn lại của
  Tiêu đề PE/COFF.

- trường phiên bản cho biết số phiên bản tiêu đề

========================
	Bit 0:15 Phiên bản nhỏ
	Bit 16:31 Phiên bản chính
	========================

Điều này duy trì khả năng tương thích giữa phiên bản mới hơn và cũ hơn của tiêu đề.
  Phiên bản hiện tại được xác định là 0,2.

- Trường "ma thuật" không được dùng nữa kể từ phiên bản 0.2.  Trong một tương lai
  phát hành, nó có thể được gỡ bỏ.  Điều này ban đầu lẽ ra phải khớp với nhau
  với trường "ma thuật" tiêu đề ARM64, nhưng tiếc là không có.
  Trường "magic2" thay thế nó, khớp với tiêu đề ARM64.

- Trong tiêu đề hiện tại, trường cờ chỉ có một trường.

===== =======================================
	Độ bền của hạt nhân bit 0. 1 nếu BE, 0 nếu LE.
	===== =======================================

- Kích thước hình ảnh là bắt buộc đối với bộ tải khởi động để tải hình ảnh hạt nhân. Khởi động sẽ
  thất bại khác.
