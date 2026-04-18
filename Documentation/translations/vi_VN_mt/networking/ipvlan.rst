.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/ipvlan.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
Trình điều khiển IPVLAN HOWTO
=============================

Phát hành lần đầu:
	Mahesh Bandewar <maheshb TẠI google.com>

1. Giới thiệu:
================
Về mặt khái niệm, điều này rất giống với trình điều khiển macvlan với một chức năng chính
ngoại trừ việc sử dụng L3 để trộn/giải mã giữa các nô lệ. Thuộc tính này làm cho
thiết bị chính chia sẻ L2 với các thiết bị phụ của nó. Tôi đã phát triển cái này
trình điều khiển kết hợp với không gian tên mạng và không chắc liệu có trường hợp sử dụng nào không
bên ngoài nó.


2. Thi công và lắp đặt:
=============================

Để build driver các bạn chọn mục config CONFIG_IPVLAN.
Trình điều khiển có thể được tích hợp vào kernel (CONFIG_IPVLAN=y) hoặc dưới dạng mô-đun
(CONFIG_IPVLAN=m).


3. Cấu hình:
=================

Không có tham số mô-đun nào cho trình điều khiển này và nó có thể được cấu hình
sử dụng tiện ích IProute2/ip.
::

liên kết ip thêm liên kết <master> tên <nô lệ> gõ ipvlan [ chế độ MODE ] [ FLAGS ]
       ở đâu
	 MODE: l3 (mặc định) ZZ0000ZZ l2
	 FLAGS: cầu (mặc định) ZZ0001ZZ vepa

ví dụ.

(a) Sau đây sẽ tạo liên kết IPvlan với eth0 làm chủ trong
	Chế độ cầu L3::

liên kết bash# ip thêm liên kết eth0 tên ipvl0 loại ipvlan
    (b) Lệnh này sẽ tạo liên kết IPvlan ở chế độ cầu L2::

liên kết bash# ip thêm liên kết eth0 tên ipvl0 loại ipvlan chế độ l2 cầu

(c) Lệnh này sẽ tạo một thiết bị IPvlan ở chế độ riêng tư L2::

liên kết bash# ip thêm liên kết eth0 tên ipvlan loại ipvlan chế độ l2 riêng tư

(d) Lệnh này sẽ tạo một thiết bị IPvlan ở chế độ L2 vepa::

liên kết bash# ip thêm liên kết eth0 tên ipvlan loại ipvlan chế độ l2 vepa


4. Các chế độ hoạt động:
===================

IPvlan có hai chế độ hoạt động - L2 và L3. Đối với một thiết bị chính nhất định,
bạn có thể chọn một trong hai chế độ này và tất cả các nô lệ trên chế độ chủ đó sẽ
hoạt động ở cùng chế độ (đã chọn). Chế độ RX gần như giống hệt nhau ngoại trừ
rằng ở chế độ L3, các máy phụ sẽ không nhận được bất kỳ lưu lượng phát đa hướng/phát sóng nào.
Chế độ L3 hạn chế hơn do việc định tuyến được điều khiển từ chế độ khác (chủ yếu)
không gian tên mặc định.

4.1 Chế độ L2:
------------

Trong chế độ này, quá trình xử lý TX xảy ra trên phiên bản ngăn xếp được gắn vào
thiết bị phụ và các gói được chuyển mạch và xếp hàng tới thiết bị chính để gửi
ra ngoài. Ở chế độ này, các máy phụ sẽ phát đa hướng và phát sóng RX/TX (nếu có)
cũng vậy.

4.2 Chế độ L3:
------------

Ở chế độ này, việc xử lý TX lên tới L3 xảy ra trên phiên bản ngăn xếp được đính kèm
tới thiết bị phụ và các gói được chuyển sang thể hiện ngăn xếp của
thiết bị chính để xử lý và định tuyến L2 từ phiên bản đó sẽ là
được sử dụng trước khi các gói được xếp hàng đợi trên thiết bị gửi đi. Trong chế độ này, nô lệ
sẽ không nhận cũng như không thể gửi lưu lượng multicast/broadcast.

4.3 Chế độ L3S:
-------------

Chế độ này rất giống với chế độ L3 ngoại trừ iptables (theo dõi kết nối)
hoạt động ở chế độ này và do đó nó có tính đối xứng L3 (L3s). Điều này sẽ có ít hơn một chút
hiệu suất nhưng điều đó không thành vấn đề vì bạn đang chọn chế độ này thay vì L3 đơn giản
chế độ để thực hiện công việc theo dõi liên kết.

5. Cờ chế độ:
==============

Tại thời điểm này, các cờ chế độ sau có sẵn

