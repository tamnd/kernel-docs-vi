.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm64/acpi_object_usage.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============
Bàn ACPI
===========

Kỳ vọng của các bảng ACPI riêng lẻ được thảo luận trong danh sách
theo sau.

Nếu số phần được sử dụng, nó sẽ đề cập đến số phần trong ACPI
đặc tả nơi đối tượng được xác định.  Nếu "Chữ ký được bảo lưu" được sử dụng,
chữ ký bảng (bốn byte đầu tiên của bảng) là phần duy nhất
của bảng được đặc tả công nhận và bảng thực tế được xác định
bên ngoài Diễn đàn UEFI (xem Phần 5.2.6 của thông số kỹ thuật).

Đối với ACPI trên arm64, các bảng cũng thuộc các loại sau:

- Bắt buộc: DSDT, FADT, GTDT, MADT, MCFG, RSDP, SPCR, XSDT

- Khuyến nghị: BERT, EINJ, ERST, HEST, PCCT, SSDT

- Tùy chọn: AGDI, BGRT, CEDT, CPEP, CSRT, DBG2, DRTM, ECDT, FACS, FPDT,
          HMAT, IBFT, IORT, MCHI, MPAM, MPST, MSCT, NFIT, PMTT, PPTT, RASF, SBST,
          SDEI, SLIT, SPMI, SRAT, STAO, TCPA, TPM2, UEFI, XENV

- Không được hỗ trợ: AEST, APMT, BOOT, DBGP, DMAR, ETDT, HPET, IVRS, LPIT,
          MSDM, OEMx, PDTT, PSDT, RAS2, RSDT, SLIC, WAET, WDAT, WDRT, WPBT

====== ==============================================================================
Cách sử dụng bảng cho ARMv8 Linux
====== ==============================================================================
Chữ ký AEST được bảo lưu (chữ ký == "AEST")

ZZ0000ZZ

Bảng này thông báo cho hệ điều hành về bất kỳ nút lỗi nào trong hệ thống được
       tương thích với kiến trúc Arm RAS.

Chữ ký AGDI được bảo lưu (chữ ký == "AGDI")

ZZ0000ZZ

Bảng này mô tả một sự kiện không thể che giấu được nền tảng sử dụng
       chương trình cơ sở, để yêu cầu HĐH tạo kết xuất chẩn đoán và đặt lại thiết bị.

Chữ ký APMT được bảo lưu (chữ ký == "APMT")

ZZ0000ZZ

Bảng này mô tả các thuộc tính của hỗ trợ PMU được triển khai bởi
       các thành phần trong hệ thống.

BERT Mục 18.3 (chữ ký == "BERT")

ZZ0000ZZ

Phải được cung cấp nếu nền tảng cung cấp hỗ trợ RAS.  Nó
       được đề nghị cung cấp bảng này.

Chữ ký BOOT được bảo lưu (chữ ký == "BOOT")

ZZ0000ZZ

Bảng duy nhất của Microsoft, sẽ không được hỗ trợ.

BGRT Mục 5.2.22 (chữ ký == "BGRT")

ZZ0000ZZ

Tùy chọn, hiện không được hỗ trợ, không có trường hợp sử dụng thực sự cho
       Máy chủ ARM.

Chữ ký CEDT được bảo lưu (chữ ký == "CEDT")

ZZ0000ZZ

Bảng này cho phép HĐH khám phá mọi Cầu nối máy chủ CXL và Máy chủ
       Cầu đăng ký.

CPEP Mục 5.2.18 (chữ ký == "CPEP")

ZZ0000ZZ

Tùy chọn, hiện không được hỗ trợ và không được đề xuất cho đến khi như vậy
       thời gian khi phần cứng tương thích với ARM có sẵn và thông số kỹ thuật
       được sửa đổi phù hợp.

Chữ ký CSRT được bảo lưu (chữ ký == "CSRT")

ZZ0000ZZ

Tùy chọn, hiện không được hỗ trợ.

Chữ ký DBG2 được bảo lưu (chữ ký == "DBG2")

ZZ0000ZZ

Giấy phép đã thay đổi và có thể sử dụng được.  Tùy chọn nếu được sử dụng thay thế
       của Earlycon=<device> trên dòng lệnh.

Chữ ký DBGP được bảo lưu (chữ ký == "DBGP")

ZZ0000ZZ

Bảng duy nhất của Microsoft, sẽ không được hỗ trợ.

DSDT Mục 5.2.11.1 (chữ ký == "DSDT")

ZZ0000ZZ

Cần có DSDT; xem thêm SSDT.

