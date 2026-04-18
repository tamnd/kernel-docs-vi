.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/RCU/rcu_dereference.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _rcu_dereference_doc:

PROPER CARE AND FEEDING CỦA RETURN VALUES FROM rcu_dereference()
===============================================================

Việc chăm sóc và cung cấp đúng cách các địa chỉ và dữ liệu phụ thuộc là rất quan trọng
điều quan trọng là phải sử dụng đúng những thứ như RCU.  Để đạt được mục đích này, các con trỏ
được trả về từ họ rcu_dereference() của địa chỉ mang nguyên thủy và
sự phụ thuộc dữ liệu.  Những phần phụ thuộc này mở rộng từ rcu_dereference()
tải con trỏ của macro để sau này sử dụng con trỏ đó để tính toán
địa chỉ của lần truy cập bộ nhớ sau này (đại diện cho một địa chỉ
phụ thuộc) hoặc giá trị được ghi bởi lần truy cập bộ nhớ sau này (biểu thị
một sự phụ thuộc dữ liệu).

Hầu hết thời gian, những phần phụ thuộc này được giữ nguyên, cho phép bạn
tự do sử dụng các giá trị từ rcu_dereference().  Ví dụ, hội thảo
(tiền tố "*"), lựa chọn trường ("->"), gán ("="), địa chỉ của
("&"), ép kiểu và cộng hoặc trừ các hằng số đều hoạt động khá tốt
một cách tự nhiên và an toàn.  Tuy nhiên, vì các trình biên dịch hiện tại không lấy
vẫn có thể tính đến sự phụ thuộc vào địa chỉ hoặc dữ liệu
để gặp rắc rối.

Thực hiện theo các quy tắc này để duy trì các phụ thuộc địa chỉ và dữ liệu phát ra
từ các cuộc gọi của bạn đến rcu_dereference() và bạn bè, do đó giữ RCU của bạn
độc giả làm việc đúng cách:

- Bạn phải sử dụng một trong các họ nguyên hàm rcu_dereference()
	để tải con trỏ được bảo vệ RCU, nếu không thì CONFIG_PROVE_RCU
	sẽ phàn nàn.  Tệ hơn nữa, mã của bạn có thể bị hỏng bộ nhớ ngẫu nhiên
	lỗi do các trò chơi mà trình biên dịch và DEC Alpha có thể chơi.
	Nếu không có một trong các hàm nguyên thủy rcu_dereference(), trình biên dịch
	có thể tải lại giá trị và mã của bạn sẽ không vui với hai
	các giá trị khác nhau cho một con trỏ!  Không có rcu_dereference(),
	DEC Alpha có thể tải một con trỏ, hủy đăng ký con trỏ đó và
	trả về dữ liệu trước lần khởi tạo trước cửa hàng
	của con trỏ.  (Như đã lưu ý sau, trong các hạt nhân gần đây READ_ONCE()
	cũng ngăn DEC Alpha chơi những trò này.)

Ngoài ra, dàn diễn viên dễ bay hơi trong rcu_dereference() sẽ ngăn cản
	trình biên dịch suy ra giá trị con trỏ kết quả.  Xin vui lòng xem
	phần có tiêu đề "EXAMPLE WHERE THE COMPILER KNOWS TOO MUCH"
	cho một ví dụ trong đó trình biên dịch trên thực tế có thể suy ra chính xác
	giá trị của con trỏ và do đó gây ra sự sắp xếp sai.

- Trong trường hợp đặc biệt dữ liệu được thêm vào nhưng không bao giờ bị xóa đi
	trong khi người đọc đang truy cập vào cấu trúc, READ_ONCE() có thể được sử dụng
	thay vì rcu_dereference().  Trong trường hợp này, sử dụng READ_ONCE()
	đảm nhận vai trò nguyên thủy lockless_dereference()
	đã bị xóa trong v4.15.

- Bạn chỉ được phép sử dụng rcu_dereference() trên các giá trị con trỏ.
	Trình biên dịch đơn giản là biết quá nhiều về các giá trị tích phân để
	tin tưởng nó sẽ mang các phụ thuộc thông qua các phép toán số nguyên.
	Có rất ít trường hợp ngoại lệ, cụ thể là bạn có thể tạm thời
	đưa con trỏ tới uintptr_t để:

- Đặt bit và xóa bit theo thứ tự thấp nhất phải bằng 0
		bit của con trỏ đó.  Điều này rõ ràng có nghĩa là con trỏ
		phải có các ràng buộc căn chỉnh, ví dụ, điều này không
		ZZ0000ZZ nói chung hoạt động với con trỏ char*.

