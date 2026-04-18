.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm64/booting.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Khởi động AArch64 Linux
=====================

Tác giả: Will Deacon <will.deacon@arm.com>

Ngày: 07 tháng 9 năm 2012

Tài liệu này dựa trên tài liệu khởi động ARM của Russell King và
có liên quan đến tất cả các bản phát hành công khai của nhân AArch64 Linux.

Mô hình ngoại lệ AArch64 được tạo thành từ một số cấp độ ngoại lệ
(EL0 - EL3), với EL0, EL1 và EL2 có bảo mật và không bảo mật
đối tác.  EL2 là cấp độ ảo hóa, EL3 là mức ưu tiên cao nhất
cấp độ và chỉ tồn tại ở chế độ an toàn. Cả hai đều là tùy chọn về mặt kiến ​​trúc.

Vì mục đích của tài liệu này, chúng tôi sẽ sử dụng thuật ngữ ZZ0000ZZ
chỉ đơn giản là xác định tất cả phần mềm thực thi trên (các) CPU trước khi điều khiển
được chuyển tới nhân Linux.  Điều này có thể bao gồm giám sát an toàn và
mã ảo hóa hoặc có thể chỉ là một số hướng dẫn dành cho
chuẩn bị một môi trường khởi động tối thiểu.

Về cơ bản, bộ tải khởi động phải cung cấp (tối thiểu)
sau đây:

1. Thiết lập và khởi tạo RAM
2. Thiết lập cây thiết bị
3. Giải nén ảnh kernel
4. Gọi ảnh kernel


1. Thiết lập và khởi tạo RAM
---------------------------

Yêu cầu: MANDATORY

Bộ tải khởi động dự kiến sẽ tìm và khởi tạo tất cả RAM mà
kernel sẽ sử dụng để lưu trữ dữ liệu dễ bay hơi trong hệ thống.  Nó thực hiện
điều này theo cách phụ thuộc vào máy.  (Nó có thể sử dụng các thuật toán nội bộ
để tự động định vị và định kích thước tất cả RAM hoặc có thể sử dụng kiến thức về
RAM trong máy hoặc bất kỳ phương pháp nào khác mà nhà thiết kế bộ tải khởi động
thấy phù hợp.)

Đối với Lĩnh vực điện toán bí mật của Arm, điều này bao gồm việc đảm bảo rằng tất cả
RAM được bảo vệ có trạng thái Realm IPA (RIPAS) là "RAM".


2. Thiết lập cây thiết bị
-------------------------

Yêu cầu: MANDATORY

Blob cây thiết bị (dtb) phải được đặt trên ranh giới 8 byte và phải
kích thước không vượt quá 2 megabyte. Vì dtb sẽ được ánh xạ vào bộ nhớ đệm
sử dụng các khối có kích thước lên tới 2 megabyte thì không được đặt nó trong
bất kỳ vùng 2M nào phải được ánh xạ với bất kỳ thuộc tính cụ thể nào.

NOTE: các phiên bản trước v4.2 cũng yêu cầu DTB được đặt bên trong
vùng 512 MB bắt đầu từ byte text_offset bên dưới Hình ảnh hạt nhân.

3. Giải nén ảnh kernel
------------------------------

Yêu cầu: OPTIONAL

Hạt nhân AArch64 hiện không cung cấp bộ giải nén và
do đó yêu cầu giải nén (gzip, v.v.) phải được thực hiện bởi boot
bộ tải nếu sử dụng mục tiêu Hình ảnh nén (ví dụ: Image.gz).  cho
bộ tải khởi động không thực hiện yêu cầu này, bộ tải khởi động không nén
Mục tiêu hình ảnh có sẵn thay thế.


4. Gọi ảnh kernel
------------------------

Yêu cầu: MANDATORY

Hình ảnh hạt nhân được giải nén chứa tiêu đề 64 byte như sau ::

mã u320;			/*Mã thực thi được*/
  mã u321;			/*Mã thực thi được*/
  văn bản u64_offset;		/* Độ lệch tải ảnh, endian nhỏ */
  u64 image_size;		/* Kích thước ảnh hiệu quả, little endian */
  cờ u64;			/* cờ kernel, endian nhỏ */
  u64 res2 = 0;		/* dành riêng */
  u64 res3 = 0;		/* dành riêng */
  u64 res4 = 0;		/* dành riêng */
  u32 ma thuật = 0x644d5241;	/* Con số kỳ diệu, endian nhỏ, "ARM\x64" */
  u32 res5;			/* dành riêng (dùng cho offset PE COFF) */


