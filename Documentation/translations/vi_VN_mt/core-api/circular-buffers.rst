.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/circular-buffers.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==================
Bộ đệm tròn
================

:Tác giả: David Howells <dhowells@redhat.com>
:Tác giả: Paul E. McKenney <paulmck@linux.ibm.com>


Linux cung cấp một số tính năng có thể được sử dụng để triển khai vòng tròn
đệm.  Có hai bộ tính năng như vậy:

(1) Các hàm thuận tiện cho việc xác định thông tin về lũy thừa cỡ 2
     bộ đệm.

(2) Rào cản trí nhớ về thời điểm người sản xuất và người tiêu dùng đồ vật trong
     bộ đệm không muốn chia sẻ khóa.

Để sử dụng những cơ sở này, như được thảo luận dưới đây, chỉ cần có một
người sản xuất và chỉ một người tiêu dùng.  Có thể xử lý nhiều nhà sản xuất bằng cách
tuần tự hóa chúng và xử lý nhiều người tiêu dùng bằng cách tuần tự hóa chúng.


.. Contents:

 (*) What is a circular buffer?

 (*) Measuring power-of-2 buffers.

 (*) Using memory barriers with circular buffers.
     - The producer.
     - The consumer.



Bộ đệm tròn là gì?
==========================

Trước hết, bộ đệm tròn là gì?  Bộ đệm tròn là bộ đệm của
kích thước cố định, hữu hạn trong đó có hai chỉ số:

(1) Chỉ số 'đầu' - điểm mà tại đó nhà sản xuất chèn các mục vào
     bộ đệm.

(2) Chỉ số 'đuôi' - điểm mà người tiêu dùng tìm thấy mặt hàng tiếp theo trong
     bộ đệm.

Thông thường khi con trỏ đuôi bằng con trỏ đầu thì bộ đệm sẽ
trống rỗng; và bộ đệm đầy khi con trỏ đầu nhỏ hơn con trỏ đuôi một đơn vị
con trỏ.

Chỉ số đầu tăng lên khi các mục được thêm vào và chỉ mục đuôi khi
các mục được loại bỏ.  Chỉ số đuôi không bao giờ được nhảy chỉ số đầu và cả hai
các chỉ số phải được gói về 0 khi chúng đến cuối bộ đệm, do đó
cho phép một lượng dữ liệu vô hạn chảy qua bộ đệm.

Thông thường, tất cả các mặt hàng sẽ có cùng kích thước đơn vị, nhưng điều này không hoàn toàn chính xác.
bắt buộc phải sử dụng các kỹ thuật dưới đây.  Chỉ số có thể tăng thêm
hơn 1 nếu có nhiều mục hoặc các mục có kích thước thay đổi được đưa vào
bộ đệm, miễn là không có chỉ mục nào vượt qua chỉ mục kia.  Người thực hiện phải
Tuy nhiên, hãy cẩn thận vì một vùng có kích thước lớn hơn một đơn vị có thể bao bọc phần cuối của
bộ đệm và được chia thành hai phân đoạn.

Đo công suất của 2 bộ đệm
============================

Tính toán công suất sử dụng hoặc sức chứa còn lại của một căn hộ có kích thước tùy ý
Bộ đệm tròn thường hoạt động chậm, đòi hỏi phải sử dụng
lệnh mô-đun (chia).  Tuy nhiên, nếu bộ đệm có kích thước lũy thừa 2,
thì có thể sử dụng lệnh bitwise-AND nhanh hơn nhiều để thay thế.

Linux cung cấp một tập hợp các macro để xử lý bộ đệm vòng tròn power-of-2.  Những cái này
có thể được sử dụng bởi::

#include <linux/circ_buf.h>

Các macro là:

(#) Đo dung lượng còn lại của bộ đệm::

CIRC_SPACE(head_index, tail_index, buffer_size);

Điều này trả về lượng không gian còn lại trong bộ đệm [1] mà các mục
     có thể được chèn vào.


(#) Đo khoảng trống tức thời tối đa liên tiếp trong bộ đệm::

CIRC_SPACE_TO_END(head_index, tail_index, buffer_size);

Điều này trả về lượng không gian liên tiếp còn lại trong bộ đệm [1] thành
     những mục nào có thể được chèn ngay lập tức mà không cần phải bọc lại vào
     đầu của bộ đệm.


(#) Đo mức độ chiếm dụng của bộ đệm::

CIRC_CNT(head_index, tail_index, buffer_size);

Điều này trả về số lượng mục hiện đang chiếm bộ đệm [2].


(#) Đo mức độ chiếm chỗ không bao bọc của bộ đệm::

CIRC_CNT_TO_END(head_index, tail_index, buffer_size);

Điều này trả về số lượng mục liên tiếp[2] có thể được trích xuất từ ​​
     bộ đệm mà không cần phải quay lại phần đầu của bộ đệm.


Mỗi macro này trên danh nghĩa sẽ trả về giá trị từ 0 đến buffer_size-1,
tuy nhiên:

(1) CIRC_SPACE*() được thiết kế để sử dụng trong nhà sản xuất.  Gửi nhà sản xuất
     họ sẽ trả về giới hạn dưới khi nhà sản xuất kiểm soát chỉ số đầu,
     nhưng người tiêu dùng vẫn có thể làm cạn bộ đệm trên một CPU khác và
     di chuyển chỉ số đuôi.

Đối với người tiêu dùng, nó sẽ hiển thị giới hạn trên vì nhà sản xuất có thể bận
     làm cạn kiệt không gian.

(2) CIRC_CNT*() được thiết kế để sử dụng cho người tiêu dùng.  Đối với người tiêu dùng, họ
     sẽ trả về giới hạn dưới khi người tiêu dùng kiểm soát chỉ số đuôi, nhưng
     nhà sản xuất có thể vẫn đang lấp đầy bộ đệm trên một chiếc CPU khác và di chuyển
     chỉ số đầu.

Đối với nhà sản xuất, nó sẽ hiển thị giới hạn trên vì người tiêu dùng có thể bận
     làm trống bộ đệm.

(3) Đối với bên thứ ba, thứ tự ghi vào các chỉ mục của
     nhà sản xuất và người tiêu dùng có thể nhìn thấy được không thể được đảm bảo vì họ
     độc lập và có thể được thực hiện trên các CPU khác nhau - vì vậy kết quả là như vậy
     tình huống sẽ chỉ là phỏng đoán và thậm chí có thể tiêu cực.

Sử dụng rào cản bộ nhớ với bộ đệm tròn
===========================================

Bằng cách sử dụng các rào cản bộ nhớ kết hợp với bộ đệm tròn, bạn có thể tránh được
sự cần thiết phải:

(1) sử dụng một khóa duy nhất để quản lý quyền truy cập vào cả hai đầu của bộ đệm, do đó
     cho phép bộ đệm được lấp đầy và làm trống cùng một lúc; Và

(2) sử dụng các hoạt động truy cập nguyên tử.

Vấn đề này có hai mặt: nhà sản xuất lấp đầy bộ đệm và
người tiêu dùng làm trống nó.  Chỉ có một điều nên làm đầy bộ đệm ở bất kỳ bộ đệm nào
thời gian và chỉ có một thứ sẽ làm trống bộ đệm bất cứ lúc nào, nhưng
hai bên có thể hoạt động đồng thời.


Nhà sản xuất
------------

Nhà sản xuất sẽ trông giống như thế này::

spin_lock(&producer_lock);

đầu dài không dấu = bộ đệm-> đầu;
	/* Spin_unlock() và spin_lock() tiếp theo cung cấp thứ tự cần thiết. */
	đuôi dài không dấu = READ_ONCE(đệm->đuôi);

if (CIRC_SPACE(đầu, đuôi, bộ đệm->kích thước) >= 1) {
		/* chèn một mục vào bộ đệm */
		mục cấu trúc *item = buffer[head];

sản xuất_item(mục);

smp_store_release(bộ đệm->đầu,
				  (đầu + 1) & (bộ đệm-> kích thước - 1));

/* Wake_up() sẽ đảm bảo rằng phần đầu được cam kết trước đó
		 *đánh thức ai dậy*/
		Wake_up(người tiêu dùng);
	}

spin_unlock(&producer_lock);

Điều này sẽ hướng dẫn CPU rằng nội dung của mục mới phải được ghi
trước khi chỉ mục head cung cấp cho người tiêu dùng và sau đó hướng dẫn
CPU rằng chỉ số đầu sửa đổi phải được viết trước khi người tiêu dùng thức dậy.

Lưu ý rằng Wake_up() không đảm bảo bất kỳ loại rào cản nào trừ khi có điều gì đó
thực sự đã được đánh thức.  Do đó chúng tôi không thể dựa vào nó để đặt hàng.  Tuy nhiên,
luôn có một phần tử của mảng bị bỏ trống.  Vì vậy,
nhà sản xuất phải sản xuất hai yếu tố trước khi nó có thể làm hỏng
phần tử hiện đang được người tiêu dùng đọc.  Vì vậy, việc mở khóa
cặp giữa các lệnh gọi liên tiếp của người tiêu dùng cung cấp sự cần thiết
sắp xếp giữa lần đọc chỉ mục cho biết rằng người tiêu dùng có
đã bỏ trống một phần tử nhất định và nhà sản xuất viết vào phần tử đó.


Người tiêu dùng
------------

Người tiêu dùng sẽ trông giống như thế này::

spin_lock(&consumer_lock);

/* Đọc chỉ mục trước khi đọc nội dung tại chỉ mục đó. */
	đầu dài không dấu = smp_load_acquire(buffer->head);
	đuôi dài không dấu = đệm->đuôi;

if (CIRC_CNT(đầu, đuôi, bộ đệm->kích thước) >= 1) {

/* trích xuất một mục từ bộ đệm */
		mục cấu trúc *item = buffer[tail];

tiêu thụ_item(item);

/* Đọc xong phần mô tả trước khi tăng đuôi. */
		smp_store_release(đệm->đuôi,
				  (đuôi + 1) & (bộ đệm-> kích thước - 1));
	}

spin_unlock(&consumer_lock);

Điều này sẽ hướng dẫn CPU đảm bảo chỉ mục được cập nhật trước khi đọc
mục mới và sau đó nó sẽ đảm bảo CPU đã đọc xong mục đó
trước khi nó ghi con trỏ đuôi mới, con trỏ này sẽ xóa mục đó.

Lưu ý việc sử dụng READ_ONCE() và smp_load_acquire() để đọc
chỉ số đối lập  Điều này ngăn cản trình biên dịch loại bỏ và
tải lại giá trị được lưu trong bộ nhớ cache của nó.  Điều này không thực sự cần thiết nếu bạn có thể
hãy chắc chắn rằng chỉ số đối lập sẽ _chỉ_ được sử dụng một lần.
Ngoài ra, smp_load_acquire() còn buộc CPU ra lệnh chống lại
tham chiếu bộ nhớ tiếp theo.  Tương tự, smp_store_release() được sử dụng
trong cả hai thuật toán để ghi chỉ mục của luồng.  Tài liệu này
thực tế là chúng ta đang viết lên thứ gì đó có thể đọc đồng thời,
ngăn trình biên dịch xé cửa hàng và thực thi việc sắp xếp
chống lại các truy cập trước đó.


Đọc thêm
===============

Xem thêm Documentation/memory-barriers.txt để biết mô tả về bộ nhớ của Linux
cơ sở rào cản.
