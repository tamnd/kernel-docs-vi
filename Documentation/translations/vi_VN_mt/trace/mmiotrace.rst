.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/mmiotrace.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================================
Truy tìm I/O được ánh xạ bộ nhớ trong nhân
===================================


Trang chủ và các liên kết đến các công cụ không gian người dùng tùy chọn:

ZZ0000ZZ

Truy tìm MMIO ban đầu được Intel phát triển vào khoảng năm 2003 để khắc phục Lỗi của họ
Khai thác thử nghiệm tiêm. Vào tháng 12 năm 2006 - tháng 1 năm 2007, sử dụng mã của Intel,
Jeff Muizelaar đã tạo một công cụ để theo dõi quyền truy cập MMIO bằng Nouveau
dự án trong tâm trí. Kể từ đó nhiều người đã đóng góp.

Mliotrace được xây dựng để thiết kế ngược bất kỳ thiết bị IO được ánh xạ bộ nhớ nào có
dự án Nouveau với tư cách là người dùng thực sự đầu tiên. Chỉ kiến trúc x86 và x86_64
được hỗ trợ.

Mmiotrace ngoài cây ban đầu được sửa đổi để đưa vào dòng chính và
khung ftrace của Pekka Paalanen <pq@iki.fi>.


Sự chuẩn bị
-----------

Tính năng Mliotrace được biên dịch bởi tùy chọn CONFIG_MMIOTRACE. Truy tìm là
bị tắt theo mặc định, vì vậy sẽ an toàn khi đặt cài đặt này thành có. Hệ thống SMP là
được hỗ trợ, nhưng việc theo dõi không đáng tin cậy và có thể bỏ lỡ các sự kiện nếu có nhiều hơn một CPU
đang trực tuyến, do đó mmiotrace sẽ ngoại tuyến tất cả trừ một CPU trong thời gian chạy
kích hoạt. Bạn có thể kích hoạt lại CPU bằng tay, nhưng bạn đã được cảnh báo ở đó
không có cách nào để tự động phát hiện xem bạn có bị mất sự kiện do chạy đua CPU hay không.


Cách sử dụng Tham khảo nhanh
---------------------
::

$ mount -t debugfs debugfs/sys/kernel/debug
	$ echo mmiotrace > /sys/kernel/tracing/current_tracer
	$ cat /sys/kernel/tracing/trace_pipe > mydump.txt &
	Bắt đầu X hoặc bất cứ điều gì.
	$ echo "X đã hoạt động" > /sys/kernel/tracing/trace_marker
	$ echo nop > /sys/kernel/tracing/current_tracer
	Kiểm tra các sự kiện bị mất.


Cách sử dụng
-----

Đảm bảo các debugf được gắn vào /sys/kernel/debug.
Nếu không (yêu cầu quyền root)::

$ mount -t debugfs debugfs/sys/kernel/debug

Kiểm tra xem trình điều khiển bạn sắp theo dõi đã được tải chưa.

Kích hoạt mmiotrace (yêu cầu quyền root)::

$ echo mmiotrace > /sys/kernel/tracing/current_tracer

Bắt đầu lưu trữ dấu vết::

$ cat /sys/kernel/tracing/trace_pipe > mydump.txt &

Quá trình 'mèo' sẽ tiếp tục chạy (ngủ) ở chế độ nền.

Tải trình điều khiển bạn muốn theo dõi và sử dụng nó. Mliotrace sẽ chỉ bắt được MMIO
truy cập vào các khu vực được ánh xạ trong khi mmiotrace đang hoạt động.

Trong quá trình theo dõi, bạn có thể đặt nhận xét (điểm đánh dấu) vào dấu vết bằng cách
$ echo "X đã hoạt động" > /sys/kernel/tracing/trace_marker
Điều này giúp dễ dàng xem phần nào của dấu vết (rất lớn) tương ứng với
hành động nào. Bạn nên đặt các điểm đánh dấu mô tả về những gì bạn
làm.

Tắt mmiotrace (yêu cầu quyền root)::

$ echo nop > /sys/kernel/tracing/current_tracer

Quá trình 'mèo' thoát ra. Nếu không, hãy tiêu diệt nó bằng cách ra lệnh 'fg' và
nhấn ctrl+c.

Kiểm tra xem mmiotrace không bị mất các sự kiện do bộ đệm bị đầy. Hoặc::

$ grep -i bị mất mydump.txt

cho bạn biết chính xác có bao nhiêu sự kiện đã bị mất hoặc sử dụng::

$ dmesg

để xem nhật ký kernel của bạn và tìm cảnh báo "mmiotrace đã mất sự kiện". Nếu
sự kiện bị mất, dấu vết không đầy đủ. Bạn nên phóng to bộ đệm và
thử lại. Bộ đệm được mở rộng bằng cách trước tiên xem bộ đệm hiện tại lớn đến mức nào
là::

$ cat /sys/kernel/tracing/buffer_size_kb

cung cấp cho bạn một con số. Khoảng gấp đôi con số này và viết nó trở lại, cho
ví dụ::

$ echo 128000 > /sys/kernel/tracing/buffer_size_kb

Sau đó bắt đầu lại từ đầu.