Ghi chú tiêu đề:

- Kể từ v3.17, tất cả các trường đều là endian nhỏ trừ khi có quy định khác.

- code0/code1 chịu trách nhiệm phân nhánh thành văn bản.

- khi khởi động qua EFI, code0/code1 ban đầu bị bỏ qua.
  res5 là phần bù cho tiêu đề PE và tiêu đề PE có EFI
  điểm vào (efi_stub_entry).  Khi stub đã hoàn thành công việc của nó, nó
  nhảy tới code0 để tiếp tục quá trình khởi động bình thường.

- Trước v3.17, độ bền của text_offset không được chỉ định.  trong
  những trường hợp này image_size bằng 0 và text_offset là 0x80000 trong
  độ bền của hạt nhân.  Trong đó image_size khác 0 image_size là
  little-endian và phải được tôn trọng.  Trong đó image_size bằng 0,
  text_offset có thể được coi là 0x80000.

- Trường flags (được giới thiệu trong v3.17) là trường 64 bit endian nhỏ
  được sáng tác như sau:

============== =====================================================================
  Độ bền của hạt nhân bit 0.  1 nếu BE, 0 nếu LE.
  Kích thước trang hạt nhân Bit 1-2.

* 0 - Không xác định.
			* 1 - 4K
			* 2 - 16K
			* 3 - 64K
  Vị trí vật lý hạt nhân bit 3

0
			  Cơ sở căn chỉnh 2 MB phải càng gần càng tốt
			  vào đế của DRAM, vì bộ nhớ bên dưới nó không
			  có thể truy cập thông qua ánh xạ tuyến tính
			1
			  Cơ sở căn chỉnh 2 MB sao cho tất cả byte image_size
			  tính từ đầu hình ảnh đều nằm trong
			  phạm vi địa chỉ 48-bit của bộ nhớ vật lý
  Bit 4-63 dành riêng.
  ============== =====================================================================

- Khi image_size bằng 0, bộ nạp khởi động sẽ cố gắng giữ càng nhiều
  bộ nhớ càng trống càng tốt để kernel sử dụng ngay sau khi
  phần cuối của ảnh kernel. Lượng không gian cần thiết sẽ thay đổi
  tùy thuộc vào các tính năng được chọn và không bị ràng buộc một cách hiệu quả.

Hình ảnh phải được đặt text_offset byte từ cơ sở căn chỉnh 2 MB
địa chỉ ở bất kỳ đâu trong hệ thống có thể sử dụng RAM và được gọi đến đó. Khu vực
giữa địa chỉ cơ sở được căn chỉnh 2 MB và phần đầu của hình ảnh không có
có ý nghĩa đặc biệt đối với kernel và có thể được sử dụng cho các mục đích khác.
Ít nhất byte image_size tính từ đầu hình ảnh phải trống trong
được sử dụng bởi kernel.
NOTE: các phiên bản trước v4.6 không thể sử dụng bộ nhớ dưới mức
độ lệch vật lý của Hình ảnh nên Hình ảnh nên được
được đặt càng gần điểm bắt đầu của hệ thống RAM càng tốt.

Nếu initrd/initramfs được truyền vào kernel khi khởi động, nó phải nằm trong
hoàn toàn trong cửa sổ bộ nhớ vật lý được căn chỉnh 1 GB lên tới 32 GB trong
kích thước bao phủ hoàn toàn hình ảnh hạt nhân.

Bất kỳ bộ nhớ nào được mô tả cho kernel (ngay cả bộ nhớ dưới phần bắt đầu của
image) không được đánh dấu là dành riêng từ kernel (ví dụ: với
vùng memreserve trong cây thiết bị) sẽ được coi là có sẵn cho
hạt nhân.

Trước khi nhảy vào kernel, phải đáp ứng các điều kiện sau:

- Tắt tất cả các thiết bị có khả năng DMA để không nhận được bộ nhớ
  bị hỏng bởi các gói mạng hoặc dữ liệu đĩa không có thật.  Điều này sẽ tiết kiệm
  bạn có nhiều giờ gỡ lỗi.

