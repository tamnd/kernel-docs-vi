.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/elf_hwcaps.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _elf_hwcaps_powerpc:

====================
POWERPC ELF HWCAP
====================

Tài liệu này mô tả cách sử dụng và ngữ nghĩa của powerpc ELF HWCAP.


1. Giới thiệu
---------------

Một số tính năng phần cứng hoặc phần mềm chỉ có trên một số CPU
triển khai và/hoặc với các cấu hình kernel nhất định, nhưng không có cài đặt nào khác
cơ chế khám phá có sẵn cho mã không gian người dùng. Hạt nhân bộc lộ
sự hiện diện của các tính năng này đối với không gian người dùng thông qua một bộ cờ gọi là HWCAP,
lộ ra trong vectơ phụ.

Phần mềm không gian người dùng có thể kiểm tra các tính năng bằng cách mua AT_HWCAP hoặc
Mục nhập AT_HWCAP2 của vectơ phụ và kiểm tra xem có liên quan hay không
cờ được đặt, ví dụ::

bool float_point_is_hiện tại (void)
	{
		HWCAP dài không dấu = getauxval(AT_HWCAP);
		nếu (HWCAP & PPC_FEATURE_HAS_FPU)
			trả về đúng sự thật;

trả về sai;
	}

Khi phần mềm dựa vào tính năng được mô tả bởi HWCAP, nó sẽ kiểm tra
cờ HWCAP có liên quan để xác minh rằng tính năng này hiện diện trước khi thử
tận dụng tính năng này.

HWCAP là phương pháp ưa thích để kiểm tra sự hiện diện của một tính năng thay vì
hơn là thăm dò thông qua các phương tiện khác, có thể không đáng tin cậy hoặc có thể gây ra
hành vi không thể đoán trước.

Phần mềm nhắm tới một nền tảng cụ thể không nhất thiết phải
kiểm tra các tính năng được yêu cầu hoặc ngụ ý. Ví dụ: nếu chương trình yêu cầu
FPU, VMX, VSX thì không cần thiết phải kiểm tra các HWCAP đó và có thể
không thể làm như vậy nếu trình biên dịch tạo mã yêu cầu các tính năng đó.

2. Cơ sở vật chất
-------------

Power ISA sử dụng thuật ngữ "cơ sở" để mô tả một loại hướng dẫn,
đăng ký, ngắt, v.v. Sự hiện diện hay vắng mặt của một cơ sở cho thấy
liệu lớp này có sẵn để sử dụng hay không, nhưng các chi tiết cụ thể phụ thuộc vào
Phiên bản ISA. Ví dụ: nếu cơ sở VSX có sẵn, VSX
hướng dẫn có thể được sử dụng khác nhau giữa v3.0B và v3.1B ISA
các phiên bản.

3. Danh mục
-------------

Power ISA trước v3.0 sử dụng thuật ngữ "danh mục" để mô tả một số
các loại hướng dẫn và chế độ vận hành có thể là tùy chọn hoặc
loại trừ lẫn nhau, ý nghĩa chính xác của cờ HWCAP có thể phụ thuộc vào
ngữ cảnh, ví dụ: sự hiện diện của tính năng BOOKE ngụ ý rằng máy chủ
danh mục không được thực hiện.

4. Phân bổ HWCAP
-------------------

HWCAP được phân bổ như mô tả trong Power Architecture 64-Bit ELF V2 ABI
Thông số kỹ thuật (sẽ được phản ánh trong các tiêu đề uapi của kernel).

5. HWCAP được hiển thị trong AT_HWCAP
---------------------------------

PPC_FEATURE_32
    CPU 32-bit

PPC_FEATURE_64
    CPU 64-bit (không gian người dùng có thể chạy ở chế độ 32-bit).

PPC_FEATURE_601_INSTR
    Bộ xử lý là PowerPC 601.
    Không được sử dụng trong kernel kể từ f0ed73f3fa2c ("powerpc: Loại bỏ PowerPC 601")

PPC_FEATURE_HAS_ALTIVEC
    Cơ sở Vector (còn gọi là Altivec, VMX) có sẵn.

PPC_FEATURE_HAS_FPU
    Cơ sở điểm nổi có sẵn.

PPC_FEATURE_HAS_MMU
    Đơn vị quản lý bộ nhớ có mặt và được kích hoạt.

PPC_FEATURE_HAS_4xxMAC
    Bộ xử lý thuộc họ 40x hoặc 44x.
    Không được sử dụng trong kernel kể từ 732b32daef80 ("powerpc: Xóa hỗ trợ lõi cho 40x")

PPC_FEATURE_UNIFIED_CACHE
    Bộ xử lý có bộ đệm L1 hợp nhất cho các lệnh và dữ liệu, như
    được tìm thấy trong NXP e200.
    Không được sử dụng trong kernel kể từ 39c8bf2b3cc1 ("powerpc: Nghỉ hưu lõi e200 (bộ xử lý mpc555x)")

PPC_FEATURE_HAS_SPE
    Cơ sở Công cụ xử lý tín hiệu có sẵn.

PPC_FEATURE_HAS_EFP_SINGLE
    Có sẵn các hoạt động chính xác đơn điểm nổi nhúng.

PPC_FEATURE_HAS_EFP_DOUBLE
    Các hoạt động chính xác gấp đôi của Điểm nổi nhúng có sẵn.

PPC_FEATURE_NO_TB
    Tiện ích cơ sở thời gian (hướng dẫn mftb) không có sẵn.
    Đây là HWCAP dành riêng cho 601, vì vậy nếu biết rằng bộ xử lý
    đang chạy không phải là 601, thông qua các HWCAP khác hoặc các phương tiện khác, nó không phải là
    cần phải kiểm tra bit này trước khi sử dụng cơ sở thời gian.
    Không được sử dụng trong kernel kể từ f0ed73f3fa2c ("powerpc: Loại bỏ PowerPC 601")

