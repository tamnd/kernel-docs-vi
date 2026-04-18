.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/PCI/endpoint/pci-ntb-function.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Chức năng PCI NTB
===================

:Tác giả: Kishon Vijay Abraham I <kishon@ti.com>

Cầu nối không trong suốt PCI (NTB) cho phép hai hệ thống máy chủ giao tiếp
với nhau bằng cách hiển thị mỗi máy chủ như một thiết bị cho máy chủ khác.
NTB thường hỗ trợ khả năng tạo ngắt trên điều khiển từ xa
máy, hiển thị phạm vi bộ nhớ dưới dạng BAR và thực hiện DMA.  Họ cũng hỗ trợ
bàn di chuột, là vùng bộ nhớ trong NTB có thể truy cập được
từ cả hai máy.

PCI NTB Chức năng cho phép hai hệ thống (hoặc máy chủ) khác nhau giao tiếp
với nhau bằng cách cấu hình các cá thể điểm cuối theo cách sao cho
các giao dịch từ một hệ thống được chuyển sang hệ thống khác.

Trong sơ đồ bên dưới, hàm PCI NTB định cấu hình SoC với nhiều
Các phiên bản PCI Điểm cuối (EP) theo cách giao dịch từ một EP
bộ điều khiển được chuyển đến bộ điều khiển EP khác. Khi chức năng PCI NTB
định cấu hình SoC với nhiều phiên bản EP, HOST1 và HOST2 có thể
liên lạc với nhau bằng cách sử dụng SoC làm cầu nối.

.. code-block:: text

    +-------------+                                   +-------------+
    |             |                                   |             |
    |    HOST1    |                                   |    HOST2    |
    |             |                                   |             |
    +------^------+                                   +------^------+
           |                                                 |
           |                                                 |
 +---------|-------------------------------------------------|---------+
 |  +------v------+                                   +------v------+  |
 |  |             |                                   |             |  |
 |  |     EP      |                                   |     EP      |  |
 |  | CONTROLLER1 |                                   | CONTROLLER2 |  |
 |  |             <----------------------------------->             |  |
 |  |             |                                   |             |  |
 |  |             |                                   |             |  |
 |  |             |  SoC With Multiple EP Instances   |             |  |
 |  |             |  (Configured using NTB Function)  |             |  |
 |  +-------------+                                   +-------------+  |
 +---------------------------------------------------------------------+

Các cấu trúc được sử dụng để triển khai NTB
====================================

1) Vùng cấu hình
	2) Thanh ghi tự Scratchpad
	3) Thanh ghi Scratchpad ngang hàng
	4) Thanh ghi chuông cửa (DB)
	5) Cửa sổ bộ nhớ (MW)


Vùng cấu hình:
--------------

Vùng cấu hình là cấu trúc dành riêng cho NTB được triển khai bằng NTB
Trình điều khiển chức năng điểm cuối. Trình điều khiển chức năng NTB phía máy chủ và điểm cuối sẽ
trao đổi thông tin với nhau bằng cách sử dụng khu vực này. Vùng cấu hình có
Thanh ghi điều khiển/trạng thái để định cấu hình Bộ điều khiển điểm cuối. Máy chủ có thể
ghi vào vùng này để định cấu hình Đơn vị dịch địa chỉ gửi đi
(ATU) và để cho biết trạng thái liên kết. Điểm cuối có thể cho biết trạng thái của
các lệnh do máy chủ đưa ra trong khu vực này. Điểm cuối cũng có thể chỉ ra
phần bù của bảng ghi nhớ và số lượng cửa sổ bộ nhớ cho máy chủ sử dụng vùng này.

Định dạng của Vùng cấu hình được đưa ra dưới đây. Tất cả các trường ở đây là 32 bit.

