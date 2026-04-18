.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm64/elf_hwcaps.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _elf_hwcaps_index:

==================
ARM64 ELF hwcaps
==================

Tài liệu này mô tả cách sử dụng và ngữ nghĩa của hwcaps arm64 ELF.


1. Giới thiệu
---------------

Một số tính năng phần cứng hoặc phần mềm chỉ có trên một số CPU
triển khai và/hoặc với các cấu hình kernel nhất định, nhưng không có
cơ chế khám phá được kiến trúc sẵn có cho mã không gian người dùng tại EL0. các
kernel hiển thị sự hiện diện của các tính năng này cho không gian người dùng thông qua một tập hợp
của các cờ được gọi là hwcaps, hiển thị trong vectơ phụ trợ.

Phần mềm không gian người dùng có thể kiểm tra các tính năng bằng cách mua AT_HWCAP,
Mục nhập AT_HWCAP2 hoặc AT_HWCAP3 của vectơ phụ và thử nghiệm
liệu các cờ liên quan có được đặt hay không, ví dụ::

bool float_point_is_hiện tại (void)
	{
		hwcaps dài không dấu = getauxval(AT_HWCAP);
		nếu (hwcaps & HWCAP_FP)
			trả về đúng sự thật;

trả về sai;
	}

Khi phần mềm dựa vào một tính năng được mô tả bởi hwcap, phần mềm đó phải kiểm tra
cờ hwcap có liên quan để xác minh rằng tính năng này có mặt trước đó
đang cố gắng sử dụng tính năng này.

Các tính năng không thể được thăm dò một cách đáng tin cậy thông qua các phương tiện khác. Khi một tính năng
không có sẵn, cố gắng sử dụng nó có thể dẫn đến kết quả không thể đoán trước
hành vi và không được đảm bảo sẽ dẫn đến bất kỳ dấu hiệu đáng tin cậy nào
rằng tính năng này không khả dụng, chẳng hạn như SIGILL.


2. Giải thích hwcaps
---------------------------

Phần lớn các hwcap nhằm mục đích chỉ ra sự hiện diện của các tính năng
được mô tả bởi các thanh ghi ID được thiết kế không thể truy cập được
mã không gian người dùng tại EL0. Những hwcap này được xác định theo thanh ghi ID
các trường và nên được giải thích bằng cách tham chiếu đến định nghĩa của
các trường này trong Sách hướng dẫn tham khảo kiến trúc ARM (ARM ARM).

Những hwcap như vậy được mô tả bên dưới dưới dạng::

Chức năng được ngụ ý bởi idreg.field == val.

Những hwcap như vậy cho biết tính khả dụng của chức năng mà ARM ARM
định nghĩa là hiện diện khi idreg.field có giá trị val, nhưng không
chỉ ra rằng idreg.field chính xác bằng val, chúng cũng không
chỉ ra sự vắng mặt của chức năng ngụ ý bởi các giá trị khác của
idreg.field.

Các hwcap khác có thể chỉ ra sự hiện diện của các tính năng không thể
được mô tả chỉ bởi các thanh ghi ID. Những điều này có thể được mô tả mà không cần
tham chiếu đến sổ đăng ký ID và có thể tham khảo các tài liệu khác.


3. Các hwcap được hiển thị trong AT_HWCAP
---------------------------------

HWCAP_FP
    Chức năng được ngụ ý bởi ID_AA64PFR0_EL1.FP == 0b0000.

HWCAP_ASIMD
    Chức năng được ngụ ý bởi ID_AA64PFR0_EL1.AdvSIMD == 0b0000.

HWCAP_EVTSTRM
    Bộ hẹn giờ chung được cấu hình để tạo ra các sự kiện với tần suất
    khoảng 10KHz.

HWCAP_AES
    Chức năng được ngụ ý bởi ID_AA64ISAR0_EL1.AES == 0b0001.

HWCAP_PMULL
    Chức năng được ngụ ý bởi ID_AA64ISAR0_EL1.AES == 0b0010.

HWCAP_SHA1
    Chức năng được ngụ ý bởi ID_AA64ISAR0_EL1.SHA1 == 0b0001.

HWCAP_SHA2
    Chức năng được ngụ ý bởi ID_AA64ISAR0_EL1.SHA2 == 0b0001.

HWCAP_CRC32
    Chức năng được ngụ ý bởi ID_AA64ISAR0_EL1.CRC32 == 0b0001.

HWCAP_ATOMICS
    Chức năng được ngụ ý bởi ID_AA64ISAR0_EL1.Atomic == 0b0010.

