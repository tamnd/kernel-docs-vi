.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/PCI/endpoint/pci-nvme-function.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Chức năng NVMe PCI
===================

:Tác giả: Damien Le Moal <dlemoal@kernel.org>

Chức năng điểm cuối PCI NVMe triển khai bộ điều khiển NVMe PCI bằng NVMe
mã lõi mục tiêu của hệ thống con. Trình điều khiển cho chức năng này nằm trong NVMe
hệ thống con dưới dạng trình điều khiển/nvme/target/pci-epf.c.

Xem Tài liệu/nvme/nvme-pci-endpoint-target.rst để biết thêm chi tiết.