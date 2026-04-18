.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/locking/lockdep-design.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình xác thực tính chính xác của khóa thời gian chạy
=====================================

bắt đầu bởi Ingo Molnar <mingo@redhat.com>

bổ sung của Arjan van de Ven <arjan@linux.intel.com>

Lớp khóa
----------

Đối tượng cơ bản mà trình xác thực vận hành là một 'lớp' khóa.

Một lớp khóa là một nhóm các khóa có logic giống nhau
tôn trọng các quy tắc khóa, ngay cả khi các khóa có thể có nhiều (có thể
hàng chục nghìn) sự khởi tạo. Ví dụ một khóa trong inode
struct là một lớp, trong khi mỗi inode có cách khởi tạo riêng của nó
khóa lớp.

Trình xác nhận theo dõi 'trạng thái sử dụng' của các lớp khóa và theo dõi
sự phụ thuộc giữa các lớp khóa khác nhau. Việc sử dụng khóa cho biết
cách sử dụng khóa liên quan đến bối cảnh IRQ của nó, trong khi khóa
sự phụ thuộc có thể được hiểu là thứ tự khóa, trong đó L1 -> L2 gợi ý rằng
một nhiệm vụ đang cố gắng lấy L2 trong khi giữ L1. Từ lockdep's
nhìn từ góc độ, hai ổ khóa (L1 và L2) không nhất thiết phải liên quan đến nhau; đó
sự phụ thuộc chỉ có nghĩa là thứ tự đã từng xảy ra. Trình xác nhận duy trì một
nỗ lực liên tục để chứng minh việc sử dụng khóa và sự phụ thuộc là chính xác hoặc
người xác nhận sẽ bắn một biểu tượng nếu không chính xác.

Hành vi của một lớp khóa được xây dựng bởi các thể hiện chung của nó:
khi phiên bản đầu tiên của lớp khóa được sử dụng sau khi khởi động lớp
được đăng ký thì tất cả các phiên bản (tiếp theo) sẽ được ánh xạ tới
lớp và do đó cách sử dụng và sự phụ thuộc của chúng sẽ góp phần vào những điều đó
lớp học. Một lớp khóa không biến mất khi một phiên bản khóa biến mất, nhưng
nó có thể bị xóa nếu không gian bộ nhớ của lớp khóa (tĩnh hoặc
Dynamic) được thu hồi, điều này xảy ra chẳng hạn khi một mô-đun được
được dỡ bỏ hoặc hàng đợi công việc bị phá hủy.

Tình trạng
-----

Trình xác thực theo dõi lịch sử sử dụng lớp khóa và chia việc sử dụng thành
(4 cách sử dụng * n STATE + 1) danh mục:

trong đó 4 cách sử dụng có thể là:

- 'từng được giữ trong bối cảnh STATE'
- 'từng được giữ ở dạng khóa đọc trong ngữ cảnh STATE'
- 'từng được giữ khi kích hoạt STATE'
- 'từng được giữ ở dạng khóa đọc khi bật STATE'

trong đó n STATE được mã hóa trong kernel/locking/lockdep_states.h và kể từ
bây giờ chúng bao gồm:

- hardirq
- phần mềm

trong đó loại 1 cuối cùng là:

- 'đã từng sử dụng' [ == !unused ]

Khi các quy tắc khóa bị vi phạm, các bit sử dụng này sẽ được trình bày trong
khóa các thông báo lỗi, bên trong các lọn tóc, với tổng số 2 * n bit STATE.
Một ví dụ giả định ::

modprobe/2287 đang cố lấy khóa:
    (&sio_locks[i].lock){-.-.}, tại: [<c02867fd>] mutex_lock+0x21/0x24

nhưng nhiệm vụ đã bị khóa:
    (&sio_locks[i].lock){-.-.}, tại: [<c02867fd>] mutex_lock+0x21/0x24


Đối với một khóa nhất định, vị trí bit từ trái sang phải cho biết cách sử dụng
của khóa và khóa đọc (nếu tồn tại), đối với mỗi n TRẠNG THÁI được liệt kê
ở trên tương ứng và ký tự được hiển thị ở mỗi vị trí bit
chỉ ra:

=== ========================================================
   '.'  thu được trong khi irqs bị vô hiệu hóa và không ở trong bối cảnh irq
   '-' có được trong bối cảnh irq
   '+' thu được khi bật irqs
   '?'  thu được trong bối cảnh irq khi bật irq.
   === ========================================================

Các bit được minh họa bằng một ví dụ::

(&sio_locks[i].lock){-.-.}, tại: [<c02867fd>] mutex_lock+0x21/0x24
                         ||||
                         ||| \-> softirq bị vô hiệu hóa và không ở trong ngữ cảnh softirq
                         || \--> thu được trong ngữ cảnh softirq
                         | \---> hardirq bị vô hiệu hóa và không ở trong bối cảnh hardirq
                          \----> có được trong bối cảnh hardirq


