.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/gtp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================================
Mô-đun đường hầm GTP của nhân Linux
=====================================

Tài liệu của
		 Harald Welte <laforge@gnumonks.org> và
		 Andreas Schultz <aschultz@tpip.net>

Trong 'drivers/net/gtp.c' bạn đang tìm cách triển khai cấp hạt nhân
của điểm cuối đường hầm GTP.

GTP là gì
===========

GTP là Giao thức đường hầm chung, là giao thức 3GPP được sử dụng cho
đào hầm tải trọng IP người dùng giữa một trạm di động (điện thoại, modem)
và kết nối giữa mạng dữ liệu gói bên ngoài (như
như internet).

Vì vậy, khi bạn bắt đầu 'kết nối dữ liệu' từ điện thoại di động của mình,
điện thoại sẽ sử dụng mặt phẳng điều khiển để báo hiệu việc thiết lập
như một đường hầm giữa mạng dữ liệu bên ngoài và điện thoại.  các
do đó các điểm cuối đường hầm nằm trên điện thoại và tại cổng.  Tất cả
các nút trung gian chỉ vận chuyển gói được đóng gói.

Bản thân điện thoại không triển khai GTP mà sử dụng một số thứ khác
ngăn xếp giao thức phụ thuộc vào công nghệ để truyền IP người dùng
tải trọng, chẳng hạn như LLC/SNDCP/RLC/MAC.

Tại một số thành phần mạng bên trong cơ sở hạ tầng của nhà điều hành mạng di động
(SGSN trong trường hợp GPRS/EGPRS hoặc UMTS cổ điển, hNodeB trong trường hợp 3G
femtocell, eNodeB trong trường hợp 4G/LTE), xếp chồng giao thức di động
được dịch sang GTP ZZ0000ZZ.  Vì vậy
các nút trung gian chỉ thực hiện một số chức năng chuyển tiếp cụ thể.

Tại một thời điểm nào đó, gói GTP kết thúc trên cái gọi là GGSN (GSM/UMTS)
hoặc P-GW (LTE), kết thúc đường hầm, giải mã gói
và chuyển tiếp nó vào mạng dữ liệu gói bên ngoài.  Đây có thể là
Internet công cộng, nhưng cũng có thể là bất kỳ mạng IP riêng nào (hoặc thậm chí
về mặt lý thuyết là một số mạng không phải IP như X.25).

Bạn có thể tìm thấy đặc tả giao thức trong 3GPP TS 29.060, có sẵn
công khai thông qua trang web 3GPP tại ZZ0000ZZ

Liên kết PDF trực tiếp tới v13.6.0 được cung cấp để thuận tiện dưới đây:
ZZ0000ZZ

Mô-đun đường hầm Linux GTP
===============================

Mô-đun này thực hiện chức năng của điểm cuối đường hầm, tức là nó
có thể giải mã các gói IP được tạo đường hầm trong đường lên có nguồn gốc từ
điện thoại và đóng gói các gói IP thô nhận được từ bên ngoài
mạng gói trong đường xuống về phía điện thoại.

Nó ZZ0000ZZ triển khai cái gọi là 'mặt phẳng người dùng', mang IP người dùng
tải trọng, được gọi là GTP-U.  Nó không thực hiện 'mặt phẳng điều khiển',
là một giao thức báo hiệu được sử dụng để thiết lập và hủy bỏ
Đường hầm GTP (GTP-C).

Vì vậy, để thiết lập GGSN/P-GW hoạt động, bạn sẽ cần một
chương trình không gian người dùng thực hiện giao thức GTP-C và sau đó
sử dụng giao diện netlink được cung cấp bởi mô-đun GTP-U trong kernel
để cấu hình mô-đun hạt nhân.

Kiến trúc phân chia này tuân theo các mô-đun đường hầm của các mô-đun khác
các giao thức, ví dụ: PPPoE hoặc L2TP, nơi bạn cũng chạy daemon không gian người dùng
để xử lý việc thiết lập đường hầm, xác thực, v.v. và chỉ
mặt phẳng dữ liệu được tăng tốc bên trong kernel.

Đừng nhầm lẫn với thuật ngữ: Mặt phẳng người dùng GTP đi qua
đường dẫn tăng tốc kernel, trong khi Mặt phẳng điều khiển GTP đi đến
Không gian người dùng :)

Trang chủ chính thức của mô-đun là tại
ZZ0000ZZ

