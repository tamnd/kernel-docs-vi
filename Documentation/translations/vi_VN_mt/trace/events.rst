.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/events.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============
Theo dõi sự kiện
=============

:Tác giả: Theodore Ts'o
:Cập nhật: Lý Trạch Phàm và Tom Zanussi

1. Giới thiệu
===============

Tracepoints (xem Tài liệu/trace/tracepoints.rst) có thể được sử dụng
mà không tạo các mô-đun hạt nhân tùy chỉnh để đăng ký các chức năng thăm dò
sử dụng cơ sở hạ tầng theo dõi sự kiện.

Không phải tất cả các điểm theo dõi đều có thể được truy tìm bằng hệ thống theo dõi sự kiện;
nhà phát triển kernel phải cung cấp các đoạn mã xác định cách thức
thông tin theo dõi được lưu vào bộ đệm theo dõi và cách thức
thông tin truy tìm nên được in.

2. Sử dụng tính năng theo dõi sự kiện
======================

2.1 Qua giao diện 'set_event'
---------------------------------

Các sự kiện có sẵn để theo dõi có thể được tìm thấy trong tệp
/sys/kernel/tracing/available_events.

Để bật một sự kiện cụ thể, chẳng hạn như 'sched_wakeup', chỉ cần lặp lại sự kiện đó
tới /sys/kernel/tracing/set_event. Ví dụ::

# echo sched_wakeup >> /sys/kernel/tracing/set_event

.. Note:: '>>' is necessary, otherwise it will firstly disable all the events.

Để tắt một sự kiện, hãy lặp lại tên sự kiện vào tệp set_event có tiền tố
với một dấu chấm than::

# echo '!sched_wakeup' >> /sys/kernel/tracing/set_event

Để tắt tất cả các sự kiện, hãy lặp lại một dòng trống vào tệp set_event::

# echo > /sys/kernel/tracing/set_event

Để kích hoạt tất cả các sự kiện, hãy echo ZZ0000ZZ hoặc ZZ0001ZZ vào tệp set_event::

# echo ZZ0000ZZ > /sys/kernel/tracing/set_event

Các sự kiện được tổ chức thành các hệ thống con, chẳng hạn như ext4, irq, sched,
v.v. và tên sự kiện đầy đủ trông như thế này: <subsystem>:<event>.  các
tên hệ thống con là tùy chọn, nhưng nó được hiển thị trong available_events
tập tin.  Tất cả các sự kiện trong một hệ thống con có thể được chỉ định thông qua cú pháp
ZZ0000ZZ; ví dụ: để kích hoạt tất cả các sự kiện irq, bạn có thể sử dụng
lệnh::

# echo 'irq:*' > /sys/kernel/tracing/set_event

Tệp set_event cũng có thể được sử dụng để kích hoạt các sự kiện chỉ liên quan đến
một mô-đun cụ thể::

# echo ':mod:<module>' > /sys/kernel/tracing/set_event

Sẽ kích hoạt tất cả các sự kiện trong mô-đun ZZ0000ZZ.  Nếu mô-đun chưa
được tải, chuỗi sẽ được lưu và khi mô-đun khớp với ZZ0001ZZ
được tải thì nó sẽ áp dụng việc kích hoạt các sự kiện sau đó.

Văn bản trước ZZ0000ZZ sẽ được phân tích cú pháp để chỉ định các sự kiện cụ thể mà
mô-đun tạo ra::

# echo '<match>:mod:<module>' > /sys/kernel/tracing/set_event

Ở trên sẽ kích hoạt bất kỳ hệ thống hoặc sự kiện nào phù hợp với ZZ0000ZZ. Nếu
ZZ0001ZZ là ZZ0002ZZ thì nó sẽ khớp với tất cả các sự kiện.

Để chỉ kích hoạt một sự kiện cụ thể trong hệ thống::

# echo '<system>:<event>:mod:<module>' > /sys/kernel/tracing/set_event

Nếu ZZ0000ZZ là ZZ0001ZZ thì nó sẽ khớp với tất cả các sự kiện trong hệ thống
cho một mô-đun nhất định.

2.2 Thông qua nút chuyển đổi 'bật'
---------------------------

Các sự kiện có sẵn cũng được liệt kê trong phân cấp /sys/kernel/tracing/events/
của các thư mục.

Để bật sự kiện 'sched_wakeup'::

# echo 1 > /sys/kernel/tracing/events/sched/sched_wakeup/enable

Để vô hiệu hóa nó::

# echo 0 > /sys/kernel/tracing/events/sched/sched_wakeup/enable

Để kích hoạt tất cả các sự kiện trong hệ thống con được lập lịch::

# echo 1 > /sys/kernel/tracing/events/scheduled/enable

Để kích hoạt tất cả các sự kiện::

# echo 1 > /sys/kernel/tracing/events/enable

Khi đọc một trong các tệp kích hoạt này, có bốn kết quả:

- 0 - tất cả các sự kiện mà tệp này ảnh hưởng đều bị tắt
 - 1 - tất cả các sự kiện mà tệp này ảnh hưởng đều được bật
 - X - có sự kết hợp của các sự kiện được bật và tắt
 - ? - tập tin này không ảnh hưởng đến bất kỳ sự kiện nào

2.3 Tùy chọn khởi động
---------------

Để tạo điều kiện thuận lợi cho việc gỡ lỗi khởi động sớm, hãy sử dụng tùy chọn khởi động ::

trace_event=[danh sách sự kiện]

danh sách sự kiện là danh sách các sự kiện được phân tách bằng dấu phẩy. Xem phần 2.1 để biết sự kiện
định dạng.

3. Xác định điểm theo dõi kích hoạt sự kiện
=======================================

Xem Ví dụ được cung cấp trong samples/trace_events

4. Hình thức sự kiện
================

Mỗi sự kiện theo dõi có một tệp 'định dạng' được liên kết với nó chứa
mô tả của từng trường trong một sự kiện được ghi lại.  Thông tin này có thể
được sử dụng để phân tích luồng dấu vết nhị phân và cũng là nơi để
tìm tên trường có thể được sử dụng trong bộ lọc sự kiện (xem phần 5).

Nó cũng hiển thị chuỗi định dạng sẽ được sử dụng để in
sự kiện ở chế độ văn bản, cùng với tên sự kiện và ID được sử dụng cho
hồ sơ.

Mỗi sự kiện đều có một tập hợp các trường ZZ0000ZZ được liên kết với nó; đây là
các trường có tiền tố ZZ0001ZZ.  Các lĩnh vực khác khác nhau giữa
sự kiện và tương ứng với các trường được xác định trong TRACE_EVENT
định nghĩa cho sự kiện đó.

Mỗi trường trong định dạng có dạng::

field:field-type field-name; bù đắp:N; kích thước:N;

trong đó offset là offset của trường trong bản ghi theo dõi và kích thước
là kích thước của mục dữ liệu, tính bằng byte.

Ví dụ: đây là thông tin được hiển thị cho 'sched_wakeup'
sự kiện::

# cat /sys/kernel/tracing/events/sched/sched_wakeup/format

