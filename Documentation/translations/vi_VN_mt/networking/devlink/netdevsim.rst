.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/netdevsim.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
hỗ trợ liên kết phát triển netdevsim
====================================

Tài liệu này mô tả các tính năng ZZ0000ZZ được hỗ trợ bởi
Trình điều khiển thiết bị ZZ0001ZZ.

Thông số
==========

.. list-table:: Generic parameters implemented

   * - Name
     - Mode
   * - ``max_macs``
     - driverinit

Trình điều khiển ZZ0000ZZ cũng triển khai các trình điều khiển cụ thể sau:
các thông số.

.. list-table:: Driver-specific parameters implemented
   :widths: 5 5 5 85

   * - Name
     - Type
     - Mode
     - Description
   * - ``test1``
     - Boolean
     - driverinit
     - Test parameter used to show how a driver-specific devlink parameter
       can be implemented.

Trình điều khiển ZZ0000ZZ hỗ trợ tải lại qua ZZ0001ZZ

Khu vực
=======

Trình điều khiển ZZ0000ZZ hiển thị vùng ZZ0001ZZ làm ví dụ về cách
giao diện khu vực devlink hoạt động. Một ảnh chụp nhanh được chụp bất cứ khi nào
Tệp gỡ lỗi ZZ0002ZZ được ghi vào.

Tài nguyên
==========

Trình điều khiển ZZ0000ZZ hiển thị tài nguyên để kiểm soát số lượng FIB
các mục nhập, mục nhập quy tắc FIB và các bước nhảy tiếp theo mà trình điều khiển sẽ cho phép.

.. code:: shell

    $ devlink resource set netdevsim/netdevsim0 path /IPv4/fib size 96
    $ devlink resource set netdevsim/netdevsim0 path /IPv4/fib-rules size 16
    $ devlink resource set netdevsim/netdevsim0 path /IPv6/fib size 64
    $ devlink resource set netdevsim/netdevsim0 path /IPv6/fib-rules size 16
    $ devlink resource set netdevsim/netdevsim0 path /nexthops size 16
    $ devlink dev reload netdevsim/netdevsim0

Đánh giá đối tượng
==================

Trình điều khiển ZZ0000ZZ hỗ trợ quản lý đối tượng tỷ lệ, bao gồm:

- đăng ký/hủy đăng ký các đối tượng tỷ lệ lá trên mỗi cổng liên kết phát triển VF;
- đối tượng tỷ lệ nút tạo/xóa;
- thiết lập các giá trị tỷ lệ tx_share và tx_max cho bất kỳ loại đối tượng tỷ lệ nào;
- thiết lập nút cha cho bất kỳ loại đối tượng tỷ lệ nào.

Các nút tốc độ và các tham số của chúng được hiển thị trong bản gỡ lỗi ZZ0000ZZ ở chế độ RO.
Ví dụ: nút tốc độ đã tạo có tên ZZ0001ZZ:

.. code:: shell

    $ ls /sys/kernel/debug/netdevsim/netdevsim0/rate_groups/some_group
    rate_parent  tx_max  tx_share

Các tham số tương tự được hiển thị cho các đối tượng lá trong các thư mục cổng tương ứng.
Ví dụ:

.. code:: shell

    $ ls /sys/kernel/debug/netdevsim/netdevsim0/ports/1
    dev  ethtool  rate_parent  tx_max  tx_share

Bẫy dành riêng cho người lái xe
===============================

.. list-table:: List of Driver-specific Traps Registered by ``netdevsim``
   :widths: 5 5 90

   * - Name
     - Type
     - Description
   * - ``fid_miss``
     - ``exception``
     - When a packet enters the device it is classified to a filtering
       identifier (FID) based on the ingress port and VLAN. This trap is used
       to trap packets for which a FID could not be found