- Các bit XOR để dịch con trỏ, như được thực hiện trong một số
		thuật toán phân bổ bạn bè cổ điển.

Điều quan trọng là truyền giá trị trở lại con trỏ trước
	làm nhiều thứ khác với nó.

- Tránh hủy bỏ khi sử dụng trung tố số học “+” và “-”
	các nhà khai thác.  Ví dụ: đối với một biến nhất định "x", hãy tránh
	"(x-(uintptr_t)x)" cho con trỏ char*.	Trình biên dịch nằm trong nó
	quyền thay thế số 0 cho loại biểu thức này, để
	các lần truy cập tiếp theo không còn phụ thuộc vào rcu_dereference(),
	một lần nữa có thể dẫn đến lỗi do sắp xếp sai.

Tất nhiên, nếu "p" là con trỏ từ rcu_dereference() và "a"
	và "b" là các số nguyên bằng nhau, biểu thức
	"p+a-b" là an toàn vì giá trị của nó nhất thiết vẫn phụ thuộc vào
	rcu_dereference(), do đó duy trì thứ tự hợp lý.

- Nếu bạn đang sử dụng RCU để bảo vệ các chức năng JITed, để
	Toán tử gọi hàm "()" được áp dụng cho giá trị thu được
	(trực tiếp hoặc gián tiếp) từ rcu_dereference(), bạn có thể cần phải
	tương tác trực tiếp với phần cứng để xóa bộ đệm hướng dẫn.
	Sự cố này phát sinh trên một số hệ thống khi một hàm JITed mới được
	sử dụng cùng bộ nhớ đã được sử dụng bởi hàm JITed trước đó.

- Không sử dụng kết quả từ các toán tử quan hệ ("==", "!=",
	">", ">=", "<" hoặc "<=") khi hội thảo.  Ví dụ,
	đoạn mã sau (khá lạ) có lỗi ::

int *p;
		int *q;

		...

p = rcu_dereference(gp)
		q = &global_q;
		q += p > &oom_p;
		r1 = ZZ0000ZZ BUGGY!!! */

Như trước đây, lý do lỗi này là do các toán tử quan hệ
	thường được biên dịch bằng cách sử dụng các nhánh.  Và như trước đây, mặc dù
	các máy có bộ nhớ yếu như ARM hay PowerPC thực hiện lưu trữ đơn hàng
	sau các nhánh như vậy, nhưng có thể suy đoán tải, có thể lại
	dẫn đến lỗi sắp xếp sai.

- Hãy thật cẩn thận khi so sánh các con trỏ thu được từ
	rcu_dereference() so với các giá trị không phải NULL.  Như Linus Torvalds
	giải thích, nếu hai con trỏ bằng nhau, trình biên dịch có thể
	thay thế con trỏ bạn đang so sánh bằng con trỏ
	thu được từ rcu_dereference().  Ví dụ::

p = rcu_dereference(gp);
		if (p == &default_struct)
			do_default(p->a);

Bởi vì trình biên dịch bây giờ biết rằng giá trị của "p" chính xác là
	địa chỉ của biến "default_struct", bạn có thể tự do
	chuyển đổi mã này thành như sau ::

p = rcu_dereference(gp);
		if (p == &default_struct)
			do_default(default_struct.a);

Trên phần cứng ARM và Power, tải từ "default_struct.a"
	bây giờ có thể được suy đoán, như vậy nó có thể xảy ra trước
	rcu_dereference().  Điều này có thể dẫn đến lỗi do sắp xếp sai.

Tuy nhiên, so sánh là ổn trong các trường hợp sau:

- So sánh với con trỏ NULL.  Nếu
		trình biên dịch biết rằng con trỏ là NULL, tốt hơn hết bạn nên
		dù sao cũng không được tham chiếu nó.  Nếu sự so sánh là
		không bằng nhau, trình biên dịch cũng không khôn ngoan hơn.  Vì vậy,
		việc so sánh các con trỏ từ rcu_dereference() là an toàn
		chống lại con trỏ NULL.

- Con trỏ không bao giờ bị hủy đăng ký sau khi được so sánh.
		Vì không có tham chiếu tiếp theo nên trình biên dịch
		không thể sử dụng bất cứ điều gì nó học được từ sự so sánh
		để sắp xếp lại các quy định không tồn tại tiếp theo.
		Kiểu so sánh này xảy ra thường xuyên khi quét
		Danh sách liên kết vòng tròn được bảo vệ bởi RCU.

