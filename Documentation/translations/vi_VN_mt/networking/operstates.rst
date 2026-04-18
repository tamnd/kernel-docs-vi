.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/operstates.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================
Các trạng thái hoạt động
========================


1. Giới thiệu
===============

Linux phân biệt giữa trạng thái quản trị và hoạt động của một
giao diện. Trạng thái quản trị là kết quả của "ip link set dev
<dev> lên hoặc xuống" và phản ánh liệu quản trị viên có muốn sử dụng hay không
thiết bị dành cho giao thông.

Tuy nhiên, một giao diện không thể sử dụng được chỉ vì quản trị viên đã kích hoạt nó
- ethernet yêu cầu phải được cắm vào bộ chuyển mạch và tùy thuộc vào
chính sách và cấu hình mạng của trang web, xác thực 802.1X
được thực hiện trước khi dữ liệu người dùng có thể được chuyển giao. Trạng thái hoạt động
cho thấy khả năng của một giao diện để truyền dữ liệu người dùng này.

Nhờ 802.1X, không gian người dùng phải được cấp khả năng
ảnh hưởng đến trạng thái hoạt động. Để đáp ứng điều này, trạng thái hoạt động là
chia thành hai phần: Hai cờ chỉ có thể được đặt bởi người lái xe và
trạng thái tương thích RFC2863 bắt nguồn từ các cờ này, chính sách,
và có thể thay đổi từ không gian người dùng theo các quy tắc nhất định.


2. Truy vấn từ không gian người dùng
====================================

Cả trạng thái quản trị và hoạt động đều có thể được truy vấn thông qua liên kết mạng
hoạt động RTM_GETLINK. Cũng có thể đăng ký RTNLGRP_LINK
để được thông báo cập nhật trong khi giao diện quản trị được bật lên. Đây là
quan trọng để cài đặt từ không gian người dùng.

Các giá trị này chứa trạng thái giao diện:

ifinfomsg::if_flags & IFF_UP:
 Giao diện được quản trị viên lên

ifinfomsg::if_flags & IFF_RUNNING:
 Giao diện ở trạng thái hoạt động RFC2863 UP hoặc UNKNOWN. Cái này dành cho
 khả năng tương thích ngược, trình nền định tuyến, máy khách dhcp có thể sử dụng điều này
 cờ để xác định xem họ có nên sử dụng giao diện hay không.

ifinfomsg::if_flags & IFF_LOWER_UP:
 Trình điều khiển đã ra tín hiệu netif_carrier_on()

ifinfomsg::if_flags & IFF_DORMANT:
 Trình điều khiển đã báo hiệu netif_dormant_on()

TLV IFLA_OPERSTATE
------------------

chứa trạng thái RFC2863 của giao diện ở dạng biểu diễn số:

IF_OPER_UNKNOWN (0):
 Giao diện ở trạng thái không xác định, cả trình điều khiển và không gian người dùng đều chưa được thiết lập
 trạng thái vận hành. Giao diện phải được xem xét đối với dữ liệu người dùng như
 thiết lập trạng thái hoạt động chưa được triển khai ở mọi trình điều khiển.

IF_OPER_NOTPRESENT (1):
 Không được sử dụng trong kernel hiện tại (các giao diện không hiện diện thường biến mất),
 chỉ là một phần giữ chỗ bằng số.

IF_OPER_DOWN (2):
 Giao diện không thể truyền dữ liệu trên L1, f.e. ethernet thì không
 đã cắm hoặc giao diện ADMIN bị hỏng.

IF_OPER_LOWERLAYERDOWN (3):
 Các giao diện được xếp chồng lên nhau trên giao diện IF_OPER_DOWN hiển thị điều này
 trạng thái (ví dụ VLAN).

IF_OPER_TESTING (4):
 Giao diện ở chế độ thử nghiệm, ví dụ thực hiện tự kiểm tra trình điều khiển
 hoặc kiểm tra phương tiện (cáp). Nó không thể được sử dụng cho giao thông bình thường cho đến khi kiểm tra
 hoàn thành.

IF_OPER_DORMANT (5):
 Giao diện đang hoạt động L1 nhưng đang chờ sự kiện bên ngoài, f.e. cho một
 giao thức để thiết lập. (802.1X)

IF_OPER_UP (6):
 Giao diện đang hoạt động và có thể sử dụng được.

TLV này cũng có thể được truy vấn thông qua sysfs.

TLV IFLA_LINKMODE
-----------------

chứa chính sách liên kết. Điều này là cần thiết cho sự tương tác không gian người dùng
được mô tả dưới đây.

TLV này cũng có thể được truy vấn thông qua sysfs.


3. Trình điều khiển hạt nhân API
================================

Trình điều khiển hạt nhân có quyền truy cập vào hai cờ ánh xạ tới IFF_LOWER_UP và
IFF_DORMANT. Những lá cờ này có thể được đặt từ mọi nơi, thậm chí từ
ngắt quãng. Nó được đảm bảo rằng chỉ có trình điều khiển mới có quyền truy cập ghi,
tuy nhiên, nếu các lớp khác nhau của trình điều khiển thao tác cùng một cờ,
trình điều khiển phải cung cấp sự đồng bộ hóa cần thiết.

