.. SPDX-License-Identifier: (GPL-2.0-only OR BSD-2-Clause)

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/marvell/octeontx2.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================================
Trình điều khiển hạt nhân Marvell OcteonTx2 RVU
===============================================

Bản quyền (c) 2020 Marvell International Ltd.

Nội dung
========

-ZZ0000ZZ
-ZZ0001ZZ
-ZZ0002ZZ
-ZZ0003ZZ
-ZZ0004ZZ
-ZZ0005ZZ

Tổng quan
========

Đơn vị ảo hóa tài nguyên (RVU) trên bản đồ OcteonTX2 SOC của Marvell HW
tài nguyên từ mạng, tiền điện tử và các khối chức năng khác vào
Các chức năng vật lý và ảo tương thích với PCI. Mỗi khối chức năng
lại có nhiều chức năng cục bộ (LF) để cung cấp cho các thiết bị PCI.
RVU hỗ trợ nhiều chức năng vật lý (PF) PCIe SRIOV và ảo
chức năng (VF). PF0 được gọi là chức năng quản trị/quản trị viên (AF)
và có đặc quyền cung cấp các LF của khối chức năng RVU cho mỗi
PF/VF.

Khối chức năng mạng được quản lý RVU
 - Nhóm mạng hoặc bộ cấp phát bộ đệm (NPA)
 - Bộ điều khiển giao diện mạng (NIX)
 - Trình phân tích cú pháp mạng CAM (NPC)
 - Đơn vị lập lịch/đồng bộ/đặt hàng (SSO)
 - Giao diện lặp lại (LBK)

RVU quản lý các khối chức năng không nối mạng
 - Máy gia tốc tiền điện tử (CPT)
 - Đơn vị hẹn giờ theo lịch trình (TIM)
 - Đơn vị lập lịch/đồng bộ/đặt hàng (SSO)
   Được sử dụng cho cả usecase mạng và không mạng

Ví dụ về cung cấp tài nguyên
 - PF/VF với tài nguyên NIX-LF & NPA-LF hoạt động như một thiết bị mạng thuần túy
 - PF/VF với tài nguyên CPT-LF hoạt động như một thiết bị giảm tải tiền điện tử thuần túy.

Các khối chức năng RVU có khả năng cấu hình cao theo yêu cầu phần mềm.

Thiết lập chương trình cơ sở sau đây trước khi khởi động kernel
 - Cho phép số lượng RVU PF được yêu cầu dựa trên số lượng liên kết vật lý.
 - Số lượng VF trên mỗi PF là tĩnh hoặc có thể định cấu hình tại thời điểm biên dịch.
   Dựa trên cấu hình, phần sụn sẽ gán VF cho từng PF.
 - Đồng thời gán vectơ MSIX cho từng PF và VF.
 - Những thứ này không bị thay đổi sau khi khởi động kernel.

Trình điều khiển
=======

Nhân Linux sẽ có nhiều trình điều khiển đăng ký cho các PF và VF khác nhau
của RVU. Mạng Wrt sẽ có 3 loại trình điều khiển.

Trình điều khiển chức năng quản trị
---------------------

Như đã đề cập ở trên RVU PF0 được gọi là chức năng quản trị (AF), trình điều khiển này
hỗ trợ cung cấp tài nguyên và cấu hình các khối chức năng.
Không xử lý bất kỳ I/O nào. Nó thiết lập một số nội dung cơ bản nhưng hầu hết
chức năng đạt được thông qua các yêu cầu cấu hình từ PF và VF.

PF/VF giao tiếp với AF thông qua vùng bộ nhớ dùng chung (hộp thư). Khi
nhận yêu cầu AF thực hiện việc cung cấp tài nguyên và cấu hình CTNH khác.
AF luôn được gắn vào nhân máy chủ, nhưng các PF và VF của chúng có thể được máy chủ sử dụng
chính kernel hoặc được gắn vào máy ảo hoặc các ứng dụng không gian người dùng như
DPDK, v.v. Vì vậy, AF phải xử lý các yêu cầu cung cấp/cấu hình được gửi
bởi bất kỳ thiết bị nào từ bất kỳ tên miền nào.

