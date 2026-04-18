.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/process/debugging/kgdb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================================================
Sử dụng kgdb, kdb và phần bên trong của trình gỡ lỗi kernel
===========================================================

:Tác giả: Jason Wessel

Giới thiệu
============

Hạt nhân có hai giao diện người dùng trình gỡ lỗi khác nhau (kdb và kgdb)
giao diện với lõi gỡ lỗi. Có thể sử dụng một trong hai
giao diện người dùng của trình gỡ lỗi và chuyển đổi linh hoạt giữa chúng nếu bạn
cấu hình kernel đúng cách khi biên dịch và chạy.

Kdb là giao diện kiểu shell đơn giản mà bạn có thể sử dụng trên hệ thống
bảng điều khiển bằng bàn phím hoặc bảng điều khiển nối tiếp. Bạn có thể sử dụng nó để kiểm tra
bộ nhớ, thanh ghi, danh sách tiến trình, dmesg và thậm chí đặt điểm dừng thành
dừng lại ở một vị trí nhất định. Kdb không phải là trình gỡ lỗi cấp nguồn, mặc dù
bạn có thể đặt điểm dừng và thực thi một số điều khiển chạy kernel cơ bản. Kdb
chủ yếu nhằm mục đích thực hiện một số phân tích để hỗ trợ phát triển hoặc
chẩn đoán các vấn đề về hạt nhân. Bạn có thể truy cập một số ký hiệu theo tên trong
các phần dựng sẵn của hạt nhân hoặc trong các mô-đun hạt nhân nếu mã được xây dựng bằng
ZZ0000ZZ.

Kgdb được dự định sẽ được sử dụng làm trình gỡ lỗi cấp nguồn cho Linux
hạt nhân. Nó được sử dụng cùng với gdb để gỡ lỗi nhân Linux. các
kỳ vọng là gdb có thể được sử dụng để "đột nhập" vào kernel để
kiểm tra bộ nhớ, các biến và xem qua thông tin ngăn xếp cuộc gọi
tương tự như cách một nhà phát triển ứng dụng sử dụng gdb để gỡ lỗi một
ứng dụng. Có thể đặt các điểm dừng trong mã hạt nhân và
thực hiện một số bước thực hiện hạn chế.

Cần có hai máy để sử dụng kgdb. Một trong những máy này là máy
máy phát triển và máy còn lại là máy mục tiêu. Hạt nhân để
được gỡ lỗi chạy trên máy mục tiêu. Máy phát triển chạy một
phiên bản của gdb đối với tệp vmlinux chứa các ký hiệu (không phải
một ảnh khởi động như bzImage, zImage, uImage...). Trong gdb nhà phát triển
chỉ định các tham số kết nối và kết nối với kgdb. Loại
kết nối mà nhà phát triển thực hiện với gdb tùy thuộc vào tính khả dụng của
mô-đun I/O kgdb được biên dịch dưới dạng mô-đun hạt nhân tích hợp hoặc có thể tải trong
kernel của máy kiểm tra.

Biên dịch hạt nhân
==================

- Để kích hoạt tính năng biên dịch kdb, trước tiên bạn phải kích hoạt kgdb.

- Các tùy chọn biên dịch kiểm tra kgdb được mô tả trong bộ kiểm tra kgdb
   chương.

Tùy chọn cấu hình hạt nhân cho kgdb
------------------------------

Để kích hoạt ZZ0002ZZ bạn nên xem bên dưới
ZZ0000ZZ và chọn
ZZ0001ZZ.

Mặc dù yêu cầu bạn phải có các ký hiệu trong vmlinux không phải là một yêu cầu khó khăn
tệp, gdb có xu hướng không hữu ích lắm nếu không có dữ liệu tượng trưng, vì vậy bạn
sẽ muốn bật ZZ0001ZZ được gọi là
ZZ0000ZZ trong menu cấu hình.

Chúng tôi khuyên bạn, nhưng không bắt buộc, rằng bạn nên bật
Tùy chọn kernel ZZ0001ZZ được gọi là ZZ0000ZZ trong menu cấu hình. Tùy chọn này chèn mã
vào tệp thực thi được biên dịch để lưu thông tin khung trong sổ đăng ký
hoặc trên ngăn xếp tại các điểm khác nhau cho phép trình gỡ lỗi như gdb
xây dựng chính xác hơn các dấu vết ngăn xếp ngược trong khi gỡ lỗi kernel.

Nếu kiến trúc bạn đang sử dụng hỗ trợ tùy chọn kernel
ZZ0000ZZ, bạn nên cân nhắc việc tắt nó đi. Cái này
tùy chọn này sẽ ngăn chặn việc sử dụng các điểm dừng phần mềm vì nó đánh dấu
một số vùng nhất định trong không gian bộ nhớ của kernel ở dạng chỉ đọc. Nếu kgdb
hỗ trợ nó cho kiến trúc bạn đang sử dụng, bạn có thể sử dụng phần cứng
điểm dừng nếu bạn muốn chạy với ZZ0001ZZ
tùy chọn đã bật, nếu không bạn cần tắt tùy chọn này.

Tiếp theo bạn nên chọn một hoặc nhiều trình điều khiển I/O để kết nối việc gỡ lỗi
máy chủ và mục tiêu được gỡ lỗi. Gỡ lỗi khởi động sớm yêu cầu I/O KGDB
trình điều khiển hỗ trợ gỡ lỗi sớm và trình điều khiển phải được tích hợp sẵn
hạt nhân trực tiếp. Cấu hình trình điều khiển I/O Kgdb diễn ra thông qua
các tham số hạt nhân hoặc mô-đun mà bạn có thể tìm hiểu thêm trong phần
phần mô tả tham số kgdboc.