Tên: sched_wakeup
	Mã số: 60
	định dạng:
		trường:unsigned short common_type;	bù đắp: 0;	kích thước:2;
		trường: char không dấu common_flags;	bù đắp:2;	kích thước: 1;
		trường: char không dấu common_preempt_count;	bù đắp:3;	kích thước: 1;
		trường:int common_pid;	bù đắp:4;	kích thước:4;
		trường:int common_tgid;	bù đắp: 8;	kích thước:4;

trường:char comm[TASK_COMM_LEN];	bù đắp:12;	kích thước:16;
		trường:pid_t pid;	bù đắp:28;	kích thước:4;
		trường:int ưu tiên;	bù đắp:32;	kích thước:4;
		trường:int thành công;	bù đắp:36;	kích thước:4;
		trường:int cpu;	bù đắp:40;	kích thước:4;

print fmt: "task %s:%d [%d] thành công=%d [%03d]", REC->comm, REC->pid,
		   REC->prio, REC->thành công, REC->cpu

Sự kiện này chứa 10 trường, 5 trường chung đầu tiên và 5 trường còn lại
sự kiện cụ thể.  Tất cả các trường cho sự kiện này đều là số, ngoại trừ
'comm' là một chuỗi, một điểm khác biệt quan trọng để lọc sự kiện.

5. Lọc sự kiện
==================

Các sự kiện theo dõi có thể được lọc trong kernel bằng cách liên kết boolean
'lọc biểu thức' với chúng.  Ngay sau khi một sự kiện được đăng nhập
bộ đệm theo dõi, các trường của nó được kiểm tra dựa trên biểu thức lọc
liên quan đến loại sự kiện đó.  Một sự kiện với các giá trị trường
'khớp' bộ lọc sẽ xuất hiện trong đầu ra theo dõi và một sự kiện có
các giá trị không khớp sẽ bị loại bỏ.  Sự kiện không có bộ lọc
được liên kết với nó khớp với mọi thứ và là mặc định khi không
bộ lọc đã được đặt cho một sự kiện.

5.1 Cú pháp biểu thức
---------------------

Một biểu thức lọc bao gồm một hoặc nhiều 'vị ngữ' có thể
được kết hợp bằng cách sử dụng các toán tử logic '&&' và '||'.  Một vị ngữ là
chỉ đơn giản là một mệnh đề so sánh giá trị của một trường chứa trong một
sự kiện được ghi lại có giá trị không đổi và trả về 0 hoặc 1 tùy theo
về việc giá trị trường khớp với (1) hay không khớp (0)::

giá trị toán tử quan hệ tên trường

Dấu ngoặc đơn có thể được sử dụng để cung cấp các nhóm logic tùy ý và
dấu ngoặc kép có thể được sử dụng để ngăn shell diễn giải
các toán tử dưới dạng siêu ký tự shell.

Tên trường có sẵn để sử dụng trong bộ lọc có thể được tìm thấy trong
các tệp 'định dạng' cho các sự kiện theo dõi (xem phần 4).

Các toán tử quan hệ phụ thuộc vào loại trường đang được kiểm tra:

Các toán tử có sẵn cho trường số là:

==, !=, <, <=, >, >=, &

Và đối với các trường chuỗi, chúng là:

==, !=, ~

