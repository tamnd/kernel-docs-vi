.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/ioctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================
giao diện dựa trên ioctl
========================

ioctl() là cách phổ biến nhất để các ứng dụng giao tiếp với nhau
với trình điều khiển thiết bị. Nó linh hoạt và dễ dàng mở rộng bằng cách thêm mới
lệnh và có thể được truyền qua các thiết bị ký tự, chặn các thiết bị như
cũng như các ổ cắm và các bộ mô tả tập tin đặc biệt khác.

Tuy nhiên, cũng rất dễ xảy ra sai sót trong định nghĩa lệnh ioctl,
và khó có thể sửa chúng sau này mà không làm hỏng các ứng dụng hiện có,
vì vậy tài liệu này cố gắng giúp các nhà phát triển làm đúng.

Định nghĩa số lệnh
==========================

Số lệnh hoặc số yêu cầu là đối số thứ hai được truyền cho
cuộc gọi hệ thống ioctl. Mặc dù đây có thể là bất kỳ số 32 bit nào duy nhất
xác định một hành động cho một trình điều khiển cụ thể, có một số
các quy ước xung quanh việc xác định chúng.

ZZ0000ZZ cung cấp bốn macro để xác định
các lệnh ioctl tuân theo các quy ước hiện đại: ZZ0001ZZ, ZZ0002ZZ,
ZZ0003ZZ và ZZ0004ZZ. Chúng nên được sử dụng cho tất cả các lệnh mới,
với các thông số chính xác:

_IO/_IOR/_IOW/_IOWR
   Tên macro chỉ định cách sử dụng đối số.  Nó có thể là một
   con trỏ tới dữ liệu được truyền vào kernel (_IOW), ra khỏi kernel
   (_IOR) hoặc cả hai (_IOWR).  _IO có thể chỉ ra một trong hai lệnh không có
   đối số hoặc những đối số truyền một giá trị số nguyên thay vì một con trỏ.
   Khuyến cáo chỉ nên sử dụng _IO cho các lệnh không có đối số,
   và sử dụng con trỏ để truyền dữ liệu.

loại
   Số 8 bit, thường là ký tự chữ, dành riêng cho hệ thống con
   hoặc trình điều khiển và được liệt kê trong Documentation/userspace-api/ioctl/ioctl-number.rst

nr
  Một số 8 bit xác định lệnh cụ thể, duy nhất cho lệnh đưa ra
  giá trị của 'loại'

kiểu dữ liệu
  Tên kiểu dữ liệu được đối số trỏ đến, số lệnh
  mã hóa giá trị ZZ0000ZZ theo số nguyên 13 bit hoặc 14 bit,
  dẫn đến giới hạn 8191 byte cho kích thước tối đa của đối số.
  Lưu ý: không chuyển loại sizeof(data_type) vào _IOR/_IOW/IOWR, vì điều đó
  sẽ dẫn đến mã hóa sizeof(sizeof(data_type)), tức là sizeof(size_t).
  _IO không có tham số data_type.


Phiên bản giao diện
==================

Một số hệ thống con sử dụng số phiên bản trong cấu trúc dữ liệu để gây quá tải
các mệnh lệnh với những cách giải thích khác nhau về đối số.

Nói chung đây là một ý tưởng tồi, vì những thay đổi đối với các lệnh hiện có có xu hướng
để phá vỡ các ứng dụng hiện có.

Cách tiếp cận tốt hơn là thêm lệnh ioctl mới với số mới. các
lệnh cũ vẫn cần được triển khai trong kernel để tương thích,
nhưng đây có thể là phần bao bọc xung quanh việc triển khai mới.

Mã trả lại
===========

lệnh ioctl có thể trả về mã lỗi âm như được ghi trong errno(3);
những giá trị này được chuyển thành giá trị sai sót trong không gian người dùng. Khi thành công, sự trở lại
mã phải bằng 0. Cũng có thể nhưng không nên quay lại
một giá trị 'dài' dương.

Khi lệnh gọi lại ioctl được gọi với số lệnh không xác định,
trình xử lý trả về -ENOTTY hoặc -ENOIOCTLCMD, điều này cũng dẫn đến
-ENOTTY được trả về từ cuộc gọi hệ thống. Một số hệ thống con trở lại
-ENOSYS hoặc -EINVAL ở đây vì lý do lịch sử, nhưng điều này sai.

Trước Linux 5.5, trình xử lý compat_ioctl bắt buộc phải trả về
-ENOIOCTLCMD để sử dụng chuyển đổi dự phòng thành gốc
lệnh. Vì tất cả các hệ thống con hiện chịu trách nhiệm xử lý tính tương thích
tự chế độ, điều này không còn cần thiết nữa, nhưng nó có thể quan trọng đối với
hãy cân nhắc khi chuyển các bản sửa lỗi sang các hạt nhân cũ hơn.

Dấu thời gian
==========

