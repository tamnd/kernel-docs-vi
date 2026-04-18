.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/usb/gadget-testing.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================
Kiểm tra tiện ích
==============

Tệp này tóm tắt thông tin về kiểm tra cơ bản các chức năng USB
được cung cấp bởi các tiện ích.

.. contents

   1. ACM function
   2. ECM function
   3. ECM subset function
   4. EEM function
   5. FFS function
   6. HID function
   7. LOOPBACK function
   8. MASS STORAGE function
   9. MIDI function
   10. NCM function
   11. OBEX function
   12. PHONET function
   13. RNDIS function
   14. SERIAL function
   15. SOURCESINK function
   16. UAC1 function (legacy implementation)
   17. UAC2 function
   18. UVC function
   19. PRINTER function
   20. UAC1 function (new API)
   21. MIDI2 function


1. Chức năng ACM
===============

Chức năng này được cung cấp bởi mô-đun usb_f_acm.ko.

Giao diện configfs dành riêng cho chức năng
------------------------------------

Tên hàm sử dụng khi tạo thư mục hàm là "acm".
Hàm ACM chỉ cung cấp một thuộc tính trong thư mục hàm của nó:

số cổng

Thuộc tính chỉ đọc.

Có thể có tối đa 4 cổng ACM/nối tiếp chung/OBEX trong hệ thống.


Kiểm tra chức năng ACM
------------------------

Trên máy chủ::

mèo > /dev/ttyACM<X>

Trên thiết bị::

mèo /dev/ttyGS<Y>

thì ngược lại

Trên thiết bị::

con mèo > /dev/ttyGS<Y>

Trên máy chủ::

mèo /dev/ttyACM<X>

2. Chức năng ECM
===============

Chức năng này được cung cấp bởi mô-đun usb_f_ecm.ko.

Giao diện configfs dành riêng cho chức năng
------------------------------------

Tên hàm sử dụng khi tạo thư mục hàm là "ecm".
Hàm ECM cung cấp các thuộc tính này trong thư mục hàm của nó:

======================================================================
	ifname tên giao diện thiết bị mạng được liên kết với điều này
			thể hiện hàm
	hệ số chiều dài hàng đợi qmult cho tốc độ cao và siêu nhanh
	Host_addr MAC địa chỉ của máy chủ ở cuối này
			Ethernet qua liên kết USB
	dev_addr MAC địa chỉ cuối thiết bị này
			Ethernet qua liên kết USB
	======================================================================

và sau khi tạo các hàm/ecm.<tên phiên bản> chúng chứa mặc định
giá trị: qmult là 5, dev_addr và Host_addr được chọn ngẫu nhiên.
Tên if có thể được ghi vào nếu hàm không bị ràng buộc. Một bài viết phải là một
mẫu giao diện chẳng hạn như "usb%d", điều này sẽ khiến lõi mạng chọn
giao diện usbX miễn phí tiếp theo. Theo mặc định, nó được đặt thành "usb%d".

Kiểm tra chức năng ECM
------------------------

Định cấu hình địa chỉ IP của thiết bị và máy chủ. Sau đó:

Trên thiết bị::

ping <IP của máy chủ>

Trên máy chủ::

ping <IP của thiết bị>

3. Hàm tập hợp con ECM
======================

Chức năng này được cung cấp bởi mô-đun usb_f_ecm_subset.ko.

Giao diện configfs dành riêng cho chức năng
------------------------------------

Tên hàm sử dụng khi tạo thư mục hàm là "geth".
Hàm tập hợp con ECM cung cấp các thuộc tính này trong thư mục hàm của nó:

======================================================================
	ifname tên giao diện thiết bị mạng được liên kết với điều này
			thể hiện hàm
	hệ số chiều dài hàng đợi qmult cho tốc độ cao và siêu nhanh
	Host_addr MAC địa chỉ của máy chủ ở cuối này
			Ethernet qua liên kết USB
	dev_addr MAC địa chỉ cuối thiết bị này
			Ethernet qua liên kết USB
	======================================================================

và sau khi tạo các hàm/ecm.<tên phiên bản> chúng chứa mặc định
giá trị: qmult là 5, dev_addr và Host_addr được chọn ngẫu nhiên.
Tên if có thể được ghi vào nếu hàm không bị ràng buộc. Một bài viết phải là một
mẫu giao diện chẳng hạn như "usb%d", điều này sẽ khiến lõi mạng chọn
giao diện usbX miễn phí tiếp theo. Theo mặc định, nó được đặt thành "usb%d".

Kiểm tra chức năng tập hợp con ECM
-------------------------------

Định cấu hình địa chỉ IP của thiết bị và máy chủ. Sau đó:

Trên thiết bị::

ping <IP của máy chủ>

Trên máy chủ::

ping <IP của thiết bị>

4. Chức năng EEM
===============

Chức năng này được cung cấp bởi mô-đun usb_f_eem.ko.

Giao diện configfs dành riêng cho chức năng
------------------------------------

Tên hàm sử dụng khi tạo thư mục hàm là "eem".
Hàm EEM cung cấp các thuộc tính này trong thư mục hàm của nó:

======================================================================
	ifname tên giao diện thiết bị mạng được liên kết với điều này
			thể hiện hàm
	hệ số chiều dài hàng đợi qmult cho tốc độ cao và siêu nhanh
	Host_addr MAC địa chỉ của máy chủ ở cuối này
			Ethernet qua liên kết USB
	dev_addr MAC địa chỉ cuối thiết bị này
			Ethernet qua liên kết USB
	======================================================================

