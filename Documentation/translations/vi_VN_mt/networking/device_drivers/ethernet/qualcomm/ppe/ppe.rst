.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/qualcomm/ppe/ppe.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================================================
Trình điều khiển Ethernet PPE cho dòng SoC Qualcomm IPQ
=======================================================

Bản quyền (c) Qualcomm Technologies, Inc. và/hoặc các công ty con của nó.

Tác giả: Lôi Vệ <quic_leiwei@quicinc.com>


Nội dung
========

-ZZ0000ZZ
-ZZ0001ZZ
-ZZ0002ZZ
-ZZ0003ZZ
-ZZ0004ZZ


Tổng quan về PPE
============

Dòng SoC (System-on-Chip) IPQ (Bộ xử lý Internet Qualcomm) là dòng SoC (System-on-Chip) của Qualcomm
kết nối mạng SoC cho các điểm truy cập Wi-Fi. PPE (Công cụ xử lý gói) là Ethernet
công cụ xử lý gói trong IPQ SoC.

Dưới đây là sơ đồ phần cứng đơn giản của IPQ9574 SoC bao gồm công cụ PPE và
các khối khác nằm trong SoC nhưng nằm ngoài công cụ PPE. Các khối này hoạt động cùng nhau
để kích hoạt Ethernet cho IPQ SoC::

+------+ +------+ +------+ +------+ +------+ +------+ bắt đầu +-------+
               ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ ZZ0004ZZ ZZ0005ZZ<------ZZ0006ZZ
               +------+ +------+ +------+ +------+ +------+ +------+ dừng lại +-+-+-+-+
                                             ZZ0007ZZ | ^
 +-------+ +--------------------------+--------+----------------------+ ZZ0008ZZ |
 ZZ0009ZZ ZZ0010ZZ EDMA ZZ0011ZZ ZZ0012ZZ |
 +---+---+ ZZ0013ZZ ZZ0014ZZ |
     ZZ0015ZZ ZZ0016ZZ ZZ0017ZZ |
     +-------->ZZ0018ZZ ZZ0019ZZ |
               Lõi chuyển mạch ZZ0020ZZ ZZ0021ZZ ZZ0022ZZ ZZ0023ZZ ZZ0024ZZ
               ZZ0025ZZ +---+---+ +------+--------+ ZZ0026ZZ ZZ0027ZZ
               ZZ0028ZZ ZZ0029ZZ ZZ0030ZZ ZZ0031ZZ |
 +-------+ ZZ0032ZZ +------+--------------+---+ ZZ0033ZZ ZZ0034ZZ |
 ZZ0035ZZ ZZ0036ZZ +---+ +---+ +----+ ZZ0037ZZ ZZ0038ZZ ZZ0039ZZ |
 +---+---+ ZZ0040ZZ ZZ0041ZZ ZZ0042ZZ ZZ0043ZZ ZZ0044ZZ L2/L3 ZZ0045ZZ ZZ0046ZZ ZZ0047ZZ |
 ZZ0048ZZ ZZ0049ZZ +---+ +---+ +----+ ZZ0050ZZ ZZ0051ZZ ZZ0052ZZ |
 ZZ0053ZZ ZZ0054ZZ +------+--------------------+ ZZ0055ZZ ZZ0056ZZ |
 ZZ0057ZZ ZZ0058ZZ ZZ0059ZZ ZZ0060ZZ ZZ0061ZZ
 ZZ0062ZZ ZZ0063ZZ ZZ0064ZZ ZZ0065ZZ
 ZZ0066ZZ | |Port1| |Port2| |Port3| |Port4|  |Port5| |Port6|   | ZZ0074ZZ ZZ0075ZZ
 ZZ0076ZZNSSCC ZZ0077ZZ ZZ0078ZZ ZZ0079ZZ ZZ0080ZZ
 ZZ0081ZZ ZZ0082ZZMAC0 ZZ0083ZZMAC1 ZZ0084ZZMAC2 ZZ0085ZZMAC3 ZZ0086ZZMAC4 ZZ0087ZZMAC5 ZZ0088ZZ ZZ0089ZZ |
 ZZ0090ZZ ZZ0091ZZ ZZ0092ZZ ZZ0093ZZ |
 ZZ0094ZZ ZZ0095ZZ +----ZZ0096ZZ-------ZZ0097ZZ----------ZZ0098ZZ------+ ZZ0099ZZ |
 ZZ0100ZZ ZZ0101ZZ |
 ZZ0102ZZ ZZ0103ZZ ZZ0104ZZ ZZ0105ZZ ZZ0106ZZ |
 ZZ0107ZZ ZZ0108ZZ QSGMII USXGMII USXGMII ZZ0109ZZ
 ZZ0110ZZ +--------------->ZZ0111ZZ ZZ0112ZZ ZZ0113ZZ ZZ0114ZZ
 ZZ0115ZZ +-----------------+ +----------+ +----------+ ZZ0116ZZ
 ZZ0117ZZ125/312.5 MHz clk|       (PCS0)            | ZZ0119ZZ ZZ0120ZZ chiếc tùy chọn ZZ0121ZZ
 ZZ0122ZZ ZZ0123ZZ ZZ0124ZZ<--------+ |
 +----------------->ZZ0125ZZ ZZ0126ZZ ZZ0127ZZ |
 ZZ0128ZZ
 ZZ0129ZZ ZZ0130ZZ ZZ0131ZZ ZZ0132ZZ
 ZZ0133ZZ
 ZZ0134ZZ +-----------------+ +------+ +------+ ZZ0135ZZ
 +--------------->ZZ0136ZZ QUAD PHY ZZ0137ZZ PHY4 ZZ0138ZZ PHY5 ZZ0139ZZ--------+
                  ZZ0140ZZ thay đổi
                  ZZ0141ZZ
                  ZZ0142ZZ
                  +------------------------------------------------------+

