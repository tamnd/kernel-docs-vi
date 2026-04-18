.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/usb/usb3-debug-port.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
Cổng gỡ lỗi USB3
=================

:Tác giả: Lu Baolu <baolu.lu@linux.intel.com>
:Ngày: Tháng 3 năm 2017

GENERAL
=======

Đây là HOWTO để sử dụng cổng gỡ lỗi USB3 trên hệ thống x86.

Trước khi sử dụng bất kỳ chức năng gỡ lỗi kernel nào dựa trên USB3
cổng gỡ lỗi, bạn cần phải::

1) kiểm tra xem có cổng gỡ lỗi USB3 nào có sẵn trong
	   hệ thống của bạn;
	2) kiểm tra cổng nào được sử dụng cho mục đích gỡ lỗi;
	3) có cáp gỡ lỗi A-to-A siêu tốc USB 3.0.

INTRODUCTION
============

Khả năng gỡ lỗi xHCI (DbC) là tùy chọn nhưng độc lập
chức năng được cung cấp bởi bộ điều khiển máy chủ xHCI. xHCI
đặc tả mô tả DbC trong phần 7.6.

Khi DbC được khởi tạo và kích hoạt, nó sẽ hiển thị một bản sửa lỗi
thiết bị thông qua cổng gỡ lỗi (thông thường là USB3 đầu tiên
cổng siêu tốc). Thiết bị gỡ lỗi hoàn toàn tuân thủ
khung USB và cung cấp mức tương đương rất cao
hiệu suất liên kết nối tiếp song công hoàn toàn giữa mục tiêu gỡ lỗi
(hệ thống đang gỡ lỗi) và máy chủ gỡ lỗi.

EARLY PRINTK
============

DbC đã được thiết kế để ghi lại các tin nhắn printk sớm. Một lần sử dụng cho
tính năng này là gỡ lỗi kernel. Ví dụ: khi máy của bạn
gặp sự cố rất sớm trước khi mã bảng điều khiển thông thường được khởi tạo.
Các cách sử dụng khác bao gồm ghi nhật ký đơn giản hơn, không khóa thay vì ghi toàn bộ
thổi trình điều khiển bảng điều khiển printk và klogd.

Trên hệ thống đích gỡ lỗi, bạn cần tùy chỉnh trình gỡ lỗi
kernel đã bật CONFIG_EARLY_PRINTK_USB_XDBC. Và thêm vào bên dưới
tham số khởi động kernel::

"earprintk=xdbc"

Nếu có nhiều bộ điều khiển xHCI trong hệ thống của bạn, bạn có thể
nối thêm chỉ mục bộ điều khiển máy chủ vào tham số kernel này. Cái này
chỉ số bắt đầu từ 0.

Thiết kế hiện tại không hỗ trợ tạm dừng/tiếp tục thời gian chạy DbC. Như
kết quả là bạn nên tắt tính năng quản lý nguồn điện trong thời gian chạy cho
Hệ thống con USB bằng cách thêm tham số khởi động kernel bên dưới ::

"usbcore.autosuspend=-1"

Trước khi bắt đầu mục tiêu gỡ lỗi, bạn nên kết nối trình gỡ lỗi
cổng sang cổng USB (cổng gốc hoặc cổng của bất kỳ hub bên ngoài nào) trên
máy chủ gỡ lỗi. Cáp dùng để kết nối 2 cổng này
phải là cáp gỡ lỗi A-to-A siêu tốc USB 3.0.

Trong quá trình khởi động sớm của mục tiêu gỡ lỗi, DbC sẽ được phát hiện và
được khởi tạo. Sau khi khởi tạo, máy chủ gỡ lỗi sẽ có thể
để liệt kê thiết bị gỡ lỗi trong mục tiêu gỡ lỗi. Máy chủ gỡ lỗi
sau đó sẽ liên kết thiết bị gỡ lỗi với mô-đun trình điều khiển usb_debug
và tạo thiết bị/dev/ttyUSB.

Nếu việc liệt kê thiết bị gỡ lỗi diễn ra suôn sẻ, bạn sẽ có thể
để xem các thông báo kernel bên dưới trên máy chủ gỡ lỗi ::