Trình điều khiển AF cũng tương tác với phần sụn cơ bản để
 - Quản lý các liên kết ethernet vật lý tức là CGX LMAC.
 - Truy xuất thông tin như tốc độ, song công, autoneg, v.v.
 - Truy xuất PHY EEPROM và số liệu thống kê.
 - Cấu hình các chế độ FEC, PAM
 - v.v.

Trình điều khiển AF từ phía mạng thuần túy hỗ trợ chức năng sau.
 - Ánh xạ một liên kết vật lý tới RVU PF mà netdev đã đăng ký.
 - Gắn các LF khối NIX và NPA vào RVU PF/VF để cung cấp vùng đệm, RQ, SQ
   cho chức năng kết nối mạng thông thường.
 - Bật/tắt/cấu hình điều khiển luồng (tạm dừng khung).
 - Cấu hình liên quan đến dấu thời gian HW PTP.
 - Cấu hình hồ sơ trình phân tích cú pháp NPC, về cơ bản cách phân tích pkt và thông tin cần trích xuất.
 - NPC trích xuất cấu hình hồ sơ, những gì cần trích xuất từ ​​pkt để khớp với dữ liệu trong các mục MCAM.
 - Quản lý các mục NPC MCAM, theo yêu cầu có thể đóng khung và cài đặt các quy tắc chuyển tiếp gói được yêu cầu.
 - Xác định thuật toán chia tỷ lệ bên nhận (RSS).
 - Xác định các thuật toán giảm tải phân đoạn (ví dụ TSO)
 - Cấu hình tước, chụp và chèn VLAN.
 - Cấu hình khối SSO và TIM cung cấp hỗ trợ lập lịch gói.
 - Hỗ trợ Debugfs, để kiểm tra việc cung cấp tài nguyên hiện tại, trạng thái hiện tại của
   Nhóm NPA, NIX RQ, SQ và CQ, các số liệu thống kê khác nhau, v.v. giúp khắc phục sự cố.
 - Và nhiều hơn nữa.

Trình điều khiển chức năng vật lý
------------------------

RVU PF này xử lý IO, được ánh xạ tới liên kết ethernet vật lý và điều này
trình điều khiển đăng ký một netdev. Điều này hỗ trợ SR-IOV. Như đã nói ở trên driver này
giao tiếp với AF bằng hộp thư. Để lấy thông tin từ vật lý
liên kết trình điều khiển này nói chuyện với AF và AF nhận thông tin đó từ chương trình cơ sở và phản hồi
trở lại tức là không thể nói chuyện trực tiếp với phần sụn.

Hỗ trợ ethtool để định cấu hình liên kết, RSS, số lượng hàng đợi, kích thước hàng đợi,
kiểm soát luồng, bộ lọc ntuple, kết xuất PHY EEPROM, cấu hình FEC, v.v.

Trình điều khiển chức năng ảo
-----------------------

Có hai loại VF, VF chia sẻ liên kết vật lý với cha mẹ của chúng
SR-IOV PF và VF hoạt động theo cặp sử dụng kênh vòng lặp HW nội bộ (LBK).

Loại 1:
 - Các VF này và PF gốc của chúng chia sẻ một liên kết vật lý và được sử dụng để liên lạc bên ngoài.
 - VF không thể giao tiếp trực tiếp với AF, chúng gửi tin nhắn mbox tới PF và PF
   chuyển tiếp nó đến AF. AF sau khi xử lý, phản hồi lại PF và chuyển tiếp PF
   câu trả lời cho VF.
 - Từ quan điểm chức năng, không có sự khác biệt giữa PF và VF như cùng loại
   Tài nguyên CTNH được gắn vào cả hai. Nhưng người dùng chỉ có thể định cấu hình một số nội dung
   từ PF vì PF được coi là chủ sở hữu/quản trị viên của liên kết.

Loại 2:
 - RVU PF0 tức là chức năng quản trị tạo ra các VF này và ánh xạ chúng tới các kênh của khối loopback.
 - Một bộ gồm hai VF (VF0 & VF1, VF2 & VF3 .. vân vân) hoạt động như một cặp tức là các gói tin được gửi đi
   VF0 sẽ được VF1 nhận và ngược lại.
 - Những VF này có thể được sử dụng bởi các ứng dụng hoặc máy ảo để liên lạc giữa chúng
   mà không gửi lưu lượng truy cập bên ngoài. Không có công tắc nào trong CTNH, do đó hỗ trợ
   cho các VF loopback.
 - Chúng giao tiếp trực tiếp với AF (PF0) qua mbox.

