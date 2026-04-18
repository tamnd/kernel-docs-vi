.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/dev-tools/kmsan.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright (C) 2022, Google LLC.

====================================
Bộ khử trùng bộ nhớ hạt nhân (KMSAN)
====================================

KMSAN là một trình phát hiện lỗi động nhằm mục đích tìm kiếm các cách sử dụng chưa được khởi tạo
các giá trị. Nó dựa trên công cụ biên dịch và khá giống với
không gian người dùng ZZ0000ZZ.

Một lưu ý quan trọng là KMSAN không dành cho mục đích sử dụng sản xuất vì nó
tăng đáng kể dung lượng bộ nhớ kernel và làm chậm toàn bộ hệ thống.

Cách sử dụng
============

Xây dựng hạt nhân
-------------------

Để xây dựng kernel bằng KMSAN, bạn sẽ cần Clang mới (14.0.6+).
Vui lòng tham khảo ZZ0000ZZ để biết hướng dẫn cách xây dựng Clang.

Bây giờ hãy cấu hình và xây dựng kernel với CONFIG_KMSAN được kích hoạt.

Báo cáo mẫu
--------------

Dưới đây là ví dụ về báo cáo KMSAN::

==========================================================
  BUG: KMSAN: giá trị uninit trong test_uninit_kmsan_check_memory+0x1be/0x380 [kmsan_test]
   test_uninit_kmsan_check_memory+0x1be/0x380 mm/kmsan/kmsan_test.c:273
   kunit_run_case_internal lib/kunit/test.c:333
   kunit_try_run_case+0x206/0x420 lib/kunit/test.c:374
   kunit_generic_run_threadfn_adapter+0x6d/0xc0 lib/kunit/try-catch.c:28
   kthread+0x721/0x850 kernel/kthread.c:327
   ret_from_fork+0x1f/0x30 ??:?

Uninit được lưu vào bộ nhớ tại:
   do_uninit_local_array+0xfa/0x110 mm/kmsan/kmsan_test.c:260
   test_uninit_kmsan_check_memory+0x1a2/0x380 mm/kmsan/kmsan_test.c:271
   kunit_run_case_internal lib/kunit/test.c:333
   kunit_try_run_case+0x206/0x420 lib/kunit/test.c:374
   kunit_generic_run_threadfn_adapter+0x6d/0xc0 lib/kunit/try-catch.c:28
   kthread+0x721/0x850 kernel/kthread.c:327
   ret_from_fork+0x1f/0x30 ??:?

Biến cục bộ uninit được tạo tại:
   do_uninit_local_array+0x4a/0x110 mm/kmsan/kmsan_test.c:256
   test_uninit_kmsan_check_memory+0x1a2/0x380 mm/kmsan/kmsan_test.c:271

Byte 4-7 của 8 chưa được khởi tạo
  Truy cập bộ nhớ có kích thước 8 bắt đầu từ ffff888083fe3da0

CPU: 0 PID: 6731 Giao tiếp: kunit_try_catch Bị nhiễm độc: G B E 5.16.0-rc3+ #104
  Tên phần cứng: QEMU PC tiêu chuẩn (i440FX + PIIX, 1996), BIOS 1.14.0-2 04/01/2014
  ==========================================================

Báo cáo nói rằng biến cục bộ ZZ0000ZZ đã được tạo chưa được khởi tạo trong
ZZ0001ZZ. Dấu vết ngăn xếp thứ ba tương ứng với vị trí
nơi biến này được tạo ra.

Dấu vết ngăn xếp đầu tiên cho thấy giá trị uninit được sử dụng ở đâu (trong
ZZ0000ZZ). Công cụ hiển thị các byte còn lại
chưa được khởi tạo trong biến cục bộ, cũng như ngăn xếp có giá trị
sao chép sang vị trí bộ nhớ khác trước khi sử dụng.

Việc sử dụng giá trị chưa được khởi tạo ZZ0000ZZ được KMSAN báo cáo trong các trường hợp sau:

- trong một điều kiện, ví dụ. ZZ0000ZZ;
 - trong một chỉ mục hoặc hội thảo con trỏ, ví dụ: ZZ0001ZZ hoặc ZZ0002ZZ;
 - khi nó được sao chép vào không gian người dùng hoặc phần cứng, ví dụ: ZZ0003ZZ;
 - khi nó được truyền dưới dạng đối số cho hàm và
   ZZ0004ZZ được bật (xem bên dưới).

Các trường hợp được đề cập (ngoài việc sao chép dữ liệu vào không gian người dùng hoặc phần cứng, đó là
một vấn đề bảo mật) được coi là hành vi không xác định từ điểm Tiêu chuẩn C11
của quan điểm.

Vô hiệu hóa thiết bị
-----------------------------

Một chức năng có thể được đánh dấu bằng ZZ0000ZZ. Làm như vậy sẽ tạo ra KMSAN
bỏ qua các giá trị chưa được khởi tạo trong hàm đó và đánh dấu đầu ra của nó là được khởi tạo.
Kết quả là người dùng sẽ không nhận được các báo cáo KMSAN liên quan đến chức năng đó.

Một thuộc tính chức năng khác được KMSAN hỗ trợ là ZZ0000ZZ.
Áp dụng thuộc tính này cho một hàm sẽ dẫn đến KMSAN không đo lường được
nó, điều này có thể hữu ích nếu chúng ta không muốn trình biên dịch can thiệp vào một số
mã cấp thấp (ví dụ: mã được đánh dấu bằng ZZ0001ZZ ngầm thêm
ZZ0002ZZ).

Tuy nhiên, điều này phải trả giá: việc phân bổ ngăn xếp từ các hàm như vậy sẽ có
giá trị bóng/gốc không chính xác, có thể dẫn đến kết quả dương tính giả. Chức năng
được gọi từ mã không có công cụ cũng có thể nhận được siêu dữ liệu không chính xác cho
các thông số.

Theo nguyên tắc chung, tránh sử dụng ZZ0000ZZ một cách rõ ràng.

Cũng có thể tắt KMSAN cho một tệp duy nhất (ví dụ: main.o)::

KMSAN_SANITIZE_main.o := n

hoặc cho toàn bộ thư mục::

KMSAN_SANITIZE := n

trong Makefile. Hãy coi điều này như việc áp dụng ZZ0000ZZ cho mọi
chức năng trong tập tin hoặc thư mục. Hầu hết người dùng sẽ không cần KMSAN_SANITIZE, trừ khi
mã của họ bị KMSAN phá vỡ (ví dụ: chạy vào thời điểm khởi động sớm).

Việc kiểm tra KMSAN cũng có thể bị vô hiệu hóa tạm thời đối với tác vụ hiện tại bằng cách sử dụng
Cuộc gọi ZZ0000ZZ và ZZ0001ZZ. Mỗi
Cuộc gọi ZZ0002ZZ phải được bắt đầu bằng một
Cuộc gọi ZZ0003ZZ; các cặp cuộc gọi này có thể được lồng nhau. Người ta cần phải
hãy cẩn thận với những cuộc gọi này, giữ cho các vùng ngắn và ưu tiên các cuộc gọi khác
cách để vô hiệu hóa thiết bị đo đạc, nếu có thể.

Ủng hộ
=======

Để KMSAN hoạt động, kernel phải được xây dựng bằng Clang, cho đến nay
trình biên dịch duy nhất có hỗ trợ KMSAN. Pass thiết bị hạt nhân là
dựa trên không gian người dùng ZZ0000ZZ.

Thư viện thời gian chạy hiện chỉ hỗ trợ x86_64.

KMSAN hoạt động như thế nào
===========================

Bộ nhớ bóng KMSAN
-------------------

KMSAN liên kết một byte siêu dữ liệu (còn gọi là byte bóng) với mỗi byte của
bộ nhớ hạt nhân. Một bit trong byte tối được thiết lập nếu bit tương ứng của
byte bộ nhớ hạt nhân chưa được khởi tạo. Đánh dấu bộ nhớ chưa được khởi tạo (tức là
đặt byte bóng của nó thành ZZ0000ZZ) được gọi là ngộ độc, đánh dấu nó
được khởi tạo (đặt byte bóng thành ZZ0001ZZ) được gọi là không nhiễm độc.

