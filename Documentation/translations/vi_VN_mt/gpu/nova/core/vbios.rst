.. SPDX-License-Identifier: (GPL-2.0+ OR MIT)

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/gpu/nova/core/vbios.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========
VBIOS
==========
Tài liệu này mô tả bố cục của hình ảnh VBIOS là một chuỗi các hình ảnh được ghép nối
hình ảnh trong ROM của GPU. VBIOS được phản chiếu vào không gian BAR 0 và được đọc
bởi cả firmware Boot ROM (còn được gọi là IFR hoặc firmware init-from-rom) trên GPU để
khởi động các bộ vi điều khiển khác nhau (PMU, SEC, GSP) với quá trình khởi tạo quan trọng trước
trình điều khiển tải, cũng như trình điều khiển nova-core trong kernel để khởi động GSP.

Định dạng của hình ảnh trong ROM tuân theo phần "Thông số kỹ thuật BIOS" của
Thông số kỹ thuật PCI, với các phần mở rộng dành riêng cho Nvidia. Hình ảnh ROM thuộc loại FwSec
là những cái có chứa ucode Falcon và những gì chúng tôi chủ yếu tìm kiếm.

Ví dụ: sau đây là các loại hình ảnh khác nhau có thể tìm thấy trong
VBIOS của Ampere GA102 GPU được hỗ trợ bởi trình điều khiển nova-core.

- PciAt Image (Loại 0x00) - Đây là image PCI BIOS tiêu chuẩn, có tên
  có thể đến từ kiến trúc "IBM PC/AT".

- Hình ảnh EFI (Loại 0x03) - Đây là hình ảnh EFI BIOS. Nó chứa UEFI GOP
  trình điều khiển được sử dụng để hiển thị đầu ra đồ họa UEFI.

- Hình ảnh FwSec đầu tiên (Loại 0xE0) - Hình ảnh FwSec đầu tiên (Firmware bảo mật)

- Hình ảnh FwSec thứ hai (Loại 0xE0) - Hình ảnh FwSec thứ hai (Firmware bảo mật)
  chứa nhiều vi mã khác nhau (còn được gọi là ứng dụng) thực hiện một phạm vi
  của các chức năng khác nhau. Ucode FWSEC được chạy ở chế độ bảo mật cao và
  thường chạy trực tiếp trên GSP (nó có thể chạy trên một thiết bị khác
  bộ xử lý được chỉ định ở các thế hệ tương lai nhưng đối với Ampere, nó là GSP).
  Phần sụn này sau đó tải các ucode phần sụn khác vào PMU và SEC2
  bộ vi điều khiển để khởi tạo gfw sau khi đặt lại GPU và trước trình điều khiển
  tải (xem deinit.rst). Bản thân ucode DEVINIT là một ucode khác
  được lưu trữ trong phân vùng ROM này.

Sau khi được xác định, các ucode của Falcon có "Giao diện ứng dụng" trong dữ liệu của chúng
bộ nhớ (DMEM). Đối với FWSEC, giao diện ứng dụng chúng tôi sử dụng cho FWSEC là
Giao diện "DMEM Mapper" được định cấu hình để chạy lệnh "FRTS". Cái này
lệnh khắc ra WPR2 (Vùng được bảo vệ ghi) trong VRAM. Sau đó nó đặt
dữ liệu quản lý năng lượng quan trọng, được gọi là 'FRTS', vào khu vực này. WPR2
khu vực chỉ có thể truy cập được bằng ucode bảo mật cao.

.. note::
   It is not clear why FwSec has 2 different partitions in the ROM, but they both
   are of type 0xE0 and can be identified as such. This could be subject to change
   in future generations.

