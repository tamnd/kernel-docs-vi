.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/PCI/endpoint/pci-test-howto.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================
Hướng dẫn sử dụng thử nghiệm PCI
===================

:Tác giả: Kishon Vijay Abraham I <kishon@ti.com>

Tài liệu này là hướng dẫn giúp người dùng sử dụng driver chức năng pci-epf-test
và trình điều khiển máy chủ pci_endpoint_test để kiểm tra PCI. Danh sách các bước để
được theo sau ở phía máy chủ và phía EP được đưa ra dưới đây.

Thiết bị đầu cuối
===============

Thiết bị điều khiển điểm cuối
---------------------------

Để tìm danh sách các thiết bị điều khiển điểm cuối trong hệ thống::

# ls /sys/class/pci_epc/
	  51000000.pcie_ep

Nếu PCI_ENDPOINT_CONFIGFS được bật::

# ls/sys/kernel/config/pci_ep/bộ điều khiển
	  51000000.pcie_ep


Trình điều khiển chức năng điểm cuối
-------------------------

Để tìm danh sách trình điều khiển chức năng điểm cuối trong hệ thống::

# ls /sys/bus/pci-epf/trình điều khiển
	  pci_epf_test

Nếu PCI_ENDPOINT_CONFIGFS được bật::

# ls /sys/kernel/config/pci_ep/functions
	  pci_epf_test


Tạo thiết bị kiểm tra pci-epf
----------------------------

Thiết bị chức năng điểm cuối PCI có thể được tạo bằng cách sử dụng configfs. Để tạo
thiết bị kiểm tra pci-epf, có thể sử dụng các lệnh sau ::

# mount -t configfs none/sys/kernel/config
	# cd /sys/kernel/config/pci_ep/
	Hàm # mkdir/pci_epf_test/func1

"mkdir func1" ở trên tạo ra thiết bị chức năng pci-epf-test sẽ
được thăm dò bởi trình điều khiển pci_epf_test.

Khung điểm cuối PCI điền vào thư mục có nội dung sau
các trường có thể định cấu hình::

Hàm # ls/pci_epf_test/func1
	  baseclass_code ngắt_pin progif_code subsys_id
	  cache_line_size msi_interrupts revid subsys_vendorid
	  deviceid msix_interrupts subclass_code nhà cung cấpid

Trình điều khiển chức năng điểm cuối PCI điền các mục này với các giá trị mặc định
khi thiết bị được liên kết với trình điều khiển. Trình điều khiển pci-epf-test được điền
nhà cung cấp với 0xffff và ngắt_pin với 0x0001::

Hàm # cat/pci_epf_test/func1/vendorid
	  0xffff
	Hàm # cat/pci_epf_test/func1/interrupt_pin
	  0x0001


Định cấu hình thiết bị kiểm tra pci-epf
-------------------------------

Người dùng có thể định cấu hình thiết bị kiểm tra pci-epf bằng cách sử dụng mục configfs. theo thứ tự
để thay đổi nhà cung cấp và số lượng ngắt MSI được hàm này sử dụng
thiết bị, các lệnh sau có thể được sử dụng ::

# echo 0x104c > hàm/pci_epf_test/func1/vendorid
	# echo 0xb500 > hàm/pci_epf_test/func1/deviceid
	# echo 32 > hàm/pci_epf_test/func1/msi_interrupts
	# echo 2048 > hàm/pci_epf_test/func1/msix_interrupts

Theo mặc định, pci-epf-test sử dụng các kích thước BAR sau::

# grep. hàm/pci_epf_test/func1/pci_epf_test.0/bar?_size
	  hàm/pci_epf_test/func1/pci_epf_test.0/bar0_size:131072
	  hàm/pci_epf_test/func1/pci_epf_test.0/bar1_size:131072
	  hàm/pci_epf_test/func1/pci_epf_test.0/bar2_size:131072
	  hàm/pci_epf_test/func1/pci_epf_test.0/bar3_size:131072
	  hàm/pci_epf_test/func1/pci_epf_test.0/bar4_size:131072
	  hàm/pci_epf_test/func1/pci_epf_test.0/bar5_size:1048576

