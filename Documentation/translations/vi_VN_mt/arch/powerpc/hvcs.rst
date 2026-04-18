.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/hvcs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================================================
Hướng dẫn cài đặt "Hypervisor Virtual Console Server" HVCS IBM
=====================================================================

dành cho nhân Linux 2.6.4+

Bản quyền (C) 2004 IBM Corporation

.. ===========================================================================
.. NOTE:Eight space tabs are the optimum editor setting for reading this file.
.. ===========================================================================


(Các) tác giả: Ryan S. Arnold <rsa@us.ibm.com>

Ngày Tạo: 02/03/2004
Thay đổi lần cuối: ngày 24 tháng 8 năm 2004

.. Table of contents:

	1.  Driver Introduction:
	2.  System Requirements
	3.  Build Options:
		3.1  Built-in:
		3.2  Module:
	4.  Installation:
	5.  Connection:
	6.  Disconnection:
	7.  Configuration:
	8.  Questions & Answers:
	9.  Reporting Bugs:

1. Giới thiệu tài xế:
=======================

Đây là trình điều khiển thiết bị cho Máy chủ bảng điều khiển ảo IBM Hypervisor,
"hvcs".  IBM hvcs cung cấp giao diện trình điều khiển tty để cho phép người dùng Linux
các ứng dụng không gian truy cập vào bảng điều khiển hệ thống của các thiết bị được phân vùng hợp lý
hệ điều hành (Linux và AIX) chạy trên cùng một phân vùng Power5
hệ thống ppc64.  Bảng điều khiển phần cứng vật lý trên mỗi phân vùng không thực tế
trên phần cứng này để bảng điều khiển hệ thống được trình điều khiển này truy cập bằng cách sử dụng
giao diện phần sụn cho các thiết bị đầu cuối ảo.

2. Yêu cầu hệ thống:
=======================

Trình điều khiển thiết bị này được viết bằng API nhân Linux 2.6.4 và sẽ chỉ
xây dựng và chạy trên kernel của phiên bản này trở lên.

Trình điều khiển này được viết để chỉ hoạt động trên phần cứng IBM Power5 ppc64
mặc dù một số sự cẩn thận đã được thực hiện để trừu tượng hóa phần sụn phụ thuộc vào kiến trúc
cuộc gọi từ mã trình điều khiển.

Sysfs phải được gắn trên hệ thống để người dùng có thể xác định cái nào
số chính và số phụ được liên kết với mỗi máy chủ vty.  Chỉ đường
để gắn sysfs nằm ngoài phạm vi của tài liệu này.

3. Tùy chọn xây dựng:
=================

Trình điều khiển hvcs tự đăng ký làm trình điều khiển tty.  Lớp tty
phân bổ động một khối số chính và số phụ trong một số lượng
được yêu cầu bởi người lái xe đăng ký.  Trình điều khiển hvcs hỏi lớp tty
theo mặc định, 64 số chính/phụ này sẽ được sử dụng cho nút thiết bị hvcs
mục nhập.

Nếu số lượng mục nhập thiết bị mặc định là đủ thì trình điều khiển này có thể
được xây dựng trong hạt nhân.  Nếu không, giá trị mặc định có thể bị ghi đè bằng cách chèn
trình điều khiển dưới dạng mô-đun với các tham số insmod.

3.1 Tích hợp:
-------------

Ví dụ về cấu hình menu sau đây minh họa việc chọn xây dựng cái này
trình điều khiển vào kernel::

Trình điều khiển thiết bị --->
		Thiết bị nhân vật --->
			<*> Hỗ trợ máy chủ bảng điều khiển ảo IBM Hypervisor

Bắt đầu quá trình tạo kernel.

3.2 Mô-đun:
-----------

Ví dụ về cấu hình menu sau đây minh họa việc chọn xây dựng cái này
trình điều khiển dưới dạng mô-đun hạt nhân::

Trình điều khiển thiết bị --->
		Thiết bị nhân vật --->
			<M> Hỗ trợ máy chủ bảng điều khiển ảo IBM Hypervisor

