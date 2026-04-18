.. SPDX-License-Identifier: (GPL-2.0+ OR MIT)

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/gpu/nova/core/fwsec.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
FWSEC (Bảo mật phần sụn)
=========================
Tài liệu này mô tả ngắn gọn/khái niệm về hình ảnh FWSEC (Firmware Security)
và vai trò của nó trong trình tự khởi động GPU. Như vậy, thông tin này phải tuân theo
thay đổi trong tương lai và chỉ hiện tại đối với dòng Ampere GPU. Tuy nhiên,
hy vọng các khái niệm được mô tả sẽ hữu ích cho việc hiểu mã hạt nhân
đó là vấn đề với nó. Tất cả các thông tin đều được lấy từ nguồn công khai
các nguồn như trình điều khiển công cộng và tài liệu.

Vai trò của FWSEC là cung cấp quy trình khởi động an toàn. Nó chạy vào
Chế độ 'Bảo mật cao' và thực hiện xác minh chương trình cơ sở sau khi đặt lại GPU
trước khi tải các hình ảnh ucode khác nhau lên các bộ vi điều khiển khác trên GPU,
chẳng hạn như PMU và GSP.

Bản thân FWSEC là một ứng dụng được lưu trữ trong VBIOS ROM trong phân vùng FWSEC của
ROM (xem vbios.rst để biết thêm chi tiết). Nó chứa các lệnh khác nhau như FRTS
(Dịch vụ thời gian chạy chương trình cơ sở) và SB (Khởi động an toàn các bộ vi điều khiển khác sau
đặt lại và tải chúng bằng ucode không phải FWSEC khác). Trình điều khiển kernel chỉ cần
để thực hiện FRTS, vì Khởi động an toàn (SB) đã hoàn tất vào thời điểm trình điều khiển
được tải.

Lệnh FRTS khắc ra vùng WPR2 (Vùng được bảo vệ ghi) chứa
dữ liệu cần thiết cho việc quản lý năng lượng. Sau khi thiết lập, chỉ ucode chế độ HS mới có thể truy cập nó
(xem falcon.rst để biết mức đặc quyền).

Hình ảnh FWSEC nằm trong VBIOS ROM trong phân vùng của ROM chứa
nhiều hình ảnh ucode khác nhau (còn được gọi là ứng dụng) - một trong số đó là FWSEC. Để làm thế nào
nó được trích xuất, xem vbios.rst và mã nguồn vbios.rs.

Dữ liệu Falcon cho mỗi hình ảnh ucode (bao gồm cả hình ảnh FWSEC) là sự kết hợp
của tiêu đề, phần dữ liệu (DMEM) và phần mã lệnh (IMEM). Tất cả những điều này
hình ảnh ucode được lưu trữ trong cùng một phân vùng ROM và bảng PMU được sử dụng để xem
thiết lập ứng dụng để tải nó dựa trên ID ứng dụng của nó (xem vbios.rs).

Đối với trình điều khiển nova-core, FWSEC chứa 'giao diện ứng dụng' được gọi là
DMEMMAPPER. Giao diện này được sử dụng để thực thi lệnh 'FWSEC-FRTS', cùng với các lệnh khác.
Đối với Ampere, FWSEC đang chạy trên GSP ở chế độ Bảo mật cao và chạy FRTS.

