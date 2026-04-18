.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/filter.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _networking-filter:

=============================================================
Bộ lọc ổ cắm Linux hay còn gọi là Bộ lọc gói Berkeley (BPF)
=============================================================

Để ý
------

Tệp này được sử dụng để ghi lại định dạng và cơ chế eBPF ngay cả khi không
liên quan đến lọc ổ cắm.  ../bpf/index.rst có nhiều chi tiết hơn
trên eBPF.

Giới thiệu
------------

Bộ lọc ổ cắm Linux (LSF) có nguồn gốc từ Bộ lọc gói Berkeley.
Mặc dù có một số khác biệt rõ ràng giữa BSD và Linux
Lọc hạt nhân, nhưng khi chúng ta nói về BPF hoặc LSF trong ngữ cảnh Linux, chúng ta
có nghĩa là cơ chế lọc rất giống nhau trong nhân Linux.

BPF cho phép chương trình không gian người dùng gắn bộ lọc vào bất kỳ ổ cắm nào và
cho phép hoặc không cho phép một số loại dữ liệu nhất định đi qua ổ cắm. LSF
tuân theo chính xác cấu trúc mã bộ lọc giống như BPF của BSD, vì vậy hãy tham khảo
vào trang chủ BSD bpf.4 rất hữu ích trong việc tạo bộ lọc.

Trên Linux, BPF đơn giản hơn nhiều so với BSD. Người ta không phải lo lắng
về thiết bị hoặc bất cứ thứ gì tương tự. Bạn chỉ cần tạo mã bộ lọc của mình,
gửi nó tới kernel thông qua tùy chọn SO_ATTACH_FILTER và nếu bộ lọc của bạn
mã đã vượt qua quá trình kiểm tra kernel, sau đó bạn bắt đầu lọc ngay lập tức
dữ liệu trên socket đó.

Bạn cũng có thể tháo bộ lọc khỏi ổ cắm của mình thông qua SO_DETACH_FILTER
tùy chọn. Điều này có thể sẽ không được sử dụng nhiều kể từ khi bạn đóng ổ cắm
có bộ lọc trên đó, bộ lọc sẽ tự động bị xóa. Cái khác
trường hợp ít phổ biến hơn có thể là thêm một bộ lọc khác trên cùng một ổ cắm trong đó
bạn đã có một bộ lọc khác vẫn đang chạy: kernel sẽ đảm nhiệm việc này
loại bỏ cái cũ và đặt cái mới của bạn vào vị trí của nó, giả sử bạn
bộ lọc đã vượt qua các bước kiểm tra, nếu không thì bộ lọc cũ sẽ
vẫn còn trên ổ cắm đó.

Tùy chọn SO_LOCK_FILTER cho phép khóa bộ lọc được gắn vào ổ cắm. Một lần
được đặt, bộ lọc không thể bị xóa hoặc thay đổi. Điều này cho phép một tiến trình
thiết lập ổ cắm, gắn bộ lọc, khóa nó rồi bỏ đặc quyền và
đảm bảo rằng bộ lọc sẽ được giữ cho đến khi ổ cắm được đóng lại.

Người dùng lớn nhất của cấu trúc này có thể là libpcap. Phát hành cấp cao
lệnh lọc như ZZ0000ZZ đi qua libpcap
trình biên dịch nội bộ tạo ra cấu trúc mà cuối cùng có thể được tải
thông qua SO_ATTACH_FILTER tới kernel. ZZ0001ZZ
hiển thị những gì đang được đặt vào cấu trúc này.

Mặc dù chúng ta chỉ nói về socket ở đây nhưng BPF trong Linux được sử dụng
ở nhiều nơi nữa. Có xt_bpf cho netfilter, cls_bpf trong kernel
lớp qdisc, SECCOMP-BPF (MÁY TÍNH AN TOÀN [1]_) và nhiều nơi khác
chẳng hạn như trình điều khiển nhóm, mã PTP, v.v. nơi BPF đang được sử dụng.

.. [1] Documentation/userspace-api/seccomp_filter.rst

Giấy BPF gốc:

Steven McCanne và Van Jacobson. 1993. Bộ lọc gói BSD: một tính năng mới
kiến trúc để chụp gói ở cấp độ người dùng. Trong Kỷ yếu tố tụng của
Kỷ yếu Hội nghị Mùa đông 1993 của USENIX về USENIX Mùa đông 1993
Kỷ yếu hội nghị (USENIX'93). Hiệp hội USENIX, Berkeley,
CA, USA, 2-2. [ZZ0000ZZ

Kết cấu
---------

Các ứng dụng không gian người dùng bao gồm <linux/filter.h> chứa
các cấu trúc liên quan sau::

struct sock_filter { /* Khối lọc */
		__u16 mã;   /* Mã bộ lọc thực tế */
		__u8jt;	/* Nhảy đúng */
		__u8 jf;	/* Nhảy sai */
		__u32k;      /* Trường đa dụng chung */
	};

Cấu trúc như vậy được tập hợp thành một mảng gồm 4 bộ, chứa
một mã, giá trị jt, jf và k. jt và jf là độ lệch bước nhảy và k a chung
giá trị được sử dụng cho mã được cung cấp::

struct sock_fprog { /* Bắt buộc đối với SO_ATTACH_FILTER. */
		len ngắn không dấu;	/* Số lượng khối lọc */
		struct sock_filter __user *filter;
	};

Để lọc ổ cắm, một con trỏ tới cấu trúc này (như được hiển thị trong
ví dụ tiếp theo) đang được chuyển tới kernel thông qua setsockopt(2).

Ví dụ
-------

::

#include <sys/socket.h>
    #include <sys/types.h>
    #include <arpa/inet.h>
    #include <linux/if_ether.h>
    /* ... */

/* Từ ví dụ trên: tcpdump -i em1 port 22 -dd */
    mã struct sock_filter[] = {
	    { 0x28, 0, 0, 0x0000000c },
	    { 0x15, 0, 8, 0x000086dd },
	    { 0x30, 0, 0, 0x00000014 },
	    { 0x15, 2, 0, 0x00000084 },
	    { 0x15, 1, 0, 0x00000006 },
	    { 0x15, 0, 17, 0x00000011 },
	    { 0x28, 0, 0, 0x00000036 },
	    { 0x15, 14, 0, 0x00000016 },
	    { 0x28, 0, 0, 0x00000038 },
	    { 0x15, 12, 13, 0x00000016 },
	    { 0x15, 0, 12, 0x00000800 },
	    { 0x30, 0, 0, 0x00000017 },
	    { 0x15, 2, 0, 0x00000084 },
	    { 0x15, 1, 0, 0x00000006 },
	    { 0x15, 0, 8, 0x00000011 },
	    { 0x28, 0, 0, 0x00000014 },
	    { 0x45, 6, 0, 0x00001fff },
	    { 0xb1, 0, 0, 0x0000000e },
	    { 0x48, 0, 0, 0x0000000e },
	    { 0x15, 2, 0, 0x00000016 },
	    { 0x48, 0, 0, 0x00000010 },
	    { 0x15, 0, 1, 0x00000016 },
	    { 0x06, 0, 0, 0x0000ffff },
	    { 0x06, 0, 0, 0x00000000 },
    };

struct sock_fprog bpf = {
	    .len = ARRAY_SIZE(mã),
	    .filter = mã,
    };

tất = ổ cắm(PF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
    nếu (tất < 0)
	    /* ... giải cứu ... */

ret = setsockopt(sock, SOL_SOCKET, SO_ATTACH_FILTER, &bpf, sizeof(bpf));
    nếu (ret < 0)
	    /* ... giải cứu ... */

/* ... */
    close(sock);

Mã ví dụ trên gắn bộ lọc ổ cắm cho ổ cắm PF_PACKET
để cho phép tất cả các gói IPv4/IPv6 có cổng 22 đi qua. Phần còn lại sẽ
được loại bỏ cho ổ cắm này.

Lệnh gọi setsockopt(2) tới SO_DETACH_FILTER không cần bất kỳ đối số nào
và SO_LOCK_FILTER để ngăn bộ lọc bị tách ra, cần một
giá trị số nguyên bằng 0 hoặc 1.

Lưu ý rằng bộ lọc ổ cắm không chỉ giới hạn ở ổ cắm PF_PACKET,
nhưng cũng có thể được sử dụng trên các dòng socket khác.

Tóm tắt các cuộc gọi hệ thống:

* setsockopt(sockfd, SOL_SOCKET, SO_ATTACH_FILTER, &val, sizeof(val));
 * setsockopt(sockfd, SOL_SOCKET, SO_DETACH_FILTER, &val, sizeof(val));
 * setsockopt(sockfd, SOL_SOCKET, SO_LOCK_FILTER, &val, sizeof(val));

Thông thường, hầu hết các trường hợp sử dụng tính năng lọc ổ cắm trên ổ cắm gói sẽ
được bao phủ bởi libpcap theo cú pháp cấp cao, vì vậy với tư cách là nhà phát triển ứng dụng
bạn nên bám vào điều đó. libpcap bao bọc lớp riêng của nó xung quanh tất cả những thứ đó.

Trừ khi i) sử dụng/liên kết tới libpcap không phải là một tùy chọn, ii) BPF được yêu cầu
bộ lọc sử dụng các tiện ích mở rộng Linux không được trình biên dịch của libpcap hỗ trợ,
iii) bộ lọc có thể phức tạp hơn và không thể triển khai rõ ràng bằng
trình biên dịch của libpcap hoặc iv) các mã bộ lọc cụ thể phải được tối ưu hóa
khác với trình biên dịch nội bộ của libpcap; thì trong những trường hợp như vậy
viết một bộ lọc như vậy "bằng tay" có thể là một giải pháp thay thế. Ví dụ,
Người dùng xt_bpf và cls_bpf có thể có các yêu cầu có thể dẫn đến
mã bộ lọc phức tạp hơn hoặc mã bộ lọc không thể biểu thị bằng libpcap
(ví dụ: các mã trả về khác nhau cho các đường dẫn mã khác nhau). Hơn nữa, BPF JIT
người triển khai có thể muốn viết các trường hợp kiểm thử theo cách thủ công và do đó cần mức độ thấp
truy cập vào mã BPF.

