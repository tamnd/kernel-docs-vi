.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/openrisc/openrisc_port.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================
OpenRISC Linux
================

Đây là một bản chuyển thể của Linux sang lớp bộ vi xử lý OpenRISC; ban đầu
kiến trúc mục tiêu cụ thể là họ OpenRISC 1000 32-bit (hoặc 1k).

Để biết thông tin về bộ xử lý OpenRISC và sự phát triển đang diễn ra:

========================================
	trang web ZZ0000ZZ
	email linux-openrisc@vger.kernel.org
	========================================

---------------------------------------------------------------------

Hướng dẫn xây dựng chuỗi công cụ OpenRISC và Linux
===================================================

Để xây dựng và chạy Linux cho OpenRISC, bạn cần có ít nhất kiến thức cơ bản
chuỗi công cụ và có lẽ là trình mô phỏng kiến trúc.  Các bước để có được những bit này
tại chỗ được phác thảo ở đây.

1) Chuỗi công cụ

Các tệp nhị phân của chuỗi công cụ có thể được lấy từ openrisc.io hoặc trang phát hành github của chúng tôi.
Hướng dẫn xây dựng các chuỗi công cụ khác nhau có thể được tìm thấy trên openrisc.io
hoặc các tập lệnh xây dựng và phát hành chuỗi công cụ của Stafford.

=========================================================================
	nhị phân ZZ0000ZZ
	chuỗi công cụ ZZ0001ZZ
	tòa nhà ZZ0002ZZ
	=========================================================================

2) Tòa nhà

Xây dựng nhân Linux như bình thường ::

tạo cấu hình định dạng ARCH=openrisc CROSS_COMPILE="or1k-linux-"
	tạo ARCH=openrisc CROSS_COMPILE="or1k-linux-"

Nếu bạn muốn nhúng initramfs vào kernel, hãy chuyển ZZ0000ZZ. Ví dụ::

tạo ARCH=openrisc CROSS_COMPILE="or1k-linux-" CONFIG_INITRAMFS_SOURCE="path/to/rootfs path/to/devnodes"

Để biết thêm thông tin về điều này, vui lòng kiểm tra Tài liệu/hệ thống tập tin/ramfs-rootfs-initramfs.rst.

3) Chạy trên FPGA (tùy chọn)

Cộng đồng OpenRISC thường sử dụng FuseSoC để quản lý việc xây dựng và lập trình
một SoC thành FPGA.  Dưới đây là ví dụ về lập trình De0 Nano
bảng phát triển với OpenRISC SoC.  Trong quá trình xây dựng FPGA RTL là mã
được tải xuống từ kho lõi IP FuseSoC và được xây dựng bằng nhà cung cấp FPGA
công cụ.  Các tệp nhị phân được tải lên bảng bằng openocd.

::

bản sao git ZZ0000ZZ
	cầu chì cd
	cài đặt sudo pip -e .

cầu chì init
	cầu chì xây dựng de0_nano
	cầu chì pgm de0_nano

openocd -f giao diện/altera-usb-blaster.cfg \
		-f bảng/or1k_generic.cfg

telnet localhost 4444
	> khởi tạo
	> dừng lại; tải_image vmlinux; cài lại

4) Chạy trên Trình mô phỏng (tùy chọn)

QEMU là trình mô phỏng bộ xử lý mà chúng tôi khuyên dùng để mô phỏng OpenRISC
nền tảng.  Vui lòng làm theo hướng dẫn OpenRISC trên trang web QEMU để nhận
Linux chạy trên QEMU.  Bạn có thể tự xây dựng QEMU, nhưng bản phân phối Linux của bạn
có khả năng cung cấp các gói nhị phân để hỗ trợ OpenRISC.

============== ===========================================================
	qemu openrisc ZZ0000ZZ
	============== ===========================================================

---------------------------------------------------------------------

Thuật ngữ
===========

Trong mã, các hạt sau đây được sử dụng trên các ký hiệu để giới hạn phạm vi
đến việc triển khai bộ xử lý cụ thể ít nhiều:

=====================================================
openrisc: lớp bộ xử lý OpenRISC
or1k: dòng bộ xử lý OpenRISC 1000
or1200: bộ xử lý OpenRISC 1200
=====================================================

---------------------------------------------------------------------

Lịch sử
========

11-11-2003 Matjaz Breskvar (phoenix@bsemi.com)
	cổng đầu tiên của linux sang kiến trúc OpenRISC/or32.
        tất cả nội dung cốt lõi đã được triển khai và các đường nối có thể sử dụng được.

12-08-2003 Matjaz Breskvar (phoenix@bsemi.com)
	thay đổi hoàn toàn cách xử lý sai sót của TLB.
	viết lại xử lý ngoại lệ.
	sash-3.6 đầy đủ chức năng trong initrd mặc định.
	một phiên bản cải tiến hơn nhiều với những thay đổi xung quanh.

04-10-2004 Matjaz Breskvar (phoenix@bsemi.com)
	rất nhiều sửa lỗi khắp nơi.
	hỗ trợ ethernet, máy chủ http và telnet chức năng.
	chạy nhiều ứng dụng linux tiêu chuẩn.

26-06-2004 Matjaz Breskvar (phoenix@bsemi.com)
	chuyển sang 2.6.x

30-11-2004 Matjaz Breskvar (phoenix@bsemi.com)
	rất nhiều sửa lỗi và cải tiến.
	đã thêm trình điều khiển bộ đệm khung opencores.

10-09-2010 Jonas Bonn (jonas@southpole.se)
	viết lại lớn để ngang bằng với Linux 2.6.36 ngược dòng