Các bảng ACPI chỉ chứa một DSDT nhưng có thể chứa một hoặc nhiều SSDT,
       đó là tùy chọn.  Mỗi SSDT chỉ có thể thêm vào không gian tên ACPI,
       nhưng không thể sửa đổi hoặc thay thế bất kỳ thứ gì trong DSDT.

Chữ ký DMAR được bảo lưu (chữ ký == "DMAR")

ZZ0000ZZ

Bảng chỉ x86, sẽ không được hỗ trợ.

Chữ ký DRTM được bảo lưu (chữ ký == "DRTM")

ZZ0000ZZ

Tùy chọn, hiện không được hỗ trợ.

ECDT Mục 5.2.16 (chữ ký == "ECDT")

ZZ0000ZZ

Tùy chọn, hiện không được hỗ trợ, nhưng có thể được sử dụng trên ARM nếu và
       chỉ khi người ta sử dụng trường GPE_BIT để biểu thị số IRQ, vì
       không có khối GPE nào được xác định ở chế độ giảm phần cứng.  Điều này sẽ
       cần được sửa đổi trong thông số kỹ thuật ACPI.

EINJ Mục 18.6 (chữ ký == "EINJ")

ZZ0000ZZ

Bảng này rất hữu ích để kiểm tra phản ứng của nền tảng đối với lỗi
       điều kiện; nó cho phép người ta đưa một lỗi vào hệ thống như
       nếu nó thực sự đã xảy ra.  Tuy nhiên, bảng này không nên
       được vận chuyển cùng với hệ thống sản xuất; nó phải được tải động
       và chỉ được thực thi bằng các công cụ ACPICA trong quá trình thử nghiệm.

ERST Mục 18.5 (chữ ký == "ERST")

ZZ0000ZZ

Trên nền tảng hỗ trợ RAS, bảng này phải được cung cấp nếu không
       Dựa trên UEFI; nếu nó dựa trên UEFI, bảng này có thể được cung cấp. Khi điều này
       bảng không có mặt, dịch vụ thời gian chạy UEFI sẽ được sử dụng để lưu
       và truy xuất thông tin lỗi phần cứng đến và đi từ một kho lưu trữ liên tục.

Chữ ký ETDT được bảo lưu (chữ ký == "ETDT")

ZZ0000ZZ

Bảng lỗi thời, sẽ không được hỗ trợ.

FACS Mục 5.2.10 (chữ ký == "FACS")

ZZ0000ZZ

Không chắc là bảng này sẽ cực kỳ hữu ích.  Nếu nó là
       được cung cấp, Khóa toàn cầu sẽ sử dụng NOT vì nó không phải là một phần của
       cấu hình giảm phần cứng và chỉ các trường địa chỉ 64 bit sẽ
       được coi là hợp lệ.

FADT Mục 5.2.9 (chữ ký == "FACP")

ZZ0000ZZ
       Cần thiết cho arm64.


Cờ HW_REDUCED_ACPI phải được đặt.  Tất cả các lĩnh vực được
       bị bỏ qua khi HW_REDUCED_ACPI được đặt dự kiến sẽ được đặt thành
       không.

Nếu bảng FACS được cung cấp thì trường X_FIRMWARE_CTRL sẽ được
       được sử dụng, không phải FIRMWARE_CTRL.

Nếu sử dụng PSCI (như được khuyến nghị), hãy đảm bảo rằng ARM_BOOT_ARCH được
       được điền đúng - cờ PSCI_COMPLIANT được đặt và
       PSCI_USE_HVC được đặt hoặc không được đặt khi cần (xem bảng 5-37).

Đối với DSDT cũng được yêu cầu, trường X_DSDT sẽ được sử dụng,
       không phải trường DSDT.

FPDT Mục 5.2.23 (chữ ký == "FPDT")

ZZ0000ZZ

Tùy chọn, hữu ích cho việc lập hồ sơ hiệu suất khởi động.

GTDT Mục 5.2.24 (chữ ký == "GTDT")

ZZ0000ZZ

Cần thiết cho arm64.

HEST Mục 18.3.2 (chữ ký == "HEST")

ZZ0000ZZ

Các nguồn lỗi dành riêng cho ARM đã được xác định; vui lòng sử dụng những cái đó hoặc
       Các loại PCI chẳng hạn như loại 6 (Cổng gốc AER), 7 (Điểm cuối AER) hoặc 8 (AER
       Bridge) hoặc sử dụng loại 9 (Nguồn lỗi phần cứng chung).  Phần sụn đầu tiên
       có thể xử lý lỗi khi và chỉ khi Phần sụn đáng tin cậy đang được
       được sử dụng trên arm64.

Phải được cung cấp nếu nền tảng cung cấp hỗ trợ RAS.  Nó
       được đề nghị cung cấp bảng này.

HMAT Mục 5.2.28 (chữ ký == "HMAT")

