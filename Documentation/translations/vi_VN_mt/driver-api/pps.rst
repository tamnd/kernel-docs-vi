.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/pps.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================
PPS - Xung mỗi giây
========================

Bản quyền (C) 2007 Rodolfo Giometti <giometti@enneenne.com>

Chương trình này là phần mềm miễn phí; bạn có thể phân phối lại nó và/hoặc sửa đổi
nó theo các điều khoản của Giấy phép Công cộng GNU được xuất bản bởi
Tổ chức Phần mềm Tự do; phiên bản 2 của Giấy phép, hoặc
(theo lựa chọn của bạn) bất kỳ phiên bản mới hơn.

Chương trình này được phân phối với hy vọng rằng nó sẽ hữu ích,
nhưng WITHOUT ANY WARRANTY; thậm chí không có sự bảo đảm ngụ ý của
MERCHANTABILITY hoặc FITNESS FOR A PARTICULAR PURPOSE.  Xem
Giấy phép Công cộng GNU để biết thêm chi tiết.



Tổng quan
---------

LinuxPPS cung cấp giao diện lập trình (API) để xác định trong
hệ thống một số nguồn PPS.

PPS có nghĩa là "xung mỗi giây" và nguồn PPS chỉ là một thiết bị
cung cấp tín hiệu có độ chính xác cao mỗi giây để ứng dụng
có thể sử dụng nó để điều chỉnh thời gian đồng hồ hệ thống.

Nguồn PPS có thể được kết nối với cổng nối tiếp (thường là với Cổng dữ liệu
Chân phát hiện sóng mang) hoặc tới cổng song song (ACK-pin) hoặc tới một cổng đặc biệt
GPIO của CPU (đây là trường hợp phổ biến trong các hệ thống nhúng) nhưng trong mỗi
trường hợp khi có xung mới đến, hệ thống phải áp dụng cho nó một dấu thời gian
và ghi lại nó cho vùng người dùng.

Việc sử dụng phổ biến là sự kết hợp của NTPD dưới dạng chương trình người dùng, với
Bộ thu GPS làm nguồn PPS, để có được thời gian treo tường với
đồng bộ hóa dưới mili giây với UTC.


Những cân nhắc về RFC
---------------------

Trong khi triển khai PPS API như RFC 2783 xác định và sử dụng một
CPU GPIO-Pin làm liên kết vật lý với tín hiệu, tôi gặp phải một vấn đề sâu hơn
vấn đề:

Khi khởi động, nó cần một bộ mô tả tệp làm đối số cho hàm
   time_pps_create().

Điều này ngụ ý rằng nguồn có mục /dev/.... Giả định này là
OK cho cổng nối tiếp và song song, nơi bạn có thể làm gì đó
hữu ích bên cạnh (!) việc thu thập dấu thời gian vì nó là trung tâm
nhiệm vụ cho PPS API. Nhưng giả định này không có tác dụng đối với một
mục đích dòng GPIO. Trong trường hợp này, ngay cả chức năng cơ bản liên quan đến tập tin
(như read() và write()) hoàn toàn vô nghĩa và không nên
điều kiện tiên quyết để sử dụng PPS API.

Vấn đề có thể được giải quyết một cách đơn giản nếu bạn cho rằng nguồn PPS
không phải lúc nào cũng được kết nối với nguồn dữ liệu GPS.

Vì vậy, các chương trình của bạn nên kiểm tra xem nguồn dữ liệu GPS (cổng nối tiếp có
chẳng hạn) cũng là nguồn PPS và nếu không, họ nên cung cấp
khả năng mở một thiết bị khác dưới dạng nguồn PPS.

Trong LinuxPPS, nguồn PPS chỉ đơn giản là các thiết bị char thường được ánh xạ
vào các tập tin/dev/pps0,/dev/pps1, v.v.


PPS với USB cho các thiết bị nối tiếp
-------------------------------------

