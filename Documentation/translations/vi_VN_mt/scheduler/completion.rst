.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scheduler/completion.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================================
Hoàn thành - API rào cản "chờ hoàn thành"
====================================================

Giới thiệu:
-------------

Nếu bạn có một hoặc nhiều luồng phải chờ một số hoạt động kernel
để đạt đến một điểm hoặc một trạng thái cụ thể, việc hoàn thành có thể cung cấp một
giải pháp không có chủng tộc cho vấn đề này. Về mặt ngữ nghĩa, chúng hơi giống một
pthread_barrier() và có trường hợp sử dụng tương tự.

Hoàn thành là một cơ chế đồng bộ hóa mã thích hợp hơn bất kỳ
lạm dụng khóa/semaphore và vòng lặp bận. Bất cứ lúc nào bạn nghĩ đến việc sử dụng
năng suất () hoặc một số vòng lặp msleep(1) kỳ quặc để cho phép một cái gì đó khác tiếp tục,
bạn có thể muốn xem xét sử dụng một trong wait_for_completion*()
thay vào đó hãy gọi và hoàn thành().

Ưu điểm của việc sử dụng sự hoàn thành là chúng có mục tiêu được xác định rõ ràng, tập trung
mục đích giúp bạn dễ dàng hiểu được mục đích của mã, nhưng chúng
cũng mang lại mã hiệu quả hơn vì tất cả các luồng có thể tiếp tục thực thi
cho đến khi thực sự cần kết quả, và cả quá trình chờ đợi và báo hiệu
có hiệu quả cao khi sử dụng các tiện ích đánh thức/ngủ theo lịch trình ở mức độ thấp.

Việc hoàn thành được xây dựng dựa trên cơ sở hạ tầng chờ đợi và đánh thức của
bộ lập lịch Linux. Sự kiện mà các chủ đề trên hàng chờ đang chờ đợi
được rút gọn thành một cờ đơn giản trong 'hoàn thành cấu trúc', được gọi một cách thích hợp là "hoàn thành".

Vì việc hoàn thành có liên quan đến lịch trình nên bạn có thể tìm thấy mã trong
kernel/scheduler/completion.c.


Cách sử dụng:
------

Có ba phần chính khi sử dụng sự hoàn thành:

- khởi tạo đối tượng đồng bộ hóa 'hoàn thành cấu trúc'
 - phần chờ thông qua lệnh gọi đến một trong các biến thể của wait_for_completion(),
 - phía báo hiệu thông qua lệnh gọi tới Complete() hoặc Complete_all().

Ngoài ra còn có một số chức năng trợ giúp để kiểm tra trạng thái hoàn thành.
Lưu ý rằng trong khi việc khởi tạo phải diễn ra trước tiên thì việc chờ đợi và báo hiệu
một phần có thể xảy ra theo bất kỳ thứ tự nào. tức là nó hoàn toàn bình thường đối với một chủ đề
đã đánh dấu việc hoàn thành là 'hoàn thành' trước khi một chủ đề khác kiểm tra xem
nó phải đợi nó.

Để sử dụng tính năng hoàn thành, bạn cần #include <linux/completion.h> và
tạo một biến tĩnh hoặc động thuộc loại 'hoàn thành cấu trúc',
chỉ có hai trường::

hoàn thành cấu trúc {
		unsign int xong;
		cấu trúc swait_queue_head chờ;
	};

Điều này cung cấp hàng đợi ->wait để đặt các tác vụ chờ (nếu có) và
cờ hoàn thành ->done để cho biết liệu nó đã hoàn thành hay chưa.

Các phần hoàn thành phải được đặt tên để đề cập đến sự kiện đang được đồng bộ hóa.
Một ví dụ điển hình là::

wait_for_completion(&early_console_ Added);

hoàn thành(&early_console_ Added);

Việc đặt tên tốt, trực quan (như mọi khi) giúp mã dễ đọc hơn. Đặt tên cho sự hoàn thành
'hoàn thành' không hữu ích trừ khi mục đích quá rõ ràng...


Đang khởi tạo hoàn thành:
-------------------------

Các đối tượng hoàn thành được phân bổ động tốt nhất nên được nhúng vào dữ liệu
các cấu trúc được đảm bảo tồn tại trong suốt vòng đời của chức năng/trình điều khiển,
để ngăn chặn các cuộc đua có lệnh gọi Complete() không đồng bộ xảy ra.