Toàn cầu (~) chấp nhận ký tự đại diện (\*,?) và các lớp ký tự
([). Ví dụ::

prev_comm ~ "*sh"
  prev_comm ~ "sh*"
  prev_comm ~ "ZZ0000ZZ"
  prev_comm ~ "ba*sh"

Nếu trường là một con trỏ trỏ vào không gian người dùng (ví dụ:
"tên tệp" từ sys_enter_openat), thì bạn phải thêm ".ustring" vào
tên trường::

tên tệp.ustring ~ "mật khẩu"

Vì kernel sẽ phải biết cách lấy lại bộ nhớ mà con trỏ
là từ không gian người dùng.

Bạn có thể chuyển đổi bất kỳ loại dài nào thành địa chỉ hàm và tìm kiếm theo tên hàm ::

call_site.function == security_prepare_creds

Ở trên sẽ lọc khi trường "call_site" rơi vào địa chỉ bên trong
"security_prepare_creds". Tức là nó sẽ so sánh giá trị của "call_site" và
bộ lọc sẽ trả về true nếu nó lớn hơn hoặc bằng điểm bắt đầu của
hàm "security_prepare_creds" và nhỏ hơn phần cuối của hàm đó.

Hậu tố ".function" chỉ có thể được gắn vào các giá trị có kích thước dài và chỉ có thể
được so sánh với "==" hoặc "!=".

Các trường Cpumask hoặc trường vô hướng mã hóa số CPU có thể được lọc bằng cách sử dụng
cpumask do người dùng cung cấp ở định dạng cpulist. Định dạng như sau::

CPUS{$cpulist}

Các toán tử có sẵn để lọc cpumask là:

& (ngã tư), ==, !=

Ví dụ: điều này sẽ lọc các sự kiện có trường .target_cpu của chúng
trong cpumask đã cho::

target_cpu & CPUS{17-42}

5.2 Cài đặt bộ lọc
-------------------

Bộ lọc cho một sự kiện riêng lẻ được đặt bằng cách viết biểu thức lọc
vào tệp 'bộ lọc' cho sự kiện đã cho.

Ví dụ::

# cd /sys/kernel/tracing/events/sched/sched_wakeup
	# echo "common_preempt_count > 4" > bộ lọc

Một ví dụ liên quan hơn một chút ::

# cd /sys/kernel/tracing/events/signal/signal_generate
	# echo "((sig >= 10 && sig < 15) || sig == 17) && comm != bash" > filter

Nếu có lỗi trong biểu thức, bạn sẽ nhận được thông báo 'Không hợp lệ
đối số' khi cài đặt nó và chuỗi bị lỗi cùng với
có thể thấy thông báo lỗi bằng cách nhìn vào bộ lọc, ví dụ:::

# cd /sys/kernel/tracing/events/signal/signal_generate
	# echo "((sig >= 10 && sig < 15) || dsig == 17) && comm != bash" > filter
	-bash: echo: lỗi ghi: Đối số không hợp lệ
	Bộ lọc # cat
	((sig >= 10 && sig < 15) || dsig == 17) && comm != bash
	^
	Parse_error: Không tìm thấy trường

Hiện tại dấu mũ ('^') biểu thị lỗi luôn xuất hiện ở đầu
chuỗi bộ lọc; thông báo lỗi vẫn hữu ích
ngay cả khi không có thông tin vị trí chính xác hơn.

5.2.1 Hạn chế của bộ lọc
------------------------

Nếu bộ lọc được đặt trên con trỏ chuỗi ZZ0000ZZ không trỏ
tới một chuỗi trên bộ đệm vòng, nhưng thay vào đó lại trỏ đến kernel hoặc không gian người dùng
bộ nhớ thì vì lý do an toàn, tối đa 1024 byte nội dung sẽ được
được sao chép vào bộ đệm tạm thời để thực hiện so sánh. Nếu bản sao của bộ nhớ
lỗi (con trỏ trỏ đến bộ nhớ không được truy cập), thì
so sánh chuỗi sẽ được coi là không khớp.

5.3 Xóa bộ lọc
--------------------

Để xóa bộ lọc cho một sự kiện, hãy viết '0' vào bộ lọc của sự kiện
tập tin.

Để xóa bộ lọc cho tất cả các sự kiện trong hệ thống con, hãy viết '0' vào
tập tin bộ lọc của hệ thống con.

5.4 Bộ lọc hệ thống con
---------------------

Để thuận tiện, các bộ lọc cho mọi sự kiện trong hệ thống con có thể được đặt hoặc
được xóa dưới dạng nhóm bằng cách viết biểu thức lọc vào tệp bộ lọc
ở gốc của hệ thống con.  Tuy nhiên, lưu ý rằng nếu một bộ lọc cho bất kỳ
sự kiện trong hệ thống con thiếu trường được chỉ định trong hệ thống con
bộ lọc hoặc nếu bộ lọc không thể được áp dụng vì bất kỳ lý do nào khác,
bộ lọc cho sự kiện đó sẽ giữ lại cài đặt trước đó.  Điều này có thể
dẫn đến sự kết hợp ngoài ý muốn của các bộ lọc có thể dẫn đến
khó hiểu (đối với người dùng có thể nghĩ rằng có các bộ lọc khác nhau trong
effect) đầu ra dấu vết.  Chỉ các bộ lọc chỉ tham chiếu chung
các trường có thể được đảm bảo truyền bá thành công tới tất cả các sự kiện.

Dưới đây là một số ví dụ về bộ lọc hệ thống con cũng minh họa cho
điểm trên:

Xóa bộ lọc trên tất cả các sự kiện trong hệ thống con được lập lịch::

# cd/sys/kernel/tracing/sự kiện/lịch trình
	# echo 0 > bộ lọc
	# cat lịch_switch/bộ lọc
	không có
	# cat lịch_wakeup/bộ lọc
	không có

Đặt bộ lọc chỉ sử dụng các trường chung cho tất cả các sự kiện trong lịch trình
hệ thống con (tất cả các sự kiện đều kết thúc với cùng một bộ lọc)::

# cd/sys/kernel/tracing/sự kiện/lịch trình
	# echo common_pid == 0 > bộ lọc
	# cat lịch_switch/bộ lọc
	common_pid == 0
	# cat lịch_wakeup/bộ lọc
	common_pid == 0

Cố gắng đặt bộ lọc bằng trường không phổ biến cho tất cả các sự kiện trong
hệ thống con được lập lịch (tất cả các sự kiện trừ những sự kiện có trường prev_pid được giữ lại
bộ lọc cũ của họ)::

# cd/sys/kernel/tracing/sự kiện/lịch trình
	# echo prev_pid == 0 > bộ lọc
	# cat lịch_switch/bộ lọc
	trước_pid == 0
	# cat lịch_wakeup/bộ lọc
	common_pid == 0

Lọc 5.5 PID
-----------------

Tệp set_event_pid trong cùng thư mục với thư mục sự kiện hàng đầu
tồn tại, sẽ lọc tất cả các sự kiện khỏi việc truy tìm bất kỳ tác vụ nào không có
PID được liệt kê trong tệp set_event_pid.
::

# cd /sys/kernel/truy tìm
	# echo $$ > set_event_pid
	# echo 1 > sự kiện/kích hoạt

Sẽ chỉ theo dõi các sự kiện cho nhiệm vụ hiện tại.

Để thêm nhiều PID hơn mà không làm mất các PID đã được bao gồm, hãy sử dụng '>>'.
::

# echo 123 244 1 >> set_event_pid


6. Trình kích hoạt sự kiện
=================

Các sự kiện theo dõi có thể được thực hiện để gọi các 'lệnh' kích hoạt có điều kiện
có thể có nhiều dạng khác nhau và được mô tả chi tiết dưới đây;
ví dụ sẽ kích hoạt hoặc vô hiệu hóa các sự kiện theo dõi khác hoặc gọi
dấu vết ngăn xếp bất cứ khi nào sự kiện theo dõi xảy ra.  Bất cứ khi nào một sự kiện theo dõi
với các trình kích hoạt đính kèm được gọi, tập hợp các lệnh kích hoạt
liên quan đến sự kiện đó được gọi.  Bất kỳ trình kích hoạt nào cũng có thể
Ngoài ra còn có bộ lọc sự kiện có cùng dạng như được mô tả trong
phần 5 (Lọc sự kiện) được liên kết với nó - lệnh sẽ chỉ
được gọi nếu sự kiện được gọi vượt qua bộ lọc liên quan.
Nếu không có bộ lọc nào được liên kết với trình kích hoạt, nó sẽ luôn vượt qua.

Trình kích hoạt được thêm vào và xóa khỏi một sự kiện cụ thể bằng cách viết
biểu thức kích hoạt vào tệp 'kích hoạt' cho sự kiện đã cho.

Một sự kiện nhất định có thể có bất kỳ số lượng trình kích hoạt nào được liên kết với nó,
tuân theo bất kỳ hạn chế nào mà các lệnh riêng lẻ có thể có trong đó
quan tâm.

Trình kích hoạt sự kiện được triển khai ở chế độ "mềm", có nghĩa là
bất cứ khi nào một sự kiện theo dõi có một hoặc nhiều trình kích hoạt được liên kết với nó,
sự kiện được kích hoạt ngay cả khi nó không thực sự được kích hoạt, nhưng
bị vô hiệu hóa ở chế độ "mềm".  Nghĩa là, tracepoint sẽ được gọi là,
nhưng sẽ không bị theo dõi, trừ khi nó thực sự được kích hoạt.
Lược đồ này cho phép kích hoạt các trình kích hoạt ngay cả đối với các sự kiện không
được bật và cũng cho phép triển khai bộ lọc sự kiện hiện tại
được sử dụng để kích hoạt lệnh gọi có điều kiện.

Cú pháp của trình kích hoạt sự kiện gần như dựa trên cú pháp của
set_ftrace_filter 'lệnh lọc ftrace' (xem 'Lệnh lọc'
phần Tài liệu/trace/ftrace.rst), nhưng có những phần chính
sự khác biệt và việc triển khai hiện không bị ràng buộc với nó theo bất kỳ cách nào
vậy nên hãy cẩn thận khi đưa ra những khái quát hóa giữa hai điều này.

.. Note::
     Writing into trace_marker (See Documentation/trace/ftrace.rst)
     can also enable triggers that are written into
     /sys/kernel/tracing/events/ftrace/print/trigger

6.1 Cú pháp biểu thức
---------------------

Trình kích hoạt được thêm bằng cách lặp lại lệnh vào tệp 'kích hoạt'::

# echo 'lệnh[:count] [if filter]' > kích hoạt

Trình kích hoạt được loại bỏ bằng cách lặp lại lệnh tương tự nhưng bắt đầu bằng '!'
vào tệp 'kích hoạt'::

# echo '!command[:count] [if filter]' > kích hoạt

Phần [if filter] không được sử dụng trong các lệnh khớp khi xóa, vì vậy
bỏ nó đi trong dấu '!' lệnh sẽ thực hiện điều tương tự như
có nó trong.

Cú pháp bộ lọc giống như cú pháp được mô tả trong phần 'Sự kiện
phần lọc' ở trên.

Để dễ sử dụng, việc ghi vào tệp kích hoạt bằng cách sử dụng '>' hiện chỉ
thêm hoặc xóa một trình kích hoạt duy nhất và không có hỗ trợ '>>' rõ ràng
('>' thực sự hoạt động giống như '>>') hoặc hỗ trợ cắt ngắn để loại bỏ tất cả
trình kích hoạt (bạn phải sử dụng '!' cho mỗi trình kích hoạt được thêm vào.)

6.2 Các lệnh kích hoạt được hỗ trợ
------------------------------

Các lệnh sau được hỗ trợ:

- Enable_event/disable_event

Các lệnh này có thể kích hoạt hoặc vô hiệu hóa một sự kiện theo dõi khác bất cứ khi nào
  sự kiện kích hoạt được nhấn.  Khi các lệnh này được đăng ký,
  sự kiện theo dõi khác được kích hoạt nhưng bị tắt ở chế độ "mềm".
  Nghĩa là, điểm theo dõi sẽ được gọi nhưng sẽ không được theo dõi.
  Điểm theo dõi sự kiện vẫn ở chế độ này miễn là có trình kích hoạt
  trong thực tế có thể kích hoạt nó.

Ví dụ: trình kích hoạt sau khiến các sự kiện kmalloc bị
  được theo dõi khi lệnh gọi hệ thống đọc được nhập và :1 ở cuối
  chỉ định rằng việc kích hoạt này chỉ xảy ra một lần::

# echo 'enable_event:kmem:kmalloc:1' > \
	      /sys/kernel/tracing/events/syscalls/sys_enter_read/trigger

Trình kích hoạt sau khiến các sự kiện kmalloc ngừng được theo dõi
  khi lệnh gọi hệ thống đọc thoát.  Sự vô hiệu hóa này xảy ra trên mọi
  đọc lối thoát cuộc gọi hệ thống::

# echo 'disable_event:kmem:kmalloc' > \
	      /sys/kernel/tracing/events/syscalls/sys_exit_read/trigger

Định dạng là::

Enable_event:<system>:<event>[:count]
      vô hiệu hóa_event:<system>:<event>[:count]

Để loại bỏ các lệnh trên::

# echo '!enable_event:kmem:kmalloc:1' > \
	      /sys/kernel/tracing/events/syscalls/sys_enter_read/trigger

# echo '!disable_event:kmem:kmalloc' > \
	      /sys/kernel/tracing/events/syscalls/sys_exit_read/trigger

Lưu ý rằng có thể có bất kỳ số lượng trình kích hoạt bật/tắt_event nào
  cho mỗi sự kiện kích hoạt, nhưng chỉ có thể có một trình kích hoạt cho mỗi sự kiện kích hoạt.
  sự kiện được kích hoạt. ví dụ. sys_enter_read có thể có trình kích hoạt cho phép cả hai
  kmem:kmalloc và sched:sched_switch, nhưng không thể có hai kmem:kmalloc
  các phiên bản như kmem:kmalloc và kmem:kmalloc:1 hoặc 'kmem:kmalloc if
  bytes_req == 256' và 'kmem:kmalloc if bytes_alloc == 256' (chúng
  có thể được kết hợp thành một bộ lọc duy nhất trên kmem: kmalloc).

