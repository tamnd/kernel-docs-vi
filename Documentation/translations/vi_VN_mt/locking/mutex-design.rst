.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/locking/mutex-design.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
Hệ thống con Mutex chung
==========================

bắt đầu bởi Ingo Molnar <mingo@redhat.com>

được cập nhật bởi Davidlohr Bueso <davidlohr@hp.com>

Mutex là gì?
-----------------

Trong nhân Linux, mutexes đề cập đến một khóa nguyên thủy cụ thể
thực thi việc tuần tự hóa trên các hệ thống bộ nhớ dùng chung và không chỉ
thuật ngữ chung đề cập đến 'loại trừ lẫn nhau' được tìm thấy trong giới học thuật
hoặc các sách giáo khoa lý thuyết tương tự. Mutexes là ổ khóa ngủ
hoạt động tương tự như các ẩn dụ nhị phân và được giới thiệu vào năm 2006[1]
như một sự thay thế cho những điều này. Cấu trúc dữ liệu mới này cung cấp một số
nhiều ưu điểm, bao gồm giao diện đơn giản hơn và tại thời điểm đó nhỏ hơn
mã (xem Nhược điểm).

[1] ZZ0000ZZ

Thực hiện
--------------

Mutexes được biểu thị bằng 'struct mutex', được định nghĩa trong include/linux/mutex.h
và được triển khai trong kernel/locking/mutex.c. Những khóa này sử dụng một biến nguyên tử
(->chủ sở hữu) để theo dõi trạng thái khóa trong suốt thời gian tồn tại của nó.  Chủ sở hữu trường
thực sự chứa ZZ0000ZZ cho chủ sở hữu khóa hiện tại và nó
do đó NULL nếu hiện không được sở hữu. Vì con trỏ task_struct được căn chỉnh
đến ít nhất L1_CACHE_BYTES, các bit thấp (3) được sử dụng để lưu trữ trạng thái bổ sung (ví dụ:
nếu danh sách người phục vụ không trống).  Ở dạng cơ bản nhất, nó cũng bao gồm một
hàng chờ và một spinlock tuần tự hóa quyền truy cập vào nó. Hơn nữa,
Các hệ thống CONFIG_MUTEX_SPIN_ON_OWNER=y sử dụng khóa MCS spinner (->osq), được mô tả
dưới đây trong (ii).

Khi có được một mutex, có ba đường dẫn có thể
được thực hiện, tùy thuộc vào trạng thái của khóa:

(i) fastpath: cố gắng lấy khóa một cách nguyên tử bằng cách cmpxchg() gửi cho chủ sở hữu bằng
    nhiệm vụ hiện tại. Điều này chỉ hoạt động trong trường hợp không được kiểm tra (cmpxchg()
    so với 0UL, vì vậy cả 3 bit trạng thái trên phải bằng 0). Nếu khóa là
    cho rằng nó sẽ đi theo con đường khả thi tiếp theo.

(ii) đường giữa: hay còn gọi là quay lạc quan, cố gắng quay để thu được
     trong khi chủ sở hữu khóa đang chạy và không có nhiệm vụ nào khác sẵn sàng
     để chạy có mức độ ưu tiên cao hơn (need_resched). Lý do là
     rằng nếu chủ khóa đang chạy thì có khả năng sẽ nhả khóa
     sớm thôi. Các máy quay mutex được xếp hàng đợi bằng khóa MCS để chỉ
     một spinner có thể cạnh tranh cho mutex.

Khóa MCS (do Mellor-Crummey và Scott đề xuất) là một khóa xoay đơn giản
     với những đặc tính mong muốn là công bằng và mỗi CPU đều cố gắng
     để có được khóa quay trên một biến cục bộ. Nó tránh đắt tiền
     cacheline trả lại các triển khai spinlock thử nghiệm và thiết lập phổ biến đó
     phát sinh. Một khóa giống MCS được thiết kế đặc biệt để quay tối ưu
     để thực hiện khóa ngủ. Một tính năng quan trọng của tùy chỉnh
     Khóa MCS là nó có thuộc tính bổ sung mà người quay có thể thoát
     hàng đợi spinlock MCS khi họ cần lên lịch lại. Điều này giúp ích thêm
     tránh các tình huống trong đó máy quay MCS cần lên lịch lại vẫn tiếp tục
     đang chờ quay trên chủ sở hữu mutex, chỉ để đi thẳng tới đường dẫn chậm
     lấy được khóa MCS.


(iii) đường dẫn chậm: biện pháp cuối cùng, nếu vẫn không thể lấy được khóa,
      tác vụ được thêm vào hàng đợi và ngủ cho đến khi được đánh thức bởi
      mở khóa đường dẫn. Trong trường hợp bình thường, nó chặn dưới dạng TASK_UNINTERRUPTIBLE.

