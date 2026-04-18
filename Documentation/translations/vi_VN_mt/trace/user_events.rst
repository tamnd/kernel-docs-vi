.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/user_events.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================================
user_events: Theo dõi sự kiện dựa trên người dùng
=================================================

:Tác giả: Beau Belgrave

Tổng quan
--------
Sự kiện theo dõi dựa trên người dùng cho phép quy trình của người dùng tạo sự kiện và theo dõi dữ liệu
có thể được xem thông qua các công cụ hiện có, chẳng hạn như ftrace và perf.
Để kích hoạt tính năng này, hãy xây dựng kernel của bạn với CONFIG_USER_EVENTS=y.

Các chương trình có thể xem trạng thái của các sự kiện thông qua
/sys/kernel/tracing/user_events_status và có thể đăng ký và ghi
dữ liệu ra qua /sys/kernel/tracing/user_events_data.

Các chương trình cũng có thể sử dụng /sys/kernel/tracing/dynamic_events để đăng ký và
xóa các sự kiện dựa trên người dùng thông qua tiền tố u:. Định dạng của lệnh để
Dynamic_events giống như ioctl với tiền tố u: được áp dụng. Cái này
yêu cầu CAP_PERFMON do sự kiện vẫn tiếp diễn, nếu không -EPERM sẽ được trả về.

Thông thường các chương trình sẽ đăng ký một tập hợp các sự kiện mà chúng muốn hiển thị.
các công cụ có thể đọc trace_events (chẳng hạn như ftrace và perf). Việc đăng ký
quy trình cho hạt nhân biết địa chỉ và bit nào sẽ phản ánh nếu có bất kỳ công cụ nào có
đã kích hoạt sự kiện và dữ liệu sẽ được ghi. Việc đăng ký sẽ trả lại
chỉ mục ghi mô tả dữ liệu khi lệnh write() hoặc writev() được gọi
trên tệp /sys/kernel/tracing/user_events_data.

Các cấu trúc được tham chiếu trong tài liệu này được chứa trong
/include/uapi/linux/user_events.h trong cây nguồn.

ZZ0000ZZ *Cả user_events_status và user_events_data đều nằm trong dấu vết
hệ thống tập tin và có thể được gắn ở các đường dẫn khác với đường dẫn trên.*

Đăng ký
-----------
Việc đăng ký trong quy trình người dùng được thực hiện thông qua ioctl() tới
Tệp /sys/kernel/tracing/user_events_data. Lệnh được đưa ra là
DIAG_IOCSREG.

Lệnh này lấy một cấu trúc user_reg được đóng gói làm đối số::

cấu trúc user_reg {
        /* Đầu vào: Kích thước của cấu trúc user_reg đang được sử dụng */
        __u32 kích thước;

/* Đầu vào: Bit trong địa chỉ cho phép sử dụng */
        __u8 kích hoạt_bit;

/* Đầu vào: Kích hoạt kích thước tính theo byte tại địa chỉ */
        __u8 kích hoạt_size;

/* Đầu vào: Các cờ sẽ sử dụng, nếu có */
        __u16 lá cờ;

/* Đầu vào: Địa chỉ cần cập nhật khi được bật */
        __u64 kích hoạt_addr;

/* Đầu vào: Con trỏ tới chuỗi có tên sự kiện, mô tả và cờ */
        __u64 tên_args;

/* Output: Chỉ mục của sự kiện sử dụng khi ghi dữ liệu */
        __u32 write_index;
  } __thuộc tính__((__ được đóng gói__));

Cấu trúc user_reg yêu cầu tất cả các đầu vào ở trên phải được đặt phù hợp.

+ size: Cái này phải được đặt thành sizeof(struct user_reg).

+ Enable_bit: Bit phản ánh trạng thái sự kiện tại địa chỉ được chỉ định bởi
  kích hoạt_addr.

+ Enable_size: Kích thước của giá trị được chỉ định bởi Enable_addr.
  Đây phải là 4 (32-bit) hoặc 8 (64-bit). Giá trị 64-bit chỉ được phép
  được sử dụng trên hạt nhân 64-bit, tuy nhiên, 32-bit có thể được sử dụng trên tất cả các hạt nhân.