Lưu ý rằng nếu việc so sánh con trỏ được thực hiện bên ngoài
		của phần quan trọng phía đọc RCU và con trỏ
		không bao giờ bị hủy đăng ký, rcu_access_pointer() sẽ là
		được sử dụng thay cho rcu_dereference().  Trong hầu hết các trường hợp,
		tốt nhất là tránh vô tình hủy đăng ký bằng cách kiểm tra
		giá trị trả về rcu_access_pointer() trực tiếp mà không cần
		gán nó cho một biến.

Trong phần quan trọng phía đọc RCU, có rất ít
		lý do nên sử dụng rcu_access_pointer().

- Việc so sánh dựa vào một con trỏ tham chiếu bộ nhớ
		đã được khởi tạo "từ lâu rồi."  Lý do
		Điều này an toàn là ngay cả khi xảy ra sai thứ tự,
		sắp xếp sai sẽ không ảnh hưởng đến các truy cập tiếp theo
		sự so sánh.  Vậy chính xác thì cách đây bao lâu là "một thời gian dài
		cách đây lâu rồi"?  Dưới đây là một số khả năng:

- Thời gian biên soạn.

- Thời gian khởi động.

- Thời gian khởi tạo mô-đun cho mã mô-đun.

- Trước khi tạo kthread cho mã kthread.

- Trong một số lần mua lại khóa trước đó
			bây giờ chúng tôi nắm giữ.

- Trước thời gian mod_timer() của bộ xử lý hẹn giờ.

Có nhiều khả năng khác liên quan đến Linux
		mảng rộng các nguyên thủy của kernel khiến mã
		sẽ được gọi vào thời điểm sau đó.

- Con trỏ được so sánh cũng đến từ
		rcu_dereference().  Trong trường hợp này, cả hai con trỏ đều phụ thuộc
		trên rcu_dereference() này hoặc trên rcu_dereference() khác, để bạn hiểu đúng
		đặt hàng một trong hai cách.

Điều đó nói lên rằng, tình huống này có thể khiến việc sử dụng RCU nhất định
		lỗi có nhiều khả năng xảy ra hơn.  Đó có thể là một điều tốt,
		ít nhất là nếu chúng xảy ra trong quá trình thử nghiệm.  Một ví dụ
		về lỗi sử dụng RCU như vậy được hiển thị trong phần có tiêu đề
		"EXAMPLE CỦA AMPLIFIED RCU-USAGE BUG".

- Tất cả các truy cập sau so sánh đều là cửa hàng,
		để sự phụ thuộc điều khiển duy trì thứ tự cần thiết.
		Điều đó nói lên rằng, rất dễ xảy ra sai sót trong việc kiểm soát các phần phụ thuộc.
		Vui lòng xem phần "CONTROL DEPENDENCIES" của
		Documentation/memory-barriers.txt để biết thêm chi tiết.

- Các con trỏ không bằng ZZ0000ZZ trình biên dịch thực hiện
		không có đủ thông tin để suy ra giá trị của
		con trỏ.  Lưu ý rằng dàn diễn viên dễ bay hơi trong rcu_dereference()
		thường sẽ ngăn trình biên dịch biết quá nhiều.

Tuy nhiên, xin lưu ý rằng nếu trình biên dịch biết rằng
		con trỏ chỉ nhận một trong hai giá trị, một giá trị không bằng nhau
		so sánh sẽ cung cấp chính xác thông tin mà
		trình biên dịch cần suy ra giá trị của con trỏ.

- Vô hiệu hóa mọi tối ưu hóa đầu cơ giá trị mà trình biên dịch của bạn
	có thể cung cấp, đặc biệt nếu bạn đang sử dụng phương pháp dựa trên phản hồi
	tối ưu hóa lấy dữ liệu được thu thập từ các lần chạy trước.  Như vậy
	tối ưu hóa việc đầu cơ giá trị sắp xếp lại các hoạt động theo thiết kế.

Có một ngoại lệ cho quy tắc này: Đầu cơ giá trị
	tối ưu hóa tận dụng phần cứng dự đoán chi nhánh là
	an toàn trên các hệ thống có thứ tự mạnh (chẳng hạn như x86), nhưng không an toàn trên các hệ thống có thứ tự yếu
	các hệ thống được đặt hàng (chẳng hạn như ARM hoặc Power).  Chọn trình biên dịch của bạn
	tùy chọn dòng lệnh một cách khôn ngoan!


