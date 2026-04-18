.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/xarray.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======
XArray
======

:Tác giả: Matthew Wilcox

Tổng quan
=========

XArray là một kiểu dữ liệu trừu tượng hoạt động giống như một mảng rất lớn
của con trỏ.  Nó đáp ứng nhiều nhu cầu giống như hàm băm hoặc thông thường
mảng có thể thay đổi kích thước.  Không giống như hàm băm, nó cho phép bạn truy cập một cách hợp lý
mục tiếp theo hoặc trước đó theo cách tiết kiệm bộ nhớ đệm.  Ngược lại với một
mảng có thể thay đổi kích thước, không cần sao chép dữ liệu hoặc thay đổi ánh xạ MMU trong
để phát triển mảng.  Nó tiết kiệm bộ nhớ hơn, có khả năng song song hóa
và thân thiện với bộ nhớ đệm hơn là danh sách liên kết đôi.  Nó lợi dụng
RCU để thực hiện tra cứu mà không cần khóa.

Việc triển khai XArray hiệu quả khi các chỉ mục được sử dụng dày đặc
nhóm lại; băm đối tượng và sử dụng hàm băm làm chỉ mục sẽ không
thực hiện tốt.  XArray được tối ưu hóa cho các chỉ mục nhỏ nhưng vẫn có
hiệu suất tốt với các chỉ số lớn.  Nếu chỉ mục của bạn có thể lớn hơn
ZZ0000ZZ thì XArray không phải là kiểu dữ liệu dành cho bạn.  nhất
người dùng quan trọng của XArray là bộ đệm trang.

Con trỏ thông thường có thể được lưu trữ trực tiếp trong XArray.  Chúng phải có kích thước 4 byte
căn chỉnh, điều này đúng với mọi con trỏ được trả về từ kmalloc() và
cấp phát_page().  Điều đó không đúng với các con trỏ không gian người dùng tùy ý,
cũng như cho con trỏ hàm.  Bạn có thể lưu trữ con trỏ để phân bổ tĩnh
các đối tượng, miễn là các đối tượng đó có căn chỉnh ít nhất là 4.

Bạn cũng có thể lưu trữ các số nguyên từ 0 đến ZZ0000ZZ trong XArray.
Trước tiên, bạn phải chuyển đổi nó thành một mục nhập bằng xa_mk_value().
Khi bạn truy xuất một mục từ XArray, bạn có thể kiểm tra xem nó có
một mục nhập giá trị bằng cách gọi xa_is_value() và chuyển đổi nó trở lại
một số nguyên bằng cách gọi xa_to_value().

Một số người dùng muốn gắn thẻ các con trỏ họ lưu trữ trong XArray.  bạn có thể
gọi xa_tag_pointer() để tạo mục nhập có thẻ, xa_untag_pointer()
để biến mục được gắn thẻ trở lại thành một con trỏ không được gắn thẻ và xa_pointer_tag()
để lấy thẻ của một mục.  Con trỏ được gắn thẻ sử dụng cùng các bit mà
được sử dụng để phân biệt các mục giá trị với các con trỏ thông thường, vì vậy bạn phải
quyết định xem bạn có muốn lưu trữ các mục nhập giá trị hoặc con trỏ được gắn thẻ trong bất kỳ
XArray cụ thể.

XArray không hỗ trợ lưu trữ con trỏ IS_ERR() như một số
xung đột với các mục giá trị hoặc các mục nội bộ.

Một tính năng khác thường của XArray là khả năng tạo các mục
chiếm một loạt các chỉ số.  Sau khi được lưu vào, tra cứu bất kỳ chỉ mục nào trong
phạm vi sẽ trả về cùng một mục như tra cứu bất kỳ chỉ mục nào khác trong
phạm vi.  Lưu trữ vào bất kỳ chỉ mục nào sẽ lưu trữ tất cả chúng.  Đa chỉ mục
các mục có thể được chia rõ ràng thành các mục nhỏ hơn. Bỏ cài đặt (sử dụng
xa_erase() hoặc xa_store() với ZZ0000ZZ), bất kỳ mục nhập nào cũng sẽ gây ra XArray
để quên đi phạm vi.