Bộ hướng dẫn và động cơ BPF
------------------------------

Trong tools/bpf/ có một công cụ trợ giúp nhỏ tên là bpf_asm có thể
được sử dụng để viết các bộ lọc cấp thấp cho các tình huống ví dụ được đề cập trong
phần trước. Cú pháp giống Asm được đề cập ở đây đã được triển khai trong
bpf_asm và sẽ được sử dụng để giải thích thêm (thay vì xử lý
các opcode ít đọc trực tiếp hơn, các nguyên tắc đều giống nhau). Cú pháp là
được mô phỏng chặt chẽ theo bài báo BPF của Steven McCanne và Van Jacobson.

Kiến trúc BPF bao gồm các thành phần cơ bản sau:

======= =========================================================
  Mô tả phần tử
  ======= =========================================================
  Bộ tích lũy rộng 32 bit
  Thanh ghi X rộng 32 bit
  M[] Các thanh ghi linh tinh rộng 16 x 32 bit hay còn gọi là "bộ nhớ cào"
		   store", có địa chỉ từ 0 đến 15
  ======= =========================================================

Một chương trình được bpf_asm dịch thành "opcodes" là một mảng
bao gồm các yếu tố sau (như đã đề cập)::

op:16, jt:8, jf:8, k:32

Phần tử op là một opcode rộng 16 bit có một lệnh cụ thể
được mã hóa. jt và jf là hai mục tiêu nhảy rộng 8 bit, một cho điều kiện
"nhảy nếu đúng", cái còn lại "nhảy nếu sai". Cuối cùng, phần tử k
chứa một đối số linh tinh có thể được giải thích theo nhiều cách khác nhau
cách tùy thuộc vào hướng dẫn nhất định trong op.

Tập lệnh bao gồm tải, lưu trữ, nhánh, alu, linh tinh
và trả về các hướng dẫn cũng được trình bày bằng cú pháp bpf_asm. Cái này
bảng liệt kê tất cả các hướng dẫn bpf_asm có sẵn. cơ bản của họ là gì
các mã opcode như được định nghĩa trong linux/filter.h là viết tắt của:

=========== ===========================================
  Lệnh Chế độ đánh địa chỉ Mô tả
  =========== ===========================================
  ld 1, 2, 3, 4, 12 Nạp từ vào A
  ldi 4 Nạp từ vào A
  ldh 1, 2 Nạp nửa từ vào A
  ldb 1, 2 Tải byte vào A
  ldx 3, 4, 5, 12 Nạp từ vào X
  ldxi 4 Tải từ vào X
  ldxb 5 Tải byte vào X

bước 3 Lưu A vào M[]
  stx 3 Lưu X vào M[]