và sau khi tạo các hàm/eem.<tên phiên bản> chúng chứa mặc định
giá trị: qmult là 5, dev_addr và Host_addr được chọn ngẫu nhiên.
Tên if có thể được ghi vào nếu hàm không bị ràng buộc. Một bài viết phải là một
mẫu giao diện chẳng hạn như "usb%d", điều này sẽ khiến lõi mạng chọn
giao diện usbX miễn phí tiếp theo. Theo mặc định, nó được đặt thành "usb%d".

Kiểm tra chức năng EEM
------------------------

Định cấu hình địa chỉ IP của thiết bị và máy chủ. Sau đó:

Trên thiết bị::

ping <IP của máy chủ>

Trên máy chủ::

ping <IP của thiết bị>

5. Chức năng FFS
===============

Chức năng này được cung cấp bởi mô-đun usb_f_fs.ko.

Giao diện configfs dành riêng cho chức năng
------------------------------------

Tên hàm sử dụng khi tạo thư mục hàm là "ffs".
Thư mục chức năng được cố ý để trống và không thể sửa đổi.

Sau khi tạo thư mục, sẽ có một phiên bản mới ("thiết bị") của FunctionFS
có sẵn trong hệ thống. Sau khi có "thiết bị", người dùng nên làm theo
quy trình chuẩn để sử dụng FunctionFS (gắn kết nó, chạy không gian người dùng
quá trình thực hiện đúng chức năng). Tiện ích này phải được kích hoạt
bằng cách viết một chuỗi thích hợp vào usb_gadget/<gadget>/UDC.

Hàm FFS chỉ cung cấp một thuộc tính trong thư mục hàm của nó:

sẵn sàng

Thuộc tính chỉ đọc và báo hiệu nếu hàm sẵn sàng (1)
đã sử dụng, E.G. nếu không gian người dùng có các bộ mô tả và chuỗi được viết thành ep0, thì
tiện ích có thể được kích hoạt.

Kiểm tra chức năng FFS
------------------------

Trên thiết bị: khởi động daemon không gian người dùng của chức năng, bật tiện ích

Trên máy chủ: sử dụng chức năng USB do thiết bị cung cấp

6. Chức năng HID
===============

Chức năng này được cung cấp bởi mô-đun usb_f_hid.ko.

Giao diện configfs dành riêng cho chức năng
------------------------------------

Tên hàm sử dụng khi tạo thư mục hàm là "hid".
Hàm HID cung cấp các thuộc tính này trong thư mục hàm của nó:

===============================================================
	giao thức HID giao thức để sử dụng
	dữ liệu report_desc được sử dụng trong báo cáo HID, ngoại trừ dữ liệu
			được thông qua với /dev/hidg<X>
	report_length HID độ dài báo cáo
	lớp con HID lớp con để sử dụng
	===============================================================

Đối với bàn phím, giao thức và lớp con là 1, report_length là 8,
trong khi report_desc là::

$ hd my_report_desc
  00000000 05 01 09 06 a1 01 05 07 19 e0 29 e7 15 00 25 01 ZZ0000ZZ
  00000010 75 01 95 08 81 02 95 01 75 08 81 03 95 05 75 01 ZZ0001ZZ
  00000020 05 08 19 01 29 05 91 02 95 01 75 03 91 03 95 06 ZZ0002ZZ
  00000030 75 08 15 00 25 65 05 07 19 00 29 65 81 00 c0 ZZ0003ZZ
  0000003f

Một chuỗi byte như vậy có thể được lưu trữ vào thuộc tính với echo::

$ echo -ne \\x05\\x01\\x09\\x06\\xa1.....

Kiểm tra chức năng HID
------------------------

Thiết bị:

- tạo tiện ích
- kết nối tiện ích với máy chủ, tốt nhất không phải thiết bị được sử dụng
  để điều khiển tiện ích
- chạy chương trình ghi vào/dev/hidg<N>, ví dụ:
  một chương trình không gian người dùng được tìm thấy trong Documentation/usb/gadget_hid.rst::

$ ./hid_gadget_test /dev/hidg0 bàn phím

Chủ nhà:

- quan sát các lần nhấn phím từ tiện ích

7. Chức năng LOOPBACK
====================

Chức năng này được cung cấp bởi mô-đun usb_f_ss_lb.ko.

Giao diện configfs dành riêng cho chức năng
------------------------------------

Tên hàm sử dụng khi tạo thư mục hàm là "Loopback".
Hàm LOOPBACK cung cấp các thuộc tính này trong thư mục hàm của nó:

=========================================
	độ sâu qlen của hàng đợi vòng lặp
	chiều dài bộ đệm Bulk_buflen
	=========================================

Kiểm tra chức năng LOOPBACK
-----------------------------

thiết bị: chạy tiện ích

máy chủ: test-usb (tools/usb/testusb.c)

8. Chức năng MASS STORAGE
========================

Chức năng này được cung cấp bởi mô-đun usb_f_mass_storage.ko.

Giao diện configfs dành riêng cho chức năng
------------------------------------

Tên hàm sử dụng khi tạo thư mục hàm là "mass_storage".
Hàm MASS STORAGE cung cấp các thuộc tính này trong thư mục của nó:
tập tin:

===================================================================
	gian hàng Đặt để cho phép chức năng tạm dừng các điểm cuối hàng loạt.
			Đã tắt trên một số thiết bị USB không hoạt động
			một cách chính xác. Bạn nên đặt nó thành đúng.
	num_buffers Số lượng bộ đệm đường ống. Số hợp lệ
			là 2..4. Chỉ có sẵn nếu
			CONFIG_USB_GADGET_DEBUG_FILES được thiết lập.
	===================================================================

và một thư mục lun.0 mặc định tương ứng với SCSI LUN #0.

Một lun mới có thể được thêm bằng mkdir::

$ hàm mkdir/mass_storage.0/partition.5