API bình thường
===============

Bắt đầu bằng cách khởi tạo XArray, với DEFINE_XARRAY()
đối với XArray được phân bổ tĩnh hoặc xa_init() cho động
những cái được phân bổ.  XArray mới được khởi tạo chứa ZZ0000ZZ
con trỏ ở mọi chỉ mục.

Sau đó, bạn có thể đặt các mục bằng cách sử dụng xa_store() và nhận các mục bằng cách sử dụng
xa_load().  xa_store() sẽ ghi đè bất kỳ mục nhập nào bằng mục nhập mới và
trả về mục trước đó được lưu trữ tại chỉ mục đó.  Bạn có thể bỏ đặt các mục
sử dụng xa_erase() hoặc bằng cách đặt mục nhập thành ZZ0000ZZ bằng xa_store().
Không có sự khác biệt giữa một mục chưa bao giờ được lưu trữ vào
và một cái đã bị xóa bằng xa_erase(); một mục có nhiều nhất
gần đây có ZZ0001ZZ được lưu trữ trong đó cũng tương đương trừ khi
XArray được khởi tạo bằng ZZ0002ZZ.

Bạn có thể thay thế một cách có điều kiện một mục nhập tại một chỉ mục bằng cách sử dụng
xa_cmpxchg().  Giống như cmpxchg(), nó chỉ thành công nếu
mục nhập tại chỉ mục đó có giá trị 'cũ'.  Nó cũng trả về mục
đó là chỉ số đó; nếu nó trả về cùng một mục đã được chuyển thành
'cũ', thì xa_cmpxchg() đã thành công.

Nếu bạn chỉ muốn lưu trữ một mục mới vào một chỉ mục nếu mục nhập hiện tại
tại chỉ mục đó là ZZ0000ZZ, bạn có thể sử dụng xa_insert()
trả về ZZ0001ZZ nếu mục nhập không trống.

Bạn có thể sao chép các mục từ XArray vào một mảng đơn giản bằng cách gọi
xa_extract().  Hoặc bạn có thể lặp lại các mục hiện tại trong XArray
bằng cách gọi xa_for_each(), xa_for_each_start() hoặc xa_for_each_range().
Bạn có thể thích sử dụng xa_find() hoặc xa_find_after() để chuyển sang phần tiếp theo
mục hiện tại trong XArray.

Gọi xa_store_range() lưu trữ cùng một mục trong một phạm vi
của các chỉ số.  Nếu bạn làm điều này, một số thao tác khác sẽ hoạt động
theo một cách hơi kỳ lạ.  Ví dụ: đánh dấu mục nhập tại một chỉ mục
có thể dẫn đến mục được đánh dấu ở một số mục, nhưng không phải tất cả các mục khác
chỉ số.  Việc lưu trữ vào một chỉ mục có thể dẫn đến mục nhập được truy xuất bởi
một số, nhưng không phải tất cả các chỉ số khác đều thay đổi.

Đôi khi bạn cần đảm bảo rằng lệnh gọi tiếp theo tới xa_store()
sẽ không cần cấp phát bộ nhớ.  Hàm xa_reserve()
sẽ lưu trữ một mục dành riêng tại chỉ mục được chỉ định.  Người dùng của
API bình thường sẽ thấy mục này có chứa ZZ0000ZZ.  Nếu bạn làm
không cần sử dụng mục dành riêng, bạn có thể gọi xa_release()
để loại bỏ mục không sử dụng.  Nếu người dùng khác đã lưu trữ vào mục
trong khi đó, xa_release() sẽ không làm gì cả; nếu thay vào đó bạn
muốn mục nhập trở thành ZZ0001ZZ, bạn nên sử dụng xa_erase().
Sử dụng xa_insert() trên mục dành riêng sẽ không thành công.

Nếu tất cả các mục trong mảng là ZZ0000ZZ, hàm xa_empty()
sẽ trả về ZZ0001ZZ.

