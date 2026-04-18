.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/loongarch/irq-chip-model.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========================================
Model chip IRQ (phân cấp) của LoongArch
=======================================

Hiện tại, bộ xử lý dựa trên LoongArch (ví dụ Loongson-3A5000) chỉ có thể hoạt động cùng nhau
với chipset LS7A. Các chip irq trong máy tính LoongArch bao gồm CPUINTC (CPU Core
Bộ điều khiển ngắt), LIOINTC (Bộ điều khiển ngắt I/O kế thừa), EIOINTC (Mở rộng
Bộ điều khiển ngắt I/O), HTVECINTC (Bộ điều khiển ngắt vectơ siêu truyền tải),
PCH-PIC (Bộ điều khiển ngắt chính trong chipset LS7A), PCH-LPC (Bộ điều khiển ngắt LPC
trong chipset LS7A) và PCH-MSI (Bộ điều khiển ngắt MSI).

CPUINTC là bộ điều khiển từng lõi (trong CPU), LIOINTC/EIOINTC/HTVECINTC là mỗi gói
bộ điều khiển (trong CPU), trong khi PCH-PIC/PCH-LPC/PCH-MSI là các bộ điều khiển ngoài CPU (tức là,
trong chipset). Các bộ điều khiển này (nói cách khác là irqchip) được liên kết theo hệ thống phân cấp,
và có hai mô hình phân cấp (mô hình kế thừa và mô hình mở rộng).

Mẫu IRQ kế thừa
================

Trong mô hình này, ngắt IPI (Ngắt giữa các bộ xử lý) và ngắt hẹn giờ cục bộ CPU sẽ hoạt động
trực tiếp tới CPUINTC, các ngắt CPU UARTS sẽ chuyển đến LIOINTC, trong khi tất cả các thiết bị khác
các ngắt đi đến PCH-PIC/PCH-LPC/PCH-MSI và được tập hợp bởi HTVECINTC, sau đó đi
tới LIOINTC và sau đó là CPUINTC::

+------+ +----------+ +-------+
     ZZ0000ZZ --> ZZ0001ZZ <-- ZZ0002ZZ
     +------+ +----------+ +-------+
                      ^
                      |
                 +----------+ +-------+
                 ZZ0003ZZ <-- ZZ0004ZZ
                 +----------+ +-------+
                      ^
                      |
                +----------+
                ZZ0005ZZ
                +----------+
                 ^ ^
                 ZZ0006ZZ
           +----------+ +----------+
           ZZ0007ZZ ZZ0008ZZ
           +----------+ +----------+
             ^ ^ ^
             ZZ0009ZZ |
     +----------+ +----------+ +----------+
     ZZ0010ZZ ZZ0011ZZ ZZ0012ZZ
     +----------+ +----------+ +----------+
          ^
          |
     +----------+
     ZZ0013ZZ
     +----------+

Mẫu IRQ mở rộng
==================

Trong mô hình này, ngắt IPI (Ngắt giữa các bộ xử lý) và ngắt hẹn giờ cục bộ CPU sẽ hoạt động
trực tiếp tới CPUINTC, các ngắt CPU UARTS sẽ chuyển đến LIOINTC, trong khi tất cả các thiết bị khác
các ngắt đi đến PCH-PIC/PCH-LPC/PCH-MSI và được tập hợp bởi EIOINTC, sau đó đi đến
tới CPUINTC trực tiếp::

+------+ +----------+ +-------+
          ZZ0000ZZ --> ZZ0001ZZ <-- ZZ0002ZZ
          +------+ +----------+ +-------+
                       ^ ^
                       ZZ0003ZZ
                +----------+ +----------+ +-------+
                ZZ0004ZZ ZZ0005ZZ <-- ZZ0006ZZ
                +----------+ +----------+ +-------+
                 ^ ^
                 ZZ0007ZZ
          +----------+ +----------+
          ZZ0008ZZ ZZ0009ZZ
          +----------+ +----------+
            ^ ^ ^
            ZZ0010ZZ |
    +----------+ +----------+ +----------+
    ZZ0011ZZ ZZ0012ZZ ZZ0013ZZ
    +----------+ +----------+ +----------+
         ^
         |
    +----------+
    ZZ0014ZZ
    +----------+

