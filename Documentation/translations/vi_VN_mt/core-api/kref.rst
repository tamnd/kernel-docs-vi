.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/kref.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================================================
Thêm bộ đếm tham chiếu (krefs) vào đối tượng kernel
===================================================

:Tác giả: Corey Minyard <minyard@acm.org>
:Tác giả: Thomas Hellström <thomas.hellstrom@linux.intel.com>

Phần lớn trong số này được rút ra từ bài báo OLS của Greg Kroah-Hartman năm 2004 và
bài thuyết trình về krefs, có thể tìm thấy tại:

-ZZ0000ZZ
  -ZZ0001ZZ

Giới thiệu
============

krefs cho phép bạn thêm bộ đếm tham chiếu vào đối tượng của mình.  Nếu bạn
có các đồ vật được sử dụng ở nhiều nơi và được chuyển đi khắp nơi, và
bạn không được hoàn tiền, mã của bạn gần như chắc chắn bị hỏng.  Nếu
bạn muốn được hoàn tiền, krefs là lựa chọn phù hợp.

Để sử dụng kref, hãy thêm một kref vào cấu trúc dữ liệu của bạn như ::

cấu trúc my_data
    {
	.
	.
	struct kref đếm lại;
	.
	.
    };

Kref có thể xảy ra ở bất cứ đâu trong cấu trúc dữ liệu.

Khởi tạo
==============

Bạn phải khởi tạo kref sau khi phân bổ nó.  Để thực hiện việc này, hãy gọi
kref_init như vậy::

cấu trúc dữ liệu my_data *;

dữ liệu = kmalloc(sizeof(*data), GFP_KERNEL);
     nếu (!dữ liệu)
            trả về -ENOMEM;
     kref_init(&data->refcount);

Điều này đặt số lần đếm trong kref thành 1.

quy tắc Kref
==========

Khi bạn đã có kref được khởi tạo, bạn phải làm theo những điều sau
quy tắc:

1) Nếu bạn tạo một bản sao không tạm thời của một con trỏ, đặc biệt nếu
   nó có thể được chuyển sang một luồng thực thi khác, bạn phải
   tăng số tiền hoàn lại bằng kref_get() trước khi chuyển nó đi::

kref_get(&data->refcount);

Nếu bạn đã có một con trỏ hợp lệ tới cấu trúc kref-ed (
   số tiền hoàn lại không thể về 0), bạn có thể thực hiện việc này mà không cần khóa.

2) Khi bạn sử dụng xong con trỏ, bạn phải gọi kref_put()::

kref_put(&data->refcount, data_release);

Nếu đây là tham chiếu cuối cùng tới con trỏ thì việc giải phóng
   thói quen sẽ được gọi.  Nếu mã không bao giờ cố gắng để có được
   một con trỏ hợp lệ tới cấu trúc kref-ed mà chưa có
   giữ một con trỏ hợp lệ, có thể thực hiện việc này một cách an toàn mà không cần
   một cái khóa.

3) Nếu mã cố gắng lấy tham chiếu đến cấu trúc kref-ed
   mà không giữ một con trỏ hợp lệ, nó phải tuần tự hóa quyền truy cập
   trong đó kref_put() không thể xảy ra trong kref_get() và
   cấu trúc phải duy trì hiệu lực trong kref_get().

Ví dụ: nếu bạn phân bổ một số dữ liệu và sau đó chuyển nó sang dữ liệu khác
chủ đề để xử lý::

void data_release(struct kref *ref)
    {
	struct my_data *data = container_of(ref, struct my_data, refcount);
	kfree(dữ liệu);
    }

void more_data_handling(void *cb_data)
    {
	struct my_data *data = cb_data;
	.
	. làm mọi thứ với dữ liệu ở đây
	.
	kref_put(&data->refcount, data_release);
    }

int my_data_handler(void)
    {
	int rv = 0;
	cấu trúc dữ liệu my_data *;
	struct task_struct *task;
	dữ liệu = kmalloc(sizeof(*data), GFP_KERNEL);
	nếu (!dữ liệu)
		trả về -ENOMEM;
	kref_init(&data->refcount);

kref_get(&data->refcount);
	task = kthread_run(more_data_handling, data, "more_data_handling");
	nếu (tác vụ == ERR_PTR(-ENOMEM)) {
		rv = -ENOMEM;
	        kref_put(&data->refcount, data_release);
		đi ra ngoài;
	}

.
	. làm mọi thứ với dữ liệu ở đây
	.
    ra:
	kref_put(&data->refcount, data_release);
	trở lại rv;
    }

