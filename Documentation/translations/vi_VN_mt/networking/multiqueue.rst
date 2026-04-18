.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/multiqueue.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===============================================
HOWTO để hỗ trợ thiết bị mạng nhiều hàng đợi
===========================================

Phần 1: Yêu cầu trình điều khiển cơ bản để triển khai hỗ trợ nhiều hàng đợi
=======================================================================

Giới thiệu: Hỗ trợ hạt nhân cho các thiết bị nhiều hàng đợi
---------------------------------------------------------

Hỗ trợ hạt nhân cho các thiết bị nhiều hàng đợi luôn hiện diện.

Trình điều khiển cơ sở được yêu cầu sử dụng alloc_etherdev_mq() mới hoặc
alloc_netdev_mq() để phân bổ các hàng đợi con cho thiết bị.  các
kernel cơ bản API sẽ đảm nhiệm việc phân bổ và giải phóng
bộ nhớ hàng đợi con cũng như cấu hình netdev nơi hàng đợi
tồn tại trong bộ nhớ.

Trình điều khiển cơ sở cũng sẽ cần quản lý hàng đợi giống như trình điều khiển chung
netdev->queue_lock ngay hôm nay.  Do đó trình điều khiển cơ sở nên sử dụng
netif_{start|stop|wake__subqueue() có chức năng quản lý từng hàng đợi trong khi
thiết bị vẫn hoạt động.  netdev->queue_lock vẫn được sử dụng khi thiết bị
trực tuyến hoặc khi nó tắt hoàn toàn (unregister_netdev(), v.v.).


Phần 2: Hỗ trợ Qdisc cho các thiết bị nhiều hàng đợi
===============================================

Hiện tại hai qdisc được tối ưu hóa cho các thiết bị nhiều hàng đợi.  Đầu tiên là
pfifo_fast qdisc mặc định.  Qdisc này hỗ trợ một qdisc cho mỗi hàng đợi phần cứng.
Một qdisc quay vòng mới, sch_multiq cũng hỗ trợ nhiều hàng đợi phần cứng. các
qdisc chịu trách nhiệm phân loại skb và sau đó hướng skb đến
các dải và hàng đợi dựa trên giá trị trong skb->queue_mapping.  Sử dụng trường này trong
trình điều khiển cơ sở để xác định hàng đợi nào sẽ gửi skb tới.

sch_multiq đã được thêm vào cho phần cứng muốn tránh tình trạng đầu hàng
chặn.  Nó sẽ quay vòng qua các băng tần và xác minh rằng hàng đợi phần cứng
liên kết với băng tần không bị dừng lại trước khi loại bỏ gói tin.

Khi tải qdisc, số lượng băng tần dựa trên số lượng hàng đợi trên
phần cứng.  Sau khi liên kết được thực hiện, bất kỳ skb nào có bộ skb->queue_mapping,
sẽ được xếp hàng vào băng tần được liên kết với hàng đợi phần cứng.


Phần 3: Tóm tắt cách sử dụng MULTIQ cho thiết bị nhiều hàng đợi
==========================================================

Lệnh không gian người dùng 'tc', một phần của gói iproute2, được sử dụng để định cấu hình
qdiscs.  Để thêm qdisc MULTIQ vào thiết bị mạng của bạn, giả sử thiết bị
được gọi là eth0, hãy chạy lệnh sau ::

# tc qdisc thêm tay cầm gốc dev eth0 1: multiq

Qdisc sẽ phân bổ số lượng băng tần bằng số lượng hàng đợi
thiết bị báo cáo và đưa qdisc trực tuyến.  Giả sử eth0 có 4 Tx
hàng đợi, ánh xạ băng tần sẽ trông như sau::

băng tần 0 => hàng đợi 0
    băng tần 1 => hàng đợi 1
    băng tần 2 => hàng đợi 2
    băng tần 3 => hàng đợi 3

Lưu lượng truy cập sẽ bắt đầu chảy qua từng hàng đợi dựa trên simple_tx_hash
hoặc dựa trên netdev->select_queue() nếu bạn đã xác định nó.

Hoạt động của bộ lọc tc vẫn giữ nguyên.  Tuy nhiên, một hành động tc mới,
skbedit, đã được thêm vào.  Giả sử bạn muốn định tuyến tất cả lưu lượng truy cập đến một
máy chủ cụ thể, ví dụ 192.168.0.3, thông qua hàng đợi cụ thể mà bạn có thể sử dụng
hành động này và thiết lập bộ lọc như::

bộ lọc tc thêm dev eth0 parent 1: giao thức ip ưu tiên 1 u32 \
	    khớp ip dst 192.168.0.3 \
	    hành động skbedit queue_mapping 3

:Tác giả: Alexander Duyck <alexander.h.duyck@intel.com>
:Tác giả gốc: Peter P. Waskiewicz Jr. <peter.p.waskiewicz.jr@intel.com>