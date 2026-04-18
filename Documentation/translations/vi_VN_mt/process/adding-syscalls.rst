.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/adding-syscalls.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.


.. _addsyscalls:

Thêm cuộc gọi hệ thống mới
==========================

Tài liệu này mô tả những gì liên quan đến việc thêm lệnh gọi hệ thống mới vào
Nhân Linux, hơn cả lời khuyên gửi thông thường trong
ZZ0000ZZ.


Các lựa chọn thay thế cuộc gọi hệ thống
---------------------------------------

Điều đầu tiên cần xem xét khi thêm một cuộc gọi hệ thống mới là liệu một trong
thay thế có thể phù hợp.  Mặc dù các cuộc gọi hệ thống là
điểm tương tác truyền thống nhất và rõ ràng nhất giữa không gian người dùng và
kernel, vẫn có những khả năng khác -- hãy chọn cái phù hợp nhất với bạn
giao diện.

- Nếu các thao tác liên quan có thể được thực hiện trông giống như một hệ thống tập tin
   đối tượng, việc tạo một hệ thống tập tin hoặc thiết bị mới có thể có ý nghĩa hơn.  Cái này
   cũng giúp việc đóng gói chức năng mới trong mô-đun hạt nhân dễ dàng hơn
   thay vì yêu cầu nó phải được tích hợp vào kernel chính.

- Nếu chức năng mới liên quan đến các hoạt động mà kernel thông báo
       không gian người dùng rằng có điều gì đó đã xảy ra, sau đó trả lại một tệp mới
       bộ mô tả cho đối tượng liên quan cho phép không gian người dùng sử dụng
       ZZ0003ZZ/ZZ0004ZZ/ZZ0005ZZ để nhận thông báo đó.
     - Tuy nhiên, các thao tác không ánh xạ tới
       Hoạt động giống ZZ0000ZZ/ZZ0001ZZ
       phải được triển khai theo yêu cầu ZZ0002ZZ, điều này có thể dẫn đến
       đến một chiếc API hơi mờ.

- Nếu bạn chỉ hiển thị thông tin hệ thống thời gian chạy, một nút mới trong sysfs
   (xem ZZ0005ZZ) hoặc hệ thống tập tin ZZ0006ZZ có thể
   trở nên thích hợp hơn.  Tuy nhiên, việc tiếp cận các cơ chế này đòi hỏi
   hệ thống tập tin liên quan đã được gắn kết, điều này có thể không phải lúc nào cũng đúng (ví dụ:
   trong môi trường được đặt tên/hộp cát/chroot).  Tránh thêm bất kỳ API nào vào
   debugfs, vì đây không được coi là giao diện 'sản xuất' cho không gian người dùng.
 - Nếu thao tác dành riêng cho một tệp hoặc bộ mô tả tệp cụ thể thì
   tùy chọn lệnh ZZ0000ZZ bổ sung có thể phù hợp hơn.  Tuy nhiên,
   ZZ0001ZZ là một cuộc gọi hệ thống ghép kênh có rất nhiều sự phức tạp, vì vậy
   tùy chọn này là tốt nhất khi chức năng mới gần giống với
   chức năng ZZ0002ZZ hiện có hoặc chức năng mới rất đơn giản
   (ví dụ: nhận/đặt cờ đơn giản liên quan đến bộ mô tả tệp).
 - Nếu thao tác đó dành riêng cho một nhiệm vụ hoặc quy trình cụ thể thì
   tùy chọn lệnh ZZ0003ZZ bổ sung có thể phù hợp hơn.  Như
   với ZZ0004ZZ, lệnh gọi hệ thống này là một bộ ghép kênh phức tạp nên
   được dành riêng tốt nhất cho các lệnh gần tương tự của các lệnh ZZ0007ZZ hiện có hoặc
   nhận/đặt cờ đơn giản liên quan đến một quy trình.


Thiết kế API: Lập kế hoạch mở rộng
-----------------------------------------

Lệnh gọi hệ thống mới tạo thành một phần của API của kernel và phải được hỗ trợ
vô thời hạn.  Vì vậy, sẽ là một ý tưởng rất hay nếu thảo luận một cách rõ ràng về
giao diện trên danh sách gửi thư kernel và điều quan trọng là lập kế hoạch cho tương lai
phần mở rộng của giao diện.

(Bảng syscall chứa đầy các ví dụ lịch sử mà việc này chưa được thực hiện,
cùng với các lệnh gọi hệ thống tiếp theo tương ứng --
ZZ0000ZZ/ZZ0001ZZ, ZZ0002ZZ/ZZ0003ZZ, ZZ0004ZZ/ZZ0005ZZ,
ZZ0006ZZ/ZZ0007ZZ, ZZ0008ZZ/ZZ0009ZZ -- vậy
tìm hiểu từ lịch sử của kernel và lên kế hoạch cho các phần mở rộng ngay từ đầu.)

