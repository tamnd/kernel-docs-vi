.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/locking/locktypes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _kernel_hacking_locktypes:

==================================
Các loại khóa và quy tắc của chúng
==================================

Giới thiệu
============

Hạt nhân cung cấp nhiều loại khóa nguyên thủy khác nhau có thể được chia
thành ba loại:

- Khóa ngủ
 - Khóa cục bộ CPU
 - Khóa xoay

Tài liệu này mô tả khái niệm các loại khóa này và cung cấp các quy tắc
để lồng chúng, bao gồm các quy tắc sử dụng theo PREEMPT_RT.


Khóa danh mục
===============

Khóa ngủ
--------------

Khóa ngủ chỉ có thể có được trong bối cảnh nhiệm vụ được ưu tiên trước.

Mặc dù việc triển khai cho phép try_lock() từ các bối cảnh khác, nhưng đó là
cần thiết để đánh giá cẩn thận sự an toàn của unlock() cũng như của
thử_lock().  Hơn nữa, cũng cần phải đánh giá việc gỡ lỗi
phiên bản của những nguyên thủy này.  Nói tóm lại, đừng lấy khóa ngủ từ
các bối cảnh khác trừ khi không có lựa chọn nào khác.

Các loại khóa ngủ:

- mutex
 - rt_mutex
 - ngữ nghĩa
 - rw_semaphore
 - ww_mutex
 - percpu_rw_semaphore

Trên hạt nhân PREEMPT_RT, các loại khóa này được chuyển đổi thành khóa ngủ:

- local_lock
 - spinlock_t
 - rwlock_t


Khóa cục bộ CPU
---------------

- local_lock

Trên các hạt nhân không phải PREEMPT_RT, các hàm local_lock là các hàm bao quanh
quyền ưu tiên và ngắt vô hiệu hóa nguyên thủy. Ngược lại với các loại khóa khác
cơ chế, vô hiệu hóa quyền ưu tiên hoặc ngắt hoàn toàn là cục bộ CPU
cơ chế kiểm soát đồng thời và không phù hợp với đồng thời giữa các CPU
kiểm soát.


Ổ khóa quay
--------------

- raw_spinlock_t
 - spinlocks bit

Trên các hạt nhân không phải PREEMPT_RT, các loại khóa này cũng là khóa quay:

- spinlock_t
 - rwlock_t

Khóa xoay hoàn toàn vô hiệu hóa quyền ưu tiên và chức năng khóa / mở khóa
có thể có các hậu tố áp dụng các biện pháp bảo vệ bổ sung:

=============================================================================
 _bh() Tắt/bật nửa dưới (ngắt mềm)
 _irq() Tắt/bật ngắt
 _irqsave/restore() Lưu và tắt/khôi phục trạng thái tắt ngắt
 =============================================================================


Ngữ nghĩa của chủ sở hữu
===============

Các loại khóa nói trên ngoại trừ semaphores đều có chủ sở hữu nghiêm ngặt
ngữ nghĩa:

Bối cảnh (nhiệm vụ) đã thu được khóa phải giải phóng nó.

rw_semaphores có giao diện đặc biệt cho phép người không phải chủ sở hữu phát hành
độc giả.


rtmutex
=======

RT-mutexes là các mutex có hỗ trợ kế thừa ưu tiên (PI).

PI có những hạn chế đối với các hạt nhân không phải PREEMPT_RT do quyền ưu tiên và
ngắt các phần bị vô hiệu hóa.

PI rõ ràng không thể ưu tiên bị vô hiệu hóa quyền ưu tiên hoặc bị vô hiệu hóa ngắt
vùng mã, ngay cả trên hạt nhân PREEMPT_RT.  Thay vào đó, hạt nhân PREEMPT_RT
thực thi hầu hết các vùng mã như vậy trong ngữ cảnh nhiệm vụ có thể ưu tiên, đặc biệt là
xử lý ngắt và ngắt mềm.  Chuyển đổi này cho phép spinlock_t
và rwlock_t sẽ được triển khai thông qua RT-mutexes.


ngữ nghĩa
=========

semaphore là một triển khai semaphore đếm.

Semaphores thường được sử dụng cho cả việc tuần tự hóa và chờ đợi, nhưng cách sử dụng mới
thay vào đó, các trường hợp nên sử dụng các cơ chế chờ đợi và tuần tự hóa riêng biệt, chẳng hạn như
như mutexes và hoàn thành.