HWCAP_FPHP
    Chức năng được ngụ ý bởi ID_AA64PFR0_EL1.FP == 0b0001.

HWCAP_ASIMDHP
    Chức năng được ngụ ý bởi ID_AA64PFR0_EL1.AdvSIMD == 0b0001.

HWCAP_CPUID
    Có sẵn quyền truy cập EL0 vào một số thanh ghi ID nhất định, trong phạm vi
    được mô tả bởi Documentation/arch/arm64/cpu-feature-registers.rst.

Các thanh ghi ID này có thể ngụ ý tính khả dụng của các tính năng.

HWCAP_ASIMDRDM
    Chức năng được ngụ ý bởi ID_AA64ISAR0_EL1.RDM == 0b0001.

HWCAP_JSCVT
    Chức năng được ngụ ý bởi ID_AA64ISAR1_EL1.JSCVT == 0b0001.

HWCAP_FCMA
    Chức năng được ngụ ý bởi ID_AA64ISAR1_EL1.FCMA == 0b0001.

HWCAP_LRCPC
    Chức năng được ngụ ý bởi ID_AA64ISAR1_EL1.LRCPC == 0b0001.

HWCAP_DCPOP
    Chức năng được ngụ ý bởi ID_AA64ISAR1_EL1.DPB == 0b0001.

HWCAP_SHA3
    Chức năng được ngụ ý bởi ID_AA64ISAR0_EL1.SHA3 == 0b0001.

HWCAP_SM3
    Chức năng được ngụ ý bởi ID_AA64ISAR0_EL1.SM3 == 0b0001.

HWCAP_SM4
    Chức năng được ngụ ý bởi ID_AA64ISAR0_EL1.SM4 == 0b0001.

HWCAP_ASIMDDP
    Chức năng được ngụ ý bởi ID_AA64ISAR0_EL1.DP == 0b0001.

HWCAP_SHA512
    Chức năng được ngụ ý bởi ID_AA64ISAR0_EL1.SHA2 == 0b0010.

HWCAP_SVE
    Chức năng được ngụ ý bởi ID_AA64PFR0_EL1.SVE == 0b0001.

HWCAP_ASIMDFHM
   Chức năng được ngụ ý bởi ID_AA64ISAR0_EL1.FHM == 0b0001.

HWCAP_DIT
    Chức năng được ngụ ý bởi ID_AA64PFR0_EL1.DIT == 0b0001.

HWCAP_USCAT
    Chức năng được ngụ ý bởi ID_AA64MMFR2_EL1.AT == 0b0001.

HWCAP_ILRCPC
    Chức năng được ngụ ý bởi ID_AA64ISAR1_EL1.LRCPC == 0b0010.

HWCAP_FLAGM
    Chức năng được ngụ ý bởi ID_AA64ISAR0_EL1.TS == 0b0001.

HWCAP_SSBS
    Chức năng được ngụ ý bởi ID_AA64PFR1_EL1.SSBS == 0b0010.

HWCAP_SB
    Chức năng được ngụ ý bởi ID_AA64ISAR1_EL1.SB == 0b0001.

HWCAP_PACA
    Chức năng được ngụ ý bởi ID_AA64ISAR1_EL1.APA == 0b0001 hoặc
    ID_AA64ISAR1_EL1.API == 0b0001, như được mô tả bởi
    Tài liệu/arch/arm64/pointer-authentication.rst.

HWCAP_PACG
    Chức năng được ngụ ý bởi ID_AA64ISAR1_EL1.GPA == 0b0001 hoặc
    ID_AA64ISAR1_EL1.GPI == 0b0001, như được mô tả bởi
    Tài liệu/arch/arm64/pointer-authentication.rst.

HWCAP_GCS
    Chức năng được ngụ ý bởi ID_AA64PFR1_EL1.GCS == 0b1, như
    được mô tả bởi Documentation/arch/arm64/gcs.rst.

HWCAP_CMPBR
    Chức năng được ngụ ý bởi ID_AA64ISAR2_EL1.CSSC == 0b0010.

HWCAP_FPRCVT
    Chức năng được ngụ ý bởi ID_AA64ISAR3_EL1.FPRCVT == 0b0001.

HWCAP_F8MM8
    Chức năng được ngụ ý bởi ID_AA64FPFR0_EL1.F8MM8 == 0b0001.

HWCAP_F8MM4
    Chức năng được ngụ ý bởi ID_AA64FPFR0_EL1.F8MM4 == 0b0001.

HWCAP_SVE_F16MM
    Chức năng được ngụ ý bởi ID_AA64PFR0_EL1.SVE == 0b0001 và
    ID_AA64ZFR0_EL1.F16MM == 0b0001.