Các chương trình không gian người dùng có hỗ trợ Linux Kernel GTP-U
==================================================

Tại thời điểm viết bài này, có ít nhất hai Phần mềm Tự do
triển khai triển khai GTP-C và có thể sử dụng giao diện netlink
để sử dụng hỗ trợ GTP-U của nhân Linux:

* OpenGGSN (2G/3G GGSN cổ điển trong C):
  ZZ0000ZZ

* ergw (GGSN + P-GW trong Erlang):
  ZZ0000ZZ

Thư viện không gian người dùng / Tiện ích dòng lệnh
==========================================

Có một thư viện không gian người dùng tên là 'libgtpnl' dựa trên
libmnl và triển khai API ngôn ngữ C hướng tới liên kết mạng
giao diện được cung cấp bởi mô-đun Kernel GTP:

ZZ0000ZZ

Phiên bản giao thức
=================

Có hai phiên bản khác nhau của GTP-U: v0 [GSM TS 09.60] và v1
[3GPP TS 29.281].  Cả hai đều được triển khai trong mô-đun Kernel GTP.
Phiên bản 0 là phiên bản cũ và không được dùng nữa từ 3GPP gần đây
thông số kỹ thuật.

GTP-U sử dụng UDP để vận chuyển PDU.  Cổng UDP nhận là 2151
cho GTPv1-U và 3386 cho GTPv0-U.

Có ba phiên bản GTP-C: v0, v1 và v2.  Là hạt nhân
không triển khai GTP-C, chúng ta không phải lo lắng về điều này.  Đó là
trách nhiệm triển khai mặt phẳng điều khiển trong không gian người dùng để
thực hiện điều đó.

IPv6
====

Thông số kỹ thuật 3GPP cho biết có thể sử dụng cả IPv4 hoặc IPv6
trên lớp IP bên trong (người dùng) hoặc trên lớp bên ngoài (vận chuyển).

Thật không may, mô-đun Kernel hiện không hỗ trợ IPv6 cho
tải trọng IP người dùng cũng như lớp IP bên ngoài.  Các bản vá hoặc khác
Đóng góp để khắc phục điều này được chào đón nhiều nhất!

Danh sách gửi thư
============

Nếu bạn có thắc mắc về cách sử dụng mô-đun Kernel GTP từ
phần mềm của riêng bạn hoặc muốn đóng góp vào mã, vui lòng sử dụng
danh sách gửi thư osmocom-net-grps để thảo luận liên quan. Danh sách có thể được
đã liên hệ tại osmocom-net-gprs@lists.osmocom.org và người đưa thư
giao diện để quản lý đăng ký của bạn là tại
ZZ0000ZZ

Trình theo dõi sự cố
=============

Dự án Osmocom duy trì trình theo dõi vấn đề cho Kernel GTP-U
mô-đun tại
ZZ0000ZZ

Lịch sử / Lời cảm ơn
==========================

Mô-đun này ban đầu được Harald Welte tạo ra vào năm 2012, nhưng chưa bao giờ
hoàn thành.  Pablo đến để giải quyết mớ hỗn độn mà Harald để lại.  Nhưng
do thiếu sự quan tâm của người dùng nên nó không bao giờ được hợp nhất.

Vào năm 2015, Andreas Schultz đã ra tay giải cứu và sửa nhiều lỗi hơn,
đã mở rộng nó với các tính năng mới và cuối cùng đã thúc đẩy tất cả chúng tôi có được nó
dòng chính, nơi nó được hợp nhất trong 4.7.0.

Chi tiết kiến ​​trúc
=====================

Nhận dạng đường hầm và thực thể GTP-U cục bộ
--------------------------------------------

GTP-U sử dụng UDP để vận chuyển PDU. Cổng UDP nhận là 2152
cho GTPv1-U và 3386 cho GTPv0-U.

Chỉ có một thực thể GTP-U (và do đó SGSN/GGSN/S-GW/PDN-GW
dụ) trên mỗi địa chỉ IP. Mã định danh điểm cuối đường hầm (TEID) là duy nhất
mỗi thực thể GTP-U.

Một đường hầm cụ thể chỉ được xác định bởi thực thể đích. Kể từ khi
cổng đích không đổi, chỉ IP đích và TEID xác định
một đường hầm. IP nguồn và Cổng không có ý nghĩa gì đối với đường hầm.

