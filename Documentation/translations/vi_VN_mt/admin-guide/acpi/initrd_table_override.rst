.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/acpi/initrd_table_override.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Nâng cấp bảng ACPI qua initrd
====================================

Chuyện này là về cái gì vậy
===========================

Nếu tùy chọn biên dịch ACPI_TABLE_UPGRADE là đúng, có thể
nâng cấp môi trường thực thi ACPI được xác định bởi các bảng ACPI
thông qua việc nâng cấp các bảng ACPI do BIOS cung cấp với một thiết bị đo,
đã sửa đổi, phiên bản mới hơn hoặc cài đặt các bảng ACPI hoàn toàn mới.

Khi xây dựng initrd bằng kernel trong một ảnh duy nhất, tùy chọn
ACPI_TABLE_OVERRIDE_VIA_BUILTIN_INITRD cũng đúng cho điều này
tính năng để làm việc.

Để biết danh sách đầy đủ các bảng ACPI có thể được nâng cấp/cài đặt, hãy xem
tại định nghĩa char ZZ0000ZZ trong
trình điều khiển/acpi/tables.c.

Tất cả các bảng ACPI iasl (trình biên dịch và dịch ngược ACPI của Intel) đều biết nên
có thể ghi đè được, ngoại trừ:

- ACPI_SIG_RSDP (có chữ ký 6 byte)
  - ACPI_SIG_FACS (không có tiêu đề bảng ACPI thông thường)

Cả hai đều có thể được thực hiện là tốt.


Cái này dùng để làm gì
======================

Khiếu nại với nền tảng/nhà cung cấp BIOS của bạn nếu bạn phát hiện ra một lỗi quá nghiêm trọng
rằng một cách giải quyết khác không được chấp nhận trong nhân Linux. Và cơ sở này
cho phép bạn nâng cấp các bảng có lỗi trước nhà cung cấp nền tảng/BIOS của bạn
phát hành tệp nhị phân BIOS được nâng cấp.

Cơ sở này có thể được sử dụng bởi các nhà cung cấp nền tảng/BIOS để cung cấp Linux
môi trường tương thích mà không cần sửa đổi phần sụn nền tảng cơ bản.

Cơ sở này cũng cung cấp một tính năng mạnh mẽ để dễ dàng gỡ lỗi và kiểm tra
Khả năng tương thích bảng ACPI BIOS với nhân Linux bằng cách sửa đổi bảng cũ
nền tảng đã cung cấp các bảng ACPI hoặc chèn các bảng ACPI mới.

Nó có thể và nên được kích hoạt trong bất kỳ kernel nào vì không có chức năng nào
thay đổi với initrds không được thiết bị.


Nó hoạt động như thế nào
========================
::

# Extract các bảng ACPI của máy:
  cd /tmp
  acpidump >acpidump
  acpixtract -a acpidump
  # Disassemble, sửa đổi và biên dịch lại chúng:
  iasl -d *.dat
  Ví dụ # For thêm câu lệnh này vào hàm _PRT (Bảng định tuyến PCI)
  # of và DSDT:
  Store("HELLO WORLD", gỡ lỗi)
  # And tăng Bản sửa đổi OEM. Ví dụ: trước khi sửa đổi:
  Định nghĩaBlock ("DSDT.aml", "DSDT", 2, "INTEL", "TEMPLATE", 0x00000000)
  Sửa đổi # After:
  Định nghĩaBlock ("DSDT.aml", "DSDT", 2, "INTEL", "TEMPLATE", 0x00000001)
  iasl -sa dsdt.dsl
  # Add các bảng ACPI thô vào kho lưu trữ cpio không nén.
  # They phải được đặt vào thư mục /kernel/firmware/acpi bên trong cpio
  # archive. Lưu ý rằng nếu bảng đặt ở đây khớp với bảng nền tảng
  # (Chữ ký bảng tương tự và OEMID tương tự và ID bảng OEM tương tự)
  # with Bản sửa đổi OEM gần đây hơn, bảng nền tảng sẽ được nâng cấp bởi
  Bàn # this. Nếu bảng đặt ở đây không khớp với bảng nền tảng
  # (Chữ ký bảng khác nhau hoặc Bảng OEMID khác nhau hoặc Bảng OEM khác nhau
  # ID), bảng này sẽ được thêm vào.
  mkdir -p kernel/chương trình cơ sở/acpi
  cp dsdt.aml hạt nhân/chương trình cơ sở/acpi
  # A hiện cho phép tối đa các bảng "NR_ACPI_INITRD_TABLES (64)"
  # (xem osl.c):
  iasl -sa facp.dsl
  iasl -sa ssdt1.dsl
  cp facp.aml kernel/firmware/acpi
  cp ssdt1.aml hạt nhân/chương trình cơ sở/acpi
  Kho lưu trữ cpio không nén # The phải là kho lưu trữ đầu tiên. Khác, thông thường
  Kho lưu trữ cpio # compressed, phải được nối lên trên kho lưu trữ không nén
  # one. Lệnh sau tạo kho lưu trữ cpio không nén và
  # concatenates initrd ban đầu ở trên:
  tìm hạt nhân | cpio -H newc --create > /boot/instrumented_initrd
  cat /boot/initrd >>/boot/instrumented_initrd
  # reboot với mức gỡ lỗi acpi tăng lên, ví dụ: thông số khởi động:
  acpi.debug_level=0x2 acpi.debug_layer=0xFFFFFFFF
  # and kiểm tra nhật ký hệ thống của bạn:
  [ 1.268089] ACPI: Bảng định tuyến ngắt PCI [\_SB_.PCI0._PRT]
  [ 1.272091] [Gỡ lỗi ACPI] Chuỗi [0x0B] "HELLO WORLD"

iasl có khả năng tháo rời và biên dịch lại khá nhiều thứ khác nhau,
cũng như các bảng ACPI tĩnh.


Nơi lấy công cụ không gian người dùng
=====================================

iasl và acpixtract là một phần của dự án ACPICA của Intel:
ZZ0000ZZ

và phải được đóng gói theo các bản phân phối (ví dụ như trong gói acpica
trên SUSE).

acpidump có thể được tìm thấy trong pmtools của Len Browns:
ftp://kernel.org/pub/linux/kernel/people/lenb/acpi/utils/pmtools/acpidump

Công cụ này cũng là một phần của gói acpica trên SUSE.
Ngoài ra, các bảng ACPI đã sử dụng có thể được truy xuất thông qua sysfs trong các hạt nhân mới nhất:
/sys/firmware/acpi/bảng