Việc đánh số lun không nhất thiết phải liên tục, ngoại trừ lun #0 là
được tạo theo mặc định. Có thể chỉ định tối đa 8 lun và tất cả chúng đều phải
được đặt tên theo sơ đồ <name>.<number>. Các số có thể là 0..8.
Có lẽ một quy ước hay là đặt tên cho lun là "lun.<number>",
mặc dù nó không bắt buộc.

Trong mỗi thư mục lun có các tệp thuộc tính sau:

===================================================================
	file Đường dẫn tới tệp sao lưu cho LUN.
			Bắt buộc nếu LUN không được đánh dấu là có thể tháo rời.
	ro Cờ chỉ định quyền truy cập vào LUN sẽ là
			chỉ đọc. Điều này được ngụ ý nếu mô phỏng CD-ROM
			được kích hoạt cũng như khi không thể
			để mở "tên tệp" ở chế độ R/W.
	Cờ có thể tháo rời xác định rằng LUN sẽ được biểu thị là
			có thể tháo rời.
	Cờ cdrom chỉ định rằng LUN sẽ được báo cáo là
			là CD-ROM.
	Cờ nofua chỉ định cờ FUA đó
			trong SCSI WRITE(10,12)
	bị ép buộc_eject Tệp chỉ ghi này chỉ hữu ích khi
			chức năng đang hoạt động. Nó gây ra sự ủng hộ
			tập tin buộc phải tách ra khỏi LUN,
			bất kể máy chủ có cho phép hay không.
			Bất kỳ số byte nào khác 0 được ghi sẽ
			dẫn đến sự phóng ra.
	===================================================================

Kiểm tra chức năng MASS STORAGE
---------------------------------

thiết bị: kết nối tiện ích, kích hoạt nó
máy chủ: dmesg, xem các ổ USB xuất hiện (nếu hệ thống được cấu hình tự động
gắn kết)

9. Chức năng MIDI
================

Chức năng này được cung cấp bởi mô-đun usb_f_midi.ko.

Giao diện configfs dành riêng cho chức năng
------------------------------------

Tên hàm sử dụng khi tạo thư mục hàm là "midi".
Hàm MIDI cung cấp các thuộc tính này trong thư mục hàm của nó:

=========================================================
	chiều dài bộ đệm buflen MIDI
	chuỗi ID id cho bộ điều hợp USB MIDI
	số in_ports của cổng đầu vào MIDI
	giá trị chỉ mục chỉ mục cho bộ điều hợp USB MIDI
	out_ports số lượng cổng đầu ra MIDI
	qlen USB độ dài hàng đợi yêu cầu đọc
	giao diện_string USB Chuỗi giao diện AudioControl
	=========================================================

Kiểm tra chức năng MIDI
-------------------------

Có 2 trường hợp: chơi mid từ tiện ích tới
máy chủ và phát mid từ máy chủ đến tiện ích.

1) Phát mid từ tiện ích đến máy chủ:

chủ nhà::

$ arecordmidi -l
   Cổng Tên khách hàng Tên cổng
   14:0 Midi Qua Midi Qua Port-0
   24:0 MIDI Tiện ích MIDI Tiện ích MIDI 1
  $ arecordmidi -p 24:0 from_gadget.mid

tiện ích::

$ aplaymidi -l
   Cổng Tên khách hàng Tên cổng
   20:0 f_midi f_midi

$ aplaymidi -p 20:0 to_host.mid

2) Phát mid từ máy chủ đến thiết bị

tiện ích::

$ arecordmidi -l
   Cổng Tên khách hàng Tên cổng
   20:0 f_midi f_midi

$ arecordmidi -p 20:0 from_host.mid

chủ nhà::

$ aplaymidi -l
   Cổng Tên khách hàng Tên cổng
   14:0 Midi Qua Midi Qua Port-0
   24:0 MIDI Tiện ích MIDI Tiện ích MIDI 1

$ aplaymidi -p24:0 to_gadget.mid

From_gadget.mid sẽ phát ra âm thanh giống với to_host.mid.

From_host.id sẽ phát ra âm thanh giống với to_gadget.mid.

Các tệp MIDI có thể được phát tới loa/tai nghe bằng ví dụ:. sự rụt rè cài đặt::

$ aplaymidi -l
   Cổng Tên khách hàng Tên cổng
   14:0 Midi Qua Midi Qua Port-0
   24:0 MIDI Tiện ích MIDI Tiện ích MIDI 1
  128:0 TiMidity Cổng TiMidity 0
  128:1 TiMidity Cổng TiMidity 1
  128:2 TiMidity Cổng TiMidity 2
  128:3 TiMidity Cổng TiMidity 3

$ aplaymidi -p 128:0 file.mid

Các cổng MIDI có thể được kết nối hợp lý bằng tiện ích aconnect, ví dụ::

$ aconnect 24:0 128:0 # try trên máy chủ

Sau khi cổng MIDI của tiện ích được kết nối với cổng MIDI của rụt rè,
bất cứ điều gì được phát ở phía tiện ích với aplaymidi -l đều có thể nghe được
trong loa/tai nghe của máy chủ.

10. Chức năng NCM
================

Chức năng này được cung cấp bởi mô-đun usb_f_ncm.ko.

Giao diện configfs dành riêng cho chức năng
------------------------------------

Tên hàm sử dụng khi tạo thư mục hàm là "ncm".
Hàm NCM cung cấp các thuộc tính này trong thư mục hàm của nó:

===============================================================================
	ifname tên giao diện thiết bị mạng được liên kết với điều này
				thể hiện hàm
	hệ số chiều dài hàng đợi qmult cho tốc độ cao và siêu nhanh
	Host_addr MAC địa chỉ của máy chủ ở cuối này
				Ethernet qua liên kết USB
	dev_addr MAC địa chỉ cuối thiết bị này
				Ethernet qua liên kết USB
	max_segment_size Kích thước phân đoạn cần thiết cho các kết nối P2P. Cái này
				sẽ đặt MTU thành 14 byte
	===============================================================================

và sau khi tạo các hàm/ncm.<tên phiên bản> chúng chứa mặc định
giá trị: qmult là 5, dev_addr và Host_addr được chọn ngẫu nhiên.
Tên if có thể được ghi vào nếu hàm không bị ràng buộc. Một bài viết phải là một
mẫu giao diện chẳng hạn như "usb%d", điều này sẽ khiến lõi mạng chọn
giao diện usbX miễn phí tiếp theo. Theo mặc định, nó được đặt thành "usb%d".

Kiểm tra chức năng NCM
------------------------

Định cấu hình địa chỉ IP của thiết bị và máy chủ. Sau đó:

Trên thiết bị::

ping <IP của máy chủ>

Trên máy chủ::

ping <IP của thiết bị>

11. Chức năng OBEX
=================

Chức năng này được cung cấp bởi mô-đun usb_f_obex.ko.

Giao diện configfs dành riêng cho chức năng
------------------------------------

Tên hàm sử dụng khi tạo thư mục hàm là "obex".
Hàm OBEX chỉ cung cấp một thuộc tính trong thư mục hàm của nó:

số cổng

Thuộc tính chỉ đọc.

Có thể có tối đa 4 cổng ACM/nối tiếp chung/OBEX trong hệ thống.

Kiểm tra chức năng OBEX
-------------------------

Trên thiết bị::

nối tiếp -f /dev/ttyGS<Y> -s 1024

Trên máy chủ::

serialc -v <vendorID> -p <productID> -i<interface#> -a1 -s1024 \
                -t<out địa chỉ cuối addr> -r<in địa chỉ cuối addr>

trong đó seriald và serialc là các tiện ích của Felipe được tìm thấy ở đây:

Bậc thầy ZZ0000ZZ

12. Chức năng PHONET
===================

Chức năng này được cung cấp bởi mô-đun usb_f_phonet.ko.

Giao diện configfs dành riêng cho chức năng
------------------------------------

Tên hàm sử dụng khi tạo thư mục hàm là "phonet".
Hàm PHONET chỉ cung cấp một thuộc tính trong thư mục hàm của nó:

======================================================================
	ifname tên giao diện thiết bị mạng được liên kết với điều này
			thể hiện hàm
	======================================================================

Kiểm tra chức năng PHONET
---------------------------

Không thể kiểm tra giao thức SOCK_STREAM mà không có phần cụ thể
về phần cứng nên chỉ có SOCK_DGRAM được thử nghiệm. Để cái sau hoạt động,
trước đây tôi đã phải áp dụng bản vá được đề cập ở đây:

ZZ0000ZZ

Những công cụ này được yêu cầu:

git://git.gitorious.org/meego-mobile/phonet-utils.git

Trên máy chủ::

$ ./phonet -a 0x10 -i usbpn0
	$ ./pnroute thêm 0x6c usbpn0
	$./pnroute thêm 0x10 usbpn0
	$ ifconfig usbpn0 lên

Trên thiết bị::

$ ./phonet -a 0x6c -i upnlink0
	$ ./pnroute thêm 0x10 upnlink0
	$ ifconfig upnlink0 lên

Sau đó, một chương trình thử nghiệm có thể được sử dụng::

ZZ0000ZZ

Trên thiết bị::

$ ./pnxmit -a 0x6c -r

Trên máy chủ::

$ ./pnxmit -a 0x10 -s 0x6c

Kết quả là một số dữ liệu sẽ được gửi từ máy chủ đến thiết bị.
Sau đó thì ngược lại:

Trên máy chủ::

$ ./pnxmit -a 0x10 -r

Trên thiết bị::

$ ./pnxmit -a 0x6c -s 0x10

13. Chức năng RNDIS
==================

Chức năng này được cung cấp bởi mô-đun usb_f_rndis.ko.

Giao diện configfs dành riêng cho chức năng
------------------------------------

Tên hàm sử dụng khi tạo thư mục hàm là "rndis".
Hàm RNDIS cung cấp các thuộc tính này trong thư mục hàm của nó:

======================================================================
	ifname tên giao diện thiết bị mạng được liên kết với điều này
			thể hiện hàm
	hệ số chiều dài hàng đợi qmult cho tốc độ cao và siêu nhanh
	Host_addr MAC địa chỉ của máy chủ ở cuối này
			Ethernet qua liên kết USB
	dev_addr MAC địa chỉ cuối thiết bị này
			Ethernet qua liên kết USB
	======================================================================

và sau khi tạo các hàm/rndis.<tên phiên bản> chúng chứa mặc định
giá trị: qmult là 5, dev_addr và Host_addr được chọn ngẫu nhiên.
Tên if có thể được ghi vào nếu hàm không bị ràng buộc. Một bài viết phải là một
mẫu giao diện chẳng hạn như "usb%d", điều này sẽ khiến lõi mạng chọn
giao diện usbX miễn phí tiếp theo. Theo mặc định, nó được đặt thành "usb%d".

Kiểm tra chức năng RNDIS
--------------------------

Định cấu hình địa chỉ IP của thiết bị và máy chủ. Sau đó:

Trên thiết bị::

ping <IP của máy chủ>

Trên máy chủ::

ping <IP của thiết bị>

14. Chức năng SERIAL
===================

Chức năng này được cung cấp bởi mô-đun usb_f_gser.ko.

Giao diện configfs dành riêng cho chức năng
------------------------------------

