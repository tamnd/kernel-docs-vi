.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/locking/seqlock.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=========================================
Bộ đếm tuần tự và khóa tuần tự
======================================

Giới thiệu
============

Bộ đếm trình tự là một cơ chế nhất quán giữa đầu đọc và ghi với
trình đọc không khóa (vòng lặp thử lại chỉ đọc) và không có tình trạng đói của người viết. Họ
được sử dụng cho dữ liệu hiếm khi được ghi vào (ví dụ: thời gian hệ thống), trong đó
Người đọc muốn có một bộ thông tin nhất quán và sẵn sàng thử lại nếu
thông tin đó thay đổi.

Một tập dữ liệu nhất quán khi số thứ tự ở đầu
phần quan trọng của bên đọc là chẵn và giá trị đếm chuỗi giống nhau là
đọc lại ở cuối phần quan trọng. Dữ liệu trong tập hợp phải
được sao chép ra bên trong phần quan trọng bên đọc. Nếu trình tự
số lượng đã thay đổi giữa phần đầu và phần cuối của phần quan trọng,
người đọc phải thử lại.

Người viết tăng số lượng trình tự ở đầu và cuối câu chuyện của họ
phần quan trọng. Sau khi bắt đầu phần quan trọng, số lượng trình tự
là số lẻ và cho người đọc biết rằng một bản cập nhật đang được tiến hành. Tại
ở phần cuối của phần quan trọng bên ghi, số lượng chuỗi sẽ trở thành
thậm chí một lần nữa cho phép người đọc tiến bộ.

Phần quan trọng của bên ghi bộ đếm trình tự không bao giờ được ưu tiên
hoặc bị gián đoạn bởi các phần bên đọc. Nếu không người đọc sẽ quay cuồng
toàn bộ lịch trình đánh dấu do giá trị đếm chuỗi lẻ và
nhà văn bị gián đoạn. Nếu đầu đọc đó thuộc về một lịch trình thời gian thực
class, nó có thể quay mãi mãi và kernel sẽ hoạt động.

Cơ chế này không thể được sử dụng nếu dữ liệu được bảo vệ chứa con trỏ,
vì người viết có thể vô hiệu hóa một con trỏ mà người đọc đang theo dõi.


.. _seqcount_t:

Bộ đếm trình tự (ZZ0000ZZ)
==================================

Đây là cơ chế đếm thô, không bảo vệ chống lại
nhiều nhà văn.  Do đó, các phần quan trọng bên ghi phải được tuần tự hóa
bằng khóa bên ngoài.

Nếu nguyên thủy ghi tuần tự hóa không bị vô hiệu hóa hoàn toàn
quyền ưu tiên, quyền ưu tiên phải được vô hiệu hóa một cách rõ ràng trước khi vào
viết phần bên. Nếu phần đọc có thể được gọi từ hardirq hoặc
bối cảnh softirq, các ngắt hoặc nửa dưới cũng phải tương ứng
bị vô hiệu hóa trước khi vào phần ghi.

Nếu muốn tự động xử lý bộ đếm trình tự
yêu cầu về việc tuần tự hóa nhà văn và tính không được ưu tiên, sử dụng
Thay vào đó là ZZ0000ZZ.

Khởi tạo::

/* động */
	seqcount_t foo_seqcount;
	seqcount_init(&foo_seqcount);

/* tĩnh */
	seqcount_t tĩnh foo_seqcount = SEQCNT_ZERO(foo_seqcount);

/* C99 cấu trúc ban đầu */
	cấu trúc {
		.seq = SEQCNT_ZERO(foo.seq),
	} foo;

Viết đường dẫn::

/* Ngữ cảnh được tuần tự hóa với quyền ưu tiên bị vô hiệu hóa */

write_seqcount_begin(&foo_seqcount);

/* ... [[phần quan trọng bên ghi]] ... */

write_seqcount_end(&foo_seqcount);

Đọc đường dẫn::

làm {
		seq = read_seqcount_begin(&foo_seqcount);

/* ... [[phần quan trọng phía đọc]] ... */

} while (read_seqcount_retry(&foo_seqcount, seq));


.. _seqcount_locktype_t:

Bộ đếm trình tự có khóa liên quan (ZZ0000ZZ)
-----------------------------------------------------------------

Như đã thảo luận tại ZZ0000ZZ, số lượng trình tự bên ghi quan trọng
các phần phải được tuần tự hóa và không được ưu tiên trước. Biến thể này của
bộ đếm trình tự liên kết khóa được sử dụng để tuần tự hóa trình ghi tại
thời gian khởi tạo, cho phép lockdep xác thực rằng việc ghi
các phần quan trọng bên được tuần tự hóa đúng cách.

Liên kết khóa này là NOOP nếu lockdep bị tắt và không có
chi phí lưu trữ cũng như thời gian chạy. Nếu lockdep được bật, con trỏ khóa sẽ
được lưu trữ trong struct seqcount và xác nhận "khóa được giữ" của lockdep là
được chèn vào đầu phần quan trọng của bên ghi để xác thực
rằng nó được bảo vệ đúng cách.

Đối với các loại khóa không ngầm vô hiệu hóa quyền ưu tiên, quyền ưu tiên
việc bảo vệ được thực thi ở chức năng bên ghi.

Các bộ đếm trình tự sau đây có khóa liên quan được xác định:

-ZZ0000ZZ
  -ZZ0001ZZ
  -ZZ0002ZZ
  -ZZ0003ZZ
  -ZZ0004ZZ

API đọc và ghi của bộ đếm trình tự có thể đơn giản
seqcount_t hoặc bất kỳ biến thể seqcount_LOCKNAME_t nào ở trên.

Khởi tạo (thay thế "LOCKNAME" bằng một trong các khóa được hỗ trợ)::

/* động */
	seqcount_LOCKNAME_t foo_seqcount;
	seqcount_LOCKNAME_init(&foo_seqcount, &lock);

/* tĩnh */
	seqcount_LOCKNAME_t foo_seqcount tĩnh =
		SEQCNT_LOCKNAME_ZERO(foo_seqcount, &lock);

/* C99 cấu trúc ban đầu */
	cấu trúc {
		.seq = SEQCNT_LOCKNAME_ZERO(foo.seq, &lock),
	} foo;

Đường dẫn ghi: giống như trong ZZ0000ZZ, trong khi chạy từ ngữ cảnh
có được khóa tuần tự ghi liên quan.

Đường dẫn đọc: giống như trong ZZ0000ZZ.


.. _seqcount_latch_t:

Bộ đếm trình tự chốt (ZZ0000ZZ)
----------------------------------------------

Bộ đếm trình tự chốt là một cơ chế kiểm soát đồng thời nhiều phiên bản
trong đó giá trị chẵn/lẻ của bộ đếm seqcount_t được nhúng được sử dụng để chuyển đổi
giữa hai bản sao của dữ liệu được bảo vệ. Điều này cho phép bộ đếm trình tự
đường dẫn đọc để ngắt đoạn quan trọng bên ghi của chính nó một cách an toàn.

Sử dụng seqcount_latch_t khi phần bên ghi không thể được bảo vệ
khỏi sự gián đoạn của độc giả. Điều này thường xảy ra khi đọc
bên có thể được gọi từ trình xử lý NMI.

Kiểm tra ZZ0000ZZ để biết thêm thông tin.


.. _seqlock_t:

Khóa tuần tự (ZZ0000ZZ)
================================

Phần này chứa cơ chế ZZ0000ZZ đã được thảo luận trước đó, cùng với một
spinlock nhúng để tuần tự hóa nhà văn và không có quyền ưu tiên.

Nếu phần bên đọc có thể được gọi từ ngữ cảnh hardirq hoặc softirq,
sử dụng các biến thể chức năng bên ghi để vô hiệu hóa các ngắt hoặc đáy
một nửa tương ứng.

Khởi tạo::

/* động */
	seqlock_t foo_seqlock;
	seqlock_init(&foo_seqlock);

/* tĩnh */
	DEFINE_SEQLOCK tĩnh (foo_seqlock);

/* C99 cấu trúc ban đầu */
	cấu trúc {
		.seql = __SEQLOCK_UNLOCKED(foo.seql)
	} foo;

Viết đường dẫn::

write_seqlock(&foo_seqlock);

/* ... [[phần quan trọng bên ghi]] ... */

write_sequnlock(&foo_seqlock);

Đọc đường dẫn, ba loại:

1. Trình đọc Trình tự Thông thường không bao giờ chặn người viết nhưng họ phải
   thử lại nếu quá trình ghi đang được tiến hành bằng cách phát hiện sự thay đổi trong trình tự
   số.  Người viết không chờ người đọc trình tự::

làm {
		seq = read_seqbegin(&foo_seqlock);

/* ... [[phần quan trọng phía đọc]] ... */

} while (read_seqretry(&foo_seqlock, seq));

2. Khóa trình đọc sẽ chờ nếu trình ghi hoặc trình đọc khác khóa
   đang được tiến hành. Trình đọc đang khóa cũng sẽ chặn trình ghi
   khỏi việc đi vào phần quan trọng của nó. Khóa đọc này là
   độc quyền. Không giống như rwlock_t, chỉ có một trình đọc khóa có thể lấy được nó ::

read_seqlock_excl(&foo_seqlock);

/* ... [[phần quan trọng phía đọc]] ... */

read_sequnlock_excl(&foo_seqlock);

3. Đầu đọc không khóa có điều kiện (như ở phần 1), hoặc đầu đọc có khóa (như ở phần 2),
   theo một điểm đánh dấu đã được thông qua. Điều này được sử dụng để tránh những đầu đọc không khóa
   chết đói (quá nhiều vòng lặp thử lại) trong trường hợp tốc độ ghi tăng đột biến
   hoạt động. Đầu tiên, việc đọc không khóa được thử (thậm chí cả điểm đánh dấu đã được thông qua). Nếu
   thử nghiệm đó không thành công (bộ đếm trình tự không khớp), hãy đánh dấu
   số lẻ cho lần lặp tiếp theo, việc đọc không khóa được chuyển thành
   đọc toàn bộ khóa và không cần vòng lặp thử lại, ví dụ::

/* điểm đánh dấu; khởi tạo chẵn */
	int seq = 1;
	làm {
		seq++; /* 2 trên đường dẫn đầu tiên/không khóa, nếu không thì là số lẻ */
		read_seqbegin_or_lock(&foo_seqlock, &seq);

/* ... [[phần quan trọng phía đọc]] ... */

} while (need_seqretry(&foo_seqlock, seq));
	done_seqretry(&foo_seqlock, seq);


Tài liệu API
=================

.. kernel-doc:: include/linux/seqlock.h