.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/kfuncs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _kfuncs-header-label:

================================
Hàm hạt nhân BPF (kfuncs)
================================

1. Giới thiệu
===============

Hàm hạt nhân BPF hay thường được gọi là kfuncs là các hàm trong Linux
kernel được hiển thị để các chương trình BPF sử dụng. Không giống như những người trợ giúp BPF bình thường,
kfuncs không có giao diện ổn định và có thể thay đổi từ bản phát hành kernel này sang bản phát hành kernel khác.
cái khác. Do đó, các chương trình BPF cần được cập nhật để đáp ứng với những thay đổi trong
hạt nhân. Xem ZZ0000ZZ để biết thêm thông tin.

2. Xác định kfunc
===================

Có hai cách để hiển thị hàm kernel cho các chương trình BPF, hoặc tạo một
chức năng hiện có trong kernel hiển thị hoặc thêm trình bao bọc mới cho BPF. Ở cả hai
trường hợp, phải lưu ý rằng chương trình BPF chỉ có thể gọi hàm đó trong một
bối cảnh hợp lệ. Để thực thi điều này, khả năng hiển thị của kfunc có thể tùy theo loại chương trình.

Nếu bạn không tạo trình bao bọc BPF cho hàm kernel hiện có, hãy bỏ qua phần tiếp theo
tới ZZ0000ZZ.

2.1 Tạo trình bao bọc kfunc
----------------------------

Khi xác định trình bao bọc kfunc, hàm bao bọc phải có liên kết bên ngoài.
Điều này ngăn trình biên dịch tối ưu hóa mã chết, vì trình bao bọc này kfunc
không được gọi ở bất kỳ đâu trong kernel. Không cần thiết phải cung cấp một
nguyên mẫu trong tiêu đề cho trình bao bọc kfunc.

Một ví dụ được đưa ra dưới đây::

/* Vô hiệu hóa các cảnh báo thiếu nguyên mẫu */
        __bpf_kfunc_start_defs();

__bpf_kfunc struct task_struct *bpf_find_get_task_by_vpid(pid_t nr)
        {
                trả về find_get_task_by_vpid(nr);
        }

__bpf_kfunc_end_defs();

Một trình bao bọc kfunc thường cần thiết khi chúng ta cần chú thích các tham số của
kfunc. Nếu không, người ta có thể trực tiếp làm cho kfunc hiển thị với chương trình BPF bằng cách
đăng ký nó với hệ thống con BPF. Xem ZZ0000ZZ.

2.2 thông số kfunc
--------------------

Theo mặc định, tất cả các kfuncs đều yêu cầu đối số đáng tin cậy. Điều này có nghĩa là tất cả
đối số con trỏ phải hợp lệ và tất cả các con trỏ tới đối tượng BTF phải là
được chuyển ở dạng chưa sửa đổi (ở độ lệch bằng 0 và không có
thu được từ việc di chuyển một con trỏ khác, với các ngoại lệ được mô tả bên dưới).

Có hai loại con trỏ tới các đối tượng kernel được coi là "đáng tin cậy":

1. Con trỏ được truyền dưới dạng đối số gọi lại tracepoint hoặc struct_ops.
2. Con trỏ được trả về từ kfunc KF_ACQUIRE.

Con trỏ tới các đối tượng không phải BTF (ví dụ: con trỏ vô hướng) cũng có thể được chuyển tới
kfuncs và có thể có độ lệch khác 0.

Định nghĩa về con trỏ "hợp lệ" có thể thay đổi bất kỳ lúc nào và có
hoàn toàn không đảm bảo độ ổn định của ABI.

Như đã đề cập ở trên, một con trỏ lồng nhau thu được từ việc di chuyển một con trỏ đáng tin cậy là
không còn được tin cậy nữa, ngoại trừ một ngoại lệ. Nếu một kiểu cấu trúc có một trường
được đảm bảo là hợp lệ (đáng tin cậy hoặc rcu, như trong mô tả KF_RCU bên dưới) miễn là
vì con trỏ cha của nó hợp lệ nên các macro sau có thể được sử dụng để biểu thị
gửi cho người xác minh:

* ZZ0000ZZ
* ZZ0001ZZ
* ZZ0002ZZ

Ví dụ,

.. code-block:: c

	BTF_TYPE_SAFE_TRUSTED(struct socket) {
		struct sock *sk;
	};

hoặc

.. code-block:: c

	BTF_TYPE_SAFE_RCU(struct task_struct) {
		const cpumask_t *cpus_ptr;
		struct css_set __rcu *cgroups;
		struct task_struct __rcu *real_parent;
		struct task_struct *group_leader;
	};

