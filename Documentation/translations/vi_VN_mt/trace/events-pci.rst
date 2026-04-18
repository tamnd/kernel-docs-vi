.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/events-pci.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
Điểm theo dõi hệ thống con: PCI
===============================

Tổng quan
========
Hệ thống theo dõi PCI cung cấp các điểm theo dõi để theo dõi các sự kiện phần cứng quan trọng
có thể ảnh hưởng đến hiệu năng và độ tin cậy của hệ thống. Những sự kiện này thường hiển thị
lên đây:

/sys/kernel/tracing/sự kiện/pci

Cf. include/trace/events/pci.h cho các định nghĩa sự kiện.

Dấu vết có sẵn
=====================

pci_hp_event
------------

Giám sát các sự kiện cắm nóng PCI bao gồm lắp/tháo thẻ và liên kết
những thay đổi trạng thái.
::

pci_hp_event "%s slot:%s, sự kiện:%s\n"

ZZ0000ZZ:

* ZZ0000ZZ - Đã thiết lập liên kết PCIe
* ZZ0001ZZ - Mất liên kết PCIe
* ZZ0002ZZ - Thẻ được phát hiện trong khe cắm
* ZZ0003ZZ - Đã tháo thẻ ra khỏi khe cắm

ZZ0000ZZ::

# Enable điểm theo dõi
    echo 1 > /sys/kernel/debug/tracing/events/pci/pci_hp_event/enable

Sự kiện # Monitor (đầu ra sau được tạo khi thiết bị được cắm nóng)
    mèo /sys/kernel/gỡ lỗi/tracing/trace_pipe
       irq/51-pciehp-88 [001]..... 1311.177459: pci_hp_event: 0000:00:02.0 slot:10, sự kiện:CARD_PRESENT

irq/51-pciehp-88 [001]..... 1311.177566: pci_hp_event: 0000:00:02.0 slot:10, sự kiện:LINK_UP

pcie_link_event
---------------

Theo dõi sự thay đổi tốc độ liên kết PCIe và cung cấp thông tin trạng thái liên kết chi tiết.
::

pcie_link_event "%s loại:%d, lý do:%d, cur_bus_speed:%d, max_bus_speed:%d, chiều rộng:%u, flit_mode:%u, trạng thái:%s\n"

ZZ0000ZZ:

* ZZ0000ZZ - Loại thiết bị PCIe (4=Cổng gốc, v.v.)
*ZZ0001ZZ - Lý do thay đổi link:

- ZZ0000ZZ - Đào tạo lại liên kết
  - ZZ0001ZZ - Đếm xe buýt
  - ZZ0002ZZ - Bật thông báo băng thông
  - ZZ0003ZZ - Thông báo băng thông IRQ
  - ZZ0004ZZ - Sự kiện cắm nóng


ZZ0000ZZ::

# Enable điểm theo dõi
    echo 1 > /sys/kernel/debug/tracing/events/pci/pcie_link_event/enable

Sự kiện # Monitor (đầu ra sau được tạo khi thiết bị được cắm nóng)
    mèo /sys/kernel/gỡ lỗi/tracing/trace_pipe
       irq/51-pciehp-88 [001]..... 381.545386: pcie_link_event: 0000:00:02.0 loại:4, lý do:4, cur_bus_speed:20, max_bus_speed:23, chiều rộng:1, flit_mode:0, trạng thái:DLLLA