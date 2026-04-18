.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/staging/static-keys.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

============
Phím tĩnh
===========

.. warning::

   DEPRECATED API:

   The use of 'struct static_key' directly, is now DEPRECATED. In addition
   static_key_{true,false}() is also DEPRECATED. IE DO NOT use the following::

	struct static_key false = STATIC_KEY_INIT_FALSE;
	struct static_key true = STATIC_KEY_INIT_TRUE;
	static_key_true()
	static_key_false()

   The updated API replacements are::

	DEFINE_STATIC_KEY_TRUE(key);
	DEFINE_STATIC_KEY_FALSE(key);
	DEFINE_STATIC_KEY_ARRAY_TRUE(keys, count);
	DEFINE_STATIC_KEY_ARRAY_FALSE(keys, count);
	static_branch_likely()
	static_branch_unlikely()

Tóm tắt
========

Khóa tĩnh cho phép bao gồm các tính năng hiếm khi được sử dụng trong
Mã hạt nhân đường dẫn nhanh nhạy cảm với hiệu suất, thông qua tính năng GCC và mã
kỹ thuật vá lỗi. Một ví dụ nhanh::

DEFINE_STATIC_KEY_FALSE(khóa);

	...

        if (static_branch_unlikely(&key))
                do unlikely code
        else
                do likely code

	...
static_branch_enable(&key);
	...
static_branch_disable(&key);
	...

Nhánh static_branch_unlikely() sẽ được tạo thành mã với ít
tác động đến đường dẫn mã có khả năng nhất có thể.


Động lực
==========


Hiện tại, các điểm theo dõi được triển khai bằng cách sử dụng nhánh có điều kiện. các
kiểm tra có điều kiện yêu cầu kiểm tra một biến toàn cục cho mỗi điểm theo dõi.
Mặc dù chi phí của việc kiểm tra này là nhỏ nhưng nó sẽ tăng lên khi bộ nhớ
bộ đệm phải chịu áp lực (các dòng bộ nhớ đệm cho các biến toàn cục này có thể
được chia sẻ với các truy cập bộ nhớ khác). Khi chúng tôi tăng số lượng dấu vết
trong kernel, chi phí này có thể trở thành một vấn đề. Ngoài ra,
các điểm theo dõi thường không hoạt động (bị vô hiệu hóa) và không cung cấp hạt nhân trực tiếp
chức năng. Vì vậy, điều rất mong muốn là giảm tác động của chúng càng nhiều càng tốt.
có thể. Mặc dù các điểm theo dõi là động lực ban đầu cho công việc này, nhưng các điểm khác
đường dẫn mã hạt nhân sẽ có thể sử dụng tiện ích khóa tĩnh.


Giải pháp
========


gcc (v4.5) thêm câu lệnh 'asm goto' mới cho phép phân nhánh thành nhãn:

ZZ0000ZZ

Sử dụng 'asm goto', chúng ta có thể tạo các nhánh được lấy hoặc không được lấy
theo mặc định mà không cần kiểm tra bộ nhớ. Sau đó, vào thời gian chạy, chúng ta có thể vá
trang web chi nhánh để thay đổi hướng chi nhánh.

Ví dụ: nếu chúng ta có một nhánh đơn giản bị tắt theo mặc định ::

if (static_branch_unlikely(&key))
		printk("Tôi là nhánh thật\n");

Do đó, theo mặc định, 'printk' sẽ không được phát ra. Và mã được tạo ra sẽ
bao gồm một lệnh 'no-op' nguyên tử duy nhất (5 byte trên x86), trong
đường dẫn mã thẳng. Khi nhánh bị “lật ngược”, chúng ta sẽ vá lại
'no-op' trong đường dẫn mã đường thẳng với lệnh 'nhảy' tới
nhánh thực sự ngoài dòng. Vì vậy, việc thay đổi hướng nhánh là tốn kém nhưng
lựa chọn chi nhánh về cơ bản là 'miễn phí'. Đó là sự đánh đổi cơ bản của việc này
tối ưu hóa.

Cơ chế vá lỗi ở mức độ thấp này được gọi là 'vá nhãn nhảy' và nó mang lại
cơ sở cho cơ sở khóa tĩnh.

Nhãn khóa tĩnh API, cách sử dụng và ví dụ
========================================


