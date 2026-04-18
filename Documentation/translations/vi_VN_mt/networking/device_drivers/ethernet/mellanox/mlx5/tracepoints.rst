.. SPDX-License-Identifier: GPL-2.0 OR Linux-OpenIB

.. include:: ../../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/mellanox/mlx5/tracepoints.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

============
Dấu vết
============

:Bản quyền: ZZ0000ZZ 2023, NVIDIA CORPORATION & AFFILIATES. Mọi quyền được bảo lưu.

Trình điều khiển mlx5 cung cấp các điểm theo dõi nội bộ để theo dõi và gỡ lỗi bằng cách sử dụng
giao diện tracepoint hạt nhân (tham khảo Tài liệu/trace/ftrace.rst).

Để biết danh sách các sự kiện hỗ trợ mlx5, hãy kiểm tra /sys/kernel/tracing/events/mlx5/.

tc và eswitch giảm tải các điểm theo dõi:

- mlx5e_configure_flower: theo dõi các hành động và cookie của bộ lọc hoa được tải xuống mlx5::

$ echo mlx5:mlx5e_configure_flower >> /sys/kernel/tracing/set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
tc-6535 [019] ...1 2672.404466: mlx5e_configure_flower: cookie=0000000067874a55 hành động= REDIRECT

- mlx5e_delete_flower: theo dõi các hành động và cookie của bộ lọc hoa đã bị xóa khỏi mlx5::

$ echo mlx5:mlx5e_delete_flower >> /sys/kernel/tracing/set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
tc-6569 [010] .N.1 2686.379075: mlx5e_delete_flower: cookie=0000000067874a55 hành động= NULL

- mlx5e_stats_flower: theo dõi yêu cầu thống kê hoa::

$ echo mlx5:mlx5e_stats_flower >> /sys/kernel/tracing/set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
tc-6546 [010] ...1 2679.704889: mlx5e_stats_flower: cookie=0000000060eb3d6a bytes=0 gói=0 lần cuối=4295560217

- mlx5e_tc_update_neigh_used_value: quy tắc đường hầm theo dõi giá trị cập nhật gần được tải xuống mlx5::

$ echo mlx5:mlx5e_tc_update_neigh_used_value >> /sys/kernel/tracing/set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
kworker/u48:4-8806 [009] ...1 55117.882428: mlx5e_tc_update_neigh_used_value: netdev: ens1f0 IPv4: 1.1.1.10 IPv6: ::ffff:1.1.1.10 neigh_used=1

- mlx5e_rep_neigh_update: theo dõi các tác vụ cập nhật lân cận được lên lịch do các sự kiện thay đổi trạng thái lân cận::

$ echo mlx5:mlx5e_rep_neigh_update >> /sys/kernel/tracing/set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
kworker/u48:7-2221 [009] ...1 1475.387435: mlx5e_rep_neigh_update: netdev: ens1f0 MAC: 24:8a:07:9a:17:9a IPv4: 1.1.1.10 IPv6: ::ffff:1.1.1.10 neigh_connected=1

Cầu giảm tải tracepoint:

- mlx5_esw_bridge_fdb_entry_init: theo dõi cầu nối FDB được giảm tải xuống mlx5::

$ echo mlx5:mlx5_esw_bridge_fdb_entry_init >> set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
kworker/u20:9-2217 [003] ...1 318.582243: mlx5_esw_bridge_fdb_entry_init: net_device=enp8s0f0_0 addr=e4:fd:05:08:00:02 vid=0 flags=0 used=0

- mlx5_esw_bridge_fdb_entry_cleanup: cầu theo dõi mục nhập FDB đã bị xóa khỏi mlx5::

$ echo mlx5:mlx5_esw_bridge_fdb_entry_cleanup >> set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
ip-2581 [005] ...1 318.629871: mlx5_esw_bridge_fdb_entry_cleanup: net_device=enp8s0f0_1 addr=e4:fd:05:08:00:03 vid=0 flags=0 used=16

- mlx5_esw_bridge_fdb_entry_refresh: giảm tải mục nhập FDB được làm mới trong
  mlx5::