# tail -f /var/log/kern.log
	[ 1815.983374] usb 4-3: thiết bị SuperSpeed USB mới số 4 sử dụng xhci_hcd
	[ 1815.999595] usb 4-3: Độ trễ thoát LPM bằng 0, vô hiệu hóa LPM.
	[ 1815.999899] usb 4-3: Đã tìm thấy thiết bị USB mới, idVendor=1d6b, idProduct=0004
	[ 1815.999902] usb 4-3: Chuỗi thiết bị USB mới: Mfr=1, Product=2, SerialNumber=3
	[ 1815.999903] usb 4-3: Sản phẩm: Remote GDB
	[ 1815.999904] usb 4-3: Hãng sản xuất: Linux
	[ 1815.999905] usb 4-3: Số Serial: 0001
	[1816.000240] usb_debug 4-3:1.0: đã phát hiện bộ chuyển đổi xhci_dbc
	[ 1816.000360] usb 4-3: bộ chuyển đổi xhci_dbc hiện được gắn vào ttyUSB0

Bạn có thể sử dụng bất kỳ chương trình giao tiếp nào, ví dụ như minicom, để
đọc và xem tin nhắn. Các tập lệnh bash đơn giản dưới đây có thể giúp ích
bạn kiểm tra tính đúng đắn của thiết lập.

.. code-block:: sh

	===== start of bash scripts =============
	#!/bin/bash

	while true ; do
		while [ ! -d /sys/class/tty/ttyUSB0 ] ; do
			:
		done
	cat /dev/ttyUSB0
	done
	===== end of bash scripts ===============

nối tiếp TTY
==========

Hỗ trợ DbC đã được thêm vào trình điều khiển xHCI. Bạn có thể nhận được một
thiết bị gỡ lỗi do DbC cung cấp khi chạy.

Để sử dụng tính năng này, bạn cần đảm bảo rằng kernel của bạn đã được
được cấu hình để hỗ trợ USB_XHCI_DBGCAP. Thuộc tính sysfs bên dưới
nút thiết bị xHCI được sử dụng để bật hoặc tắt DbC. Theo mặc định,
DbC bị vô hiệu hóa::

root@target:/sys/bus/pci/devices/0000:00:14.0# cat dbc
	bị vô hiệu hóa

Kích hoạt DbC bằng lệnh sau ::

root@target:/sys/bus/pci/devices/0000:00:14.0# echo bật > dbc

Bạn có thể kiểm tra trạng thái DbC bất cứ lúc nào::

root@target:/sys/bus/pci/devices/0000:00:14.0# cat dbc
	đã bật

Kết nối mục tiêu gỡ lỗi với máy chủ gỡ lỗi bằng siêu USB 3.0
cáp gỡ lỗi tốc độ A-to-A. Bạn có thể thấy /dev/ttyDBC0 đã được tạo
trên mục tiêu gỡ lỗi. Bạn sẽ thấy các dòng thông báo kernel bên dưới::

root@target: tail -f /var/log/kern.log
	[ 182.730103] xhci_hcd 0000:00:14.0: Đã kết nối DbC
	[ 191.169420] xhci_hcd 0000:00:14.0: Đã định cấu hình DbC
	[ 191.169597] xhci_hcd 0000:00:14.0: DbC hiện được gắn vào /dev/ttyDBC0

Theo đó, trạng thái DbC đã được nâng lên::

root@target:/sys/bus/pci/devices/0000:00:14.0# cat dbc
	được cấu hình

Trên máy chủ gỡ lỗi, bạn sẽ thấy thiết bị gỡ lỗi đã được liệt kê.
Bạn sẽ thấy các dòng thông báo kernel bên dưới::

root@host: tail -f /var/log/kern.log
	[ 79.454780] usb 2-2.1: thiết bị SuperSpeed USB mới số 3 sử dụng xhci_hcd
	[ 79.475003] usb 2-2.1: Độ trễ thoát LPM bằng 0, vô hiệu hóa LPM.
	[ 79.475389] usb 2-2.1: Đã tìm thấy thiết bị USB mới, idVendor=1d6b, idProduct=0010
	[ 79.475390] usb 2-2.1: Chuỗi thiết bị USB mới: Mfr=1, Product=2, SerialNumber=3
	[ 79.475391] usb 2-2.1: Sản phẩm: Mục tiêu gỡ lỗi Linux USB
	[ 79.475392] usb 2-2.1: Nhà sản xuất: Linux Foundation
	[ 79.475393] usb 2-2.1: Số sê-ri: 0001

Thiết bị gỡ lỗi hiện đang hoạt động. Bạn có thể sử dụng bất kỳ thông tin liên lạc hoặc gỡ lỗi
chương trình trao đổi giữa máy chủ và mục tiêu.
