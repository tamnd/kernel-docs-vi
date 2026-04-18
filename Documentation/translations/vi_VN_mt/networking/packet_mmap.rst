.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/packet_mmap.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============
Gói MMAP
============

Tóm tắt
========

Tệp này ghi lại cơ sở mmap() có sẵn với PACKET
giao diện ổ cắm. Loại ổ cắm này được sử dụng cho

i) nắm bắt lưu lượng mạng bằng các tiện ích như tcpdump,
ii) truyền lưu lượng mạng hoặc bất kỳ lưu lượng nào khác cần dữ liệu thô
    truy cập vào giao diện mạng.

Howto có thể được tìm thấy tại:

ZZ0000ZZ

Hãy gửi ý kiến của bạn tới
    - Ulisses Alonso Camaró <uaca@i.hate.spam.alumni.uv.es>
    - Johann Baudy

Tại sao nên sử dụng PACKET_MMAP
===============================

Quá trình chụp không phải PACKET_MMAP (AF_PACKET đơn giản) rất
không hiệu quả. Nó sử dụng bộ đệm rất hạn chế và yêu cầu một lệnh gọi hệ thống tới
chụp từng gói, cần có hai gói nếu bạn muốn lấy dấu thời gian của gói
(như libpcap luôn làm).

Mặt khác PACKET_MMAP rất hiệu quả. PACKET_MMAP cung cấp kích thước
bộ đệm tròn có thể định cấu hình được ánh xạ trong không gian người dùng có thể được sử dụng cho
gửi hoặc nhận gói tin. Bằng cách này, việc đọc các gói chỉ cần đợi chúng,
hầu hết thời gian không cần thực hiện một cuộc gọi hệ thống nào. Về việc
truyền, nhiều gói có thể được gửi qua một cuộc gọi hệ thống để nhận được
băng thông cao nhất. Bằng cách sử dụng bộ đệm chung giữa kernel và người dùng
cũng có lợi ích là giảm thiểu việc sao chép gói tin.

Bạn có thể sử dụng PACKET_MMAP để cải thiện hiệu suất chụp và
quá trình truyền tải, nhưng nó không phải là tất cả. Ít nhất, nếu bạn đang chụp
ở tốc độ cao (điều này liên quan đến tốc độ CPU), bạn nên kiểm tra xem
trình điều khiển thiết bị của card giao diện mạng của bạn hỗ trợ một số loại ngắt
giảm tải hoặc (thậm chí tốt hơn) nếu nó hỗ trợ NAPI, hãy đảm bảo rằng nó được hỗ trợ
đã bật. Để truyền, hãy kiểm tra MTU (Đơn vị truyền tối đa) được sử dụng và
được hỗ trợ bởi các thiết bị trong mạng của bạn. CPU IRQ ghim giao diện mạng của bạn
thẻ cũng có thể là một lợi thế.

Cách sử dụng mmap() để cải thiện quá trình chụp
===============================================

Từ quan điểm người dùng, bạn nên sử dụng thư viện libpcap cấp cao hơn, thư viện này
là một tiêu chuẩn thực tế, có thể di chuyển trên hầu hết các hệ điều hành
trong đó có Win32.

Hỗ trợ gói MMAP đã được tích hợp vào libpcap vào khoảng thời gian của phiên bản 1.3.0;
Hỗ trợ TPACKET_V3 đã được thêm vào trong phiên bản 1.5.0

Cách sử dụng trực tiếp mmap() để cải thiện quá trình chụp
=========================================================

Từ quan điểm gọi hệ thống, việc sử dụng PACKET_MMAP liên quan đến
quá trình sau::


[thiết lập] socket() -------> tạo ổ cắm chụp
		setsockopt() ---> phân bổ bộ đệm tròn (vòng)
				  tùy chọn: PACKET_RX_RING
		mmap() ----------> ánh xạ bộ đệm được phân bổ tới
				  quy trình người dùng

[capture] poll() ----------> để chờ gói tin đến

[tắt máy] close() --------> phá hủy ổ cắm chụp và
				  phân bổ tất cả các liên quan
				  tài nguyên.


Việc tạo và hủy socket được thực hiện một cách dễ dàng và được thực hiện
tương tự khi có hoặc không có PACKET_MMAP::

int fd = socket(PF_PACKET, mode, htons(ETH_P_ALL));

trong đó chế độ là SOCK_RAW cho giao diện thô là cấp độ liên kết
thông tin có thể được ghi lại hoặc SOCK_DGRAM cho món ăn đã nấu chín
giao diện nơi không thu thập thông tin ở cấp độ liên kết
được hỗ trợ và cung cấp tiêu đề giả cấp liên kết
bởi hạt nhân.

Sự phá hủy ổ cắm và tất cả các tài nguyên liên quan
được thực hiện bằng một lệnh gọi đơn giản để đóng (fd).

Tương tự như không có PACKET_MMAP, có thể sử dụng một ổ cắm
để thu thập và truyền tải. Điều này có thể được thực hiện bằng cách lập bản đồ
vòng đệm RX và TX được phân bổ chỉ bằng một lệnh gọi mmap().
Xem "Ánh xạ và sử dụng bộ đệm tròn (vòng)".

Tiếp theo tôi sẽ mô tả cài đặt PACKET_MMAP và các ràng buộc của nó,
cũng là ánh xạ của bộ đệm tròn trong quy trình người dùng và
việc sử dụng bộ đệm này.

Cách sử dụng trực tiếp mmap() để cải thiện quá trình truyền tải
===============================================================
Quá trình truyền tương tự như chụp như hình dưới đây::

[thiết lập] socket() -------> tạo ổ cắm truyền
		    setsockopt() ---> phân bổ bộ đệm tròn (vòng)
				      tùy chọn: PACKET_TX_RING
		    bind() ----------> liên kết ổ cắm truyền với giao diện mạng
		    mmap() ----------> ánh xạ bộ đệm được phân bổ tới
				      quy trình người dùng

[truyền] thăm dò ý kiến() ---------> đợi gói miễn phí (tùy chọn)
		    send() ----------> gửi tất cả các gói được đặt ở trạng thái sẵn sàng
				      chiếc nhẫn
				      Cờ MSG_DONTWAIT có thể được sử dụng để trả về
				      trước khi kết thúc quá trình chuyển giao.