Nói cách khác, bạn phải:

1. Bao bọc loại con trỏ hợp lệ trong macro ZZ0000ZZ.

2. Chỉ định loại và tên của trường lồng nhau hợp lệ. Trường này phải khớp
   trường trong định nghĩa kiểu ban đầu một cách chính xác.

Một loại mới được khai báo bởi macro ZZ0000ZZ cũng cần được phát ra để
nó xuất hiện trong BTF. Ví dụ: ZZ0001ZZ
được phát ra trong hàm ZZ0002ZZ như sau:

.. code-block:: c

	BTF_TYPE_EMIT(BTF_TYPE_SAFE_TRUSTED(struct socket));

2.3 Chú thích các tham số kfunc
-------------------------------

Tương tự như người trợ giúp BPF, đôi khi cần có thêm ngữ cảnh
bởi người xác minh để làm cho việc sử dụng các hàm kernel an toàn hơn và hữu ích hơn.
Do đó, chúng ta có thể chú thích một tham số bằng cách thêm vào tên đối số của
kfunc bằng __tag, trong đó thẻ có thể là một trong những chú thích được hỗ trợ.

2.3.1 __sz Chú thích
---------------------

Chú thích này được sử dụng để chỉ ra cặp bộ nhớ và kích thước trong danh sách đối số.
Một ví dụ được đưa ra dưới đây::

__bpf_kfunc void bpf_memzero(void *mem, int mem__sz)
        {
        ...
        }

Ở đây, trình xác minh sẽ coi đối số đầu tiên là PTR_TO_MEM và đối số thứ hai
đối số như kích thước của nó. Theo mặc định, không có chú thích __sz, kích thước của loại
của con trỏ được sử dụng. Không có chú thích __sz, kfunc không thể chấp nhận khoảng trống
con trỏ.

2.3.2 __k Chú thích
--------------------

Chú thích này chỉ được hiểu đối với các đối số vô hướng, trong đó nó chỉ ra rằng
người xác minh phải kiểm tra đối số vô hướng có phải là một hằng số đã biết hay không
không chỉ ra tham số kích thước và giá trị của hằng số có liên quan đến
an toàn của chương trình.

Một ví dụ được đưa ra dưới đây::

__bpf_kfunc void *bpf_obj_new(u32 local_type_id__k, ...)
        {
        ...
        }

Ở đây, bpf_obj_new sử dụng đối số local_type_id để tìm ra kích thước của loại đó
ID trong BTF của chương trình và trả về một con trỏ có kích thước cho nó. Mỗi loại ID sẽ có một
kích thước riêng biệt, do đó điều quan trọng là phải coi mỗi lệnh gọi như vậy là khác biệt khi
các giá trị không khớp trong quá trình kiểm tra việc cắt bớt trạng thái của trình xác minh.

Do đó, bất cứ khi nào một đối số vô hướng không đổi được chấp nhận bởi một kfunc không phải là một
tham số kích thước và giá trị của các hằng số quan trọng đối với sự an toàn của chương trình, __k
nên sử dụng hậu tố.

2.3.3 __uninit Chú thích
-------------------------

Chú thích này được sử dụng để chỉ ra rằng đối số sẽ được coi là
chưa được khởi tạo.

Một ví dụ được đưa ra dưới đây::

__bpf_kfunc int bpf_dynptr_from_skb(..., struct bpf_dynptr_kern *ptr__uninit)
        {
        ...
        }

Ở đây, dynptr sẽ được coi là dynptr chưa được khởi tạo. Không có cái này
chú thích, trình xác minh sẽ từ chối chương trình nếu dynptr được chuyển vào là
không được khởi tạo.

2.3.4 __Chú thích có thể vô hiệu
--------------------------------

Chú thích này được sử dụng để chỉ ra rằng đối số con trỏ có thể là NULL.
Trình xác minh sẽ cho phép chuyển NULL cho các đối số như vậy.

Một ví dụ được đưa ra dưới đây::

__bpf_kfunc void bpf_task_release(struct task_struct *task__nullable)
        {
        ...
        }

Ở đây, con trỏ tác vụ có thể là NULL. Kfunc chịu trách nhiệm kiểm tra xem
con trỏ là NULL trước khi hủy tham chiếu nó.

Chú thích __nullable có thể được kết hợp với các chú thích khác. Ví dụ,
khi được sử dụng với các chú thích __sz hoặc __szk cho các cặp bộ nhớ và kích thước,
trình xác minh sẽ bỏ qua xác thực kích thước khi con trỏ NULL được chuyển qua, nhưng sẽ
vẫn xử lý đối số kích thước để trích xuất thông tin kích thước không đổi khi
cần thiết::

