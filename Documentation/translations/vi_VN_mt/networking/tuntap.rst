.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/tuntap.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

==================================
Trình điều khiển thiết bị phổ dụng TUN/TAP
===============================

Bản quyền ZZ0000ZZ 1999-2000 Maxim Krasnyansky <max_mk@yahoo.com>

Trình điều khiển Linux, Solaris
  Bản quyền ZZ0000ZZ 1999-2000 Maxim Krasnyansky <max_mk@yahoo.com>

Trình điều khiển FreeBSD TAP
  Bản quyền ZZ0000ZZ 1999-2000 Maksim Yevmenkin <m_evmenkin@yahoo.com>

Bản sửa đổi tài liệu này năm 2002 của Florian Thiel <florian.thiel@gmx.net>

1. Mô tả
==============

TUN/TAP cung cấp khả năng nhận và truyền gói cho các chương trình không gian người dùng.
  Nó có thể được coi là một thiết bị Point-to-Point hoặc Ethernet đơn giản,
  thay vì nhận các gói từ phương tiện vật lý, hãy nhận chúng từ
  chương trình không gian người dùng và thay vì gửi các gói thông qua phương tiện vật lý
  ghi chúng vào chương trình không gian người dùng.

Để sử dụng trình điều khiển, một chương trình phải mở /dev/net/tun và đưa ra lệnh
  ioctl() tương ứng để đăng ký thiết bị mạng với kernel. Một mạng lưới
  thiết bị sẽ xuất hiện dưới dạng tunXX hoặc tapXX, tùy thuộc vào các tùy chọn đã chọn. Khi nào
  chương trình sẽ đóng bộ mô tả tập tin, thiết bị mạng và tất cả
  các tuyến đường tương ứng sẽ biến mất.

Tùy thuộc vào loại thiết bị được chọn, chương trình không gian người dùng phải đọc/ghi
  Gói IP (có tun) hoặc khung ethernet (có tap). Cái nào đang được sử dụng
  phụ thuộc vào các cờ được cung cấp bằng ioctl().

Gói từ ZZ0000ZZ chứa hai ví dụ đơn giản
  để biết cách sử dụng các thiết bị tun và tap. Cả hai chương trình đều hoạt động như một cầu nối giữa
  hai giao diện mạng.
  br_select.c - cầu nối dựa trên lệnh gọi hệ thống được chọn.
  br_sigio.c - cầu nối dựa trên tín hiệu async io và SIGIO.
  Tuy nhiên, ví dụ điển hình nhất là VTun ZZ0001ZZ :))

2. Cấu hình
================

Tạo nút thiết bị::

mkdir /dev/net (nếu nó chưa tồn tại)
     mknod /dev/net/tun c 10 200

Đặt quyền::

ví dụ. chmod 0666/dev/net/tun

Không có hại gì khi cho phép người dùng không phải root có thể truy cập thiết bị,
  vì CAP_NET_ADMIN cần thiết để tạo các thiết bị mạng hoặc cho
  kết nối với các thiết bị mạng không thuộc sở hữu của người dùng được đề cập.
  Nếu bạn muốn tạo các thiết bị cố định và trao quyền sở hữu chúng cho
  người dùng không có đặc quyền, thì bạn cần có thiết bị /dev/net/tun để có thể sử dụng được
  những người dùng đó.

Tự động tải mô-đun trình điều khiển

Đảm bảo rằng "Trình tải mô-đun hạt nhân" - tự động tải mô-đun
     hỗ trợ được kích hoạt trong kernel của bạn.  Kernel nên tải nó vào
     truy cập đầu tiên.

Tải thủ công

chèn mô-đun bằng tay::

điều chỉnh modprobe

Nếu bạn làm theo cách thứ hai, bạn phải tải mô-đun mỗi lần bạn
  cần nó, nếu bạn làm theo cách khác nó sẽ tự động được tải khi
  /dev/net/tun đang được mở.

3. Giao diện chương trình
====================