jmp 6 Chuyển tới nhãn
  ja 6 Chuyển tới nhãn
  jeq 7, 8, 9, 10 Nhảy lên A == <x>
  jneq 9, 10 Nhảy lên A != <x>
  jne 9, 10 Nhảy lên A != <x>
  jlt 9, 10 Nhảy lên A < <x>
  jle 9, 10 Nhảy lên A <= <x>
  jgt 7, 8, 9, 10 Nhảy lên A > <x>
  jge 7, 8, 9, 10 Nhảy lên A >= <x>
  jset 7, 8, 9, 10 Nhảy vào A & <x>

cộng 0, 4 A + <x>
  phụ 0, 4 A - <x>
  mul 0, 4 A * <x>
  div 0, 4 A / <x>
  mod 0, 4 A % <x>
  phủ định !A
  và 0, 4 A & <x>
  hoặc 0, 4 A | <x>
  xor 0, 4 A ^ <x>
  lsh 0, 4 A << <x>
  rsh 0, 4 A >> <x>

thuế Sao chép A vào X
  txa Sao chép X vào A

ret 4, 11 Trở lại
  =========== ===========================================

Bảng tiếp theo hiển thị các định dạng địa chỉ từ cột thứ 2:

========================================================================================
  Chế độ địa chỉ Cú pháp Mô tả
  ========================================================================================
   0 x/%x Đăng ký X
   1 [k] BHW ở độ lệch byte k trong gói
   2 [x + k] BHW ở offset X + k trong gói
   3 M[k] Từ ở độ lệch k trong M[]
   4 #k Giá trị bằng chữ được lưu trong k
   5 4*([k]&0xf)          Lower nibble * 4 ở độ lệch byte k trong gói
   6 L Nhảy nhãn L
   7 #k,Lt,Lf Nhảy tới Lt nếu đúng, nếu không thì nhảy tới Lf
   8 x/%x,Lt,Lf Nhảy tới Lt nếu đúng, nếu không thì nhảy tới Lf
   9 #k,Lt Nhảy tới Lt nếu vị từ đúng
  10 x/%x,Lt Nhảy tới Lt nếu vị từ đúng
  11 a/%a Tích lũy A
  12 phần mở rộng BPF phần mở rộng
  ========================================================================================

Nhân Linux cũng có một vài phần mở rộng BPF được sử dụng cùng với
với lớp hướng dẫn tải bằng cách "quá tải" đối số k với
phần bù âm + phần bù mở rộng cụ thể. Kết quả của BPF như vậy
các phần mở rộng được tải vào A.

Các phần mở rộng BPF có thể có được hiển thị trong bảng sau:

=========================================================================================
  Mô tả tiện ích mở rộng
  =========================================================================================
  len skb->len
  proto skb->giao thức
  gõ skb->pkt_type
  poff Phần bù bắt đầu tải trọng
  ifidx skb->dev->ifindex
  nla Thuộc tính Netlink loại X có offset A
  nlan Thuộc tính Netlink lồng nhau của loại X có offset A
  đánh dấu skb->đánh dấu
  hàng đợi skb->queue_mapping
  hatype skb->dev->loại
  rxhash skb->băm
  cpu raw_smp_processor_id()
  vlan_tci skb_vlan_tag_get(skb)
  vlan_avail skb_vlan_tag_hiện(skb)
  vlan_tpid skb->vlan_proto
  rand get_random_u32()
  =========================================================================================

Các tiện ích mở rộng này cũng có thể được bắt đầu bằng '#'.
Ví dụ về BPF cấp thấp:

ZZ0000ZZ::

ldh [12]
  jne #0x806, thả
  ret #-1
  thả: ret #0

ZZ0000ZZ::

ldh [12]
  jne #0x800, thả
  ldb [23]
  jneq #6, thả
  ret #-1
  thả: ret #0

ZZ0000ZZ::

ldh [12]
  jne #0x800, thả
  ldb [23]
  jneq #1, thả
  # get một số uint32 ngẫu nhiên
  ld rand
  mod #4
  jneq #1, thả
  ret #-1
  thả: ret #0

ZZ0000ZZ::

