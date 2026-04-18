.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/locking/futex-requeue-pi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================
PI yêu cầu Futex
================

Việc yêu cầu xếp hàng các tác vụ từ futex không PI đến futex PI yêu cầu
xử lý đặc biệt để đảm bảo rt_mutex cơ bản không bao giờ bị
bỏ đi nếu có người phục vụ; làm như vậy sẽ phá vỡ PI
tăng cường logic [xem rt-mutex-design.rst] Với mục đích
ngắn gọn, hành động này sẽ được gọi là "requeue_pi" xuyên suốt
tài liệu này.  Quyền kế thừa ưu tiên được viết tắt xuyên suốt là
"PI".

Động lực
----------

Không có requeue_pi, việc triển khai glibc của
pthread_cond_broadcast() phải đánh thức tất cả các tác vụ đang chờ
trên pthread_condvar và để họ cố gắng sắp xếp nhiệm vụ nào
được chạy đầu tiên trong đội hình bầy sấm sét cổ điển.  Một lý tưởng
việc thực hiện sẽ đánh thức người phục vụ có mức độ ưu tiên cao nhất và để lại
nghỉ ngơi trong sự thức tỉnh tự nhiên vốn có khi mở khóa mutex
liên kết với condvar.

Hãy xem xét các cuộc gọi glibc đơn giản hóa ::

/*người gọi phải khóa mutex */
	pthread_cond_wait(cond, mutex)
	{
		lock(cond->__data.__lock);
		mở khóa(mutex);
		làm {
		mở khóa(cond->__data.__lock);
		futex_wait(cond->__data.__futex);
		lock(cond->__data.__lock);
		} trong khi(...)
		mở khóa(cond->__data.__lock);
		khóa (mutex);
	}

pthread_cond_broadcast(cond)
	{
		lock(cond->__data.__lock);
		mở khóa(cond->__data.__lock);
		futex_requeue(cond->data.__futex, cond->mutex);
	}

Khi pthread_cond_broadcast() yêu cầu các tác vụ, cond->mutex
có người phục vụ. Lưu ý rằng pthread_cond_wait() cố gắng khóa
mutex chỉ sau khi nó đã trở lại không gian người dùng.  Điều này sẽ để lại
rt_mutex cơ bản có người phục vụ và không có chủ sở hữu, phá vỡ
các thuật toán tăng cường PI đã đề cập trước đây.

Để hỗ trợ pthread_condvar nhận biết PI, kernel cần phải
có thể yêu cầu các nhiệm vụ tới PI futexes.  Sự hỗ trợ này ngụ ý rằng
khi lệnh gọi hệ thống futex_wait thành công, người gọi sẽ quay lại
không gian người dùng đã giữ PI futex.  Việc triển khai glibc
sẽ được sửa đổi như sau::


/*người gọi phải khóa mutex */
	pthread_cond_wait_pi(cond, mutex)
	{
		lock(cond->__data.__lock);
		mở khóa(mutex);
		làm {
		mở khóa(cond->__data.__lock);
		futex_wait_requeue_pi(cond->__data.__futex);
		lock(cond->__data.__lock);
		} trong khi(...)
		mở khóa(cond->__data.__lock);
		/* kernel đã lấy được mutex cho chúng ta */
	}

pthread_cond_broadcast_pi(cond)
	{
		lock(cond->__data.__lock);
		mở khóa(cond->__data.__lock);
		futex_requeue_pi(cond->data.__futex, cond->mutex);
	}

Việc triển khai glibc thực tế có thể sẽ kiểm tra PI và thực hiện
những thay đổi cần thiết bên trong các cuộc gọi hiện tại thay vì tạo mới
kêu gọi các trường hợp PI.  Những thay đổi tương tự là cần thiết cho
pthread_cond_timedwait() và pthread_cond_signal().

Thực hiện
--------------

Để đảm bảo rt_mutex có chủ sở hữu nếu nó có người phục vụ, nó
là cần thiết cho cả mã yêu cầu cũng như mã chờ,
để có thể lấy được rt_mutex trước khi quay lại không gian người dùng.
Mã yêu cầu không thể đơn giản đánh thức người phục vụ và để nó
có được rt_mutex vì nó sẽ mở ra một cửa sổ cuộc đua giữa
cuộc gọi yêu cầu quay trở lại không gian người dùng và người phục vụ thức dậy và
bắt đầu chạy.  Điều này đặc biệt đúng trong trường hợp không có tranh chấp.

Giải pháp này bao gồm hai quy trình trợ giúp rt_mutex mới,
rt_mutex_start_proxy_lock() và rt_mutex_finish_proxy_lock(), trong đó
cho phép mã yêu cầu thay mặt nhận được rt_mutex không được kiểm soát
của người phục vụ và xếp người phục vụ vào hàng đợi trên rt_mutex đang tranh chấp.
Hai cuộc gọi hệ thống mới cung cấp giao diện người dùng kernel<-> cho
requeue_pi: FUTEX_WAIT_REQUEUE_PI và FUTEX_CMP_REQUEUE_PI.

FUTEX_WAIT_REQUEUE_PI được người phục vụ gọi (pthread_cond_wait()
và pthread_cond_timedwait()) để chặn futex ban đầu và chờ
được yêu cầu xếp hàng vào futex nhận biết PI.  Việc thực hiện là
kết quả của sự va chạm tốc độ cao giữa futex_wait() và
futex_lock_pi(), với một số logic bổ sung để kiểm tra bổ sung
kịch bản thức tỉnh.

FUTEX_CMP_REQUEUE_PI được gọi bởi người đánh thức
(pthread_cond_broadcast() và pthread_cond_signal()) để yêu cầu và
có thể đánh thức các nhiệm vụ đang chờ đợi. Trong nội bộ, cuộc gọi hệ thống này là
vẫn được xử lý bởi futex_requeue (bằng cách chuyển requeue_pi=1).  trước đây
yêu cầu, futex_requeue() cố gắng đạt được mục tiêu yêu cầu
PI futex thay mặt người phục vụ hàng đầu.  Nếu có thể thì người phục vụ này là
thức dậy.  futex_requeue() sau đó tiến hành yêu cầu phần còn lại
nhiệm vụ nr_wake+nr_requeue tới futex PI, gọi
rt_mutex_start_proxy_lock() trước mỗi hàng đợi để chuẩn bị
làm nhiệm vụ bồi bàn trên rt_mutex cơ bản.  Có thể là
khóa cũng có thể được lấy ở giai đoạn này, nếu vậy, giai đoạn tiếp theo
người phục vụ được đánh thức để hoàn tất việc lấy lại ổ khóa.

FUTEX_CMP_REQUEUE_PI chấp nhận nr_wake và nr_requeue làm đối số, nhưng
tổng của chúng là tất cả những gì thực sự quan trọng.  futex_requeue() sẽ thức dậy hoặc
yêu cầu tối đa các nhiệm vụ nr_wake + nr_requeue.  Nó sẽ chỉ thức dậy khi có nhiều người
nhiệm vụ vì nó có thể lấy được khóa, trong phần lớn các trường hợp
phải là 0 vì cách lập trình tốt quy định rằng người gọi
pthread_cond_broadcast() hoặc pthread_cond_signal() đều nhận được
mutex trước khi thực hiện cuộc gọi. FUTEX_CMP_REQUEUE_PI yêu cầu điều đó
nr_wake=1.  nr_requeue phải là INT_MAX để phát sóng và 0 cho
tín hiệu.