- Cài đặt thanh ghi đa năng CPU chính:

- x0 = địa chỉ vật lý của blob cây thiết bị (dtb) trong hệ thống RAM.
    - x1 = 0 (dành riêng cho tương lai)
    - x2 = 0 (dành riêng cho tương lai)
    - x3 = 0 (dành riêng cho tương lai)

- Chế độ CPU

Tất cả các dạng ngắt phải được che giấu trong PSTATE.DAIF (Debug, SError,
  IRQ và FIQ).
  CPU phải ở trạng thái không an toàn, hoặc ở EL2 (RECOMMENDED theo thứ tự
  để có quyền truy cập vào các tiện ích mở rộng ảo hóa) hoặc trong EL1.

- Bộ nhớ đệm, MMU

MMU phải tắt.

Bộ nhớ đệm lệnh có thể bật hoặc tắt và không được giữ bất kỳ thông tin cũ nào
  các mục tương ứng với hình ảnh hạt nhân được tải.

Dải địa chỉ tương ứng với ảnh kernel được tải phải là
  được làm sạch tới PoC. Khi có bộ đệm hệ thống hoặc bộ đệm khác
  các bản gốc mạch lạc có bật bộ nhớ đệm, điều này thường sẽ yêu cầu
  bảo trì bộ đệm bằng VA thay vì thực hiện các thao tác thiết lập/cách thức.
  Bộ nhớ đệm hệ thống tôn trọng việc bảo trì bộ nhớ đệm theo kiến trúc của VA
  hoạt động phải được cấu hình và có thể được kích hoạt.
  Bộ nhớ đệm hệ thống không tôn trọng việc bảo trì bộ nhớ đệm theo kiến trúc của VA
  các hoạt động (không được khuyến nghị) phải được cấu hình và tắt.

- Kiến trúc tính giờ

CNTFRQ phải được lập trình với tần số hẹn giờ và CNTVOFF phải
  được lập trình với một giá trị nhất quán trên tất cả các CPU.  Nếu vào
  kernel tại EL1, CNTHCTL_EL2 phải có EL1PCTEN (bit 0) được đặt ở đâu
  có sẵn.

- Tính mạch lạc

Tất cả các CPU được kernel khởi động phải là một phần của cùng một mạch lạc
  tên miền khi vào kernel.  Điều này có thể yêu cầu IMPLEMENTATION DEFINED
  khởi tạo để cho phép nhận các hoạt động bảo trì trên
  mỗi CPU.

- Hệ thống đăng ký

Tất cả các thanh ghi hệ thống có kiến trúc có thể ghi ở hoặc dưới ngoại lệ
  mức độ mà hình ảnh hạt nhân sẽ được nhập phải được khởi tạo bởi
  phần mềm ở mức ngoại lệ cao hơn để ngăn chặn việc thực thi trong UNKNOWN
  trạng thái.

Đối với tất cả các hệ thống:
  - Nếu có EL3:

- SCR_EL3.FIQ phải có cùng giá trị trên tất cả các CPU có hạt nhân
      đang thực hiện.
    - Giá trị của SCR_EL3.FIQ phải giống với giá trị khi khởi động
      thời gian bất cứ khi nào kernel đang thực thi.

- Nếu có EL3 và nhập kernel vào EL2:

- SCR_EL3.HCE (bit 8) phải được khởi tạo thành 0b1.

Đối với các hệ thống có bộ điều khiển ngắt GICv5 được sử dụng ở chế độ v5:

- Nếu kernel nhập vào EL1 và có EL2:

- ICH_HFGRTR_EL2.ICC_PPI_ACTIVERn_EL1 (bit 20) phải được khởi tạo thành 0b1.
      - ICH_HFGRTR_EL2.ICC_PPI_PRIORITYRn_EL1 (bit 19) phải được khởi tạo thành 0b1.
      - ICH_HFGRTR_EL2.ICC_PPI_PENDRn_EL1 (bit 18) phải được khởi tạo thành 0b1.
      - ICH_HFGRTR_EL2.ICC_PPI_ENABLERn_EL1 (bit 17) phải được khởi tạo thành 0b1.
      - ICH_HFGRTR_EL2.ICC_PPI_HMRN_EL1 (bit 16) phải được khởi tạo thành 0b1.
      - ICH_HFGRTR_EL2.ICC_IAFFIDR_EL1 (bit 7) phải được khởi tạo thành 0b1.
      - ICH_HFGRTR_EL2.ICC_ICSR_EL1 (bit 6) phải được khởi tạo thành 0b1.
      - ICH_HFGRTR_EL2.ICC_PCR_EL1 (bit 5) phải được khởi tạo thành 0b1.
      - ICH_HFGRTR_EL2.ICC_HPPIR_EL1 (bit 4) phải được khởi tạo thành 0b1.
      - ICH_HFGRTR_EL2.ICC_HAPR_EL1 (bit 3) phải được khởi tạo thành 0b1.
      - ICH_HFGRTR_EL2.ICC_CR0_EL1 (bit 2) phải được khởi tạo thành 0b1.
      - ICH_HFGRTR_EL2.ICC_IDRn_EL1 (bit 1) phải được khởi tạo thành 0b1.
      - ICH_HFGRTR_EL2.ICC_APR_EL1 (bit 0) phải được khởi tạo thành 0b1.

- ICH_HFGWTR_EL2.ICC_PPI_ACTIVERn_EL1 (bit 20) phải được khởi tạo thành 0b1.
      - ICH_HFGWTR_EL2.ICC_PPI_PRIORITYRn_EL1 (bit 19) phải được khởi tạo thành 0b1.
      - ICH_HFGWTR_EL2.ICC_PPI_PENDRn_EL1 (bit 18) phải được khởi tạo thành 0b1.
      - ICH_HFGWTR_EL2.ICC_PPI_ENABLERn_EL1 (bit 17) phải được khởi tạo thành 0b1.
      - ICH_HFGWTR_EL2.ICC_ICSR_EL1 (bit 6) phải được khởi tạo thành 0b1.
      - ICH_HFGWTR_EL2.ICC_PCR_EL1 (bit 5) phải được khởi tạo thành 0b1.
      - ICH_HFGWTR_EL2.ICC_CR0_EL1 (bit 2) phải được khởi tạo thành 0b1.
      - ICH_HFGWTR_EL2.ICC_APR_EL1 (bit 0) phải được khởi tạo thành 0b1.

- ICH_HFGITR_EL2.GICRCDNMIA (bit 10) phải được khởi tạo thành 0b1.
      - ICH_HFGITR_EL2.GICRCDIA (bit 9) phải được khởi tạo thành 0b1.
      - ICH_HFGITR_EL2.GICCDDI (bit 8) phải được khởi tạo thành 0b1.
      - ICH_HFGITR_EL2.GICCDEOI (bit 7) phải được khởi tạo thành 0b1.
      - ICH_HFGITR_EL2.GICCDHM (bit 6) phải được khởi tạo thành 0b1.
      - ICH_HFGITR_EL2.GICCDRCFG (bit 5) phải được khởi tạo thành 0b1.
      - ICH_HFGITR_EL2.GICCDPEND (bit 4) phải được khởi tạo thành 0b1.
      - ICH_HFGITR_EL2.GICCDAFF (bit 3) phải được khởi tạo thành 0b1.
      - ICH_HFGITR_EL2.GICCDPRI (bit 2) phải được khởi tạo thành 0b1.
      - ICH_HFGITR_EL2.GICCDDIS (bit 1) phải được khởi tạo thành 0b1.
      - ICH_HFGITR_EL2.GICCDEN (bit 0) phải được khởi tạo thành 0b1.

- Bảng DT hoặc ACPI phải mô tả bộ điều khiển ngắt GICv5.

Đối với các hệ thống có bộ điều khiển ngắt GICv3 được sử dụng ở chế độ v3:
  - Nếu có EL3:

- ICC_SRE_EL3.Enable (bit 3) phải được khởi tạo thành 0b1.
      - ICC_SRE_EL3.SRE (bit 0) phải được khởi tạo thành 0b1.
      - ICC_CTLR_EL3.PMHE (bit 6) phải được đặt thành cùng một giá trị trên
        tất cả các CPU mà kernel đang thực thi và phải không đổi
        trong suốt thời gian tồn tại của kernel.