- dấu vết ngăn xếp

Lệnh này đưa một stacktrace vào bộ đệm theo dõi bất cứ khi nào
  sự kiện kích hoạt xảy ra.

Ví dụ: trình kích hoạt sau sẽ loại bỏ một stacktrace mỗi khi
  điểm theo dõi kmalloc bị tấn công ::

# echo 'stacktrace' > \
		/sys/kernel/tracing/events/kmem/kmalloc/trigger

Trình kích hoạt sau đây loại bỏ một stacktrace 5 lần đầu tiên trong một kmalloc
  yêu cầu xảy ra với kích thước >= 64K::

# echo 'stacktrace:5 if bytes_req >= 65536' > \
		/sys/kernel/tracing/events/kmem/kmalloc/trigger

Định dạng là::

stacktrace[:count]

Để loại bỏ các lệnh trên::

# echo '!stacktrace' > \
		/sys/kernel/tracing/events/kmem/kmalloc/trigger

# echo '!stacktrace:5 if bytes_req >= 65536' > \
		/sys/kernel/tracing/events/kmem/kmalloc/trigger

Cái sau cũng có thể được loại bỏ đơn giản hơn bằng cách sau (không cần
  bộ lọc)::

# echo '!stacktrace:5' > \
		/sys/kernel/tracing/events/kmem/kmalloc/trigger

Lưu ý rằng chỉ có thể có một trình kích hoạt stacktrace cho mỗi lần kích hoạt
  sự kiện.

- ảnh chụp nhanh

Lệnh này khiến một ảnh chụp nhanh được kích hoạt bất cứ khi nào
  sự kiện kích hoạt xảy ra.

Lệnh sau tạo ảnh chụp nhanh mỗi khi có yêu cầu chặn
  hàng đợi được rút ra với độ sâu > 1. Nếu bạn đang truy tìm một tập hợp
  các sự kiện hoặc chức năng tại thời điểm đó, bộ đệm theo dõi ảnh chụp nhanh sẽ
  nắm bắt những sự kiện đó khi sự kiện kích hoạt xảy ra::

# echo 'ảnh chụp nhanh nếu nr_rq > 1' > \
		/sys/kernel/tracing/events/block/block_unplug/trigger

Để chỉ chụp nhanh một lần::

# echo 'snapshot:1 if nr_rq > 1' > \
		/sys/kernel/tracing/events/block/block_unplug/trigger

Để loại bỏ các lệnh trên::

# echo '!snapshot if nr_rq > 1' > \
		/sys/kernel/tracing/events/block/block_unplug/trigger

# echo '!snapshot:1 if nr_rq > 1' > \
		/sys/kernel/tracing/events/block/block_unplug/trigger

Lưu ý rằng chỉ có thể có một trình kích hoạt ảnh chụp nhanh cho mỗi lần kích hoạt
  sự kiện.

- dấu vết/dấu vết

Các lệnh này bật và tắt theo dõi khi các sự kiện được chỉ định
  đánh. Tham số xác định hệ thống theo dõi được thực hiện bao nhiêu lần
  bật và tắt. Nếu không xác định thì không có giới hạn.

Lệnh sau tắt tính năng dò tìm trong lần đầu tiên một khối
  hàng đợi yêu cầu được rút ra với độ sâu > 1. Nếu bạn đang truy tìm một
  tập hợp các sự kiện hoặc chức năng tại thời điểm đó, khi đó bạn có thể kiểm tra
  bộ đệm theo dõi để xem chuỗi các sự kiện dẫn đến
  sự kiện kích hoạt::

# echo 'dấu vết:1 nếu nr_rq > 1' > \
		/sys/kernel/tracing/events/block/block_unplug/trigger

Để luôn tắt tính năng theo dõi khi nr_rq > 1::

# echo 'theo dõi nếu nr_rq > 1' > \
		/sys/kernel/tracing/events/block/block_unplug/trigger

Để loại bỏ các lệnh trên::

# echo '!traceoff:1 if nr_rq > 1' > \
		/sys/kernel/tracing/events/block/block_unplug/trigger

# echo '!traceoff nếu nr_rq > 1' > \
		/sys/kernel/tracing/events/block/block_unplug/trigger

