.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/locking/robust-futexes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============================================
Mô tả về futex mạnh mẽ là gì
============================================

:Bắt đầu bởi: Ingo Molnar <mingo@redhat.com>

Lý lịch
----------

futex mạnh mẽ là gì? Để trả lời điều đó, trước tiên chúng ta cần hiểu
futex là gì: futex thông thường là loại khóa đặc biệt có trong
trường hợp không được kiểm soát có thể được lấy/giải phóng khỏi không gian người dùng mà không cần
để vào hạt nhân.

Futex về bản chất là một địa chỉ không gian người dùng, ví dụ: biến khóa 32 bit
lĩnh vực. Nếu không gian người dùng thông báo tranh chấp (khóa đã được sở hữu và
người khác cũng muốn lấy nó) thì khóa được đánh dấu bằng một giá trị
có nội dung "có người phục vụ đang chờ xử lý" và sys_futex(FUTEX_WAIT)
syscall được sử dụng để chờ người kia giải phóng nó. Hạt nhân
tạo ra một 'hàng đợi futex' bên trong để sau này nó có thể khớp với
người phục vụ với người đánh thức - mà họ không cần phải biết về nhau.
Khi luồng chủ sở hữu giải phóng futex, nó sẽ thông báo (thông qua biến
value) rằng có (những) người phục vụ đang chờ xử lý và liệu
sys_futex(FUTEX_WAKE) để đánh thức chúng.  Một khi tất cả những người phục vụ đã
lấy và mở khóa, futex lại trở lại 'không thể kiểm soát'
trạng thái và không có trạng thái trong kernel nào liên kết với nó. Hạt nhân
hoàn toàn quên rằng đã từng có futex tại địa chỉ đó. Cái này
phương pháp làm cho futexes rất nhẹ và có thể mở rộng.

"Mạnh mẽ" là xử lý các sự cố khi giữ khóa: nếu
quá trình thoát sớm trong khi đang giữ khóa pthread_mutex_t
cũng được chia sẻ với một số quy trình khác (ví dụ: yum segfaults trong khi giữ một
pthread_mutex_t, hoặc yum là kill -9-ed), thì người phục vụ cho khóa đó cần
được thông báo rằng chủ sở hữu cuối cùng của khóa đã thoát ra ngoài một cách bất thường
cách.

Để giải quyết những loại vấn đề như vậy, các API không gian người dùng "mạnh mẽ" đã được
đã tạo: pthread_mutex_lock() trả về giá trị lỗi nếu chủ sở hữu thoát
sớm - và chủ sở hữu mới có thể quyết định liệu dữ liệu được bảo vệ bởi
khóa có thể được phục hồi một cách an toàn.

Tuy nhiên, có một vấn đề lớn về mặt khái niệm với các mutex dựa trên futex: đó là
hạt nhân phá hủy tác vụ của chủ sở hữu (ví dụ: do SEGFAULT), nhưng
kernel không thể giúp dọn dẹp: nếu không có 'hàng đợi futex'
(và trong hầu hết các trường hợp thì không có, futexes là loại khóa nhanh nhẹ)
thì kernel không có thông tin gì để dọn dẹp sau khi bị lock!
Không gian người dùng cũng không có cơ hội dọn dẹp sau khi khóa - không gian người dùng là
cái bị hỏng nên không có cơ hội dọn dẹp. Bắt-22.

Trong thực tế, khi ví dụ: yum bị kill -9-ed (hoặc segfaults), khởi động lại hệ thống
là cần thiết để giải phóng khóa dựa trên futex đó. Đây là một trong những hàng đầu
báo cáo lỗi chống lại yum.

Để giải quyết vấn đề này, cách tiếp cận truyền thống là mở rộng vma
(bộ mô tả vùng bộ nhớ ảo) có khái niệm 'đang chờ xử lý'
futexes mạnh mẽ gắn liền với khu vực này'. Cách tiếp cận này đòi hỏi 3
các biến thể syscall thành sys_futex(): FUTEX_REGISTER, FUTEX_DEREGISTER và
FUTEX_RECOVER. Tại thời điểm do_exit(), tất cả vmas được tìm kiếm để xem liệu
họ có một bộ Robust_head. Cách tiếp cận này có hai vấn đề cơ bản
trái:

- nó có kịch bản khóa và đua khá phức tạp. Dựa trên vma
   phương pháp tiếp cận này đã được chờ đợi trong nhiều năm, nhưng chúng vẫn chưa hoàn toàn
   đáng tin cậy.

- họ phải quét _every_ vma vào thời điểm sys_exit(), trên mỗi luồng!

