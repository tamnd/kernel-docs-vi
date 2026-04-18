.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/mlx5.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
hỗ trợ liên kết phát triển mlx5
===============================

Tài liệu này mô tả các tính năng của devlink được ZZ0000ZZ triển khai
trình điều khiển thiết bị.

Thông số
==========

.. list-table:: Generic parameters implemented

   * - Name
     - Mode
     - Validation
     - Notes
   * - ``enable_roce``
     - driverinit
     - Boolean
     - If the device supports RoCE disablement, RoCE enablement state controls
       device support for RoCE capability. Otherwise, the control occurs in the
       driver stack. When RoCE is disabled at the driver level, only raw
       ethernet QPs are supported.
   * - ``io_eq_size``
     - driverinit
     - The range is between 64 and 4096.
     -
   * - ``event_eq_size``
     - driverinit
     - The range is between 64 and 4096.
     -
   * - ``max_macs``
     - driverinit
     - The range is between 1 and 2^31. Only power of 2 values are supported.
     -
   * - ``enable_sriov``
     - permanent
     - Boolean
     - Applies to each physical function (PF) independently, if the device
       supports it. Otherwise, it applies symmetrically to all PFs.
   * - ``total_vfs``
     - permanent
     - The range is between 1 and a device-specific max.
     - Applies to each physical function (PF) independently, if the device
       supports it. Otherwise, it applies symmetrically to all PFs.

Lưu ý: các tham số cố định như ZZ0000ZZ và ZZ0001ZZ yêu cầu thiết lập lại FW để có hiệu lực

.. code-block:: bash

   # setup parameters
   devlink dev param set pci/0000:01:00.0 name enable_sriov value true cmode permanent
   devlink dev param set pci/0000:01:00.0 name total_vfs value 8 cmode permanent

   # Fw reset
   devlink dev reload pci/0000:01:00.0 action fw_activate

   # for PCI related config such as sriov PCI reset/rescan is required:
   echo 1 >/sys/bus/pci/devices/0000:01:00.0/remove
   echo 1 >/sys/bus/pci/rescan
   grep ^ /sys/bus/pci/devices/0000:01:00.0/sriov_*

   * - ``num_doorbells``
     - driverinit
     - This controls the number of channel doorbells used by the netdev. In all
       cases, an additional doorbell is allocated and used for non-channel
       communication (e.g. for PTP, HWS, etc.). Supported values are:

       - 0: No channel-specific doorbells, use the global one for everything.
       - [1, max_num_channels]: Spread netdev channels equally across these
         doorbells.

Trình điều khiển ZZ0000ZZ cũng triển khai các trình điều khiển cụ thể sau:
các thông số.