ld [4] /* offsetof(struct seccomp_data, Arch) */
  jne #0xc000003e, xấu /* AUDIT_ARCH_X86_64 */
  ld [0] /* offsetof(struct seccomp_data, nr) */
  jeq #15, tốt /* __NR_rt_sigreturn */
  jeq #231, tốt /* __NR_exit_group */
  jeq #60, tốt /* __NR_exit */
  jeq #0, tốt /* __NR_read */
  jeq #1, tốt /* __NR_write */
  jeq #5, tốt /* __NR_fstat */
  jeq #9, tốt /* __NR_mmap */
  jeq #14, tốt /* __NR_rt_sigprocmask */
  jeq #13, tốt /* __NR_rt_sigaction */
  jeq #35, tốt /* __NR_nanosleep */
  xấu: ret #0 /* SECCOMP_RET_KILL_THREAD */
  tốt: ret #0x7fff0000 /* SECCOMP_RET_ALLOW */

Ví dụ về tiện ích mở rộng BPF cấp thấp:

ZZ0000ZZ::

ld ifidx
  jneq #13, thả
  ret #-1
  thả: ret #0

ZZ0000ZZ::

ld vlan_tci
  jneq #10, thả
  ret #-1
  thả: ret #0

Mã ví dụ trên có thể được đặt vào một tệp (ở đây gọi là "foo") và
sau đó được chuyển đến công cụ bpf_asm để tạo opcode, xuất ra xt_bpf
và cls_bpf hiểu và có thể được tải trực tiếp. Ví dụ với ở trên
Mã ARP::

$ ./bpf_asm foo
    4,40 0 0 12,21 0 1 2054,6 0 0 4294967295,6 0 0 0,

Trong bản sao và dán đầu ra giống như C::

$ ./bpf_asm -c foo
    { 0x28, 0, 0, 0x0000000c },
    { 0x15, 0, 1, 0x00000806 },
    { 0x06, 0, 0, 0xffffffff },
    { 0x06, 0, 0, 0000000000 },

Đặc biệt, việc sử dụng xt_bpf hoặc cls_bpf có thể dẫn đến BPF phức tạp hơn
các bộ lọc ban đầu có thể không rõ ràng, bạn nên kiểm tra các bộ lọc trước
gắn vào một hệ thống sống. Với mục đích đó, có một công cụ nhỏ tên là
bpf_dbg trong tools/bpf/ trong thư mục nguồn kernel. Trình gỡ lỗi này cho phép
để kiểm tra các bộ lọc BPF đối với các tệp pcap nhất định, chỉ cần thực hiện một bước qua
Mã BPF trên các gói của pcap và để thực hiện kết xuất đăng ký máy BPF.

Bắt đầu bpf_dbg là chuyện nhỏ và chỉ yêu cầu phát hành ::

# ./bpf_dbg

Trong trường hợp đầu vào và đầu ra không bằng stdin/stdout, bpf_dbg sẽ lấy một
nguồn stdin thay thế làm đối số đầu tiên và một thiết bị xuất chuẩn thay thế
chìm như cái thứ hai, ví dụ: ZZ0000ZZ.

Ngoài ra, một cấu hình libreadline cụ thể có thể được đặt thông qua
tệp "~/.bpf_dbg_init" và lịch sử lệnh được lưu trữ trong tệp
"~/.bpf_dbg_history".

Tương tác trong bpf_dbg xảy ra thông qua Shell cũng có tính năng tự động hoàn thành
hỗ trợ (các lệnh ví dụ tiếp theo bắt đầu bằng '>' biểu thị bpf_dbg shell).
Quy trình làm việc thông thường sẽ là ...

* tải bpf 6,40 0 0 12,21 0 3 2048,48 0 0 23,21 0 1 1,6 0 0 65535,6 0 0 0
  Tải bộ lọc BPF từ đầu ra tiêu chuẩn của bpf_asm hoặc được chuyển đổi qua
  ví dụ: ZZ0000ZZ. Lưu ý rằng đối với JIT
  gỡ lỗi (phần tiếp theo), lệnh này tạo một ổ cắm tạm thời và
  tải mã BPF vào kernel. Vì vậy, điều này cũng sẽ hữu ích cho
  Nhà phát triển JIT.

* tải pcap foo.pcap

Tải tập tin pcap tcpdump tiêu chuẩn.

* chạy [<n>]

bpf vượt qua: 1 thất bại: 9
  Chạy qua tất cả các gói từ một pcap để tính toán số lần vượt qua và thất bại
  bộ lọc sẽ tạo ra. Có thể đưa ra giới hạn số gói đi qua.

* tháo rời::

l0: ldh [12]
	l1: jeq #0x800, l2, l5
	l2: ldb [23]
	l3: jeq #0x1, l4, l5
	l4: ret #0xffff
	l5: ret #0

