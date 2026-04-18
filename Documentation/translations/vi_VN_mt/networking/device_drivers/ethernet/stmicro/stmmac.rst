.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/stmicro/stmmac.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================================================
Trình điều khiển Linux cho Bộ điều khiển Ethernet Synopsys(R) "stmmac"
======================================================================

Tác giả: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
Alexandre Torgue <alexandre.torgue@st.com>, Jose Abreu <joabreu@synopsys.com>

Nội dung
========

- Trong bản phát hành này
- Danh sách tính năng
- Cấu hình hạt nhân
- Tham số dòng lệnh
- Thông tin và ghi chú về tài xế
- Thông tin gỡ lỗi
- Hỗ trợ

Trong bản phát hành này
===============

Tệp này mô tả Trình điều khiển Linux stmmac cho tất cả Ethernet Synopsys(R)
Bộ điều khiển.

Hiện tại, trình điều khiển thiết bị mạng này dành cho tất cả MAC/GMAC được nhúng STi
(tức là SoC 7xxx/5xxx), SPEAr (cánh tay), Loongson1B (mips) và XILINX XC2V3000
Bảng mạch FF1152AMT0221 D1215994A VIRTEX FPGA. Tóm tắt Ethernet QoS 5.0 IPK
cũng được hỗ trợ.

DesignWare(R) Cores Ethernet MAC 10/100/1000 Phiên bản phổ thông 3.70a
(và cũ hơn) và DesignWare(R) Cores Ethernet Quality-of-Service phiên bản 4.0
(và phía trên) đã được sử dụng để phát triển trình điều khiển này cũng như
Lõi DesignWare(R) XGMAC - 10G Ethernet MAC và lõi DesignWare(R)
Doanh nghiệp MAC - 100G Ethernet MAC.

Trình điều khiển này hỗ trợ cả bus nền tảng và PCI.

Trình điều khiển này bao gồm hỗ trợ cho Synopsys(R) DesignWare(R) sau
Bộ điều khiển Ethernet lõi và các phiên bản tối thiểu và tối đa tương ứng:

+------------------------------+--------------+--------------+--------------+
ZZ0000ZZ Tối thiểu. Phiên bản ZZ0001ZZ Viết tắt. Tên |
+==============================================================================================+
ZZ0002ZZ Không có ZZ0003ZZ GMAC |
+------------------------------+--------------+--------------+--------------+
ZZ0004ZZ 4.00a ZZ0005ZZ GMAC4+ |
+------------------------------+--------------+--------------+--------------+
ZZ0006ZZ 2.10a ZZ0007ZZ XGMAC2+ |
+------------------------------+--------------+--------------+--------------+
ZZ0008ZZ 2.00a ZZ0009ZZ XLGMAC2+ |
+------------------------------+--------------+--------------+--------------+

Đối với các câu hỏi liên quan đến yêu cầu phần cứng, hãy tham khảo tài liệu
được cung cấp cùng với bộ điều hợp Ethernet của bạn. Tất cả các yêu cầu phần cứng được liệt kê đều áp dụng
để sử dụng với Linux.

Danh sách tính năng
============

