.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/psp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Giao thức bảo mật PSP
=======================

Giao thức
========

Giao thức bảo mật PSP (PSP) đã được xác định tại Google và được xuất bản trong:

ZZ0000ZZ

Phần này trình bày ngắn gọn các khía cạnh giao thức quan trọng để hiểu
hạt nhân API. Tham khảo đặc tả giao thức để biết thêm chi tiết.

Lưu ý rằng việc triển khai kernel và tài liệu sử dụng thuật ngữ
"khóa thiết bị" thay cho "khóa chính", vừa ít gây nhầm lẫn hơn
dành cho một nhà phát triển trung bình và ít có khả năng vi phạm bất kỳ cách đặt tên nào
hướng dẫn.

Khóa Rx có nguồn gốc
---------------

PSP mượn một số điều khoản và cơ chế từ IPsec. PSP được thiết kế
có lưu ý đến việc giảm tải CTNH. Tính năng chính của PSP là các phím Rx cho mọi
kết nối không cần phải được lưu trữ bởi người nhận nhưng có thể được lấy từ
từ khóa thiết bị và thông tin có trong tiêu đề gói.
Điều này làm cho nó có thể thực hiện các máy thu yêu cầu một hằng số
dung lượng bộ nhớ bất kể số lượng kết nối (tỷ lệ ZZ0000ZZ).

Khóa Tx phải được lưu trữ giống như bất kỳ giao thức nào khác, nhưng Tx thì cần nhiều
độ trễ ít nhạy hơn Rx và độ trễ trong việc tìm nạp khóa từ chậm
bộ nhớ ít có khả năng gây ra tình trạng rớt gói. Tốt nhất là các phím Tx
phải được cung cấp cùng với gói (ví dụ như một phần của bộ mô tả).

Xoay phím
------------

Khóa thiết bị chỉ người nhận mới biết là cơ bản cho thiết kế.
Theo đặc điểm kỹ thuật, trạng thái này không thể truy cập trực tiếp được (nó phải được
không thể đọc nó ra khỏi phần cứng của máy thu NIC).
Hơn nữa, nó phải được “xoay vòng” định kỳ (thường là hàng ngày). Xoay
có nghĩa là khóa thiết bị mới được tạo (bởi trình tạo số ngẫu nhiên
của thiết bị) và được sử dụng cho tất cả các kết nối mới. Để tránh làm gián đoạn
kết nối cũ, khóa thiết bị cũ vẫn còn trong NIC. Một chút pha
mang trong các tiêu đề gói cho biết thế hệ khóa thiết bị nào
gói đã được mã hóa bằng.

Người dùng phải đối mặt với API
===============

PSP được thiết kế chủ yếu để giảm tải phần cứng. Hiện tại có
không có dự phòng phần mềm cho các hệ thống không có NIC hỗ trợ PSP.
Cũng không có cách tiêu chuẩn (hoặc được định nghĩa khác) để thiết lập
kết nối được bảo mật PSP hoặc trao đổi khóa đối xứng.

Kỳ vọng là các giao thức lớp cao hơn sẽ đảm nhiệm việc
giao thức và đàm phán khóa. Ví dụ: người ta có thể sử dụng trao đổi khóa TLS,
thông báo khả năng PSP và chuyển sang PSP nếu cả hai điểm cuối
có khả năng PSP.

Tất cả cấu hình của PSP được thực hiện thông qua họ netlink PSP.

Khám phá thiết bị
----------------

Họ netlink PSP xác định các hoạt động để truy xuất thông tin
về các thiết bị PSP có sẵn trên hệ thống, định cấu hình chúng và
truy cập số liệu thống kê liên quan đến PSP.

Bảo đảm kết nối
---------------------

Mã hóa PSP hiện chỉ được hỗ trợ cho các kết nối TCP.
Khóa Rx và Tx được phân bổ riêng. Đầu tiên là ZZ0000ZZ
Lệnh Netlink cần được ban hành, chỉ định ổ cắm TCP đích.
Kernel sẽ phân bổ khóa PSP Rx mới từ NIC và liên kết nó
với ổ cắm nhất định. Ở giai đoạn này, ổ cắm sẽ chấp nhận cả PSP được bảo mật
và các gói TCP văn bản thuần túy.

Khóa Tx được cài đặt bằng lệnh ZZ0000ZZ Netlink.
Sau khi cài đặt khóa Tx, tất cả dữ liệu được đọc từ ổ cắm sẽ
được bảo mật PSP. Nói cách khác, hành động cài đặt khóa Tx có tác dụng phụ
ảnh hưởng đến hướng Rx.

Có một khoảng thời gian trung gian sau khi ZZ0000ZZ thành công
trả về và trước khi ổ cắm TCP gặp PSP đầu tiên
gói được xác thực, trong đó ngăn xếp TCP sẽ cho phép một số dữ liệu phi dữ liệu nhất định
các gói, tức là ACK, FIN và RST, để nhập TCP để nhận xử lý
ngay cả khi PSP không được xác thực. Trong cuộc gọi ZZ0001ZZ, TCP
trường ZZ0002ZZ của socket được ghi lại. Tại thời điểm này, ACK và RST
sẽ được chấp nhận với bất kỳ số thứ tự nào, trong khi FIN sẽ chỉ được
được chấp nhận ở giá trị chốt của ZZ0003ZZ. Khi ngăn xếp TCP
gặp gói TCP đầu tiên chứa dữ liệu được xác thực PSP,
đầu kia của kết nối phải thực thi ZZ0004ZZ
lệnh, vì vậy mọi gói TCP, kể cả những gói không có dữ liệu, sẽ bị
bị hủy trước khi xử lý nhận nếu nó không thành công
được xác thực. Điều này được tóm tắt trong bảng dưới đây. các
trạng thái từ chối tất cả các gói không phải PSP nói trên được gắn nhãn "PSP
Đầy đủ".