3.1 Phân bổ thiết bị mạng
-----------------------------

ZZ0000ZZ phải là tên của thiết bị có chuỗi định dạng (ví dụ:
"tun%d"), nhưng (theo như tôi thấy) đây có thể là bất kỳ tên thiết bị mạng hợp lệ nào.
Lưu ý rằng con trỏ ký tự sẽ bị ghi đè bằng tên thiết bị thực
(ví dụ: "tun0")::

#include <linux/if.h>
  #include <linux/if_tun.h>

int tun_alloc(char *dev)
  {
      cấu trúc ifreq ifr;
      int fd, err;

if( (fd = open("/dev/net/tun", O_RDWR)) < 0 )
	 trả về tun_alloc_old(dev);

bộ nhớ(&ifr, 0, sizeof(ifr));

/* Cờ: IFF_TUN - Thiết bị TUN (không có tiêu đề Ethernet)
       * Thiết bị IFF_TAP - TAP
       *
       * IFF_NO_PI - Không cung cấp thông tin gói
       */
      ifr.ifr_flags = IFF_TUN;
      nếu( *dev )
	 strscpy_pad(ifr.ifr_name, dev, IFNAMSIZ);

if( (err = ioctl(fd, TUNSETIFF, (void *) &ifr)) < 0 ){
	 đóng(fd);
	 trả lại lỗi;
      }
      strcpy(dev, ifr.ifr_name);
      trả lại fd;
  }

3.2 Định dạng khung
----------------

Nếu cờ IFF_NO_PI không được đặt thì mỗi định dạng khung là::

Cờ [2 byte]
     Nguyên bản [2 byte]
     Khung giao thức thô (IP, IPv6, v.v.).

3.3 Giao diện tuntap nhiều hàng đợi
-------------------------------

Từ phiên bản 3.8, Linux hỗ trợ tuntap nhiều hàng đợi có thể sử dụng nhiều
bộ mô tả tệp (hàng đợi) để song song hóa việc gửi hoặc nhận các gói. các
việc phân bổ thiết bị vẫn giống như trước và nếu người dùng muốn tạo nhiều
hàng đợi, TUNSETIFF có cùng tên thiết bị phải được gọi nhiều lần với
Cờ IFF_MULTI_QUEUE.

ZZ0000ZZ phải là tên của thiết bị, hàng đợi là số lượng hàng đợi
được tạo, fds được sử dụng để lưu trữ và trả về các bộ mô tả tệp (hàng đợi)
được tạo cho người gọi. Mỗi bộ mô tả tập tin được dùng làm giao diện của một
hàng đợi có thể được truy cập bởi không gian người dùng.

::

#include <linux/if.h>
  #include <linux/if_tun.h>

int tun_alloc_mq(char *dev, int queues, int *fds)
  {
      cấu trúc ifreq ifr;
      int fd, err, i;

nếu (!dev)
	  trả về -1;

bộ nhớ(&ifr, 0, sizeof(ifr));
      /* Cờ: IFF_TUN - Thiết bị TUN (không có tiêu đề Ethernet)
       * Thiết bị IFF_TAP - TAP
       *
       * IFF_NO_PI - Không cung cấp thông tin gói
       * IFF_MULTI_QUEUE - Tạo hàng đợi thiết bị nhiều hàng đợi
       */
      ifr.ifr_flags = IFF_TAP ZZ0000ZZ IFF_MULTI_QUEUE;
      strcpy(ifr.ifr_name, dev);

for (i = 0; i < hàng đợi; i++) {
	  nếu ((fd = open("/dev/net/tun", O_RDWR)) < 0)
	     nhầm rồi;
	  err = ioctl(fd, TUNSETIFF, (void *)&ifr);
	  nếu (lỗi) {
	     đóng(fd);
	     nhầm rồi;
	  }
	  fds[i] = fd;
      }

trả về 0;
  lỗi:
      vì (--i; i >= 0; i--)
	  đóng(fds[i]);
      trả lại lỗi;
  }