[tắt máy] close() --------> phá hủy ổ cắm truyền và
				      phân bổ tất cả các tài nguyên liên quan.

Việc tạo và hủy socket cũng diễn ra nhanh chóng và được thực hiện
cách tương tự như cách chụp được mô tả ở đoạn trước::

int fd = ổ cắm (PF_PACKET, chế độ, 0);

Giao thức có thể tùy chọn là 0 trong trường hợp chúng ta chỉ muốn truyền
thông qua ổ cắm này, giúp tránh được cuộc gọi tốn kém tới packet_rcv().
Trong trường hợp này, bạn cũng cần liên kết (2) TX_RING với sll_protocol = 0
thiết lập. Mặt khác, htons(ETH_P_ALL) hoặc bất kỳ giao thức nào khác chẳng hạn.

Việc liên kết ổ cắm với giao diện mạng của bạn là bắt buộc (không có bản sao) để
biết kích thước tiêu đề của khung được sử dụng trong bộ đệm tròn.

Khi chụp, mỗi khung hình chứa hai phần::

--------------------
    Tiêu đề ZZ0000ZZ. Nó chứa trạng thái của
    ZZ0001ZZ của khung này
    ZZ0002ZZ
    ZZ0003ZZ
    .                    .  Dữ liệu sẽ được gửi qua giao diện mạng.
    .                    .
    --------------------

bind() liên kết ổ cắm với giao diện mạng của bạn nhờ
 tham số sll_ifindex của struct sockaddr_ll.

Ví dụ khởi tạo::

cấu trúc sockaddr_ll my_addr;
    cấu trúc ifreq s_ifr;
    ...

strscpy_pad (s_ifr.ifr_name, "eth0", sizeof(s_ifr.ifr_name));

/* lấy chỉ số giao diện của eth0 */
    ioctl(this->socket, SIOCGIFINDEX, &s_ifr);

/* điền vào cấu trúc sockaddr_ll để chuẩn bị liên kết */
    my_addr.sll_family = AF_PACKET;
    my_addr.sll_protocol = htons(ETH_P_ALL);
    my_addr.sll_ifindex = s_ifr.ifr_ifindex;

/* liên kết socket với eth0 */
    bind(this->socket, (struct sockaddr *)&my_addr, sizeof(struct sockaddr_ll));

Một hướng dẫn đầy đủ có sẵn tại:
 ZZ0000ZZ

Theo mặc định, người dùng nên đặt dữ liệu tại::

đế khung + TPACKET_HDRLEN - sizeof(struct sockaddr_ll)

Vì vậy, bất kể bạn chọn chế độ ổ cắm nào (SOCK_DGRAM hoặc SOCK_RAW),
phần đầu của dữ liệu người dùng sẽ ở::

đế khung + TPACKET_ALIGN(sizeof(struct tpacket_hdr))

Nếu bạn muốn đặt dữ liệu người dùng ở mức chênh lệch tùy chỉnh từ đầu
khung (ví dụ để căn chỉnh tải trọng với chế độ SOCK_RAW) bạn
có thể đặt tp_net (với SOCK_DGRAM) hoặc tp_mac (với SOCK_RAW). theo thứ tự
để thực hiện công việc này, nó phải được kích hoạt trước đó bằng setsockopt()
và tùy chọn PACKET_TX_HAS_OFF.

Cài đặt PACKET_MMAP
====================

Để thiết lập PACKET_MMAP từ mã cấp người dùng được thực hiện bằng lệnh gọi như

- Quá trình chụp::

setsockopt(fd, SOL_PACKET, PACKET_RX_RING, (void *) &req, sizeof(req))

- Quá trình truyền dẫn::

setsockopt(fd, SOL_PACKET, PACKET_TX_RING, (void *) &req, sizeof(req))

Đối số quan trọng nhất trong lệnh gọi trước là tham số req,
tham số này phải có cấu trúc sau::

cấu trúc tpacket_req
    {
	int unsigned tp_block_size;  /* Kích thước tối thiểu của khối liền kề */
	int unsigned tp_block_nr;    /* Số khối */
	int unsigned tp_frame_size;  /*Kích thước khung hình*/
	int unsigned tp_frame_nr;    /* Tổng số khung hình */
    };

Cấu trúc này được định nghĩa trong /usr/include/linux/if_packet.h và thiết lập một
bộ đệm tròn (vòng) của bộ nhớ không thể tráo đổi.
Được ánh xạ trong quá trình chụp cho phép đọc các khung đã chụp và
thông tin meta liên quan như dấu thời gian mà không yêu cầu lệnh gọi hệ thống.

Các khung được nhóm lại thành các khối. Mỗi khối là một khối liền kề về mặt vật lý
vùng bộ nhớ và chứa các khung tp_block_size/tp_frame_size. Tổng số
số khối là tp_block_nr. Lưu ý rằng tp_frame_nr là tham số dự phòng vì::

khung_per_block = tp_block_size/tp_frame_size

thực sự, packet_set_ring kiểm tra xem điều kiện sau có đúng không::

khung_per_block * tp_block_nr == tp_frame_nr

Hãy xem một ví dụ, với các giá trị sau::

tp_block_size= 4096
     tp_frame_size= 2048
     tp_block_nr = 4
     tp_frame_nr = 8

chúng ta sẽ có cấu trúc bộ đệm sau ::

khối #1 khối #2
    +----------+----------+ +----------+----------+
    Khung ZZ0000ZZ 2 ZZ0001ZZ khung 3 ZZ0002ZZ
    +----------+----------+ +----------+----------+

khối #3 khối #4
    +----------+----------+ +----------+----------+
    Khung ZZ0000ZZ 6 Khung ZZ0001ZZ 7 ZZ0002ZZ
    +----------+----------+ +----------+----------+

Một khung có thể có kích thước bất kỳ với điều kiện duy nhất là nó có thể vừa với một khối. một khối
chỉ có thể chứa một số nguyên khung hình, hay nói cách khác, một khung hình không thể
được sinh ra qua hai khối, vì vậy có một số chi tiết bạn phải xem xét
tài khoản khi chọn frame_size. Xem "Lập bản đồ và sử dụng hình tròn
đệm (vòng)".