EXAMPLE CỦA AMPLIFIED RCU-USAGE BUG
----------------------------------

Vì các trình cập nhật có thể chạy đồng thời với đầu đọc RCU nên đầu đọc RCU có thể
thấy các giá trị cũ và/hoặc không nhất quán.  Nếu độc giả RCU cần mới hoặc
những giá trị nhất quán, điều mà đôi khi họ vẫn làm, họ cần có những biện pháp phù hợp
biện pháp phòng ngừa.  Để thấy điều này, hãy xem xét đoạn mã sau::

cấu trúc foo {
		int một;
		int b;
		int c;
	};
	struct foo *gp1;
	struct foo *gp2;

trình cập nhật void(void)
	{
		struct foo *p;

p = kmalloc(...);
		nếu (p == NULL)
			thỏa thuận_with_it();
		p->a = 42;  /* Mỗi trường trong dòng bộ đệm riêng. */
		p->b = 43;
		p->c = 44;
		rcu_sign_pointer(gp1, p);
		p->b = 143;
		p->c = 144;
		rcu_sign_pointer(gp2, p);
	}

trình đọc void(void)
	{
		struct foo *p;
		struct foo *q;
		int r1, r2;

rcu_read_lock();
		p = rcu_dereference(gp2);
		nếu (p == NULL)
			trở lại;
		r1 = p->b;  /* Đảm bảo đạt 143. */
		q = rcu_dereference(gp1);  /* Đảm bảo không phải NULL. */
		nếu (p == q) {
			/* Trình biên dịch quyết định rằng q->c giống với p->c. */
			r2 = p->c; /* Có thể nhận được 44 trên hệ thống đặt hàng yếu. */
		} khác {
			r2 = p->c - r1; /* Truy cập vô điều kiện vào p->c. */
		}
		rcu_read_unlock();
		do_something_with(r1, r2);
	}

Bạn có thể ngạc nhiên khi kết quả (r1 == 143 && r2 == 44) có thể xảy ra,
nhưng bạn không nên như vậy.  Rốt cuộc, trình cập nhật có thể đã được gọi
lần thứ hai giữa thời gian reader() được tải vào "r1" và thời gian
mà nó được tải vào "r2".  Thực tế là kết quả tương tự này có thể xảy ra do
việc sắp xếp lại một số thứ từ trình biên dịch và CPU là điều không cần thiết.

Nhưng giả sử người đọc cần một cái nhìn nhất quán?

Sau đó, một cách tiếp cận là sử dụng khóa, ví dụ như sau::

cấu trúc foo {
		int một;
		int b;
		int c;
		khóa spinlock_t;
	};
	struct foo *gp1;
	struct foo *gp2;

trình cập nhật void(void)
	{
		struct foo *p;

p = kmalloc(...);
		nếu (p == NULL)
			thỏa thuận_with_it();
		spin_lock(&p->lock);
		p->a = 42;  /* Mỗi trường trong dòng bộ đệm riêng. */
		p->b = 43;
		p->c = 44;
		spin_unlock(&p->lock);
		rcu_sign_pointer(gp1, p);
		spin_lock(&p->lock);
		p->b = 143;
		p->c = 144;
		spin_unlock(&p->lock);
		rcu_sign_pointer(gp2, p);
	}

trình đọc void(void)
	{
		struct foo *p;
		struct foo *q;
		int r1, r2;

rcu_read_lock();
		p = rcu_dereference(gp2);
		nếu (p == NULL)
			trở lại;
		spin_lock(&p->lock);
		r1 = p->b;  /* Đảm bảo đạt 143. */
		q = rcu_dereference(gp1);  /* Đảm bảo không phải NULL. */
		nếu (p == q) {
			/* Trình biên dịch quyết định rằng q->c giống với p->c. */
			r2 = p->c; /* Khóa đảm bảo r2 == 144. */
		} khác {
			spin_lock(&q->lock);
			r2 = q->c - r1;
			spin_unlock(&q->lock);
		}
		rcu_read_unlock();
		spin_unlock(&p->lock);
		do_something_with(r1, r2);
	}

Như mọi khi, hãy sử dụng đúng công cụ cho công việc!


EXAMPLE WHERE THE COMPILER KNOWS TOO MUCH
-----------------------------------------

