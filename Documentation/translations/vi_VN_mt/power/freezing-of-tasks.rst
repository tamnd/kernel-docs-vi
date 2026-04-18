.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/power/freezing-of-tasks.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Đóng băng nhiệm vụ
===================

(C) 2007 Rafael J. Wysocki <rjw@sisk.pl>, GPL

I. Việc đóng băng nhiệm vụ là gì?
=================================

Việc đóng băng các tác vụ là một cơ chế trong đó không gian người dùng xử lý và một số
các luồng nhân được kiểm soát trong quá trình ngủ đông hoặc tạm dừng toàn hệ thống (trên một số
kiến trúc).

II. Nó hoạt động như thế nào?
=====================

Có một cờ cho mỗi nhiệm vụ (PF_NOFREEZE) và ba trạng thái cho mỗi nhiệm vụ
(TASK_FROZEN, TASK_FREEZABLE và __TASK_FREEZABLE_UNSAFE) được sử dụng cho việc đó.
Các tác vụ chưa đặt PF_NOFREEZE (tất cả các tác vụ trong không gian người dùng và một số tác vụ kernel
các sợi) được coi là 'có thể đóng băng' và được xử lý theo cách đặc biệt trước khi
hệ thống chuyển sang trạng thái ngủ cũng như trước khi hình ảnh ngủ đông được tạo
(ngủ đông được đề cập trực tiếp trong phần tiếp theo, nhưng mô tả được áp dụng
để tạm dừng toàn hệ thống).

Cụ thể, bước đầu tiên của quy trình ngủ đông là hàm
đóng băng_processes() (được xác định trong kernel/power/process.c) được gọi.  Trên toàn hệ thống
khóa tĩnh Frozen_active (ngược lại với cờ hoặc trạng thái trên mỗi tác vụ) được sử dụng để
cho biết liệu hệ thống có phải trải qua hoạt động đóng băng hay không. Và
đóng băng_processes() đặt khóa tĩnh này.  Sau này, nó thực thi
try_to_freeze_tasks() gửi tín hiệu giả đến tất cả các quy trình không gian của người dùng và
đánh thức tất cả các chủ đề kernel. Tất cả các nhiệm vụ có thể đóng băng phải phản ứng với điều đó bằng cách
gọi try_to_freeze(), kết quả là gọi tới __refrigerator() (được xác định
trong kernel/freezer.c), làm thay đổi trạng thái của tác vụ thành TASK_FROZEN và khiến
nó lặp lại cho đến khi được đánh thức bởi một lần đánh thức TASK_FROZEN rõ ràng. Sau đó, nhiệm vụ đó
được coi là 'đóng băng' và do đó tập hợp các chức năng xử lý cơ chế này là
được gọi là 'tủ đông' (các chức năng này được định nghĩa trong
kernel/power/process.c, kernel/freezer.c & include/linux/freezer.h). Không gian người dùng
các tác vụ thường bị đóng băng trước các luồng nhân.

__refrigerator() không được gọi trực tiếp.  Thay vào đó, hãy sử dụng
Hàm try_to_freeze() (được xác định trong include/linux/freezer.h), để kiểm tra
nếu tác vụ bị đóng băng và làm cho tác vụ đó nhập __refrigerator().

Đối với các quy trình không gian người dùng, try_to_freeze() được gọi tự động từ
mã xử lý tín hiệu, nhưng các luồng hạt nhân có thể đóng băng cần gọi nó
rõ ràng ở những nơi thích hợp hoặc sử dụng wait_event_freezable() hoặc
macro wait_event_freezable_timeout() (được xác định trong include/linux/wait.h)
đặt tác vụ ở chế độ ngủ (TASK_INTERRUPTIBLE) hoặc đóng băng nó (TASK_FROZEN) nếu
tủ đông_active được đặt. Vòng lặp chính của một luồng hạt nhân có thể đóng băng có thể trông giống như
như sau::

set_freezable();

trong khi (đúng) {
		struct task_struct *tsk = NULL;

wait_event_freezable(oom_reaper_wait, oom_reaper_list != NULL);
		spin_lock_irq(&oom_reaper_lock);
		nếu (oom_reaper_list != NULL) {
			tsk = oom_reaper_list;
			oom_reaper_list = tsk->oom_reaper_list;
		}
		spin_unlock_irq(&oom_reaper_lock);

nếu (tsk)
			oom_reap_task(tsk);
	}

(từ mm/oom_kill.c::oom_reaper()).

Nếu một luồng hạt nhân có thể đóng băng không được đặt ở trạng thái đóng băng sau khi đóng băng
đã bắt đầu hoạt động đóng băng, việc đóng băng các tác vụ sẽ thất bại và
toàn bộ quá trình chuyển đổi toàn hệ thống sẽ bị hủy bỏ.  Vì lý do này, có thể đóng băng
các luồng nhân phải gọi try_to_freeze() ở đâu đó hoặc sử dụng một trong các
Các macro wait_event_freezable() và wait_event_freezable_timeout().

