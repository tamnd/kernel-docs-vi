.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/boot.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Giao thức khởi động Linux/x86
===========================

Trên nền x86, nhân Linux sử dụng cách khởi động khá phức tạp
quy ước.  Điều này đã phát triển một phần do các khía cạnh lịch sử, như
cũng như mong muốn trong những ngày đầu có được hạt nhân
hình ảnh có thể khởi động, mô hình bộ nhớ PC phức tạp và do thay đổi
những kỳ vọng trong ngành công nghiệp PC gây ra bởi sự sụp đổ của
DOS ở chế độ thực như một hệ điều hành chính thống.

Hiện tại, các phiên bản sau của giao thức khởi động Linux/x86 đã tồn tại.

============== =================================================================
Hạt nhân cũ zChỉ hỗ trợ hình ảnh/hình ảnh.  Một số hạt nhân rất sớm
		thậm chí có thể không hỗ trợ một dòng lệnh.

Giao thức 2.00 (Kernel 1.3.73) Đã thêm hỗ trợ bzImage và initrd, như
		cũng như một cách chính thức để giao tiếp giữa
		bộ tải khởi động và kernel.  setup.S được thực hiện có thể di dời,
		mặc dù khu vực thiết lập truyền thống vẫn được đảm nhận
		có thể ghi được.

Giao thức 2.01 (Kernel 1.3.76) Đã thêm cảnh báo tràn bộ nhớ đệm.

Giao thức 2.02 (Kernel 2.4.0-test3-pre3) Giao thức dòng lệnh mới.
		Hạ trần bộ nhớ thông thường.	Không ghi đè
		của khu vực thiết lập truyền thống, do đó làm cho việc khởi động
		an toàn cho các hệ thống sử dụng EBDA từ SMM hoặc 32-bit
		Điểm vào BIOS.  zImage không được dùng nữa nhưng vẫn
		được hỗ trợ.

Giao thức 2.03 (Kernel 2.4.18-pre1) Rõ ràng đạt mức cao nhất có thể
		địa chỉ initrd có sẵn cho bộ nạp khởi động.

Giao thức 2.04 (Kernel 2.6.14) Mở rộng trường syssize thành bốn byte.

Giao thức 2.05 (Kernel 2.6.20) Làm cho hạt nhân chế độ được bảo vệ có thể định vị lại được.
		Giới thiệu các trường relocatable_kernel và kernel_alignment.

Giao thức 2.06 (Kernel 2.6.22) Đã thêm trường chứa kích thước của
		dòng lệnh khởi động.

Giao thức 2.07 (Kernel 2.6.24) Đã thêm giao thức khởi động ảo hóa song song.
		Giới thiệu phần cứng_subarch và phần cứng_subarch_data
		và cờ KEEP_SEGMENTS trong Load_flags.

Giao thức 2.08 (Kernel 2.6.26) Đã thêm tổng kiểm tra crc32 và định dạng ELF
		tải trọng. Giới thiệu payload_offset và payload_length
		các trường để hỗ trợ việc định vị tải trọng.

Giao thức 2.09 (Kernel 2.6.26) Đã thêm trường vật lý 64 bit
		con trỏ tới danh sách liên kết đơn của struct setup_data.

Giao thức 2.10 (Kernel 2.6.31) Đã thêm giao thức để căn chỉnh thoải mái
		ngoài kernel_alignment được thêm vào, init_size mới và
		trường pref_address.  Đã thêm ID bộ tải khởi động mở rộng.

Giao thức 2.11 (Kernel 3.6) Đã thêm trường để bù chuyển giao EFI
		điểm vào giao thức.

Giao thức 2.12 (Kernel 3.8) Đã thêm trường xloadflags và trường mở rộng
		để cấu trúc boot_params để tải bzImage và ramdisk
		trên 4G ở 64bit.

Giao thức 2.13 (Kernel 3.14) Hỗ trợ cài đặt cờ 32 và 64 bit
		xloadflags để hỗ trợ khởi động kernel 64 bit từ 32 bit
		EFI

Giao thức 2.14 BURNT BỞI INCORRECT COMMIT
                ae7e1238e68f2a472a125673ab506d49158c1889
		("x86/boot: Thêm địa chỉ ACPI RSDP vào setup_header")
		LÀM NOT USE!!! ASSUME SAME NHƯ 2.13.

Giao thức 2.15 (Kernel 5.5) Đã thêm kernel_info và kernel_info.setup_type_max.
============== =================================================================

.. note::
     The protocol version number should be changed only if the setup header
     is changed. There is no need to update the version number if boot_params
     or kernel_info are changed. Additionally, it is recommended to use
     xloadflags (in this case the protocol version number should not be
     updated either) or kernel_info to communicate supported Linux kernel
     features to the boot loader. Due to very limited space available in
     the original setup header every update to it should be considered
     with great care. Starting from the protocol 2.15 the primary way to
     communicate things to the boot loader is the kernel_info.


Bố cục bộ nhớ
=============

Bản đồ bộ nhớ truyền thống cho trình tải hạt nhân, được sử dụng cho Hình ảnh hoặc
Hạt nhân zImage, thường trông giống như::

ZZ0000ZZ
  0A0000 +------------------------+
		ZZ0001ZZ Không sử dụng.  Dành riêng cho BIOS EBDA.
  09A000 +------------------------+
		ZZ0002ZZ
		ZZ0003ZZ Để sử dụng bởi mã chế độ thực hạt nhân.
  098000 +---------------------------------------
		ZZ0004ZZ Mã chế độ thực của hạt nhân.
  090200 +---------------------------------------
		ZZ0005ZZ Khu vực khởi động kế thừa kernel.
  090000 +---------------------------------------
		ZZ0006ZZ Phần lớn hình ảnh hạt nhân.
  010000 +------------------------------ +
		ZZ0007ZZ <- Điểm vào khu vực khởi động 0000:7C00
  001000 +------------------------------ +
		ZZ0008ZZ
  000800 +---------------+
		ZZ0009ZZ
  000600 +------------------------+
		ZZ0010ZZ
  000000 +------------------------+

Khi sử dụng bzImage, kernel ở chế độ được bảo vệ đã được chuyển sang
0x100000 ("bộ nhớ cao") và khối chế độ thực kernel (khu vực khởi động,
thiết lập và ngăn xếp/đống) đã được thực hiện có thể định vị lại tới bất kỳ địa chỉ nào giữa
0x10000 và hết bộ nhớ thấp. Unfortunately, in protocols 2.00 and
2.01, phạm vi bộ nhớ 0x90000+ vẫn được kernel sử dụng nội bộ;
giao thức 2.02 giải quyết vấn đề đó.

Nên giữ nguyên “mức trần ký ức” - điểm cao nhất trong
bộ tải khởi động chạm vào bộ nhớ thấp -- càng thấp càng tốt, vì
một số BIOS mới hơn đã bắt đầu phân bổ một lượng khá lớn
bộ nhớ, được gọi là Vùng dữ liệu BIOS mở rộng, gần đỉnh thấp
trí nhớ.	 Bộ tải khởi động nên sử dụng lệnh gọi BIOS "INT 12h" để xác minh
bộ nhớ còn trống bao nhiêu.

Thật không may, nếu INT 12h báo cáo rằng dung lượng bộ nhớ quá lớn
thấp, bộ tải khởi động thường không thể làm gì khác ngoài việc báo cáo một
lỗi cho người dùng.  Do đó bộ nạp khởi động phải được thiết kế để
chiếm ít không gian trong bộ nhớ thấp nhất có thể.  cho
zImage hoặc hạt nhân bzImage cũ, cần dữ liệu được ghi vào
0x90000, bộ tải khởi động phải đảm bảo không sử dụng bộ nhớ
trên điểm 0x9A000; quá nhiều BIOS sẽ vượt quá điểm đó.

Đối với hạt nhân bzImage hiện đại có phiên bản giao thức khởi động >= 2.02,
bố trí bộ nhớ như sau được đề xuất ::

~ ~
		ZZ0000ZZ
  100000 +------------------------+
		ZZ0001ZZ
  0A0000 +------------------------+
		ZZ0002ZZ Để càng nhiều càng tốt không sử dụng
		~  			 ~
		ZZ0003ZZ (Cũng có thể dưới mốc X+10000)
  X+10000 +---------------+
		ZZ0004ZZ Để sử dụng bởi mã chế độ thực hạt nhân.
  X+08000 +---------------+
		ZZ0005ZZ Mã chế độ thực của hạt nhân.
		ZZ0006ZZ Khu vực khởi động kế thừa kernel.
  X +---------------+
		ZZ0007ZZ <- Điểm vào khu vực khởi động 0000:7C00
  001000 +------------------------------ +
		ZZ0008ZZ
  000800 +---------------+
		ZZ0009ZZ
  000600 +------------------------+
		ZZ0010ZZ
  000000 +------------------------+

  ... where the address X is as low as the design of the boot loader permits.