Người dùng có thể ghi đè giá trị mặc định bằng cách sử dụng ví dụ:::
	# echo 1048576 > hàm/pci_epf_test/func1/pci_epf_test.0/bar1_size

Việc ghi đè kích thước BAR mặc định chỉ có thể được thực hiện trước khi liên kết
thiết bị kiểm tra pci-epf sang trình điều khiển bộ điều khiển điểm cuối PCI.

Lưu ý: Một số bộ điều khiển điểm cuối có thể có BAR có kích thước cố định hoặc BAR dành riêng;
đối với các bộ điều khiển như vậy, kích thước BAR tương ứng trong configfs sẽ bị bỏ qua.


Liên kết thiết bị kiểm tra pci-epf với Bộ điều khiển EP
--------------------------------------------

Để thiết bị chức năng điểm cuối trở nên hữu ích, nó phải được ràng buộc với
trình điều khiển bộ điều khiển điểm cuối PCI. Sử dụng configfs để liên kết hàm
thiết bị tới một trong các trình điều khiển bộ điều khiển có trong hệ thống::

# ln -s chức năng/pci_epf_test/bộ điều khiển func1/51000000.pcie_ep/

Sau khi hoàn thành bước trên, điểm cuối PCI đã sẵn sàng thiết lập liên kết
với chủ nhà.


Bắt đầu liên kết
--------------

Để thiết bị đầu cuối thiết lập liên kết với máy chủ, _start_
trường phải được điền bằng '1'::

# echo 1 > bộ điều khiển/51000000.pcie_ep/bắt đầu


Thiết bị phức tạp Root
==================

đầu ra lspci
------------

Lưu ý rằng các thiết bị được liệt kê ở đây tương ứng với giá trị được điền trong 1.4
ở trên::

00:00.0 Cầu PCI: Thiết bị Texas Instruments 8888 (rev 01)
	01:00.0 Lớp chưa được chỉ định [ff00]: Texas Instruments Device b500


Sử dụng chức năng Endpoint Test
-----------------------------------

Kselftest được thêm vào trong tools/testing/selftests/pci_endpoint có thể được sử dụng để chạy tất cả
các bài kiểm tra điểm cuối PCI mặc định. Để xây dựng Kselftest cho điểm cuối PCI
hệ thống con, nên sử dụng các lệnh sau ::

# cd <kernel-dir>
	# make -C công cụ/thử nghiệm/selftests/pci_endpoint

hoặc nếu bạn muốn biên dịch và cài đặt trong hệ thống của mình ::

# cd <kernel-dir>
	# make -C công cụ/thử nghiệm/selftests/pci_endpoint INSTALL_PATH=/usr/bin cài đặt

Bài kiểm tra sẽ được đặt tại <rootfs>/usr/bin/

Kết quả Kselftest
~~~~~~~~~~~~~~~~
::

