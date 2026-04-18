.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/ice.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================
hỗ trợ devlink băng
=====================

Tài liệu này mô tả các tính năng của devlink được ZZ0000ZZ triển khai
trình điều khiển thiết bị.

Thông số
==========

.. list-table:: Generic parameters implemented
   :widths: 5 5 90

   * - Name
     - Mode
     - Notes
   * - ``enable_roce``
     - runtime
     - mutually exclusive with ``enable_iwarp``
   * - ``enable_iwarp``
     - runtime
     - mutually exclusive with ``enable_roce``
   * - ``tx_scheduling_layers``
     - permanent
     - The ice hardware uses hierarchical scheduling for Tx with a fixed
       number of layers in the scheduling tree. Each of them are decision
       points. Root node represents a port, while all the leaves represent
       the queues. This way of configuring the Tx scheduler allows features
       like DCB or devlink-rate (documented below) to configure how much
       bandwidth is given to any given queue or group of queues, enabling
       fine-grained control because scheduling parameters can be configured
       at any given layer of the tree.

       The default 9-layer tree topology was deemed best for most workloads,
       as it gives an optimal ratio of performance to configurability. However,
       for some specific cases, this 9-layer topology might not be desired.
       One example would be sending traffic to queues that are not a multiple
       of 8. Because the maximum radix is limited to 8 in 9-layer topology,
       the 9th queue has a different parent than the rest, and it's given
       more bandwidth credits. This causes a problem when the system is
       sending traffic to 9 queues:

       | tx_queue_0_packets: 24163396
       | tx_queue_1_packets: 24164623
       | tx_queue_2_packets: 24163188
       | tx_queue_3_packets: 24163701
       | tx_queue_4_packets: 24163683
       | tx_queue_5_packets: 24164668
       | tx_queue_6_packets: 23327200
       | tx_queue_7_packets: 24163853
       | tx_queue_8_packets: 91101417 < Too much traffic is sent from 9th

       To address this need, you can switch to a 5-layer topology, which
       changes the maximum topology radix to 512. With this enhancement,
       the performance characteristic is equal as all queues can be assigned
       to the same parent in the tree. The obvious drawback of this solution
       is a lower configuration depth of the tree.

       Use the ``tx_scheduling_layer`` parameter with the devlink command
       to change the transmit scheduler topology. To use 5-layer topology,
       use a value of 5. For example:
       $ devlink dev param set pci/0000:16:00.0 name tx_scheduling_layers
       value 5 cmode permanent
       Use a value of 9 to set it back to the default value.

       You must do PCI slot powercycle for the selected topology to take effect.

       To verify that value has been set:
       $ devlink dev param show pci/0000:16:00.0 name tx_scheduling_layers
   * - ``msix_vec_per_pf_max``
     - driverinit
     - Set the max MSI-X that can be used by the PF, rest can be utilized for
       SRIOV. The range is from min value set in msix_vec_per_pf_min to
       2k/number of ports.
   * - ``msix_vec_per_pf_min``
     - driverinit
     - Set the min MSI-X that will be used by the PF. This value inform how many
       MSI-X will be allocated statically. The range is from 2 to value set
       in msix_vec_per_pf_max.

.. list-table:: Driver specific parameters implemented
    :widths: 5 5 90

    * - Name
      - Mode
      - Description
    * - ``local_forwarding``
      - runtime
      - Controls loopback behavior by tuning scheduler bandwidth.
        It impacts all kinds of functions: physical, virtual and
        subfunctions.
        Supported values are:

        ``enabled`` - loopback traffic is allowed on port

        ``disabled`` - loopback traffic is not allowed on this port

        ``prioritized`` - loopback traffic is prioritized on this port

        Default value of ``local_forwarding`` parameter is ``enabled``.
        ``prioritized`` provides ability to adjust loopback traffic rate to increase
        one port capacity at cost of the another. User needs to disable
        local forwarding on one of the ports in order have increased capacity
        on the ``prioritized`` port.

Phiên bản thông tin
===================

Trình điều khiển ZZ0000ZZ báo cáo các phiên bản sau