Dưới đây là tập hợp ví dụ về các ký hiệu ZZ0000ZZ để bật hoặc tắt cho kgdb::

# ZZ0000ZZ chưa được đặt
  CONFIG_FRAME_POINTER=y
  CONFIG_KGDB=y
  CONFIG_KGDB_SERIAL_CONSOLE=y

Tùy chọn cấu hình hạt nhân cho kdb
-----------------------------

Kdb phức tạp hơn một chút so với gdbstub đơn giản nằm ở trên cùng
lõi gỡ lỗi của kernel. Kdb phải triển khai một shell và cũng bổ sung thêm
một số chức năng trợ giúp trong các phần khác của kernel, chịu trách nhiệm
in ra dữ liệu thú vị chẳng hạn như những gì bạn sẽ thấy nếu bạn chạy
ZZ0000ZZ, hoặc ZZ0001ZZ. Để xây dựng kdb vào kernel, bạn làm theo
các bước tương tự như bạn làm với kgdb.

Tùy chọn cấu hình chính cho kdb là ZZ0001ZZ được gọi là
ZZ0000ZZ trong menu cấu hình.
Về lý thuyết, bạn cũng đã chọn một trình điều khiển I/O chẳng hạn như
Giao diện ZZ0002ZZ nếu bạn định sử dụng kdb trên
cổng nối tiếp, khi bạn đang định cấu hình kgdb.

Nếu bạn muốn sử dụng bàn phím kiểu PS/2 với kdb, bạn sẽ chọn
ZZ0001ZZ được gọi là ZZ0000ZZ trong menu cấu hình. Tùy chọn ZZ0002ZZ không
được sử dụng cho mọi thứ trong giao diện gdb tới kgdb. ZZ0003ZZ
tùy chọn chỉ hoạt động với kdb.

Dưới đây là tập hợp ví dụ về các ký hiệu ZZ0000ZZ để bật/tắt kdb ::

# ZZ0000ZZ chưa được đặt
  CONFIG_FRAME_POINTER=y
  CONFIG_KGDB=y
  CONFIG_KGDB_SERIAL_CONSOLE=y
  CONFIG_KGDB_KDB=y
  CONFIG_KDB_KEYBOARD=y

Đối số khởi động trình gỡ lỗi hạt nhân
==============================

Phần này mô tả các tham số kernel thời gian chạy khác nhau ảnh hưởng đến
cấu hình của trình gỡ lỗi kernel. Chương sau bao gồm
sử dụng kdb và kgdb cũng như cung cấp một số ví dụ về
các thông số cấu hình.

Tham số hạt nhân: kgdboc
------------------------

Trình điều khiển kgdboc ban đầu là tên viết tắt của
"kgdb trên bảng điều khiển". Ngày nay nó là cơ chế chính để cấu hình cách thức
để giao tiếp từ gdb đến kgdb cũng như các thiết bị bạn muốn sử dụng
để tương tác với shell kdb.

Đối với kgdb/gdb, kgdboc được thiết kế để hoạt động với một cổng nối tiếp duy nhất. Nó
nhằm mục đích đề cập đến trường hợp bạn muốn sử dụng nối tiếp
console làm bảng điều khiển chính cũng như sử dụng nó để thực hiện kernel
gỡ lỗi. Cũng có thể sử dụng kgdb trên một cổng nối tiếp không
được chỉ định là bảng điều khiển hệ thống. Kgdboc có thể được cấu hình như một kernel
mô-đun tích hợp hoặc có thể tải hạt nhân. Bạn chỉ có thể sử dụng
ZZ0000ZZ và gỡ lỗi sớm nếu bạn xây dựng kgdboc vào kernel như
một tích hợp sẵn.

Tùy chọn, bạn có thể chọn kích hoạt km (Cài đặt chế độ hạt nhân)
hội nhập. Khi bạn sử dụng km với kgdboc và bạn có trình điều khiển video
có móc cài đặt chế độ nguyên tử, có thể vào trình gỡ lỗi
trên bảng điều khiển đồ họa. Khi quá trình thực thi kernel được tiếp tục,
chế độ đồ họa trước đó sẽ được khôi phục. Sự tích hợp này có thể phục vụ như một
công cụ hữu ích để hỗ trợ chẩn đoán sự cố hoặc phân tích bộ nhớ
với kdb trong khi cho phép chạy các ứng dụng bảng điều khiển đồ họa đầy đủ.

đối số kgdboc
~~~~~~~~~~~~~~~~

Cách sử dụng::

kgdboc=[kms][[,]kbd][[,]serial_device][,baud]

Thứ tự được liệt kê ở trên phải được tuân thủ nếu bạn sử dụng bất kỳ tùy chọn nào
cấu hình với nhau.

Chữ viết tắt:

- kms = Cài đặt chế độ hạt nhân

- kbd = Bàn phím

Bạn có thể định cấu hình kgdboc để sử dụng bàn phím và/hoặc thiết bị nối tiếp
tùy thuộc vào việc bạn đang sử dụng kdb và/hoặc kgdb, theo một trong các cách sau
kịch bản. Thứ tự được liệt kê ở trên phải được tuân thủ nếu bạn sử dụng bất kỳ
cấu hình tùy chọn với nhau. Sử dụng km + chỉ gdb nói chung là không
một sự kết hợp hữu ích.

Sử dụng mô-đun có thể tải hoặc tích hợp sẵn
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. Là một kernel tích hợp:

Sử dụng đối số khởi động kernel ::

kgdbc=<tty-device>,[baud]

2. Là mô-đun có thể tải hạt nhân:

Sử dụng lệnh::