CMN (Chung) PLL, NSSCC (Bộ điều khiển đồng hồ hệ thống phụ mạng) và GCC (Toàn cầu
Các khối Bộ điều khiển Đồng hồ) nằm trong SoC và hoạt động như nhà cung cấp đồng hồ.

Khối UNIPHY nằm trong SoC và cung cấp PCS (Lớp con mã hóa vật lý) và
Chức năng XPCS (Lớp con mã hóa vật lý 10-Gigabit) để hỗ trợ các giao diện khác nhau
các chế độ giữa PPE MAC và PHY bên ngoài.

Tài liệu này tập trung vào các mô tả về công cụ PPE và trình điều khiển PPE.

Chức năng Ethernet trong PPE (Công cụ xử lý gói) bao gồm ba
các thành phần: lõi chuyển mạch, trình bao bọc cổng và Ethernet DMA.

Lõi Switch trong IPQ9574 PPE có tối đa 6 cổng bảng mặt trước và hai cổng FIFO
giao diện. Một trong hai giao diện FIFO được sử dụng cho cổng Ethernet để lưu trữ CPU
giao tiếp bằng Ethernet DMA. Cái còn lại được sử dụng để liên lạc với EIP
công cụ được sử dụng để giảm tải IPsec. Trên IPQ9574, PPE bao gồm 6 GMAC/XGMAC
có thể được kết nối với Ethernet PHY bên ngoài. Lõi chuyển mạch cũng bao gồm BM (Bộ đệm
Các mô-đun QM (Quản lý hàng đợi) và SCH (Bộ lập lịch) để hỗ trợ
xử lý gói tin.

Trình bao bọc cổng cung cấp các kết nối từ 6 GMAC/XGMACS đến UNIPHY (PCS) hỗ trợ
nhiều chế độ khác nhau như SGMII/QSGMII/PSGMII/USXGMII/10G-BASER. Có 3 UNIPHY (PCS)
các phiên bản được hỗ trợ trên IPQ9574.

Ethernet DMA được sử dụng để truyền và nhận các gói giữa hệ thống con Ethernet
và máy chủ ARM CPU.

Sau đây liệt kê các khối chính trong động cơ PPE sẽ được điều khiển bởi điều này
Trình điều khiển PPE:

- BM
    BM là trình quản lý bộ đệm phần cứng cho các cổng chuyển đổi PPE.
- QM
    Trình quản lý hàng đợi để quản lý hàng đợi phần cứng đầu ra của các cổng chuyển đổi PPE.
-SCH
    Bộ lập lịch quản lý việc lập lịch lưu lượng phần cứng cho các cổng chuyển đổi PPE.
- L2
    Khối L2 thực hiện việc kết nối gói tin trong lõi chuyển mạch. Miền cầu là
    được đại diện bởi miền VSI (Phiên bản chuyển đổi ảo) trong PPE. Việc học FDB có thể
    được bật dựa trên miền VSI và chuyển tiếp cầu nối xảy ra trong miền VSI.
-MAC
    PPE trong IPQ9574 hỗ trợ tối đa sáu MAC (MAC0 đến MAC5) tương ứng
    đến sáu cổng chuyển đổi (port1 đến port6). Khối MAC được kết nối với PHY bên ngoài
    thông qua khối UNIPHY PCS. Mỗi khối MAC bao gồm các khối GMAC và XGMAC và
    cổng chuyển đổi có thể chọn sử dụng GMAC hoặc XMAC thông qua lựa chọn MUX theo
    khả năng của PHY bên ngoài.
-EDMA (Ethernet DMA)
    Ethernet DMA được sử dụng để truyền và nhận các gói Ethernet giữa PPE
    cổng và lõi ARM.

Gói nhận được trên cổng PPE MAC có thể được chuyển tiếp đến một cổng PPE MAC khác. Nó có thể
cũng được chuyển tiếp đến cổng chuyển mạch nội bộ port0 để gói có thể được chuyển đến
Các lõi ARM sử dụng công cụ Ethernet DMA (EDMA). Trình điều khiển Ethernet DMA sẽ cung cấp
gói đến giao diện 'netdevice' tương ứng.

Việc khởi tạo phần mềm của PPE MAC (netdevice), PCS và PHY bên ngoài tương tác
với khung Linux PHYLINK để quản lý kết nối giữa các cổng PPE và
các PHY được kết nối và trạng thái liên kết cổng. Điều này cũng được minh họa trong sơ đồ trên.


Tổng quan về trình điều khiển PPE
===================
Trình điều khiển PPE là trình điều khiển Ethernet cho SoC Qualcomm IPQ. Nó là một trình điều khiển nền tảng duy nhất
bao gồm phần PPE và phần Ethernet DMA. Phần PPE khởi tạo và điều khiển
các khối khác nhau trong lõi chuyển đổi PPE như khối BM/QM/L2 và MAC PPE. Phần EDMA
điều khiển Ethernet DMA để truyền gói giữa các cổng PPE và lõi ARM, đồng thời cho phép
trình điều khiển netdevice cho các cổng PPE.

Các tệp trình điều khiển PPE trong driver/net/ethernet/qualcomm/ppe/ được liệt kê như bên dưới:

- Tập tin tạo
- pp.c
- pp.h
- ppe_config.c
- ppe_config.h
- ppe_debugfs.c
- ppe_debugfs.h
- ppe_regs.h

Tệp ppe.c chứa trình điều khiển nền tảng PPE chính và đảm nhận việc khởi tạo
PPE chuyển đổi các khối lõi như QM, BM và L2. API cấu hình cho các phần cứng này
các khối được cung cấp trong tệp ppe_config.c.

Ppe.h xác định cấu trúc dữ liệu thiết bị PPE sẽ được sử dụng bởi các chức năng của trình điều khiển PPE.

ppe_debugfs.c kích hoạt các bộ đếm thống kê PPE như bộ đếm cổng Rx và Tx của PPE,
Bộ đếm mã CPU và bộ đếm hàng đợi.


SoC được hỗ trợ trình điều khiển PPE
=========================

Trình điều khiển PPE hỗ trợ IPQ SoC sau:

-IPQ9574


Kích hoạt trình điều khiển
===================

Trình điều khiển nằm trong cấu trúc menu tại::

-> Trình điều khiển thiết bị
    -> Hỗ trợ thiết bị mạng (NETDEVICES [=y])
      -> Hỗ trợ trình điều khiển Ethernet
        -> Thiết bị Qualcomm
          -> Hỗ trợ Ethernet của Qualcomm Technologies, Inc. PPE

Nếu trình điều khiển được xây dựng dưới dạng mô-đun thì mô-đun đó sẽ được gọi là qcom-ppe.

Trình điều khiển PPE về mặt chức năng phụ thuộc vào trình điều khiển bộ điều khiển đồng hồ CMN PLL và NSSCC.
Vui lòng đảm bảo rằng các mô-đun phụ thuộc đã được cài đặt trước khi cài đặt trình điều khiển PPE
mô-đun.


Gỡ lỗi
=========

Bộ đếm phần cứng PPE có thể được truy cập bằng giao diện debugfs từ
Thư mục ZZ0000ZZ.