Ràng buộc cài đặt PACKET_MMAP
===============================

Trong các phiên bản kernel trước 2.4.26 (đối với nhánh 2.4) và 2.6.5 (nhánh 2.6),
bộ đệm PACKET_MMAP chỉ có thể chứa 32768 khung hình trong kiến trúc 32 bit hoặc
16384 trong kiến trúc 64 bit.

Giới hạn kích thước khối
------------------------

Như đã nêu trước đó, mỗi khối là một vùng bộ nhớ vật lý liền kề. Những cái này
vùng bộ nhớ được phân bổ bằng các lệnh gọi đến hàm __get_free_pages(). Như
tên cho biết, chức năng này phân bổ các trang của bộ nhớ và chức năng thứ hai
đối số là "thứ tự" hoặc lũy thừa của hai số trang, nghĩa là
(đối với PAGE_SIZE == 4096) order=0 ==> 4096 byte, order=1 ==> 8192 byte,
order=2 ==> 16384 byte, v.v. Kích thước tối đa của một
vùng được phân bổ bởi __get_free_pages được xác định bởi macro MAX_PAGE_ORDER.
Chính xác hơn, giới hạn có thể được tính như sau:

PAGE_SIZE << MAX_PAGE_ORDER

Trong kiến trúc i386 PAGE_SIZE là 4096 byte
   Trong kernel 2.4/i386 MAX_PAGE_ORDER là 10
   Trong kernel 2.6/i386 MAX_PAGE_ORDER là 11

Vì vậy get_free_pages có thể phân bổ tối đa 4 MB hoặc 8 MB trong kernel 2.4/2.6
tương ứng với kiến trúc i386.

Các chương trình không gian người dùng có thể bao gồm /usr/include/sys/user.h và
/usr/include/linux/mmzone.h để nhận các khai báo PAGE_SIZE MAX_PAGE_ORDER.

Kích thước trang cũng có thể được xác định động bằng getpagesize (2)
cuộc gọi hệ thống.

Giới hạn số khối
------------------

Để hiểu các ràng buộc của PACKET_MMAP, chúng ta phải xem cấu trúc
được sử dụng để giữ con trỏ tới mỗi khối.

Hiện tại, cấu trúc này là một vectơ được phân bổ động với kmalloc
được gọi là pg_vec, kích thước của nó giới hạn số khối có thể được phân bổ ::

+---+---+---+---+
    ZZ0000ZZ x ZZ0001ZZ x |
    +---+---+---+---+
      ZZ0002ZZ ZZ0003ZZ
      ZZ0004ZZ |   v
      ZZ0005ZZ v khối #4
      |   khối v #3
      khối v #2
     khối #1

kmalloc phân bổ bất kỳ số byte bộ nhớ vật lý liền kề nào từ
một tập hợp các kích thước được xác định trước. Nhóm bộ nhớ này được duy trì bởi bản sàn
người cấp phát cuối cùng chịu trách nhiệm thực hiện việc phân bổ và
do đó áp đặt bộ nhớ tối đa mà kmalloc có thể phân bổ.

Trong hạt nhân 2.4/2.6 và kiến ​​trúc i386, giới hạn là 131072 byte. các
kích thước được xác định trước mà kmalloc sử dụng có thể được kiểm tra trong "size-<bytes>"
các mục của /proc/slabinfo

Trong kiến trúc 32 bit, con trỏ dài 4 byte, do đó tổng số
con trỏ tới các khối là::

131072/4 = 32768 khối

Máy tính kích thước bộ đệm PACKET_MMAP
======================================

định nghĩa:

=====================================================================================
<size-max> là kích thước tối đa có thể phân bổ với kmalloc
		(xem/proc/slabinfo)
<kích thước con trỏ> phụ thuộc vào kiến trúc -- ZZ0000ZZ
<kích thước trang> phụ thuộc vào kiến trúc -- PAGE_SIZE hoặc getpagesize (2)
<max-order> là giá trị được xác định bằng MAX_PAGE_ORDER
<kích thước khung hình> đó là giới hạn trên của kích thước chụp của khung hình (sẽ nói thêm về điều này sau)
============================================================================================================

từ những định nghĩa này chúng ta sẽ suy ra::

<số khối> = <size-max>/<kích thước con trỏ>
	<kích thước khối> = <kích thước trang> << <thứ tự tối đa>

vì vậy, kích thước bộ đệm tối đa là::

<số khối> * <kích thước khối>

và số lượng khung hình là::

<số khối> * <kích thước khối> / <kích thước khung>

Giả sử các tham số sau đây áp dụng cho kernel 2.6 và một
kiến trúc i386::

<size-max> = 131072 byte
	<kích thước con trỏ> = 4 byte
	<kích thước trang> = 4096 byte
	<thứ tự tối đa> = 11

và giá trị cho <frame size> là 2048 byte. Các tham số này sẽ mang lại::

<số khối> = 131072/4 = 32768 khối
	<kích thước khối> = 4096 << 11 = 8 MiB.

và do đó bộ đệm sẽ có kích thước 262144 MiB. So it can hold
262144 MiB/2048 byte = 134217728 khung

Trên thực tế, kích thước bộ đệm này không thể thực hiện được với kiến ​​trúc i386.
Hãy nhớ rằng bộ nhớ được phân bổ trong không gian kernel, trong trường hợp
kích thước bộ nhớ của kernel i386 bị giới hạn ở 1GiB.

Tất cả việc cấp phát bộ nhớ sẽ không được giải phóng cho đến khi ổ cắm được đóng lại. Bộ nhớ
việc phân bổ được thực hiện với mức độ ưu tiên GFP_KERNEL, về cơ bản điều này có nghĩa là
việc phân bổ có thể đợi và trao đổi bộ nhớ của tiến trình khác để phân bổ
bộ nhớ cần thiết, do đó thông thường có thể đạt tới giới hạn.

Những hạn chế khác
------------------

Nếu bạn kiểm tra mã nguồn, bạn sẽ thấy những gì tôi vẽ ở đây dưới dạng khung
không chỉ là khung mức liên kết. Ở đầu mỗi khung có một
tiêu đề có tên struct tpacket_hdr được sử dụng trong PACKET_MMAP để giữ khung của cấp độ liên kết
thông tin meta như dấu thời gian. Vì vậy, những gì chúng ta vẽ ở đây là một khung, nó thực sự là
phần sau (từ include/linux/if_packet.h)::

