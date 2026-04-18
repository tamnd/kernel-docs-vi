.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/locking/robust-futex-ABI.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================
Futex ABI mạnh mẽ
====================

:Tác giả: Bắt đầu bởi Paul Jackson <pj@sgi.com>


Robust_futexes cung cấp một cơ chế được sử dụng ngoài cơ chế thông thường
futexes, để hỗ trợ kernel dọn dẹp các khóa bị giữ khi thoát tác vụ.

Dữ liệu thú vị về những gì futex mà một luồng đang nắm giữ được lưu giữ trên một
danh sách liên kết trong không gian người dùng, nơi nó có thể được cập nhật một cách hiệu quả dưới dạng khóa
được lấy và loại bỏ mà không cần sự can thiệp của kernel.  Bổ sung duy nhất
Cần có sự can thiệp của kernel đối với Robust_futexes ở trên và hơn thế nữa
cần thiết cho futexes là:

1) lệnh gọi một lần, trên mỗi luồng, để báo cho kernel biết danh sách các
    được tổ chức Robust_futexes bắt đầu và
 2) mã hạt nhân nội bộ khi thoát, để xử lý mọi khóa được liệt kê được giữ
    bởi luồng thoát.

Các futex thông thường hiện có đã cung cấp tính năng "Khóa không gian người dùng nhanh"
cơ chế xử lý việc khóa không bị tranh chấp mà không cần hệ thống
gọi và xử lý việc khóa tranh chấp bằng cách duy trì danh sách chờ
các luồng trong kernel.  Các tùy chọn về hỗ trợ cuộc gọi hệ thống sys_futex(2)
chờ đợi một futex cụ thể và đánh thức người phục vụ tiếp theo trên một
futex cụ thể.

Để Robust_futexes hoạt động, mã người dùng (thường nằm trong thư viện như
như glibc được liên kết với ứng dụng) phải quản lý và đặt
danh sách các phần tử cần thiết chính xác như kernel mong đợi.  Nếu nó thất bại
để làm như vậy thì các khóa được liệt kê không đúng sẽ không được xóa khi thoát,
có thể gây ra bế tắc hoặc lỗi tương tự khác của các luồng khác
đang chờ đợi trên cùng một ổ khóa.

Một luồng dự kiến có thể sử dụng Robust_futexes trước tiên phải
đưa ra lời gọi hệ thống::

liên kết dài
    sys_set_robust_list(struct Robust_list_head __user *head, size_t len);

Con trỏ 'đầu' trỏ đến một cấu trúc trong không gian địa chỉ của luồng
gồm có ba từ.  Mỗi từ có 32 bit trên vòm 32 bit hoặc 64
bit trên vòm 64 bit và thứ tự byte cục bộ.  Mỗi chủ đề nên có
chủ đề riêng tư của nó 'đầu'.

Nếu một luồng đang chạy ở chế độ tương thích 32 bit trên vòm gốc 64
kernel, thì nó thực sự có thể có hai cấu trúc như vậy - một cấu trúc sử dụng 32 bit
từ cho chế độ tương thích 32 bit và một từ sử dụng từ 64 bit cho chế độ tương thích 64
chế độ gốc bit.  Hạt nhân, nếu là hạt nhân 64 bit hỗ trợ 32 bit
chế độ tương thích, sẽ cố gắng xử lý cả hai danh sách trên mỗi tác vụ
thoát, nếu lệnh gọi sys_set_robust_list() tương ứng đã được thực hiện tới
thiết lập danh sách đó.

Từ đầu tiên trong cấu trúc bộ nhớ ở 'head' chứa một
  con trỏ tới một danh sách liên kết duy nhất của 'mục khóa', mỗi mục một khóa,
  như được mô tả dưới đây.  Nếu danh sách trống, con trỏ sẽ trỏ
  với chính nó, 'đầu'.  'Mục khóa' cuối cùng quay lại 'đầu'.

Từ thứ hai, được gọi là 'offset', chỉ định phần bù từ
  địa chỉ của 'mục khóa' liên quan, cộng hoặc trừ, những gì sẽ
  được gọi là 'từ khóa', từ 'mục khóa' đó.  'Từ khóa'
  luôn là một từ 32 bit, không giống như các từ khác ở trên.  Cái khóa
  word' giữ 2 bit cờ ở 2 bit trên và id luồng (TID)
  của luồng giữ khóa ở 30 bit dưới cùng.  Xem thêm
  bên dưới để biết mô tả về các bit cờ.