Nếu một con trỏ thu được từ rcu_dereference() so sánh không bằng một số
con trỏ khác, trình biên dịch thường không biết giá trị của
con trỏ đầu tiên có thể là.  Sự thiếu hiểu biết này ngăn cản trình biên dịch
từ việc thực hiện tối ưu hóa mà nếu không có thể phá hủy thứ tự
đảm bảo rằng RCU phụ thuộc vào.  Và dàn diễn viên dễ bay hơi trong rcu_dereference()
nên ngăn trình biên dịch đoán giá trị.

Nhưng nếu không có rcu_dereference(), trình biên dịch sẽ biết nhiều hơn bạn có thể
mong đợi.  Hãy xem xét đoạn mã sau::

cấu trúc foo {
		int một;
		int b;
	};
	biến cấu trúc tĩnh foo1;
	biến cấu trúc tĩnh foo2;
	cấu trúc tĩnh foo *gp = &variable1;

trình cập nhật void(void)
	{
		khởi tạo_foo(&variable2);
		rcu_sign_pointer(gp, &variable2);
		/*
		 * Ở trên là nơi lưu trữ duy nhất cho gp trong đơn vị dịch thuật này,
		 * và địa chỉ của gp không được xuất dưới bất kỳ hình thức nào.
		 */
	}

trình đọc int(void)
	{
		struct foo *p;

p = gp;
		rào cản();
		nếu (p == &biến1)
			trả lại p->a; /* Phải là biến1.a. */
		khác
			trả lại p->b; /* Phải là biến2.b. */
	}

Bởi vì trình biên dịch có thể thấy tất cả các cửa hàng chứa "gp", nên nó biết rằng chỉ có
các giá trị có thể có của "gp" một mặt là "variable1" và "variable2"
mặt khác.  Do đó, sự so sánh trong reader() sẽ báo cho trình biên dịch biết
giá trị chính xác của "p" ngay cả trong trường hợp không bằng.  Điều này cho phép
trình biên dịch để tạo ra các giá trị trả về độc lập với tải từ "gp",
lần lượt phá hủy thứ tự giữa tải này và tải của
các giá trị trả về.  Điều này có thể dẫn đến việc "p->b" trả về quá trình khởi tạo trước
giá trị rác trên các hệ thống có thứ tự yếu.

Nói tóm lại, rcu_dereference() là ZZ0000ZZ tùy chọn khi bạn định
hủy đăng ký con trỏ kết quả.


WHICH MEMBER CỦA THE rcu_dereference() FAMILY SHOULD YOU USE?
------------------------------------------------------------

Trước tiên, vui lòng tránh sử dụng rcu_dereference_raw() và cũng vui lòng tránh
sử dụng rcu_dereference_check() và rcu_dereference_protected() với
đối số thứ hai có giá trị không đổi là 1 (hoặc đúng, đối với vấn đề đó).
Với sự thận trọng đó, đây là một số hướng dẫn dành cho bạn
thành viên của rcu_dereference() để sử dụng trong nhiều tình huống khác nhau:

1. Nếu quyền truy cập cần nằm trong phạm vi quan trọng của phía đọc RCU
	phần này, hãy sử dụng rcu_dereference().  Với sự hợp nhất mới
	Hương vị RCU, phần quan trọng bên đọc RCU được nhập
	sử dụng rcu_read_lock(), bất cứ thứ gì vô hiệu hóa nửa dưới,
	bất cứ điều gì vô hiệu hóa các ngắt hoặc bất cứ điều gì vô hiệu hóa
	quyền ưu tiên.  Xin lưu ý rằng các phần quan trọng của spinlock
	cũng được ngụ ý là các phần quan trọng phía đọc RCU, ngay cả khi
	chúng có thể được ưu tiên, vì chúng nằm trong các hạt nhân được xây dựng bằng
	CONFIG_PREEMPT_RT=y.

2. Nếu quyền truy cập có thể nằm trong phần quan trọng phía đọc RCU
	một mặt hoặc được bảo vệ bởi (giả sử) my_lock mặt khác,
	sử dụng rcu_dereference_check(), ví dụ::

p1 = rcu_dereference_check(p->rcu_protected_pointer,
					   lockdep_is_held(&my_lock));


3. Nếu quyền truy cập có thể nằm trong phần quan trọng bên đọc RCU
	một mặt hoặc được bảo vệ bởi my_lock hoặc your_lock trên
	cái còn lại, lại sử dụng rcu_dereference_check(), ví dụ::