Nhược điểm thứ hai là khá nguy hiểm: pthread_exit() mất khoảng 1
micro giây trên Linux, nhưng với hàng nghìn (hoặc hàng chục nghìn) vmas
mỗi pthread_exit() mất một phần nghìn giây hoặc hơn, hoàn toàn
phá hủy bộ đệm L1 và L2 của CPU!

Điều này rất đáng chú ý ngay cả đối với quy trình bình thường sys_exit_group()
cuộc gọi: hạt nhân phải thực hiện quét vma vô điều kiện! (đây là
bởi vì kernel không biết có bao nhiêu futex mạnh mẽ ở đó
sẽ được dọn dẹp, bởi vì một futex mạnh mẽ có thể đã được đăng ký
trong một tác vụ khác và biến futex có thể chỉ đơn giản là mmap()-ed
vào không gian địa chỉ của quá trình này).

Chi phí khổng lồ này buộc phải tạo ra CONFIG_FUTEX_ROBUST để
hạt nhân bình thường có thể tắt nó đi, nhưng tệ hơn thế: chi phí hoạt động khiến
futex mạnh mẽ không thực tế đối với bất kỳ loại phân phối Linux chung nào.

Vì vậy cần phải làm gì đó.

Cách tiếp cận mới cho futex mạnh mẽ
------------------------------

Trọng tâm của phương pháp mới này là một danh sách riêng tư cho mỗi luồng
các khóa mạnh mẽ mà không gian người dùng đang nắm giữ (được duy trì bởi glibc) - được
danh sách vùng người dùng được đăng ký với kernel thông qua một tòa nhà mới [điều này
đăng ký xảy ra nhiều nhất một lần trong suốt vòng đời của luồng]. Tại do_exit()
lúc này, kernel sẽ kiểm tra danh sách không gian người dùng này: có futex mạnh mẽ nào không
ổ khóa cần được dọn dẹp?

Trong trường hợp thông thường, tại thời điểm do_exit(), không có danh sách nào được đăng ký, vì vậy
chi phí của futex mạnh mẽ chỉ là một dòng điện đơn giản->robust_list != NULL
so sánh. Nếu chủ đề đã đăng ký một danh sách thì thông thường danh sách đó
trống rỗng. Nếu luồng/tiến trình bị lỗi hoặc kết thúc ở một số lỗi không chính xác
theo cách này thì danh sách có thể không trống: trong trường hợp này kernel cẩn thận
duyệt danh sách [không tin tưởng nó] và đánh dấu tất cả các khóa thuộc sở hữu của
luồng này với bit FUTEX_OWNER_DIED và đánh thức một người phục vụ (nếu
bất kỳ).

Danh sách được đảm bảo ở chế độ riêng tư và theo từng luồng tại thời điểm do_exit(),
vì vậy nó có thể được truy cập bởi kernel một cách không khóa.

Tuy nhiên, có một cuộc đua có thể xảy ra: kể từ khi thêm vào và xóa khỏi
danh sách được thực hiện sau khi futex được glibc mua lại, có một vài
cửa sổ hướng dẫn cho luồng (hoặc tiến trình) chết ở đó, để lại
futex bị treo. Để bảo vệ khỏi khả năng này, không gian người dùng (glibc)
cũng duy trì trường 'list_op_pending' đơn giản trên mỗi luồng, để cho phép
kernel để dọn dẹp nếu luồng chết sau khi lấy được khóa, nhưng chỉ
trước khi nó có thể tự thêm vào danh sách. Glibc đặt cái này
trường list_op_pending trước khi nó cố lấy futex và xóa
nó sau khi quá trình thêm danh sách (hoặc xóa danh sách) kết thúc.

Đó là tất cả những gì cần thiết - tất cả phần còn lại của quá trình dọn dẹp mạnh mẽ-futex đã hoàn tất
trong không gian người dùng [giống như các bản vá trước đó].

Ulrich Drepper đã triển khai hỗ trợ glibc cần thiết cho phiên bản mới này
cơ chế, cho phép hoàn toàn các mutex mạnh mẽ.

Những điểm khác biệt chính của cách tiếp cận dựa trên danh sách không gian người dùng này so với cách tiếp cận
phương pháp dựa trên vma:

- nhanh hơn rất nhiều: tại thời điểm thoát luồng, không cần phải lặp lại
   trên mọi vma (!), mà phương pháp dựa trên VM phải thực hiện. Chỉ có rất
   đơn giản là 'danh sách trống' đã xong.

- không cần thay đổi VM - chỉ để lại 'struct address_space'.