/*
   Cấu trúc khung:

- Bắt đầu. Khung phải được căn chỉnh theo TPACKET_ALIGNMENT=16
   - struct tpacket_hdr
   - chuyển sang TPACKET_ALIGNMENT=16
   - struct sockaddr_ll
   - Gap, được chọn sao cho dữ liệu gói (Start+tp_net) căn chỉnh với
     TPACKET_ALIGNMENT=16
   - Bắt đầu+tp_mac: [ Tiêu đề MAC tùy chọn ]
   - Start+tp_net: Dữ liệu gói, căn chỉnh theo TPACKET_ALIGNMENT=16.
   - Pad để căn chỉnh theo TPACKET_ALIGNMENT=16
 */

Sau đây là các điều kiện được kiểm tra trong packet_set_ring

- tp_block_size phải là bội số của PAGE_SIZE (1)
   - tp_frame_size phải lớn hơn TPACKET_HDRLEN (rõ ràng)
   - tp_frame_size phải là bội số của TPACKET_ALIGNMENT
   - tp_frame_nr phải chính xác là frame_per_block*tp_block_nr

Lưu ý rằng tp_block_size nên được chọn là lũy thừa của hai nếu không sẽ có
trở nên lãng phí trí nhớ.

Ánh xạ và sử dụng bộ đệm tròn (vòng)
---------------------------------------------

Việc ánh xạ bộ đệm trong quy trình người dùng được thực hiện theo cách thông thường
chức năng mmap. Ngay cả bộ đệm tròn cũng là sự kết hợp của một số vật lý
các khối bộ nhớ rời rạc, chúng liền kề với không gian người dùng, do đó
chỉ cần một cuộc gọi tới mmap ::

mmap(0, kích thước, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);

Nếu tp_frame_size là ước số của tp_block_size thì khung hình sẽ là
cách nhau liên tục bởi byte tp_frame_size. Nếu không thì mỗi
khung tp_block_size/tp_frame_size sẽ có một khoảng cách giữa
các khung hình. Điều này là do một khung không thể xuất hiện trên hai
khối.

Để sử dụng một ổ cắm cho việc thu và truyền, việc ánh xạ cả hai
Vòng đệm RX và TX phải được thực hiện bằng một lệnh gọi tới mmap::

    ...
setsockopt(fd, SOL_PACKET, PACKET_RX_RING, &foo, sizeof(foo));
    setsockopt(fd, SOL_PACKET, PACKET_TX_RING, &bar, sizeof(bar));
    ...