modprobe kgdbc kgdboc=<tty-device>,[baud]

Dưới đây là hai ví dụ về cách bạn có thể định dạng chuỗi kgdboc. các
   đầu tiên là dành cho mục tiêu x86 sử dụng cổng nối tiếp đầu tiên. thứ hai
   ví dụ dành cho ARM Versatile AB sử dụng cổng nối tiếp thứ hai.

1. ZZ0000ZZ

2. ZZ0000ZZ

Định cấu hình kgdboc khi chạy với sysfs
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Trong thời gian chạy, bạn có thể bật hoặc tắt kgdboc bằng cách ghi tham số
vào sysfs. Dưới đây là hai ví dụ:

1. Kích hoạt kgdboc trên ttyS0::

echo ttyS0 > /sys/module/kgdboc/tham số/kgdboc

2. Vô hiệu hóa kgdboc::

echo "" > /sys/module/kgdboc/parameters/kgdboc

.. note::

   You do not need to specify the baud if you are configuring the
   console on tty which is already configured or open.

Thêm ví dụ
^^^^^^^^^^^^^

Bạn có thể định cấu hình kgdboc để sử dụng bàn phím và/hoặc thiết bị nối tiếp
tùy thuộc vào việc bạn đang sử dụng kdb và/hoặc kgdb, theo một trong các cách sau
kịch bản.

1. kdb và kgdb chỉ qua cổng nối tiếp::

kgdboc=<serial_device>[,baud]

Ví dụ::

kgdbc=ttyS0,115200

2. kdb và kgdb với bàn phím và cổng nối tiếp::

kgdbc=kbd,<serial_device>[,baud]

Ví dụ::

kgdbc=kbd,ttyS0,115200

3. kdb bằng bàn phím::

kgdboc=kbd

4. kdb với cài đặt chế độ kernel::

kgdbc=km,kbd

5. kdb với cài đặt chế độ kernel và kgdb qua cổng nối tiếp ::

kgdboc=kms,kbd,ttyS0,115200

.. note::

   Kgdboc does not support interrupting the target via the gdb remote
   protocol. You must manually send a `SysRq-G` unless you have a proxy
   that splits console output to a terminal program. A console proxy has a
   separate TCP port for the debugger and a separate TCP port for the
   "human" console. The proxy can take care of sending the `SysRq-G`
   for you.

Khi sử dụng kgdboc không có proxy trình gỡ lỗi, bạn có thể kết nối
trình gỡ lỗi tại một trong hai điểm vào. Nếu một ngoại lệ xảy ra sau khi bạn
đã tải kgdboc, một thông báo sẽ in trên bảng điều khiển cho biết nó đã được tải
đang chờ trình gỡ lỗi. Trong trường hợp này bạn ngắt kết nối thiết bị đầu cuối của bạn
chương trình và sau đó kết nối trình gỡ lỗi vào vị trí của nó. Nếu bạn muốn
làm gián đoạn hệ thống đích và buộc phải tham gia phiên gỡ lỗi mà bạn có
để tạo ra một chuỗi ZZ0000ZZ rồi gõ chữ cái ZZ0001ZZ. Sau đó bạn
ngắt kết nối phiên cuối và kết nối gdb. Lựa chọn của bạn nếu bạn
không thích điều này thì hack gdb để gửi ZZ0002ZZ cho bạn cũng như
trong lần kết nối đầu tiên hoặc sử dụng proxy trình gỡ lỗi cho phép
gdb chưa sửa đổi để thực hiện gỡ lỗi.

Tham số hạt nhân: ZZ0000ZZ
-------------------------------------

Nếu bạn chỉ định tham số kernel ZZ0000ZZ và serial của bạn
trình điều khiển đăng ký bảng điều khiển khởi động hỗ trợ bỏ phiếu (không cần
làm gián đoạn và thực hiện chức năng read() không chặn) kgdb sẽ thử
để làm việc bằng bảng điều khiển khởi động cho đến khi nó có thể chuyển sang bảng điều khiển khởi động thông thường
trình điều khiển tty được chỉ định bởi tham số ZZ0001ZZ.

Thông thường chỉ có một bàn điều khiển khởi động (đặc biệt là bàn điều khiển thực hiện
read()) nên chỉ cần thêm ZZ0000ZZ vào chính nó là được
đủ để thực hiện công việc này. Nếu bạn có nhiều hơn một bảng điều khiển khởi động, bạn
có thể thêm tên boot console để phân biệt. Lưu ý rằng những cái tên đó
được đăng ký thông qua lớp bảng điều khiển khởi động và lớp tty thì không
tương tự cho cùng một cổng.

Chẳng hạn, trên một bảng để nói rõ ràng, bạn có thể làm::

kgdboc_earlycon=qcom_geni kgdoc=ttyMSM0

Nếu bảng điều khiển khởi động duy nhất trên thiết bị là "qcom_geni", bạn có thể đơn giản hóa ::

kgdboc_earlycon kgdbc=ttyMSM0

Tham số hạt nhân: ZZ0000ZZ
------------------------------

Tùy chọn dòng lệnh Kernel ZZ0000ZZ khiến kgdb phải chờ một
kết nối trình gỡ lỗi trong khi khởi động kernel. Bạn chỉ có thể sử dụng cái này
tùy chọn nếu bạn đã biên dịch trình điều khiển I/O kgdb vào kernel và bạn
đã chỉ định cấu hình trình điều khiển I/O làm tùy chọn dòng lệnh kernel.
Tham số kgdbwait phải luôn tuân theo tham số cấu hình
đối với trình điều khiển I/O kgdb trong dòng lệnh kernel, còn lại thì trình điều khiển I/O
sẽ không được cấu hình trước khi yêu cầu kernel sử dụng để chờ.

