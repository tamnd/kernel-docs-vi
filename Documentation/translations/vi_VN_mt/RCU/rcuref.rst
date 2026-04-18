.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/RCU/rcuref.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================================================================
Thiết kế đếm tham chiếu cho các thành phần của danh sách/mảng được bảo vệ bởi RCU
=================================================================================


Xin lưu ý rằng tính năng percpu-ref có thể là tính năng đầu tiên của bạn
dừng lại nếu bạn cần kết hợp số lượng tham chiếu và RCU.  Xin vui lòng xem
include/linux/percpu-refcount.h để biết thêm thông tin.  Tuy nhiên, trong
những trường hợp bất thường trong đó percpu-ref sẽ tiêu tốn quá nhiều bộ nhớ,
xin vui lòng đọc tiếp.

-------------------------------------------------------------------------

Việc đếm tham chiếu trên các thành phần của danh sách được bảo vệ theo cách truyền thống
spinlocks hoặc semaphores của trình đọc/ghi rất đơn giản:

CODE LISTING MỘT::

1. 2.
    thêm() tìm kiếm_and_reference()
    { {
	alloc_object read_lock(&list_lock);
	...					search_for_element
Atomic_set(&el->rc, 1);			Atomic_inc(&el->rc);
	write_lock(&list_lock);			 ...
	add_element read_unlock(&list_lock);
	...					...
write_unlock(&list_lock);	   }
    }

3. 4.
    Release_referenced() xóa()
    { {
	...					write_lock(&list_lock);
if(atomic_dec_and_test(&el->rc)) ...
	    kfree(el);
	...					remove_element
    }						write_unlock(&list_lock);
						...
						if (atomic_dec_and_test(&el->rc))
						    kfree(el);
						...
					    }

Nếu danh sách/mảng này được khóa miễn phí bằng cách sử dụng RCU như khi thay đổi
write_lock() trong add() và delete() thành spin_lock() và thay đổi read_lock()
trong search_and_reference() tới rcu_read_lock(), Atomic_inc() trong
search_and_reference() có khả năng chứa tham chiếu đến một phần tử
đã bị xóa khỏi danh sách/mảng.  Sử dụng Atomic_inc_not_zero()
trong tình huống này như sau:

CODE LISTING B::

1. 2.
    thêm() tìm kiếm_and_reference()
    { {
	alloc_object rcu_read_lock();
	...					search_for_element
Atomic_set(&el->rc, 1);			if (!atomic_inc_not_zero(&el->rc)) {
	spin_lock(&list_lock);			    rcu_read_unlock();
						    trả lại FAIL;
	add_element }
	...					...
spin_unlock(&list_lock);		rcu_read_unlock();
    } }
    3. 4.
    Release_referenced() xóa()
    { {
	...					spin_lock(&list_lock);
nếu (atomic_dec_and_test(&el->rc)) ...
	    call_rcu(&el->head, el_free);	xóa_element
	...					spin_unlock(&list_lock);
    }						...
						if (atomic_dec_and_test(&el->rc))
						    call_rcu(&el->head, el_free);
						...
					    }

Đôi khi, cần phải có một tham chiếu đến phần tử trong
luồng cập nhật (ghi).	Trong những trường hợp như vậy, Atomic_inc_not_zero() có thể là
quá mức cần thiết vì chúng tôi giữ spinlock bên cập nhật.  Thay vào đó người ta có thể
sử dụng Atomic_inc() trong những trường hợp như vậy.

Không phải lúc nào cũng thuận tiện khi xử lý "FAIL" trong
đường dẫn mã search_and_reference().  Trong những trường hợp như vậy,
Atomic_dec_and_test() có thể được chuyển từ delete() sang el_free()
như sau:

CODE LISTING C::

1. 2.
    thêm() tìm kiếm_and_reference()
    { {
	alloc_object rcu_read_lock();
	...					search_for_element
Atomic_set(&el->rc, 1);			Atomic_inc(&el->rc);
	spin_lock(&list_lock);			...

add_element rcu_read_unlock();
	...				    }
spin_unlock(&list_lock);	    4.
    } xóa()
    3. {
    Release_referenced() spin_lock(&list_lock);
    { ...
	...					remove_element
if (atomic_dec_and_test(&el->rc)) spin_unlock(&list_lock);
	    kfree(el);				...
	...					call_rcu(&el->head, el_free);
    }						...
    5.					    }
    void el_free(struct rcu_head *rhp)
    {
phát hành_referenced();
    }

Điểm mấu chốt là tham chiếu ban đầu được thêm bởi add() không bị xóa
cho đến khi thời gian gia hạn đã trôi qua sau khi xóa.  Điều này có nghĩa là
search_and_reference() không thể tìm thấy phần tử này, điều đó có nghĩa là giá trị
của el->rc không thể tăng.  Vì vậy, một khi nó đạt tới số 0 thì không có
độc giả có thể hoặc sẽ có thể tham chiếu phần tử đó.	 các
do đó phần tử có thể được giải phóng một cách an toàn.	Điều này lại đảm bảo rằng nếu
bất kỳ người đọc nào tìm thấy phần tử đó, người đọc đó có thể lấy được tham chiếu một cách an toàn
mà không kiểm tra giá trị của bộ đếm tham chiếu.

Ưu điểm rõ ràng của mẫu dựa trên RCU trong việc liệt kê C so với mẫu
trong danh sách B là bất kỳ lệnh gọi tới search_and_reference() nào định vị
một đối tượng nhất định sẽ thành công trong việc lấy được một tham chiếu đến đối tượng đó,
thậm chí còn đưa ra lệnh gọi đồng thời delete() cho cùng một đối tượng.
Tương tự, lợi thế rõ ràng của cả danh sách B và C so với danh sách A là
lệnh gọi delete() không bị trì hoãn ngay cả khi có lệnh tùy ý
số lượng lớn các cuộc gọi tới search_and_reference() để tìm kiếm điều tương tự
đối tượng xóa() đã được gọi.  Thay vào đó, tất cả những gì bị trì hoãn là
lệnh gọi cuối cùng của kfree(), thường không phải là vấn đề trên
hệ thống máy tính hiện đại, ngay cả những máy tính nhỏ.

Trong trường hợp delete() có thể ngủ, sync_rcu() có thể được gọi từ
delete(), do đó el_free() có thể được gộp thành delete như sau::

4.
    xóa()
    {
	spin_lock(&list_lock);
	...
xóa_element
	spin_unlock(&list_lock);
	...
đồng bộ hóa_rcu();
	if (atomic_dec_and_test(&el->rc))
	    kfree(el);
	...
    }

Như các ví dụ bổ sung trong kernel, mẫu trong danh sách C được sử dụng bởi
việc đếm tham chiếu của struct pid, trong khi mẫu trong danh sách B được sử dụng bởi
cấu trúc posix_acl.