Mô hình IRQ mở rộng ảo
==========================

Trong mô hình này, ngắt IPI (Ngắt giữa các bộ xử lý) và ngắt hẹn giờ cục bộ CPU
đi trực tiếp đến CPUINTC, các ngắt CPU UARTS sẽ đi tới PCH-PIC, trong khi tất cả các ngắt khác
các thiết bị bị gián đoạn đi tới PCH-PIC/PCH-MSI và được tập hợp bởi V-EIOINTC (Virtual
Bộ điều khiển ngắt I/O mở rộng), sau đó truy cập trực tiếp vào CPUINTC ::

+------+ +-------------------+ +-------+
       ZZ0000ZZ-> ZZ0001ZZ <- ZZ0002ZZ
       +------+ +-------------------+ +-------+
                            ^
                            |
                      +----------+
                      ZZ0003ZZ
                      +----------+
                       ^ ^
                       ZZ0004ZZ
                +----------+ +----------+
                ZZ0005ZZ ZZ0006ZZ
                +----------+ +----------+
                  ^ ^ ^
                  ZZ0007ZZ |
           +--------+ +----------+ +---------+
           ZZ0008ZZ ZZ0009ZZ ZZ0010ZZ
           +--------+ +----------+ +---------+


Sự miêu tả
-----------
V-EIOINTC (Bộ điều khiển ngắt I/O mở rộng ảo) là phần mở rộng của
EIOINTC, nó chỉ hoạt động ở chế độ VM chạy trong bộ ảo hóa KVM. Ngắt có thể
được định tuyến tới tối đa bốn vCPU thông qua EIOINTC tiêu chuẩn, tuy nhiên với V-EIOINTC
các ngắt có thể được định tuyến tới tối đa 256 CPU ảo.

Với EIOINTC tiêu chuẩn, cài đặt định tuyến ngắt bao gồm hai phần: tám
các bit cho lựa chọn CPU và bốn bit cho lựa chọn CPU IP (Pin ngắt).
Đối với lựa chọn CPU, có bốn bit để lựa chọn nút EIOINTC, bốn bit
để lựa chọn EIOINTC CPU. Phương pháp bitmap được sử dụng để lựa chọn CPU và
Lựa chọn IP CPU, do đó ngắt chỉ có thể định tuyến đến CPU0 - CPU3 và IP0-IP3 trong
một nút EIOINTC.

Với V-EIOINTC, nó hỗ trợ định tuyến nhiều CPU hơn và CPU IP (Pin ngắt),
có hai thanh ghi mới được thêm vào với V-EIOINTC.

EXTIOI_VIRT_FEATURES
--------------------
Thanh ghi này là thanh ghi chỉ đọc, cho biết các tính năng được hỗ trợ với
V-EIOINTC. Tính năng EXTIOI_HAS_INT_ENCODE và EXTIOI_HAS_CPU_ENCODE được thêm vào.

Tính năng EXTIOI_HAS_INT_ENCODE là một phần của EIOINTC tiêu chuẩn. Nếu là 1 thì nó
chỉ ra rằng việc lựa chọn Pin ngắt CPU có thể là phương pháp bình thường thay vì
phương pháp bitmap, do đó ngắt có thể được định tuyến tới IP0 - IP15.

Tính năng EXTIOI_HAS_CPU_ENCODE là phần mở rộng của V-EIOINTC. Nếu là 1 thì nó
chỉ ra rằng lựa chọn CPU có thể là phương pháp bình thường thay vì phương pháp bitmap,
vì vậy ngắt có thể được định tuyến tới CPU0 - CPU255.

EXTIOI_VIRT_CONFIG
------------------
Thanh ghi này là thanh ghi đọc-ghi, để sử dụng định tuyến ngắt tương thích
phương thức mặc định giống với EIOINTC tiêu chuẩn. Nếu bit được đặt
với 1, nó cho biết HW sử dụng phương pháp thông thường thay vì phương pháp bitmap.

Mẫu IRQ mở rộng nâng cao
===========================