In ra mã tháo gỡ BPF.

* bãi rác::

/* { op, jt, jf, k }, */
	{ 0x28, 0, 0, 0x0000000c },
	{ 0x15, 0, 3, 0x00000800 },
	{ 0x30, 0, 0, 0x00000017 },
	{ 0x15, 0, 1, 0x00000001 },
	{ 0x06, 0, 0, 0x0000ffff },
	{ 0x06, 0, 0, 0000000000 },

In kết xuất mã BPF kiểu C.

* điểm dừng 0::

điểm dừng tại: l0: ldh [12]

* điểm dừng 1::

điểm dừng tại: l1: jeq #0x800, l2, l5

  ...

Đặt điểm dừng theo hướng dẫn BPF cụ thể. Phát lệnh ZZ0000ZZ
  sẽ duyệt qua tệp pcap tiếp tục từ gói hiện tại và
  phá vỡ khi một điểm dừng bị tấn công (một ZZ0001ZZ khác sẽ tiếp tục từ
  điểm dừng hiện đang hoạt động thực hiện các hướng dẫn tiếp theo):

* chạy::

-- đăng ký kết xuất --
	pc: [0] <-- bộ đếm chương trình
	mã: [40] jt[0] jf[0] k[12] <- mã BPF đơn giản của lệnh hiện tại
	curr: l0: ldh [12] <- tháo gỡ lệnh hiện tại
	A: [00000000][0] <- nội dung của A (hex, thập phân)
	X: [00000000][0] <- nội dung của X (hex, thập phân)
	M[0,15]: [00000000][0] <- nội dung gấp của M (hex, thập phân)
	-- kết xuất gói -- <-- Gói hiện tại từ pcap (hex)
	len: 42
	    0: 00 19 cb 55 55 a4 00 14 a4 43 78 69 08 06 00 01
	16: 08 00 06 04 00 01 00 14 a4 43 78 69 0a 3b 01 26
	32: 00 00 00 00 00 00 0a 3b 01 01
	(điểm dừng)
	>

* điểm dừng::

điểm dừng: 0 1

Các bản in hiện được đặt điểm ngắt.

* bước [-<n>, +<n>]

Thực hiện từng bước thông qua chương trình BPF từ máy tính hiện tại
  bù đắp. Do đó, trên mỗi bước gọi, kết xuất đăng ký ở trên sẽ được phát hành.
  Điều này có thể tiến và lùi theo thời gian, một chiếc ZZ0000ZZ đơn giản sẽ bị hỏng
  trên lệnh BPF tiếp theo, do đó +1. (Không cần phát hành ZZ0001ZZ ở đây.)

* chọn <n>

Chọn một gói nhất định từ tệp pcap để tiếp tục. Như vậy, trên
  ZZ0000ZZ hoặc ZZ0001ZZ tiếp theo, chương trình BPF đang được đánh giá dựa trên
  gói được người dùng chọn trước. Việc đánh số bắt đầu giống như trong Wireshark
  với chỉ số 1.

* từ bỏ

Thoát khỏi bpf_dbg.

Trình biên dịch JIT
------------

Nhân Linux có trình biên dịch BPF JIT tích hợp cho x86_64, SPARC,
PowerPC, ARM, ARM64, MIPS, RISC-V, s390 và ARC và có thể được kích hoạt thông qua
CONFIG_BPF_JIT. Trình biên dịch JIT được gọi một cách minh bạch cho mỗi
bộ lọc đính kèm từ không gian người dùng hoặc cho người dùng kernel nội bộ nếu nó có
đã được kích hoạt trước đó bởi root::

echo 1 > /proc/sys/net/core/bpf_jit_enable

Đối với các nhà phát triển JIT, thực hiện kiểm tra, v.v., mỗi lần chạy biên dịch có thể xuất ra kết quả được tạo
hình ảnh opcode vào nhật ký kernel thông qua ::

echo 2 > /proc/sys/net/core/bpf_jit_enable

Đầu ra ví dụ từ dmesg::