Khi một biến mới được cấp phát vào ngăn xếp, theo mặc định nó sẽ bị nhiễm độc bởi
mã công cụ được trình biên dịch chèn vào (trừ khi nó là biến ngăn xếp
được khởi tạo ngay lập tức). Bất kỳ sự phân bổ vùng nhớ heap mới nào được thực hiện mà không có
ZZ0000ZZ cũng bị nhiễm độc.

Công cụ biên dịch cũng theo dõi các giá trị bóng khi chúng được sử dụng cùng
mã. Khi cần, mã thiết bị sẽ gọi thư viện thời gian chạy trong
ZZ0000ZZ để duy trì giá trị bóng.

Giá trị bóng của kiểu cơ bản hoặc kiểu ghép là một mảng các byte có cùng kiểu
chiều dài. Khi một giá trị không đổi được ghi vào bộ nhớ, bộ nhớ đó không bị nhiễm độc.
Khi một giá trị được đọc từ bộ nhớ, bộ nhớ bóng của nó cũng được lấy và
được truyền vào tất cả các hoạt động sử dụng giá trị đó. Đối với mỗi hướng dẫn
nhận một hoặc nhiều giá trị, trình biên dịch sẽ tạo mã để tính toán
bóng của kết quả tùy thuộc vào các giá trị đó và bóng của chúng.

Ví dụ::

int a = 0xff;  // tức là 0x000000ff
  int b;
  int c = a | b;

Trong trường hợp này, bóng của ZZ0000ZZ là ZZ0001ZZ, bóng của ZZ0002ZZ là ZZ0003ZZ,
bóng của ZZ0004ZZ là ZZ0005ZZ. Điều này có nghĩa là ba byte trên của
ZZ0006ZZ chưa được khởi tạo, trong khi byte thấp hơn được khởi tạo.

Theo dõi xuất xứ
----------------

Cứ bốn byte bộ nhớ kernel cũng có cái gọi là nguồn gốc được ánh xạ tới chúng.
Điểm gốc này mô tả điểm trong quá trình thực hiện chương trình mà tại đó giá trị chưa được khởi tạo
giá trị đã được tạo ra. Mọi nguồn gốc đều được liên kết với việc phân bổ đầy đủ
ngăn xếp (đối với bộ nhớ được cấp phát heap) hoặc hàm chứa chưa được khởi tạo
biến (đối với người dân địa phương).

Khi một biến chưa được khởi tạo được cấp phát trên ngăn xếp hoặc đống, một nguồn gốc mới
giá trị được tạo và nguồn gốc của biến đó được điền bằng giá trị đó. Khi một
giá trị được đọc từ bộ nhớ, nguồn gốc của nó cũng được đọc và lưu giữ cùng với giá trị
cái bóng. For every instruction that takes one or more values, the origin of the
kết quả là một trong những nguồn gốc tương ứng với bất kỳ đầu vào chưa được khởi tạo nào.
Nếu một giá trị bị nhiễm độc được ghi vào bộ nhớ thì nguồn gốc của nó sẽ được ghi vào
lưu trữ tương ứng là tốt.

Ví dụ 1::

int a = 42;
  int b;
  int c = a + b;

Trong trường hợp này, nguồn gốc của ZZ0000ZZ được tạo khi nhập hàm và được
được lưu trữ vào nguồn gốc của ZZ0001ZZ ngay trước khi kết quả phép cộng được ghi vào
trí nhớ.

Một số biến có thể chia sẻ cùng một địa chỉ gốc nếu chúng được lưu trữ trong
cùng một đoạn bốn byte. Trong trường hợp này, mỗi lần ghi vào một trong hai biến sẽ cập nhật
nguồn gốc của tất cả chúng. Chúng ta phải hy sinh độ chính xác trong trường hợp này, bởi vì
lưu trữ nguồn gốc cho từng bit riêng lẻ (và thậm chí cả byte) sẽ quá tốn kém.