ngữ nghĩa và PREEMPT_RT
----------------------------

PREEMPT_RT không thay đổi việc triển khai semaphore vì việc đếm
các đèn hiệu không có khái niệm về chủ sở hữu, do đó ngăn PREEMPT_RT khỏi
cung cấp sự kế thừa ưu tiên cho các ẩn dụ.  Rốt cuộc, một điều chưa biết
chủ sở hữu không thể được tăng cường. Kết quả là, việc chặn trên các ngữ nghĩa có thể
dẫn đến đảo ngược mức độ ưu tiên.


rw_semaphore
============

rw_semaphore là cơ chế khóa nhiều trình đọc và một trình ghi.

Trên các hạt nhân không phải PREEMPT_RT, việc triển khai diễn ra công bằng, do đó ngăn chặn
nhà văn chết đói

rw_semaphore tuân thủ theo mặc định với ngữ nghĩa nghiêm ngặt của chủ sở hữu, nhưng ở đó
tồn tại các giao diện có mục đích đặc biệt cho phép người đọc không phải là chủ sở hữu phát hành.
Các giao diện này hoạt động độc lập với cấu hình kernel.

rw_semaphore và PREEMPT_RT
---------------------------

Hạt nhân PREEMPT_RT ánh xạ rw_semaphore sang một hạt nhân dựa trên rt_mutex riêng biệt
thực hiện, do đó làm thay đổi tính công bằng:

Bởi vì một trình soạn thảo rw_semaphore không thể cấp quyền ưu tiên cho nhiều
 độc giả, một đầu đọc có mức độ ưu tiên thấp được ưu tiên sẽ tiếp tục giữ khóa của nó,
 do đó làm chết đói ngay cả những nhà văn có mức độ ưu tiên cao.  Ngược lại, vì người đọc
 có thể cấp quyền ưu tiên của họ cho một nhà văn, một nhà văn có mức độ ưu tiên thấp được ưu tiên sẽ
 được tăng mức độ ưu tiên cho đến khi nó nhả khóa, do đó ngăn chặn điều đó
 nhà văn khỏi những độc giả chết đói.


local_lock
==========

local_lock cung cấp phạm vi được đặt tên cho các phần quan trọng được bảo vệ
bằng cách vô hiệu hóa quyền ưu tiên hoặc ngắt.

Trên các hạt nhân không phải PREEMPT_RT, các hoạt động local_lock ánh xạ tới quyền ưu tiên và
ngắt vô hiệu hóa và kích hoạt nguyên thủy:

=========================================================
 local_lock(&llock) preempt_disable()
 local_unlock(&llock) preempt_enable()
 local_lock_irq(&llock) local_irq_disable()
 local_unlock_irq(&llock) local_irq_enable()
 local_lock_irqsave(&llock) local_irq_save()
 local_unlock_irqrestore(&llock) local_irq_restore()
 =========================================================

Phạm vi được đặt tên của local_lock có hai ưu điểm so với phạm vi thông thường
nguyên thủy:

- Tên khóa cho phép phân tích tĩnh và cũng là tài liệu rõ ràng
    về phạm vi bảo vệ trong khi các nguyên thủy thông thường là không có phạm vi và
    mờ đục.

- Nếu bật lockdep, local_lock sẽ nhận được sơ đồ khóa cho phép
    xác nhận tính đúng đắn của việc bảo vệ. Điều này có thể phát hiện những trường hợp
    ví dụ: một hàm sử dụng preempt_disable() làm cơ chế bảo vệ là
    được gọi từ bối cảnh ngắt hoặc ngắt mềm. Bên cạnh đó
    lockdep_assert_held(&llock) hoạt động giống như bất kỳ khóa nguyên thủy nào khác.

local_lock và PREEMPT_RT
-------------------------

Hạt nhân PREEMPT_RT ánh xạ local_lock thành spinlock_t trên mỗi CPU, do đó thay đổi
ngữ nghĩa:

- Mọi thay đổi của spinlock_t cũng áp dụng cho local_lock.

sử dụng local_lock
----------------

local_lock nên được sử dụng trong các trường hợp vô hiệu hóa quyền ưu tiên hoặc
ngắt là hình thức kiểm soát đồng thời thích hợp để bảo vệ
Cấu trúc dữ liệu per-CPU trên hạt nhân không phải PREEMPT_RT.