Cuối cùng, bạn có thể xóa tất cả các mục khỏi XArray bằng cách gọi
xa_destroy().  Nếu các mục XArray là con trỏ, bạn có thể muốn
để giải phóng các mục đầu tiên.  Bạn có thể làm điều này bằng cách lặp lại tất cả hiện tại
các mục trong XArray bằng trình lặp xa_for_each().

Tìm kiếm dấu
------------

Mỗi mục trong mảng có ba bit liên kết với nó được gọi là dấu.
Mỗi dấu có thể được đặt hoặc xóa độc lập với các dấu khác.  bạn có thể
lặp lại các mục được đánh dấu bằng cách sử dụng trình vòng lặp xa_for_each_marked().

Bạn có thể hỏi liệu một dấu có được đặt trên một mục hay không bằng cách sử dụng
xa_get_mark().  Nếu mục nhập không phải là ZZ0000ZZ, bạn có thể đặt dấu vào đó
bằng cách sử dụng xa_set_mark() và xóa dấu khỏi mục nhập bằng cách gọi
xa_clear_mark().  Bạn có thể hỏi liệu bất kỳ mục nào trong XArray có
dấu cụ thể được đặt bằng cách gọi xa_marked().  Xóa một mục từ
XArray làm cho tất cả các dấu liên quan đến mục đó bị xóa.

Việc đặt hoặc xóa dấu trên bất kỳ chỉ mục nào của mục nhập nhiều chỉ mục sẽ
ảnh hưởng đến tất cả các chỉ số được đề cập trong mục đó.  Truy vấn nhãn hiệu trên bất kỳ
chỉ mục sẽ trả về kết quả tương tự.

Không có cách nào để lặp lại các mục không được đánh dấu; dữ liệu
cấu trúc không cho phép điều này được thực hiện một cách hiệu quả.  có
hiện không phải là trình vòng lặp để tìm kiếm sự kết hợp logic của các bit (ví dụ:
lặp lại tất cả các mục có cả ZZ0000ZZ và ZZ0001ZZ
đặt hoặc lặp lại tất cả các mục có ZZ0002ZZ hoặc ZZ0003ZZ
thiết lập).  Có thể thêm những thứ này nếu người dùng phát sinh.

Phân bổ XArray
------------------

Nếu bạn sử dụng DEFINE_XARRAY_ALLOC() để xác định XArray hoặc
khởi tạo nó bằng cách chuyển ZZ0000ZZ tới xa_init_flags(),
XArray thay đổi để theo dõi xem các mục có được sử dụng hay không.

Bạn có thể gọi xa_alloc() để lưu mục nhập ở chỉ mục không sử dụng
trong XArray.  Nếu bạn cần sửa đổi mảng từ ngữ cảnh ngắt,
bạn có thể sử dụng xa_alloc_bh() hoặc xa_alloc_irq() để tắt
bị gián đoạn trong khi cấp phát ID.

Sử dụng xa_store(), xa_cmpxchg() hoặc xa_insert() sẽ
cũng đánh dấu mục nhập là được phân bổ.  Không giống như XArray bình thường, việc lưu trữ
ZZ0000ZZ sẽ đánh dấu mục này là đang được sử dụng, như xa_reserve().
Để giải phóng một mục, hãy sử dụng xa_erase() (hoặc xa_release() nếu
bạn chỉ muốn giải phóng mục nhập nếu đó là ZZ0001ZZ).

Theo mặc định, mục nhập miễn phí thấp nhất được phân bổ bắt đầu từ 0. Nếu bạn
muốn phân bổ các mục bắt đầu từ 1, sẽ hiệu quả hơn khi sử dụng
DEFINE_XARRAY_ALLOC1() hoặc ZZ0000ZZ.  Nếu bạn muốn
phân bổ ID đến mức tối đa, sau đó quay trở lại mức miễn phí thấp nhất
ID, bạn có thể sử dụng xa_alloc_cycle().

Bạn không thể sử dụng ZZ0000ZZ với XArray phân bổ làm nhãn hiệu này
được sử dụng để theo dõi xem một mục có miễn phí hay không.  Các dấu hiệu khác là
có sẵn để bạn sử dụng.