.. list-table:: Driver-specific parameters implemented
   :widths: 5 5 5 85

   * - Name
     - Type
     - Mode
     - Description
   * - ``flow_steering_mode``
     - string
     - runtime
     - Controls the flow steering mode of the driver

       * ``dmfs`` Device managed flow steering. In DMFS mode, the HW
         steering entities are created and managed through firmware.
       * ``smfs`` Software managed flow steering. In SMFS mode, the HW
         steering entities are created and manage through the driver without
         firmware intervention.
       * ``hmfs`` Hardware managed flow steering. In HMFS mode, the driver
         is configuring steering rules directly to the HW using Work Queues with
         a special new type of WQE (Work Queue Element).

       SMFS mode is faster and provides better rule insertion rate compared to
       default DMFS mode.
   * - ``fdb_large_groups``
     - u32
     - driverinit
     - Control the number of large groups (size > 1) in the FDB table.

       * The default value is 15, and the range is between 1 and 1024.
   * - ``esw_multiport``
     - Boolean
     - runtime
     - Control MultiPort E-Switch shared fdb mode.

       An experimental mode where a single E-Switch is used and all the vports
       and physical ports on the NIC are connected to it.

       An example is to send traffic from a VF that is created on PF0 to an
       uplink that is natively associated with the uplink of PF1

       Note: Future devices, ConnectX-8 and onward, will eventually have this
       as the default to allow forwarding between all NIC ports in a single
       E-switch environment and the dual E-switch mode will likely get
       deprecated.

       Default: disabled
   * - ``esw_port_metadata``
     - Boolean
     - runtime
     - When applicable, disabling eswitch metadata can increase packet rate up
       to 20% depending on the use case and packet sizes.

       Eswitch port metadata state controls whether to internally tag packets
       with metadata. Metadata tagging must be enabled for multi-port RoCE,
       failover between representors and stacked devices. By default metadata is
       enabled on the supported devices in E-switch. Metadata is applicable only
       for E-switch in switchdev mode and users may disable it when NONE of the
       below use cases will be in use:
       1. HCA is in Dual/multi-port RoCE mode.
       2. VF/SF representor bonding (Usually used for Live migration)
       3. Stacked devices

       When metadata is disabled, the above use cases will fail to initialize if
       users try to enable them.

       Note: Setting this parameter does not take effect immediately. Setting
       must happen in legacy mode and eswitch port metadata takes effect after
       enabling switchdev mode.
   * - ``hairpin_num_queues``
     - u32
     - driverinit
     - We refer to a TC NIC rule that involves forwarding as "hairpin".
       Hairpin queues are mlx5 hardware specific implementation for hardware
       forwarding of such packets.

       Control the number of hairpin queues.
   * - ``hairpin_queue_size``
     - u32
     - driverinit
     - Control the size (in packets) of the hairpin queues.
   * - ``pcie_cong_inbound_high``
     - u16
     - driverinit
     - High threshold configuration for PCIe congestion events. The firmware
       will send an event once device side inbound PCIe traffic went
       above the configured high threshold for a long enough period (at least
       200ms).

       See pci_bw_inbound_high ethtool stat.

       Units are 0.01 %. Accepted values are in range [0, 10000].
       pcie_cong_inbound_low < pcie_cong_inbound_high.
       Default value: 9000 (Corresponds to 90%).
   * - ``pcie_cong_inbound_low``
     - u16
     - driverinit
     - Low threshold configuration for PCIe congestion events. The firmware
       will send an event once device side inbound PCIe traffic went
       below the configured low threshold, only after having been previously in
       a congested state.

       See pci_bw_inbound_low ethtool stat.

       Units are 0.01 %. Accepted values are in range [0, 10000].
       pcie_cong_inbound_low < pcie_cong_inbound_high.
       Default value: 7500.
   * - ``pcie_cong_outbound_high``
     - u16
     - driverinit
     - High threshold configuration for PCIe congestion events. The firmware
       will send an event once device side outbound PCIe traffic went
       above the configured high threshold for a long enough period (at least
       200ms).

       See pci_bw_outbound_high ethtool stat.

       Units are 0.01 %. Accepted values are in range [0, 10000].
       pcie_cong_outbound_low < pcie_cong_outbound_high.
       Default value: 9000 (Corresponds to 90%).
   * - ``pcie_cong_outbound_low``
     - u16
     - driverinit
     - Low threshold configuration for PCIe congestion events. The firmware
       will send an event once device side outbound PCIe traffic went
       below the configured low threshold, only after having been previously in
       a congested state.

       See pci_bw_outbound_low ethtool stat.

       Units are 0.01 %. Accepted values are in range [0, 10000].
       pcie_cong_outbound_low < pcie_cong_outbound_high.
       Default value: 7500.

   * - ``cqe_compress_type``
     - string
     - permanent
     - Configure which mechanism/algorithm should be used by the NIC that will
       affect the rate (aggressiveness) of compressed CQEs depending on PCIe bus
       conditions and other internal NIC factors. This mode affects all queues
       that enable compression.
       * ``balanced`` : Merges fewer CQEs, resulting in a moderate compression ratio but maintaining a balance between bandwidth savings and performance
       * ``aggressive`` : Merges more CQEs into a single entry, achieving a higher compression rate and maximizing performance, particularly under high traffic loads

   * - ``swp_l4_csum_mode``
     - string
     - permanent
     - Configure how the L4 checksum is calculated by the device when using
       Software Parser (SWP) hints for header locations.

       * ``default`` : Use the device's default checksum calculation
         mode. The driver will discover during init whether or
         full_csum or l4_only is in use. Setting this value explicitly
         from userspace is not allowed, but some firmware versions may
         return this value on param read.
       * ``full_csum`` : Calculate full checksum including the pseudo-header
       * ``l4_only`` : Calculate L4-only checksum, excluding the pseudo-header

Trình điều khiển ZZ0000ZZ hỗ trợ tải lại qua ZZ0001ZZ

Phiên bản thông tin
=============

Trình điều khiển ZZ0000ZZ báo cáo các phiên bản sau

.. list-table:: devlink info versions implemented
   :widths: 5 5 90

   * - Name
     - Type
     - Description
   * - ``fw.psid``
     - fixed
     - Used to represent the board id of the device.
   * - ``fw.version``
     - stored, running
     - Three digit major.minor.subminor firmware version number.