[ 3389.935842] flen=6 proglen=70 pass=3 image=ffffffffa0069c8f
    [ 3389.935847] Mã JIT: 00000000: 55 48 89 e5 48 83 ec 60 48 89 5d f8 44 8b 4f 68
    [ 3389.935849] Mã JIT: 00000010: 44 2b 4f 6c 4c 8b 87 d8 00 00 00 be 0c 00 00 00
    [ 3389.935850] Mã JIT: 00000020: e8 1d 94 ff e0 3d 00 08 00 00 75 16 be 17 00 00
    [ 3389.935851] Mã JIT: 00000030: 00 e8 28 94 ff e0 83 f8 01 75 07 b8 ff ff 00 00
    [ 3389.935852] Mã JIT: 00000040: eb 02 31 c0 c9 c3

Khi CONFIG_BPF_JIT_ALWAYS_ON được bật, bpf_jit_enable được đặt vĩnh viễn thành 1 và
đặt bất kỳ giá trị nào khác ngoài giá trị đó sẽ trả về thất bại. Điều này thậm chí còn đúng với trường hợp
đặt bpf_jit_enable thành 2, kể từ khi đổ hình ảnh JIT cuối cùng vào nhật ký kernel
không được khuyến khích và việc xem xét nội tâm thông qua bpftool (trong tools/bpf/bpftool/) là
cách tiếp cận chung được đề nghị thay thế.

Trong cây nguồn kernel bên dưới tools/bpf/, có bpf_jit_disasm cho
tạo ra sự phân tách từ hexdump của nhật ký kernel ::

# ./bpf_jit_disasm
	70 byte được phát ra từ trình biên dịch JIT (pass:3, flen:6)
	ffffffffa0069c8f + <x>:
	0: đẩy %rbp
	1: di chuyển %rsp,%rbp
	4: phụ $0x60,%rsp
	8: di chuyển %rbx,-0x8(%rbp)
	c: di chuyển 0x68(%rdi),%r9d
	10: phụ 0x6c(%rdi),%r9d
	14: di chuyển 0xd8(%rdi),%r8
	1b: di chuyển $0xc,%esi
	20: callq 0xffffffffe0ff9442
	25: cmp $0x800,%eax
	2a: jne 0x0000000000000042
	2c: di chuyển $0x17,%esi
	31: callq 0xffffffffe0ff945e
	36: cmp $0x1,%eax
	39: jne 0x0000000000000042
	3b: di chuyển $0xffff,%eax
	40: jmp 0x0000000000000044
	42: xor %eax,%eax
	44: rời khỏi
	45: yêu cầu

Tùy chọn phát hành ZZ0000ZZ sẽ "chú thích" các opcode cho trình biên dịch kết quả
	hướng dẫn, có thể rất hữu ích cho các nhà phát triển JIT:

# ./bpf_jit_disasm -o
	70 byte được phát ra từ trình biên dịch JIT (pass:3, flen:6)
	ffffffffa0069c8f + <x>:
	0: đẩy %rbp
		55
	1: di chuyển %rsp,%rbp
		48 89 e5
	4: phụ $0x60,%rsp
		48 83 ec 60
	8: di chuyển %rbx,-0x8(%rbp)
		48 89 5d f8
	c: di chuyển 0x68(%rdi),%r9d
		44 8b 4f 68
	10: phụ 0x6c(%rdi),%r9d
		44 2b 4f 6c
	14: di chuyển 0xd8(%rdi),%r8
		4c 8b 87 d8 00 00 00
	1b: di chuyển $0xc,%esi
		là 0c 00 00 00
	20: callq 0xffffffffe0ff9442
		e8 1d 94 ff e0
	25: cmp $0x800,%eax
		3d 00 08 00 00
	2a: jne 0x0000000000000042
		75 16
	2c: di chuyển $0x17,%esi
		là 17 00 00 00
	31: callq 0xffffffffe0ff945e
		e8 28 94 ff e0
	36: cmp $0x1,%eax
		83 f8 01
	39: jne 0x0000000000000042
		75 07
	3b: di chuyển $0xffff,%eax
		b8 ff ff 00 00
	40: jmp 0x0000000000000044
		eb 02
	42: xor %eax,%eax
		31 c0
	44: rời khỏi
		c9
	45: yêu cầu
		c3

Đối với các nhà phát triển BPF JIT, bpf_jit_disasm, bpf_asm và bpf_dbg cung cấp một cách hữu ích
chuỗi công cụ để phát triển và thử nghiệm trình biên dịch JIT của kernel.

