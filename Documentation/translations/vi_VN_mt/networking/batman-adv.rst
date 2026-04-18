.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/batman-adv.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========
Batman-adv
==========

Batman nâng cao là một cách tiếp cận mới đối với mạng không dây không còn
hoạt động trên cơ sở IP. Không giống như daemon của Batman, nơi trao đổi thông tin
sử dụng các gói UDP và đặt bảng định tuyến, Batman-Advanced hoạt động trên ISO/OSI
Chỉ lớp 2 và sử dụng cũng như định tuyến (hoặc tốt hơn: cầu nối) Khung Ethernet. Nó
mô phỏng chuyển đổi mạng ảo của tất cả các nút tham gia. Vì thế tất cả
các nút dường như là liên kết cục bộ, do đó tất cả các giao thức vận hành cao hơn sẽ không được
bị ảnh hưởng bởi bất kỳ thay đổi nào trong mạng. Bạn có thể chạy hầu hết mọi giao thức
ở trên Batman nâng cao, ví dụ nổi bật là: IPv4, IPv6, DHCP, IPX.

Batman nâng cao được triển khai dưới dạng trình điều khiển nhân Linux để giảm chi phí
đến mức tối thiểu. Nó không phụ thuộc vào bất kỳ trình điều khiển mạng (khác) nào và có thể được sử dụng
trên wifi cũng như ethernet lan, vpn, v.v ... (bất cứ thứ gì có kiểu ethernet
lớp 2).


Cấu hình
=============

Tải mô-đun batman-adv vào kernel của bạn ::

$ insmod batman-adv.ko

Mô-đun hiện đang chờ kích hoạt. Bạn phải thêm một số giao diện trên đó
Batman-adv có thể hoạt động. Giao diện lưới Batman-adv có thể được tạo bằng cách sử dụng
công cụ iproute2 ZZ0000ZZ::

$ ip link thêm tên bat0 gõ batadv

Để kích hoạt một giao diện nhất định, chỉ cần gắn nó vào giao diện ZZ0000ZZ::

$ ip liên kết thiết lập dev eth0 master bat0

Lặp lại bước này cho tất cả các giao diện bạn muốn thêm. Bây giờ Batman-adv bắt đầu
sử dụng/phát sóng trên (các) giao diện này.

Để tắt một giao diện, bạn phải tách nó ra khỏi giao diện "bat0"::

$ ip liên kết đặt dev eth0 nomaster

Điều tương tự cũng có thể được thực hiện bằng cách sử dụng lệnh con giao diện batctl ::

batctl -m bat0 tạo giao diện
  giao diện batctl -m bat0 thêm -M eth0

Để tách eth0 và tiêu diệt bat0::

giao diện batctl -m bat0 del -M eth0
  giao diện batctl -m bat0 phá hủy

Có các cài đặt bổ sung cho từng giao diện lưới batadv, vlan và hardif
có thể được sửa đổi bằng cách sử dụng batctl. Thông tin chi tiết về điều này có thể được tìm thấy
trong hướng dẫn sử dụng của nó.

Ví dụ: bạn có thể kiểm tra khoảng thời gian khởi tạo hiện tại (giá trị
tính bằng mili giây, xác định tần suất batman-adv gửi chương trình phát sóng của nó
gói)::

$ batctl -M bat0 orig_interval
  1000

và cũng thay đổi giá trị của nó::

$ batctl -M bat0 orig_interval 3000

Trong các trường hợp rất di động, bạn có thể muốn điều chỉnh khoảng thời gian của người khởi tạo thành một
giá trị thấp hơn. Điều này sẽ làm cho lưới phản ứng nhanh hơn với những thay đổi cấu trúc liên kết, nhưng
cũng sẽ làm tăng chi phí.

Thông tin về trạng thái hiện tại có thể được truy cập thông qua chung batadv
gia đình netlink. batctl cung cấp phiên bản có thể đọc được cho con người thông qua các bảng gỡ lỗi của nó
các lệnh phụ.


Cách sử dụng
=====