Nếu bạn đang thực hiện theo dõi cho một dự án trình điều khiển, ví dụ: Nouveau, bạn cũng nên
hãy làm như sau trước khi gửi kết quả của bạn::

$ lspci -vvv > lspci.txt
	$ dmesg > dmesg.txt
	$ tar zcf pciid-nick-mmiotrace.tar.gz mydump.txt lspci.txt dmesg.txt

rồi gửi tệp .tar.gz. Dấu vết nén đáng kể. Thay thế
"pciid" và "nick" kèm theo ID PCI hoặc tên mẫu phần cứng của bạn
đang bị điều tra và biệt danh của bạn.


Mliotrace hoạt động như thế nào
-------------------

Có thể truy cập vào bộ nhớ IO phần cứng bằng cách ánh xạ địa chỉ từ bus PCI bằng
gọi một trong các hàm ioremap_*(). Miotrace được nối vào
__ioremap() và được gọi bất cứ khi nào ánh xạ được tạo. Lập bản đồ là
một sự kiện được ghi vào nhật ký theo dõi. Lưu ý rằng ánh xạ phạm vi ISA
không bị bắt vì ánh xạ luôn tồn tại và được trả về trực tiếp.

Các truy cập MMIO được ghi lại thông qua lỗi trang. Ngay trước khi __ioremap() trả về,
các trang được ánh xạ được đánh dấu là không có. Bất kỳ quyền truy cập nào vào các trang đều gây ra
lỗi. Trình xử lý lỗi trang gọi mmiotrace để xử lý lỗi. Miotrace
đánh dấu trang hiện tại, đặt cờ TF để đạt được bước đơn và thoát khỏi
người xử lý lỗi. Lệnh bị lỗi sẽ được thực thi và bẫy gỡ lỗi được thực hiện
đã vào. Ở đây mmiotrace lại đánh dấu trang này là không có. hướng dẫn
được giải mã để lấy loại hoạt động (đọc/ghi), độ rộng dữ liệu và giá trị
đọc hoặc viết. Chúng được lưu trữ vào nhật ký theo dõi.

Việc đặt trang hiện có trong trình xử lý lỗi trang có điều kiện chạy đua trên SMP
máy móc. Trong một bước, các CPU khác có thể chạy tự do trên trang đó
và các sự kiện có thể bị bỏ lỡ mà không cần thông báo trước. Kích hoạt lại các CPU khác trong
việc truy tìm không được khuyến khích.


Định dạng nhật ký theo dõi
----------------

Nhật ký thô là văn bản và dễ dàng được lọc bằng ví dụ: grep và awk. Một kỷ lục là
một dòng trong nhật ký. Một bản ghi bắt đầu bằng một từ khóa, theo sau là từ khóa-
luận cứ phụ thuộc. Các đối số được phân tách bằng dấu cách hoặc tiếp tục cho đến khi
cuối dòng. Định dạng cho phiên bản 20070824 như sau:

Giải thích Từ khóa Đối số được phân tách bằng dấu cách
---------------------------------------------------------------------------

đọc sự kiện R chiều rộng, dấu thời gian, id bản đồ, vật lý, giá trị, PC, PID
ghi sự kiện W chiều rộng, dấu thời gian, id bản đồ, vật lý, giá trị, PC, PID
ioremap sự kiện MAP dấu thời gian, id bản đồ, vật lý, ảo, độ dài, PC, PID
sự kiện iounmap UNMAP dấu thời gian, id bản đồ, PC, PID
dấu thời gian MARK, văn bản
phiên bản VERSION chuỗi "20070824"
thông tin cho người đọc LSPCI một dòng từ lspci -v
Bản đồ địa chỉ PCI Dữ liệu /proc/bus/pci/thiết bị được phân tách bằng dấu cách PCIDEV
unk. opcode UNKNOWN dấu thời gian, id bản đồ, vật lý, dữ liệu, PC, PID

Dấu thời gian tính bằng giây với số thập phân. Vật lý là địa chỉ bus PCI, ảo
là một địa chỉ ảo kernel. Chiều rộng là chiều rộng dữ liệu tính bằng byte và giá trị là
giá trị dữ liệu. Id bản đồ là số id tùy ý xác định ánh xạ đã được
được sử dụng trong một thao tác. PC là bộ đếm chương trình và PID là id tiến trình. PC là
bằng 0 nếu nó không được ghi lại. PID luôn bằng 0 khi truy tìm các truy cập MMIO
nguồn gốc trong bộ nhớ không gian người dùng chưa được hỗ trợ.

Chẳng hạn, bộ lọc awk sau sẽ vượt qua tất cả mục tiêu ghi 32 bit đó
địa chỉ vật lý trong phạm vi [0xfb73ce40, 0xfb800000]
::

$ awk '/W 4 / { adr=strtonum($5); nếu (adr >= 0xfb73ce40 &&
	adr < 0xfb800000) in; }'


Công cụ dành cho nhà phát triển
--------------------

Các công cụ không gian người dùng bao gồm các tiện ích dành cho:
  - thay thế địa chỉ số và giá trị bằng tên đăng ký phần cứng
  - phát lại nhật ký MMIO, tức là thực hiện lại việc ghi đã ghi