- không cần đăng ký các khóa riêng lẻ: các mutex mạnh mẽ không
   cần thêm bất kỳ cuộc gọi tòa nhà nào trên mỗi khóa. Do đó, các mutex mạnh mẽ trở thành một
   nguyên thủy nhẹ - vì vậy chúng không ép buộc người thiết kế ứng dụng
   phải đưa ra lựa chọn khó khăn giữa hiệu suất và độ bền - mạnh mẽ
   mutexes cũng nhanh như vậy.

- không xảy ra phân bổ kernel trên mỗi khóa.

- không cần giới hạn tài nguyên.

- không cần lệnh gọi khôi phục không gian kernel (FUTEX_RECOVER).

- việc triển khai và khóa là "rõ ràng" và không có
   tương tác với VM.

Hiệu suất
-----------

Tôi đã benchmark thời gian cần thiết để kernel xử lý danh sách 1
triệu (!) Đã giữ khóa, sử dụng phương pháp mới [trên CPU 2GHz]:

- với bộ FUTEX_WAIT [mutex dự kiến]: 130 mili giây
 - không có bộ FUTEX_WAIT [mutex không được kiểm soát]: 30 mili giây

Tôi cũng đã đo lường cách tiếp cận trong đó glibc thực hiện thông báo khóa
[điều mà nó hiện đang thực hiện đối với các mutex mạnh mẽ được chia sẻ] và việc đó mất tới 256
msec - rõ ràng là chậm hơn, do có 1 triệu tòa nhà FUTEX_WAKE
không gian người dùng phải làm.

(1 triệu ổ khóa được giữ là chưa từng có - chúng tôi mong đợi nhiều nhất là một số ít
khóa được giữ cùng một lúc. Tuy nhiên thật vui khi biết rằng điều này
tiếp cận quy mô độc đáo.)

Chi tiết triển khai
----------------------

Bản vá bổ sung thêm hai lệnh gọi tòa nhà mới: một để đăng ký danh sách không gian người dùng và
một để truy vấn con trỏ danh sách đã đăng ký::

liên kết dài
 sys_set_robust_list(struct Robust_list_head __user *head,
                     size_t len);

liên kết dài
 sys_get_robust_list(int pid, struct Robust_list_head __user **head_ptr,
                     size_t __người dùng *len_ptr);

Đăng ký danh sách rất nhanh: con trỏ được lưu trữ đơn giản trong
hiện tại-> mạnh mẽ_list. [Lưu ý rằng trong tương lai, nếu futex mạnh mẽ trở thành
rộng rãi, chúng ta có thể mở rộng sys_clone() để đăng ký phần đầu danh sách mạnh mẽ
cho các chủ đề mới mà không cần một tòa nhà cao tầng khác.]

Vì vậy, hầu như không có chi phí cho các tác vụ không sử dụng futex mạnh mẽ,
và ngay cả đối với người dùng futex mạnh mẽ, chỉ có một tòa nhà bổ sung cho mỗi
tuổi thọ của luồng và hoạt động dọn dẹp, nếu xảy ra, sẽ nhanh chóng và
đơn giản. Hạt nhân không có bất kỳ sự phân biệt nội bộ nào giữa
futexes mạnh mẽ và bình thường.

Nếu một futex được tìm thấy được giữ tại thời điểm thoát, kernel sẽ đặt
đoạn sau của từ futex::

#define FUTEX_OWNER_DIED 0x40000000

và đánh thức người phục vụ futex tiếp theo (nếu có). Không gian người dùng thực hiện phần còn lại
việc dọn dẹp.

Mặt khác, glibc thu được các futex mạnh mẽ bằng cách đặt TID vào
trường futex về mặt nguyên tử. Người phục vụ đặt bit FUTEX_WAITERS ::

#define FUTEX_WAITERS 0x80000000

và các bit còn lại dành cho TID.

Kiểm tra, hỗ trợ kiến ​​trúc
-----------------------------

Tôi đã thử nghiệm các tòa nhà cao tầng mới trên x86 và x86_64 và đã đảm bảo rằng
phân tích cú pháp danh sách không gian người dùng rất mạnh mẽ [ ;-)] ngay cả khi danh sách đó
cố tình làm hỏng.

các tòa nhà cao tầng i386 và x86_64 hiện đã được kết nối và Ulrich có
đã thử nghiệm mã glibc mới (trên x86_64 và i386) và nó hoạt động với
trường hợp thử nghiệm mạnh mẽ-mutex.

Tất cả các kiến trúc khác cũng sẽ được xây dựng tốt - nhưng chúng sẽ không có
các syscalls mới chưa.

Kiến trúc cần triển khai futex_atomic_cmpxchg_inatomic() mới
chức năng nội tuyến trước khi viết lên các tòa nhà.