Cần đặc biệt cẩn thận khi sử dụng _timeout() hoặc _killable()/_interruptible()
các biến thể của wait_for_completion(), vì phải đảm bảo rằng việc phân bổ lại bộ nhớ
không xảy ra cho đến khi tất cả các hoạt động liên quan (complete() hoặc renit_completion())
đã diễn ra, ngay cả khi các chức năng chờ này quay trở lại sớm do hết thời gian chờ
hoặc tín hiệu kích hoạt.

Việc khởi tạo các đối tượng hoàn thành được phân bổ động được thực hiện thông qua lệnh gọi tới
init_completion()::

init_completion(&dynamic_object->done);

Trong lệnh gọi này, chúng ta khởi tạo hàng đợi và đặt ->done thành 0, tức là "chưa hoàn thành"
hoặc "chưa xong".

Hàm khởi tạo lại, Reinit_completion(), chỉ cần đặt lại
->trường hoàn thành thành 0 ("chưa hoàn thành") mà không cần chạm vào hàng chờ.
Người gọi hàm này phải đảm bảo rằng không có hành vi không phù hợp
các cuộc gọi wait_for_completion() diễn ra song song.

Gọi init_completion() trên cùng một đối tượng hoàn thành hai lần là
rất có thể là lỗi vì nó khởi tạo lại hàng đợi thành hàng đợi trống và
các tác vụ được xếp hàng đợi có thể bị "mất" - hãy sử dụng reit_completion() trong trường hợp đó,
nhưng hãy lưu ý đến các chủng tộc khác.

Để khai báo và khởi tạo tĩnh, macro có sẵn.

Đối với các khai báo tĩnh (hoặc toàn cục) trong phạm vi tệp, bạn có thể sử dụng
DECLARE_COMPLETION()::

DECLARE_COMPLETION tĩnh (setup_done);
	DECLARE_COMPLETION(setup_done);

Lưu ý rằng trong trường hợp này việc hoàn thành là thời gian khởi động (hoặc thời gian tải mô-đun)
được khởi tạo thành 'chưa xong' và không yêu cầu lệnh gọi init_completion().

Khi sự hoàn thành được khai báo là một biến cục bộ trong hàm,
thì việc khởi tạo phải luôn sử dụng DECLARE_COMPLETION_ONSTACK()
một cách rõ ràng, không chỉ để làm Lockdep hài lòng mà còn để làm rõ điều đó
phạm vi giới hạn đó đã được xem xét và có chủ ý::

DECLARE_COMPLETION_ONSTACK(setup_done)

Lưu ý rằng khi sử dụng các đối tượng hoàn thành làm biến cục bộ, bạn phải
nhận thức sâu sắc về thời gian tồn tại ngắn ngủi của ngăn xếp hàm: hàm
không được quay lại bối cảnh đang gọi cho đến khi tất cả các hoạt động (chẳng hạn như chờ
thread) đã ngừng hoạt động và đối tượng hoàn thành hoàn toàn không được sử dụng.

Để nhấn mạnh lại điều này: đặc biệt khi sử dụng một số biến thể API đang chờ
với các kết quả phức tạp hơn, chẳng hạn như thời gian chờ hoặc báo hiệu (_timeout(),
_killable() và _interruptible()), quá trình chờ đợi có thể hoàn tất
sớm trong khi đối tượng vẫn có thể được sử dụng bởi một luồng khác - và trả về
từ hàm người gọi wait_on_completion*() sẽ giải phóng hàm
xếp chồng lên nhau và gây ra lỗi dữ liệu tinh vi nếu một phương thức Complete() được thực hiện trong một số
chủ đề khác. Thử nghiệm đơn giản có thể không kích hoạt các loại cuộc đua này.

Nếu không chắc chắn, hãy sử dụng các đối tượng hoàn thành được phân bổ động, tốt nhất là được nhúng
ở một số vật thể sống lâu khác có thời gian sống dài một cách nhàm chán
vượt quá thời gian tồn tại của bất kỳ luồng trợ giúp nào sử dụng đối tượng hoàn thành,
hoặc có khóa hoặc cơ chế đồng bộ hóa khác để đảm bảo Complete()
không được gọi trên một đối tượng được giải phóng.

Một DECLARE_COMPLETION() ngây thơ trên ngăn xếp sẽ kích hoạt cảnh báo lockdep.

Đang chờ hoàn thiện:
------------------------

Để một luồng chờ một số hoạt động đồng thời kết thúc, nó
gọi wait_for_completion() trên cấu trúc hoàn thành đã khởi tạo ::