rx_ring = mmap(0, size * 2, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
    tx_ring = rx_ring + kích thước;

RX phải là cái đầu tiên vì kernel ánh xạ bộ nhớ vòng TX sang phải
sau chiếc RX.

Ở đầu mỗi khung có một trường trạng thái (xem
cấu trúc tpacket_hdr). Nếu trường này bằng 0 nghĩa là khung đã sẵn sàng
được sử dụng cho kernel, Nếu không, có một khung mà người dùng có thể đọc
và các cờ sau được áp dụng:

Quá trình chụp
^^^^^^^^^^^^^^^

Từ bao gồm/linux/if_packet.h::

#define TP_STATUS_COPY (1 << 1)
     #define TP_STATUS_LOSING (1 << 2)
     #define TP_STATUS_CSUMNOTREADY (1 << 3)
     #define TP_STATUS_CSUM_VALID (1 << 7)

===================================================================================
TP_STATUS_COPY Cờ này cho biết khung (và được liên kết
			thông tin meta) đã bị cắt bớt vì nó
			lớn hơn tp_frame_size. Gói tin này có thể
			đọc hoàn toàn bằng recvfrom().

Để thực hiện được công việc này thì phải
			được kích hoạt trước đó với setsockopt() và
			tùy chọn PACKET_COPY_THRESH.

Số lượng khung hình có thể được đệm vào
			được đọc bằng recvfrom bị giới hạn giống như ổ cắm thông thường.
			Xem tùy chọn SO_RCVBUF trong trang man socket (7).

TP_STATUS_LOSING cho biết đã có gói bị rớt từ lần trước
			số liệu thống kê được kiểm tra bằng getsockopt() và
			tùy chọn PACKET_STATISTICS.

TP_STATUS_CSUMNOTREADY hiện được sử dụng cho các gói IP gửi đi
			tổng kiểm tra của nó sẽ được thực hiện trong phần cứng. Vì vậy trong khi
			đọc gói chúng ta không nên cố gắng kiểm tra
			tổng kiểm tra.

TP_STATUS_CSUM_VALID Cờ này cho biết rằng ít nhất việc vận chuyển
			tổng kiểm tra tiêu đề của gói đã được
			được xác nhận ở phía kernel. Nếu cờ không được đặt
			sau đó chúng ta có thể tự mình kiểm tra tổng kiểm tra
			với điều kiện TP_STATUS_CSUMNOTREADY cũng chưa được thiết lập.
===================================================================================

để thuận tiện, cũng có những định nghĩa sau::

#define TP_STATUS_KERNEL 0
     #define TP_STATUS_USER 1

Hạt nhân khởi tạo tất cả các khung thành TP_STATUS_KERNEL, khi hạt nhân
nhận được một gói mà nó đặt vào bộ đệm và cập nhật trạng thái với
ít nhất là cờ TP_STATUS_USER. Sau đó người dùng có thể đọc gói tin,
Sau khi gói được đọc, người dùng phải đưa trường trạng thái về 0, để hạt nhân
có thể sử dụng lại bộ đệm khung đó.

Người dùng có thể sử dụng cuộc thăm dò ý kiến (bất kỳ biến thể nào khác cũng nên áp dụng) để kiểm tra xem có mới không
các gói đang ở trong vòng::

cấu trúc thăm dò ý kiến ​​pfd;

pfd.fd = fd;
    pfd.revents = 0;
    pfd.events = POLLINZZ0000ZZPOLLERR;

nếu (trạng thái == TP_STATUS_KERNEL)
	retval = thăm dò ý kiến(&pfd, 1, hết thời gian chờ);

Nó không phát sinh trong điều kiện chạy đua để kiểm tra giá trị trạng thái trước tiên và
sau đó thăm dò các khung.

Quá trình truyền tải
^^^^^^^^^^^^^^^^^^^^

Những định nghĩa đó cũng được sử dụng để truyền::

#define TP_STATUS_AVAILABLE 0 // Khung có sẵn
     #define TP_STATUS_SEND_REQUEST 1 // Khung sẽ được gửi vào lần gửi tiếp theo()
     #define TP_STATUS_SENDING 2 // Khung hiện đang được truyền
     #define TP_STATUS_WRONG_FORMAT 4 // Định dạng khung không chính xác

Đầu tiên, kernel khởi tạo tất cả các khung thành TP_STATUS_AVAILABLE. Để gửi một
gói, người dùng điền vào bộ đệm dữ liệu của khung có sẵn, đặt tp_len thành
kích thước bộ đệm dữ liệu hiện tại và đặt trường trạng thái của nó thành TP_STATUS_SEND_REQUEST.
Điều này có thể được thực hiện trên nhiều khung. Khi người dùng đã sẵn sàng truyền, nó
gọi gửi(). Sau đó, tất cả các bộ đệm có trạng thái bằng TP_STATUS_SEND_REQUEST đều được
chuyển tiếp tới thiết bị mạng. Kernel cập nhật từng trạng thái gửi
khung hình với TP_STATUS_SENDING cho đến khi kết thúc quá trình truyền.

Vào cuối mỗi lần truyền, trạng thái bộ đệm sẽ trở về TP_STATUS_AVAILABLE.

::

tiêu đề->tp_len = in_i_size;
    tiêu đề->tp_status = TP_STATUS_SEND_REQUEST;
    retval = send(this->socket, NULL, 0, 0);

Người dùng cũng có thể sử dụng poll() để kiểm tra xem có bộ đệm hay không:

(trạng thái == TP_STATUS_SENDING)

::

cấu trúc thăm dò ý kiến ​​pfd;
    pfd.fd = fd;
    pfd.revents = 0;
    pfd.events = POLLOUT;
    retval = thăm dò ý kiến(&pfd, 1, hết thời gian chờ);

TPACKET có những phiên bản nào và khi nào nên sử dụng chúng?
============================================================

::

int val = tpacket_version;
 setsockopt(fd, SOL_PACKET, PACKET_VERSION, &val, sizeof(val));
 getockopt(fd, SOL_PACKET, PACKET_VERSION, &val, sizeof(val));

trong đó 'tpacket_version' có thể là TPACKET_V1 (mặc định), TPACKET_V2, TPACKET_V3.

TPACKET_V1:
	- Mặc định nếu không được chỉ định khác bởi setsockopt(2)
	- RX_RING, TX_RING có sẵn

TPACKET_V1 --> TPACKET_V2:
	- Làm sạch 64 bit do sử dụng lâu không dấu trong TPACKET_V1
	  cấu trúc, do đó điều này cũng hoạt động trên kernel 64 bit với 32 bit
	  không gian người dùng và những thứ tương tự
	- Độ phân giải dấu thời gian tính bằng nano giây thay vì micro giây
	- RX_RING, TX_RING có sẵn
	- Thông tin siêu dữ liệu VLAN có sẵn cho các gói
	  (TP_STATUS_VLAN_VALID, TP_STATUS_VLAN_TPID_VALID),
	  trong cấu trúc tpacket2_hdr:

- Bit TP_STATUS_VLAN_VALID được đặt vào trường tp_status cho biết
		  trường tp_vlan_tci có giá trị VLAN TCI hợp lệ
		- Bit TP_STATUS_VLAN_TPID_VALID được đặt vào trường tp_status
		  chỉ ra rằng trường tp_vlan_tpid có giá trị VLAN TPID hợp lệ

- Cách chuyển sang TPACKET_V2:

1. Thay thế struct tpacket_hdr bằng struct tpacket2_hdr
		2. Truy vấn len tiêu đề và lưu
		3. Đặt phiên bản giao thức thành 2, thiết lập chuông như bình thường
		4. Để nhận sockaddr_ll,
		   sử dụng ZZ0000ZZ thay vì
		   ZZ0001ZZ

TPACKET_V2 --> TPACKET_V3:
	- Triển khai bộ đệm linh hoạt cho RX_RING:
		1. Các khối có thể được cấu hình với kích thước khung không tĩnh
		2. Đọc/thăm dò ở cấp độ khối (ngược lại với cấp độ gói)
		3. Đã thêm thời gian chờ thăm dò để tránh phải chờ đợi không gian người dùng vô thời hạn
		   trên các liên kết nhàn rỗi
		4. Đã thêm các nút bấm do người dùng định cấu hình:

Khối 4.1::thời gian chờ
			4.2 tpkt_hdr::sk_rxhash

- Dữ liệu RX Hash có sẵn trong không gian người dùng
	- Về mặt khái niệm, ngữ nghĩa của TX_RING tương tự như TPACKET_V2;
	  sử dụng tpacket3_hdr thay vì tpacket2_hdr và TPACKET3_HDRLEN
	  thay vì TPACKET2_HDRLEN. Trong cách thực hiện hiện nay,
	  trường tp_next_offset trong tpacket3_hdr MUST được đặt thành
	  bằng 0, biểu thị rằng vòng không chứa các khung có kích thước thay đổi.
	  Các gói có giá trị khác 0 của tp_next_offset sẽ bị loại bỏ.

Chế độ quạt AF_PACKET
=====================

Trong chế độ fanout AF_PACKET, việc tiếp nhận gói có thể được cân bằng tải giữa
quá trình. Điều này cũng hoạt động kết hợp với mmap(2) trên ổ cắm gói.

Các chính sách fanout được triển khai hiện nay là:

- PACKET_FANOUT_HASH: lên lịch socket theo gói băm của skb
  - PACKET_FANOUT_LB: lên lịch socket theo vòng tròn
  - PACKET_FANOUT_CPU: lên lịch cắm theo gói CPU đến
  - PACKET_FANOUT_RND: lên lịch socket bằng cách chọn ngẫu nhiên
  - PACKET_FANOUT_ROLLOVER: nếu một ổ cắm đầy, chuyển sang ổ cắm khác
  - PACKET_FANOUT_QM: lên lịch socket bằng skbs ghi queue_mapping

Mã ví dụ tối thiểu của David S. Miller (thử những thứ như "./test eth0 hash",
"./test eth0 lb", v.v.)::

#include <stddef.h>
    #include <stdlib.h>
    #include <stdio.h>
    #include <string.h>

#include <sys/types.h>
    #include <sys/wait.h>
    #include <sys/socket.h>
    #include <sys/ioctl.h>

#include <unistd.h>

#include <linux/if_ether.h>
    #include <linux/if_packet.h>

#include <net/if.h>

const char *device_name tĩnh;
    int tĩnh fanout_type;
    int tĩnh fanout_id;

#ifndef PACKET_FANOUT
    # define PACKET_FANOUT 18
    # define PACKET_FANOUT_HASH 0
    # define PACKET_FANOUT_LB 1
    #endif

int tĩnh setup_socket(void)
    {
	    int err, fd = socket(AF_PACKET, SOCK_RAW, htons(ETH_P_IP));
	    struct sockaddr_ll ll;
	    cấu trúc ifreq ifr;
	    int fanout_arg;

nếu (fd < 0) {
		    perror("socket");
		    trả lại EXIT_FAILURE;
	    }

bộ nhớ(&ifr, 0, sizeof(ifr));
	    strcpy(ifr.ifr_name, device_name);
	    err = ioctl(fd, SIOCGIFINDEX, &ifr);
	    nếu (lỗi < 0) {
		    lỗi ("SIOCGIFINDEX");
		    trả lại EXIT_FAILURE;
	    }

bộ nhớ(&ll, 0, sizeof(ll));
	    ll.sll_family = AF_PACKET;
	    ll.sll_ifindex = ifr.ifr_ifindex;
	    err = bind(fd, (struct sockaddr *) &ll, sizeof(ll));
	    nếu (lỗi < 0) {
		    perror("liên kết");
		    trả lại EXIT_FAILURE;
	    }

fanout_arg = (fanout_id | (fanout_type << 16));
	    err = setsockopt(fd, SOL_PACKET, PACKET_FANOUT,
			    &fanout_arg, sizeof(fanout_arg));
	    nếu (lỗi) {
		    perror("setsockopt");
		    trả lại EXIT_FAILURE;
	    }

trả lại fd;
    }

tĩnh void fanout_thread(void)
    {
	    int fd = setup_socket();
	    giới hạn int = 10000;

nếu (fd < 0)
		    thoát (fd);

trong khi (giới hạn-- > 0) {
		    char buf[1600];
		    int lỗi;

err = đọc(fd, buf, sizeof(buf));
		    nếu (lỗi < 0) {
			    perror("đọc");
			    thoát (EXIT_FAILURE);
		    }
		    nếu ((giới hạn % 10) == 0)
			    fprintf(stdout, "(%d) \n", getpid());
	    }

fprintf(stdout, "%d: Đã nhận 10000 gói\n", getpid());

đóng(fd);
	    thoát (0);
    }

int main(int argc, char **argp)
    {
	    int fd, err;
	    int tôi;

nếu (argc != 3) {
		    fprintf(stderr, "Cách sử dụng: %s INTERFACE {hash|lb}\n", argp[0]);
		    trả lại EXIT_FAILURE;
	    }

if (!strcmp(argp[2], "băm"))
		    fanout_type = PACKET_FANOUT_HASH;
	    khác nếu (!strcmp(argp[2], "lb"))
		    fanout_type = PACKET_FANOUT_LB;
	    khác {
		    fprintf(stderr, "Loại fanout không xác định [%s]\n", argp[2]);
		    thoát (EXIT_FAILURE);
	    }

tên_thiết bị = argp[1];
	    fanout_id = getpid() & 0xffff;

vì (i = 0; i < 4; i++) {
		    pid_t pid = nĩa();

chuyển đổi (pid) {
		    trường hợp 0:
			    fanout_thread();

trường hợp -1:
			    perror("ngã ba");
			    thoát (EXIT_FAILURE);
		    }
	    }

vì (i = 0; i < 4; i++) {
		    trạng thái int;

chờ đợi(&trạng thái);
	    }

trả về 0;
    }

Ví dụ về AF_PACKET TPACKET_V3
=============================

Bộ đệm vòng TPACKET_V3 của AF_PACKET có thể được cấu hình để sử dụng khung không tĩnh
kích thước bằng cách thực hiện quản lý bộ nhớ của riêng mình. Nó dựa trên các khối nơi bỏ phiếu
hoạt động trên cơ sở từng khối thay vì trên mỗi vòng như trong TPACKET_V2 và phiên bản tiền nhiệm.

Người ta nói rằng TPACKET_V3 mang lại những lợi ích sau:

* ~15% - Giảm 20% mức sử dụng CPU
 * ~20% tăng tốc độ bắt gói
 * ~ Tăng mật độ gói gấp 2 lần
 * Phân tích tổng hợp cổng
 * Kích thước khung hình không tĩnh để nắm bắt toàn bộ tải trọng gói

Vì vậy, nó có vẻ là một ứng cử viên tốt để sử dụng với gói fanout.

Mã ví dụ tối thiểu của Daniel Borkmann dựa trên lolpcap của Chetan Loke (biên dịch
nó với gcc -Wall -O2 blob.c và thử những thứ như "./a.out eth0", v.v.)::

/* Được viết từ đầu, nhưng sử dụng không gian kernel-to-user API
    * được mổ xẻ từ lolpcap:
    * Bản quyền 2011, Chetan Loke <loke.chetan@gmail.com>
    * Giấy phép: GPL, phiên bản 2.0
    */

#include <stdio.h>
    #include <stdlib.h>
    #include <stdint.h>
    #include <string.h>
    #include <khẳng định.h>
    #include <net/if.h>
    #include <arpa/inet.h>
    #include <netdb.h>
    #include <thăm dò ý kiến.h>
    #include <unistd.h>
    #include <tín hiệu.h>
    #include <inttypes.h>
    #include <sys/socket.h>
    #include <sys/mman.h>
    #include <linux/if_packet.h>
    #include <linux/if_ether.h>
    #include <linux/ip.h>

Có khả năng là #ifndef
    # define có khả năng(x) __buildin_expect(!!(x), 1)
    #endif
    #ifndef khó có thể xảy ra
    # define không chắc(x) __buildin_expect(!!(x), 0)
    #endif

cấu trúc block_desc {
	    phiên bản uint32_t;
	    uint32_t offset_to_priv;
	    cấu trúc tpacket_hdr_v1 h1;
    };

vòng cấu trúc {
	    struct iovec *rd;
	    uint8_t *bản đồ;
	    cấu trúc tpacket_req3 req;
    };

gói dài không dấu tĩnh_total = 0, byte_total = 0;
    sig_atomic_t sigint tĩnh = 0;

tĩnh void thở dài (int num)
    {
	    dấu = 1;
    }

static int setup_socket(struct ring *ring, char *netdev)
    {
	    int err, i, fd, v = TPACKET_V3;
	    struct sockaddr_ll ll;
	    unsigned int blockiz = 1 << 22, frameiz = 1 << 11;
	    unsigned int blocknum = 64;

fd = ổ cắm(AF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
	    nếu (fd < 0) {
		    perror("socket");
		    thoát (1);
	    }

err = setsockopt(fd, SOL_PACKET, PACKET_VERSION, &v, sizeof(v));
	    nếu (lỗi < 0) {
		    perror("setsockopt");
		    thoát (1);
	    }

bộ nhớ(&ring->req, 0, sizeof(ring->req));
	    ring->req.tp_block_size = blockiz;
	    ring->req.tp_frame_size = frameiz;
	    ring->req.tp_block_nr = blocknum;
	    ring->req.tp_frame_nr = (blocksiz * blocknum) / frameiz;
	    đổ chuông->req.tp_retire_blk_tov = 60;
	    đổ chuông->req.tp_feature_req_word = TP_FT_REQ_FILL_RXHASH;

err = setsockopt(fd, SOL_PACKET, PACKET_RX_RING, &ring->req,
			    sizeof(ring->req));
	    nếu (lỗi < 0) {
		    perror("setsockopt");
		    thoát (1);
	    }

ring->map = mmap(NULL, ring->req.tp_block_size * ring->req.tp_block_nr,
			    PROT_READ ZZ0000ZZ MAP_LOCKED, fd, 0);
	    if (ring->map == MAP_FAILED) {
		    lỗi ("mmap");
		    thoát (1);
	    }

ring->rd = malloc(ring->req.tp_block_nr * sizeof(*ring->rd));
	    khẳng định(ring->rd);
	    for (i = 0; i < ring->req.tp_block_nr; ++i) {
		    ring->rd[i].iov_base = ring->map + (i * ring->req.tp_block_size);
		    ring->rd[i].iov_len = ring->req.tp_block_size;
	    }

bộ nhớ(&ll, 0, sizeof(ll));
	    ll.sll_family = PF_PACKET;
	    ll.sll_protocol = htons(ETH_P_ALL);
	    ll.sll_ifindex = if_nametoindex(netdev);
	    ll.sll_hatype = 0;
	    ll.sll_pkttype = 0;
	    ll.sll_halen = 0;

err = bind(fd, (struct sockaddr *) &ll, sizeof(ll));
	    nếu (lỗi < 0) {
		    perror("liên kết");
		    thoát (1);
	    }

trả lại fd;
    }

hiển thị khoảng trống tĩnh (struct tpacket3_hdr *ppd)
    {
	    struct ethhdr ZZ0000ZZ) ((uint8_t *) ppd + ppd->tp_mac);
	    cấu trúc iphdr ZZ0001ZZ) ((uint8_t *) eth + ETH_HLEN);

if (eth->h_proto == htons(ETH_P_IP)) {
		    struct sockaddr_in ss, sd;
		    char sbuff[NI_MAXHOST], dbuff[NI_MAXHOST];

bộ nhớ(&ss, 0, sizeof(ss));
		    ss.sin_family = PF_INET;
		    ss.sin_addr.s_addr = ip->saddr;
		    getnameinfo((struct sockaddr *) &ss, sizeof(ss),
				sbuff, sizeof(sbuff), NULL, 0, NI_NUMERICHOST);

bộ nhớ(&sd, 0, sizeof(sd));
		    sd.sin_family = PF_INET;
		    sd.sin_addr.s_addr = ip->daddr;
		    getnameinfo((struct sockaddr *) &sd, sizeof(sd),
				dbuff, sizeof(dbuff), NULL, 0, NI_NUMERICHOST);

printf("%s -> %s,", sbuff, dbuff);
	    }

printf("rxhash: 0x%x\n", ppd->hv1.tp_rxhash);
    }

