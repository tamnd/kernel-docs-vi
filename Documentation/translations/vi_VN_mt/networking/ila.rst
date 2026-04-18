.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/ila.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================================
Địa chỉ định vị định danh (ILA)
===================================


Giới thiệu
============

Địa chỉ bộ định vị-định danh (ILA) là một kỹ thuật được sử dụng với IPv6
phân biệt giữa vị trí và danh tính của một nút mạng. Một phần của một
địa chỉ thể hiện danh tính bất biến của nút và một phần khác
cho biết vị trí của nút có thể động. Định danh-định vị
địa chỉ có thể được sử dụng để triển khai hiệu quả các mạng lớp phủ cho
ảo hóa mạng cũng như các giải pháp cho các trường hợp sử dụng trong di động.

ILA có thể được coi là phương tiện để triển khai mạng lớp phủ mà không cần
đóng gói. Điều này được thực hiện bằng cách thực hiện địa chỉ mạng
dịch địa chỉ đích khi gói tin đi qua mạng. Đến
mạng, gói dịch ILA dường như không khác gì bất kỳ gói nào
gói IPv6 khác. Ví dụ: nếu giao thức truyền tải là TCP thì
Gói dịch ILA trông giống như một gói TCP/IPv6 khác. các
Ưu điểm của việc này là ILA trong suốt với mạng nên
tối ưu hóa trong mạng, chẳng hạn như ECMP, RSS, GRO, GSO, v.v., vẫn hoạt động.

Giao thức ILA được mô tả trong Internet-Draft Draft-herbert-intarea-ila.


Thuật ngữ ILA
===============

- Mã định danh
		Một số xác định một nút có thể định địa chỉ trong mạng
		độc lập với vị trí của nó. Số nhận dạng ILA là sáu mươi bốn
		các giá trị bit.

- Định vị
		Tiền tố mạng định tuyến đến máy chủ vật lý. Máy định vị
		cung cấp vị trí tôpô của một nút được đánh địa chỉ. ILA
		bộ định vị là tiền tố 64 bit.

- Ánh xạ ILA
		Ánh xạ mã định danh ILA tới bộ định vị (hoặc tới
		định vị và dữ liệu meta). Miền ILA duy trì cơ sở dữ liệu
		chứa ánh xạ cho tất cả các đích trong miền.

- Địa chỉ SIR
		Địa chỉ IPv6 bao gồm tiền tố SIR (sáu mươi trên
		bốn bit) và một mã định danh (sáu mươi bốn bit thấp hơn).
		Địa chỉ SIR được hiển thị cho các ứng dụng và cung cấp
		phương tiện để họ đánh địa chỉ các nút độc lập với
		vị trí.

- Địa chỉ ILA
		Một địa chỉ IPv6 bao gồm một bộ định vị (sáu mươi bốn trên
		bit) và mã định danh (sáu mươi bốn bit bậc thấp). ILA
		địa chỉ không bao giờ được hiển thị cho một ứng dụng.

- Máy chủ ILA
		Máy chủ cuối có khả năng thực hiện các bản dịch ILA
		khi truyền hoặc nhận.

- Bộ định tuyến ILA
		Nút mạng thực hiện dịch và chuyển tiếp ILA
		của các gói được dịch.

- Bộ đệm chuyển tiếp ILA
		Một loại bộ định tuyến ILA chỉ duy trì một bộ hoạt động
		bộ đệm của ánh xạ.

- Nút ILA
		Một nút mạng có khả năng thực hiện các bản dịch ILA. Cái này
		có thể là bộ định tuyến ILA, bộ đệm chuyển tiếp ILA hoặc máy chủ ILA.


Hoạt động
=========

Có hai hoạt động cơ bản với ILA:

- Dịch địa chỉ SIR sang địa chỉ ILA. Điều này được thực hiện khi xâm nhập
    đến lớp phủ ILA.

- Dịch địa chỉ ILA sang địa chỉ SIR. Việc này được thực hiện ở lối ra
    từ lớp phủ ILA.

ILA có thể được triển khai trên máy chủ cuối hoặc thiết bị trung gian trong
mạng; chúng được cung cấp lần lượt bởi "máy chủ ILA" và "bộ định tuyến ILA".
Cấu hình và đường dẫn dữ liệu cho hai điểm triển khai này có phần hơi phức tạp.
khác nhau.

Sơ đồ bên dưới cũng minh họa luồng gói thông qua ILA
như hiển thị máy chủ và bộ định tuyến ILA::