void wait_for_completion(hoàn thành cấu trúc *xong)

Một kịch bản sử dụng điển hình là::

CPU#1 CPU#2

hoàn thành cấu trúc setup_done;

init_completion(&setup_done);
	initize_work(...,&setup_done,...);

/* chạy mã không phụ thuộc ZZ0000ZZ để thiết lập */

wait_for_completion(&setup_done);	hoàn thành(&setup_done);

Điều này không ngụ ý bất kỳ thứ tự cụ thể nào giữa wait_for_completion() và
lệnh gọi hoàn thành() - nếu lệnh gọi hoàn thành() xảy ra trước cuộc gọi
tới wait_for_completion() thì phía chờ sẽ tiếp tục
ngay lập tức khi tất cả các phụ thuộc đều được thỏa mãn; nếu không, nó sẽ chặn cho đến khi
sự hoàn thành được báo hiệu bởi Complete().

Lưu ý rằng Wait_for_completion() đang gọi spin_lock_irq()/spin_unlock_irq(),
vì vậy nó chỉ có thể được gọi một cách an toàn khi bạn biết rằng các ngắt được kích hoạt.
Gọi nó từ bối cảnh nguyên tử không có IRQ sẽ dẫn đến kết quả khó phát hiện
cho phép ngắt một cách giả tạo.

Hành vi mặc định là chờ mà không hết thời gian chờ và đánh dấu nhiệm vụ là
không thể gián đoạn. wait_for_completion() và các biến thể của nó chỉ an toàn
trong bối cảnh quá trình (vì họ có thể ngủ) nhưng không phải trong bối cảnh nguyên tử,
bối cảnh ngắt, với IRQ bị vô hiệu hóa hoặc quyền ưu tiên bị vô hiệu hóa - xem thêm
try_wait_for_completion() bên dưới để xử lý hoàn thành nguyên tử/ngắt
bối cảnh.

Vì tất cả các biến thể của wait_for_completion() có thể (rõ ràng) chặn trong thời gian dài
thời gian tùy thuộc vào tính chất của hoạt động mà họ đang chờ đợi, vì vậy trong
hầu hết các trường hợp bạn có thể không muốn gọi điều này bằng các mutex bị giữ.


Các biến thể wait_for_completion*() có sẵn:
------------------------------------------

Tất cả các biến thể bên dưới đều có trạng thái trả về và trạng thái này cần được kiểm tra trong
hầu hết(/tất cả) trường hợp - trong trường hợp bạn cố tình không kiểm tra trạng thái
có lẽ muốn ghi chú giải thích điều này (ví dụ: xem
Arch/arm/kernel/smp.c:__cpu_up()).

Một vấn đề phổ biến xảy ra là việc gán các kiểu trả về không rõ ràng,
vì vậy hãy cẩn thận khi gán giá trị trả về cho các biến có kiểu thích hợp.

Việc kiểm tra ý nghĩa cụ thể của các giá trị trả về cũng đã được tìm thấy
là khá không chính xác, ví dụ. các cấu trúc như::

nếu (! Wait_for_completion_interruptible_timeout(...))

... would execute the same code path for successful completion and for the
trường hợp bị gián đoạn - đó có thể không phải là điều bạn muốn ::

int wait_for_completion_interruptible(hoàn thành cấu trúc *xong)

Chức năng này đánh dấu nhiệm vụ TASK_INTERRUPTIBLE trong khi chờ đợi.
Nếu nhận được tín hiệu trong khi chờ, nó sẽ trả về -ERESTARTSYS; 0 nếu không::

chờ đợi lâu không dấu_for_completion_timeout(hoàn thành cấu trúc *xong, thời gian chờ dài không dấu)

Tác vụ được đánh dấu là TASK_UNINTERRUPTIBLE và sẽ đợi tối đa là 'hết thời gian'
nháy mắt. Nếu xảy ra thời gian chờ, nó sẽ trả về 0, nếu không thì thời gian còn lại sẽ
nháy mắt (nhưng ít nhất là 1).

Tốt nhất là nên tính thời gian chờ bằng msecs_to_jiffies() hoặc usecs_to_jiffies(),
để làm cho mã phần lớn là bất biến HZ.

Nếu giá trị thời gian chờ được trả về bị bỏ qua một cách có chủ ý thì có lẽ nên giải thích
tại sao (ví dụ: xem trình điều khiển/mfd/wm8350-core.c wm8350_read_auxadc())::