Cầu 5.1:
-----------
Đây là tùy chọn mặc định. Để định cấu hình cổng IPvlan ở chế độ này,
người dùng có thể chọn thêm tùy chọn này trên dòng lệnh hoặc không chỉ định
bất cứ điều gì. Đây là chế độ truyền thống nơi nô lệ có thể trao đổi chéo giữa
bản thân họ ngoài việc nói chuyện qua thiết bị chính.

5.2 riêng tư:
------------
Nếu tùy chọn này được thêm vào dòng lệnh, cổng sẽ được đặt ở chế độ riêng tư
chế độ. tức là cổng sẽ không cho phép liên lạc chéo giữa các nô lệ.

5.3 vepa:
---------
Nếu điều này được thêm vào dòng lệnh, cổng được đặt ở chế độ VEPA.
tức là cổng sẽ giảm tải chức năng chuyển đổi cho thực thể bên ngoài như
được mô tả trong 802.1Qbg
Lưu ý: Chế độ VEPA trong IPvlan có những hạn chế. IPvlan sử dụng địa chỉ mac của
thiết bị chính, do đó các gói được phát ở chế độ này cho thiết bị lân cận
hàng xóm sẽ có mac nguồn và đích giống nhau. Điều này sẽ thực hiện chuyển đổi /
bộ định tuyến gửi tin nhắn chuyển hướng.

6. Chọn gì (macvlan so với ipvlan)?
=======================================

Hai thiết bị này rất giống nhau về nhiều mặt và cách sử dụng cụ thể
trường hợp có thể xác định rất rõ nên chọn thiết bị nào. nếu một trong những điều sau đây
tình huống xác định trường hợp sử dụng của bạn thì bạn có thể chọn sử dụng ipvlan:


(a) Máy chủ Linux được kết nối với bộ chuyển mạch/bộ định tuyến bên ngoài có
    chính sách được định cấu hình chỉ cho phép một máy Mac trên mỗi cổng.
(b) Không có thiết bị ảo nào được tạo trên máy chủ vượt quá dung lượng mac và
    đặt NIC ở chế độ lăng nhăng và hiệu suất suy giảm là điều đáng lo ngại.
(c) Nếu thiết bị phụ được đưa vào mạng thù địch/không tin cậy
    không gian tên nơi L2 trên nô lệ có thể bị thay đổi/sử dụng sai mục đích.


6. Cấu hình ví dụ:
=========================

::

+=========================================================================================================
  ZZ0000ZZ
  ZZ0001ZZ
  ZZ0002ZZ
  ZZ0003ZZ NS:ns0 ZZ0004ZZ NS:ns1 ZZ0005ZZ
  ZZ0006ZZ ZZ0007ZZ ZZ0008ZZ
  ZZ0009ZZ ZZ0010ZZ ZZ0011ZZ
  ZZ0012ZZ ipvl0 ZZ0013ZZ ipvl1 ZZ0014ZZ
  ZZ0015ZZ
  ZZ0016ZZ
  ZZ0017ZZ
  ZZ0018ZZ
  +==============================================================================================================


(a) Tạo hai không gian tên mạng - ns0, ns1::

mạng ip thêm ns0
	mạng ip thêm ns1

(b) Tạo hai nô lệ ipvlan trên eth0 (thiết bị chính)::

liên kết ip thêm liên kết eth0 ipvl0 loại ipvlan chế độ l2
	liên kết ip thêm liên kết eth0 ipvl1 loại ipvlan chế độ l2

(c) Chỉ định nô lệ cho các không gian tên mạng tương ứng::

bộ liên kết ip dev ipvl0 netns ns0
	bộ liên kết ip dev ipvl1 netns ns1

(d) Bây giờ chuyển sang không gian tên (ns0 hoặc ns1) để định cấu hình các thiết bị phụ

- Đối với ns0::

(1) ip netns exec ns0 bash
		(2) liên kết ip thiết lập dev ipvl0 lên
		(3) liên kết ip được thiết lập dev lo up
		(4) ip -4 addr thêm 127.0.0.1 dev lo
		(5) địa chỉ ip -4 thêm $IPADDR dev ipvl0
		(6) tuyến ip -4 thêm mặc định qua $ROUTER dev ipvl0

- Đối với ns1::

(1) ip netns exec ns1 bash
		(2) liên kết ip thiết lập dev ipvl1 lên
		(3) liên kết ip được thiết lập dev lo up
		(4) ip -4 addr thêm 127.0.0.1 dev lo
		(5) địa chỉ ip -4 thêm $IPADDR dev ipvl1
		(6) tuyến ip -4 thêm mặc định qua $ROUTER dev ipvl1