Các tính năng sau có sẵn trong trình điều khiển này:
 - Giao diện GMII/MII/RGMII/SGMII/RMII/XGMII/XLGMII
 - Hoạt động bán song công / song công hoàn toàn
 - Ethernet tiết kiệm năng lượng (EEE)
 - Gói IEEE 802.3x PAUSE (Kiểm soát luồng)
 - Bộ đếm RMON/MIB
 - Dấu thời gian IEEE 1588 (PTP)
 - Đầu ra xung mỗi giây (PPS)
 - MDIO Khoản 22 / Khoản 45 Giao diện
 - Quay lại MAC
 - Giảm tải ARP
 - Tự động chèn và kiểm tra CRC / PAD
 - Giảm tải tổng kiểm tra cho các gói đã nhận và truyền
 - Gói Ethernet tiêu chuẩn hoặc Jumbo
 - Chèn/thay thế địa chỉ nguồn
 - VLAN TAG Chèn/Thay thế/Xóa/Lọc (HASH và PERFECT)
 - Cài đặt kết hợp và cơ quan giám sát TX và RX có thể lập trình
 - Lọc địa chỉ đích (PERFECT)
 - Lọc HASH (Đa hướng)
 - Lọc lớp 3/Lớp 4
 - Phát hiện đánh thức từ xa
 - Nhận tỷ lệ bên (RSS)
 - Ưu tiên khung cho TX và RX
 - Độ dài, ngưỡng, kích thước hàng đợi có thể lập trình
 - Nhiều hàng đợi (tối đa 8)
 - Nhiều thuật toán lập lịch (TX: WRR, DWRR, WFQ, SP, CBS, EST, TBS;
   RX: WRR, SP)
 - Trình phân tích cú pháp RX linh hoạt
 - Giảm tải phân đoạn TCP / UDP (TSO, USO)
 - Tiêu đề phân chia (SPH)
 - Tính năng an toàn (Bảo vệ ECC, Bảo vệ chẵn lẻ dữ liệu)
 - Tự kiểm tra bằng Ethtool

Cấu hình hạt nhân
====================

Tùy chọn cấu hình kernel là ZZ0000ZZ:
 - ZZ0001ZZ: là để kích hoạt trình điều khiển nền tảng.
 - ZZ0002ZZ: dùng để kích hoạt driver pci.

Tham số dòng lệnh
=======================

Nếu trình điều khiển được xây dựng dưới dạng mô-đun thì các tham số tùy chọn sau sẽ được sử dụng
bằng cách nhập chúng vào dòng lệnh bằng lệnh modprobe bằng cách sử dụng lệnh này
cú pháp (ví dụ: đối với mô-đun PCI)::

modprobe stmmac_pci [<option>=<VAL1>,<VAL2>,...]

Các tham số trình điều khiển cũng có thể được truyền trong dòng lệnh bằng cách sử dụng::

stmmaceth=cơ quan giám sát:100,chain_mode=1

Giá trị mặc định cho từng tham số thường là cài đặt được đề xuất,
trừ khi có ghi chú khác.

cơ quan giám sát
--------
:Phạm vi hợp lệ: 5000-Không
: Giá trị mặc định: 5000

Tham số này ghi đè thời gian chờ truyền tính bằng mili giây.

gỡ lỗi
-----
:Phạm vi hợp lệ: 0-16 (0=none,...,16=all)
: Giá trị mặc định: 0

Thông số này điều chỉnh mức độ thông báo debug hiển thị trong hệ thống
nhật ký.

phyaddr
-------
:Phạm vi hợp lệ: 0-31
: Giá trị mặc định: -1

Tham số này ghi đè địa chỉ vật lý của thiết bị PHY.

flow_ctrl
---------
:Phạm vi hợp lệ: 0-3 (0=off,1=rx,2=tx,3=rx/tx)
: Giá trị mặc định: 3

Tham số này thay đổi khả năng Kiểm soát luồng mặc định.

tạm dừng
-----
:Phạm vi hợp lệ: 0-65535
: Giá trị mặc định: 65535

Tham số này thay đổi thời gian Tạm dừng Kiểm soát Luồng mặc định.

tc
--
:Phạm vi hợp lệ: 64-256
: Giá trị mặc định: 64

Tham số này thay đổi giá trị điều khiển Ngưỡng HW FIFO mặc định.

buf_sz
------
:Phạm vi hợp lệ: 1536-16384
: Giá trị mặc định: 1536

Tham số này thay đổi kích thước bộ đệm gói RX DMA mặc định.

ee_timer
---------
:Phạm vi hợp lệ: 0-Không
: Giá trị mặc định: 1000

Tham số này thay đổi thời gian hết hạn LPI TX mặc định tính bằng mili giây.