Tiêu đề hạt nhân chế độ thực
===========================

Trong văn bản sau đây và bất kỳ vị trí nào trong chuỗi khởi động kernel, "a
ngành" đề cập đến 512 byte.  Nó độc lập với khu vực thực tế
kích thước của phương tiện cơ bản.

Bước đầu tiên trong việc tải nhân Linux là tải
mã chế độ thực (khu vực khởi động và mã thiết lập) và sau đó kiểm tra
tiêu đề sau ở offset 0x01f1.  Mã chế độ thực có thể tổng cộng lên tới
32K, mặc dù bộ tải khởi động có thể chọn chỉ tải hai phần đầu tiên
các lĩnh vực (1K) và sau đó kiểm tra kích thước của khu vực khởi động.

Tiêu đề trông giống như:

=========== ======== =======================================================================
Bù đắp/Kích thước Ý nghĩa tên nguyên mẫu
=========== ======== =======================================================================
01F1/1 ALL(1) setup_sects Kích thước của thiết lập theo các cung
01F2/2 ALL root_flags Nếu được đặt, gốc sẽ được gắn chỉ đọc
01F4/4 2.04+(2) syssize Kích thước của mã 32 bit trong các đoạn 16 byte
01F8/2 ALL ram_size DO NOT USE - chỉ sử dụng cho bootect.S
01FA/2 ALL vid_mode Điều khiển chế độ video
01FC/2 ALL root_dev Số thiết bị gốc mặc định
01FE/2 ALL boot_flag 0xAA55 con số kỳ diệu
0200/2 2.00+ lệnh nhảy Lệnh nhảy
0202/4 2.00+ tiêu đề Chữ ký ma thuật "HdrS"
Phiên bản 0206/2 2.00+ Phiên bản giao thức khởi động được hỗ trợ
0208/4 2.00+ realmode_swtch Móc bộ tải khởi động (xem bên dưới)
020C/2 2.00+ start_sys_seg Phân đoạn tải thấp (0x1000) (lỗi thời)
020E/2 2.00+ kernel_version Con trỏ tới chuỗi phiên bản kernel
0210/1 2.00+ type_of_loader Mã định danh bộ tải khởi động
0211/1 2.00+ cờ tải Cờ tùy chọn giao thức khởi động
0212/2 2.00+ setup_move_size Di chuyển đến kích thước bộ nhớ cao (được sử dụng với hook)
0214/4 2.00+ code32_start Móc bộ tải khởi động (xem bên dưới)
0218/4 2.00+ địa chỉ tải initrd ramdisk_image (được đặt bởi bộ tải khởi động)
021C/4 2.00+ kích thước initrd ramdisk_size (được đặt bởi bộ tải khởi động)
0220/4 2.00+ bootect_kludge DO NOT USE - chỉ sử dụng cho bootect.S
0224/2 2.01+ heap_end_ptr Bộ nhớ trống sau khi kết thúc thiết lập
0226/1 2.02+(3) ext_loader_ver Phiên bản bộ tải khởi động mở rộng
0227/1 2.02+(3) ext_loader_type ID bộ tải khởi động mở rộng
0228/4 2.02+ cmd_line_ptr Con trỏ 32 bit tới dòng lệnh kernel
022C/4 2.03+ initrd_addr_max Địa chỉ initrd hợp pháp cao nhất
0230/4 2.05+ kernel_alignment Cần căn chỉnh địa chỉ vật lý cho kernel
0234/1 2.05+ relocatable_kernel Liệu kernel có thể định vị lại được hay không
0235/1 2.10+ min_alignment Căn chỉnh tối thiểu, theo lũy thừa của hai
0236/2 2.12+ xloadflags Cờ tùy chọn giao thức khởi động
0238/4 2.06+ cmdline_size Kích thước tối đa của dòng lệnh kernel
023C/4 2.07+ hardware_subarch Kiến trúc phụ phần cứng
0240/8 2.07+ hardware_subarch_data Dữ liệu dành riêng cho kiến trúc phụ
0248/4 2.08+ payload_offset Bù tải trọng hạt nhân
024C/4 2.08+ payload_length Độ dài của tải trọng kernel
0250/8 2.09+ setup_data Con trỏ vật lý 64-bit tới danh sách liên kết
							của cấu trúc setup_data
0258/8 2.10+ pref_address Địa chỉ tải ưa thích
0260/4 2.10+ init_size Cần có bộ nhớ tuyến tính trong quá trình khởi tạo
0264/4 2.11+ handover_offset Offset của điểm vào chuyển giao
0268/4 2.15+ kernel_info_offset Độ lệch của kernel_info
=========== ======== =======================================================================

.. note::
     (1) For backwards compatibility, if the setup_sects field contains 0,
         the real value is 4.

     (2) For boot protocol prior to 2.04, the upper two bytes of the syssize
         field are unusable, which means the size of a bzImage kernel
         cannot be determined.

     (3) Ignored, but safe to set, for boot protocols 2.02-2.09.

Nếu không tìm thấy số ma thuật "HdrS" (0x53726448) ở offset 0x202,
phiên bản giao thức khởi động là "cũ".  Đang tải một kernel cũ,
cần giả sử các tham số sau::

Loại hình ảnh = zImage
  initrd không được hỗ trợ
  Hạt nhân chế độ thực phải được đặt ở 0x90000.

Mặt khác, trường "phiên bản" chứa phiên bản giao thức,
ví dụ: giao thức phiên bản 2.01 sẽ chứa 0x0201 trong trường này.  Khi nào
cài đặt các trường trong tiêu đề, bạn phải đảm bảo chỉ đặt các trường
được hỗ trợ bởi phiên bản giao thức đang sử dụng.


Chi tiết về trường tiêu đề
========================

Đối với mỗi trường, một số thông tin từ kernel đến bootloader
("đọc"), một số dự kiến sẽ được bộ nạp khởi động điền vào
("viết"), và một số dự kiến sẽ được đọc và sửa đổi bởi
bộ nạp khởi động ("sửa đổi").

Tất cả các bộ tải khởi động cho mục đích chung phải ghi vào các trường được đánh dấu
(bắt buộc).  Những người tải khởi động muốn tải kernel cùng một lúc
địa chỉ không chuẩn phải điền vào các trường được đánh dấu (reloc); khác
bộ tải khởi động có thể bỏ qua các trường đó.

Thứ tự byte của tất cả các trường là little endian (x86 là x86).

========================
Tên trường: setup_sects
Loại: đọc
Độ lệch/kích thước: 0x1f1/1
Giao thức: ALL
========================

Kích thước của mã thiết lập trong các cung 512 byte.  Nếu trường này là
  0, giá trị thực là 4. Mã chế độ thực bao gồm mã khởi động
  khu vực (luôn luôn có một khu vực 512 byte) cộng với mã thiết lập.

===============================
Tên trường: root_flags
Loại: sửa đổi (tùy chọn)
Độ lệch/kích thước: 0x1f2/2
Giao thức: ALL
===============================

Nếu trường này khác 0 thì gốc mặc định là chỉ đọc.  Việc sử dụng
  trường này không được dùng nữa; sử dụng tùy chọn "ro" hoặc "rw" trên
  thay vào đó là dòng lệnh.

===============================================================
Tên trường: syssize
Loại: đọc
Độ lệch/kích thước: 0x1f4/4 (giao thức 2.04+) 0x1f4/2 (giao thức ALL)
Giao thức: 2.04+
===============================================================

Kích thước của mã chế độ được bảo vệ theo đơn vị đoạn văn 16 byte.
  Đối với các phiên bản giao thức cũ hơn 2.04, trường này chỉ có hai byte
  rộng và do đó không thể tin cậy được đối với kích thước của hạt nhân nếu
  cờ LOAD_HIGH được đặt.

============================
Tên trường: ram_size
Kiểu: hạt nhân nội bộ
Độ lệch/kích thước: 0x1f8/2
Giao thức: ALL
============================

Lĩnh vực này đã lỗi thời.

=================================
Tên trường: vid_mode
Loại: sửa đổi (bắt buộc)
Độ lệch/kích thước: 0x1fa/2
=================================

Vui lòng xem phần trên SPECIAL COMMAND LINE OPTIONS.

===============================
Tên trường: root_dev
Loại: sửa đổi (tùy chọn)
Độ lệch/kích thước: 0x1fc/2
Giao thức: ALL
===============================

