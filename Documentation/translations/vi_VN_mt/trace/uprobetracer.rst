.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/uprobetracer.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================================
Uprobe-tracer: Theo dõi sự kiện dựa trên Uprobe
=========================================

:Tác giả: Srikar Dronamraju


Tổng quan
--------
Các sự kiện theo dõi dựa trên Uprobe tương tự như các sự kiện theo dõi dựa trên kprobe.
Để kích hoạt tính năng này, hãy xây dựng kernel của bạn với CONFIG_UPROBE_EVENTS=y.

Tương tự như công cụ theo dõi sự kiện kprobe, tính năng này không cần phải được kích hoạt thông qua
current_tracer. Thay vào đó, hãy thêm điểm thăm dò thông qua
/sys/kernel/tracing/uprobe_events và kích hoạt nó thông qua
/sys/kernel/tracing/events/uprobes/<EVENT>/enable.

Tuy nhiên, không giống như công cụ theo dõi sự kiện kprobe, giao diện sự kiện uprobe mong đợi
người dùng tính toán độ lệch của điểm thăm dò trong đối tượng.

Bạn cũng có thể sử dụng /sys/kernel/tracing/dynamic_events thay vì
up_events. Giao diện đó sẽ cung cấp quyền truy cập thống nhất vào các
sự kiện năng động quá.

Tóm tắt của uprobe_tracer
-------------------------
::

p[:[GRP/][EVENT]] PATH:OFFSET [FETCHARGS] : Đặt tủ quần áo
  r[:[GRP/][EVENT]] PATH:OFFSET [FETCHARGS] : Đặt đầu dò quay trở lại (uretprobe)
  p[:[GRP/][EVENT]] PATH:OFFSET%return [FETCHARGS] : Đặt bộ dò ngược trở lại (uretprobe)
  -:[GRP/][EVENT] : Xóa sự kiện uprobe hoặc niệu đạo

GRP : Tên nhóm. Nếu bị bỏ qua, "uprobes" là giá trị mặc định.
  EVENT : Tên sự kiện. Nếu bị bỏ qua, tên sự kiện sẽ được tạo dựa trên
                  trên PATH+OFFSET.
  PATH : Đường dẫn đến tệp thực thi hoặc thư viện.
  OFFSET : Độ lệch nơi đầu dò được lắp vào.
  OFFSET%return : Độ lệch nơi đầu dò phản hồi được lắp vào.

FETCHARGS : Đối số. Mỗi đầu dò có thể có tới 128 đối số.
   %REG : Tìm nạp thanh ghi REG
   @ADDR : Tìm nạp bộ nhớ tại ADDR (ADDR phải ở trong không gian người dùng)
   @+OFFSET : Tìm nạp bộ nhớ tại OFFSET (OFFSET từ cùng một tệp với PATH)
   $stackN : Tìm nạp mục nhập thứ N của ngăn xếp (N >= 0)
   $stack : Lấy địa chỉ ngăn xếp.
   $retval : Tìm nạp giá trị trả về.(\*1)
   $comm : Tìm nạp nhiệm vụ hiện tại comm.
   +ZZ0001ZZ- Địa chỉ OFFS.(\ZZ0000ZZ3)
   \IMM : Lưu trữ giá trị ngay lập tức cho đối số.
   NAME=FETCHARG : Đặt NAME làm tên đối số của FETCHARG.
   FETCHARG:TYPE : Đặt TYPE làm loại FETCHARG. Hiện nay, các loại cơ bản
		       (u8/u16/u32/u64/s8/s16/s32/s64), loại thập lục phân
		       (x8/x16/x32/x64), "chuỗi" và trường bit được hỗ trợ.

(\*1) chỉ dành cho thăm dò trở lại.
  (\*2) điều này rất hữu ích để tìm nạp một trường cấu trúc dữ liệu.
  (\*3) Không giống như sự kiện kprobe, tiền tố "u" sẽ bị bỏ qua, vì uprobe
        các sự kiện chỉ có thể truy cập bộ nhớ không gian người dùng.

Các loại
-----
Một số loại được hỗ trợ cho tìm nạp-args. Uprobe tracer sẽ truy cập bộ nhớ
theo loại nhất định. Tiền tố 's' và 'u' có nghĩa là các loại đó được ký và không dấu
tương ứng. Tiền tố 'x' ngụ ý nó không được ký. Đối số theo dõi được hiển thị
ở dạng thập phân ('s' và 'u') hoặc thập lục phân ('x'). Không truyền kiểu, 'x32'
hoặc 'x64' được sử dụng tùy thuộc vào kiến trúc (ví dụ: x86-32 sử dụng x32 và
x86-64 sử dụng x64).
Loại chuỗi là loại đặc biệt, tìm nạp chuỗi "kết thúc null" từ
không gian người dùng.
Bitfield là một loại đặc biệt khác, có 3 tham số, độ rộng bit, bit-
offset và kích thước vùng chứa (thường là 32). Cú pháp là::

b<bit-width>@<bit-offset>/<container-size>

Đối với $comm, loại mặc định là "chuỗi"; bất kỳ loại nào khác là không hợp lệ.


Hồ sơ sự kiện
---------------
Bạn có thể kiểm tra tổng số lượt truy cập thăm dò cho mỗi sự kiện thông qua
/sys/kernel/tracing/uprobe_profile. Cột đầu tiên là tên tệp,
thứ hai là tên sự kiện, thứ ba là số lần thăm dò.