chuỗi_mode
----------
:Phạm vi hợp lệ: 0-1 (0=tắt,1=bật)
: Giá trị mặc định: 0

Tham số này thay đổi chế độ hoạt động mặc định từ Ring Mode sang
Chế độ chuỗi

Thông tin và ghi chú về tài xế
============================

Quá trình truyền
----------------

Phương thức xmit được gọi khi kernel cần truyền một gói; nó đặt
các bộ mô tả trong vòng và thông báo cho công cụ DMA rằng có một gói
sẵn sàng để được truyền đi.

Theo mặc định, trình điều khiển đặt bit ZZ0000ZZ trong trường tính năng của
cấu trúc ZZ0001ZZ, cho phép tính năng thu thập phân tán. Đây là
đúng trên các chip và cấu hình mà việc kiểm tra tổng có thể được thực hiện trong phần cứng.

Khi bộ điều khiển đã truyền xong gói tin, bộ đếm thời gian sẽ
dự kiến giải phóng tài nguyên truyền.

Quá trình nhận
---------------

Khi nhận được một hoặc nhiều gói, sự gián đoạn sẽ xảy ra. Các ngắt
không được xếp hàng đợi, vì vậy người lái xe phải quét tất cả các bộ mô tả trong vòng
trong quá trình nhận.

Điều này dựa trên NAPI, do đó bộ xử lý ngắt chỉ phát tín hiệu nếu có công việc
được thực hiện và nó thoát ra. Sau đó, phương pháp thăm dò ý kiến sẽ được lên lịch vào một lúc nào đó.
điểm tương lai.

Các gói đến được DMA lưu trữ trong danh sách ổ cắm được phân bổ trước
bộ đệm để tránh memcpy (không sao chép).

Giảm thiểu gián đoạn
--------------------

Trình điều khiển có thể giảm thiểu số lần ngắt DMA bằng cách sử dụng NAPI cho
khả năng tiếp nhận trên các chip cũ hơn 3,50. Các chip mới có Cơ quan giám sát HW RX
được sử dụng cho việc giảm nhẹ này.

Các tham số giảm thiểu có thể được điều chỉnh bằng ethtool.

WoL
---

Tính năng Wake up on Lan thông qua khung Magic và Unicast được hỗ trợ cho
Lõi GMAC, GMAC4/5 và XGMAC.

Bộ mô tả DMA
---------------

Trình điều khiển xử lý cả mô tả bình thường và mô tả thay thế. Cái sau chỉ có
đã thử nghiệm trên DesignWare(R) Cores Ethernet MAC Universal phiên bản 3.41a trở lên.

stmmac hỗ trợ bộ mô tả DMA để hoạt động cả trong bộ đệm kép (RING) và
chế độ danh sách liên kết (CHAINED). Trong RING, mỗi bộ mô tả trỏ đến hai bộ đệm dữ liệu
con trỏ trong khi ở chế độ CHAINED chúng chỉ trỏ đến một con trỏ bộ đệm dữ liệu.
Chế độ RING là mặc định.

Trong chế độ CHAINED, mỗi bộ mô tả sẽ có con trỏ tới bộ mô tả tiếp theo trong
danh sách, do đó tạo ra chuỗi rõ ràng trong chính bộ mô tả, trong khi
Không thể thực hiện chuỗi rõ ràng như vậy ở chế độ RING.

Bộ mô tả mở rộng
--------------------

Các bộ mô tả mở rộng cung cấp cho chúng ta thông tin về tải trọng Ethernet khi
nó đang mang các gói PTP hoặc TCP/UDP/ICMP qua IP. Những thứ này không có sẵn trên
Chip GMAC Synopsys(R) cũ hơn 3.50. Tại thời điểm thăm dò người lái xe sẽ
quyết định xem những thứ này có thực sự được sử dụng hay không. Hỗ trợ này cũng là bắt buộc đối với PTPv2
bởi vì các bộ mô tả bổ sung được sử dụng để lưu dấu thời gian phần cứng và
Trạng thái mở rộng.

