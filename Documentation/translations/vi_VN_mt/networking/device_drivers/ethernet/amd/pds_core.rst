.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/amd/pds_core.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================================================
Trình điều khiển Linux cho dòng bộ điều hợp AMD/Pensando(R) DSC
========================================================

Copyright(c) 2023 Advanced Micro Devices, Inc

Xác định bộ chuyển đổi
=======================

Để tìm xem một hoặc nhiều thiết bị AMD/Pensando PCI Core có được cài đặt trên
máy chủ, hãy kiểm tra các thiết bị PCI::

# lspci -d 1dd8:100c
  b5:00.0 Máy gia tốc xử lý: Thiết bị hệ thống Pensando 100c
  b6:00.0 Máy gia tốc xử lý: Thiết bị hệ thống Pensando 100c

Nếu các thiết bị đó được liệt kê như trên thì trình điều khiển pds_core.ko sẽ tìm
và cấu hình chúng để sử dụng.  Cần có các mục nhật ký trong kernel
những tin nhắn như thế này::

$dmesg | grep pds_core
  pds_core 0000:b5:00.0: Băng thông PCIe khả dụng 252,048 Gb/s (liên kết PCIe x16 16,0 GT/s)
  pds_core 0000:b5:00.0: FW: 1.60.0-73
  pds_core 0000:b6:00.0: Băng thông PCIe khả dụng 252,048 Gb/s (liên kết PCIe x16 16,0 GT/s)
  pds_core 0000:b6:00.0: FW: 1.60.0-73

Thông tin phiên bản trình điều khiển và chương trình cơ sở có thể được thu thập bằng devlink::

$ devlink thông tin nhà phát triển pci/0000:b5:00.0
  pci/0000:b5:00.0:
    trình điều khiển pds_core
    số_sê-ri FLM18420073
    phiên bản:
        đã sửa:
          asic.id 0x0
          asic.rev 0x0
        đang chạy:
          fw 1.51.0-73
        được lưu trữ:
          fw.goldfw 1.15.9-C-22
          fw.mainfwa 1.60.0-73
          fw.mainfwb 1.60.0-57

Phiên bản thông tin
=============

Trình điều khiển ZZ0000ZZ báo cáo các phiên bản sau

.. list-table:: devlink info versions implemented
   :widths: 5 5 90

   * - Name
     - Type
     - Description
   * - ``fw``
     - running
     - Version of firmware running on the device
   * - ``fw.goldfw``
     - stored
     - Version of firmware stored in the goldfw slot
   * - ``fw.mainfwa``
     - stored
     - Version of firmware stored in the mainfwa slot
   * - ``fw.mainfwb``
     - stored
     - Version of firmware stored in the mainfwb slot
   * - ``asic.id``
     - fixed
     - The ASIC type for this device
   * - ``asic.rev``
     - fixed
     - The revision of the ASIC for this device

Thông số
==========

Trình điều khiển ZZ0000ZZ triển khai các tính năng chung sau
các tham số để kiểm soát chức năng được cung cấp
như các thiết bị phụ trợ_bus.

.. list-table:: Generic parameters implemented
   :widths: 5 5 8 82

   * - Name
     - Mode
     - Type
     - Description
   * - ``enable_vnet``
     - runtime
     - Boolean
     - Enables vDPA functionality through an auxiliary_bus device

Quản lý phần mềm
===================

Lệnh ZZ0000ZZ có thể cập nhật chương trình cơ sở DSC.  Phần sụn đã tải xuống
sẽ được lưu vào ngân hàng phần sụn 1 hoặc ngân hàng 2, tùy theo ngân hàng nào không
hiện đang được sử dụng và ngân hàng đó sẽ được sử dụng cho lần khởi động tiếp theo::

# devlink flash dev pci/0000:b5:00.0 \
            tập tin pensando/dsc_fw_1.63.0-22.tar

Phóng viên sức khỏe
================

Trình điều khiển hỗ trợ trình báo cáo tình trạng liên kết phát triển cho trạng thái FW::

# devlink chương trình sức khỏe pci/0000:2b:00.0 phóng viên fw
  pci/0000:2b:00.0:
    phóng viên
      trạng thái khỏe mạnh lỗi 0 khôi phục 0
  # devlink chẩn đoán sức khỏe pci/0000:2b:00.0 phóng viên fw
   Tình trạng: khỏe mạnh Trạng thái: 1 Thế hệ: 0 Số lần phục hồi: 0

Kích hoạt trình điều khiển
===================

Trình điều khiển được kích hoạt thông qua hệ thống cấu hình kernel tiêu chuẩn,
sử dụng lệnh tạo ::

tạo oldconfig/menuconfig/etc.

Trình điều khiển nằm trong cấu trúc menu tại:

-> Trình điều khiển thiết bị
    -> Hỗ trợ thiết bị mạng (NETDEVICES [=y])
      -> Hỗ trợ trình điều khiển Ethernet
        -> Thiết bị AMD
          -> Hỗ trợ AMD/Pensando Ethernet PDS_CORE

Ủng hộ
=======

Để được hỗ trợ mạng Linux nói chung, vui lòng sử dụng gửi thư netdev
danh sách, được giám sát bởi nhân viên AMD/Pensando::

netdev@vger.kernel.org