Đối với một STATE nhất định, liệu STATE đó có từng được lấy khóa hay không
bối cảnh và liệu STATE có được bật hay không sẽ mang lại bốn trường hợp có thể xảy ra như
thể hiện trong bảng dưới đây. Ký tự bit có thể chỉ ra cái nào
trường hợp chính xác là khóa tính đến thời điểm báo cáo.

+--------------+-----------------+--------------+
  ZZ0000ZZ irq đã kích hoạt ZZ0001ZZ
  +--------------+-----------------+--------------+
  ZZ0002ZZ '?'     ZZ0003ZZ
  +--------------+-----------------+--------------+
  ZZ0004ZZ '+' ZZ0005ZZ
  +--------------+-----------------+--------------+

Ký tự '-' gợi ý irq bị tắt vì nếu không thì
ký tự '?' thay vào đó sẽ được hiển thị. Việc khấu trừ tương tự có thể được
cũng đã áp dụng cho '+'.

Các khóa không được sử dụng (ví dụ: mutexes) không thể là một phần nguyên nhân gây ra lỗi.


Quy tắc trạng thái khóa đơn:
------------------------

Khóa là irq-safe có nghĩa là nó đã từng được sử dụng trong ngữ cảnh irq, trong khi khóa
irq-unsafe có nghĩa là nó đã từng được mua khi kích hoạt irq.

Lớp khóa softirq-unsafe cũng tự động được hardirq-unsafe. các
các trạng thái sau phải là độc quyền: chỉ một trong số chúng được phép thiết lập
đối với bất kỳ lớp khóa nào dựa trên cách sử dụng nó ::

<hardirq-safe> hoặc <hardirq-unsafe>
 <softirq-safe> hoặc <softirq-unsafe>

Điều này là do nếu một khóa có thể được sử dụng trong ngữ cảnh irq (irq-safe) thì nó
không bao giờ có được khi kích hoạt irq (irq-không an toàn). Nếu không, một
bế tắc có thể xảy ra. Ví dụ: trong trường hợp sau khóa này
đã được mua lại nhưng trước khi được phát hành, nếu bối cảnh bị gián đoạn
lock sẽ được cố gắng lấy hai lần, điều này tạo ra sự bế tắc,
được gọi là khóa đệ quy bế tắc.

Trình xác nhận phát hiện và báo cáo việc sử dụng khóa vi phạm những điều này
quy tắc trạng thái khóa đơn.

Quy tắc phụ thuộc nhiều khóa:
----------------------------

Không được mua cùng một loại khóa hai lần vì điều này có thể dẫn đến
để khóa các bế tắc đệ quy.

Hơn nữa, hai khóa không thể được lấy theo thứ tự nghịch đảo::

<L1> -> <L2>
 <L2> -> <L1>

bởi vì điều này có thể dẫn đến bế tắc - được gọi là đảo ngược khóa
bế tắc - khi nỗ lực giành được hai ổ khóa sẽ tạo thành một vòng tròn
có thể dẫn đến hai bối cảnh chờ đợi nhau vĩnh viễn. các
người xác nhận sẽ tìm thấy vòng tròn phụ thuộc như vậy với độ phức tạp tùy ý,
tức là có thể có bất kỳ trình tự khóa nào khác giữa khóa thu được
hoạt động; người xác nhận vẫn sẽ tìm hiểu xem những khóa này có thể được
thu được theo kiểu tuần hoàn.

Hơn nữa, không cho phép các phụ thuộc khóa dựa trên cách sử dụng sau đây
giữa hai lớp khóa bất kỳ::

<hardirq-safe> -> <hardirq-không an toàn>
   <softirq-safe> -> <softirq-không an toàn>

Nguyên tắc đầu tiên xuất phát từ thực tế là một khóa an toàn có thể
được thực hiện bởi bối cảnh hardirq, làm gián đoạn khóa hardirq-không an toàn - và
do đó có thể dẫn đến bế tắc đảo ngược khóa. Tương tự như vậy, một softirq-safe
khóa có thể bị lấy bởi bối cảnh softirq, làm gián đoạn quá trình softirq-không an toàn
khóa.

Các quy tắc trên được thực thi đối với bất kỳ trình tự khóa nào xảy ra trong
kernel: khi có được khóa mới, trình xác thực sẽ kiểm tra xem có
bất kỳ vi phạm quy tắc nào giữa khóa mới và bất kỳ khóa nào được giữ.

Khi một lớp khóa thay đổi trạng thái của nó, các khía cạnh sau của vấn đề trên
quy tắc phụ thuộc được thi hành:

- nếu phát hiện thấy khóa an toàn hardirq mới, chúng tôi sẽ kiểm tra xem nó có
  đã lấy bất kỳ khóa cứng không an toàn nào trong quá khứ.