Phân bổ bộ nhớ
-----------------

Các xa_store(), xa_cmpxchg(), xa_alloc(),
Các hàm xa_reserve() và xa_insert() nhận gfp_t
tham số trong trường hợp XArray cần phân bổ bộ nhớ để lưu trữ mục này.
Nếu mục nhập đang bị xóa, không cần thực hiện phân bổ bộ nhớ,
và các cờ GFP được chỉ định sẽ bị bỏ qua.

Có thể không có bộ nhớ nào được cấp phát, đặc biệt nếu bạn vượt qua
một bộ cờ GFP hạn chế.  Trong trường hợp đó, các hàm trả về một
giá trị đặc biệt có thể được chuyển thành lỗi khi sử dụng xa_err().
Nếu bạn không cần biết chính xác lỗi nào đã xảy ra, hãy sử dụng
xa_is_err() hiệu quả hơn một chút.

Khóa
-------

Khi sử dụng API Thông thường, bạn không phải lo lắng về việc khóa.
XArray sử dụng RCU và một khóa xoay bên trong để đồng bộ hóa quyền truy cập:

Không cần khóa:
 * xa_empty()
 * xa_marked()

Thực hiện khóa đọc RCU:
 * xa_load()
 * xa_for_each()
 * xa_for_each_start()
 * xa_for_each_range()
 * xa_find()
 * xa_find_after()
 * xa_extract()
 * xa_get_mark()

Đưa xa_lock vào nội bộ:
 * xa_store()
 * xa_store_bh()
 * xa_store_irq()
 * xa_insert()
 * xa_insert_bh()
 * xa_insert_irq()
 * xa_erase()
 * xa_erase_bh()
 * xa_erase_irq()
 * xa_cmpxchg()
 * xa_cmpxchg_bh()
 * xa_cmpxchg_irq()
 * xa_store_range()
 * xa_alloc()
 * xa_alloc_bh()
 * xa_alloc_irq()
 * xa_reserve()
 * xa_reserve_bh()
 * xa_reserve_irq()
 * xa_destroy()
 * xa_set_mark()
 * xa_clear_mark()

Giả sử xa_lock được giữ khi nhập:
 * __xa_store()
 * __xa_insert()
 * __xa_erase()
 * __xa_cmpxchg()
 * __xa_alloc()
 * __xa_set_mark()
 * __xa_clear_mark()

Nếu bạn muốn tận dụng khóa để bảo vệ cấu trúc dữ liệu
mà bạn đang lưu trữ trong XArray, bạn có thể gọi xa_lock()
trước khi gọi xa_load(), sau đó tính số tham chiếu trên
đối tượng bạn đã tìm thấy trước khi gọi xa_unlock().  Điều này sẽ
ngăn các cửa hàng xóa đối tượng khỏi mảng giữa quá trình tìm kiếm
lên đối tượng và tăng số tiền hoàn lại.  Bạn cũng có thể sử dụng RCU để
tránh hủy bỏ bộ nhớ được giải phóng, nhưng lời giải thích về điều đó vượt xa
phạm vi của tài liệu này.

XArray không vô hiệu hóa các ngắt hoặc softirq trong khi sửa đổi
mảng.  Việc đọc XArray từ ngắt hoặc softirq là an toàn
bối cảnh vì khóa RCU cung cấp đủ khả năng bảo vệ.

Ví dụ: nếu bạn muốn lưu trữ các mục trong XArray đang được xử lý
bối cảnh và sau đó xóa chúng trong bối cảnh softirq, bạn có thể làm theo cách này ::

void foo_init(struct foo *foo)
    {
        xa_init_flags(&foo->mảng, XA_FLAGS_LOCK_BH);
    }

int foo_store(struct foo *foo, unsigned long index, void *entry)
    {
        int lỗi;

xa_lock_bh(&foo->mảng);
        err = xa_err(__xa_store(&foo->mảng, chỉ mục, mục nhập, GFP_KERNEL));
        nếu (! err)
            foo->đếm++;
        xa_unlock_bh(&foo->mảng);
        trả lại lỗi;
    }