Đối với các cuộc gọi hệ thống đơn giản hơn chỉ có một vài đối số, ưu tiên
cách để cho phép khả năng mở rộng trong tương lai là đưa đối số cờ vào
cuộc gọi hệ thống.  Để đảm bảo rằng các chương trình không gian người dùng có thể sử dụng cờ một cách an toàn
giữa các phiên bản hạt nhân, hãy kiểm tra xem giá trị cờ có chứa bất kỳ ẩn số nào không
cờ và từ chối lệnh gọi hệ thống (với ZZ0000ZZ) nếu có ::

nếu (cờ & ~(THING_FLAG1 ZZ0000ZZ THING_FLAG3))
        trả về -EINVAL;

(Nếu chưa sử dụng giá trị cờ nào, hãy kiểm tra xem đối số cờ có bằng 0 không.)

Đối với các lệnh gọi hệ thống phức tạp hơn có số lượng đối số lớn hơn,
tốt nhất nên gói gọn phần lớn các đối số vào một cấu trúc
được truyền vào bằng con trỏ.  Cấu trúc như vậy có thể đáp ứng được nhu cầu mở rộng trong tương lai
bằng cách bao gồm một đối số kích thước trong cấu trúc::

cấu trúc xyzzy_params {
        kích thước u32; /* không gian người dùng đặt p->size = sizeof(struct xyzzy_params) */
        u32 thông số_1;
        u64 thông số_2;
        u64 param_3;
    };

Miễn là bất kỳ trường nào được thêm sau đó, chẳng hạn như ZZ0000ZZ, đều được thiết kế sao cho
giá trị 0 cho hành vi trước đó, thì điều này cho phép cả hai hướng
phiên bản không khớp:

- Để đối phó với chương trình không gian người dùng sau này gọi kernel cũ hơn, kernel
   mã nên kiểm tra xem có bất kỳ bộ nhớ nào vượt quá kích thước của cấu trúc mà nó
   kỳ vọng bằng 0 (kiểm tra hiệu quả ZZ0000ZZ đó).
 - Để đối phó với chương trình không gian người dùng cũ hơn gọi hạt nhân mới hơn, hạt nhân
   mã có thể mở rộng bằng không một phiên bản nhỏ hơn của cấu trúc (một cách hiệu quả
   cài đặt ZZ0001ZZ).

Xem ZZ0000ZZ và chức năng ZZ0001ZZ (trong
ZZ0002ZZ) để biết ví dụ về phương pháp này.


Thiết kế API: Những cân nhắc khác
---------------------------------------

Nếu lệnh gọi hệ thống mới của bạn cho phép không gian người dùng tham chiếu đến một đối tượng kernel, thì nó
nên sử dụng bộ mô tả tệp làm phần xử lý cho đối tượng đó -- đừng phát minh ra
kiểu xử lý đối tượng không gian người dùng mới khi kernel đã có cơ chế và
ngữ nghĩa được xác định rõ ràng để sử dụng bộ mô tả tệp.

Nếu lệnh gọi hệ thống xyzzy(2) mới của bạn trả về một bộ mô tả tệp mới,
thì đối số flags sẽ bao gồm một giá trị tương đương với cài đặt
ZZ0000ZZ trên FD mới.  Điều này làm cho không gian người dùng có thể đóng
cửa sổ thời gian giữa ZZ0001ZZ và cuộc gọi
ZZ0002ZZ, nơi có ZZ0003ZZ bất ngờ và
ZZ0004ZZ trong một luồng khác có thể rò rỉ bộ mô tả tới
chương trình được thực hiện. (Tuy nhiên, hãy chống lại sự cám dỗ sử dụng lại giá trị thực tế
của hằng số ZZ0005ZZ, vì nó có kiến trúc cụ thể và là một phần của
không gian đánh số của cờ ZZ0006ZZ khá đầy đủ.)

Nếu cuộc gọi hệ thống của bạn trả về một bộ mô tả tệp mới, bạn cũng nên xem xét
ý nghĩa của việc sử dụng dòng lệnh gọi hệ thống ZZ0000ZZ trên tệp đó
mô tả. Làm cho bộ mô tả tập tin sẵn sàng để đọc hoặc ghi là
cách thông thường để kernel chỉ ra không gian người dùng rằng một sự kiện đã xảy ra
xảy ra trên đối tượng kernel tương ứng.

Nếu lệnh gọi hệ thống xyzzy(2) mới của bạn liên quan đến đối số tên tệp ::

int sys_xyzzy(const char __user *path, ..., unsigned int flag);

bạn cũng nên xem xét liệu phiên bản xyzzyat(2) có phù hợp hơn không ::

int sys_xyzzyat(int dfd, const char __user *path, ..., cờ int không dấu);

Điều này cho phép linh hoạt hơn về cách không gian người dùng chỉ định tệp được đề cập;
đặc biệt là nó cho phép không gian người dùng yêu cầu chức năng cho một
bộ mô tả tệp đã mở bằng cờ ZZ0000ZZ, một cách hiệu quả
cung cấp miễn phí thao tác fxyzzy(3) ::

- xyzzyat(AT_FDCWD, path, ..., 0) tương đương với xyzzy(path,...)
 - xyzzyat(fd, "", ..., AT_EMPTY_PATH) tương đương với fxyzzy(fd, ...)

