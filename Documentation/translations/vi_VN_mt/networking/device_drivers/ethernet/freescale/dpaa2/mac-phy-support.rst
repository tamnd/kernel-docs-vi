.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/freescale/dpaa2/mac-phy-support.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

==========================
Hỗ trợ DPAA2 MAC / PHY
==========================

:Bản quyền: ZZ0000ZZ 2019 NXP

Tổng quan
---------

Hỗ trợ DPAA2 MAC / PHY bao gồm một bộ API giúp mạng DPAA2
trình điều khiển (dpaa2-eth, dpaa2-ethsw) tương tác với thư viện PHY.

Kiến trúc phần mềm DPAA2
---------------------------

Trong số các đối tượng DPAA2 khác, bus fsl-mc xuất các đối tượng DPNI (trừu tượng một
giao diện mạng) và các đối tượng DPMAC (trừu tượng hóa MAC). Trình điều khiển dpaa2-eth
thăm dò đối tượng DPNI và kết nối cũng như định cấu hình đối tượng DPMAC với
sự giúp đỡ của phylink.

Kết nối dữ liệu có thể được thiết lập giữa DPNI và DPMAC hoặc giữa hai
DPNI. Tùy thuộc vào loại kết nối, netif_carrier_[bật/tắt] được xử lý
trực tiếp bởi trình điều khiển dpaa2-eth hoặc bằng phyllink.

.. code-block:: none

  Sources of abstracted link state information presented by the MC firmware

                                               +--------------------------------------+
  +------------+                  +---------+  |                           xgmac_mdio |
  | net_device |                  | phylink |--|  +-----+  +-----+  +-----+  +-----+  |
  +------------+                  +---------+  |  | PHY |  | PHY |  | PHY |  | PHY |  |
        |                             |        |  +-----+  +-----+  +-----+  +-----+  |
      +------------------------------------+   |                    External MDIO bus |
      |            dpaa2-eth               |   +--------------------------------------+
      +------------------------------------+
        |                             |                                           Linux
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        |                             |                                     MC firmware
        |              /|             V
  +----------+        / |       +----------+
  |          |       /  |       |          |
  |          |       |  |       |          |
  |   DPNI   |<------|  |<------|   DPMAC  |
  |          |       |  |       |          |
  |          |       \  |<---+  |          |
  +----------+        \ |    |  +----------+
                       \|    |
                             |
           +--------------------------------------+
           | MC firmware polling MAC PCS for link |
           |  +-----+  +-----+  +-----+  +-----+  |
           |  | PCS |  | PCS |  | PCS |  | PCS |  |
           |  +-----+  +-----+  +-----+  +-----+  |
           |                    Internal MDIO bus |
           +--------------------------------------+


Tùy thuộc vào cài đặt cấu hình chương trình cơ sở MC, mỗi MAC có thể ở một trong hai chế độ:

- DPMAC_LINK_TYPE_FIXED: việc quản lý trạng thái liên kết được xử lý độc quyền bởi
  phần mềm MC bằng cách thăm dò MAC PCS. Không cần phải đăng ký một
  phiên bản phylink, trình điều khiển dpaa2-eth sẽ không liên kết với dpmac được kết nối
  đối tượng cả.

- DPMAC_LINK_TYPE_PHY: Firmware MC vẫn đang chờ cập nhật trạng thái liên kết
  nhưng trên thực tế, chúng được truyền nghiêm ngặt giữa dpaa2-mac (dựa trên
  phylink) và trình điều khiển net_device đính kèm của nó (dpaa2-eth, dpaa2-ethsw),
  bỏ qua phần sụn một cách hiệu quả.

Thực hiện
--------------

Tại thời điểm thăm dò hoặc khi điểm cuối của DPNI được thay đổi linh hoạt, dpaa2-eth
có trách nhiệm tìm hiểu xem đối tượng ngang hàng có phải là DPMAC hay không và liệu đây có phải là
trường hợp, để tích hợp nó với PHYLINK bằng cách sử dụng dpaa2_mac_connect() API,
sẽ làm như sau:

- tra cứu cây thiết bị để biết ràng buộc tương thích với PHYLINK (tay cầm phy)
 - sẽ tạo một phiên bản PHYLINK được liên kết với net_device đã nhận
 - kết nối với PHY bằng phyllink_of_phy_connect()

Lệnh gọi lại phylink_mac_ops sau đây được triển khai:

- .validate() sẽ cung cấp các mã liên kết được hỗ trợ với khả năng MAC
   chỉ khi phy_interface_t là RGMII_* (hiện tại, đây là giao diện duy nhất
   loại liên kết được trình điều khiển hỗ trợ).

- .mac_config() sẽ định cấu hình MAC trong cấu hình mới bằng cách sử dụng
   dpmac_set_link_state() Phần mềm MC API.

