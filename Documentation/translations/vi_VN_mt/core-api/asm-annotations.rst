.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/asm-annotations.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Chú thích của trình biên dịch mã
=====================

Bản quyền (c) 2017-2019 Jiri Slaby

Tài liệu này mô tả các macro mới để chú thích dữ liệu và mã trong
lắp ráp. Đặc biệt, nó chứa thông tin về ZZ0000ZZ,
ZZ0001ZZ, ZZ0002ZZ và tương tự.

Cơ sở lý luận
---------
Một số mã như mục nhập, tấm bạt lò xo hoặc mã khởi động cần phải được viết bằng
lắp ráp. Giống như trong C, mã như vậy được nhóm thành các hàm và
kèm theo dữ liệu. Trình biên dịch chuẩn không bắt buộc người dùng phải nhập chính xác
đánh dấu những phần này dưới dạng mã, dữ liệu hoặc thậm chí chỉ định độ dài của chúng.
Tuy nhiên, các nhà lắp ráp cung cấp cho các nhà phát triển những chú thích như vậy để hỗ trợ
trình gỡ lỗi trong suốt quá trình lắp ráp. Ngoài ra, các nhà phát triển còn muốn đánh dấu
một số chức năng như ZZ0000ZZ để hiển thị bên ngoài bản dịch của chúng
đơn vị.

Theo thời gian, nhân Linux đã tiếp nhận các macro từ nhiều dự án khác nhau (như
ZZ0000ZZ) để tạo điều kiện thuận lợi cho các chú thích như vậy. Vì vậy, vì lý do lịch sử,
các nhà phát triển đã sử dụng ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ và các loại khác
chú thích trong hội.  Do thiếu tài liệu nên macro
được sử dụng trong bối cảnh khá sai ở một số địa điểm. Rõ ràng, ZZ0004ZZ đã
nhằm biểu thị sự bắt đầu của các ký hiệu chung (có thể là dữ liệu hoặc mã).
ZZ0005ZZ dùng để đánh dấu sự kết thúc của dữ liệu hoặc sự kết thúc của các chức năng đặc biệt bằng
Quy ước gọi ZZ0007ZZ. Ngược lại, ZZ0006ZZ nên chú thích
chỉ kết thúc các chức năng ZZ0008ZZ.

Khi các macro này được sử dụng đúng cách, chúng sẽ giúp người lắp ráp tạo ra một giao diện đẹp mắt.
đối tượng có cả kích thước và loại được đặt chính xác. Ví dụ, kết quả của
ZZ0000ZZ::

Num: Giá trị Kích thước Loại Liên kết Tên Ndx
    25: 0000000000000000 33 FUNC GLOBAL DEFAULT 1 __put_user_1
    29: 0000000000000030 37 FUNC GLOBAL DEFAULT 1 __put_user_2
    32: 0000000000000060 36 FUNC GLOBAL DEFAULT 1 __put_user_4
    35: 0000000000000090 37 FUNC GLOBAL DEFAULT 1 __put_user_8

Điều này không chỉ quan trọng cho mục đích gỡ lỗi. Khi có đúng cách
các đối tượng được chú thích như thế này, các công cụ có thể chạy trên chúng để tạo ra các đối tượng hữu ích hơn
thông tin. Đặc biệt, trên các đối tượng được chú thích chính xác, ZZ0000ZZ có thể
chạy để kiểm tra và sửa chữa đối tượng nếu cần. Hiện tại, ZZ0001ZZ có thể báo cáo
thiếu thiết lập/hủy bỏ con trỏ khung trong hàm. Nó cũng có thể
tự động tạo chú thích cho trình tháo gỡ ORC
(Tài liệu/arch/x86/orc-unwinder.rst)
cho hầu hết các mã. Cả hai điều này đều đặc biệt quan trọng để hỗ trợ
dấu vết ngăn xếp cần thiết cho việc vá lỗi trực tiếp kernel
(Tài liệu/livepatch/livepatch.rst).

Hãy cẩn thận và thảo luận
---------------------
Như người ta có thể nhận ra, trước đây chỉ có ba macro. Đó thực sự là
không đủ để bao gồm tất cả các kết hợp của trường hợp:

* chức năng tiêu chuẩn/không chuẩn
* mã/dữ liệu
* biểu tượng toàn cầu/cục bộ

Đã có một cuộc thảo luận_ và thay vì mở rộng ZZ0000ZZ hiện tại
macro, người ta đã quyết định rằng thay vào đó nên giới thiệu các macro hoàn toàn mới ::

Vậy thay vào đó, hãy sử dụng tên macro thực sự thể hiện được mục đích
    nhập khẩu tất cả những thứ vớ vẩn, mang tính lịch sử, về cơ bản được chọn ngẫu nhiên
    gỡ lỗi tên macro biểu tượng từ binutils và hạt nhân cũ hơn?

