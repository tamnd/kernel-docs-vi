.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/iosm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
hỗ trợ liên kết phát triển iosm
===============================

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
   * - ``erase_full_flash``
     - u8
     - runtime
     - erase_full_flash parameter is used to check if full erase is required for
       the device during firmware flashing.
       If set, Full nand erase command will be sent to the device. By default,
       only conditional erase support is enabled.


Cập nhật nhanh
==============

Trình điều khiển ZZ0000ZZ triển khai hỗ trợ cập nhật flash bằng cách sử dụng
Giao diện ZZ0001ZZ.

Nó hỗ trợ cập nhật flash của thiết bị bằng hình ảnh flash kết hợp có chứa
hình ảnh Bootloader và hình ảnh phần mềm modem khác.

Trình điều khiển sử dụng DEVLINK_SUPPORT_FLASH_UPDATE_COMPONENT để xác định loại
hình ảnh chương trình cơ sở cần được flash theo yêu cầu của ứng dụng không gian người dùng.
Các loại hình ảnh phần sụn được hỗ trợ.

.. list-table:: Firmware Image types
    :widths: 15 85

    * - Name
      - Description
    * - ``PSI RAM``
      - Primary Signed Image
    * - ``EBL``
      - External Bootloader
    * - ``FLS``
      - Modem Software Image

PSI RAM và EBL là các hình ảnh RAM được đưa vào thiết bị khi
thiết bị đang ở giai đoạn BOOT ROM. Khi việc này thành công, phần mềm cơ sở của modem thực tế sẽ
hình ảnh được flash vào thiết bị. Hình ảnh phần mềm modem chứa nhiều tập tin
mỗi tệp có một tệp bin an toàn và ít nhất một tệp Loadmap/Region. Để nhấp nháy
những tập tin này, các lệnh thích hợp sẽ được gửi đến thiết bị modem cùng với
dữ liệu cần thiết để nhấp nháy. Dữ liệu như số vùng và địa chỉ của từng vùng
phải được chuyển cho trình điều khiển bằng lệnh devlink param.

Nếu thiết bị phải được xóa hoàn toàn trước khi flash firmware, ứng dụng người dùng sẽ
cần đặt tham số eras_full_flash bằng lệnh devlink param.
Theo mặc định, tính năng xóa có điều kiện được hỗ trợ.

Lệnh nhấp nháy:
===============
1) Khi modem đang ở giai đoạn Boot ROM, người dùng có thể sử dụng lệnh bên dưới để chèn PSI RAM
hình ảnh bằng lệnh flash devlink.

$ devlink dev flash pci/0000:02:00.0 tệp <PSI_RAM_File_name>

2) Nếu người dùng muốn xóa hoàn toàn, cần đưa ra lệnh bên dưới để đặt
xóa thông số flash đầy đủ (Chỉ được đặt nếu cần xóa hoàn toàn).

$ devlink dev param set pci/0000:02:00.0 name eras_full_flash value true thời gian chạy cmode

3) Đưa EBL sau khi modem ở giai đoạn PSI.

$ devlink dev flash pci/0000:02:00.0 tập tin <EBL_File_name>

4) Sau khi EBL được tiêm thành công, quá trình flash firmware thực tế sẽ diễn ra
nơi. Dưới đây là chuỗi lệnh được sử dụng cho từng hình ảnh phần sụn.

a) Tệp bin an toàn flash.

$ devlink dev flash pci/0000:02:00.0 tập tin <Secure_bin_file_name>

b) Nhấp nháy tệp Loadmap/Vùng

$ devlink dev flash pci/0000:02:00.0 tập tin <Load_map_file_name>

Khu vực
=======

Trình điều khiển ZZ0000ZZ hỗ trợ kết xuất nhật ký coredump.

Trong trường hợp phần sụn gặp ngoại lệ, ảnh chụp nhanh sẽ được thực hiện bởi
người lái xe. Các vùng sau được truy cập cho dữ liệu nội bộ của thiết bị.

.. list-table:: Regions implemented
    :widths: 15 85

    * - Name
      - Description
    * - ``report.json``
      - The summary of exception details logged as part of this region.
    * - ``coredump.fcd``
      - This region contains the details related to the exception occurred in the
        device (RAM dump).
    * - ``cdd.log``
      - This region contains the logs related to the modem CDD driver.
    * - ``eeprom.bin``
      - This region contains the eeprom logs.
    * - ``bootcore_trace.bin``
      -  This region contains the current instance of bootloader logs.
    * - ``bootcore_prev_trace.bin``
      - This region contains the previous instance of bootloader logs.


Lệnh vùng
===============

$ chương trình khu vực devlink

$ devlink khu vực pci/0000:02:00.0/report.json

$ devlink khu vực kết xuất pci/0000:02:00.0/report.json ảnh chụp nhanh 0

$ devlink khu vực del pci/0000:02:00.0/report.json ảnh chụp nhanh 0

$ khu vực devlink pci/0000:02:00.0/coredump.fcd

$ devlink khu vực kết xuất pci/0000:02:00.0/coredump.fcd snapshot 1

$ khu vực devlink del pci/0000:02:00.0/coredump.fcd snapshot 1

$ devlink khu vực pci/0000:02:00.0/cdd.log

$ devlink khu vực kết xuất pci/0000:02:00.0/cdd.log ảnh chụp nhanh 2

$ devlink khu vực del pci/0000:02:00.0/cdd.log snapshot 2

$ khu vực devlink pci/0000:02:00.0/eeprom.bin

$ devlink khu vực kết xuất pci/0000:02:00.0/eeprom.bin ảnh chụp nhanh 3

$ devlink khu vực del pci/0000:02:00.0/eeprom.bin snapshot 3

$ devlink khu vực pci/0000:02:00.0/bootcore_trace.bin

$ devlink khu vực kết xuất pci/0000:02:00.0/bootcore_trace.bin ảnh chụp nhanh 4

$ devlink khu vực del pci/0000:02:00.0/bootcore_trace.bin ảnh chụp nhanh 4

$ devlink khu vực pci/0000:02:00.0/bootcore_prev_trace.bin

$ devlink khu vực kết xuất pci/0000:02:00.0/bootcore_prev_trace.bin ảnh chụp nhanh 5

$ devlink khu vực del pci/0000:02:00.0/bootcore_prev_trace.bin ảnh chụp nhanh 5