chờ đợi lâu_for_completion_interruptible_timeout (hoàn thành cấu trúc *xong, thời gian chờ dài không dấu)

Hàm này vượt qua thời gian chờ trong nháy mắt và đánh dấu nhiệm vụ là
TASK_INTERRUPTIBLE. Nếu nhận được tín hiệu, nó sẽ trả về -ERESTARTSYS;
mặt khác, nó trả về 0 nếu hết thời gian hoàn thành hoặc thời gian còn lại trong
nhanh chóng nếu hoàn thành xảy ra.

Các biến thể khác bao gồm _killable sử dụng TASK_KILLABLE làm
trạng thái nhiệm vụ được chỉ định và sẽ trả về -ERESTARTSYS nếu nó bị gián đoạn,
hoặc 0 nếu đã hoàn thành.  Ngoài ra còn có một biến thể _timeout ::

chờ đợi lâu_for_completion_killable(hoàn thành cấu trúc *xong)
	chờ đợi lâu_for_completion_killable_timeout (hoàn thành cấu trúc *xong, thời gian chờ lâu không dấu)

Các biến thể _io wait_for_completion_io() hoạt động giống như các biến thể không phải _io
các biến thể, ngoại trừ thời gian chờ kế toán là 'chờ trên IO', có
tác động đến cách nhiệm vụ được tính trong thống kê lập kế hoạch/IO::

void wait_for_completion_io(hoàn thành cấu trúc *xong)
	chờ đợi lâu không dấu_for_completion_io_timeout(hoàn thành cấu trúc *xong, thời gian chờ dài không dấu)


Hoàn thành báo hiệu:
----------------------

Một luồng muốn báo hiệu rằng các điều kiện để tiếp tục đã được
đạt được các cuộc gọi Complete() để báo hiệu chính xác một trong những người phục vụ rằng nó có thể
tiếp tục::

void hoàn thành(hoàn thành cấu trúc *xong)

... or calls complete_all() to signal all current and future waiters::

	void complete_all(struct completion *done)

Tín hiệu sẽ hoạt động như mong đợi ngay cả khi việc hoàn thành được báo hiệu trước đó
một chủ đề bắt đầu chờ đợi. Điều này đạt được nhờ người phục vụ “tiêu thụ”
(giảm dần) trường done của 'hoàn thành cấu trúc'. Chủ đề đang chờ
thứ tự đánh thức giống như thứ tự chúng được xếp vào hàng đợi (thứ tự FIFO).

Nếu Complete() được gọi nhiều lần thì điều này sẽ cho phép số đó
số người phục vụ tiếp tục - mỗi lệnh gọi tới Complete() sẽ chỉ tăng
lĩnh vực đã hoàn thành. Tuy nhiên, việc gọi Complete_all() nhiều lần là một lỗi. Cả hai
Complete() và Complete_all() có thể được gọi trong ngữ cảnh IRQ/atomic một cách an toàn.

Chỉ có thể có một luồng gọi Complete() hoặc Complete_all() trên một
'hoàn thành cấu trúc' cụ thể bất kỳ lúc nào - được tuần tự hóa trong quá trình chờ đợi
hàng đợi spinlock. Bất kỳ lệnh gọi đồng thời nào như vậy tới Complete() hoặc Complete_all()
có lẽ là một lỗi thiết kế.

Việc hoàn thành tín hiệu từ ngữ cảnh IRQ là tốt vì nó sẽ phù hợp
khóa bằng spin_lock_irqsave()/spin_unlock_irqrestore() và nó sẽ không bao giờ
ngủ.


try_wait_for_completion()/completion_done():
--------------------------------------------

Hàm try_wait_for_completion() sẽ không đưa luồng vào trạng thái chờ
xếp hàng mà thay vào đó trả về sai nếu nó cần xếp hàng (chặn) luồng,
nếu không, nó sẽ sử dụng một lần hoàn thành đã đăng và trả về true ::

bool try_wait_for_completion(hoàn thành cấu trúc *xong)

Cuối cùng, để kiểm tra trạng thái hoàn thành mà không thay đổi nó theo bất kỳ cách nào,
gọi Complete_done(), trả về sai nếu không có thông tin nào được đăng
những lần hoàn thành chưa được người phục vụ sử dụng (ngụ ý rằng có
bồi bàn) và đúng nếu không::

bool Complete_done(hoàn thành cấu trúc *xong)

Cả try_wait_for_completion() và Complete_done() đều an toàn để được gọi vào
IRQ hoặc bối cảnh nguyên tử.