Hỗ trợ Ethtool
---------------

Ethtool được hỗ trợ. Ví dụ: số liệu thống kê về trình điều khiển (bao gồm RMON),
lỗi nội bộ có thể được thực hiện bằng cách sử dụng ::

ethtool -S ethX

Tự kiểm tra Ethtool cũng được hỗ trợ. Điều này cho phép bạn tỉnh táo sớm
kiểm tra CTNH bằng cơ chế lặp lại MAC và PHY ::

ethtool -t ethX

Giảm tải Jumbo và phân đoạn
---------------------------------

Khung Jumbo được hỗ trợ và thử nghiệm cho GMAC. GSO cũng đã được
được thêm vào nhưng nó được thực hiện trong phần mềm. LRO không được hỗ trợ.

Hỗ trợ TSO
-----------

Tính năng TSO (Giảm tải phân đoạn TCP) được hỗ trợ bởi GMAC > 4.x và XGMAC
gia đình chip. Khi một gói được gửi qua giao thức TCP, ngăn xếp TCP đảm bảo
mà SKB cung cấp cho trình điều khiển cấp thấp (stmmac trong trường hợp của chúng tôi) khớp
với len khung tối đa (tiêu đề IP + tiêu đề TCP + tải trọng <= 1500 byte
(đối với MTU được đặt thành 1500)). Điều đó có nghĩa là nếu một ứng dụng sử dụng TCP muốn gửi
một gói sẽ có độ dài (sau khi thêm tiêu đề)> 1514 gói
sẽ được chia thành nhiều gói TCP: Tải trọng dữ liệu được chia và các tiêu đề
(TCP/IP ..) được thêm vào. Nó được thực hiện bằng phần mềm.

Khi TSO được bật, ngăn xếp TCP không quan tâm đến độ dài khung hình tối đa
và cung cấp gói SKB cho stmmac. IP GMAC sẽ phải thực hiện
tự phân đoạn để phù hợp với độ dài khung hình tối đa.

Tính năng này có thể được kích hoạt trong cây thiết bị thông qua mục nhập ZZ0000ZZ.

Ethernet hiệu quả năng lượng
-------------------------

Ethernet hiệu quả năng lượng (EEE) cho phép lớp con IEEE 802.3 MAC cùng với một
họ lớp Vật lý để hoạt động ở chế độ Nhàn rỗi năng lượng thấp (LPI). EEE
chế độ hỗ trợ hoạt động của IEEE 802.3 MAC ở tốc độ 100Mbps, 1000Mbps và 1Gbps.

Chế độ LPI cho phép tiết kiệm năng lượng bằng cách tắt các phần của giao tiếp
chức năng của thiết bị khi không có dữ liệu nào được truyền và nhận.
Hệ thống ở cả hai bên liên kết có thể vô hiệu hóa một số chức năng và
tiết kiệm năng lượng trong thời gian sử dụng liên kết thấp. MAC kiểm soát xem
hệ thống sẽ vào hoặc thoát khỏi chế độ LPI và truyền thông tin này đến PHY.

Ngay khi giao diện được mở, trình điều khiển sẽ xác minh xem EEE có thể hoạt động được không
được hỗ trợ. Điều này được thực hiện bằng cách xem xét cả thanh ghi khả năng DMA HW và
các thiết bị PHY đăng ký MCD.

Để vào chế độ TX LPI, trình điều khiển cần có bộ hẹn giờ phần mềm cho phép
và tắt chế độ LPI khi không có gì để truyền đi.

Giao thức thời gian chính xác (PTP)
-----------------------------

Trình điều khiển hỗ trợ IEEE 1588-2002, Giao thức thời gian chính xác (PTP), trong đó
cho phép đồng bộ hóa chính xác các đồng hồ trong hệ thống đo lường và điều khiển
được thực hiện với các công nghệ như truyền thông mạng.