.. list-table:: devlink info versions implemented
    :widths: 5 5 5 90

    * - Name
      - Type
      - Example
      - Description
    * - ``board.id``
      - fixed
      - K65390-000
      - The Product Board Assembly (PBA) identifier of the board.
    * - ``cgu.id``
      - fixed
      - 36
      - The Clock Generation Unit (CGU) hardware revision identifier.
    * - ``fw.mgmt``
      - running
      - 2.1.7
      - 3-digit version number of the management firmware running on the
        Embedded Management Processor of the device. It controls the PHY,
        link, access to device resources, etc. Intel documentation refers to
        this as the EMP firmware.
    * - ``fw.mgmt.api``
      - running
      - 1.5.1
      - 3-digit version number (major.minor.patch) of the API exported over
        the AdminQ by the management firmware. Used by the driver to
        identify what commands are supported. Historical versions of the
        kernel only displayed a 2-digit version number (major.minor).
    * - ``fw.mgmt.build``
      - running
      - 0x305d955f
      - Unique identifier of the source for the management firmware.
    * - ``fw.undi``
      - running
      - 1.2581.0
      - Version of the Option ROM containing the UEFI driver. The version is
        reported in ``major.minor.patch`` format. The major version is
        incremented whenever a major breaking change occurs, or when the
        minor version would overflow. The minor version is incremented for
        non-breaking changes and reset to 1 when the major version is
        incremented. The patch version is normally 0 but is incremented when
        a fix is delivered as a patch against an older base Option ROM.
    * - ``fw.psid.api``
      - running
      - 0.80
      - Version defining the format of the flash contents.
    * - ``fw.bundle_id``
      - running
      - 0x80002ec0
      - Unique identifier of the firmware image file that was loaded onto
        the device. Also referred to as the EETRACK identifier of the NVM.
    * - ``fw.app.name``
      - running
      - ICE OS Default Package
      - The name of the DDP package that is active in the device. The DDP
        package is loaded by the driver during initialization. Each
        variation of the DDP package has a unique name.
    * - ``fw.app``
      - running
      - 1.3.1.0
      - The version of the DDP package that is active in the device. Note
        that both the name (as reported by ``fw.app.name``) and version are
        required to uniquely identify the package.
    * - ``fw.app.bundle_id``
      - running
      - 0xc0000001
      - Unique identifier for the DDP package loaded in the device. Also
        referred to as the DDP Track ID. Can be used to uniquely identify
        the specific DDP package.
    * - ``fw.netlist``
      - running
      - 1.1.2000-6.7.0
      - The version of the netlist module. This module defines the device's
        Ethernet capabilities and default settings, and is used by the
        management firmware as part of managing link and device
        connectivity.
    * - ``fw.netlist.build``
      - running
      - 0xee16ced7
      - The first 4 bytes of the hash of the netlist module contents.
    * - ``fw.cgu``
      - running
      - 8032.16973825.6021
      - The version of Clock Generation Unit (CGU). Format:
        <CGU type>.<configuration version>.<firmware version>.

Cập nhật nhanh
==============

Trình điều khiển ZZ0000ZZ triển khai hỗ trợ cập nhật flash bằng cách sử dụng
Giao diện ZZ0001ZZ. Nó hỗ trợ cập nhật flash thiết bị bằng cách sử dụng
hình ảnh flash kết hợp có chứa ZZ0002ZZ, ZZ0003ZZ và
Các thành phần ZZ0004ZZ.

.. list-table:: List of supported overwrite modes
   :widths: 5 95

   * - Bits
     - Behavior
   * - ``DEVLINK_FLASH_OVERWRITE_SETTINGS``
     - Do not preserve settings stored in the flash components being
       updated. This includes overwriting the port configuration that
       determines the number of physical functions the device will
       initialize with.
   * - ``DEVLINK_FLASH_OVERWRITE_SETTINGS`` and ``DEVLINK_FLASH_OVERWRITE_IDENTIFIERS``
     - Do not preserve either settings or identifiers. Overwrite everything
       in the flash with the contents from the provided image, without
       performing any preservation. This includes overwriting device
       identifying fields such as the MAC address, VPD area, and device
       serial number. It is expected that this combination be used with an
       image customized for the specific device.

Phần cứng băng không hỗ trợ ghi đè chỉ các mã định danh trong khi
bảo toàn cài đặt và do đó ZZ0000ZZ trên
riêng sẽ bị từ chối. Nếu không có mặt nạ ghi đè nào được cung cấp, chương trình cơ sở sẽ bị
được hướng dẫn giữ nguyên tất cả các cài đặt và xác định các trường khi cập nhật.

Tải lại
=======

Trình điều khiển ZZ0000ZZ hỗ trợ kích hoạt firmware mới sau khi cập nhật flash
sử dụng ZZ0001ZZ với ZZ0002ZZ
hành động.

.. code:: shell

    $ devlink dev reload pci/0000:01:00.0 reload action fw_activate