Hạt nhân sẽ dừng và chờ ngay khi trình điều khiển I/O và
kiến trúc cho phép khi bạn sử dụng tùy chọn này. Nếu bạn xây dựng I/O kgdb
trình điều khiển dưới dạng mô-đun hạt nhân có thể tải kgdbwait sẽ không làm gì cả.

Tham số hạt nhân: ZZ0000ZZ
-----------------------------

Tính năng ZZ0000ZZ cho phép bạn xem các thông báo printk() bên trong gdb
trong khi gdb được kết nối với kernel. Kdb không sử dụng kgdbcon
tính năng.

Kgdb hỗ trợ sử dụng giao thức nối tiếp gdb để gửi tin nhắn bảng điều khiển tới
trình gỡ lỗi khi trình gỡ lỗi được kết nối và chạy. Có hai
cách kích hoạt tính năng này.

1. Kích hoạt bằng tùy chọn dòng lệnh kernel ::

kgdbcon

2. Sử dụng sysfs trước khi định cấu hình trình điều khiển I/O::

echo 1 > /sys/module/debug_core/parameter/kgdb_use_con

.. note::

   If you do this after you configure the kgdb I/O driver, the
   setting will not take effect until the next point the I/O is
   reconfigured.

.. important::

   You cannot use kgdboc + kgdbcon on a tty that is an
   active system console. An example of incorrect usage is::

	console=ttyS0,115200 kgdboc=ttyS0 kgdbcon

Có thể sử dụng tùy chọn này với kgdboc trên một tty không phải là
bảng điều khiển hệ thống.

Tham số thời gian chạy: ZZ0000ZZ
----------------------------------

Tính năng kgdbreboot cho phép bạn thay đổi cách trình gỡ lỗi xử lý
thông báo khởi động lại. Bạn có 3 lựa chọn cho hành vi. các
hành vi mặc định luôn được đặt thành 0.

.. tabularcolumns:: |p{0.4cm}|p{11.5cm}|p{5.6cm}|

.. flat-table::
  :widths: 1 10 8

  * - 1
    - ``echo -1 > /sys/module/debug_core/parameters/kgdbreboot``
    - Ignore the reboot notification entirely.

  * - 2
    - ``echo 0 > /sys/module/debug_core/parameters/kgdbreboot``
    - Send the detach message to any attached debugger client.

  * - 3
    - ``echo 1 > /sys/module/debug_core/parameters/kgdbreboot``
    - Enter the debugger on reboot notify.

Tham số hạt nhân: ZZ0000ZZ
-----------------------------

Nếu kiến trúc bạn đang sử dụng bật KASLR theo mặc định,
bạn nên cân nhắc việc tắt nó đi.  KASLR ngẫu nhiên hóa
địa chỉ ảo nơi hình ảnh hạt nhân được ánh xạ và gây nhầm lẫn
gdb giải quyết địa chỉ của các ký hiệu hạt nhân từ bảng ký hiệu
của vmlinux.

Tham số hạt nhân: ZZ0000ZZ
----------------------------

ZZ0000ZZ được bật theo mặc định và không
hiển thị với menuconfig trên một số kiến ​​trúc (ví dụ: arm64),
bạn có thể chuyển ZZ0001ZZ vào kernel trong trường hợp này.

Sử dụng kdb
=========

Khởi động nhanh cho kdb trên cổng nối tiếp
------------------------------------

Đây là một ví dụ nhanh về cách sử dụng kdb.

1. Cấu hình kgdboc khi khởi động bằng tham số kernel ::

console=ttyS0,115200 kgdboc=ttyS0,115200 nokaslr

HOẶC

Định cấu hình kgdboc sau khi kernel đã khởi động; giả sử bạn đang sử dụng
   bảng điều khiển cổng nối tiếp::

echo ttyS0 > /sys/module/kgdboc/tham số/kgdboc

2. Nhập trình gỡ lỗi kernel theo cách thủ công hoặc bằng cách đợi lỗi hoặc
   lỗi. Có một số cách để bạn có thể vào trình gỡ lỗi kernel
   bằng tay; tất cả đều liên quan đến việc sử dụng ZZ0001ZZ, có nghĩa là bạn phải có
   đã bật ZZ0000ZZ trong cấu hình kernel của bạn.

- Khi đăng nhập bằng root hoặc với phiên siêu người dùng, bạn có thể chạy ::

echo g > /proc/sysrq-trigger

- Ví dụ sử dụng minicom 2.2

Bấm: ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ

- Khi bạn đã telnet tới một máy chủ đầu cuối hỗ trợ gửi
      một kỳ nghỉ từ xa

Bấm: ZZ0000ZZ

Nhập vào: ZZ0000ZZ

Bấm: ZZ0000ZZ ZZ0001ZZ

3. Từ dấu nhắc kdb, bạn có thể chạy lệnh ZZ0000ZZ để xem toàn bộ
   danh sách các lệnh có sẵn.

Một số lệnh hữu ích trong kdb bao gồm:

============ =======================================================================
   ZZ0000ZZ Hiển thị nơi tải các mô-đun hạt nhân
   ZZ0001ZZ Chỉ hiển thị các tiến trình đang hoạt động
   ZZ0002ZZ Hiển thị tất cả các quy trình
   ZZ0003ZZ Hiển thị thông tin phiên bản kernel và mức sử dụng bộ nhớ
   ZZ0004ZZ Lấy lại dấu vết của quy trình hiện tại bằng cách sử dụng dump_stack()
   ZZ0005ZZ Xem bộ đệm nhật ký hệ thống kernel
   ZZ0006ZZ Tiếp tục hệ thống
   ============ =======================================================================

