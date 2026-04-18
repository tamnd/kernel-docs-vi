.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/perf/meson-ddr-pmu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================================================================
Thiết bị giám sát hiệu suất băng thông Amlogic SoC DDR (PMU)
===========================================================

Amlogic Meson G12 SoC chứa bộ giám sát băng thông bên trong bộ điều khiển DRAM.
Màn hình bao gồm 4 kênh. Mỗi kênh có thể đếm yêu cầu truy cập
DRAM. Kênh có thể đếm đồng thời tối đa 3 cổng AXI. Nó có thể hữu ích
để hiển thị xem nút cổ chai hiệu suất có nằm trên băng thông DDR hay không.

Hiện tại, trình điều khiển này hỗ trợ 5 sự kiện hoàn hảo sau:

+ meson_ddr_bw/total_rw_bytes/
+ meson_ddr_bw/chan_1_rw_bytes/
+ meson_ddr_bw/chan_2_rw_bytes/
+ meson_ddr_bw/chan_3_rw_bytes/
+ meson_ddr_bw/chan_4_rw_bytes/

meson_ddr_bw/chan_{1,2,3,4__rw_bytes/ sự kiện là các sự kiện dành riêng cho kênh.
Mỗi kênh hỗ trợ lọc, có thể cho phép kênh giám sát
mô-đun IP riêng lẻ trong SoC.

Dưới đây là các từ khóa bộ lọc sự kiện yêu cầu truy cập DDR:

+ cánh tay - từ CPU
+ vpu_read1 - từ OSD + VPP đọc
+ gpu - từ 3D GPU
+ pcie - từ bộ điều khiển PCIe
+ hdcp - từ bộ điều khiển HDCP
+ hevc_front - từ giao diện người dùng codec HEVC
+ usb3_0 - từ bộ điều khiển USB3.0
+ hevc_back - từ phần cuối của codec HEVC
+ h265enc - từ bộ mã hóa HEVC
+ vpu_read2 - từ DI đọc
+ vpu_write1 - từ VDIN ghi
+ vpu_write2 - từ di write
+ vdec - từ bộ giải mã video codec cũ
+ hcodec - từ bộ mã hóa H264
+ ge2d - từ ge2d
+ spicc1 - từ bộ điều khiển SPI 1
+ usb0 - từ bộ điều khiển USB2.0 0
+ dma - từ hệ thống bộ điều khiển DMA 1
+ arb0 - từ arb0
+ sd_emmc_b - từ bộ điều khiển SD eMMC b
+ usb1 - từ bộ điều khiển USB2.0 1
+ âm thanh - từ mô-đun Âm thanh
+ sd_emmc_c - từ bộ điều khiển SD eMMC c
+ spicc2 - từ bộ điều khiển SPI 2
+ ethernet - từ bộ điều khiển Ethernet


Ví dụ:

+ Hiển thị tổng băng thông DDR mỗi giây:

    .. code-block:: bash

       perf stat -a -e meson_ddr_bw/total_rw_bytes/ -I 1000 sleep 10


+ Hiển thị băng thông DDR riêng lẻ từ CPU và GPU tương ứng, cũng như
    tổng của chúng:

    .. code-block:: bash

       perf stat -a -e meson_ddr_bw/chan_1_rw_bytes,arm=1/ -I 1000 sleep 10
       perf stat -a -e meson_ddr_bw/chan_2_rw_bytes,gpu=1/ -I 1000 sleep 10
       perf stat -a -e meson_ddr_bw/chan_3_rw_bytes,arm=1,gpu=1/ -I 1000 sleep 10
