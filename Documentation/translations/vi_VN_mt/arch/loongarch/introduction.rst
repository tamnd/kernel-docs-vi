.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/loongarch/introduction.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Giới thiệu về LoongArch
=========================

LoongArch là RISC ISA mới, hơi giống MIPS hoặc RISC-V. có
hiện có 3 biến thể: phiên bản 32 bit rút gọn (LA32R), phiên bản 32 bit tiêu chuẩn
phiên bản (LA32S) và phiên bản 64-bit (LA64). Có 4 cấp độ đặc quyền
(PLV) được xác định trong LoongArch: PLV0~PLV3, từ cao đến thấp. Hạt nhân chạy ở PLV0
trong khi các ứng dụng chạy ở PLV3. Tài liệu này giới thiệu các thanh ghi, cơ bản
tập lệnh, bộ nhớ ảo và một số chủ đề khác của LoongArch.

Đăng ký
=========

Các thanh ghi LoongArch bao gồm các thanh ghi mục đích chung (GPR), dấu phẩy động
thanh ghi (FPR), thanh ghi vectơ (VR) và thanh ghi trạng thái điều khiển (CSR)
được sử dụng ở chế độ đặc quyền (PLV0).

GPR
----

LoongArch có 32 GPR ( ZZ0000ZZ ~ ZZ0001ZZ ); mỗi cái rộng 32 bit trong LA32
và rộng 64-bit trong LA64. ZZ0002ZZ được nối cứng về 0 và các thanh ghi khác
không có kiến trúc đặc biệt. (Ngoại trừ ZZ0003ZZ, có dây cứng như
thanh ghi liên kết của lệnh BL.)

Hạt nhân sử dụng một biến thể của quy ước đăng ký LoongArch, như được mô tả trong
thông số psABI của LoongArch ELF, trong ZZ0000ZZ:

===================================================== =============
Tên Bí danh Cách sử dụng Giữ nguyên
                                                      qua các cuộc gọi
===================================================== =============
ZZ0000ZZ ZZ0001ZZ Hằng số 0 Chưa sử dụng
ZZ0002ZZ ZZ0003ZZ Địa chỉ trả lại Không
ZZ0004ZZ ZZ0005ZZ TLS/Con trỏ luồng Không sử dụng
ZZ0006ZZ ZZ0007ZZ Con trỏ ngăn xếp Có
ZZ0008ZZ-ZZ0009ZZ ZZ0010ZZ-ZZ0011ZZ Thanh ghi đối số Không
ZZ0012ZZ-ZZ0013ZZ ZZ0014ZZ-ZZ0015ZZ Giá trị trả về Không
ZZ0016ZZ-ZZ0017ZZ ZZ0018ZZ-ZZ0019ZZ Thanh ghi nhiệt độ Không
ZZ0020ZZ ZZ0021ZZ Địa chỉ cơ sở Percpu Không được sử dụng
ZZ0022ZZ ZZ0023ZZ Con trỏ khung Có
ZZ0024ZZ-ZZ0025ZZ ZZ0026ZZ-ZZ0027ZZ Thanh ghi tĩnh Có
===================================================== =============

.. Note::
    The register ``$r21`` is reserved in the ELF psABI, but used by the Linux
    kernel for storing the percpu base address. It normally has no ABI name,
    but is called ``$u0`` in the kernel. You may also see ``$v0`` or ``$v1``
    in some old code,however they are deprecated aliases of ``$a0`` and ``$a1``
    respectively.

FPR
----

LoongArch có 32 FPR ( ZZ0000ZZ ~ ZZ0001ZZ ) khi có FPU. Mỗi người là
Độ rộng 64-bit trên lõi LA64.

Quy ước đăng ký dấu phẩy động giống như được mô tả trong
Thông số LoongArch ELF psABI:

========================================================= ==============
Tên Bí danh Cách sử dụng Giữ nguyên
                                                         qua các cuộc gọi