Quá trình tạo sẽ xây dựng các mô-đun hạt nhân sau:

- hvcs.ko
	- hvcserver.ko

Để chèn mô-đun với phân bổ mặc định, hãy thực hiện như sau
các lệnh theo thứ tự chúng xuất hiện::

insmod hvcserver.ko
	insmod hvcs.ko

Mô-đun hvcserver chứa các lệnh gọi chương trình cơ sở cụ thể về kiến trúc và phải
được chèn vào trước, nếu không mô-đun hvcs sẽ không tìm thấy một số
những biểu tượng mà nó mong đợi.

Để ghi đè mặc định, hãy sử dụng tham số insmod như sau (yêu cầu 4
thiết bị tty làm ví dụ)::

insmod hvcs.ko hvcs_parm_num_devs=4

Có thể chỉ định số lượng mục phát triển tối đa trên insmod.
Chúng tôi nghĩ rằng 1024 hiện là số lượng bộ điều hợp máy chủ tối đa khá tốt
cho phép.  Điều này luôn có thể được thay đổi bằng cách sửa đổi hằng số trong
tập tin nguồn trước khi xây dựng.

NOTE: Khoảng thời gian cần thiết để cài đặt trình điều khiển dường như có liên quan
đến số lượng giao diện tty mà trình điều khiển đăng ký yêu cầu.

Để loại bỏ mô-đun trình điều khiển, hãy thực hiện lệnh sau ::

rmmod hvcs.ko

Phương pháp được khuyến nghị để cài đặt hvcs làm mô-đun là sử dụng depmod để
xây dựng tệp module.dep hiện tại trong /lib/modules/ZZ0000ZZ và sau đó
thực hiện::

modprobe hvcs hvcs_parm_num_devs=4

Tệp module.dep chỉ ra rằng hvcserver.ko cần được chèn
trước khi hvcs.ko và modprobe sử dụng tệp này để chèn các mô-đun vào một cách thông minh
đúng thứ tự.

Lệnh modprobe sau đây được sử dụng để loại bỏ hvcs và hvcserver trong
đúng thứ tự::

modprobe -r hvcs

4. Cài đặt:
================

Lớp tty tạo các mục sysfs chứa các mục chính và phụ
số được phân bổ cho trình điều khiển hvcs.  Đoạn mã sau của "cây"
đầu ra của thư mục sysfs hiển thị nơi những con số này được trình bày ::