Phần sụn mới được kích hoạt bằng cách phát hành một thiết bị nhúng cụ thể
Đặt lại bộ xử lý quản lý yêu cầu thiết bị đặt lại và tải lại
Hình ảnh phần mềm EMP.

Trình điều khiển hiện không hỗ trợ tải lại trình điều khiển thông qua
ZZ0000ZZ.

Chia cổng
==========

Trình điều khiển ZZ0000ZZ chỉ hỗ trợ chia cổng cho cổng 0, vì FW có
một tập hợp các tùy chọn phân chia cổng có sẵn được xác định trước cho toàn bộ thiết bị.

Cần phải khởi động lại hệ thống để áp dụng tính năng chia cổng.

Lệnh sau sẽ chọn tùy chọn chia cổng với 4 cổng:

.. code:: shell

    $ devlink port split pci/0000:16:00.0/0 count 4

Danh sách tất cả các tùy chọn cổng khả dụng sẽ được in ở chế độ gỡ lỗi động sau
mỗi lệnh ZZ0000ZZ và ZZ0001ZZ. Tùy chọn đầu tiên là mặc định.

.. code:: shell

    ice 0000:16:00.0: Available port split options and max port speeds (Gbps):
    ice 0000:16:00.0: Status  Split      Quad 0          Quad 1
    ice 0000:16:00.0:         count  L0  L1  L2  L3  L4  L5  L6  L7
    ice 0000:16:00.0: Active  2     100   -   -   - 100   -   -   -
    ice 0000:16:00.0:         2      50   -  50   -   -   -   -   -
    ice 0000:16:00.0: Pending 4      25  25  25  25   -   -   -   -
    ice 0000:16:00.0:         4      25  25   -   -  25  25   -   -
    ice 0000:16:00.0:         8      10  10  10  10  10  10  10  10
    ice 0000:16:00.0:         1     100   -   -   -   -   -   -   -

Có thể có nhiều tùy chọn cổng FW với cùng số lượng cổng phân chia. Khi nào
yêu cầu đếm số lượng cổng tương tự được đưa ra lần nữa, tùy chọn cổng FW tiếp theo với
số lượng phân chia cổng giống nhau sẽ được chọn.

ZZ0000ZZ sẽ chọn tùy chọn có số lượng phân chia là 1. Nếu
không có tùy chọn FW nào với số lượng phân chia là 1, bạn sẽ gặp lỗi.

Khu vực
=======

Trình điều khiển ZZ0000ZZ triển khai các vùng sau để truy cập nội bộ
dữ liệu thiết bị.

.. list-table:: regions implemented
    :widths: 15 85

    * - Name
      - Description
    * - ``nvm-flash``
      - The contents of the entire flash chip, sometimes referred to as
        the device's Non Volatile Memory.
    * - ``shadow-ram``
      - The contents of the Shadow RAM, which is loaded from the beginning
        of the flash. Although the contents are primarily from the flash,
        this area also contains data generated during device boot which is
        not stored in flash.
    * - ``device-caps``
      - The contents of the device firmware's capabilities buffer. Useful to
        determine the current state and configuration of the device.

Cả hai vùng ZZ0000ZZ và ZZ0001ZZ đều có thể được truy cập mà không cần
ảnh chụp nhanh. Vùng ZZ0002ZZ yêu cầu ảnh chụp nhanh vì nội dung được
được gửi bởi phần sụn và không thể chia thành các lần đọc riêng biệt.

Người dùng có thể yêu cầu chụp ảnh nhanh ngay lập tức cho cả ba khu vực
thông qua lệnh ZZ0000ZZ.