Bằng cách này, việc hai luồng xử lý thứ tự nào không quan trọng
dữ liệu, kref_put() xử lý việc biết khi nào dữ liệu không được tham chiếu
nữa và thả nó ra.  kref_get() không yêu cầu khóa,
vì chúng tôi đã có một con trỏ hợp lệ mà chúng tôi sở hữu số tiền hoàn lại.  các
put không cần khóa vì không có gì cố lấy dữ liệu mà không có
đã giữ một con trỏ.

Trong ví dụ trên, kref_put() sẽ được gọi 2 lần trong cả hai lần thành công
và đường dẫn lỗi. Điều này là cần thiết vì số lượng tham chiếu có
tăng gấp 2 lần bởi kref_init() và kref_get().

Lưu ý rằng "trước" trong quy tắc 1 rất quan trọng.  Bạn không bao giờ nên
làm điều gì đó như::

task = kthread_run(more_data_handling, data, "more_data_handling");
	nếu (tác vụ == ERR_PTR(-ENOMEM)) {
		rv = -ENOMEM;
		đi ra ngoài;
	} khác
		/* BAD BAD BAD - nhận được sau khi chuyển giao */
		kref_get(&data->refcount);

Đừng cho rằng bạn biết bạn đang làm gì và sử dụng cấu trúc trên.
Trước hết, bạn có thể không biết mình đang làm gì.  Thứ hai, bạn có thể
biết bạn đang làm gì (có một số trường hợp khóa
liên quan nếu những điều trên có thể hợp pháp) nhưng một người khác thì không
biết họ đang làm gì có thể thay đổi mã hoặc sao chép mã.  Đó là
phong cách xấu.  Đừng làm điều đó.

Có một số tình huống mà bạn có thể tối ưu hóa việc nhận và đặt.
Ví dụ, nếu bạn đã hoàn thành xong một đối tượng và xếp nó vào hàng đợi
cái gì khác hoặc chuyển nó sang cái gì khác, không có lý do
để thực hiện nhận rồi đặt::

/* Nhận và đặt thêm một cách ngớ ngẩn */
	kref_get(&obj->ref);
	xếp hàng(obj);
	kref_put(&obj->ref, obj_cleanup);

Chỉ cần làm enqueue.  Một bình luận về điều này luôn được chào đón::

xếp hàng(obj);
	/* Chúng ta đã hoàn tất obj, vì vậy chúng ta bỏ qua việc tính lại số tiền của mình
	   đến hàng đợi.  DON'T TOUCH đối với AFTER HERE! */

Quy tắc cuối cùng (quy tắc 3) là quy tắc khó xử lý nhất.  Nói, đối với
Ví dụ, bạn có một danh sách các mục thuộc từng loại kref-ed và bạn muốn
để có được cái đầu tiên.  Bạn không thể chỉ cần kéo mục đầu tiên ra khỏi danh sách
và kref_get() nó.  Điều đó vi phạm quy tắc 3 vì bạn chưa
giữ một con trỏ hợp lệ.  Bạn phải thêm một mutex (hoặc một số khóa khác).
Ví dụ::

DEFINE_MUTEX tĩnh (mutex);
	tĩnh LIST_HEAD(q);
	cấu trúc my_data
	{
		struct kref đếm lại;
		liên kết struct list_head;
	};

cấu trúc tĩnh my_data *get_entry()
	{
		struct my_data *entry = NULL;
		mutex_lock(&mutex);
		if (!list_empty(&q)) {
			entry = container_of(q.next, struct my_data, link);
			kref_get(&entry->refcount);
		}
		mutex_unlock(&mutex);
		trả lại mục nhập;
	}

static void Release_entry(struct kref *ref)
	{
		struct my_data *entry = container_of(ref, struct my_data, refcount);

list_del(&entry->link);
		kfree(mục nhập);
	}

static void put_entry(struct my_data *entry)
	{
		mutex_lock(&mutex);
		kref_put(&entry->refcount, Release_entry);
		mutex_unlock(&mutex);
	}