- nếu phát hiện thấy khóa an toàn softirq mới, chúng tôi sẽ kiểm tra xem nó có bị mất không
  bất kỳ khóa softirq-không an toàn nào trong quá khứ.

- nếu phát hiện thấy khóa không an toàn hardirq mới, chúng tôi sẽ kiểm tra xem có khóa nào không
  khóa hardirq-safe đã lấy nó trong quá khứ.

- nếu phát hiện thấy khóa không an toàn softirq mới, chúng tôi sẽ kiểm tra xem có khóa nào không
  khóa softirq-safe đã lấy nó trong quá khứ.

(Một lần nữa, chúng tôi cũng thực hiện những kiểm tra này trên cơ sở bối cảnh ngắt
có thể làm gián đoạn _any_ của các khóa irq-không an toàn hoặc hardirq-không an toàn, mà
có thể dẫn đến bế tắc đảo ngược khóa - ngay cả khi trường hợp khóa đó xảy ra
chưa kích hoạt trong thực tế.)

Ngoại lệ: Các phần phụ thuộc dữ liệu lồng nhau dẫn đến khóa lồng nhau
-------------------------------------------------------------

Có một số trường hợp nhân Linux có được nhiều hơn một
thể hiện của cùng một lớp khóa. Những trường hợp như vậy thường xảy ra khi có
là một số loại phân cấp trong các đối tượng cùng loại. Trong này
trường hợp có một thứ tự "tự nhiên" cố hữu giữa hai đối tượng
(được xác định bởi các thuộc tính của hệ thống phân cấp) và kernel lấy
khóa theo thứ tự cố định này trên mỗi đối tượng.

Một ví dụ về hệ thống phân cấp đối tượng dẫn đến "khóa lồng nhau"
là đối tượng block-dev "toàn bộ đĩa" và block-dev "phân vùng"
đối tượng; phân vùng là "một phần" của toàn bộ thiết bị và miễn là một
luôn lấy toàn bộ khóa đĩa làm khóa cao hơn phân vùng
lock, thứ tự khóa là hoàn toàn chính xác. Người xác nhận không
tự động phát hiện thứ tự tự nhiên này, như quy tắc khóa đằng sau
thứ tự không tĩnh.

Để hướng dẫn người xác nhận về mô hình sử dụng chính xác này, mới
các phiên bản của các kiểu khóa cơ bản khác nhau đã được thêm vào cho phép bạn
chỉ định một "mức độ lồng nhau". Một cuộc gọi ví dụ, dành cho mutex của thiết bị khối,
trông như thế này::

enum bdev_bd_mutex_lock_class
  {
       BD_MUTEX_NORMAL,
       BD_MUTEX_WHOLE,
       BD_MUTEX_PARTITION
  };

mutex_lock_nested(&bdev->bd_contains->bd_mutex, BD_MUTEX_PARTITION);

Trong trường hợp này, việc khóa được thực hiện trên một đối tượng bdev được biết đến là một
phân vùng.

Trình xác thực xử lý một khóa được lấy theo kiểu lồng nhau như một
lớp (phụ) riêng biệt cho mục đích xác nhận.

Lưu ý: Khi thay đổi mã để sử dụng các hàm nguyên thủy _nested(), hãy cẩn thận và
kiểm tra thực sự kỹ lưỡng xem hệ thống phân cấp có được ánh xạ chính xác hay không; mặt khác
bạn có thể nhận được kết quả dương tính giả hoặc âm tính giả.

Chú thích
-----------

Hai cấu trúc có thể được sử dụng để chú thích và kiểm tra vị trí và liệu các khóa nhất định
phải được giữ: lockdep_assert_held*(&lock) and lockdep_*pin_lock(&lock).

Như tên cho thấy, họ macro lockdep_assert_held* xác nhận rằng một
khóa cụ thể được giữ tại một thời điểm nhất định (và tạo WARN() nếu không).
Chú thích này phần lớn được sử dụng trên toàn bộ kernel, ví dụ: hạt nhân/lịch trình/
lõi.c::

void update_rq_clock(struct rq *rq)
  {
	đồng bằng s64;

lockdep_assert_held(&rq->lock);
	[…]
  }

trong đó cần phải giữ rq->lock để cập nhật đồng hồ của rq một cách an toàn.

Họ macro khác là lockdep_*pin_lock(), được thừa nhận là chỉ
được sử dụng cho rq-> khóa ATM. Bất chấp việc áp dụng hạn chế, những chú thích này
tạo WARN() nếu khóa quan tâm được mở khóa "vô tình". Điều này lần lượt
đặc biệt hữu ích khi gỡ lỗi mã bằng lệnh gọi lại, trong đó phần trên
lớp cho rằng khóa vẫn được lấy, nhưng lớp thấp hơn cho rằng nó có thể bị rơi
và lấy lại khóa ("vô tình" giới thiệu các cuộc đua). lockdep_pin_lock()
trả về 'struct pin_cookie' sau đó được lockdep_unpin_lock() sử dụng để kiểm tra
rằng không ai giả mạo ổ khóa, ví dụ: kernel/sched/sched.h::