/* foo_erase() chỉ được gọi từ ngữ cảnh softirq */
    void foo_erase(struct foo *foo, chỉ mục dài không dấu)
    {
        xa_lock(&foo->mảng);
        __xa_erase(&foo->mảng, chỉ mục);
        foo->đếm--;
        xa_unlock(&foo->mảng);
    }

Nếu bạn định sửa đổi XArray từ ngữ cảnh ngắt hoặc softirq,
bạn cần khởi tạo mảng bằng xa_init_flags(), chuyển
ZZ0000ZZ hoặc ZZ0001ZZ.

Ví dụ trên cũng cho thấy một mô hình chung là muốn mở rộng
phạm vi bảo hiểm của xa_lock ở phía cửa hàng để bảo vệ một số số liệu thống kê
liên kết với mảng.

Cũng có thể chia sẻ XArray với bối cảnh ngắt
sử dụng xa_lock_irqsave() trong cả trình xử lý và xử lý ngắt
bối cảnh hoặc xa_lock_irq() trong bối cảnh quá trình và xa_lock()
trong trình xử lý ngắt.  Một số mẫu phổ biến hơn có người trợ giúp
các hàm như xa_store_bh(), xa_store_irq(),
xa_erase_bh(), xa_erase_irq(), xa_cmpxchg_bh()
và xa_cmpxchg_irq().

Đôi khi bạn cần bảo vệ quyền truy cập vào XArray bằng một mutex vì
khóa đó nằm phía trên một mutex khác trong hệ thống phân cấp khóa.  Điều đó không
không cho phép bạn sử dụng các chức năng như __xa_erase() mà không lấy
xa_lock; xa_lock được sử dụng để xác thực lockdep và sẽ được sử dụng
cho các mục đích khác trong tương lai.

Các hàm __xa_set_mark() và __xa_clear_mark() cũng
có sẵn cho các tình huống mà bạn tra cứu một mục và muốn tìm kiếm một cách nguyên tử
thiết lập hoặc xóa một dấu.  Có thể hiệu quả hơn khi sử dụng API tiên tiến
trong trường hợp này, vì nó sẽ giúp bạn không phải đi lại trên cây hai lần.

API nâng cao
============

API tiên tiến mang đến sự linh hoạt hơn và hiệu suất tốt hơn ở
chi phí cho một giao diện khó sử dụng hơn và có ít biện pháp bảo vệ hơn.
API nâng cao không thực hiện khóa cho bạn và bạn được yêu cầu
để sử dụng xa_lock trong khi sửa đổi mảng.  Bạn có thể chọn xem
để sử dụng khóa xa_lock hoặc RCU trong khi thực hiện các thao tác chỉ đọc trên
mảng.  Bạn có thể kết hợp các thao tác nâng cao và thông thường trên cùng một mảng;
thực sự API bình thường được triển khai dưới dạng API nâng cao.  các
API nâng cao chỉ khả dụng cho các mô-đun có giấy phép tương thích với GPL.

API nâng cao dựa trên xa_state.  Đây là một dữ liệu không rõ ràng
cấu trúc mà bạn khai báo trên ngăn xếp bằng macro XA_STATE().
Macro này khởi tạo xa_state sẵn sàng để bắt đầu di chuyển xung quanh
XArray.  Nó được sử dụng như một con trỏ để duy trì vị trí trong XArray
và cho phép bạn kết hợp nhiều thao tác khác nhau mà không cần phải khởi động lại
từ đầu mọi lúc.  Nội dung của xa_state được bảo vệ bởi
rcu_read_lock() hoặc xas_lock().  Nếu bạn cần bỏ cái nào trong số đó
những khóa đó đang bảo vệ trạng thái và cây của bạn, bạn phải gọi xas_pause()
để các cuộc gọi trong tương lai không phụ thuộc vào các phần của bang đã được
không được bảo vệ.