Sau khi trạng thái bộ nhớ hệ thống đã được khôi phục từ hình ảnh ngủ đông và
các thiết bị đã được khởi tạo lại, hàm thaw_processes() sẽ được gọi trong
để đánh thức từng nhiệm vụ bị đóng băng.  Sau đó, những nhiệm vụ bị đóng băng sẽ rời đi
__refrigerator() và tiếp tục chạy.


Cơ sở lý luận đằng sau các chức năng xử lý việc đóng băng và rã đông các nhiệm vụ
-------------------------------------------------------------------------

đóng băng_processes():
  - chỉ đóng băng các tác vụ trong không gian người dùng

đóng băng_kernel_threads():
  - đóng băng tất cả các tác vụ (bao gồm cả các luồng kernel) vì chúng tôi không thể đóng băng
    luồng hạt nhân mà không đóng băng các tác vụ không gian người dùng

thaw_kernel_threads():
  - chỉ làm tan các luồng hạt nhân; điều này đặc biệt hữu ích nếu chúng ta cần làm
    bất cứ điều gì đặc biệt giữa việc rã đông các luồng nhân và việc rã đông
    các tác vụ trong không gian người dùng hoặc nếu chúng tôi muốn trì hoãn việc rã đông các tác vụ trong không gian người dùng

tan_processes():
  - làm tan băng tất cả các tác vụ (bao gồm cả các luồng nhân) vì chúng tôi không thể làm tan băng không gian người dùng
    nhiệm vụ mà không làm tan chủ đề hạt nhân


III. Những chủ đề hạt nhân nào có thể đóng băng được?
========================================

Các luồng hạt nhân không thể đóng băng theo mặc định.  Tuy nhiên, một luồng hạt nhân có thể xóa
PF_NOFREEZE cho chính nó bằng cách gọi set_freezable() (việc đặt lại PF_NOFREEZE
trực tiếp là không được phép).  Từ thời điểm này nó được coi là có thể đóng băng
và phải gọi try_to_freeze() hoặc các biến thể của wait_event_freezable() trong
nơi thích hợp.

IV. Tại sao chúng tôi làm điều đó?
======================

Nói chung, có một số lý do để sử dụng tính năng đóng băng nhiệm vụ:

1. Lý do chính là để ngăn chặn hệ thống tập tin bị hư hỏng sau khi
   ngủ đông.  Hiện tại chúng tôi không có phương tiện kiểm tra đơn giản nào
   hệ thống tập tin, vì vậy nếu có bất kỳ sửa đổi nào được thực hiện đối với dữ liệu hệ thống tập tin và/hoặc
   siêu dữ liệu trên đĩa, chúng tôi không thể đưa chúng trở lại trạng thái trước khi
   sửa đổi.  Đồng thời mỗi hình ảnh ngủ đông chứa một số
   thông tin liên quan đến hệ thống tập tin phải nhất quán với trạng thái của
   dữ liệu trên đĩa và siêu dữ liệu sau khi trạng thái bộ nhớ hệ thống được khôi phục
   từ hình ảnh (nếu không hệ thống tập tin sẽ bị hỏng một cách nghiêm trọng,
   thường khiến chúng gần như không thể sửa chữa được).  Do đó chúng tôi đóng băng
   các tác vụ có thể khiến dữ liệu và siêu dữ liệu của hệ thống tập tin trên đĩa bị
   được sửa đổi sau khi hình ảnh ngủ đông được tạo và trước khi
   hệ thống cuối cùng đã tắt nguồn. Phần lớn trong số này là không gian người dùng
   xử lý, nhưng nếu bất kỳ luồng nhân nào có thể gây ra sự cố như thế này
   để xảy ra, chúng phải có khả năng đóng băng được.

2. Tiếp theo, để tạo image ngủ đông chúng ta cần giải phóng một lượng vừa đủ
   bộ nhớ (khoảng 50% RAM có sẵn) và chúng ta cần làm điều đó trước
   các thiết bị bị vô hiệu hóa vì chúng ta thường cần chúng để hoán đổi.
   Sau đó, sau khi bộ nhớ dành cho hình ảnh đã được giải phóng, chúng ta không muốn thực hiện các tác vụ nữa
   để phân bổ bộ nhớ bổ sung và chúng tôi ngăn họ làm điều đó bằng cách
   đóng băng chúng sớm hơn. [Tất nhiên, điều này cũng có nghĩa là trình điều khiển thiết bị
   không nên phân bổ lượng bộ nhớ đáng kể từ .suspend() của chúng
   gọi lại trước khi ngủ đông, nhưng đây là một vấn đề riêng.]

