.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/platform-cardlist.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển nền tảng
================

Có một số trình điều khiển tập trung vào việc cung cấp hỗ trợ cho
chức năng đã được bao gồm trong bo mạch chính và không
không sử dụng bus USB hay PCI. Những trình điều khiển đó được gọi là nền tảng
trình điều khiển và rất phổ biến trên các thiết bị nhúng.

Các trình điều khiển nền tảng được hỗ trợ hiện tại (không bao gồm trình điều khiển dàn dựng) là
liệt kê dưới đây

===================================================================================
Tên tài xế
===================================================================================
am437x-vpfe TI AM437x VPFE
aspeed-video Aspeed AST2400 và AST2500
Bộ điều khiển cảm biến hình ảnh atmel-isc ATMEL (ISC)
Giao diện cảm biến hình ảnh atmel-isi ATMEL (ISI)
cafe_ccic Marvell 88ALP01 (Cafe) Bộ điều khiển camera CMOS
Bộ điều khiển RX cdns-csi2rx Cadence MIPI-CSI2
Bộ điều khiển cadence cdns-csi2tx MIPI-CSI2 TX
coda-vpu Chips&Media IP codec đa chuẩn Coda
quay video dm355_ccdc TI DM355 CCDC
quay video dm644x_ccdc TI DM6446 CCDC
exynos-fimc-is EXYNOS4x12 FIMC-IS (Hệ thống con hình ảnh)
Giao diện máy ảnh exynos-fimc-lite EXYNOS FIMC-LITE
exynos-gsc Samsung Exynos G-Scaler
exy Hệ thống con máy ảnh dòng SoC Samsung S5P/EXYNOS4
Đường ống pixel imx-pxp i.MX (PXP)
quay video isdf TI DM365 ISIF
mmp_máy ảnh Bộ điều khiển camera tích hợp Marvell Armada 610
Bộ giải mã mtk_jpeg Mediatek JPEG
mtk-mdp Mediatek MDP
mtk-vcodec-dec Bộ giải mã video Mediatek
Bộ xử lý video Mediatek mtk-vpu
mx2_emmaprp MX2 eMMa-PrP
Camera omap3-isp OMAP 3
omap-vout OMAP2/OMAP3 V4L2-Hiển thị
pxa_Camera PXA27x Giao diện chụp ảnh nhanh
qcom-camss Hệ thống con camera Qualcomm V4L2
rcar-csi2 Bộ thu R-Car MIPI CSI-2
rcar_drif Giao diện vô tuyến kỹ thuật số Renesas (DRIF)
Bộ xử lý nén khung rcar-fcp Renesas
rcar_fdp1 Bộ xử lý hiển thị tốt của Renesas
rcar_jpu Bộ xử lý Renesas JPEG
Đầu vào video R-Car rcar-vin (VIN)
Renesas-ceu Bộ phận Công cụ Chụp Renesas (CEU)
rockchip-rga Bộ tăng tốc đồ họa Rockchip Raster 2d
s3c-camif Giao diện máy ảnh SoC Samsung S3C24XX/S3C64XX
Bộ thu s5p-csis S5P/EXYNOS MIPI-CSI2 (MIPI-CSIS)
s5p-fimc S5P/EXYNOS4 FIMC/CAMIF giao diện máy ảnh
s5p-g2d Bộ tăng tốc đồ họa 2d Samsung S5P và EXYNOS4 G2D
s5p-jpeg Bộ giải mã Samsung S5P/Exynos3250/Exynos4 JPEG
s5p-mfc Bộ giải mã video Samsung S5P MFC
sh_veu SuperH VEU xử lý video mem2mem
sh_vou Đầu ra video SuperH VOU
Giao diện bộ nhớ máy ảnh kỹ thuật số stm32-dcmi STM32 (DCMI)
stm32-dma2d STM32 Bộ tăng tốc Chrom-Art
sun4i-csi Allwinner A10 CMOS Hỗ trợ giao diện cảm biến
Giao diện cảm biến máy ảnh sun6i-csi Allwinner V3s
sun8i-di Allwinner Deinterlace
sun8i-rotate Vòng quay Allwinner DE2
ti-cal TI Thiết bị đa phương tiện chuyển đổi bộ nhớ sang bộ nhớ
thiết bị nền tảng ti-csc TI DVB
ti-vpe TI VPE (Công cụ xử lý video)
venus-enc Bộ mã hóa/giải mã Qualcomm Venus V4L2
Bộ điều khiển máy ảnh VIAFB qua camera
Bộ ghép kênh video-mux
vpif_display TI DaVinci VPIF V4L2-Hiển thị
vpif_capture TI DaVinci VPIF quay video
vsp1 Renesas VSP1 Công cụ xử lý video
xilinx-tpg Trình tạo mẫu thử nghiệm video Xilinx
xilinx-video Xilinx Video IP (EXPERIMENTAL)
Bộ điều khiển thời gian video xilinx-vtc Xilinx
===================================================================================

Bộ chuyển đổi MMC/SDIO DVB
---------------------

======= ===============================================
Tên tài xế
======= ===============================================
smssdio Siano SMS1xxx dựa trên MDTV qua giao diện SDIO
======= ===============================================