Lưu ý rằng chỉ có thể có một trình kích hoạt traceon hoặc traceoff cho mỗi
  sự kiện kích hoạt.

- lịch sử

Lệnh này tổng hợp các lần truy cập sự kiện vào một bảng băm được khóa trên một hoặc
  nhiều trường định dạng sự kiện theo dõi hơn (hoặc stacktrace) và một tập hợp các trường đang chạy
  tổng số bắt nguồn từ một hoặc nhiều trường định dạng sự kiện theo dõi và/hoặc
  số lượng sự kiện (hitcount).

Xem Documentation/trace/histogram.rst để biết chi tiết và ví dụ.

7. Sự kiện theo dõi trong kernel API
============================

Trong hầu hết các trường hợp, giao diện dòng lệnh để theo dõi các sự kiện không chỉ đơn giản là
đủ.  Tuy nhiên, đôi khi các ứng dụng có thể thấy cần
những mối quan hệ phức tạp hơn mức có thể được thể hiện thông qua một cách đơn giản
một loạt các biểu thức dòng lệnh được liên kết hoặc tập hợp các bộ
các lệnh có thể đơn giản là quá cồng kềnh.  Một ví dụ có thể là một
ứng dụng cần 'lắng nghe' luồng theo dõi để
duy trì một máy trạng thái trong kernel phát hiện, ví dụ, khi một
trạng thái hạt nhân bất hợp pháp xảy ra trong bộ lập lịch.

Hệ thống con sự kiện theo dõi cung cấp API trong kernel cho phép các mô-đun
hoặc mã hạt nhân khác để tạo ra các sự kiện 'tổng hợp' do người dùng xác định tại
ý chí, có thể được sử dụng để tăng cường luồng dấu vết hiện có
và/hoặc báo hiệu rằng một trạng thái quan trọng cụ thể đã xảy ra.

API trong kernel tương tự cũng có sẵn để tạo kprobe và
sự kiện kretprobe.

Cả API sự kiện tổng hợp và API sự kiện k/ret/probe đều được xây dựng dựa trên
của lệnh sự kiện "dynevent_cmd" cấp thấp hơn API, cũng là
có sẵn cho các ứng dụng chuyên biệt hơn, hoặc làm cơ sở cho các ứng dụng khác
API sự kiện theo dõi cấp cao hơn.

API được cung cấp cho các mục đích này được mô tả bên dưới và cho phép
sau đây:

- tự động tạo các định nghĩa sự kiện tổng hợp
  - tự động tạo các định nghĩa sự kiện kprobe và kretprobe
  - truy tìm các sự kiện tổng hợp từ mã trong kernel
  - API "dynevent_cmd" cấp thấp

7.1 Tự động tạo các định nghĩa sự kiện tổng hợp
----------------------------------------------------

Có một số cách để tạo sự kiện tổng hợp mới từ kernel
mô-đun hoặc mã hạt nhân khác.

Bước đầu tiên tạo sự kiện trong một bước, sử dụng synth_event_create().
Trong phương thức này, tên của sự kiện cần tạo và một mảng xác định
các trường được cung cấp cho synth_event_create().  Nếu thành công, một
sự kiện tổng hợp có tên và trường đó sẽ tồn tại sau đó
gọi.  Ví dụ: để tạo sự kiện tổng hợp "lịch trình" mới::

ret = synth_event_create("schedtest", sched_fields,
                           ARRAY_SIZE(sched_fields), THIS_MODULE);

Thông số sched_fields trong ví dụ này trỏ tới một mảng cấu trúc
synth_field_desc, mỗi trường mô tả một trường sự kiện theo loại và
tên::

cấu trúc tĩnh synth_field_desc sched_fields[] = {
        { .type = "pid_t", .name = "next_pid_field" },
        { .type = "char[16]", .name = "next_comm_field" },
        { .type = "u64", .name = "ts_ns" },
        { .type = "u64", .name = "ts_ms" },
        { .type = "unsign int", .name = "cpu" },
        { .type = "char[64]", .name = "my_string_field" },
        { .type = "int", .name = "my_int_field" },
  };

Xem synth_field_size() để biết các loại có sẵn.

Nếu field_name chứa [n] thì trường đó được coi là một mảng tĩnh.

Nếu field_names chứa[] (không có chỉ số dưới), trường này được coi là
là một mảng động, sẽ chỉ chiếm nhiều không gian trong sự kiện như
được yêu cầu để giữ mảng.

Bởi vì không gian cho một sự kiện được dành riêng trước khi gán giá trị trường
đối với sự kiện, việc sử dụng mảng động ngụ ý rằng từng phần
API trong kernel được mô tả bên dưới không thể được sử dụng với mảng động.  các
Tuy nhiên, các API trong kernel không riêng lẻ khác có thể được sử dụng với các API động
mảng.

Nếu sự kiện được tạo từ bên trong một mô-đun, một con trỏ tới mô-đun
phải được chuyển đến synth_event_create().  Điều này sẽ đảm bảo rằng
bộ đệm theo dõi sẽ không chứa các sự kiện không thể đọc được khi mô-đun được
bị loại bỏ.

Tại thời điểm này, đối tượng sự kiện đã sẵn sàng được sử dụng để tạo mới
sự kiện.

Trong phương pháp thứ hai, sự kiện được tạo theo nhiều bước.  Cái này
cho phép các sự kiện được tạo một cách linh hoạt và không cần phải tạo
và điền trước một mảng các trường.

Để sử dụng phương pháp này, một sự kiện tổng hợp trống hoặc trống một phần phải
đầu tiên được tạo bằng synth_event_gen_cmd_start() hoặc
synth_event_gen_cmd_array_start().  Đối với synth_event_gen_cmd_start(),
tên của sự kiện cùng với một hoặc nhiều cặp đối số mỗi cặp
đại diện cho 'loại field_name;' đặc tả trường nên
được cung cấp.  Đối với synth_event_gen_cmd_array_start(), tên của
sự kiện cùng với một mảng cấu trúc synth_field_desc sẽ là
được cung cấp. Trước khi gọi synth_event_gen_cmd_start() hoặc
synth_event_gen_cmd_array_start(), người dùng nên tạo và
khởi tạo đối tượng dynevent_cmd bằng cách sử dụng synth_event_cmd_init().

Ví dụ: để tạo một sự kiện tổng hợp "lịch trình" mới với hai
lĩnh vực::

struct dynevent_cmd cmd;
  char *buf;

/* Tạo vùng đệm để chứa lệnh đã tạo */
  buf = kzalloc(MAX_DYNEVENT_CMD_LEN, GFP_KERNEL);

/* Trước khi tạo lệnh, hãy khởi tạo đối tượng cmd */
  synth_event_cmd_init(&cmd, buf, MAX_DYNEVENT_CMD_LEN);

ret = synth_event_gen_cmd_start(&cmd, "schedtest", THIS_MODULE,
                                  "pid_t", "next_pid_field",
                                  "u64", "ts_ns");

Ngoài ra, bằng cách sử dụng một mảng các trường struct synth_field_desc
chứa cùng một thông tin::

ret = synth_event_gen_cmd_array_start(&cmd, "schedtest", THIS_MODULE,
                                        trường, n_field);