(Để biết thêm chi tiết về lý do của lệnh gọi \*at(), hãy xem phần
Trang người dùng ZZ0000ZZ; để biết ví dụ về AT_EMPTY_PATH, hãy xem
Trang người dùng ZZ0001ZZ.)

Nếu lệnh gọi hệ thống xyzzy(2) mới của bạn liên quan đến một tham số mô tả một
offset trong một tệp, hãy đặt loại ZZ0000ZZ của nó để có thể bù đắp 64-bit
được hỗ trợ ngay cả trên kiến trúc 32-bit.

Nếu lệnh gọi hệ thống xyzzy(2) mới của bạn liên quan đến chức năng đặc quyền,
nó cần được quản lý bởi bit khả năng thích hợp của Linux (được kiểm tra bằng
một cuộc gọi tới ZZ0001ZZ), như được mô tả trong ZZ0000ZZ man
trang.  Chọn một bit khả năng hiện có chi phối chức năng liên quan,
nhưng cố gắng tránh kết hợp nhiều chức năng có liên quan mơ hồ với nhau
dưới cùng một bit, vì điều này đi ngược lại mục đích phân chia khả năng
sức mạnh của rễ.  Đặc biệt, tránh thêm những cách sử dụng mới của
khả năng ZZ0002ZZ quá chung chung.

Nếu lệnh gọi hệ thống xyzzy(2) mới của bạn thao túng một quy trình khác ngoài
quá trình gọi, nó sẽ bị hạn chế (sử dụng lệnh gọi tới
ZZ0000ZZ) để chỉ có quá trình gọi có cùng
các quyền như quy trình đích hoặc với các khả năng cần thiết có thể
thao tác quá trình mục tiêu.

Cuối cùng, hãy lưu ý rằng một số kiến trúc không phải x86 sẽ dễ dàng hơn nếu
các tham số cuộc gọi hệ thống rõ ràng là 64 bit rơi vào số lẻ
đối số (tức là tham số 1, 3, 5), để cho phép sử dụng các cặp 32 bit liền kề
sổ đăng ký.  (Mối lo ngại này không áp dụng nếu các đối số là một phần của
cấu trúc được truyền vào bằng con trỏ.)


Đề xuất API
-----------------

Để thực hiện các cuộc gọi hệ thống mới dễ dàng xem xét, tốt nhất nên chia nhỏ bản vá
thành từng đoạn riêng biệt.  Chúng nên bao gồm ít nhất các mục sau đây như
các cam kết riêng biệt (mỗi cam kết được mô tả thêm bên dưới):

- Việc triển khai cốt lõi của lệnh gọi hệ thống, cùng với các nguyên mẫu,
   đánh số chung, thay đổi Kconfig và triển khai sơ khai dự phòng.
 - Việc kết nối hệ thống mới đòi hỏi một kiến trúc cụ thể, thường là
   x86 (bao gồm tất cả x86_64, x86_32 và x32).
 - Trình diễn việc sử dụng lệnh gọi hệ thống mới trong không gian người dùng thông qua
   tự kiểm tra trong ZZ0000ZZ.
 - Một trang man dự thảo cho lệnh gọi hệ thống mới, dưới dạng văn bản thuần túy trong
   thư xin việc hoặc dưới dạng bản vá cho kho lưu trữ trang man (riêng biệt).

Các đề xuất cuộc gọi hệ thống mới, giống như bất kỳ thay đổi nào đối với API của kernel, phải luôn luôn
được gửi tới linux-api@vger.kernel.org.


Triển khai cuộc gọi hệ thống chung
----------------------------------

Điểm vào chính cho lệnh gọi hệ thống xyzzy(2) mới của bạn sẽ được gọi
ZZ0000ZZ, nhưng bạn thêm điểm vào này bằng
Macro ZZ0001ZZ thay vì rõ ràng.  Chữ 'n' biểu thị
số lượng đối số cho lệnh gọi hệ thống và macro lấy tên lệnh gọi hệ thống
theo sau là các cặp (loại, tên) cho các tham số làm đối số.  sử dụng
macro này cho phép siêu dữ liệu về cuộc gọi hệ thống mới được cung cấp cho
các công cụ khác.

Điểm vào mới cũng cần một nguyên mẫu hàm tương ứng, trong
ZZ0000ZZ, được đánh dấu là liên kết để phù hợp với cách hệ thống đó
các cuộc gọi được gọi::

asmlinkage dài sys_xyzzy(...);

Một số kiến trúc (ví dụ x86) có hệ thống tòa nhà dành riêng cho kiến trúc của chúng
các bảng, nhưng một số kiến trúc khác có chung một bảng tòa nhà chung. Thêm của bạn
gọi hệ thống mới vào danh sách chung bằng cách thêm một mục vào danh sách trong
ZZ0000ZZ::

#define __NR_xyzzy 292
    __SYSCALL(__NR_xyzzy, sys_xyzzy)

Đồng thời cập nhật số lượng __NR_syscalls để phản ánh cuộc gọi hệ thống bổ sung và
lưu ý rằng nếu nhiều lệnh gọi hệ thống mới được thêm vào cùng một cửa sổ hợp nhất,
số cuộc gọi chung mới của bạn có thể được điều chỉnh để giải quyết xung đột.