+ flags: Các cờ sử dụng nếu có.
  Người gọi trước tiên nên thử sử dụng cờ và thử lại mà không có cờ để đảm bảo
  hỗ trợ cho các phiên bản kernel thấp hơn. Nếu cờ không được hỗ trợ -EINVAL
  được trả lại.

+ Enable_addr: Địa chỉ của giá trị dùng để phản ánh trạng thái sự kiện. Cái này
  phải được căn chỉnh tự nhiên và có thể ghi được trong chương trình người dùng.

+ name_args: Tên và đối số mô tả sự kiện, xem dạng lệnh
  để biết chi tiết.

Các cờ sau hiện được hỗ trợ.

+ USER_EVENT_REG_PERSIST: Sự kiện sẽ không bị xóa ở lần tham chiếu cuối cùng
  đóng cửa. Người gọi có thể sử dụng điều này nếu một sự kiện vẫn tồn tại ngay cả sau khi
  quá trình đóng hoặc hủy đăng ký sự kiện. Yêu cầu CAP_PERFMON nếu không
  -EPERM được trả lại.

+ USER_EVENT_REG_MULTI_FORMAT: Sự kiện có thể chứa nhiều định dạng. Cái này
  cho phép các chương trình tránh bị chặn khi sự kiện của chúng
  thay đổi định dạng và họ muốn sử dụng cùng một tên. Khi cờ này được sử dụng
  Tên tracepoint sẽ có định dạng mới là "name.unique_id" so với định dạng cũ hơn
  dạng "tên". Một điểm theo dõi sẽ được tạo cho mỗi cặp tên duy nhất
  và định dạng. Điều này có nghĩa là nếu một số tiến trình sử dụng cùng tên và định dạng,
  họ sẽ sử dụng cùng một điểm theo dõi. Nếu có một tiến trình khác sử dụng cùng tên,
  nhưng có định dạng khác với các quy trình khác, nó sẽ sử dụng một quy trình khác
  tracepoint với một id duy nhất mới. Các chương trình ghi cần quét dấu vết để tìm
  các định dạng khác nhau của tên sự kiện mà họ quan tâm
  ghi âm. Tên hệ thống của điểm theo dõi cũng sẽ sử dụng "user_events_multi"
  thay vì "user_event". Điều này ngăn xung đột tên sự kiện định dạng đơn
  với bất kỳ tên sự kiện đa định dạng nào trong tracefs. Unique_id được xuất ra dưới dạng
  một chuỗi hex. Các chương trình ghi phải đảm bảo tên dấu vết bắt đầu bằng
  tên sự kiện họ đã đăng ký và có hậu tố bắt đầu bằng . và chỉ
  có ký tự hex. Ví dụ để tìm tất cả các phiên bản của sự kiện "kiểm tra" bạn
  có thể sử dụng biểu thức chính quy "^test\.[0-9a-fA-F]+$".

Sau khi đăng ký thành công, thông tin sau sẽ được thiết lập.

+ write_index: Chỉ mục sử dụng cho file mô tả này
  sự kiện khi ghi dữ liệu. Chỉ mục này là duy nhất cho phiên bản này của tệp
  mô tả đã được sử dụng để đăng ký. Xem dữ liệu ghi để biết chi tiết.

Các sự kiện dựa trên người dùng hiển thị dưới dấu vết giống như bất kỳ sự kiện nào khác trong
hệ thống con có tên "user_events". Điều này có nghĩa là các công cụ muốn gắn vào
các sự kiện cần sử dụng /sys/kernel/tracing/events/user_events/[name]/enable
hoặc perf record -e user_events:[name] khi đính kèm/ghi.

ZZ0000ZZ Tên hệ thống con sự kiện theo mặc định là "user_events". Người gọi nên
không cho rằng nó sẽ luôn là "user_events". Các nhà khai thác có quyền trong
trong tương lai để thay đổi tên hệ thống con trên mỗi quy trình để phù hợp với sự cô lập sự kiện.
Ngoài ra, nếu cờ USER_EVENT_REG_MULTI_FORMAT được sử dụng thì tên điểm theo dõi
sẽ có một id duy nhất được gắn vào nó và tên hệ thống sẽ là
"user_events_multi" như được mô tả ở trên.

