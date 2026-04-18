.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/octeontx2.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
hỗ trợ liên kết phát triển octeontx2
=========================

Tài liệu này mô tả các tính năng của devlink được ZZ0000ZZ triển khai
trình điều khiển thiết bị.

Thông số
==========

Trình điều khiển ZZ0000ZZ triển khai các tham số dành riêng cho trình điều khiển sau.

.. list-table:: Driver-specific parameters implemented
   :widths: 5 5 5 85

   * - Name
     - Type
     - Mode
     - Description
   * - ``mcam_count``
     - u16
     - runtime
     - Select number of match CAM entries to be allocated for an interface.
       The same is used for ntuple filters of the interface. Supported by
       PF and VF drivers.

Trình điều khiển ZZ0000ZZ triển khai các tham số dành riêng cho trình điều khiển sau.

.. list-table:: Driver-specific parameters implemented
   :widths: 5 5 5 85

   * - Name
     - Type
     - Mode
     - Description
   * - ``dwrr_mtu``
     - u32
     - runtime
     - Use to set the quantum which hardware uses for scheduling among transmit queues.
       Hardware uses weighted DWRR algorithm to schedule among all transmit queues.
   * - ``npc_mcam_high_zone_percent``
     - u8
     - runtime
     - Use to set the number of high priority zone entries in NPC MCAM that can be allocated
       by a user, out of the three priority zone categories high, mid and low.
   * - ``npc_def_rule_cntr``
     - bool
     - runtime
     - Use to enable or disable hit counters for the default rules in NPC MCAM.
       Its not guaranteed that counters gets enabled and mapped to all the default rules,
       since the counters are scarce and driver follows a best effort approach.
       The default rule serves as the primary packet steering rule for a specific PF or VF,
       based on its DMAC address which is installed by AF driver as part of its initialization.
       Sample command to read hit counters for default rule from debugfs is as follows,
       cat /sys/kernel/debug/cn10k/npc/mcam_rules
   * - ``nix_maxlf``
     - u16
     - runtime
     - Use to set the maximum number of LFs in NIX hardware block. This would be useful
       to increase the availability of default resources allocated to enabled LFs like
       MCAM entries for example.

Trình điều khiển ZZ0000ZZ triển khai các tham số dành riêng cho trình điều khiển sau.

.. list-table:: Driver-specific parameters implemented
   :widths: 5 5 5 85

   * - Name
     - Type
     - Mode
     - Description
   * - ``unicast_filter_count``
     - u8
     - runtime
     - Set the maximum number of unicast filters that can be programmed for
       the device. This can be used to achieve better device resource
       utilization, avoiding over consumption of unused MCAM table entries.