Có thể lấy PPS từ USB sang thiết bị nối tiếp. Tuy nhiên,
bạn nên tính đến độ trễ và độ biến động do
ngăn xếp USB. Người dùng đã báo cáo sự mất ổn định của đồng hồ khoảng +-1ms khi
được đồng bộ hóa với PPS thông qua USB. Với USB 2.0, độ giật có thể giảm
xuống mức 125 micro giây.

Điều này có thể phù hợp để đồng bộ hóa máy chủ thời gian với NTP vì
về việc lấy mẫu và thuật toán của nó.

Nếu thiết bị của bạn không báo cáo PPS, bạn có thể kiểm tra xem tính năng này có
được hỗ trợ bởi trình điều khiển của nó. Hầu hết thời gian, bạn chỉ cần thêm cuộc gọi
sang usb_serial_handle_dcd_change sau khi kiểm tra trạng thái DCD (xem
ví dụ ch341 và pl2303).


Ví dụ mã hóa
--------------

Để đăng ký nguồn PPS vào kernel, bạn nên xác định cấu trúc
pps_source_info như sau::

cấu trúc tĩnh pps_source_info pps_ktimer_info = {
	    .name = "ktimer",
	    .path = "",
	    .chế độ = PPS_CAPTUREASSERT ZZ0000ZZ
			    PPS_ECHOASSERT |
			    PPS_CANWAIT | PPS_TSFMT_TSPEC,
	    .echo = pps_ktimer_echo,
	    .chủ sở hữu = THIS_MODULE,
    };

và sau đó gọi hàm pps_register_source() trong
trình khởi tạo như sau::

nguồn = pps_register_source(&pps_ktimer_info,
			PPS_CAPTUREASSERT | PPS_OFFSETASSERT);

Nguyên mẫu pps_register_source() là::

int pps_register_source(struct pps_source_info *thông tin, int default_params)

trong đó "thông tin" là một con trỏ tới một cấu trúc mô tả một đối tượng cụ thể
Nguồn PPS, "default_params" cho hệ thống biết giá trị mặc định ban đầu
các thông số cho thiết bị phải có (rõ ràng là các thông số này
phải là tập hợp con của những cái được xác định trong cấu trúc
pps_source_info mô tả khả năng của trình điều khiển).

Khi bạn đã đăng ký nguồn PPS mới vào hệ thống, bạn có thể
báo hiệu một sự kiện khẳng định (ví dụ như trong thủ tục xử lý ngắt)
chỉ sử dụng ::

pps_event(nguồn, &ts, PPS_CAPTUREASSERT, ptr)

trong đó "ts" là dấu thời gian của sự kiện.

Chức năng tương tự cũng có thể chạy chức năng echo được xác định
(pps_ktimer_echo(), chuyển tới nó con trỏ "ptr") nếu người dùng
đã yêu cầu điều đó... vv..

Vui lòng xem tệp driver/pps/clients/pps-ktimer.c để biết mã ví dụ.


Hỗ trợ SYSFS
-------------

Nếu hệ thống tập tin SYSFS được kích hoạt trong kernel thì nó sẽ cung cấp một lớp mới ::

$ ls /sys/class/pps/
   pps0/ pps1/ pps2/

Mỗi thư mục là ID của nguồn PPS được xác định trong hệ thống và
bên trong bạn tìm thấy một số tập tin::

$ ls -F /sys/class/pps/pps0/
   khẳng định hệ thống con đường dẫn chế độ dev @
   rõ ràng tên echo sức mạnh/sự kiện


Bên trong mỗi tệp "xác nhận" và "xóa", bạn có thể tìm thấy dấu thời gian và
số thứ tự::

$ cat /sys/class/pps/pps0/assert
   1170026870.983207967#8

Trong đó trước "#" là dấu thời gian tính bằng giây; sau đó là
số thứ tự. Các tập tin khác là:

* echo: báo cáo nguồn PPS có chức năng echo hay không;

* chế độ: báo cáo các chế độ hoạt động PPS có sẵn;

* tên: báo cáo tên nguồn PPS;

* đường dẫn: báo cáo đường dẫn thiết bị của nguồn PPS, đó là thiết bị
   Nguồn PPS được kết nối với (nếu nó tồn tại).


Kiểm tra hỗ trợ PPS
-----------------------

Để kiểm tra khả năng hỗ trợ PPS ngay cả khi không có phần cứng cụ thể, bạn có thể sử dụng
trình điều khiển pps-ktimer (xem phần phụ máy khách trong menu cấu hình PPS)
và các công cụ vùng người dùng có sẵn trong gói pps-tools của bản phân phối của bạn,
ZZ0000ZZ hoặc ZZ0001ZZ

Khi bạn đã kích hoạt tính năng biên dịch pps-ktimer, chỉ cần sửa đổi nó (nếu
không được biên dịch tĩnh)::

# modprobe pps-ktimer

và chạy ppstest như sau::

$ ./ppstest /dev/pps1
   đang thử nguồn PPS "/dev/pps1"
   đã tìm thấy nguồn PPS "/dev/pps1"
   được rồi, đã tìm thấy 1 nguồn, giờ hãy bắt đầu tìm nạp dữ liệu...
   nguồn 0 - khẳng định 1186592699.388832443, trình tự: 364 - xóa 0,000000000, trình tự: 0
   nguồn 0 - khẳng định 1186592700.388931295, trình tự: 365 - xóa 0,000000000, trình tự: 0
   nguồn 0 - khẳng định 1186592701.389032765, trình tự: 366 - xóa 0,000000000, trình tự: 0

Xin lưu ý rằng để biên dịch các chương trình vùng người dùng, bạn cần có tệp timepps.h.
Tính năng này có sẵn trong kho lưu trữ pps-tools được đề cập ở trên.


Máy phát điện
-------------

Đôi khi người ta không chỉ cần có khả năng bắt được tín hiệu PPS mà còn có thể tạo ra
họ cũng vậy. Ví dụ: chạy mô phỏng phân tán, yêu cầu
đồng hồ của máy tính được đồng bộ rất chặt chẽ.

Để làm như vậy lớp pps-gen đã được thêm vào. Máy phát điện PPS có thể
đã đăng ký trong kernel bằng cách xác định cấu trúc pps_gen_source_info là
sau::

cấu trúc const tĩnh pps_gen_source_info pps_gen_dummy_info = {
            .use_system_clock = đúng,
            .get_time = pps_gen_dummy_get_time,
            .enable = pps_gen_dummy_enable,
    };

Trong đó use_system_clock nêu rõ nếu trình tạo sử dụng hệ thống
đồng hồ để tạo ra các xung của nó hoặc chúng đến từ một thiết bị ngoại vi
đồng hồ. Phương thức get_time() được sử dụng để truy vấn thời gian được lưu trữ trong
đồng hồ máy phát điện, trong khi phương thức Enable() được sử dụng để kích hoạt hoặc
vô hiệu hóa việc tạo xung PPS.

Sau đó gọi hàm pps_gen_register_source() trong
Quá trình khởi tạo như sau sẽ tạo một trình tạo mới trong
hệ thống::

pps_gen = pps_gen_register_source(&pps_gen_dummy_info);

Hỗ trợ máy phát điện SYSFS
--------------------------

Nếu hệ thống tập tin SYSFS được kích hoạt trong kernel thì nó sẽ cung cấp một lớp mới ::

$ ls /sys/class/pps-gen/
    pps-gen0/ pps-gen1/ pps-gen2/

Mỗi thư mục là ID của trình tạo PPS được xác định trong hệ thống và
bên trong nó bạn tìm thấy một số tập tin::