Phóng viên sức khỏe
================

phóng viên tx
-----------
Trình báo cáo tx chịu trách nhiệm báo cáo và khôi phục ba tình huống lỗi sau:

- hết thời gian chờ
    Báo cáo về phát hiện thời gian chờ kernel tx.
    Khôi phục bằng cách tìm kiếm các ngắt bị mất.
- hoàn thành lỗi tx
    Báo cáo về lỗi tx hoàn thành.
    Khôi phục bằng cách xóa hàng đợi tx và đặt lại nó.
- Dấu thời gian cổng tx PTP CQ không lành mạnh
    Báo cáo quá nhiều CQE chưa bao giờ được gửi trên cổng ts CQ.
    Khôi phục bằng cách xóa và tạo lại tất cả các kênh PTP.

Phóng viên tx cũng hỗ trợ gọi lại chẩn đoán theo yêu cầu, trên đó nó cung cấp
thông tin thời gian thực về trạng thái hàng đợi gửi của nó.

Ví dụ về lệnh của người dùng:

- Chẩn đoán trạng thái hàng đợi gửi::

$ devlink chẩn đoán sức khỏe pci/0000:82:00.0 phóng viên tx

.. note::
   This command has valid output only when interface is up, otherwise the command has empty output.

- Hiển thị số lỗi tx được chỉ định, số luồng khôi phục đã kết thúc thành công,
  tính năng tự động phục hồi đã được bật và khoảng thời gian linh hoạt kể từ lần khôi phục cuối cùng::

$ devlink chương trình sức khỏe pci/0000:82:00.0 phóng viên tx

phóng viên rx
-----------
Trình báo cáo rx chịu trách nhiệm báo cáo và khôi phục hai trường hợp lỗi sau:

- hết thời gian khởi tạo (dân số) của hàng đợi rx
    Việc tổng hợp các bộ mô tả của hàng đợi rx khi khởi tạo vòng đã hoàn tất
    trong bối cảnh napi thông qua việc kích hoạt irq. Trong trường hợp không nhận được
    số lượng mô tả tối thiểu, thời gian chờ sẽ xảy ra và
    bộ mô tả có thể được phục hồi bằng cách bỏ phiếu EQ (Hàng đợi sự kiện).
- hoàn thành rx có lỗi (được HW báo cáo về bối cảnh ngắt)
    Báo cáo về lỗi hoàn thành rx.
    Khôi phục (nếu cần) bằng cách xóa hàng đợi liên quan và đặt lại nó.

Phóng viên rx cũng hỗ trợ cuộc gọi lại chẩn đoán theo yêu cầu, trên đó nó
cung cấp thông tin thời gian thực về trạng thái hàng đợi nhận của nó.

- Chẩn đoán trạng thái của hàng đợi rx và hàng đợi hoàn thành tương ứng::

$ devlink chẩn đoán sức khỏe pci/0000:82:00.0 phóng viên rx

.. note::
   This command has valid output only when interface is up. Otherwise, the command has empty output.

- Hiển thị số lỗi rx được chỉ định, số luồng khôi phục đã kết thúc thành công,
  đã bật tính năng tự động phục hồi và khoảng thời gian ân hạn kể từ lần khôi phục cuối cùng::

$ devlink chương trình sức khỏe pci/0000:82:00.0 phóng viên rx

phóng viên fw
-----------
Trình báo cáo fw triển khai lệnh gọi lại ZZ0000ZZ và ZZ0001ZZ.
Nó tuân theo các triệu chứng của lỗi fw như hội chứng fw bằng cách kích hoạt
kết xuất lõi fw và lưu trữ nó vào bộ đệm kết xuất.
Người dùng có thể kích hoạt lệnh chẩn đoán trình báo cáo fw bất cứ lúc nào để kiểm tra
tình trạng fw hiện tại.

Ví dụ về lệnh của người dùng:

- Kiểm tra tình trạng sức khỏe của fw::

$ devlink chẩn đoán sức khỏe pci/0000:82:00.0 phóng viên fw

- Đọc kết xuất lõi FW nếu đã được lưu trữ hoặc kích hoạt kết xuất lõi mới::

$ devlink kết xuất sức khỏe hiển thị pci/0000:82:00.0 phóng viên fw

.. note::
   This command can run only on the PF which has fw tracer ownership,
   running it on other PF or any VF will return "Operation not permitted".