p1 = rcu_dereference_check(p->rcu_protected_pointer,
					   lockdep_is_held(&my_lock) ||
					   lockdep_is_held(&your_lock));

4. Nếu quyền truy cập nằm ở phía cập nhật, để nó luôn được bảo vệ
	bởi my_lock, sử dụng rcu_dereference_protected()::

p1 = rcu_dereference_protected(p->rcu_protected_pointer,
					       lockdep_is_held(&my_lock));

Điều này có thể được mở rộng để xử lý nhiều khóa như trong #3 ở trên,
	và cả hai đều có thể được mở rộng để kiểm tra các điều kiện khác.

5. Nếu biện pháp bảo vệ được cung cấp bởi người gọi và do đó không xác định được
	đối với mã này, đó là trường hợp hiếm gặp khi rcu_dereference_raw()
	là phù hợp.  Ngoài ra, rcu_dereference_raw() có thể
	thích hợp khi biểu thức lockdep quá mức
	phức tạp, ngoại trừ cách tiếp cận tốt hơn trong trường hợp đó có thể là
	hãy xem xét kỹ thiết kế đồng bộ hóa của bạn.  Tuy nhiên,
	có những trường hợp khóa dữ liệu trong đó bất kỳ một trong số rất lớn
	các khóa hoặc bộ đếm tham chiếu đủ để bảo vệ con trỏ,
	vì vậy rcu_dereference_raw() có vị trí của nó.

Tuy nhiên, vị trí của nó có lẽ nhỏ hơn một chút so với một
	có thể mong đợi dựa trên số lượng sử dụng trong kernel hiện tại.
	Tương tự với từ đồng nghĩa của nó, rcu_dereference_check( ... , 1) và
	Họ hàng gần của nó, rcu_dereference_protected(..., 1).


SPARSE CHECKING CỦA RCU-PROTECTED POINTERS
-----------------------------------------

Công cụ phân tích tĩnh thưa thớt kiểm tra quyền truy cập không phải RCU vào RCU được bảo vệ
con trỏ, có thể gây ra lỗi "thú vị" do trình biên dịch
tối ưu hóa liên quan đến tải được phát minh và có lẽ cả việc xé tải.
Ví dụ: giả sử ai đó làm nhầm điều gì đó như thế này ::

p = q->rcu_protected_pointer;
	do_something_with(p->a);
	do_something_else_with(p->b);

Nếu áp suất thanh ghi cao, trình biên dịch có thể tối ưu hóa "p"
của sự tồn tại, chuyển đổi mã thành một cái gì đó như thế này ::

do_something_with(q->rcu_protected_pointer->a);
	do_something_else_with(q->rcu_protected_pointer->b);

Điều này có thể làm mã của bạn thất vọng nếu q->rcu_protected_pointer
đã thay đổi trong thời gian đó.  Đây cũng không phải là vấn đề lý thuyết: Chính xác
loại lỗi này đã khiến Paul E. McKenney phải trả giá (và một số người vô tội của anh ta).
đồng nghiệp) một ngày cuối tuần ba ngày vào đầu những năm 1990.

Tất nhiên, việc xé tải có thể dẫn đến việc hủy tham chiếu một bản kết hợp của một cặp
của con trỏ, điều này cũng có thể làm mã của bạn thất vọng.

Những vấn đề này có thể tránh được đơn giản bằng cách tạo mã thay thế
đọc như sau::

p = rcu_dereference(q->rcu_protected_pointer);
	do_something_with(p->a);
	do_something_else_with(p->b);

Thật không may, những loại lỗi này có thể cực kỳ khó phát hiện trong quá trình
xem xét.  Đây là lúc công cụ thưa thớt phát huy tác dụng, cùng với
điểm đánh dấu "__rcu".  Nếu bạn đánh dấu một khai báo con trỏ, dù trong một cấu trúc
hoặc dưới dạng tham số chính thức, với "__rcu", thông báo cho thưa thớt khiếu nại nếu
con trỏ này được truy cập trực tiếp.  Nó cũng sẽ khiến thưa thớt phàn nàn
nếu một con trỏ không được đánh dấu bằng "__rcu" được truy cập bằng rcu_dereference()
và bạn bè.  Ví dụ: ->rcu_protected_pointer có thể được khai báo là
sau::

struct foo __rcu *rcu_protected_pointer;

Việc sử dụng "__rcu" là tùy chọn tham gia.  Nếu bạn chọn không sử dụng nó thì bạn nên
bỏ qua các cảnh báo thưa thớt.
