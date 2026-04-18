.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/kprobetrace.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
Theo dõi sự kiện dựa trên Kprobe
==========================

:Tác giả: Masami Hiramatsu

Tổng quan
--------
Những sự kiện này tương tự như các sự kiện dựa trên tracepoint. Thay vì dấu vết,
điều này dựa trên kprobes (kprobe và kretprobe). Vì vậy nó có thể thăm dò bất cứ nơi nào
kprobes có thể thăm dò (điều này có nghĩa là tất cả các chức năng ngoại trừ những chức năng có
__kprobes/nokprobe_inline chú thích và những chú thích được đánh dấu NOKPROBE_SYMBOL).
Không giống như sự kiện dựa trên dấu vết, sự kiện này có thể được thêm và xóa
một cách năng động, nhanh chóng.

Để kích hoạt tính năng này, hãy xây dựng kernel của bạn với CONFIG_KPROBE_EVENTS=y.

Tương tự như trình theo dõi sự kiện, tính năng này không cần phải được kích hoạt thông qua
current_tracer. Thay vào đó, hãy thêm điểm thăm dò thông qua
/sys/kernel/tracing/kprobe_events và kích hoạt nó thông qua
/sys/kernel/tracing/events/kprobes/<EVENT>/enable.

Bạn cũng có thể sử dụng /sys/kernel/tracing/dynamic_events thay vì
kprobe_events. Giao diện đó sẽ cung cấp quyền truy cập thống nhất vào các
sự kiện năng động quá.

Tóm tắt của kprobe_events
-------------------------
::

p[:[GRP/][EVENT]] [MOD:]SYM[+offs]|MEMADDR [FETCHARGS] : Đặt đầu dò
  r[MAXACTIVE][:[GRP/][EVENT]] [MOD:]SYM[+0] [FETCHARGS] : Đặt đầu dò quay trở lại
  p[:[GRP/][EVENT]] [MOD:]SYM[+0]%return [FETCHARGS] : Đặt đầu dò quay trở lại
  -:[GRP/][EVENT] : Xóa đầu dò

GRP : Tên nhóm. Nếu bị bỏ qua, hãy sử dụng "kprobes" cho nó.
 EVENT : Tên sự kiện. Nếu bị bỏ qua, tên sự kiện sẽ được tạo
		  dựa trên SYM+off hoặc MEMADDR.
 MOD : Tên mô-đun đã đặt cho SYM.
 SYM[+offs] : Ký hiệu+độ lệch nơi đầu dò được lắp vào.
 SYM%return : Địa chỉ trả về của biểu tượng
 MEMADDR : Địa chỉ nơi cắm đầu dò.
 MAXACTIVE : Số phiên bản tối đa của hàm được chỉ định
		  có thể được thăm dò đồng thời hoặc 0 cho giá trị mặc định
		  như được định nghĩa trong Tài liệu/trace/kprobes.rst phần 1.3.1.