HWCAP_SVE_ELTPERM
    Chức năng được ngụ ý bởi ID_AA64PFR0_EL1.SVE == 0b0001 và
    ID_AA64ZFR0_EL1.ELTPERM == 0b0001.

HWCAP_SVE_AES2
    Chức năng được ngụ ý bởi ID_AA64PFR0_EL1.SVE == 0b0001 và
    ID_AA64ZFR0_EL1.AES == 0b0011.

HWCAP_SVE_BFSCALE
    Chức năng được ngụ ý bởi ID_AA64PFR0_EL1.SVE == 0b0001 và
    ID_AA64ZFR0_EL1.B16B16 == 0b0010.

HWCAP_SVE2P2
    Chức năng được ngụ ý bởi ID_AA64PFR0_EL1.SVE == 0b0001 và
    ID_AA64ZFR0_EL1.SVEver == 0b0011.

HWCAP_SME2P2
    Chức năng được ngụ ý bởi ID_AA64SMFR0_EL1.SMever == 0b0011.

HWCAP_SME_SBITPERM
    Chức năng được ngụ ý bởi ID_AA64SMFR0_EL1.SBitPerm == 0b1.

HWCAP_SME_AES
    Chức năng được ngụ ý bởi ID_AA64SMFR0_EL1.AES == 0b1.

HWCAP_SME_SFEXPA
    Chức năng được ngụ ý bởi ID_AA64SMFR0_EL1.SFEXPA == 0b1.

HWCAP_SME_STMOP
    Chức năng được ngụ ý bởi ID_AA64SMFR0_EL1.STMOP == 0b1.

HWCAP_SME_SMOP4
    Chức năng được ngụ ý bởi ID_AA64SMFR0_EL1.SMOP4 == 0b1.

HWCAP2_DCPODP
    Chức năng được ngụ ý bởi ID_AA64ISAR1_EL1.DPB == 0b0010.

HWCAP2_SVE2
    Chức năng được ngụ ý bởi ID_AA64PFR0_EL1.SVE == 0b0001 và
    ID_AA64ZFR0_EL1.SVEver == 0b0001.

HWCAP2_SVEAES
    Chức năng được ngụ ý bởi ID_AA64PFR0_EL1.SVE == 0b0001 và
    ID_AA64ZFR0_EL1.AES == 0b0001.

HWCAP2_SVEPMULL
    Chức năng được ngụ ý bởi ID_AA64PFR0_EL1.SVE == 0b0001 và
    ID_AA64ZFR0_EL1.AES == 0b0010.

HWCAP2_SVEBITPERM
    Chức năng được ngụ ý bởi ID_AA64PFR0_EL1.SVE == 0b0001 và
    ID_AA64ZFR0_EL1.BitPerm == 0b0001.

HWCAP2_SVESHA3
    Chức năng được ngụ ý bởi ID_AA64PFR0_EL1.SVE == 0b0001 và
    ID_AA64ZFR0_EL1.SHA3 == 0b0001.

HWCAP2_SVESM4
    Chức năng được ngụ ý bởi ID_AA64PFR0_EL1.SVE == 0b0001 và
    ID_AA64ZFR0_EL1.SM4 == 0b0001.

HWCAP2_FLAGM2
    Chức năng được ngụ ý bởi ID_AA64ISAR0_EL1.TS == 0b0010.

HWCAP2_FRINT
    Chức năng được ngụ ý bởi ID_AA64ISAR1_EL1.FRINTTS == 0b0001.

HWCAP2_SVEI8MM
    Chức năng được ngụ ý bởi ID_AA64PFR0_EL1.SVE == 0b0001 và
    ID_AA64ZFR0_EL1.I8MM == 0b0001.

HWCAP2_SVEF32MM
    Chức năng được ngụ ý bởi ID_AA64PFR0_EL1.SVE == 0b0001 và
    ID_AA64ZFR0_EL1.F32MM == 0b0001.

HWCAP2_SVEF64MM
    Chức năng được ngụ ý bởi ID_AA64PFR0_EL1.SVE == 0b0001 và
    ID_AA64ZFR0_EL1.F64MM == 0b0001.

HWCAP2_SVEBF16
    Chức năng được ngụ ý bởi ID_AA64PFR0_EL1.SVE == 0b0001 và
    ID_AA64ZFR0_EL1.BF16 == 0b0001.

HWCAP2_I8MM
    Chức năng được ngụ ý bởi ID_AA64ISAR1_EL1.I8MM == 0b0001.