Số thiết bị gốc mặc định.  Việc sử dụng trường này là
  không được dùng nữa, thay vào đó hãy sử dụng tùy chọn "root=" trên dòng lệnh.

======================
Tên trường: boot_flag
Loại: đọc
Độ lệch/kích thước: 0x1fe/2
Giao thức: ALL
======================

Chứa 0xAA55.  Đây là thứ gần gũi nhất mà nhân Linux cũ có
  đến một con số kỳ diệu.

============= =======
Tên trường: nhảy
Loại: đọc
Độ lệch/kích thước: 0x200/2
Giao thức: 2,00+
============= =======

Chứa lệnh nhảy x86, 0xEB theo sau là phần bù đã ký
  liên quan đến byte 0x202.  Điều này có thể được sử dụng để xác định kích thước của
  tiêu đề.

============= =======
Tên trường: tiêu đề
Loại: đọc
Độ lệch/kích thước: 0x202/4
Giao thức: 2,00+
============= =======

Chứa số ma thuật "HdrS" (0x53726448).

============= =======
Tên trường: phiên bản
Loại: đọc
Độ lệch/kích thước: 0x206/2
Giao thức: 2,00+
============= =======

Chứa phiên bản giao thức khởi động, ở định dạng (chính << 8) + phụ,
  ví dụ: 0x0204 cho phiên bản 2.04 và 0x0a11 cho phiên bản giả định
  17/10.

===============================
Tên trường: realmode_swtch
Loại: sửa đổi (tùy chọn)
Độ lệch/kích thước: 0x208/4
Giao thức: 2,00+
===============================

Móc bộ tải khởi động (xem ADVANCED BOOT LOADER HOOKS bên dưới.)

============= ==============
Tên trường: start_sys_seg
Loại: đọc
Độ lệch/kích thước: 0x20c/2
Giao thức: 2,00+
============= ==============

Phân đoạn tải thấp (0x1000).  Lỗi thời.

============= ===============
Tên trường: kernel_version
Loại: đọc
Độ lệch/kích thước: 0x20e/2
Giao thức: 2,00+
============= ===============

Nếu được đặt thành giá trị khác 0, chứa một con trỏ tới NUL đã kết thúc
  Chuỗi số phiên bản kernel mà con người có thể đọc được, nhỏ hơn 0x200.  Điều này có thể
  được sử dụng để hiển thị phiên bản kernel cho người dùng.  Giá trị này
  phải nhỏ hơn (0x200 * setup_sects).

Ví dụ: nếu giá trị này được đặt thành 0x1c00, phiên bản kernel
  chuỗi số có thể được tìm thấy ở offset 0x1e00 trong tệp kernel.
  Đây là giá trị hợp lệ khi và chỉ khi trường "setup_sects"
  chứa giá trị 15 hoặc cao hơn, như::

0x1c00 < 15 * 0x200 (= 0x1e00) nhưng
   0x1c00 >= 14 * 0x200 (= 0x1c00)

0x1c00 >> 9 = 14, Vì vậy giá trị tối thiểu cho setup_secs là 15.

================================
Tên trường: type_of_loader
Loại: viết (bắt buộc)
Độ lệch/kích thước: 0x210/1
Giao thức: 2,00+
================================

Nếu bộ tải khởi động của bạn có ID được chỉ định (xem bảng bên dưới), hãy nhập
  0xTV ở đây, trong đó T là mã định danh cho bộ tải khởi động và V là
  một số phiên bản.  Nếu không, hãy nhập 0xFF vào đây.

Đối với ID bộ tải khởi động trên T = 0xD, hãy ghi T = 0xE vào trường này và
  ghi ID mở rộng trừ 0x10 vào trường ext_loader_type.
  Tương tự, trường ext_loader_ver có thể được sử dụng để cung cấp nhiều hơn
  bốn bit cho phiên bản bootloader.

Ví dụ: với T = 0x15, V = 0x234, hãy viết::

loại_of_loader <- 0xE4
   ext_loader_type <- 0x05
   ext_loader_ver <- 0x23

ID bộ tải khởi động được chỉ định:

==== ===========================================
	0x0 LILO
	     (0x00 dành riêng cho bộ tải khởi động trước 2.00)
	Tải trọng 0x1
	Trình tải khởi động 0x2
	     (0x20, tất cả các giá trị khác được bảo lưu)
	Hệ thống 0x3
	0x4 Etherboot/gPXE/iPXE
	0x5 ELILO
	0x7 GRUB
	Khởi động U 0x8
	Xen 0x9
	0xA Gujin
	0xB Qemu
	0xC Arcturus Networks uCbootloader
	Công cụ kexec 0xD
	0xE mở rộng (xem ext_loader_type)
	0xF Đặc biệt (0xFF = không xác định)
	0x10 dành riêng
	Bộ tải khởi động Linux tối thiểu 0x11
	     <ZZ0000ZZ
	Ngăn xếp ảo hóa 0x12 OVMF UEFI
	hộp trần 0x13
	==== ===========================================

Vui lòng liên hệ <hpa@zytor.com> nếu bạn cần gán giá trị ID bộ nạp khởi động.

=================================
Tên trường: Loadflags
Loại: sửa đổi (bắt buộc)
Độ lệch/kích thước: 0x211/1
Giao thức: 2,00+
=================================

Trường này là một bitmask.

Bit 0 (đọc): LOADED_HIGH

- Nếu 0, mã chế độ bảo vệ được tải ở mức 0x10000.
	- Nếu 1, mã chế độ bảo vệ được tải ở mức 0x100000.

Bit 1 (nhân bên trong): KASLR_FLAG

- Được sử dụng nội bộ bởi hạt nhân nén để giao tiếp
	  Trạng thái KASLR thành kernel thích hợp.

- Nếu là 1, KASLR đã được bật.
	    - Nếu 0, KASLR bị vô hiệu hóa.

Bit 5 (ghi): QUIET_FLAG

- Nếu 0 thì in tin nhắn sớm.
	- Nếu 1, ngăn chặn các tin nhắn sớm.

Điều này yêu cầu kernel (bộ giải nén và đầu
		kernel) để không viết các tin nhắn sớm yêu cầu
		truy cập trực tiếp vào phần cứng hiển thị.

Bit 6 (lỗi thời): KEEP_SEGMENTS

Giao thức: 2.07+

- Lá cờ này đã lỗi thời.

Bit 7 (ghi): CAN_USE_HEAP

Đặt bit này thành 1 để chỉ ra rằng giá trị được nhập vào
	heap_end_ptr là hợp lệ.  Nếu trường này trống, một số mã thiết lập
	chức năng sẽ bị vô hiệu hóa.


=================================
Tên trường: setup_move_size
Loại: sửa đổi (bắt buộc)
Độ lệch/kích thước: 0x212/2
Giao thức: 2,00-2,01
=================================

Khi sử dụng giao thức 2.00 hoặc 2.01, nếu kernel chế độ thực không có
  được tải ở 0x90000, nó sẽ được chuyển đến đó sau trong quá trình tải
  trình tự.  Điền vào trường này nếu bạn muốn có thêm dữ liệu (chẳng hạn như
  dòng lệnh kernel) được di chuyển cùng với kernel chế độ thực
  chính nó.

Đơn vị là byte bắt đầu từ phần đầu của khu vực khởi động.

Trường này có thể bị bỏ qua khi giao thức là 2.02 trở lên hoặc
  nếu mã chế độ thực được tải ở 0x90000.

=======================================
Tên trường: code32_start
Loại: sửa đổi (tùy chọn, định vị lại)
Độ lệch/kích thước: 0x214/4
Giao thức: 2,00+
=======================================

Địa chỉ để nhảy tới ở chế độ được bảo vệ.  Điều này mặc định cho tải
  địa chỉ của kernel và có thể được bộ tải khởi động sử dụng để
  xác định địa chỉ tải thích hợp.

Trường này có thể được sửa đổi cho hai mục đích:

1. như một hook bộ tải khởi động (xem Móc bộ tải khởi động nâng cao bên dưới.)

2. nếu bộ nạp khởi động không cài đặt hook sẽ tải một
       hạt nhân có thể định vị lại ở một địa chỉ không chuẩn, nó sẽ phải sửa đổi
       trường này để trỏ đến địa chỉ tải.

================================
Tên trường: ramdisk_image
Loại: viết (bắt buộc)
Độ lệch/kích thước: 0x218/4
Giao thức: 2,00+
================================

Địa chỉ tuyến tính 32 bit của ramdisk hoặc ramf ban đầu.  Khởi hành lúc
  0 nếu không có ramdisk/ramfs ban đầu.