4. Khi sử dụng xong kdb, bạn cần cân nhắc việc khởi động lại hệ thống
   hoặc sử dụng lệnh ZZ0000ZZ để tiếp tục thực thi kernel bình thường. Nếu bạn
   đã tạm dừng kernel trong một thời gian dài, các ứng dụng
   dựa vào kết nối mạng kịp thời hoặc bất cứ điều gì liên quan đến đồng hồ treo tường thực sự
   thời gian có thể bị ảnh hưởng bất lợi, vì vậy bạn nên cân nhắc điều này
   cân nhắc khi sử dụng trình gỡ lỗi kernel.

Bắt đầu nhanh cho kdb bằng bảng điều khiển được kết nối với bàn phím
------------------------------------------------------

Đây là ví dụ nhanh về cách sử dụng kdb bằng bàn phím.

1. Cấu hình kgdboc khi khởi động bằng tham số kernel ::

kgdboc=kbd

HOẶC

Định cấu hình kgdboc sau khi kernel đã khởi động::

echo kbd > /sys/module/kgdboc/parameters/kgdboc

2. Nhập trình gỡ lỗi kernel theo cách thủ công hoặc bằng cách đợi lỗi hoặc
   lỗi. Có một số cách để bạn có thể vào trình gỡ lỗi kernel
   bằng tay; tất cả đều liên quan đến việc sử dụng ZZ0001ZZ, có nghĩa là bạn phải có
   đã bật ZZ0000ZZ trong cấu hình kernel của bạn.

- Khi đăng nhập bằng root hoặc với phiên siêu người dùng, bạn có thể chạy ::

echo g > /proc/sysrq-trigger

- Ví dụ sử dụng bàn phím laptop:

Nhấn và giữ: ZZ0000ZZ

Nhấn và giữ: ZZ0000ZZ

Nhấn và thả phím có nhãn: ZZ0000ZZ

Phát hành: ZZ0000ZZ

Nhấn và phát hành: ZZ0000ZZ

Phát hành: ZZ0000ZZ

- Ví dụ sử dụng bàn phím PS/2 101 phím

Nhấn và giữ: ZZ0000ZZ

Nhấn và thả phím có nhãn: ZZ0000ZZ

Nhấn và phát hành: ZZ0000ZZ

Phát hành: ZZ0000ZZ

3. Bây giờ hãy nhập lệnh kdb chẳng hạn như ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ hoặc ZZ0003ZZ để
   tiếp tục thực thi kernel.

Sử dụng kgdb/gdb
================

Để sử dụng kgdb bạn phải kích hoạt nó bằng cách chuyển cấu hình
thông tin tới một trong các trình điều khiển I/O kgdb. Nếu bạn không vượt qua bất kỳ
thông tin cấu hình kgdb sẽ không làm gì cả. Kgdb sẽ
chỉ tích cực kết nối với móc bẫy hạt nhân nếu trình điều khiển I/O kgdb được cài đặt
được tải và cấu hình. Nếu bạn hủy định cấu hình trình điều khiển I/O kgdb, kgdb sẽ
hủy đăng ký tất cả các điểm hook kernel.

Tất cả các trình điều khiển I/O kgdb có thể được cấu hình lại trong thời gian chạy, nếu
ZZ0000ZZ và ZZ0001ZZ được kích hoạt bằng cách lặp lại một
chuỗi cấu hình thành ZZ0002ZZ. Người lái xe
có thể được hủy cấu hình bằng cách chuyển một chuỗi trống. Bạn không thể thay đổi
cấu hình trong khi trình gỡ lỗi được đính kèm. Đảm bảo đã tháo
trình gỡ lỗi bằng lệnh ZZ0003ZZ trước khi thử hủy cấu hình một
trình điều khiển I/O kgdb.

Kết nối với gdb với cổng nối tiếp
------------------------------------

1. Cấu hình kgdboc

Định cấu hình kgdboc khi khởi động bằng tham số kernel ::

kgdbc=ttyS0,115200

HOẶC

Định cấu hình kgdboc sau khi kernel đã khởi động::

echo ttyS0 > /sys/module/kgdboc/tham số/kgdboc

2. Dừng thực thi kernel (đột nhập vào trình gỡ lỗi)

Để kết nối với gdb qua kgdboc, trước tiên kernel phải được
   dừng lại. Có một số cách để dừng kernel bao gồm
   sử dụng kgdbwait làm đối số khởi động, thông qua ZZ0000ZZ hoặc chạy
   kernel cho đến khi nó gặp một ngoại lệ trong đó nó chờ trình gỡ lỗi
   đính kèm.

- Khi đăng nhập bằng root hoặc với phiên siêu người dùng, bạn có thể chạy ::

echo g > /proc/sysrq-trigger

- Ví dụ sử dụng minicom 2.2

Bấm: ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ

- Khi bạn đã telnet tới một máy chủ đầu cuối hỗ trợ gửi
      một kỳ nghỉ từ xa

Bấm: ZZ0000ZZ

Nhập vào: ZZ0000ZZ

Bấm: ZZ0000ZZ ZZ0001ZZ

3. Kết nối từ gdb

Ví dụ (sử dụng cổng được kết nối trực tiếp)::

% gdb ./vmlinux
           (gdb) đặt baud nối tiếp 115200
           (gdb) nhắm mục tiêu từ xa/dev/ttyS0


Ví dụ (kgdb đến máy chủ đầu cuối trên cổng TCP 2012)::

% gdb ./vmlinux
           (gdb) nhắm mục tiêu từ xa 192.168.2.2:2012


