.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/amd/pds_vfio_pci.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. note: can be edited and viewed with /usr/bin/formiko-vim

===============================================================
Trình điều khiển PCI VFIO dành cho dòng bộ chuyển đổi AMD/Pensando(R) DSC
==========================================================

Trình điều khiển thiết bị AMD/Pensando Linux VFIO PCI
Bản quyền(c) 2023 Advanced Micro Devices, Inc.

Tổng quan
========

Mô-đun ZZ0000ZZ là trình điều khiển PCI hỗ trợ Di chuyển trực tiếp
các thiết bị Chức năng ảo (VF) có khả năng trong phần cứng DSC.

Sử dụng thiết bị
================

Thiết bị pds-vfio-pci được kích hoạt thông qua nhiều bước cấu hình và
phụ thuộc vào trình điều khiển ZZ0000ZZ để tạo và kích hoạt SR-IOV Virtual
Các thiết bị chức năng

Dưới đây là các bước để liên kết trình điều khiển với VF và cả với
thiết bị phụ trợ liên quan được tạo bởi trình điều khiển ZZ0000ZZ. Cái này
ví dụ giả sử các mô-đun pds_core và pds-vfio-pci đã có sẵn
đã tải.

.. code-block:: bash
  :name: example-setup-script

  #!/bin/bash

  PF_BUS="0000:60"
  PF_BDF="0000:60:00.0"
  VF_BDF="0000:60:00.1"

  # Prevent non-vfio VF driver from probing the VF device
  echo 0 > /sys/class/pci_bus/$PF_BUS/device/$PF_BDF/sriov_drivers_autoprobe

  # Create single VF for Live Migration via pds_core
  echo 1 > /sys/bus/pci/drivers/pds_core/$PF_BDF/sriov_numvfs

  # Allow the VF to be bound to the pds-vfio-pci driver
  echo "pds-vfio-pci" > /sys/class/pci_bus/$PF_BUS/device/$VF_BDF/driver_override

  # Bind the VF to the pds-vfio-pci driver
  echo "$VF_BDF" > /sys/bus/pci/drivers/pds-vfio-pci/bind

Sau khi thực hiện các bước trên, một tệp trong /dev/vfio/<iommu_group>
đáng lẽ phải được tạo ra.


Kích hoạt trình điều khiển
===================

Trình điều khiển được kích hoạt thông qua hệ thống cấu hình kernel tiêu chuẩn,
sử dụng lệnh tạo ::

tạo oldconfig/menuconfig/etc.

Trình điều khiển nằm trong cấu trúc menu tại:

-> Trình điều khiển thiết bị
    -> Khung trình điều khiển không gian người dùng không có đặc quyền VFIO
      -> VFIO hỗ trợ cho các thiết bị PDS PCI

Ủng hộ
=======

Để được hỗ trợ mạng Linux nói chung, vui lòng sử dụng gửi thư netdev
danh sách, được giám sát bởi nhân viên của Pensando::

netdev@vger.kernel.org

Để biết thêm nhu cầu hỗ trợ cụ thể, vui lòng sử dụng hỗ trợ trình điều khiển Pensando
thư điện tử::

driver@pensando.io