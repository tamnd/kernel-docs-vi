.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/omap/omap.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============
Lịch sử OMAP
=============

Tệp này chứa tài liệu để chạy dòng chính
hạt nhân trên omaps.

====== ===========================================================
KERNEL NEW DEPENDENCIES
====== ===========================================================
Cần cập nhật v4.3+ cho các tệp .config tùy chỉnh để đảm bảo
		CONFIG_REGULATOR_PBIAS được kích hoạt để MMC1 hoạt động
		đúng cách.

Cần có bản cập nhật v4.18+ cho các tệp .config tùy chỉnh để đảm bảo
		CONFIG_MMC_SDHCI_OMAP được bật cho tất cả các phiên bản MMC
		để làm việc trên các bo mạch dựa trên DRA7 và K2G.
====== ===========================================================