Sau khi kết nối, bạn có thể gỡ lỗi kernel theo cách bạn gỡ lỗi kernel.
   chương trình ứng dụng.

Nếu bạn gặp vấn đề khi kết nối hoặc có điều gì đó nghiêm trọng xảy ra
   sai trong khi gỡ lỗi, thường thì đó sẽ là trường hợp bạn muốn
   để cho phép gdb chi tiết về thông tin liên lạc mục tiêu của nó. bạn làm
   điều này trước khi phát lệnh ZZ0000ZZ bằng cách nhập vào ::

đặt gỡ lỗi từ xa 1

Hãy nhớ rằng nếu bạn tiếp tục trong gdb và cần "đột nhập" lại, bạn cần
để phát hành một ZZ0002ZZ khác. Thật dễ dàng để tạo một điểm vào đơn giản bằng cách
đặt điểm dừng tại ZZ0000ZZ và sau đó bạn có thể chạy ZZ0001ZZ từ
shell hoặc script để đột nhập vào trình gỡ lỗi.

khả năng tương tác kgdb và kdb
=============================

Có thể chuyển đổi linh hoạt giữa kdb và kgdb. Việc gỡ lỗi
core sẽ ghi nhớ những gì bạn đã sử dụng lần trước và tự động bắt đầu
trong cùng một chế độ.

Chuyển đổi giữa kdb và kgdb
------------------------------

Chuyển từ kgdb sang kdb
~~~~~~~~~~~~~~~~~~~~~~~~~~

Có hai cách để chuyển từ kgdb sang kdb: bạn có thể sử dụng gdb để phát hành
gói bảo trì hoặc bạn có thể gõ lệnh ZZ0000ZZ một cách mù quáng.
Bất cứ khi nào trình gỡ lỗi kernel dừng ở chế độ kgdb, nó sẽ in
tin nhắn ZZ0001ZZ. Điều quan trọng cần lưu ý là bạn có
để gõ đúng trình tự trong một lượt. Bạn không thể gõ phím backspace
hoặc xóa vì kgdb sẽ hiểu đó là một phần của luồng gỡ lỗi.

1. Thay đổi từ kgdb sang kdb bằng cách gõ một cách mù quáng ::

$3#33

2. Đổi từ kgdb sang kdb bằng gdb::

gói bảo trì 3

   .. note::

     Now you must kill gdb. Typically you press `CTRL-Z` and issue
     the command::

giết -9 %

Chuyển từ kdb sang kgdb
~~~~~~~~~~~~~~~~~~~~~~~

Có hai cách để bạn có thể thay đổi từ kdb sang kgdb. Bạn có thể theo cách thủ công
vào chế độ kgdb bằng cách phát lệnh kgdb từ dấu nhắc shell kdb,
hoặc bạn có thể kết nối gdb trong khi dấu nhắc shell kdb đang hoạt động. Kdb
shell tìm kiếm các lệnh đầu tiên điển hình mà gdb sẽ đưa ra với
giao thức từ xa gdb và nếu nó thấy một trong những lệnh đó thì nó
tự động chuyển sang chế độ kgdb.

1. Từ kdb ra lệnh::

kgdb

2. Tại dấu nhắc kdb, ngắt kết nối chương trình đầu cuối và kết nối gdb trong
   vị trí của nó.

Chạy lệnh kdb từ gdb
-----------------------------

Có thể chạy một tập lệnh kdb giới hạn từ gdb, bằng cách sử dụng
lệnh giám sát gdb. Bạn không muốn thực hiện bất kỳ điều khiển chạy nào hoặc
hoạt động điểm dừng, vì nó có thể phá vỡ trạng thái của kernel
trình gỡ lỗi. Bạn nên sử dụng gdb cho điểm dừng và chạy điều khiển
hoạt động nếu bạn đã kết nối gdb. Các lệnh hữu ích hơn để chạy
là những thứ như lsmod, dmesg, ps hoặc có thể là một số bộ nhớ
lệnh thông tin. Để xem tất cả các lệnh kdb, bạn có thể chạy
ZZ0000ZZ.

Ví dụ::

(gdb) giám sát ps
    1 tiến trình nhàn rỗi (trạng thái I) và
    27 quy trình daemon hệ thống ngủ (trạng thái M) bị chặn,
    sử dụng 'ps A' để xem tất cả.
    Tác vụ Addr Pid Parent [*] cpu Lệnh luồng trạng thái

0xc78291d0 1 0 0 0 S 0xc7829404 ban đầu
    0xc7954150 942 1 0 0 S 0xc7954384 gấu thả
    0xc78789c0 944 1 0 0 S 0xc7878bf4 sh
    (gdb)

Bộ thử nghiệm kgdb
===============

Khi kgdb được bật trong cấu hình kernel, bạn cũng có thể chọn bật
tham số cấu hình ZZ0000ZZ. Bật tính năng này sẽ kích hoạt một tính năng đặc biệt
Mô-đun I/O kgdb được thiết kế để kiểm tra các chức năng bên trong của kgdb.

Các bài kiểm tra kgdb chủ yếu nhằm mục đích dành cho các nhà phát triển để kiểm tra kgdb
nội bộ cũng như một công cụ để phát triển kiến trúc kgdb mới
triển khai cụ thể. Những thử nghiệm này không thực sự dành cho người dùng cuối của
Hạt nhân Linux. Nguồn tài liệu chính sẽ là xem xét
tệp ZZ0000ZZ.