.. code-block:: text

	+------------------------+
	|         COMMAND        |
	+------------------------+
	|         ARGUMENT       |
	+------------------------+
	|         STATUS         |
	+------------------------+
	|         TOPOLOGY       |
	+------------------------+
	|    ADDRESS (LOWER 32)  |
	+------------------------+
	|    ADDRESS (UPPER 32)  |
	+------------------------+
	|           SIZE         |
	+------------------------+
	|   NO OF MEMORY WINDOW  |
	+------------------------+
	|  MEMORY WINDOW1 OFFSET |
	+------------------------+
	|       SPAD OFFSET      |
	+------------------------+
	|        SPAD COUNT      |
	+------------------------+
	|      DB ENTRY SIZE     |
	+------------------------+
	|         DB DATA        |
	+------------------------+
	|            :           |
	+------------------------+
	|            :           |
	+------------------------+
	|         DB DATA        |
	+------------------------+


  COMMAND:

	NTB function supports three commands:

	  CMD_CONFIGURE_DOORBELL (0x1): Command to configure doorbell. Before
	invoking this command, the host should allocate and initialize
	MSI/MSI-X vectors (i.e., initialize the MSI/MSI-X Capability in the
	Endpoint). The endpoint on receiving this command will configure
	the outbound ATU such that transactions to Doorbell BAR will be routed
	to the MSI/MSI-X address programmed by the host. The ARGUMENT
	register should be populated with number of DBs to configure (in the
	lower 16 bits) and if MSI or MSI-X should be configured (BIT 16).

	  CMD_CONFIGURE_MW (0x2): Command to configure memory window (MW). The
	host invokes this command after allocating a buffer that can be
	accessed by remote host. The allocated address should be programmed
	in the ADDRESS register (64 bit), the size should be programmed in
	the SIZE register and the memory window index should be programmed
	in the ARGUMENT register. The endpoint on receiving this command
	will configure the outbound ATU such that transactions to MW BAR
	are routed to the address provided by the host.

	  CMD_LINK_UP (0x3): Command to indicate an NTB application is
	bound to the EP device on the host side. Once the endpoint
	receives this command from both the hosts, the endpoint will
	raise a LINK_UP event to both the hosts to indicate the host
	NTB applications can start communicating with each other.

  ARGUMENT:

	The value of this register is based on the commands issued in
	command register. See COMMAND section for more information.

  TOPOLOGY:

	Set to NTB_TOPO_B2B_USD for Primary interface
	Set to NTB_TOPO_B2B_DSD for Secondary interface

  ADDRESS/SIZE:

	Address and Size to be used while configuring the memory window.
	See "CMD_CONFIGURE_MW" for more info.

  MEMORY WINDOW1 OFFSET:

	Memory Window 1 and Doorbell registers are packed together in the
	same BAR. The initial portion of the region will have doorbell
	registers and the latter portion of the region is for memory window 1.
	This register will specify the offset of the memory window 1.

  NO OF MEMORY WINDOW:

	Specifies the number of memory windows supported by the NTB device.

  SPAD OFFSET:

	Self scratchpad region and config region are packed together in the
	same BAR. The initial portion of the region will have config region
	and the latter portion of the region is for self scratchpad. This
	register will specify the offset of the self scratchpad registers.

  SPAD COUNT:

	Specifies the number of scratchpad registers supported by the NTB
	device.

  DB ENTRY SIZE:

	Used to determine the offset within the DB BAR that should be written
	in order to raise doorbell. EPF NTB can use either MSI or MSI-X to
	ring doorbell (MSI-X support will be added later). MSI uses same
	address for all the interrupts and MSI-X can provide different
	addresses for different interrupts. The MSI/MSI-X address is provided
	by the host and the address it gives is based on the MSI/MSI-X
	implementation supported by the host. For instance, ARM platform
	using GIC ITS will have the same MSI-X address for all the interrupts.
	In order to support all the combinations and use the same mechanism
	for both MSI and MSI-X, EPF NTB allocates a separate region in the
	Outbound Address Space for each of the interrupts. This region will
	be mapped to the MSI/MSI-X address provided by the host. If a host
	provides the same address for all the interrupts, all the regions
	will be translated to the same address. If a host provides different
	addresses, the regions will be translated to different addresses. This
	will ensure there is no difference while raising the doorbell.

  DB DATA:

	EPF NTB supports 32 interrupts, so there are 32 DB DATA registers.
	This holds the MSI/MSI-X data that has to be written to MSI address
	for raising doorbell interrupt. This will be populated by EPF NTB
	while invoking CMD_CONFIGURE_DOORBELL.