.. _discussion: https://lore.kernel.org/r/20170217104757.28588-1-jslaby@suse.cz

Mô tả macro
------------------

Các macro mới có tiền tố ZZ0000ZZ và có thể được chia thành
ba nhóm chính:

1. ZZ0000ZZ -- để chú thích các hàm giống C. Điều này có nghĩa là hoạt động với
   quy ước gọi C tiêu chuẩn. Ví dụ: trên x86, điều này có nghĩa là
   ngăn xếp chứa địa chỉ trả về tại vị trí được xác định trước và trả về từ
   chức năng có thể xảy ra một cách tiêu chuẩn. Khi con trỏ khung được bật,
   việc lưu/khôi phục con trỏ khung sẽ xảy ra ở đầu/cuối hàm,
   tương ứng cũng vậy.

Các công cụ kiểm tra như ZZ0000ZZ phải đảm bảo các chức năng được đánh dấu đó phù hợp
   tới những quy tắc này. Các công cụ này cũng có thể dễ dàng chú thích các chức năng này bằng
   tự động gỡ lỗi thông tin (như ZZ0001ZZ).

2. ZZ0000ZZ -- các chức năng đặc biệt được gọi với ngăn xếp đặc biệt. Hãy là nó
   trình xử lý ngắt với nội dung ngăn xếp đặc biệt, tấm bạt lò xo hoặc khởi động
   chức năng.

Các công cụ kiểm tra hầu như bỏ qua việc kiểm tra các chức năng này. Nhưng một số gỡ lỗi
   thông tin vẫn có thể được tạo ra tự động. Để có dữ liệu gỡ lỗi chính xác,
   mã này cần các gợi ý như ZZ0000ZZ do nhà phát triển cung cấp.

3. ZZ0000ZZ -- rõ ràng là dữ liệu thuộc về các phần ZZ0001ZZ chứ không thuộc về
   ZZ0002ZZ. Dữ liệu không chứa hướng dẫn nên chúng phải được xử lý
   đặc biệt bằng các công cụ: chúng không nên coi byte là hướng dẫn,
   cũng như không chỉ định bất kỳ thông tin gỡ lỗi nào cho họ.

Macro hướng dẫn
~~~~~~~~~~~~~~~~~~
Phần này bao gồm ZZ0000ZZ và ZZ0001ZZ được liệt kê ở trên.

ZZ0000ZZ yêu cầu tất cả mã phải được chứa trong ký hiệu ELF. Biểu tượng
tên có tiền tố ZZ0001ZZ không phát ra các mục trong bảng ký hiệu. ZZ0002ZZ
các ký hiệu có tiền tố có thể được sử dụng trong vùng mã, nhưng nên tránh dùng cho
biểu thị một phạm vi mã thông qua chú thích ZZ0003ZZ.

* ZZ0000ZZ và ZZ0001ZZ được cho là **
  dấu hiệu thường xuyên nhất**. Chúng được sử dụng cho các chức năng có cách gọi tiêu chuẩn
  quy ước -- toàn cầu và địa phương. Giống như trong C, cả hai đều căn chỉnh các hàm thành
  kiến trúc byte ZZ0002ZZ cụ thể. Ngoài ra còn có các biến thể ZZ0003ZZ
  đối với những trường hợp đặc biệt mà nhà phát triển không muốn sự liên kết ngầm này.

Các ký hiệu ZZ0000ZZ và ZZ0001ZZ là
  cũng được cung cấp dưới dạng đối tác lắp ráp cho thuộc tính ZZ0002ZZ được biết đến từ
  C.

Tất cả ZZ0001ZZ này được ghép nối với ZZ0000ZZ. Đầu tiên, nó đánh dấu
  chuỗi lệnh như một hàm và tính toán kích thước của nó theo
  tập tin đối tượng được tạo ra. Thứ hai, nó cũng tạo điều kiện thuận lợi cho việc kiểm tra và xử lý các
  các tệp đối tượng vì các công cụ có thể tìm thấy ranh giới chức năng chính xác một cách tầm thường.

Vì vậy, trong hầu hết các trường hợp, các nhà phát triển nên viết một cái gì đó như sau
  ví dụ, tất nhiên có một số hướng dẫn asm ở giữa các macro ::

SYM_FUNC_START(bộ nhớ)
        ... asm insns ...
SYM_FUNC_END(bộ nhớ)

Trên thực tế, loại chú thích này tương ứng với ZZ0000ZZ hiện không được dùng nữa
  và macro ZZ0001ZZ.

* ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ có thể
  được sử dụng để xác định nhiều tên cho một hàm. Việc sử dụng điển hình là::