Tên hàm sử dụng khi tạo thư mục hàm là "gser".
Hàm SERIAL chỉ cung cấp một thuộc tính trong thư mục hàm của nó:

số cổng

Thuộc tính chỉ đọc.

Có thể có tối đa 4 cổng ACM/nối tiếp chung/OBEX trong hệ thống.

Kiểm tra chức năng SERIAL
---------------------------

Trên máy chủ::

insmod usbserial
	echo VID PID >/sys/bus/usb-serial/drivers/generic/new_id

Trên máy chủ::

con mèo > /dev/ttyUSB<X>

Đúng mục tiêu::

mèo /dev/ttyGS<Y>

thì ngược lại

Đúng mục tiêu::

con mèo > /dev/ttyGS<Y>

Trên máy chủ::

mèo /dev/ttyUSB<X>

15. Chức năng SOURCESINK
=======================

Chức năng này được cung cấp bởi mô-đun usb_f_ss_lb.ko.

Giao diện configfs dành riêng cho chức năng
------------------------------------

Tên hàm được sử dụng khi tạo thư mục hàm là "SourceSink".
Hàm SOURCESINK cung cấp các thuộc tính này trong thư mục hàm của nó:

======================================================
	mẫu 0 (tất cả số không), 1 (mod63), 2 (không có)
	isoc_interval 1..16
	isoc_maxpacket 0 - 1023 (fs), 0 - 1024 (hs/ss)
	isoc_mult 0..2 (chỉ hs/ss)
	isoc_maxburst 0..15 (chỉ ss)
	chiều dài bộ đệm Bulk_buflen
	Bulk_maxburst 0..15 (chỉ giây)
	Bulk_qlen độ sâu của hàng đợi cho số lượng lớn
	iso_qlen độ sâu của hàng đợi cho iso
	======================================================

Kiểm tra chức năng SOURCESINK
-------------------------------

thiết bị: chạy tiện ích

máy chủ: test-usb (tools/usb/testusb.c)


16. Chức năng UAC1 (triển khai kế thừa)
=========================================

Chức năng này được cung cấp bởi mô-đun usb_f_uac1_legacy.ko.

Giao diện configfs dành riêng cho chức năng
------------------------------------

Tên hàm sẽ sử dụng khi tạo thư mục hàm
là "uac1_legacy".
Hàm uac1 cung cấp các thuộc tính này trong thư mục hàm của nó:

========================================================
	audio_buf_size kích thước bộ đệm âm thanh
	fn_cap chụp tên tệp thiết bị pcm
	tên tệp thiết bị điều khiển fn_cntl
	fn_play phát lại tên tệp thiết bị pcm
	req_buf_size ISO OUT kích thước bộ đệm yêu cầu điểm cuối
	req_count ISO OUT số lượng yêu cầu điểm cuối
	========================================================

Các thuộc tính có giá trị mặc định lành mạnh.

Kiểm tra chức năng UAC1
-------------------------

thiết bị: chạy tiện ích

chủ nhà::

aplay -l # should liệt kê Tiện ích âm thanh USB của chúng tôi

17. Chức năng UAC2
=================

Chức năng này được cung cấp bởi mô-đun usb_f_uac2.ko.

Giao diện configfs dành riêng cho chức năng
------------------------------------

Tên hàm được sử dụng khi tạo thư mục hàm là "uac2".
Hàm uac2 cung cấp các thuộc tính này trong thư mục hàm của nó:

==========================================================================
	mặt nạ kênh chụp c_chmask
	c_srate danh sách tỷ lệ lấy mẫu chụp (được phân tách bằng dấu phẩy)
	c_ssize chụp kích thước mẫu (byte)
	loại đồng bộ hóa chụp c_sync (không đồng bộ/thích ứng)
	c_mute_hiện tại cho phép điều khiển tắt tiếng chụp
	c_volume_ Present bật điều khiển âm lượng chụp
	c_volume_min giá trị tối thiểu của điều khiển âm lượng chụp (tính bằng 1/256 dB)
	c_volume_max giá trị tối đa của điều khiển âm lượng chụp (tính bằng 1/256 dB)
	c_volume_res độ phân giải điều khiển âm lượng chụp (tính bằng 1/256 dB)
	c_hs_bint chụp bInterval cho HS/SS (1-4: cố định, 0: tự động)
	fb_max băng thông bổ sung tối đa ở chế độ không đồng bộ
	mặt nạ kênh phát lại p_chmask
	danh sách p_srate tốc độ lấy mẫu phát lại (được phân tách bằng dấu phẩy)
	kích thước mẫu phát lại p_ssize (byte)
	bật điều khiển tắt tiếng phát lại p_mute_hiện tại
	bật điều khiển âm lượng phát lại p_volume_hiện tại
	Giá trị tối thiểu của điều khiển âm lượng phát lại p_volume_min (tính bằng 1/256 dB)
	Giá trị tối đa của điều khiển âm lượng phát lại p_volume_max (tính bằng 1/256 dB)
	độ phân giải điều khiển âm lượng phát lại p_volume_res (tính bằng 1/256 dB)
	Phát lại p_hs_bint bInterval cho HS/SS (1-4: cố định, 0: tự động)
	req_number số lượng yêu cầu được phân bổ trước cho cả hai lần chụp
	                 và phát lại
	function_name tên giao diện
	Tên điều khiển cấu trúc liên kết if_ctrl_name
	clksrc_in_name nhập tên đồng hồ
	clksrc_out_name tên đồng hồ đầu ra
	tên thiết bị đầu cuối đầu vào phát lại p_it_name
	p_it_ch_name phát lại tên kênh đầu tiên
	tên thiết bị đầu cuối đầu ra phát lại p_ot_name
	tên đơn vị chức năng phát lại p_fu_vol_name
	c_it_name chụp tên thiết bị đầu cuối đầu vào
	c_it_ch_name ghi lại tên kênh đầu tiên
	c_ot_name chụp tên thiết bị đầu cuối đầu ra
	c_fu_vol_name nắm bắt tên đơn vị chức năng
	Mã c_terminal_type của loại thiết bị đầu cuối chụp
	mã p_terminal_type của loại thiết bị đầu cuối phát lại
	==========================================================================