.. code:: shell

    $ devlink region show
    pci/0000:01:00.0/nvm-flash: size 10485760 snapshot [] max 1
    pci/0000:01:00.0/device-caps: size 4096 snapshot [] max 10

    $ devlink region new pci/0000:01:00.0/nvm-flash snapshot 1
    $ devlink region dump pci/0000:01:00.0/nvm-flash snapshot 1

    $ devlink region dump pci/0000:01:00.0/nvm-flash snapshot 1
    0000000000000000 0014 95dc 0014 9514 0035 1670 0034 db30
    0000000000000010 0000 0000 ffff ff04 0029 8c00 0028 8cc8
    0000000000000020 0016 0bb8 0016 1720 0000 0000 c00f 3ffc
    0000000000000030 bada cce5 bada cce5 bada cce5 bada cce5

    $ devlink region read pci/0000:01:00.0/nvm-flash snapshot 1 address 0 length 16
    0000000000000000 0014 95dc 0014 9514 0035 1670 0034 db30

    $ devlink region delete pci/0000:01:00.0/nvm-flash snapshot 1

    $ devlink region new pci/0000:01:00.0/device-caps snapshot 1
    $ devlink region dump pci/0000:01:00.0/device-caps snapshot 1
    0000000000000000 01 00 01 00 00 00 00 00 01 00 00 00 00 00 00 00
    0000000000000010 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    0000000000000020 02 00 02 01 32 03 00 00 0a 00 00 00 25 00 00 00
    0000000000000030 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    0000000000000040 04 00 01 00 01 00 00 00 00 00 00 00 00 00 00 00
    0000000000000050 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    0000000000000060 05 00 01 00 03 00 00 00 00 00 00 00 00 00 00 00
    0000000000000070 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    0000000000000080 06 00 01 00 01 00 00 00 00 00 00 00 00 00 00 00
    0000000000000090 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    00000000000000a0 08 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00
    00000000000000b0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    00000000000000c0 12 00 01 00 01 00 00 00 01 00 01 00 00 00 00 00
    00000000000000d0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    00000000000000e0 13 00 01 00 00 01 00 00 00 00 00 00 00 00 00 00
    00000000000000f0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    0000000000000100 14 00 01 00 01 00 00 00 00 00 00 00 00 00 00 00
    0000000000000110 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    0000000000000120 15 00 01 00 01 00 00 00 00 00 00 00 00 00 00 00
    0000000000000130 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    0000000000000140 16 00 01 00 01 00 00 00 00 00 00 00 00 00 00 00
    0000000000000150 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    0000000000000160 17 00 01 00 06 00 00 00 00 00 00 00 00 00 00 00
    0000000000000170 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    0000000000000180 18 00 01 00 01 00 00 00 01 00 00 00 08 00 00 00
    0000000000000190 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    00000000000001a0 22 00 01 00 01 00 00 00 00 00 00 00 00 00 00 00
    00000000000001b0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    00000000000001c0 40 00 01 00 00 08 00 00 08 00 00 00 00 00 00 00
    00000000000001d0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    00000000000001e0 41 00 01 00 00 08 00 00 00 00 00 00 00 00 00 00
    00000000000001f0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    0000000000000200 42 00 01 00 00 08 00 00 00 00 00 00 00 00 00 00
    0000000000000210 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

    $ devlink region delete pci/0000:01:00.0/device-caps snapshot 1

Tỷ lệ liên kết nhà phát triển
=============================

Trình điều khiển ZZ0000ZZ triển khai API tốc độ liên kết phát triển. Nó cho phép giảm tải
QoS phân cấp cho phần cứng. Nó cho phép người dùng nhóm ảo
Các chức năng theo cấu trúc cây và gán các tham số được hỗ trợ: tx_share,
tx_max, tx_priority và tx_weight cho mỗi nút trong cây. Rất hiệu quả
người dùng có được khả năng kiểm soát lượng băng thông được phân bổ cho mỗi
Nhóm VF. Điều này sau đó được thực thi bởi HW.

Người ta cho rằng tính năng này loại trừ lẫn nhau khi DCB được thực hiện
trong FW và ADQ hoặc bất kỳ tính năng trình điều khiển nào có thể kích hoạt các thay đổi trong QoS,
ví dụ như tạo lớp lưu lượng mới. Trình điều khiển sẽ ngăn chặn DCB
hoặc cấu hình ADQ nếu người dùng bắt đầu thực hiện bất kỳ thay đổi nào đối với các nút bằng cách sử dụng
tốc độ liên kết phát triển API. Để định cấu hình các tính năng đó, việc tải lại trình điều khiển là cần thiết.
Tương ứng, nếu ADQ hoặc DCB được định cấu hình thì trình điều khiển sẽ không xuất
thứ bậc nào cả, hoặc sẽ loại bỏ thứ bậc chưa được chạm tới nếu những thứ đó
các tính năng được bật sau khi hệ thống phân cấp được xuất, nhưng trước bất kỳ tính năng nào
những thay đổi được thực hiện.

Tính năng này cũng phụ thuộc vào việc switchdev được bật trong hệ thống.
Điều này là bắt buộc vì tốc độ liên kết phát triển yêu cầu các đối tượng cổng liên kết phát triển phải được
hiện tại và những đối tượng đó chỉ được tạo ở chế độ switchdev.