Từ thứ ba, được gọi là 'list_op_pending', chứa bản sao tạm thời của
  địa chỉ của 'mục khóa', trong quá trình chèn và xóa danh sách,
  và cần thiết để giải quyết chính xác các cuộc đua nếu một luồng thoát ra trong khi
  ở giữa thao tác khóa hoặc mở khóa.

Mỗi 'mục khóa' trên danh sách liên kết đơn bắt đầu từ 'đầu' bao gồm
chỉ một từ duy nhất, trỏ đến 'mục khóa' tiếp theo hoặc quay lại
'đầu' nếu không còn mục nào nữa.  Ngoài ra, ở gần mỗi ổ khóa
mục nhập', ở độ lệch so với 'mục nhập khóa' được chỉ định bởi 'phần bù'
từ, là một 'khóa từ'.

'Từ khóa' luôn là 32 bit và được dự định là 32 bit giống nhau
Biến khóa được sử dụng bởi cơ chế futex, kết hợp với
mạnh mẽ_futexes.  Hạt nhân sẽ chỉ có thể đánh thức luồng tiếp theo
chờ khóa trên một luồng thoát nếu luồng tiếp theo đó sử dụng futex
cơ chế đăng ký địa chỉ của “lock word” đó với kernel.

Đối với mỗi khóa futex hiện được giữ bởi một luồng, nếu nó muốn điều này
hỗ trợ Robust_futex để dọn dẹp lối ra của khóa đó, cần có một cái
'khóa mục' trong danh sách này, với 'từ khóa' liên quan ở
'bù đắp' được chỉ định.  Nếu một sợi chỉ bị chết khi đang giữ bất kỳ ổ khóa nào như vậy,
kernel sẽ duyệt danh sách này, đánh dấu bất kỳ khóa nào như vậy bằng một chút
cho biết chủ sở hữu của họ đã chết và đánh thức chuỗi tiếp theo đang chờ
khóa đó bằng cơ chế futex.

Khi một luồng đã gọi lệnh gọi hệ thống ở trên để chỉ ra nó
dự đoán bằng cách sử dụng Robust_futexes, kernel sẽ lưu trữ thông tin được truyền vào 'head'
con trỏ cho nhiệm vụ đó.  Tác vụ có thể truy xuất giá trị đó sau này bằng cách
sử dụng lệnh gọi hệ thống::

liên kết dài
    sys_get_robust_list(int pid, struct Robust_list_head __user **head_ptr,
                        size_t __người dùng *len_ptr);

Người ta dự đoán rằng các chủ đề sẽ sử dụng Robust_futexes được nhúng trong
cấu trúc khóa cấp độ người dùng lớn hơn, mỗi cấu trúc một khóa.  Hạt nhân
Cơ chế Robust_futex không quan tâm đến cấu trúc đó có gì khác, vì vậy
miễn là 'độ lệch' cho 'từ khóa' là như nhau đối với tất cả
Robust_futexes được chủ đề đó sử dụng.  Sợi dây sẽ liên kết những ổ khóa đó
nó hiện đang giữ bằng cách sử dụng con trỏ 'khóa mục nhập'.  Nó cũng có thể có
các liên kết khác giữa các ổ khóa, chẳng hạn như mặt sau của một đôi
danh sách liên kết, nhưng điều đó không quan trọng với kernel.

Bằng cách giữ các khóa của nó được liên kết theo cách này, trên danh sách bắt đầu bằng 'đầu'
con trỏ được biết đến trong kernel, kernel có thể cung cấp cho một thread
dịch vụ thiết yếu có sẵn cho Robust_futexes, giúp dọn dẹp
lên các ổ khóa được giữ tại thời điểm thoát (có lẽ là bất ngờ).