Các thuộc tính có giá trị mặc định lành mạnh.

Kiểm tra chức năng UAC2
-------------------------

thiết bị: chạy tiện ích
máy chủ: aplay -l # should liệt kê Tiện ích âm thanh USB của chúng tôi

Chức năng này không yêu cầu hỗ trợ phần cứng thực sự, nó chỉ
gửi một luồng dữ liệu âm thanh đến/từ máy chủ. để
thực sự nghe thấy điều gì đó ở phía thiết bị, một lệnh tương tự
cái này phải được sử dụng ở phía thiết bị ::

$ arecord -f dat -t wav -D hw:2,0 | aplay -D hw:0,0 &

ví dụ.::

$ arecord -f dat -t wav -D hw:CARD=UAC2Gadget,DEV=0 | \
	  aplay -D mặc định:CARD=OdroidU3

18. Chức năng UVC
================

Chức năng này được cung cấp bởi mô-đun usb_f_uvc.ko.

Giao diện configfs dành riêng cho chức năng
------------------------------------

Tên hàm được sử dụng khi tạo thư mục hàm là "uvc".
Hàm uvc cung cấp các thuộc tính này trong thư mục hàm của nó:

========================================================================
	khoảng streaming_interval cho điểm cuối thăm dò để truyền dữ liệu
	streaming_maxburst bMaxBurst cho bộ mô tả đồng hành siêu tốc độ
	streaming_maxpacket kích thước gói tối đa mà điểm cuối này có khả năng
			    gửi hoặc nhận khi cấu hình này được
			    đã chọn
	function_name tên giao diện
	========================================================================

Ngoài ra còn có các thư mục con "điều khiển" và "truyền phát", mỗi thư mục chứa
một số thư mục con của chúng. Có một số giá trị mặc định hợp lý được cung cấp, nhưng
người dùng phải cung cấp những thông tin sau:

============================================================================
	tiêu đề điều khiển tạo trong control/header, liên kết từ control/class/fs
			   và/hoặc điều khiển/lớp/ss
	tiêu đề phát trực tuyến tạo trong phát trực tuyến/tiêu đề, liên kết từ
			   streaming/class/fs và/hoặc streaming/class/hs và/hoặc
			   phát trực tuyến/lớp/ss
	mô tả định dạng tạo trong streaming/mjpeg và/hoặc
			   truyền phát/không nén
	mô tả khung tạo trong streaming/mjpeg/<format> và/hoặc trong
			   truyền trực tuyến/không nén/<format>
	============================================================================

Mỗi mô tả khung chứa đặc tả khoảng thời gian khung và mỗi
đặc điểm kỹ thuật như vậy bao gồm một số dòng có giá trị khoảng
trong mỗi dòng. Các quy tắc nêu trên được minh họa rõ nhất bằng một ví dụ::

Các hàm # mkdir/uvc.usb0/control/header/h
  Các hàm # cd/uvc.usb0/control/
  # ln -s tiêu đề/h lớp/fs
  # ln -s tiêu đề/h lớp/ss
  # mkdir -p hàm/uvc.usb0/streaming/uncompression/u/360p
  # cat <<EOF > hàm/uvc.usb0/streaming/uncompression/u/360p/dwFrameInterval
  666666
  1000000
  5000000
  EOF
  # cd $GADGET_CONFIGFS_ROOT
  Các hàm # mkdir/uvc.usb0/streaming/header/h
  Các hàm # cd/uvc.usb0/streaming/header/h
  # ln -s ../../uncompression/u
  # cd ../../class/fs
  # ln -s ../../header/h
  # cd ../../class/hs
  # ln -s ../../header/h
  # cd ../../class/ss
  # ln -s ../../header/h


Kiểm tra chức năng UVC
------------------------

thiết bị: chạy tiện ích, modprobe Vivid::

# uvc-gadget -u /dev/video<nút video uvc #> -v /dev/video<nút video sống động #>

nơi uvc-gadget là chương trình này:
	ZZ0000ZZ

với các bản vá này:

ZZ0000ZZ

chủ nhà::

luvcview -f yuv

19. Chức năng PRINTER
====================

Chức năng này được cung cấp bởi mô-đun usb_f_printer.ko.

Giao diện configfs dành riêng cho chức năng
------------------------------------

Tên hàm được sử dụng khi tạo thư mục hàm là "máy in".
Hàm máy in cung cấp các thuộc tính này trong thư mục hàm của nó:

==========================================================
	pnp_string Dữ liệu được truyền tới máy chủ dưới dạng chuỗi pnp
	q_len Số lượng yêu cầu trên mỗi điểm cuối
	==========================================================

Kiểm tra chức năng PRINTER
----------------------------

Thử nghiệm cơ bản nhất:

thiết bị: chạy tiện ích::

# ls -l /thiết bị/ảo/usb_printer_gadget/

sẽ hiển thị g_printer<number>.

Nếu udev đang hoạt động thì /dev/g_printer<number> sẽ tự động xuất hiện.

chủ nhà:

Nếu udev đang hoạt động, thì vd /dev/usb/lp0 sẽ xuất hiện.

máy chủ-> truyền thiết bị:

thiết bị::

# cat /dev/g_printer<số>

chủ nhà::

