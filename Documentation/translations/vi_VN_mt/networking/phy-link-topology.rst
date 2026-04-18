.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/phy-link-topology.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _phy_link_topology:

=====================
Cấu trúc liên kết PHY
=====================

Tổng quan
=========

Việc biểu diễn cấu trúc liên kết PHY trong ngăn xếp mạng nhằm mục đích thể hiện
bố trí phần cứng cho bất kỳ liên kết Ethernet nhất định nào.

Giao diện Ethernet theo quan điểm của không gian người dùng không là gì ngoài một
ZZ0000ZZ, hiển thị các tùy chọn cấu hình
thông qua các lệnh ioctls kế thừa và ethtool netlink. Giả định cơ sở
khi thiết kế các API cấu hình này, liên kết trông giống như ::

+--------------+ +----------+ +--------------+
  ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ
  ZZ0003ZZ ------ ZZ0004ZZ ---- ZZ0005ZZ ---... sang LP
  +--------------+ +----------+ +--------------+
  cấu trúc net_device cấu trúc phy_device

Các lệnh cần định cấu hình PHY sẽ đi qua net_device.phydev
trường để tiếp cận PHY và thực hiện cấu hình liên quan.

Giả định này không còn phù hợp với các cấu trúc liên kết phức tạp hơn có thể phát sinh khi,
ví dụ: sử dụng bộ thu phát SFP (mặc dù đó không phải là trường hợp cụ thể duy nhất).

Ở đây, chúng ta có 2 kịch bản cơ bản. MAC có thể xuất ra một chuỗi được tuần tự hóa
giao diện, có thể được đưa trực tiếp vào lồng SFP, chẳng hạn như SGMII, 1000BaseX,
10GBaseR, v.v.

Cấu trúc liên kết khi đó trông như thế này (khi mô-đun SFP được lắp vào)::

+------+ SGMII +-------------+
  ZZ0000ZZ ------- ZZ0001ZZ
  +------+ +-----------+

Biết rằng một số mô-đun nhúng PHY, liên kết thực tế giống như ::

+------+ SGMII +--------------+
  ZZ0000ZZ -------- ZZ0001ZZ
  +------+ +--------------+

Trong trường hợp này, SFP PHY được phylib xử lý và được phyllink đăng ký thông qua
hoạt động ngược dòng SFP của nó.

Bây giờ một số bộ điều khiển Ethernet không thể xuất ra giao diện được tuần tự hóa, vì vậy
chúng tôi không thể kết nối trực tiếp chúng với lồng SFP. Tuy nhiên, một số PHY có thể được sử dụng
với tư cách là bộ chuyển đổi phương tiện, để dịch giao diện MAC MII không được tuần tự hóa sang giao diện
giao diện MII được tuần tự hóa được cung cấp cho SFP ::

+------+ RGMII +--------------+ SGMII +--------------+
  ZZ0000ZZ ------- ZZ0001ZZ ------- ZZ0002ZZ
  +------+ +--------------+ +--------------+

Đây là nơi mô hình có một con trỏ net_device.phydev duy nhất hiển thị
hạn chế vì hiện tại chúng tôi có 2 PHY trên liên kết.

Khung cấu trúc liên kết phy_link nhằm mục đích cung cấp một cách để theo dõi mọi
PHY trên liên kết, để sử dụng bởi cả trình điều khiển hạt nhân và hệ thống con, nhưng cũng để
báo cáo cấu trúc liên kết tới không gian người dùng, cho phép nhắm mục tiêu các PHY riêng lẻ trong cấu hình
lệnh.

API
===

ZZ0000ZZ là một thiết bị trên mỗi mạng
tài nguyên, được khởi tạo khi tạo netdevice. Một khi nó được khởi tạo,
sau đó có thể đăng ký PHY vào cấu trúc liên kết thông qua:

ZZ0000ZZ

Bên cạnh việc đăng ký PHY vào cấu trúc liên kết, lệnh gọi này cũng sẽ gán một địa chỉ duy nhất
lập chỉ mục cho PHY, sau đó có thể được báo cáo tới không gian người dùng để tham khảo PHY này
(giống như ifindex). Chỉ số này là u32, dao động từ 1 đến U32_MAX. giá trị
0 được dành riêng để cho biết PHY chưa thuộc bất kỳ cấu trúc liên kết nào.

PHY sau đó có thể được loại bỏ khỏi cấu trúc liên kết thông qua

ZZ0000ZZ

Các chức năng này đã được nối vào hệ thống con phylib, vì vậy tất cả các PHY
được liên kết với net_device thông qua ZZ0000ZZ sẽ tự động
tham gia cấu trúc liên kết của netdev.

PHY trên mô-đun SFP cũng sẽ được đăng ký tự động NẾU SFP
ngược dòng là phyllink (vì vậy, không có bộ chuyển đổi phương tiện).

Trình điều khiển PHY có thể được sử dụng làm SFP ngược dòng cần gọi ZZ0000ZZ
và ZZ0001ZZ, có thể được sử dụng như một
Triển khai .attach_phy / .detach_phy cho
ZZ0002ZZ.

UAPI
====

Tồn tại một tập hợp các lệnh netlink để truy vấn cấu trúc liên kết từ không gian người dùng,
xem ZZ0000ZZ.

Toàn bộ mục đích của việc biểu diễn cấu trúc liên kết là gán phyindex
trường trong ZZ0000ZZ. Chỉ số này được báo cáo
không gian người dùng bằng lệnh ZZ0001ZZ ethtnl. Thực hiện thao tác DUMP
sẽ dẫn đến tất cả PHY từ tất cả net_device được liệt kê. Lệnh DUMP
chấp nhận ZZ0002ZZ hoặc ZZ0003ZZ
được chuyển trong yêu cầu lọc DUMP thành một net_device duy nhất.

Chỉ mục được truy xuất sau đó có thể được chuyển dưới dạng tham số yêu cầu bằng cách sử dụng
Trường ZZ0000ZZ trong các lệnh ethnl sau:

* ZZ0000ZZ để lấy chuỗi thống kê được đặt từ PHY nhất định
* ZZ0001ZZ và ZZ0002ZZ, để biểu diễn
  kiểm tra cáp trên PHY nhất định trên liên kết (rất có thể là PHY ngoài cùng)
* ZZ0003ZZ và ZZ0004ZZ cho cài đặt PoE và PSE được kiểm soát bởi PHY
* ZZ0005ZZ, ZZ0006ZZ và ZZ0007ZZ
  để đặt tham số PLCA (Tránh va chạm lớp vật lý)

Lưu ý rằng chỉ mục PHY có thể được chuyển tới các yêu cầu khác, điều này sẽ âm thầm
bỏ qua nó nếu có và không liên quan.