Khi đối tượng sự kiện tổng hợp đã được tạo, nó có thể được
có nhiều lĩnh vực hơn.  Các trường được thêm từng trường một bằng cách sử dụng
synth_event_add_field(), cung cấp đối tượng dynevent_cmd, một trường
loại và tên trường.  Ví dụ: để thêm trường int mới có tên
"intfield", cuộc gọi sau sẽ được thực hiện ::

ret = synth_event_add_field(&cmd, "int", "intfield");

Xem synth_field_size() để biết các loại có sẵn. Nếu field_name chứa [n]
trường được coi là một mảng.

Một nhóm trường cũng có thể được thêm vào cùng một lúc bằng cách sử dụng một mảng
synth_field_desc với add_synth_fields().  Ví dụ, điều này sẽ thêm
chỉ bốn sched_fields đầu tiên::

ret = synth_event_add_fields(&cmd, sched_fields, 4);

Nếu bạn đã có một chuỗi có dạng 'gõ field_name',
synth_event_add_field_str() có thể được sử dụng để thêm nguyên trạng; nó sẽ
cũng tự động thêm dấu ';' đến chuỗi.

Khi tất cả các trường đã được thêm vào, sự kiện sẽ được hoàn tất và
đã đăng ký bằng cách gọi hàm synth_event_gen_cmd_end() ::

ret = synth_event_gen_cmd_end(&cmd);

Tại thời điểm này, đối tượng sự kiện đã sẵn sàng được sử dụng để theo dõi các thông tin mới
sự kiện.

7.2 Truy tìm các sự kiện tổng hợp từ mã trong kernel
------------------------------------------------

Để theo dõi một sự kiện tổng hợp, có một số lựa chọn.  đầu tiên
tùy chọn là theo dõi sự kiện trong một cuộc gọi, sử dụng synth_event_trace()
với số lượng giá trị thay đổi hoặc synth_event_trace_array() với
mảng giá trị cần thiết lập.  Tùy chọn thứ hai có thể được sử dụng để tránh
cần một mảng giá trị hoặc danh sách đối số được tạo sẵn, thông qua
synth_event_trace_start() và synth_event_trace_end() cùng với
synth_event_add_next_val() hoặc synth_event_add_val() để thêm các giá trị
từng phần.

7.2.1 Truy tìm một sự kiện tổng hợp cùng một lúc
-------------------------------------------

Để theo dõi một sự kiện tổng hợp cùng một lúc, synth_event_trace() hoặc
Có thể sử dụng các hàm synth_event_trace_array().

Hàm synth_event_trace() được truyền vào trace_event_file
đại diện cho sự kiện tổng hợp (có thể được truy xuất bằng cách sử dụng
trace_get_event_file() sử dụng tên sự kiện tổng hợp, "synthetic" làm
tên hệ thống và tên phiên bản theo dõi (NULL nếu sử dụng tên chung
mảng theo dõi)), cùng với số lượng biến u64 đối số, một cho mỗi đối số
trường sự kiện tổng hợp và số lượng giá trị được truyền.

Vì vậy, để theo dõi một sự kiện tương ứng với định nghĩa sự kiện tổng hợp
ở trên, mã như sau có thể được sử dụng ::

ret = synth_event_trace(create_synth_test, 7, /* số giá trị */
                          444, /* next_pid_field */
                          (u64)"crackers", /* next_comm_field */
                          1000000, /* ts_ns */
                          1000, /* ts_ms */
                          smp_processor_id(),/* cpu */
                          (u64)"Thneed", /* my_string_field */
                          999);            /* my_int_field */

Tất cả các giá trị phải được truyền tới u64 và các giá trị chuỗi chỉ là con trỏ tới
chuỗi, chuyển sang u64.  Chuỗi sẽ được sao chép vào không gian dành riêng trong
sự kiện cho chuỗi bằng cách sử dụng các con trỏ này.

Ngoài ra, hàm synth_event_trace_array() có thể được sử dụng để
hoàn thành điều tương tự.  Nó được chuyển qua trace_event_file
đại diện cho sự kiện tổng hợp (có thể được truy xuất bằng cách sử dụng
trace_get_event_file() sử dụng tên sự kiện tổng hợp, "synthetic" làm
tên hệ thống và tên phiên bản theo dõi (NULL nếu sử dụng tên chung
mảng dấu vết)), cùng với một mảng u64, một mảng cho mỗi mảng tổng hợp
trường sự kiện.

Để theo dõi một sự kiện tương ứng với định nghĩa sự kiện tổng hợp
ở trên, mã như sau có thể được sử dụng ::

u64 vals[7];

giá trị [0] = 777;                  /* next_pid_field */
  vals[1] = (u64)"tiddlywinks";   /* next_comm_field */
  giá trị [2] = 1000000;              /* ts_ns */
  giá trị [3] = 1000;                 /* ts_ms */
  vals[4] = smp_processor_id();   /*cpu*/
  vals[5] = (u64)"thneed";        /* my_string_field */
  giá trị [6] = 398;                  /* my_int_field */

Mảng 'vals' chỉ là một mảng của u64, số lượng của nó phải
khớp với số trường trong sự kiện tổng hợp và phải nằm trong
thứ tự giống như các trường sự kiện tổng hợp.

Tất cả các giá trị phải được truyền tới u64 và các giá trị chuỗi chỉ là con trỏ tới
chuỗi, chuyển sang u64.  Chuỗi sẽ được sao chép vào không gian dành riêng trong
sự kiện cho chuỗi bằng cách sử dụng các con trỏ này.

Để theo dõi một sự kiện tổng hợp, một con trỏ tới tệp sự kiện theo dõi
là cần thiết.  Hàm trace_get_event_file() có thể được sử dụng để lấy
nó - nó sẽ tìm thấy tệp trong phiên bản theo dõi đã cho (trong trường hợp này
NULL vì mảng theo dõi trên cùng đang được sử dụng) đồng thời
ngăn chặn phiên bản chứa nó biến mất::

schedtest_event_file = trace_get_event_file(NULL, "tổng hợp",
                                                   "lịch trình");

Trước khi theo dõi sự kiện, nó phải được kích hoạt theo cách nào đó, nếu không thì
sự kiện tổng hợp sẽ không thực sự hiển thị trong bộ đệm theo dõi.

Để kích hoạt một sự kiện tổng hợp từ kernel, trace_array_set_clr_event()
có thể được sử dụng (không dành riêng cho các sự kiện tổng hợp, do đó cần
tên hệ thống "tổng hợp" được chỉ định rõ ràng).

Để kích hoạt sự kiện, hãy chuyển 'true' cho nó::

trace_array_set_clr_event(schedtest_event_file->tr,
                                 "tổng hợp", "lập kế hoạch", đúng);

Để vô hiệu hóa nó, hãy chuyển sai::

trace_array_set_clr_event(schedtest_event_file->tr,
                                 "tổng hợp", "lập kế hoạch", sai);

Cuối cùng, synth_event_trace_array() có thể được sử dụng để thực sự theo dõi
sự kiện này sẽ hiển thị trong bộ đệm theo dõi sau đó ::

ret = synth_event_trace_array(schedtest_event_file, vals,
                                     ARRAY_SIZE(vals));