Bộ kiểm tra kgdb cũng có thể được cấu hình tại thời điểm biên dịch để chạy
tập hợp các bài kiểm tra cốt lõi bằng cách thiết lập tham số cấu hình kernel
ZZ0000ZZ. Tùy chọn cụ thể này nhằm mục đích tự động
kiểm tra hồi quy và không yêu cầu sửa đổi cấu hình khởi động kernel
lý lẽ. Nếu tính năng này được bật, bộ kiểm tra kgdb có thể bị tắt bằng cách
chỉ định ZZ0001ZZ làm đối số khởi động kernel.

Nội bộ trình gỡ lỗi hạt nhân
=========================

Kiến trúc cụ thể
----------------------

Trình gỡ lỗi kernel được tổ chức thành một số thành phần:

1. Lõi gỡ lỗi

Lõi gỡ lỗi được tìm thấy trong ZZ0000ZZ. Nó
   chứa:

- Trình xử lý ngoại lệ chung của hệ điều hành bao gồm việc đồng bộ hóa
      bộ xử lý ở trạng thái dừng trên hệ thống nhiều CPU.

- API để giao tiếp với trình điều khiển I/O kgdb

- API để thực hiện các cuộc gọi đến việc triển khai kgdb dành riêng cho vòm

- Logic thực hiện việc đọc và ghi bộ nhớ an toàn vào bộ nhớ trong khi
      sử dụng trình gỡ lỗi

- Triển khai đầy đủ các điểm dừng phần mềm trừ khi bị ghi đè
      bởi vòm

- API để gọi giao diện kdb hoặc kgdb để gỡ lỗi
      cốt lõi.

- Các cấu trúc và callback API để thiết lập chế độ hạt nhân nguyên tử.

      .. note:: kgdboc is where the kms callbacks are invoked.

2. triển khai theo kiến ​​trúc cụ thể của kgdb

Việc triển khai này thường được tìm thấy trong ZZ0000ZZ. Như
   một ví dụ, ZZ0001ZZ chứa thông tin chi tiết về
   triển khai điểm dừng CTNH cũng như khởi tạo một cách linh hoạt
   đăng ký và hủy đăng ký trình xử lý bẫy trên kiến trúc này.
   Phần dành riêng cho vòm thực hiện:

- chứa một công cụ bắt bẫy dành riêng cho vòm để gọi
      kgdb_handle_Exception() để bắt đầu kgdb thực hiện công việc của nó

- dịch sang và từ định dạng gói cụ thể của gdb sang struct pt_regs

- Đăng ký và hủy đăng ký bẫy kiến trúc cụ thể
      móc

- Bất kỳ xử lý và dọn dẹp ngoại lệ đặc biệt nào

- Xử lý và dọn dẹp ngoại lệ NMI

- (tùy chọn) Điểm dừng CTNH

3. giao diện gdbstub (còn gọi là kgdb)

Gdbstub nằm ở ZZ0000ZZ. Nó chứa:

- Tất cả logic để thực hiện giao thức nối tiếp gdb

4. giao diện kdb

Trình gỡ lỗi kdb được chia thành một số thành phần.
   Lõi kdb nằm trong kernel/debug/kdb. Có một số
   các chức năng trợ giúp trong một số thành phần kernel khác để làm cho nó
   kdb có thể kiểm tra và báo cáo thông tin về kernel
   không lấy các khóa có thể gây ra bế tắc kernel. Lõi kdb
   thực hiện các chức năng sau.

- Vỏ đơn giản

- Bộ lệnh lõi kdb

- Một đăng ký API để đăng ký các lệnh shell kdb bổ sung.

- Một ví dụ điển hình về mô-đun kdb khép kín là ZZ0000ZZ
         lệnh hủy bỏ bộ đệm ftrace. Xem:
         ZZ0001ZZ

- Để biết ví dụ về cách đăng ký động một lệnh kdb mới
         bạn có thể xây dựng mô-đun hạt nhân kdb_hello.ko từ
         ZZ0000ZZ. Để xây dựng ví dụ này, bạn có thể đặt
         ZZ0001ZZ và ZZ0002ZZ trong kernel của bạn
         config. Sau đó hãy chạy ZZ0003ZZ và lần sau bạn
         nhập shell kdb, bạn có thể chạy lệnh ZZ0004ZZ.

- Việc triển khai kdb_printf() phát ra thông báo trực tiếp
      tới trình điều khiển I/O, bỏ qua nhật ký kernel.

- Quản lý điểm dừng SW/HW cho shell kdb

5. Trình điều khiển I/O kgdb

Mỗi trình điều khiển I/O kgdb phải cung cấp một cách triển khai cho
   sau đây:

- cấu hình thông qua tích hợp hoặc mô-đun

- cấu hình động và các cuộc gọi đăng ký hook kgdb

- giao diện đọc và viết ký tự

- Trình xử lý dọn dẹp để hủy cấu hình từ lõi kgdb

- (tùy chọn) Phương pháp gỡ lỗi sớm

Bất kỳ trình điều khiển I/O kgdb nào cũng phải hoạt động rất chặt chẽ với
   phần cứng và phải thực hiện theo cách không cho phép ngắt
   hoặc thay đổi các phần khác của bối cảnh hệ thống mà không hoàn toàn
   khôi phục chúng. Lõi kgdb sẽ liên tục "thăm dò" I/O kgdb
   trình điều khiển cho các ký tự khi cần nhập liệu. Trình điều khiển I/O được mong đợi
   quay lại ngay nếu không có dữ liệu. Làm như vậy cho phép
   cho khả năng trong tương lai có thể chạm vào phần cứng của cơ quan giám sát theo cách như vậy
   để hệ thống đích không được đặt lại khi chúng được bật.

