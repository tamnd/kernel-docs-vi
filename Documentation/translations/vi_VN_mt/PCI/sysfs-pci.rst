.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/PCI/sysfs-pci.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================================
Truy cập tài nguyên thiết bị PCI thông qua sysfs
================================================

sysfs, thường được gắn tại /sys, cung cấp quyền truy cập vào tài nguyên PCI trên nền tảng
hỗ trợ nó.  Ví dụ: một xe buýt nhất định có thể trông như thế này::

/sys/thiết bị/pci0000:17
     |-- 0000:17:00.0
     ZZ0001ZZ-- lớp
     ZZ0002ZZ-- cấu hình
     ZZ0003ZZ-- thiết bị
     ZZ0004ZZ-- kích hoạt
     ZZ0005ZZ-- irq
     ZZ0006ZZ-- local_cpus
     ZZ0007ZZ-- loại bỏ
     ZZ0008ZZ-- tài nguyên
     ZZ0009ZZ-- tài nguyên0
     ZZ0010ZZ-- tài nguyên1
     ZZ0011ZZ-- tài nguyên2
     ZZ0012ZZ-- sửa đổi
     ZZ0013ZZ-- rom
     ZZ0014ZZ-- hệ thống con_thiết bị
     ZZ0015ZZ-- hệ thống con_vendor
     |   ZZ0000ZZ-- ...

Phần tử trên cùng mô tả miền PCI và số bus.  Trong trường hợp này,
số miền là 0000 và số bus là 17 (cả hai giá trị đều ở dạng hex).
Bus này chứa một thiết bị chức năng duy nhất trong khe 0. Miền và bus
số được sao chép để thuận tiện.  Trong thư mục thiết bị có một số
các tập tin, mỗi tập tin có chức năng riêng.

=============================================================================
       chức năng tập tin
       =============================================================================
       lớp PCI lớp (ascii, ro)
       config PCI không gian cấu hình (nhị phân, rw)
       thiết bị PCI thiết bị (ascii, ro)
       bật Liệu thiết bị có được bật hay không (ascii, rw)
       số irq IRQ (ascii, ro)
       local_cpus mặt nạ CPU gần đó (cpumask, ro)
       xóa thiết bị xóa khỏi danh sách kernel (ascii, wo)
       tài nguyên địa chỉ máy chủ tài nguyên PCI (ascii, ro)
       Resource0..N PCI tài nguyên N, nếu có (nhị phân, mmap, rw\ [1]_)
       Resource0_wc..N_wc PCI Tài nguyên bản đồ WC N, nếu có thể tìm nạp trước (nhị phân, mmap)
       bản sửa đổi Bản sửa đổi PCI (ascii, ro)
       Tài nguyên rom PCI ROM, nếu có (nhị phân, ro)
       subsystem_device PCI thiết bị hệ thống con (ascii, ro)
       subsystem_vendor PCI nhà cung cấp hệ thống con (ascii, ro)
       nhà cung cấp PCI nhà cung cấp (ascii, ro)
       =============================================================================

::

ro - tập tin chỉ đọc
  rw - tập tin có thể đọc và ghi được
  wo - chỉ ghi tập tin
  mmap - tập tin có thể mmapable
  ascii - tập tin chứa văn bản ascii
  nhị phân - tập tin chứa dữ liệu nhị phân
  cpumask - tệp chứa loại cpumask

.. [1] rw for IORESOURCE_IO (I/O port) regions only

Các tệp chỉ đọc mang tính thông tin, việc ghi vào chúng sẽ bị bỏ qua, với
ngoại trừ tập tin 'rom'.  Các tập tin có thể ghi có thể được sử dụng để thực hiện
hành động trên thiết bị (ví dụ: thay đổi không gian cấu hình, tháo thiết bị).
Các tệp mmapable có sẵn thông qua mmap của tệp ở offset 0 và có thể
được sử dụng để lập trình thiết bị thực tế từ không gian người dùng.  Lưu ý rằng một số nền tảng
không hỗ trợ việc ánh xạ một số tài nguyên nhất định, vì vậy hãy nhớ kiểm tra kết quả trả lại
giá trị từ bất kỳ mmap nào đã thử.  Đáng chú ý nhất trong số này là cổng I/O
tài nguyên, cũng cung cấp quyền truy cập đọc/ghi.