Việc khóa và mở khóa thực tế trong quá trình hoạt động bình thường được xử lý
hoàn toàn bằng mã cấp độ người dùng trong các luồng tranh chấp và bằng
cơ chế futex hiện có để chờ và đánh thức, khóa.  Hạt nhân
Sự tham gia cần thiết duy nhất trong Robust_futexes là nhớ vị trí của
danh sách 'đầu' là, và để duyệt danh sách khi thoát luồng, xử lý các khóa
vẫn được giữ bởi sợi chỉ khởi hành, như mô tả bên dưới.

Có thể tồn tại hàng nghìn cấu trúc khóa futex trong một luồng được chia sẻ
bộ nhớ, trên các cấu trúc dữ liệu khác nhau, tại một thời điểm nhất định. Chỉ những cái đó
cấu trúc khóa cho các khóa hiện được giữ bởi luồng đó phải được bật
danh sách khóa được liên kết Robust_futex của luồng đó trong một thời gian nhất định.

Cấu trúc khóa futex nhất định trong vùng bộ nhớ dùng chung của người dùng có thể được giữ
tại các thời điểm khác nhau bởi bất kỳ luồng nào có quyền truy cập vào khu vực đó. các
luồng hiện đang giữ khóa như vậy, nếu có, được đánh dấu bằng các luồng
TID ở 30 bit thấp hơn của 'từ khóa'.

Khi thêm hoặc xóa một khóa khỏi danh sách các khóa được giữ của nó, để
kernel để xử lý chính xác việc dọn dẹp khóa bất kể khi nào tác vụ
thoát ra (có lẽ nó nhận được tín hiệu không mong muốn 9 ở giữa
thao tác danh sách này), mã người dùng phải tuân theo những điều sau
giao thức chèn và xóa 'khóa mục nhập':

Khi chèn:

1) đặt từ 'list_op_pending' thành địa chỉ của 'mục khóa'
    được chèn vào,
 2) có được khóa futex,
 3) thêm mục khóa, với id luồng của nó (TID) ở 30 bit dưới cùng
    của 'từ khóa', vào danh sách liên kết bắt đầu từ 'đầu', và
 4) xóa từ 'list_op_pending'.

Khi gỡ bỏ:

1) đặt từ 'list_op_pending' thành địa chỉ của 'mục khóa'
    bị loại bỏ,
 2) xóa mục khóa cho khóa này khỏi danh sách 'đầu',
 3) nhả khóa futex và
 4) xóa từ 'lock_op_pending'.

Khi thoát, kernel sẽ xem xét địa chỉ được lưu trong
'list_op_pending' và địa chỉ của từng 'lock word' được tìm thấy bằng cách đi bộ
danh sách bắt đầu từ 'đầu'.  Đối với mỗi địa chỉ như vậy, nếu 30 dưới cùng
các bit của 'từ khóa' ở phần bù 'offset' từ địa chỉ đó bằng với
thoát khỏi luồng TID, thì kernel sẽ thực hiện hai việc:

1) nếu bit 31 (0x80000000) được đặt trong từ đó, thì hãy thử futex
    đánh thức địa chỉ đó, điều này sẽ đánh thức luồng tiếp theo có
    đã sử dụng cơ chế futex để đợi địa chỉ đó và
 2) đặt nguyên tử bit 30 (0x40000000) trong 'từ khóa'.

Ở phần trên, bit 31 được người phục vụ futex thiết lập trên khóa đó để biểu thị
họ đang đợi và bit 30 được hạt nhân thiết lập để chỉ ra rằng
chủ ổ khóa chết khi cầm ổ khóa.

Mã thoát kernel sẽ âm thầm dừng quét thêm danh sách nếu tại
bất kỳ điểm nào:

1) con trỏ 'đầu' hoặc con trỏ danh sách liên kết tiếp theo
    không phải là địa chỉ hợp lệ của từ không gian người dùng
 2) vị trí được tính toán của 'từ khóa' (địa chỉ cộng
    'offset') không phải là địa chỉ hợp lệ của không gian người dùng 32 bit
    từ
 3) nếu danh sách chứa hơn 1 triệu (tùy thuộc vào
    các phần tử thay đổi cấu hình hạt nhân trong tương lai).

Khi hạt nhân nhìn thấy một mục danh sách có 'từ khóa' không có
các luồng hiện tại TID ở 30 bit thấp hơn, nó không làm gì với điều đó
mục này và chuyển sang mục tiếp theo.