========================================================= ==============
ZZ0000ZZ-ZZ0001ZZ ZZ0002ZZ-ZZ0003ZZ Thanh ghi đối số Không
ZZ0004ZZ-ZZ0005ZZ ZZ0006ZZ-ZZ0007ZZ Giá trị trả về Không
ZZ0008ZZ-ZZ0009ZZ ZZ0010ZZ-ZZ0011ZZ Thanh ghi nhiệt độ Không
ZZ0012ZZ-ZZ0013ZZ ZZ0014ZZ-ZZ0015ZZ Thanh ghi tĩnh Có
========================================================= ==============

.. Note::
    You may see ``$fv0`` or ``$fv1`` in some old code, however they are
    deprecated aliases of ``$fa0`` and ``$fa1`` respectively.

VR
----

Hiện tại có 2 phần mở rộng vector cho LoongArch:

- LSX (Loongson SIMD eXtension) với vectơ 128-bit,
- LASX (Loongson Advanced SIMD eXtension) với vectơ 256-bit.

LSX mang ZZ0000ZZ ~ ZZ0001ZZ trong khi LASX mang ZZ0002ZZ ~ ZZ0003ZZ làm vectơ
sổ đăng ký.

Các VR trùng lặp với FPR: ví dụ: trên lõi triển khai LSX và LASX,
128 bit thấp hơn của ZZ0000ZZ được chia sẻ với ZZ0001ZZ và 64 bit thấp hơn của
ZZ0002ZZ được chia sẻ với ZZ0003ZZ; tương tự với tất cả các VR khác.

CSR
----

CSR chỉ có thể được truy cập từ chế độ đặc quyền (PLV0):

================= ===================================== ==============
Address           Full Name                             Abbrev Name
================= ===================================== ==============
0x0               Current Mode Information              CRMD
0x1               Pre-exception Mode Information        PRMD
0x2               Extension Unit Enable                 EUEN
0x3               Miscellaneous Control                 MISC
0x4               Exception Configuration               ECFG
0x5               Exception Status                      ESTAT
0x6               Exception Return Address              ERA
0x7               Bad (Faulting) Virtual Address        BADV
0x8               Bad (Faulting) Instruction Word       BADI
0xC               Exception Entrypoint Address          EENTRY
0x10              TLB Index                             TLBIDX
0x11              TLB Entry High-order Bits             TLBEHI
0x12              TLB Entry Low-order Bits 0            TLBELO0
0x13              TLB Entry Low-order Bits 1            TLBELO1
0x18              Address Space Identifier              ASID
0x19              Page Global Directory Address for     PGDL
                  Lower-half Address Space
0x1A              Page Global Directory Address for     PGDH
                  Higher-half Address Space
0x1B              Page Global Directory Address         PGD
0x1C              Page Walk Control for Lower-          PWCL
                  half Address Space
0x1D              Page Walk Control for Higher-         PWCH
                  half Address Space
0x1E              STLB Page Size                        STLBPS
0x1F              Reduced Virtual Address Configuration RVACFG
0x20              CPU Identifier                        CPUID
0x21              Privileged Resource Configuration 1   PRCFG1
0x22              Privileged Resource Configuration 2   PRCFG2
0x23              Privileged Resource Configuration 3   PRCFG3
0x30+n (0≤n≤15)   Saved Data register                   SAVEn
0x40              Timer Identifier                      TID
0x41              Timer Configuration                   TCFG
0x42              Timer Value                           TVAL
0x43              Compensation of Timer Count           CNTC
0x44              Timer Interrupt Clearing              TICLR
0x60              LLBit Control                         LLBCTL
0x80              Implementation-specific Control 1     IMPCTL1
0x81              Implementation-specific Control 2     IMPCTL2
0x88              TLB Refill Exception Entrypoint       TLBRENTRY
                  Address
0x89              TLB Refill Exception BAD (Faulting)   TLBRBADV
                  Virtual Address
0x8A              TLB Refill Exception Return Address   TLBRERA
0x8B              TLB Refill Exception Saved Data       TLBRSAVE
                  Register
0x8C              TLB Refill Exception Entry Low-order  TLBRELO0
                  Bits 0
0x8D              TLB Refill Exception Entry Low-order  TLBRELO1
                  Bits 1
0x8E              TLB Refill Exception Entry High-order TLBEHI
                  Bits