Xa_state cũng được sử dụng để lưu trữ lỗi.  Bạn có thể gọi
xas_error() để truy xuất lỗi.  Tất cả các hoạt động kiểm tra xem
xa_state đang ở trạng thái lỗi trước khi tiếp tục, vì vậy không cần thiết
để bạn kiểm tra lỗi sau mỗi cuộc gọi; bạn có thể làm nhiều
gọi liên tiếp và chỉ kiểm tra tại một điểm thuận tiện.  duy nhất
các lỗi hiện do chính mã XArray tạo ra là ZZ0000ZZ và
ZZ0001ZZ nhưng nó hỗ trợ lỗi tùy ý trong trường hợp bạn muốn gọi
xas_set_err() chính bạn.

Nếu xa_state đang gặp lỗi ZZ0000ZZ, hãy gọi xas_nomem()
sẽ cố gắng phân bổ nhiều bộ nhớ hơn bằng cách sử dụng cờ gfp được chỉ định và
lưu nó vào xa_state cho lần thử tiếp theo.  Ý tưởng là bạn lấy
xa_lock, hãy thử thao tác và thả khóa.  hoạt động
cố gắng phân bổ bộ nhớ trong khi giữ khóa, nhưng nó còn hơn thế nữa
có khả năng thất bại.  Khi bạn đã bỏ khóa, xas_nomem()
có thể cố gắng hơn để phân bổ nhiều bộ nhớ hơn.  Nó sẽ trả về ZZ0001ZZ nếu
đáng để thử lại thao tác (tức là đã xảy ra lỗi bộ nhớ ZZ0003ZZ
nhiều bộ nhớ hơn đã được phân bổ).  Nếu nó đã được cấp phát bộ nhớ trước đó và
bộ nhớ đó không được sử dụng và không có lỗi nào (hoặc một số lỗi không được
ZZ0002ZZ), thì nó sẽ giải phóng bộ nhớ được phân bổ trước đó.

Mục nội bộ
----------------

XArray bảo lưu một số mục cho mục đích riêng của nó.  Những điều này không bao giờ
được tiếp xúc qua API bình thường, nhưng khi sử dụng API nâng cao, nó
có thể nhìn thấy chúng.  Thông thường cách tốt nhất để xử lý chúng là vượt qua chúng
tới xas_retry() và thử lại thao tác nếu nó trả về ZZ0000ZZ.

.. flat-table::
   :widths: 1 1 6

   * - Name
     - Test
     - Usage

   * - Node
     - xa_is_node()
     - An XArray node.  May be visible when using a multi-index xa_state.

   * - Sibling
     - xa_is_sibling()
     - A non-canonical entry for a multi-index entry.  The value indicates
       which slot in this node has the canonical entry.

   * - Retry
     - xa_is_retry()
     - This entry is currently being modified by a thread which has the
       xa_lock.  The node containing this entry may be freed at the end
       of this RCU period.  You should restart the lookup from the head
       of the array.

   * - Zero
     - xa_is_zero()
     - Zero entries appear as ``NULL`` through the Normal API, but occupy
       an entry in the XArray which can be used to reserve the index for
       future use.  This is used by allocating XArrays for allocated entries
       which are ``NULL``.

Các mục nội bộ khác có thể được thêm vào trong tương lai.  Trong chừng mực có thể, họ
sẽ được xử lý bởi xas_retry().

Chức năng bổ sung
------------------------

Hàm xas_create_range() phân bổ tất cả bộ nhớ cần thiết
để lưu trữ mọi mục trong một phạm vi.  Nó sẽ đặt ENOMEM ở xa_state nếu
nó không thể phân bổ bộ nhớ.

Bạn có thể sử dụng xas_init_marks() để đặt lại dấu trên một mục
về trạng thái mặc định của chúng.  Điều này thường là tất cả các dấu hiệu rõ ràng, trừ khi
XArray được đánh dấu bằng ZZ0000ZZ, trong trường hợp này dấu 0 được đặt
và tất cả các dấu hiệu khác đều rõ ràng.  Thay thế một mục bằng một mục khác bằng cách sử dụng
xas_store() sẽ không đặt lại điểm trên mục đó; nếu bạn muốn
việc đặt lại nhãn hiệu, bạn nên làm điều đó một cách rõ ràng.