$ ls -F /sys/class/pps-gen/pps-gen0/
    dev kích hoạt tên power/ subsystem@ system time ueevent

Để kích hoạt tính năng tạo tín hiệu PPS, bạn có thể sử dụng lệnh bên dưới ::

$ echo 1 > /sys/class/pps-gen/pps-gen0/enable

Bộ tạo cổng song song
------------------------

Một cách để làm điều này là phát minh ra một số giải pháp phần cứng phức tạp nhưng nó
có thể không cần thiết và không phải chăng. Cách rẻ nhất là tải PPS
trình tạo trên một trong các máy tính (chính) và máy khách PPS trên các máy tính khác
(nô lệ) và sử dụng các loại cáp rất đơn giản để truyền tín hiệu bằng cách sử dụng song song
cổng chẳng hạn.

Sơ đồ chân cáp cổng song song::

tên pin nô lệ chính
	1 STROBE ZZ0000ZZ
	2D0 * |     *
	3 D1 * |     *
	4D2* |     *
	5 D3 * |     *
	6 D4 * |     *
	7 D5 * |     *
	8 D6 * |     *
	9 D7 * |     *
	10 ACK * ------*
	11 BUSY * *
	12 PE * *
	13 SEL * *
	14 AUTOFD * *
	15 ERROR * *
	16 INIT * *
	17 SELIN * *
	18-25 GND ZZ0001ZZ

Xin lưu ý rằng ngắt cổng song song chỉ xảy ra khi chuyển đổi cao->thấp,
vì vậy nó được sử dụng cho cạnh khẳng định PPS. Chỉ có thể xác định cạnh rõ ràng của PPS
sử dụng tính năng bỏ phiếu trong trình xử lý ngắt, điều này thực sự có thể được thực hiện nhiều hơn
chính xác vì độ trễ xử lý ngắt có thể khá lớn và ngẫu nhiên. Vì vậy
Việc triển khai trình tạo PPS của parport hiện tại (mô-đun pps_gen_parport) là
hướng đến việc sử dụng cạnh rõ ràng để đồng bộ hóa thời gian.

Việc thăm dò cạnh rõ ràng được thực hiện với các ngắt bị vô hiệu hóa nên tốt hơn nên chọn
độ trễ giữa xác nhận và cạnh rõ ràng càng nhỏ càng tốt để giảm hệ thống
độ trễ. Nhưng nếu nó quá nhỏ thì nô lệ sẽ không thể chụp được cạnh rõ ràng
chuyển tiếp. Giá trị mặc định là 30us là đủ tốt trong hầu hết các tình huống.
Độ trễ có thể được chọn bằng cách sử dụng tham số mô-đun 'delay' pps_gen_parport.


Bộ tạo tín hiệu I/O định thời PPS của Intel
-------------------------------------------

Intel Timed I/O là thiết bị có độ chính xác cao, có mặt trên Intel 2019 và mới hơn
CPU có thể tạo tín hiệu PPS.

I/O định giờ và thời gian hệ thống đều được điều khiển bởi cùng một đồng hồ phần cứng. tín hiệu
được tạo ra với độ chính xác ~ 20 nano giây. Tín hiệu PPS được tạo
được sử dụng để đồng bộ hóa thiết bị bên ngoài với đồng hồ hệ thống. Ví dụ,
nó có thể được sử dụng để chia sẻ đồng hồ của bạn với thiết bị nhận tín hiệu PPS,
được tạo ra bởi thiết bị I/O định thời gian. Có các chân I/O định giờ chuyên dụng để phân phối
tín hiệu PPS tới thiết bị bên ngoài.

Việc sử dụng I/O định thời của Intel làm trình tạo PPS:

Bắt đầu tạo tín hiệu PPS::

$echo 1 > /sys/class/pps-gen/pps-genx/enable

Dừng tạo tín hiệu PPS::

$echo 0 > /sys/class/pps-gen/pps-genx/enable