static void walk_block(struct block_desc *pbd, const int block_num)
    {
	    int num_pkts = pbd->h1.num_pkts, i;
	    byte dài không dấu = 0;
	    cấu trúc tpacket3_hdr *ppd;

ppd = (struct tpacket3_hdr ZZ0000ZZ) pbd +
					pbd->h1.offset_to_first_pkt);
	    for (i = 0; i < num_pkts; ++i) {
		    byte += ppd->tp_snaplen;
		    hiển thị(ppd);

ppd = (struct tpacket3_hdr ZZ0000ZZ) ppd +
						ppd->tp_next_offset);
	    }

gói_total += num_pkts;
	    byte_total += byte;
    }

static void tuôn ra_block(struct block_desc *pbd)
    {
	    pbd->h1.block_status = TP_STATUS_KERNEL;
    }

static void Tearsdown_socket(struct ring *ring, int fd)
    {
	    munmap(ring->map, ring->req.tp_block_size * ring->req.tp_block_nr);
	    miễn phí(ring->rd);
	    đóng(fd);
    }

int main(int argc, char **argp)
    {
	    int fd, err;
	    socklen_t len;
	    cấu trúc vòng vòng;
	    cấu trúc thăm dò ý kiến ​​pfd;
	    int unsigned block_num = 0, khối = 64;
	    struct block_desc *pbd;
	    thống kê cấu trúc tpacket_stats_v3;

nếu (argc != 2) {
		    fprintf(stderr, "Cách sử dụng: %s INTERFACE\n", argp[0]);
		    trả lại EXIT_FAILURE;
	    }

tín hiệu (SIGINT, người thở dài);

bộ nhớ(&ring, 0, sizeof(ring));
	    fd = setup_socket(&ring, argp[argc - 1]);
	    khẳng định(fd > 0);

bộ nhớ(&pfd, 0, sizeof(pfd));
	    pfd.fd = fd;
	    pfd.events = POLLIN | POLLERR;
	    pfd.revents = 0;

trong khi (có thể(!sigint)) {
		    pbd = (struct block_desc *) ring.rd[block_num].iov_base;

if ((pbd->h1.block_status & TP_STATUS_USER) == 0) {
			    thăm dò ý kiến(&pfd, 1, -1);
			    Tiếp tục;
		    }

walk_block(pbd, block_num);
		    tuôn ra_block(pbd);
		    block_num = (block_num + 1) % khối;
	    }

len = sizeof(số liệu thống kê);
	    err = getsockopt(fd, SOL_PACKET, PACKET_STATISTICS, &stats, &len);
	    nếu (lỗi < 0) {
		    perror("getsockopt");
		    thoát (1);
	    }

fflush(stdout);
	    printf("\nĐã nhận %u gói, %lu byte, %u bị rớt, Freeze_q_cnt: %u\n",
		stats.tp_packets, byte_total, stats.tp_drops,
		stats.tp_freeze_q_cnt);

Tearsdown_socket(&ring, fd);
	    trả về 0;
    }