Ngoại trừ các kênh IO hoặc các liên kết được sử dụng để nhận và truyền gói tin, còn có
không có sự khác biệt nào khác giữa các loại VF này. Trình điều khiển AF đảm nhiệm việc ánh xạ kênh IO,
do đó trình điều khiển VF giống nhau hoạt động cho cả hai loại thiết bị.

Luồng gói cơ bản
=================

Xâm nhập
-------

1. CGX LMAC nhận gói tin.
2. Chuyển tiếp gói tới khối NIX.
3. Sau đó gửi tới khối NPC để phân tích cú pháp và sau đó tra cứu MCAM để lấy thiết bị RVU đích.
4. NIX LF được gắn vào thiết bị RVU đích sẽ phân bổ bộ đệm từ nhóm bộ đệm được ánh xạ RQ của khối LF NPA.
5. RQ có thể được chọn bởi RSS hoặc bằng cách định cấu hình quy tắc MCAM bằng số RQ.
6. Gói có mã DMA'ed và trình điều khiển sẽ được thông báo.

Đi ra
------

1. Trình điều khiển chuẩn bị mô tả gửi và gửi tới SQ để truyền.
2. SQ đã được cấu hình (bằng AF) để truyền trên một liên kết/kênh cụ thể.
3. Vòng mô tả SQ được duy trì trong các bộ đệm được phân bổ từ nhóm ánh xạ SQ của khối LF NPA.
4. Khối NIX truyền gói tin trên kênh được chỉ định.
5. Các mục NPC MCAM có thể được cài đặt để chuyển hướng pkt sang một kênh khác.

Phóng viên sức khỏe Devlink
========================

NPA Phóng viên
-------------
Các phóng viên NPA có trách nhiệm báo cáo và khắc phục nhóm lỗi sau:

1. Sự kiện GENERAL

- Lỗi do hoạt động của PF chưa được ánh xạ.
   - Lỗi do vô hiệu hóa cấp phát/miễn phí cho các khối CTNH khác (NIX, SSO, TIM, DPI và AURA).

2. Sự kiện ERROR

- Lỗi do NPA_AQ_INST_S đọc hoặc ghi NPA_AQ_RES_S.
   - Lỗi chuông cửa AQ.

3. Sự kiện RAS

- Báo cáo lỗi RAS cho NPA_AQ_INST_S/NPA_AQ_RES_S.

4. Sự kiện RVU

- Lỗi do vị trí chưa được ánh xạ.

Đầu ra mẫu::

~# devlink sức khỏe
	pci/0002:01:00.0:
	  phóng viên hw_npa_intr
	      lỗi trạng thái khỏe mạnh 2872 khôi phục 2872 Last_dump_date 2020-12-10 Last_dump_time 09:39:09 Grace_ Period 0 auto_recover true auto_dump true
	  phóng viên hw_npa_gen
	      trạng thái khỏe mạnh lỗi 2872 khôi phục 2872 Last_dump_date 2020-12-11 Last_dump_time 04:43:04 Grace_ Period 0 auto_recover true auto_dump true
	  phóng viên hw_npa_err
	      lỗi trạng thái khỏe mạnh 2871 khôi phục 2871 Last_dump_date 2020-12-10 Last_dump_time 09:39:17 Grace_ Period 0 auto_recover true auto_dump true
	   phóng viên hw_npa_ras
	      trạng thái lỗi lành mạnh 0 khôi phục 0 Last_dump_date 2020-12-10 Last_dump_time 09:32:40 Grace_ Period 0 auto_recover true auto_dump true

Mỗi phóng viên vứt bỏ

- Loại lỗi
 - Lỗi Đăng ký giá trị
 - Lý do bằng lời nói

Ví dụ::

~# devlink kết xuất sức khỏe hiển thị pci/0002:01:00.0 phóng viên hw_npa_gen
	 NPA_AF_GENERAL:
	         NPA Reg ngắt chung: 1
	         NIX0: RX bị vô hiệu hóa miễn phí
	~# devlink kết xuất sức khỏe hiển thị pci/0002:01:00.0 phóng viên hw_npa_intr
	 NPA_AF_RVU:
	         NPA RVU Ngắt Reg: 1
	         Lỗi bỏ bản đồ vị trí
	~# devlink kết xuất sức khỏe hiển thị pci/0002:01:00.0 phóng viên hw_npa_err
	 NPA_AF_ERR:
	        NPA Lỗi ngắt Reg: 4096
	        Lỗi chuông cửa AQ