0x8F              TLB Refill Exception Pre-exception    TLBRPRMD
                  Mode Information
0x90              Machine Error Control                 MERRCTL
0x91              Machine Error Information 1           MERRINFO1
0x92              Machine Error Information 2           MERRINFO2
0x93              Machine Error Exception Entrypoint    MERRENTRY
                  Address
0x94              Machine Error Exception Return        MERRERA
                  Address
0x95              Machine Error Exception Saved Data    MERRSAVE
                  Register
0x98              Cache TAGs                            CTAG
0x180+n (0≤n≤3)   Direct Mapping Configuration Window n DMWn
0x200+2n (0≤n≤31) Performance Monitor Configuration n   PMCFGn
0x201+2n (0≤n≤31) Performance Monitor Overall Counter n PMCNTn
0x300             Memory Load/Store WatchPoint          MWPC
                  Overall Control
0x301             Memory Load/Store WatchPoint          MWPS
                  Overall Status
0x310+8n (0≤n≤7)  Memory Load/Store WatchPoint n        MWPnCFG1
                  Configuration 1
0x311+8n (0≤n≤7)  Memory Load/Store WatchPoint n        MWPnCFG2
                  Configuration 2
0x312+8n (0≤n≤7)  Memory Load/Store WatchPoint n        MWPnCFG3
                  Configuration 3
0x313+8n (0≤n≤7)  Memory Load/Store WatchPoint n        MWPnCFG4
                  Configuration 4
0x380             Instruction Fetch WatchPoint          FWPC
                  Overall Control
0x381             Instruction Fetch WatchPoint          FWPS
                  Overall Status
0x390+8n (0≤n≤7)  Instruction Fetch WatchPoint n        FWPnCFG1
                  Configuration 1
0x391+8n (0≤n≤7)  Instruction Fetch WatchPoint n        FWPnCFG2
                  Configuration 2
0x392+8n (0≤n≤7)  Instruction Fetch WatchPoint n        FWPnCFG3
                  Configuration 3
0x393+8n (0≤n≤7)  Instruction Fetch WatchPoint n        FWPnCFG4
                  Configuration 4
0x500             Debug Register                        DBG
0x501             Debug Exception Return Address        DERA
0x502             Debug Exception Saved Data Register   DSAVE
================= ===================================== ==============

ERA, TLBRERA, MERRERA và DERA đôi khi còn được gọi là EPC, TLBREPC, MERREPC
và DEPC tương ứng.

Bộ hướng dẫn cơ bản
=====================

Định dạng hướng dẫn
-------------------

Lệnh LoongArch rộng 32 bit, thuộc 9 lệnh cơ bản
định dạng (và các biến thể của chúng):

=========== =============================
Tên định dạng Thành phần
=========== =============================
Mã hoạt động 2R + Rj + Rd
Mã hoạt động 3R + Rk + Rj + Rd
Mã hoạt động 4R + Ra + Rk + Rj + Rd
Mã hoạt động 2RI8 + I8 + Rj + Rd
Mã hoạt động 2RI12 + I12 + Rj + Rd
Mã hoạt động 2RI14 + I14 + Rj + Rd
Mã hoạt động 2RI16 + I16 + Rj + Rd
1RI21 Mã sản phẩm + I21L + Rj + I21H
Mã sản phẩm I26 + I26L + I26H
=========== =============================

Rd là toán hạng thanh ghi đích, trong khi Rj, Rk và Ra ("a" là viết tắt của
"bổ sung") là toán hạng thanh ghi nguồn. I8/I12/I14/I16/I21/I26 là
toán hạng ngay lập tức có chiều rộng tương ứng. I21 và I26 được lưu trữ càng lâu
phân biệt phần trên và phần dưới trong từ lệnh, ký hiệu là chữ “L”
và hậu tố "H".

Danh sách hướng dẫn
--------------------

Để ngắn gọn, chỉ có tên lệnh (ghi nhớ) được liệt kê ở đây; xin vui lòng xem
ZZ0000ZZ để biết chi tiết.


1. Hướng dẫn tính toán::