nội tuyến tĩnh void rq_pin_lock(struct rq *rq, struct rq_flags *rf)
  {
	rf->cookie = lockdep_pin_lock(&rq->lock);
	[…]
  }

nội tuyến tĩnh void rq_unpin_lock(struct rq *rq, struct rq_flags *rf)
  {
	[…]
	lockdep_unpin_lock(&rq->lock, rf->cookie);
  }

Mặc dù các nhận xét về yêu cầu khóa có thể cung cấp thông tin hữu ích,
việc kiểm tra thời gian chạy được thực hiện bởi các chú thích là vô giá khi gỡ lỗi
vấn đề về khóa và chúng có cùng mức độ chi tiết khi kiểm tra
mã.  Luôn thích chú thích khi nghi ngờ!

Bằng chứng về tính đúng đắn 100%:
--------------------------

Trình xác nhận đạt được 'sự đóng' hoàn hảo, về mặt toán học (bằng chứng về việc khóa
tính chính xác) theo nghĩa là đối với mỗi tác vụ đơn lẻ, độc lập
trình tự khóa xảy ra ít nhất một lần trong suốt thời gian tồn tại của
kernel, trình xác thực sẽ chứng minh điều đó một cách chắc chắn 100% rằng không có
sự kết hợp và thời gian của các chuỗi khóa này có thể gây ra bất kỳ loại
bế tắc liên quan đến khóa. [1]_

tức là các kịch bản khóa đa CPU và đa tác vụ phức tạp không cần phải
xảy ra trong thực tế để chứng minh sự bế tắc: chỉ có 'thành phần' đơn giản
chuỗi khóa phải xảy ra ít nhất một lần (bất cứ lúc nào, trong bất kỳ
nhiệm vụ/bối cảnh) để người xác thực có thể chứng minh tính chính xác. (Đối với
Ví dụ, các bế tắc phức tạp thường cần nhiều hơn 3 CPU và
một nhóm nhiệm vụ, bối cảnh và thời gian khó có thể xảy ra
xảy ra, có thể được phát hiện trên hệ thống CPU đơn giản, được tải nhẹ như
ờ!)

Điều này làm giảm đáng kể độ phức tạp của việc khóa QA liên quan đến khóa của
kernel: điều phải làm trong quá trình QA là kích hoạt càng nhiều "đơn giản"
ít nhất có thể, ít nhất là phụ thuộc khóa một tác vụ trong kernel
một lần, để chứng minh tính chính xác của khóa - thay vì phải kích hoạt mọi
có thể kết hợp khóa tương tác giữa các CPU, kết hợp với
mọi kịch bản lồng nhau hardirq và softirq có thể xảy ra (điều này là không thể
làm trong thực tế).

.. [1]

    assuming that the validator itself is 100% correct, and no other
    part of the system corrupts the state of the validator in any way.
    We also assume that all NMI/SMM paths [which could interrupt
    even hardirq-disabled codepaths] are correct and do not interfere
    with the validator. We also assume that the 64-bit 'chain hash'
    value is unique for every lock-chain in the system. Also, lock
    recursion must not be higher than 20.

Hiệu suất:
------------

Các quy tắc trên yêu cầu số lượng ZZ0000ZZ kiểm tra thời gian chạy. Nếu chúng tôi đã làm
rằng đối với mỗi khóa được lấy và đối với mỗi sự kiện kích hoạt irqs, nó sẽ
khiến hệ thống thực tế chậm đến mức không thể sử dụng được. Sự phức tạp của việc kiểm tra
là O(N^2), nên thậm chí chỉ với vài trăm lớp khóa chúng ta vẫn phải làm
hàng chục ngàn séc cho mỗi sự kiện.

Vấn đề này được giải quyết bằng cách kiểm tra bất kỳ 'kịch bản khóa' nào (duy nhất
chuỗi các khóa nối tiếp nhau) chỉ một lần. Một chồng đơn giản
các khóa được giữ được duy trì và giá trị băm 64 bit nhẹ được
được tính toán, hàm băm nào là duy nhất cho mỗi chuỗi khóa. Giá trị băm,
khi chuỗi được xác thực lần đầu tiên, sau đó được đưa vào hàm băm
bảng, bảng băm nào có thể được kiểm tra theo cách không khóa. Nếu
chuỗi khóa xảy ra lại sau đó, bảng băm cho chúng ta biết rằng chúng ta
không cần phải xác nhận lại chuỗi.

Khắc phục sự cố:
----------------

Trình xác thực theo dõi số lượng lớp khóa tối đa MAX_LOCKDEP_KEYS.
Vượt quá con số này sẽ kích hoạt cảnh báo lockdep sau::