chết tiệt phóng viên
-----------------
Phóng viên nguy hiểm nhất thực hiện lệnh gọi lại ZZ0000ZZ và ZZ0001ZZ.
Nó tuân theo các chỉ báo lỗi nghiêm trọng bằng cách kết xuất không gian CR và luồng phục hồi.
Kết xuất CR-space sử dụng giao diện vsc hợp lệ ngay cả khi lệnh FW
giao diện không hoạt động, đây là trường hợp xảy ra ở hầu hết các lỗi nghiêm trọng của FW.
Chức năng khôi phục chạy luồng khôi phục tải lại trình điều khiển và kích hoạt fw
đặt lại nếu cần.
Khi xảy ra lỗi phần sụn, bộ đệm tình trạng sẽ được chuyển vào dmesg. Nhật ký
mức độ được lấy từ mức độ nghiêm trọng của lỗi (được đưa ra trong bộ đệm tình trạng).

Ví dụ về lệnh của người dùng:

- Chạy luồng khôi phục fw thủ công::

$ devlink phục hồi sức khỏe pci/0000:82:00.0 phóng viên fw_fatal

- Đọc kết xuất FW CR-space nếu đã được lưu trữ hoặc kích hoạt kết xuất mới::

$ devlink kết xuất sức khỏe hiển thị pci/0000:82:00.1 phóng viên fw_fatal

.. note::
   This command can run only on PF.

phóng viên vnic
-------------
Trình báo cáo vnic chỉ thực hiện lệnh gọi lại ZZ0000ZZ.
Nó chịu trách nhiệm truy vấn các bộ đếm chẩn đoán vnic từ fw và hiển thị
chúng trong thời gian thực.

Mô tả bộ đếm vnic:

- tổng_error_queues
        số lượng hàng đợi ở trạng thái lỗi do
        lỗi không đồng bộ hoặc lệnh bị lỗi.
- send_queue_priority_update_flow
        số sự kiện cập nhật ưu tiên QP/SQ/SL.
- cq_overrun
        số lần CQ rơi vào trạng thái lỗi do tràn.
- async_eq_overrun
        số lần EQ được ánh xạ tới các sự kiện không đồng bộ bị tràn.
- comp_eq_overrun
        số lần EQ được ánh xạ tới các sự kiện hoàn thành
        tràn ngập.
- hạn ngạch_vượt quá_lệnh
        số lượng lệnh được ban hành và không thành công do vượt quá hạn ngạch.
- không hợp lệ_lệnh
        số lượng lệnh được ban hành và không thành công do bất kỳ lý do nào ngoài hạn ngạch
        vượt quá.
- nic_receive_steering_discard
        số gói đã hoàn thành luồng RX
        lái nhưng đã bị loại bỏ do bảng lưu lượng không khớp.
- generate_pkt_steering_fail
	số lượng gói do VNIC tạo ra gặp phải tình trạng điều khiển không mong muốn
	hỏng hóc (tại bất kỳ điểm nào trong luồng lái).
- xử lý_pkt_steering_fail
	số lượng gói được xử lý bởi VNIC gặp phải tình trạng điều khiển không mong muốn
	hỏng hóc (tại bất kỳ thời điểm nào trong luồng lái thuộc sở hữu của VNIC, bao gồm cả FDB
	dành cho chủ sở hữu eswitch).
- icm_consumption
        lượng Bộ nhớ máy chủ kết nối (ICM) được vnic tiêu thụ trong
        độ chi tiết của 4KB. ICM là bộ nhớ máy chủ được SW phân bổ theo yêu cầu của HCA
        và được sử dụng để lưu trữ cấu trúc dữ liệu điều khiển hoạt động HCA.
- bar_uar_access
        số hoạt động truy cập WRITE hoặc READ vào UAR trên PCIe BAR.
- odp_local_triggered_page_fault
        số lỗi trang được kích hoạt cục bộ do ODP.
- odp_remote_triggered_page_fault
        số lỗi trang được kích hoạt từ xa do ODP.

Ví dụ về lệnh của người dùng:

- Chẩn đoán bộ đếm vnic PF/VF::

$ devlink chẩn đoán sức khỏe pci/0000:82:00.1 phóng viên vnic

- Chẩn đoán bộ đếm vnic đại diện (thực hiện bằng cách cung cấp cổng devlink của
  đại diện, có thể lấy được thông qua lệnh cổng devlink)::

$ devlink chẩn đoán sức khỏe pci/0000:82:00.1/65537 phóng viên vnic

.. note::
   This command can run over all interfaces such as PF/VF and representor ports.