Ví dụ 2::

int kết hợp(ngắn a, ngắn b) {
    công đoàn ret_t {
      int tôi;
      s ngắn [2];
    } ret;
    ret.s[0] = a;
    ret.s[1] = b;
    return ret.i;
  }

Nếu ZZ0000ZZ được khởi tạo còn ZZ0001ZZ thì không, bóng của kết quả sẽ là
0xffff0000 và nguồn gốc của kết quả sẽ là nguồn gốc của ZZ0002ZZ.
ZZ0003ZZ có cùng nguồn gốc nhưng sẽ không bao giờ được sử dụng, bởi vì
biến đó được khởi tạo.

Nếu cả hai đối số hàm đều chưa được khởi tạo thì chỉ có nguồn gốc của đối số thứ hai
đối số được bảo tồn.

Chuỗi gốc
~~~~~~~~~~~~~~~

Để dễ dàng gỡ lỗi, KMSAN tạo nguồn gốc mới cho mọi cửa hàng của một
giá trị chưa được khởi tạo vào bộ nhớ. Nguồn gốc mới tham chiếu cả ngăn xếp tạo của nó
và nguồn gốc trước đó mà giá trị có. Điều này có thể gây tăng trí nhớ
mức tiêu thụ, vì vậy chúng tôi giới hạn độ dài của chuỗi gốc trong thời gian chạy.

Thiết bị đo tiếng kêu API
-------------------------

Thẻ thiết bị Clang chèn lệnh gọi đến các hàm được xác định trong
ZZ0000ZZ vào mã hạt nhân.

Thao tác bóng
~~~~~~~~~~~~~~~~~~~

Đối với mỗi lần truy cập bộ nhớ, trình biên dịch sẽ phát ra lệnh gọi hàm trả về một giá trị
cặp con trỏ tới địa chỉ bóng và địa chỉ gốc của bộ nhớ đã cho::

cấu trúc typedef {
    vô hiệu *shadow, *origin;
  } bóng_origin_ptr_t

Shadow_origin_ptr_t __msan_metadata_ptr_for_load_{1,2,4,8}(void *addr)
  Shadow_origin_ptr_t __msan_metadata_ptr_for_store_{1,2,4,8}(void *addr)
  Shadow_origin_ptr_t __msan_metadata_ptr_for_load_n(void *addr, kích thước uintptr_t)
  Shadow_origin_ptr_t __msan_metadata_ptr_for_store_n(void *addr, kích thước uintptr_t)

Tên hàm phụ thuộc vào kích thước truy cập bộ nhớ.

Trình biên dịch đảm bảo rằng với mỗi giá trị được tải, bóng và gốc của nó
các giá trị được đọc từ bộ nhớ. Khi một giá trị được lưu vào bộ nhớ, bóng của nó và
nguồn gốc cũng được lưu trữ bằng cách sử dụng con trỏ siêu dữ liệu.

Xử lý người dân địa phương
~~~~~~~~~~~~~~~~~~~~~~~~~~

Một hàm đặc biệt được sử dụng để tạo giá trị gốc mới cho biến cục bộ và
đặt điểm gốc của biến đó thành giá trị đó ::

khoảng trống __msan_poison_alloca(void *addr, uintptr_t size, char *descr)

Truy cập vào dữ liệu trên mỗi tác vụ
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Ở đầu mỗi chức năng được thiết bị, KMSAN sẽ chèn lệnh gọi tới
ZZ0000ZZ::

kmsan_context_state *__msan_get_context_state(void)

ZZ0000ZZ được khai báo trong ZZ0001ZZ::

cấu trúc kmsan_context_state {
    char param_tls[KMSAN_PARAM_SIZE];
    char retval_tls[KMSAN_RETVAL_SIZE];
    char va_arg_tls[KMSAN_PARAM_SIZE];
    char va_arg_origin_tls[KMSAN_PARAM_SIZE];
    u64 va_arg_overflow_size_tls;
    char param_origin_tls[KMSAN_PARAM_SIZE];
    depot_stack_handle_t retval_origin_tls;
  };