Ngoài các tính năng dấu thời gian cơ bản được đề cập trong IEEE 1588-2002
Dấu thời gian, lõi GMAC mới hỗ trợ các tính năng dấu thời gian nâng cao.
IEEE 1588-2008 có thể được bật khi định cấu hình Kernel.

Hỗ trợ SGMII/RGMII
-------------------

Các thiết bị GMAC mới cung cấp cách quản lý RGMII/SGMII riêng. Thông tin này là
có sẵn trong thời gian chạy bằng cách xem sổ đăng ký khả năng CTNH. Điều này có nghĩa
rằng stmmac có thể quản lý tự động đàm phán và trạng thái liên kết bằng cách sử dụng
Đồ PHYLIB. Trong thực tế, HW cung cấp một tập hợp con các thanh ghi mở rộng để
khởi động lại ANE, xác minh chế độ Song công hoàn toàn/Một nửa và Tốc độ. Nhờ những điều này
đăng ký, có thể xem Khả năng đối tác liên kết tự động thương lượng.

Thuộc vật chất
--------

Trình điều khiển tương thích với Lớp trừu tượng vật lý để được kết nối với
Thiết bị PHY và GPHY.

Thông tin nền tảng
--------------------

Một số thông tin có thể được truyền qua nền tảng và cây thiết bị.

::

cấu trúc plat_stmmacenet_data {

1) Mã định danh xe buýt::

int bus_id;

2) Địa chỉ vật lý PHY. Nếu được đặt thành -1, trình điều khiển sẽ chọn PHY đầu tiên
tìm thấy::

int phy_addr;

3) Giao diện thiết bị PHY::

giao diện int;

4) Các trường nền tảng cụ thể cho bus MDIO::

cấu trúc stmmac_mdio_bus_data *mdio_bus_data;

5) Thông số DMA nội bộ::

cấu trúc stmmac_dma_cfg *dma_cfg;

6) Đã sửa lỗi lựa chọn Phạm vi đồng hồ CSR::

int clk_csr;

7) HW sử dụng lõi GMAC::

int has_gmac;

8) Nếu được đặt, MAC sẽ sử dụng Bộ mô tả nâng cao::

int enh_desc;

9) Core có thể thực hiện Tổng kiểm tra TX và/hoặc Tổng kiểm tra RX trong HW::

int tx_coe;
        int rx_coe;

11) Một số CTNH không thể thực hiện csum trong CTNH đối với các khung có kích thước quá lớn do
đến kích thước bộ đệm hạn chế. Đặt cờ này, csum sẽ được thực hiện trong SW trên
Khung JUMBO::

int buged_jumbo;

12) Core có mô-đun nguồn nhúng::

int chiều;

13) Buộc DMA sử dụng chế độ Lưu trữ và chuyển tiếp hoặc chế độ Ngưỡng::

int Force_sf_dma_mode;
        int Force_thresh_dma_mode;

15) Buộc tắt tính năng RX Watchdog và chuyển sang chế độ NAPI::

int riwt_off;

16) Giới hạn tốc độ hoạt động tối đa và MTU::

int max_speed;
        int maxmtu;

18) Số lượng bộ lọc Multicast/Unicast::

int multicast_filter_bins;
        int unicast_filter_entries;

20) Giới hạn kích thước tối đa TX và RX FIFO::

int tx_fifo_size;
        int rx_fifo_size;

21) Sử dụng số lượng hàng đợi TX và RX được chỉ định::

u32 rx_queues_to_use;
        u32 tx_queues_to_use;

22) Sử dụng thuật toán lập lịch TX và RX được chỉ định::

thuật toán u8 rx_sched_algorithm;
        thuật toán tx_sched_algorithm u8;

23) Thông số hàng đợi TX và RX nội bộ::