Thanh ghi Scratchpad:
---------------------

Mỗi máy chủ có không gian đăng ký riêng được phân bổ trong bộ nhớ của điểm cuối NTB
  bộ điều khiển. Chúng đều có thể đọc và ghi được từ cả hai phía của cây cầu.
  Chúng được sử dụng bởi các ứng dụng được xây dựng trên NTB và có thể được sử dụng để vượt qua điều khiển
  và thông tin trạng thái giữa hai bên của thiết bị.

Thanh ghi Scratchpad có 2 phần
	1) Self Scratchpad: Không gian đăng ký riêng của máy chủ
	2) Peer Scratchpad: Không gian đăng ký của máy chủ từ xa.

Thanh ghi chuông cửa:
-------------------

Các thanh ghi chuông cửa được các máy chủ sử dụng để làm gián đoạn lẫn nhau.

Cửa sổ bộ nhớ:
--------------

Việc truyền dữ liệu thực tế giữa hai máy chủ sẽ diễn ra bằng cách sử dụng
  cửa sổ bộ nhớ.

Cấu trúc mô hình hóa:
====================

Có 5 vùng riêng biệt trở lên (config, self Scratchpad, ngang hàng
bàn di chuột, chuông cửa, một hoặc nhiều cửa sổ bộ nhớ) được mô hình hóa để đạt được
Chức năng NTB. Cần có ít nhất một cửa sổ bộ nhớ trong khi có nhiều hơn
một được cho phép. Tất cả các vùng này phải được ánh xạ tới BAR để các máy chủ có thể
truy cập vào các khu vực này.

Nếu một BAR 32 bit được phân bổ cho từng vùng này, sơ đồ sẽ
trông như thế này:

====== =================
BAR KHÔNG CONSTRUCTS USED
====== =================
Vùng cấu hình BAR0
Bàn di chuột tự BAR1
Bàn di chuột ngang hàng BAR2
Chuông cửa BAR3
Cửa sổ bộ nhớ BAR4 1
Cửa sổ bộ nhớ BAR5 2
====== =================

Tuy nhiên, nếu chúng tôi phân bổ một BAR riêng cho từng khu vực thì sẽ không có
có đủ BAR cho tất cả các vùng trong nền tảng chỉ hỗ trợ 64-bit
BAR.

Để được hầu hết các nền tảng hỗ trợ, các khu vực phải
được đóng gói và ánh xạ tới BAR theo cách cung cấp chức năng NTB và
cũng đảm bảo rằng máy chủ không truy cập vào bất kỳ khu vực nào mà nó không được phép
đến.

Sơ đồ sau được sử dụng trong Chức năng EPF NTB:

========================================
BAR KHÔNG CONSTRUCTS USED
========================================
Vùng cấu hình BAR0 + Bàn di chuột tự
Bàn di chuột ngang hàng BAR1
Chuông cửa BAR2 + Cửa sổ bộ nhớ 1
Cửa sổ bộ nhớ BAR3 2
Cửa sổ bộ nhớ BAR4 3
Cửa sổ bộ nhớ BAR5 4
========================================

Với sơ đồ này, đối với chức năng cơ bản của NTB, 3 BAR là đủ.

Cấu hình mô hình/Vùng Scratchpad:
----------------------------------

.. code-block:: text

 +-----------------+------->+------------------+        +-----------------+
 |       BAR0      |        |  CONFIG REGION   |        |       BAR0      |
 +-----------------+----+   +------------------+<-------+-----------------+
 |       BAR1      |    |   |SCRATCHPAD REGION |        |       BAR1      |
 +-----------------+    +-->+------------------+<-------+-----------------+
 |       BAR2      |            Local Memory            |       BAR2      |
 +-----------------+                                    +-----------------+
 |       BAR3      |                                    |       BAR3      |
 +-----------------+                                    +-----------------+
 |       BAR4      |                                    |       BAR4      |
 +-----------------+                                    +-----------------+
 |       BAR5      |                                    |       BAR5      |
 +-----------------+                                    +-----------------+
   EP CONTROLLER 1                                        EP CONTROLLER 2

