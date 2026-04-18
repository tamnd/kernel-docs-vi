.. SPDX-License-Identifier: (GPL-2.0-only OR BSD-2-Clause)

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/devlink-selftests.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Tự kiểm tra Devlink
=================

ZZ0000ZZ API cho phép thực hiện tự kiểm tra trên thiết bị.

Mặt nạ kiểm tra
==========
Lệnh ZZ0000ZZ phải được chạy với mặt nạ biểu thị
các thử nghiệm cần thực hiện.

Kiểm tra Mô tả
=================
Sau đây là danh sách các bài kiểm tra mà trình điều khiển có thể thực hiện.

.. list-table:: List of tests
   :widths: 5 90

   * - Name
     - Description
   * - ``DEVLINK_SELFTEST_FLASH``
     - Devices may have the firmware on non-volatile memory on the board, e.g.
       flash. This particular test helps to run a flash selftest on the device.
       Implementation of the test is left to the driver/firmware.

cách sử dụng ví dụ
-------------

.. code:: shell

    # Query selftests supported on the devlink device
    $ devlink dev selftests show DEV
    # Query selftests supported on all devlink devices
    $ devlink dev selftests show
    # Executes selftests on the device
    $ devlink dev selftests run DEV id flash