.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/ntb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

============
Trình điều khiển NTB
===========

NTB (Non-Transparent Bridge) là loại chip cầu nối PCI-Express kết nối
hệ thống bộ nhớ riêng biệt của hai hoặc nhiều máy tính cho cùng một PCI-Express
vải. Phần cứng NTB hiện tại hỗ trợ một bộ tính năng chung: chuông cửa
các thanh ghi và cửa sổ dịch bộ nhớ, cũng như các tính năng không phổ biến như
bảng ghi dữ liệu và các thanh ghi tin nhắn. Các thanh ghi Scratchpad có thể đọc và ghi
các thanh ghi có thể truy cập được từ hai phía của thiết bị, để các đồng nghiệp có thể
trao đổi một lượng nhỏ thông tin tại một địa chỉ cố định. Thanh ghi tin nhắn có thể
được sử dụng cho cùng một mục đích. Ngoài ra họ còn được cung cấp
các bit trạng thái đặc biệt để đảm bảo thông tin không bị người khác viết lại
ngang hàng. Các thanh ghi chuông cửa cung cấp một cách để các đồng nghiệp gửi các sự kiện gián đoạn.
Cửa sổ bộ nhớ cho phép truy cập đọc và ghi được dịch vào bộ nhớ ngang hàng.

Trình điều khiển lõi NTB (ntb)
=====================

Trình điều khiển lõi NTB xác định một api bao bọc bộ tính năng chung và cho phép
khách hàng quan tâm đến các tính năng của NTB để khám phá NTB các thiết bị được hỗ trợ bởi
trình điều khiển phần cứng.  Thuật ngữ "khách hàng" được sử dụng ở đây có nghĩa là lớp trên
thành phần sử dụng api NTB.  Thuật ngữ "trình điều khiển" hoặc "trình điều khiển phần cứng"
được sử dụng ở đây có nghĩa là trình điều khiển cho một nhà cung cấp và kiểu phần cứng NTB cụ thể.

Trình điều khiển máy khách NTB
==================

Trình điều khiển máy khách NTB nên đăng ký với trình điều khiển lõi NTB.  Sau
đăng ký, các chức năng thăm dò và loại bỏ của khách hàng sẽ được gọi một cách thích hợp
vì phần cứng ntb hoặc trình điều khiển phần cứng được chèn và xóa.  các
đăng ký sử dụng khung Thiết bị Linux, do đó, nó sẽ có cảm giác quen thuộc với
bất cứ ai đã viết một trình điều khiển pci.

NTB Triển khai trình điều khiển máy khách điển hình
----------------------------------------

Mục đích chính của NTB là chia sẻ một số phần bộ nhớ giữa ít nhất hai
hệ thống. Vì vậy, các tính năng của thiết bị NTB như thanh ghi Scratchpad/Message là
chủ yếu được sử dụng để thực hiện khởi tạo cửa sổ bộ nhớ thích hợp. Thông thường
có hai loại giao diện cửa sổ bộ nhớ được NTB API hỗ trợ:
bản dịch gửi đến được định cấu hình trên cổng ntb cục bộ và bản dịch gửi đi
được cấu hình bởi máy ngang hàng, trên cổng ntb ngang hàng. Loại đầu tiên là
được mô tả trên hình tiếp theo::

Bản dịch đầu vào:

Bộ nhớ: NTB cục bộ Cổng: NTB ngang hàng Cổng: MMIO ngang hàng:
  ____________
 ZZ0000ZZ-ntb_mw_set_trans(addr) |
 ZZ0001ZZ _v____________ |   ______________
 ZZ0002ZZ<======ZZ0003ZZ<====ZZ0004ZZ<== IO được ánh xạ vào bộ nhớ
 ZZ0005ZZ ZZ0006ZZ ZZ0007ZZ--------------|

Vì vậy, kịch bản điển hình của việc khởi tạo cửa sổ bộ nhớ loại đầu tiên trông như sau:
1) phân bổ vùng bộ nhớ, 2) đặt địa chỉ đã dịch vào cấu hình NTB,
3) bằng cách nào đó thông báo cho thiết bị ngang hàng về việc khởi tạo được thực hiện, 4) thiết bị ngang hàng
ánh xạ cửa sổ bộ nhớ gửi đi tương ứng để có quyền truy cập vào phần được chia sẻ
vùng bộ nhớ.

Loại giao diện thứ hai, có nghĩa là các cửa sổ chia sẻ được
được khởi tạo bởi một thiết bị ngang hàng, được mô tả trên hình::

Dịch ra ngoài:

Bộ nhớ: NTB cục bộ Cổng: NTB ngang hàng Cổng: MMIO ngang hàng:
  ____________ ______________
 Bộ bổ sung cơ sở ZZ0000ZZ ZZ0001ZZ MW |<== IO được ánh xạ bộ nhớ
 ZZ0002ZZ ZZ0003ZZ--------------|
 ZZ0004ZZ<======================ZZ0005ZZ<-ntb_peer_mw_set_trans(addr)
 ZZ0006ZZ ZZ0007ZZ--------------|

Kịch bản điển hình của việc khởi tạo giao diện loại thứ hai sẽ là:
1) phân bổ vùng bộ nhớ, 2) bằng cách nào đó cung cấp địa chỉ đã dịch cho thiết bị ngang hàng
thiết bị, 3) thiết bị ngang hàng đặt địa chỉ đã dịch sang cấu hình NTB, 4) bản đồ thiết bị ngang hàng
cửa sổ bộ nhớ gửi đi để có quyền truy cập vào vùng bộ nhớ dùng chung.

Như người ta có thể thấy, các kịch bản được mô tả có thể được kết hợp trong một thiết bị di động
thuật toán.

Thiết bị cục bộ:
  1) Cấp phát bộ nhớ cho cửa sổ dùng chung
  2) Khởi tạo cửa sổ bộ nhớ theo địa chỉ đã dịch của vùng được phân bổ
     (có thể thất bại nếu việc khởi tạo cửa sổ bộ nhớ cục bộ không được hỗ trợ)
  3) Gửi địa chỉ đã dịch và chỉ mục cửa sổ bộ nhớ tới thiết bị ngang hàng

Thiết bị ngang hàng:
  1) Khởi tạo cửa sổ bộ nhớ với địa chỉ được cấp phát
     bởi vùng bộ nhớ thiết bị khác (có thể bị lỗi nếu cửa sổ bộ nhớ ngang hàng
     việc khởi tạo không được hỗ trợ)
  2) Bản đồ cửa sổ bộ nhớ gửi đi

Theo kịch bản này, Cửa sổ bộ nhớ NTB API có thể được sử dụng làm
sau:

Thiết bị cục bộ:
  1) ntb_mw_count(pidx) - truy xuất số lượng phạm vi bộ nhớ, có thể
     được phân bổ cho các cửa sổ bộ nhớ giữa thiết bị cục bộ và thiết bị ngang hàng
     của cổng với chỉ mục được chỉ định.
  2) ntb_get_align(pidx, midx) - truy xuất các tham số hạn chế
     căn chỉnh và kích thước vùng bộ nhớ dùng chung. Sau đó bộ nhớ có thể hoạt động bình thường
     được phân bổ.
  3) Phân bổ vùng bộ nhớ liền kề về mặt vật lý tuân thủ
     các hạn chế được lấy ở phần 2).
  4) ntb_mw_set_trans(pidx, midx) - thử đặt địa chỉ dịch của
     cửa sổ bộ nhớ với chỉ mục được chỉ định cho thiết bị ngang hàng được xác định
     (có thể thất bại nếu cài đặt địa chỉ dịch cục bộ không được hỗ trợ)
  5) Gửi địa chỉ cơ sở đã dịch (thường cùng với cửa sổ bộ nhớ
     số) tới thiết bị ngang hàng bằng cách sử dụng, chẳng hạn như bảng ghi nhớ hoặc tin nhắn
     sổ đăng ký.

Thiết bị ngang hàng:
  1) ntb_peer_mw_set_trans(pidx, midx) - thử đặt nhận từ người khác
     địa chỉ được dịch của thiết bị (liên quan đến pidx) cho bộ nhớ được chỉ định
     cửa sổ. Nó có thể thất bại nếu địa chỉ được truy xuất, chẳng hạn, vượt quá
     địa chỉ tối đa có thể hoặc không được căn chỉnh chính xác.
  2) ntb_peer_mw_get_addr(widx) - truy xuất địa chỉ MMIO để ánh xạ bộ nhớ
     window để có quyền truy cập vào bộ nhớ dùng chung.

Ngoài ra, điều đáng lưu ý là phương thức đó ntb_mw_count(pidx) sẽ trả về
cùng giá trị với ntb_peer_mw_count() trên thiết bị ngang hàng có chỉ mục cổng - pidx.

Máy khách truyền tải NTB (ntb\_transport) và NTB Netdev (ntb\_netdev)
------------------------------------------------------------------

Máy khách chính của NTB là máy khách Vận tải, được sử dụng song song với NTB
Netdev.  Các trình điều khiển này hoạt động cùng nhau để tạo ra một liên kết logic đến thiết bị ngang hàng,
trên ntb, để trao đổi các gói dữ liệu mạng.  Khách hàng Vận tải
thiết lập một liên kết logic đến thiết bị ngang hàng và tạo các cặp hàng đợi để trao đổi
tin nhắn và dữ liệu.  NTB Netdev sau đó tạo một thiết bị ethernet bằng cách sử dụng
Cặp hàng đợi vận chuyển.  Dữ liệu mạng được sao chép giữa bộ đệm ổ cắm và
Bộ đệm cặp hàng đợi vận chuyển.  Máy khách Transport có thể được sử dụng cho những việc khác
ngoài Netdev, tuy nhiên vẫn chưa có ứng dụng nào khác được viết.