Theo truyền thống, dấu thời gian và giá trị thời gian chờ được chuyển dưới dạng ZZ0000ZZ hoặc ZZ0001ZZ, nhưng đây là vấn đề vì
định nghĩa không tương thích của các cấu trúc này trong không gian người dùng sau
chuyển sang time_t 64-bit.

Loại ZZ0000ZZ có thể được sử dụng thay thế để nhúng
trong các cấu trúc dữ liệu khác khi có các giá trị giây/nano giây riêng biệt
mong muốn hoặc được chuyển trực tiếp đến không gian người dùng. Tuy nhiên, điều này vẫn chưa lý tưởng,
vì cấu trúc không khớp với timespec64 của kernel cũng như người dùng
không gian thời gian chính xác. Trình trợ giúp get_timespec64() và put_timespec64()
các chức năng có thể được sử dụng để đảm bảo rằng bố cục vẫn tương thích với
không gian người dùng và phần đệm được xử lý chính xác.

Vì việc chuyển đổi giây thành nano giây thì rẻ, nhưng ngược lại
yêu cầu phân chia 64-bit đắt tiền, giá trị __u64 nano giây đơn giản
có thể đơn giản và hiệu quả hơn.

Các giá trị thời gian chờ và dấu thời gian lý tưởng nhất nên sử dụng thời gian CLOCK_MONOTONIC,
được trả về bởi ktime_get_ns() hoặc ktime_get_ts64().  Không giống
CLOCK_REALTIME, điều này làm cho dấu thời gian không bị nhảy lùi
hoặc chuyển tiếp do điều chỉnh giây nhuận và lệnh gọi clock_settime().

ktime_get_real_ns() có thể được sử dụng cho dấu thời gian CLOCK_REALTIME
cần phải liên tục trong quá trình khởi động lại hoặc giữa nhiều máy.

Chế độ tương thích 32-bit
==================

Để hỗ trợ không gian người dùng 32-bit chạy trên máy 64-bit, mỗi
hệ thống con hoặc trình điều khiển triển khai trình xử lý gọi lại ioctl cũng phải
triển khai trình xử lý compat_ioctl tương ứng.

Miễn là tất cả các quy tắc về cấu trúc dữ liệu được tuân theo, điều này giống như
dễ dàng như đặt con trỏ .compat_ioctl thành hàm trợ giúp, chẳng hạn như
compat_ptr_ioctl() hoặc blkdev_compat_ptr_ioctl().

compat_ptr()
------------

Trên kiến trúc s390, không gian người dùng 31 bit có các cách biểu diễn không rõ ràng
đối với con trỏ dữ liệu, bit trên bị bỏ qua. Khi chạy như vậy
một tiến trình ở chế độ tương thích, trình trợ giúp compat_ptr() phải được sử dụng để
xóa bit trên của compat_uptr_t và biến nó thành 64-bit hợp lệ
con trỏ.  Trên các kiến trúc khác, macro này chỉ thực hiện chuyển đổi thành một
Con trỏ ZZ0000ZZ.

Trong lệnh gọi lại compat_ioctl(), đối số cuối cùng là một giá trị dài không dấu,
có thể được hiểu là một con trỏ hoặc một đại lượng tùy thuộc vào
lệnh. Nếu nó là đại lượng vô hướng thì không được sử dụng compat_ptr() để
đảm bảo rằng kernel 64 bit hoạt động giống như kernel 32 bit
cho các đối số có tập bit trên.

Trình trợ giúp compat_ptr_ioctl() có thể được sử dụng thay cho tùy chỉnh
hoạt động của tệp compat_ioctl dành cho trình điều khiển chỉ nhận các đối số
là các con trỏ tới các cấu trúc dữ liệu tương thích.

Bố trí kết cấu
----------------

Các cấu trúc dữ liệu tương thích có cùng bố cục trên tất cả các kiến trúc,
tránh tất cả các thành viên có vấn đề:

* ZZ0000ZZ và ZZ0001ZZ có kích thước của một thanh ghi, vì vậy
  chúng có thể rộng 32-bit hoặc 64-bit và không thể được sử dụng trong thiết bị di động
  các cấu trúc dữ liệu. Các sản phẩm thay thế có độ dài cố định là ZZ0002ZZ, ZZ0003ZZ,
  ZZ0004ZZ và ZZ0005ZZ.

* Con trỏ cũng gặp vấn đề tương tự, ngoài việc yêu cầu
  sử dụng compat_ptr(). Cách giải quyết tốt nhất là sử dụng ZZ0000ZZ
  thay cho con trỏ, yêu cầu chuyển tới ZZ0001ZZ trong người dùng
  không gian và việc sử dụng u64_to_user_ptr() trong kernel để chuyển đổi
  nó trở lại thành một con trỏ người dùng.

* Trên kiến trúc x86-32 (i386), việc căn chỉnh các biến 64-bit
  chỉ 32-bit nhưng chúng được căn chỉnh tự nhiên trên hầu hết các phiên bản khác
  kiến trúc bao gồm x86-64. Điều này có nghĩa là một cấu trúc như::

cấu trúc foo {
        __u32 một;
        __u64 b;
        __u32 c;
    };