Nội bộ hạt nhân BPF
--------------------
Trong nội bộ, đối với trình thông dịch kernel, một tập lệnh khác
định dạng có nguyên tắc cơ bản tương tự từ BPF được mô tả ở phần trước
đoạn đang được sử dụng. Tuy nhiên, định dạng tập lệnh được mô hình hóa
gần hơn với kiến trúc cơ bản để bắt chước các tập lệnh gốc, vì vậy
rằng có thể đạt được hiệu suất tốt hơn (chi tiết hơn ở phần sau). Cái mới này
ISA được gọi là eBPF.  Xem ../bpf/index.rst để biết chi tiết.  (Lưu ý: eBPF
bắt nguồn từ [e]xtends BPF không giống với phần mở rộng BPF! Trong khi
eBPF là một tiện ích mở rộng ISA, BPF có từ thời 'quá tải' của BPF cổ điển
của lệnh BPF_LD ZZ0000ZZ BPF_ABS.)

Tập lệnh mới ban đầu được thiết kế với mục tiêu là
nhớ viết chương trình bằng "C bị hạn chế" và biên dịch thành eBPF với tùy chọn
Phần phụ trợ GCC/LLVM, để nó có thể ánh xạ kịp thời tới các CPU 64-bit hiện đại với
chi phí hoạt động tối thiểu qua hai bước, nghĩa là C -> eBPF -> mã gốc.

Hiện tại, định dạng mới đang được sử dụng để chạy các chương trình BPF của người dùng.
bao gồm seccomp BPF, bộ lọc ổ cắm cổ điển, bộ phân loại lưu lượng truy cập cls_bpf,
trình phân loại của trình điều khiển nhóm cho chế độ cân bằng tải của nó, xt_bpf của netfilter
tiện ích mở rộng, bộ phân tích/phân loại PTP, v.v. Tất cả họ đều ở bên trong
được kernel chuyển đổi thành biểu diễn tập lệnh mới và chạy
trong trình thông dịch eBPF. Đối với các trình xử lý trong kernel, tất cả đều hoạt động minh bạch
bằng cách sử dụng bpf_prog_create() để thiết lập bộ lọc, tương ứng.
bpf_prog_destroy() vì đã phá hủy nó. chức năng
bpf_prog_run(filter, ctx) gọi trình thông dịch eBPF hoặc JITed một cách minh bạch
mã để chạy bộ lọc. 'filter' là một con trỏ tới struct bpf_prog mà chúng ta
lấy từ bpf_prog_create() và 'ctx' ngữ cảnh đã cho (ví dụ:
con trỏ skb). Tất cả các ràng buộc và hạn chế từ bpf_check_classic() đều được áp dụng
trước khi việc chuyển đổi sang bố cục mới đang được thực hiện ở hậu trường!

Hiện tại, định dạng BPF cổ điển đang được sử dụng cho JITing trên hầu hết
Kiến trúc 32-bit, trong khi x86-64, aarch64, s390x, powerpc64,
sparc64, arm32, riscv64, riscv32, loongarch64, arc thực hiện biên dịch JIT
từ tập lệnh eBPF.

Kiểm tra
-------

Bên cạnh chuỗi công cụ BPF, kernel cũng cung cấp một mô-đun thử nghiệm có chứa
các trường hợp thử nghiệm khác nhau cho cổ điển và eBPF có thể được thực thi dựa trên
trình thông dịch BPF và trình biên dịch JIT. Nó có thể được tìm thấy trong lib/test_bpf.c và
được kích hoạt qua Kconfig::

CONFIG_TEST_BPF=m

Sau khi mô-đun được xây dựng và cài đặt, bộ thử nghiệm có thể được thực thi
thông qua insmod hoặc modprobe đối với mô-đun 'test_bpf'. Kết quả của các trường hợp thử nghiệm
bao gồm cả thời gian trong nsec có thể được tìm thấy trong nhật ký kernel (dmesg).

linh tinh
----

Ngoài ra, bộ ba, bộ làm mờ hệ thống Linux, có hỗ trợ tích hợp cho BPF và
Làm mờ hạt nhân SECCOMP-BPF.

Được viết bởi
----------

Tài liệu này được viết với hy vọng rằng nó hữu ích và phù hợp
để cung cấp cho các tin tặc hoặc kiểm toán viên bảo mật BPF tiềm năng một cái nhìn tổng quan hơn về
kiến trúc cơ bản.

- Jay Schulist <jschlst@samba.org>
- Daniel Borkmann <daniel@iogearbox.net>
- Alexei Starovoytov <ast@kernel.org>