================================
Tên trường: ramdisk_size
Loại: viết (bắt buộc)
Độ lệch/kích thước: 0x21c/4
Giao thức: 2,00+
================================

Kích thước của ramdisk hoặc ramf ban đầu.  Để lại ở mức 0 nếu không có
  ramdisk/ramfs ban đầu.

============================
Tên trường: bootect_kludge
Kiểu: hạt nhân nội bộ
Độ lệch/kích thước: 0x220/4
Giao thức: 2,00+
============================

Lĩnh vực này đã lỗi thời.

================================
Tên trường: heap_end_ptr
Loại: viết (bắt buộc)
Độ lệch/kích thước: 0x224/2
Giao thức: 2.01+
================================

Đặt trường này thành phần bù (từ đầu chế độ thực
  code) ở cuối ngăn xếp/đống thiết lập, trừ 0x0200.

==============================
Tên trường: ext_loader_ver
Loại: viết (tùy chọn)
Độ lệch/kích thước: 0x226/1
Giao thức: 2.02+
==============================

Trường này được sử dụng như phần mở rộng của số phiên bản trong
  trường type_of_loader.  Tổng số phiên bản được coi là
  (type_of_loader & 0x0f) + (ext_loader_ver << 4).

Việc sử dụng trường này là dành riêng cho bộ tải khởi động.  Nếu không được viết thì nó
  là số không.

Hạt nhân trước 2.6.31 không nhận ra trường này, nhưng nó an toàn
  để viết cho giao thức phiên bản 2.02 trở lên.

======================================================================
Tên trường: ext_loader_type
Kiểu: ghi (bắt buộc if (type_of_loader & 0xf0) == 0xe0)
Độ lệch/kích thước: 0x227/1
Giao thức: 2.02+
======================================================================

Trường này được sử dụng như phần mở rộng của số loại trong
  trường type_of_loader.  Nếu loại trong type_of_loader là 0xE thì
  loại thực tế là (ext_loader_type + 0x10).

Trường này bị bỏ qua nếu loại trong type_of_loader không phải là 0xE.

Hạt nhân trước 2.6.31 không nhận ra trường này, nhưng nó an toàn
  để viết cho giao thức phiên bản 2.02 trở lên.

================================
Tên trường: cmd_line_ptr
Loại: viết (bắt buộc)
Độ lệch/kích thước: 0x228/4
Giao thức: 2.02+
================================

Đặt trường này thành địa chỉ tuyến tính của dòng lệnh kernel.
  Dòng lệnh kernel có thể được đặt ở bất cứ đâu giữa phần cuối của
  vùng thiết lập và 0xA0000; nó không nhất thiết phải nằm ở
  cùng phân đoạn 64K với chính mã chế độ thực.

Điền vào trường này ngay cả khi bộ tải khởi động của bạn không hỗ trợ
  dòng lệnh, trong trường hợp đó bạn có thể trỏ dòng lệnh này tới một chuỗi trống
  (hoặc tốt hơn nữa là chuỗi "auto".) Nếu trường này được để lại ở
  0, kernel sẽ cho rằng bộ tải khởi động của bạn không hỗ trợ
  giao thức 2.02+.

============================
Tên trường: initrd_addr_max
Loại: đọc
Độ lệch/kích thước: 0x22c/4
Giao thức: 2.03+
============================

Địa chỉ tối đa có thể bị chiếm giữ bởi địa chỉ ban đầu
  nội dung ramdisk/ramfs.  Đối với các giao thức khởi động 2.02 hoặc cũ hơn, điều này
  trường không có mặt và địa chỉ tối đa là 0x37FFFFFF.  (Cái này
  địa chỉ được định nghĩa là địa chỉ của byte an toàn cao nhất, vì vậy nếu
  ramdisk của bạn dài chính xác là 131072 byte và trường này là
  0x37FFFFFF, bạn có thể khởi động đĩa RAM của mình ở 0x37FE0000.)

===========================================
Tên trường: kernel_alignment
Loại: đọc/sửa đổi (reloc)
Độ lệch/kích thước: 0x230/4
Giao thức: 2.05+ (đọc), 2.10+ (sửa đổi)
===========================================

Đơn vị căn chỉnh được hạt nhân yêu cầu (nếu relocatable_kernel là
  đúng.) Một hạt nhân có thể định vị lại được tải theo căn chỉnh
  không tương thích với giá trị trong trường này sẽ được sắp xếp lại trong quá trình
  khởi tạo kernel.

Bắt đầu với giao thức phiên bản 2.10, điều này phản ánh kernel
  căn chỉnh ưu tiên để có hiệu suất tối ưu; nó có thể cho
  bộ tải để sửa đổi trường này để cho phép căn chỉnh ít hơn.  Xem
  trường min_alignment và pref_address bên dưới.

================================
Tên trường: relocatable_kernel
Kiểu: đọc (reloc)
Độ lệch/kích thước: 0x234/1
Giao thức: 2.05+
================================

Nếu trường này khác 0 thì phần chế độ được bảo vệ của hạt nhân có thể
  được tải tại bất kỳ địa chỉ nào thỏa mãn trường kernel_alignment.
  Sau khi tải, bộ tải khởi động phải đặt trường code32_start thành
  trỏ đến mã được tải hoặc tới hook bộ tải khởi động.

============= ==============
Tên trường: min_alignment
Kiểu: đọc (reloc)
Độ lệch/kích thước: 0x235/1
Giao thức: 2.10+
============= ==============

Trường này, nếu khác 0, biểu thị lũy thừa của hai giá trị tối thiểu
  kernel cần căn chỉnh, trái ngược với mức ưu tiên, để khởi động.
  Nếu bộ tải khởi động sử dụng trường này, nó sẽ cập nhật
  trường kernel_alignment với đơn vị căn chỉnh mong muốn; tiêu biểu::

kernel_alignment = 1 << min_alignment;

Có thể có chi phí thực hiện đáng kể nếu sử dụng quá mức
  hạt nhân bị lệch.  Vì vậy, trình tải thường phải thử từng
  căn chỉnh lũy thừa hai từ kernel_alignment xuống căn chỉnh này.

=======================
Tên trường: xloadflags
Loại: đọc
Độ lệch/kích thước: 0x236/2
Giao thức: 2.12+
=======================

Trường này là một bitmask.

Bit 0 (đọc): XLF_KERNEL_64

- Nếu là 1, kernel này có điểm vào 64-bit kế thừa là 0x200.

Bit 1 (đọc): XLF_CAN_BE_LOADED_ABOVE_4G

- Nếu là 1 thì kernel/boot_params/cmdline/ramdisk có thể trên 4G.

Bit 2 (đọc): XLF_EFI_HANDOVER_32

- Nếu 1, kernel hỗ trợ điểm vào chuyển giao EFI 32-bit
          được đưa ra tại thời điểm chuyển giao_offset.

Bit 3 (đọc): XLF_EFI_HANDOVER_64

- Nếu 1, kernel hỗ trợ điểm vào chuyển giao EFI 64-bit
          đưa ra tại handover_offset + 0x200.

Bit 4 (đọc): XLF_EFI_KEXEC

- Nếu 1, kernel hỗ trợ khởi động kexec EFI với hỗ trợ thời gian chạy EFI.


============= =============
Tên trường: cmdline_size
Loại: đọc
Độ lệch/kích thước: 0x238/4
Giao thức: 2.06+
============= =============

Kích thước tối đa của dòng lệnh mà không cần kết thúc
  không. Điều này có nghĩa là dòng lệnh có thể chứa tối đa
  ký tự cmdline_size. Với giao thức phiên bản 2.05 trở về trước,
  kích thước tối đa là 255.

====================================================
Tên trường: hardware_subarch
Loại: ghi (tùy chọn, mặc định là x86/PC)
Độ lệch/kích thước: 0x23c/4
Giao thức: 2.07+
====================================================

Trong môi trường ảo hóa, kiến trúc phần cứng cấp thấp
  các phần như xử lý ngắt, xử lý bảng trang và
  việc truy cập các thanh ghi điều khiển quá trình cần phải được thực hiện khác nhau.

Trường này cho phép bộ nạp khởi động thông báo cho kernel biết chúng ta đang ở trong một
  một trong những môi trường đó

===========================================
  0x00000000 Môi trường x86/PC mặc định
  0x00000001 lkhách
  0x00000002 Xen
  0x00000003 Intel MID (Moorestown, CloverTrail, Merrifield, Moorefield)
  Nền tảng TV 0x00000004 CE4100
  ===========================================

========================================
Tên trường: hardware_subarch_data
Loại: viết (phụ thuộc vào phân nhóm)
Độ lệch/kích thước: 0x240/8
Giao thức: 2.07+
========================================