Để sử dụng lưới mới tạo của bạn, Batman Advanced cung cấp một
giao diện "bat0" mà bạn nên sử dụng từ thời điểm này trở đi. Tất cả các giao diện được thêm vào
đến Batman nâng cao không còn phù hợp nữa vì Batman xử lý chúng cho
bạn. Về cơ bản, người ta "chuyển giao" dữ liệu bằng cách sử dụng giao diện Batman và
Batman sẽ đảm bảo nó đến đích.

Giao diện "bat0" có thể được sử dụng giống như bất kỳ giao diện thông thường nào khác. Nó cần một
Địa chỉ IP có thể được cấu hình tĩnh hoặc động (bằng cách sử dụng
DHCP hoặc các dịch vụ tương tự)::

NodeA: thiết lập liên kết ip dev bat0
  NodeA: ip addr thêm 192.168.0.1/24 dev bat0

NodeB: thiết lập liên kết ip dev bat0
  NútB: ip addr thêm 192.168.0.2/24 dev bat0
  NútB: ping 192.168.0.1

Lưu ý: Để tránh sự cố, hãy xóa tất cả các địa chỉ IP được gán trước đó cho
các giao diện hiện được Batman Advanced sử dụng, ví dụ:::

$ ip addr tuôn ra dev eth0


Ghi nhật ký/Gỡ lỗi
=================

Tất cả các thông báo lỗi, cảnh báo và thông tin đều được gửi đến kernel
nhật ký. Tùy thuộc vào phân phối hệ điều hành của bạn, điều này có thể được đọc bằng một trong các
một số cách. Hãy thử sử dụng các lệnh: ZZ0000ZZ, ZZ0001ZZ hoặc tìm trong
các tập tin ZZ0002ZZ hoặc ZZ0003ZZ. Tất cả tin nhắn Batman-adv
có tiền tố là "batman-adv:" Vì vậy, để xem những thông báo này, hãy thử ::

$dmesg | grep Batman-adv

Khi điều tra các vấn đề với mạng lưới của bạn, đôi khi cần phải
xem thông báo gỡ lỗi chi tiết hơn. Điều này phải được kích hoạt khi biên dịch
mô-đun Batman-adv. Khi xây dựng batman-adv như một phần của kernel, hãy sử dụng "make
menuconfig" và bật tùy chọn ZZ0000ZZ
(ZZ0001ZZ).

Những thông báo gỡ lỗi bổ sung đó có thể được truy cập bằng cơ sở hạ tầng hoàn hảo ::

$ trace-cmd luồng -e batadv:batadv_dbg

Đầu ra gỡ lỗi bổ sung theo mặc định bị tắt. Nó có thể được kích hoạt trong quá trình
thời gian chạy::

$ batctl -m bat0 tuyến loglevel tt

sẽ kích hoạt thông báo gỡ lỗi khi các tuyến đường và mục nhập bảng dịch thay đổi.

Bộ đếm các loại gói khác nhau vào và ra khỏi batman-adv
mô-đun có sẵn thông qua ethtool::

$ ethtool --statistics bat0


chiến đấu
======

Khi Batman Advanced hoạt động trên lớp 2, tất cả các máy chủ tham gia vào ảo
switch hoàn toàn trong suốt đối với tất cả các giao thức ở trên lớp 2. Do đó
các công cụ chẩn đoán thông thường không hoạt động như mong đợi. Để khắc phục những vấn đề này,
batctl đã được tạo. Hiện tại batctl chứa ping, traceroute, tcpdump
và giao diện với các cài đặt mô-đun hạt nhân.

Để biết thêm thông tin, vui lòng xem trang chủ (ZZ0000ZZ).

batctl có sẵn trên ZZ0000ZZ


Liên hệ
=======

Hãy gửi cho chúng tôi ý kiến, kinh nghiệm, câu hỏi, bất cứ điều gì :)

IRC:
  #batadv trên ircs://irc.hackint.org/
Danh sách gửi thư:
  b.a.t.m.a.n@lists.open-mesh.org (đăng ký tùy chọn tại
  ZZ0000ZZ

Bạn cũng có thể liên hệ với Tác giả:

* Marek Lindner <marek.lindner@mailbox.org>
* Simon Wunderlich <sw@simonwunderlich.de>