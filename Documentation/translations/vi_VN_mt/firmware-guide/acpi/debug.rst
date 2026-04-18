.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/firmware-guide/acpi/debug.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Đầu ra gỡ lỗi ACPI CA
======================

ACPI CA có thể tạo đầu ra gỡ lỗi.  Tài liệu này mô tả cách sử dụng
cơ sở vật chất.

Cấu hình thời gian biên dịch
============================

Đầu ra gỡ lỗi ACPI CA được kích hoạt trên toàn cầu bởi CONFIG_ACPI_DEBUG.  Nếu điều này
tùy chọn cấu hình không được đặt, các thông báo gỡ lỗi thậm chí không được tích hợp vào kernel.

Cấu hình thời gian khởi động và chạy
====================================

Khi CONFIG_ACPI_DEBUG=y, bạn có thể chọn thành phần và cấp độ của tin nhắn
bạn quan tâm. Khi khởi động, hãy sử dụng acpi.debug_layer và
Tùy chọn dòng lệnh kernel acpi.debug_level.  Sau khi khởi động, bạn có thể sử dụng
các tệp debug_layer và debug_level trong /sys/module/acpi/parameters/ để kiểm soát
các thông báo gỡ lỗi.

debug_layer (thành phần)
========================

"debug_layer" là mặt nạ chọn các thành phần quan tâm, ví dụ:
phần cụ thể của trình thông dịch ACPI.  Để xây dựng mặt nạ bit debug_layer, hãy xem
cho "#define _COMPONENT" trong tệp nguồn ACPI.

Bạn có thể đặt mặt nạ debug_layer khi khởi động bằng acpi.debug_layer
đối số dòng lệnh và bạn có thể thay đổi nó sau khi khởi động bằng cách viết các giá trị
tới /sys/module/acpi/parameters/debug_layer.

Các thành phần có thể có được xác định trong include/acpi/acoutput.h.

Đọc /sys/module/acpi/parameters/debug_layer hiển thị các giá trị mặt nạ được hỗ trợ ::

ACPI_UTILITIES 0x00000001
    ACPI_HARDWARE 0x00000002
    ACPI_EVENTS 0x00000004
    ACPI_TABLES 0x00000008
    ACPI_NAMESPACE 0x00000010
    ACPI_PARSER 0x00000020
    ACPI_DISPATCHER 0x00000040
    ACPI_EXECUTER 0x00000080
    ACPI_RESOURCES 0x00000100
    ACPI_CA_DEBUGGER 0x00000200
    ACPI_OS_SERVICES 0x00000400
    ACPI_CA_DISASSEMBLER 0x00000800
    ACPI_COMPILER 0x00001000
    ACPI_TOOLS 0x00002000

cấp độ gỡ lỗi
=============

"debug_level" là mặt nạ chọn các loại thông báo khác nhau, ví dụ:
những thứ liên quan đến khởi tạo, thực thi phương thức, thông báo thông tin, v.v.
Để xây dựng debug_level, hãy xem cấp độ được chỉ định trong ACPI_DEBUG_PRINT()
tuyên bố.

Trình thông dịch ACPI sử dụng nhiều cấp độ khác nhau, nhưng Linux
Trình điều khiển lõi ACPI và ACPI thường chỉ sử dụng ACPI_LV_INFO.

Bạn có thể đặt mặt nạ debug_level khi khởi động bằng cách sử dụng acpi.debug_level
đối số dòng lệnh và bạn có thể thay đổi nó sau khi khởi động bằng cách viết các giá trị
tới /sys/module/acpi/parameters/debug_level.

Các mức có thể được xác định trong include/acpi/acoutput.h.  Đọc
/sys/module/acpi/parameters/debug_level hiển thị các giá trị mặt nạ được hỗ trợ,
hiện tại là::

ACPI_LV_INIT 0x00000001
    ACPI_LV_DEBUG_OBJECT 0x00000002
    ACPI_LV_INFO 0x00000004
    ACPI_LV_INIT_NAMES 0x00000020
    ACPI_LV_PARSE 0x00000040
    ACPI_LV_LOAD 0x00000080
    ACPI_LV_DISPATCH 0x00000100
    ACPI_LV_EXEC 0x00000200
    ACPI_LV_NAMES 0x00000400
    ACPI_LV_OPREGION 0x00000800
    ACPI_LV_BFIELD 0x00001000
    ACPI_LV_TABLES 0x00002000
    ACPI_LV_VALUES 0x00004000
    ACPI_LV_OBJECTS 0x00008000
    ACPI_LV_RESOURCES 0x00010000
    ACPI_LV_USER_REQUESTS 0x00020000
    ACPI_LV_PACKAGE 0x00040000
    ACPI_LV_ALLOCATIONS 0x00100000
    ACPI_LV_FUNCTIONS 0x00200000
    ACPI_LV_OPTIMIZATIONS 0x00400000
    ACPI_LV_MUTEX 0x01000000
    ACPI_LV_THREADS 0x02000000
    ACPI_LV_IO 0x04000000
    ACPI_LV_INTERRUPTS 0x08000000
    ACPI_LV_AML_DISASSEMBLE 0x10000000
    ACPI_LV_VERBOSE_INFO 0x20000000
    ACPI_LV_FULL_TABLES 0x40000000
    ACPI_LV_EVENTS 0x80000000

Ví dụ
========

Ví dụ: driver/acpi/acpica/evxfevnt.c chứa phần này::

#define _COMPONENT ACPI_EVENTS
    ...
ACPI_DEBUG_PRINT((ACPI_DB_INIT, "Chế độ ACPI bị tắt\n"));

Để bật thông báo này, hãy đặt bit ACPI_EVENTS trong acpi.debug_layer
và bit ACPI_LV_INIT trong acpi.debug_level.  (ACPI_DEBUG_PRINT
câu lệnh sử dụng ACPI_DB_INIT, đây là macro dựa trên ACPI_LV_INIT
định nghĩa.)

Kích hoạt tất cả đầu ra "Gỡ lỗi" AML (lưu vào đối tượng Gỡ lỗi trong khi diễn giải
AML) trong khi khởi động::

acpi.debug_layer=0xffffffff acpi.debug_level=0x2

Kích hoạt tất cả các thông báo liên quan đến phần cứng ACPI::

acpi.debug_layer=0x2 acpi.debug_level=0xffffffff

Kích hoạt tất cả các tin nhắn ACPI_DB_INFO sau khi khởi động::

# echo 0x4 > /sys/module/acpi/parameters/debug_level

Hiển thị tất cả các giá trị thành phần hợp lệ::

# cat/sys/mô-đun/acpi/tham số/debug_layer