PPC_FEATURE_POWER4
    Bộ xử lý là POWER4 hoặc PPC970/FX/MP.
    Hỗ trợ POWER4 bị loại bỏ khỏi kernel kể từ 471d7ff8b51b ("powerpc/64s: Xóa hỗ trợ POWER4")

PPC_FEATURE_POWER5
    Bộ xử lý là POWER5.

PPC_FEATURE_POWER5_PLUS
    Bộ xử lý là POWER5+.

PPC_FEATURE_CELL
    Bộ xử lý là Cell.

PPC_FEATURE_BOOKE
    Bộ xử lý triển khai kiến trúc danh mục nhúng ("BookE").

PPC_FEATURE_SMT
    Bộ xử lý thực hiện SMT.

PPC_FEATURE_ICACHE_SNOOP
    Icache của bộ xử lý kết hợp với dcache và việc lưu trữ lệnh
    có thể được thực hiện phù hợp với việc lưu trữ dữ liệu nhằm mục đích thực hiện
    hướng dẫn theo trình tự (như được mô tả trong, ví dụ: Bộ xử lý POWER9
    Hướng dẫn sử dụng, 4.6.2.2 Hướng dẫn Khối bộ đệm không hợp lệ (icbi))::

đồng bộ hóa
        icbi (đến bất kỳ địa chỉ nào)
        không đồng bộ

PPC_FEATURE_ARCH_2_05
    Bộ xử lý hỗ trợ kiến trúc cấp độ người dùng v2.05. Bộ xử lý
    hỗ trợ các kiến trúc sau này DO NOT thiết lập tính năng này.

PPC_FEATURE_PA6T
    Bộ xử lý là PA6T.

PPC_FEATURE_HAS_DFP
    Cơ sở DFP có sẵn.

PPC_FEATURE_POWER6_EXT
    Bộ xử lý là POWER6.

PPC_FEATURE_ARCH_2_06
    Bộ xử lý hỗ trợ kiến trúc cấp độ người dùng v2.06. Bộ xử lý
    hỗ trợ các kiến trúc sau này cũng thiết lập tính năng này.

PPC_FEATURE_HAS_VSX
    Cơ sở VSX có sẵn.

PPC_FEATURE_PSERIES_PERFMON_COMPAT
    Bộ xử lý hỗ trợ các sự kiện PMU được kiến trúc trong phạm vi 0xE0-0xFF.

PPC_FEATURE_TRUE_LE
    Bộ xử lý hỗ trợ chế độ endian nhỏ thực sự.

PPC_FEATURE_PPC_LE
    Bộ xử lý hỗ trợ "PowerPC Little-Endian", sử dụng địa chỉ
    trộn lẫn để làm cho việc truy cập vào bộ nhớ có vẻ hơi khó khăn, nhưng
    dữ liệu được lưu trữ ở một định dạng khác không phù hợp để
    được truy cập bởi các tác nhân khác không chạy trong chế độ này.

6. HWCAP được hiển thị trong AT_HWCAP2
----------------------------------

PPC_FEATURE2_ARCH_2_07
    Bộ xử lý hỗ trợ kiến trúc cấp độ người dùng v2.07. Bộ xử lý
    hỗ trợ các kiến trúc sau này cũng thiết lập tính năng này.

PPC_FEATURE2_HTM
    Tính năng Bộ nhớ giao dịch có sẵn.

PPC_FEATURE2_DSCR
    Cơ sở DSCR có sẵn.

PPC_FEATURE2_EBB
    Cơ sở EBB có sẵn.

PPC_FEATURE2_ISEL
    hướng dẫn isel có sẵn. Điều này được thay thế bởi ARCH_2_07 và
    sau này.

PPC_FEATURE2_TAR
    Cơ sở TAR có sẵn.

PPC_FEATURE2_VEC_CRYPTO
    Hướng dẫn về mật mã v2.07 có sẵn.

PPC_FEATURE2_HTM_NOSC
    Cuộc gọi hệ thống không thành công nếu được gọi ở trạng thái giao dịch, xem
    Tài liệu/arch/powerpc/syscall64-abi.rst

PPC_FEATURE2_ARCH_3_00
    Bộ xử lý hỗ trợ kiến trúc cấp độ người dùng v3.0B / v3.0C. Bộ xử lý
    hỗ trợ các kiến trúc sau này cũng thiết lập tính năng này.

PPC_FEATURE2_HAS_IEEE128
    IEEE Điểm nổi nhị phân 128 bit được hỗ trợ với VSX
    các hướng dẫn và kiểu dữ liệu có độ chính xác gấp bốn lần.

PPC_FEATURE2_DARN
    hướng dẫn chết tiệt có sẵn.

PPC_FEATURE2_SCV
    Lệnh scv 0 có thể được sử dụng cho các cuộc gọi hệ thống, xem
    Tài liệu/arch/powerpc/syscall64-abi.rst.

PPC_FEATURE2_HTM_NO_SUSPEND
    Cơ sở Bộ nhớ giao dịch hạn chế không hỗ trợ tạm dừng là
    có sẵn, hãy xem Tài liệu/arch/powerpc/transactional_memory.rst.

PPC_FEATURE2_ARCH_3_1
    Bộ xử lý hỗ trợ kiến trúc cấp độ người dùng v3.1. Bộ xử lý
    hỗ trợ các kiến trúc sau này cũng thiết lập tính năng này.

PPC_FEATURE2_MMA
    Cơ sở MMA có sẵn.
