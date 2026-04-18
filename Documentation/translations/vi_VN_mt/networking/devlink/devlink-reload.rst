.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/devlink-reload.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================
Tải lại liên kết nhà phát triển
==============

ZZ0000ZZ cung cấp cơ chế khởi tạo lại các thực thể trình điều khiển, áp dụng
Giá trị mới của ZZ0001ZZ và ZZ0002ZZ. Nó cũng cung cấp
cơ chế kích hoạt firmware.

Hành động tải lại
==============

Người dùng có thể chọn hành động tải lại.
Theo mặc định, hành động ZZ0000ZZ được chọn.

.. list-table:: Possible reload actions
   :widths: 5 90

   * - Name
     - Description
   * - ``driver-reinit``
     - Devlink driver entities re-initialization, including applying
       new values to devlink entities which are used during driver
       load which are:

       * ``devlink-params`` in configuration mode ``driverinit``
       * ``devlink-resources``

       Other devlink entities may stay over the re-initialization:

       * ``devlink-health-reporter``
       * ``devlink-region``

       The rest of the devlink entities have to be removed and readded.
   * - ``fw_activate``
     - Firmware activate. Activates new firmware if such image is stored and
       pending activation. If no limitation specified this action may involve
       firmware reset. If no new image pending this action will reload current
       firmware image.

Lưu ý rằng mặc dù người dùng yêu cầu một hành động cụ thể, trình điều khiển
việc triển khai có thể yêu cầu thực hiện một hành động khác cùng với
nó. Ví dụ: một số trình điều khiển không hỗ trợ khởi tạo lại trình điều khiển
được thực hiện mà không cần kích hoạt fw. Do đó, tải lại devlink
lệnh trả về danh sách các hành động đã được thực hiện thực sự.

Giới hạn tải lại
=============

Theo mặc định, các hành động tải lại không bị giới hạn và việc triển khai trình điều khiển có thể
bao gồm thời gian đặt lại hoặc thời gian ngừng hoạt động nếu cần để thực hiện các hành động.

Tuy nhiên, một số trình điều khiển hỗ trợ giới hạn hành động, giới hạn hành động
thực hiện các ràng buộc cụ thể.

.. list-table:: Possible reload limits
   :widths: 5 90

   * - Name
     - Description
   * - ``no_reset``
     - No reset allowed, no down time allowed, no link flap and no
       configuration is lost.

Thay đổi không gian tên
================

Tùy chọn netns cho phép người dùng có thể di chuyển các phiên bản devlink vào
không gian tên trong quá trình tải lại liên kết phát triển.
Theo mặc định, tất cả các phiên bản liên kết phát triển được tạo trong init_net và ở đó.

cách sử dụng ví dụ
-------------

.. code:: shell

    $ devlink dev reload help
    $ devlink dev reload DEV [ netns { PID | NAME | ID } ] [ action { driver_reinit | fw_activate } ] [ limit no_reset ]

    # Run reload command for devlink driver entities re-initialization:
    $ devlink dev reload pci/0000:82:00.0 action driver_reinit
    reload_actions_performed:
      driver_reinit

    # Run reload command to activate firmware:
    # Note that mlx5 driver reloads the driver while activating firmware
    $ devlink dev reload pci/0000:82:00.0 action fw_activate
    reload_actions_performed:
      driver_reinit fw_activate