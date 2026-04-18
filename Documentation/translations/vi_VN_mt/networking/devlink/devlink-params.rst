.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/devlink-params.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================
Thông số Devlink
================

ZZ0000ZZ cung cấp khả năng cho trình điều khiển hiển thị các thông số thiết bị ở mức thấp
cấp độ chức năng của thiết bị. Vì devlink có thể hoạt động trên toàn thiết bị
cấp độ, nó có thể được sử dụng để cung cấp cấu hình có thể ảnh hưởng đến nhiều
cổng trên một thiết bị duy nhất.

Tài liệu này mô tả một số tham số chung được hỗ trợ
trên nhiều trình điều khiển. Mỗi tài xế cũng có thể tự do thêm tài xế của mình
các thông số. Mỗi trình điều khiển phải ghi lại các thông số cụ thể mà họ hỗ trợ,
dù chung chung hay không.

Chế độ cấu hình
===================

Các thông số có thể được đặt ở các chế độ cấu hình khác nhau.

.. list-table:: Possible configuration modes
   :widths: 5 90

   * - Name
     - Description
   * - ``runtime``
     - set while the driver is running, and takes effect immediately. No
       reset is required.
   * - ``driverinit``
     - applied while the driver initializes. Requires the user to restart
       the driver using the ``devlink`` reload command.
   * - ``permanent``
     - written to the device's non-volatile memory. A hard reset is required
       for it to take effect.

Đang tải lại
------------

Để các thông số ZZ0000ZZ có hiệu lực, trình điều khiển phải
hỗ trợ tải lại thông qua lệnh ZZ0001ZZ. Lệnh này sẽ
yêu cầu tải lại trình điều khiển thiết bị.

Giá trị tham số mặc định
=========================

Trình điều khiển có thể tùy chọn xuất giá trị mặc định cho các tham số của cmode
ZZ0000ZZ và ZZ0001ZZ. Đối với các thông số ZZ0002ZZ, thông số cuối cùng
giá trị do trình điều khiển đặt sẽ được sử dụng làm giá trị mặc định. Người lái xe có thể
cũng hỗ trợ đặt lại các thông số với cmode ZZ0003ZZ và ZZ0004ZZ
về giá trị mặc định của chúng. Hỗ trợ đặt lại thông số ZZ0005ZZ
bởi lõi devlink mà không cần hỗ trợ thêm trình điều khiển.

.. _devlink_params_generic:

Thông số cấu hình chung
================================
Sau đây là danh sách các tham số cấu hình chung mà trình điều khiển có thể
thêm vào. Việc sử dụng các tham số chung được ưu tiên hơn mỗi trình điều khiển tạo ra chúng
tên riêng.

.. list-table:: List of generic parameters
   :widths: 5 5 90

   * - Name
     - Type
     - Description
   * - ``enable_sriov``
     - Boolean
     - Enable Single Root I/O Virtualization (SRIOV) in the device.
   * - ``ignore_ari``
     - Boolean
     - Ignore Alternative Routing-ID Interpretation (ARI) capability. If
       enabled, the adapter will ignore ARI capability even when the
       platform has support enabled. The device will create the same number
       of partitions as when the platform does not support ARI.
   * - ``msix_vec_per_pf_max``
     - u32
     - Provides the maximum number of MSI-X interrupts that a device can
       create. Value is the same across all physical functions (PFs) in the
       device.
   * - ``msix_vec_per_pf_min``
     - u32
     - Provides the minimum number of MSI-X interrupts required for the
       device to initialize. Value is the same across all physical functions
       (PFs) in the device.
   * - ``fw_load_policy``
     - u8
     - Control the device's firmware loading policy.
        - ``DEVLINK_PARAM_FW_LOAD_POLICY_VALUE_DRIVER`` (0)
          Load firmware version preferred by the driver.
        - ``DEVLINK_PARAM_FW_LOAD_POLICY_VALUE_FLASH`` (1)
          Load firmware currently stored in flash.
        - ``DEVLINK_PARAM_FW_LOAD_POLICY_VALUE_DISK`` (2)
          Load firmware currently available on host's disk.
   * - ``reset_dev_on_drv_probe``
     - u8
     - Controls the device's reset policy on driver probe.
        - ``DEVLINK_PARAM_RESET_DEV_ON_DRV_PROBE_VALUE_UNKNOWN`` (0)
          Unknown or invalid value.
        - ``DEVLINK_PARAM_RESET_DEV_ON_DRV_PROBE_VALUE_ALWAYS`` (1)
          Always reset device on driver probe.
        - ``DEVLINK_PARAM_RESET_DEV_ON_DRV_PROBE_VALUE_NEVER`` (2)
          Never reset device on driver probe.
        - ``DEVLINK_PARAM_RESET_DEV_ON_DRV_PROBE_VALUE_DISK`` (3)
          Reset the device only if firmware can be found in the filesystem.
   * - ``enable_roce``
     - Boolean
     - Enable handling of RoCE traffic in the device.
   * - ``enable_eth``
     - Boolean
     - When enabled, the device driver will instantiate Ethernet specific
       auxiliary device of the devlink device.
   * - ``enable_rdma``
     - Boolean
     - When enabled, the device driver will instantiate RDMA specific
       auxiliary device of the devlink device.
   * - ``enable_vnet``
     - Boolean
     - When enabled, the device driver will instantiate VDPA networking
       specific auxiliary device of the devlink device.
   * - ``enable_iwarp``
     - Boolean
     - Enable handling of iWARP traffic in the device.
   * - ``internal_err_reset``
     - Boolean
     - When enabled, the device driver will reset the device on internal
       errors.
   * - ``max_macs``
     - u32
     - Typically macvlan, vlan net devices mac are also programmed in their
       parent netdevice's Function rx filter. This parameter limit the
       maximum number of unicast mac address filters to receive traffic from
       per ethernet port of this device.
   * - ``region_snapshot_enable``
     - Boolean
     - Enable capture of ``devlink-region`` snapshots.
   * - ``enable_remote_dev_reset``
     - Boolean
     - Enable device reset by remote host. When cleared, the device driver
       will NACK any attempt of other host to reset the device. This parameter
       is useful for setups where a device is shared by different hosts, such
       as multi-host setup.
   * - ``io_eq_size``
     - u32
     - Control the size of I/O completion EQs.
   * - ``event_eq_size``
     - u32
     - Control the size of asynchronous control events EQ.
   * - ``enable_phc``
     - Boolean
     - Enable PHC (PTP Hardware Clock) functionality in the device.
   * - ``clock_id``
     - u64
     - Clock ID used by the device for registering DPLL devices and pins.
   * - ``total_vfs``
     - u32
     - The max number of Virtual Functions (VFs) exposed by the PF.
       after reboot/pci reset, 'sriov_totalvfs' entry under the device's sysfs
       directory will report this value.
   * - ``num_doorbells``
     - u32
     - Controls the number of doorbells used by the device.
   * - ``max_mac_per_vf``
     - u32
     - Controls the maximum number of MAC address filters that can be assigned
       to a Virtual Function (VF).