PACKET_QDISC_BYPASS
===================

Nếu có yêu cầu tải mạng với nhiều gói trong cùng một
như pktgen, bạn có thể đặt tùy chọn sau sau socket
sáng tạo::

int một = 1;
    setsockopt(fd, SOL_PACKET, PACKET_QDISC_BYPASS, &one, sizeof(one));

Điều này có tác dụng phụ là các gói được gửi qua PF_PACKET sẽ bỏ qua
lớp qdisc của kernel và buộc phải được đẩy trực tiếp tới trình điều khiển. Ý nghĩa,
gói không được lưu vào bộ đệm, các nguyên tắc tc bị bỏ qua, có thể xảy ra tình trạng mất gói dữ liệu tăng lên
và các gói như vậy cũng không còn hiển thị trên các ổ cắm PF_PACKET khác nữa. Vì vậy,
bạn đã được cảnh báo; nói chung, điều này có thể hữu ích cho việc kiểm tra sức chịu đựng khác nhau
các thành phần của một hệ thống.

Theo mặc định, PACKET_QDISC_BYPASS bị tắt và cần được bật rõ ràng
trên ổ cắm PF_PACKET.

PACKET_TIMESTAMP
================

Cài đặt PACKET_TIMESTAMP xác định nguồn của dấu thời gian trong
thông tin meta gói cho mmap(2)ed RX_RING và TX_RING.  Nếu bạn
NIC có khả năng đánh dấu thời gian các gói trong phần cứng, bạn có thể yêu cầu các gói đó
dấu thời gian phần cứng sẽ được sử dụng. Lưu ý: bạn có thể cần kích hoạt thế hệ
dấu thời gian phần cứng với SIOCSHWTSTAMP (xem thông tin liên quan từ
Tài liệu/mạng/timestamping.rst).