- .mac_link_up() / .mac_link_down() sẽ cập nhật liên kết MAC bằng cách sử dụng tương tự
   API được mô tả ở trên.

Tại trình điều khiển unbind() hoặc khi đối tượng DPNI bị ngắt kết nối khỏi DPMAC,
Trình điều khiển dpaa2-eth gọi dpaa2_mac_disconnect(), điều này sẽ ngắt kết nối
khỏi PHY và hủy phiên bản PHYLINK.

Trong trường hợp kết nối DPNI-DPMAC, 'ip link set dev eth0 up' sẽ bắt đầu
trình tự thao tác sau:

(1) phylink_start() được gọi từ .dev_open().
(2) Lệnh gọi lại .mac_config() và .mac_link_up() được gọi bởi PHYLINK.
(3) Để định cấu hình HW MAC, MC Firmware API
    dpmac_set_link_state() được gọi.
(4) Phần sụn cuối cùng sẽ thiết lập HW MAC trong cấu hình mới.
(5) Lệnh gọi netif_carrier_on() được thực hiện trực tiếp từ PHYLINK trên thiết bị được liên kết
    net_device.
(6) Trình điều khiển dpaa2-eth xử lý irq LINK_STATE_CHANGE để
    bật/tắt Rx taildrop dựa trên cài đặt khung tạm dừng.

.. code-block:: none

  +---------+               +---------+
  | PHYLINK |-------------->|  eth0   |
  +---------+           (5) +---------+
  (1) ^  |
      |  |
      |  v (2)
  +-----------------------------------+
  |             dpaa2-eth             |
  +-----------------------------------+
         |                    ^ (6)
         |                    |
         v (3)                |
  +---------+---------------+---------+
  |  DPMAC  |               |  DPNI   |
  +---------+               +---------+
  |            MC Firmware            |
  +-----------------------------------+
         |
         |
         v (4)
  +-----------------------------------+
  |             HW MAC                |
  +-----------------------------------+

Trong trường hợp kết nối DPNI-DPNI, một chuỗi thao tác thông thường sẽ trông giống như
sau đây:

(1) liên kết ip thiết lập dev eth0 lên
(2) dpni_enable() MC API đã gọi trên fsl_mc_device được liên kết.
(3) liên kết ip thiết lập dev eth1 lên
(4) dpni_enable() MC API đã gọi trên fsl_mc_device được liên kết.
(5) Cả hai phiên bản của dpaa2-eth đều nhận được Irq LINK_STATE_CHANGED
    trình điều khiển vì bây giờ trạng thái liên kết hoạt động đã lên.
(6) Netif_carrier_on() được gọi trên net_device đã xuất từ ​​
    link_state_update().

.. code-block:: none

  +---------+               +---------+
  |  eth0   |               |  eth1   |
  +---------+               +---------+
      |  ^                     ^  |
      |  |                     |  |
  (1) v  | (6)             (6) |  v (3)
  +---------+               +---------+
  |dpaa2-eth|               |dpaa2-eth|
  +---------+               +---------+
      |  ^                     ^  |
      |  |                     |  |
  (2) v  | (5)             (5) |  v (4)
  +---------+---------------+---------+
  |  DPNI   |               |  DPNI   |
  +---------+               +---------+
  |            MC Firmware            |
  +-----------------------------------+


API đã xuất khẩu
----------------

Bất kỳ trình điều khiển DPAA2 nào điều khiển các điểm cuối của đối tượng DPMAC đều phải phục vụ nó
_EVENT_ENDPOINT_CHANGED irq và kết nối/ngắt kết nối khỏi DPMAC được liên kết
khi cần thiết, hãy sử dụng API được liệt kê bên dưới::

- int dpaa2_mac_connect(struct dpaa2_mac *mac);
 - void dpaa2_mac_disconnect(struct dpaa2_mac *mac);

Việc tích hợp phyllink chỉ cần thiết khi đối tác DPMAC không thuộc
ZZ0000ZZ. Điều này có nghĩa là nó thuộc loại ZZ0001ZZ hoặc thuộc loại
ZZ0002ZZ (sự khác biệt là hai cái trong ZZ0003ZZ
chế độ, phần sụn MC không truy cập vào các thanh ghi PCS). Người ta có thể kiểm tra
điều kiện này bằng cách sử dụng trình trợ giúp sau::

- bool nội tuyến tĩnh dpaa2_mac_is_type_phy(struct dpaa2_mac *mac);

Trước khi kết nối với MAC, người gọi phải phân bổ và điền địa chỉ
Cấu trúc dpaa2_mac với net_device được liên kết, một con trỏ tới cổng MC
được sử dụng và cấu trúc fsl_mc_device thực tế của DPMAC.