$ echo mlx5:mlx5_esw_bridge_fdb_entry_refresh >> set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
kworker/u20:8-3849 [003] ...1 466716: mlx5_esw_bridge_fdb_entry_refresh: net_device=enp8s0f0_0 addr=e4:fd:05:08:00:02 vid=3 flags=0 used=0

- mlx5_esw_bridge_vlan_create: cầu theo dõi đối tượng VLAN thêm vào mlx5
  đại diện::

$ echo mlx5:mlx5_esw_bridge_vlan_create >> set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
ip-2560 [007] ...1 318.460258: mlx5_esw_bridge_vlan_create: vid=1 flags=6

- mlx5_esw_bridge_vlan_cleanup: theo dõi cầu nối đối tượng VLAN xóa khỏi mlx5
  đại diện::

$ echo mlx5:mlx5_esw_bridge_vlan_cleanup >> set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
bridge-2582 [007] ...1 318.653496: mlx5_esw_bridge_vlan_cleanup: vid=2 flags=8

- mlx5_esw_bridge_vport_init: theo dõi vport mlx5 được gán với cầu nối phía trên
  thiết bị::

$ echo mlx5:mlx5_esw_bridge_vport_init >> set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
ip-2560 [007] ...1 318.458915: mlx5_esw_bridge_vport_init: vport_num=1

- mlx5_esw_bridge_vport_cleanup: xóa dấu vết mlx5 vport khỏi cầu phía trên
  thiết bị::

$ echo mlx5:mlx5_esw_bridge_vport_cleanup >> set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
ip-5387 [000] ...1 573713: mlx5_esw_bridge_vport_cleanup: vport_num=1

Điểm theo dõi QoS của Eswitch:

- mlx5_esw_vport_qos_create: tạo dấu vết của trọng tài lập lịch truyền cho vport::

$ echo mlx5:mlx5_esw_vport_qos_create >> /sys/kernel/tracing/set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
<...>-23496 [018] .... 73136.838831: mlx5_esw_vport_qos_create: (0000:82:00.0) vport=2 tsar_ix=4 bw_share=0, max_rate=0 nhóm=000000007b576bb3

- mlx5_esw_vport_qos_config: theo dõi cấu hình của trọng tài lập lịch truyền cho vport::

$ echo mlx5:mlx5_esw_vport_qos_config >> /sys/kernel/tracing/set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
<...>-26548 [023] .... 75754.223823: mlx5_esw_vport_qos_config: (0000:82:00.0) vport=1 tsar_ix=3 bw_share=34, max_rate=10000 nhóm=000000007b576bb3

- mlx5_esw_vport_qos_destroy: xóa dấu vết của trọng tài lập lịch truyền cho vport::

$ echo mlx5:mlx5_esw_vport_qos_destroy >>/sys/kernel/tracing/set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
<...>-27418 [004] .... 76546.680901: mlx5_esw_vport_qos_destroy: (0000:82:00.0) vport=1 tsar_ix=3

- mlx5_esw_group_qos_create: tạo dấu vết của trọng tài lập lịch truyền cho nhóm tốc độ::

$ echo mlx5:mlx5_esw_group_qos_create >> /sys/kernel/tracing/set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
<...>-26578 [008] .... 75776.022112: mlx5_esw_group_qos_create: (0000:82:00.0) group=000000008dac63ea tsar_ix=5

- mlx5_esw_group_qos_config: theo dõi cấu hình của bộ lập lịch truyền trọng tài cho nhóm tốc độ::

$ echo mlx5:mlx5_esw_group_qos_config >> /sys/kernel/tracing/set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
<...>-27303 [020] .... 76461.455356: mlx5_esw_group_qos_config: (0000:82:00.0) group=000000008dac63ea tsar_ix=5 bw_share=100 max_rate=20000

- mlx5_esw_group_qos_destroy: xóa dấu vết của trọng tài lập lịch truyền cho nhóm::

$ echo mlx5:mlx5_esw_group_qos_destroy >>/sys/kernel/tracing/set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
<...>-27418 [006] .... 76547.187258: mlx5_esw_group_qos_destroy: (0000:82:00.0) group=000000007b576bb3 tsar_ix=1

