.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/PCI/endpoint/pci-endpoint-cfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================================
Định cấu hình điểm cuối PCI bằng CONFIGFS
==========================================

:Tác giả: Kishon Vijay Abraham I <kishon@ti.com>

Lõi điểm cuối PCI hiển thị mục nhập configfs (pci_ep) để định cấu hình
Chức năng điểm cuối PCI và để liên kết chức năng điểm cuối
với bộ điều khiển điểm cuối. (Để giới thiệu các cơ chế khác để
định cấu hình Chức năng điểm cuối PCI, hãy tham khảo [1]).

Gắn cấu hình
=================

Lớp lõi điểm cuối PCI tạo thư mục pci_ep trong configfs được gắn
thư mục. configfs có thể được gắn kết bằng lệnh sau ::

mount -t configfs none /sys/kernel/config

Cấu trúc thư mục
===================

Cấu hình pci_ep có hai thư mục gốc: bộ điều khiển và
chức năng. Mọi thiết bị EPC có trong hệ thống sẽ có một mục nhập
thư mục ZZ0000ZZ và mọi trình điều khiển EPF có trong hệ thống
sẽ có một mục trong thư mục ZZ0001ZZ.
:::::::::::::::::::::::::::::::::::::

/sys/kernel/config/pci_ep/
		.. controllers/
		.. functions/

Tạo thiết bị EPF
===================

Mọi trình điều khiển EPF đã đăng ký sẽ được liệt kê trong thư mục bộ điều khiển. các
các mục tương ứng với trình điều khiển EPF sẽ được tạo bởi lõi EPF.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

/sys/kernel/config/pci_ep/functions/
		.. <EPF Driver1>/
			... <EPF Device 11>/
			... <EPF Device 21>/
			... <EPF Device 31>/
		.. <EPF Driver2>/
			... <EPF Device 12>/
			... <EPF Device 22>/

Để tạo một <EPF thiết bị> thuộc loại được thăm dò bởi <EPF Driver>,
người dùng phải tạo một thư mục bên trong <EPF DriverN>.

Mỗi thư mục <EPF device> bao gồm các mục sau có thể được
được sử dụng để định cấu hình tiêu đề cấu hình tiêu chuẩn của chức năng điểm cuối.
(Các mục này được tạo bởi khung khi có bất kỳ <EPF Device> mới nào được
đã tạo)
:::::::

		.. <EPF Driver1>/
			... <EPF Device 11>/
				... vendorid
				... deviceid
				... revid
				... progif_code
				... subclass_code
				... baseclass_code
				... cache_line_size
				... subsys_vendor_id
				... subsys_id
				... interrupt_pin
			        ... <Symlink EPF Device 31>/
                                ... primary/
			                ... <Symlink EPC Device1>/
                                ... secondary/
			                ... <Symlink EPC Device2>/

Nếu một thiết bị EPF phải được liên kết với 2 EPC (như trong trường hợp
Cầu không trong suốt), liên kết tượng trưng của bộ điều khiển điểm cuối được kết nối với chính
giao diện nên được thêm vào thư mục 'chính' và liên kết tượng trưng của điểm cuối
bộ điều khiển được kết nối với giao diện phụ nên được thêm vào 'phụ'
thư mục.

Thư mục <EPF Device> có thể có danh sách các liên kết tượng trưng
(<Symlink EPF Device 31>) tới <EPF Device> khác. Những liên kết tượng trưng này nên
được người dùng tạo ra để thể hiện các chức năng ảo được ràng buộc với
chức năng vật lý. Trong cấu trúc thư mục trên <EPF Device 11> là một
chức năng vật lý và <EPF Device 31> là một chức năng ảo. Một thiết bị EPF một lần
nó được liên kết với một thiết bị EPF khác, không thể liên kết với thiết bị EPC.

Thiết bị EPC
============

Mọi thiết bị EPC đã đăng ký sẽ được liệt kê trong thư mục bộ điều khiển. các
các mục tương ứng với thiết bị EPC sẽ được tạo bởi lõi EPC.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

/sys/kernel/config/pci_ep/bộ điều khiển/
		.. <EPC Device1>/
			... <Symlink EPF Device11>/
			... <Symlink EPF Device12>/
			... start
		.. <EPC Device2>/
			... <Symlink EPF Device21>/
			... <Symlink EPF Device22>/
			... start

Thư mục <EPC Device> sẽ có danh sách các liên kết tượng trưng đến
<Thiết bị EPF>. Những liên kết tượng trưng này phải được người dùng tạo ra để
đại diện cho các chức năng có trong thiết bị đầu cuối. Chỉ <Thiết bị EPF>
đại diện cho chức năng vật lý có thể được liên kết với thiết bị EPC.

Thư mục <EPC Device> cũng sẽ có trường ZZ0000ZZ. Một lần
"1" được ghi vào trường này, thiết bị đầu cuối sẽ sẵn sàng
thiết lập liên kết với máy chủ. Việc này thường được thực hiện sau
tất cả các thiết bị EPF đều được tạo và liên kết với thiết bị EPC.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

| bộ điều khiển/
				| <Thư mục: Tên EPC>/
					| <Liên kết tượng trưng: Chức năng>
					| bắt đầu
			 | chức năng/
				| <Thư mục: Trình điều khiển EPF>/
					| <Thư mục: thiết bị EPF>/
						| nhà cung cấp
						| id thiết bị
						| làm lại
						| progif_code
						| subclass_code
						| baseclass_code
						| kích thước bộ nhớ cache_line_size
						| subsys_vendor_id
						| subsys_id
						| ngắt_pin
						| chức năng

[1] Tài liệu/PCI/endpoint/pci-endpoint.rst