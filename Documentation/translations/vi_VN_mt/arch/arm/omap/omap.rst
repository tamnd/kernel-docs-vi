.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/omap/omap.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============
Lịch sử OMAP
============

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