xas_load() sẽ đi theo xa_state càng gần mục nhập
như nó có thể.  Nếu bạn biết xa_state đã được chuyển đến
mục nhập và cần kiểm tra xem mục nhập đó có thay đổi không, bạn có thể sử dụng
xas_reload() để lưu lệnh gọi hàm.

Nếu bạn cần chuyển sang một chỉ mục khác trong XArray, hãy gọi
xas_set().  Thao tác này sẽ đặt lại con trỏ về đầu cây,
nói chung sẽ làm cho thao tác tiếp theo đưa con trỏ đến vị trí mong muốn
chỗ trên cây.  Nếu bạn muốn chuyển sang chỉ mục tiếp theo hoặc trước đó,
gọi xas_next() hoặc xas_prev().  Việc thiết lập chỉ mục không
không di chuyển con trỏ quanh mảng nên không yêu cầu khóa
được giữ, trong khi chuyển sang chỉ mục tiếp theo hoặc trước đó.

Bạn có thể tìm kiếm mục hiện tại tiếp theo bằng xas_find().  Cái này
tương đương với cả xa_find() và xa_find_after();
nếu con trỏ đã được đưa đến một mục nhập thì nó sẽ tìm mục tiếp theo
mục nhập sau mục hiện được tham chiếu.  Nếu không, nó sẽ trả về
mục nhập tại chỉ mục của xa_state.  Sử dụng xas_next_entry() để
chuyển đến mục hiện tại tiếp theo thay vì xas_find() sẽ lưu
một lệnh gọi hàm trong phần lớn các trường hợp phải trả giá bằng việc phát ra nhiều hơn
mã nội tuyến.

Hàm xas_find_marked() cũng tương tự.  Nếu xa_state có
chưa được đi, nó sẽ trả về mục nhập ở chỉ mục của xa_state,
nếu nó được đánh dấu.  Nếu không, nó sẽ trả về mục được đánh dấu đầu tiên sau
mục được tham chiếu bởi xa_state.  Xas_next_marked()
hàm tương đương với xas_next_entry().

Khi lặp qua một phạm vi của XArray bằng xas_for_each()
hoặc xas_for_each_marked(), có thể cần phải tạm dừng
sự lặp lại.  Hàm xas_pause() tồn tại cho mục đích này.
Sau khi bạn đã hoàn thành công việc cần thiết và muốn tiếp tục, xa_state
ở trạng thái thích hợp để tiếp tục lặp lại sau khi nhập
bạn đã xử lý lần cuối.  Nếu bạn đã tắt các ngắt trong khi lặp,
thì đó là cách tốt để tạm dừng việc lặp lại và ngắt có thể kích hoạt lại
mỗi mục ZZ0000ZZ.

Các hàm xas_get_mark(), xas_set_mark() và xas_clear_mark() yêu cầu
con trỏ xa_state đã được di chuyển đến vị trí thích hợp trong
XArray; họ sẽ không làm gì nếu bạn đã gọi xas_pause() hoặc xas_set()
ngay trước đó.

Bạn có thể gọi xas_set_update() để có chức năng gọi lại
được gọi mỗi lần XArray cập nhật một nút.  Điều này được sử dụng bởi trang
mã bộ đệm làm việc để duy trì danh sách các nút chỉ chứa
mục bóng tối.

Mục nhập nhiều chỉ mục
----------------------

XArray có khả năng liên kết nhiều chỉ số lại với nhau để
các hoạt động trên một chỉ mục sẽ ảnh hưởng đến tất cả các chỉ mục.  Ví dụ, lưu trữ vào
bất kỳ chỉ mục nào cũng sẽ thay đổi giá trị của mục được truy xuất từ bất kỳ chỉ mục nào.
Đặt hoặc xóa dấu trên bất kỳ chỉ mục nào sẽ đặt hoặc xóa dấu
trên mọi chỉ số được gắn với nhau.  Việc thực hiện hiện tại
chỉ cho phép liên kết các phạm vi được căn chỉnh lũy thừa của hai với nhau;
ví dụ: chỉ số 64-127 có thể được gắn với nhau, nhưng 2-6 có thể không.  Điều này có thể
tiết kiệm lượng bộ nhớ đáng kể; ví dụ buộc 512 mục
cùng nhau sẽ tiết kiệm được hơn 4kB.