HWCAP2_BF16
    Chức năng được ngụ ý bởi ID_AA64ISAR1_EL1.BF16 == 0b0001.

HWCAP2_DGH
    Chức năng được ngụ ý bởi ID_AA64ISAR1_EL1.DGH == 0b0001.

HWCAP2_RNG
    Chức năng được ngụ ý bởi ID_AA64ISAR0_EL1.RNDR == 0b0001.

HWCAP2_BTI
    Chức năng được ngụ ý bởi ID_AA64PFR1_EL1.BT == 0b0001.

HWCAP2_MTE
    Chức năng được ngụ ý bởi ID_AA64PFR1_EL1.MTE == 0b0010, như được mô tả
    bởi Documentation/arch/arm64/memory-tagging-extension.rst.

HWCAP2_ECV
    Chức năng được ngụ ý bởi ID_AA64MMFR0_EL1.ECV == 0b0001.

HWCAP2_AFP
    Chức năng được ngụ ý bởi ID_AA64MMFR1_EL1.AFP == 0b0001.

HWCAP2_RPRES
    Chức năng được ngụ ý bởi ID_AA64ISAR2_EL1.RPRES == 0b0001.

HWCAP2_MTE3
    Chức năng được ngụ ý bởi ID_AA64PFR1_EL1.MTE == 0b0011, như được mô tả
    bởi Documentation/arch/arm64/memory-tagging-extension.rst.

HWCAP2_SME
    Chức năng được ngụ ý bởi ID_AA64PFR1_EL1.SME == 0b0001, như được mô tả
    bởi Documentation/arch/arm64/sme.rst.

HWCAP2_SME_I16I64
    Chức năng được ngụ ý bởi ID_AA64SMFR0_EL1.I16I64 == 0b1111.

HWCAP2_SME_F64F64
    Chức năng được ngụ ý bởi ID_AA64SMFR0_EL1.F64F64 == 0b1.

HWCAP2_SME_I8I32
    Chức năng được ngụ ý bởi ID_AA64SMFR0_EL1.I8I32 == 0b1111.

HWCAP2_SME_F16F32
    Chức năng được ngụ ý bởi ID_AA64SMFR0_EL1.F16F32 == 0b1.

HWCAP2_SME_B16F32
    Chức năng được ngụ ý bởi ID_AA64SMFR0_EL1.B16F32 == 0b1.

HWCAP2_SME_F32F32
    Chức năng được ngụ ý bởi ID_AA64SMFR0_EL1.F32F32 == 0b1.

HWCAP2_SME_FA64
    Chức năng được ngụ ý bởi ID_AA64SMFR0_EL1.FA64 == 0b1.

HWCAP2_WFXT
    Chức năng được ngụ ý bởi ID_AA64ISAR2_EL1.WFXT == 0b0010.

HWCAP2_EBF16
    Chức năng được ngụ ý bởi ID_AA64ISAR1_EL1.BF16 == 0b0010.

HWCAP2_SVE_EBF16
    Chức năng được ngụ ý bởi ID_AA64PFR0_EL1.SVE == 0b0001 và
    ID_AA64ZFR0_EL1.BF16 == 0b0010.

HWCAP2_CSSC
    Chức năng được ngụ ý bởi ID_AA64ISAR2_EL1.CSSC == 0b0001.

HWCAP2_RPRFM
    Chức năng được ngụ ý bởi ID_AA64ISAR2_EL1.RPRFM == 0b0001.

HWCAP2_SVE2P1
    Chức năng được ngụ ý bởi ID_AA64PFR0_EL1.SVE == 0b0001 và
    ID_AA64ZFR0_EL1.SVEver == 0b0010.

HWCAP2_SME2
    Chức năng được ngụ ý bởi ID_AA64SMFR0_EL1.SMever == 0b0001.

HWCAP2_SME2P1
    Chức năng được ngụ ý bởi ID_AA64SMFR0_EL1.SMever == 0b0010.

HWCAP2_SMEI16I32
    Chức năng được ngụ ý bởi ID_AA64SMFR0_EL1.I16I32 == 0b0101

HWCAP2_SMEBI32I32
    Chức năng được ngụ ý bởi ID_AA64SMFR0_EL1.BI32I32 == 0b1

HWCAP2_SMEB16B16
    Chức năng được ngụ ý bởi ID_AA64SMFR0_EL1.B16B16 == 0b1

HWCAP2_SMEF16F16
    Chức năng được ngụ ý bởi ID_AA64SMFR0_EL1.F16F16 == 0b1

HWCAP2_MOPS
    Chức năng được ngụ ý bởi ID_AA64ISAR2_EL1.MOPS == 0b0001.