+--------+ +--------+
    ZZ0000ZZ Máy chủ B |
    ZZ0001ZZ ZZ0002ZZ |
    +--------+ |            ...đã gửi địa chỉ.... ( ) +--------+
	       V +---+--+ .  gói .  +---+--+ (_)
   (1) SIR ZZ0003ZZ ILA ZZ0004ZZ ILA ZZ0005ZZ (3) SIR
    có địa chỉ +->ZZ0006ZZ .              .  ZZ0007ZZ->-+ có địa chỉ
    gói +---+--+ .     IPv6 .  +---+--+ gói
		   / .    Mạng   .
		  / .              .   +--+-++--------+
    +--------+/ .              .   ZZ0008ZZZZ0009ZZ
    |  Host  +--+           .              .- -|host|ZZ0011ZZ
    ZZ0012ZZ.              .   +--+-++--------+
    +--------+............


Xử lý tổng kiểm tra vận chuyển
===========================

Khi một địa chỉ được dịch bởi ILA, tổng kiểm tra vận chuyển được đóng gói
bao gồm địa chỉ đã dịch trong tiêu đề giả có thể được hiển thị
trên dây không chính xác. Đây là một vấn đề đối với các thiết bị trung gian,
bao gồm cả việc giảm tải tổng kiểm tra trong NIC, xử lý tổng kiểm tra đó. có
ba lựa chọn để giải quyết vấn đề này:

- không có hành động Cho phép tổng kiểm tra trên dây không chính xác. trước đây
		người nhận xác minh tổng kiểm tra địa chỉ ILA đến SIR
		phải thực hiện việc dịch thuật.

- điều chỉnh tổng kiểm tra vận chuyển
		Khi bản dịch ILA được thực hiện, gói được phân tích cú pháp
		và nếu tìm thấy tổng kiểm tra lớp vận chuyển thì đó là
		được điều chỉnh để phản ánh tổng kiểm tra chính xác theo
		địa chỉ được dịch

- ánh xạ trung tính tổng kiểm tra
		Khi một địa chỉ được dịch, sự khác biệt có thể được bù đắp
		ở nơi khác trong một phần của gói được bao phủ bởi
		tổng kiểm tra. Thứ tự thấp mười sáu bit của mã định danh
		được sử dụng. Phương pháp này được ưa chuộng hơn vì nó không yêu cầu
		phân tích gói tin ngoài tiêu đề IP và trong hầu hết các trường hợp,
		điều chỉnh có thể được tính toán trước và lưu cùng với ánh xạ.

Lưu ý rằng việc điều chỉnh trung lập tổng kiểm tra ảnh hưởng đến thứ tự thấp mười sáu
bit của mã định danh. Khi quá trình dịch địa chỉ ILA sang SIR được thực hiện trên
đầu ra các bit thứ tự thấp được khôi phục về giá trị ban đầu
khôi phục mã định danh như ban đầu nó được gửi.


Các loại định danh
================

ILA xác định các loại mã định danh khác nhau cho các trường hợp sử dụng khác nhau.

Các loại được xác định là:

0: định danh giao diện

1: mã định danh duy nhất cục bộ

2: mã định danh mạng ảo cho địa chỉ IPv4

3: mã định danh mạng ảo cho địa chỉ unicast IPv6

4: mã định danh mạng ảo cho địa chỉ multicast IPv6

5: mã định danh địa chỉ không cục bộ

Trong quá trình triển khai hiện tại của kernel ILA chỉ có các mã định danh duy nhất cục bộ
(LUID) được hỗ trợ. LUID cho phép 64 bit chung, không được định dạng
định danh.


Định dạng định danh
==================

Kernel ILA hỗ trợ hai trường tùy chọn trong mã định danh để định dạng:
"C-bit" và "loại định danh". Sự hiện diện của các trường này được xác định
theo cấu hình như minh họa dưới đây.

Nếu có loại định danh thì nó chiếm ba thứ tự cao nhất
bit của một mã định danh. Các giá trị có thể được đưa ra trong danh sách trên.

Nếu có bit C, điều này được sử dụng như một dấu hiệu cho thấy tổng kiểm tra
lập bản đồ trung lập đã được thực hiện. Bit C chỉ có thể được thiết lập trong một
Địa chỉ ILA, không bao giờ là địa chỉ SIR.

Ở định dạng đơn giản nhất, các loại mã định danh, C-bit và tổng kiểm tra
giá trị điều chỉnh không xuất hiện nên mã định danh được coi là
Giá trị 64 bit không có cấu trúc::

+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     ZZ0000ZZ
     + +
     ZZ0001ZZ
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

Việc điều chỉnh trung tính tổng kiểm tra có thể được cấu hình để luôn luôn
hiện tại bằng cách sử dụng neutral-map-auto. Trong trường hợp này không có C-bit, nhưng
điều chỉnh tổng kiểm tra ở mức thấp 16 bit. Mã định danh là
vẫn còn sáu mươi bốn bit::

+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     ZZ0000ZZ
     |                               +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     ZZ0001ZZ Điều chỉnh trung tính tổng kiểm tra |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