Nếu trình điều khiển được đặt ở chế độ switchdev, nó sẽ xuất nội bộ
phân cấp thời điểm VF được tạo. Gốc của cây luôn luôn
được đại diện bởi nút_0. Người dùng không thể xóa nút này. Lá
các nút và nút có con cũng không thể xóa được.

.. list-table:: Attributes supported
    :widths: 15 85

    * - Name
      - Description
    * - ``tx_max``
      - maximum bandwidth to be consumed by the tree Node. Rate Limit is
        an absolute number specifying a maximum amount of bytes a Node may
        consume during the course of one second. Rate limit guarantees
        that a link will not oversaturate the receiver on the remote end
        and also enforces an SLA between the subscriber and network
        provider.
    * - ``tx_share``
      - minimum bandwidth allocated to a tree node when it is not blocked.
        It specifies an absolute BW. While tx_max defines the maximum
        bandwidth the node may consume, the tx_share marks committed BW
        for the Node.
    * - ``tx_priority``
      - allows for usage of strict priority arbiter among siblings. This
        arbitration scheme attempts to schedule nodes based on their
        priority as long as the nodes remain within their bandwidth limit.
        Range 0-7. Nodes with priority 7 have the highest priority and are
        selected first, while nodes with priority 0 have the lowest
        priority. Nodes that have the same priority are treated equally.
    * - ``tx_weight``
      - allows for usage of Weighted Fair Queuing arbitration scheme among
        siblings. This arbitration scheme can be used simultaneously with
        the strict priority. Range 1-200. Only relative values matter for
        arbitration.

ZZ0000ZZ và ZZ0001ZZ có thể được sử dụng đồng thời. Trong trường hợp đó
các nút có cùng mức độ ưu tiên tạo thành nhóm con WFQ trong nhóm anh chị em
và việc phân xử giữa chúng dựa trên trọng số được chỉ định.

.. code:: shell

    # enable switchdev
    $ devlink dev eswitch set pci/0000:4b:00.0 mode switchdev

    # at this point driver should export internal hierarchy
    $ echo 2 > /sys/class/net/ens785np0/device/sriov_numvfs

    $ devlink port function rate show
    pci/0000:4b:00.0/node_25: type node parent node_24
    pci/0000:4b:00.0/node_24: type node parent node_0
    pci/0000:4b:00.0/node_32: type node parent node_31
    pci/0000:4b:00.0/node_31: type node parent node_30
    pci/0000:4b:00.0/node_30: type node parent node_16
    pci/0000:4b:00.0/node_19: type node parent node_18
    pci/0000:4b:00.0/node_18: type node parent node_17
    pci/0000:4b:00.0/node_17: type node parent node_16
    pci/0000:4b:00.0/node_14: type node parent node_5
    pci/0000:4b:00.0/node_5: type node parent node_3
    pci/0000:4b:00.0/node_13: type node parent node_4
    pci/0000:4b:00.0/node_12: type node parent node_4
    pci/0000:4b:00.0/node_11: type node parent node_4
    pci/0000:4b:00.0/node_10: type node parent node_4
    pci/0000:4b:00.0/node_9: type node parent node_4
    pci/0000:4b:00.0/node_8: type node parent node_4
    pci/0000:4b:00.0/node_7: type node parent node_4
    pci/0000:4b:00.0/node_6: type node parent node_4
    pci/0000:4b:00.0/node_4: type node parent node_3
    pci/0000:4b:00.0/node_3: type node parent node_16
    pci/0000:4b:00.0/node_16: type node parent node_15
    pci/0000:4b:00.0/node_15: type node parent node_0
    pci/0000:4b:00.0/node_2: type node parent node_1
    pci/0000:4b:00.0/node_1: type node parent node_0
    pci/0000:4b:00.0/node_0: type node
    pci/0000:4b:00.0/1: type leaf parent node_25
    pci/0000:4b:00.0/2: type leaf parent node_25

    # let's create some custom node
    $ devlink port function rate add pci/0000:4b:00.0/node_custom parent node_0

    # second custom node
    $ devlink port function rate add pci/0000:4b:00.0/node_custom_1 parent node_custom

    # reassign second VF to newly created branch
    $ devlink port function rate set pci/0000:4b:00.0/2 parent node_custom_1

    # assign tx_weight to the VF
    $ devlink port function rate set pci/0000:4b:00.0/2 tx_weight 5

    # assign tx_share to the VF
    $ devlink port function rate set pci/0000:4b:00.0/2 tx_share 500Mbps