Một con trỏ tới dữ liệu dành riêng cho phân mục phần cứng
  Trường này hiện không được sử dụng cho môi trường x86/PC mặc định,
  không sửa đổi.

============= ===============
Tên trường: payload_offset
Loại: đọc
Độ lệch/kích thước: 0x248/4
Giao thức: 2.08+
============= ===============

Nếu khác 0 thì trường này chứa phần bù từ đầu
  của mã chế độ được bảo vệ vào tải trọng.

Tải trọng có thể được nén. Định dạng của cả tệp nén và
  dữ liệu không nén phải được xác định bằng phép thuật tiêu chuẩn
  những con số.  Các định dạng nén hiện được hỗ trợ là gzip
  (số ma thuật 1F 8B hoặc 1F 9E), bzip2 (con số ma thuật 42 5A), LZMA
  (con số ma thuật 5D 00), XX (con số ma thuật FD 37), LZ4 (con số ma thuật
  02 21) và ZSTD (con số kỳ diệu 28 B5). Tải trọng không nén là
  hiện tại luôn là ELF (con số kỳ diệu 7F 45 4C 46).

============= ===============
Tên trường: payload_length
Loại: đọc
Độ lệch/kích thước: 0x24c/4
Giao thức: 2.08+
============= ===============

Chiều dài của tải trọng.

============================
Tên trường: setup_data
Loại: viết (đặc biệt)
Độ lệch/kích thước: 0x250/8
Giao thức: 2.09+
============================

Con trỏ vật lý 64 bit tới NULL đã kết thúc danh sách liên kết đơn của
  cấu trúc setup_data. Điều này được sử dụng để xác định một khởi động mở rộng hơn
  cơ chế truyền tham số Định nghĩa của struct setup_data là
  như sau::

cấu trúc setup_data {
	__u64 tiếp theo;
	__u32 loại;
	__u32 len;
	__u8 dữ liệu[];
   }

Trong đó, tiếp theo là con trỏ vật lý 64 bit tới nút tiếp theo của
  danh sách liên kết, trường tiếp theo của nút cuối cùng là 0; loại được sử dụng
  để xác định nội dung của dữ liệu; len là độ dài của dữ liệu
  lĩnh vực; dữ liệu chứa tải trọng thực sự.

Danh sách này có thể được sửa đổi tại một số điểm trong quá trình khởi động
  quá trình.  Vì vậy, khi sửa đổi danh sách này, người ta phải luôn thực hiện
  chắc chắn xem xét trường hợp danh sách liên kết đã chứa
  mục nhập.

setup_data hơi khó sử dụng cho các đối tượng dữ liệu cực lớn,
  cả hai vì tiêu đề setup_data phải liền kề với đối tượng dữ liệu
  và bởi vì nó có trường có độ dài 32 bit. Tuy nhiên, điều quan trọng là
  các giai đoạn trung gian của quá trình khởi động có cách để xác định
  khối bộ nhớ bị chiếm giữ bởi dữ liệu kernel.

Do đó, cấu trúc setup_indirect và loại SETUP_INDIRECT đã được giới thiệu trong
  giao thức 2.15::

cấu trúc setup_indirect {
	__u32 loại;
	__u32 dành riêng;		/* Dành riêng, phải được đặt thành 0. */
	__u64 len;
	__u64 địa chỉ;
   };

Thành viên loại là SETUP_INDIRECT | Loại SETUP_*. Tuy nhiên, nó không thể
  Bản thân SETUP_INDIRECT kể từ khi tạo cấu trúc cây setup_indirect
  có thể cần nhiều không gian ngăn xếp trong thứ gì đó cần phân tích cú pháp
  và không gian ngăn xếp có thể bị giới hạn trong bối cảnh khởi động.

Hãy đưa ra một ví dụ về cách trỏ đến dữ liệu SETUP_E820_EXT bằng setup_indirect.
  Trong trường hợp này setup_data và setup_indirect sẽ trông như thế này ::

cấu trúc setup_data {
	.next = 0, /* hoặc <addr_of_next_setup_data_struct> */
	.type = SETUP_INDIRECT,
	.len = sizeof(setup_indirect),
	.data[sizeof(setup_indirect)] = (struct setup_indirect) {
		.type = SETUP_INDIRECT | SETUP_E820_EXT,
		.reserved = 0,
		.len = <len_of_SETUP_E820_EXT_data>,
		.addr = <addr_of_SETUP_E820_EXT_data>,
	},
   }

.. note::
     SETUP_INDIRECT | SETUP_NONE objects cannot be properly distinguished
     from SETUP_INDIRECT itself. So, this kind of objects cannot be provided
     by the bootloaders.

============= =============
Tên trường: pref_address
Kiểu: đọc (reloc)
Độ lệch/kích thước: 0x258/8
Giao thức: 2.10+
============= =============

Trường này, nếu khác 0, biểu thị địa chỉ tải ưu tiên cho
  hạt nhân.  Bộ tải khởi động được định vị lại sẽ cố gắng tải vào thời điểm này
  địa chỉ nếu có thể.

Một hạt nhân không thể định vị lại sẽ tự di chuyển vô điều kiện và chạy
  tại địa chỉ này. Một hạt nhân có khả năng định vị lại sẽ tự di chuyển đến địa chỉ này nếu nó
  được tải bên dưới địa chỉ này.

============= =======
Tên trường: init_size
Loại: đọc
Độ lệch/kích thước: 0x260/4
============= =======

Trường này cho biết số lượng bộ nhớ liền kề tuyến tính bắt đầu
  tại địa chỉ bắt đầu thời gian chạy kernel mà kernel cần trước nó
  có khả năng kiểm tra bản đồ bộ nhớ của nó.  Đây không phải là điều tương tự
  là tổng dung lượng bộ nhớ mà kernel cần để khởi động, nhưng nó có thể
  được sử dụng bởi bộ tải khởi động định vị lại để giúp chọn tải an toàn
  địa chỉ cho kernel.

Địa chỉ bắt đầu thời gian chạy kernel được xác định bằng thuật toán sau::

if (relocatable_kernel) {
	nếu (load_address < pref_address)
		Load_address = pref_address;
	thời gian chạy_start = căn_up(load_address, kernel_alignment);
   } khác {
	thời gian chạy_start = pref_address;
   }

Do đó, vị trí và kích thước cửa sổ bộ nhớ cần thiết có thể được ước tính bằng
một bộ tải khởi động như::

bộ nhớ_window_start = thời gian chạy_start;
   bộ nhớ_window_size = init_size;

============================
Tên trường: handover_offset
Loại: đọc
Độ lệch/kích thước: 0x264/4
============================

Trường này là phần bù từ đầu của ảnh hạt nhân đến
  điểm vào giao thức chuyển giao EFI. Bộ tải khởi động sử dụng EFI
  giao thức chuyển giao để khởi động kernel sẽ chuyển sang phần bù này.

Xem EFI HANDOVER PROTOCOL bên dưới để biết thêm chi tiết.

================================
Tên trường: kernel_info_offset
Loại: đọc
Độ lệch/kích thước: 0x268/4
Giao thức: 2.15+
================================

Trường này là phần bù từ phần đầu của ảnh hạt nhân đến phần
  kernel_info. Cấu trúc kernel_info được nhúng trong image Linux
  trong vùng chế độ bảo vệ không nén.


Thông tin hạt nhân
===============

Mối quan hệ giữa các tiêu đề tương tự với các dữ liệu khác nhau
phần::

setup_header = .data
  boot_params/setup_data = .bss

Danh sách trên còn thiếu điều gì? Đúng rồi::

kernel_info = .rodata

Chúng tôi đã (ab) sử dụng .data cho những thứ có thể chuyển sang .rodata hoặc .bss cho
một thời gian dài, vì thiếu các lựa chọn thay thế và - đặc biệt là ở giai đoạn đầu - quán tính.
Ngoài ra, sơ khai BIOS chịu trách nhiệm tạo boot_params, vì vậy nó không phải
có sẵn cho trình tải dựa trên BIOS (mặc dù vậy là setup_data).

setup_header bị giới hạn vĩnh viễn ở 144 byte do phạm vi tiếp cận của
Trường nhảy 2 byte, được nhân đôi thành trường độ dài cho cấu trúc, được kết hợp
với kích thước của "lỗ" trong struct boot_params mà trình tải chế độ được bảo vệ
hoặc sơ khai BIOS phải sao chép nó vào. Hiện tại nó dài 119 byte,
để lại cho chúng tôi 25 byte rất quý giá. Đây không phải là thứ có thể sửa được
mà không sửa đổi hoàn toàn giao thức khởi động, phá vỡ khả năng tương thích ngược.