ADD.W SUB.W ADDI.W ADD.D SUB.D ADDI.D
    SLT SLTU SLTI SLTUI
    AND HOẶC NOR XOR ANDN ORN ANDI ORI XORI
    MUL.W MULH.W MULH.WU DIV.W DIV.WU MOD.W MOD.WU
    MUL.D MULH.D MULH.DU DIV.D DIV.DU MOD.D MOD.DU
    PCADDI PCADDU12I PCADDU18I
    LU12I.W LU32I.D LU52I.D ADDU16I.D

2. Hướng dẫn dịch chuyển bit::

SLL.W SRL.W SRA.W ROTR.W SLLI.W SRLI.W SRAI.W ROTRI.W
    SLL.D SRL.D SRA.D ROTR.D SLLI.D SRLI.D SRAI.D ROTRI.D

3. Hướng dẫn thao tác bit::

EXT.W.B EXT.W.H CLO.W CLO.D SLZ.W CLZ.D CTO.W CTO.D CTZ.W CTZ.D
    BYTEPICK.W BYTEPICK.D BSTRINS.W BSTRINS.D BSTRPICK.W BSTRPICK.D
    REVB.2H REVB.4H REVB.2W REVB.D REVH.2W REVH.D BITREV.4B BITREV.8B BITREV.W BITREV.D
    MASKEQZ MASKNEZ

4. Hướng dẫn chi nhánh::

BEQ BNE BLT BGE BLTU BGEU BEQZ BNEZ B BL JIRL

5. Hướng dẫn tải/lưu trữ::

LD.B LD.BU LD.H LD.HU LD.W LD.WU LD.D ST.B ST.H ST.W ST.D
    LDX.B LDX.BU LDX.H LDX.HU LDX.W LDX.WU LDX.D STX.B STX.H STX.W STX.D
    LDPTR.W LDPTR.D STPTR.W STPTR.D
    PRELD PRELDX

6. Hướng dẫn vận hành nguyên tử::

LL.W SC.W LL.D SC.D
    AMSWAP.W AMSWAP.D AMADD.W AMADD.D AMAND.W AMAND.D AMOR.W AMOR.D AMXOR.W AMXOR.D
    AMMAX.W AMMAX.D AMMIN.W AMMIN.D

7. Hướng dẫn rào cản::

IBAR DBAR

8. Hướng dẫn đặc biệt::

SYSCALL BREAK CPUCFG NOP IDLE ERTN(ERET) DBCL(DBGCALL) RDTIMEL.W RDTIMEH.W RDTIME.D
    ASRTLE.D ASRTGT.D

9. Hướng dẫn đặc quyền::

CSRRD CSRWR CSRXCHG
    IOCSRRD.B IOCSRRD.H IOCSRRD.W IOCSRRD.D IOCSRWR.B IOCSRWR.H IOCSRWR.W IOCSRWR.D
    CACOP TLBP(TLBSRCH) TLBRD TLBWR TLBFILL TLBCLR TLBFLUSH INVTLB LDDIR LDPTE

Bộ nhớ ảo
==============

LoongArch hỗ trợ bộ nhớ ảo được ánh xạ trực tiếp và bộ nhớ ảo được ánh xạ trang.

Bộ nhớ ảo được ánh xạ trực tiếp được cấu hình bởi CSR.DMWn (n=0~3), nó có cấu hình đơn giản
mối quan hệ giữa địa chỉ ảo (VA) và địa chỉ vật lý (PA)::

VA = PA + Offset cố định

Bộ nhớ ảo được ánh xạ trang có mối quan hệ tùy ý giữa VA và PA, trong đó
được ghi lại trong TLB và các bảng trang. TLB của LoongArch bao gồm một kết hợp đầy đủ
MTLB (Kích thước nhiều trang TLB) và STLB liên kết theo tập hợp (Kích thước một trang TLB).

Theo mặc định, toàn bộ không gian địa chỉ ảo của LA32 được cấu hình như sau:

============= ============================ =================================
Tên Địa chỉ Phạm vi Thuộc tính
============= ============================ =================================
ZZ0000ZZ ZZ0001ZZ Ánh xạ trang, được lưu trong bộ nhớ đệm, PLV0~3
ZZ0002ZZ ZZ0003ZZ Ánh xạ trực tiếp, Không được lưu vào bộ nhớ đệm, PLV0
ZZ0004ZZ ZZ0005ZZ Ánh xạ trực tiếp, được lưu vào bộ nhớ đệm, PLV0
ZZ0006ZZ ZZ0007ZZ Ánh xạ trang, được lưu trong bộ nhớ đệm, PLV0
============= ============================ =================================

Chế độ người dùng (PLV3) chỉ có thể truy cập UVRANGE. Đối với KPRANGE0 được ánh xạ trực tiếp và
KPRANGE1, PA bằng VA khi bit30~31 bị xóa. Ví dụ: không được lưu vào bộ nhớ đệm
VA được ánh xạ trực tiếp của 0x00001000 là 0x80001000 và được ánh xạ trực tiếp vào bộ nhớ đệm
VA của 0x00001000 là 0xA0001000.

Theo mặc định, toàn bộ không gian địa chỉ ảo của LA64 được cấu hình như sau:

============ =================================================================
Tên Địa chỉ Phạm vi Thuộc tính
============ =================================================================
ZZ0000ZZ ZZ0001ZZ
ZZ0002ZZ ZZ0003ZZ
ZZ0004ZZ ZZ0005ZZ
ZZ0006ZZ ZZ0007ZZ
============ =================================================================

Chế độ người dùng (PLV3) chỉ có thể truy cập XUVRANGE. Đối với XSPRANGE được ánh xạ trực tiếp và
XKPRANGE, PA bằng VA với các bit 60~63 bị xóa và thuộc tính bộ đệm
được cấu hình bởi các bit 60~61 trong VA: 0 dành cho bộ đệm có thứ tự mạnh, 1 là
đối với bộ nhớ đệm nhất quán và 2 dành cho bộ nhớ đệm có thứ tự yếu.

Hiện tại chúng tôi chỉ sử dụng XKPRANGE để lập bản đồ trực tiếp và XSPRANGE được bảo lưu.

Để thực hiện điều này: VA được ánh xạ trực tiếp không được lưu vào bộ đệm được sắp xếp theo thứ tự mạnh (trong
XKPRANGE) của 0x00000000_00001000 là 0x80000000_00001000, bộ nhớ đệm nhất quán
VA được ánh xạ trực tiếp (trong XKPRANGE) của 0x00000000_00001000 là 0x90000000_00001000,
và VA được ánh xạ trực tiếp không được lưu vào bộ nhớ đệm theo thứ tự yếu (trong XKPRANGE) là 0x00000000
_00001000 là 0xA0000000_00001000.

Mối quan hệ của Loongson và LoongArch
======================================

LoongArch là RISC ISA khác với bất kỳ phiên bản hiện có nào khác, trong khi
Loongson là một gia đình xử lý. Loongson bao gồm 3 series: Loongson-1 là
dòng bộ xử lý 32-bit, Loongson-2 là dòng bộ xử lý 64-bit cấp thấp,
và Loongson-3 là dòng vi xử lý 64-bit cao cấp. Old Loongson dựa trên
MIPS, trong khi Loongson mới dựa trên LoongArch. Lấy Loongson-3 làm ví dụ:
Loongson-3A1000/3B1500/3A2000/3A3000/3A4000 tương thích với MIPS, trong khi Loongson-
3A5000 (và các bản sửa đổi trong tương lai) đều dựa trên LoongArch.

.. _loongarch-references:

Tài liệu tham khảo
==========

Trang web chính thức của Loongson Technology Corp. Ltd.:

ZZ0000ZZ

Trang web dành cho nhà phát triển của Loongson và LoongArch (Phần mềm và Tài liệu):

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

Tài liệu của LoongArch ISA:

ZZ0000ZZ (bằng tiếng Trung Quốc)

ZZ0000ZZ (bằng tiếng Anh)

Tài liệu của LoongArch ELF psABI:

ZZ0000ZZ (bằng tiếng Trung Quốc)

ZZ0000ZZ (bằng tiếng Anh)

Kho kernel Linux của Loongson và LoongArch:

ZZ0000ZZ