.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/ixgbe.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
hỗ trợ liên kết phát triển ixgbe
================================

Tài liệu này mô tả các tính năng của devlink được ZZ0000ZZ triển khai
trình điều khiển thiết bị.

Phiên bản thông tin
===================

Bất kỳ phiên bản nào liên quan đến bảo mật do ZZ0000ZZ trình bày
thuần túy là thông tin. Devlink không sử dụng kênh an toàn để liên lạc
với thiết bị.

Trình điều khiển ZZ0000ZZ báo cáo các phiên bản sau

.. list-table:: devlink info versions implemented
    :widths: 5 5 5 90

    * - Name
      - Type
      - Example
      - Description
    * - ``board.id``
      - fixed
      - H49289-000
      - The Product Board Assembly (PBA) identifier of the board.
    * - ``fw.undi``
      - running
      - 1.1937.0
      - Version of the Option ROM containing the UEFI driver. The version is
        reported in ``major.minor.patch`` format. The major version is
        incremented whenever a major breaking change occurs, or when the
        minor version would overflow. The minor version is incremented for
        non-breaking changes and reset to 1 when the major version is
        incremented. The patch version is normally 0 but is incremented when
        a fix is delivered as a patch against an older base Option ROM.
    * - ``fw.undi.srev``
      - running
      - 4
      - Number indicating the security revision of the Option ROM.
    * - ``fw.bundle_id``
      - running
      - 0x80000d0d
      - Unique identifier of the firmware image file that was loaded onto
        the device. Also referred to as the EETRACK identifier of the NVM.
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
    * - ``fw.mgmt.srev``
      - running
      - 3
      - Number indicating the security revision of the firmware.
    * - ``fw.psid.api``
      - running
      - 0.80
      - Version defining the format of the flash contents.
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
       identifying fields such as the MAC address, Vital product Data (VPD) area,
       and device serial number. It is expected that this combination be used with an
       image customized for the specific device.

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
    0000000000000000 0014 95dc 0014 9514 0035 1670 0034 db30
    0000000000000010 0000 0000 ffff ff04 0029 8c00 0028 8cc8
    0000000000000020 0016 0bb8 0016 1720 0000 0000 c00f 3ffc
    0000000000000030 bada cce5 bada cce5 bada cce5 bada cce5

    $ devlink region read pci/0000:01:00.0/nvm-flash snapshot 1 address 0 length 16
    0000000000000000 0014 95dc 0014 9514 0035 1670 0034 db30

    $ devlink region delete pci/0000:01:00.0/device-caps snapshot 1