boot_params thích hợp được giới hạn ở 4096 byte, nhưng có thể được mở rộng tùy ý
bằng cách thêm các mục setup_data. Nó không thể được sử dụng để truyền đạt các thuộc tính của
hình ảnh hạt nhân, vì nó là .bss và không có nội dung do hình ảnh cung cấp.

kernel_info giải quyết vấn đề này bằng cách cung cấp một nơi có thể mở rộng thông tin về
hình ảnh hạt nhân. Nó ở dạng chỉ đọc, vì kernel không thể dựa vào một
bootloader sao chép nội dung của nó ở bất cứ đâu, nhưng không sao; nếu nó trở thành
cần thiết, nó vẫn có thể chứa các mục dữ liệu mà bộ tải khởi động được kích hoạt sẽ
dự kiến ​​sẽ sao chép vào một đoạn setup_data.

Tất cả dữ liệu kernel_info phải là một phần của cấu trúc này. Dữ liệu có kích thước cố định phải
được đặt trước nhãn kernel_info_var_len_data. Dữ liệu kích thước thay đổi phải được đặt
sau nhãn kernel_info_var_len_data. Mỗi đoạn dữ liệu có kích thước thay đổi phải
được bắt đầu bằng tiêu đề/ma thuật và kích thước của nó, ví dụ::

kernel_info:
	.ascii "LToP" /* Tiêu đề, phần trên cùng của Linux (cấu trúc). */
	.long kernel_info_var_len_data - kernel_info
	.long kernel_info_end - kernel_info
	.long 0x01234567 /* Một số dữ liệu có kích thước cố định cho bộ nạp khởi động. */
  kernel_info_var_len_data:
  example_struct: /* Một số dữ liệu có kích thước thay đổi cho bộ nạp khởi động. */
	.ascii "0123" /* Tiêu đề/Magic. */
	.long example_struct_end - example_struct
	.ascii "Cấu trúc"
	.dài 0x89012345
  example_struct_end:
  example_strings: /* Một số dữ liệu có kích thước thay đổi cho bộ nạp khởi động. */
	.ascii "ABCD" /* Tiêu đề/Magic. */
	.long example_strings_end - example_strings
	.asciz "Chuỗi_0"
	.asciz "Chuỗi_1"
  example_strings_end:
  kernel_info_end:

Bằng cách này, kernel_info là một blob độc lập.

.. note::
     Each variable size data header/magic can be any 4-character string,
     without \0 at the end of the string, which does not collide with
     existing variable length data headers/magics.


Chi tiết về các trường kernel_info
=================================

=====================
Tên trường: tiêu đề
Độ lệch/kích thước: 0x0000/4
=====================

Chứa số ma thuật "LToP" (0x506f544c).

=====================
Tên trường: kích thước
Độ lệch/kích thước: 0x0004/4
=====================

Trường này chứa kích thước của kernel_info bao gồm kernel_info.header.
  Nó không tính kích thước kernel_info.kernel_info_var_len_data. Trường này nên được
  được bộ tải khởi động sử dụng để phát hiện các trường có kích thước cố định được hỗ trợ trong kernel_info
  và bắt đầu kernel_info.kernel_info_var_len_data.

=====================
Tên trường: size_total
Độ lệch/kích thước: 0x0008/4
=====================

Trường này chứa kích thước của kernel_info bao gồm kernel_info.header
  và kernel_info.kernel_info_var_len_data.

============= ===============
Tên trường: setup_type_max
Độ lệch/kích thước: 0x000c/4
============= ===============

Trường này chứa loại tối đa được phép cho các cấu trúc setup_data và setup_indirect.


Dòng lệnh hạt nhân
=======================

Dòng lệnh kernel đã trở thành một cách quan trọng để khởi động
bộ nạp để giao tiếp với kernel.  Một số tùy chọn của nó cũng
có liên quan đến chính bộ tải khởi động, hãy xem "các tùy chọn dòng lệnh đặc biệt"
bên dưới.

Dòng lệnh kernel là một chuỗi kết thúc bằng null. Tối đa
chiều dài có thể được lấy từ trường cmdline_size.  Trước giao thức
phiên bản 2.06, tối đa là 255 ký tự.  Một chuỗi quá
long sẽ được kernel tự động cắt bớt.

Nếu phiên bản giao thức khởi động là 2.02 hoặc mới hơn, địa chỉ của
dòng lệnh kernel được cung cấp bởi trường tiêu đề cmd_line_ptr (xem
ở trên.) Địa chỉ này có thể ở bất kỳ đâu giữa phần cuối của quá trình thiết lập
đống và 0xA0000.

Nếu phiên bản giao thức là ZZ0000ZZ 2.02 trở lên, kernel
dòng lệnh được nhập bằng giao thức sau:

- Tại offset 0x0020(word), “cmd_line_magic”, nhập magic
    số 0xA33F.

- Tại offset 0x0022(word), “cmd_line_offset”, nhập offset
    của dòng lệnh kernel (so với thời điểm bắt đầu của
    hạt nhân chế độ thực).

- Dòng lệnh kernel ZZ0000ZZ nằm trong vùng bộ nhớ
    được bao phủ bởi setup_move_size, vì vậy bạn có thể cần điều chỉnh điều này
    lĩnh vực.


Bố cục bộ nhớ của mã chế độ thực
===================================

Mã chế độ thực yêu cầu thiết lập ngăn xếp/đống, cũng như
bộ nhớ được phân bổ cho dòng lệnh kernel.  Điều này cần phải được thực hiện
trong bộ nhớ có thể truy cập ở chế độ thực tính bằng megabyte dưới cùng.

Cần lưu ý rằng các máy hiện đại thường có Extended khá lớn.
Vùng dữ liệu BIOS (EBDA).  Vì vậy, nên sử dụng càng ít
có dung lượng megabyte thấp nhất có thể.

Thật không may, trong những trường hợp sau, bộ nhớ 0x90000
phân đoạn phải được sử dụng:

- Khi tải kernel zImage ((loadflags & 0x01) == 0).
	- Khi tải hạt nhân giao thức khởi động 2.01 hoặc cũ hơn.

.. note::
     For the 2.00 and 2.01 boot protocols, the real-mode code
     can be loaded at another address, but it is internally
     relocated to 0x90000.  For the "old" protocol, the
     real-mode code must be loaded at 0x90000.

Khi tải ở 0x90000, tránh sử dụng bộ nhớ trên 0x9a000.

Đối với giao thức khởi động 2.02 trở lên, dòng lệnh không cần phải
nằm trong cùng phân đoạn 64K với mã thiết lập chế độ thực; nó là
do đó được phép cung cấp cho ngăn xếp/đống phân đoạn 64K đầy đủ và xác định vị trí
dòng lệnh phía trên nó.

Dòng lệnh kernel không được đặt bên dưới chế độ thực
mã, nó cũng không nên được đặt trong bộ nhớ cao.


Cấu hình khởi động mẫu
=========================

Là một cấu hình mẫu, giả sử bố cục sau của mạng thực
đoạn chế độ.

Khi tải dưới 0x90000, hãy sử dụng toàn bộ phân đoạn:

===================================
	0x0000-0x7fff Hạt nhân chế độ thực
	0x8000-0xdfff Ngăn xếp và đống
	Dòng lệnh hạt nhân 0xe000-0xffff
	===================================

Khi tải ở 0x90000 HOẶC phiên bản giao thức là 2.01 trở về trước:

===================================
	0x0000-0x7fff Hạt nhân chế độ thực
	0x8000-0x97ff Xếp chồng và đống
	Dòng lệnh hạt nhân 0x9800-0x9fff
	===================================

Bộ tải khởi động như vậy phải nhập các trường sau vào tiêu đề ::

base_ptr dài không dấu;	/* địa chỉ cơ sở cho phân đoạn chế độ thực */

nếu (setup_sects == 0)
	setup_sects = 4;

