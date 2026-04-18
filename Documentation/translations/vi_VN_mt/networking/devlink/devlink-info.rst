.. SPDX-License-Identifier: (GPL-2.0-only OR BSD-2-Clause)

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/devlink-info.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============
Thông tin liên kết nhà phát triển
============

Cơ chế ZZ0000ZZ cho phép trình điều khiển thiết bị báo cáo thiết bị
(phần cứng và phần sụn) theo cách tiêu chuẩn, có thể mở rộng.

Động lực ban đầu của ZZ0000ZZ API có hai mục đích:

- làm cho nó có thể tự động hóa việc quản lý thiết bị và chương trình cơ sở trong một nhóm
   của máy theo kiểu độc lập với nhà cung cấp (xem thêm
   ZZ0000ZZ);
 - đặt tên cho các phiên bản FW cho mỗi thành phần (ngược lại với ethtool đông đúc
   chuỗi phiên bản).

ZZ0000ZZ hỗ trợ báo cáo nhiều loại đối tượng. Trình điều khiển báo cáo
các phiên bản thường không được khuyến khích - tại đây và thông qua bất kỳ Linux API nào khác.

.. list-table:: List of top level info objects
   :widths: 5 95

   * - Name
     - Description
   * - ``driver``
     - Name of the currently used device driver, also available through sysfs.

   * - ``serial_number``
     - Serial number of the device.

       This is usually the serial number of the ASIC, also often available
       in PCI config space of the device in the *Device Serial Number*
       capability.

       The serial number should be unique per physical device.
       Sometimes the serial number of the device is only 48 bits long (the
       length of the Ethernet MAC address), and since PCI DSN is 64 bits long
       devices pad or encode additional information into the serial number.
       One example is adding port ID or PCI interface ID in the extra two bytes.
       Drivers should make sure to strip or normalize any such padding
       or interface ID, and report only the part of the serial number
       which uniquely identifies the hardware. In other words serial number
       reported for two ports of the same device or on two hosts of
       a multi-host device should be identical.

   * - ``board.serial_number``
     - Board serial number of the device.

       This is usually the serial number of the board, often available in
       PCI *Vital Product Data*.

   * - ``fixed``
     - Group for hardware identifiers, and versions of components
       which are not field-updatable.

       Versions in this section identify the device design. For example,
       component identifiers or the board version reported in the PCI VPD.
       Data in ``devlink-info`` should be broken into the smallest logical
       components, e.g. PCI VPD may concatenate various information
       to form the Part Number string, while in ``devlink-info`` all parts
       should be reported as separate items.

       This group must not contain any frequently changing identifiers,
       such as serial numbers. See
       :ref:`Documentation/networking/devlink/devlink-flash.rst <devlink_flash>`
       to understand why.

   * - ``running``
     - Group for information about currently running software/firmware.
       These versions often only update after a reboot, sometimes device reset.

   * - ``stored``
     - Group for software/firmware versions in device flash.

       Stored values must update to reflect changes in the flash even
       if reboot has not yet occurred. If device is not capable of updating
       ``stored`` versions when new software is flashed, it must not report
       them.

Mỗi phiên bản có thể được báo cáo nhiều nhất một lần trong mỗi nhóm phiên bản. Phần sụn
các thành phần được lưu trữ trên flash phải có trong cả ZZ0001ZZ và
Các phần ZZ0002ZZ, nếu thiết bị có khả năng báo cáo các phiên bản ZZ0003ZZ
(xem ZZ0000ZZ).
Trong trường hợp các thành phần phần mềm/chương trình cơ sở được tải từ đĩa (ví dụ:
ZZ0004ZZ) chỉ có phiên bản đang chạy mới được báo cáo qua
hạt nhân API.

Xin lưu ý rằng mọi phiên bản bảo mật được báo cáo qua liên kết nhà phát triển hoàn toàn là
thông tin. Devlink không sử dụng kênh an toàn để liên lạc với
thiết bị.

Phiên bản chung
================