__bpf_kfunc void *bpf_dynptr_slice(..., void *buffer__nullable,
                                           bộ đệm u32__szk)

Ở đây, bộ đệm có thể là NULL. Nếu bộ đệm không phải là NULL thì ít nhất nó phải là
kích thước buffer__szk byte. Kfunc chịu trách nhiệm kiểm tra xem bộ đệm có
là NULL trước khi sử dụng.

2.3.5 __str Chú thích
----------------------------
Chú thích này được sử dụng để chỉ ra rằng đối số là một chuỗi không đổi.

Một ví dụ được đưa ra dưới đây::

__bpf_kfunc bpf_get_file_xattr(..., const char *name__str, ...)
        {
        ...
        }

Trong trường hợp này, ZZ0000ZZ có thể được gọi là::

bpf_get_file_xattr(..., "xattr_name", ...);

Hoặc::

const char name[] = "xattr_name";  /* Điều này cần phải mang tính toàn cục */
        int BPF_PROG(...)
        {
                ...
bpf_get_file_xattr(...,tên,...);
                ...
        }

.. _BPF_kfunc_nodef:

2.4 Sử dụng hàm kernel hiện có
-------------------------------------

Khi một chức năng hiện có trong kernel phù hợp để các chương trình BPF sử dụng,
nó có thể được đăng ký trực tiếp với hệ thống con BPF. Tuy nhiên vẫn phải quan tâm
được đưa ra để xem xét bối cảnh trong đó nó sẽ được chương trình BPF gọi ra
và liệu làm như vậy có an toàn không.

2.5 Chú thích kfuncs
---------------------

Ngoài các đối số của kfuncs, người xác minh có thể cần thêm thông tin về
loại kfunc đang được đăng ký với hệ thống con BPF. Để làm như vậy, chúng tôi xác định
cờ trên một tập hợp kfuncs như sau::

BTF_KFUNCS_START(bpf_task_set)
        BTF_ID_FLAGS(func, bpf_get_task_pid, KF_ACQUIRE | KF_RET_NULL)
        BTF_ID_FLAGS(func, bpf_put_pid, KF_RELEASE)
        BTF_KFUNCS_END(bpf_task_set)

Bộ này mã hóa ID BTF của từng kfunc được liệt kê ở trên và mã hóa các cờ
cùng với nó. Tất nhiên, nó cũng được phép chỉ định không có cờ.

Các định nghĩa kfunc cũng phải luôn được chú thích bằng ZZ0000ZZ
vĩ mô. Điều này ngăn chặn các vấn đề như trình biên dịch nội tuyến kfunc nếu đó là
hàm hạt nhân tĩnh hoặc hàm được tách biệt trong bản dựng LTO vì nó
không được sử dụng trong phần còn lại của kernel. Nhà phát triển không nên thêm thủ công
chú thích vào kfunc của họ để ngăn chặn những vấn đề này. Nếu một chú thích là
cần thiết để ngăn chặn sự cố như vậy với kfunc của bạn, đó là một lỗi và cần được khắc phục
được thêm vào định nghĩa của macro để các kfunc khác cũng tương tự
được bảo vệ. Một ví dụ được đưa ra dưới đây::

__bpf_kfunc cấu trúc task_struct *bpf_get_task_pid(s32 pid)
        {
        ...
        }

2.5.1 Cờ KF_ACQUIRE
---------------------

Cờ KF_ACQUIRE được sử dụng để chỉ ra rằng kfunc trả về một con trỏ tới một
đối tượng được tính lại. Trình xác minh sau đó sẽ đảm bảo rằng con trỏ tới đối tượng
cuối cùng được phát hành bằng cách sử dụng kfunc phát hành hoặc được chuyển sang bản đồ bằng cách sử dụng
kptr được tham chiếu (bằng cách gọi bpf_kptr_xchg). Nếu không, trình xác minh sẽ không thực hiện được
tải chương trình BPF cho đến khi không còn tài liệu tham khảo nào còn sót lại
khám phá các trạng thái của chương trình.

2.5.2 Cờ KF_RET_NULL
----------------------

Cờ KF_RET_NULL được sử dụng để chỉ ra rằng con trỏ được trả về bởi kfunc
có thể là NULL. Do đó, nó buộc người dùng thực hiện kiểm tra NULL trên con trỏ
được trả về từ kfunc trước khi sử dụng nó (hội thảo hoặc chuyển tới
người trợ giúp khác). Cờ này thường được sử dụng để ghép nối với cờ KF_ACQUIRE, nhưng
cả hai đều trực giao với nhau.