Để sử dụng tối ưu hóa này, trước tiên bạn phải xác định khóa::

DEFINE_STATIC_KEY_TRUE(khóa);

hoặc::

DEFINE_STATIC_KEY_FALSE(khóa);


Khóa phải có tính toàn cục, nghĩa là nó không thể được cấp phát trên ngăn xếp hoặc động
được phân bổ vào thời gian chạy.

Sau đó, khóa này được sử dụng trong mã dưới dạng ::

if (static_branch_unlikely(&key))
                làm mã không chắc chắn
        khác
                có khả năng viết mã

Hoặc::

if (static_branch_likely(&key))
                có khả năng viết mã
        khác
                làm mã không chắc chắn

Các khóa được xác định thông qua DEFINE_STATIC_KEY_TRUE() hoặc DEFINE_STATIC_KEY_FALSE, có thể
được sử dụng trong static_branch_likely() hoặc static_branch_unlikely()
các tuyên bố.

(Các) chi nhánh có thể được đặt thành đúng thông qua ::

static_branch_enable(&key);

hoặc sai thông qua::

static_branch_disable(&key);

(Các) nhánh sau đó có thể được chuyển đổi thông qua số lượng tham chiếu::

static_branch_inc(&key);
	...
static_branch_dec(&key);

Do đó, 'static_branch_inc()' có nghĩa là 'làm cho nhánh trở thành đúng' và
'static_branch_dec()' có nghĩa là 'làm cho nhánh sai' bằng cách thích hợp
tính toán tham khảo Ví dụ: nếu khóa được khởi tạo là true,
static_branch_dec(), sẽ chuyển nhánh thành sai. Và tiếp theo
static_branch_inc(), sẽ thay đổi nhánh thành true. Tương tự như vậy, nếu
khóa được khởi tạo sai, 'static_branch_inc()', sẽ thay đổi nhánh thành
đúng. Và sau đó, 'static_branch_dec()' sẽ lại làm cho nhánh sai.

Trạng thái và số lượng tham chiếu có thể được truy xuất bằng 'static_key_enabled()'
và 'static_key_count()'.  Nói chung, nếu bạn sử dụng các chức năng này, chúng sẽ
phải được bảo vệ bằng cùng một mutex được sử dụng xung quanh việc bật/tắt
hoặc hàm tăng/giảm.

Lưu ý rằng việc chuyển nhánh dẫn đến một số khóa bị lấy đi,
đặc biệt là khóa cắm nóng CPU (để tránh chạy đua với
CPU được đưa vào kernel trong khi kernel đang nhận
đã vá). Gọi khóa tĩnh API từ bên trong trình thông báo cắm nóng là
do đó một công thức bế tắc chắc chắn. Để vẫn có thể cho phép sử dụng
chức năng, các chức năng sau được cung cấp:

static_key_enable_cpuslocked()
	static_key_disable_cpuslocked()
	static_branch_enable_cpuslocked()
	static_branch_disable_cpuslocked()

Các chức năng này là mục đích chung của ZZ0000ZZ và chỉ được sử dụng khi
bạn thực sự biết rằng bạn đang ở trong bối cảnh trên chứ không phải ai khác.

Trong trường hợp cần có một mảng khóa, nó có thể được định nghĩa là::

DEFINE_STATIC_KEY_ARRAY_TRUE(phím, số lượng);

hoặc::

DEFINE_STATIC_KEY_ARRAY_FALSE(phím, số lượng);

4) Giao diện vá mã cấp độ kiến ​​trúc, 'nhảy nhãn'


Có một số chức năng và macro mà kiến trúc phải triển khai để
để tận dụng tối ưu hóa này. Nếu không có sự hỗ trợ về kiến trúc, chúng tôi
chỉ cần quay lại trình tự tải, kiểm tra và nhảy truyền thống. Ngoài ra,
Bảng struct jump_entry phải được căn chỉnh ít nhất 4 byte vì
trường static_key->entry sử dụng hai bit có trọng số thấp nhất.

* ZZ0000ZZ,
    xem: Arch/x86/Kconfig

* ZZ0000ZZ,
    xem: Arch/x86/include/asm/jump_label.h

* ZZ0000ZZ,
    xem: Arch/x86/include/asm/jump_label.h

* ZZ0000ZZ,
    xem: Arch/x86/include/asm/jump_label.h