NIX Phóng viên
-------------
Các phóng viên NIX có trách nhiệm báo cáo và khắc phục nhóm lỗi sau:

1. Sự kiện GENERAL

- Nhận được gói mirror/multicast bị rớt do không đủ bộ đệm.
   - SMQ Hoạt động xả nước.

2. Sự kiện ERROR

- Lỗi bộ nhớ do WQE đọc/ghi từ bộ đệm multicast/mirror.
   - Nhận lỗi danh sách sao chép multicast/mirror.
   - Nhận gói tin trên PF chưa được ánh xạ.
   - Lỗi do NIX_AQ_INST_S đọc hoặc ghi NIX_AQ_RES_S.
   - Lỗi chuông cửa AQ.

3. Sự kiện RAS

- Báo cáo lỗi RAS cho NIX Nhận cấu trúc mục nhập Multicast/Mirror.
   - Báo cáo lỗi RAS cho WQE/Dữ liệu gói được đọc từ Multicast/Mirror Buffer..
   - Báo cáo lỗi RAS cho NIX_AQ_INST_S/NIX_AQ_RES_S.

4. Sự kiện RVU

- Lỗi do vị trí chưa được ánh xạ.

Đầu ra mẫu::

~# ./devlink sức khỏe
	pci/0002:01:00.0:
	  phóng viên hw_npa_intr
	    trạng thái lỗi lành mạnh 0 khôi phục 0 Grace_ Period 0 auto_recover true auto_dump true
	  phóng viên hw_npa_gen
	    trạng thái lỗi lành mạnh 0 khôi phục 0 Grace_ Period 0 auto_recover true auto_dump true
	  phóng viên hw_npa_err
	    trạng thái lỗi lành mạnh 0 khôi phục 0 Grace_ Period 0 auto_recover true auto_dump true
	  phóng viên hw_npa_ras
	    trạng thái lỗi lành mạnh 0 khôi phục 0 Grace_ Period 0 auto_recover true auto_dump true
	  phóng viên hw_nix_intr
	    lỗi trạng thái khỏe mạnh 1121 khôi phục 1121 Last_dump_date 2021-01-19 Last_dump_time 05:42:26 Grace_ Period 0 auto_recover true auto_dump true
	  phóng viên hw_nix_gen
	    trạng thái khỏe mạnh lỗi 949 khôi phục 949 Last_dump_date 2021-01-19 Last_dump_time 05:42:43 Grace_ Period 0 auto_recover true auto_dump true
	  phóng viên hw_nix_err
	    lỗi trạng thái khỏe mạnh 1147 khôi phục 1147 Last_dump_date 2021-01-19 Last_dump_time 05:42:59 Grace_ Period 0 auto_recover true auto_dump true
	  phóng viên hw_nix_ras
	    trạng thái khỏe mạnh lỗi 409 khôi phục 409 Last_dump_date 2021-01-19 Last_dump_time 05:43:16 Grace_ Period 0 auto_recover true auto_dump true

Mỗi phóng viên vứt bỏ

- Loại lỗi
 - Lỗi Đăng ký giá trị
 - Lý do bằng lời nói

Ví dụ::

~# devlink kết xuất sức khỏe hiển thị pci/0002:01:00.0 phóng viên hw_nix_intr
	 NIX_AF_RVU:
	        NIX RVU Ngắt Reg: 1
	        Lỗi bỏ bản đồ vị trí
	~# devlink kết xuất sức khỏe hiển thị pci/0002:01:00.0 phóng viên hw_nix_gen
	 NIX_AF_GENERAL:
	        NIX Reg ngắt chung: 1
	        Rx multicast gói thả
	~# devlink kết xuất sức khỏe hiển thị pci/0002:01:00.0 phóng viên hw_nix_err
	 NIX_AF_ERR:
	        NIX Lỗi ngắt Reg: 64
	        Rx trên PF_FUNC chưa được ánh xạ


Chất lượng dịch vụ
==================