local_lock không phù hợp để bảo vệ chống lại sự chiếm quyền hoặc gián đoạn trên một
Hạt nhân PREEMPT_RT do ngữ nghĩa spinlock_t cụ thể của PREEMPT_RT.

Phạm vi cục bộ và nửa dưới của CPU
-------------------------------

Các biến Per-CPU chỉ được truy cập trong ngữ cảnh softirq không nên dựa vào
giả định rằng bối cảnh này được bảo vệ ngầm do
không được ưu tiên trước. Trong kernel PREEMPT_RT, ngữ cảnh softirq có thể được ưu tiên và
đồng bộ hóa mọi phần bị vô hiệu hóa ở nửa dưới thông qua kết quả ngữ cảnh ngầm định
trong một "khóa hạt nhân lớn" ngầm định trên mỗi CPU.

Một local_lock_t cùng với local_lock_nested_bh() và
local_unlock_nested_bh() cho các thao tác khóa giúp xác định khóa
phạm vi.

Khi lockdep được bật, các chức năng này xác minh rằng quyền truy cập cấu trúc dữ liệu
xảy ra trong bối cảnh softirq.
Không giống như local_lock(), local_unlock_nested_bh() không vô hiệu hóa quyền ưu tiên và
không thêm chi phí khi sử dụng mà không có lockdep.

Trên kernel PREEMPT_RT, local_lock_t hoạt động như một khóa thực sự và
local_unlock_nested_bh() tuần tự hóa quyền truy cập vào cấu trúc dữ liệu, cho phép
loại bỏ tuần tự hóa thông qua local_bh_disable().

raw_spinlock_t và spinlock_t
=============================

raw_spinlock_t
--------------

raw_spinlock_t là triển khai khóa quay nghiêm ngặt trong tất cả các hạt nhân,
bao gồm cả hạt nhân PREEMPT_RT.  Chỉ sử dụng raw_spinlock_t trong trường hợp thực sự quan trọng
mã lõi, xử lý ngắt cấp thấp và những nơi vô hiệu hóa
ví dụ, cần phải có quyền ưu tiên hoặc ngắt để truy cập một cách an toàn
trạng thái phần cứng.  raw_spinlock_t đôi khi cũng có thể được sử dụng khi
phần quan trọng rất nhỏ, do đó tránh được chi phí RT-mutex.

spinlock_t
----------

Ngữ nghĩa của spinlock_t thay đổi theo trạng thái PREEMPT_RT.

Trên kernel không phải PREEMPT_RT, spinlock_t được ánh xạ tới raw_spinlock_t và có
ngữ nghĩa hoàn toàn giống nhau.

spinlock_t và PREEMPT_RT
-------------------------

Trên kernel PREEMPT_RT, spinlock_t được ánh xạ tới một triển khai riêng
dựa trên rt_mutex làm thay đổi ngữ nghĩa:

- Quyền ưu tiên không bị vô hiệu hóa.

- Các hậu tố liên quan đến ngắt cứng của spin_lock/spin_unlock
   các hoạt động (_irq, _irqsave / _irqrestore) không ảnh hưởng đến CPU
   ngắt trạng thái vô hiệu hóa.

- Hậu tố liên quan đến ngắt mềm (_bh()) vẫn vô hiệu hóa softirq
   người xử lý.

Các hạt nhân không phải PREEMPT_RT vô hiệu hóa quyền ưu tiên để có được hiệu ứng này.

Hạt nhân PREEMPT_RT sử dụng khóa trên mỗi CPU để tuần tự hóa
   đã bật quyền ưu tiên. Khóa vô hiệu hóa trình xử lý softirq và cả
   ngăn chặn việc quay trở lại do quyền ưu tiên nhiệm vụ.

Hạt nhân PREEMPT_RT bảo tồn tất cả các ngữ nghĩa spinlock_t khác:

- Các tác vụ có spinlock_t không được di chuyển.  Hạt nhân không phải PREEMPT_RT
   tránh di chuyển bằng cách vô hiệu hóa quyền ưu tiên.  Thay vào đó là hạt nhân PREEMPT_RT
   vô hiệu hóa di chuyển, điều này đảm bảo rằng các con trỏ tới các biến trên mỗi CPU
   vẫn có hiệu lực ngay cả khi nhiệm vụ được ưu tiên.