Tệp ZZ0000ZZ cung cấp cách triển khai sơ khai dự phòng của từng
cuộc gọi hệ thống, trả về ZZ0001ZZ.  Thêm lệnh gọi hệ thống mới của bạn vào đây::

COND_SYSCALL(xyzzy);

Chức năng hạt nhân mới của bạn và lệnh gọi hệ thống điều khiển nó sẽ
thường là tùy chọn, vì vậy hãy thêm tùy chọn ZZ0000ZZ (thường là
ZZ0001ZZ) cho nó. Như thường lệ đối với các tùy chọn ZZ0002ZZ mới:

- Bao gồm mô tả về chức năng mới và cuộc gọi hệ thống được kiểm soát
   theo tùy chọn.
 - Thực hiện tùy chọn phụ thuộc vào EXPERT nếu nó bị ẩn khỏi người dùng bình thường.
 - Tạo bất kỳ tệp nguồn mới nào thực hiện chức năng phụ thuộc vào CONFIG
   tùy chọn trong Makefile (ví dụ ZZ0000ZZ).
 - Kiểm tra kỹ xem kernel vẫn xây dựng với tùy chọn CONFIG mới được bật
   tắt.

Tóm lại, bạn cần một cam kết bao gồm:

- Tùy chọn ZZ0000ZZ cho chức năng mới, thông thường trong ZZ0001ZZ
 - ZZ0002ZZ cho điểm vào
 - nguyên mẫu tương ứng trong ZZ0003ZZ
 - mục nhập bảng chung trong ZZ0004ZZ
 - sơ khai dự phòng trong ZZ0005ZZ


.. _syscall_generic_6_11:

Kể từ ngày 11/6
~~~~~~~~~~~~~~~

Bắt đầu với phiên bản kernel 6.11, việc triển khai lệnh gọi hệ thống chung cho
các kiến trúc sau đây không còn yêu cầu sửa đổi đối với
ZZ0000ZZ:

- vòng cung
 - cánh tay64
 - csky
 - hình lục giác
 - loongarch
 - nios2
 - openrisc
 - riscv

Thay vào đó, bạn cần cập nhật ZZ0000ZZ và nếu có thể, hãy điều chỉnh
ZZ0001ZZ.

Vì ZZ0000ZZ phục vụ như một bảng tòa nhà chung trên nhiều
kiến trúc, cần có một mục mới trong bảng này::

468 xyzzy phổ biến sys_xyzzy

Lưu ý rằng việc thêm một mục vào ZZ0000ZZ bằng ABI "chung"
cũng ảnh hưởng đến tất cả các kiến trúc chia sẻ bảng này. Để hạn chế hơn hoặc
những thay đổi dành riêng cho kiến trúc, hãy cân nhắc sử dụng ABI dành riêng cho kiến trúc hoặc
xác định một cái mới.

Nếu ABI mới, chẳng hạn như ZZ0000ZZ, được giới thiệu, các bản cập nhật tương ứng sẽ là
cũng được tạo cho ZZ0001ZZ ::

syscall_abis_{32,64} += xyz (...)

Tóm lại, bạn cần một cam kết bao gồm:

- Tùy chọn ZZ0000ZZ cho chức năng mới, thông thường trong ZZ0001ZZ
 - ZZ0002ZZ cho điểm vào
 - nguyên mẫu tương ứng trong ZZ0003ZZ
 - mục mới trong ZZ0004ZZ
 - (nếu cần) Cập nhật Makefile trong ZZ0005ZZ
 - sơ khai dự phòng trong ZZ0006ZZ


Triển khai cuộc gọi hệ thống x86
--------------------------------

Để kết nối cuộc gọi hệ thống mới của bạn cho nền tảng x86, bạn cần cập nhật
bảng syscall chính.  Giả sử cuộc gọi hệ thống mới của bạn không có gì đặc biệt trong một số trường hợp
theo cách (xem bên dưới), điều này liên quan đến mục nhập "chung" (đối với x86_64 và x32) trong
Arch/x86/entry/syscalls/syscall_64.tbl::

333 xyzzy phổ biến sys_xyzzy

và mục "i386" trong ZZ0000ZZ::

380 i386 xyzzy sys_xyzzy

Một lần nữa, những con số này có thể bị thay đổi nếu có xung đột trong
cửa sổ hợp nhất có liên quan.


Cuộc gọi hệ thống tương thích (Chung)
-------------------------------------

Đối với hầu hết các cuộc gọi hệ thống, việc triển khai 64-bit tương tự có thể được gọi ngay cả khi
bản thân chương trình không gian người dùng là 32-bit; ngay cả khi các tham số của lệnh gọi hệ thống
bao gồm một con trỏ rõ ràng, việc này được xử lý một cách minh bạch.

Tuy nhiên, có một số trường hợp trong đó lớp tương thích được
cần thiết để giải quyết sự khác biệt về kích thước giữa 32 bit và 64 bit.

