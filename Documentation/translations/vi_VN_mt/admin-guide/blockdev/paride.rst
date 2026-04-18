.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/blockdev/paride.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================================
Thiết bị Linux và cổng song song IDE
===================================

PARIDE v1.03 (c) 1997-8 Grant Guenther <grant@torque.net>
PATA_PARPORT (c) 2023 Ondrej Zary

1. Giới thiệu
===============

Do tính đơn giản và gần như phổ quát của giao diện cổng song song
cho máy tính cá nhân, nhiều thiết bị bên ngoài như đĩa cứng di động,
Ổ đĩa CD-ROM, LS-120 và băng từ sử dụng cổng song song để kết nối với ổ đĩa của chúng
máy tính chủ.  Trong khi một số thiết bị (đặc biệt là máy quét) sử dụng các phương pháp đặc biệt
để truyền lệnh và dữ liệu qua giao diện cổng song song, hầu hết
các thiết bị bên ngoài thực sự giống với một mô hình bên trong, nhưng với
một chip bộ điều hợp cổng song song được thêm vào. Một số cổng song song ban đầu
bộ điều hợp không chỉ là cơ chế ghép kênh bus SCSI.
(Bộ điều hợp Iomega PPA-3 được sử dụng trong ổ ZIP là một ví dụ về điều này
cách tiếp cận).  Tuy nhiên, hầu hết các thiết kế hiện tại đều có cách tiếp cận khác.
Chip bộ điều hợp tái tạo bus ISA hoặc IDE nhỏ trong thiết bị bên ngoài
và giao thức truyền thông cung cấp các hoạt động đọc và ghi
thanh ghi thiết bị cũng như các chức năng truyền khối dữ liệu.  Đôi khi,
thiết bị được xử lý qua cáp song song là SCSI tiêu chuẩn
bộ điều khiển như NCR 5380. Dòng băng bên ngoài "như vậy"
các ổ đĩa sử dụng bộ sao chép ISA để giao tiếp với bộ điều khiển đĩa mềm,
sau đó được kết nối với cơ chế băng mềm.  Đại đa số
Tuy nhiên, các thiết bị cổng song song bên ngoài hiện nay dựa trên tiêu chuẩn
Thiết bị loại IDE, không yêu cầu bộ điều khiển trung gian.  Nếu một
Ví dụ, để mở một ổ đĩa CD-ROM có cổng song song, người ta sẽ
tìm ổ ATAPI CD-ROM tiêu chuẩn, nguồn điện và một bộ chuyển đổi duy nhất
kết nối cáp cổng song song PC tiêu chuẩn và một cáp tiêu chuẩn
Cáp IDE.  Thông thường có thể trao đổi thiết bị CD-ROM với
bất kỳ thiết bị nào khác sử dụng giao diện IDE.

Tài liệu mô tả sự hỗ trợ trong Linux cho cổng song song IDE
thiết bị.  Nó không bao gồm các thiết bị SCSI cổng song song, băng "như vậy"
ổ đĩa hoặc máy quét.  Nhiều thiết bị khác nhau được hỗ trợ bởi
hệ thống con cổng song song IDE, bao gồm:

- Balo MicroSolutions CD-ROM
	- PD/CD ba lô MicroSolutions
	- Ổ cứng ba lô MicroSolutions
	- Ổ băng từ ba lô MicroSolutions 8000t
	- Ổ đĩa SyQuest EZ-135, EZ-230 & SparQ
	- Cá mập Avatar
	- Siêu đĩa ảo LS-120
	- Siêu Đĩa Maxell LS-120
	- Đĩa CD điện FreeCom
	- Ổ băng từ Hewlett-Packard 5GB và 8GB
	- Ổ đĩa CD-RW Hewlett-Packard 7100 và 7200

cũng như hầu hết các sản phẩm nhái, không tên tuổi trên thị trường.

Để hỗ trợ nhiều loại thiết bị như vậy, pata_parport thực sự được cấu trúc
thành hai phần. Có một mô-đun pata_parport cơ sở cung cấp giao diện
vào hệ thống con libata kernel, sổ đăng ký và một số phương pháp phổ biến để truy cập
các cổng song song.

Thành phần thứ hai là một tập hợp các trình điều khiển giao thức cấp thấp cho mỗi
chip chuyển đổi cổng song song IDE.  Nhờ sự quan tâm và động viên của
Người dùng Linux từ nhiều nơi trên thế giới, hầu hết tất cả đều được hỗ trợ
các giao thức bộ điều hợp đã biết:

==== ========================================= ====
        aten ATEN EH-100 (HK)
        Ba lô Microsolutions bpck (Mỹ)
        comm DataStor (loại cũ) bộ chuyển đổi "đi lại" (TW)
        dstr DataStor EP-2000 (TW)
        epat Shuttle EPAT (Anh)
        epia Shuttle EPIA (Anh)
	fit2 FIT TD-2000 (Mỹ)
	fit3 FIT TD-3000 (Mỹ)
	cáp friq Freecom IQ (DE)
        frpw Freecom Power (DE)
        kbic KingByte KBIC-951A và KBIC-971A (TW)
	Bộ chuyển đổi PHd của ktti KT Technology (SG)
        on20 OnSpec 90c20 (Mỹ)
        on26 OnSpec 90c26 (Mỹ)
	==== ========================================= ====


2. Sử dụng hệ thống con pata_parport
===============================