(DEBUG_LOCKS_WARN_ON(id >= MAX_LOCKDEP_KEYS))

Theo mặc định, MAX_LOCKDEP_KEYS hiện được đặt thành 8191 và thông thường
hệ thống máy tính để bàn có ít hơn 1.000 lớp khóa, vì vậy cảnh báo này
thường là do rò rỉ lớp khóa hoặc không thực hiện đúng cách
khởi tạo ổ khóa.  Hai vấn đề này được minh họa dưới đây:

1. Tải và dỡ tải mô-đun lặp đi lặp lại trong khi chạy trình xác thực
	sẽ dẫn đến rò rỉ lớp khóa.  Vấn đề ở đây là mỗi
	tải của mô-đun sẽ tạo ra một tập hợp các lớp khóa mới cho
	khóa của mô-đun đó, nhưng việc dỡ mô-đun không xóa mô-đun cũ
	các lớp (xem phần thảo luận bên dưới về việc sử dụng lại các lớp khóa để biết lý do).
	Vì vậy, nếu mô-đun đó được tải và dỡ tải liên tục,
	số lượng các lớp khóa cuối cùng sẽ đạt đến mức tối đa.

2. Sử dụng các cấu trúc như mảng có số lượng lớn
	các khóa không được khởi tạo rõ ràng.  Ví dụ,
	một bảng băm với 8192 nhóm trong đó mỗi nhóm có một nhóm riêng
	spinlock_t sẽ tiêu thụ 8192 lớp khóa -trừ khi- mỗi spinlock
	được khởi tạo rõ ràng trong thời gian chạy, ví dụ: bằng cách sử dụng
	thời gian chạy spin_lock_init() trái ngược với các công cụ khởi tạo thời gian biên dịch
	chẳng hạn như __SPIN_LOCK_UNLOCKED().  Không khởi tạo đúng cách
	các spinlock trên mỗi nhóm sẽ đảm bảo tràn lớp khóa.
	Ngược lại, một vòng lặp có tên spin_lock_init() trên mỗi khóa
	sẽ đặt tất cả 8192 khóa vào một lớp khóa duy nhất.

Bài học của câu chuyện này là bạn nên luôn luôn rõ ràng
	khởi tạo ổ khóa của bạn.

Người ta có thể lập luận rằng trình xác nhận nên được sửa đổi để cho phép
khóa các lớp để được sử dụng lại.  Tuy nhiên, nếu bạn muốn làm điều này
tranh luận, trước tiên hãy xem lại mã và suy nghĩ kỹ về những thay đổi có thể xảy ra
được yêu cầu, hãy nhớ rằng các lớp khóa cần loại bỏ là
có khả năng được liên kết vào biểu đồ phụ thuộc khóa.  Điều này hóa ra
làm khó hơn nói.

Tất nhiên, nếu bạn hết lớp khóa, việc tiếp theo cần làm là
để tìm các lớp khóa vi phạm.  Đầu tiên, lệnh sau đưa ra
cho bạn số lượng lớp khóa hiện đang được sử dụng cùng với mức tối đa ::

grep "khóa lớp" /proc/lockdep_stats

Lệnh này tạo ra kết quả sau trên một hệ thống khiêm tốn::

lớp khóa: 748 [tối đa: 8191]

Nếu số lượng được phân bổ (748 ở trên) tăng liên tục theo thời gian,
thì có khả năng bị rò rỉ.  Lệnh sau có thể được sử dụng để
xác định các lớp khóa bị rò rỉ::

grep "BD" /proc/lockdep

Chạy lệnh và lưu kết quả, sau đó so sánh với kết quả từ
lần chạy lệnh này sau đó để xác định những kẻ rò rỉ.  Đầu ra tương tự này
cũng có thể giúp bạn tìm ra các tình huống trong đó việc khởi tạo khóa thời gian chạy có
bị bỏ qua.

Khóa đọc đệ quy:
---------------------
Toàn bộ tài liệu còn lại cố gắng chứng minh một loại chu trình nhất định là tương đương
đến khả năng bế tắc.

Có ba loại tủ khóa: nhà văn (tức là tủ khóa độc quyền, như
spin_lock() hoặc write_lock()), các trình đọc không đệ quy (tức là các tủ khóa dùng chung, như
down_read()) và các trình đọc đệ quy (các tủ khóa chia sẻ đệ quy, như rcu_read_lock()).
Và chúng tôi sử dụng các ký hiệu sau đây về các tủ khóa đó trong phần còn lại của tài liệu:

W hoặc E: là viết tắt của nhà văn (tủ đựng đồ độc quyền).
	r: là viết tắt của trình đọc không đệ quy.
	R: là viết tắt của trình đọc đệ quy.
	S: là viết tắt của tất cả các độc giả (không đệ quy + đệ quy), vì cả hai đều là tủ khóa chung.
	N: là viết tắt của người viết và người đọc không đệ quy, vì cả hai đều không đệ quy.

