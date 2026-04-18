.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/locking/spinlocks.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
Khóa bài học
=================

Bài 1: Khóa xoay
====================

Nguyên thủy cơ bản nhất để khóa là spinlock::

DEFINE_SPINLOCK tĩnh (xxx_lock);

cờ dài không dấu;

spin_lock_irqsave(&xxx_lock, flag);
	... critical section here ..
spin_unlock_irqrestore(&xxx_lock, flag);

Ở trên luôn an toàn. Nó sẽ vô hiệu hóa các ngắt _locally_, nhưng
Bản thân spinlock sẽ đảm bảo khóa toàn cục, vì vậy nó sẽ đảm bảo rằng
chỉ có một luồng điều khiển trong (các) vùng được bảo vệ bởi luồng đó
khóa. Điều này cũng hoạt động tốt ngay cả trong UP, vì vậy mã _không_ cần
lo lắng về các vấn đề UP so với SMP: các khóa xoay hoạt động chính xác trong cả hai.

NOTE! Ý nghĩa của spin_locks đối với bộ nhớ được mô tả thêm trong:

Tài liệu/bộ nhớ-barriers.txt

(5) Hoạt động ACQUIRE.

(6) Hoạt động RELEASE.

Những điều trên thường khá đơn giản (bạn thường chỉ cần và muốn chỉ một
spinlock cho hầu hết mọi thứ - sử dụng nhiều hơn một spinlock có thể khiến mọi thứ trở nên khó khăn
phức tạp hơn nhiều và thậm chí còn chậm hơn và thường chỉ có giá trị đối với
các chuỗi mà ZZ0000ZZ của bạn cần được tách ra: hãy tránh nó bằng mọi giá nếu bạn
không chắc chắn).

Đây thực sự là phần thực sự khó khăn duy nhất về spinlocks: một khi bạn bắt đầu
bằng cách sử dụng spinlocks, chúng có xu hướng mở rộng sang các khu vực mà bạn có thể không nhận thấy
trước đây, bởi vì bạn phải đảm bảo rằng các khóa xoay bảo vệ chính xác
cấu trúc dữ liệu chia sẻ ZZ0000ZZ chúng được sử dụng. Hầu hết các spinlocks
dễ dàng thêm vào những nơi hoàn toàn độc lập với mã khác (đối với
ví dụ: cấu trúc dữ liệu trình điều khiển nội bộ mà không ai khác từng chạm vào).

NOTE! Khóa xoay chỉ an toàn khi ZZ0000ZZ sử dụng chính khóa đó
   để thực hiện khóa trên CPU, điều này ngụ ý rằng EVERYTHING
   chạm vào một biến chia sẻ phải đồng ý về spinlock mà họ muốn
   để sử dụng.

----

Bài học 2: spinlocks của người đọc-người viết.
==================================

Nếu việc truy cập dữ liệu của bạn có kiểu mẫu rất tự nhiên mà bạn thường có xu hướng
để đọc chủ yếu từ các biến được chia sẻ, khóa trình đọc-ghi
(rw_lock) các phiên bản spinlocks đôi khi rất hữu ích. Họ cho phép nhiều
độc giả ở cùng một khu vực quan trọng cùng một lúc, nhưng nếu ai đó muốn
để thay đổi các biến, nó phải có khóa ghi độc quyền.

NOTE! khóa đầu đọc-ghi yêu cầu nhiều hoạt động bộ nhớ nguyên tử hơn
   spinlock đơn giản.  Trừ khi phần quan trọng của người đọc dài, bạn
   tốt hơn hết là chỉ sử dụng spinlocks.

Các quy trình trông giống như trên::

rwlock_t xxx_lock = __RW_LOCK_UNLOCKED(xxx_lock);

cờ dài không dấu;

read_lock_irqsave(&xxx_lock, cờ);
	.. critical section that only reads the info ...
read_unlock_irqrestore(&xxx_lock, flag);

write_lock_irqsave(&xxx_lock, flag);
	.. read and write exclusive access to the info ...
write_unlock_irqrestore(&xxx_lock, flag);

Loại khóa trên có thể hữu ích cho các cấu trúc dữ liệu phức tạp như
danh sách liên kết, đặc biệt là tìm kiếm các mục mà không thay đổi danh sách
chính nó.  Khóa đọc cho phép nhiều người đọc đồng thời.  Bất cứ điều gì
ZZ0000ZZ danh sách sẽ phải lấy khóa ghi.