- Trạng thái tác vụ được bảo toàn trong quá trình thu thập spinlock, đảm bảo rằng
   quy tắc trạng thái nhiệm vụ áp dụng cho tất cả các cấu hình kernel.  Không phải PREEMPT_RT
   hạt nhân để lại trạng thái nhiệm vụ không bị ảnh hưởng.  Tuy nhiên, PREEMPT_RT phải thay đổi
   trạng thái nhiệm vụ nếu nhiệm vụ chặn trong quá trình thu thập.  Vì vậy nó tiết kiệm
   trạng thái nhiệm vụ hiện tại trước khi chặn và đánh thức khóa tương ứng
   khôi phục nó, như hiển thị bên dưới::

nhiệm vụ->trạng thái = TASK_INTERRUPTIBLE
     khóa()
       khối()
         nhiệm vụ->saved_state = nhiệm vụ->trạng thái
	 nhiệm vụ->trạng thái = TASK_UNINTERRUPTIBLE
	 lịch trình()
					khóa đánh thức
					  nhiệm vụ->trạng thái = nhiệm vụ->đã lưu_state

Các kiểu đánh thức khác thường sẽ đặt trạng thái nhiệm vụ một cách vô điều kiện
   tới RUNNING, nhưng điều đó không có tác dụng ở đây vì nhiệm vụ phải được giữ nguyên
   bị chặn cho đến khi có khóa.  Vì vậy, khi không khóa
   đánh thức cố gắng đánh thức một tác vụ bị chặn đang chờ spinlock, nó
   thay vào đó đặt trạng thái đã lưu thành RUNNING.  Sau đó, khi khóa
   quá trình thu thập hoàn tất, quá trình đánh thức khóa sẽ đặt trạng thái tác vụ thành trạng thái đã lưu
   trạng thái, trong trường hợp này đặt nó thành RUNNING::

nhiệm vụ->trạng thái = TASK_INTERRUPTIBLE
     khóa()
       khối()
         nhiệm vụ->saved_state = nhiệm vụ->trạng thái
	 nhiệm vụ->trạng thái = TASK_UNINTERRUPTIBLE
	 lịch trình()
					đánh thức không khóa
					  nhiệm vụ-> đã lưu_state = TASK_RUNNING

khóa đánh thức
					  nhiệm vụ->trạng thái = nhiệm vụ->đã lưu_state

Điều này đảm bảo rằng sự thức tỉnh thực sự không thể bị mất.


rwlock_t
========

rwlock_t là cơ chế khóa nhiều trình đọc và một trình ghi.

Các hạt nhân không phải PREEMPT_RT triển khai rwlock_t như một khóa quay và
quy tắc hậu tố của spinlock_t áp dụng tương ứng. Việc thực hiện là công bằng,
do đó ngăn chặn nạn đói của nhà văn.

rwlock_t và PREEMPT_RT
-----------------------

Hạt nhân PREEMPT_RT ánh xạ rwlock_t sang một hạt nhân dựa trên rt_mutex riêng biệt
thực hiện, do đó thay đổi ngữ nghĩa:

- Tất cả những thay đổi về spinlock_t cũng áp dụng cho rwlock_t.

- Bởi vì người viết rwlock_t không thể cấp quyền ưu tiên cho nhiều người
   độc giả, một đầu đọc có mức độ ưu tiên thấp được ưu tiên sẽ tiếp tục giữ khóa của nó,
   do đó làm chết đói ngay cả những nhà văn có mức độ ưu tiên cao.  Ngược lại, vì người đọc
   có thể cấp quyền ưu tiên của họ cho một nhà văn, một nhà văn có mức độ ưu tiên thấp được ưu tiên
   sẽ được tăng mức độ ưu tiên cho đến khi nó nhả khóa, do đó
   ngăn chặn nhà văn đó bỏ đói độc giả.


PREEMPT_RT hãy cẩn thận
==================

local_lock trên RT
----------------

Việc ánh xạ local_lock tới spinlock_t trên hạt nhân PREEMPT_RT có một số
những hàm ý. Ví dụ: trên kernel không phải PREEMPT_RT, đoạn mã sau
trình tự hoạt động như mong đợi::

local_lock_irq(&local_lock);
  raw_spin_lock(&lock);

và hoàn toàn tương đương với::

raw_spin_lock_irq(&lock);

Trên kernel PREEMPT_RT, chuỗi mã này bị hỏng vì local_lock_irq()
được ánh xạ tới spinlock_t trên mỗi CPU, nó không vô hiệu hóa các ngắt cũng như không
quyền ưu tiên. Chuỗi mã sau đây hoạt động hoàn toàn chính xác trên cả hai
Hạt nhân PREEMPT_RT và không phải PREEMPT_RT::