# cat > /dev/usb/lp0

thiết bị-> truyền máy chủ::

# cat > /dev/g_printer<số>

chủ nhà::

# cat /dev/usb/lp0

Thử nghiệm nâng cao hơn có thể được thực hiện với prn_example
được mô tả trong Tài liệu/usb/gadget_printer.rst.


20. Chức năng UAC1 (thẻ ALSA ảo, sử dụng u_audio API)
========================================================

Chức năng này được cung cấp bởi mô-đun usb_f_uac1.ko.
Nó sẽ tạo một thẻ ALSA ảo và các luồng âm thanh chỉ đơn giản là
chìm vào và bắt nguồn từ nó.

Giao diện configfs dành riêng cho chức năng
------------------------------------

Tên hàm được sử dụng khi tạo thư mục hàm là "uac1".
Hàm uac1 cung cấp các thuộc tính này trong thư mục hàm của nó:

==========================================================================
	mặt nạ kênh chụp c_chmask
	c_srate danh sách tỷ lệ lấy mẫu chụp (được phân tách bằng dấu phẩy)
	c_ssize chụp kích thước mẫu (byte)
	c_mute_hiện tại cho phép điều khiển tắt tiếng chụp
	c_volume_ Present bật điều khiển âm lượng chụp
	c_volume_min giá trị tối thiểu của điều khiển âm lượng chụp (tính bằng 1/256 dB)
	c_volume_max giá trị tối đa của điều khiển âm lượng chụp (tính bằng 1/256 dB)
	c_volume_res độ phân giải điều khiển âm lượng chụp (tính bằng 1/256 dB)
	mặt nạ kênh phát lại p_chmask
	danh sách p_srate tốc độ lấy mẫu phát lại (được phân tách bằng dấu phẩy)
	kích thước mẫu phát lại p_ssize (byte)
	bật điều khiển tắt tiếng phát lại p_mute_hiện tại
	bật điều khiển âm lượng phát lại p_volume_hiện tại
	Giá trị tối thiểu của điều khiển âm lượng phát lại p_volume_min (tính bằng 1/256 dB)
	Giá trị tối đa của điều khiển âm lượng phát lại p_volume_max (tính bằng 1/256 dB)
	độ phân giải điều khiển âm lượng phát lại p_volume_res (tính bằng 1/256 dB)
	req_number số lượng yêu cầu được phân bổ trước cho cả hai lần chụp
	                 và phát lại
	function_name tên giao diện
	tên thiết bị đầu cuối đầu vào phát lại p_it_name
	p_it_ch_name tên kênh phát lại
	tên thiết bị đầu cuối đầu ra phát lại p_ot_name
	p_fu_vol_name tên đơn vị chức năng tắt tiếng/âm lượng phát lại
	c_it_name chụp tên thiết bị đầu cuối đầu vào
	c_it_ch_name chụp tên kênh
	c_ot_name chụp tên thiết bị đầu cuối đầu ra
	c_fu_vol_name tên đơn vị chức năng tắt tiếng/âm lượng chụp
	==========================================================================

Các thuộc tính có giá trị mặc định lành mạnh.

Kiểm tra chức năng UAC1
-------------------------

thiết bị: chạy tiện ích
máy chủ: aplay -l # should liệt kê Tiện ích âm thanh USB của chúng tôi

Chức năng này không yêu cầu hỗ trợ phần cứng thực sự, nó chỉ
gửi một luồng dữ liệu âm thanh đến/từ máy chủ. để
thực sự nghe thấy điều gì đó ở phía thiết bị, một lệnh tương tự
cái này phải được sử dụng ở phía thiết bị ::

$ arecord -f dat -t wav -D hw:2,0 | aplay -D hw:0,0 &

ví dụ.::

$ arecord -f dat -t wav -D hw:CARD=UAC1Gadget,DEV=0 | \
	  aplay -D mặc định:CARD=OdroidU3


21. Chức năng MIDI2
==================

Chức năng này được cung cấp bởi mô-đun usb_f_midi2.ko.
Nó sẽ tạo một thẻ ALSA ảo chứa thiết bị rawmidi UMP
nơi gói UMP được lặp lại. Ngoài ra, một rawmidi kế thừa
thiết bị được tạo ra. UMP rawmidi được liên kết với trình sắp xếp ALSA
khách hàng cũng vậy.

Giao diện configfs dành riêng cho chức năng
------------------------------------

Tên hàm sử dụng khi tạo thư mục hàm là "midi2".
Hàm midi2 cung cấp các thuộc tính này trong thư mục hàm của nó
như thông tin cấp cao nhất của thẻ:

====================================================================
	process_ump Cờ Bool để xử lý tin nhắn luồng UMP (0 hoặc 1)
	static_block Cờ Bool cho khối tĩnh (0 hoặc 1)
	iface_name Chuỗi tên giao diện tùy chọn
	====================================================================

Thư mục chứa thư mục con "ep.0" và thư mục này cung cấp
các thuộc tính cho Điểm cuối UMP (là một cặp Điểm cuối USB MIDI):

====================================================================
	giao thức_caps Khả năng giao thức MIDI;
			1: MIDI 1.0, 2: MIDI 2.0 hoặc 3: cả hai giao thức
	giao thức Giao thức MIDI mặc định (1 hoặc 2)
	ep_name UMP Chuỗi tên điểm cuối
	Product_id Chuỗi ID sản phẩm
	nhà sản xuất Số ID sản xuất (24 bit)
	gia đình Số ID gia đình thiết bị (16 bit)
	model Số ID model thiết bị (16 bit)
	sw_revision Sửa đổi phần mềm (32 bit)
	====================================================================