HWCAP2_HBC
    Chức năng được ngụ ý bởi ID_AA64ISAR2_EL1.BC == 0b0001.

HWCAP2_SVE_B16B16
    Chức năng được ngụ ý bởi ID_AA64PFR0_EL1.SVE == 0b0001 và
    ID_AA64ZFR0_EL1.B16B16 == 0b0001.

HWCAP2_LRCPC3
    Chức năng được ngụ ý bởi ID_AA64ISAR1_EL1.LRCPC == 0b0011.

HWCAP2_LSE128
    Chức năng được ngụ ý bởi ID_AA64ISAR0_EL1.Atomic == 0b0011.

HWCAP2_FPMR
    Chức năng được ngụ ý bởi ID_AA64PFR2_EL1.FMR == 0b0001.

HWCAP2_LUT
    Chức năng được ngụ ý bởi ID_AA64ISAR2_EL1.LUT == 0b0001.

HWCAP2_FAMINMAX
    Chức năng được ngụ ý bởi ID_AA64ISAR3_EL1.FAMINMAX == 0b0001.

HWCAP2_F8CVT
    Chức năng được ngụ ý bởi ID_AA64FPFR0_EL1.F8CVT == 0b1.

HWCAP2_F8FMA
    Chức năng được ngụ ý bởi ID_AA64FPFR0_EL1.F8FMA == 0b1.

HWCAP2_F8DP4
    Chức năng được ngụ ý bởi ID_AA64FPFR0_EL1.F8DP4 == 0b1.

HWCAP2_F8DP2
    Chức năng được ngụ ý bởi ID_AA64FPFR0_EL1.F8DP2 == 0b1.

HWCAP2_F8E4M3
    Chức năng được ngụ ý bởi ID_AA64FPFR0_EL1.F8E4M3 == 0b1.

HWCAP2_F8E5M2
    Chức năng được ngụ ý bởi ID_AA64FPFR0_EL1.F8E5M2 == 0b1.

HWCAP2_SME_LUTV2
    Chức năng được ngụ ý bởi ID_AA64SMFR0_EL1.LUTv2 == 0b1.

HWCAP2_SME_F8F16
    Chức năng được ngụ ý bởi ID_AA64SMFR0_EL1.F8F16 == 0b1.

HWCAP2_SME_F8F32
    Chức năng được ngụ ý bởi ID_AA64SMFR0_EL1.F8F32 == 0b1.

HWCAP2_SME_SF8FMA
    Chức năng được ngụ ý bởi ID_AA64SMFR0_EL1.SF8FMA == 0b1.

HWCAP2_SME_SF8DP4
    Chức năng được ngụ ý bởi ID_AA64SMFR0_EL1.SF8DP4 == 0b1.

HWCAP2_SME_SF8DP2
    Chức năng được ngụ ý bởi ID_AA64SMFR0_EL1.SF8DP2 == 0b1.

HWCAP2_SME_SF8DP4
    Chức năng được ngụ ý bởi ID_AA64SMFR0_EL1.SF8DP4 == 0b1.

HWCAP2_POE
    Chức năng được ngụ ý bởi ID_AA64MMFR3_EL1.S1POE == 0b0001.

HWCAP3_MTE_FAR
    Chức năng được ngụ ý bởi ID_AA64PFR2_EL1.MTEFAR == 0b0001.

HWCAP3_MTE_STORE_ONLY
    Chức năng được ngụ ý bởi ID_AA64PFR2_EL1.MTESTOREONLY == 0b0001.

HWCAP3_LSFE
    Chức năng được ngụ ý bởi ID_AA64ISAR3_EL1.LSFE == 0b0001

HWCAP3_LS64
    Chức năng được ngụ ý bởi ID_AA64ISAR1_EL1.LS64 == 0b0001. Lưu ý rằng
    chức năng của lệnh ld64b/st64b yêu cầu sự hỗ trợ của CPU, hệ thống
    và vị trí bộ nhớ đích (thiết bị) và HWCAP3_LS64 ngụ ý sự hỗ trợ
    của CPU. Người dùng chỉ nên sử dụng ld64b/st64b trên mục tiêu (thiết bị) được hỗ trợ
    vị trí bộ nhớ, nếu không thì dự phòng cho các lựa chọn thay thế phi nguyên tử.


4. Các bit AT_HWCAP chưa sử dụng
-----------------------

Để tương tác với không gian người dùng, kernel đảm bảo rằng các bit 62
và 63 của AT_HWCAP sẽ luôn được trả về là 0.