cấu trúc stmmac_rxq_cfg rx_queues_cfg[MTL_MAX_RX_QUEUES];
        cấu trúc stmmac_txq_cfg tx_queues_cfg[MTL_MAX_TX_QUEUES];

24) Lệnh gọi lại này được sử dụng để sửa đổi một số thanh ghi syscfg (trên ST SoC)
theo tốc độ liên kết được thỏa thuận bởi lớp vật lý::

void (*fix_mac_speed)(void *priv, tốc độ int không dấu);

25) Lệnh gọi lại được sử dụng để gọi khởi tạo tùy chỉnh; Điều này đôi khi
cần thiết trên một số nền tảng (ví dụ: hộp ST) nơi CTNH cần phải đặt
một số dòng PIO hoặc thanh ghi cfg hệ thống. cuộc gọi lại init/exit không nên sử dụng
hoặc sửa đổi dữ liệu nền tảng::

int (*init)(struct platform_device *pdev, void *priv);
        khoảng trống (*exit)(struct platform_device *pdev, khoảng trống *priv);

26) Thực hiện thiết lập CTNH của xe buýt. Ví dụ: trên một số nền tảng ST, trường này
được sử dụng để định cấu hình cầu AMBA nhằm tạo lưu lượng STBus hiệu quả hơn ::

struct mac_device_info *(*setup)(void *priv);
        void *bsp_priv;

27) Đồng hồ và tốc độ nội bộ::

struct clk *stmmac_clk;
        struct clk *pclk;
        struct clk *clk_ptp_ref;
        int chưa dấu clk_ptp_rate;
        int chưa dấu clk_ref_rate;
        s32 ptp_max_adj;

28) Thiết lập lại chính::

struct reset_control *stmmac_rst;

29) Thông số bên trong AXI::

struct stmmac_axi *axi;

30) HW sử dụng GMAC>4 lõi::

int has_gmac4;

31) HW dựa trên sun8i::

bool has_sun8i;

32) Kích hoạt tính năng TSO::

bool tso_en;

33) Kích hoạt tính năng Chia tỷ lệ bên nhận (RSS)::

int rss_en;

34) Lựa chọn cổng MAC::

int mac_port_sel_speed;

35) Kích hoạt tính năng đo đồng hồ TX LPI::

bool en_tx_lpi_clockgating;

36) HW sử dụng lõi XGMAC>2.10::

int has_xgmac;

::

    }

Đối với dữ liệu bus MDIO, chúng tôi có:

::

cấu trúc stmmac_mdio_bus_data {

1) Mặt nạ PHY được thông qua khi xe buýt MDIO được đăng ký::

unsigned int phy_mask;

2) Danh sách IRQ, mỗi IRQ trên mỗi PHY::

int *irqs;

3) Nếu IRQ là NULL, hãy sử dụng mã này cho PHY đã được thăm dò::

int thăm dò_phy_irq;

4) Đặt thành true nếu PHY cần đặt lại::

bool cần_reset;

::

    }

Đối với cấu hình động cơ DMA, chúng ta có:

::

cấu trúc stmmac_dma_cfg {

1) Độ dài bùng nổ có thể lập trình (TX và RX)::

int pbl;

2) Nếu được đặt, DMA TX / RX sẽ sử dụng giá trị này thay vì pbl::

int txpbl;
        int rxpbl;

3) Kích hoạt 8xPBL::

bool pblx8;

4) Kích hoạt cụm cố định hoặc hỗn hợp::

int cố định_burst;
        int hỗn hợp_burst;

5) Kích hoạt nhịp điệu được căn chỉnh theo địa chỉ::

bool aal;

6) Kích hoạt tính năng Địa chỉ nâng cao (> 32 bit)::

bool eame;

::

    }

Đối với tham số DMA AXI, chúng ta có:

::

cấu trúc stmmac_axi {

1) Kích hoạt AXI LPI::

bool axi_lpi_en;
        bool axi_xit_frm;