Máy khách thử nghiệm bóng bàn NTB (ntb\_pingpong)
-----------------------------------------

Khách hàng thử nghiệm Ping Pong đóng vai trò minh họa cách sử dụng chuông cửa
và các thanh ghi Scratchpad của phần cứng NTB và như một ví dụ máy khách NTB đơn giản.
Ping Pong kích hoạt liên kết khi bắt đầu, đợi liên kết NTB xuất hiện và
sau đó tiến hành đọc và ghi các thanh ghi trên bàn di chuột của chuông cửa của NTB.
Các đồng nghiệp ngắt lời nhau bằng cách sử dụng một chút mặt nạ của các bit chuông cửa, nghĩa là
thay đổi một đơn vị trong mỗi vòng để kiểm tra hoạt động của nhiều bit chuông cửa
và các vectơ ngắt.  Trình điều khiển Ping Pong cũng đọc địa phương đầu tiên
bàn di chuột và ghi giá trị cộng thêm một vào bàn di chuột ngang hàng đầu tiên, mỗi bàn di chuột
vòng trước khi viết đăng ký chuông cửa ngang hàng.

Thông số mô-đun:

* không an toàn - Một số phần cứng đã biết có vấn đề với bàn di chuột và chuông cửa
	sổ đăng ký.  Theo mặc định, Ping Pong sẽ không thực hiện các hoạt động như vậy.
	phần cứng.  Bạn có thể tự mình ghi đè hành vi này bằng cách tự chịu rủi ro bằng cách đặt
	không an toàn=1.
* delay\_ms - Chỉ định độ trễ giữa khi nhận chuông cửa
	làm gián đoạn sự kiện và thiết lập đăng ký chuông cửa ngang hàng cho lần tiếp theo
	tròn.
* init\_db - Chỉ định bit chuông cửa để bắt đầu chuỗi vòng mới.  Một cái mới
	chuỗi bắt đầu khi tất cả các bit chuông cửa đã được chuyển ra khỏi
	phạm vi.
* dyndbg - Nên chỉ định dyndbg=+p khi tải mô-đun này và
	sau đó để quan sát đầu ra gỡ lỗi trên bảng điều khiển.

Máy khách kiểm tra công cụ NTB (ntb\_tool)
--------------------------------

Ứng dụng khách Tool test phục vụ việc gỡ lỗi, chủ yếu là phần cứng và trình điều khiển ntb.
Công cụ này cung cấp quyền truy cập thông qua các bản gỡ lỗi để đọc, cài đặt và xóa
Chuông cửa NTB, và bảng ghi nhớ đọc viết.

Công cụ hiện không có bất kỳ tham số mô-đun nào.

Tệp gỡ lỗi:

* ZZ0008ZZ/ntb\_tool/ZZ0009ZZ/
	Một thư mục trong debugfs sẽ được tạo cho mỗi
	Thiết bị NTB được công cụ này thăm dò.  Thư mục này được rút ngắn thành ZZ0010ZZ
	bên dưới.
* ZZ0011ZZ/db
	Tập tin này được sử dụng để đọc, đặt và xóa chuông cửa cục bộ.  Không
	tất cả các hoạt động có thể được hỗ trợ bởi tất cả phần cứng.  Để đọc chuông cửa,
	đọc tập tin.  Để đặt chuông cửa, hãy viết ZZ0000ZZ theo sau là các bit để
	bộ (ví dụ: ZZ0001ZZ).  Để xóa chuông cửa, hãy viết ZZ0002ZZ
	tiếp theo là các bit để xóa.
* ZZ0012ZZ/mặt nạ
	Tệp này được sử dụng để đọc, đặt và xóa mặt nạ chuông cửa cục bộ.
	Xem ZZ0013ZZ để biết chi tiết.
* ZZ0014ZZ/ngang hàng\_db
	Tệp này được sử dụng để đọc, đặt và xóa chuông cửa ngang hàng.
	Xem ZZ0015ZZ để biết chi tiết.
* ZZ0016ZZ/ngang hàng\_mask
	Tệp này được sử dụng để đọc, đặt và xóa chuông cửa ngang hàng
	mặt nạ.  Xem ZZ0017ZZ để biết chi tiết.