nếu (giao thức >= 0x0200) {
	type_of_loader = <gõ mã>;
	nếu (loading_initrd) {
		ramdisk_image = <initrd_address>;
		ramdisk_size = <initrd_size>;
	}

if (giao thức >= 0x0202 && Loadflags & 0x01)
		heap_end = 0xe000;
	khác
		đống_end = 0x9800;

nếu (giao thức >= 0x0201) {
		heap_end_ptr = heap_end - 0x200;
		cờ tải |= 0x80;		/* CAN_USE_HEAP */
	}

nếu (giao thức >= 0x0202) {
		cmd_line_ptr = base_ptr + heap_end;
		strcpy(cmd_line_ptr, cmdline);
	} khác {
		cmd_line_magic = 0xA33F;
		cmd_line_offset = heap_end;
		setup_move_size = heap_end + strlen(cmdline) + 1;
		strcpy(base_ptr + cmd_line_offset, cmdline);
	}
  } khác {
	/* Kernel rất cũ */

đống_end = 0x9800;

cmd_line_magic = 0xA33F;
	cmd_line_offset = heap_end;

/* Kernel MUST rất cũ có mã chế độ thực được tải ở 0x90000 */
	nếu (base_ptr != 0x90000) {
		/* Sao chép kernel chế độ thực */
		memcpy(0x90000, base_ptr, (setup_sects + 1) * 512);
		base_ptr = 0x90000;		 /* Đã di dời */
	}

strcpy(0x90000 + cmd_line_offset, cmdline);

/* Nên xóa bộ nhớ lên tới mốc 32K */
	bộ nhớ (0x90000 + (setup_sects + 1) * 512, 0, (64 - (setup_sects + 1)) * 512);
  }


Đang tải phần còn lại của hạt nhân
==============================

Hạt nhân 32 bit (không phải chế độ thực) bắt đầu ở offset (setup_sects + 1) * 512
trong tệp kernel (một lần nữa, nếu setup_sects == 0 thì giá trị thực là 4.)
Nó phải được tải tại địa chỉ 0x10000 cho hạt nhân Image/zImage và
0x100000 cho hạt nhân bzImage.

Hạt nhân là hạt nhân bzImage nếu giao thức >= 2.00 và 0x01
bit (LOAD_HIGH) trong trường cờ tải được đặt::

is_bzImage = (giao thức >= 0x0200) && (loadflags & 0x01);
  tải_địa chỉ = is_bzImage? 0x100000 : 0x10000;

.. note::
     Image/zImage kernels can be up to 512K in size, and thus use the entire
     0x10000-0x90000 range of memory.  This means it is pretty much a
     requirement for these kernels to load the real-mode part at 0x90000.
     bzImage kernels allow much more flexibility.

Tùy chọn dòng lệnh đặc biệt
============================

Nếu dòng lệnh do bộ tải khởi động cung cấp được nhập bởi
người dùng, người dùng có thể mong đợi các tùy chọn dòng lệnh sau hoạt động.
Thông thường chúng không nên bị xóa khỏi dòng lệnh kernel ngay cả
mặc dù không phải tất cả chúng đều thực sự có ý nghĩa đối với kernel.  Khởi động
tác giả trình tải cần tùy chọn dòng lệnh bổ sung để khởi động
bản thân bộ nạp sẽ đăng ký chúng trong
Documentation/admin-guide/kernel-parameters.rst để đảm bảo rằng chúng sẽ không
xung đột với các tùy chọn kernel thực tế hiện tại hoặc trong tương lai.

vga=<chế độ>
	<mode> ở đây là một số nguyên (trong ký hiệu C, hoặc
	thập phân, bát phân hoặc thập lục phân) hoặc một trong các chuỗi
	"bình thường" (nghĩa là 0xFFFF), "ext" (nghĩa là 0xFFFE) hoặc "hỏi"
	(có nghĩa là 0xFFFD).  Giá trị này phải được nhập vào
	trường vid_mode, vì nó được kernel sử dụng trước lệnh
	dòng được phân tích cú pháp.

ghi nhớ=<kích thước>
	<size> là một số nguyên trong ký hiệu C, theo sau là tùy chọn
	(không phân biệt chữ hoa chữ thường) K, M, G, T, P hoặc E (nghĩa là << 10, << 20,
	<< 30, << 40, << 50 hoặc << 60).  Điều này xác định sự kết thúc của
	bộ nhớ vào kernel. Điều này ảnh hưởng đến vị trí có thể của
	một initrd, vì initrd nên được đặt gần cuối
	trí nhớ.  Lưu ý rằng đây là một tùy chọn cho hạt nhân ZZ0000ZZ và
	bộ nạp khởi động!

initrd=<tập tin>
	Một initrd nên được tải.  Ý nghĩa của <file> là
	rõ ràng là phụ thuộc vào bộ nạp khởi động và một số bộ tải khởi động
	(ví dụ LILO) không có lệnh như vậy.

Ngoài ra, một số bộ tải khởi động còn thêm các tùy chọn sau vào
dòng lệnh do người dùng chỉ định:

BOOT_IMAGE=<tập tin>
	Hình ảnh khởi động đã được tải.  Một lần nữa, ý nghĩa của <file>
	rõ ràng là phụ thuộc vào bootloader.

tự động
	Kernel đã được khởi động mà không có sự can thiệp rõ ràng của người dùng.

Nếu các tùy chọn này được thêm vào bởi bộ tải khởi động thì sẽ rất nguy hiểm.
khuyến nghị rằng chúng nên được đặt ở vị trí ZZ0000ZZ, trước địa chỉ do người dùng chỉ định
hoặc dòng lệnh do cấu hình chỉ định.  Ngược lại, "init=/bin/sh"
bị nhầm lẫn bởi tùy chọn "tự động".


Chạy hạt nhân
==================

Hạt nhân được khởi động bằng cách nhảy tới điểm vào của hạt nhân, đó là
nằm ở ZZ0000ZZ offset 0x20 kể từ khi bắt đầu chế độ thực
hạt nhân.  Điều này có nghĩa là nếu bạn đã tải mã hạt nhân chế độ thực của mình tại
0x90000, điểm vào kernel là 9020:0000.

Khi vào, ds = es = ss sẽ trỏ đến điểm bắt đầu của chế độ thực
mã hạt nhân (0x9000 nếu mã được tải ở 0x90000), sp phải là
được thiết lập đúng cách, thường trỏ đến đỉnh của vùng heap và
ngắt nên bị vô hiệu hóa.  Hơn nữa, để đề phòng các lỗi trong
kernel, bộ tải khởi động nên đặt fs = gs = ds =
es = ss.

Trong ví dụ của chúng tôi ở trên, chúng tôi sẽ làm::

/*
   * Lưu ý: trong trường hợp giao thức kernel "cũ", base_ptr phải
   * be == 0x90000 tại thời điểm này; xem mã mẫu trước đó.
   */
  seg = base_ptr >> 4;

cli();			/* Nhập với các ngắt bị vô hiệu hóa! */

/* Thiết lập ngăn xếp kernel ở chế độ thực */
  _SS = phân đoạn;
  _SP = heap_end;

_DS = _ES = _FS = _GS = phân đoạn;
  jmp_far(seg + 0x20, 0);	/* Chạy hạt nhân */

Nếu khu vực khởi động của bạn truy cập vào ổ đĩa mềm, bạn nên
hãy tắt động cơ đĩa mềm trước khi chạy kernel, vì
quá trình khởi động kernel bị gián đoạn và do đó động cơ sẽ không hoạt động
bị tắt, đặc biệt nếu hạt nhân đã nạp có trình điều khiển đĩa mềm như
một mô-đun đáp ứng nhu cầu!


Móc tải khởi động nâng cao
==========================

Nếu bộ tải khởi động chạy trong một môi trường đặc biệt thù địch (chẳng hạn như
LOADLIN, chạy dưới DOS), có thể không thể làm theo
yêu cầu vị trí bộ nhớ tiêu chuẩn.  Bộ tải khởi động như vậy có thể sử dụng
các hook sau đây, nếu được thiết lập, sẽ được gọi bởi kernel tại
thời điểm thích hợp.  Việc sử dụng những chiếc móc này có lẽ nên
được coi là phương sách cuối cùng!

IMPORTANT: Cần có tất cả các hook để bảo toàn %esp, %ebp, %esi và
%edi qua lời gọi.

realmode_swtch:
	Một chương trình con xa ở chế độ thực 16-bit được gọi ngay trước
	vào chế độ được bảo vệ.  Quy trình mặc định sẽ vô hiệu hóa NMI, vì vậy
	thói quen của bạn có lẽ cũng nên làm như vậy.

mã32_start:
	Một quy trình chế độ phẳng 32-bit ZZ0000ZZ ngay sau
	chuyển sang chế độ được bảo vệ, nhưng trước khi kernel được
	không nén.  Không có phân đoạn nào, ngoại trừ CS, được đảm bảo là
	thiết lập (hạt nhân hiện tại thì có, nhưng hạt cũ thì không); bạn nên
	hãy tự thiết lập chúng thành BOOT_DS (0x18).

Sau khi hook xong bạn nên nhảy tới địa chỉ
	nó nằm trong trường này trước khi bộ tải khởi động của bạn ghi đè lên nó
	(di dời, nếu thích hợp.)