Các thuật toán phần cứng được sử dụng trong lập kế hoạch
--------------------------------------

Giao diện truyền octeontx2 silicon và CN10K bao gồm năm cấp độ truyền
bắt đầu từ SMQ/MDQ, TL4 đến TL1. Mỗi gói sẽ đi qua MDQ, TL4 đến TL1
cấp độ. Mỗi cấp độ chứa một mảng hàng đợi để hỗ trợ lập kế hoạch và định hình.
Phần cứng sử dụng các thuật toán dưới đây tùy thuộc vào mức độ ưu tiên của hàng đợi lập lịch.
khi người dùng tạo các lớp tc với mức độ ưu tiên khác nhau, trình điều khiển sẽ cấu hình
bộ lập lịch được phân bổ cho lớp với mức độ ưu tiên được chỉ định cùng với giới hạn tốc độ
cấu hình.

1. Ưu tiên nghiêm ngặt

- Khi các gói được gửi tới MDQ, phần cứng sẽ chọn tất cả các MDQ đang hoạt động có mức độ ưu tiên khác nhau
         sử dụng mức độ ưu tiên nghiêm ngặt.

2. Vòng tròn

- Các MDQ hoạt động có cùng mức độ ưu tiên được chọn bằng cách sử dụng vòng tròn.


Thiết lập giảm tải HTB
-----------------

1. Kích hoạt tính năng giảm tải CTNH trên giao diện::

# ethtool -K <giao diện> bật hw-tc-offload

2. Tạo root htb::

# tc qdisc thêm dev <giao diện> clsact
        # tc qdisc thay thế tay cầm gốc dev <giao diện> 1: giảm tải htb

3. Tạo các lớp tc với mức độ ưu tiên khác nhau::

Lớp # tc thêm dev <interface> cha 1: classid 1:1 tỷ lệ htb 10Gbit ưu tiên 1

Lớp # tc thêm dev <interface> cha 1: classid 1:2 htb rate 10Gbit prio 7

4. Tạo các lớp tc có cùng mức độ ưu tiên và lượng tử khác nhau::

Lớp # tc thêm dev <giao diện> cha mẹ 1: classid tỷ lệ htb 1:1 10Gbit prio 2 lượng tử 409600

Lớp # tc thêm dev <interface> cha 1: classid 1:2 htb rate 10Gbit prio 2 lượng tử 188416

Lớp # tc thêm dev <interface> cha 1: classid 1:3 htb rate 10Gbit prio 2 lượng tử 32768


Đại diện RVU
================

Trình điều khiển đại diện RVU bổ sung hỗ trợ cho việc tạo các thiết bị đại diện cho
VF của RVU PF trong hệ thống. Thiết bị đại diện được tạo khi người dùng kích hoạt
chế độ switchdev.
Chế độ Switchdev có thể được bật trước hoặc sau khi thiết lập numVF SRIOV.
Tất cả các thiết bị đại diện đều dùng chung một NIXLF nhưng mỗi thiết bị có một Rx/Tx chuyên dụng
hàng đợi. Trình điều khiển đại diện RVU PF đăng ký một netdev riêng cho mỗi trình điều khiển
Cặp hàng đợi Rx/Tx.

HW hiện tại không hỗ trợ công tắc tích hợp có thể thực hiện việc học và thực hiện L2
chuyển tiếp các gói tin giữa người đại diện và người đại diện. Do đó, đường dẫn gói
giữa người được đại diện và người đại diện của mình đạt được bằng cách thiết lập các
Bộ lọc NPC MCAM.
Các gói truyền phù hợp với các bộ lọc này sẽ được lặp lại thông qua phần cứng
kênh/giao diện loopback (tức là thay vì gửi chúng ra khỏi giao diện MAC).
Bộ lọc này sẽ lại khớp với các bộ lọc đã cài đặt và sẽ được chuyển tiếp.
Cách này người đại diện => người đại diện và người đại diện => gói người đại diện
con đường đạt được. Các quy tắc này được cài đặt khi đại diện được tạo
và được kích hoạt/hủy kích hoạt dựa trên trạng thái giao diện người đại diện/người đại diện.

Ví dụ sử dụng:

- Chuyển thiết bị sang chế độ switchdev::

Bộ chuyển đổi chế độ pci/0002:1c:00.0 dành cho nhà phát triển # devlink