Đầu tiên là nếu hạt nhân 64 bit cũng hỗ trợ các chương trình không gian người dùng 32 bit và
vì vậy cần phân tích các vùng bộ nhớ (ZZ0000ZZ) có thể chứa 32-bit hoặc
Giá trị 64-bit.  Đặc biệt, điều này là cần thiết bất cứ khi nào một đối số cuộc gọi hệ thống
là:

- một con trỏ tới một con trỏ
 - một con trỏ tới một cấu trúc chứa một con trỏ (ví dụ ZZ0000ZZ)
 - một con trỏ tới loại tích phân có kích thước khác nhau (ZZ0001ZZ, ZZ0002ZZ,
   ZZ0003ZZ, ...)
 - một con trỏ tới một cấu trúc chứa kiểu tích phân có kích thước khác nhau.

Tình huống thứ hai yêu cầu lớp tương thích là nếu một trong các
đối số của cuộc gọi hệ thống có loại rõ ràng là 64-bit ngay cả trên 32-bit
kiến trúc, ví dụ ZZ0000ZZ hoặc ZZ0001ZZ.  Trong trường hợp này, một giá trị
đến kernel 64-bit từ ứng dụng 32-bit sẽ được chia thành hai
Các giá trị 32 bit, sau đó cần được tập hợp lại trong lớp tương thích.

(Lưu ý rằng đối số cuộc gọi hệ thống là con trỏ tới loại 64-bit rõ ràng
ZZ0003ZZ có cần lớp tương thích không; ví dụ: đối số của ZZ0000ZZ về
loại ZZ0001ZZ không kích hoạt nhu cầu gọi hệ thống ZZ0002ZZ.)

Phiên bản tương thích của lệnh gọi hệ thống được gọi là ZZ0000ZZ,
và được thêm bằng macro ZZ0001ZZ, tương tự như
SYSCALL_DEFINEn.  Phiên bản triển khai này chạy như một phần của phiên bản 64-bit
kernel, nhưng mong muốn nhận được các giá trị tham số 32-bit và thực hiện bất cứ điều gì
cần thiết để đối phó với chúng.  (Thông thường, phiên bản ZZ0002ZZ chuyển đổi
các giá trị thành phiên bản 64-bit và gọi phiên bản ZZ0003ZZ hoặc cả hai
họ gọi một hàm triển khai chung bên trong.)

Điểm vào tương thích cũng cần một nguyên mẫu hàm tương ứng, trong
ZZ0000ZZ, được đánh dấu là liên kết để phù hợp với cách hệ thống đó
các cuộc gọi được gọi::

asmlinkage dài compat_sys_xyzzy(...);

Nếu cuộc gọi hệ thống liên quan đến cấu trúc được trình bày khác trên 32-bit
và hệ thống 64-bit, chẳng hạn như ZZ0000ZZ, sau đó là include/linux/compat.h
tệp tiêu đề cũng phải bao gồm một phiên bản tương thích của cấu trúc (ZZ0001ZZ) trong đó mỗi trường có kích thước thay đổi có giá trị thích hợp
Loại ZZ0002ZZ tương ứng với loại trong ZZ0003ZZ.  các
Sau đó, quy trình ZZ0004ZZ có thể sử dụng cấu trúc ZZ0005ZZ này để
phân tích các đối số từ lệnh gọi 32 bit.

Ví dụ: nếu có các trường::

cấu trúc xyzzy_args {
        const char __user *ptr;
        __kernel_long_t thay đổi_val;
        u64 cố định_val;
        /* ... */
    };

trong struct xyzzy_args, thì struct compat_xyzzy_args sẽ có ::

cấu trúc compat_xyzzy_args {
        compat_uptr_t ptr;
        compat_long_t thay đổi_val;
        u64 cố định_val;
        /* ... */
    };

Danh sách cuộc gọi hệ thống chung cũng cần điều chỉnh để cho phép tương thích
phiên bản; mục trong ZZ0000ZZ nên sử dụng
ZZ0001ZZ chứ không phải ZZ0002ZZ::

#define __NR_xyzzy 292
    __SC_COMP(__NR_xyzzy, sys_xyzzy, compat_sys_xyzzy)

Tóm lại, bạn cần:

- ZZ0000ZZ cho điểm vào tương thích
 - nguyên mẫu tương ứng trong ZZ0001ZZ
 - (nếu cần) Cấu trúc ánh xạ 32 bit trong ZZ0002ZZ
 - phiên bản của ZZ0003ZZ chứ không phải ZZ0004ZZ trong
   ZZ0005ZZ


Kể từ ngày 11/6
~~~~~~~~~~~~~~~

Điều này áp dụng cho tất cả các kiến trúc được liệt kê trong ZZ0000ZZ
trong phần "Triển khai cuộc gọi hệ thống chung", ngoại trừ arm64. Xem
ZZ0001ZZ để biết thêm thông tin.

Bạn cần mở rộng mục nhập trong ZZ0000ZZ bằng một cột bổ sung
để chỉ ra rằng chương trình không gian người dùng 32 bit chạy trên hạt nhân 64 bit sẽ
nhấn điểm vào tương thích::

468 xyzzy phổ biến sys_xyzzy compat_sys_xyzzy

