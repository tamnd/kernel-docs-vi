.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/firmware-guide/acpi/chromeos-acpi-device.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Thiết bị Chrome OS ACPI
=======================

Chức năng phần cứng dành riêng cho Chrome OS được hiển thị thông qua thiết bị Chrome OS ACPI.
ID plug and play của thiết bị Chrome OS ACPI là GGL0001 và ID phần cứng là
GOOG0016.  Các đối tượng ACPI sau đây được hỗ trợ:

.. flat-table:: Supported ACPI Objects
   :widths: 1 2
   :header-rows: 1

   * - Object
     - Description

   * - CHSW
     - Chrome OS switch positions

   * - HWID
     - Chrome OS hardware ID

   * - FWID
     - Chrome OS firmware version

   * - FRID
     - Chrome OS read-only firmware version

   * - BINF
     - Chrome OS boot information

   * - GPIO
     - Chrome OS GPIO assignments

   * - VBNV
     - Chrome OS NVRAM locations

   * - VDTA
     - Chrome OS verified boot data

   * - FMAP
     - Chrome OS flashmap base address

   * - MLST
     - Chrome OS method list

CHSW (Vị trí chuyển đổi Chrome OS)
==================================
Phương thức điều khiển này trả về vị trí công tắc cho các công tắc phần cứng cụ thể của Chrome OS.

Lập luận:
----------
Không có

Mã kết quả:
------------
Một số nguyên chứa các vị trí chuyển đổi dưới dạng trường bit:

.. flat-table::
   :widths: 1 2

   * - 0x00000002
     - Recovery button was pressed when x86 firmware booted.

   * - 0x00000004
     - Recovery button was pressed when EC firmware booted. (required if EC EEPROM is
       rewritable; otherwise optional)

   * - 0x00000020
     - Developer switch was enabled when x86 firmware booted.

   * - 0x00000200
     - Firmware write protection was disabled when x86 firmware booted. (required if
       firmware write protection is controlled through x86 BIOS; otherwise optional)

Tất cả các bit khác được dự trữ và phải được đặt thành 0.

HWID (ID phần cứng Chrome OS)
=============================
Phương pháp kiểm soát này trả về ID phần cứng cho Chromebook.

Lập luận:
----------
Không có

Mã kết quả:
------------
Chuỗi ASCII kết thúc bằng null chứa ID phần cứng từ vùng Dữ liệu dành riêng cho mô hình của
EEPROM.

Lưu ý rằng ID phần cứng có thể dài tới 256 ký tự, bao gồm cả ký tự null kết thúc.

FWID (Phiên bản phần mềm hệ điều hành Chrome)
=============================================
Phương pháp điều khiển này trả về phiên bản phần sụn cho phần có thể ghi lại của phần chính
phần mềm bộ xử lý.

Lập luận:
----------
Không có

Mã kết quả:
------------
Chuỗi ASCII kết thúc bằng null chứa phiên bản phần sụn hoàn chỉnh cho khả năng ghi lại
phần mềm của bộ xử lý chính.

FRID (Phiên bản phần sụn chỉ đọc của Chrome OS)
===============================================
Phương pháp điều khiển này trả về phiên bản phần sụn cho phần chỉ đọc của phần chính
phần mềm bộ xử lý.

Lập luận:
----------
Không có

Mã kết quả:
------------
Chuỗi ASCII kết thúc bằng null chứa phiên bản chương trình cơ sở hoàn chỉnh dành cho chế độ chỉ đọc
(bootstrap + recovery ) của phần sụn bộ xử lý chính.

BINF (Thông tin khởi động Chrome OS)
====================================
Phương thức điều khiển này trả về thông tin về lần khởi động hiện tại.

Lập luận:
----------
Không có

Mã kết quả:
------------

.. code-block::

   Package {
           Reserved1
           Reserved2
           Active EC Firmware
           Active Main Firmware Type
           Reserved5
   }

.. flat-table::
   :widths: 1 1 2
   :header-rows: 1

   * - Field
     - Format
     - Description

   * - Reserved1
     - DWORD
     - Set to 256 (0x100). This indicates this field is no longer used.

   * - Reserved2
     - DWORD
     - Set to 256 (0x100). This indicates this field is no longer used.

   * - Active EC firmware
     - DWORD
     - The EC firmware which was used during boot.

       - 0 - Read-only (recovery) firmware
       - 1 - Rewritable firmware.

       Set to 0 if EC firmware is always read-only.

   * - Active Main Firmware Type
     - DWORD
     - The main firmware type which was used during boot.

       - 0 - Recovery
       - 1 - Normal
       - 2 - Developer
       - 3 - netboot (factory installation only)

       Other values are reserved.

   * - Reserved5
     - DWORD
     - Set to 256 (0x100). This indicates this field is no longer used.

GPIO (Bài tập Chrome OS GPIO)
=================================
Phương thức kiểm soát này trả về thông tin về các bài tập GPIO dành riêng cho Chrome OS cho
Phần cứng Chrome OS nên kernel có thể trực tiếp điều khiển phần cứng đó.