Định dạng lệnh
^^^^^^^^^^^^^^
Định dạng chuỗi lệnh như sau::

name[:FLAG1[,FLAG2...]] [Field1[;Field2...]]

Cờ được hỗ trợ
^^^^^^^^^^^^^^^
Chưa có

Định dạng trường
^^^^^^^^^^^^
::

tên loại [kích thước]

Các loại cơ bản được hỗ trợ (__data_loc, u32, u64, int, char, char[20], v.v.).
Các chương trình người dùng được khuyến khích sử dụng các loại có kích thước rõ ràng như u32.

ZZ0000ZZ ZZ0001ZZ

Kích thước chỉ hợp lệ cho các loại bắt đầu bằng tiền tố cấu trúc.
Điều này cho phép các chương trình người dùng mô tả các cấu trúc tùy chỉnh cho các công cụ, nếu được yêu cầu.

Ví dụ: một cấu trúc trong C trông như thế này::

cấu trúc mytype {
    dữ liệu char[20];
  };

Sẽ được đại diện bởi trường sau::

cấu trúc mytype tên tôi 20

Đang xóa
--------
Việc xóa một sự kiện từ bên trong quy trình người dùng được thực hiện thông qua ioctl() ra
Tệp /sys/kernel/tracing/user_events_data. Lệnh được đưa ra là
DIAG_IOCSDEL.

Lệnh này chỉ yêu cầu một chuỗi xác định sự kiện cần xóa bằng
tên của nó. Xóa sẽ chỉ thành công nếu không còn tài liệu tham khảo nào cho
sự kiện (trong cả không gian người dùng và kernel). Chương trình người dùng nên sử dụng một tệp riêng biệt
để yêu cầu xóa hơn cái được sử dụng để đăng ký do điều này.

ZZ0000ZZ Theo mặc định, các sự kiện sẽ tự động xóa khi không còn tài liệu tham khảo nào
đến sự kiện. Nếu chương trình không muốn tự động xóa thì phải sử dụng
Cờ USER_EVENT_REG_PERSIST khi đăng ký sự kiện. Khi cờ đó được sử dụng
sự kiện tồn tại cho đến khi DIAG_IOCSDEL được gọi. Cả đăng ký và xóa một
sự kiện vẫn tiếp diễn yêu cầu CAP_PERFMON, nếu không -EPERM sẽ được trả về. Khi nào
có nhiều định dạng của cùng một tên sự kiện, tất cả các sự kiện có cùng tên
tên sẽ được cố gắng xóa. Nếu chỉ muốn một phiên bản cụ thể
bị xóa thì tệp /sys/kernel/tracing/dynamic_events sẽ được sử dụng cho
định dạng cụ thể của sự kiện.

Hủy đăng ký
-------------
Nếu sau khi đăng ký một sự kiện, nó không còn muốn được cập nhật nữa thì nó có thể
bị vô hiệu hóa thông qua ioctl() đối với tệp /sys/kernel/tracing/user_events_data.
Lệnh phát hành là DIAG_IOCSUNREG. Điều này khác với việc xóa, trong đó
việc xóa thực sự sẽ xóa sự kiện khỏi hệ thống. Việc hủy đăng ký chỉ đơn giản là nói
kernel, quy trình của bạn không còn quan tâm đến các bản cập nhật cho sự kiện.

Lệnh này lấy một cấu trúc user_unreg được đóng gói làm đối số::

cấu trúc user_unreg {
        /* Đầu vào: Kích thước của cấu trúc user_unreg đang được sử dụng */
        __u32 kích thước;

/* Đầu vào: Bit để hủy đăng ký */
        __u8 vô hiệu hóa_bit;

/* Đầu vào: Dự trữ, đặt thành 0 */
        __u8 __bảo lưu;

/* Đầu vào: Dự trữ, đặt thành 0 */
        __u16 __reserved2;

/* Đầu vào: Địa chỉ hủy đăng ký */
        __u64 vô hiệu hóa_addr;
  } __thuộc tính__((__ được đóng gói__));