Rõ ràng, N là "r hoặc W" và S là "r hoặc R".

Các đầu đọc đệ quy, như tên gọi của chúng, là những thiết bị khóa được phép thu thập
ngay cả bên trong phần quan trọng của một trình đọc khác có cùng phiên bản khóa,
nói cách khác, cho phép các phần quan trọng phía đọc lồng nhau của một phiên bản khóa.

Trong khi các trình đọc không đệ quy sẽ gây ra tình trạng tự bế tắc nếu cố gắng tiếp thu bên trong
phần quan trọng của một trình đọc khác của cùng phiên bản khóa.

Sự khác biệt giữa trình đọc đệ quy và trình đọc không đệ quy là do:
trình đọc đệ quy chỉ bị chặn bởi khóa ghi ZZ0000ZZ, trong khi trình đọc không đệ quy
người đọc có thể bị chặn bởi khóa ghi ZZ0001ZZ. Xét theo sau
ví dụ::

TASK A: TASK B:

read_lock(X);
				write_lock(X);
	read_lock_2(X);

Nhiệm vụ A đưa người đọc (bất kể đệ quy hay không đệ quy) đến X thông qua
read_lock() trước. Và khi tác vụ B cố gắng giành được người viết trên X, nó sẽ chặn
và trở thành người phục vụ cho người viết trên X. Bây giờ nếu read_lock_2() là trình đọc đệ quy,
nhiệm vụ A sẽ đạt được tiến bộ, bởi vì người phục vụ người viết không chặn người đọc đệ quy,
và không có bế tắc. Tuy nhiên, nếu read_lock_2() là trình đọc không đệ quy,
nó sẽ bị chặn bởi người phục vụ nhà văn B và gây ra sự bế tắc.

Điều kiện chặn đối với trình đọc/ghi của cùng một phiên bản khóa:
--------------------------------------------------------------
Đơn giản chỉ có bốn điều kiện khối:

1. Người viết chặn người viết khác.
2. Người đọc chặn người viết.
3. Trình ghi chặn cả trình đọc đệ quy và trình đọc không đệ quy.
4. Và các trình đọc (đệ quy hoặc không) không chặn các trình đọc đệ quy khác nhưng
	có thể chặn các trình đọc không đệ quy (vì khả năng cùng tồn tại
	nhà văn bồi bàn)

Ma trận điều kiện khối, Y có nghĩa là hàng chặn cột và N có nghĩa là ngược lại.

+---+---+---+---+
	ZZ0000ZZ W ZZ0001ZZ R |
	+---+---+---+---+
	ZZ0002ZZ Y ZZ0003ZZ Y |
	+---+---+---+---+
	ZZ0004ZZ Y ZZ0005ZZ N |
	+---+---+---+---+
	ZZ0006ZZ Y ZZ0007ZZ N |
	+---+---+---+---+

(W: trình ghi, r: trình đọc không đệ quy, R: trình đọc đệ quy)


thu được một cách đệ quy. Không giống như khóa đọc không đệ quy, khóa đọc đệ quy
chỉ bị chặn bởi khóa ghi hiện tại ZZ0000ZZ ngoài khóa ghi
ZZ0001ZZ, ví dụ::

TASK A: TASK B:

read_lock(X);

write_lock(X);

read_lock(X);

không phải là sự bế tắc đối với các khóa đọc đệ quy, như trong khi tác vụ B đang chờ
khóa X, read_lock() thứ hai không cần đợi vì nó là đệ quy
đọc khóa. Tuy nhiên, nếu read_lock() là khóa đọc không đệ quy thì ở trên
trường hợp này là bế tắc, vì ngay cả khi write_lock() trong TASK B không thể nhận được
lock, nhưng nó có thể chặn read_lock() thứ hai trong TASK A.

Lưu ý rằng khóa có thể là khóa ghi (khóa độc quyền), khóa đọc không đệ quy
khóa (khóa chia sẻ không đệ quy) hoặc khóa đọc đệ quy (khóa chia sẻ đệ quy
lock), tùy thuộc vào thao tác khóa được sử dụng để lấy nó (cụ thể hơn,
giá trị của tham số 'đọc' cho lock_acquire()). Nói cách khác, một đơn
phiên bản khóa có ba loại mua lại tùy thuộc vào việc mua lại
chức năng: đọc độc quyền, không đệ quy và đọc đệ quy.

Để ngắn gọn, chúng tôi gọi đó là khóa ghi và khóa đọc không đệ quy như
khóa "không đệ quy" và khóa đọc đệ quy là khóa "đệ quy".

Các khóa đệ quy không chặn lẫn nhau, trong khi các khóa không đệ quy thì có (đây là
thậm chí đúng với hai khóa đọc không đệ quy). Khóa không đệ quy có thể chặn
khóa đệ quy tương ứng và ngược lại.