2.5.3 Cờ KF_RELEASE
---------------------

Cờ KF_RELEASE được sử dụng để chỉ ra rằng kfunc giải phóng con trỏ
truyền vào nó. Chỉ có thể có một con trỏ tham chiếu có thể được truyền
in. Tất cả các bản sao của con trỏ được giải phóng đều bị vô hiệu do
gọi kfunc bằng cờ này.

Cờ 2.5.4 KF_SLEEPABLE
-----------------------

Cờ KF_SLEEPABLE được sử dụng cho kfunc có thể ngủ. Những kfunc như vậy chỉ có thể
được gọi bởi các chương trình BPF có thể ngủ được (BPF_F_SLEEPABLE).

Cờ 2.5.5 KF_DESTRUCTIVE
--------------------------

Cờ KF_DESTRUCTIVE được sử dụng để biểu thị các hàm đang gọi
phá hoại hệ thống. Ví dụ, một cuộc gọi như vậy có thể dẫn đến hệ thống
khởi động lại hoặc hoảng loạn. Do hạn chế bổ sung này áp dụng cho những
cuộc gọi. Hiện tại, họ chỉ yêu cầu khả năng CAP_SYS_BOOT, nhưng có thể nhiều hơn nữa
được thêm vào sau.

2.5.6 Cờ KF_RCU
-----------------

Cờ KF_RCU cho phép kfuncs chọn không tham gia các đối số đáng tin cậy mặc định
yêu cầu và chấp nhận con trỏ RCU với độ đảm bảo yếu hơn. Các kfuncs được đánh dấu
với KF_RCU mong đợi các đối số PTR_TRUSTED hoặc MEM_RCU. Người xác minh
đảm bảo rằng các đối tượng là hợp lệ và không có lần sử dụng miễn phí nào. các
con trỏ không phải là NULL, nhưng số lần đếm của đối tượng có thể đạt tới 0. các
kfuncs cần cân nhắc việc thực hiện kiểm tra refcnt != 0, đặc biệt khi trả về một
Con trỏ KF_ACQUIRE. Cũng lưu ý rằng kfunc KF_ACQUIRE là KF_RCU sẽ
rất có thể cũng là KF_RET_NULL.

Cờ 2.5.7 KF_RCU_PROTECTED
---------------------------

Cờ KF_RCU_PROTECTED được sử dụng để chỉ ra rằng kfunc phải được gọi trong
một phần quan trọng RCU. Điều này được giả định theo mặc định trong các chương trình không thể ngủ được,
và phải được đảm bảo rõ ràng bằng cách gọi ZZ0000ZZ để có thể ngủ được
những cái đó.

Nếu kfunc trả về một giá trị con trỏ, cờ này cũng bắt buộc rằng giá trị được trả về
con trỏ được bảo vệ RCU và chỉ có thể được sử dụng khi phần quan trọng RCU được bảo vệ
hoạt động.

Cờ này khác với cờ ZZ0000ZZ, cờ này chỉ đảm bảo rằng nó
đối số ít nhất là con trỏ được bảo vệ RCU. Điều này có thể tạm thời ngụ ý rằng
Bảo vệ RCU được đảm bảo, nhưng nó không hoạt động trong trường hợp kfuncs yêu cầu
Bảo vệ RCU nhưng không lấy các đối số được bảo vệ RCU.

.. _KF_deprecated_flag:

Cờ 2.5.8 KF_DEPRECATED
------------------------

Cờ KF_DEPRECATED được sử dụng cho kfuncs được lên lịch
đã thay đổi hoặc loại bỏ trong bản phát hành kernel tiếp theo. Đó là một kfunc
được đánh dấu bằng KF_DEPRECATED cũng phải có bất kỳ thông tin liên quan nào
được ghi lại trong tài liệu kernel của nó. Những thông tin như vậy thường bao gồm
tuổi thọ còn lại dự kiến của kfunc, một khuyến nghị cho
chức năng có thể thay thế nó nếu có sẵn và có thể là một
lý do tại sao nó bị loại bỏ.

Lưu ý rằng trong một số trường hợp, kfunc KF_DEPRECATED có thể tiếp tục
được hỗ trợ và loại bỏ cờ KF_DEPRECATED của nó, nó có thể còn hơn thế nữa
khó xóa cờ KF_DEPRECATED sau khi nó được thêm vào
ngăn chặn nó được thêm vào ngay từ đầu. Như được mô tả trong
ZZ0000ZZ, người dùng dựa vào kfuncs cụ thể là
được khuyến khích làm cho các trường hợp sử dụng của họ được biết đến càng sớm càng tốt và tham gia
trong các cuộc thảo luận phía trên về việc nên giữ, thay đổi, loại bỏ hay loại bỏ
những kfuncs đó nếu và khi những cuộc thảo luận như vậy diễn ra.