SYM_FUNC_START(__ bộ nhớ)
        ... asm insns ...
SYN_FUNC_END(__ bộ nhớ)
    SYM_FUNC_ALIAS(bộ nhớ, __bộ nhớ)

Trong ví dụ này, người ta có thể gọi ZZ0000ZZ hoặc ZZ0001ZZ với cùng một
  kết quả, ngoại trừ thông tin gỡ lỗi cho các hướng dẫn được tạo ra để
  tệp đối tượng chỉ một lần -- đối với trường hợp không phải ZZ0002ZZ.

* ZZ0000ZZ và ZZ0001ZZ chỉ nên được sử dụng trong
  trường hợp đặc biệt -- nếu bạn biết bạn đang làm gì. Điều này được sử dụng riêng
  đối với các trình xử lý ngắt và tương tự trong đó quy ước gọi không phải là C
  một. Các biến thể ZZ0002ZZ cũng tồn tại. Cách sử dụng tương tự như đối với ZZ0003ZZ
  loại trên::

SYM_CODE_START_LOCAL(bad_put_user)
        ... asm insns ...
SYM_CODE_END(bad_put_user)

Một lần nữa, mọi ZZ0000ZZ ZZ0002ZZ đều được ghép nối bởi ZZ0001ZZ.

Ở một mức độ nào đó, danh mục này tương ứng với ZZ0000ZZ không được dùng nữa và
  ZZ0001ZZ. Ngoại trừ ZZ0002ZZ còn có một số ý nghĩa khác.

* ZZ0000ZZ được dùng để biểu thị nhãn bên trong một số
  ZZ0001ZZ và ZZ0002ZZ.  Họ rất giống nhau
  sang nhãn C, ngoại trừ chúng có thể được tạo thành toàn cầu. Một ví dụ về sử dụng::

SYM_CODE_START(ftrace_caller)
        /* save_mcount_regs điền vào hai tham số đầu tiên */
        ...

SYM_INNER_LABEL(ftrace_caller_op_ptr, SYM_L_GLOBAL)
        /* Tải ftrace_ops vào tham số thứ 3 */
        ...

SYM_INNER_LABEL(ftrace_call, SYM_L_GLOBAL)
        gọi ftrace_stub
        ...
retq
    SYM_CODE_END(ftrace_caller)

Macro dữ liệu
~~~~~~~~~~~
Tương tự như hướng dẫn, có một số macro để mô tả dữ liệu trong
lắp ráp.

* ZZ0000ZZ và ZZ0001ZZ đánh dấu sự bắt đầu của một số dữ liệu
  và sẽ được sử dụng cùng với ZZ0002ZZ hoặc
  ZZ0003ZZ. Cái sau cũng thêm một nhãn vào cuối, để
  mọi người có thể sử dụng ZZ0004ZZ và ZZ0005ZZ (cục bộ) sau đây
  ví dụ::

SYM_DATA_START_LOCAL(lstack)
        .skip 4096
    SYM_DATA_END_LABEL(lstack, SYM_L_LOCAL, lstack_end)

* ZZ0000ZZ và ZZ0001ZZ là các biến thể dành cho đơn giản, chủ yếu là một dòng
  dữ liệu::

SYM_DATA(HEAP, .long rm_heap)
    SYM_DATA(heap_end, .long rm_stack)

Cuối cùng, họ mở rộng sang ZZ0000ZZ với ZZ0001ZZ
  nội bộ.

Hỗ trợ macro
~~~~~~~~~~~~~~
Tất cả những điều trên đều rút gọn thành một số lệnh gọi ZZ0000ZZ,
ZZ0001ZZ hoặc cuối cùng là ZZ0002ZZ. Thông thường, các nhà phát triển nên tránh sử dụng
những cái này.

Hơn nữa, trong các ví dụ trên, người ta có thể thấy ZZ0000ZZ. Ngoài ra còn có
ZZ0001ZZ và ZZ0002ZZ. Tất cả đều nhằm mục đích biểu thị sự liên kết của một
biểu tượng được đánh dấu bởi họ. Chúng được sử dụng trong các biến thể ZZ0003ZZ của
các macro trước đó hoặc trong ZZ0004ZZ.


Ghi đè macro
~~~~~~~~~~~~~~~~~
Kiến trúc cũng có thể ghi đè bất kỳ macro nào trong chính chúng
ZZ0000ZZ, bao gồm các macro chỉ định loại ký hiệu
(ZZ0001ZZ, ZZ0002ZZ và ZZ0003ZZ).  Như mọi macro
được mô tả trong tệp này được bao quanh bởi ZZ0004ZZ + ZZ0005ZZ, thế là đủ
để xác định các macro khác nhau trong kiến trúc phụ thuộc đã nói ở trên
tiêu đề.