# pci_endpoint_test
	TAP phiên bản 13
	1..16
	# Starting 16 bài kiểm tra từ 9 trường hợp kiểm tra.
	#  ZZ0001ZZ pci_ep_bar.BAR0.BAR_TEST ...
	#            OK pci_ep_bar.BAR0.BAR_TEST
	được 1 pci_ep_bar.BAR0.BAR_TEST
	#  ZZ0008ZZ pci_ep_bar.BAR1.BAR_TEST ...
	#            OK pci_ep_bar.BAR1.BAR_TEST
	được rồi 2 pci_ep_bar.BAR1.BAR_TEST
	#  ZZ0015ZZ pci_ep_bar.BAR2.BAR_TEST ...
	#            OK pci_ep_bar.BAR2.BAR_TEST
	được rồi 3 pci_ep_bar.BAR2.BAR_TEST
	#  ZZ0022ZZ pci_ep_bar.BAR3.BAR_TEST ...
	#            OK pci_ep_bar.BAR3.BAR_TEST
	được rồi 4 pci_ep_bar.BAR3.BAR_TEST
	#  ZZ0029ZZ pci_ep_bar.BAR4.BAR_TEST ...
	#            OK pci_ep_bar.BAR4.BAR_TEST
	được rồi 5 pci_ep_bar.BAR4.BAR_TEST
	#  ZZ0036ZZ pci_ep_bar.BAR5.BAR_TEST ...
	#            OK pci_ep_bar.BAR5.BAR_TEST
	được rồi 6 pci_ep_bar.BAR5.BAR_TEST
	#  ZZ0043ZZ pci_ep_basic.CONSECUTIVE_BAR_TEST ...
	#            OK pci_ep_basic.CONSECUTIVE_BAR_TEST
	được rồi 7 pci_ep_basic.CONSECUTIVE_BAR_TEST
	#  ZZ0047ZZ pci_ep_basic.LEGACY_IRQ_TEST ...
	#            OK pci_ep_basic.LEGACY_IRQ_TEST
	được 8 pci_ep_basic.LEGACY_IRQ_TEST
	#  ZZ0051ZZ pci_ep_basic.MSI_TEST ...
	#            OK pci_ep_basic.MSI_TEST
	được rồi 9 pci_ep_basic.MSI_TEST
	#  ZZ0055ZZ pci_ep_basic.MSIX_TEST ...
	#            OK pci_ep_basic.MSIX_TEST
	được 10 pci_ep_basic.MSIX_TEST
	#  ZZ0059ZZ pci_ep_data_transfer.memcpy.READ_TEST ...
	#            OK pci_ep_data_transfer.memcpy.READ_TEST
	được 11 pci_ep_data_transfer.memcpy.READ_TEST
	#  ZZ0063ZZ pci_ep_data_transfer.memcpy.WRITE_TEST ...
	#            OK pci_ep_data_transfer.memcpy.WRITE_TEST
	được rồi 12 pci_ep_data_transfer.memcpy.WRITE_TEST
	#  ZZ0067ZZ pci_ep_data_transfer.memcpy.COPY_TEST ...
	#            OK pci_ep_data_transfer.memcpy.COPY_TEST
	được 13 pci_ep_data_transfer.memcpy.COPY_TEST
	#  ZZ0071ZZ pci_ep_data_transfer.dma.READ_TEST ...
	#            OK pci_ep_data_transfer.dma.READ_TEST
	được rồi 14 pci_ep_data_transfer.dma.READ_TEST
	#  ZZ0075ZZ pci_ep_data_transfer.dma.WRITE_TEST ...
	#            OK pci_ep_data_transfer.dma.WRITE_TEST
	được 15 pci_ep_data_transfer.dma.WRITE_TEST
	#  ZZ0079ZZ pci_ep_data_transfer.dma.COPY_TEST ...
	#            OK pci_ep_data_transfer.dma.COPY_TEST
	được 16 pci_ep_data_transfer.dma.COPY_TEST
	# ZZ0083ZZ: 16/16 bài kiểm tra đã đạt.
	# Totals: vượt qua:16 thất bại:0 xfail:0 xpass:0 bỏ qua:0 lỗi:0


Testcase 16 (pci_ep_data_transfer.dma.COPY_TEST) sẽ thất bại đối với hầu hết DMA
bộ điều khiển điểm cuối có khả năng do không có MEMCPY trên DMA. Đối với như vậy
bộ điều khiển, bạn nên bỏ qua trường hợp thử nghiệm này bằng cách sử dụng
lệnh::

# pci_endpoint_test -f pci_ep_bar -f pci_ep_basic -v memcpy -T COPY_TEST -v dma

Chuông cửa Kselftest EP
~~~~~~~~~~~~~~~~~~~~~

Nếu bộ điều khiển Endpoint MSI được sử dụng cho trường hợp sử dụng chuông cửa, hãy chạy bên dưới
lệnh để kiểm tra nó:

# pci_endpoint_test -f pcie_ep_doorbell

# Starting 1 thử nghiệm từ 1 trường hợp thử nghiệm.
	#  ZZ0000ZZ pcie_ep_doorbell.DOORBELL_TEST ...
	#            OK pcie_ep_doorbell.DOORBELL_TEST
	được 1 pcie_ep_doorbell.DOORBELL_TEST
	# ZZ0004ZZ: 1/1 bài kiểm tra đã đạt.
	# Totals: vượt qua:1 thất bại:0 xfail:0 xpass:0 bỏ qua:0 lỗi:0