* ZZ0000ZZ,
    xem: Arch/x86/kernel/jump_label.c

* ZZ0000ZZ,
    xem: Arch/x86/include/asm/jump_label.h


5) Phân tích khóa tĩnh / nhãn nhảy, kết quả (x86_64):


Ví dụ: hãy thêm nhánh sau vào 'getppid()', sao cho
cuộc gọi hệ thống bây giờ trông giống như::

SYSCALL_DEFINE0(getppid)
  {
        int pid;

+ if (static_branch_unlikely(&key))
  + printk("Tôi là nhánh thật\n");

rcu_read_lock();
        pid = task_tgid_vnr(rcu_dereference(current->real_parent));
        rcu_read_unlock();

trả về pid;
  }

Hướng dẫn kết quả với nhãn nhảy được tạo bởi GCC là::

ffffffff81044290 <sys_getppid>:
  ffffffff81044290: 55 lần đẩy %rbp
  ffffffff81044291: 48 89 e5 mov %rsp,%rbp
  ffffffff81044294: e9 00 00 00 00 jmpq ffffffff81044299 <sys_getppid+0x9>
  ffffffff81044299: 65 48 8b 04 25 c0 b6 mov %gs:0xb6c0,%rax
  ffffffff810442a0: 00 00
  ffffffff810442a2: 48 8b 80 80 02 00 00 mov 0x280(%rax),%rax
  ffffffff810442a9: 48 8b 80 b0 02 00 00 mov 0x2b0(%rax),%rax
  ffffffff810442b0: 48 8b b8 e8 02 00 00 mov 0x2e8(%rax),%rdi
  ffffffff810442b7: e8 f4 d9 00 00 callq ffffffff81051cb0 <pid_vnr>
  ffffffff810442bc: 5d pop %rbp
  ffffffff810442bd: 48 98 cltq
  ffffffff810442bf: c3 retq
  ffffffff810442c0: 48 c7 c7 e3 54 98 81 mov $0xffffffff819854e3,%rdi
  ffffffff810442c7: 31 c0 xor %eax,%eax
  ffffffff810442c9: e8 71 13 6d 00 callq ffffffff8171563f <printk>
  ffffffff810442ce: eb c9 jmp ffffffff81044299 <sys_getppid+0x9>

Nếu không tối ưu hóa nhãn nhảy, nó trông giống như ::

ffffffff810441f0 <sys_getppid>:
  ffffffff810441f0: 8b 05 8a 52 d8 00 mov 0xd8528a(%rip),%eax # ffffffff81dc9480 <key>
  ffffffff810441f6: 55 lần đẩy %rbp
  ffffffff810441f7: 48 89 e5 di chuyển %rsp,%rbp
  ffffffff810441fa: kiểm tra 85 c0 %eax,%eax
  ffffffff810441fc: 75 27 jne ffffffff81044225 <sys_getppid+0x35>
  ffffffff810441fe: 65 48 8b 04 25 c0 b6 mov %gs:0xb6c0,%rax
  ffffffff81044205: 00 00
  ffffffff81044207: 48 8b 80 80 02 00 00 mov 0x280(%rax),%rax
  ffffffff8104420e: 48 8b 80 b0 02 00 00 mov 0x2b0(%rax),%rax
  ffffffff81044215: 48 8b b8 e8 02 00 00 mov 0x2e8(%rax),%rdi
  ffffffff8104421c: e8 2f da 00 00 callq ffffffff81051c50 <pid_vnr>
  ffffffff81044221: 5d pop %rbp
  ffffffff81044222: 48 98 cltq
  ffffffff81044224: c3 retq
  ffffffff81044225: 48 c7 c7 13 53 98 81 mov $0xffffffff81985313,%rdi
  ffffffff8104422c: 31 c0 xor %eax,%eax
  ffffffff8104422e: e8 60 0f 6d 00 callq ffffffff81715193 <printk>
  ffffffff81044233: eb c9 jmp ffffffff810441fe <sys_getppid+0xe>
  ffffffff81044235: 66 66 2e 0f 1f 84 00 data32 nopw %cs:0x0(%rax,%rax,1)
  ffffffff8104423c: 00 00 00 00