có bốn byte đệm giữa a và b trên x86-64, cộng thêm bốn byte nữa
  byte đệm ở cuối, nhưng không có đệm trên i386 và nó cần một
  trình xử lý chuyển đổi compat_ioctl để dịch giữa hai định dạng.

Để tránh vấn đề này, tất cả các cấu trúc nên có các thành viên
  các trường được căn chỉnh tự nhiên hoặc dành riêng rõ ràng được thêm vào thay cho
  phần đệm ngầm. Công cụ ZZ0000ZZ có thể được sử dụng để kiểm tra
  căn chỉnh.

* Trên không gian người dùng ARM OABI, các cấu trúc được đệm theo bội số của 32-bit,
  làm cho một số cấu trúc không tương thích với hạt nhân EABI hiện đại nếu chúng
  không kết thúc ở ranh giới 32 bit.

* Trên kiến trúc m68k, các thành viên cấu trúc không được đảm bảo có
  căn chỉnh lớn hơn 16-bit, đây là một vấn đề khi dựa vào
  phần đệm ngầm.

* Bitfield và enum thường hoạt động như người ta mong đợi,
  nhưng một số thuộc tính của chúng được xác định theo cách triển khai, vì vậy sẽ tốt hơn
  để tránh chúng hoàn toàn trong giao diện ioctl.

* Thành viên ZZ0000ZZ có thể được ký hoặc không ký, tùy thuộc vào
  kiến trúc, vì vậy nên sử dụng loại __u8 và __s8 cho 8-bit
  các giá trị số nguyên, mặc dù mảng char rõ ràng hơn đối với các chuỗi có độ dài cố định.

Rò rỉ thông tin
=================

Dữ liệu chưa được khởi tạo không được sao chép trở lại không gian người dùng, vì điều này có thể
gây rò rỉ thông tin, có thể được sử dụng để đánh bại địa chỉ kernel
ngẫu nhiên bố trí không gian (KASLR), giúp tấn công.

Vì lý do này (và để hỗ trợ tương thích), tốt nhất nên tránh mọi
phần đệm ngầm trong cấu trúc dữ liệu.  Nơi có phần đệm ngầm
trong cấu trúc hiện có, trình điều khiển hạt nhân phải cẩn thận để
khởi tạo một thể hiện của cấu trúc trước khi sao chép nó cho người dùng
không gian.  Điều này thường được thực hiện bằng cách gọi memset() trước khi gán cho
các thành viên cá nhân.

Trừu tượng hóa hệ thống con
======================

Trong khi một số trình điều khiển thiết bị triển khai chức năng ioctl của riêng chúng thì hầu hết
các hệ thống con thực hiện cùng một lệnh cho nhiều trình điều khiển.  Lý tưởng nhất là
hệ thống con có trình xử lý .ioctl() sao chép các đối số từ và
tới không gian người dùng, chuyển chúng vào các hàm gọi lại cụ thể của hệ thống con
thông qua các con trỏ hạt nhân thông thường.

Điều này giúp ích theo nhiều cách khác nhau:

* Các ứng dụng được viết cho một trình điều khiển có nhiều khả năng hoạt động hơn
  một cái khác trong cùng hệ thống con nếu không có sự khác biệt nhỏ
  trong không gian người dùng ABI.

* Sự phức tạp của việc truy cập không gian người dùng và bố cục cấu trúc dữ liệu đã được thực hiện
  ở một nơi, giảm khả năng xảy ra lỗi khi triển khai.

* Nó có nhiều khả năng được các nhà phát triển có kinh nghiệm xem xét hơn
  có thể phát hiện các vấn đề trong giao diện khi chia sẻ ioctl
  giữa nhiều trình điều khiển hơn là khi nó chỉ được sử dụng trong một trình điều khiển duy nhất.

Các lựa chọn thay thế cho ioctl
=====================

Có nhiều trường hợp ioctl không phải là giải pháp tốt nhất cho
vấn đề. Các lựa chọn thay thế bao gồm:

* Cuộc gọi hệ thống là lựa chọn tốt hơn cho tính năng toàn hệ thống
  không bị ràng buộc với thiết bị vật lý hoặc bị ràng buộc bởi hệ thống tệp
  quyền của nút thiết bị ký tự

* netlink là cách ưa thích để định cấu hình bất kỳ mạng nào liên quan
  các đối tượng thông qua các ổ cắm.

* debugfs được sử dụng cho các giao diện đặc biệt cho chức năng gỡ lỗi
  không cần phải thể hiện như một giao diện ổn định cho các ứng dụng.

* sysfs là một cách hay để hiển thị trạng thái của một đối tượng trong kernel
  nó không bị ràng buộc với một bộ mô tả tập tin.

* configfs có thể được sử dụng cho cấu hình phức tạp hơn sysfs

* Một hệ thống tệp tùy chỉnh có thể mang lại sự linh hoạt cao hơn với một thao tác đơn giản
  giao diện người dùng nhưng thêm rất nhiều sự phức tạp vào việc thực hiện.
