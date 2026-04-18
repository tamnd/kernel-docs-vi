.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/amd/pds_vdpa.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. note: can be edited and viewed with /usr/bin/formiko-vim

===============================================================
Trình điều khiển PCI vDPA dành cho dòng bộ chuyển đổi AMD/Pensando(R) DSC
==========================================================

Trình điều khiển thiết bị AMD/Pensando vDPA VF

Copyright(c) 2023 Advanced Micro Devices, Inc

Tổng quan
========

Trình điều khiển ZZ0000ZZ là trình điều khiển xe buýt phụ trợ cung cấp
một thiết bị vDPA để ngăn xếp mạng virtio sử dụng.  Nó được sử dụng với
các thiết bị Chức năng ảo Pensando cung cấp hàng đợi vDPA và virtio
dịch vụ.  Nó phụ thuộc vào trình điều khiển và phần cứng ZZ0001ZZ cho PF
và xử lý VF PCI cũng như các dịch vụ cấu hình thiết bị.

Sử dụng thiết bị
================

Thiết bị ZZ0000ZZ được kích hoạt thông qua nhiều bước cấu hình và
phụ thuộc vào trình điều khiển ZZ0001ZZ để tạo và kích hoạt SR-IOV Virtual
Các thiết bị chức năng  Sau khi VF được bật, chúng tôi kích hoạt dịch vụ vDPA
trong thiết bị ZZ0002ZZ để tạo các thiết bị phụ trợ được pds_vdpa sử dụng.

Các bước ví dụ:

.. code-block:: bash

  #!/bin/bash

  modprobe pds_core
  modprobe vdpa
  modprobe pds_vdpa

  PF_BDF=`ls /sys/module/pds_core/drivers/pci\:pds_core/*/sriov_numvfs | awk -F / '{print $7}'`

  # Enable vDPA VF auxiliary device(s) in the PF
  devlink dev param set pci/$PF_BDF name enable_vnet cmode runtime value true

  # Create a VF for vDPA use
  echo 1 > /sys/bus/pci/drivers/pds_core/$PF_BDF/sriov_numvfs

  # Find the vDPA services/devices available
  PDS_VDPA_MGMT=`vdpa mgmtdev show | grep vDPA | head -1 | cut -d: -f1`

  # Create a vDPA device for use in virtio network configurations
  vdpa dev add name vdpa1 mgmtdev $PDS_VDPA_MGMT mac 00:11:22:33:44:55

  # Set up an ethernet interface on the vdpa device
  modprobe virtio_vdpa



Kích hoạt trình điều khiển
===================

Trình điều khiển được kích hoạt thông qua hệ thống cấu hình kernel tiêu chuẩn,
sử dụng lệnh tạo ::

tạo oldconfig/menuconfig/etc.

Trình điều khiển nằm trong cấu trúc menu tại:

-> Trình điều khiển thiết bị
    -> Hỗ trợ thiết bị mạng (NETDEVICES [=y])
      -> Hỗ trợ trình điều khiển Ethernet
        -> Thiết bị Pensando
          -> Hỗ trợ Pensando Ethernet PDS_VDPA

Ủng hộ
=======

Để được hỗ trợ mạng Linux nói chung, vui lòng sử dụng gửi thư netdev
danh sách, được giám sát bởi nhân viên của Pensando::

netdev@vger.kernel.org

Để biết thêm nhu cầu hỗ trợ cụ thể, vui lòng sử dụng hỗ trợ trình điều khiển Pensando
thư điện tử::

driver@pensando.io