Tóm lại, bạn cần:

- ZZ0000ZZ cho điểm vào tương thích
 - nguyên mẫu tương ứng trong ZZ0001ZZ
 - sửa đổi mục nhập trong ZZ0002ZZ để bao gồm một mục bổ sung
   cột "tương thích"
 - (nếu cần) Cấu trúc ánh xạ 32 bit trong ZZ0003ZZ


.. _compat_arm64:

Cuộc gọi hệ thống tương thích (arm64)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Trên arm64, có một bảng syscall dành riêng cho các cuộc gọi hệ thống tương thích
nhắm mục tiêu không gian người dùng 32-bit (AArch32): ZZ0000ZZ.
Bạn cần thêm một dòng bổ sung vào bảng này để chỉ định tương thích
điểm vào::

468 xyzzy phổ biến sys_xyzzy compat_sys_xyzzy


Cuộc gọi hệ thống tương thích (x86)
-----------------------------------

Để kết nối kiến trúc x86 của cuộc gọi hệ thống với phiên bản tương thích,
các mục trong bảng syscall cần được điều chỉnh.

Đầu tiên, mục nhập trong ZZ0000ZZ sẽ nhận được thêm một khoản
cột để chỉ ra rằng chương trình không gian người dùng 32 bit chạy trên hạt nhân 64 bit
sẽ đạt điểm vào tương thích::

380 i386 xyzzy sys_xyzzy __ia32_compat_sys_xyzzy

Thứ hai, bạn cần tìm hiểu điều gì sẽ xảy ra với phiên bản x32 ABI của
cuộc gọi hệ thống mới.  Có một sự lựa chọn ở đây: cách bố trí các đối số
phải phù hợp với phiên bản 64 bit hoặc phiên bản 32 bit.

Nếu có liên quan đến con trỏ tới con trỏ thì quyết định rất dễ dàng: x32 là
ILP32, do đó bố cục phải phù hợp với phiên bản 32-bit và mục nhập trong
ZZ0000ZZ được chia nhỏ để các chương trình x32 tấn công
trình bao bọc tương thích::

333 64 xyzzy sys_xyzzy
    ...
555 x32 xyzzy __x32_compat_sys_xyzzy

Nếu không có con trỏ nào liên quan thì nên sử dụng lại hệ thống 64 bit
gọi x32 ABI (và do đó mục nhập trong
Arch/x86/entry/syscalls/syscall_64.tbl không thay đổi).

Trong cả hai trường hợp, bạn nên kiểm tra xem các loại liên quan đến đối số của bạn có
bố cục thực sự ánh xạ chính xác từ x32 (-mx32) sang 32-bit (-m32) hoặc
Tương đương 64-bit (-m64).


Cuộc gọi hệ thống quay trở lại nơi khác
---------------------------------------

Đối với hầu hết các cuộc gọi hệ thống, khi cuộc gọi hệ thống hoàn tất, chương trình người dùng sẽ
tiếp tục chính xác nơi nó đã dừng lại -- ở lệnh tiếp theo, với
xếp chồng giống nhau và hầu hết các thanh ghi giống như trước lệnh gọi hệ thống,
và với cùng một không gian bộ nhớ ảo.

Tuy nhiên, một số cuộc gọi hệ thống thực hiện những việc khác nhau.  Họ có thể quay trở lại một
vị trí khác (ZZ0000ZZ) hoặc thay đổi dung lượng bộ nhớ
(ZZ0001ZZ/ZZ0002ZZ/ZZ0003ZZ) hoặc thậm chí là kiến trúc (ZZ0004ZZ/ZZ0005ZZ)
của chương trình.

Để cho phép điều này, việc triển khai kernel của lệnh gọi hệ thống có thể cần phải
lưu và khôi phục các thanh ghi bổ sung vào ngăn xếp kernel, cho phép hoàn thành
kiểm soát vị trí và cách thức thực thi tiếp tục sau lệnh gọi hệ thống.

Điều này dành riêng cho từng kiến trúc nhưng thường liên quan đến việc xác định các điểm đầu vào của tập hợp
lưu/khôi phục các thanh ghi bổ sung và gọi mục nhập cuộc gọi hệ thống thực
điểm.

Đối với x86_64, điều này được triển khai dưới dạng điểm vào ZZ0000ZZ trong
ZZ0001ZZ và mục nhập trong bảng syscall
(ZZ0002ZZ) được điều chỉnh để phù hợp::

333 sơ khai xyzzy phổ biến_xyzzy

Thông thường, mức tương đương cho các chương trình 32 bit chạy trên kernel 64 bit là
được gọi là ZZ0000ZZ và được triển khai trong ZZ0001ZZ,
với sự điều chỉnh bảng syscall tương ứng trong
ZZ0002ZZ::

380 i386 xyzzy sys_xyzzy stub32_xyzzy

Nếu cuộc gọi hệ thống cần lớp tương thích (như trong phần trước)
thì phiên bản ZZ0000ZZ cần gọi lên phiên bản ZZ0001ZZ
của cuộc gọi hệ thống thay vì phiên bản 64-bit gốc.  Ngoài ra, nếu x32 ABI
việc triển khai không phổ biến với phiên bản x86_64, thì syscall của nó
bảng cũng sẽ cần gọi một sơ khai gọi tới ZZ0002ZZ
phiên bản.