Cấu trúc này được KMSAN sử dụng để truyền bóng tham số và nguồn gốc giữa
chức năng đo lường (trừ khi các thông số được kiểm tra ngay lập tức bởi
ZZ0000ZZ).

Truyền các giá trị chưa được khởi tạo cho các hàm
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Công cụ MemorySanitizer của Clang có một tùy chọn,
ZZ0000ZZ, thực hiện chức năng kiểm tra trình biên dịch
các tham số được truyền theo giá trị, cũng như các giá trị trả về của hàm.

Tùy chọn này được điều khiển bởi ZZ0000ZZ,
được bật theo mặc định để cho phép KMSAN báo cáo các giá trị chưa được khởi tạo trước đó.
Vui lòng tham khảo ZZ0001ZZ để biết thêm chi tiết.

Do cách thực hiện kiểm tra trong LLVM (chúng chỉ được áp dụng cho
tham số được đánh dấu là ZZ0000ZZ), không phải tất cả các tham số đều được đảm bảo
đã chọn, vì vậy chúng tôi không thể từ bỏ bộ lưu trữ siêu dữ liệu trong ZZ0001ZZ.

Hàm chuỗi
~~~~~~~~~~~~~~~~

Trình biên dịch thay thế các lệnh gọi tới ZZ0000ZZ/ZZ0001ZZ/ZZ0002ZZ bằng
các chức năng sau. Các hàm này cũng được gọi khi cấu trúc dữ liệu được
được khởi tạo hoặc sao chép, đảm bảo các giá trị bóng và gốc được sao chép cùng với
với dữ liệu::

void *__msan_memcpy(void *dst, void *src, uintptr_t n)
  void *__msan_memmove(void *dst, void *src, uintptr_t n)
  void *__msan_memset(void *dst, int c, uintptr_t n)

Báo cáo lỗi
~~~~~~~~~~~~~~~

Đối với mỗi lần sử dụng một giá trị, trình biên dịch sẽ phát ra một lệnh kiểm tra bóng gọi
ZZ0000ZZ trong trường hợp giá trị đó bị nhiễm độc::

void __msan_warning(nguồn gốc u32)

ZZ0000ZZ khiến thời gian chạy KMSAN in báo cáo lỗi.

Thiết bị lắp ráp nội tuyến
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

KMSAN đo lường mọi đầu ra lắp ráp nội tuyến bằng lệnh gọi tới::

void __msan_instrument_asm_store(void *addr, uintptr_t size)

, giải phóng vùng bộ nhớ.

Cách tiếp cận này có thể che giấu một số lỗi nhất định nhưng nó cũng giúp tránh được nhiều sai sót.
dương tính giả trong hoạt động bitwise, nguyên tử, v.v.

Đôi khi các con trỏ được truyền vào tập hợp nội tuyến không trỏ đến bộ nhớ hợp lệ.
Trong những trường hợp như vậy, chúng bị bỏ qua khi chạy.


Thư viện thời gian chạy
-----------------------

Mã nằm ở ZZ0000ZZ.

Trạng thái KMSAN trên mỗi tác vụ
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mỗi task_struct có trạng thái tác vụ KMSAN liên quan chứa KMSAN
bối cảnh (xem ở trên) và bộ đếm mỗi tác vụ không cho phép báo cáo KMSAN ::

cấu trúc kmsan_context {
    ...
độ sâu int không dấu;
    cấu trúc kmsan_context_state cstate;
    ...
  }

cấu trúc task_struct {
    ...
struct kmsan_context kmsan;
    ...
  }

Bối cảnh KMSAN
~~~~~~~~~~~~~~

Khi chạy trong ngữ cảnh tác vụ kernel, KMSAN sử dụng ZZ0000ZZ để
giữ siêu dữ liệu cho các tham số hàm và giá trị trả về.