Tệp 'kích hoạt' cung cấp bộ đếm cho biết thiết bị đã bao nhiêu lần
đã được kích hoạt.  Nếu tệp 'bật' hiện trả về '4' và '1' là
vang vọng vào nó, sau đó nó sẽ trả về '5'.  Báo lại '0' vào nó sẽ giảm
số đếm.  Tuy nhiên, ngay cả khi nó trở về 0, một số thao tác khởi tạo
có thể không được đảo ngược.

Tệp 'rom' đặc biệt ở chỗ nó cung cấp quyền truy cập chỉ đọc vào thư mục của thiết bị.
Tệp ROM, nếu có.  Tuy nhiên, nó bị tắt theo mặc định nên các ứng dụng
nên ghi chuỗi "1" vào tệp để kích hoạt nó trước khi thử đọc
gọi và vô hiệu hóa nó sau khi truy cập bằng cách ghi "0" vào tệp.  Lưu ý
rằng thiết bị phải được kích hoạt để đọc rom để trả về dữ liệu thành công.
Trong trường hợp trình điều khiển không bị ràng buộc với thiết bị, nó có thể được kích hoạt bằng cách sử dụng
tệp 'kích hoạt', được ghi lại ở trên.

Tệp 'remove' được sử dụng để xóa thiết bị PCI, bằng cách viết một giá trị khác 0
số nguyên cho tập tin.  Điều này không liên quan đến bất kỳ loại chức năng cắm nóng nào,
ví dụ: tắt nguồn thiết bị.  Thiết bị bị xóa khỏi danh sách kernel
Các thiết bị PCI, thư mục sysfs cho nó sẽ bị xóa và thiết bị sẽ
bị xóa khỏi mọi trình điều khiển được đính kèm với nó. Việc loại bỏ các bus gốc PCI là
không được phép.

Truy cập tài nguyên kế thừa thông qua sysfs
-------------------------------------------

Cổng I/O kế thừa và tài nguyên bộ nhớ ISA cũng được cung cấp trong sysfs nếu
nền tảng cơ bản hỗ trợ chúng.  Chúng nằm trong hệ thống phân cấp lớp PCI,
ví dụ::

/sys/class/pci_bus/0000:17/
	|-- cầu -> ../../../devices/pci0000:17
	|-- cpuaffinity
	|-- di sản_io
	`-- Legacy_mem

Tệp Legacy_io là tệp đọc/ghi có thể được các ứng dụng sử dụng để
thực hiện I/O cổng kế thừa.  Ứng dụng sẽ mở tệp, tìm kiếm mong muốn
port (ví dụ: 0x3e8) và thực hiện đọc hoặc ghi 1, 2 hoặc 4 byte.  Di sản_mem
tập tin phải được thêm vào với phần bù tương ứng với phần bù bộ nhớ
mong muốn, ví dụ: 0xa0000 cho bộ đệm khung VGA.  Ứng dụng sau đó có thể
chỉ cần hủy đăng ký con trỏ trả về (tất nhiên là sau khi kiểm tra lỗi)
để truy cập vào không gian bộ nhớ kế thừa.

Hỗ trợ truy cập PCI trên nền tảng mới
--------------------------------------

Để hỗ trợ ánh xạ tài nguyên PCI như mô tả ở trên, nền tảng Linux
lý tưởng nhất là mã nên xác định ARCH_GENERIC_PCI_MMAP_RESOURCE và sử dụng mã chung
việc thực hiện chức năng đó. Để hỗ trợ giao diện lịch sử của
mmap() thông qua các tệp trong /proc/bus/pci, nền tảng cũng có thể đặt HAVE_PCI_MMAP.

Ngoài ra, các nền tảng đặt HAVE_PCI_MMAP có thể cung cấp
triển khai pci_mmap_resource_range() thay vì xác định
ARCH_GENERIC_PCI_MMAP_RESOURCE.

Các nền tảng hỗ trợ bản đồ kết hợp ghi của tài nguyên PCI phải xác định
Arch_can_pci_mmap_wc() sẽ đánh giá khác 0 khi chạy khi
kết hợp ghi được cho phép. Nền tảng hỗ trợ bản đồ tài nguyên I/O
xác định Arch_can_pci_mmap_io() tương tự.

Tài nguyên kế thừa được bảo vệ bởi định nghĩa HAVE_PCI_LEGACY.  Nền tảng
mong muốn hỗ trợ chức năng kế thừa nên xác định nó và cung cấp
các hàm pci_legacy_read, pci_legacy_write và pci_mmap_legacy_page_range.