* ZZ0018ZZ/đệm
	Tập tin này được sử dụng để đọc và ghi các bảng ghi nhớ cục bộ.  Để đọc
	giá trị của tất cả các bảng ghi nhớ, hãy đọc tệp.  Để viết các giá trị, hãy viết một
	chuỗi các cặp số và giá trị của bảng ghi nhớ
	(ví dụ: ZZ0003ZZ
	# to đặt các bảng ghi nhớ ZZ0004ZZ và ZZ0005ZZ thành ZZ0006ZZ và ZZ0007ZZ tương ứng).
* ZZ0019ZZ/ngang hàng\_spad
	Tập tin này được sử dụng để đọc và ghi các bảng ghi chú ngang hàng.  Xem
	ZZ0020ZZ để biết chi tiết.

Máy khách thử nghiệm NTB MSI (ntb\_msi\_test)
------------------------------------

Máy khách thử nghiệm MSI dùng để kiểm tra và gỡ lỗi thư viện MSI
cho phép truyền các ngắt MSI qua các cửa sổ bộ nhớ NTB. các
máy khách thử nghiệm được tương tác thông qua hệ thống tệp debugfs:

* ZZ0000ZZ/ntb\_msi\_test/ZZ0001ZZ/
	Một thư mục trong debugfs sẽ được tạo cho mỗi
	Thiết bị NTB được thử nghiệm bằng msi.  Thư mục này được rút ngắn thành ZZ0002ZZ
	bên dưới.
* ZZ0003ZZ/cổng
	Tệp này mô tả số cổng cục bộ
* ZZ0004ZZ/irq*_lần xuất hiện
	Một tập tin lần xuất hiện tồn tại cho mỗi ngắt và khi đọc,
	trả về số lần ngắt được kích hoạt.
* ZZ0005ZZ/ngang hàng*/cổng
	Tệp này mô tả số cổng cho mỗi thiết bị ngang hàng
* ZZ0006ZZ/ngang hàng*/đếm
	Tập tin này mô tả số lượng ngắt có thể xảy ra
	được kích hoạt trên mỗi máy ngang hàng
* ZZ0007ZZ/ngang hàng*/kích hoạt
	Viết một số ngắt (bất kỳ số nào nhỏ hơn giá trị
	được chỉ định trong count) sẽ kích hoạt ngắt trên
	ngang hàng được chỉ định. Tệp xảy ra ngắt ngang hàng đó
	nên được tăng lên.

Trình điều khiển phần cứng NTB
====================

Trình điều khiển phần cứng NTB nên đăng ký thiết bị với trình điều khiển lõi NTB.  Sau
đăng ký, các chức năng thăm dò và xóa của khách hàng sẽ được gọi.

Trình điều khiển phần cứng Intel NTB (ntb\_hw\_intel)
------------------------------------------

Trình điều khiển phần cứng Intel hỗ trợ NTB trên CPU Xeon và Atom.

Thông số mô-đun:

* b2b\_mw\_idx
	Nếu ntb ngang hàng được truy cập thông qua cửa sổ bộ nhớ, thì hãy sử dụng
	cửa sổ bộ nhớ này để truy cập ntb ngang hàng.  Giá trị bằng 0 hoặc dương
	bắt đầu từ mw idx đầu tiên và giá trị âm bắt đầu từ mw idx cuối cùng
	tôi không biết.  Cả hai bên MUST đều đặt cùng một giá trị ở đây!  Giá trị mặc định là
	ZZ0000ZZ.
* b2b\_mw\_share
	Nếu ntb ngang hàng được truy cập thông qua cửa sổ bộ nhớ và nếu
	cửa sổ bộ nhớ đủ lớn, vẫn cho phép máy khách sử dụng
	nửa sau của cửa sổ bộ nhớ để dịch địa chỉ sang thiết bị ngang hàng.
* xeon\_b2b\_usd\_bar2\_addr64
	Nếu sử dụng cấu trúc liên kết B2B trên phần cứng Xeon, hãy sử dụng
	địa chỉ 64 bit này trên bus giữa các thiết bị NTB dành cho cửa sổ
	tại BAR2, ở phía thượng nguồn của liên kết.
* xeon\_b2b\_usd\_bar4\_addr64 - Xem ZZ0001ZZ.
* xeon\_b2b\_usd\_bar4\_addr32 - Xem ZZ0002ZZ.
* xeon\_b2b\_usd\_bar5\_addr32 - Xem ZZ0003ZZ.
* xeon\_b2b\_dsd\_bar2\_addr64 - Xem ZZ0004ZZ.
* xeon\_b2b\_dsd\_bar4\_addr64 - Xem ZZ0005ZZ.
* xeon\_b2b\_dsd\_bar4\_addr32 - Xem ZZ0006ZZ.
* xeon\_b2b\_dsd\_bar5\_addr32 - Xem ZZ0007ZZ.