Một trường hợp bế tắc có liên quan đến khóa đệ quy như sau ::

TASK A: TASK B:

read_lock(X);
				read_lock(Y);
	write_lock(Y);
				write_lock(X);

Tác vụ A đang đợi tác vụ B đọc_unlock() Y và tác vụ B đang chờ tác vụ
A tới read_unlock() X.

Các loại phụ thuộc và đường dẫn phụ thuộc mạnh:
---------------------------------------------
Các phần phụ thuộc của khóa ghi lại thứ tự mua một cặp khóa và
Vì tủ có 3 loại nên về lý thuyết có 9 loại khóa
phụ thuộc, nhưng chúng tôi có thể chỉ ra rằng 4 loại phụ thuộc khóa là đủ cho
phát hiện bế tắc.

Đối với mỗi phụ thuộc khóa ::

L1 -> L2

, có nghĩa là lockdep đã thấy L1 được giữ trước L2 được giữ trong cùng bối cảnh khi chạy.
Và trong việc phát hiện bế tắc, chúng tôi quan tâm liệu chúng tôi có thể bị chặn trên L2 khi L1 được giữ hay không,
IOW, có tủ L3 mà L1 chặn L3 và L2 bị L3 chặn hay không. Vì vậy
chúng tôi chỉ quan tâm đến 1) L1 chặn cái gì và 2) L2 chặn cái gì. Kết quả là chúng ta có thể kết hợp
trình đọc đệ quy và trình đọc không đệ quy cho L1 (vì chúng chặn cùng loại) và
chúng ta có thể kết hợp trình ghi và trình đọc không đệ quy cho L2 (vì chúng bị chặn bởi
cùng loại).

Với sự kết hợp trên để đơn giản hóa, có 4 loại cạnh phụ thuộc
trong biểu đồ lockdep:

1) -(ER)->:
	    người viết độc quyền cho người đọc phụ thuộc đệ quy, "X -(ER)-> Y" có nghĩa là
	    X -> Y và X là trình ghi và Y là trình đọc đệ quy.

2) -(VI)->:
	    người viết độc quyền cho phần phụ thuộc khóa không đệ quy, "X -(EN)-> Y" có nghĩa là
	    X -> Y và X là trình ghi và Y là trình ghi hoặc trình đọc không đệ quy.

3) -(SR)->:
	    trình đọc được chia sẻ với sự phụ thuộc của trình đọc đệ quy, "X -(SR)-> Y" có nghĩa là
	    X -> Y và X là trình đọc (đệ quy hoặc không) và Y là trình đọc đệ quy.

4) -(SN)->:
	    trình đọc được chia sẻ cho phần phụ thuộc khóa không đệ quy, "X -(SN)-> Y" có nghĩa là
	    X -> Y và X là trình đọc (đệ quy hoặc không) và Y là trình ghi hoặc
	    đầu đọc không đệ quy.

Lưu ý rằng với hai khóa, chúng có thể có nhiều phụ thuộc giữa chúng,
ví dụ::

TASK MỘT:

read_lock(X);
	write_lock(Y);
	...

TASK B:

write_lock(X);
	write_lock(Y);

, chúng ta có cả X -(SN)-> Y và X -(EN)-> Y trong biểu đồ phụ thuộc.

Chúng ta sử dụng -(xN)-> để biểu thị các cạnh là -(EN)-> hoặc -(SN)->,
tương tự với -(Ex)->, -(xR)-> và -(Sx)->

"Đường dẫn" là một chuỗi các cạnh phụ thuộc liên hợp trong biểu đồ. Và chúng tôi xác định một
đường dẫn "mạnh", biểu thị sự phụ thuộc mạnh mẽ trong mỗi phần phụ thuộc
trong đường dẫn, vì đường dẫn không có hai cạnh liên kết (phụ thuộc) như
-(xR)-> và -(Sx)->. Nói cách khác, đường dẫn "mạnh" là đường dẫn từ ổ khóa
đi đến cái khác thông qua các phụ thuộc khóa và nếu X -> Y -> Z nằm trong
đường đi (trong đó X, Y, Z là các ổ khóa) và quãng đường đi bộ từ X đến Y là thông qua -(SR)-> hoặc
-(ER)-> phụ thuộc, quãng đường đi bộ từ Y đến Z không được đi qua -(SN)-> hoặc
-(SR)-> phụ thuộc.

Chúng ta sẽ xem tại sao đường dẫn này được gọi là "mạnh" trong phần tiếp theo.

Phát hiện bế tắc đọc đệ quy:
----------------------------------

Bây giờ chúng ta chứng minh hai điều:

Bổ đề 1:

Nếu có một đường đi mạnh khép kín (tức là một vòng tròn mạnh), thì sẽ có một
sự kết hợp của trình tự khóa gây ra bế tắc. tức là một vòng tròn mạnh là
đủ để phát hiện deadlock.