ZZ0000ZZ

Bảng này mô tả các thuộc tính bộ nhớ, chẳng hạn như bộ đệm bên bộ nhớ
       các thuộc tính và chi tiết về băng thông và độ trễ, liên quan đến Khoảng cách bộ nhớ
       Tên miền. HĐH sử dụng thông tin này để tối ưu hóa bộ nhớ hệ thống
       cấu hình.

Chữ ký HPET được bảo lưu (chữ ký == "HPET")

ZZ0000ZZ

Bảng chỉ x86, sẽ không được hỗ trợ.

Chữ ký IBFT được bảo lưu (chữ ký == "IBFT")

ZZ0000ZZ

Bảng do Microsoft xác định, hỗ trợ TBD.

Chữ ký IORT được bảo lưu (chữ ký == "IORT")

ZZ0000ZZ

bảng chỉ arm64, được yêu cầu để mô tả cấu trúc liên kết IO, SMMU,
       và ITS GIC cũng như cách kết nối các thành phần khác nhau đó với nhau,
       chẳng hạn như xác định thành phần nào đứng sau SMMU/ITS nào.
       Bảng này sẽ chỉ được yêu cầu trên một số nền tảng SBSA nhất định (ví dụ:
       khi sử dụng GICv3-ITS và SMMU); trên nền tảng SBSA Cấp 0, nó
       vẫn là tùy chọn.

Chữ ký IVRS được bảo lưu (chữ ký == "IVRS")

ZZ0000ZZ

Chỉ có bảng x86_64 (AMD), sẽ không được hỗ trợ.

Chữ ký LPIT được bảo lưu (chữ ký == "LPIT")

ZZ0000ZZ

bảng chỉ x86 kể từ ACPI 5.1; bắt đầu với ACPI 6.0, bộ xử lý
       mô tả và trạng thái nguồn trên nền tảng ARM nên sử dụng DSDT
       và xác định các thiết bị chứa bộ xử lý (_HID ACPI0010, Mục 8.4,
       và cụ thể hơn là 8.4.3 và 8.4.4).

MADT Mục 5.2.12 (chữ ký == "APIC")

ZZ0000ZZ

Cần thiết cho arm64.  Chỉ cấu trúc bộ điều khiển ngắt GIC
       nên sử dụng (loại 0xA - 0xF).

Chữ ký MCFG được bảo lưu (chữ ký == "MCFG")

ZZ0000ZZ

Nếu nền tảng hỗ trợ PCI/PCIe thì cần có bảng MCFG.

Chữ ký MCHI được bảo lưu (chữ ký == "MCHI")

ZZ0000ZZ

Tùy chọn, hiện không được hỗ trợ.

Chữ ký MPAM được bảo lưu (chữ ký == "MPAM")

ZZ0000ZZ

Bảng này cho phép HĐH khám phá các điều khiển MPAM được triển khai bởi
       các hệ thống con.

MPST Mục 5.2.21 (chữ ký == "MPST")

ZZ0000ZZ

Tùy chọn, hiện không được hỗ trợ.

MSCT Mục 5.2.19 (chữ ký == "MSCT")

ZZ0000ZZ

Tùy chọn, hiện không được hỗ trợ.

Chữ ký MSDM được bảo lưu (chữ ký == "MSDM")

ZZ0000ZZ

Bảng duy nhất của Microsoft, sẽ không được hỗ trợ.

NFIT Mục 5.2.25 (chữ ký == "NFIT")

ZZ0000ZZ

Tùy chọn, hiện không được hỗ trợ.

Chữ ký OEMx chỉ của "OEMx"

ZZ0000ZZ

Tất cả các bảng bắt đầu bằng chữ ký "OEM" được dành riêng cho OEM
       sử dụng.  Vì những thứ này không nhằm mục đích sử dụng chung nhưng bị hạn chế
       đối với người dùng cuối rất cụ thể, chúng không được khuyến khích sử dụng và
       không được kernel hỗ trợ cho arm64.

