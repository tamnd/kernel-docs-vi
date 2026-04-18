.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/spear/overview.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Tổng quan về SPEAr ARM Linux
========================

Giới thiệu
------------

SPEAr (Kiến trúc nâng cao bộ xử lý có cấu trúc).
  liên kết web: ZZ0000ZZ

Dòng sản phẩm ST Microelectronics SPEAr của CPU hệ thống trên chip ARM9/CortexA9 là
  được hỗ trợ bởi nền tảng “giáo” của ARM Linux. Hiện tại SPEAr1310,
  SPEAr1340, SPEAr300, SPEAr310, SPEAr320 và SPEAr600 SOC được hỗ trợ.

Hệ thống phân cấp trong SPEAr như sau:

SPEAr (Nền tảng)

- SPEAr3XX (dòng 3XX SOC, dựa trên ARM9)
		- SPEAr300 (SOC)
			- Hội đồng đánh giá SPEAr300
		- SPEAr310 (SOC)
			- Hội đồng đánh giá SPEAr310
		- SPEAr320 (SOC)
			- Hội đồng đánh giá SPEAr320
	- SPEAr6XX (dòng 6XX SOC, dựa trên ARM9)
		- SPEAr600 (SOC)
			- Hội đồng đánh giá SPEAr600
	- SPEAr13XX (dòng 13XX SOC, dựa trên ARM CORTEXA9)
		- SPEAr1310 (SOC)
			- Hội đồng đánh giá SPEAr1310
		- SPEAr1340 (SOC)
			- Hội đồng đánh giá SPEAr1340

Cấu hình
-------------

Một cấu hình chung được cung cấp cho mỗi máy và có thể được sử dụng làm
  mặc định bởi::

tạo giáo13xx_defconfig
	tạo Spear3xx_defconfig
	tạo Spear6xx_defconfig

Cách trình bày
------

Các tập tin chung cho nhiều dòng máy (SPEAr3xx, SPEAr6xx và
  SPEAr13xx) được đặt trong mã nền tảng có trong Arch/arm/plat-spear
  với các tiêu đề trong plat/.

Mỗi dòng máy có một thư mục có tên Arch/arm/mach-spear theo sau là
  tên loạt. Giống như mach-spear3xx, mach-spear6xx và mach-spear13xx.

Tệp chung cho các máy thuộc họ Spear3xx là mach-spear3xx/spear3xx.c, dành cho
  Spear6xx là mach-spear6xx/spear6xx.c và đối với họ Spear13xx là
  mach-spear13xx/spear13xx.c. mach-spear* cũng chứa soc/machine cụ thể
  các tập tin như Spear1310.c, Spear1340.c Spear300.c, Spear310.c, Spear320.c và
  giáo600.c.  mach-spear* không chứa các tệp cụ thể của bảng vì chúng hoàn toàn
  hỗ trợ Cây thiết bị làm phẳng.


Tác giả tài liệu
---------------

Viresh Kumar <vireshk@kernel.org>, (c) 2010-2012 ST Vi điện tử