Bit C có thể được sử dụng để chỉ rõ ràng rằng tổng kiểm tra trung tính
ánh xạ đã được áp dụng cho địa chỉ ILA. Định dạng là::

+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     ZZ0000ZZCZZ0001ZZ
     |     +-+ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     ZZ0002ZZ Điều chỉnh trung tính tổng kiểm tra |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

Trường loại định danh có thể xuất hiện để chỉ ra định danh
loại. Nếu nó không xuất hiện thì loại được suy ra dựa trên ánh xạ
cấu hình. Việc điều chỉnh trung tính tổng kiểm tra có thể tự động
được sử dụng với loại mã định danh như minh họa bên dưới::

+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     Mã định danh ZZ0000ZZ |
     +-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     ZZ0001ZZ Điều chỉnh trung tính tổng kiểm tra |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

Nếu loại định danh và bit C có thể xuất hiện đồng thời thì
định dạng định danh sẽ là::

+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     ZZ0000ZZCZZ0001ZZ
     +-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     ZZ0002ZZ Điều chỉnh trung tính tổng kiểm tra |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+


Cấu hình
=============

Có hai phương pháp để định cấu hình ánh xạ ILA. Một là sử dụng các tuyến LWT
và cái còn lại là ila_xlat (được gọi từ hook NFHOOK PREROUTING). ila_xlat
được thiết kế để sử dụng trong đường dẫn nhận cho máy chủ ILA.

Bộ định tuyến ILA cũng đã được triển khai trong XDP. Mô tả đó là
nằm ngoài phạm vi của tài liệu này.

Việc sử dụng các tuyến đường ILA LWT là:

lộ trình ip thêm DEST/128 encap ila LOC csum-mode MODE loại nhận dạng TYPE qua ADDR

Đích (DEST) có thể là địa chỉ SIR (đối với máy chủ ILA hoặc xâm nhập
bộ định tuyến ILA) hoặc địa chỉ ILA (bộ định tuyến ILA đầu ra). LOC là sáu mươi bốn
bộ định vị bit (có định dạng W:X:Y:Z) ghi đè lên 64 bit trên
bit của địa chỉ đích.  Tổng kiểm tra MODE là một trong những "không có hành động",
"adj-transport", "bản đồ trung tính" và "bản đồ trung tính-tự động". Nếu bản đồ trung tính là
được thiết lập thì bit C sẽ xuất hiện. Mã định danh TYPE một trong những "chất lỏng" hoặc
"sử dụng định dạng." Trong trường hợp định dạng sử dụng, trường loại định danh là
hiện tại và loại hiệu quả được lấy từ đó.

Việc sử dụng ila_xlat là:

ip ila thêm loc_match MATCH loc LOC csum-mode MODE loại nhận dạng TYPE

MATCH cho biết bộ định vị đến phải khớp để áp dụng
a bản dịch. LOC là bộ định vị ghi đè phần trên
sáu mươi bốn bit của địa chỉ đích. MODE và TYPE có
ý nghĩa tương tự như đã mô tả ở trên.


Một số ví dụ
=============

::

# Configure một tuyến ILA cũng sử dụng ánh xạ trung tính tổng kiểm tra
     Trường loại # as. Lưu ý rằng trường loại được đặt ở địa chỉ SIR
     # (loại 2000 ngụ ý là 1 tức là LUID).
     tuyến ip thêm 3333:0:0:1:2000:0:1:87/128 encap ila 2001:0:87:0 \
	  định dạng sử dụng loại nhận dạng bản đồ trung tính csum-mode

# Configure tuyến đường ILA LWT sử dụng ánh xạ trung tính tổng kiểm tra tự động
     # (không có C-bit) và định cấu hình loại mã định danh là LUID để
     Trường loại # identifier sẽ không xuất hiện.
     tuyến ip thêm 3333:0:0:1:2000:0:2:87/128 encap ila 2001:0:87:1 \
	  csum-mode neutral-map-auto nhận dạng loại chất lỏng

cấu hình ila_xlat

# Configure ánh xạ ILA sang SIR khớp với bộ định vị và ghi đè
     # it có địa chỉ SIR (3333:0:0:1 trong ví dụ này). Bit C và
     Trường # identifier được sử dụng.
     ip ila thêm loc_match 2001:0:119:0 loc 3333:0:0:1 \
	 định dạng sử dụng loại nhận dạng trung lập-map-auto csum-mode

# Configure ánh xạ ILA sang SIR trong đó tổng kiểm tra trung tính tự động
     # set không có C-bit và loại mã định danh được cấu hình là LUID
     # so rằng trường loại định danh không xuất hiện.
     ip ila thêm loc_match 2001:0:119:0 loc 3333:0:0:1 \
	 định dạng sử dụng loại nhận dạng trung lập-map-auto csum-mode