Do đó, trường hợp nhãn nhảy vô hiệu hóa sẽ thêm lệnh 'mov', 'test' và 'jne'
so với trường hợp nhãn nhảy chỉ có 'no-op' hoặc 'jmp 0'. (Jmp 0, đã được vá
đến lệnh no-op nguyên tử 5 byte khi khởi động.) Do đó, bước nhảy bị vô hiệu hóa
trường hợp nhãn thêm::

6 (mov) + 2 (test) + 2 (jne) = 10 - 5 (5 byte nhảy 0) = 5 byte bổ sung.

Sau đó, nếu chúng tôi bao gồm các byte đệm, mã nhãn nhảy sẽ lưu, tổng cộng là 16 byte
bộ nhớ lệnh cho chức năng nhỏ này. Trong trường hợp này nhãn không nhảy
hàm dài 80 byte. Như vậy, chúng ta đã tiết kiệm được 20% chỉ dẫn
dấu chân. Trên thực tế, chúng tôi có thể cải thiện điều này hơn nữa vì 5 byte no-op
thực sự có thể là no-op 2 byte vì chúng ta có thể đến nhánh với jmp 2 byte.
Tuy nhiên, chúng tôi vẫn chưa triển khai các kích thước no-op tối ưu (hiện tại chúng
mã hóa cứng).

Vì có một số khóa tĩnh API sử dụng trong đường dẫn bộ lập lịch,
'pipe-test' (còn được gọi là 'perf bench sched pipe') có thể được sử dụng để hiển thị
cải thiện hiệu suất. Thử nghiệm được thực hiện trên 3.3.0-rc2:

nhãn nhảy bị vô hiệu hóa::

Thống kê bộ đếm hiệu suất cho 'bash -c /tmp/pipe-test' (50 lần chạy):

855.700314 CPU #    0.534 xung nhịp tác vụ được sử dụng (+ - 0,11%)
           200.003 chuyển mạch ngữ cảnh #    0.234 M/giây (+ - 0,00%)
                 0 CPU-di chuyển #    0.000 M/giây (+ - 39,58% )
               487 lỗi trang #    0.001 M/giây (+ - 0,02%)
     1.474.374.262 chu kỳ #    1.723 GHz (+ - 0,17% )
   <không được hỗ trợ> bị đình trệ-chu kỳ-frontend
   <không được hỗ trợ> bị đình trệ-chu kỳ-phụ trợ
     1.178.049.567 hướng dẫn #    0.80 số lượt mỗi chu kỳ (+ - 0,06%)
       208.368.926 nhánh #  243.507 M/giây (+ - 0,06% )
         5.569.188 lượt bỏ lỡ chi nhánh #    2,67% trên tổng số chi nhánh (+- 0,54% )

Thời gian trôi qua 1,601607384 giây (+- 0,07%)

nhãn nhảy được bật::

Thống kê bộ đếm hiệu suất cho 'bash -c /tmp/pipe-test' (50 lần chạy):

841.043185 CPU #    0.533 xung nhịp tác vụ được sử dụng (+ - 0,12%)
           200.004 chuyển mạch ngữ cảnh #    0.238 M/giây (+ - 0,00%)
                 0 CPU-di chuyển #    0.000 M/giây (+ - 40,87% )
               487 lỗi trang #    0.001 M/giây (+ - 0,05% )
     1.432.559.428 chu kỳ #    1.703 GHz (+ - 0,18% )
   <không được hỗ trợ> bị đình trệ-chu kỳ-frontend
   <không được hỗ trợ> bị đình trệ-chu kỳ-phụ trợ
     1.175.363.994 hướng dẫn #    0.82 số lượt mỗi chu kỳ (+ - 0,04%)
       206.859.359 nhánh #  245.956 M/giây (+ - 0,04% )
         4.884.119 lượt bỏ lỡ chi nhánh #    2,36% trên tổng số chi nhánh (+- 0,85% )

Thời gian trôi qua 1,579384366 giây

Tỷ lệ chi nhánh được lưu là 0,7% và chúng tôi đã tiết kiệm được 12% trên
'bỏ lỡ cành'. Đây là nơi chúng ta mong đợi nhận được nhiều khoản tiết kiệm nhất, vì
tối ưu hóa này là về việc giảm số lượng chi nhánh. Ngoài ra, chúng tôi đã
đã tiết kiệm 0,2% cho các hướng dẫn và 2,8% cho các chu kỳ và 1,4% cho thời gian đã trôi qua.