Ví dụ sử dụng
--------------
* Thêm một thăm dò làm sự kiện upprobe mới, viết định nghĩa mới cho uprobe_events
   như bên dưới (đặt bộ điều khiển ở độ lệch 0x4245c0 trong tệp thực thi/bin/bash)::

echo 'p /bin/bash:0x4245c0' > /sys/kernel/tracing/uprobe_events

* Thêm đầu dò dưới dạng sự kiện uretprobe mới::

echo 'r /bin/bash:0x4245c0' > /sys/kernel/tracing/uprobe_events

* Bỏ đặt sự kiện đã đăng ký::

echo '-:p_bash_0x4245c0' >> /sys/kernel/tracing/uprobe_events

* In ra các sự kiện đã đăng ký::

mèo /sys/kernel/tracing/uprobe_events

* Xóa tất cả các sự kiện::

echo > /sys/kernel/tracing/upprobe_events

Ví dụ sau minh họa cách kết xuất con trỏ lệnh và thanh ghi %ax
tại địa chỉ văn bản được thăm dò. Thăm dò hàm zfree trong /bin/zsh::

# cd /sys/kernel/tracing/
    # cat /proc/ZZ0000ZZ/maps ZZ0001ZZ grep r-xp
    00400000-0048a000 r-xp 00000000 08:03 130904 /bin/zsh
    # objdump -T /bin/zsh | grep -w zfree
    0000000000446420 g DF .text 0000000000000012 Base zfree

0x46420 là phần bù của zfree trong đối tượng /bin/zsh được tải tại
0x00400000. Do đó lệnh để nâng cấp sẽ là::

# echo 'p:zfree_entry /bin/zsh:0x46420 %ip %ax' > uprobe_events

Và điều tương tự đối với đầu dò niệu đạo sẽ là::

# echo 'r:zfree_exit /bin/zsh:0x46420 %ip %ax' >> uprobe_events

.. note:: User has to explicitly calculate the offset of the probe-point
	in the object.

Chúng ta có thể xem các sự kiện đã được đăng ký bằng cách xem tệp uprobe_events.
::

Sự kiện nâng cấp # cat
    p:uprobes/zfree_entry /bin/zsh:0x00046420 arg1=%ip arg2=%ax
    r:uprobes/zfree_exit /bin/zsh:0x00046420 arg1=%ip arg2=%ax

Định dạng của sự kiện có thể được xem bằng cách xem tệp events/uprobes/zfree_entry/format.
::

Sự kiện/uprobes/zfree_entry/format # cat
    tên: zfree_entry
    Mã số: 922
    định dạng:
         trường:unsigned short common_type;         bù đắp: 0;  kích thước:2; đã ký: 0;
         trường: char không dấu common_flags;         bù đắp:2;  kích thước: 1; đã ký: 0;
         trường: char không dấu common_preempt_count; bù đắp:3;  kích thước: 1; đã ký: 0;
         trường:int common_pid;                     bù đắp:4;  kích thước:4; đã ký: 1;
         trường:int common_padding;                 bù đắp: 8;  kích thước:4; đã ký: 1;

trường:không dấu dài __probe_ip;           bù đắp:12; kích thước:4; đã ký: 0;
         trường:u32 arg1;                           bù đắp:16; kích thước:4; đã ký: 0;
         trường:u32 arg2;                           bù đắp:20; kích thước:4; đã ký: 0;

in fmt: "(%lx) arg1=%lx arg2=%lx", REC->__probe_ip, REC->arg1, REC->arg2

Ngay sau khi định nghĩa, mỗi sự kiện sẽ bị tắt theo mặc định. Để theo dõi những điều này
sự kiện, bạn cần kích hoạt nó bằng cách::

# echo 1 > sự kiện/upprobe/kích hoạt

Hãy bắt đầu truy tìm, ngủ một lúc và ngừng truy tìm.
::

# echo 1 > truy tìm_on
    # sleep 20
    # echo 0 > truy tìm_on

Ngoài ra, bạn có thể tắt sự kiện bằng cách::

# echo 0 > sự kiện/upprobe/kích hoạt

Và bạn có thể xem thông tin được theo dõi qua /sys/kernel/tracing/trace.
::

Dấu vết # cat
    # tracer: không
    #
    #           ZZ0002ZZ-ZZ0003ZZ CPU#    ZZ0005ZZ FUNCTION
    #              ZZ0007ZZ ZZ0001ZZ |
                 zsh-24842 [006] 258544.995456: zfree_entry: (0x446420) arg1=446420 arg2=79
                 zsh-24842 [007] 258545.000270: zfree_exit: (0x446540 <- 0x446420) arg1=446540 arg2=0
                 zsh-24842 [002] 258545.043929: zfree_entry: (0x446420) arg1=446420 arg2=79
                 zsh-24842 [004] 258547.046129: zfree_exit: (0x446540 <- 0x446420) arg1=446540 arg2=0

Đầu ra cho chúng ta thấy uprobe đã được kích hoạt cho pid 24842 với ip là 0x446420
và nội dung của thanh ghi rìu là 79. Và uretprobe được kích hoạt bằng ip tại
0x446540 với mục nhập hàm đối ứng ở 0x446420.
