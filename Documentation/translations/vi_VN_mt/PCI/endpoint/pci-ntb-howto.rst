.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/PCI/endpoint/pci-ntb-howto.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================================================================
Hướng dẫn sử dụng Chức năng điểm cuối cầu nối không trong suốt PCI (NTB) (EPF)
==============================================================================

:Tác giả: Kishon Vijay Abraham I <kishon@ti.com>

Tài liệu này là tài liệu hướng dẫn giúp người dùng sử dụng chức năng driver pci-epf-ntb
và trình điều khiển máy chủ ntb_hw_epf cho chức năng NTB. Danh sách các bước để
được theo sau ở phía máy chủ và phía EP được đưa ra dưới đây. Đối với phần cứng
cấu hình và phần bên trong của NTB bằng cách sử dụng các điểm cuối có thể định cấu hình, xem
Tài liệu/PCI/điểm cuối/pci-ntb-function.rst

Thiết bị đầu cuối
=================

Thiết bị điều khiển điểm cuối
-----------------------------

Để triển khai chức năng NTB, ít nhất hai thiết bị điều khiển điểm cuối
được yêu cầu.

Để tìm danh sách các thiết bị điều khiển điểm cuối trong hệ thống::

# ls /sys/class/pci_epc/
	2900000.pcie-ep 2910000.pcie-ep

Nếu PCI_ENDPOINT_CONFIGFS được bật::

# ls/sys/kernel/config/pci_ep/bộ điều khiển
	2900000.pcie-ep 2910000.pcie-ep


Trình điều khiển chức năng điểm cuối
------------------------------------

Để tìm danh sách trình điều khiển chức năng điểm cuối trong hệ thống::

# ls /sys/bus/pci-epf/trình điều khiển
	pci_epf_ntb pci_epf_ntb

Nếu PCI_ENDPOINT_CONFIGFS được bật::

# ls /sys/kernel/config/pci_ep/functions
	pci_epf_ntb pci_epf_ntb


Tạo thiết bị pci-epf-ntb
----------------------------

Thiết bị chức năng điểm cuối PCI có thể được tạo bằng cách sử dụng configfs. Để tạo
thiết bị pci-epf-ntb, có thể sử dụng các lệnh sau ::

# mount -t configfs none/sys/kernel/config
	# cd /sys/kernel/config/pci_ep/
	Hàm # mkdir/pci_epf_ntb/func1

"mkdir func1" ở trên tạo ra thiết bị chức năng pci-epf-ntb sẽ
được thăm dò bởi trình điều khiển pci_epf_ntb.

Khung điểm cuối PCI điền vào thư mục có nội dung sau
các trường có thể định cấu hình::

Hàm # ls/pci_epf_ntb/func1
	baseclass_code deviceid msi_interrupt pci-epf-ntb.0
	progif_code subsys_id thứ cấp nhà cung cấp
	cache_line_size ngắt_pin msix_interrupts chính
	khôi phục subclass_code subsys_vendor_id

Trình điều khiển chức năng điểm cuối PCI điền các mục này với các giá trị mặc định
khi thiết bị được liên kết với trình điều khiển. Trình điều khiển pci-epf-ntb được điền
nhà cung cấp với 0xffff và ngắt_pin với 0x0001::

Hàm # cat/pci_epf_ntb/func1/vendorid
	0xffff
	Hàm # cat/pci_epf_ntb/func1/interrupt_pin
	0x0001


Định cấu hình thiết bị pci-epf-ntb
----------------------------------

Người dùng có thể định cấu hình thiết bị pci-epf-ntb bằng mục configfs của nó. theo thứ tự
để thay đổi nhà cung cấp và id thiết bị, hãy làm như sau
lệnh có thể được sử dụng ::

# echo 0x104c > hàm/pci_epf_ntb/func1/vendorid
	# echo 0xb00d > hàm/pci_epf_ntb/func1/deviceid

Khung điểm cuối PCI cũng tự động tạo một thư mục con trong
thư mục thuộc tính hàm. Thư mục con này có cùng tên với tên
của thiết bị chức năng và được điền với NTB cụ thể sau
các thuộc tính có thể được cấu hình bởi người dùng::

Hàm # ls/pci_epf_ntb/func1/pci_epf_ntb.0/
	db_count mw1 mw2 mw3 mw4 num_mws
	spad_count

Cấu hình mẫu cho chức năng NTB được đưa ra bên dưới::

# echo 4 > hàm/pci_epf_ntb/func1/pci_epf_ntb.0/db_count
	# echo 128 > hàm/pci_epf_ntb/func1/pci_epf_ntb.0/spad_count
	# echo 2 > hàm/pci_epf_ntb/func1/pci_epf_ntb.0/num_mws
	# echo 0x100000 > hàm/pci_epf_ntb/func1/pci_epf_ntb.0/mw1
	# echo 0x100000 > hàm/pci_epf_ntb/func1/pci_epf_ntb.0/mw2

Liên kết thiết bị pci-epf-ntb với bộ điều khiển EP
--------------------------------------------------

Thiết bị chức năng NTB phải được gắn vào hai bộ điều khiển điểm cuối PCI
được kết nối với hai máy chủ. Sử dụng các mục nhập 'chính' và 'phụ'
bên trong thiết bị chức năng NTB để gắn một bộ điều khiển điểm cuối PCI vào
giao diện chính và bộ điều khiển điểm cuối PCI khác đến giao diện phụ
giao diện::

# ln -s bộ điều khiển/2900000.pcie-ep/ hàm/pci-epf-ntb/func1/chính
	# ln -s bộ điều khiển/2910000.pcie-ep/ hàm/pci-epf-ntb/func1/thứ cấp

Sau khi hoàn thành bước trên, cả hai bộ điều khiển điểm cuối PCI đều sẵn sàng
thiết lập một liên kết với máy chủ.


Bắt đầu liên kết
----------------

Để thiết bị đầu cuối thiết lập liên kết với máy chủ, _start_
trường phải được điền bằng '1'. Đối với NTB, cả bộ điều khiển điểm cuối PCI
nên thiết lập liên kết với máy chủ::

# echo 1 > bộ điều khiển/2900000.pcie-ep/bắt đầu
	# echo 1 > bộ điều khiển/2910000.pcie-ep/bắt đầu


Thiết bị phức tạp Root
======================

đầu ra lspci
------------

Lưu ý rằng các thiết bị được liệt kê ở đây tương ứng với các giá trị được điền vào
Phần "Tạo thiết bị pci-epf-ntb" ở trên::

# lspci
	0000:00:00.0 Cầu PCI: Thiết bị Texas Instruments b00d
	0000:01:00.0 Bộ nhớ RAM: Thiết bị Texas Instruments b00d


Sử dụng thiết bị ntb_hw_epf
---------------------------

Phần mềm phía máy chủ tuân theo kiến ​​trúc phần mềm NTB tiêu chuẩn trong Linux.
Tất cả các tiện ích NTB phía máy khách hiện có như NTB Transport Client và NTB
Netdev, NTB Ping Pong Test Client và NTB Tool Test Client có thể được sử dụng với NTB
thiết bị chức năng.

Để biết thêm thông tin về NTB, hãy xem
ZZ0000ZZ