Dự kiến các trình điều khiển sẽ sử dụng các tên chung sau để xuất
thông tin phiên bản. Nếu tên chung cho một thành phần nhất định chưa tồn tại,
tác giả trình điều khiển nên tham khảo các phiên bản dành riêng cho trình điều khiển hiện có và thử
tái sử dụng. Phương sách cuối cùng, nếu một thành phần thực sự là duy nhất, sử dụng trình điều khiển cụ thể
được phép đặt tên, nhưng những tên này phải được ghi lại trong tệp dành riêng cho trình điều khiển.

Tất cả các phiên bản nên cố gắng sử dụng thuật ngữ sau:

.. list-table:: List of common version suffixes
   :widths: 10 90

   * - Name
     - Description
   * - ``id``, ``revision``
     - Identifiers of designs and revision, mostly used for hardware versions.

   * - ``api``
     - Version of API between components. API items are usually of limited
       value to the user, and can be inferred from other versions by the vendor,
       so adding API versions is generally discouraged as noise.

   * - ``bundle_id``
     - Identifier of a distribution package which was flashed onto the device.
       This is an attribute of a firmware package which covers multiple versions
       for ease of managing firmware images (see
       :ref:`Documentation/networking/devlink/devlink-flash.rst <devlink_flash>`).

       ``bundle_id`` can appear in both ``running`` and ``stored`` versions,
       but it must not be reported if any of the components covered by the
       ``bundle_id`` was changed and no longer matches the version from
       the bundle.

bảng.id
--------

Mã định danh duy nhất của thiết kế bảng.

board.rev
---------

Sửa đổi thiết kế bảng.

asic.id
-------

Mã định danh thiết kế ASIC.

asic.rev
--------

Sửa đổi/bước thiết kế ASIC.

board.sản xuất
-----------------

Mã nhận dạng của công ty hoặc cơ sở sản xuất bộ phận đó.

board.part_number
-----------------

Số bộ phận của bo mạch và các thành phần của nó.

ôi
--

Phiên bản phần sụn tổng thể, thường đại diện cho bộ sưu tập
fw.mgmt, fw.app, v.v.

fw.mgmt
-------

Phiên bản chương trình cơ sở của bộ điều khiển. Phần sụn này chịu trách nhiệm quản lý
giữ các nhiệm vụ, điều khiển PHY, v.v. nhưng không giữ đường dẫn dữ liệu theo từng gói
hoạt động.

fw.mgmt.api
-----------

Phiên bản đặc tả giao diện phần mềm của giao diện phần mềm giữa
trình điều khiển và phần sụn.

fw.app
------

Vi mã đường dẫn dữ liệu kiểm soát xử lý gói tốc độ cao.

fw.undi
-------

Phần mềm UNDI, có thể bao gồm trình điều khiển, chương trình cơ sở UEFI hoặc cả hai.

fw.ncsi
-------

Phiên bản của phần mềm chịu trách nhiệm hỗ trợ/xử lý
Giao diện dải biên của bộ điều khiển mạng.

fw.psid
-------

Mã định danh duy nhất của bộ tham số phần sụn. Đây thường là
các thông số của một bảng cụ thể, được xác định tại thời điểm sản xuất.

fw.roce
-------

Phiên bản phần mềm RoCE chịu trách nhiệm xử lý roce
quản lý.

fw.bundle_id
------------

Mã định danh duy nhất của toàn bộ gói phần sụn.

fw.bootloader
-------------

Phiên bản của bộ nạp khởi động.

Công việc tương lai
===========

Các phần mở rộng sau có thể hữu ích:

- tên tệp chương trình cơ sở trên đĩa - trình điều khiển liệt kê tên tệp của chương trình cơ sở mà chúng
   có thể cần tải lên thiết bị thông qua macro ZZ0000ZZ. Những cái này
   tuy nhiên, là trên mỗi mô-đun chứ không phải trên mỗi thiết bị. Sẽ rất hữu ích nếu liệt kê
   tên của các tập tin chương trình cơ sở mà trình điều khiển sẽ cố tải cho một thiết bị nhất định,
   theo thứ tự ưu tiên.