Cờ 2.5.9 KF_IMPLICIT_ARGS
------------------------------------

Cờ KF_IMPLICIT_ARGS được sử dụng để chỉ ra rằng chữ ký BPF
của kfunc khác với chữ ký kernel của nó và các giá trị
đối với các đối số ngầm định được cung cấp tại thời điểm tải bởi trình xác minh.

Chỉ các đối số của các loại cụ thể là ngầm định.
Hiện tại chỉ hỗ trợ loại ZZ0000ZZ.

Do đó, một kfunc có cờ KF_IMPLICIT_ARGS có hai loại trong BTF: một
hàm khớp với khai báo kernel (với hậu tố _impl trong
tên theo quy ước) và một tên khác phù hợp với BPF API dự định.

Trình xác minh chỉ cho phép các cuộc gọi đến phiên bản không phải _impl của kfunc, phiên bản đó
sử dụng chữ ký mà không có đối số ngầm định.

Khai báo ví dụ:

.. code-block:: c

	__bpf_kfunc int bpf_task_work_schedule_signal(struct task_struct *task, struct bpf_task_work *tw,
						      void *map__map, bpf_task_work_callback_t callback,
						      struct bpf_prog_aux *aux) { ... }

Ví dụ sử dụng trong chương trình BPF:

.. code-block:: c

	/* note that the last argument is omitted */
        bpf_task_work_schedule_signal(task, &work->tw, &arrmap, task_work_callback);

2.6 Đăng ký kfuncs
--------------------------

Khi kfunc đã được chuẩn bị để sử dụng, bước cuối cùng để hiển thị nó là
đăng ký nó với hệ thống con BPF. Việc đăng ký được thực hiện theo chương trình BPF
loại. Một ví dụ được hiển thị dưới đây::

BTF_KFUNCS_START(bpf_task_set)
        BTF_ID_FLAGS(func, bpf_get_task_pid, KF_ACQUIRE | KF_RET_NULL)
        BTF_ID_FLAGS(func, bpf_put_pid, KF_RELEASE)
        BTF_KFUNCS_END(bpf_task_set)

cấu trúc const tĩnh btf_kfunc_id_set bpf_task_kfunc_set = {
                .chủ sở hữu = THIS_MODULE,
                .set = &bpf_task_set,
        };

int init_subsystem tĩnh (void)
        {
                trả về register_btf_kfunc_id_set(BPF_PROG_TYPE_TRACING, &bpf_task_kfunc_set);
        }
        Late_initcall(init_subsystem);

2.7 Chỉ định bí danh không truyền bằng ___init
----------------------------------------------

Trình xác minh sẽ luôn thực thi rằng loại con trỏ BTF được truyền tới một
kfunc bằng chương trình BPF, khớp với loại con trỏ được chỉ định trong kfunc
định nghĩa. Tuy nhiên, trình xác minh cho phép các loại tương đương
theo tiêu chuẩn C sẽ được chuyển tới cùng một kfunc arg, ngay cả khi chúng
BTF_ID khác nhau.

Ví dụ: đối với định nghĩa kiểu sau:

.. code-block:: c

	struct bpf_cpumask {
		cpumask_t cpumask;
		refcount_t usage;
	};

Trình xác minh sẽ cho phép ZZ0000ZZ được chuyển tới kfunc
lấy ZZ0001ZZ (là typedef của ZZ0002ZZ). cho
Ví dụ, cả ZZ0003ZZ và ZZ0004ZZ đều có thể được chuyển
tới bpf_cpumask_test_cpu().

Trong một số trường hợp, hành vi bí danh kiểu này là không mong muốn. ZZ0000ZZ là một ví dụ như vậy:

.. code-block:: c

	struct nf_conn___init {
		struct nf_conn ct;
	};

Tiêu chuẩn C sẽ coi các loại này là tương đương, nhưng nó sẽ không
luôn an toàn khi chuyển một trong hai loại cho kfunc đáng tin cậy. ZZ0000ZZ đại diện cho một đối tượng ZZ0001ZZ được phân bổ có
ZZ0005ZZ, do đó sẽ không an toàn khi chuyển ZZ0002ZZ cho một kfunc đang mong đợi một ZZ0003ZZ được khởi tạo đầy đủ (ví dụ: ZZ0004ZZ).