- Nếu nhập kernel tại EL1:

- ICC_SRE_EL2.Enable (bit 3) phải được khởi tạo thành 0b1
      - ICC_SRE_EL2.SRE (bit 0) phải được khởi tạo thành 0b1.

- Bảng DT hoặc ACPI phải mô tả bộ điều khiển ngắt GICv3.

Đối với các hệ thống có bộ điều khiển ngắt GICv3 được sử dụng trong
  chế độ tương thích (v2):

- Nếu có EL3:

ICC_SRE_EL3.SRE (bit 0) phải được khởi tạo thành 0b0.

- Nếu nhập kernel tại EL1:

ICC_SRE_EL2.SRE (bit 0) phải được khởi tạo thành 0b0.

- Bảng DT hoặc ACPI phải mô tả bộ điều khiển ngắt GICv2.

Đối với CPU có chức năng xác thực con trỏ:

- Nếu có EL3:

- SCR_EL3.APK (bit 16) phải được khởi tạo thành 0b1
    - SCR_EL3.API (bit 17) phải được khởi tạo thành 0b1

- Nếu nhập kernel tại EL1:

- HCR_EL2.APK (bit 40) phải được khởi tạo thành 0b1
    - HCR_EL2.API (bit 41) phải được khởi tạo thành 0b1

Đối với các CPU có phần mở rộng Bộ giám sát hoạt động v1 (AMUv1):

- Nếu có EL3:

- CPTR_EL3.TAM (bit 30) phải được khởi tạo thành 0b0
    - CPTR_EL2.TAM (bit 30) phải được khởi tạo thành 0b0
    - AMCNTENSET0_EL0 phải được khởi tạo thành 0b1111
    - AMCNTENSET1_EL0 phải được khởi tạo thành giá trị cụ thể của nền tảng
      có 0b1 được đặt cho bit tương ứng cho mỗi phần phụ trợ
      quầy có mặt.

- Nếu nhập kernel tại EL1:

- AMCNTENSET0_EL0 phải được khởi tạo thành 0b1111
    - AMCNTENSET1_EL0 phải được khởi tạo thành giá trị cụ thể của nền tảng
      có 0b1 được đặt cho bit tương ứng cho mỗi phần phụ trợ
      quầy có mặt.

Đối với các CPU có tiện ích mở rộng Bẫy hạt mịn (FEAT_FGT):

- Nếu có EL3 và nhập kernel vào EL2:

- SCR_EL3.FGTEn (bit 27) phải được khởi tạo thành 0b1.

Đối với các CPU có tiện ích mở rộng Fine Grained Traps 2 (FEAT_FGT2):

- Nếu có EL3 và nhập kernel vào EL2:

- SCR_EL3.FGTEn2 (bit 59) phải được khởi tạo thành 0b1.

Đối với các CPU có hỗ trợ HCRX_EL2 (FEAT_HCX):

- Nếu có EL3 và nhập kernel vào EL2:

- SCR_EL3.HXEn (bit 38) phải được khởi tạo thành 0b1.

Đối với CPU có SIMD nâng cao và hỗ trợ dấu phẩy động:

- Nếu có EL3:

- CPTR_EL3.TFP (bit 10) phải được khởi tạo thành 0b0.

- Nếu có EL2 và nhập kernel vào EL1:

- CPTR_EL2.TFP (bit 10) phải được khởi tạo thành 0b0.

Đối với các CPU có Tiện ích mở rộng vectơ có thể mở rộng (FEAT_SVE):

- nếu có EL3:

- CPTR_EL3.EZ (bit 8) phải được khởi tạo thành 0b1.

- ZCR_EL3.LEN phải được khởi tạo ở cùng một giá trị cho tất cả các CPU
      kernel được thực thi trên đó.

- Nếu kernel nhập vào EL1 và có EL2:

- CPTR_EL2.TZ (bit 8) phải được khởi tạo thành 0b0.

- CPTR_EL2.ZEN (bit 17:16) phải được khởi tạo thành 0b11.

- ZCR_EL2.LEN phải được khởi tạo ở cùng một giá trị cho tất cả các CPU
      kernel sẽ thực thi.

Đối với CPU có Tiện ích mở rộng ma trận có thể mở rộng (FEAT_SME):

- Nếu có EL3:

- CPTR_EL3.ESM (bit 12) phải được khởi tạo thành 0b1.

- SCR_EL3.EnTP2 (bit 41) phải được khởi tạo thành 0b1.

- SMCR_EL3.LEN phải được khởi tạo ở cùng một giá trị cho tất cả các CPU
      kernel sẽ thực thi.

- Nếu kernel nhập vào EL1 và có EL2:

- CPTR_EL2.TSM (bit 12) phải được khởi tạo thành 0b0.

- CPTR_EL2.SMEN (bit 25:24) phải được khởi tạo thành 0b11.

- SCTLR_EL2.EnTP2 (bit 60) phải được khởi tạo thành 0b1.

- SMCR_EL2.LEN phải được khởi tạo ở cùng một giá trị cho tất cả các CPU
      kernel sẽ thực thi.

- HFGRTR_EL2.nTPIDR2_EL0 (bit 55) phải được khởi tạo thành 0b01.

- HFGWTR_EL2.nTPIDR2_EL0 (bit 55) phải được khởi tạo thành 0b01.

- HFGRTR_EL2.nSMPRI_EL1 (bit 54) phải được khởi tạo thành 0b01.

- HFGWTR_EL2.nSMPRI_EL1 (bit 54) phải được khởi tạo thành 0b01.

Đối với CPU có tính năng Mở rộng ma trận có thể mở rộng FA64 (FEAT_SME_FA64):

- Nếu có EL3:

- SMCR_EL3.FA64 (bit 31) phải được khởi tạo thành 0b1.

- Nếu kernel nhập vào EL1 và có EL2:

- SMCR_EL2.FA64 (bit 31) phải được khởi tạo thành 0b1.

Đối với CPU có tính năng Mở rộng gắn thẻ bộ nhớ (FEAT_MTE2):

- Nếu có EL3:

- SCR_EL3.ATA (bit 26) phải được khởi tạo thành 0b1.

- Nếu kernel nhập vào EL1 và có EL2:

- HCR_EL2.ATA (bit 56) phải được khởi tạo thành 0b1.

Đối với CPU có Tiện ích mở rộng ma trận có thể mở rộng phiên bản 2 (FEAT_SME2):

- Nếu có EL3:

- SMCR_EL3.EZT0 (bit 30) phải được khởi tạo thành 0b1.

- Nếu kernel nhập vào EL1 và có EL2:

- SMCR_EL2.EZT0 (bit 30) phải được khởi tạo thành 0b1.

Đối với các CPU có Tiện ích mở rộng bộ đệm bản ghi nhánh (FEAT_BRBE):

- Nếu có EL3:

- MDCR_EL3.SBRBE (bit 33:32) phải được khởi tạo thành 0b01 hoặc 0b11.

- Nếu kernel nhập vào EL1 và có EL2:

- BRBCR_EL2.CC (bit 3) phải được khởi tạo thành 0b1.
    - BRBCR_EL2.MPRED (bit 4) phải được khởi tạo thành 0b1.

- HDFGRTR_EL2.nBRBDATA (bit 61) phải được khởi tạo thành 0b1.
    - HDFGRTR_EL2.nBRBCTL (bit 60) phải được khởi tạo thành 0b1.
    - HDFGRTR_EL2.nBRBIDR (bit 59) phải được khởi tạo thành 0b1.

- HDFGWTR_EL2.nBRBDATA (bit 61) phải được khởi tạo thành 0b1.
    - HDFGWTR_EL2.nBRBCTL (bit 60) phải được khởi tạo thành 0b1.

- HFGITR_EL2.nBRBIALL (bit 56) phải được khởi tạo thành 0b1.
    - HFGITR_EL2.nBRBINJ (bit 55) phải được khởi tạo thành 0b1.

Đối với CPU có Tiện ích mở rộng giám sát hiệu suất (FEAT_PMUv3p9):

- Nếu có EL3:

- MDCR_EL3.EnPM2 (bit 7) phải được khởi tạo thành 0b1.

- Nếu kernel nhập vào EL1 và có EL2:

- HDFGRTR2_EL2.nPMICNTR_EL0 (bit 2) phải được khởi tạo thành 0b1.
    - HDFGRTR2_EL2.nPMICFILTR_EL0 (bit 3) phải được khởi tạo thành 0b1.
    - HDFGRTR2_EL2.nPMUACR_EL1 (bit 4) phải được khởi tạo thành 0b1.