FETCHARGS : Đối số. Mỗi đầu dò có thể có tới 128 đối số.
  %REG : Tìm nạp thanh ghi REG
  @ADDR : Tìm nạp bộ nhớ tại ADDR (ADDR phải có trong kernel)
  @SYM[+ZZ0001ZZ- tắt (SYM phải là ký hiệu dữ liệu)
  $stackN : Tìm nạp mục nhập thứ N của ngăn xếp (N >= 0)
  $stack : Lấy địa chỉ ngăn xếp.
  $argN : Tìm nạp đối số hàm thứ N. (N >= 1) (\*1)
  $retval : Tìm nạp giá trị trả về.(\*2)
  $comm : Tìm nạp nhiệm vụ hiện tại comm.
  +ZZ0002ZZ- Địa chỉ OFFS.(\ZZ0000ZZ4)
  \IMM : Lưu trữ giá trị ngay lập tức cho đối số.
  NAME=FETCHARG : Đặt NAME làm tên đối số của FETCHARG.
  FETCHARG:TYPE : Đặt TYPE làm loại FETCHARG. Hiện nay, các loại cơ bản
		  (u8/u16/u32/u64/s8/s16/s32/s64), loại thập lục phân
		  (x8/x16/x32/x64), loại phổ biến của lớp VFS(%pd/%pD), "char",
                  "chuỗi", "ustring", "biểu tượng", "symstr" và bitfield là
                  được hỗ trợ.

(\*1) chỉ dành cho thăm dò khi nhập hàm (tắt == 0). Lưu ý, quyền truy cập đối số này
        là nỗ lực tốt nhất, vì tùy thuộc vào loại đối số, nó có thể được chuyển tiếp
        ngăn xếp. Nhưng điều này chỉ hỗ trợ các đối số thông qua sổ đăng ký.
  (\*2) chỉ dành cho thăm dò trở lại. Lưu ý rằng đây cũng là nỗ lực tốt nhất. Tùy thuộc vào
        kiểu giá trị trả về, nó có thể được truyền qua một cặp thanh ghi. Nhưng điều này chỉ
        truy cập vào một thanh ghi.
  (\*3) điều này rất hữu ích để tìm nạp một trường cấu trúc dữ liệu.
  (\*4) "u" có nghĩa là vô hiệu hóa không gian người dùng. Xem ZZ0000ZZ.

Đối số hàm tại kretprobe
-------------------------------
Các đối số của hàm có thể được truy cập tại kretprobe bằng cách sử dụng $arg<N>fetcharg. Cái này
rất hữu ích để ghi lại tham số hàm và giá trị trả về cùng một lúc, và
theo dõi sự khác biệt của các trường cấu trúc (để gỡ lỗi một hàm cho dù nó
có cập nhật chính xác cấu trúc dữ liệu đã cho hay không).
Xem ZZ0000ZZ trong sự kiện fprobe để biết cách thực hiện
nó hoạt động.

.. _kprobetrace_types:

Các loại
-----
Một số loại được hỗ trợ cho tìm nạp. Trình theo dõi Kprobe sẽ truy cập bộ nhớ
theo loại nhất định. Tiền tố 's' và 'u' có nghĩa là các loại đó được ký và không dấu
tương ứng. Tiền tố 'x' ngụ ý nó không được ký. Đối số theo dõi được hiển thị
ở dạng thập phân ('s' và 'u') hoặc thập lục phân ('x'). Không truyền kiểu, 'x32'
hoặc 'x64' được sử dụng tùy thuộc vào kiến trúc (ví dụ: x86-32 sử dụng x32 và
x86-64 sử dụng x64).

Các loại giá trị này có thể là một mảng. Để ghi dữ liệu mảng, bạn có thể thêm '[N]'
(trong đó N là số cố định, nhỏ hơn 64) cho loại cơ sở.
Ví dụ. 'x16[4]' có nghĩa là mảng x16 (hex 2 byte) có 4 phần tử.
Lưu ý rằng mảng có thể được áp dụng cho các bộ tìm nạp kiểu bộ nhớ, bạn không thể
áp dụng nó cho các thanh ghi/mục ngăn xếp, v.v. (ví dụ: '$stack1:x8[8]' là
sai, nhưng '+8($stack):x8[8]' vẫn ổn.)

Kiểu char có thể được sử dụng để hiển thị giá trị ký tự của các đối số được theo dõi.

Loại chuỗi là loại đặc biệt, tìm nạp chuỗi "kết thúc null" từ
không gian hạt nhân. Điều này có nghĩa là nó sẽ bị lỗi và lưu trữ NULL nếu vùng chứa chuỗi
đã được phân trang ra. Loại "ustring" là một dạng thay thế của chuỗi cho không gian người dùng.
Xem ZZ0000ZZ để biết thêm thông tin.

Kiểu mảng chuỗi hơi khác một chút so với các kiểu khác. Đối với cơ sở khác
các loại, <base-type>[1] bằng <base-type> (ví dụ: +0(%di):x32[1] giống nhau
as +0(%di):x32.) Nhưng chuỗi[1] không bằng chuỗi. Chính kiểu chuỗi
đại diện cho "mảng char", nhưng kiểu mảng chuỗi đại diện cho "mảng char *".
Vì vậy, ví dụ, +0(%di):string[1] bằng +0(+0(%di)):string.
Bitfield là một loại đặc biệt khác, có 3 tham số, độ rộng bit, bit-
offset và kích thước vùng chứa (thường là 32). Cú pháp là::

b<bit-width>@<bit-offset>/<container-size>

Loại biểu tượng('symbol') là bí danh của loại u32 hoặc u64 (tùy thuộc vào BITS_PER_LONG)
hiển thị con trỏ đã cho theo kiểu "ký hiệu + offset".
Mặt khác, loại chuỗi ký hiệu ('symstr') chuyển đổi địa chỉ đã cho thành
kiểu "symbol+offset/symbolsize" và lưu nó dưới dạng chuỗi kết thúc null.
Với loại 'symstr', bạn có thể lọc sự kiện bằng mẫu ký tự đại diện của
các ký hiệu và bạn không cần phải tự mình giải tên ký hiệu.
Đối với $comm, loại mặc định là "chuỗi"; bất kỳ loại nào khác là không hợp lệ.

Loại phổ biến của lớp VFS (%pd/%pD) là loại đặc biệt, lấy dữ liệu của nha khoa hoặc
tên tệp từ địa chỉ của struct dentry hoặc địa chỉ của tệp struct.

.. _user_mem_access:

Truy cập bộ nhớ người dùng
------------------
Sự kiện Kprobe hỗ trợ truy cập bộ nhớ không gian người dùng. Với mục đích đó, bạn có thể sử dụng
cú pháp quy định không gian người dùng hoặc loại 'ustring'.

Cú pháp quy định không gian người dùng cho phép bạn truy cập vào một trường dữ liệu
cấu trúc trong không gian người dùng. Điều này được thực hiện bằng cách thêm tiền tố "u" vào
cú pháp dereference. Ví dụ: +u4(%si) có nghĩa là nó sẽ đọc bộ nhớ từ
địa chỉ trong thanh ghi %si được bù bằng 4 và bộ nhớ dự kiến sẽ ở
không gian người dùng. Bạn cũng có thể sử dụng điều này cho các chuỗi, ví dụ: +u0(%si):chuỗi sẽ đọc
một chuỗi từ địa chỉ trong sổ đăng ký %si dự kiến sẽ có trong user-
không gian. 'ustring' là một cách tắt để thực hiện cùng một tác vụ. Đó là,
+0(%si):ustring tương đương với +u0(%si):string.

Lưu ý rằng kprobe-event cung cấp cú pháp truy cập bộ nhớ người dùng nhưng không
sử dụng nó một cách minh bạch. Điều này có nghĩa là nếu bạn sử dụng loại tham chiếu hoặc loại chuỗi thông thường
đối với bộ nhớ người dùng, nó có thể bị lỗi và có thể luôn bị lỗi trên một số kiến trúc. các
người dùng phải kiểm tra cẩn thận xem dữ liệu đích có nằm trong kernel hay không gian người dùng hay không.

Lọc sự kiện trên mỗi đầu dò
-------------------------
Tính năng lọc sự kiện trên mỗi đầu dò cho phép bạn đặt các bộ lọc khác nhau trên mỗi đầu dò
thăm dò và cung cấp cho bạn những đối số nào sẽ được hiển thị trong bộ đệm theo dõi. Nếu một sự kiện
tên được chỉ định ngay sau 'p:' hoặc 'r:' trong kprobe_events, nó sẽ thêm một sự kiện
trong tracing/events/kprobes/<EVENT>, tại thư mục bạn có thể thấy 'id',
'bật', 'định dạng', 'bộ lọc' và 'kích hoạt'.

kích hoạt:
  Bạn có thể bật/tắt đầu dò bằng cách viết số 1 hoặc 0 lên đó.

định dạng:
  Điều này cho thấy định dạng của sự kiện thăm dò này.

bộ lọc:
  Bạn có thể viết quy tắc lọc của sự kiện này.

mã số:
  Điều này hiển thị id của sự kiện thăm dò này.

kích hoạt:
  Điều này cho phép cài đặt các lệnh kích hoạt được thực thi khi sự kiện diễn ra.
  nhấn (để biết chi tiết, xem Tài liệu/trace/events.rst, phần 6).

Hồ sơ sự kiện
---------------
Bạn có thể kiểm tra tổng số lần truy cập thăm dò và thăm dò số lần truy cập sai thông qua
/sys/kernel/tracing/kprobe_profile.
Cột đầu tiên là tên sự kiện, cột thứ hai là số lần truy cập thăm dò,
thứ ba là số lần truy cập sai của thăm dò.

Tham số khởi động hạt nhân
---------------------
Bạn có thể thêm và kích hoạt các sự kiện kprobe mới khi khởi động kernel bằng cách
tham số "kprobe_event=". Tham số chấp nhận phân cách bằng dấu chấm phẩy
sự kiện kprobe, có định dạng tương tự như kprobe_events.
Sự khác biệt là các tham số định nghĩa thăm dò được phân cách bằng dấu phẩy
thay vì không gian. Ví dụ: thêm sự kiện myprobe trên do_sys_open như bên dưới ::

p:myprobe do_sys_open dfd=%ax filename=%dx flags=%cx mode=+4($stack)

phải ở bên dưới cho tham số khởi động kernel (chỉ cần thay thế dấu cách bằng dấu phẩy)::

p:myprobe,do_sys_open,dfd=%ax,filename=%dx,flags=%cx,mode=+4($stack)


Ví dụ sử dụng
--------------
Để thêm một thăm dò làm sự kiện mới, hãy viết định nghĩa mới vào kprobe_events
như dưới đây::

echo 'p:myprobe do_sys_open dfd=%ax filename=%dx flags=%cx mode=+4($stack)' > /sys/kernel/tracing/kprobe_events

Điều này đặt một kprobe lên trên cùng của hàm do_sys_open() với chức năng ghi
Đối số thứ 1 đến thứ 4 là sự kiện "myprobe". Lưu ý, mục đăng ký/ngăn xếp nào là
được gán cho từng đối số hàm phụ thuộc vào ABI dành riêng cho vòm. Nếu bạn không chắc chắn
ABI, vui lòng thử sử dụng lệnh con thăm dò của perf-tools (bạn có thể tìm thấy nó
trong công cụ/perf/).
Như ví dụ này cho thấy, người dùng có thể chọn những tên quen thuộc hơn cho mỗi đối số.
::

echo 'r:myretprobe do_sys_open $retval' >> /sys/kernel/tracing/kprobe_events

Điều này đặt một kretprobe về điểm trả về của hàm do_sys_open() với
ghi lại giá trị trả về dưới dạng sự kiện "myretprobe".
Bạn có thể xem định dạng của các sự kiện này thông qua
/sys/kernel/tracing/events/kprobes/<EVENT>/format.
::

cat /sys/kernel/tracing/events/kprobes/myprobe/format
  Tên: myprobe
  Mã số: 780
  định dạng:
          trường:unsigned short common_type;       bù đắp: 0;       kích thước:2; đã ký: 0;
          trường: char không dấu common_flags;       bù đắp:2;       kích thước: 1; đã ký: 0;
          trường: char không dấu common_preempt_count;       bù đắp:3; kích thước:1;đã ký:0;
          trường:int common_pid;   bù đắp:4;       kích thước:4; đã ký: 1;

trường:không dấu dài __probe_ip; bù đắp:12;      kích thước:4; đã ký: 0;
          trường:int __probe_nargs;        bù đắp:16;      kích thước:4; đã ký: 1;
          trường:dfd dài không dấu;        bù đắp:20;      kích thước:4; đã ký: 0;
          trường:tên tệp dài không dấu;   bù đắp:24;      kích thước:4; đã ký: 0;
          trường:cờ dài không dấu;      bù đắp:28;      kích thước:4; đã ký: 0;
          trường:chế độ dài không dấu;       bù đắp:32;      kích thước:4; đã ký: 0;


print fmt: "(%lx) dfd=%lx filename=%lx flags=%lx mode=%lx", REC->__probe_ip,
  REC->dfd, REC->tên tệp, REC->cờ, REC->chế độ

Bạn có thể thấy rằng sự kiện này có 4 đối số như trong biểu thức bạn đã chỉ định.
::

echo > /sys/kernel/tracing/kprobe_events

Điều này xóa tất cả các điểm thăm dò.

Hoặc,
::

echo -:myprobe >> kprobe_events

Điều này xóa các điểm thăm dò một cách có chọn lọc.

Ngay sau khi định nghĩa, mỗi sự kiện sẽ bị tắt theo mặc định. Để theo dõi những điều này
sự kiện, bạn cần kích hoạt nó.
::

echo 1 > /sys/kernel/tracing/events/kprobes/myprobe/enable
  echo 1 > /sys/kernel/tracing/events/kprobes/myretprobe/enable

Sử dụng lệnh sau để bắt đầu theo dõi trong một khoảng thời gian.
::

# echo 1 > truy tìm_on
    Mở cái gì đó...
    # echo 0 > truy tìm_on

Và bạn có thể xem thông tin được theo dõi qua /sys/kernel/tracing/trace.
::

mèo /sys/kernel/truy tìm/dấu vết
  # tracer: không
  #
  #           ZZ0002ZZ-ZZ0003ZZ CPU#    ZZ0005ZZ FUNCTION
  #              ZZ0007ZZ ZZ0001ZZ |
             <...>-1447 [001] 1038282.286875: myprobe: (do_sys_open+0x0/0xd6) dfd=3 filename=7fffd1ec4440 flags=8000 mode=0
             <...>-1447 [001] 1038282.286878: myretprobe: (sys_openat+0xc/0xe <- do_sys_open) $retval=ffffffffffffffe
             <...>-1447 [001] 1038282.286885: myprobe: (do_sys_open+0x0/0xd6) dfd=ffffff9c filename=40413c flags=8000 mode=1b6
             <...>-1447 [001] 1038282.286915: myretprobe: (sys_open+0x1b/0x1d <- do_sys_open) $retval=3
             <...>-1447 [001] 1038282.286969: myprobe: (do_sys_open+0x0/0xd6) dfd=ffffff9c filename=4041c6 flags=98800 mode=10
             <...>-1447 [001] 1038282.286976: myretprobe: (sys_open+0x1b/0x1d <- do_sys_open) $retval=3


Mỗi dòng hiển thị khi kernel gặp một sự kiện và <- SYMBOL có nghĩa là kernel
trả về từ SYMBOL(ví dụ: "sys_open+0x1b/0x1d <- do_sys_open" nghĩa là kernel
trả về từ do_sys_open tới sys_open+0x1b).