Trong khi định cấu hình nhân Linux, bạn có thể chọn xây dựng
trình điều khiển pata_parport vào kernel của bạn hoặc để xây dựng chúng dưới dạng mô-đun.

Trong cả hai trường hợp, bạn sẽ cần chọn "Hỗ trợ thiết bị IDE cổng song song"
và ít nhất một trong các giao thức truyền thông cổng song song.
Nếu bạn không biết loại bộ điều hợp cổng song song nào được sử dụng trong ổ đĩa của mình,
bạn có thể bắt đầu bằng cách kiểm tra tên tệp và bất kỳ tệp văn bản nào trên DOS của mình
đĩa mềm cài đặt.  Ngoài ra, bạn có thể nhìn vào các dấu hiệu trên
bản thân chip điều hợp.  Điều đó thường đủ để xác định
đúng thiết bị.

Bạn thực sự có thể chọn tất cả các mô-đun giao thức và cho phép pata_parport
hệ thống con để thử tất cả chúng cho bạn.

Đối với các sản phẩm "có thương hiệu" được liệt kê ở trên, đây là quy trình
và trình điều khiển cấp cao mà bạn sẽ sử dụng:

======================================
	Giao thức mẫu của nhà sản xuất
	======================================
	MicroSolutions CD-ROM bpck
	Ổ đĩa MicroSolutions PD bpck
	Ổ cứng MicroSolutions bpck
	Băng keo MicroSolutions 8000t bpck
	SyQuest EZ, SparQ epat
	Hình ảnh Superdisk epat
	Maxell Superdisk friq
	Tập phim Avatar Shark
	FreeCom CD-ROM miễn phí
	Băng từ Hewlett-Packard 5GB
	Bản cập nhật Hewlett-Packard 7200e (CD)
	Bản nâng cấp Hewlett-Packard 7200e (CD-R)
	======================================

Tất cả các cổng và tất cả trình điều khiển giao thức đều được thăm dò tự động trừ khi thăm dò=0
tham số được sử dụng. Vì vậy chỉ cần "modprobe epat" là đủ cho Imation SuperDisk
lái xe đi làm.

Tạo thiết bị thủ công::

# echo "độ trễ đơn vị chế độ giao thức cổng" >/sys/bus/pata_parport/new_device

Ở đâu:

=============================================================
	tên cổng cảng (hoặc "tự động" cho tất cả các cổng)
	tên giao thức giao thức (hoặc "tự động" cho tất cả các giao thức)
	số chế độ (theo giao thức cụ thể) hoặc -1 cho đầu dò
	số đơn vị (chỉ dành cho ba lô, xem bên dưới)
	độ trễ Độ trễ I/O (xem phần khắc phục sự cố bên dưới)
	=============================================================

Nếu tình cờ bạn đang sử dụng thiết bị ba lô MicroSolutions, bạn sẽ
cũng cần biết số ID đơn vị cho mỗi ổ đĩa.  Đây thường là
hai chữ số cuối của số sê-ri ổ đĩa (nhưng đọc là MicroSolutions'
tài liệu về điều này).

Nếu bạn bỏ qua các tham số ở cuối, các giá trị mặc định sẽ được sử dụng, ví dụ:

Thăm dò tất cả các cổng với tất cả các giao thức::

Tự động # echo >/sys/bus/pata_parport/new_device

Thăm dò parport0 bằng giao thức epat và chế độ 4 (EPP-16)::

# echo "parport0 epat 4" >/sys/bus/pata_parport/new_device

Thăm dò parport0 bằng cách sử dụng tất cả các giao thức::

# echo "parport0 auto" >/sys/bus/pata_parport/new_device

Thăm dò tất cả các cổng bằng giao thức epat::

	# echo "auto epat" >/sys/bus/pata_parport/new_device

Deleting devices::

	# echo pata_parport.0 >/sys/bus/pata_parport/delete_device


3. Troubleshooting
==================

3.1  Use EPP mode if you can
----------------------------

The most common problems that people report with the pata_parport drivers
concern the parallel port CMOS settings.  At this time, none of the
protocol modules support ECP mode, or any ECP combination modes.
If you are able to do so, please set your parallel port into EPP mode
using your CMOS setup procedure.

3.2  Check the port delay
-------------------------

Some parallel ports cannot reliably transfer data at full speed.  To
offset the errors, the protocol modules introduce a "port
delay" between each access to the i/o ports.  Each protocol sets
a default value for this delay.  In most cases, the user can override
the default and set it to 0 - resulting in somewhat higher transfer
rates.  In some rare cases (especially with older 486 systems) the
default delays are not long enough.  if you experience corrupt data
transfers, or unexpected failures, you may wish to increase the
port delay.

3.3  Some drives need a printer reset
-------------------------------------

There appear to be a number of "noname" external drives on the market
that do not always power up correctly.  We have noticed this with some
drives based on OnSpec and older Freecom adapters.  In these rare cases,
the adapter can often be reinitialised by issuing a "printer reset" on
the parallel port.  As the reset operation is potentially disruptive in
multiple device environments, the pata_parport drivers will not do it
automatically.  You can however, force a printer reset by doing::

	insmod lp reset=1
	rmmod lp

If you have one of these marginal cases, you should probably build
your pata_parport drivers as modules, and arrange to do the printer reset
before loading the pata_parport drivers.