sys/
	|-- ZZ0002ZZ
	|
	|-- lớp học
	ZZ0006ZZ-- ZZ0003ZZ
	ZZ0007ZZ
	|   ZZ0000ZZ-- nhà phát triển
	ZZ0008ZZ-- hvcs1
	ZZ0009ZZ ZZ0001ZZ-- dev
	ZZ0010ZZ-- hvcs3
	ZZ0011ZZ `-- dev
	ZZ0012ZZ
	ZZ0013ZZ-- ZZ0004ZZ
	|
	|-- ZZ0005ZZ

Đối với các ví dụ trên, kết quả đầu ra sau đây là kết quả của việc thực hiện
mục "dev" trong thư mục hvcs::

Nhà phát triển Pow5:/sys/class/tty/hvcs0/ # cat
	254:0

Nhà phát triển Pow5:/sys/class/tty/hvcs1/ # cat
	254:1

Nhà phát triển Pow5:/sys/class/tty/hvcs2/ # cat
	254:2

Nhà phát triển Pow5:/sys/class/tty/hvcs3/ # cat
	254:3

Đầu ra từ việc đọc thuộc tính "dev" là thiết bị char chính và
các số nhỏ mà lớp tty đã phân bổ cho việc sử dụng trình điều khiển này.  Hầu hết
hệ thống chạy hvcs sẽ có các mục thiết bị được tạo hoặc udev
sẽ tự động làm điều đó.

Với kết quả đầu ra ví dụ ở trên, để tạo mục nhập nút /dev/hvcs* theo cách thủ công
mknod có thể được sử dụng như sau::

mknod /dev/hvcs0 c 254 0
	mknod /dev/hvcs1 c 254 1
	mknod /dev/hvcs2 c 254 2
	mknod /dev/hvcs3 c 254 3

Sử dụng mknod để tạo thủ công các mục nhập thiết bị sẽ làm cho các nút thiết bị này
kiên trì.  Sau khi được tạo, chúng sẽ tồn tại trước trình điều khiển insmod.

Cố gắng kết nối một ứng dụng với /dev/hvcs* trước khi chèn
mô-đun hvcs sẽ dẫn đến thông báo lỗi tương tự như sau ::

"/dev/hvcs*: Không có thiết bị như vậy".

NOTE: Chỉ vì có một nút thiết bị hiện diện không có nghĩa là có
là thiết bị vty-server được cấu hình cho nút đó.

5. Kết nối
=============

Vì trình điều khiển này điều khiển các thiết bị cung cấp giao diện tty nên người dùng có thể
tương tác với các mục nút thiết bị bằng cách sử dụng bất kỳ tương tác tty tiêu chuẩn nào
phương thức (ví dụ: "cat", "dd", "echo").  Tuy nhiên, mục đích của trình điều khiển này là
để cung cấp khả năng tương tác bảng điều khiển thời gian thực với bảng điều khiển của phân vùng Linux,
đòi hỏi phải sử dụng các ứng dụng cung cấp hai chiều,
I/O tương tác với một thiết bị tty.

Các ứng dụng (ví dụ: "minicom" và "screen") hoạt động như trình mô phỏng thiết bị đầu cuối
hoặc thực hiện chuyển đổi trình tự điều khiển loại thiết bị đầu cuối trên dữ liệu đang được
được chuyển qua chúng là NOT được chấp nhận để cung cấp bảng điều khiển tương tác
Tôi/O.  Các chương trình này thường mô phỏng các loại thiết bị đầu cuối lỗi thời (vt100 và
ANSI) và mong đợi dữ liệu gửi đến có dạng một trong những dữ liệu được hỗ trợ này
loại thiết bị đầu cuối nhưng chúng không chuyển đổi hoặc không _đầy đủ_
chuyển đổi, dữ liệu gửi đi thành loại thiết bị đầu cuối của thiết bị đầu cuối được gọi
chúng (mặc dù màn hình đã thử và dường như có thể được định cấu hình bằng
đấu vật nhiều termcap.)

Vì lý do này kermit và cu là hai trong số những ứng dụng được khuyên dùng cho
tương tác với bảng điều khiển Linux thông qua thiết bị hvcs.  Những chương trình này đơn giản
hoạt động như một đường dẫn truyền dữ liệu đến và đi từ thiết bị tty.  Họ không
yêu cầu dữ liệu gửi đến có dạng của một loại thiết bị đầu cuối cụ thể, cũng như không
họ nấu dữ liệu gửi đi đến một loại thiết bị đầu cuối cụ thể.

Để đảm bảo các ứng dụng console hoạt động bình thường, người ta phải thực hiện
chắc chắn rằng sau khi được kết nối với bảng điều khiển /dev/hvcs thì $TERM của bảng điều khiển đó
Biến env được đặt thành loại thiết bị đầu cuối chính xác của trình mô phỏng thiết bị đầu cuối
được sử dụng để khởi chạy ứng dụng I/O tương tác.  Nếu một người đang sử dụng xterm và
kermit để kết nối với /dev/hvcs0 khi có lời nhắc của bảng điều khiển
người ta nên "xuất TERM=xterm" trên bảng điều khiển.  Điều này nói với ncurses
các ứng dụng được gọi từ bảng điều khiển mà chúng sẽ xuất ra
trình tự điều khiển mà xterm có thể hiểu được.

Như một biện pháp phòng ngừa, người dùng hvcs phải luôn "thoát" khỏi
phiên trước khi ngắt kết nối một ứng dụng như kermit khỏi thiết bị
nút.  Nếu điều này không được thực hiện, người dùng tiếp theo kết nối với bảng điều khiển sẽ
tiếp tục sử dụng phiên đăng nhập của người dùng trước đó bao gồm
sử dụng biến $TERM mà người dùng trước đã cung cấp.

Việc thêm và xóa hotplug của bộ điều hợp vty-server ảnh hưởng đến nút /dev/hvcs* nào
được sử dụng để kết nối với từng bộ điều hợp máy chủ vty.  Để xác định xem
Bộ điều hợp vty-server được liên kết với nút/dev/hvcs* nào là một sysfs đặc biệt
thuộc tính đã được thêm vào mỗi mục nhập sysfs vty-server.  Mục nhập này là
được gọi là "chỉ mục" và hiển thị nó cho thấy một số nguyên đề cập đến
/dev/hvcs* để sử dụng để kết nối với thiết bị đó.  Ví dụ như trích dẫn
Thuộc tính chỉ mục của bộ điều hợp máy chủ vty 30000004 hiển thị như sau ::

Pow5:/sys/bus/vio/drivers/hvcs/30000004 Chỉ mục # cat
	2

Chỉ số '2' này có nghĩa là để kết nối với bộ chuyển đổi vty-server
30000004 người dùng nên tương tác với /dev/hvcs2.

Cần lưu ý rằng do khả năng I/O cắm nóng của hệ thống
hệ thống mục /dev/hvcs* tương tác với một máy chủ vty cụ thể
bộ điều hợp không được đảm bảo giữ nguyên trong các lần khởi động lại hệ thống.  Nhìn kìa
trong phần Hỏi & Đáp để biết thêm về vấn đề này.

6. Ngắt kết nối
================

Là một tính năng bảo mật để ngăn chặn việc gửi dữ liệu cũ đến một
nhắm mục tiêu ngoài ý muốn, phần sụn hệ thống Power5 sẽ vô hiệu hóa việc tìm nạp dữ liệu
và loại bỏ dữ liệu đó khi có kết nối giữa vty-server và vty
bị cắt đứt.  Ví dụ: khi vty-server bị ngắt kết nối ngay lập tức
từ đầu ra dữ liệu của vty tới vty mà bộ điều hợp vty có thể không có
đủ thời gian kể từ khi nó nhận được dữ liệu bị gián đoạn và khi
kết nối đã bị cắt để tìm nạp dữ liệu từ phần sụn trước khi quá trình tìm nạp hoàn tất
bị vô hiệu hóa bởi firmware.

Khi hvcs đang được sử dụng để phục vụ bảng điều khiển, hành vi này không phải là vấn đề lớn
vì bộ điều hợp vẫn được kết nối trong một khoảng thời gian dài sau
gần như tất cả dữ liệu ghi.  Khi hvcs đang được sử dụng làm ống dẫn tty tới đường hầm
dữ liệu giữa hai phân vùng [xem phần Hỏi & Đáp bên dưới] đây là một vấn đề lớn
bởi vì hành vi tiêu chuẩn của Linux khi truyền hoặc truyền dữ liệu vào thiết bị
là mở tty, gửi dữ liệu và sau đó đóng tty.  Nếu trình điều khiển này
kết thúc thủ công các kết nối máy chủ vty khi đóng tty, thao tác này sẽ đóng
kết nối vty-server và vty trước khi vty mục tiêu có cơ hội
lấy dữ liệu.

Ngoài ra, chỉ ngắt kết nối vty-server và vty khi xóa mô-đun hoặc
việc loại bỏ bộ điều hợp là không thực tế vì các máy chủ vty khác ở các nơi khác
các phân vùng có thể yêu cầu sử dụng vty đích bất cứ lúc nào.

Do hạn chế hành vi này, việc ngắt kết nối máy chủ vty khỏi
vty được kết nối là một quy trình thủ công bằng cách sử dụng ghi vào thuộc tính sysfs
mặt khác, được nêu bên dưới, kết nối máy chủ vty ban đầu với
vty được thiết lập tự động bởi trình điều khiển này.  Máy chủ vty thủ công
kết nối không bao giờ được yêu cầu.

Để chấm dứt kết nối giữa vty-server và vty,
Thuộc tính sysfs "vterm_state" trong mỗi mục nhập sysfs của vty-server được sử dụng.
Đọc thuộc tính này sẽ hiển thị trạng thái kết nối hiện tại của
bộ điều hợp máy chủ vty.  Số 0 có nghĩa là máy chủ vty không được kết nối với
vty.  Một chỉ ra rằng một kết nối đang hoạt động.

Viết '0' (không) vào thuộc tính vterm_state sẽ ngắt kết nối VTERM
kết nối giữa vty-server và vty ONLY đích nếu vterm_state
trước đó đã đọc '1'.  Lệnh ghi sẽ bị bỏ qua nếu vterm_state
đọc '0' hoặc nếu bất kỳ giá trị nào khác '0' được ghi vào vterm_state
thuộc tính.  Ví dụ sau đây sẽ hiển thị phương pháp được sử dụng để xác minh
trạng thái kết nối vty-server và ngắt kết nối vty-server ::

Pow5:/sys/bus/vio/drivers/hvcs/30000004 # cat vterm_state
	1

Pow5:/sys/bus/vio/drivers/hvcs/30000004 # echo 0 > vterm_state

Pow5:/sys/bus/vio/drivers/hvcs/30000004 # cat vterm_state
	0

Tất cả các kết nối vty-server sẽ tự động bị chấm dứt khi thiết bị
hotplug được gỡ bỏ và khi mô-đun được gỡ bỏ.

7. Cấu hình
================

Mỗi vty-server có một mục sysfs trong thư mục /sys/devices/vio.
được liên kết tượng trưng trong một số thư mục cây sysfs khác, đặc biệt là dưới
mục nhập trình điều khiển hvcs, trông giống như ví dụ sau::

Pow5:/sys/bus/vio/drivers/hvcs # ls
	.  .. 30000003 30000004 quét lại

Theo thiết kế, chương trình cơ sở sẽ thông báo cho trình điều khiển hvcs về vòng đời của máy chủ vty và
loại bỏ vty đối tác nhưng không thêm vty đối tác.  Kể từ HMC
Quản trị viên cấp cao có thể thêm thông tin đối tác một cách linh hoạt mà chúng tôi đã cung cấp cho hvcs
thư mục trình điều khiển sysfs với thuộc tính cập nhật "quét lại" sẽ truy vấn
chương trình cơ sở và cập nhật thông tin đối tác cho tất cả các máy chủ vty này
tài xế quản lý.  Viết '1' vào thuộc tính sẽ kích hoạt cập nhật.  Một
ví dụ rõ ràng sau:

Pow5:/sys/bus/vio/drivers/hvcs # echo 1 > quét lại

Đọc thuộc tính sẽ cho biết trạng thái '1' hoặc '0'.  Một cái chỉ ra
rằng một bản cập nhật đang được xử lý.  Số 0 cho biết có bản cập nhật
đã hoàn thành hoặc chưa bao giờ được thực hiện.

Các mục Vty-server trong thư mục này là một đơn vị duy nhất phân vùng 32 bit
địa chỉ được tạo bởi phần sụn.  Một ví dụ về mục nhập sysfs vty-server
trông giống như sau::

Pow5:/sys/bus/vio/drivers/hvcs/30000004 # ls
	.   current_vty tên devspec đối tác_vtys
	..  index         partner_clcs  vterm_state

Theo mặc định, mỗi mục nhập được cung cấp một thuộc tính "tên".  Đọc
Thuộc tính "name" sẽ tiết lộ loại thiết bị như sau
ví dụ::

Pow5:/sys/bus/vio/drivers/hvcs/30000003 Tên # cat
	máy chủ vty

Theo mặc định, mỗi mục nhập cũng được cung cấp một thuộc tính "devspec"
hiển thị thông số kỹ thuật đầy đủ của thiết bị khi đọc, như được hiển thị trong phần sau
ví dụ::

Pow5:/sys/bus/vio/drivers/hvcs/30000004 # cat devspec
	/vdevice/vty-server@30000004

Mỗi thư mục sysfs vty-server được cung cấp hai thuộc tính chỉ đọc
cung cấp danh sách dữ liệu vty đối tác được phân tích cú pháp dễ dàng: "partner_vtys" và
"partner_clcs"::

Pow5:/sys/bus/vio/drivers/hvcs/30000004 # cat đối tác_vtys
	30000000
	30000001
	30000002
	30000000
	30000000

Pow5:/sys/bus/vio/drivers/hvcs/30000004 # cat đối tác_clcs
	U5112.428.103048A-V3-C0
	U5112.428.103048A-V3-C2
	U5112.428.103048A-V3-C3
	U5112.428.103048A-V4-C0
	U5112.428.103048A-V5-C0

Đọc đối tác_vtys trả về danh sách vtys đối tác.  Địa chỉ đơn vị Vty
việc đánh số chỉ là duy nhất cho mỗi phân vùng nên các mục sẽ thường xuyên lặp lại.

Việc đọc đối tác_clcs sẽ trả về danh sách "mã vị trí hội tụ"
bao gồm một số sê-ri hệ thống theo sau là "-VZZ0000ZZ' là
số phân vùng đích và "-CZZ0001ZZ' là vị trí của
bộ chuyển đổi.  Đối tác vty đầu tiên tương ứng với mục clc đầu tiên,
đối tác vty thứ hai với mục clc thứ hai, v.v.

Một vty-server chỉ có thể được kết nối với một vty tại một thời điểm.  Mục nhập,
"current_vty" in clc của vty đối tác hiện được chọn khi
đọc.

Current_vty có thể được thay đổi bằng cách viết clc đối tác hợp lệ vào mục nhập
như trong ví dụ sau::

Pow5:/sys/bus/vio/drivers/hvcs/30000004 # echo U5112.428.10304
	8A-V4-C0 > current_vty

Thay đổi current_vty khi máy chủ vty đã được kết nối với vty
không ảnh hưởng đến kết nối hiện tại.  Sự thay đổi có hiệu lực khi
kết nối hiện đang mở được giải phóng.

Thông tin về thuộc tính "vterm_state" đã được đề cập trước đó trên
chương có tựa đề "ngắt kết nối".

8. Hỏi & Đáp:
=======================

Hỏi: Những lo ngại về bảo mật liên quan đến hvcs là gì?

Đáp: Có ba mối lo ngại chính về bảo mật:

1. Người tạo các nút /dev/hvcs* có khả năng hạn chế
	quyền truy cập của các mục thiết bị đối với người dùng hoặc nhóm nhất định.  Nó
	có thể tốt nhất là tạo một đặc quyền nhóm hvcs đặc biệt để cung cấp
	truy cập vào bảng điều khiển hệ thống.

2. Để cung cấp bảo mật mạng khi sử dụng bảng điều khiển
	đề nghị người dùng kết nối với phân vùng lưu trữ bảng điều khiển
	bằng phương pháp bảo mật, chẳng hạn như SSH hoặc ngồi vào bảng điều khiển phần cứng.

3. Đảm bảo thoát khỏi phiên người dùng khi thực hiện xong với bảng điều khiển hoặc
	kết nối vty-server tiếp theo (có thể từ một máy chủ khác
	phân vùng) sẽ trải nghiệm phiên đăng nhập trước đó.

--------------------------------------------------------------------------

Câu hỏi: Làm cách nào để ghép kênh một bảng điều khiển mà tôi lấy qua hvcs để bảng điều khiển khác
mọi người có thể nhìn thấy nó:

Đáp: Bạn có thể sử dụng "màn hình" để kết nối trực tiếp với thiết bị /dev/hvcs* và
thiết lập phiên trên máy của bạn với các đặc quyền của nhóm bảng điều khiển.  Như
được chỉ ra trước đó bởi màn hình mặc định không cung cấp cài đặt termcap
để hầu hết các trình mô phỏng thiết bị đầu cuối cung cấp khả năng chuyển đổi ký tự đầy đủ từ
loại thuật ngữ "màn hình" cho người khác.  Điều này có nghĩa là các chương trình dựa trên lời nguyền có thể
không hiển thị đúng trong các phiên màn hình.

--------------------------------------------------------------------------

Q: Tại sao tất cả các màu đều bị lộn xộn?
Q: Tại sao các nhân vật điều khiển lại hành động kỳ lạ hoặc không hoạt động?
Hỏi: Tại sao đầu ra của bảng điều khiển lại lạ và khó hiểu?

Đáp: Vui lòng xem phần trước về "Kết nối" để thảo luận về cách
các ứng dụng có thể ảnh hưởng đến việc hiển thị các chuỗi điều khiển ký tự.
Ngoài ra, chỉ vì bạn đã đăng nhập vào bảng điều khiển bằng xterm
không có nghĩa là người khác không đăng nhập vào bảng điều khiển bằng bảng điều khiển HMC
(vt320) trước bạn và rời khỏi phiên đăng nhập. Điều tốt nhất nên làm
là xuất TERM sang loại thiết bị đầu cuối của trình mô phỏng thiết bị đầu cuối khi bạn
lấy bảng điều khiển.  Ngoài ra, hãy đảm bảo "thoát" bảng điều khiển trước khi bạn
ngắt kết nối khỏi bảng điều khiển.  Điều này sẽ đảm bảo rằng người dùng tiếp theo sẽ nhận được
bộ loại TERM của riêng họ khi họ đăng nhập.

--------------------------------------------------------------------------

Hỏi: Khi tôi cố gắng kết nối CONNECT với thiết bị hvcs, tôi nhận được:
"Xin lỗi, không thể mở kết nối: /dev/hvcs*"Chuyện gì đang xảy ra vậy?

Trả lời: Một số cơ chế bảng điều khiển Power5 khác có kết nối với vty và
không từ bỏ nó.  Bạn có thể thử buộc ngắt kết nối bảng điều khiển khỏi
HMC bằng cách nhấp chuột phải vào phân vùng rồi chọn "đóng thiết bị đầu cuối".
Nếu không, bạn phải săn lùng những người có quyền điều khiển.  Nó
có thể bạn đã mở bảng điều khiển bằng kermit khác
phiên và quên nó đi.  Vui lòng xem lại các tùy chọn bảng điều khiển cho
Hệ thống Power5 để xác định nhiều cách có thể giữ bảng điều khiển hệ thống.

HOẶC

Đáp: Người dùng khác có thể hiện không có phương thức kết nối nào được gắn vào thiết bị.
/dev/hvcs nhưng vterm_state có thể tiết lộ rằng họ vẫn có
Đã thiết lập kết nối máy chủ vty.  Họ cần giải phóng cái này bằng phương pháp
được nêu trong phần "Ngắt kết nối" để người khác kết nối
tới mục tiêu vty.

HOẶC

Đáp: Hồ sơ người dùng bạn đang sử dụng để thực thi kermit có thể không có
quyền sử dụng thiết bị /dev/hvcs*.

HOẶC

Đáp: Có thể bạn chưa chèn mô-đun hvcs.ko nhưng /dev/hvcs*
mục nhập vẫn tồn tại (trên các hệ thống không có udev).

HOẶC

Trả lời: Không có thiết bị vty-server tương ứng nào ánh xạ tới thiết bị hiện có
mục nhập /dev/hvcs*.

--------------------------------------------------------------------------

Hỏi: Khi tôi cố gắng kết nối CONNECT với thiết bị hvcs, tôi nhận được:
"Xin lỗi, quyền ghi vào thư mục lockfile UUCP bị từ chối."

Đáp: Mục /dev/hvcs* bạn đã chỉ định không tồn tại ở nơi bạn nói nó
phải không?  Có thể bạn chưa chèn mô-đun (trên hệ thống có udev).

--------------------------------------------------------------------------

Hỏi: Nếu tôi đã cài đặt một phân vùng Linux thì tôi có thể sử dụng hvcs trên đó không?
phân vùng để cung cấp bảng điều khiển cho việc cài đặt Linux thứ hai
phân vùng?

Đáp: Có, với điều kiện là bạn được kết nối với thiết bị /dev/hvcs* bằng cách sử dụng
kermit hoặc cu hoặc một số chương trình khác không cung cấp tính năng mô phỏng thiết bị đầu cuối.

--------------------------------------------------------------------------

Hỏi: Tôi có thể kết nối với nhiều bảng điều khiển của phân vùng cùng một lúc bằng cách này không?
tài xế?

Đ: Vâng.  Tất nhiên điều này có nghĩa là phải có nhiều hơn một vty-server
được định cấu hình cho phân vùng này và mỗi phân vùng phải trỏ đến một vty bị ngắt kết nối.

--------------------------------------------------------------------------

Câu hỏi: Trình điều khiển hvcs có hỗ trợ bổ sung thiết bị động (hotplug) không?

Trả lời: Có, nếu bạn đã bật dlpar và hotplug cho hệ thống của mình và nó có
được tích hợp vào kernel, trình điều khiển hvcs được cấu hình linh hoạt
xử lý việc bổ sung các thiết bị mới và loại bỏ các thiết bị không sử dụng.

--------------------------------------------------------------------------

Hỏi: Vì lý do nào đó /dev/hvcs* không ánh xạ tới cùng một bộ chuyển đổi vty-server
sau khi khởi động lại.  Chuyện gì đã xảy ra thế?

Trả lời: Việc gán bộ điều hợp vty-server cho các mục /dev/hvcs* luôn được thực hiện
theo thứ tự các bộ điều hợp được hiển thị.  Do khả năng cắm nóng của
Việc gán trình điều khiển này của các máy chủ vty được thêm vào hotplug có thể ở một dạng khác
thứ tự hơn cách chúng sẽ được hiển thị khi tải mô-đun.  Khởi động lại hoặc
tải lại mô-đun sau khi bổ sung động có thể dẫn đến /dev/hvcs*
và khớp nối vty-server thay đổi nếu bộ điều hợp vty-server được thêm vào
khe cắm giữa hai bộ điều hợp máy chủ vty khác.  Tham khảo phần trên
về cách xác định vty-server nào đi với nút /dev/hvcs* nào.
Gợi ý; hãy xem thuộc tính "index" sysfs cho vty-server.

--------------------------------------------------------------------------

Hỏi: Tôi có thể sử dụng /dev/hvcs* làm đường dẫn tới phân vùng khác và sử dụng tty không?
thiết bị trên phân vùng đó làm đầu kia của đường ống?

Trả lời: Có, trên nền tảng Power5, trình điều khiển hvc_console cung cấp giao diện tty
dành cho các thiết bị /dev/hvc* bổ sung (trong đó /dev/hvc0 rất có thể là bảng điều khiển).
Để có một ống dẫn tty hoạt động giữa hai phân vùng, HMC
Super Admin phải tạo thêm một "serial server" cho mục tiêu
phân vùng có gui HMC sẽ hiển thị dưới dạng /dev/hvc* khi mục tiêu
phân vùng được khởi động lại.

Sau đó, Quản trị viên cấp cao HMC sẽ tạo một "máy khách nối tiếp" bổ sung cho
phân vùng hiện tại và trỏ nó vào phân vùng đích mới được tạo
bộ chuyển đổi "máy chủ nối tiếp" (nhớ khe cắm).  Điều này xuất hiện dưới dạng
thiết bị /dev/hvcs* bổ sung.

Bây giờ một chương trình trên hệ thống đích có thể được cấu hình để đọc hoặc ghi vào
/dev/hvc* và một chương trình khác trên phân vùng hiện tại có thể được cấu hình để
đọc hoặc ghi vào /dev/hvcs*.  Bây giờ bạn có một ống dẫn tty giữa hai
phân vùng.

--------------------------------------------------------------------------

9. Báo cáo lỗi:
==================

Kênh thích hợp để báo cáo lỗi là thông qua hệ điều hành Linux
công ty phân phối đã cung cấp hệ điều hành của bạn hoặc bằng cách đăng các vấn đề lên
Danh sách gửi thư phát triển PowerPC tại:

linuxppc-dev@lists.ozlabs.org

Yêu cầu này nhằm cung cấp một trao đổi công khai được ghi lại và có thể tìm kiếm được
các vấn đề và giải pháp xung quanh trình điều khiển này vì lợi ích của
tất cả người dùng.