Cấu trúc user_unreg yêu cầu tất cả các đầu vào ở trên phải được đặt phù hợp.

+ size: Cái này phải được đặt thành sizeof(struct user_unreg).

+ vô hiệu hóa_bit: Cái này phải được đặt thành bit để tắt (giống bit đó
  đã đăng ký trước đó qua Enable_bit).

+vô hiệu hóa_addr: Địa chỉ này phải được đặt thành địa chỉ cần tắt (cùng địa chỉ đã được
  đã đăng ký trước đó qua Enable_addr).

Sự kiện ZZ0000ZZ được tự động hủy đăng ký khi execve() được gọi. Trong thời gian
fork() các sự kiện đã đăng ký sẽ được giữ lại và phải được hủy đăng ký theo cách thủ công
trong mỗi quá trình nếu muốn.

Trạng thái
------
Khi các công cụ đính kèm/ghi lại các sự kiện dựa trên người dùng, trạng thái của sự kiện sẽ được cập nhật
trong thời gian thực. Điều này cho phép các chương trình của người dùng chỉ phải chịu chi phí ghi() hoặc
writev() gọi khi có thứ gì đó được tích cực gắn vào sự kiện.

Hạt nhân sẽ cập nhật bit đã chỉ định đã được đăng ký cho sự kiện dưới dạng
công cụ đính kèm/tách khỏi sự kiện. Các chương trình người dùng chỉ cần kiểm tra xem bit đã được đặt chưa
để xem có cái gì được gắn vào hay không.

Quản trị viên có thể dễ dàng kiểm tra trạng thái của tất cả các sự kiện đã đăng ký bằng cách đọc
tệp user_events_status trực tiếp qua thiết bị đầu cuối. Đầu ra như sau::

Tên [# Comments]
  ...

Đang hoạt động: ActiveCount
  Bận: Bận đếm

Ví dụ: trên hệ thống có một sự kiện duy nhất, kết quả đầu ra trông như thế này::

Bài kiểm tra

Đang hoạt động: 1
  Bận: 0

Nếu người dùng kích hoạt sự kiện người dùng thông qua ftrace, thì kết quả đầu ra sẽ thay đổi thành thế này::

kiểm tra # Used bằng ftrace

Đang hoạt động: 1
  Bận: 1

Viết dữ liệu
------------
Sau khi đăng ký một sự kiện, có thể sử dụng cùng một fd đã được sử dụng để đăng ký
để viết một mục cho sự kiện đó. write_index được trả về phải ở đầu
của dữ liệu thì dữ liệu còn lại được coi là tải trọng của sự kiện.

Ví dụ: nếu write_index trả về là 1 và tôi muốn viết ra một int
tải trọng của sự kiện. Sau đó, dữ liệu sẽ phải có kích thước 8 byte (2 int),
với 4 byte đầu tiên bằng 1 và 4 byte cuối cùng bằng
giá trị tôi muốn làm tải trọng.

Trong bộ nhớ, nó sẽ trông như thế này::

chỉ số int;
  tải trọng int;

Các chương trình người dùng có thể có các cấu trúc nổi tiếng mà họ muốn sử dụng để phát ra
dưới dạng tải trọng. Trong những trường hợp đó, writev() có thể được sử dụng, với vectơ đầu tiên là
chỉ mục và (các) vectơ sau đây là tải trọng sự kiện thực tế.

Ví dụ: nếu tôi có cấu trúc như thế này ::

tải trọng cấu trúc {
        int src;
        int dst;
        cờ int;
  } __thuộc tính__((__ được đóng gói__));

Các chương trình người dùng nên làm như sau ::

cấu trúc iovec io[2];
  tải trọng cấu trúc e;

io[0].iov_base = &write_index;
  io[0].iov_len = sizeof(write_index);
  io[1].iov_base = &e;
  io[1].iov_len = sizeof(e);

writev(fd, (const struct iovec*)io, 2);

ZZ0000ZZ ZZ0001ZZ

Mã ví dụ
------------
Xem mã mẫu trong samples/user_events.