local_lock_irq(&local_lock);
  spin_lock(&lock);

Một cảnh báo khác với các khóa cục bộ là mỗi local_lock có một khóa cụ thể.
phạm vi bảo vệ. Vậy phép thay thế sau đây là sai::

func1()
  {
    local_irq_save(cờ);    -> local_lock_irqsave(&local_lock_1, cờ);
    func3();
    local_irq_restore(cờ); -> local_unlock_irqrestore(&local_lock_1, cờ);
  }

func2()
  {
    local_irq_save(cờ);    -> local_lock_irqsave(&local_lock_2, cờ);
    func3();
    local_irq_restore(cờ); -> local_unlock_irqrestore(&local_lock_2, cờ);
  }

func3()
  {
    lockdep_assert_irqs_disabled();
    access_protected_data();
  }

Trên hạt nhân không phải PREEMPT_RT, điều này hoạt động chính xác, nhưng trên hạt nhân PREEMPT_RT
local_lock_1 và local_lock_2 khác biệt và không thể tuần tự hóa người gọi
của func3(). Ngoài ra, xác nhận lockdep sẽ kích hoạt trên kernel PREEMPT_RT
bởi vì local_lock_irqsave() không vô hiệu hóa các ngắt do
Ngữ nghĩa dành riêng cho PREEMPT_RT của spinlock_t. Sự thay thế đúng là::

func1()
  {
    local_irq_save(cờ);    -> local_lock_irqsave(&local_lock, cờ);
    func3();
    local_irq_restore(cờ); -> local_unlock_irqrestore(&local_lock, cờ);
  }

func2()
  {
    local_irq_save(cờ);    -> local_lock_irqsave(&local_lock, cờ);
    func3();
    local_irq_restore(cờ); -> local_unlock_irqrestore(&local_lock, cờ);
  }

func3()
  {
    lockdep_assert_held(&local_lock);
    access_protected_data();
  }


spinlock_t và rwlock_t
-----------------------

Những thay đổi về ngữ nghĩa spinlock_t và rwlock_t trên hạt nhân PREEMPT_RT
có một vài ý nghĩa.  Ví dụ: trên hạt nhân không phải PREEMPT_RT,
chuỗi mã sau hoạt động như mong đợi::

local_irq_disable();
   spin_lock(&lock);

và hoàn toàn tương đương với::

spin_lock_irq(&lock);

Điều tương tự cũng áp dụng cho các biến thể hậu tố rwlock_t và _irqsave().

Trên kernel PREEMPT_RT, chuỗi mã này bị hỏng do RT-mutex yêu cầu
bối cảnh hoàn toàn được ưu tiên trước.  Thay vào đó, hãy sử dụng spin_lock_irq() hoặc
spin_lock_irqsave() và các đối tác mở khóa của chúng.  Trong những trường hợp
việc vô hiệu hóa và khóa ngắt phải được tách biệt, PREEMPT_RT cung cấp một
cơ chế local_lock.  Việc nhận local_lock sẽ ghim tác vụ vào CPU,
cho phép thu được những thứ như khóa bị vô hiệu hóa ngắt trên mỗi CPU.
Tuy nhiên, phương pháp này chỉ nên được sử dụng khi thực sự cần thiết.

Một kịch bản điển hình là bảo vệ các biến trên mỗi CPU trong ngữ cảnh luồng ::

struct foo *p = get_cpu_ptr(&var1);

spin_lock(&p->lock);
  p->count += this_cpu_read(var2);

Đây là mã đúng trên hạt nhân không phải PREEMPT_RT, nhưng trên hạt nhân PREEMPT_RT
điều này phá vỡ. Sự thay đổi ngữ nghĩa spinlock_t dành riêng cho PREEMPT_RT
không cho phép lấy p->lock vì get_cpu_ptr() ngầm vô hiệu hóa
quyền ưu tiên. Sự thay thế sau đây hoạt động trên cả hai hạt nhân ::

struct foo *p;

di chuyển_disable();
  p = this_cpu_ptr(&var1);
  spin_lock(&p->lock);
  p->count += this_cpu_read(var2);

Migrate_disable() đảm bảo rằng tác vụ được ghim trên CPU hiện tại
lần lượt đảm bảo rằng quyền truy cập trên mỗi CPU vào var1 và var2 vẫn được duy trì
cùng CPU trong khi nhiệm vụ vẫn được ưu tiên.