Giao thức khởi động 32-bit
====================

Đối với máy có một số BIOS mới ngoài BIOS cũ, chẳng hạn như EFI,
LinuxBIOS, v.v. và kexec, mã thiết lập chế độ thực 16 bit trong kernel
không thể sử dụng dựa trên BIOS kế thừa, do đó cần có giao thức khởi động 32 bit
được xác định.

Trong giao thức khởi động 32 bit, bước đầu tiên trong quá trình tải nhân Linux
nên thiết lập các tham số khởi động (struct boot_params,
theo truyền thống được gọi là "trang không"). Bộ nhớ cho struct boot_params
nên được phân bổ và khởi tạo bằng 0. Sau đó, tiêu đề thiết lập
từ offset 0x01f1 của ảnh kernel trở đi nên được tải vào struct
boot_params và kiểm tra. Tiêu đề kết thúc thiết lập có thể được tính như sau
theo dõi::

0x0202 + giá trị byte ở offset 0x0201

Ngoài việc đọc/sửa đổi/ghi tiêu đề thiết lập của cấu trúc
boot_params giống như giao thức khởi động 16-bit, bộ tải khởi động sẽ
cũng điền vào các trường bổ sung của struct boot_params như
được mô tả trong chương Documentation/arch/x86/zero-page.rst.

Sau khi thiết lập cấu trúc boot_params, bộ tải khởi động có thể tải
Kernel 32/64-bit giống như giao thức khởi động 16-bit.

Trong giao thức khởi động 32-bit, kernel được khởi động bằng cách nhảy tới
Điểm vào kernel 32-bit, là địa chỉ bắt đầu của quá trình tải
Hạt nhân 32/64-bit.

Khi vào, CPU phải ở chế độ được bảo vệ 32 bit với tính năng phân trang
bị vô hiệu hóa; GDT phải được tải cùng với bộ mô tả cho bộ chọn
__BOOT_CS(0x10) và __BOOT_DS(0x18); cả hai mô tả phải là 4G phẳng
phân đoạn; __BOOT_CS phải có quyền thực thi/đọc và __BOOT_DS
phải có quyền đọc/ghi; CS phải là __BOOT_CS và DS, ES, SS
phải là __BOOT_DS; ngắt phải bị vô hiệu hóa; %esi phải giữ căn cứ
địa chỉ của struct boot_params; %ebp, %edi và %ebx phải bằng 0.

Giao thức khởi động 64-bit
====================

Đối với máy có cpu 64bit và kernel 64bit, chúng ta có thể sử dụng bootloader 64bit
và chúng ta cần một giao thức khởi động 64-bit.

Trong giao thức khởi động 64-bit, bước đầu tiên trong quá trình tải nhân Linux
nên thiết lập các tham số khởi động (struct boot_params,
theo truyền thống được gọi là "trang không"). Bộ nhớ cho struct boot_params
có thể được phân bổ ở bất cứ đâu (thậm chí trên 4G) và được khởi tạo bằng 0.
Sau đó, tiêu đề thiết lập ở offset 0x01f1 của ảnh kernel sẽ là
được tải vào struct boot_params và kiểm tra. Tiêu đề kết thúc thiết lập
có thể được tính như sau::

0x0202 + giá trị byte ở offset 0x0201

Ngoài việc đọc/sửa đổi/ghi tiêu đề thiết lập của cấu trúc
boot_params giống như giao thức khởi động 16-bit, bộ tải khởi động sẽ
cũng điền vào các trường bổ sung của struct boot_params như được mô tả
trong chương Documentation/arch/x86/zero-page.rst.

Sau khi thiết lập cấu trúc boot_params, bộ tải khởi động có thể tải
Hạt nhân 64-bit giống như giao thức khởi động 16-bit, nhưng
kernel có thể được tải trên 4G.

Trong giao thức khởi động 64-bit, kernel được khởi động bằng cách nhảy tới
Điểm vào kernel 64-bit, là địa chỉ bắt đầu của quá trình tải
Hạt nhân 64 bit cộng với 0x200.

Khi vào, CPU phải ở chế độ 64-bit và bật tính năng phân trang.
Phạm vi có setup_header.init_size từ địa chỉ bắt đầu được tải
kernel và trang zero và bộ đệm dòng lệnh lấy ánh xạ nhận dạng;
GDT phải được tải cùng với bộ mô tả cho bộ chọn
__BOOT_CS(0x10) và __BOOT_DS(0x18); cả hai mô tả phải là 4G phẳng
phân đoạn; __BOOT_CS phải có quyền thực thi/đọc và __BOOT_DS
phải có quyền đọc/ghi; CS phải là __BOOT_CS và DS, ES, SS
phải là __BOOT_DS; ngắt phải bị vô hiệu hóa; %rsi phải giữ chân đế
địa chỉ của struct boot_params.

Giao thức chuyển giao EFI (không dùng nữa)
==================================

Giao thức này cho phép bộ tải khởi động trì hoãn việc khởi tạo EFI
cuống khởi động. Cần có bộ tải khởi động để tải kernel/initrd
từ phương tiện khởi động và nhảy tới điểm vào giao thức chuyển giao EFI
đó là hdr->handover_offset byte từ đầu
khởi động_{32,64}.

Bộ tải khởi động MUST tôn trọng siêu dữ liệu PE/COFF của kernel khi nó xuất hiện
để căn chỉnh phần, dung lượng bộ nhớ của hình ảnh thực thi vượt quá
kích thước của chính tệp đó và bất kỳ khía cạnh nào khác của tiêu đề PE/COFF
có thể ảnh hưởng đến hoạt động chính xác của hình ảnh dưới dạng nhị phân PE/COFF trong
bối cảnh thực thi được cung cấp bởi phần sụn EFI.

Nguyên mẫu hàm cho điểm vào chuyển giao trông như thế này::

void efi_stub_entry(void *handle, efi_system_table_t *table, struct boot_params *bp);

'xử lý' là trình xử lý hình ảnh EFI được EFI chuyển đến bộ tải khởi động
firmware, 'table' là bảng hệ thống EFI - đây là hai bảng đầu tiên
các đối số của "trạng thái chuyển giao" như được mô tả trong phần 2.3 của
Thông số kỹ thuật UEFI. 'bp' là thông số khởi động được phân bổ bởi bộ tải khởi động.

Bộ tải khởi động ZZ0000ZZ điền vào các trường sau trong bp::

- hdr.cmd_line_ptr
  - hdr.ramdisk_image (nếu có)
  - hdr.ramdisk_size (nếu có)

Tất cả các trường khác phải bằng 0.

.. note::
   The EFI Handover Protocol is deprecated in favour of the ordinary PE/COFF
   entry point described below.

.. _pe-coff-entry-point:

Điểm vào PE/COFF
===================

Khi được biên dịch bằng ZZ0000ZZ, kernel có thể được thực thi dưới dạng
nhị phân PE/COFF thông thường. Xem Tài liệu/admin-guide/efi-stub.rst để biết
chi tiết thực hiện.

Trình tải sơ khai có thể yêu cầu initrd thông qua giao thức UEFI. Để làm việc này,
phần sụn hoặc bộ nạp khởi động cần đăng ký một tay cầm mang
triển khai giao thức ZZ0000ZZ và đường dẫn thiết bị
giao thức hiển thị đường dẫn thiết bị đa phương tiện của nhà cung cấp ZZ0001ZZ.
Trong trường hợp này, kernel khởi động qua sơ khai EFI sẽ gọi
Phương pháp ZZ0002ZZ trên giao thức đã đăng ký để hướng dẫn
chương trình cơ sở để tải initrd vào vị trí bộ nhớ được chọn bởi kernel/EFI
sơ khai.

Cách tiếp cận này loại bỏ sự cần thiết phải có bất kỳ kiến thức nào về phía EFI
bộ nạp khởi động liên quan đến biểu diễn bên trong của boot_params hoặc bất kỳ
yêu cầu/hạn chế liên quan đến vị trí của dòng lệnh và
ramdisk trong bộ nhớ hoặc vị trí của hình ảnh hạt nhân.

Để biết cách triển khai mẫu, hãy tham khảo ZZ0000ZZ hoặc
ZZ0001ZZ.

.. _the original u-boot implementation: https://github.com/u-boot/u-boot/commit/ec80b4735a593961fe701cc3a5d717d4739b0fd0
.. _the OVMF implementation: https://github.com/tianocore/edk2/blob/1780373897f12c25075f8883e073144506441168/OvmfPkg/LinuxInitrdDynamicShellCommand/LinuxInitrdDynamicShellCommand.c