PACKET_TIMESTAMP chấp nhận trường bit số nguyên giống như SO_TIMESTAMPING::

int req = SOF_TIMESTAMPING_RAW_HARDWARE;
    setsockopt(fd, SOL_PACKET, PACKET_TIMESTAMP, (void *) &req, sizeof(req))

Đối với bộ đệm vòng mmap(2)ed, các dấu thời gian như vậy được lưu trữ trong
Các thành viên tp_sec và ZZ0001ZZ của cấu trúc ZZ0000ZZ.
Để xác định loại dấu thời gian nào đã được báo cáo, trường tp_status
là nhị phân hoặc có các bit có thể sau đây ...

::

TP_STATUS_TS_RAW_HARDWARE
    TP_STATUS_TS_SOFTWARE

... that are equivalent to its ``SOF_TIMESTAMPING_*`` counterparts. For the
RX_RING, nếu cả hai đều không được đặt (tức là PACKET_TIMESTAMP không được đặt), thì a
dự phòng phần mềm đã được gọi mã xử lý của ZZ0000ZZ PF_PACKET (ít hơn
chính xác).

Việc lấy dấu thời gian cho TX_RING hoạt động như sau: i) điền vào các khung vòng,
ii) gọi sendto() ví dụ: ở chế độ chặn, iii) chờ trạng thái liên quan
các khung sẽ được cập nhật tương ứng. khung được bàn giao cho ứng dụng, iv) đi bộ
thông qua các khung để lấy dấu thời gian hw/sw riêng lẻ.

Chỉ (!) nếu tính năng đánh dấu thời gian truyền được bật thì các bit này sẽ được kết hợp
với nhị phân | với TP_STATUS_AVAILABLE, vì vậy bạn phải kiểm tra điều đó trong
ứng dụng (ví dụ !(tp_status & (TP_STATUS_SEND_REQUEST | TP_STATUS_SENDING))
ở bước đầu tiên để xem khung có thuộc về ứng dụng không, sau đó
người ta có thể trích xuất loại dấu thời gian ở bước thứ hai từ tp_status)!

Nếu bạn không quan tâm đến chúng, do đó nó bị vô hiệu hóa, hãy kiểm tra
TP_STATUS_AVAILABLE tương ứng. TP_STATUS_WRONG_FORMAT là đủ. Nếu trong
Chỉ phần TX_RING TP_STATUS_AVAILABLE được đặt, sau đó là tp_sec và tp_{n,u}sec
thành viên không chứa giá trị hợp lệ. Đối với TX_RING, theo mặc định không có dấu thời gian
được tạo ra!

Xem include/linux/net_tstamp.h và Documentation/networking/timestamping.rst
để biết thêm thông tin về dấu thời gian phần cứng.

Các bit khác
==================

- Ổ cắm gói hoạt động tốt cùng với các bộ lọc ổ cắm Linux, do đó bạn cũng có thể
  có thể muốn xem Tài liệu/mạng/filter.rst

THANKS
======

Jesse Brandeburg, vì đã sửa lỗi ngữ pháp/chính tả của tôi