- Danh sách các thiết bị đại diện trên hệ thống::

Hiển thị liên kết # ip
	Rpf1vf0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast trạng thái DOWN chế độ DEFAULT mặc định nhóm qlen 1000 liên kết/ether f6:43:83:ee:26:21 brd ff:ff:ff:ff:ff:ff
	Rpf1vf1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast trạng thái DOWN chế độ DEFAULT mặc định nhóm qlen 1000 liên kết/ether 12:b2:54:0e:24:54 brd ff:ff:ff:ff:ff:ff
	Rpf1vf2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast trạng thái DOWN chế độ DEFAULT mặc định nhóm qlen 1000 liên kết/ether 4a:12:c4:4c:32:62 brd ff:ff:ff:ff:ff:ff
	Rpf1vf3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast trạng thái DOWN chế độ DEFAULT nhóm mặc định qlen 1000 liên kết/ether ca:cb:68:0e:e2:6e brd ff:ff:ff:ff:ff:ff
	Rpf2vf0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast trạng thái DOWN chế độ DEFAULT nhóm mặc định qlen 1000 liên kết/ether 06:cc:ad:b4:f0:93 brd ff:ff:ff:ff:ff:ff


Để xóa các thiết bị đại diện khỏi hệ thống. Thay đổi thiết bị sang chế độ cũ.

- Chuyển thiết bị sang chế độ cũ::

# devlink dev eswitch thiết lập chế độ kế thừa pci/0002:1c:00.0

Các đại diện RVU có thể được quản lý bằng cổng devlink
(xem giao diện ZZ0000ZZ).

- Hiển thị cổng devlink của đại diện::

Cổng # devlink
	pci/0002:1c:00.0/0: gõ eth netdev Rpf1vf0 hương vị cổng vật lý 0 có thể chia sai
	pci/0002:1c:00.0/1: loại eth netdev Rpf1vf1 hương vị bộ điều khiển pcivf 0 pfnum 1 vfnum 1 sai bên ngoài có thể chia tách sai
	pci/0002:1c:00.0/2: type eth netdev Rpf1vf2 hương vị bộ điều khiển pcivf 0 pfnum 1 vfnum 2 sai bên ngoài có thể chia tách sai
	pci/0002:1c:00.0/3: type eth netdev Rpf1vf3 hương vị bộ điều khiển pcivf 0 pfnum 1 vfnum 3 sai bên ngoài có thể chia tách sai

Thuộc tính chức năng
===================

Các thuộc tính chức năng hỗ trợ đại diện RVU cho các đại diện.
Cấu hình chức năng cổng của các đại diện được hỗ trợ thông qua cổng eswitch devlink.

Thiết lập địa chỉ MAC
-----------------

Trình điều khiển đại diện RVU hỗ trợ cơ chế attr chức năng cổng devlink để thiết lập MAC
địa chỉ. (tham khảo Tài liệu/mạng/devlink/devlink-port.rst)

- Để thiết lập địa chỉ MAC cho cổng 2::

Bộ chức năng cổng # devlink pci/0002:1c:00.0/2 hw_addr 5c:a1:1b:5e:43:11
	Cổng # devlink hiển thị pci/0002:1c:00.0/2
	pci/0002:1c:00.0/2: type eth netdev Rpf1vf2 hương vị bộ điều khiển pcivf 0 pfnum 1 vfnum 2 sai bên ngoài có thể chia tách sai
	chức năng:
		hw_addr 5c:a1:1b:5e:43:11


giảm tải TC
==========

Trình điều khiển đại diện rvu triển khai hỗ trợ giảm tải các quy tắc tc bằng cách sử dụng các đại diện cổng.

- Thả gói tin có vlan id 3::

Bộ lọc # tc thêm giao thức dev Rpf1vf0 802.1Q cha mẹ ffff: hoa vlan_id 3 vlan_ethtype ipv4 Skip_sw thả hành động

- Redirect các gói tin vlan id 5 và gói IPv4 về eth1, sau khi đã loại bỏ vlan header.::

Bộ lọc # tc thêm giao thức xâm nhập dev Rpf1vf0 802.1Q hoa vlan_id 5 vlan_ethtype ipv4 Skip_sw hành động vlan pop hành động nhân bản chuyển hướng xâm nhập dev eth1