Bố cục VBIOS ROM
----------------
Bố cục VBIOS đại khái là một loạt các hình ảnh được ghép nối được trình bày như sau::

    +----------------------------------------------------------------------------+
    | VBIOS (Starting at ROM_OFFSET: 0x300000)                                   |
    +----------------------------------------------------------------------------+
    | +-----------------------------------------------+                          |
    | | PciAt Image (Type 0x00)                       |                          |
    | +-----------------------------------------------+                          |
    | | +-------------------+                         |                          |
    | | | ROM Header        |                         |                          |
    | | | (Signature 0xAA55)|                         |                          |
    | | +-------------------+                         |                          |
    | |         | rom header's pci_data_struct_offset |                          |
    | |         | points to the PCIR structure        |                          |
    | |         V                                     |                          |
    | | +-------------------+                         |                          |
    | | | PCIR Structure    |                         |                          |
    | | | (Signature "PCIR")|                         |                          |
    | | | last_image: 0x80  |                         |                          |
    | | | image_len: size   |                         |                          |
    | | | in 512-byte units |                         |                          |
    | | +-------------------+                         |                          |
    | |         |                                     |                          |
    | |         | NPDE immediately follows PCIR       |                          |
    | |         V                                     |                          |
    | | +-------------------+                         |                          |
    | | | NPDE Structure    |                         |                          |
    | | | (Signature "NPDE")|                         |                          |
    | | | last_image: 0x00  |                         |                          |
    | | +-------------------+                         |                          |
    | |                                               |                          |
    | | +-------------------+                         |                          |
    | | | BIT Header        | (Signature scanning     |                          |
    | | | (Signature "BIT") |  provides the location  |                          |
    | | +-------------------+  of the BIT table)      |                          |
    | |         | header is                           |                          |
    | |         | followed by a table of tokens       |                          |
    | |         V one of which is for falcon data.    |                          |
    | | +-------------------+                         |                          |
    | | | BIT Tokens        |                         |                          |
    | | |  ______________   |                         |                          |
    | | | | Falcon Data |   |                         |                          |
    | | | | Token (0x70)|---+------------>------------+--+                       |
    | | | +-------------+   |  falcon_data_ptr()      |  |                       |
    | | +-------------------+                         |  V                       |
    | +-----------------------------------------------+  |                       |
    |              (no gap between images)               |                       |
    | +-----------------------------------------------+  |                       |
    | | EFI Image (Type 0x03)                         |  |                       |
    | +-----------------------------------------------+  |                       |
    | | Contains the UEFI GOP driver (Graphics Output)|  |                       |
    | | +-------------------+                         |  |                       |
    | | | ROM Header        |                         |  |                       |
    | | +-------------------+                         |  |                       |
    | | | PCIR Structure    |                         |  |                       |
    | | +-------------------+                         |  |                       |
    | | | NPDE Structure    |                         |  |                       |
    | | +-------------------+                         |  |                       |
    | | | Image data        |                         |  |                       |
    | | +-------------------+                         |  |                       |
    | +-----------------------------------------------+  |                       |
    |              (no gap between images)               |                       |
    | +-----------------------------------------------+  |                       |
    | | First FwSec Image (Type 0xE0)                 |  |                       |
    | +-----------------------------------------------+  |                       |
    | | +-------------------+                         |  |                       |
    | | | ROM Header        |                         |  |                       |
    | | +-------------------+                         |  |                       |
    | | | PCIR Structure    |                         |  |                       |
    | | +-------------------+                         |  |                       |
    | | | NPDE Structure    |                         |  |                       |
    | | +-------------------+                         |  |                       |
    | | | Image data        |                         |  |                       |
    | | +-------------------+                         |  |                       |
    | +-----------------------------------------------+  |                       |
    |              (no gap between images)               |                       |
    | +-----------------------------------------------+  |                       |
    | | Second FwSec Image (Type 0xE0)                |  |                       |
    | +-----------------------------------------------+  |                       |
    | | +-------------------+                         |  |                       |
    | | | ROM Header        |                         |  |                       |
    | | +-------------------+                         |  |                       |
    | | | PCIR Structure    |                         |  |                       |
    | | +-------------------+                         |  |                       |
    | | | NPDE Structure    |                         |  |                       |
    | | +-------------------+                         |  |                       |
    | |                                               |  |                       |
    | | +-------------------+                         |  |                       |
    | | | PMU Lookup Table  | <- falcon_data_offset <----+                       |
    | | | +-------------+   |    pmu_lookup_table     |                          |
    | | | | Entry 0x85  |   |                         |                          |
    | | | | FWSEC_PROD  |   |                         |                          |
    | | | +-------------+   |                         |                          |
    | | +-------------------+                         |                          |
    | |         |                                     |                          |
    | |         | points to                           |                          |
    | |         V                                     |                          |
    | | +-------------------+                         |                          |
    | | | FalconUCodeDescV3 | <- falcon_ucode_offset  |                          |
    | | | (FWSEC Firmware)  |    fwsec_header()       |                          |
    | | +-------------------+                         |                          |
    | |         |   immediately followed  by...       |                          |
    | |         V                                     |                          |
    | | +----------------------------+                |                          |
    | | | Signatures + FWSEC Ucode   |                |                          |
    | | | fwsec_sigs(), fwsec_ucode()|                |                          |
    | | +----------------------------+                |                          |
    | +-----------------------------------------------+                          |
    |                                                                            |
    +----------------------------------------------------------------------------+

.. note::
   This diagram is created based on an GA-102 Ampere GPU as an example and could
   vary for future or other GPUs.

.. note::
   For more explanations of acronyms, see the detailed descriptions in `vbios.rs`.

Tra cứu dữ liệu Falcon
------------------
Một phần quan trọng của mã trích xuất VBIOS (vbios.rs) là tìm vị trí của
Dữ liệu chim ưng trong VBIOS chứa bảng tra cứu PMU. Bảng tra cứu này là
được sử dụng để tìm ucode Falcon cần thiết dựa trên ID ứng dụng.

Vị trí của bảng tra cứu PMU được tìm thấy bằng cách quét BIT (ZZ0000ZZ)
mã thông báo cho mã thông báo có id ZZ0001ZZ (0x70) cho biết
độ lệch tương tự từ đầu hình ảnh VBIOS. Thật không may, sự bù đắp
không tính đến hình ảnh EFI nằm giữa hình ảnh PciAt và FwSec.
Mã ZZ0002ZZ bù đắp cho điều này bằng số học thích hợp.

.. _`BIOS Information Table`: https://download.nvidia.com/open-gpu-doc/BIOS-Information-Table/1/BIOS-Information-Table.html