Bố cục bộ nhớ FWSEC
-------------------
Bố cục bộ nhớ của hình ảnh FWSEC như sau::

   +---------------------------------------------------------------+
   |                         FWSEC ROM image (type 0xE0)           |
   |                                                               |
   |  +---------------------------------+                          |
   |  |     PMU Falcon Ucode Table      |                          |
   |  |     (PmuLookupTable)            |                          |
   |  |  +-------------------------+    |                          |
   |  |  | Table Header            |    |                          |
   |  |  | - version: 0x01         |    |                          |
   |  |  | - header_size: 6        |    |                          |
   |  |  | - entry_size: 6         |    |                          |
   |  |  | - entry_count: N        |    |                          |
   |  |  | - desc_version:3(unused)|    |                          |
   |  |  +-------------------------+    |                          |
   |  |         ...                     |                          |
   |  |  +-------------------------+    |                          |
   |  |  | Entry for FWSEC (0x85)  |    |                          |
   |  |  | (PmuLookupTableEntry)   |    |                          |
   |  |  | - app_id: 0x85 (FWSEC)  |----|----+                     |
   |  |  | - target_id: 0x01 (PMU) |    |    |                     |
   |  |  | - data: offset ---------|----|----|---+ look up FWSEC   |
   |  |  +-------------------------+    |    |   |                 |
   |  +---------------------------------+    |   |                 |
   |                                         |   |                 |
   |                                         |   |                 |
   |  +---------------------------------+    |   |                 |
   |  |     FWSEC Ucode Component       |<---+   |                 |
   |  |     (aka Falcon data)           |        |                 |
   |  |  +-------------------------+    |        |                 |
   |  |  | FalconUCodeDescV3       |<---|--------+                 |
   |  |  | - hdr                   |    |                          |
   |  |  | - stored_size           |    |                          |
   |  |  | - pkc_data_offset       |    |                          |
   |  |  | - interface_offset -----|----|----------------+         |
   |  |  | - imem_phys_base        |    |                |         |
   |  |  | - imem_load_size        |    |                |         |
   |  |  | - imem_virt_base        |    |                |         |
   |  |  | - dmem_phys_base        |    |                |         |
   |  |  | - dmem_load_size        |    |                |         |
   |  |  | - engine_id_mask        |    |                |         |
   |  |  | - ucode_id              |    |                |         |
   |  |  | - signature_count       |    |    look up sig |         |
   |  |  | - signature_versions --------------+          |         |
   |  |  +-------------------------+    |     |          |         |
   |  |         (no gap)                |     |          |         |
   |  |  +-------------------------+    |     |          |         |
   |  |  | Signatures Section      |<---|-----+          |         |
   |  |  | (384 bytes per sig)     |    |                |         |
   |  |  | - RSA-3K Signature 1    |    |                |         |
   |  |  | - RSA-3K Signature 2    |    |                |         |
   |  |  |   ...                   |    |                |         |
   |  |  +-------------------------+    |                |         |
   |  |                                 |                |         |
   |  |  +-------------------------+    |                |         |
   |  |  | IMEM Section (Code)     |    |                |         |
   |  |  |                         |    |                |         |
   |  |  | Contains instruction    |    |                |         |
   |  |  | code etc.               |    |                |         |
   |  |  +-------------------------+    |                |         |
   |  |                                 |                |         |
   |  |  +-------------------------+    |                |         |
   |  |  | DMEM Section (Data)     |    |                |         |
   |  |  |                         |    |                |         |
   |  |  | +---------------------+ |    |                |         |
   |  |  | | Application         | |<---|----------------+         |
   |  |  | | Interface Table     | |    |                          |
   |  |  | | (FalconAppifHdrV1)  | |    |                          |
   |  |  | | Header:             | |    |                          |
   |  |  | | - version: 0x01     | |    |                          |
   |  |  | | - header_size: 4    | |    |                          |
   |  |  | | - entry_size: 8     | |    |                          |
   |  |  | | - entry_count: N    | |    |                          |
   |  |  | |                     | |    |                          |
   |  |  | | Entries:            | |    |                          |
   |  |  | | +-----------------+ | |    |                          |
   |  |  | | | DEVINIT (ID 1)  | | |    |                          |
   |  |  | | | - id: 0x01      | | |    |                          |
   |  |  | | | - dmemOffset X -|-|-|----+                          |
   |  |  | | +-----------------+ | |    |                          |
   |  |  | | +-----------------+ | |    |                          |
   |  |  | | | DMEMMAPPER(ID 4)| | |    |                          |
   |  |  | | | - id: 0x04      | | |    | Used only for DevInit    |
   |  |  | | |  (NVFW_FALCON_  | | |    | application (not FWSEC)  |
   |  |  | | |   APPIF_ID_DMEMMAPPER)   |                          |
   |  |  | | | - dmemOffset Y -|-|-|----|-----+                    |
   |  |  | | +-----------------+ | |    |     |                    |
   |  |  | +---------------------+ |    |     |                    |
   |  |  |                         |    |     |                    |
   |  |  | +---------------------+ |    |     |                    |
   |  |  | | DEVINIT Engine      |<|----+     | Used by FWSEC      |
   |  |  | | Interface           | |    |     |         app.       |
   |  |  | +---------------------+ |    |     |                    |
   |  |  |                         |    |     |                    |
   |  |  | +---------------------+ |    |     |                    |
   |  |  | | DMEM Mapper (ID 4)  |<|----+-----+                    |
   |  |  | | (FalconAppifDmemmapperV3)  |                          |
   |  |  | | - signature: "DMAP" | |    |                          |
   |  |  | | - version: 0x0003   | |    |                          |
   |  |  | | - Size: 64 bytes    | |    |                          |
   |  |  | | - cmd_in_buffer_off | |----|------------+             |
   |  |  | | - cmd_in_buffer_size| |    |            |             |
   |  |  | | - cmd_out_buffer_off| |----|------------|-----+       |
   |  |  | | - cmd_out_buffer_sz | |    |            |     |       |
   |  |  | | - init_cmd          | |    |            |     |       |
   |  |  | | - features          | |    |            |     |       |
   |  |  | | - cmd_mask0/1       | |    |            |     |       |
   |  |  | +---------------------+ |    |            |     |       |
   |  |  |                         |    |            |     |       |
   |  |  | +---------------------+ |    |            |     |       |
   |  |  | | Command Input Buffer|<|----|------------+     |       |
   |  |  | | - Command data      | |    |                  |       |
   |  |  | | - Arguments         | |    |                  |       |
   |  |  | +---------------------+ |    |                  |       |
   |  |  |                         |    |                  |       |
   |  |  | +---------------------+ |    |                  |       |
   |  |  | | Command Output      |<|----|------------------+       |
   |  |  | | Buffer              | |    |                          |
   |  |  | | - Results           | |    |                          |
   |  |  | | - Status            | |    |                          |
   |  |  | +---------------------+ |    |                          |
   |  |  +-------------------------+    |                          |
   |  +---------------------------------+                          |
   |                                                               |
   +---------------------------------------------------------------+

.. note::
   This is using an GA-102 Ampere GPU as an example and could vary for future GPUs.

.. note::
   The FWSEC image also plays a role in memory scrubbing (ECC initialization) and VPR
   (Video Protected Region) initialization as well. Before the nova-core driver is even
   loaded, the FWSEC image is running on the GSP in heavy-secure mode. After the devinit
   sequence completes, it does VRAM memory scrubbing (ECC initialization). On consumer
   GPUs, it scrubs only part of memory and then initiates 'async scrubbing'. Before this
   async scrubbing completes, the unscrubbed VRAM cannot be used for allocation (thus DRM
   memory allocators need to wait for this scrubbing to complete).