Để đáp ứng các yêu cầu đó, người xác minh sẽ thực thi nghiêm ngặt
Khớp loại PTR_TO_BTF_ID nếu hai loại có cùng tên, với một loại
được gắn với ZZ0000ZZ.

.. _BPF_kfunc_lifecycle_expectations:

3. kỳ vọng về vòng đời của kfunc
================================

kfuncs cung cấp kernel <-> kernel API và do đó không bị ràng buộc bởi bất kỳ
hạn chế nghiêm ngặt về độ ổn định liên quan đến kernel <-> UAPI của người dùng. Điều này có nghĩa
chúng có thể được coi là tương tự như EXPORT_SYMBOL_GPL và do đó có thể
được sửa đổi hoặc loại bỏ bởi người bảo trì hệ thống con mà họ được xác định khi
nó được coi là cần thiết.

Giống như bất kỳ thay đổi nào khác đối với kernel, người bảo trì sẽ không thay đổi hoặc xóa phần
kfunc mà không có lý do chính đáng.  Liệu họ có chọn hay không
để thay đổi kfunc cuối cùng sẽ phụ thuộc vào nhiều yếu tố khác nhau, chẳng hạn như cách
kfunc được sử dụng rộng rãi như thế nào, kfunc đã ở trong kernel bao lâu, liệu có phải là
kfunc thay thế tồn tại, tiêu chuẩn về độ ổn định cho
hệ thống con được đề cập, và tất nhiên chi phí kỹ thuật của việc tiếp tục
để hỗ trợ kfunc.

Có một số ý nghĩa của việc này:

a) kfunc được sử dụng rộng rãi hoặc đã có trong kernel một thời gian dài sẽ
   khó biện minh hơn cho việc bị người bảo trì thay đổi hoặc loại bỏ. trong
   nói cách khác, kfuncs được biết là có nhiều người dùng và cung cấp
   giá trị đáng kể mang lại sự khuyến khích mạnh mẽ hơn cho những người bảo trì đầu tư vào
   thời gian và sự phức tạp trong việc hỗ trợ họ. Do đó, điều quan trọng đối với
   các nhà phát triển đang sử dụng kfuncs trong chương trình BPF của họ để giao tiếp và
   giải thích cách thức và lý do những kfunc đó được sử dụng và tham gia vào
   các cuộc thảo luận liên quan đến những kfunc đó khi chúng xảy ra ở thượng nguồn.

b) Không giống như các ký hiệu kernel thông thường được đánh dấu bằng các chương trình EXPORT_SYMBOL_GPL, BPF
   lệnh gọi kfuncs đó thường không phải là một phần của cây nhân. Điều này có nghĩa là
   việc tái cấu trúc thường không thể thay đổi người gọi tại chỗ khi kfunc thay đổi,
   như được thực hiện cho ví dụ. trình điều khiển ngược dòng đang được cập nhật tại chỗ khi
   biểu tượng hạt nhân được thay đổi.

Không giống như các ký hiệu kernel thông thường, đây là hành vi được mong đợi đối với BPF
   các ký hiệu và các chương trình BPF ngoài cây sử dụng kfuncs nên được xem xét
   liên quan đến các cuộc thảo luận và quyết định xung quanh việc sửa đổi và loại bỏ những
   kfuncs. Cộng đồng BPF sẽ đóng vai trò tích cực trong việc tham gia
   các cuộc thảo luận cấp trên khi cần thiết để đảm bảo rằng quan điểm của những vấn đề đó
   người dùng được tính đến.

c) Kfunc sẽ không bao giờ có bất kỳ đảm bảo ổn định cứng nào. API BPF không thể và
   sẽ không bao giờ chặn cứng một thay đổi trong kernel chỉ vì sự ổn định
   lý do. Nói như vậy, kfuncs là các tính năng nhằm giải quyết
   vấn đề và cung cấp giá trị cho người dùng. Quyết định thay đổi hay
   loại bỏ kfunc là một quyết định kỹ thuật đa biến được thực hiện trên một
   theo từng trường hợp cụ thể và được thông báo bằng các điểm dữ liệu như
   đã đề cập ở trên. Dự kiến ​​kfunc sẽ bị xóa hoặc thay đổi bằng
   không có cảnh báo sẽ không xảy ra thường xuyên hoặc diễn ra mà không có âm thanh
   sự biện minh, nhưng đó là một khả năng phải được chấp nhận nếu một người muốn
   sử dụng kfuncs.

3,1 kfunc không được dùng nữa
-----------------------------