Để loại bỏ sự kiện tổng hợp, sự kiện đó phải bị vô hiệu hóa và
phiên bản dấu vết phải được 'đặt' lại bằng cách sử dụng trace_put_event_file()::

trace_array_set_clr_event(schedtest_event_file->tr,
                                 "tổng hợp", "lập kế hoạch", sai);
       trace_put_event_file(schedtest_event_file);

Nếu những điều đó thành công, synth_event_delete() có thể được gọi tới
xóa sự kiện::

ret = synth_event_delete("schedtest");

7.2.2 Truy tìm từng sự kiện tổng hợp
-----------------------------------------

Để theo dõi một chất tổng hợp bằng phương pháp từng phần được mô tả ở trên,
Hàm synth_event_trace_start() được sử dụng để 'mở' tổng hợp
dấu vết sự kiện::

cấu trúc synth_event_trace_state trace_state;

ret = synth_event_trace_start(schedtest_event_file, &trace_state);

Nó đã vượt qua trace_event_file đại diện cho sự kiện tổng hợp
sử dụng các phương pháp tương tự như được mô tả ở trên, cùng với một con trỏ tới một
đối tượng struct synth_event_trace_state, sẽ được xóa về 0 trước khi sử dụng và
được sử dụng để duy trì trạng thái giữa cuộc gọi này và cuộc gọi tiếp theo.

Khi sự kiện đã được mở, có nghĩa là không gian dành cho nó đã được
dành riêng trong bộ đệm theo dõi, các trường riêng lẻ có thể được đặt.  Ở đó
có hai cách để làm điều đó, lần lượt từng cách cho từng trường trong
sự kiện không yêu cầu tra cứu hoặc theo tên.  các
sự cân bằng là sự linh hoạt trong việc thực hiện các nhiệm vụ so với chi phí của một
tra cứu theo từng trường.

Để gán các giá trị lần lượt mà không cần tra cứu,
nên sử dụng synth_event_add_next_val().  Mỗi cuộc gọi được chuyển qua
cùng một đối tượng synth_event_trace_state được sử dụng trong synth_event_trace_start(),
cùng với giá trị để đặt trường tiếp theo trong sự kiện.  Sau mỗi lần
trường được đặt, 'con trỏ' trỏ đến trường tiếp theo, trường này sẽ được đặt
bằng cuộc gọi tiếp theo, tiếp tục cho đến khi tất cả các trường đã được đặt
theo thứ tự.  Chuỗi cuộc gọi tương tự như trong các ví dụ trên bằng cách sử dụng
phương pháp này sẽ là (không có mã xử lý lỗi)::

/* next_pid_field */
       ret = synth_event_add_next_val(777, &trace_state);

/* next_comm_field */
       ret = synth_event_add_next_val((u64)"slinky", &trace_state);

/* ts_ns */
       ret = synth_event_add_next_val(1000000, &trace_state);

/* ts_ms */
       ret = synth_event_add_next_val(1000, &trace_state);

/*cpu*/
       ret = synth_event_add_next_val(smp_processor_id(), &trace_state);

/* my_string_field */
       ret = synth_event_add_next_val((u64)"thneed_2.01", &trace_state);

/* my_int_field */
       ret = synth_event_add_next_val(395, &trace_state);

Để gán các giá trị theo bất kỳ thứ tự nào, synth_event_add_val() phải là
đã sử dụng.  Mỗi cuộc gọi được truyền cùng một đối tượng synth_event_trace_state được sử dụng trong
synth_event_trace_start(), cùng với tên trường của trường
để đặt và giá trị để đặt.  Chuỗi cuộc gọi tương tự như trong
các ví dụ trên sử dụng phương pháp này sẽ là (không có xử lý lỗi
mã)::

ret = synth_event_add_val("next_pid_field", 777, &trace_state);
       ret = synth_event_add_val("next_comm_field", (u64)"putty ngớ ngẩn",
                                 &trace_state);
       ret = synth_event_add_val("ts_ns", 1000000, &trace_state);
       ret = synth_event_add_val("ts_ms", 1000, &trace_state);
       ret = synth_event_add_val("cpu", smp_processor_id(), &trace_state);
       ret = synth_event_add_val("my_string_field", (u64)"thneed_9",
                                 &trace_state);
       ret = synth_event_add_val("my_int_field", 3999, &trace_state);

Lưu ý rằng synth_event_add_next_val() và synth_event_add_val() là
không tương thích nếu được sử dụng trong cùng một dấu vết của một sự kiện - một trong hai
có thể được sử dụng nhưng không phải cả hai cùng một lúc.

Cuối cùng, sự kiện sẽ không được theo dõi thực sự cho đến khi nó 'đóng',
được thực hiện bằng cách sử dụng synth_event_trace_end(), chỉ mất
Đối tượng struct synth_event_trace_state được sử dụng trong các lệnh gọi trước đó::

ret = synth_event_trace_end(&trace_state);

Lưu ý rằng synth_event_trace_end() phải được gọi ở cuối bất kể
về việc có bất kỳ lệnh gọi thêm nào không thành công hay không (ví dụ do tên trường sai
được thông qua).

7.3 Tự động tạo định nghĩa sự kiện kprobe và kretprobe
---------------------------------------------------------------

Để tạo một sự kiện theo dõi kprobe hoặc kretprobe từ mã hạt nhân,
kprobe_event_gen_cmd_start() hoặc kretprobe_event_gen_cmd_start()
có thể sử dụng các chức năng.

Để tạo một sự kiện kprobe, một sự kiện kprobe trống hoặc trống một phần
trước tiên phải được tạo bằng kprobe_event_gen_cmd_start().  Tên
của sự kiện và vị trí thăm dò phải được chỉ định cùng với một
hoặc các đối số đại diện cho một trường thăm dò phải được cung cấp cho trường này
chức năng.  Trước khi gọi kprobe_event_gen_cmd_start(), người dùng
nên tạo và khởi tạo đối tượng dynevent_cmd bằng cách sử dụng
kprobe_event_cmd_init().

Ví dụ: để tạo một sự kiện kprobe "schedtest" mới với hai trường ::

struct dynevent_cmd cmd;
  char *buf;

/* Tạo vùng đệm để chứa lệnh đã tạo */
  buf = kzalloc(MAX_DYNEVENT_CMD_LEN, GFP_KERNEL);

/* Trước khi tạo lệnh, hãy khởi tạo đối tượng cmd */
  kprobe_event_cmd_init(&cmd, buf, MAX_DYNEVENT_CMD_LEN);

/*
   * Xác định sự kiện gen_kprobe_test với 2 kprobe đầu tiên
   * các trường.
   */
  ret = kprobe_event_gen_cmd_start(&cmd, "gen_kprobe_test", "do_sys_open",
                                   "dfd=%ax", "filename=%dx");

Khi đối tượng sự kiện kprobe đã được tạo, nó có thể được
có nhiều lĩnh vực hơn.  Các trường có thể được thêm bằng cách sử dụng
kprobe_event_add_fields(), cung cấp đối tượng dynevent_cmd cùng với
với một danh sách các trường thăm dò có arg thay đổi.  Ví dụ, để thêm một
vài trường bổ sung, cuộc gọi sau có thể được thực hiện ::

ret = kprobe_event_add_fields(&cmd, "flags=%cx", "mode=+4($stack)");