Điểm theo dõi SF:

- mlx5_sf_add: bổ sung dấu vết của cổng SF::

$ echo mlx5:mlx5_sf_add >> /sys/kernel/tracing/set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
devlink-9363 [031]..... 24610.188722: mlx5_sf_add: (0000:06:00.0) port_index=32768 control=0 hw_id=0x8000 sfnum=88

- mlx5_sf_free: giải phóng dấu vết của cổng SF::

$ echo mlx5:mlx5_sf_free >> /sys/kernel/tracing/set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
devlink-9830 [038]..... 26300.404749: mlx5_sf_free: (0000:06:00.0) port_index=32768 bộ điều khiển=0 hw_id=0x8000

- mlx5_sf_activate: theo dõi hoạt động của cổng SF::

$ echo mlx5:mlx5_sf_activate >> /sys/kernel/tracing/set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
devlink-29841 [008]..... 3669.635095: mlx5_sf_activate: (0000:08:00.0) port_index=32768 bộ điều khiển=0 hw_id=0x8000

- mlx5_sf_deactivate: theo dõi việc vô hiệu hóa cổng SF::

$ echo mlx5:mlx5_sf_deactivate >> /sys/kernel/tracing/set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
devlink-29994 [008]..... 4015.969467: mlx5_sf_deactivate: (0000:08:00.0) port_index=32768 bộ điều khiển=0 hw_id=0x8000

- mlx5_sf_hwc_alloc: phân bổ theo dõi bối cảnh SF phần cứng::

$ echo mlx5:mlx5_sf_hwc_alloc >> /sys/kernel/tracing/set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
devlink-9775 [031]..... 26296.385259: mlx5_sf_hwc_alloc: (0000:06:00.0) control=0 hw_id=0x8000 sfnum=88

- mlx5_sf_hwc_free: giải phóng dấu vết của bối cảnh SF phần cứng::

$ echo mlx5:mlx5_sf_hwc_free >> /sys/kernel/tracing/set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
kworker/u128:3-9093 [046]..... 24625.365771: mlx5_sf_hwc_free: (0000:06:00.0) hw_id=0x8000

- mlx5_sf_hwc_deferred_free: giải phóng dấu vết bị trì hoãn khỏi bối cảnh SF phần cứng::

$ echo mlx5:mlx5_sf_hwc_deferred_free >> /sys/kernel/tracing/set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
devlink-9519 [046]..... 24624.400271: mlx5_sf_hwc_deferred_free: (0000:06:00.0) hw_id=0x8000

- mlx5_sf_update_state: theo dõi cập nhật trạng thái cho bối cảnh SF::

$ echo mlx5:mlx5_sf_update_state >> /sys/kernel/tracing/set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
kworker/u20:3-29490 [009]..... 4141.453530: mlx5_sf_update_state: (0000:08:00.0) port_index=32768 bộ điều khiển=0 hw_id=0x8000 state=2

- mlx5_sf_vhca_event: theo dõi sự kiện và trạng thái SF vhca::

$ echo mlx5:mlx5_sf_vhca_event >> /sys/kernel/tracing/set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
kworker/u128:3-9093 [046]..... 24625.365525: mlx5_sf_vhca_event: (0000:06:00.0) hw_id=0x8000 sfnum=88 vhca_state=1

- mlx5_sf_dev_add: theo dõi sự kiện thêm thiết bị SF::

$ echo mlx5:mlx5_sf_dev_add>> /sys/kernel/tracing/set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
kworker/u128:3-9093 [000]..... 24616.524495: mlx5_sf_dev_add: (0000:06:00.0) sfdev=00000000fc5d96fd aux_id=4 hw_id=0x8000 sfnum=88

- mlx5_sf_dev_del: theo dõi sự kiện xóa thiết bị SF::

$ echo mlx5:mlx5_sf_dev_del >> /sys/kernel/tracing/set_event
    $ cat /sys/kernel/truy tìm/dấu vết
    ...
kworker/u128:3-9093 [044]..... 24624.400749: mlx5_sf_dev_del: (0000:06:00.0) sfdev=00000000fc5d96fd aux_id=4 hw_id=0x8000 sfnum=88