Như đã mô tả ở trên, đôi khi người bảo trì có thể thấy rằng kfunc phải được
được thay đổi hoặc loại bỏ ngay lập tức để phù hợp với một số thay đổi trong hệ thống con của họ,
thông thường kfuncs sẽ có thể đáp ứng được thời gian dài hơn và đo lường được nhiều hơn
quá trình khấu hao. Ví dụ: nếu một kfunc mới xuất hiện cung cấp
chức năng vượt trội so với kfunc hiện có, kfunc hiện tại có thể
không được dùng nữa trong một khoảng thời gian để cho phép người dùng di chuyển các chương trình BPF của họ
để sử dụng cái mới. Hoặc, nếu kfunc không có người dùng nào được biết đến, quyết định có thể được đưa ra
để xóa kfunc (mà không cung cấp API thay thế) sau một số
thời gian ngừng sử dụng để cung cấp cho người dùng một cửa sổ thông báo cho kfunc
người bảo trì nếu hóa ra kfunc thực sự đang được sử dụng.

Dự kiến trường hợp phổ biến là kfuncs sẽ trải qua một
thời gian ngừng sử dụng thay vì bị thay đổi hoặc xóa mà không có cảnh báo. Như
được mô tả trong ZZ0000ZZ, khung kfunc cung cấp
Cờ KF_DEPRECATED gửi tới các nhà phát triển kfunc để báo hiệu cho người dùng rằng kfunc đã được
không được dùng nữa. Khi một kfunc đã được đánh dấu bằng KF_DEPRECATED, phần sau đây
quy trình được thực hiện để loại bỏ:

1. Mọi thông tin liên quan đến kfunc không được dùng nữa đều được ghi lại trong kfunc's
   tài liệu hạt nhân. Tài liệu này thường sẽ bao gồm dự kiến của kfunc
   tuổi thọ còn lại, khuyến nghị về chức năng mới có thể thay thế
   việc sử dụng hàm không được dùng nữa (hoặc giải thích tại sao không có chức năng đó
   tồn tại sự thay thế), v.v.

2. Kfunc không được dùng nữa sẽ được giữ trong kernel trong một khoảng thời gian sau đó
   lần đầu tiên được đánh dấu là không dùng nữa. Khoảng thời gian này sẽ được chọn
   tùy từng trường hợp cụ thể và thường sẽ phụ thuộc vào mức độ phổ biến của việc sử dụng
   kfunc là gì, nó đã tồn tại trong kernel bao lâu và việc di chuyển nó khó khăn như thế nào
   đến các lựa chọn thay thế. Khoảng thời gian ngừng sử dụng này là "nỗ lực tốt nhất" và vì
   được mô tả ZZ0000ZZ, hoàn cảnh có thể
   đôi khi ra lệnh rằng kfunc phải được loại bỏ trước khi có ý định đầy đủ
   thời gian khấu hao đã hết.

3. Sau thời gian ngừng sử dụng, kfunc sẽ bị xóa. Tại thời điểm này, BPF
   các chương trình gọi kfunc sẽ bị người xác minh từ chối.

4. Kfunc cốt lõi
================

Hệ thống con BPF cung cấp một số kfunc "cốt lõi" có khả năng
có thể áp dụng cho nhiều trường hợp và chương trình sử dụng khác nhau.
Những kfuncs đó được ghi lại ở đây.

4.1 cấu trúc task_struct * kfuncs
---------------------------------

Có một số kfunc cho phép các đối tượng ZZ0000ZZ
được sử dụng như kptr:

.. kernel-doc:: kernel/bpf/helpers.c
   :identifiers: bpf_task_acquire bpf_task_release

Những kfunc này hữu ích khi bạn muốn lấy hoặc giải phóng một tham chiếu tới một
ZZ0000ZZ đã được thông qua, ví dụ: một tracepoint arg, hoặc một
đối số gọi lại struct_ops. Ví dụ:

.. code-block:: c

	/**
	 * A trivial example tracepoint program that shows how to
	 * acquire and release a struct task_struct * pointer.
	 */
	SEC("tp_btf/task_newtask")
	int BPF_PROG(task_acquire_release_example, struct task_struct *task, u64 clone_flags)
	{
		struct task_struct *acquired;

		acquired = bpf_task_acquire(task);
		if (acquired)
			/*
			 * In a typical program you'd do something like store
			 * the task in a map, and the map will automatically
			 * release it later. Here, we release it manually.
			 */
			bpf_task_release(acquired);
		return 0;
	}


Các tham chiếu thu được trên các đối tượng ZZ0000ZZ được bảo vệ RCU.
Do đó, khi ở vùng đọc RCU, bạn có thể lấy con trỏ tới một tác vụ
được nhúng vào giá trị bản đồ mà không cần phải lấy tham chiếu:

.. code-block:: c

	#define private(name) SEC(".data." #name) __hidden __attribute__((aligned(8)))
	private(TASK) static struct task_struct *global;

	/**
	 * A trivial example showing how to access a task stored
	 * in a map using RCU.
	 */
	SEC("tp_btf/task_newtask")
	int BPF_PROG(task_rcu_read_example, struct task_struct *task, u64 clone_flags)
	{
		struct task_struct *local_copy;

		bpf_rcu_read_lock();
		local_copy = global;
		if (local_copy)
			/*
			 * We could also pass local_copy to kfuncs or helper functions here,
			 * as we're guaranteed that local_copy will be valid until we exit
			 * the RCU read region below.
			 */
			bpf_printk("Global task %s is valid", local_copy->comm);
		else
			bpf_printk("No global task found");
		bpf_rcu_read_unlock();

		/* At this point we can no longer reference local_copy. */

		return 0;
	}

----

Chương trình BPF cũng có thể tra cứu tác vụ từ pid. Điều này có thể hữu ích nếu
người gọi không có con trỏ đáng tin cậy tới đối tượng ZZ0000ZZ
nó có thể thu được một tham chiếu bằng bpf_task_acquire().

.. kernel-doc:: kernel/bpf/helpers.c
   :identifiers: bpf_task_from_pid

Đây là một ví dụ về nó đang được sử dụng:

.. code-block:: c

	SEC("tp_btf/task_newtask")
	int BPF_PROG(task_get_pid_example, struct task_struct *task, u64 clone_flags)
	{
		struct task_struct *lookup;

		lookup = bpf_task_from_pid(task->pid);
		if (!lookup)
			/* A task should always be found, as %task is a tracepoint arg. */
			return -ENOENT;

		if (lookup->pid != task->pid) {
			/* bpf_task_from_pid() looks up the task via its
			 * globally-unique pid from the init_pid_ns. Thus,
			 * the pid of the lookup task should always be the
			 * same as the input task.
			 */
			bpf_task_release(lookup);
			return -EINVAL;
		}

		/* bpf_task_from_pid() returns an acquired reference,
		 * so it must be dropped before returning from the
		 * tracepoint handler.
		 */
		bpf_task_release(lookup);
		return 0;
	}

4.2 struct cgroup * kfuncs
--------------------------

Các đối tượng ZZ0000ZZ cũng có chức năng thu thập và giải phóng:

.. kernel-doc:: kernel/bpf/helpers.c
   :identifiers: bpf_cgroup_acquire bpf_cgroup_release

Những kfunc này được sử dụng theo cách tương tự như bpf_task_acquire() và
bpf_task_release() tương ứng, vì vậy chúng tôi sẽ không cung cấp ví dụ cho chúng.

----

Các kfunc khác có sẵn để tương tác với các đối tượng ZZ0000ZZ là
bpf_cgroup_ancestor() và bpf_cgroup_from_id(), cho phép người gọi truy cập
tổ tiên của một nhóm và tìm một nhóm theo ID của nó. Cả hai
trả lại một cgroup kptr.

.. kernel-doc:: kernel/bpf/helpers.c
   :identifiers: bpf_cgroup_ancestor

.. kernel-doc:: kernel/bpf/helpers.c
   :identifiers: bpf_cgroup_from_id

Cuối cùng, BPF phải được cập nhật để cho phép điều này xảy ra với bộ nhớ bình thường
tải trong chính chương trình. Điều này hiện không thể thực hiện được nếu không có thêm công việc trong
người xác minh. bpf_cgroup_ancestor() có thể được sử dụng như sau:

.. code-block:: c

	/**
	 * Simple tracepoint example that illustrates how a cgroup's
	 * ancestor can be accessed using bpf_cgroup_ancestor().
	 */
	SEC("tp_btf/cgroup_mkdir")
	int BPF_PROG(cgrp_ancestor_example, struct cgroup *cgrp, const char *path)
	{
		struct cgroup *parent;

		/* The parent cgroup resides at the level before the current cgroup's level. */
		parent = bpf_cgroup_ancestor(cgrp, cgrp->level - 1);
		if (!parent)
			return -ENOENT;

		bpf_printk("Parent id is %d", parent->self.id);

		/* Return the parent cgroup that was acquired above. */
		bpf_cgroup_release(parent);
		return 0;
	}

4.3 cấu trúc cpumask * kfuncs
-----------------------------

BPF cung cấp một tập hợp kfunc có thể được sử dụng để truy vấn, phân bổ, thay đổi và
phá hủy các đối tượng struct cpumask *. Vui lòng tham khảo ZZ0000ZZ
để biết thêm chi tiết.