Bạn có thể tạo mục nhập nhiều chỉ mục bằng cách sử dụng XA_STATE_ORDER()
hoặc xas_set_order() theo sau là lệnh gọi tới xas_store().
Gọi xas_load() với xa_state đa chỉ mục sẽ thực hiện
xa_state vào đúng vị trí trên cây nhưng giá trị trả về thì không
có ý nghĩa, có khả năng là một mục nội bộ hoặc ZZ0000ZZ ngay cả khi có
là một mục được lưu trữ trong phạm vi.  Gọi xas_find_conflict()
sẽ trả về mục đầu tiên trong phạm vi hoặc ZZ0001ZZ nếu không có
các mục trong phạm vi.  Trình lặp xas_for_each_conflict() sẽ
lặp lại mọi mục nhập trùng lặp với phạm vi đã chỉ định.

Nếu xas_load() gặp mục nhập nhiều chỉ mục, xa_index
trong xa_state sẽ không bị thay đổi.  Khi lặp qua XArray
hoặc gọi xas_find(), nếu chỉ mục ban đầu ở giữa
của một mục nhập có nhiều chỉ mục, nó sẽ không bị thay đổi.  Cuộc gọi tiếp theo
hoặc các lần lặp sẽ di chuyển chỉ mục đến chỉ mục đầu tiên trong phạm vi.
Mỗi mục sẽ chỉ được trả về một lần, bất kể nó có bao nhiêu chỉ mục
chiếm giữ.

Sử dụng xas_next() hoặc xas_prev() với xa_state đa chỉ mục là không
được hỗ trợ.  Việc sử dụng một trong hai hàm này trên mục nhập có nhiều chỉ mục sẽ
tiết lộ các mục anh chị em; người gọi nên bỏ qua những điều này.

Lưu trữ ZZ0000ZZ vào bất kỳ chỉ mục nào của mục nhập nhiều chỉ mục sẽ đặt
nhập ở mọi chỉ số vào ZZ0001ZZ và giải thể mối ràng buộc.  Đa chỉ mục
mục nhập có thể được chia thành các mục chiếm phạm vi nhỏ hơn bằng cách gọi
xas_split_alloc() mà không giữ xa_lock, sau đó lấy khóa
và gọi xas_split() hoặc gọi xas_try_split() bằng xa_lock. các
sự khác biệt giữa xas_split_alloc()+xas_split() và xas_try_alloc() là
xas_split_alloc() + xas_split() tách mục nhập khỏi bản gốc
sắp xếp theo thứ tự mới một cách thống nhất, trong khi xas_try_split()
lặp đi lặp lại việc phân chia mục chứa chỉ mục không đồng nhất.
Ví dụ: để phân chia mục nhập đơn hàng-9, chiếm 2^(9-6)=8 vị trí,
giả sử ZZ0002ZZ là 6, xas_split_alloc() + xas_split() cần
8 xa_node. xas_try_split() chia mục nhập thứ tự 9 thành
2 mục nhập đơn hàng 8, sau đó chia một mục nhập đơn hàng 8, dựa trên chỉ mục đã cho,
thành 2 mục nhập đơn hàng 7, ... và chia một mục nhập đơn hàng 1 thành 2 mục nhập đơn hàng 0.
Khi tách mục nhập order-6 và cần có xa_node mới, xas_try_split()
sẽ cố gắng phân bổ một nếu có thể. Kết quả là xas_try_split() sẽ chỉ
cần 1 xa_node thay vì 8.

Chức năng và cấu trúc
========================

.. kernel-doc:: include/linux/xarray.h
.. kernel-doc:: lib/xarray.c