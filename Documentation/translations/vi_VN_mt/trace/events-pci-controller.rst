.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/events-pci-controller.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=========================================
Điểm theo dõi hệ thống con: Bộ điều khiển PCI
======================================

Tổng quan
========
Hệ thống theo dõi bộ điều khiển PCI cung cấp các điểm theo dõi để giám sát bộ điều khiển
thông tin cấp độ cho mục đích gỡ lỗi. Các sự kiện thường hiển thị ở đây:

/sys/kernel/tracing/events/pci_controller

Cf. include/trace/events/pci_controller.h cho các định nghĩa sự kiện.

Dấu vết có sẵn
=====================

pcie_ltssm_state_transition
---------------------------

Giám sát quá trình chuyển đổi trạng thái PCIe LTSSM bao gồm thông tin trạng thái và tốc độ
::

pcie_ltssm_state_transition "dev: %s trạng thái: %s rate: %s\n"

ZZ0000ZZ:

* ZZ0000ZZ - Phiên bản bộ điều khiển PCIe
* ZZ0001ZZ - Trạng thái PCIe LTSSM
* ZZ0002ZZ - Tốc độ ngày PCIe

ZZ0000ZZ:

.. code-block:: shell

    # Enable the tracepoint
    echo 1 > /sys/kernel/debug/tracing/events/pci_controller/pcie_ltssm_state_transition/enable

    # Monitor events (the following output is generated when a device is linking)
    cat /sys/kernel/debug/tracing/trace_pipe
       kworker/0:0-9       [000] .....     5.600221: pcie_ltssm_state_transition: dev: a40000000.pcie state: RCVRY_EQ2 rate: 8.0 GT/s