3. Lý do thứ ba là để ngăn chặn các tiến trình không gian người dùng và một số luồng kernel
   can thiệp vào việc tạm dừng và tiếp tục các thiết bị.  Một không gian người dùng
   quá trình chạy trên CPU thứ hai trong khi chúng tôi đang tạm dừng thiết bị có thể, ví dụ:
   ví dụ, rắc rối và không có nhiệm vụ bị đóng băng, chúng tôi sẽ cần một số
   các biện pháp bảo vệ chống lại các điều kiện chủng tộc có thể xảy ra trong trường hợp như vậy.

Mặc dù Linus Torvalds không thích việc đóng băng các nhiệm vụ nhưng anh ấy đã nói điều này trong một
trong số các cuộc thảo luận về LKML (ZZ0000ZZ

"RJW:> Tại sao chúng tôi đóng băng các tác vụ hoặc tại sao chúng tôi đóng băng các luồng nhân?

Linus: Theo nhiều cách, 'không hề'.

Tôi ZZ0000ZZ nhận thấy các vấn đề về hàng đợi yêu cầu IO và chúng tôi thực sự không thể làm được
s2ram với một số thiết bị ở giữa DMA.  Vì vậy chúng tôi muốn có thể
tránh ZZ0001ZZ, không có câu hỏi nào về điều đó.  Và tôi nghi ngờ rằng việc dừng lại
luồng của người dùng và sau đó chờ đồng bộ hóa thực tế là một trong những cách dễ dàng hơn
những cách để làm như vậy.

Vì vậy, trong thực tế, 'tất cả' có thể trở thành 'tại sao lại đóng băng các luồng hạt nhân?' và
việc đóng băng các chủ đề của người dùng mà tôi thấy không thực sự đáng phản đối."

Tuy nhiên, vẫn có những luồng nhân có thể muốn được đóng băng.  Ví dụ, nếu
một luồng nhân thuộc về trình điều khiển thiết bị sẽ truy cập trực tiếp vào thiết bị, nó
về nguyên tắc cần biết khi nào thiết bị bị treo để không cố gắng
để truy cập vào thời điểm đó.  Tuy nhiên, nếu luồng kernel có thể đóng băng được, nó sẽ
bị đóng băng trước khi lệnh gọi lại .suspend() của trình điều khiển được thực thi và nó sẽ
tan băng sau khi lệnh gọi lại .resume() của trình điều khiển chạy, vì vậy nó sẽ không truy cập được
thiết bị trong khi nó bị treo.

4. Một lý do khác để đóng băng các tác vụ là để ngăn các quá trình không gian người dùng khỏi
   nhận ra rằng hoạt động ngủ đông (hoặc tạm dừng) diễn ra.  Lý tưởng nhất là người dùng
   các quy trình không gian không nên nhận thấy rằng hoạt động trên toàn hệ thống như vậy có
   đã xảy ra và sẽ tiếp tục chạy mà không gặp vấn đề gì sau khi khôi phục
   (hoặc tiếp tục từ việc đình chỉ).  Thật không may, trong trường hợp chung nhất, điều này
   là khá khó khăn để đạt được nếu không có sự đóng băng của các nhiệm vụ.  Hãy xem xét,
   ví dụ: một quy trình phụ thuộc vào việc tất cả các CPU đều trực tuyến trong khi nó
   đang chạy.  Vì chúng ta cần tắt các CPU không khởi động được trong thời gian ngủ đông,
   nếu quá trình này không bị đóng băng, nó có thể nhận thấy rằng số lượng CPU đã
   đã thay đổi và có thể bắt đầu hoạt động không chính xác vì lý do đó.

V. Có bất kỳ vấn đề nào liên quan đến việc đóng băng nhiệm vụ không?
===========================================================

Vâng, có.

Trước hết, việc đóng băng các luồng nhân có thể khó khăn nếu chúng phụ thuộc vào một
trên cái khác.  Ví dụ: nếu luồng nhân A chờ hoàn thành (trong
Trạng thái TASK_UNINTERRUPTIBLE) cần được thực hiện bằng luồng hạt nhân có thể đóng băng B
và B bị đóng băng trong lúc đó thì A sẽ bị chặn cho đến khi B tan băng, điều này
có thể là điều không mong muốn.  Đó là lý do tại sao các luồng kernel không thể đóng băng theo mặc định.

Thứ hai, có hai vấn đề sau liên quan đến việc đóng băng người dùng
quá trình không gian:

1. Đưa các tiến trình vào trạng thái ngủ liên tục sẽ làm sai lệch mức tải trung bình.
2. Bây giờ chúng ta đã có FUSE, cùng với framework để thực hiện trình điều khiển thiết bị trong
   không gian người dùng, nó thậm chí còn phức tạp hơn vì một số quy trình không gian người dùng được
   hiện đang làm những việc mà các luồng hạt nhân làm
   (ZZ0000ZZ

Vấn đề 1. dường như có thể khắc phục được, mặc dù cho đến nay nó vẫn chưa được khắc phục.  các
một vấn đề khác nghiêm trọng hơn, nhưng có vẻ như chúng ta có thể giải quyết nó bằng cách sử dụng
trình thông báo ngủ đông (và tạm dừng) (tuy nhiên, trong trường hợp đó, chúng tôi sẽ không thể
tránh việc quá trình không gian người dùng nhận ra rằng chế độ ngủ đông đang diễn ra
nơi).

Cũng có những vấn đề mà việc đóng băng các nhiệm vụ có xu hướng bộc lộ, mặc dù
họ không liên quan trực tiếp đến nó.  Ví dụ: nếu request_firmware() là
được gọi từ quy trình .resume() của trình điều khiển thiết bị, nó sẽ hết thời gian chờ và cuối cùng
không thành công, vì quy trình đất đai của người dùng đáp ứng yêu cầu đã bị đóng băng
vào thời điểm này.  Vì vậy, có vẻ như thất bại là do nhiệm vụ bị đóng băng.
Tuy nhiên, giả sử rằng tệp chương trình cơ sở nằm trên một hệ thống tệp có thể truy cập được
chỉ thông qua một thiết bị khác chưa được tiếp tục.  Trong trường hợp đó,
request_firmware() sẽ thất bại bất kể việc đóng băng nhiệm vụ có hay không
được sử dụng.  Do đó, vấn đề không thực sự liên quan đến việc đóng băng
nhiệm vụ, vì dù sao thì nó cũng tồn tại.

Trình điều khiển phải có tất cả phần mềm cơ sở mà nó có thể cần trong RAM trước khi gọi hàm tạm dừng().
Nếu việc giữ chúng là không thực tế, chẳng hạn như do kích thước của chúng, thì chúng phải được
đã yêu cầu đủ sớm bằng cách sử dụng trình thông báo tạm dừng API được mô tả trong
Tài liệu/driver-api/pm/notifiers.rst.

VI. Có biện pháp phòng ngừa nào cần được thực hiện để ngăn chặn sự cố đóng băng không?
=======================================================================

Vâng, có.

Trước hết, hãy lấy khóa 'system_transition_mutex' để loại trừ lẫn nhau
đoạn mã từ chế độ ngủ trên toàn hệ thống như tạm dừng/ngủ đông thì không
được khuyến khích.  Nếu có thể, đoạn mã đó phải nối vào
tạm dừng/ngủ đông thông báo để đạt được sự loại trừ lẫn nhau. Nhìn vào
Mã CPU-Hotplug (kernel/cpu.c) làm ví dụ.

Tuy nhiên, nếu điều đó không khả thi và việc lấy 'system_transition_mutex' là
thấy cần thiết, chúng tôi không khuyến khích gọi trực tiếp
mutex_[un]lock(&system_transition_mutex) vì điều đó có thể dẫn đến đóng băng
thất bại, bởi vì nếu mã tạm dừng/ngủ đông có được thành công
Khóa 'system_transition_mutex' và do đó thực thể khác không thể lấy được
khóa thì tác vụ đó sẽ bị chặn ở trạng thái TASK_UNINTERRUPTIBLE. Như một
hậu quả là tủ đông sẽ không thể đóng băng nhiệm vụ đó, dẫn đến
sự cố đóng băng.

Tuy nhiên, API [un]lock_system_sleep() vẫn an toàn để sử dụng trong trường hợp này,
vì họ yêu cầu tủ đông bỏ qua nhiệm vụ đóng băng này, vì dù sao thì đó cũng là
"đủ đông lạnh" vì nó bị chặn trên 'system_transition_mutex', điều này sẽ
chỉ được phát hành sau khi toàn bộ chuỗi tạm dừng/ngủ đông hoàn tất.  Vì vậy, để
tóm tắt, sử dụng [un]lock_system_sleep() thay vì sử dụng trực tiếp
mutex_[un]lock(&system_transition_mutex). Điều đó sẽ ngăn chặn sự cố đóng băng.

V. Linh tinh
================

/sys/power/pm_freeze_timeout kiểm soát thời gian đóng băng tối đa là bao lâu
tất cả các tiến trình không gian người dùng hoặc tất cả các luồng hạt nhân có thể đóng băng, tính theo đơn vị
mili giây.  Giá trị mặc định là 20000, với phạm vi số nguyên không dấu.
