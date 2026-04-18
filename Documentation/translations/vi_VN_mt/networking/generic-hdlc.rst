.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/generic-hdlc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================
Lớp HDLC chung
====================

Krzysztof Halasa <khc@pm.waw.pl>


Lớp HDLC chung hiện hỗ trợ:

1. Rơle khung (ANSI, CCITT, Cisco và không có LMI)

- Bình thường (định tuyến) và cầu nối Ethernet (mô phỏng thiết bị Ethernet)
     giao diện có thể chia sẻ một PVC duy nhất.
   - Hỗ trợ ARP (không hỗ trợ InARP trong kernel - có một
     daemon không gian người dùng InARP thử nghiệm có sẵn trên:
     ZZ0000ZZ

2. HDLC thô - giao diện IP (IPv4) hoặc mô phỏng thiết bị Ethernet
3. Cisco HDLC
4. PPP
5. X.25 (sử dụng các thủ tục X.25).

HDLC chung chỉ là trình điều khiển giao thức - nó cần trình điều khiển cấp thấp
cho phần cứng cụ thể của bạn.

Tương thích mô phỏng thiết bị Ethernet (sử dụng HDLC hoặc Frame-Relay PVC)
với IEEE 802.1Q (Vlan) và 802.1D (cầu nối Ethernet).


Đảm bảo hdlc.o và trình điều khiển phần cứng đã được tải. Nó nên
tạo một số thiết bị mạng "hdlc" (hdlc0, v.v.), mỗi thiết bị cho một thiết bị mạng
Cổng WAN. Bạn sẽ cần tiện ích "sethdlc", lấy nó từ:

ZZ0000ZZ

Biên dịch tiện ích sethdlc.c::

gcc -O2 -Wall -o sethdlc sethdlc.c

Đảm bảo bạn đang sử dụng đúng phiên bản sethdlc cho kernel của mình.

Sử dụng sethdlc để đặt giao diện vật lý, tốc độ xung nhịp, chế độ HDLC được sử dụng,
và thêm bất kỳ PVC cần thiết nào nếu sử dụng Frame Relay.
Thông thường bạn muốn một cái gì đó như ::

sethdlc hdlc0 tốc độ int đồng hồ 128000
	sethdlc hdlc0 cisco khoảng thời gian 10 thời gian chờ 25

hoặc::

sethdlc hdlc0 rs232 máy lẻ đồng hồ
	sethdlc hdlc0 từ lmi ansi
	sethdlc hdlc0 tạo 99
	ifconfig hdlc0 lên
	ifconfig PVC0 localIP pointopoint remoteIP

Trong chế độ Frame Relay, thiết bị ifconfig master hdlc được bật lên (không gán
bất kỳ địa chỉ IP nào vào nó) trước khi sử dụng thiết bị PVC.


Giao diện cài đặt:

* v35 ZZ0000ZZ x21 ZZ0001ZZ e1
    - đặt giao diện vật lý cho một cổng nhất định
      nếu thẻ có giao diện có thể lựa chọn bằng phần mềm
  vòng lặp lại
    - kích hoạt loopback phần cứng (chỉ để thử nghiệm)
* đồng hồ mở rộng
    - cả đồng hồ RX và đồng hồ TX bên ngoài
* đồng hồ int
    - cả đồng hồ RX và đồng hồ TX bên trong
* tin nhắn đồng hồ
    - Đồng hồ RX bên ngoài, đồng hồ TX bên trong
* đồng hồ txfromrx
    - Đồng hồ RX bên ngoài, đồng hồ TX có nguồn gốc từ đồng hồ RX
* tỷ lệ
    - đặt tốc độ xung nhịp tính bằng bps (chỉ dành cho đồng hồ "int" hoặc "txint")


Giao thức cài đặt:

* hdlc - đặt chế độ HDLC (chỉ IP) thô

nrz / nrzi / fm-mark / fm-space / manchester - đặt mã truyền

không chẵn lẻ / crc16 / crc16-pr0 (CRC16 với các số 0 đặt trước) / crc32-itu

crc16-itu (CRC16 với đa thức ITU-T) / crc16-itu-pr0 - đặt tính chẵn lẻ

* hdlc-eth - Mô phỏng thiết bị Ethernet bằng HDLC. Tính chẵn lẻ và mã hóa
  như trên.

* cisco - đặt chế độ Cisco HDLC (hỗ trợ IP, IPv6 và IPX)

khoảng thời gian - thời gian tính bằng giây giữa các gói lưu giữ

thời gian chờ - thời gian tính bằng giây sau lần cuối nhận được gói tin lưu giữ trước đó
	    chúng tôi cho rằng liên kết đã ngừng hoạt động

* ppp - đặt chế độ PPP đồng bộ

* x25 - đặt chế độ X.25

* fr - Chế độ chuyển tiếp khung

lmi ansi / ccitt / cisco / none - loại LMI (quản lý liên kết)

dce - Frame Relay DCE (mạng) bên LMI thay vì DTE mặc định (người dùng).

Nó không liên quan gì đến đồng hồ cả!

- t391 - bộ đếm thời gian bỏ phiếu xác minh tính toàn vẹn của liên kết (tính bằng giây) - người dùng
  - t392 - hẹn giờ xác minh bỏ phiếu (tính bằng giây) - mạng
  - n391 - bộ đếm thăm dò trạng thái đầy đủ - người dùng
  - n392 - ngưỡng lỗi - cả người dùng và mạng
  - n393 - số lượng sự kiện được giám sát - cả người dùng và mạng

Chỉ chuyển tiếp khung:

* tạo n | delete n - thêm/xóa giao diện PVC với DLCI #n.
  Giao diện mới tạo sẽ có tên là PVC0, PVC1, v.v.

* tạo ether n | xóa ether n - thêm một thiết bị cho cầu nối Ethernet
  khung. Thiết bị sẽ được đặt tên là PVCeth0, PVCeth1, v.v.




Các vấn đề cụ thể của HĐQT
--------------------------

n2.o và c101.o cần tham số để hoạt động ::

insmod n2 hw=io,irq,ram,ports[:io,irq,...]

ví dụ::

insmod n2 hw=0x300,10,0xD0000,01

hoặc::

insmod c101 hw=irq,ram[:irq,...]

ví dụ::

insmod c101 hw=9,0xdc000

Nếu được tích hợp trong kernel, các trình điều khiển này cần có tham số kernel (dòng lệnh)::

n2.hw=io,irq,ram,port:...

hoặc::

c101.hw=irq,ram:...



Nếu bạn gặp vấn đề với thẻ N2, C101 hoặc PLX200SYN, bạn có thể phát hành thẻ
Lệnh "riêng tư" để xem các vòng mô tả gói của cổng (trong nhật ký kernel)::

sethdlc hdlc0 riêng tư

Trình điều khiển phần cứng phải được xây dựng bằng #define DEBUG_RINGS.
Việc đính kèm thông tin này vào báo cáo lỗi sẽ hữu ích. Dù sao đi nữa, hãy cho tôi biết
nếu bạn gặp vấn đề khi sử dụng cái này.

Để biết các bản vá và thông tin khác, hãy xem:
<ZZ0000ZZ