Sự thay thế Migrate_disable() không hợp lệ cho các mục sau
kịch bản::

func()
  {
    struct foo *p;

di chuyển_disable();
    p = this_cpu_ptr(&var1);
    p->val = func2();

Điều này bị hỏng vì Migrate_disable() không bảo vệ chống lại sự quay trở lại từ
một nhiệm vụ ưu tiên. Một sự thay thế đúng cho trường hợp này là::

func()
  {
    struct foo *p;

local_lock(&foo_lock);
    p = this_cpu_ptr(&var1);
    p->val = func2();

Trên hạt nhân không phải PREEMPT_RT, điều này bảo vệ chống lại sự quay trở lại bằng cách vô hiệu hóa
quyền ưu tiên. Trên hạt nhân PREEMPT_RT, điều này đạt được bằng cách lấy
khóa xoay cơ bản trên mỗi CPU.


raw_spinlock_t trên RT
--------------------

Việc có được raw_spinlock_t sẽ vô hiệu hóa quyền ưu tiên và cũng có thể
bị gián đoạn, do đó phần quan trọng phải tránh nhận được một lệnh ngắt thường xuyên
ví dụ: spinlock_t hoặc rwlock_t, phần quan trọng phải tránh
phân bổ bộ nhớ.  Do đó, trên hạt nhân không phải PREEMPT_RT, đoạn mã sau
hoạt động hoàn hảo::

raw_spin_lock(&lock);
  p = kmalloc(sizeof(*p), GFP_ATOMIC);

Nhưng mã này không thành công trên hạt nhân PREEMPT_RT vì bộ cấp phát bộ nhớ
hoàn toàn có thể được ưu tiên trước và do đó không thể được viện dẫn từ nguyên tử thực sự
bối cảnh.  Tuy nhiên, việc gọi bộ cấp phát bộ nhớ là hoàn toàn ổn
trong khi giữ các spinlock không thô bình thường vì chúng không vô hiệu hóa
quyền ưu tiên trên hạt nhân PREEMPT_RT::

spin_lock(&lock);
  p = kmalloc(sizeof(*p), GFP_ATOMIC);


spinlocks bit
-------------

PREEMPT_RT không thể thay thế các khóa quay bit vì một bit đơn lẻ quá
nhỏ để chứa RT-mutex.  Vì vậy, ngữ nghĩa của bit
spinlocks được bảo toàn trên hạt nhân PREEMPT_RT, do đó raw_spinlock_t
hãy cẩn thận cũng áp dụng cho spinlocks bit.

Một số spinlock bit được thay thế bằng spinlock_t thông thường cho PREEMPT_RT
sử dụng các thay đổi mã có điều kiện (#ifdef'ed) tại trang sử dụng.  Ngược lại,
Không cần thay đổi trang web sử dụng để thay thế spinlock_t.
Thay vào đó, các điều kiện trong tệp tiêu đề và việc triển khai khóa lõi
cho phép trình biên dịch thực hiện thay thế một cách minh bạch.


Quy tắc lồng kiểu khóa
=======================

Các quy tắc cơ bản nhất là:

- Các loại khóa cùng loại (ngủ, CPU cục bộ, quay)
    có thể lồng tùy ý miễn là chúng tôn trọng thứ tự khóa chung
    các quy tắc để tránh bế tắc.

- Các loại khóa ngủ không thể lồng bên trong các loại khóa cục bộ và khóa quay CPU.

- Các loại khóa cục bộ và khóa quay CPU có thể lồng vào các loại khóa ngủ.

- Các loại khóa xoay có thể lồng vào bên trong tất cả các loại khóa

Những ràng buộc này áp dụng cả trong PREEMPT_RT và các mặt khác.

Thực tế là PREEMPT_RT thay đổi loại khóa của spinlock_t và
rwlock_t từ quay sang ngủ và thay thế local_lock bằng
per-CPU spinlock_t có nghĩa là chúng không thể lấy được khi đang giữ nguyên
spinlock.  Điều này dẫn đến thứ tự lồng nhau sau đây:

1) Khóa ngủ
  2) spinlock_t, rwlock_t, local_lock
  3) raw_spinlock_t và bit spinlock

Lockdep sẽ khiếu nại nếu những hạn chế này bị vi phạm, cả trong
PREEMPT_RT và ngược lại.