Một ioctl mới (TUNSETQUEUE) đã được giới thiệu để bật hoặc tắt hàng đợi. Khi nào
gọi nó bằng cờ IFF_DETACH_QUEUE, hàng đợi đã bị vô hiệu hóa. Và khi nào
gọi nó bằng cờ IFF_ATTACH_QUEUE, hàng đợi đã được bật. Hàng đợi đã
được bật theo mặc định sau khi được tạo thông qua TUNSETIFF.

fd là bộ mô tả tệp (hàng đợi) mà chúng tôi muốn bật hoặc tắt khi
kích hoạt là đúng, chúng tôi kích hoạt nó, nếu không chúng tôi sẽ tắt nó ::

#include <linux/if.h>
  #include <linux/if_tun.h>

int tun_set_queue(int fd, int kích hoạt)
  {
      cấu trúc ifreq ifr;

bộ nhớ(&ifr, 0, sizeof(ifr));

nếu (kích hoạt)
	 ifr.ifr_flags = IFF_ATTACH_QUEUE;
      khác
	 ifr.ifr_flags = IFF_DETACH_QUEUE;

trả về ioctl(fd, TUNSETQUEUE, (void *)&ifr);
  }

Trình điều khiển thiết bị Universal TUN/TAP Câu hỏi thường gặp
=========================================================

1. Trình điều khiển TUN/TAP hỗ trợ những nền tảng nào?

Hiện nay driver đã được viết cho 3 Unice:

- Nhân Linux 2.2.x, 2.4.x
  - FreeBSD 3.x, 4.x, 5.x
  - Solaris 2.6, 7.0, 8.0

2. Trình điều khiển TUN/TAP dùng để làm gì?

Như đã đề cập ở trên, mục đích chính của trình điều khiển TUN/TAP là đào hầm.
Nó được sử dụng bởi VTun (ZZ0000ZZ

Một ứng dụng thú vị khác sử dụng TUN/TAP là pipsecd
(ZZ0000ZZ một IPSec không gian người dùng
triển khai có thể sử dụng định tuyến hạt nhân hoàn chỉnh (không giống như FreeS/WAN).

3. Thực chất thiết bị mạng ảo hoạt động như thế nào?

Thiết bị mạng ảo có thể được xem như một thiết bị Point-to-Point đơn giản hoặc
Thiết bị Ethernet, thay vì nhận gói từ thiết bị vật lý
media, nhận chúng từ chương trình không gian người dùng và thay vì gửi
các gói thông qua phương tiện vật lý sẽ gửi chúng đến chương trình không gian người dùng.

Giả sử bạn đã định cấu hình IPv6 trên tap0 thì bất cứ khi nào
kernel gửi gói IPv6 tới tap0, nó được chuyển đến ứng dụng
(VTUn chẳng hạn). Ứng dụng mã hóa, nén và gửi nó tới
phía bên kia trên TCP hoặc UDP. Ứng dụng bên kia giải nén
và giải mã dữ liệu nhận được và ghi gói vào thiết bị TAP,
hạt nhân xử lý gói giống như nó đến từ thiết bị vật lý thực.

4. Sự khác biệt giữa trình điều khiển TUN và trình điều khiển TAP là gì?

TUN hoạt động với khung IP. TAP hoạt động với khung Ethernet.

Điều này có nghĩa là bạn phải đọc/ghi các gói IP khi bạn đang sử dụng tun và
khung ethernet khi sử dụng tap.

5. Sự khác biệt giữa trình điều khiển BPF và TUN/TAP là gì?

BPF là bộ lọc gói nâng cao. Nó có thể được gắn vào hiện có
giao diện mạng. Nó không cung cấp giao diện mạng ảo.
Trình điều khiển TUN/TAP cung cấp giao diện mạng ảo và có thể
để gắn BPF vào giao diện này.

6. Trình điều khiển TAP có hỗ trợ kết nối kernel Ethernet không?

Đúng. Trình điều khiển Linux và FreeBSD hỗ trợ kết nối Ethernet.