Bổ đề 2:

Nếu không có đường dẫn mạnh khép kín (tức là vòng tròn mạnh) thì không có
sự kết hợp của trình tự khóa có thể gây ra bế tắc. tức là  mạnh mẽ
vòng tròn là cần thiết để phát hiện bế tắc.

Với hai Bổ đề này, chúng ta có thể dễ dàng nói rằng một đường đi mạnh khép kín vừa đủ
và cần thiết cho các bế tắc, do đó một đường dẫn mạnh đóng tương đương với
khả năng bế tắc. Là một con đường mạnh mẽ khép kín tượng trưng cho một chuỗi phụ thuộc
có thể gây ra bế tắc nên chúng tôi gọi nó là "mạnh", vì có sự phụ thuộc
vòng tròn sẽ không gây ra bế tắc.

Chứng minh tính đầy đủ (Bổ đề 1):

Giả sử chúng ta có một vòng tròn mạnh::

L1 -> L2 ... -> Ln -> L1

, có nghĩa là chúng tôi có các phần phụ thuộc::

L1 -> L2
	L2 -> L3
	...
Ln-1 -> Ln
	Ln -> L1

Bây giờ chúng ta có thể xây dựng một tổ hợp các chuỗi khóa gây ra bế tắc:

Trước tiên, hãy tạo một CPU/tác vụ nhận L1 trong L1 -> L2, sau đó lấy một tác vụ khác
L2 trong L2 -> L3, v.v. Sau đó, tất cả Lx trong Lx -> Lx+1 đều là
được đảm nhiệm bởi CPU/nhiệm vụ khác nhau.

Và sau đó vì ta có L1 -> L2 nên người nắm giữ L1 sẽ có được L2
trong L1 -> L2, tuy nhiên vì L2 đã được giữ bởi CPU/nhiệm vụ khác, cộng với L1 ->
L2 và L2 -> L3 không phải là -(xR)-> và -(Sx)-> (định nghĩa của mạnh), mà
có nghĩa là L2 trong L1 -> L2 là tủ khóa không đệ quy (bị chặn bởi bất kỳ ai) hoặc
L2 trong L2 -> L3, là người viết (chặn bất kỳ ai), do đó người giữ L1
không thể nhận được L2, nó phải đợi người giữ L2 giải phóng.

Hơn nữa, chúng ta có thể có một kết luận tương tự đối với người nắm giữ L2: nó phải đợi người nắm giữ L3
người giữ để phát hành, v.v. Bây giờ chúng ta có thể chứng minh rằng người nắm giữ Lx phải đợi
Người giữ Lx+1 cần thả ra và lưu ý rằng Ln+1 là L1, nên ta có hình tròn
kịch bản chờ đợi và không ai có thể đạt được tiến bộ nên bế tắc.

Chứng minh điều cần thiết (Bổ đề 2):

Bổ đề 2 tương đương với: Nếu xảy ra tình huống bế tắc thì phải có một
vòng tròn mạnh trong biểu đồ phụ thuộc.

Theo Wikipedia[1], nếu bế tắc thì phải có thông tư
kịch bản chờ, nghĩa là có N CPU/nhiệm vụ, trong đó CPU/nhiệm vụ P1 đang chờ
một khóa do P2 giữ, và P2 đang chờ một khóa do P3 giữ, ... và Pn đang đợi
đối với khóa được giữ bởi P1. Hãy đặt tên khóa Px đang chờ là Lx, vì vậy P1 đang chờ
đối với L1 và giữ Ln thì ta sẽ có Ln -> L1 trong đồ thị phụ thuộc. Tương tự,
chúng ta có L1 -> L2, L2 -> L3, ..., Ln-1 -> Ln trong biểu đồ phụ thuộc, nghĩa là chúng ta
có một vòng tròn::

Ln -> L1 -> L2 -> ... -> Ln

, và bây giờ hãy chứng minh đường tròn mạnh:

Đối với khóa Lx, Px đóng góp phụ thuộc Lx-1 -> Lx và Px+1 đóng góp
sự phụ thuộc Lx -> Lx+1 và vì Px đang đợi Px+1 giải phóng Lx,
vì vậy Lx trên Px+1 không thể là trình đọc và Lx trên Px là đệ quy
trình đọc, bởi vì trình đọc (bất kể đệ quy hay không) không chặn đệ quy
trình đọc, do đó Lx-1 -> Lx và Lx -> Lx+1 không thể là cặp -(xR)-> -(Sx)->,
và điều này đúng với bất kỳ ổ khóa nào trong vòng tròn, do đó, vòng tròn này mạnh.

Tài liệu tham khảo:
-----------
[1]: ZZ0000ZZ
[2]: Shibu, K. (2009). Giới thiệu về Hệ thống nhúng (tái bản lần thứ 1). Tata McGraw-Hill