++-------+----------++-------------+-------------+-------------+
ZZ0000ZZ Bình thường TCP ZZ0001ZZ Tx PSP ZZ0002ZZ
+==================================================================================================================================================
ZZ0003ZZ chấp nhận ZZ0004ZZ thả ZZ0005ZZ
ZZ0006ZZ ZZ0007ZZ ZZ0008ZZ
++-------+----------++-------------+-------------+-------------+
ZZ0009ZZ chấp nhận ZZ0010ZZ chấp nhận ZZ0011ZZ
ZZ0012ZZFINZZ0013ZZ ZZ0014ZZ ZZ0015ZZ
++-------+----------++-------------+-------------+-------------+
ZZ0016ZZ thả ZZ0017ZZ chấp nhận ZZ0018ZZ
++-------+----------++-------------+-------------+-------------+
ZZ0019ZZ thả ZZ0020ZZ thả ZZ0021ZZ
ZZ0022ZZ ZZ0023ZZ ZZ0024ZZ
++-------+----------++-------------+-------------+-------------+
ZZ0025ZZ văn bản thuần túy ZZ0026ZZ được mã hóa ZZ0027ZZ
ZZ0028ZZ ZZ0029ZZ (không bao gồm rtx) ZZ0030ZZ
++-------+----------++-------------+-------------+-------------+

Để đảm bảo rằng mọi dữ liệu được đọc từ ổ cắm sau ZZ0000ZZ
cuộc gọi trả về thành công đã được xác thực, kernel sẽ quét
nhận và loại bỏ hàng đợi của ổ cắm tại thời điểm ZZ0001ZZ. Nếu có
gói trong hàng đợi đã được nhận ở dạng văn bản rõ ràng, liên kết Tx sẽ
không thành công và ứng dụng sẽ thử cài đặt lại khóa Tx sau
làm cạn ổ cắm (điều này không cần thiết nếu cả hai điểm cuối
cư xử tốt).

Bởi vì số thứ tự TCP không được bảo vệ toàn vẹn trước
nâng cấp lên PSP, có thể MITM có thể bù chuỗi
các số theo cách xóa tiền tố của phần được bảo vệ PSP của
luồng TCP. Nếu không gian người dùng quan tâm đến việc giảm thiểu kiểu tấn công này,
Thông báo "bắt đầu PSP" đặc biệt phải được trao đổi sau ZZ0000ZZ.

Thông báo xoay vòng
----------------------

Việc xoay phím thiết bị diễn ra không đồng bộ và thường
được thực hiện bởi trình nền quản lý, không nằm dưới sự kiểm soát của ứng dụng.
Dòng netlink PSP sẽ tạo thông báo bất cứ khi nào có khóa
được quay. Các ứng dụng dự kiến sẽ thiết lập lại kết nối
trước khi các phím được xoay lại.

Triển khai hạt nhân
=====================

Ghi chú của tài xế
------------

Trình điều khiển dự kiến sẽ bắt đầu khi không bật PSP (ZZ0000ZZ
trong ZZ0001ZZ được đặt thành ZZ0002ZZ) bất cứ khi nào có thể. Không gian người dùng nên
không phụ thuộc vào hành vi này, vì việc mở rộng trong tương lai có thể cần phải tạo
trong số các thiết bị đã bật PSP, tuy nhiên trình điều khiển sẽ không bật
PSP theo mặc định. Việc kích hoạt PSP phải là trách nhiệm của hệ thống
thành phần cũng đảm nhiệm việc xoay vòng phím.

Lưu ý rằng ZZ0000ZZ dự kiến chỉ được sử dụng để kích hoạt
nhận xử lý. Dự kiến thiết bị sẽ không từ chối các yêu cầu truyền
sau khi ZZ0001ZZ bị vô hiệu hóa. Người dùng cũng có thể vô hiệu hóa
ZZ0002ZZ trong khi có các liên kết đang hoạt động, điều này sẽ
phá vỡ mọi quá trình xử lý PSP Rx.

Trình điều khiển phải đảm bảo rằng khóa thiết bị có thể sử dụng được và an toàn
khi init, không có sự xoay vòng khóa rõ ràng theo không gian người dùng. Nó phải như vậy
có thể phân bổ các khóa làm việc và không được có khóa trùng lặp
được tạo ra. Nếu thiết bị cho phép máy chủ yêu cầu khóa cho
tùy ý SPI - trình điều khiển nên loại bỏ cả hai phím thiết bị (xoay
phím thiết bị hai lần), để tránh khả năng sử dụng phím SPI+ mà trước đó
Phiên bản hệ điều hành đã có quyền truy cập.

Trình điều khiển phải sử dụng ZZ0000ZZ để kiểm tra xem PSP Tx có giảm tải không
đã được yêu cầu cho skb nhất định. Trên trình điều khiển Rx nên phân bổ và điền
phần mở rộng skb ZZ0001ZZ và đặt bit được giải mã skb-> thành 1.

Ghi chú triển khai hạt nhân
---------------------------

Việc triển khai PSP tuân theo quá trình giảm tải TLS chặt chẽ hơn so với IPsec
giảm tải, với trạng thái trên mỗi socket và việc sử dụng skb->decrypted để ngăn chặn
rò rỉ văn bản rõ ràng.

Thiết bị PSP tách biệt với netdev, để có thể "ủy quyền"
Khả năng giảm tải của PSP cho các thiết bị phần mềm (ví dụ: ZZ0000ZZ).