__LINK_STATE_NOCARRIER, ánh xạ tới !IFF_LOWER_UP:

Trình điều khiển sử dụng netif_carrier_on() để xóa và netif_carrier_off() để
đặt cờ này. Trên netif_carrier_off(), bộ lập lịch ngừng gửi
gói. Cái tên 'người vận chuyển' và sự đảo ngược mang tính lịch sử, hãy nghĩ đến
nó là lớp thấp hơn.

Lưu ý rằng đối với một số loại thiết bị phần mềm nhất định không quản lý bất kỳ
phần cứng thực, có thể thiết lập bit này từ không gian người dùng.  một
nên sử dụng TLV IFLA_CARRIER để làm điều đó.

netif_carrier_ok() có thể được sử dụng để truy vấn bit đó.

__LINK_STATE_DORMANT, ánh xạ tới IFF_DORMANT:

Được thiết lập bởi trình điều khiển để thể hiện rằng thiết bị chưa thể sử dụng được
bởi vì một số thiết lập giao thức điều khiển bằng trình điều khiển phải
hoàn thành. Các hàm tương ứng là netif_dormant_on() để thiết lập
gắn cờ, netif_dormant_off() để xóa nó và netif_dormant() để truy vấn.

Khi phân bổ thiết bị, cả hai cờ __LINK_STATE_NOCARRIER và
__LINK_STATE_DORMANT bị xóa nên trạng thái hiệu dụng tương đương
tới netif_carrier_ok() và !netif_dormant().


Bất cứ khi nào trình điều khiển CHANGES có một trong những lá cờ này, một sự kiện hàng đợi công việc sẽ diễn ra
được lên lịch dịch tổ hợp cờ sang IFLA_OPERSTATE dưới dạng
sau:

!netif_carrier_ok():
 IF_OPER_LOWERLAYERDOWN nếu giao diện được xếp chồng lên nhau, IF_OPER_DOWN
 mặt khác. Hạt nhân có thể nhận ra các giao diện xếp chồng vì chúng
 ifindex != iflink.

netif_carrier_ok() && netif_dormant():
 IF_OPER_DORMANT

netif_carrier_ok() && !netif_dormant():
 IF_OPER_UP nếu tương tác không gian người dùng bị tắt. Nếu không
 IF_OPER_DORMANT với khả năng không gian người dùng bắt đầu
 Chuyển đổi IF_OPER_UP sau đó.


4. Cài đặt từ không gian người dùng
===================================

Các ứng dụng phải sử dụng giao diện netlink để tác động đến
RFC2863 trạng thái hoạt động của một giao diện. Đặt IFLA_LINKMODE thành 1
thông qua RTM_SETLINK hướng dẫn kernel rằng giao diện sẽ đi tới
IF_OPER_DORMANT thay vì IF_OPER_UP khi kết hợp
netif_carrier_ok() && !netif_dormant() được thiết lập bởi
người lái xe. Sau đó, ứng dụng không gian người dùng có thể đặt IFLA_OPERSTATE
sang IF_OPER_DORMANT hoặc IF_OPER_UP miễn là trình điều khiển không đặt
netif_carrier_off() hoặc netif_dormant_on(). Những thay đổi được thực hiện bởi không gian người dùng
được phát đa hướng trên nhóm netlink RTNLGRP_LINK.

Vì vậy, về cơ bản, trình thay thế 802.1X tương tác với kernel như thế này:

- đăng ký RTNLGRP_LINK
- đặt IFLA_LINKMODE thành 1 qua RTM_SETLINK
- truy vấn RTM_GETLINK một lần để có trạng thái ban đầu
- nếu cờ ban đầu không phải là (IFF_LOWER_UP && !IFF_DORMANT), hãy đợi cho đến khi
  netlink multicast báo hiệu trạng thái này
- thực hiện 802.1X, cuối cùng hủy bỏ nếu cờ lại xuống
- gửi RTM_SETLINK để đặt trạng thái hoạt động thành IF_OPER_UP nếu xác thực
  thành công, IF_OPER_DORMANT nếu không
- xem cách hoạt động và IFF_RUNNING được lặp lại thông qua multicast liên kết mạng
- đặt giao diện trở lại IF_OPER_DORMANT nếu xác thực lại 802.1X
  thất bại
- khởi động lại nếu kernel thay đổi cờ IFF_LOWER_UP hoặc IFF_DORMANT

nếu chất cầu xin bị hỏng, hãy đưa IFLA_LINKMODE về 0 và
IFLA_OPERSTATE về giá trị hợp lý.

Một daemon định tuyến hoặc máy khách dhcp chỉ cần quan tâm đến IFF_RUNNING hoặc
chờ trạng thái vận hành hoạt động IF_OPER_UP/IF_OPER_UNKNOWN trước đó
xem xét giao diện/truy vấn địa chỉ DHCP.


Đối với các câu hỏi và/hoặc ý kiến về kỹ thuật, vui lòng gửi email tới Stefan Rompf
(stefan tại loplof.de).