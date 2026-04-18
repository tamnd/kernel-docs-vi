.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/PCI/endpoint/pci-vntb-howto.rst
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

:Tác giả: Frank Li <Frank.Li@nxp.com>

Tài liệu này là tài liệu hướng dẫn giúp người dùng sử dụng chức năng driver pci-epf-vntb
và trình điều khiển máy chủ ntb_hw_epf cho chức năng NTB. Danh sách các bước để
được theo sau ở phía máy chủ và phía EP được đưa ra dưới đây. Đối với phần cứng
cấu hình và phần bên trong của NTB bằng cách sử dụng các điểm cuối có thể định cấu hình, xem
Tài liệu/PCI/endpoint/pci-vntb-function.rst

Thiết bị đầu cuối
===============

Thiết bị điều khiển điểm cuối
---------------------------

Để tìm danh sách các thiết bị điều khiển điểm cuối trong hệ thống::

# ls /sys/class/pci_epc/
          5f010000.pcie_ep

Nếu PCI_ENDPOINT_CONFIGFS được bật::

# ls/sys/kernel/config/pci_ep/bộ điều khiển
          5f010000.pcie_ep

Trình điều khiển chức năng điểm cuối
-------------------------

Để tìm danh sách trình điều khiển chức năng điểm cuối trong hệ thống::

# ls /sys/bus/pci-epf/trình điều khiển
	pci_epf_ntb pci_epf_test pci_epf_vntb

Nếu PCI_ENDPOINT_CONFIGFS được bật::

# ls /sys/kernel/config/pci_ep/functions
	pci_epf_ntb pci_epf_test pci_epf_vntb


Tạo thiết bị pci-epf-vntb
----------------------------

Thiết bị chức năng điểm cuối PCI có thể được tạo bằng cách sử dụng configfs. Để tạo
thiết bị pci-epf-vntb, có thể sử dụng các lệnh sau ::

# mount -t configfs none/sys/kernel/config
	# cd /sys/kernel/config/pci_ep/
	Hàm # mkdir/pci_epf_vntb/func1

"mkdir func1" ở trên tạo ra thiết bị chức năng pci-epf-vntb sẽ
được thăm dò bởi trình điều khiển pci_epf_vntb.

Khung điểm cuối PCI điền vào thư mục có nội dung sau
các trường có thể định cấu hình::

Hàm # ls/pci_epf_vntb/func1
	baseclass_code deviceid msi_interrupts pci-epf-vntb.0
	progif_code subsys_id thứ cấp nhà cung cấp
	cache_line_size ngắt_pin msix_interrupts chính
	khôi phục subclass_code subsys_vendor_id

Trình điều khiển chức năng điểm cuối PCI điền các mục này với các giá trị mặc định
khi thiết bị được liên kết với trình điều khiển. Trình điều khiển pci-epf-vntb được điền
nhà cung cấp với 0xffff và ngắt_pin với 0x0001::

Hàm # cat/pci_epf_vntb/func1/vendorid
	0xffff
	Hàm # cat/pci_epf_vntb/func1/interrupt_pin
	0x0001


Cấu hình thiết bị pci-epf-vntb
-------------------------------

Người dùng có thể định cấu hình thiết bị pci-epf-vntb bằng mục configfs của nó. theo thứ tự
để thay đổi nhà cung cấp và id thiết bị, hãy làm như sau
lệnh có thể được sử dụng ::

# echo 0x1957 > hàm/pci_epf_vntb/func1/vendorid
	# echo 0x0809 > hàm/pci_epf_vntb/func1/deviceid

Khung điểm cuối PCI cũng tự động tạo một thư mục con trong
thư mục thuộc tính hàm. Thư mục con này có cùng tên với tên
của thiết bị chức năng và được điền với NTB cụ thể sau
các thuộc tính có thể được cấu hình bởi người dùng::

