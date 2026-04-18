.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/sfc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
hỗ trợ liên kết phát triển sfc
==============================

Tài liệu này mô tả các tính năng của devlink được ZZ0000ZZ triển khai
trình điều khiển thiết bị cho thiết bị ef10 và ef100.

Phiên bản thông tin
===================

Trình điều khiển ZZ0000ZZ báo cáo các phiên bản sau

.. list-table:: devlink info versions implemented
   :widths: 5 5 90

   * - Name
     - Type
     - Description
   * - ``fw.bundle_id``
     - stored
     - Version of the firmware "bundle" image that was last used to update
       multiple components.
   * - ``fw.mgmt.suc``
     - running
     - For boards where the management function is split between multiple
       control units, this is the SUC control unit's firmware version.
   * - ``fw.mgmt.cmc``
     - running
     - For boards where the management function is split between multiple
       control units, this is the CMC control unit's firmware version.
   * - ``fpga.rev``
     - running
     - FPGA design revision.
   * - ``fpga.app``
     - running
     - Datapath programmable logic version.
   * - ``fw.app``
     - running
     - Datapath software/microcode/firmware version.
   * - ``coproc.boot``
     - running
     - SmartNIC application co-processor (APU) first stage boot loader version.
   * - ``coproc.uboot``
     - running
     - SmartNIC application co-processor (APU) co-operating system loader version.
   * - ``coproc.main``
     - running
     - SmartNIC application co-processor (APU) main operating system version.
   * - ``coproc.recovery``
     - running
     - SmartNIC application co-processor (APU) recovery operating system version.
   * - ``fw.exprom``
     - running
     - Expansion ROM version. For boards where the expansion ROM is split between
       multiple images (e.g. PXE and UEFI), this is the specifically the PXE boot
       ROM version.
   * - ``fw.uefi``
     - running
     - UEFI driver version (No UNDI support).

Cập nhật nhanh
==============

Trình điều khiển ZZ0000ZZ triển khai hỗ trợ cập nhật flash bằng cách sử dụng
Giao diện ZZ0001ZZ. Nó hỗ trợ cập nhật flash thiết bị bằng cách sử dụng
hình ảnh flash kết hợp ("gói") có chứa nhiều thành phần (trên ef10,
điển hình là ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ và ZZ0005ZZ).

Trình điều khiển không hỗ trợ bất kỳ cờ mặt nạ ghi đè nào.