Vì thế:

* khi gửi, thực thể từ xa được xác định bởi IP từ xa và
    id điểm cuối đường hầm. IP nguồn và cổng không có ý nghĩa và
    có thể được thay đổi bất cứ lúc nào.

* khi việc nhận thực thể cục bộ được xác định bởi thực thể cục bộ
    IP đích và id điểm cuối đường hầm. IP nguồn và cổng
    không có ý nghĩa và có thể thay đổi bất cứ lúc nào.

[3GPP TS 29.281] Mục 4.3.0 định nghĩa điều này như sau::

TEID trong tiêu đề GTP-U được sử dụng để phân kênh lưu lượng
  đến từ các điểm cuối đường hầm từ xa để nó được chuyển đến
  Các thực thể mặt phẳng người dùng theo cách cho phép ghép kênh các thực thể khác nhau
  người dùng, các giao thức gói khác nhau và các mức QoS khác nhau.
  Do đó, không có hai điểm cuối GTP-U từ xa nào sẽ gửi lưu lượng truy cập đến một
  Thực thể giao thức GTP-U sử dụng cùng một giá trị TEID ngoại trừ
  để chuyển tiếp dữ liệu như một phần của thủ tục di động.

Định nghĩa ở trên chỉ định nghĩa rằng hai điểm cuối GTP-U từ xa
ZZ0000ZZ gửi đến cùng một TEID, nó ZZ0001ZZ cấm hoặc loại trừ
một kịch bản như vậy Trong thực tế, các thủ tục di chuyển được đề cập làm cho nó
cần thiết rằng thực thể GTP-U chấp nhận lưu lượng truy cập cho TEID từ
nhiều đồng nghiệp hoặc chưa biết.

Do đó, bên nhận sẽ xác định các đường hầm dựa hoàn toàn vào
TEID, không dựa trên IP nguồn!

APN so với thiết bị mạng
======================

Trình điều khiển GTP-U tạo thiết bị mạng Linux cho mỗi Gi/SGi
giao diện.

[3GPP TS 29.281] gọi điểm tham chiếu Gi/SGi là một giao diện. Cái này
có thể dẫn đến ấn tượng rằng GGSN/P-GW chỉ có thể có một chiếc như vậy
giao diện.

Đúng là điểm tham chiếu Gi/SGi xác định mối quan hệ tương tác
giữa +miền gói 3GPP (PDN) dựa trên đường hầm và IP GTP-U
các mạng dựa trên

Không có điều khoản nào trong bất kỳ tài liệu 3GPP nào giới hạn việc
số lượng giao diện Gi/SGi được GGSN/P-GW triển khai.

[3GPP TS 29.061] Mục 11.3 nêu rõ rằng việc lựa chọn một
giao diện Gi/SGi cụ thể được thực hiện thông qua Tên điểm truy cập
(APN)::

2. mỗi mạng riêng quản lý địa chỉ riêng của mình. Nói chung điều này
     sẽ dẫn đến các mạng riêng khác nhau có sự chồng chéo
     các dãy địa chỉ. Một kết nối riêng biệt về mặt logic (ví dụ: một IP trong IP
     đường hầm hoặc mạch ảo lớp 2) được sử dụng giữa GGSN/P-GW
     và mỗi mạng riêng.

Trong trường hợp này, địa chỉ IP không nhất thiết phải là duy nhất.  các
     cặp giá trị, Tên điểm truy cập (APN) và địa chỉ IPv4 và/hoặc
     Tiền tố IPv6, là duy nhất.

Để hỗ trợ trường hợp sử dụng dải địa chỉ chồng chéo, mỗi APN
được ánh xạ tới một giao diện Gi/SGi (thiết bị mạng) riêng biệt.

.. note::

   The Access Point Name is purely a control plane (GTP-C) concept.
   At the GTP-U level, only Tunnel Endpoint Identifiers are present in
   GTP-U packets and network devices are known

Do đó, đối với một UE nhất định, ánh xạ trong mạng IP tới mạng PDN là:

* thiết bị mạng + MS IP -> Peer IP + Peer TEID,

và từ PDN sang mạng IP:

* IP GTP-U cục bộ + TEID -> thiết bị mạng

Hơn nữa, trước khi T-PDU nhận được được đưa vào mạng
thiết bị IP MS được kiểm tra dựa trên IP được ghi trong ngữ cảnh PDP.