Nếu bạn có ý định thêm hỗ trợ cụ thể cho kiến trúc kgdb cho một phiên bản mới
kiến trúc, kiến trúc nên xác định ZZ0000ZZ trong
kiến trúc tập tin Kconfig cụ thể. Điều này sẽ kích hoạt kgdb cho
kiến trúc và tại thời điểm đó bạn phải tạo một kiến trúc cụ thể
triển khai kgdb.

Có một số cờ phải được đặt trên mọi kiến trúc trong
Tệp ZZ0000ZZ. Đây là:

-ZZ0000ZZ:
     Kích thước tính bằng byte của tất cả các thanh ghi, sao cho chúng ta
     có thể đảm bảo tất cả chúng sẽ vừa với một gói.

-ZZ0000ZZ:
     Kích thước tính bằng byte của bộ đệm GDB sẽ đọc vào. Điều này phải
     lớn hơn NUMREGBYTES.

-ZZ0000ZZ:
     Đặt thành 1 nếu luôn an toàn khi gọi
     Flush_cache_range hoặc Flush_icache_range. Trên một số kiến trúc,
     các chức năng này có thể không an toàn khi gọi trên SMP vì chúng tôi giữ các chức năng khác
     CPU ở trạng thái chờ.

Ngoài ra còn có các chức năng sau dành cho phần phụ trợ chung, được tìm thấy trong
ZZ0000ZZ, phải được cung cấp bởi kiến trúc cụ thể
phụ trợ trừ khi được đánh dấu là (tùy chọn), trong trường hợp đó là hàm mặc định
có thể được sử dụng nếu kiến trúc không cần cung cấp một thông tin cụ thể
thực hiện.

.. kernel-doc:: include/linux/kgdb.h
   :internal:

nội bộ kgdboc
----------------

kgdboc và uarts
~~~~~~~~~~~~~~~~

Trình điều khiển kgdboc thực sự là một trình điều khiển rất mỏng dựa trên
mức thấp cơ bản đối với trình điều khiển phần cứng có "móc bỏ phiếu" để
mà trình điều khiển tty được đính kèm. Trong quá trình triển khai ban đầu của
kgdboc, serial_core đã được thay đổi để hiển thị móc UART cấp thấp cho
thực hiện đọc và viết ở chế độ thăm dò ý kiến một ký tự đơn trong khi
bối cảnh nguyên tử. Khi kgdb gửi yêu cầu I/O tới trình gỡ lỗi, kgdboc
gọi một lệnh gọi lại trong lõi nối tiếp, từ đó sử dụng lệnh gọi lại trong
trình điều khiển UART.

Khi sử dụng kgdboc với UART, trình điều khiển UART phải triển khai hai
cuộc gọi lại trong cấu trúc uart_ops.
Ví dụ từ ZZ0000ZZ::


#ifdef CONFIG_CONSOLE_POLL
        .poll_get_char = nối tiếp8250_get_poll_char,
        .poll_put_char = serial8250_put_poll_char,
    #endif


Mọi chi tiết triển khai cụ thể xung quanh việc tạo trình điều khiển bỏ phiếu đều sử dụng
ZZ0000ZZ, như được hiển thị ở trên. Hãy nhớ rằng
móc bỏ phiếu phải được thực hiện theo cách mà chúng có thể được
được gọi từ bối cảnh nguyên tử và phải khôi phục trạng thái của UART
chip on return sao cho hệ thống có thể trở lại bình thường khi
trình gỡ lỗi tách ra. Bạn cần hết sức cẩn thận với bất kỳ loại khóa nào
hãy cân nhắc, bởi vì thất bại ở đây rất có thể có nghĩa là phải nhấn nút
nút đặt lại.

kgdboc và bàn phím
~~~~~~~~~~~~~~~~~~~~~~~~

Trình điều khiển kgdboc chứa logic để định cấu hình liên lạc với
bàn phím đi kèm. Cơ sở hạ tầng bàn phím chỉ được biên dịch thành
kernel khi ZZ0000ZZ được đặt trong cấu hình kernel.

Trình điều khiển bàn phím được thăm dò cốt lõi dành cho bàn phím loại PS/2 nằm trong
ZZ0001ZZ. Trình điều khiển này được nối vào lõi gỡ lỗi
khi kgdboc điền vào cuộc gọi lại trong mảng được gọi
ZZ0000ZZ. Kdb_get_kbd_char() là cấp cao nhất
chức năng thăm dò phần cứng cho đầu vào ký tự đơn.

kgdboc và km
~~~~~~~~~~~~~~~~~~

Trình điều khiển kgdboc chứa logic để yêu cầu hiển thị đồ họa
chuyển sang ngữ cảnh văn bản khi bạn đang sử dụng ZZ0000ZZ, được cung cấp
rằng bạn có trình điều khiển video có bảng điều khiển bộ đệm khung và nguyên tử
hỗ trợ cài đặt chế độ kernel.

Mỗi lần nhập trình gỡ lỗi kernel, nó sẽ gọi
kgdboc_pre_exp_handler() từ đó gọi con_debug_enter()
trong lớp bảng điều khiển ảo. Khi tiếp tục thực thi kernel, kernel
trình gỡ lỗi gọi kgdboc_post_exp_handler() và lần lượt gọi
con_debug_leave().



Tín dụng
=======

Những người sau đây đã đóng góp cho tài liệu này:

1. Amit Cải xoăn <amitkale@linsyssoft.com>

2. Tom Rini <trini@kernel.crashing.org>

Vào tháng 3 năm 2008, tài liệu này đã được viết lại hoàn toàn bởi:

- Jason Wessel <jason.wessel@windriver.com>

Vào tháng 1 năm 2010, tài liệu này đã được cập nhật để bao gồm kdb.

- Jason Wessel <jason.wessel@windriver.com>