NOTE! RCU tốt hơn cho việc duyệt danh sách nhưng yêu cầu phải cẩn thận
   chú ý đến chi tiết thiết kế (xem Documentation/RCU/listRCU.rst).

Ngoài ra, bạn không thể "nâng cấp" khóa đọc thành khóa ghi, vì vậy nếu bạn ở _any_
cần thực hiện bất kỳ thay đổi nào (ngay cả khi bạn không thực hiện việc đó mọi lúc), bạn có
để có được khóa ghi ngay từ đầu.

NOTE! Chúng tôi đang nỗ lực loại bỏ các vấn đề liên quan đến trình đọc-ghi trong hầu hết các
   trường hợp, vì vậy xin vui lòng không thêm một trường hợp mới mà không có sự đồng thuận.  (Thay vào đó, hãy xem
   Documentation/RCU/rcu.rst để biết thông tin đầy đủ.)

----

Bài học 3: xem lại spinlocks.
==============================

Các nguyên hàm khóa xoay đơn ở trên không phải là những nguyên thủy duy nhất. Họ
là những thứ an toàn nhất và có thể hoạt động trong mọi hoàn cảnh,
nhưng một phần ZZ0000ZZ chúng an toàn và cũng khá chậm. Họ chậm hơn
hơn mức cần thiết vì họ phải vô hiệu hóa các ngắt
(đây chỉ là một lệnh duy nhất trên x86, nhưng nó là một lệnh đắt tiền -
và trên các kiến trúc khác, nó có thể tệ hơn).

Nếu bạn gặp trường hợp phải bảo vệ cấu trúc dữ liệu trên
một số CPU và bạn muốn sử dụng khóa xoay mà bạn có thể sử dụng
phiên bản rẻ hơn của spinlocks. IFF bạn biết rằng spinlocks là
không bao giờ được sử dụng trong các trình xử lý ngắt, bạn có thể sử dụng các phiên bản không phải irq ::

spin_lock(&lock);
	...
spin_unlock(&lock);

(và tất nhiên cả các phiên bản đọc-ghi tương đương). Spinlock sẽ
đảm bảo cùng một loại quyền truy cập độc quyền và nó sẽ nhanh hơn nhiều.
Điều này hữu ích nếu bạn biết rằng dữ liệu được đề cập chỉ bao giờ
được thao tác từ một "bối cảnh quá trình", tức là không có sự gián đoạn nào liên quan.

Những lý do bạn không được sử dụng các phiên bản này nếu bạn bị gián đoạn
chơi với spinlock là bạn có thể gặp bế tắc ::

spin_lock(&lock);
	...
		<- interrupt comes in:
			spin_lock(&lock);

trong đó một ngắt cố gắng khóa một biến đã bị khóa. Điều này ổn nếu
ngắt khác xảy ra trên một CPU khác, nhưng sẽ không ổn nếu
ngắt xảy ra trên cùng một CPU đã giữ khóa, bởi vì
khóa rõ ràng sẽ không bao giờ được giải phóng (vì ngắt đang chờ
đối với khóa và người giữ khóa bị gián đoạn do ngắt và sẽ
không tiếp tục cho đến khi ngắt được xử lý).

(Đây cũng là lý do tại sao các phiên bản irq của spinlocks chỉ cần
để vô hiệu hóa các ngắt _local_ - bạn có thể sử dụng khóa spin trong các ngắt
trên các CPU khác, vì một ngắt trên một CPU khác không làm gián đoạn
CPU giữ khóa để người giữ khóa có thể tiếp tục và cuối cùng
nhả khóa).

Linus

----

Thông tin tham khảo:
======================

Để khởi tạo động, hãy sử dụng spin_lock_init() hoặc rwlock_init() làm
thích hợp::

spinlock_t xxx_lock;
   rwlock_t xxx_rw_lock;

int tĩnh __init xxx_init(void)
   {
	spin_lock_init(&xxx_lock);
	rwlock_init(&xxx_rw_lock);
	...
   }

   module_init(xxx_init);

Để khởi tạo tĩnh, hãy sử dụng DEFINE_SPINLOCK() / DEFINE_RWLOCK() hoặc
__SPIN_LOCK_UNLOCKED() / __RW_LOCK_UNLOCKED() nếu phù hợp.