Mỗi thư mục con Endpoint chứa một thư mục con "block.0", thư mục này
đại diện cho Khối chức năng cho thông tin Khối 0.
Thuộc tính của nó là:

======================================================================
	tên Chức năng Chuỗi tên khối
	hướng Hướng của FB này
				1: đầu vào, 2: đầu ra hoặc 3: hai chiều
	first_group Số nhóm UMP đầu tiên (0-15)
	num_groups Số lượng nhóm trong FB này (1-16)
	midi1_first_group Số nhóm UMP đầu tiên cho MIDI 1.0 (0-15)
	midi1_num_groups Số lượng nhóm cho MIDI 1.0 (0-16)
	ui_hint UI-hint của FB này
				0: không xác định, 1: người nhận, 2: người gửi, 3: cả hai
	midi_ci_version Số phiên bản MIDI-CI được hỗ trợ (8 bit)
	is_midi1 Thiết bị MIDI 1.0 kế thừa (0-2)
				0: Thiết bị MIDI 2.0,
				1: MIDI 1.0 không hạn chế, hoặc
				2: MIDI 1.0 với tốc độ thấp
	sysex8_streams Số luồng SysEx8 tối đa (8 bit)
	cờ Bool hoạt động cho hoạt động FB (0 hoặc 1)
	======================================================================

Nếu cần nhiều Khối chức năng, bạn có thể thêm nhiều Khối chức năng hơn
Chặn bằng cách tạo thư mục con "block.<num>" với tương ứng
Số khối chức năng (1, 2, ....). Các thư mục con FB có thể
cũng bị loại bỏ một cách linh hoạt. Lưu ý rằng số Khối chức năng phải
liên tục.

Tương tự, nếu bạn cần nhiều Điểm cuối UMP, bạn có thể thêm
thêm Điểm cuối bằng cách tạo thư mục con "ep.<num>". Số lượng phải
hãy liên tục.

Để mô phỏng thiết bị MIDI 2.0 cũ không hỗ trợ UMP v1.1, hãy vượt qua 0
tới cờ ZZ0000ZZ. Sau đó, toàn bộ yêu cầu UMP v1.1 sẽ bị bỏ qua.

Kiểm tra chức năng MIDI2
--------------------------

Trên thiết bị: chạy tiện ích và chạy::

$ cat /proc/asound/cards

sẽ hiển thị card âm thanh mới chứa thiết bị MIDI2.

OTOH, trên máy chủ::

$ cat /proc/asound/cards

sẽ hiển thị card âm thanh mới chứa thiết bị MIDI1 hoặc MIDI2,
tùy thuộc vào cấu hình trình điều khiển âm thanh USB.

Trên cả hai, khi trình sắp xếp ALSA được bật trên máy chủ, bạn có thể tìm thấy
Ứng dụng khách UMP MIDI chẳng hạn như "Tiện ích MIDI 2.0".

Vì trình điều khiển chỉ lặp lại dữ liệu nên không cần có
thiết bị chỉ để thử nghiệm.

Để kiểm tra đầu vào MIDI từ tiện ích đến máy chủ (ví dụ: mô phỏng
bàn phím MIDI), bạn có thể gửi luồng MIDI như sau.

Trên tiện ích::

$ kết nối -o
  ....
khách hàng 20: 'Tiện ích MIDI 2.0' [type=kernel,card=1]
      0 'MIDI 2.0'
      1 'Nhóm 1 (I/O tiện ích MIDI 2.0)'
  $ aplaymidi -p 20:1 to_host.mid

Trên máy chủ::

$ kết nối -i
  ....
khách hàng 24: 'Tiện ích MIDI 2.0' [type=kernel,card=2]
      0 'MIDI 2.0'
      1 'Nhóm 1 (I/O tiện ích MIDI 2.0)'
  $ arecordmidi -p 24:1 from_gadget.mid

Nếu bạn có ứng dụng hỗ trợ UMP, bạn có thể sử dụng cổng UMP để
cũng gửi/nhận các gói UMP thô. Ví dụ: chương trình aseqdump
với sự hỗ trợ của UMP có thể nhận từ cổng UMP. Trên máy chủ::

$ aseqdump -u 2 -p 24:1
  Đang chờ dữ liệu. Nhấn Ctrl+C để kết thúc.
  Dữ liệu sự kiện nhóm nguồn
   24:1 Nhóm 0, Thay đổi chương trình 0, Chương trình 0, Chọn ngân hàng 0:0
   24:1 Nhóm 0, Áp suất kênh 0, giá trị 0x80000000

Để kiểm tra đầu ra MIDI từ tiện ích tới máy chủ (ví dụ: mô phỏng
MIDI synth), mọi chuyện sẽ hoàn toàn khác.

Trên tiện ích::

$ arecordmidi -p 20:1 from_host.mid

Trên máy chủ::

$ aplaymidi -p 24:1 to_gadget.mid

Quyền truy cập vào MIDI 1.0 trên altset 0 trên máy chủ được hỗ trợ và nó
được dịch từ/sang các gói UMP trên tiện ích. Nó chỉ bị ràng buộc
Khối chức năng 0.

Chế độ hoạt động hiện tại có thể được quan sát trong phần tử điều khiển ALSA
"Chế độ hoạt động" cho SND_CTL_IFACE_RAWMIDI.  Ví dụ::

nội dung $ amixer -c1
  numid=1,iface=RAWMIDI,name='Chế độ hoạt động'
    ; type=INTEGER,access=r--v----,values=1,min=0,max=2,step=0
    : giá trị=2

trong đó 0 = không sử dụng, 1 = MIDI 1.0 (altset 0), 2 = MIDI 2.0 (altset 1).
Ví dụ trên cho thấy nó đang chạy ở 2, tức là MIDI 2.0.
