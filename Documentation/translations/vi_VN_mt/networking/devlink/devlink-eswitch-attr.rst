.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/devlink-eswitch-attr.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
Thuộc tính E-Switch của Devlink
===============================

Devlink E-Switch hỗ trợ hai chế độ hoạt động: Legacy và Switchdev.
Chế độ kế thừa hoạt động dựa trên quy tắc lái MAC/VLAN truyền thống. Chuyển đổi
các quyết định được đưa ra dựa trên địa chỉ MAC, Vlan, v.v. Khả năng bị hạn chế
để giảm tải các quy tắc chuyển đổi sang phần cứng.

Mặt khác, chế độ switchdev cho phép giảm tải nâng cao hơn
khả năng của E-Switch sang phần cứng. Ở chế độ switchdev, chuyển đổi nhiều hơn
các quy tắc và logic có thể được tải xuống bộ chuyển mạch phần cứng ASIC. Nó cho phép
các thiết bị mạng đại diện đại diện cho đường đi chậm của các hàm ảo (VF)
hoặc các chức năng có thể mở rộng (SF) của thiết bị. Xem thêm thông tin về
ZZ0000ZZ và
ZZ0001ZZ.

Ngoài ra, E-Switch của devlink còn đi kèm với các thuộc tính khác được liệt kê
trong phần sau.

Thuộc tính Mô tả
======================

Sau đây là danh sách các thuộc tính của E-Switch.

.. list-table:: E-Switch attributes
   :widths: 8 5 45

   * - Name
     - Type
     - Description
   * - ``mode``
     - enum
     - The mode of the device. The mode can be one of the following:

       * ``legacy`` operates based on traditional MAC/VLAN steering
         rules.
       * ``switchdev`` allows for more advanced offloading capabilities of
         the E-Switch to hardware.
       * ``switchdev_inactive`` switchdev mode but starts inactive, doesn't allow traffic
         until explicitly activated. This mode is useful for orchestrators that
         want to prepare the device in switchdev mode but only activate it when
         all configurations are done.
   * - ``inline-mode``
     - enum
     - Some HWs need the VF driver to put part of the packet
       headers on the TX descriptor so the e-switch can do proper
       matching and steering. Support for both switchdev mode and legacy mode.

       * ``none`` none.
       * ``link`` L2 mode.
       * ``network`` L3 mode.
       * ``transport`` L4 mode.
   * - ``encap-mode``
     - enum
     - The encapsulation mode of the device. Support for both switchdev mode
       and legacy mode. The mode can be one of the following:

       * ``none`` Disable encapsulation support.
       * ``basic`` Enable encapsulation support.

Cách sử dụng ví dụ
=============

.. code:: shell

    # enable switchdev mode
    $ devlink dev eswitch set pci/0000:08:00.0 mode switchdev

    # set inline-mode and encap-mode
    $ devlink dev eswitch set pci/0000:08:00.0 inline-mode none encap-mode basic

    # display devlink device eswitch attributes
    $ devlink dev eswitch show pci/0000:08:00.0
      pci/0000:08:00.0: mode switchdev inline-mode none encap-mode basic

    # enable encap-mode with legacy mode
    $ devlink dev eswitch set pci/0000:08:00.0 mode legacy inline-mode none encap-mode basic

    # start switchdev mode in inactive state
    $ devlink dev eswitch set pci/0000:08:00.0 mode switchdev_inactive

    # setup switchdev configurations, representors, FDB entries, etc..
    ...

    # activate switchdev mode to allow traffic
    $ devlink dev eswitch set pci/0000:08:00.0 mode switchdev