Mặc dù các mutex kernel chính thức là các khóa có thể ngủ được, nhưng chính đường dẫn (ii) mới
làm cho chúng thực tế hơn là một loại lai. Đơn giản là không làm gián đoạn một
nhiệm vụ và bận rộn chờ đợi một vài chu kỳ thay vì ngủ ngay lập tức,
hiệu suất của khóa này đã được chứng minh là cải thiện đáng kể
số khối lượng công việc. Lưu ý rằng kỹ thuật này cũng được sử dụng cho các ngữ nghĩa rw.

Ngữ nghĩa
---------

Hệ thống con mutex kiểm tra và thực thi các quy tắc sau:

- Mỗi lần chỉ có một tác vụ có thể giữ mutex.
    - Chỉ có chủ sở hữu mới có thể mở khóa mutex.
    - Không được phép mở khóa nhiều lần.
    - Không được phép khóa/mở khóa đệ quy.
    - Một mutex chỉ được khởi tạo thông qua API (xem bên dưới).
    - Một tác vụ không thể thoát khi mutex được giữ.
    - Các vùng nhớ chứa ổ khóa không được giải phóng.
    - Các mutex được giữ lại không được khởi tạo lại.
    - Không được sử dụng Mutexes khi ngắt phần cứng hoặc phần mềm
      các bối cảnh như tasklets và bộ tính giờ.

Các ngữ nghĩa này được thực thi đầy đủ khi CONFIG DEBUG_MUTEXES được bật.
Ngoài ra, mã gỡ lỗi mutex còn thực hiện một số chức năng khác
các tính năng giúp việc gỡ lỗi khóa dễ dàng và nhanh hơn:

- Sử dụng tên tượng trưng của mutexes bất cứ khi nào chúng được in
      trong đầu ra gỡ lỗi.
    - Theo dõi điểm thu được, tra cứu ký hiệu tên hàm,
      danh sách tất cả các khóa được giữ trong hệ thống, bản in của chúng.
    - Theo dõi chủ sở hữu.
    - Phát hiện ổ khóa tự lặp lại và in ra tất cả thông tin liên quan.
    - Phát hiện bế tắc vòng tròn đa tác vụ và in ra tất cả những gì bị ảnh hưởng
      khóa và nhiệm vụ (và chỉ những nhiệm vụ đó).

Mutexes - và hầu hết các khóa ngủ khác như rwsems - không cung cấp
tham chiếu ngầm cho bộ nhớ mà chúng chiếm giữ, tham chiếu nào sẽ được giải phóng
với mutex_unlock().

[ Điều này trái ngược với spin_unlock() [hoặc Complete_done()],
  API có thể được sử dụng để đảm bảo rằng bộ nhớ không bị chạm vào bởi
  khóa triển khai sau khi phát hành spin_unlock()/completion_done()
  cái khóa. ]

mutex_unlock() có thể truy cập cấu trúc mutex ngay cả sau khi nó đã có nội bộ
đã giải phóng khóa - vì vậy sẽ không an toàn cho bối cảnh khác
lấy mutex và cho rằng ngữ cảnh mutex_unlock() không được sử dụng
cấu trúc nữa.

Người dùng mutex phải đảm bảo rằng mutex không bị phá hủy trong khi
Hoạt động phát hành vẫn đang được tiến hành - nói cách khác, người gọi
mutex_unlock() phải đảm bảo rằng mutex vẫn tồn tại cho đến khi mutex_unlock()
đã trở lại.

Giao diện
----------
Xác định tĩnh mutex::

DEFINE_MUTEX(tên);

Tự động khởi tạo mutex::

mutex_init(mutex);

Có được mutex, không bị gián đoạn::

void mutex_lock(struct mutex *lock);
   void mutex_lock_nested(struct mutex *lock, unsigned int subclass);
   int mutex_trylock(struct mutex *lock);

Có được mutex, bị gián đoạn::

int mutex_lock_interruptible_nested(struct mutex *lock,
				       lớp con unsigned int);
   int mutex_lock_interruptible(struct mutex *lock);

Lấy mutex, có thể ngắt, nếu dec thành 0::

int Atomic_dec_and_mutex_lock(atomic_t *cnt, struct mutex *lock);

Mở khóa mutex::

void mutex_unlock(struct mutex *lock);

Kiểm tra xem mutex có được lấy không ::

int mutex_is_locked(struct mutex *lock);

Nhược điểm
-------------

Không giống như thiết kế và mục đích ban đầu của nó, 'struct mutex' là một trong những cấu trúc lớn nhất
khóa trong kernel. Ví dụ: trên x86-64 là 32 byte, trong đó 'struct semaphore'
là 24 byte và rw_semaphore là 40 byte. Kích thước cấu trúc lớn hơn có nghĩa là nhiều CPU hơn
bộ nhớ cache và dấu chân bộ nhớ.

Khi nào nên sử dụng mutexes
-------------------

Trừ khi ngữ nghĩa nghiêm ngặt của mutexes không phù hợp và/hoặc điều quan trọng
khu vực ngăn không cho khóa được chia sẻ, luôn ưu tiên chúng hơn bất kỳ khu vực nào khác
khóa nguyên thủy.
