.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/locking/rt-mutex.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================================
Hệ thống con RT-mutex có hỗ trợ PI
==================================

RT-mutexes có tính kế thừa ưu tiên được sử dụng để hỗ trợ PI-futexes,
cho phép các thuộc tính kế thừa ưu tiên pthread_mutex_t
(PTHREAD_PRIO_INHERIT). [Xem Tài liệu/khóa/pi-futex.rst để biết thêm chi tiết
về PI-futexes.]

Công nghệ này được phát triển trong cây -rt và được sắp xếp hợp lý cho
hỗ trợ pthread_mutex.

Nguyên tắc cơ bản:
-----------------

RT-mutexes mở rộng ngữ nghĩa của các mutex đơn giản theo mức độ ưu tiên
giao thức kế thừa.

Chủ sở hữu có mức độ ưu tiên thấp của rt-mutex sẽ kế thừa mức độ ưu tiên của rt-mutex cao hơn
người phục vụ ưu tiên cho đến khi rt-mutex được phát hành. Nếu tạm thời
tăng cường khối chủ sở hữu trên chính rt-mutex, nó truyền bá mức độ ưu tiên
thúc đẩy chủ sở hữu của rt_mutex khác thì nó sẽ bị chặn. các
tăng cường mức độ ưu tiên sẽ bị xóa ngay lập tức sau khi rt_mutex được thực hiện
đã được mở khóa.

Cách tiếp cận này cho phép chúng tôi rút ngắn khối nhiệm vụ ưu tiên cao trên
mutexes bảo vệ tài nguyên được chia sẻ. Kế thừa ưu tiên không phải là một
viên đạn ma thuật cho các ứng dụng được thiết kế kém, nhưng nó cho phép
các ứng dụng được thiết kế tốt để sử dụng khóa vùng người dùng trong các phần quan trọng của
một chủ đề có mức độ ưu tiên cao mà không làm mất tính quyết định.

Việc xếp hàng những người phục vụ vào cây bồi bàn rtmutex được thực hiện trong
thứ tự ưu tiên. Đối với cùng mức độ ưu tiên, thứ tự FIFO được chọn. Đối với mỗi
rtmutex, chỉ người phục vụ ưu tiên hàng đầu mới được xếp vào hàng của chủ sở hữu
cây bồi bàn ưu tiên. Cây này cũng xếp hàng theo thứ tự ưu tiên. Bất cứ khi nào
người phục vụ ưu tiên hàng đầu của một nhiệm vụ thay đổi (ví dụ: nó đã hết thời gian chờ hoặc
nhận được tín hiệu), mức độ ưu tiên của nhiệm vụ chủ sở hữu sẽ được điều chỉnh lại. các
việc xếp hàng ưu tiên được xử lý bởi "pi_waiters".

RT-mutexes được tối ưu hóa cho các hoạt động đường dẫn nhanh và không có nội bộ
khóa trên cao khi khóa một mutex không được kiểm soát hoặc mở khóa một mutex
không có người phục vụ. Các hoạt động đường dẫn nhanh được tối ưu hóa yêu cầu cmpxchg
hỗ trợ. [Nếu điều đó không có sẵn thì khóa xoay bên trong rt-mutex
được sử dụng]

Trạng thái của rt-mutex được theo dõi thông qua trường chủ sở hữu của rt-mutex
cấu trúc:

lock->owner giữ con trỏ task_struct của chủ sở hữu. Bit 0 được dùng để
theo dõi trạng thái "khóa có người phục vụ":

============ ======= =====================================================
 chủ sở hữu bit0 Ghi chú
 ============ ======= =====================================================
 Khóa NULL 0 miễn phí (có thể lấy nhanh)
 Khóa NULL 1 miễn phí và có người phục vụ và người phục vụ hàng đầu
		      sẽ lấy ổ khóa [1]_
 khóa taskpointer 0 được giữ (có thể nhả nhanh)
 khóa con trỏ nhiệm vụ 1 được giữ và có người phục vụ [2]_
 ============ ======= =====================================================

Việc thu thập và phát hành dựa trên trao đổi so sánh nguyên tử nhanh chỉ
có thể khi bit 0 của lock->owner là 0.

.. [1] It also can be a transitional state when grabbing the lock
       with ->wait_lock is held. To prevent any fast path cmpxchg to the lock,
       we need to set the bit0 before looking at the lock, and the owner may
       be NULL in this small time, hence this can be a transitional state.

.. [2] There is a small time when bit 0 is set but there are no
       waiters. This can happen when grabbing the lock in the slow path.
       To prevent a cmpxchg of the owner releasing the lock, we need to
       set this bit before looking at the lock.

BTW, về mặt kỹ thuật vẫn là "Chủ sở hữu đang chờ xử lý", nó chỉ chưa được gọi
cái đó nữa. Chủ sở hữu đang chờ xử lý tình cờ là top_waiter của khóa
không có chủ và đã bị đánh thức để lấy ổ khóa.