Trong mô hình này, ngắt IPI (Ngắt giữa các bộ xử lý) và ngắt hẹn giờ cục bộ CPU sẽ hoạt động
trực tiếp tới CPUINTC, các ngắt CPU UARTS đi tới LIOINTC, các ngắt PCH-MSI đi tới
tới AVECINTC, sau đó truy cập trực tiếp vào CPUINTC, trong khi tất cả các thiết bị khác đều ngắt
đi tới PCH-PIC/PCH-LPC và được tập hợp bởi EIOINTC, sau đó truy cập trực tiếp vào CPUINTC::

+------+ +--------------+ +-------+
 ZZ0000ZZ --> ZZ0001ZZ <-- ZZ0002ZZ
 +------+ +--------------+ +-------+
              ^ ^ ^
              ZZ0003ZZ |
       +----------+ +----------+ +----------+ +-------+
       ZZ0004ZZ ZZ0005ZZ ZZ0006ZZ <-- ZZ0007ZZ
       +----------+ +----------+ +----------+ +-------+
            ^ ^
            ZZ0008ZZ
       +----------+ +----------+
       ZZ0009ZZ ZZ0010ZZ
       +----------+ +----------+
         ^ ^ ^
         ZZ0011ZZ |
 +----------+ +----------+ +----------+
 ZZ0012ZZ ZZ0013ZZ ZZ0014ZZ
 +----------+ +----------+ +----------+
                  ^
                  |
             +----------+
             ZZ0015ZZ
             +----------+

Các định nghĩa liên quan đến ACPI
========================

CPUINTC::

ACPI_MADT_TYPE_CORE_PIC;
  cấu trúc acpi_madt_core_pic;
  enum acpi_madt_core_pic_version;

LIOINTC::

ACPI_MADT_TYPE_LIO_PIC;
  cấu trúc acpi_madt_lio_pic;
  enum acpi_madt_lio_pic_version;

EIOINTC::

ACPI_MADT_TYPE_EIO_PIC;
  cấu trúc acpi_madt_eio_pic;
  enum acpi_madt_eio_pic_version;

HTVECINTC::

ACPI_MADT_TYPE_HT_PIC;
  cấu trúc acpi_madt_ht_pic;
  enum acpi_madt_ht_pic_version;

PCH-PIC::

ACPI_MADT_TYPE_BIO_PIC;
  cấu trúc acpi_madt_bio_pic;
  enum acpi_madt_bio_pic_version;

PCH-MSI::

ACPI_MADT_TYPE_MSI_PIC;
  cấu trúc acpi_madt_msi_pic;
  enum acpi_madt_msi_pic_version;

PCH-LPC::

ACPI_MADT_TYPE_LPC_PIC;
  cấu trúc acpi_madt_lpc_pic;
  enum acpi_madt_lpc_pic_version;

Tài liệu tham khảo
==========

Tài liệu của Loongson-3A5000:

ZZ0000ZZ (bằng tiếng Trung Quốc)

ZZ0000ZZ (bằng tiếng Anh)

Tài liệu về chipset LS7A của Loongson:

ZZ0000ZZ (bằng tiếng Trung Quốc)

ZZ0000ZZ (bằng tiếng Anh)

.. Note::
    - CPUINTC is CSR.ECFG/CSR.ESTAT and its interrupt controller described
      in Section 7.4 of "LoongArch Reference Manual, Vol 1";
    - LIOINTC is "Legacy I/OInterrupts" described in Section 11.1 of
      "Loongson 3A5000 Processor Reference Manual";
    - EIOINTC is "Extended I/O Interrupts" described in Section 11.2 of
      "Loongson 3A5000 Processor Reference Manual";
    - HTVECINTC is "HyperTransport Interrupts" described in Section 14.3 of
      "Loongson 3A5000 Processor Reference Manual";
    - PCH-PIC/PCH-MSI is "Interrupt Controller" described in Section 5 of
      "Loongson 7A1000 Bridge User Manual";
    - PCH-LPC is "LPC Interrupts" described in Section 24.3 of
      "Loongson 7A1000 Bridge User Manual".