.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/PCI/endpoint/pci-nvme-function.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===================
Chức năng NVMe PCI
=================

:Tác giả: Damien Le Moal <dlemoal@kernel.org>

Chức năng điểm cuối PCI NVMe triển khai bộ điều khiển NVMe PCI bằng NVMe
mã lõi mục tiêu của hệ thống con. Trình điều khiển cho chức năng này nằm trong NVMe
hệ thống con dưới dạng trình điều khiển/nvme/target/pci-epf.c.

Xem Tài liệu/nvme/nvme-pci-endpoint-target.rst để biết thêm chi tiết.