- HDFGWTR2_EL2.nPMICNTR_EL0 (bit 2) phải được khởi tạo thành 0b1.
    - HDFGWTR2_EL2.nPMICFILTR_EL0 (bit 3) phải được khởi tạo thành 0b1.
    - HDFGWTR2_EL2.nPMUACR_EL1 (bit 4) phải được khởi tạo thành 0b1.

Đối với CPU có tính năng lọc nguồn dữ liệu SPE (FEAT_SPE_FDS):

- Nếu có EL3:

- MDCR_EL3.EnPMS3 (bit 42) phải được khởi tạo thành 0b1.

- Nếu kernel nhập vào EL1 và có EL2:

- HDFGRTR2_EL2.nPMSDSFR_EL1 (bit 19) phải được khởi tạo thành 0b1.
    - HDFGWTR2_EL2.nPMSDSFR_EL1 (bit 19) phải được khởi tạo thành 0b1.

Đối với CPU có lệnh Sao chép bộ nhớ và Bộ nhớ (FEAT_MOPS):

- Nếu kernel nhập vào EL1 và có EL2:

- HCRX_EL2.MSCEn (bit 11) phải được khởi tạo thành 0b1.

- HCRX_EL2.MCE2 (bit 10) phải được khởi tạo thành 0b1 và bộ ảo hóa
      phải xử lý các ngoại lệ MOPS như được mô tả trong ZZ0000ZZ.

Đối với CPU có tính năng Đăng ký điều khiển dịch mở rộng (FEAT_TCR2):

- Nếu có EL3:

- SCR_EL3.TCR2En (bit 43) phải được khởi tạo thành 0b1.

- Nếu kernel nhập vào EL1 và có EL2:

- HCRX_EL2.TCR2En (bit 14) phải được khởi tạo thành 0b1.

Đối với CPU có tính năng Mở rộng gián tiếp quyền giai đoạn 1 (FEAT_S1PIE):

- Nếu có EL3:

- SCR_EL3.PIEn (bit 45) phải được khởi tạo thành 0b1.

- Nếu kernel nhập vào EL1 và có EL2:

- HFGRTR_EL2.nPIR_EL1 (bit 58) phải được khởi tạo thành 0b1.

- HFGWTR_EL2.nPIR_EL1 (bit 58) phải được khởi tạo thành 0b1.

- HFGRTR_EL2.nPIRE0_EL1 (bit 57) phải được khởi tạo thành 0b1.

- HFGRWR_EL2.nPIRE0_EL1 (bit 57) phải được khởi tạo thành 0b1.

- Đối với CPU có ngăn xếp điều khiển được bảo vệ (FEAT_GCS):

- GCSCR_EL1 phải được khởi tạo về 0.

- GCSCRE0_EL1 phải được khởi tạo về 0.

- Nếu có EL3:

- SCR_EL3.GCSEn (bit 39) phải được khởi tạo thành 0b1.

- Nếu có EL2:

- GCSCR_EL2 phải được khởi tạo về 0.

- Nếu kernel nhập vào EL1 và có EL2:

- HCRX_EL2.GCSEn phải được khởi tạo thành 0b1.

- HFGITR_EL2.nGCSEPP (bit 59) phải được khởi tạo thành 0b1.

- HFGITR_EL2.nGCSSTR_EL1 (bit 58) phải được khởi tạo thành 0b1.

- HFGITR_EL2.nGCSPUSHM_EL1 ​​(bit 57) phải được khởi tạo thành 0b1.

- HFGRTR_EL2.nGCS_EL1 (bit 53) phải được khởi tạo thành 0b1.

- HFGRTR_EL2.nGCS_EL0 (bit 52) ​​phải được khởi tạo thành 0b1.

- HFGWTR_EL2.nGCS_EL1 (bit 53) phải được khởi tạo thành 0b1.

- HFGWTR_EL2.nGCS_EL0 (bit 52) ​​phải được khởi tạo thành 0b1.

- Đối với CPU có kiến ​​trúc gỡ lỗi tức là FEAT_Debugv8pN (tất cả các phiên bản):

- Nếu có EL3:

- MDCR_EL3.TDA (bit 9) phải được khởi tạo thành 0b0

- Đối với CPU có FEAT_PMUv3:

- Nếu có EL3:

- MDCR_EL3.TPM (bit 6) phải được khởi tạo thành 0b0

Đối với CPU có hỗ trợ tải và lưu trữ 64 byte không có trạng thái (FEAT_LS64):

- Nếu kernel nhập vào EL1 và có EL2:

- HCRX_EL2.EnALS (bit 1) phải được khởi tạo thành 0b1.

Đối với CPU có hỗ trợ lưu trữ 64 byte có trạng thái (FEAT_LS64_V):

- Nếu kernel nhập vào EL1 và có EL2:

- HCRX_EL2.EnASR (bit 2) phải được khởi tạo thành 0b1.

Các yêu cầu được mô tả ở trên đối với chế độ CPU, bộ nhớ đệm, MMU, được thiết kế
bộ định thời, tính kết hợp và thanh ghi hệ thống áp dụng cho tất cả các CPU.  Tất cả các CPU phải
nhập kernel ở cùng mức ngoại lệ.  Trường hợp các giá trị được ghi lại
vô hiệu hóa bẫy, được phép bật các bẫy này miễn là
những cái bẫy đó được xử lý một cách minh bạch bởi các mức ngoại lệ cao hơn như thể
các giá trị được ghi lại đã được thiết lập.

Bộ tải khởi động dự kiến sẽ nhập kernel trên mỗi CPU trong
cách sau:

- CPU chính phải nhảy trực tiếp tới lệnh đầu tiên của
  hình ảnh hạt nhân.  blob cây thiết bị được chuyển qua CPU này phải chứa
  thuộc tính 'phương thức kích hoạt' cho mỗi nút cpu.  Được hỗ trợ
  các phương thức kích hoạt được mô tả dưới đây.

Dự kiến bootloader sẽ tạo ra các cây thiết bị này
  thuộc tính và chèn chúng vào blob trước khi nhập kernel.

- CPU có phương thức kích hoạt "spin-table" phải có 'cpu-release-addr'
  thuộc tính trong nút cpu của họ.  Thuộc tính này xác định một
  Vị trí bộ nhớ được kích hoạt bằng 0 64-bit được căn chỉnh tự nhiên.

Các CPU này sẽ quay bên ngoài hạt nhân trong một vùng dành riêng
  bộ nhớ (được truyền tới kernel bằng vùng /memreserve/ trong
  cây thiết bị) đang thăm dò vị trí cpu-release-addr của chúng, vị trí này phải là
  chứa trong vùng dành riêng.  Một lệnh wfe có thể được chèn vào
  để giảm chi phí của vòng lặp bận và một thứ bảy sẽ được cấp bởi
  CPU chính.  Khi đọc vị trí được trỏ bởi
  cpu-release-addr trả về giá trị khác 0, CPU phải nhảy tới giá trị này
  giá trị.  Giá trị sẽ được viết dưới dạng một endian nhỏ 64 bit
  giá trị, do đó CPU phải chuyển đổi giá trị đọc thành giá trị cuối cùng gốc của chúng
  trước khi chuyển sang nó.

- CPU có phương thức kích hoạt "psci" phải ở bên ngoài
  hạt nhân (tức là nằm ngoài vùng bộ nhớ được mô tả cho
  kernel trong nút bộ nhớ hoặc trong vùng bộ nhớ dành riêng được mô tả
  tới hạt nhân theo vùng /memreserve/ trong cây thiết bị).  các
  kernel sẽ thực hiện các cuộc gọi CPU_ON như được mô tả trong số tài liệu ARM ARM
  DEN 0022A ("Phần mềm hệ thống giao diện phối hợp trạng thái nguồn trên ARM
  bộ xử lý") để đưa CPU vào kernel.

Cây thiết bị phải chứa nút 'psci', như được mô tả trong
  Tài liệu/devicetree/binds/arm/psci.yaml.

- Cài đặt thanh ghi đa năng CPU thứ cấp

- x0 = 0 (dành riêng cho lần sau)
  - x1 = 0 (dành riêng cho tương lai)
  - x2 = 0 (dành riêng cho tương lai)
  - x3 = 0 (dành riêng cho tương lai)