Để hoàn thiện, bạn cũng nên thiết lập ánh xạ sao cho Linux ở chế độ người dùng
vẫn hoạt động -- bảng syscall của nó sẽ tham chiếu stub_xyzzy, nhưng bản dựng UML
không bao gồm việc triển khai ZZ0000ZZ (vì UML
mô phỏng các thanh ghi, v.v.).  Việc khắc phục điều này đơn giản như việc thêm #define vào
ZZ0001ZZ::

#define stub_xyzzy sys_xyzzy


Chi tiết khác
-------------

Hầu hết kernel xử lý các lệnh gọi hệ thống theo cách chung, nhưng có một
thỉnh thoảng có ngoại lệ có thể cần cập nhật cho lệnh gọi hệ thống cụ thể của bạn.

Hệ thống con kiểm toán là một trong những trường hợp đặc biệt như vậy; nó bao gồm (dành riêng cho vòm)
các hàm phân loại một số loại lệnh gọi hệ thống đặc biệt -- cụ thể là
mở tệp (ZZ0000ZZ/ZZ0001ZZ), thực thi chương trình (ZZ0002ZZ/ZZ0003ZZ) hoặc
Hoạt động ghép kênh ổ cắm (ZZ0004ZZ). Nếu cuộc gọi hệ thống mới của bạn là
tương tự như một trong những điều này thì hệ thống kiểm toán cần được cập nhật.

Tổng quát hơn, nếu có một lệnh gọi hệ thống hiện có tương tự với lệnh gọi hệ thống của bạn
cuộc gọi hệ thống mới, đáng để thực hiện grep toàn kernel cho hệ thống hiện có
gọi để kiểm tra không có trường hợp đặc biệt nào khác.


Kiểm tra
--------

Một cuộc gọi hệ thống mới rõ ràng phải được thử nghiệm; nó cũng hữu ích để cung cấp
người đánh giá bằng cách trình diễn cách các chương trình không gian người dùng sẽ sử dụng hệ thống
gọi.  Một cách tốt để kết hợp những mục tiêu này là bao gồm một bài tự kiểm tra đơn giản.
chương trình trong một thư mục mới dưới ZZ0000ZZ.

Đối với một cuộc gọi hệ thống mới, rõ ràng sẽ không có chức năng bao bọc libc và do đó
bài kiểm tra sẽ cần gọi nó bằng ZZ0000ZZ; Ngoài ra, nếu hệ thống gọi
liên quan đến cấu trúc hiển thị không gian người dùng mới, tiêu đề tương ứng sẽ cần
sẽ được cài đặt để biên dịch bài kiểm tra.

Đảm bảo quá trình tự kiểm tra diễn ra thành công trên tất cả các kiến ​​trúc được hỗ trợ.  cho
ví dụ: kiểm tra xem nó có hoạt động khi được biên dịch dưới dạng x86_64 (-m64), x86_32 (-m32)
và chương trình ABI x32 (-mx32).

Để thử nghiệm rộng rãi và kỹ lưỡng hơn về chức năng mới, bạn cũng nên
hãy xem xét thêm các thử nghiệm vào Dự án thử nghiệm Linux hoặc vào dự án xfstests
cho những thay đổi liên quan đến hệ thống tập tin.

-ZZ0000ZZ
 - git://git.kernel.org/pub/scm/fs/xfs/xfstests-dev.git


trang người đàn ông
-------------------

Tất cả các cuộc gọi hệ thống mới phải đi kèm với một trang man hoàn chỉnh, lý tưởng nhất là sử dụng groff
đánh dấu, nhưng văn bản thuần túy sẽ làm được.  Nếu sử dụng groff, sẽ rất hữu ích nếu bao gồm một
phiên bản ASCII được hiển thị trước của trang man trong email bìa cho
patchset, để thuận tiện cho người đánh giá.

Trang man phải được gửi tới linux-man@vger.kernel.org
Để biết thêm chi tiết, xem ZZ0000ZZ


Không gọi cuộc gọi hệ thống trong kernel
----------------------------------------

Các cuộc gọi hệ thống, như đã nêu ở trên, là các điểm tương tác giữa không gian người dùng và
hạt nhân.  Do đó, các chức năng gọi hệ thống như ZZ0000ZZ hoặc
ZZ0001ZZ chỉ nên được gọi từ không gian người dùng thông qua syscall
table, nhưng không phải từ nơi nào khác trong kernel.  Nếu chức năng syscall là
hữu ích để sử dụng trong kernel, cần được chia sẻ giữa kernel cũ và kernel
syscall mới hoặc cần được chia sẻ giữa syscall và khả năng tương thích của nó
biến thể, nó nên được thực hiện bằng chức năng "trợ giúp" (chẳng hạn như
ZZ0002ZZ).  Hàm kernel này sau đó có thể được gọi trong
sơ khai syscall (ZZ0003ZZ), sơ khai syscall tương thích
(ZZ0004ZZ) và/hoặc mã hạt nhân khác.