2) Đặt AXI Ghi / Đọc số lượng yêu cầu còn tồn đọng tối đa::

u32 axi_wr_osr_lmt;
        u32 axi_rd_osr_lmt;

3) Đặt cụm AXI 4KB::

bool axi_kbbe;

4) Đặt bản đồ độ dài cụm tối đa AXI::

u32 axi_blen[AXI_BLEN];

5) Đặt AXI Cụm cố định / cụm hỗn hợp::

bool axi_fb;
        bool axi_mb;

6) Đặt chế độ tăng trưởng AXI xây dựng lại::

bool axi_rb;

::

    }

Đối với cấu hình Hàng đợi RX, chúng tôi có:

::

cấu trúc stmmac_rxq_cfg {

1) Chế độ sử dụng (DCB hoặc AVB)::

chế độ u8_to_use;

2) Kênh DMA để sử dụng::

u32 chan;

3) Định tuyến gói, nếu có::

u8 pkt_route;

4) Sử dụng định tuyến ưu tiên và ưu tiên định tuyến::

bool use_prio;
        u32 trước;

::

    }

Đối với cấu hình Hàng đợi TX, chúng tôi có:

::

cấu trúc stmmac_txq_cfg {

1) Trọng lượng hàng đợi trong bộ lập lịch::

cân nặng u32;

2) Chế độ sử dụng (DCB hoặc AVB)::

chế độ u8_to_use;

3) Thông số định hình cơ sở tín dụng::

u32 send_slope;
        u32 nhàn rỗi_slope;
        u32 high_credit;
        u32 low_credit;

4) Sử dụng lập lịch ưu tiên và mức độ ưu tiên::

bool use_prio;
        u32 trước;

::

    }

Thông tin cây thiết bị
-----------------------

Vui lòng tham khảo tài liệu sau:
Tài liệu/devicetree/binds/net/snps,dwmac.yaml

Khả năng CTNH
---------------

Lưu ý rằng, bắt đầu từ các chip mới, ở nơi có sẵn khả năng CTNH
đăng ký, nhiều cấu hình được phát hiện trong thời gian chạy chẳng hạn như
hiểu xem EEE, HW csum, PTP, bộ mô tả nâng cao, v.v. có thực sự là
có sẵn. Khi chiến lược được áp dụng trong trình điều khiển này, thông tin từ CTNH
thanh ghi khả năng có thể thay thế những gì đã được truyền từ nền tảng.

Thông tin gỡ lỗi
=================

Trình điều khiển xuất nhiều thông tin như thống kê nội bộ, gỡ lỗi
thông tin, các thanh ghi MAC và DMA, v.v.

Chúng có thể được đọc theo nhiều cách tùy thuộc vào loại thông tin
thực sự cần thiết.

Ví dụ: người dùng có thể sử dụng hỗ trợ ethtool để lấy số liệu thống kê: ví dụ:
sử dụng: ZZ0000ZZ (hiển thị Bộ đếm quản lý (MMC) nếu
được hỗ trợ) hoặc xem các thanh ghi MAC/DMA: ví dụ: sử dụng: ZZ0001ZZ

Biên dịch hạt nhân với ZZ0000ZZ, trình điều khiển sẽ xuất
các mục gỡ lỗi sau:

- ZZ0000ZZ: Để hiển thị các vòng mô tả DMA TX/RX
 - ZZ0001ZZ: Để hiển thị Khả năng CTNH

Nhà phát triển cũng có thể sử dụng tham số mô-đun ZZ0000ZZ để gỡ lỗi thêm
thông tin (vui lòng xem: Cấp độ tin nhắn NETIF).

Ủng hộ
=======

Nếu xác định được sự cố với mã nguồn đã phát hành trên hạt nhân được hỗ trợ
với bộ điều hợp được hỗ trợ, hãy gửi email thông tin cụ thể liên quan đến
vấn đề với netdev@vger.kernel.org