Khi tất cả các trường đã được thêm vào, sự kiện sẽ được hoàn tất và
đã đăng ký bằng cách gọi kprobe_event_gen_cmd_end() hoặc
các hàm kretprobe_event_gen_cmd_end(), tùy thuộc vào việc kprobe có
hoặc lệnh kretprobe đã được bắt đầu::

ret = kprobe_event_gen_cmd_end(&cmd);

hoặc::

ret = kretprobe_event_gen_cmd_end(&cmd);

Tại thời điểm này, đối tượng sự kiện đã sẵn sàng được sử dụng để theo dõi các thông tin mới
sự kiện.

Tương tự, một sự kiện kretprobe có thể được tạo bằng cách sử dụng
kretprobe_event_gen_cmd_start() với tên và vị trí thăm dò và
các thông số bổ sung như $retval::

ret = kretprobe_event_gen_cmd_start(&cmd, "gen_kretprobe_test",
                                      "do_sys_open", "$retval");

Tương tự như trường hợp sự kiện tổng hợp, mã như sau có thể được
được sử dụng để kích hoạt sự kiện kprobe mới được tạo ::

gen_kprobe_test = trace_get_event_file(NULL, "kprobes", "gen_kprobe_test");

ret = trace_array_set_clr_event(gen_kprobe_test->tr,
                                  "kprobes", "gen_kprobe_test", đúng);

Cuối cùng, cũng tương tự như các sự kiện tổng hợp, đoạn mã sau có thể được
được sử dụng để trả lại tệp sự kiện kprobe và xóa sự kiện ::

trace_put_event_file(gen_kprobe_test);

ret = kprobe_event_delete("gen_kprobe_test");

7.4 API cấp thấp "dynevent_cmd"
------------------------------------

Cả giao diện sự kiện tổng hợp trong kernel và giao diện kprobe đều được xây dựng trên
trên cùng của giao diện "dynevent_cmd" cấp thấp hơn.  Giao diện này là
nhằm cung cấp cơ sở cho các giao diện cấp cao hơn như
giao diện tổng hợp và kprobe, có thể được sử dụng làm ví dụ.

Ý tưởng cơ bản rất đơn giản và nhằm mục đích cung cấp một mục đích chung
lớp có thể được sử dụng để tạo ra các lệnh sự kiện theo dõi.  các
chuỗi lệnh được tạo ra sau đó có thể được chuyển tới bộ phận phân tích cú pháp lệnh
và mã tạo sự kiện đã tồn tại trong sự kiện theo dõi
hệ thống con để tạo các sự kiện theo dõi tương ứng.

Tóm lại, cách thức hoạt động của nó là giao diện cấp cao hơn
đoạn mã tạo một đối tượng struct dynevent_cmd, sau đó sử dụng một vài
các hàm dynevent_arg_add() và dynevent_arg_pair_add() để xây dựng
một chuỗi lệnh, cuối cùng khiến lệnh được thực thi
sử dụng hàm dynevent_create().  Các chi tiết của giao diện
được mô tả dưới đây.

Bước đầu tiên trong việc xây dựng một chuỗi lệnh mới là tạo và
khởi tạo một phiên bản của dynevent_cmd.  Ví dụ ở đây, chúng tôi
tạo một dynevent_cmd trên ngăn xếp và khởi tạo nó ::

struct dynevent_cmd cmd;
  char *buf;
  int ret;

buf = kzalloc(MAX_DYNEVENT_CMD_LEN, GFP_KERNEL);

dynevent_cmd_init(cmd, buf, maxlen, DYNEVENT_TYPE_FOO,
                    foo_event_run_command);

Việc khởi tạo dynevent_cmd cần được cung cấp một giá trị do người dùng chỉ định
bộ đệm và độ dài của bộ đệm (có thể sử dụng MAX_DYNEVENT_CMD_LEN
cho mục đích này - ở mức 2k, nó thường quá lớn để có thể đặt thoải mái
trên ngăn xếp, do đó được phân bổ động), id loại dynevent,
được sử dụng để kiểm tra xem các cuộc gọi API tiếp theo có dành cho
đúng loại lệnh và một con trỏ tới run_command() dành riêng cho sự kiện
gọi lại sẽ được gọi để thực sự thực hiện sự kiện cụ thể
chức năng lệnh.

Khi đã xong, chuỗi lệnh có thể được xây dựng bằng cách liên tiếp
gọi các hàm thêm đối số.

Để thêm một đối số, hãy xác định và khởi tạo struct dynevent_arg
hoặc đối tượng struct dynevent_arg_pair.  Đây là một ví dụ đơn giản nhất
có thể bổ sung đối số, đơn giản là nối thêm chuỗi đã cho dưới dạng
một đối số được phân tách bằng khoảng trắng cho lệnh ::

cấu trúc dynevent_arg arg;

dynevent_arg_init(&arg, NULL, 0);

arg.str = tên;

ret = dynevent_arg_add(cmd, &arg);

Đối tượng arg lần đầu tiên được khởi tạo bằng cách sử dụng dynevent_arg_init() và trong
trường hợp này các tham số là NULL hoặc 0, có nghĩa là không có
chức năng kiểm tra độ chính xác tùy chọn hoặc dấu phân cách được thêm vào cuối
tranh luận.

Đây là một ví dụ phức tạp khác sử dụng 'cặp arg', đó là
được sử dụng để tạo một đối số bao gồm một vài thành phần được thêm vào
cùng nhau thành một đơn vị, ví dụ: 'type field_name;' arg hoặc đơn giản
biểu thức arg, ví dụ: 'flags=%cx'::

cấu trúc dynevent_arg_pair arg_pair;

dynevent_arg_pair_init(&arg_pair, dynevent_foo_check_arg_fn, 0, ';');

arg_pair.lhs = loại;
  arg_pair.rhs = tên;

ret = dynevent_arg_pair_add(cmd, &arg_pair);

Một lần nữa, arg_pair được khởi tạo lần đầu tiên, trong trường hợp này là một lệnh gọi lại
hàm được sử dụng để kiểm tra tính đúng đắn của các đối số (ví dụ:
không phần nào của cặp này là NULL), cùng với một ký tự được sử dụng
để thêm một toán tử giữa cặp (ở đây không có) và một dấu phân cách
được thêm vào cuối cặp arg (ở đây ';').

Ngoài ra còn có hàm dynevent_str_add() có thể được sử dụng đơn giản
thêm một chuỗi nguyên trạng, không có dấu cách, dấu phân cách hoặc kiểm tra đối số.

Bất kỳ số lượng cuộc gọi dynevent_*_add() nào cũng có thể được thực hiện để xây dựng chuỗi
(cho đến khi chiều dài của nó vượt quá cmd->maxlen).  Khi tất cả các đối số có
đã được thêm vào và chuỗi lệnh đã hoàn tất, điều duy nhất còn lại là
làm là chạy lệnh, điều này xảy ra bằng cách gọi đơn giản
dynevent_create()::

ret = dynevent_create(&cmd);

Tại thời điểm đó, nếu giá trị trả về là 0 thì sự kiện động đã được
được tạo và sẵn sàng để sử dụng.

Xem định nghĩa hàm dynevent_cmd để biết chi tiết
của API.