Lập luận:
----------
Không có

Mã kết quả:
------------
.. code-block::

        Package {
                Package {
                        // First GPIO assignment
                        Signal Type        //DWORD
                        Attributes         //DWORD
                        Controller Offset  //DWORD
                        Controller Name    //ASCIIZ
                },
                ...
                Package {
                        // Last GPIO assignment
                        Signal Type        //DWORD
                        Attributes         //DWORD
                        Controller Offset  //DWORD
                        Controller Name    //ASCIIZ
                }
        }

Trong đó ASCIIZ có nghĩa là chuỗi ASCII kết thúc bằng null.

.. flat-table::
   :widths: 1 1 2
   :header-rows: 1

   * - Field
     - Format
     - Description

   * - Signal Type
     - DWORD
     - Type of GPIO signal

       - 0x00000001 - Recovery button
       - 0x00000002 - Developer mode switch
       - 0x00000003 - Firmware write protection switch
       - 0x00000100 - Debug header GPIO 0
       - ...
       - 0x000001FF - Debug header GPIO 255

       Other values are reserved.

   * - Attributes
     - DWORD
     - Signal attributes as bitfields:

       - 0x00000001 - Signal is active-high (for button, a GPIO value
         of 1 means the button is pressed; for switches, a GPIO value
         of 1 means the switch is enabled). If this bit is 0, the signal
         is active low. Set to 0 for debug header GPIOs.

   * - Controller Offset
     - DWORD
     - GPIO number on the specified controller.

   * - Controller Name
     - ASCIIZ
     - Name of the controller for the GPIO.
       Currently supported names:
       "NM10" - Intel NM10 chip

VBNV (Vị trí Chrome OS NVRAM)
================================
Phương thức điều khiển này trả về thông tin về các vị trí NVRAM (CMOS) được sử dụng để
giao tiếp với BIOS.

Lập luận:
----------
Không có

Mã kết quả:
------------
.. code-block::

        Package {
                NV Storage Block Offset  //DWORD
                NV Storage Block Size    //DWORD
        }

.. flat-table::
   :widths: 1 1 2
   :header-rows: 1

   * - Field
     - Format
     - Description

   * - NV Storage Block Offset
     - DWORD
     - Offset in CMOS bank 0 of the verified boot non-volatile storage block, counting from
       the first writable CMOS byte (that is, offset=0 is the byte following the 14 bytes of
       clock data).

   * - NV Storage Block Size
     - DWORD
     - Size in bytes of the verified boot non-volatile storage block.

FMAP (Địa chỉ flashmap của Chrome OS)
=====================================
Phương thức điều khiển này trả về địa chỉ bộ nhớ vật lý khi bắt đầu bộ xử lý chính
bản đồ flash chương trình cơ sở.

Lập luận:
----------
Không có

Không có Mã kết quả:
--------------------
DWORD chứa địa chỉ bộ nhớ vật lý khi bắt đầu phần sụn bộ xử lý chính
flashmap.

VDTA (Dữ liệu khởi động đã được xác minh của Chrome OS)
=======================================================
Phương thức điều khiển này trả về khối dữ liệu khởi động đã được xác minh được chia sẻ giữa phần sụn
bước xác minh và bước xác minh kernel.

Lập luận:
----------
Không có

Mã kết quả:
------------
Một bộ đệm chứa khối dữ liệu khởi động đã được xác minh.

MECK (Tổng kiểm tra công cụ quản lý)
====================================
Phương thức điều khiển này trả về hàm băm SHA-1 hoặc SHA-256 được đọc ra khỏi Quản lý
Các thanh ghi mở rộng của động cơ trong quá trình khởi động. Hàm băm được xuất qua ACPI để hệ điều hành có thể xác minh rằng
firmware ME không thay đổi. Nếu Công cụ quản lý không có hoặc nếu chương trình cơ sở đã bị
không thể đọc các thanh ghi mở rộng, bộ đệm này có thể bằng 0.

Lập luận:
----------
Không có

Mã kết quả:
------------
Một bộ đệm chứa hàm băm ME.

MLST (danh sách phương thức Chrome OS)
======================================
Phương thức điều khiển này trả về danh sách các phương thức điều khiển khác được Chrome OS hỗ trợ
thiết bị phần cứng.

Lập luận:
----------
Không có

Mã kết quả:
------------
Gói chứa danh sách các chuỗi ASCII kết thúc bằng null, một chuỗi cho mỗi phương thức điều khiển
được thiết bị phần cứng Chrome OS hỗ trợ, không bao gồm chính phương pháp MLST.
Đối với phiên bản đặc tả này, kết quả là:

.. code-block::

        Package {
                "CHSW",
                "FWID",
                "HWID",
                "FRID",
                "BINF",
                "GPIO",
                "VBNV",
                "FMAP",
                "VDTA",
                "MECK"
        }