Giá trị trả về kref_put() rất hữu ích nếu bạn không muốn giữ
khóa trong toàn bộ hoạt động phát hành.  Nói rằng bạn không muốn gọi
kfree() với khóa được giữ trong ví dụ trên (vì nó thuộc loại
làm như vậy là vô nghĩa).  Bạn có thể sử dụng kref_put() như sau ::

static void Release_entry(struct kref *ref)
	{
		/* Tất cả công việc được thực hiện sau khi trả về từ kref_put(). */
	}

static void put_entry(struct my_data *entry)
	{
		mutex_lock(&mutex);
		if (kref_put(&entry->refcount, Release_entry)) {
			list_del(&entry->link);
			mutex_unlock(&mutex);
			kfree(mục nhập);
		} khác
			mutex_unlock(&mutex);
	}

Điều này thực sự hữu ích hơn nếu bạn phải gọi các thủ tục khác như một phần
trong số các hoạt động miễn phí có thể mất nhiều thời gian hoặc có thể yêu cầu
cùng một khóa.  Lưu ý rằng việc thực hiện mọi thứ trong quy trình phát hành vẫn
ưa thích vì nó gọn gàng hơn một chút.

Ví dụ trên cũng có thể được tối ưu hóa bằng cách sử dụng kref_get_unless_zero() trong
cách sau::

cấu trúc tĩnh my_data *get_entry()
	{
		struct my_data *entry = NULL;
		mutex_lock(&mutex);
		if (!list_empty(&q)) {
			entry = container_of(q.next, struct my_data, link);
			if (!kref_get_unless_zero(&entry->refcount))
				mục nhập = NULL;
		}
		mutex_unlock(&mutex);
		trả lại mục nhập;
	}

static void Release_entry(struct kref *ref)
	{
		struct my_data *entry = container_of(ref, struct my_data, refcount);

mutex_lock(&mutex);
		list_del(&entry->link);
		mutex_unlock(&mutex);
		kfree(mục nhập);
	}

static void put_entry(struct my_data *entry)
	{
		kref_put(&entry->refcount, Release_entry);
	}

Điều này hữu ích khi loại bỏ khóa mutex xung quanh kref_put() trong put_entry(), nhưng
điều quan trọng là kref_get_unless_zero được đặt trong cùng một phần quan trọng
phần tìm mục nhập trong bảng tra cứu,
nếu không thì kref_get_unless_zero có thể tham chiếu bộ nhớ đã được giải phóng.
Lưu ý rằng việc sử dụng kref_get_unless_zero mà không kiểm tra nó là bất hợp pháp
giá trị trả về. Nếu bạn chắc chắn (bằng cách đã có một con trỏ hợp lệ) rằng
kref_get_unless_zero() sẽ trả về true, sau đó sử dụng kref_get() thay thế.

Krefs và RCU
=============

Hàm kref_get_unless_zero cũng giúp bạn có thể sử dụng rcu
khóa để tra cứu trong ví dụ trên::

cấu trúc my_data
	{
		struct rcu_head rhead;
		.
		struct kref đếm lại;
		.
		.
	};

cấu trúc tĩnh my_data *get_entry_rcu()
	{
		struct my_data *entry = NULL;
		rcu_read_lock();
		if (!list_empty(&q)) {
			entry = container_of(q.next, struct my_data, link);
			if (!kref_get_unless_zero(&entry->refcount))
				mục nhập = NULL;
		}
		rcu_read_unlock();
		trả lại mục nhập;
	}

static void Release_entry_rcu(struct kref *ref)
	{
		struct my_data *entry = container_of(ref, struct my_data, refcount);

mutex_lock(&mutex);
		list_del_rcu(&entry->link);
		mutex_unlock(&mutex);
		kfree_rcu(entry, rhead);
	}

static void put_entry(struct my_data *entry)
	{
		kref_put(&entry->refcount, Release_entry_rcu);
	}

Nhưng lưu ý rằng thành viên struct kref cần duy trì trong bộ nhớ hợp lệ trong một thời gian
thời gian gia hạn rcu sau khi Release_entry_rcu được gọi. Điều đó có thể được thực hiện
bằng cách sử dụng kfree_rcu(entry, rhead) như đã thực hiện ở trên hoặc bằng cách gọi sync_rcu()
trước khi sử dụng kfree, nhưng lưu ý rằng sync_rcu() có thể ngủ trong một thời gian
lượng thời gian đáng kể.

Chức năng và cấu trúc
========================

.. kernel-doc:: include/linux/kref.h