Sơ đồ trên hiển thị Vùng cấu hình + Vùng Scratchpad cho HOST1 (được kết nối với
Bộ điều khiển EP 1) được phân bổ trong bộ nhớ cục bộ. HOST1 có thể truy cập cấu hình
vùng và vùng Scratchpad (tự Scratchpad) sử dụng BAR0 của bộ điều khiển EP 1.
Máy chủ ngang hàng (HOST2 được kết nối với bộ điều khiển EP 2) cũng có thể truy cập vào đây
vùng Scratchpad (bàn di chuột ngang hàng) sử dụng BAR1 của bộ điều khiển EP 2. Điều này
sơ đồ hiển thị trường hợp phân bổ vùng Cấu hình và vùng Scratchpad
đối với HOST1, tuy nhiên điều tương tự cũng được áp dụng cho HOST2.

Mô hình chuông cửa/Cửa sổ bộ nhớ 1:
----------------------------------

.. code-block:: text

 +-----------------+    +----->+----------------+-----------+-----------------+
 |       BAR0      |    |      |   Doorbell 1   +-----------> MSI-X ADDRESS 1 |
 +-----------------+    |      +----------------+           +-----------------+
 |       BAR1      |    |      |   Doorbell 2   +---------+ |                 |
 +-----------------+----+      +----------------+         | |                 |
 |       BAR2      |           |   Doorbell 3   +-------+ | +-----------------+
 +-----------------+----+      +----------------+       | +-> MSI-X ADDRESS 2 |
 |       BAR3      |    |      |   Doorbell 4   +-----+ |   +-----------------+
 +-----------------+    |      |----------------+     | |   |                 |
 |       BAR4      |    |      |                |     | |   +-----------------+
 +-----------------+    |      |      MW1       +---+ | +-->+ MSI-X ADDRESS 3||
 |       BAR5      |    |      |                |   | |     +-----------------+
 +-----------------+    +----->-----------------+   | |     |                 |
   EP CONTROLLER 1             |                |   | |     +-----------------+
                               |                |   | +---->+ MSI-X ADDRESS 4 |
                               +----------------+   |       +-----------------+
                                EP CONTROLLER 2     |       |                 |
                                  (OB SPACE)        |       |                 |
                                                    +------->      MW1        |
                                                            |                 |
                                                            |                 |
                                                            +-----------------+
                                                            |                 |
                                                            |                 |
                                                            |                 |
                                                            |                 |
                                                            |                 |
                                                            +-----------------+
                                                             PCI Address Space
                                                             (Managed by HOST2)

Sơ đồ trên cho thấy cách ánh xạ chuông cửa và cửa sổ bộ nhớ 1 sao cho
HOST1 có thể kích hoạt ngắt chuông cửa trên HOST2 và cách HOST1 có thể truy cập
bộ đệm được hiển thị bởi HOST2 bằng cửa sổ bộ nhớ1 (MW1). Đây là chuông cửa và
Các vùng cửa sổ bộ nhớ 1 được phân bổ trong địa chỉ gửi đi (OB) của bộ điều khiển EP 2
không gian. Phân bổ và cấu hình BAR cho chuông cửa và cửa sổ bộ nhớ1
được thực hiện trong giai đoạn khởi tạo trình điều khiển chức năng điểm cuối NTB.
Ánh xạ từ không gian 2 OB của bộ điều khiển EP tới không gian địa chỉ PCI được thực hiện khi HOST2
gửi CMD_CONFIGURE_MW/CMD_CONFIGURE_DOORBELL.

Mô hình hóa bộ nhớ tùy chọn Windows:
---------------------------------

Điều này được mô hình hóa giống như MW1 nhưng mỗi cửa sổ bộ nhớ bổ sung
được ánh xạ tới các BAR riêng biệt.