PCCT Mục 14.1 (chữ ký == "PCCT)

ZZ0000ZZ

Đề nghị sử dụng trên arm64; nên sử dụng PCC khi sử dụng CPPC
       để kiểm soát hiệu suất và sức mạnh cho bộ xử lý nền tảng.

PDTT Mục 5.2.29 (chữ ký == "PDTT")

ZZ0000ZZ

Bảng này mô tả các kênh PCC được sử dụng để thu thập nhật ký gỡ lỗi của
       đặc điểm phi kiến trúc.


PMTT Mục 5.2.21.12 (chữ ký == "PMTT")

ZZ0000ZZ

Tùy chọn, hiện không được hỗ trợ.

PPTT Mục 5.2.30 (chữ ký == "PPTT")

ZZ0000ZZ

Bảng này cung cấp cấu trúc liên kết bộ xử lý và bộ đệm.

PSDT Mục 5.2.11.3 (chữ ký == "PSDT")

ZZ0000ZZ

Bảng lỗi thời, sẽ không được hỗ trợ.

RAS2 Mục 5.2.21 (chữ ký == "RAS2")

ZZ0000ZZ

Bảng này cung cấp các giao diện cho các khả năng RAS được triển khai trong
       nền tảng.

RASF Mục 5.2.20 (chữ ký == "RASF")

ZZ0000ZZ

Tùy chọn, hiện không được hỗ trợ.

RSDP Mục 5.2.5 (chữ ký == "RSD PTR")

ZZ0000ZZ

Cần thiết cho arm64.

RSDT Mục 5.2.7 (chữ ký == "RSDT")

ZZ0000ZZ

Vì bảng này chỉ có thể cung cấp địa chỉ 32 bit nên nó không được dùng nữa
       trên arm64 và sẽ không được sử dụng.  Nếu được cung cấp, nó sẽ bị bỏ qua.

SBST Mục 5.2.14 (chữ ký == "SBST")

ZZ0000ZZ

Tùy chọn, hiện không được hỗ trợ.

Chữ ký SDEI được bảo lưu (chữ ký == "SDEI")

ZZ0000ZZ

Bảng này quảng cáo sự hiện diện của giao diện SDEI.

Chữ ký SLIC được bảo lưu (chữ ký == "SLIC")

ZZ0000ZZ

Bảng duy nhất của Microsoft, sẽ không được hỗ trợ.

SLIT Mục 5.2.17 (chữ ký == "SLIT")

ZZ0000ZZ

Nói chung là tùy chọn, nhưng bắt buộc đối với hệ thống NUMA.

Chữ ký SPCR được bảo lưu (chữ ký == "SPCR")

ZZ0000ZZ

Cần thiết cho arm64.

Chữ ký SPMI được bảo lưu (chữ ký == "SPMI")

ZZ0000ZZ

Tùy chọn, hiện không được hỗ trợ.

SRAT Mục 5.2.16 (chữ ký == "SRAT")

ZZ0000ZZ

Tùy chọn, nhưng nếu được sử dụng, chỉ có cấu trúc Mối quan hệ GICC được đọc.
       Để hỗ trợ arm64 NUMA, cần có bảng này.

SSDT Mục 5.2.11.2 (chữ ký == "SSDT")

ZZ0000ZZ

Các bảng này là sự tiếp nối của DSDT; những điều này được khuyến khích
       để sử dụng với các thiết bị có thể được thêm vào hệ thống đang chạy, nhưng có thể
       cũng phục vụ mục đích chia mô tả thiết bị thành nhiều phần hơn
       những phần có thể quản lý được.

SSDT chỉ có thể ADD vào không gian tên ACPI.  Nó không thể sửa đổi hoặc
       thay thế các mô tả thiết bị hiện có trong không gian tên.

Tuy nhiên, những bảng này là tùy chọn.  Các bảng ACPI chỉ được chứa
       một DSDT nhưng có thể chứa nhiều SSDT.

Chữ ký STAO được bảo lưu (chữ ký == "STAO")

ZZ0000ZZ

Tùy chọn, nhưng chỉ cần thiết trong môi trường ảo hóa để
       ẩn thiết bị khỏi hệ điều hành khách.

Chữ ký TCPA được bảo lưu (chữ ký == "TCPA")

ZZ0000ZZ

Tùy chọn, hiện không được hỗ trợ và có thể cần thay đổi hoàn toàn
       tương tác với arm64.

Chữ ký TPM2 được bảo lưu (chữ ký == "TPM2")

ZZ0000ZZ

Tùy chọn, hiện không được hỗ trợ và có thể cần thay đổi hoàn toàn
       tương tác với arm64.

Chữ ký UEFI được bảo lưu (chữ ký == "UEFI")

ZZ0000ZZ

Tùy chọn, hiện không được hỗ trợ.  Không có trường hợp sử dụng nào được biết đến cho arm64,
       hiện tại.

Chữ ký WAET được bảo lưu (chữ ký == "WAET")

ZZ0000ZZ

Bảng duy nhất của Microsoft, sẽ không được hỗ trợ.

Chữ ký WDAT được bảo lưu (chữ ký == "WDAT")

ZZ0000ZZ

Bảng duy nhất của Microsoft, sẽ không được hỗ trợ.

Chữ ký WDRT được bảo lưu (chữ ký == "WDRT")

ZZ0000ZZ

Bảng duy nhất của Microsoft, sẽ không được hỗ trợ.

Chữ ký WPBT được bảo lưu (chữ ký == "WPBT")

ZZ0000ZZ

Bảng duy nhất của Microsoft, sẽ không được hỗ trợ.

Chữ ký XENV được bảo lưu (chữ ký == "XENV")

ZZ0000ZZ

Tùy chọn, hiện tại chỉ được Xen sử dụng.

XSDT Mục 5.2.8 (chữ ký == "XSDT")

ZZ0000ZZ

Cần thiết cho arm64.
====== ==============================================================================

Đối tượng ACPI
------------
Những kỳ vọng về các đối tượng ACPI riêng lẻ có khả năng được sử dụng là
hiển thị trong danh sách sau; bất kỳ đối tượng nào không được đề cập rõ ràng dưới đây
nên được sử dụng khi cần thiết cho một nền tảng cụ thể hoặc hệ thống con cụ thể,
chẳng hạn như quản lý năng lượng hoặc PCI.

===================== ==============================================================
Phần tên Cách sử dụng cho ARMv8 Linux
===================== ==============================================================
_CCA 6.2.17 Phương thức này phải được xác định cho tất cả các bus master
                       trên arm64 - không có giả định nào được đưa ra về
                       liệu các thiết bị đó có kết hợp bộ nhớ đệm hay không.
                       Giá trị _CCA được kế thừa bởi tất cả con cháu của
                       những thiết bị này nên không cần phải lặp lại.
                       Không có _CCA trên arm64 thì kernel không biết là gì
                       cần thực hiện việc thiết lập DMA cho thiết bị.

NB: phương pháp này cung cấp tính kết hợp bộ đệm mặc định
                       thuộc tính; sự hiện diện của SMMU có thể được sử dụng để
                       Tuy nhiên, hãy sửa đổi điều đó.  Ví dụ, một bậc thầy có thể
                       mặc định là không mạch lạc, nhưng được thực hiện mạch lạc với
                       cấu hình SMMU thích hợp (xem Bảng 17 của
                       thông số kỹ thuật IORT, Tài liệu ARM DEN 0049B).

_CID 6.1.2 Sử dụng khi cần thiết, xem thêm _HID.

_CLS 6.1.3 Sử dụng khi cần thiết, xem thêm _HID.

_CPC 8.4.7.1 Sử dụng khi cần thiết, quản lý nguồn điện cụ thể.  CPPC là
                       được đề xuất trên arm64.

_CRS 6.2.2 Bắt buộc trên arm64.

_CSD 8.4.2.2 Sử dụng khi cần thiết, chỉ sử dụng kết hợp với _CST.

Thay vào đó, nên sử dụng _CST 8.4.2.1 Trạng thái không tải công suất thấp (8.4.4)
                       của trạng thái C.

_DDN 6.1.4 Trường này có thể được sử dụng cho tên thiết bị.  Tuy nhiên,
                       nó dành cho tên thiết bị DOS (ví dụ: COM1), vì vậy hãy
                       cẩn thận khi sử dụng nó trên các hệ điều hành.

_DSD 6.2.5 Cần thận trọng khi sử dụng.  Nếu đối tượng này được sử dụng, hãy thử
                       để sử dụng nó trong những ràng buộc đã được xác định bởi
                       Thuộc tính thiết bị UUID.  Chỉ trong những trường hợp hiếm hoi
                       nếu cần thiết phải tạo _DSD UUID mới.

Trong cả hai trường hợp, hãy gửi định nghĩa _DSD cùng với
                       bất kỳ bản vá trình điều khiển nào để thảo luận, đặc biệt là khi
                       thuộc tính thiết bị được sử dụng.  Người lái xe sẽ không
                       được coi là hoàn thành nếu không có _DSD tương ứng
                       mô tả.  Sau khi được các nhà bảo trì kernel chấp thuận,
                       UUID hoặc thuộc tính thiết bị phải được đăng ký
                       với Diễn đàn UEFI; điều này có thể gây ra một số lần lặp lại như
                       nhiều hơn một hệ điều hành sẽ đăng ký các mục.

_DSM 9.1.1 Không sử dụng phương pháp này.  Nó không được tiêu chuẩn hóa,
                       các giá trị trả về không được ghi chép đầy đủ và đó là
                       hiện nay là một nguồn lỗi thường xuyên.

\_GL 5.7.1 Đối tượng này không được sử dụng trong phần cứng bị giảm
                       chế độ này và do đó không nên sử dụng trên arm64.

_GLK 6.5.7 Đối tượng này yêu cầu phải xác định khóa toàn cục; ở đó
                       không có khóa chung trên arm64 vì nó chạy trong phần cứng
                       chế độ giảm.  Do đó, không sử dụng đối tượng này trên arm64.

\_GPE 5.3.1 Không gian tên này chỉ dành cho x86.  Đừng sử dụng nó
                       trên cánh tay64.

_HID 6.1.5 Đây là đối tượng chính được sử dụng trong việc thăm dò thiết bị,
		       mặc dù _CID và _CLS cũng có thể được sử dụng.

_INI 6.5.1 Không bắt buộc nhưng có thể hữu ích trong việc thiết lập thiết bị
                       khi UEFI để chúng ở trạng thái có thể không phải là điều gì
                       người lái xe mong đợi trước khi bắt đầu thăm dò.

_LPI 8.4.4.3 Được khuyến nghị sử dụng với các định nghĩa bộ xử lý (_HID
		       ACPI0010) trên arm64.  Xem thêm _RDI.

_MLS 6.1.7 Rất khuyến khích sử dụng trong quá trình quốc tế hóa.

_OFF 7.2.2 Nên xác định phương pháp này cho mọi thiết bị
                       có thể được bật hoặc tắt.

_ON 7.2.3 Nên xác định phương pháp này cho mọi thiết bị
                       có thể được bật hoặc tắt.

\_OS 5.7.3 Phương thức này sẽ trả về "Linux" theo mặc định (đây là
                       giá trị của macro ACPI_OS_NAME trên Linux).  các
                       tham số dòng lệnh acpi_os=<string> có thể được sử dụng
                       để đặt nó thành một số giá trị khác.

_OSC 6.2.11 Phương pháp này có thể là phương pháp chung trong ACPI (tức là
                       \_SB._OSC) hoặc nó có thể được liên kết với một địa chỉ cụ thể
                       thiết bị (ví dụ: \_SB.DEV0._OSC) hoặc cả hai.  Khi sử dụng
                       như một phương pháp toàn cầu, chỉ những khả năng được công bố trong
                       đặc điểm kỹ thuật ACPI được cho phép.  Khi được sử dụng như
                       một phương pháp dành riêng cho thiết bị, quy trình được mô tả cho
                       sử dụng _DSD MUST được sử dụng để tạo định nghĩa _OSC;
                       Không được phép sử dụng _OSC ngoài quy trình.  Đó là,
                       gửi mô tả cách sử dụng _OSC dành riêng cho thiết bị dưới dạng
                       một phần của quá trình gửi trình điều khiển hạt nhân, hãy phê duyệt nó
                       bởi cộng đồng kernel, sau đó đăng ký nó với
                       Diễn đàn UEFI.

\_OSI 5.7.2 Không được dùng nữa trên ARM64.  Theo như phần sụn ACPI là
		       có liên quan, _OSI không được sử dụng để xác định những gì
		       loại hệ thống đang được sử dụng hoặc chức năng gì
		       được cung cấp.  Phương pháp _OSC sẽ được sử dụng thay thế.

_PDC 8.4.1 Không dùng nữa, không sử dụng trên arm64.

\_PIC 5.8.1 Không nên sử dụng phương pháp này.  Trên arm64, duy nhất
                       mô hình ngắt có sẵn là GIC.

\_PR 5.3.1 Không gian tên này chỉ dành cho x86 trên các hệ thống cũ.
                       Không sử dụng nó trên arm64.

_PRT 6.2.13 Được yêu cầu như một phần của định nghĩa về tất cả gốc PCI
                       thiết bị.

_PRx 7.3.8-11 Sử dụng khi cần thiết; quản lý năng lượng cụ thể.  Nếu _PR0 là
                       được xác định, _PR3 cũng phải được xác định.

_PSx 7.3.2-5 Sử dụng khi cần thiết; quản lý năng lượng cụ thể.  Nếu _PS0 là
                       được xác định, _PS3 cũng phải được xác định.  Nếu đồng hồ hoặc
                       cơ quan quản lý cần điều chỉnh để phù hợp với quyền lực
                       cách sử dụng, hãy thay đổi chúng trong các phương pháp này.

_RDI 8.4.4.4 Được khuyến nghị sử dụng với các định nghĩa bộ xử lý (_HID
		       ACPI0010) trên arm64.  Điều này chỉ nên được sử dụng trong
		       kết hợp với _LPI.

\_REV 5.7.4 Luôn trả về phiên bản mới nhất của ACPI được hỗ trợ.

\_SB 5.3.1 Bắt buộc trên arm64; tất cả các thiết bị phải được xác định trong này
                       không gian tên.

_SLI 6.2.15 Nên sử dụng khi sử dụng bảng SLIT.

_STA 6.3.7, Nên xác định phương pháp này cho mọi thiết bị
       7.2.4 có thể bật hoặc tắt.  Xem thêm bảng STAO
                       cung cấp khả năng ghi đè để ẩn thiết bị trong môi trường ảo hóa
                       môi trường.

_SRS 6.2.16 Sử dụng khi cần thiết; xem thêm _PRS.

_STR 6.1.10 Được khuyến nghị để truyền tải tên thiết bị tới người dùng cuối;
                       điều này được ưu tiên hơn khi sử dụng _DDN.

_SUB 6.1.9 Sử dụng khi cần thiết; _HID hoặc _CID được ưu tiên.

_SUN 6.1.11 Sử dụng khi cần thiết nhưng được khuyến nghị.

_SWS 7.4.3 Sử dụng khi cần thiết; quản lý điện năng cụ thể; điều này có thể
                       yêu cầu thay đổi thông số kỹ thuật để sử dụng trên arm64.

_UID 6.1.12 Được khuyến nghị để phân biệt các thiết bị giống nhau
                       lớp; xác định nó nếu có thể.
===================== ==============================================================




Mô hình sự kiện ACPI
----------------
Không sử dụng các thiết bị khối GPE; những thứ này không được hỗ trợ trong phần cứng giảm
hồ sơ được sử dụng bởi arm64.  Vì không có khối GPE nào được xác định để sử dụng trên ARM
nền tảng, các sự kiện ACPI phải được báo hiệu khác nhau.

Có hai tùy chọn: Ngắt có tín hiệu GPIO (Phần 5.6.5) và
các sự kiện có tín hiệu ngắt (Phần 5.6.9).  Các sự kiện có tín hiệu ngắt là một
tính năng mới trong thông số kỹ thuật ACPI 6.1.  Một trong hai - hoặc cả hai - có thể được sử dụng
trên một nền tảng nhất định và việc sử dụng nền tảng nào có thể phụ thuộc vào các giới hạn trong bất kỳ
đưa ra SoC.  Nếu có thể, nên sử dụng các sự kiện có tín hiệu ngắt.


Điều khiển bộ xử lý ACPI
----------------------
Phần 8 của thông số kỹ thuật ACPI đã thay đổi đáng kể trong phiên bản 6.0.
Bộ xử lý bây giờ phải được xác định là đối tượng Thiết bị với _HID ACPI0007; làm
không sử dụng câu lệnh Bộ xử lý không được dùng nữa trong ASL.  Tất cả các hệ thống đa bộ xử lý
cũng nên xác định hệ thống phân cấp của bộ xử lý, được thực hiện với Bộ chứa bộ xử lý
Thiết bị (xem Phần 8.4.3.1, _HID ACPI0010); không sử dụng bộ tổng hợp bộ xử lý
thiết bị (Phần 8.5) để mô tả cấu trúc liên kết bộ xử lý.  Mục 8.4 của
đặc tả mô tả ngữ nghĩa của các định nghĩa đối tượng này và cách
chúng có mối liên hệ với nhau.

Quan trọng nhất, hệ thống phân cấp bộ xử lý được xác định cũng xác định mức năng lượng thấp
trạng thái nhàn rỗi có sẵn cho nền tảng, cùng với các quy tắc cho
xác định bộ xử lý nào có thể được bật hoặc tắt và các trường hợp
điều khiển cái đó.  Nếu không có thông tin này, bộ xử lý sẽ chạy trong
bất kể trạng thái sức mạnh nào mà UEFI để lại.

Cũng lưu ý rằng các đối tượng Thiết bị bộ xử lý được xác định và các mục trong
MADT dành cho GIC dự kiến sẽ được đồng bộ hóa.  _UID của thiết bị
đối tượng phải tương ứng với ID bộ xử lý được sử dụng trong MADT.

Nên sử dụng CPPC (8.4.5) làm mẫu chính cho bộ xử lý
kiểm soát hiệu suất trên arm64.  Trạng thái C và trạng thái P có thể có sẵn tại
một thời điểm nào đó trong tương lai, nhưng hầu hết các công việc thiết kế hiện tại đều thiên về CPPC.

Hơn nữa, điều cần thiết là ARMv8 SoC cung cấp đầy đủ chức năng
triển khai PSCI; đây sẽ là cơ chế duy nhất được ACPI hỗ trợ
để kiểm soát trạng thái nguồn CPU.  Khởi động CPU thứ cấp bằng ACPI
Có thể sử dụng giao thức đỗ xe, nhưng không được khuyến khích vì chỉ hỗ trợ PSCI
dành cho máy chủ ARM.


Giao diện bản đồ địa chỉ hệ thống ACPI
----------------------------------
Trong Phần 15 của đặc tả ACPI, một số phương pháp được đề cập như
các cơ chế có thể để truyền tải thông tin tài nguyên bộ nhớ tới kernel.
Đối với arm64, chúng tôi sẽ chỉ hỗ trợ UEFI khởi động bằng ACPI, do đó có UEFI
Dịch vụ khởi động GetMemoryMap() là cơ chế duy nhất sẽ được sử dụng.


Giao diện lỗi nền tảng ACPI (APEI)
-------------------------------------
Các bảng APEI được hỗ trợ đã được mô tả ở trên.

APEI yêu cầu tương đương với SCI và NMI trên ARMv8.  SCI được sử dụng
để thông báo cho OSPM về các lỗi đã xảy ra nhưng có thể sửa được và
thống có thể tiếp tục hoạt động bình thường ngay cả khi có thể bị xuống cấp.  NMI là
được sử dụng để chỉ ra những lỗi nghiêm trọng không thể sửa được và yêu cầu ngay lập tức
chú ý.

Vì không có giá trị tương đương trực tiếp với x86 SCI hoặc NMI nên tay cầm arm64
những điều này hơi khác nhau.  SCI được xử lý như một ngắt có mức ưu tiên cao;
cho rằng đây là những lỗi đã được sửa (hoặc có thể sửa được) được báo cáo, điều này
là đủ.  NMI được mô phỏng là ngắt có mức ưu tiên cao nhất
có thể.  Điều này ngụ ý cần phải thận trọng vì có thể có
ngắt ở mức đặc quyền cao hơn hoặc thậm chí ngắt ở cùng mức ưu tiên
như NMI được mô phỏng.  Trong Linux, điều này không nên xảy ra nhưng người ta nên
hãy lưu ý rằng nó có thể xảy ra.


Đối tượng ACPI không được hỗ trợ trên ARM64
-----------------------------------
Mặc dù điều này có thể thay đổi trong tương lai nhưng có một số lớp đối tượng
có thể được xác định, nhưng hiện không được các máy chủ ARM quan tâm chung.
Một số đối tượng này có tương đương x86 và thực sự có thể có ý nghĩa trong ARM
máy chủ.  Tuy nhiên, hiện tại không có phần cứng sẵn có hoặc có
thậm chí có thể chưa phải là triển khai không phải ARM.  Vì thế, hiện tại họ không
được hỗ trợ.

Các lớp đối tượng sau đây không được hỗ trợ:

- Mục 9.2: thiết bị cảm biến ánh sáng xung quanh

- Mục 9.3: thiết bị dùng pin

- Mục 9.4: nắp đậy (ví dụ: nắp máy tính xách tay)

- Mục 9.8.2: Bộ điều khiển IDE

- Mục 9.9: Bộ điều khiển đĩa mềm

- Mục 9.10: Khối thiết bị GPE

- Mục 9.15: Thiết bị PC/AT RTC/CMOS

- Mục 9.16: thiết bị phát hiện sự hiện diện của người dùng

- Mục 9.17: Thiết bị I/O APIC; tất cả GIC phải có thể đếm được thông qua MADT

- Mục 9.18: thiết bị báo giờ và báo động (xem 9.15)

- Mục 10: Thiết bị nguồn điện và đồng hồ đo điện

- Mục 11: Quản lý nhiệt

- Mục 12: Giao diện bộ điều khiển nhúng

- Mục 13: Giao diện SMBus


Điều này cũng có nghĩa là không có hỗ trợ cho các đối tượng sau:

==== ============================= ==== ===========
Tên Phần Tên Phần
==== ============================= ==== ===========
_ALC 9.3.4 _FDM 9.10.3
_ALI 9.3.2 _FIX 6.2.7
_ALP 9.3.6 _GAI 10.4.5
_ALR 9.3.5 _GHL 10.4.7
_ALT 9.3.3 _GTM 9.9.2.1.1
_BCT 10.2.2.10 _LID 9.5.1
_BDN 6.5.3 _PAI 10.4.4
_BIF 10.2.2.1 _PCL 10.3.2
_BIX 10.2.2.1 _PIF 10.3.3
_BLT 9.2.3 _PMC 10.4.1
_BMA 10.2.2.4 _PMD 10.4.8
_BMC 10.2.2.12 _PMM 10.4.3
_BMD 10.2.2.11 _PRL 10.3.4
_BMS 10.2.2.5 _PSR 10.3.1
_BST 10.2.2.6 _PTP 10.4.2
_BTH 10.2.2.7 _SBS 10.1.3
_BTM 10.2.2.9 _SHL 10.4.6
_BTP 10.2.2.8 _STM 9.9.2.1.1
_DCK 6.5.2 _UPD 9.16.1
_EC 12.12 _UPP 9.16.2
_FDE 9.10.1 _WPC 10.5.2
_FDI 9.10.2 _WPP 10.5.3
==== ============================= ==== ===========