Nhưng trong trường hợp kernel đang chạy trong bối cảnh ngắt, softirq hoặc NMI,
trong đó ZZ0000ZZ không khả dụng, KMSAN chuyển sang trạng thái ngắt trên mỗi CPU::

DEFINE_PER_CPU(struct kmsan_ctx, kmsan_percpu_ctx);

Phân bổ siêu dữ liệu
~~~~~~~~~~~~~~~~~~~~

Có một số vị trí trong kernel mà siêu dữ liệu được lưu trữ.

1. Mỗi phiên bản ZZ0000ZZ chứa hai con trỏ tới bóng của nó và
trang gốc::

trang cấu trúc {
    ...
trang cấu trúc *shadow, *origin;
    ...
  };

Vào thời điểm khởi động, kernel phân bổ các trang bóng và trang gốc cho mọi trang có sẵn.
trang hạt nhân. Việc này được thực hiện khá muộn, khi không gian địa chỉ kernel đã đầy.
bị phân mảnh, do đó các trang dữ liệu thông thường có thể xen kẽ tùy ý với siêu dữ liệu
trang.

Điều này có nghĩa là nhìn chung đối với hai trang bộ nhớ liền kề, bóng/nguồn gốc của chúng
các trang có thể không liền kề nhau. Do đó, nếu quyền truy cập bộ nhớ vượt qua
ranh giới của một khối bộ nhớ, việc truy cập vào bộ nhớ gốc/bóng có thể có khả năng
làm hỏng các trang khác hoặc đọc các giá trị không chính xác từ chúng.

Trong thực tế, các trang bộ nhớ liền kề được trả về bởi cùng một ZZ0000ZZ
cuộc gọi sẽ có siêu dữ liệu liền kề, trong khi nếu các trang này thuộc về hai
các phân bổ khác nhau, các trang siêu dữ liệu của chúng có thể bị phân mảnh.

Đối với dữ liệu kernel (ZZ0000ZZ, ZZ0001ZZ, v.v.) và vùng bộ nhớ percpu
cũng không có sự đảm bảo nào về tính liên tục của siêu dữ liệu.

Trong trường hợp ZZ0000ZZ chạm vào ranh giới giữa hai
các trang có siêu dữ liệu không liền kề, nó sẽ trả về các con trỏ tới các vùng bóng/gốc giả::

char dummy_load_page[PAGE_SIZE] __attribute__((căn chỉnh(PAGE_SIZE)));
  char dummy_store_page[PAGE_SIZE] __attribute__((căn chỉnh(PAGE_SIZE)));

ZZ0000ZZ được khởi tạo bằng 0, vì vậy các lần đọc từ nó luôn mang lại số 0.
Tất cả các cửa hàng vào ZZ0001ZZ đều bị bỏ qua.

2. Đối với bộ nhớ và mô-đun vmalloc, có sự ánh xạ trực tiếp giữa bộ nhớ
phạm vi, bóng tối và nguồn gốc của nó. KMSAN giảm diện tích vmalloc xuống 3/4, chỉ tạo ra
quý đầu tiên có sẵn cho ZZ0000ZZ. Quý thứ hai của vmalloc
khu vực chứa bộ nhớ bóng cho quý đầu tiên, khu vực thứ ba giữ
nguồn gốc. Một phần nhỏ của quý 4 chứa đựng bóng tối và nguồn gốc của
mô-đun hạt nhân. Vui lòng tham khảo ZZ0001ZZ để biết
biết thêm chi tiết.

Khi một mảng các trang được ánh xạ vào một không gian bộ nhớ ảo liền kề, chúng
các trang bóng và trang gốc được ánh xạ tương tự vào các vùng liền kề.

Tài liệu tham khảo
==================

E. Stepanov, K. Serebryany. ZZ0000ZZ.
Trong Kỷ yếu của CGO 2015.

.. _MemorySanitizer tool: https://clang.llvm.org/docs/MemorySanitizer.html
.. _LLVM documentation: https://llvm.org/docs/GettingStarted.html
.. _LKML discussion: https://lore.kernel.org/all/20220614144853.3693273-1-glider@google.com/