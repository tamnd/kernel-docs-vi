.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================
Hướng dẫn cài đặt trình điều khiển API
==============================

Kernel cung cấp nhiều giao diện khác nhau để hỗ trợ sự phát triển
của trình điều khiển thiết bị.  Tài liệu này là một bộ sưu tập duy nhất có tổ chức
của một số giao diện đó - hy vọng nó sẽ tốt hơn theo thời gian!  các
các phần phụ có sẵn có thể được nhìn thấy dưới đây.


Thông tin chung cho tác giả trình điều khiển
======================================

Phần này bao gồm các tài liệu mà vào lúc này hay lúc khác sẽ được
được hầu hết các nhà phát triển làm việc trên trình điều khiển thiết bị quan tâm.

.. toctree::
   :maxdepth: 1

   basics
   driver-model/index
   device_link
   infrastructure
   ioctl
   pm/index

Thư viện hỗ trợ hữu ích
========================

Phần này bao gồm các tài liệu mà vào lúc này hay lúc khác sẽ được
được hầu hết các nhà phát triển làm việc trên trình điều khiển thiết bị quan tâm.

.. toctree::
   :maxdepth: 1

   early-userspace/index
   connector
   device-io
   devfreq
   dma-buf
   component
   io-mapping
   io_ordering
   uio-howto
   vfio-mediated-device
   vfio
   vfio-pci-device-specific-driver-acceptance

Tài liệu cấp độ xe buýt
=======================

.. toctree::
   :maxdepth: 1

   auxiliary_bus
   cxl/index
   eisa
   firewire
   i3c/index
   isa
   men-chameleon-bus
   pci/index
   rapidio/index
   slimbus
   usb/index
   virtio/index
   vme
   w1
   xillybus


API dành riêng cho hệ thống con
=======================

.. toctree::
   :maxdepth: 1

   80211/index
   acpi/index
   backlight/lp855x-driver.rst
   clk
   coco/index
   console
   crypto/index
   dmaengine/index
   dpll
   edac
   extcon
   firmware/index
   fpga/index
   frame-buffer
   aperture
   generic-counter
   generic_pt
   gpio/index
   hsi
   hte/index
   hw-recoverable-errors
   i2c
   iio/index
   infiniband
   input
   interconnect
   ipmb
   ipmi
   libata
   mailbox
   md/index
   media/index
   mei/index
   memory-devices/index
   message-based
   misc_devices
   miscellaneous
   mmc/index
   mtd/index
   mtdnand
   nfc/index
   ntb
   nvdimm/index
   nvmem
   parport-lowlevel
   phy/index
   pin-control
   pldmfw/index
   pps
   ptp
   pwm
   pwrseq
   regulator
   reset
   rfkill
   s390-drivers
   scsi
   serial/index
   sm501
   soundwire/index
   spi
   surface_aggregator/index
   switchtec
   sync_file
   target
   tee
   thermal/index
   tty/index
   wbrf
   wmi
   xilinx/index
   zorro