Hàm # ls/pci_epf_vntb/func1/pci_epf_vntb.0/
	ctrl_bar db_count mw1_bar mw2_bar mw3_bar mw4_bar spad_count
	db_bar mw1 mw2 mw3 mw4 num_mws vbus_number
	vntb_vid vntb_pid

Cấu hình mẫu cho chức năng NTB được đưa ra bên dưới::

# echo 4 > hàm/pci_epf_vntb/func1/pci_epf_vntb.0/db_count
	# echo 128 > hàm/pci_epf_vntb/func1/pci_epf_vntb.0/spad_count
	# echo 1 > hàm/pci_epf_vntb/func1/pci_epf_vntb.0/num_mws
	# echo 0x100000 > hàm/pci_epf_vntb/func1/pci_epf_vntb.0/mw1

Theo mặc định, mỗi cấu trúc được gán một BAR, nếu cần và theo thứ tự.
Nếu nền tảng yêu cầu thiết lập BAR cụ thể, BAR có thể được chỉ định
cho mỗi cấu trúc bằng cách sử dụng mục nhập ZZ0000ZZ có liên quan.

Cấu hình mẫu cho trình điều khiển NTB ảo cho bus PCI ảo::

# echo 0x1957 > hàm/pci_epf_vntb/func1/pci_epf_vntb.0/vntb_vid
	# echo 0x080A > hàm/pci_epf_vntb/func1/pci_epf_vntb.0/vntb_pid
	# echo 0x10 > hàm/pci_epf_vntb/func1/pci_epf_vntb.0/vbus_number

Liên kết thiết bị pci-epf-vntb với bộ điều khiển EP
--------------------------------------------

Thiết bị chức năng NTB phải được gắn vào bộ điều khiển điểm cuối PCI
được kết nối với máy chủ.

# ln -s bộ điều khiển/5f010000.pcie_ep chức năng/pci_epf_vntb/func1/chính

Sau khi hoàn thành bước trên, bộ điều khiển điểm cuối PCI đã sẵn sàng
thiết lập một liên kết với máy chủ.


Bắt đầu liên kết
--------------

Để thiết bị đầu cuối thiết lập liên kết với máy chủ, _start_
trường phải được điền bằng '1'. Đối với NTB, cả bộ điều khiển điểm cuối PCI
nên thiết lập liên kết với máy chủ (imx8 không cần bước này)::

# echo 1 > bộ điều khiển/5f010000.pcie_ep/bắt đầu

Thiết bị phức tạp Root
==================

Đầu ra lspci ở phía máy chủ
-------------------------

Lưu ý rằng các thiết bị được liệt kê ở đây tương ứng với các giá trị được điền vào
Phần "Tạo thiết bị pci-epf-vntb" ở trên::

# lspci
        00:00.0 Cầu PCI: Thiết bị Freescale Semiconductor Inc 0000 (rev 01)
        01:00.0 Bộ nhớ RAM: Thiết bị Freescale Semiconductor Inc 0809

Thiết bị đầu cuối / Bus PCI ảo
=================================

Đầu ra lspci ở phía EP / bus PCI ảo
-----------------------------------------

Lưu ý rằng các thiết bị được liệt kê ở đây tương ứng với các giá trị được điền vào
Phần "Tạo thiết bị pci-epf-vntb" ở trên::

# lspci
        10:00.0 Lớp chưa được chỉ định [ffff]: Dawicontrol Computersysteme GmbH Device 1234 (rev ff)

Sử dụng thiết bị ntb_hw_epf
-----------------------

Phần mềm phía máy chủ tuân theo kiến ​​trúc phần mềm NTB tiêu chuẩn trong Linux.
Tất cả các tiện ích NTB phía máy khách hiện có như NTB Transport Client và NTB
Netdev, NTB Ping Pong Test Client và NTB Tool Test Client có thể được sử dụng với NTB
thiết bị chức năng.

Để biết thêm thông tin về NTB, hãy xem
ZZ0000ZZ