Ít nhất là trên x86 64-bit sẽ là yêu cầu khó từ v4.17 trở đi
gọi các hàm gọi hệ thống trong kernel.  Nó sử dụng một cách gọi khác
quy ước cho các cuộc gọi hệ thống trong đó ZZ0000ZZ được giải mã nhanh chóng trong một
trình bao bọc syscall, sau đó xử lý chức năng syscall thực tế.
Điều này có nghĩa là chỉ những tham số thực sự cần thiết cho một mục đích cụ thể
syscall được chuyển đi trong quá trình nhập syscall, thay vì điền vào sáu CPU
đăng ký với nội dung không gian người dùng ngẫu nhiên mọi lúc (điều này có thể gây ra nghiêm trọng
rắc rối trong chuỗi cuộc gọi).

Hơn nữa, các quy tắc về cách truy cập dữ liệu có thể khác nhau giữa dữ liệu kernel và
dữ liệu người dùng.  Đây là một lý do khác tại sao việc gọi ZZ0000ZZ thường là một
ý tưởng tồi.

Các ngoại lệ đối với quy tắc này chỉ được phép trong các ghi đè dành riêng cho kiến trúc,
các trình bao bọc tương thích dành riêng cho kiến trúc hoặc mã khác trong Arch/.


Tài liệu tham khảo và nguồn
---------------------------

- Bài viết LWN của Michael Kerrisk về việc sử dụng đối số cờ trong lệnh gọi hệ thống:
   ZZ0000ZZ
 - Bài viết LWN của Michael Kerrisk về cách xử lý các cờ không xác định trong hệ thống
   gọi: ZZ0001ZZ
 - Bài viết LWN từ Jake Edge mô tả các ràng buộc đối với lệnh gọi hệ thống 64-bit
   đối số: ZZ0002ZZ
 - Cặp bài viết LWN của David Drysdale mô tả cuộc gọi hệ thống
   đường dẫn triển khai chi tiết cho v3.14:

-ZZ0000ZZ
    -ZZ0001ZZ

- Các yêu cầu cụ thể về kiến trúc cho cuộc gọi hệ thống được thảo luận trong phần
   Trang người dùng ZZ0000ZZ:
   ZZ0003ZZ
 - Các email đối chiếu từ Linus Torvalds thảo luận về các vấn đề với ZZ0002ZZ:
   ZZ0004ZZ
 - "Làm thế nào để không phát minh ra giao diện kernel", Arnd Bergmann,
   ZZ0005ZZ
 - Bài viết LWN của Michael Kerrisk về việc tránh sử dụng CAP_SYS_ADMIN mới:
   ZZ0006ZZ
 - Khuyến nghị từ Andrew Morton rằng tất cả các thông tin liên quan cho một phiên bản mới
   cuộc gọi hệ thống sẽ đến trong cùng một chuỗi email:
   ZZ0007ZZ
 - Khuyến nghị từ Michael Kerrisk rằng nên thực hiện cuộc gọi hệ thống mới
   một trang nam: ZZ0008ZZ
 - Đề xuất của Thomas Gleixner rằng việc kết nối x86 nên ở một nơi riêng biệt
   cam kết: ZZ0009ZZ
 - Đề xuất từ Greg Kroah-Hartman rằng điều đó tốt cho các cuộc gọi hệ thống mới tới
   đi kèm với man-page & selftest: ZZ0010ZZ
 - Thảo luận từ Michael Kerrisk về lệnh gọi hệ thống mới so với tiện ích mở rộng ZZ0001ZZ:
   ZZ0011ZZ
 - Đề xuất từ Ingo Molnar rằng các lệnh gọi hệ thống liên quan đến nhiều
   các đối số nên gói gọn các đối số đó trong một cấu trúc, bao gồm một
   trường kích thước để mở rộng trong tương lai: ZZ0012ZZ
 - Đánh số lẻ phát sinh từ việc sử dụng (tái) các cờ cách đánh số O_*:

- cam kết 75069f2b5bfb ("vfs: đánh số lại FMODE_NONOTIFY và thêm vào tính duy nhất
      kiểm tra")
    - cam kết 12ed2e36c98a ("fanotify: FMODE_NONOTIFY và __O_SYNC trong sparc
      xung đột")
    - cam kết bb458c644a59 ("ABI an toàn hơn cho O_TMPFILE")

- Thảo luận từ Matthew Wilcox về các hạn chế đối với đối số 64-bit:
   ZZ0000ZZ
 - Khuyến nghị từ Greg Kroah-Hartman rằng nên sử dụng những cờ chưa biết
   chính sách: ZZ0001ZZ
 - Khuyến nghị từ Linus Torvalds rằng các cuộc gọi hệ thống x32 nên ưu tiên
   khả năng tương thích với các phiên bản 64 bit thay vì phiên bản 32 bit:
   ZZ0002ZZ
 - Chuỗi bản vá sửa đổi cơ sở hạ tầng bảng gọi hệ thống để sử dụng
   scripts/syscall.tbl trên nhiều kiến trúc:
   ZZ0003ZZ
