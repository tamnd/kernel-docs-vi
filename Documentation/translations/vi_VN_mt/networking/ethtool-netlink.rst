.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/ethtool-netlink.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Giao diện Netlink cho ethtool
=============================


Thông tin cơ bản
=================

Giao diện Netlink cho ethtool sử dụng họ netlink chung ZZ0000ZZ
(ứng dụng không gian người dùng nên sử dụng macro ZZ0001ZZ và
ZZ0002ZZ được định nghĩa trong uapi ZZ0003ZZ
tiêu đề). Họ này không sử dụng một tiêu đề cụ thể, tất cả thông tin trong
yêu cầu và trả lời được chuyển bằng thuộc tính netlink.

Giao diện netlink ethtool sử dụng ACK mở rộng để phát hiện lỗi và cảnh báo
báo cáo, các nhà phát triển ứng dụng không gian người dùng được khuyến khích thực hiện những điều này
thông điệp có sẵn cho người dùng một cách phù hợp.

Yêu cầu có thể được chia thành ba loại: "get" (lấy thông tin),
"set" (cài đặt tham số) và "hành động" (gọi một hành động).

Tất cả các yêu cầu loại "đặt" và "hành động" đều yêu cầu quyền quản trị viên
(ZZ0000ZZ trong không gian tên). Hầu hết các yêu cầu loại "nhận" đều được phép
bất kỳ ai ngoại trừ những trường hợp ngoại lệ (trong đó phản hồi có chứa thông tin nhạy cảm
thông tin). Trong một số trường hợp, yêu cầu như vậy được phép đối với bất kỳ ai ngoại trừ
người dùng không có đặc quyền có các thuộc tính có thông tin nhạy cảm (ví dụ:
mật khẩu Wake-on-lan) bị bỏ qua.


Công ước
===========

Các thuộc tính đại diện cho giá trị boolean thường sử dụng loại NLA_U8 để chúng ta
có thể phân biệt ba trạng thái: “bật”, “tắt” và “không hiện diện” (nghĩa là
thông tin không có sẵn trong yêu cầu "nhận" hoặc giá trị không thể thay đổi
trong các yêu cầu "đặt"). Đối với các thuộc tính này, giá trị "true" phải được chuyển dưới dạng
số 1 nhưng mọi giá trị khác 0 sẽ được người nhận hiểu là "true".
Trong các bảng bên dưới, "bool" biểu thị các thuộc tính NLA_U8 được diễn giải theo cách này.

Trong mô tả cấu trúc thông báo bên dưới, nếu tên thuộc tính được thêm vào
với "+", tổ mẹ có thể chứa nhiều thuộc tính cùng loại. Cái này
thực hiện một loạt các mục.

Các thuộc tính cần được trình điều khiển thiết bị điền vào và được chuyển vào
không gian người dùng dựa trên việc chúng có hợp lệ hay không không nên sử dụng số 0 làm
giá trị hợp lệ. Điều này tránh sự cần thiết phải báo hiệu rõ ràng tính hợp lệ của
thuộc tính trong trình điều khiển thiết bị API.


Tiêu đề yêu cầu
==============

Mỗi tin nhắn yêu cầu hoặc trả lời chứa một thuộc tính lồng nhau với tiêu đề chung.
Cấu trúc của tiêu đề này là

=============================== ====== ==================================
  ZZ0000ZZ u32 thiết bị ifindex
  Tên thiết bị chuỗi ZZ0001ZZ
  Cờ ZZ0002ZZ u32 chung cho tất cả các yêu cầu
  Chỉ số thiết bị phy ZZ0003ZZ u32
  =============================== ====== ==================================

ZZ0000ZZ và ZZ0001ZZ xác định
tin nhắn thiết bị liên quan đến. Một trong số đó là đủ cho các yêu cầu, nếu cả hai đều
được sử dụng, họ phải xác định cùng một thiết bị. Một số yêu cầu, ví dụ: chuỗi toàn cầu
bộ, không yêu cầu nhận dạng thiết bị. Hầu hết các yêu cầu ZZ0002ZZ cũng cho phép
kết xuất các yêu cầu mà không cần nhận dạng thiết bị để truy vấn cùng một thông tin cho
tất cả các thiết bị cung cấp nó (mỗi thiết bị trong một tin nhắn riêng).

ZZ0000ZZ là bitmap của các cờ yêu cầu chung cho tất cả các yêu cầu
các loại. Việc giải thích các cờ này giống nhau đối với tất cả các loại yêu cầu nhưng
các cờ có thể không áp dụng cho các yêu cầu. Cờ được công nhận là:

=========================================================================
  ZZ0000ZZ sử dụng bitset định dạng nhỏ gọn để trả lời
  ZZ0001ZZ bỏ qua trả lời tùy chọn (_SET và _ACT)
  ZZ0002ZZ bao gồm số liệu thống kê thiết bị tùy chọn
  =========================================================================

Cờ yêu cầu mới phải tuân theo ý tưởng chung là nếu cờ không được đặt,
hành vi tương thích ngược, tức là các yêu cầu từ khách hàng cũ không biết
của cờ phải được diễn giải theo cách khách hàng mong đợi. Một khách hàng phải
không đặt cờ nó không hiểu.

ZZ0000ZZ xác định Ethernet PHY mà thông báo liên quan đến.
Vì có nhiều lệnh liên quan đến cấu hình PHY và vì
có thể có nhiều hơn một PHY trên liên kết, chỉ mục PHY có thể được chuyển vào
yêu cầu các lệnh cần nó. Tuy nhiên, điều này không bắt buộc và nếu
không được chuyển cho các lệnh nhắm mục tiêu PHY, con trỏ net_device.phydev
được sử dụng.

Bộ bit
========

Đối với các bitmap ngắn có độ dài cố định (hợp lý), ZZ0000ZZ tiêu chuẩn
loại được sử dụng. Đối với các bitmap có độ dài tùy ý, ethtool netlink sử dụng một
thuộc tính có nội dung thuộc một trong hai dạng: nhỏ gọn (hai bitmap nhị phân
đại diện cho các giá trị bit và mặt nạ của các bit bị ảnh hưởng) và từng bit (danh sách
bit được xác định theo chỉ mục hoặc tên).

Các bit dài dòng (từng bit) cho phép gửi tên tượng trưng cho các bit cùng nhau
với các giá trị của chúng giúp tiết kiệm một chuyến đi khứ hồi (khi bitset được truyền trong một
yêu cầu) hoặc ít nhất là yêu cầu thứ hai (khi bitset trả lời). Đây là
hữu ích cho các ứng dụng một lần như lệnh ethtool truyền thống. Trên
mặt khác, các ứng dụng chạy dài như màn hình ethtool (hiển thị
thông báo) hoặc trình nền quản lý mạng có thể thích tìm nạp tên
chỉ một lần và sử dụng hình thức thu gọn để tiết kiệm kích thước tin nhắn. Thông báo từ
Giao diện netlink ethtool luôn sử dụng dạng nhỏ gọn cho các bit.

Một bitset có thể đại diện cho một cặp giá trị/mặt nạ (ZZ0000ZZ
chưa được đặt) hoặc một bitmap đơn (bộ ZZ0001ZZ). Trong yêu cầu
sửa đổi một bitmap, cái trước sẽ thay đổi bit được đặt trong mặt nạ thành các giá trị được đặt trong
giá trị và bảo tồn phần còn lại; cái sau đặt các bit được đặt trong bitmap và
xóa phần còn lại.

Dạng thu gọn: nội dung thuộc tính lồng nhau (bitset):

================================== ================================
  Cờ ZZ0000ZZ không có mặt nạ, chỉ có danh sách
  ZZ0001ZZ u32 số bit quan trọng
  Bitmap nhị phân ZZ0002ZZ của các giá trị bit
  Bitmap nhị phân ZZ0003ZZ của các bit hợp lệ
  ================================== ================================

Giá trị và mặt nạ phải có độ dài ít nhất là bit ZZ0000ZZ
được làm tròn thành bội số của 32 bit. Chúng bao gồm các từ 32 bit trong byte máy chủ
thứ tự, các từ được sắp xếp từ ít quan trọng nhất đến quan trọng nhất (tức là giống nhau
cách bitmap được truyền bằng giao diện ioctl).

Đối với dạng nhỏ gọn, ZZ0000ZZ và ZZ0001ZZ là
bắt buộc. Thuộc tính ZZ0002ZZ là bắt buộc nếu
ZZ0003ZZ chưa được đặt (bitset đại diện cho cặp giá trị/mặt nạ);
nếu ZZ0004ZZ không được đặt thì ZZ0005ZZ cũng không
được phép (bitset đại diện cho một bitmap.

Độ dài tập hợp bit hạt nhân có thể khác với độ dài vùng người dùng nếu ứng dụng cũ hơn
được sử dụng trên kernel mới hơn hoặc ngược lại. Nếu bitmap vùng người dùng dài hơn thì sẽ xảy ra lỗi
chỉ được đưa ra nếu yêu cầu thực sự cố gắng đặt giá trị của một số bit không
được kernel công nhận.

Dạng bit-by-bit: nội dung thuộc tính lồng nhau (bitset):

+-----------------------------------+--------+-----------------------------+
 Cờ ZZ0007ZZ ZZ0008ZZ
 +-----------------------------------+--------+-----------------------------+
 ZZ0009ZZ u32 ZZ0010ZZ
 +-----------------------------------+--------+-----------------------------+
 ZZ0011ZZ lồng nhau ZZ0012ZZ
 +-+-----------------------------------+--------+-----------------------------+
 ZZ0013ZZ ZZ0003ZZ ZZ0014ZZ một chút |
 +-+-+--------------------------------+--------+-----------------------------+
 ZZ0015ZZ ZZ0016ZZ u32 ZZ0017ZZ
 +-+-+--------------------------------+--------+-----------------------------+
 ZZ0018ZZ ZZ0019ZZ chuỗi ZZ0020ZZ
 +-+-+--------------------------------+--------+-----------------------------+
 ZZ0021ZZ ZZ0022ZZ cờ ZZ0023ZZ
 +-+-+--------------------------------+--------+-----------------------------+

Đối với dạng từng bit, ZZ0000ZZ là tùy chọn và
ZZ0001ZZ là bắt buộc. ZZ0002ZZ tổ yến
chỉ chứa các thuộc tính ZZ0003ZZ nhưng có thể có một
số lượng tùy ý của chúng.  Một bit có thể được xác định bởi chỉ mục của nó hoặc bởi
tên. Khi được sử dụng trong các yêu cầu, các bit được liệt kê được đặt thành 0 hoặc 1 tùy theo
ZZ0004ZZ, phần còn lại được giữ nguyên.

Yêu cầu không thành công nếu chỉ mục vượt quá độ dài bit kernel hoặc nếu tên không
được công nhận. Nếu cả tên và chỉ mục đều được đặt, yêu cầu sẽ thất bại nếu chúng
trỏ đến các bit khác nhau.

Khi có cờ ZZ0000ZZ, bitset được hiểu là
một bitmap đơn giản. Thuộc tính ZZ0001ZZ không được sử dụng trong
trường hợp như vậy. Bitset như vậy đại diện cho một bitmap với các bit được liệt kê và phần còn lại
không.

Trong yêu cầu, ứng dụng có thể sử dụng một trong hai hình thức. Biểu mẫu được kernel sử dụng để trả lời là
được xác định bởi cờ ZZ0000ZZ trong trường cờ yêu cầu
tiêu đề. Ngữ nghĩa của giá trị và mặt nạ phụ thuộc vào thuộc tính.


Danh sách các loại tin nhắn
=====================

Tất cả các hằng số xác định loại thông báo đều sử dụng tiền tố và hậu tố ZZ0000ZZ
theo mục đích tin nhắn:

========================================================
  Yêu cầu không gian người dùng ZZ0000ZZ để truy xuất dữ liệu
  ZZ0001ZZ yêu cầu không gian người dùng để thiết lập dữ liệu
  Yêu cầu không gian người dùng ZZ0002ZZ để thực hiện một hành động
  Hạt nhân ZZ0003ZZ trả lời yêu cầu ZZ0004ZZ
  Hạt nhân ZZ0005ZZ trả lời yêu cầu ZZ0006ZZ
  Hạt nhân ZZ0007ZZ trả lời yêu cầu ZZ0008ZZ
  Thông báo hạt nhân ZZ0009ZZ
  ========================================================

Không gian người dùng cho kernel:

============================================================================
  ZZ0000ZZ nhận bộ dây
  ZZ0001ZZ nhận cài đặt liên kết
  ZZ0002ZZ thiết lập cài đặt liên kết
  ZZ0003ZZ lấy thông tin chế độ liên kết
  ZZ0004ZZ thiết lập thông tin chế độ liên kết
  ZZ0005ZZ nhận trạng thái liên kết
  ZZ0006ZZ nhận cài đặt gỡ lỗi
  ZZ0007ZZ đặt cài đặt gỡ lỗi
  ZZ0008ZZ nhận cài đặt đánh thức trên mạng
  ZZ0009ZZ đặt cài đặt đánh thức trên mạng
  ZZ0010ZZ nhận các tính năng của thiết bị
  ZZ0011ZZ cài đặt tính năng của thiết bị
  ZZ0012ZZ nhận cờ riêng
  ZZ0013ZZ đặt cờ riêng
  ZZ0014ZZ nhận kích thước nhẫn
  ZZ0015ZZ đặt kích thước vòng
  ZZ0016ZZ lấy số lượng kênh
  ZZ0017ZZ đặt số lượng kênh
  ZZ0018ZZ lấy thông số kết hợp
  ZZ0019ZZ đặt tham số kết hợp
  ZZ0020ZZ nhận thông số tạm dừng
  ZZ0021ZZ đặt thông số tạm dừng
  ZZ0022ZZ nhận cài đặt EEE
  ZZ0023ZZ đặt cài đặt EEE
  ZZ0024ZZ lấy thông tin về dấu thời gian
  Kiểm tra cáp khởi động hành động ZZ0025ZZ
  Hành động ZZ0026ZZ bắt đầu thử nghiệm cáp TDR thô
  ZZ0027ZZ lấy thông tin giảm tải đường hầm
  ZZ0028ZZ nhận cài đặt FEC
  ZZ0029ZZ đặt cài đặt FEC
  ZZ0030ZZ đọc mô-đun SFP EEPROM
  ZZ0031ZZ lấy số liệu thống kê tiêu chuẩn
  ZZ0032ZZ lấy thông tin đồng hồ ảo PHC
  ZZ0033ZZ đặt thông số mô-đun thu phát
  ZZ0034ZZ lấy thông số mô-đun thu phát
  ZZ0035ZZ cài đặt thông số PSE
  ZZ0036ZZ lấy thông số PSE
  ZZ0037ZZ nhận cài đặt RSS
  ZZ0038ZZ lấy thông số PLCA RS
  ZZ0039ZZ đặt thông số PLCA RS
  ZZ0040ZZ nhận trạng thái PLCA RS
  ZZ0041ZZ nhận trạng thái lớp hợp nhất MAC
  ZZ0042ZZ đặt tham số lớp hợp nhất MAC
  Phần mềm mô-đun thu phát flash ZZ0043ZZ
  Thông tin ZZ0044ZZ nhận Ethernet PHY
  ZZ0045ZZ nhận cấu hình đánh dấu thời gian
  ZZ0046ZZ đặt cấu hình đánh dấu thời gian hw
  ZZ0047ZZ đặt cài đặt RSS
  ZZ0048ZZ tạo bối cảnh RSS bổ sung
  ZZ0049ZZ xóa bối cảnh RSS bổ sung
  ZZ0050ZZ lấy dữ liệu chẩn đoán MSE
  ============================================================================

Hạt nhân tới không gian người dùng:

==============================================================================
  Nội dung bộ chuỗi ZZ0000ZZ
  Cài đặt liên kết ZZ0001ZZ
  Thông báo cài đặt liên kết ZZ0002ZZ
  Thông tin chế độ liên kết ZZ0003ZZ
  Thông báo chế độ liên kết ZZ0004ZZ
  Thông tin trạng thái liên kết ZZ0005ZZ
  Cài đặt gỡ lỗi ZZ0006ZZ
  Thông báo cài đặt gỡ lỗi ZZ0007ZZ
  Cài đặt đánh thức ZZ0008ZZ
  Thông báo cài đặt Wake-on-lan ZZ0009ZZ
  Tính năng của thiết bị ZZ0010ZZ
  ZZ0011ZZ trả lời tùy chọn cho FEATURES_SET
  Thông báo tính năng của netdev ZZ0012ZZ
  Cờ riêng ZZ0013ZZ
  Cờ riêng ZZ0014ZZ
  Kích thước vòng ZZ0015ZZ
  Kích thước vòng ZZ0016ZZ
  Số kênh ZZ0017ZZ
  Số kênh ZZ0018ZZ
  Thông số kết hợp ZZ0019ZZ
  Thông số kết hợp ZZ0020ZZ
  Thông số tạm dừng ZZ0021ZZ
  Thông số tạm dừng ZZ0022ZZ
  Cài đặt ZZ0023ZZ EEE
  Cài đặt ZZ0024ZZ EEE
  Thông tin về dấu thời gian của ZZ0025ZZ
  Kết quả kiểm tra cáp ZZ0026ZZ
  ZZ0027ZZ Kiểm tra cáp Kết quả TDR
  Thông tin giảm tải đường hầm ZZ0028ZZ
  Cài đặt ZZ0029ZZ FEC
  Cài đặt ZZ0030ZZ FEC
  ZZ0031ZZ đọc mô-đun SFP EEPROM
  Thống kê tiêu chuẩn ZZ0032ZZ
  Thông tin đồng hồ ảo ZZ0033ZZ PHC
  Thông số mô-đun thu phát ZZ0034ZZ
  Thông số ZZ0035ZZ PSE
  Cài đặt ZZ0036ZZ RSS
  Cài đặt ZZ0037ZZ RSS
  Thông số ZZ0038ZZ PLCA RS
  Trạng thái ZZ0039ZZ PLCA RS
  Thông số ZZ0040ZZ PLCA RS
  Trạng thái lớp hợp nhất ZZ0041ZZ MAC
  Cập nhật flash mô-đun thu phát ZZ0042ZZ
  Thông tin ZZ0043ZZ Ethernet PHY
  ZZ0044ZZ Ethernet PHY thay đổi thông tin
  Cấu hình đánh dấu thời gian ZZ0045ZZ hw
  ZZ0046ZZ cấu hình đánh dấu thời gian hw mới
  Thông báo sự kiện ZZ0047ZZ PSE
  Thông báo cài đặt ZZ0048ZZ RSS
  ZZ0049ZZ tạo bối cảnh RSS bổ sung
  Đã tạo bối cảnh RSS bổ sung ZZ0050ZZ
  Đã xóa bối cảnh RSS bổ sung ZZ0051ZZ
  Dữ liệu chẩn đoán ZZ0052ZZ MSE
  ==============================================================================

Yêu cầu ZZ0000ZZ được gửi bởi ứng dụng không gian người dùng để truy xuất thiết bị
thông tin. Chúng thường không chứa bất kỳ thuộc tính cụ thể nào của tin nhắn.
Kernel trả lời bằng thông báo "GET_REPLY" tương ứng. Đối với hầu hết các loại, ZZ0001ZZ
yêu cầu với ZZ0002ZZ và không thể sử dụng nhận dạng thiết bị để truy vấn
thông tin cho tất cả các thiết bị hỗ trợ yêu cầu.

Nếu dữ liệu cũng có thể được sửa đổi, thông báo ZZ0000ZZ tương ứng có cùng nội dung
bố cục như ZZ0001ZZ tương ứng được sử dụng để yêu cầu thay đổi. Chỉ
các thuộc tính nơi yêu cầu thay đổi được bao gồm trong yêu cầu đó (đồng thời, không phải
tất cả các thuộc tính có thể được thay đổi). Các câu trả lời cho hầu hết yêu cầu ZZ0002ZZ chỉ bao gồm
mã lỗi và exack; nếu kernel cung cấp dữ liệu bổ sung, nó sẽ được gửi vào
dạng thông báo ZZ0003ZZ tương ứng có thể bị chặn bởi
cài đặt cờ ZZ0004ZZ trong tiêu đề yêu cầu.

Việc sửa đổi dữ liệu cũng kích hoạt việc gửi tin nhắn ZZ0000ZZ kèm theo thông báo.
Chúng thường chỉ mang một tập hợp con các thuộc tính bị ảnh hưởng bởi
thay đổi. Thông báo tương tự được đưa ra nếu dữ liệu được sửa đổi bằng cách sử dụng khác
có nghĩa là (chủ yếu là giao diện ioctl ethtool). Không giống như thông báo từ ethtool
mã netlink chỉ được gửi nếu có gì đó thực sự thay đổi, thông báo
được kích hoạt bởi giao diện ioctl có thể được gửi ngay cả khi yêu cầu không thực sự
thay đổi bất kỳ dữ liệu nào

Tin nhắn ZZ0000ZZ yêu cầu kernel (trình điều khiển) thực hiện một hành động cụ thể. Nếu một số
thông tin được báo cáo bởi kernel (có thể bị chặn bằng cách cài đặt
Cờ ZZ0001ZZ trong tiêu đề yêu cầu), câu trả lời có dạng
một tin nhắn ZZ0002ZZ. Thực hiện một hành động cũng kích hoạt thông báo
(Tin nhắn ZZ0003ZZ).

Các phần sau mô tả định dạng và ngữ nghĩa của các thông báo này.


STRSET_GET
==========

Yêu cầu nội dung của một chuỗi được cung cấp bởi các lệnh ioctl
Bộ chuỗi ZZ0000ZZ và ZZ0001ZZ không phải là người dùng
có thể ghi nên thông báo ZZ0002ZZ tương ứng chỉ được sử dụng trong
câu trả lời của hạt nhân. Có hai loại bộ chuỗi: toàn cục (độc lập với
một thiết bị, ví dụ: tên tính năng của thiết bị) và thiết bị cụ thể (ví dụ: thiết bị riêng tư
cờ).

Nội dung yêu cầu:

+---------------------------------------+--------+---------------+
 ZZ0004ZZ lồng nhau ZZ0005ZZ
 +---------------------------------------+--------+---------------+
 ZZ0006ZZ lồng nhau ZZ0007ZZ
 +-+---------------------------------------------------+--------+--------------+
 ZZ0008ZZ ZZ0002ZZ ZZ0009ZZ bộ một dây |
 +-+-+-----------------------------------+--------+--------------+
 ZZ0010ZZ ZZ0011ZZ u32 ZZ0012ZZ
 +-+-+-----------------------------------+--------+--------------+

Nội dung phản hồi hạt nhân:

+---------------------------------------+--------+--------------+
 ZZ0010ZZ lồng nhau ZZ0011ZZ
 +---------------------------------------+--------+--------------+
 ZZ0012ZZ lồng nhau ZZ0013ZZ
 +-+---------------------------------------------------+--------+--------------+
 ZZ0014ZZ ZZ0002ZZ ZZ0015ZZ bộ một dây |
 +-+-+-----------------------------------+--------+--------------+
 ZZ0016ZZ ZZ0017ZZ u32 ZZ0018ZZ
 +-+-+-----------------------------------+--------+--------------+
 ZZ0019ZZ ZZ0020ZZ u32 ZZ0021ZZ
 +-+-+-----------------------------------+--------+--------------+
 ZZ0022ZZ ZZ0023ZZ lồng nhau ZZ0024ZZ
 +-+-+-+---------------------------------+--------+--------------+
 ZZ0025ZZ ZZ0026ZZ ZZ0006ZZ ZZ0027ZZ một chuỗi |
 +-+-+-+-+----------------------+--------+--------------+
 ZZ0028ZZ ZZ0029ZZ ZZ0030ZZ u32 ZZ0031ZZ
 +-+-+-+-+----------------------+--------+--------------+
 ZZ0032ZZ ZZ0033ZZ ZZ0034ZZ chuỗi ZZ0035ZZ
 +-+-+-+-+----------------------+--------+--------------+
 Cờ ZZ0036ZZ ZZ0037ZZ
 +---------------------------------------+--------+--------------+

Nhận dạng thiết bị trong tiêu đề yêu cầu là tùy chọn. Tùy thuộc vào sự hiện diện của nó
a và cờ ZZ0000ZZ, có ba loại yêu cầu ZZ0001ZZ:

- không có ZZ0000ZZ không có thiết bị: nhận các bộ chuỗi "toàn cầu"
 - không có ZZ0001ZZ, có thiết bị: lấy các bộ chuỗi liên quan đến thiết bị
 - ZZ0002ZZ, không có thiết bị: nhận bộ chuỗi liên quan đến thiết bị cho tất cả các thiết bị

Nếu không có mảng ZZ0000ZZ, tất cả các bộ chuỗi
loại được yêu cầu sẽ được trả về, nếu không thì chỉ những loại được chỉ định trong yêu cầu.
Cờ ZZ0001ZZ yêu cầu kernel chỉ trả về chuỗi
số lượng bộ chứ không phải số chuỗi thực tế.


LINKINFO_GET
============

Yêu cầu cài đặt liên kết do ZZ0000ZZ cung cấp ngoại trừ
chế độ liên kết và thông tin liên quan đến tự động đàm phán. Yêu cầu không sử dụng
bất kỳ thuộc tính nào.

Nội dung yêu cầu:

=========================================== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  =========================================== =============================

Nội dung phản hồi hạt nhân:

=========================================== =============================
  Tiêu đề trả lời lồng nhau ZZ0000ZZ
  Cổng vật lý ZZ0001ZZ u8
  Địa chỉ ZZ0002ZZ u8 phy MDIO
  Trạng thái ZZ0003ZZ u8 MDI(-X)
  Điều khiển ZZ0004ZZ u8 MDI(-X)
  Bộ thu phát ZZ0005ZZ u8
  =========================================== =============================

Các thuộc tính và giá trị của chúng có cùng ý nghĩa như các thành viên phù hợp của
cấu trúc ioctl tương ứng.

ZZ0000ZZ cho phép kết xuất các yêu cầu (kernel trả về tin nhắn trả lời cho tất cả
thiết bị hỗ trợ yêu cầu).


LINKINFO_SET
============

Yêu cầu ZZ0000ZZ cho phép thiết lập một số thuộc tính được báo cáo bởi
ZZ0001ZZ.

Nội dung yêu cầu:

=========================================== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  Cổng vật lý ZZ0001ZZ u8
  Địa chỉ ZZ0002ZZ u8 phy MDIO
  Điều khiển ZZ0003ZZ u8 MDI(-X)
  =========================================== =============================

Không thể đặt trạng thái và bộ thu phát MDI(-X), hãy yêu cầu với thông số tương ứng
thuộc tính bị từ chối.


LINKMODES_GET
=============

Yêu cầu các chế độ liên kết (được hỗ trợ, quảng cáo và quảng cáo ngang hàng) và các chế độ liên quan
thông tin (trạng thái tự động đàm phán, tốc độ liên kết và song công) được cung cấp bởi
ZZ0000ZZ. Yêu cầu không sử dụng bất kỳ thuộc tính nào.

Nội dung yêu cầu:

=========================================== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  =========================================== =============================

Nội dung phản hồi hạt nhân:

============================================ ====== =============================
  Tiêu đề trả lời lồng nhau ZZ0000ZZ
  Trạng thái tự động đàm phán ZZ0001ZZ u8
  Chế độ liên kết được quảng cáo bitset ZZ0002ZZ
  Chế độ liên kết đối tác bitset ZZ0003ZZ
  Tốc độ liên kết ZZ0004ZZ u32 (Mb/s)
  Chế độ song công ZZ0005ZZ u8
  ZZ0006ZZ u8 Chế độ cổng chính/phụ
  ZZ0007ZZ u8 Trạng thái cổng chính/phụ
  Khớp tỷ lệ ZZ0008ZZ u8 PHY
  ============================================ ====== =============================

Đối với ZZ0000ZZ, giá trị đại diện cho các chế độ và mặt nạ được quảng cáo
đại diện cho các chế độ được hỗ trợ. ZZ0001ZZ ở phần trả lời có hơi chút
danh sách.

ZZ0000ZZ cho phép kết xuất các yêu cầu (kernel trả về tin nhắn trả lời cho tất cả
thiết bị hỗ trợ yêu cầu).


LINKMODES_SET
=============

Nội dung yêu cầu:

============================================ ====== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  Trạng thái tự động đàm phán ZZ0001ZZ u8
  Chế độ liên kết được quảng cáo bitset ZZ0002ZZ
  Chế độ liên kết đối tác bitset ZZ0003ZZ
  Tốc độ liên kết ZZ0004ZZ u32 (Mb/s)
  Chế độ song công ZZ0005ZZ u8
  ZZ0006ZZ u8 Chế độ cổng chính/phụ
  Khớp tỷ lệ ZZ0007ZZ u8 PHY
  Làn đường ZZ0008ZZ u32
  ============================================ ====== =============================

Bộ bit ZZ0000ZZ cho phép thiết lập các chế độ liên kết được quảng cáo. Nếu
tự động thương lượng đang bật (được đặt ngay bây giờ hoặc được giữ từ trước), các chế độ được quảng cáo
không bị thay đổi (không có thuộc tính ZZ0001ZZ) và ít nhất một
về tốc độ, song công và làn đường được chỉ định, kernel điều chỉnh các chế độ được quảng cáo cho tất cả
các chế độ được hỗ trợ phù hợp với tốc độ, song công, làn đường hoặc tất cả (bất cứ điều gì được chỉ định).
Việc tự động lựa chọn này được thực hiện ở phía ethtool với giao diện ioctl, netlink
giao diện được cho là cho phép yêu cầu thay đổi mà không cần biết chính xác những gì
hỗ trợ hạt nhân.


LINKSTATE_GET
=============

Yêu cầu thông tin trạng thái liên kết. Cờ liên kết lên/xuống (được cung cấp bởi
Lệnh ZZ0000ZZ ioctl) được cung cấp. Tùy chọn, trạng thái mở rộng có thể
cũng được cung cấp. Nói chung, trạng thái mở rộng mô tả lý do tại sao một cổng
không hoạt động hoặc tại sao nó hoạt động ở một chế độ không rõ ràng. Yêu cầu này không có
bất kỳ thuộc tính nào.

Nội dung yêu cầu:

=========================================== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  =========================================== =============================

Nội dung phản hồi hạt nhân:

=========================================== ===============================
  Tiêu đề trả lời lồng nhau ZZ0000ZZ
  Trạng thái liên kết bool ZZ0001ZZ (lên/xuống)
  ZZ0002ZZ u32 Chỉ số chất lượng tín hiệu hiện tại
  ZZ0003ZZ u32 Hỗ trợ tối đa giá trị SQI
  Trạng thái mở rộng liên kết ZZ0004ZZ u8
  Trạm biến áp mở rộng liên kết ZZ0005ZZ u8
  ZZ0006ZZ u32 số sự kiện liên kết xuống
  =========================================== ===============================

Đối với hầu hết các trình điều khiển NIC, giá trị của ZZ0000ZZ trả về
cờ nhà mạng do ZZ0001ZZ cung cấp nhưng có trình điều khiển
xác định trình xử lý riêng của họ.

ZZ0000ZZ và ZZ0001ZZ là
các giá trị tùy chọn. lõi ethtool có thể cung cấp cả hai
ZZ0002ZZ và ZZ0003ZZ,
hoặc chỉ ZZ0004ZZ, hoặc không có cái nào trong số đó.

ZZ0000ZZ cho phép kết xuất các yêu cầu (kernel trả về tin nhắn trả lời cho tất cả
thiết bị hỗ trợ yêu cầu).


Liên kết các trạng thái mở rộng:

====================================================================================================
  ZZ0000ZZ Các trạng thái liên quan đến tự động đàm phán hoặc
                                                        vấn đề trong đó

ZZ0000ZZ Lỗi trong quá trình đào tạo liên kết

ZZ0000ZZ Sự không khớp logic trong lớp con mã hóa vật lý
                                                        hoặc chuyển tiếp lớp con sửa lỗi

Vấn đề về tính toàn vẹn tín hiệu ZZ0000ZZ

ZZ0000ZZ Không có cáp kết nối

ZZ0000ZZ Lỗi liên quan đến cáp,
                                                        ví dụ: cáp không được hỗ trợ

Lỗi ZZ0000ZZ có liên quan đến EEPROM, ví dụ: lỗi
                                                        trong khi đọc hoặc phân tích dữ liệu

ZZ0000ZZ Lỗi trong thuật toán hiệu chuẩn

ZZ0000ZZ Phần cứng không thể cung cấp
                                                        nguồn điện cần thiết từ cáp hoặc mô-đun

ZZ0000ZZ Mô-đun quá nóng

Sự cố mô-đun thu phát ZZ0000ZZ
  ====================================================================================================

Liên kết các trạng thái phụ mở rộng:

Trạm biến áp Autoneg:

=======================================================================================================
  ZZ0000ZZ Mặt ngang bị hỏng

ZZ0000ZZ Không nhận được xác nhận từ phía ngang hàng

ZZ0000ZZ Trao đổi trang tiếp theo không thành công

ZZ0000ZZ Mặt ngang hàng bị hỏng khi có lực
                                                                    chế độ hoặc không có thỏa thuận của
                                                                    tốc độ

ZZ0000ZZ Chế độ sửa lỗi chuyển tiếp
                                                                    ở cả hai bên đều không khớp

ZZ0000ZZ Không có Mẫu số chung cao nhất
  =======================================================================================================

Liên kết các trạng thái đào tạo:

=======================================================================================================
  Không có khung ZZ0000ZZ
                                                                                 được công nhận,
                                                                                 khóa không thành công

ZZ0000ZZ Khóa không
                                                                                 xảy ra trước
                                                                                 hết thời gian

ZZ0000ZZ Bên ngang hàng thì không
                                                                                 gửi tín hiệu sẵn sàng
                                                                                 sau khi đào tạo
                                                                                 quá trình

ZZ0000ZZ Phía từ xa không có
                                                                                 sẵn sàng chưa
  =======================================================================================================

Liên kết các trạng thái con không khớp logic:

=======================================================================================================
  ZZ0000ZZ Lớp con mã hóa vật lý là
                                                                     không bị khóa trong giai đoạn đầu -
                                                                     khóa khối

ZZ0000ZZ Lớp con mã hóa vật lý là
                                                                     không bị khóa trong giai đoạn thứ hai -
                                                                     khóa đánh dấu căn chỉnh

ZZ0000ZZ Lớp con mã hóa vật lý đã thực hiện
                                                                     không nhận được trạng thái căn chỉnh

Sửa lỗi chuyển tiếp ZZ0000ZZ FC là
                                                                     không bị khóa

Sửa lỗi chuyển tiếp ZZ0000ZZ RS là
                                                                     không bị khóa
  =======================================================================================================

Trạng thái toàn vẹn tín hiệu xấu:

======================================================================================================
  ZZ0000ZZ Số lượng lớn vật lý
                                                                       lỗi

ZZ0000ZZ Hệ thống đã cố gắng
                                                                       vận hành cáp ở tốc độ
                                                                       đó không phải là chính thức
                                                                       được hỗ trợ, dẫn đến
                                                                       vấn đề toàn vẹn tín hiệu

ZZ0000ZZ Tín hiệu đồng hồ bên ngoài cho
                                                                       SerDes quá yếu hoặc
                                                                       không có sẵn.

ZZ0000ZZ Tín hiệu nhận được cho
                                                                       SerDes quá yếu vì
                                                                       mất tín hiệu analog.
  ======================================================================================================

Trạm biến áp phát hành cáp:

===================================================== =================================================
  ZZ0000ZZ Cáp không được hỗ trợ

Lỗi kiểm tra cáp ZZ0000ZZ
  ===================================================== =================================================

Các trạng thái phụ của mô-đun thu phát:

===================================================== =================================================
  ZZ0000ZZ Máy trạng thái mô-đun CMIS không đạt được
                                                        trạng thái ModuleReady. Ví dụ, nếu
                                                        mô-đun bị kẹt ở trạng thái ModuleFault
  ===================================================== =================================================

DEBUG_GET
=========

Yêu cầu cài đặt gỡ lỗi của thiết bị. Hiện tại, chỉ có mặt nạ tin nhắn là
được cung cấp.

Nội dung yêu cầu:

=========================================== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  =========================================== =============================

Nội dung phản hồi hạt nhân:

=========================================== =============================
  Tiêu đề trả lời lồng nhau ZZ0000ZZ
  Mặt nạ tin nhắn bitset ZZ0001ZZ
  =========================================== =============================

Mặt nạ tin nhắn (ZZ0000ZZ) bằng với mức tin nhắn như
được cung cấp bởi ZZ0001ZZ và được thiết lập bởi ZZ0002ZZ trong ioctl
giao diện. Mặc dù nó được gọi là cấp độ thông điệp ở đó vì lý do lịch sử, nhưng hầu hết
trình điều khiển và hầu hết tất cả các trình điều khiển mới hơn đều sử dụng nó làm mặt nạ cho thông báo đã bật
các lớp (được biểu thị bằng hằng số ZZ0003ZZ); do đó liên kết mạng
giao diện tuân theo việc sử dụng thực tế của nó trong thực tế.

ZZ0000ZZ cho phép kết xuất các yêu cầu (kernel trả về tin nhắn trả lời cho tất cả
thiết bị hỗ trợ yêu cầu).


DEBUG_SET
=========

Đặt hoặc cập nhật cài đặt gỡ lỗi của thiết bị. Hiện tại chỉ có mặt nạ tin nhắn
được hỗ trợ.

Nội dung yêu cầu:

=========================================== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  Mặt nạ tin nhắn bitset ZZ0001ZZ
  =========================================== =============================

Bộ bit ZZ0000ZZ cho phép cài đặt hoặc sửa đổi mặt nạ của
đã bật các loại thông báo gỡ lỗi cho thiết bị.


WOL_GET
=======

Truy vấn cài đặt Wake-on-lan của thiết bị. Không giống như hầu hết các yêu cầu loại "GET",
ZZ0000ZZ yêu cầu (netns) đặc quyền ZZ0001ZZ vì nó
(có khả năng) cung cấp mật khẩu SecureOn(tm) được bảo mật.

Nội dung yêu cầu:

=========================================== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  =========================================== =============================

Nội dung phản hồi hạt nhân:

=========================================== =============================
  Tiêu đề trả lời lồng nhau ZZ0000ZZ
  Mặt nạ bitset ZZ0001ZZ của các chế độ WoL được bật
  Mật khẩu SecureOn(tm) nhị phân ZZ0002ZZ
  =========================================== =============================

Trả lời, mặt nạ ZZ0000ZZ bao gồm các chế độ được hỗ trợ bởi
thiết bị, giá trị của các chế độ được kích hoạt. ZZ0001ZZ chỉ
được bao gồm trong thư trả lời nếu chế độ ZZ0002ZZ được hỗ trợ.


WOL_SET
=======

Đặt hoặc cập nhật cài đặt đánh thức trên mạng.

Nội dung yêu cầu:

=========================================== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  Chế độ WoL hỗ trợ bitset ZZ0001ZZ
  Mật khẩu SecureOn(tm) nhị phân ZZ0002ZZ
  =========================================== =============================

ZZ0000ZZ chỉ được phép cho các thiết bị hỗ trợ
Chế độ ZZ0001ZZ.


FEATURES_GET
============

Nhận các tính năng của netdev như yêu cầu ZZ0000ZZ ioctl.

Nội dung yêu cầu:

=========================================== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  =========================================== =============================

Nội dung phản hồi hạt nhân:

=========================================== =============================
  Tiêu đề trả lời lồng nhau ZZ0000ZZ
  Nhà phát triển bit ZZ0001ZZ->hw_features
  ZZ0002ZZ bitset dev->wanted_features
  Tính năng phát triển bitset ZZ0003ZZ->
  Bộ bit ZZ0004ZZ NETIF_F_NEVER_CHANGE
  =========================================== =============================

Bitmap trong phản hồi kernel có ý nghĩa tương tự như bitmap được sử dụng trong ioctl
nhiễu nhưng tên thuộc tính lại khác nhau (chúng dựa trên
thành viên tương ứng của struct net_device). "Cờ" kế thừa không được cung cấp,
nếu không gian người dùng cần chúng (rất có thể chỉ ethtool để tương thích ngược),
nó có thể tính toán giá trị của chúng từ chính các bit tính năng liên quan.
ETHA_FEATURES_HW sử dụng mặt nạ bao gồm tất cả các tính năng được kernel nhận dạng (để
cung cấp tất cả các tên khi sử dụng định dạng bitmap dài dòng), ba tên còn lại không sử dụng
mặt nạ (danh sách bit đơn giản).


FEATURES_SET
============

Yêu cầu đặt các tính năng của netdev như yêu cầu ZZ0000ZZ ioctl.

Nội dung yêu cầu:

=========================================== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  Các tính năng được yêu cầu của bit ZZ0001ZZ
  =========================================== =============================

Nội dung phản hồi hạt nhân:

=========================================== =============================
  Tiêu đề trả lời lồng nhau ZZ0000ZZ
  ZZ0001ZZ bitset khác biệt mong muốn so với kết quả
  Bitset ZZ0002ZZ khác biệt giữa cũ và mới hoạt động
  =========================================== =============================

Yêu cầu chỉ chứa một bitset có thể là cặp giá trị/mặt nạ (yêu cầu
để thay đổi các bit tính năng cụ thể và giữ lại phần còn lại) hoặc chỉ một giá trị (yêu cầu
để đặt tất cả các tính năng thành bộ được chỉ định).

Vì yêu cầu phải tuân theo kiểm tra độ chính xác của netdev_change_features(), tùy chọn
trả lời kernel (có thể bị chặn bởi cờ ZZ0000ZZ trong yêu cầu
header) thông báo cho khách hàng về kết quả thực tế. ZZ0001ZZ
báo cáo sự khác biệt giữa yêu cầu của khách hàng và kết quả thực tế: mặt nạ bao gồm
số bit khác nhau giữa các tính năng được yêu cầu và kết quả (dev->features
sau thao tác), giá trị bao gồm các giá trị của các bit này trong yêu cầu
(tức là các giá trị phủ định từ các tính năng thu được). ZZ0002ZZ
báo cáo sự khác biệt giữa dev->features cũ và mới: mặt nạ bao gồm
các bit đã thay đổi, giá trị là giá trị của chúng trong các tính năng dev-> mới (sau
thao tác).

Thông báo ZZ0000ZZ không chỉ được gửi nếu tính năng của thiết bị
được sửa đổi bằng yêu cầu ZZ0001ZZ hoặc trên ethtool ioctl
request mà còn mỗi lần các tính năng được sửa đổi bằng netdev_update_features()
hoặc netdev_change_features().


PRIVFLAGS_GET
=============

Nhận các cờ riêng tư như yêu cầu ZZ0000ZZ ioctl.

Nội dung yêu cầu:

=========================================== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  =========================================== =============================

Nội dung phản hồi hạt nhân:

=========================================== =============================
  Tiêu đề trả lời lồng nhau ZZ0000ZZ
  Cờ riêng bitset ZZ0001ZZ
  =========================================== =============================

ZZ0000ZZ là một bitset có các giá trị cờ riêng của thiết bị.
Các cờ này được xác định bởi trình điều khiển, số lượng và tên của chúng (và cả ý nghĩa)
phụ thuộc vào thiết bị. Đối với định dạng bitset nhỏ gọn, tên có thể được truy xuất dưới dạng
Bộ dây ZZ0001ZZ. Nếu định dạng bitset chi tiết được yêu cầu,
phản hồi sử dụng tất cả các cờ riêng được thiết bị hỗ trợ làm mặt nạ để ứng dụng khách
lấy thông tin đầy đủ mà không cần phải tìm nạp chuỗi có tên.


PRIVFLAGS_SET
=============

Đặt hoặc sửa đổi giá trị của cờ riêng của thiết bị như ZZ0000ZZ
yêu cầu ioctl.

Nội dung yêu cầu:

=========================================== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  Cờ riêng bitset ZZ0001ZZ
  =========================================== =============================

ZZ0000ZZ có thể đặt toàn bộ bộ cờ riêng hoặc
chỉ sửa đổi giá trị của một số trong số chúng.


RINGS_GET
=========

Nhận kích thước vòng như yêu cầu ZZ0000ZZ ioctl.

Nội dung yêu cầu:

=========================================== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  =========================================== =============================

Nội dung phản hồi hạt nhân:

======================================== ====== ==============================
  Tiêu đề trả lời lồng nhau ZZ0000ZZ
  ZZ0001ZZ u32 kích thước tối đa của vòng RX
  ZZ0002ZZ u32 kích thước tối đa của vòng mini RX
  ZZ0003ZZ u32 kích thước tối đa của vòng jumbo RX
  ZZ0004ZZ u32 kích thước tối đa của vòng TX
  Kích thước ZZ0005ZZ u32 của vòng RX
  Kích thước ZZ0006ZZ u32 của vòng mini RX
  Kích thước ZZ0007ZZ u32 của vòng jumbo RX
  Kích thước ZZ0008ZZ u32 của vòng TX
  Kích thước bộ đệm ZZ0009ZZ u32 trên vòng
  ZZ0010ZZ u8 TCP tiêu đề/tách dữ liệu
  ZZ0011ZZ u32 Kích thước của TX/RX CQE
  Cờ ZZ0012ZZ u8 của chế độ Đẩy TX
  Cờ ZZ0013ZZ u8 của chế độ Đẩy RX
  Kích thước ZZ0014ZZ u32 của bộ đệm đẩy TX
  ZZ0015ZZ u32 kích thước tối đa của bộ đệm đẩy TX
  Ngưỡng ZZ0016ZZ u32 của
                                                    phân chia tiêu đề/dữ liệu
  Ngưỡng tối đa của ZZ0017ZZ u32
                                                    phân chia tiêu đề/dữ liệu
  ======================================== ====== ==============================

ZZ0000ZZ cho biết thiết bị có thể sử dụng được với
nhận không sao chép TCP lật trang (ZZ0001ZZ).
Nếu được bật, thiết bị sẽ được cấu hình để đặt tiêu đề khung và dữ liệu vào
bộ đệm riêng biệt. Cấu hình thiết bị phải đảm bảo có thể nhận được
các trang bộ nhớ dữ liệu đầy đủ, ví dụ vì MTU đủ cao hoặc thông qua
HW-GRO.

Cờ ZZ0000ZZ được sử dụng để kích hoạt nhanh bộ mô tả
đường dẫn gửi hoặc nhận gói tin. Trong đường dẫn thông thường, trình điều khiển điền mô tả vào DRAM và
thông báo cho phần cứng NIC. Trong đường dẫn nhanh, trình điều khiển đẩy bộ mô tả vào thiết bị
thông qua ghi MMIO, do đó giảm độ trễ. Tuy nhiên, việc kích hoạt tính năng này
có thể làm tăng chi phí CPU. Trình điều khiển có thể thực thi bổ sung cho mỗi gói
kiểm tra tính đủ điều kiện (ví dụ: về kích thước gói).

ZZ0000ZZ chỉ định số byte tối đa của một
gói được truyền, trình điều khiển có thể đẩy trực tiếp đến thiết bị cơ bản
(chế độ 'đẩy'). Việc đẩy một số byte tải trọng tới thiết bị có
lợi thế của việc giảm độ trễ cho các gói nhỏ bằng cách tránh ánh xạ DMA (tương tự
như tham số ZZ0001ZZ) cũng như cho phép cơ bản
thiết bị xử lý các tiêu đề gói trước khi lấy tải trọng của nó.
Điều này có thể giúp thiết bị thực hiện các hành động nhanh chóng dựa trên tiêu đề của gói.
Điều này tương tự với tham số "tx-copybreak", sao chép gói tin vào một
vùng bộ nhớ DMA được phân bổ trước thay vì ánh xạ bộ nhớ mới. Tuy nhiên,
Tham số tx-push-buff sao chép gói trực tiếp vào thiết bị để cho phép
thiết bị để thực hiện hành động nhanh hơn trên gói.

RINGS_SET
=========

Đặt kích thước vòng như yêu cầu ZZ0000ZZ ioctl.

Nội dung yêu cầu:

=========================================== ==============================
  Tiêu đề trả lời lồng nhau ZZ0000ZZ
  Kích thước ZZ0001ZZ u32 của vòng RX
  Kích thước ZZ0002ZZ u32 của vòng mini RX
  Kích thước ZZ0003ZZ u32 của vòng jumbo RX
  Kích thước ZZ0004ZZ u32 của vòng TX
  Kích thước bộ đệm ZZ0005ZZ u32 trên vòng
  ZZ0006ZZ u8 TCP tiêu đề / chia dữ liệu
  ZZ0007ZZ u32 Kích thước của TX/RX CQE
  Cờ ZZ0008ZZ u8 của chế độ Đẩy TX
  Cờ ZZ0009ZZ u8 của chế độ Đẩy RX
  Kích thước ZZ0010ZZ u32 của bộ đệm đẩy TX
  ZZ0011ZZ u32 ngưỡng phân chia tiêu đề / dữ liệu
  =========================================== ==============================

Kiểm tra hạt nhân yêu cầu kích thước vòng không vượt quá giới hạn được báo cáo bởi
người lái xe. Trình điều khiển có thể áp đặt các ràng buộc bổ sung và có thể không hỗ trợ tất cả
thuộc tính.


ZZ0000ZZ chỉ định kích thước sự kiện hàng đợi hoàn thành.
Các sự kiện xếp hàng hoàn thành (CQE) là các sự kiện được NIC đăng để chỉ ra
trạng thái hoàn thành của gói khi gói được gửi (như gửi thành công hoặc
lỗi) hoặc đã nhận được (như con trỏ tới các đoạn gói). Thông số kích thước CQE
cho phép sửa đổi kích thước CQE khác với kích thước mặc định nếu NIC hỗ trợ nó.
CQE lớn hơn có thể có nhiều con trỏ bộ đệm nhận hơn và NIC có thể
chuyển một khung lớn hơn từ dây. Dựa trên phần cứng NIC, tổng thể
kích thước hàng đợi hoàn thành có thể được điều chỉnh trong trình điều khiển nếu kích thước CQE được sửa đổi.

ZZ0000ZZ chỉ định giá trị ngưỡng của
tính năng phân chia tiêu đề/dữ liệu. Nếu kích thước gói nhận được lớn hơn kích thước này
giá trị ngưỡng, tiêu đề và dữ liệu sẽ được phân chia.

CHANNELS_GET
============

Nhận số lượng kênh như yêu cầu ZZ0000ZZ ioctl.

Nội dung yêu cầu:

=========================================== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  =========================================== =============================

Nội dung phản hồi hạt nhân:

====================================== ====== =============================
  Tiêu đề trả lời lồng nhau ZZ0000ZZ
  Kênh nhận tối đa ZZ0001ZZ u32
  Kênh truyền tối đa ZZ0002ZZ u32
  ZZ0003ZZ u32 max các kênh khác
  Kênh kết hợp tối đa ZZ0004ZZ u32
  ZZ0005ZZ u32 nhận số kênh
  Số kênh truyền ZZ0006ZZ u32
  ZZ0007ZZ u32 số kênh khác
  Số kênh kết hợp ZZ0008ZZ u32
  ====================================== ====== =============================


CHANNELS_SET
============

Đặt số lượng kênh như yêu cầu ZZ0000ZZ ioctl.

Nội dung yêu cầu:

====================================== ====== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  ZZ0001ZZ u32 nhận số kênh
  Số kênh truyền ZZ0002ZZ u32
  ZZ0003ZZ u32 số kênh khác
  Số kênh kết hợp ZZ0004ZZ u32
  ====================================== ====== =============================

Kiểm tra hạt nhân để đảm bảo số lượng kênh được yêu cầu không vượt quá giới hạn được báo cáo bởi
người lái xe. Trình điều khiển có thể áp đặt các ràng buộc bổ sung và có thể không hỗ trợ tất cả
thuộc tính.


COALESCE_GET
============

Nhận các tham số hợp nhất như yêu cầu ZZ0000ZZ ioctl.

Nội dung yêu cầu:

=========================================== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  =========================================== =============================

Nội dung phản hồi hạt nhân:

============================================ ====== ==========================
  Tiêu đề trả lời lồng nhau ZZ0000ZZ
  Độ trễ ZZ0001ZZ u32 (chúng tôi), Rx bình thường
  Gói tối đa ZZ0002ZZ u32, Rx bình thường
  Độ trễ ZZ0003ZZ u32 (chúng tôi), Rx trong IRQ
  Gói tối đa ZZ0004ZZ u32, Rx trong IRQ
  Độ trễ ZZ0005ZZ u32 (chúng tôi), Tx bình thường
  Gói tối đa ZZ0006ZZ u32, Tx bình thường
  Độ trễ ZZ0007ZZ u32 (chúng tôi), Tx trong IRQ
  Gói ZZ0008ZZ u32 IRQ, Tx trong IRQ
  ZZ0009ZZ u32 trì hoãn cập nhật số liệu thống kê
  ZZ0010ZZ bool thích ứng Rx hợp nhất
  ZZ0011ZZ bool thích ứng Tx kết hợp
  Ngưỡng ZZ0012ZZ u32 cho tốc độ thấp
  Độ trễ ZZ0013ZZ u32 (chúng tôi), Rx thấp
  Gói tối đa ZZ0014ZZ u32, Rx thấp
  Độ trễ ZZ0015ZZ u32 (chúng tôi), Tx thấp
  Gói tối đa ZZ0016ZZ u32, Tx thấp
  Ngưỡng ZZ0017ZZ u32 cho tốc độ cao
  Độ trễ ZZ0018ZZ u32 (chúng tôi), Rx cao
  Gói tối đa ZZ0019ZZ u32, Rx cao
  Độ trễ ZZ0020ZZ u32 (chúng tôi), Tx cao
  Gói tối đa ZZ0021ZZ u32, Tx cao
  Khoảng thời gian lấy mẫu tốc độ ZZ0022ZZ u32
  Chế độ đặt lại bộ hẹn giờ bool ZZ0023ZZ, Tx
  Chế độ đặt lại bộ hẹn giờ bool ZZ0024ZZ, Rx
  Kích thước tổng hợp tối đa ZZ0025ZZ u32, Tx
  Gói tổng hợp tối đa ZZ0026ZZ u32, Tx
  ZZ0027ZZ u32 thời gian (chúng tôi), aggr, Tx
  Cấu hình lồng nhau của ZZ0028ZZ của DIM, Rx
  Hồ sơ lồng nhau của ZZ0029ZZ của DIM, Tx
  Gói tối đa ZZ0030ZZ u32, Rx CQE
  Độ trễ ZZ0031ZZ u32 (ns), Rx CQE
  ============================================ ====== ==========================

Các thuộc tính chỉ được đưa vào trong phản hồi nếu giá trị của chúng không bằng 0 hoặc
bit tương ứng trong ZZ0000ZZ được đặt (tức là
chúng được khai báo là được hỗ trợ bởi trình điều khiển).

Chế độ đặt lại hẹn giờ (ZZ0000ZZ và
ZZ0001ZZ) kiểm soát sự tương tác giữa gói
đến và các tham số độ trễ dựa trên thời gian khác nhau. Theo mặc định bộ hẹn giờ là
dự kiến sẽ hạn chế độ trễ tối đa giữa bất kỳ gói đến/đi nào và
ngắt tương ứng. Ở chế độ này, bộ đếm thời gian phải được bắt đầu bằng gói
đến (đôi khi gửi ngắt trước đó) và đặt lại khi ngắt
được giao.
Đặt thuộc tính thích hợp thành 1 sẽ bật chế độ ZZ0002ZZ, trong đó
mỗi sự kiện gói sẽ đặt lại bộ đếm thời gian. Trong chế độ này, bộ đếm thời gian được sử dụng để buộc
ngắt nếu hàng đợi không hoạt động, trong khi hàng đợi bận phụ thuộc vào gói
giới hạn kích hoạt ngắt.

Tập hợp Tx bao gồm việc sao chép các khung vào một bộ đệm liền kề để chúng
có thể được gửi dưới dạng một hoạt động IO duy nhất. ZZ0000ZZ
mô tả kích thước tối đa tính bằng byte cho bộ đệm được gửi.
ZZ0001ZZ mô tả số lượng khung hình tối đa
có thể được tổng hợp thành một bộ đệm duy nhất.
ZZ0002ZZ mô tả lượng thời gian trong usecs,
được tính kể từ khi gói đầu tiên đến trong một khối tổng hợp, sau đó gói
khối nên được gửi đi.
Tính năng này chủ yếu được quan tâm đối với các thiết bị USB cụ thể không đáp ứng được
tốt với việc truyền URB cỡ nhỏ thường xuyên.

ZZ0000ZZ và ZZ0001ZZ tham khảo
đến các thông số DIM, xem ZZ0002ZZ.

Kết hợp Rx CQE cho phép kết hợp nhiều gói đã nhận thành một
Mục nhập hàng đợi hoàn thành duy nhất (CQE) hoặc ghi lại bộ mô tả.
ZZ0000ZZ mô tả số lượng tối đa
các khung có thể được hợp nhất thành CQE hoặc writeback.
ZZ0001ZZ mô tả thời gian tối đa tính bằng nano giây sau
gói đầu tiên đến trong CQE được hợp nhất hoặc viết lại sẽ được gửi.

COALESCE_SET
============

Đặt các tham số hợp nhất như yêu cầu ZZ0000ZZ ioctl.

Nội dung yêu cầu:

============================================ ====== ==========================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  Độ trễ ZZ0001ZZ u32 (chúng tôi), Rx bình thường
  Gói tối đa ZZ0002ZZ u32, Rx bình thường
  Độ trễ ZZ0003ZZ u32 (chúng tôi), Rx trong IRQ
  Gói tối đa ZZ0004ZZ u32, Rx trong IRQ
  Độ trễ ZZ0005ZZ u32 (chúng tôi), Tx bình thường
  Gói tối đa ZZ0006ZZ u32, Tx bình thường
  Độ trễ ZZ0007ZZ u32 (chúng tôi), Tx trong IRQ
  Gói ZZ0008ZZ u32 IRQ, Tx trong IRQ
  ZZ0009ZZ u32 trì hoãn cập nhật số liệu thống kê
  ZZ0010ZZ bool thích ứng Rx hợp nhất
  ZZ0011ZZ bool thích ứng Tx kết hợp
  Ngưỡng ZZ0012ZZ u32 cho tốc độ thấp
  Độ trễ ZZ0013ZZ u32 (chúng tôi), Rx thấp
  Gói tối đa ZZ0014ZZ u32, Rx thấp
  Độ trễ ZZ0015ZZ u32 (chúng tôi), Tx thấp
  Gói tối đa ZZ0016ZZ u32, Tx thấp
  Ngưỡng ZZ0017ZZ u32 cho tốc độ cao
  Độ trễ ZZ0018ZZ u32 (chúng tôi), Rx cao
  Gói tối đa ZZ0019ZZ u32, Rx cao
  Độ trễ ZZ0020ZZ u32 (chúng tôi), Tx cao
  Gói tối đa ZZ0021ZZ u32, Tx cao
  Khoảng thời gian lấy mẫu tốc độ ZZ0022ZZ u32
  Chế độ đặt lại bộ hẹn giờ bool ZZ0023ZZ, Tx
  Chế độ đặt lại bộ hẹn giờ bool ZZ0024ZZ, Rx
  Kích thước tổng hợp tối đa ZZ0025ZZ u32, Tx
  Gói tổng hợp tối đa ZZ0026ZZ u32, Tx
  ZZ0027ZZ u32 thời gian (chúng tôi), aggr, Tx
  Cấu hình lồng nhau của ZZ0028ZZ của DIM, Rx
  Hồ sơ lồng nhau của ZZ0029ZZ của DIM, Tx
  Gói tối đa ZZ0030ZZ u32, Rx CQE
  Độ trễ ZZ0031ZZ u32 (ns), Rx CQE
  ============================================ ====== ==========================

Yêu cầu bị từ chối nếu thuộc tính được khai báo là không được trình điều khiển hỗ trợ (tức là.
sao cho bit tương ứng trong ZZ0000ZZ
không được đặt), bất kể giá trị của chúng là gì. Lái xe có thể áp dụng thêm
các ràng buộc về việc kết hợp các tham số và giá trị của chúng.

So với các yêu cầu được đưa ra thông qua phiên bản liên kết mạng ZZ0000ZZ của yêu cầu này
sẽ cố gắng hơn nữa để đảm bảo rằng các giá trị do người dùng chỉ định đã được áp dụng
và có thể gọi tài xế hai lần.


PAUSE_GET
=========

Nhận cài đặt khung tạm dừng như yêu cầu ioctl ZZ0000ZZ.

Nội dung yêu cầu:

====================================== ====== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  Nguồn thống kê ZZ0001ZZ u32
  ====================================== ====== =============================

ZZ0000ZZ là tùy chọn. Nó nhận các giá trị từ:

.. kernel-doc:: include/uapi/linux/ethtool.h
    :identifiers: ethtool_mac_stats_src

Nếu vắng mặt trong yêu cầu, số liệu thống kê sẽ được cung cấp
thuộc tính ZZ0000ZZ trong phản hồi bằng
ZZ0001ZZ.

Nội dung phản hồi hạt nhân:

====================================== ====== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  ZZ0001ZZ bool tạm dừng tự động đàm phán
  ZZ0002ZZ bool nhận khung tạm dừng
  ZZ0003ZZ khung tạm dừng truyền bool
  Thống kê tạm dừng lồng nhau của ZZ0004ZZ
  ====================================== ====== =============================

ZZ0000ZZ được báo cáo nếu ZZ0001ZZ được đặt
trong ZZ0002ZZ.
Nó sẽ trống nếu người lái xe không báo cáo bất kỳ số liệu thống kê nào. Trình điều khiển điền vào
thống kê theo cấu trúc sau:

.. kernel-doc:: include/linux/ethtool.h
    :identifiers: ethtool_pause_stats

Mỗi thành viên có một thuộc tính tương ứng được xác định.

PAUSE_SET
=========

Đặt các tham số tạm dừng như yêu cầu ZZ0000ZZ ioctl.

Nội dung yêu cầu:

====================================== ====== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  ZZ0001ZZ bool tạm dừng tự động đàm phán
  ZZ0002ZZ bool nhận khung tạm dừng
  ZZ0003ZZ khung tạm dừng truyền bool
  ====================================== ====== =============================


EEE_GET
=======

Nhận các cài đặt Ethernet tiết kiệm năng lượng như yêu cầu ZZ0000ZZ ioctl.

Nội dung yêu cầu:

====================================== ====== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  ====================================== ====== =============================

Nội dung phản hồi hạt nhân:

====================================== ====== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  Các chế độ được quảng cáo/hỗ trợ bool ZZ0001ZZ
  ZZ0002ZZ chế độ liên kết được quảng cáo ngang hàng bool
  ZZ0003ZZ bool EEE được sử dụng tích cực
  ZZ0004ZZ bool EEE được kích hoạt
  Đã bật ZZ0005ZZ bool Tx lpi
  Hết thời gian chờ ZZ0006ZZ u32 Tx lpi (ở chúng tôi)
  ====================================== ====== =============================

Trong ZZ0000ZZ, mặt nạ bao gồm các chế độ liên kết mà EEE phục vụ
được bật, giá trị của các chế độ liên kết mà EEE được quảng cáo. Các chế độ liên kết dành cho nó
quảng cáo ngang hàng EEE được liệt kê trong ZZ0001ZZ (không có mặt nạ). các
giao diện netlink cho phép báo cáo trạng thái EEE cho tất cả các chế độ liên kết nhưng chỉ
32 đầu tiên được cung cấp bởi lệnh gọi lại ZZ0002ZZ.


EEE_SET
=======

Đặt các tham số Ethernet tiết kiệm năng lượng như yêu cầu ZZ0000ZZ ioctl.

Nội dung yêu cầu:

====================================== ====== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  Các chế độ quảng cáo bool ZZ0001ZZ
  ZZ0002ZZ bool EEE được kích hoạt
  Đã bật ZZ0003ZZ bool Tx lpi
  Hết thời gian chờ ZZ0004ZZ u32 Tx lpi (ở chúng tôi)
  ====================================== ====== =============================

ZZ0000ZZ được sử dụng để liệt kê các chế độ liên kết để quảng cáo
EEE cho (nếu không có mặt nạ) hoặc chỉ định các thay đổi trong danh sách (nếu có
một chiếc mặt nạ). Giao diện netlink cho phép báo cáo trạng thái EEE cho tất cả các chế độ liên kết
nhưng hiện tại chỉ có thể đặt 32 đầu tiên vì đó là những gì ZZ0001ZZ
hỗ trợ gọi lại.


TSINFO_GET
==========

Nhận thông tin về dấu thời gian như yêu cầu ZZ0000ZZ ioctl.

Nội dung yêu cầu:

========================================== ====== ===============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  ZZ0001ZZ nhà cung cấp đồng hồ hw PTP lồng nhau
  ========================================== ====== ===============================

Nội dung phản hồi hạt nhân:

====================================== ====== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  Cờ bit ZZ0001ZZ SO_TIMESTAMPING
  Các loại Tx được hỗ trợ bit ZZ0002ZZ
  Bộ lọc Rx được hỗ trợ bit ZZ0003ZZ
  Chỉ số đồng hồ hw ZZ0004ZZ u32 PTP hw
  Thống kê về dấu thời gian CTNH lồng nhau của ZZ0005ZZ
  ====================================== ====== =============================

ZZ0000ZZ vắng mặt nếu không có PHC liên quan (có
không có giá trị đặc biệt cho trường hợp này). Các thuộc tính bitset bị bỏ qua nếu chúng
sẽ trống (không có bit nào được đặt).

Nội dung phản hồi thống kê đánh dấu thời gian phần cứng bổ sung:

==================================================== ====== ========================
  Gói uint ZZ0000ZZ có Tx
                                                              Dấu thời gian CTNH
  Dấu thời gian ZZ0001ZZ uint Tx HW
                                                              chưa đến được tính
  ZZ0002ZZ yêu cầu lỗi uint HW
                                                              Số dấu thời gian Tx
  Gói uint ZZ0003ZZ với một bước
                                                              Dấu thời gian HW TX với
                                                              giao hàng chưa được xác nhận
  ==================================================== ====== ========================

CABLE_TEST
==========

Bắt đầu kiểm tra cáp.

Nội dung yêu cầu:

=========================================== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  =========================================== =============================

Nội dung thông báo:

Cáp Ethernet thường chứa 1, 2 hoặc 4 cặp. Chiều dài của
cặp chỉ có thể được đo khi có lỗi trong cặp và
do đó một sự phản ánh. Thông tin về lỗi có thể không có sẵn,
tùy thuộc vào phần cứng cụ thể. Do đó nội dung của thông báo
tin nhắn chủ yếu là tùy chọn. Các thuộc tính có thể được lặp lại một
số lần tùy ý, theo thứ tự tùy ý, tùy ý
số cặp.

Ví dụ hiển thị thông báo được gửi khi bài kiểm tra hoàn thành
một cáp T2, tức là hai cặp. Một cặp là được và do đó không có độ dài
thông tin. Cặp thứ hai có lỗi và có chiều dài
thông tin.

+---------------------------------------------+--------+----------------------+
 ZZ0014ZZ lồng nhau ZZ0015ZZ
 +---------------------------------------------+--------+----------------------+
 ZZ0016ZZ u8 ZZ0017ZZ
 +---------------------------------------------+--------+----------------------+
 ZZ0018ZZ lồng nhau ZZ0019ZZ
 +-+-------------------------------------------------------+--------+----------------------+
 Kết quả kiểm tra cáp ZZ0020ZZ ZZ0003ZZ ZZ0021ZZ |
 +-+-+------------------------------------------+--------+----------------------+
 ZZ0022ZZ ZZ0023ZZ u8 ZZ0024ZZ
 +-+-+------------------------------------------+--------+----------------------+
 ZZ0025ZZ ZZ0026ZZ u8 ZZ0027ZZ
 +-+-+------------------------------------------+--------+----------------------+
 Kết quả kiểm tra cáp ZZ0028ZZ ZZ0006ZZ ZZ0029ZZ |
 +-+-+------------------------------------------+--------+----------------------+
 ZZ0030ZZ ZZ0031ZZ u8 ZZ0032ZZ
 +-+-+------------------------------------------+--------+----------------------+
 ZZ0033ZZ ZZ0034ZZ u8 ZZ0035ZZ
 +-+-+------------------------------------------+--------+----------------------+
 ZZ0036ZZ ZZ0037ZZ u32 ZZ0038ZZ
 +-+-+------------------------------------------+--------+----------------------+
 ZZ0039ZZ ZZ0010ZZ ZZ0040ZZ chiều dài cáp |
 +-+-+------------------------------------------+--------+----------------------+
 ZZ0041ZZ ZZ0042ZZ u8 ZZ0043ZZ
 +-+-+------------------------------------------+--------+----------------------+
 ZZ0044ZZ ZZ0045ZZ u32 ZZ0046ZZ
 +-+-+------------------------------------------+--------+----------------------+
 ZZ0047ZZ ZZ0048ZZ u32 ZZ0049ZZ
 +-+-+------------------------------------------+--------+----------------------+


CABLE_TEST TDR
==============

Bắt đầu kiểm tra cáp và báo cáo dữ liệu TDR thô

Nội dung yêu cầu:

+---------------------------------------------+--------+--------------+
 ZZ0006ZZ lồng nhau ZZ0007ZZ
 +---------------------------------------------+--------+--------------+
 ZZ0008ZZ lồng nhau ZZ0009ZZ
 ++-----------------------------------------------+--------+--------------+
 ZZ0010ZZ ZZ0002ZZ ZZ0011ZZ khoảng cách dữ liệu đầu tiên |
 ++-+----------------------------------------------+--------+--------------+
 ZZ0012ZZ ZZ0003ZZ ZZ0013ZZ khoảng cách dữ liệu cuối cùng |
 ++-+----------------------------------------------+--------+--------------+
 ZZ0014ZZ ZZ0004ZZ ZZ0015ZZ khoảng cách mỗi bước |
 ++-+----------------------------------------------+--------+--------------+
 Cặp ZZ0016ZZ ZZ0005ZZ ZZ0017ZZ để test |
 ++-+----------------------------------------------+--------+--------------+

ETHTOOL_A_CABLE_TEST_TDR_CFG là tùy chọn, cũng như tất cả các thành viên
của tổ. Tất cả khoảng cách được thể hiện bằng cm. PHY mất
khoảng cách làm hướng dẫn và làm tròn đến khoảng cách gần nhất
thực sự hỗ trợ. Nếu một cặp được thông qua thì chỉ có một cặp đó sẽ được
đã thử nghiệm. Nếu không thì tất cả các cặp đều được kiểm tra.

Nội dung thông báo:

Dữ liệu TDR thô được thu thập bằng cách gửi xung xuống cáp và
ghi lại biên độ của xung phản xạ trong một khoảng cách nhất định.

Có thể mất vài giây để thu thập dữ liệu TDR, đặc biệt nếu
toàn bộ 100 mét được thăm dò ở khoảng cách 1 mét. Khi bài kiểm tra được thực hiện
đã bắt đầu, một thông báo sẽ được gửi chỉ chứa
ETHTOOL_A_CABLE_TEST_TDR_STATUS với giá trị
ETHTOOL_A_CABLE_TEST_NTF_STATUS_STARTED.

Khi bài kiểm tra hoàn thành, thông báo thứ hai sẽ được gửi
chứa ETHTOOL_A_CABLE_TEST_TDR_STATUS với giá trị
Dữ liệu ETHTOOL_A_CABLE_TEST_NTF_STATUS_COMPLETED và TDR.

Tin nhắn có thể tùy ý chứa biên độ của xung gửi
xuống cáp. Điều này được đo bằng mV. Sự phản ánh không nên
lớn hơn xung truyền đi.

Trước dữ liệu TDR thô phải là ETHTOOL_A_CABLE_TDR_NEST_STEP
tổ chứa thông tin về khoảng cách dọc theo cáp cho
lần đọc đầu tiên, lần đọc cuối cùng và bước giữa mỗi lần đọc
đọc. Khoảng cách được đo bằng cm. Đây phải là những
giá trị chính xác mà PHY đã sử dụng. Những điều này có thể khác với những gì người dùng
được yêu cầu, nếu độ phân giải đo gốc lớn hơn 1 cm.

Đối với mỗi bước dọc theo cáp, một ETHTOOL_A_CABLE_TDR_NEST_AMPLITUDE được
được sử dụng để báo cáo biên độ phản xạ của một cặp nhất định.

+---------------------------------------------+--------+----------------------+
 ZZ0018ZZ lồng nhau ZZ0019ZZ
 +---------------------------------------------+--------+----------------------+
 ZZ0020ZZ u8 ZZ0021ZZ
 +---------------------------------------------+--------+----------------------+
 ZZ0022ZZ lồng nhau ZZ0023ZZ
 ++--------------------------------------------------+--------+----------------------+
 ZZ0024ZZ ZZ0003ZZ ZZ0025ZZ TX Biên độ xung |
 +-+-+------------------------------------------+--------+----------------------+
 ZZ0026ZZ ZZ0027ZZ s16 ZZ0028ZZ
 +-+-+------------------------------------------+--------+----------------------+
 Thông tin bước ZZ0029ZZ ZZ0005ZZ ZZ0030ZZ TDR |
 +-+-+------------------------------------------+--------+----------------------+
 ZZ0031ZZ ZZ0032ZZ u32 ZZ0033ZZ
 +-+-+------------------------------------------+--------+----------------------+
 ZZ0034ZZ ZZ0035ZZ u32 ZZ0036ZZ
 +-+-+------------------------------------------+--------+----------------------+
 ZZ0037ZZ ZZ0038ZZ u32 ZZ0039ZZ
 +-+-+------------------------------------------+--------+----------------------+
 ZZ0040ZZ ZZ0009ZZ ZZ0041ZZ Biên độ phản xạ |
 +-+-+------------------------------------------+--------+----------------------+
 ZZ0042ZZ ZZ0043ZZ u8 ZZ0044ZZ
 +-+-+------------------------------------------+--------+----------------------+
 ZZ0045ZZ ZZ0046ZZ s16 ZZ0047ZZ
 +-+-+------------------------------------------+--------+----------------------+
 ZZ0048ZZ ZZ0012ZZ ZZ0049ZZ Biên độ phản xạ |
 +-+-+------------------------------------------+--------+----------------------+
 ZZ0050ZZ ZZ0051ZZ u8 ZZ0052ZZ
 +-+-+------------------------------------------+--------+----------------------+
 ZZ0053ZZ ZZ0054ZZ s16 ZZ0055ZZ
 +-+-+------------------------------------------+--------+----------------------+
 ZZ0056ZZ ZZ0015ZZ ZZ0057ZZ Biên độ phản xạ |
 +-+-+------------------------------------------+--------+----------------------+
 ZZ0058ZZ ZZ0059ZZ u8 ZZ0060ZZ
 +-+-+------------------------------------------+--------+----------------------+
 ZZ0061ZZ ZZ0062ZZ s16 ZZ0063ZZ
 +-+-+------------------------------------------+--------+----------------------+

TUNNEL_INFO
===========

Nhận thông tin về trạng thái đường hầm mà NIC biết.

Nội dung yêu cầu:

====================================== ====== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  ====================================== ====== =============================

Nội dung phản hồi hạt nhân:

+---------------------------------------------+--------+----------------------+
 ZZ0008ZZ lồng nhau ZZ0009ZZ
 +---------------------------------------------+--------+----------------------+
 ZZ0010ZZ lồng nhau ZZ0011ZZ
 +-+-------------------------------------------------------+--------+----------------------+
 ZZ0012ZZ ZZ0002ZZ ZZ0013ZZ một bảng cổng UDP |
 +-+-+------------------------------------------+--------+----------------------+
 ZZ0014ZZ ZZ0015ZZ u32 ZZ0016ZZ
 ZZ0017ZZ ZZ0018ZZ ZZ0019ZZ
 +-+-+------------------------------------------+--------+----------------------+
 Bộ bit ZZ0020ZZ ZZ0021ZZ ZZ0022ZZ
 ZZ0023ZZ ZZ0024ZZ ZZ0025ZZ
 +-+-+------------------------------------------+--------+----------------------+
 ZZ0026ZZ ZZ0027ZZ lồng nhau ZZ0028ZZ
 +-+-+-+---------------------------------------+--------+----------------------+
 Cổng ZZ0029ZZ ZZ0030ZZ ZZ0006ZZ ZZ0031ZZ UDP cổng |
 +-+-+-+---------------------------------------+--------+----------------------+
 ZZ0032ZZ ZZ0033ZZ ZZ0007ZZ ZZ0034ZZ loại đường hầm |
 +-+-+-+---------------------------------------+--------+----------------------+

Đối với bảng đường hầm UDP trống, ZZ0000ZZ chỉ ra rằng
bảng chứa các mục tĩnh, được mã hóa cứng bởi NIC.

FEC_GET
=======

Nhận cấu hình và trạng thái FEC giống như yêu cầu ioctl ZZ0000ZZ.

Nội dung yêu cầu:

====================================== ====== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  ====================================== ====== =============================

Nội dung phản hồi hạt nhân:

====================================== ====== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  Các chế độ cấu hình bitset ZZ0001ZZ
  Tự động lựa chọn chế độ ZZ0002ZZ bool FEC
  Chỉ số ZZ0003ZZ u32 của chế độ FEC đang hoạt động
  Thống kê ZZ0004ZZ lồng nhau FEC
  ====================================== ====== =============================

ZZ0000ZZ hiện tại là chỉ số bit của chế độ liên kết FEC
hoạt động trên giao diện. Thuộc tính này có thể không xuất hiện nếu thiết bị không
không hỗ trợ FEC.

ZZ0000ZZ và ZZ0001ZZ chỉ có ý nghĩa khi
tự động đàm phán bị vô hiệu hóa. Nếu ZZ0002ZZ là trình điều khiển khác 0 sẽ
tự động chọn chế độ FEC dựa trên các thông số của mô-đun SFP.
Điều này tương đương với bit ZZ0003ZZ của giao diện ioctl.
ZZ0004ZZ mang cấu hình FEC hiện tại bằng chế độ liên kết
bit (chứ không phải các bit ZZ0005ZZ cũ).

ZZ0000ZZ được báo cáo nếu ZZ0001ZZ được đặt trong
ZZ0002ZZ.
Mỗi thuộc tính mang một mảng thống kê 64bit. Mục nhập đầu tiên trong mảng
chứa tổng số sự kiện trên cổng, trong khi các mục sau
là các bộ đếm tương ứng với các làn/phiên bản PCS. Số lượng mục trong
mảng sẽ là:

+--------------+---------------------------------------------+
Thiết bị ZZ0003ZZ không hỗ trợ thống kê FEC |
+--------------+---------------------------------------------+
Thiết bị ZZ0004ZZ không hỗ trợ phân tích từng làn |
+--------------+---------------------------------------------+
Thiết bị ZZ0005ZZ có hỗ trợ đầy đủ các chỉ số FEC |
+--------------+---------------------------------------------+

Trình điều khiển điền số liệu thống kê theo cấu trúc sau:

.. kernel-doc:: include/linux/ethtool.h
    :identifiers: ethtool_fec_stats

Thống kê có thể có thuộc tính biểu đồ thùng FEC ZZ0000ZZ
như được định nghĩa trong IEEE 802.3ck-2022 và 802.3df-2024. Các thuộc tính lồng nhau sẽ có
phạm vi lỗi FEC trong thùng (đã bao gồm) và số lượng sự kiện lỗi
trong thùng.

FEC_SET
=======

Đặt tham số FEC như yêu cầu ZZ0000ZZ ioctl.

Nội dung yêu cầu:

====================================== ====== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  Các chế độ cấu hình bitset ZZ0001ZZ
  Tự động lựa chọn chế độ ZZ0002ZZ bool FEC
  ====================================== ====== =============================

ZZ0000ZZ chỉ có ý nghĩa khi tính năng tự động đàm phán bị tắt. Nếu không
Chế độ FEC được chọn như một phần của quá trình tự động đàm phán.

ZZ0000ZZ chọn chế độ FEC nào sẽ được sử dụng. Nó được khuyến khích
chỉ đặt một bit, nếu nhiều bit được đặt, trình điều khiển có thể chọn giữa chúng
một cách cụ thể để thực hiện.

ZZ0000ZZ yêu cầu trình điều khiển chọn chế độ FEC dựa trên SFP
thông số mô-đun. Điều này không có nghĩa là tự thương lượng.

MODULE_EEPROM_GET
=================

Tìm nạp kết xuất dữ liệu mô-đun EEPROM.
Giao diện này được thiết kế để cho phép kết xuất tối đa 1/2 trang cùng một lúc. Cái này
có nghĩa là chỉ cho phép kết xuất 128 (hoặc ít hơn) byte mà không vượt qua nửa trang
ranh giới nằm ở offset 128. Đối với các trang khác 0, chỉ có 128 byte cao là
có thể truy cập được.

Nội dung yêu cầu:

========================================= ====== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  ZZ0001ZZ u32 bù trong một trang
  ZZ0002ZZ u32 số byte cần đọc
  Số trang ZZ0003ZZ u8
  Số ngân hàng ZZ0004ZZ u8
  Trang ZZ0005ZZ u8 Địa chỉ I2C
  ========================================= ====== =============================

Nếu ZZ0000ZZ không được chỉ định, ngân hàng 0 được giả sử.

Nội dung phản hồi hạt nhân:

+---------------------------------------------+--------+----------------------+
 ZZ0002ZZ lồng nhau ZZ0003ZZ
 +---------------------------------------------+--------+----------------------+
 ZZ0004ZZ nhị phân ZZ0005ZZ
 ZZ0006ZZ ZZ0007ZZ
 +---------------------------------------------+--------+----------------------+

ZZ0000ZZ có độ dài thuộc tính bằng số lượng
trình điều khiển byte thực sự đọc.

STATS_GET
=========

Nhận số liệu thống kê tiêu chuẩn cho giao diện. Lưu ý rằng đây không phải là
việc triển khai lại ZZ0000ZZ đã làm lộ ra
số liệu thống kê.

Nội dung yêu cầu:

========================================= ====== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  Nguồn thống kê ZZ0001ZZ u32
  Nhóm số liệu thống kê được yêu cầu bitset ZZ0002ZZ
  ========================================= ====== =============================

Nội dung phản hồi hạt nhân:

+-----------------------------------+--------+--------------------------------+
 ZZ0009ZZ lồng nhau ZZ0010ZZ
 +-----------------------------------+--------+--------------------------------+
 ZZ0011ZZ u32 ZZ0012ZZ
 +-----------------------------------+--------+--------------------------------+
 ZZ0013ZZ lồng nhau ZZ0014ZZ
 +-+-----------------------------------+--------+--------------------------------+
 ZZ0015ZZ ZZ0003ZZ ZZ0016ZZ ID nhóm - ZZ0004ZZ |
 +-+-----------------------------------+--------+--------------------------------+
 ZZ0017ZZ ZZ0005ZZ ZZ0018ZZ bộ chuỗi ID cho tên |
 +-+-----------------------------------+--------+--------------------------------+
 ZZ0019ZZ ZZ0006ZZ ZZ0020ZZ tổ chứa một thống kê |
 +-+-----------------------------------+--------+--------------------------------+
 Thống kê biểu đồ ZZ0021ZZ ZZ0007ZZ ZZ0022ZZ (Rx) |
 +-+-----------------------------------+--------+--------------------------------+
 Thống kê biểu đồ ZZ0023ZZ ZZ0008ZZ ZZ0024ZZ (Tx) |
 +-+-----------------------------------+--------+--------------------------------+

Người dùng chỉ định nhóm thống kê nào họ đang yêu cầu thông qua
bộ bit ZZ0000ZZ. Các giá trị được xác định hiện tại là:

======================= ============================================================
 ETHTOOL_STATS_ETH_MAC eth-mac Thống kê IEEE 802.3 MAC cơ bản (30.3.1.1.*)
 ETHTOOL_STATS_ETH_PHY eth-phy Thống kê cơ bản IEEE 802.3 PHY (30.3.2.1.*)
 ETHTOOL_STATS_ETH_CTRL eth-ctrl Thống kê cơ bản IEEE 802.3 MAC Ctrl (30.3.3.*)
 Thống kê ETHTOOL_STATS_RMON rmon RMON (RFC 2819)
 ETHTOOL_STATS_PHY phy Số liệu thống kê bổ sung về PHY, không được xác định bởi IEEE
 ======================= ============================================================

Mỗi nhóm phải có một ZZ0000ZZ tương ứng trong thư trả lời.
ZZ0001ZZ xác định tổ thống kê của nhóm nào chứa.
ZZ0002ZZ xác định ID bộ chuỗi cho tên của
số liệu thống kê trong nhóm, nếu có.

Số liệu thống kê được thêm vào tổ ZZ0000ZZ bên dưới
ZZ0001ZZ. ZZ0002ZZ nên chứa
thuộc tính 8 byte (u64) đơn bên trong - loại thuộc tính đó là
ID thống kê và giá trị là giá trị của thống kê.
Mỗi nhóm có cách giải thích riêng về ID thống kê.
ID thuộc tính tương ứng với các chuỗi từ bộ chuỗi được xác định
bởi ZZ0003ZZ. Số liệu thống kê phức tạp (chẳng hạn như biểu đồ RMON
mục) cũng được liệt kê bên trong ZZ0004ZZ và không có
một chuỗi được xác định trong tập hợp chuỗi.

Bộ đếm "biểu đồ" RMON đếm số lượng gói trong phạm vi kích thước nhất định.
Bởi vì RFC không chỉ định phạm vi vượt quá 1518 thiết bị MTU tiêu chuẩn
khác nhau về định nghĩa của xô. Vì lý do này, định nghĩa về phạm vi gói
được giao cho mỗi người lái xe.

Tổ ZZ0000ZZ và ZZ0001ZZ
chứa các thuộc tính sau:

================================== ====== =======================================
 ETHTOOL_A_STATS_RMON_HIST_BKT_LOW u32 giới hạn thấp của nhóm kích thước gói
 ETHTOOL_A_STATS_RMON_HIST_BKT_HI u32 giới hạn cao của thùng
 Bộ đếm gói ETHTOOL_A_STATS_RMON_HIST_VAL u64
 ================================== ====== =======================================

Giới hạn thấp và cao đều bao gồm, ví dụ:

=============================== ==== ====
 Thống kê RFC thấp cao
 =============================== ==== ====
 etherStatsPkts64Octets 0 64
 etherStatsPkts512to1023Octets 512 1023
 =============================== ==== ====

ZZ0000ZZ là tùy chọn. Tương tự như ZZ0001ZZ, nó nhận các giá trị
từ ZZ0002ZZ. Nếu vắng mặt trong yêu cầu, số liệu thống kê sẽ được
được cung cấp thuộc tính ZZ0003ZZ trong phản hồi bằng
ZZ0004ZZ.

PHC_VCLOCKS_GET
===============

Truy vấn thông tin đồng hồ ảo PHC của thiết bị.

Nội dung yêu cầu:

=========================================== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  =========================================== =============================

Nội dung phản hồi hạt nhân:

=========================================== =============================
  Tiêu đề trả lời lồng nhau ZZ0000ZZ
  Số đồng hồ ảo ZZ0001ZZ u32 PHC
  Mảng chỉ số ZZ0002ZZ s32 PHC
  =========================================== =============================

MODULE_GET
==========

Nhận thông số mô-đun thu phát.

Nội dung yêu cầu:

====================================== ====== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  ====================================== ====== =============================

Nội dung phản hồi hạt nhân:

======================================= ====== =============================
  Tiêu đề trả lời lồng nhau ZZ0000ZZ
  Chính sách chế độ nguồn ZZ0001ZZ u8
  Chế độ năng lượng hoạt động ZZ0002ZZ u8
  ======================================= ====== =============================

Thuộc tính ZZ0000ZZ tùy chọn mã hóa
Chính sách chế độ nguồn của mô-đun thu phát được thực thi bởi máy chủ. Chính sách mặc định
phụ thuộc vào trình điều khiển, nhưng "tự động" là mặc định được đề xuất và nó phải là
được triển khai bởi các trình điều khiển và trình điều khiển mới nơi tuân thủ hành vi cũ
không quan trọng.

Thuộc tính ZZ0000ZZ tùy chọn mã hóa hoạt động
chính sách chế độ nguồn của mô-đun thu phát. Nó chỉ được báo cáo khi một mô-đun
đã được cắm vào. Các giá trị có thể là:

.. kernel-doc:: include/uapi/linux/ethtool.h
    :identifiers: ethtool_module_power_mode

MODULE_SET
==========

Đặt tham số mô-đun thu phát.

Nội dung yêu cầu:

======================================= ====== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  Chính sách chế độ nguồn ZZ0001ZZ u8
  ======================================= ====== =============================

Khi được đặt, thuộc tính ZZ0000ZZ tùy chọn sẽ được sử dụng
để đặt chính sách nguồn điện của mô-đun thu phát do máy chủ thực thi. Có thể
giá trị là:

.. kernel-doc:: include/uapi/linux/ethtool.h
    :identifiers: ethtool_module_power_mode_policy

Đối với các mô-đun SFF-8636, máy chủ buộc phải sử dụng chế độ năng lượng thấp theo bảng
6-10 trong bản sửa đổi 2.10a của thông số kỹ thuật.

Đối với mô-đun CMIS, máy chủ buộc phải áp dụng chế độ năng lượng thấp theo bảng 6-12
trong phiên bản 5.0 của đặc tả.

PSE_GET
=======

Nhận thuộc tính PSE.

Nội dung yêu cầu:

====================================== ====== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  ====================================== ====== =============================

Nội dung phản hồi hạt nhân:

============================================ ====== ================================
  Tiêu đề trả lời lồng nhau ZZ0000ZZ
  ZZ0001ZZ u32 Trạng thái hoạt động của PoDL
                                                      Chức năng PSE
  Trạng thái phát hiện nguồn điện ZZ0002ZZ u32 của
                                                      PoDL PSE.
  ZZ0003ZZ u32 Trạng thái hoạt động của PoE
                                                      Chức năng PSE.
  Trạng thái phát hiện nguồn điện ZZ0004ZZ u32 của
                                                      PoE PSE.
  Lớp năng lượng ZZ0005ZZ u32 của PoE PSE.
  ZZ0006ZZ u32 công suất thực tế được rút ra trên
                                                      PoE PSE.
  Trạng thái mở rộng nguồn ZZ0007ZZ u32 của
                                                      PoE PSE.
  Trạng thái phụ mở rộng nguồn ZZ0008ZZ u32 của
                                                      PoE PSE.
  Nguồn điện được cấu hình hiện tại của ZZ0009ZZ u32
                                                      giới hạn của PoE PSE.
  ZZ0010ZZ lồng nhau Giới hạn công suất được hỗ trợ
                                                      các phạm vi cấu hình.
  ZZ0011ZZ u32 Chỉ mục của miền năng lượng PSE
  ZZ0012ZZ u32 Cấu hình ưu tiên tối đa
                                                      trên PoE PSE
  ZZ0013ZZ u32 Ưu tiên của PoE PSE
                                                      hiện đang được cấu hình
  ============================================ ====== ================================

Khi được đặt, thuộc tính ZZ0000ZZ tùy chọn sẽ xác định
trạng thái hoạt động của các chức năng PoDL PSE.  Tình trạng hoạt động của
Chức năng PSE có thể được thay đổi bằng ZZ0001ZZ
hành động. Thuộc tính này tương ứng với ZZ0002ZZ 30.15.1.1.2
aPoDLPSEAdminState. Các giá trị có thể là:

.. kernel-doc:: include/uapi/linux/ethtool.h
    :identifiers: ethtool_podl_pse_admin_state

Điều tương tự cũng xảy ra với việc triển khai ZZ0000ZZ
ZZ0001ZZ 30.9.1.1.2 aPSEAdminState.

.. kernel-doc:: include/uapi/linux/ethtool.h
    :identifiers: ethtool_c33_pse_admin_state

Khi được đặt, thuộc tính ZZ0000ZZ tùy chọn sẽ xác định
trạng thái phát hiện nguồn điện của PoDL PSE.  Trạng thái phụ thuộc vào PSE nội bộ
máy trạng thái và hỗ trợ phân loại PD tự động. Thuộc tính này
tương ứng với ZZ0001ZZ 30.15.1.1.3 aPoDLPSEPowerDetectionStatus.
Các giá trị có thể là:

.. kernel-doc:: include/uapi/linux/ethtool.h
    :identifiers: ethtool_podl_pse_pw_d_status

Điều tương tự cũng xảy ra với việc triển khai ZZ0000ZZ
ZZ0001ZZ 30.9.1.1.5 aPSEPowerDetectionStatus.

.. kernel-doc:: include/uapi/linux/ethtool.h
    :identifiers: ethtool_c33_pse_pw_d_status

Khi được đặt, thuộc tính ZZ0000ZZ tùy chọn sẽ xác định
loại sức mạnh của C33 PSE. Nó phụ thuộc vào lớp được đàm phán giữa
PSE và PD. Thuộc tính này tương ứng với ZZ0001ZZ
30.9.1.1.8 aPSEPower Phân loại.

Khi được đặt, thuộc tính ZZ0000ZZ tùy chọn sẽ xác định
công suất thực tế do C33 PSE tiêu thụ. Thuộc tính này tương ứng với
ZZ0001ZZ 30.9.1.1.23 aPSEActuualPower. Công suất thực tế được báo cáo
tính bằng mW.

Khi được đặt, thuộc tính ZZ0000ZZ tùy chọn sẽ xác định
trạng thái lỗi mở rộng của C33 PSE. Các giá trị có thể là:

.. kernel-doc:: include/uapi/linux/ethtool.h
    :identifiers: ethtool_c33_pse_ext_state

Khi được đặt, thuộc tính ZZ0000ZZ tùy chọn sẽ xác định
trạng thái lỗi mở rộng của C33 PSE. Các giá trị có thể là:
Các giá trị có thể là:

.. kernel-doc:: include/uapi/linux/ethtool.h
    :identifiers: ethtool_c33_pse_ext_substate_class_num_events
		  ethtool_c33_pse_ext_substate_error_condition
		  ethtool_c33_pse_ext_substate_mr_pse_enable
		  ethtool_c33_pse_ext_substate_option_detect_ted
		  ethtool_c33_pse_ext_substate_option_vport_lim
		  ethtool_c33_pse_ext_substate_ovld_detected
		  ethtool_c33_pse_ext_substate_pd_dll_power_type
		  ethtool_c33_pse_ext_substate_power_not_available
		  ethtool_c33_pse_ext_substate_short_detected

Khi được đặt, thuộc tính ZZ0000ZZ tùy chọn
xác định giới hạn công suất C33 PSE tính bằng mW.

Khi đặt thuộc tính lồng nhau ZZ0000ZZ tùy chọn
xác định phạm vi giới hạn công suất C33 PSE thông qua
ZZ0001ZZ và
ZZ0002ZZ.
Nếu bộ điều khiển hoạt động với các lớp cố định, giá trị tối thiểu và tối đa sẽ là
bằng nhau.

Thuộc tính ZZ0000ZZ xác định chỉ số sức mạnh của PSE
miền.

Khi được đặt, thuộc tính ZZ0000ZZ tùy chọn sẽ xác định
giá trị ưu tiên tối đa PSE.
Khi được đặt, các thuộc tính ZZ0001ZZ tùy chọn sẽ được sử dụng để
xác định mức độ ưu tiên PSE hiện được cấu hình.
Để biết mô tả về các thuộc tính ưu tiên của PSE, hãy xem ZZ0002ZZ.

PSE_SET
=======

Đặt tham số PSE.

Nội dung yêu cầu:

======================================= ====== ================================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  ZZ0001ZZ u32 Điều khiển PoDL PSE Trạng thái quản trị
  ZZ0002ZZ u32 Kiểm soát trạng thái quản trị PSE
  ZZ0003ZZ u32 Điều khiển PoE PSE có sẵn
                                                  giới hạn sức mạnh
  ZZ0004ZZ u32 Ưu tiên điều khiển của
                                                  PoE PSE
  ======================================= ====== ================================

Khi được đặt, thuộc tính ZZ0000ZZ tùy chọn sẽ được sử dụng
để kiểm soát các chức năng Quản trị viên PoDL PSE. Tùy chọn này thực hiện
ZZ0001ZZ 30.15.1.2.1 acPoDLPSEAdminControl. Xem
ZZ0002ZZ cho các giá trị được hỗ trợ.

Điều tương tự cũng xảy ra với việc triển khai ZZ0000ZZ
ZZ0001ZZ 30.9.1.2.1 acPSEAdminControl.

Khi được đặt, thuộc tính ZZ0000ZZ tùy chọn là
được sử dụng để kiểm soát giới hạn giá trị công suất khả dụng cho C33 PSE tính bằng miliwatt.
Thuộc tính này tương ứng với biến ZZ0002ZZ được mô tả trong
Các biến ZZ0001ZZ 33.2.4.4 và ZZ0003ZZ trong 145.2.5.4
Các biến, được mô tả trong các lớp sức mạnh.

Người ta quyết định sử dụng miliwatt cho giao diện này để thống nhất nó với các giao diện khác.
giao diện giám sát năng lượng, cũng sử dụng miliwatt và để phù hợp với
các sản phẩm hiện có khác nhau ghi lại mức tiêu thụ điện năng tính bằng watt thay vì
các lớp học. Nếu cần cấu hình giới hạn công suất dựa trên các lớp, thì
chuyển đổi có thể được thực hiện trong không gian người dùng, ví dụ như bằng ethtool.

Khi được đặt, các thuộc tính ZZ0000ZZ tùy chọn sẽ được sử dụng để
kiểm soát mức độ ưu tiên PSE. Giá trị ưu tiên được phép nằm trong khoảng từ 0 đến
giá trị của thuộc tính ZZ0001ZZ.

Giá trị thấp hơn biểu thị mức độ ưu tiên cao hơn, nghĩa là giá trị ưu tiên
0 tương ứng với mức ưu tiên cổng cao nhất.
Ưu tiên cổng phục vụ hai chức năng:

- Thứ tự bật nguồn: Sau khi reset, các cổng sẽ được bật nguồn theo thứ tự
   ưu tiên từ cao nhất đến thấp nhất. Cổng có mức độ ưu tiên cao hơn
   (giá trị thấp hơn) bật nguồn trước.
 - Lệnh tắt máy: Khi vượt quá mức điện năng dự kiến, các cổng có công suất thấp hơn
   mức độ ưu tiên (giá trị cao hơn) sẽ bị tắt trước tiên.

PSE_NTF
=======

Thông báo sự kiện PSE.

Nội dung thông báo:

================================ ====== ===========================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  Sự kiện bit ZZ0001ZZ PSE
  ================================ ====== ===========================

Khi được đặt, thuộc tính ZZ0000ZZ tùy chọn sẽ xác định
Sự kiện PSE.

.. kernel-doc:: include/uapi/linux/ethtool_netlink_generated.h
    :identifiers: ethtool_pse_event

RSS_GET
=======

Nhận bảng hướng dẫn, khóa băm và thông tin hàm băm liên quan đến một
Bối cảnh RSS của một giao diện tương tự như yêu cầu ioctl ZZ0000ZZ.

Nội dung yêu cầu:

====================================== ====== ===============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  Số ngữ cảnh ZZ0001ZZ u32
  Số bối cảnh bắt đầu ZZ0002ZZ u32 (kết xuất)
====================================== ====== ===============================

ZZ0000ZZ chỉ định số ngữ cảnh RSS nào cần truy vấn,
nếu không đặt bối cảnh 0 (ngữ cảnh chính) sẽ được truy vấn. Các bãi rác có thể được lọc
theo thiết bị (chỉ liệt kê bối cảnh của một netdev nhất định). Lọc đơn
số ngữ cảnh không được hỗ trợ nhưng ZZ0001ZZ
có thể được sử dụng để bắt đầu kết xuất bối cảnh từ số đã cho (chủ yếu
được sử dụng để bỏ qua ngữ cảnh 0 và chỉ kết xuất các ngữ cảnh bổ sung).

Nội dung phản hồi hạt nhân:

============================================ ========================================
  Tiêu đề trả lời lồng nhau ZZ0000ZZ
  Số ngữ cảnh ZZ0001ZZ u32
  Chức năng băm ZZ0002ZZ u32 RSS
  ZZ0003ZZ byte bảng Indir nhị phân
  ZZ0004ZZ byte khóa nhị phân băm
  Chuyển đổi dữ liệu đầu vào ZZ0005ZZ u32 RSS
  Các trường Tiêu đề lồng nhau ZZ0006ZZ được bao gồm trong hàm băm
============================================ ========================================

Thuộc tính ETHTOOL_A_RSS_HFUNC là bitmap biểu thị hàm băm
đang được sử dụng. Các tùy chọn được hỗ trợ hiện tại là toeplitz, xor hoặc crc32.
Thuộc tính ETHTOOL_A_RSS_INDIR trả về bảng hướng dẫn RSS trong đó mỗi byte
cho biết số hàng đợi.
Thuộc tính ETHTOOL_A_RSS_INPUT_XFRM là một bitmap cho biết loại
chuyển đổi được áp dụng cho các trường giao thức đầu vào trước khi được cung cấp cho RSS
hfunc. Các tùy chọn được hỗ trợ hiện tại là đối xứng-xor và đối xứng-hoặc-xor.
ETHTOOL_A_RSS_FLOW_HASH mang bitmask loại mỗi luồng trong đó tiêu đề
các trường được bao gồm trong tính toán băm.

RSS_SET
=======

Nội dung yêu cầu:

============================================ =======================================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  Số ngữ cảnh ZZ0001ZZ u32
  Chức năng băm ZZ0002ZZ u32 RSS
  ZZ0003ZZ byte bảng Indir nhị phân
  ZZ0004ZZ byte khóa nhị phân băm
  Chuyển đổi dữ liệu đầu vào ZZ0005ZZ u32 RSS
  Các trường Tiêu đề lồng nhau ZZ0006ZZ được bao gồm trong hàm băm
============================================ =======================================

ZZ0000ZZ là bảng RSS tối thiểu mà người dùng mong đợi. hạt nhân và
trình điều khiển thiết bị có thể sao chép bảng nếu nó nhỏ hơn bảng nhỏ nhất
kích thước được thiết bị hỗ trợ. Ví dụ: nếu người dùng yêu cầu ZZ0001ZZ nhưng
thiết bị cần ít nhất 8 mục - bảng thực đang được sử dụng sẽ
ZZ0002ZZ. Hầu hết các thiết bị đều yêu cầu kích thước bàn để cấp nguồn
bằng 2, vì vậy các bảng có kích thước không phải là lũy thừa của 2 sẽ có khả năng bị từ chối.
Sử dụng bảng có kích thước 0 sẽ đặt lại bảng hướng dẫn về mặc định.

RSS_CREATE_ACT
==============

Nội dung yêu cầu:

============================================ =======================================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  Số ngữ cảnh ZZ0001ZZ u32
  Chức năng băm ZZ0002ZZ u32 RSS
  ZZ0003ZZ byte bảng Indir nhị phân
  ZZ0004ZZ byte khóa nhị phân băm
  Chuyển đổi dữ liệu đầu vào ZZ0005ZZ u32 RSS
============================================ =======================================

Nội dung phản hồi hạt nhân:

============================================ =======================================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  Số ngữ cảnh ZZ0001ZZ u32
============================================ =======================================

Tạo bối cảnh RSS bổ sung, nếu không có ZZ0000ZZ
hạt nhân được chỉ định sẽ tự động phân bổ một hạt nhân.

RSS_DELETE_ACT
==============

Nội dung yêu cầu:

============================================ =======================================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  Số ngữ cảnh ZZ0001ZZ u32
============================================ =======================================

Xóa bối cảnh RSS bổ sung.

PLCA_GET_CFG
============

Nhận IEEE 802.3cg-2019 Điều khoản 148 Tránh va chạm lớp vật lý
(PLCA) Thuộc tính lớp con hòa giải (RS).

Nội dung yêu cầu:

====================================== ====== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  ====================================== ====== =============================

Nội dung phản hồi hạt nhân:

======================================= ====== ================================
  Tiêu đề trả lời lồng nhau ZZ0000ZZ
  ZZ0001ZZ u16 Hỗ trợ quản lý PLCA
                                                  giao diện tiêu chuẩn/phiên bản
  ZZ0002ZZ u8 PLCA Quản trị viên
  ZZ0003ZZ u32 PLCA ID nút cục bộ duy nhất
  ZZ0004ZZ u32 Số lượng nút PLCA trên
                                                  mạng, bao gồm cả
                                                  điều phối viên
  Bộ đếm thời gian cơ hội truyền ZZ0005ZZ u32
                                                  giá trị tính theo thời gian bit (BT)
  ZZ0006ZZ u32 Số lượng gói bổ sung
                                                  nút được phép gửi
                                                  trong một ĐẾN duy nhất
  ZZ0007ZZ u32 Đã đến lúc chờ đợi MAC
                                                  truyền một khung hình mới trước
                                                  chấm dứt vụ nổ
  ======================================= ====== ================================

Khi được đặt, thuộc tính ZZ0000ZZ tùy chọn cho biết
tiêu chuẩn và phiên bản mà giao diện quản lý PLCA tuân thủ. Khi chưa được thiết lập,
giao diện dành riêng cho nhà cung cấp và (có thể) do trình điều khiển cung cấp.
Liên minh OPEN SIG chỉ định bản đồ đăng ký tiêu chuẩn cho PHY 10BASE-T1S
nhúng Lớp con hòa giải PLCA. Xem "Quản lý 10BASE-T1S PLCA
Đăng ký" tại ZZ0001ZZ

Khi được đặt, thuộc tính ZZ0000ZZ tùy chọn cho biết
trạng thái hành chính của PLCA RS. Khi không được đặt, nút hoạt động ở chế độ "đơn giản"
Chế độ CSMA/CD. Tùy chọn này tương ứng với ZZ0001ZZ 30.16.1.1.1
aPLCAAdminState / 30.16.1.2.1 acPLCAAdminControl.

Khi được đặt, thuộc tính ZZ0000ZZ tùy chọn cho biết
ID nút cục bộ được cấu hình của PHY. ID này xác định việc truyền nào
cơ hội (TO) được dành riêng cho nút truyền vào. Tùy chọn này là
tương ứng với ZZ0001ZZ 30.16.1.1.4 aPLCALocalNodeID. hợp lệ
phạm vi cho thuộc tính này là [0 .. 255] trong đó 255 có nghĩa là "không được định cấu hình".

Khi được đặt, thuộc tính ZZ0000ZZ tùy chọn cho biết
được định cấu hình số lượng nút PLCA tối đa trên phân đoạn trộn. Số này
xác định tổng số cơ hội truyền được tạo ra trong một
Chu trình PLCA. Thuộc tính này chỉ liên quan đến điều phối viên PLCA,
nút có aPLCALocalNodeID được đặt thành 0. Các nút theo dõi bỏ qua cài đặt này.
Tùy chọn này tương ứng với ZZ0001ZZ 30.16.1.1.3
aPLCANodeCount. Phạm vi hợp lệ cho thuộc tính này là [1 .. 255].

Khi được đặt, thuộc tính ZZ0000ZZ tùy chọn cho biết
giá trị được cấu hình của bộ định thời cơ hội truyền theo thời gian bit. Giá trị này
phải được đặt bằng nhau trên tất cả các nút chia sẻ phương tiện để PLCA hoạt động
một cách chính xác. Tùy chọn này tương ứng với ZZ0001ZZ 30.16.1.1.5
aPLCATransmitOpportunityTimer. Phạm vi hợp lệ cho thuộc tính này là
[0 .. 255].

Khi được đặt, thuộc tính ZZ0000ZZ tùy chọn cho biết
số lượng gói bổ sung được cấu hình mà nút được phép gửi trong một
cơ hội truyền đơn. Theo mặc định, thuộc tính này là 0, nghĩa là
nút chỉ có thể gửi một khung hình cho mỗi TO. Khi lớn hơn 0, PLCA RS
giữ TO sau bất kỳ lần truyền nào, chờ MAC gửi khung mới
cho tối đa aPLCABurstTimer BT. Điều này chỉ có thể xảy ra một số lần trên mỗi PLCA
chu kỳ lên đến giá trị của tham số này. Sau đó, vụ nổ kết thúc và
việc đếm TO bình thường được tiếp tục. Tùy chọn này tương ứng với
ZZ0001ZZ 30.16.1.1.6 aPLCAMaxBurstCount. Phạm vi hợp lệ cho việc này
thuộc tính là [0 .. 255].

Khi được đặt, thuộc tính ZZ0000ZZ tùy chọn cho biết cách
nhiều lần bit PLCA RS đợi MAC bắt đầu truyền mới
khi aPLCAMaxBurstCount lớn hơn 0. Nếu MAC không gửi được lệnh mới
khung trong thời gian này, cụm kết thúc và quá trình đếm TO tiếp tục.
Ngược lại, khung mới sẽ được gửi như một phần của cụm hiện tại. Tùy chọn này
tương ứng với ZZ0001ZZ 30.16.1.1.7 aPLCABurstTimer. các
phạm vi hợp lệ cho thuộc tính này là [0 .. 255]. Mặc dù, giá trị phải là
được đặt lớn hơn thời gian Khoảng cách giữa các khung (IFG) của MAC (cộng với một số lề)
để chế độ chụp liên tục PLCA hoạt động như dự định.

PLCA_SET_CFG
============

Đặt thông số PLCA RS.

Nội dung yêu cầu:

======================================= ====== ================================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  ZZ0001ZZ u8 PLCA Quản trị viên
  ZZ0002ZZ u8 PLCA ID nút cục bộ duy nhất
  ZZ0003ZZ u8 Số lượng nút PLCA trên
                                                  mạng, bao gồm cả
                                                  điều phối viên
  Bộ đếm thời gian cơ hội truyền ZZ0004ZZ u8
                                                  giá trị tính theo thời gian bit (BT)
  ZZ0005ZZ u8 Số lượng gói bổ sung
                                                  nút được phép gửi
                                                  trong một ĐẾN duy nhất
  ZZ0006ZZ u8 Đã đến lúc chờ đợi MAC
                                                  truyền một khung hình mới trước
                                                  chấm dứt vụ nổ
  ======================================= ====== ================================

Để biết mô tả về từng thuộc tính, hãy xem ZZ0000ZZ.

PLCA_GET_STATUS
===============

Nhận thông tin trạng thái PLCA RS.

Nội dung yêu cầu:

====================================== ====== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  ====================================== ====== =============================

Nội dung phản hồi hạt nhân:

======================================= ====== ================================
  Tiêu đề trả lời lồng nhau ZZ0000ZZ
  Trạng thái hoạt động của ZZ0001ZZ u8 PLCA RS
  ======================================= ====== ================================

Khi được đặt, thuộc tính ZZ0000ZZ cho biết nút có
phát hiện sự hiện diện của BEACON trên mạng. Lá cờ này là
tương ứng với ZZ0001ZZ 30.16.1.1.2 aPLCAStatus.

MM_GET
======

Truy xuất các tham số Hợp nhất 802.3 MAC.

Nội dung yêu cầu:

=========================================== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  =========================================== =============================

Nội dung phản hồi hạt nhân:

================================== ====== =======================================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  ZZ0001ZZ bool được đặt nếu RX được ưu tiên và SMD-V
                                             khung được kích hoạt
  ZZ0002ZZ bool được đặt nếu TX của các khung có thể chiếm trước là
                                             được kích hoạt về mặt quản trị (có thể
                                             không hoạt động nếu xác minh không thành công)
  ZZ0003ZZ bool được đặt nếu TX của các khung có thể chiếm trước là
                                             kích hoạt hoạt động
  ZZ0004ZZ u32 kích thước tối thiểu của truyền
                                             các đoạn không phải cuối cùng, tính bằng octet
  ZZ0005ZZ u32 kích thước tối thiểu nhận được không phải cuối cùng
                                             các mảnh, tính bằng octet
  Bool ZZ0006ZZ được đặt nếu TX của khung SMD-V là
                                             kích hoạt quản trị
  Trạng thái ZZ0007ZZ u8 của chức năng xác minh
  Độ trễ ZZ0008ZZ u32 giữa các lần xác minh
  Khoảng thời gian xác minh tối đa ZZ0009ZZ` u32
                                             được hỗ trợ bởi thiết bị
  ZZ0010ZZ lồng nhau IEEE 802.3-2018 điều khoản phụ 30.14.1
                                             Bộ đếm thống kê oMACMergeEntity
  ================================== ====== =======================================

Các thuộc tính được trình điều khiển thiết bị điền thông qua các mục sau
cấu trúc:

.. kernel-doc:: include/linux/ethtool.h
    :identifiers: ethtool_mm_state

ZZ0000ZZ sẽ báo cáo một trong các giá trị từ

.. kernel-doc:: include/uapi/linux/ethtool.h
    :identifiers: ethtool_mm_verify_status

Nếu ZZ0000ZZ được chuyển là sai trong ZZ0001ZZ
lệnh, ZZ0002ZZ sẽ báo cáo
ZZ0003ZZ hoặc ZZ0004ZZ,
nếu không nó sẽ báo cáo một trong các trạng thái khác.

Chúng tôi khuyên các trình điều khiển nên bắt đầu với pMAC bị vô hiệu hóa và bật nó khi
yêu cầu không gian người dùng. Người ta cũng khuyến nghị rằng không gian người dùng không phụ thuộc vào
các giá trị mặc định từ các yêu cầu ZZ0000ZZ.

ZZ0000ZZ được báo cáo nếu ZZ0001ZZ được đặt trong
ZZ0002ZZ. Thuộc tính sẽ trống nếu trình điều khiển không
báo cáo bất kỳ số liệu thống kê. Trình điều khiển điền vào số liệu thống kê sau đây
cấu trúc:

.. kernel-doc:: include/linux/ethtool.h
    :identifiers: ethtool_mm_stats

MM_SET
======

Sửa đổi cấu hình của lớp Hợp nhất 802.3 MAC.

Nội dung yêu cầu:

================================== ====== ==============================
  ZZ0000ZZ u32 xem mô tả MM_GET
  ZZ0001ZZ bool xem mô tả MM_GET
  ZZ0002ZZ bool xem mô tả MM_GET
  ZZ0003ZZ bool xem mô tả MM_GET
  ZZ0004ZZ u32 xem mô tả MM_GET
  ================================== ====== ==============================

Các thuộc tính được truyền tới trình điều khiển thông qua cấu trúc sau:

.. kernel-doc:: include/linux/ethtool.h
    :identifiers: ethtool_mm_cfg

MODULE_FW_FLASH_ACT
===================

Nhấp nháy phần mềm mô-đun thu phát.

Nội dung yêu cầu:

======================================== ====== ==============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  Tên tệp hình ảnh chương trình cơ sở chuỗi ZZ0001ZZ
  Mật khẩu mô-đun thu phát ZZ0002ZZ u32
  ======================================== ====== ==============================

Quá trình cập nhật chương trình cơ sở bao gồm ba bước hợp lý:

1. Tải hình ảnh chương trình cơ sở xuống mô-đun thu phát và xác nhận nó.
2. Chạy hình ảnh phần sụn.
3. Cam kết hình ảnh chương trình cơ sở để nó chạy khi thiết lập lại.

Khi lệnh flash được đưa ra, ba bước đó sẽ được thực hiện theo thứ tự đó.

Thông báo này chỉ đơn thuần là lên lịch cho quá trình cập nhật và trả về ngay lập tức
mà không chặn. Quá trình sau đó chạy không đồng bộ.
Vì có thể mất vài phút để hoàn tất nên trong quá trình cập nhật
thông báo được phát ra từ kernel tới không gian người dùng cập nhật nó về
tình trạng và tiến độ.

Thuộc tính ZZ0000ZZ mã hóa phần sụn
tên tập tin hình ảnh. Hình ảnh phần sụn được tải xuống mô-đun thu phát,
xác nhận, chạy và cam kết.

Thuộc tính ZZ0000ZZ tùy chọn mã hóa mật khẩu
có thể được yêu cầu như một phần của bản cập nhật chương trình cơ sở mô-đun thu phát
quá trình.

Quá trình cập nhật chương trình cơ sở có thể mất vài phút để hoàn tất. Vì vậy,
trong quá trình cập nhật, các thông báo được phát ra từ kernel tới người dùng
không gian cập nhật nó về tình trạng và tiến độ.



Nội dung thông báo:

+---------------------------------------------------+--------+----------------+
 ZZ0005ZZ lồng nhau ZZ0006ZZ
 +---------------------------------------------------+--------+----------------+
 ZZ0007ZZ u32 ZZ0008ZZ
 +---------------------------------------------------+--------+----------------+
 Dây ZZ0009ZZ ZZ0010ZZ
 +---------------------------------------------------+--------+----------------+
 ZZ0011ZZ uint ZZ0012ZZ
 +---------------------------------------------------+--------+----------------+
 ZZ0013ZZ uint ZZ0014ZZ
 +---------------------------------------------------+--------+----------------+

Thuộc tính ZZ0000ZZ mã hóa trạng thái hiện tại
của quá trình cập nhật firmware. Các giá trị có thể là:

.. kernel-doc:: include/uapi/linux/ethtool.h
    :identifiers: ethtool_module_fw_flash_status

Thuộc tính ZZ0000ZZ mã hóa thông báo trạng thái
chuỗi.

ZZ0000ZZ và ZZ0001ZZ
các thuộc tính lần lượt mã hóa số lượng công việc đã hoàn thành và tổng số lượng công việc.

PHY_GET
=======

Truy xuất thông tin về Ethernet PHY nhất định đang nằm trên liên kết. DO
hoạt động trả về tất cả thông tin có sẵn về dev->phydev. Người dùng cũng có thể
chỉ định PHY_INDEX, trong trường hợp đó yêu cầu DO trả về thông tin về điều đó
PHY cụ thể.

Vì có thể có nhiều hơn một PHY nên thao tác DUMP có thể được sử dụng để liệt kê các PHY
hiện diện trên một giao diện nhất định, bằng cách chuyển chỉ mục hoặc tên giao diện vào
yêu cầu kết xuất.

Để biết thêm thông tin, hãy tham khảo ZZ0000ZZ

Nội dung yêu cầu:

=========================================== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  =========================================== =============================

Nội dung phản hồi hạt nhân:

============================================ ========================================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  ZZ0001ZZ u32 chỉ số duy nhất của phy, có thể
                                                được sử dụng cho phy cụ thể
                                                yêu cầu
  ZZ0002ZZ xâu chuỗi tên trình điều khiển phy
  ZZ0003ZZ xâu chuỗi tên thiết bị phy
  ZZ0004ZZ u32 loại thiết bị phy này
                                                kết nối với
  ZZ0005ZZ u32 chỉ số PHY của thượng nguồn
                                                PHY
  Chuỗi ZZ0006ZZ nếu PHY này được kết nối với
                                                cha mẹ của nó là PHY thông qua SFP
                                                xe buýt, tên của xe buýt sfp này
  Chuỗi ZZ0007ZZ nếu phy điều khiển bus sfp,
                                                tên của xe buýt sfp
  ============================================ ========================================

Khi ZZ0000ZZ là PHY_UPSTREAM_PHY, cha mẹ của PHY là
một chiếc PHY khác.

TSCONFIG_GET
============

Truy xuất thông tin về nguồn đánh dấu thời gian phần cứng hiện tại và
cấu hình.

Nó tương tự như yêu cầu ioctl ZZ0000ZZ không được dùng nữa.

Nội dung yêu cầu:

=========================================== =============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  =========================================== =============================

Nội dung phản hồi hạt nhân:

========================================== ====== ===============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  ZZ0001ZZ nhà cung cấp đồng hồ hw PTP lồng nhau
  ZZ0002ZZ bitset hwtstamp loại Tx
  Bộ lọc bitset hwtstamp Rx ZZ0003ZZ
  Cờ hwtstamp ZZ0004ZZ u32
  ========================================== ====== ===============================

Khi đặt thuộc tính ZZ0000ZZ sẽ xác định
nguồn của nhà cung cấp tính năng đánh dấu thời gian hw. Nó được sáng tác bởi
Thuộc tính ZZ0001ZZ mô tả chỉ mục của
thiết bị PTP và ZZ0002ZZ mô tả
vòng loại của dấu thời gian.

Khi đặt ZZ0000ZZ, ZZ0001ZZ
và thuộc tính ZZ0002ZZ xác định Tx
loại, bộ lọc Rx và các cờ được định cấu hình cho dấu thời gian hw hiện tại
nhà cung cấp. Các thuộc tính được truyền tới trình điều khiển thông qua các bước sau
cấu trúc:

.. kernel-doc:: include/linux/net_tstamp.h
    :identifiers: kernel_hwtstamp_config

TSCONFIG_SET
============

Đặt thông tin về nguồn đánh dấu thời gian phần cứng hiện tại và
cấu hình.

Nó tương tự như yêu cầu ioctl ZZ0000ZZ không được dùng nữa.

Nội dung yêu cầu:

========================================== ====== ===============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  ZZ0001ZZ nhà cung cấp đồng hồ hw PTP lồng nhau
  ZZ0002ZZ bitset hwtstamp loại Tx
  Bộ lọc bitset hwtstamp Rx ZZ0003ZZ
  Cờ hwtstamp ZZ0004ZZ u32
  ========================================== ====== ===============================

Nội dung phản hồi hạt nhân:

========================================== ====== ===============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  ZZ0001ZZ nhà cung cấp đồng hồ hw PTP lồng nhau
  ZZ0002ZZ bitset hwtstamp loại Tx
  Bộ lọc bitset hwtstamp Rx ZZ0003ZZ
  Cờ hwtstamp ZZ0004ZZ u32
  ========================================== ====== ===============================

Để biết mô tả về từng thuộc tính, hãy xem ZZ0000ZZ.

MSE_GET
=======

Truy xuất thông tin chẩn đoán Lỗi Bình phương Trung bình (MSE) chi tiết từ PHY.

Nội dung yêu cầu:

=========================================== ===============================
  Tiêu đề yêu cầu lồng nhau ZZ0000ZZ
  =========================================== ===============================

Nội dung phản hồi hạt nhân:

=========================================== ===================================
  Tiêu đề trả lời lồng nhau ZZ0000ZZ
  Thông tin về khả năng/quy mô lồng nhau của ZZ0001ZZ dành cho MSE
                                                số đo
  Ảnh chụp nhanh lồng nhau ZZ0002ZZ cho Kênh A
  Ảnh chụp nhanh lồng nhau ZZ0003ZZ cho Kênh B
  Ảnh chụp nhanh lồng nhau ZZ0004ZZ cho Kênh C
  Ảnh chụp nhanh lồng nhau ZZ0005ZZ cho Kênh D
  Ảnh chụp nhanh lồng nhau ZZ0006ZZ cho kênh kém nhất
  Ảnh chụp nhanh lồng nhau ZZ0007ZZ để tổng hợp trên toàn liên kết
  =========================================== ===================================

Khả năng của MSE
----------------

Thuộc tính lồng nhau này báo cáo các thuộc tính về khả năng/điều chỉnh quy mô được sử dụng để
giải thích các giá trị ảnh chụp nhanh.

================================================ ====== ============================
  ZZ0000ZZ uint thang đo trung bình tối đa
  ZZ0001ZZ uint thang đo max_mse
  Tốc độ mẫu uint ZZ0002ZZ (pico giây)
  Ký hiệu uint ZZ0003ZZ trên mỗi mẫu CTNH
  ================================================ ====== ============================

Các trường trung bình tối đa/cao điểm chỉ được bao gồm nếu số liệu tương ứng
được hỗ trợ bởi PHY. Sự vắng mặt của họ cho thấy số liệu này không
có sẵn.

Xem tài liệu về hạt nhân ZZ0000ZZ trong
ZZ0001ZZ.

Ảnh chụp nhanh MSE
------------

Mỗi tổ trên mỗi kênh chứa ảnh chụp nhanh nguyên tử của các giá trị MSE cho điều đó
bộ chọn (kênh A/B/C/D, kênh kém nhất hoặc liên kết).

============================================ ====== =====================
  ZZ0000ZZ uint giá trị trung bình MSE
  ZZ0001ZZ uint đỉnh hiện tại MSE
  ZZ0002ZZ uint đỉnh trường hợp xấu nhất MSE
  ============================================ ====== =====================

Trong mỗi tổ kênh, chỉ có các số liệu được PHY hỗ trợ mới xuất hiện.

Xem tài liệu về hạt nhân ZZ0000ZZ trong
ZZ0001ZZ.

Yêu cầu dịch
===================

Bảng sau ánh xạ các lệnh ioctl tới các lệnh netlink cung cấp
chức năng. Các mục có "n/a" ở cột bên phải là các lệnh không
đã có sự thay thế liên kết mạng của họ chưa. Các mục "n/a" ở cột bên trái
chỉ có liên kết mạng.

=============================================================================
  lệnh ioctl lệnh netlink
  =============================================================================
  ZZ0000ZZ ZZ0001ZZ
                                      ZZ0002ZZ
  ZZ0003ZZ ZZ0004ZZ
                                      ZZ0005ZZ
  ZZ0006ZZ không áp dụng
  ZZ0007ZZ không áp dụng
  ZZ0008ZZ ZZ0009ZZ
  ZZ0010ZZ ZZ0011ZZ
  ZZ0012ZZ ZZ0013ZZ
  ZZ0014ZZ ZZ0015ZZ
  ZZ0016ZZ không áp dụng
  ZZ0017ZZ ZZ0018ZZ
  ZZ0019ZZ không áp dụng
  ZZ0020ZZ không áp dụng
  ZZ0021ZZ ZZ0022ZZ
  ZZ0023ZZ ZZ0024ZZ
  ZZ0025ZZ ZZ0026ZZ
  ZZ0027ZZ ZZ0028ZZ
  ZZ0029ZZ ZZ0030ZZ
  ZZ0031ZZ ZZ0032ZZ
  ZZ0033ZZ ZZ0034ZZ
  ZZ0035ZZ ZZ0036ZZ
  ZZ0037ZZ ZZ0038ZZ
  ZZ0039ZZ ZZ0040ZZ
  ZZ0041ZZ ZZ0042ZZ
  ZZ0043ZZ ZZ0044ZZ
  ZZ0045ZZ không áp dụng
  ZZ0046ZZ ZZ0047ZZ
  ZZ0048ZZ không áp dụng
  ZZ0049ZZ không áp dụng
  ZZ0050ZZ ZZ0051ZZ
  ZZ0052ZZ ZZ0053ZZ
  ZZ0054ZZ liên kết mạng ZZ0055ZZ
  ZZ0056ZZ ZZ0057ZZ
  ZZ0058ZZ ZZ0059ZZ
  ZZ0060ZZ ZZ0061ZZ
  ZZ0062ZZ ZZ0063ZZ
  ZZ0064ZZ ZZ0065ZZ
  ZZ0066ZZ ZZ0067ZZ
  ZZ0068ZZ ZZ0069ZZ
  ZZ0070ZZ ZZ0071ZZ
  ZZ0072ZZ ZZ0073ZZ
  ZZ0074ZZ ZZ0075ZZ
  ZZ0076ZZ ZZ0077ZZ
  ZZ0078ZZ ZZ0079ZZ
  ZZ0080ZZ không áp dụng
  ZZ0081ZZ không áp dụng
  ZZ0082ZZ không áp dụng
  ZZ0083ZZ không áp dụng
  ZZ0084ZZ không áp dụng
  ZZ0085ZZ không áp dụng
  ZZ0086ZZ không áp dụng
  ZZ0087ZZ không áp dụng
  ZZ0088ZZ không áp dụng
  ZZ0089ZZ không áp dụng
  ZZ0090ZZ ZZ0091ZZ
  ZZ0092ZZ ZZ0093ZZ
  ZZ0094ZZ ZZ0095ZZ
  ZZ0096ZZ ZZ0097ZZ
  ZZ0098ZZ ZZ0099ZZ
  ZZ0100ZZ ZZ0101ZZ
  ZZ0102ZZ ZZ0103ZZ
  ZZ0104ZZ không áp dụng
  ZZ0105ZZ không áp dụng
  ZZ0106ZZ không áp dụng
  ZZ0107ZZ ZZ0108ZZ
  ZZ0109ZZ ZZ0110ZZ
  ZZ0111ZZ ZZ0112ZZ
  ZZ0113ZZ ZZ0114ZZ
  ZZ0115ZZ ZZ0116ZZ
  ZZ0117ZZ ZZ0118ZZ
  ZZ0119ZZ không áp dụng
  ZZ0120ZZ không áp dụng
  ZZ0121ZZ không áp dụng
  ZZ0122ZZ không áp dụng
  ZZ0123ZZ không áp dụng
  ZZ0124ZZ ZZ0125ZZ
                                      ZZ0126ZZ
  ZZ0127ZZ ZZ0128ZZ
                                      ZZ0129ZZ
  ZZ0130ZZ không áp dụng
  ZZ0131ZZ không áp dụng
  ZZ0132ZZ ZZ0133ZZ
  ZZ0134ZZ ZZ0135ZZ
  không có ZZ0136ZZ
  không có ZZ0137ZZ
  không có ZZ0138ZZ
  không có ZZ0139ZZ
  không có ZZ0140ZZ
  không có ZZ0141ZZ
  không có ZZ0142ZZ
  không có ZZ0143ZZ
  không có ZZ0144ZZ
  không có ZZ0145ZZ
  không có ZZ0146ZZ
  không có ZZ0147ZZ
  không có ZZ0148ZZ
  ZZ0149ZZ ZZ0150ZZ
  ZZ0151ZZ ZZ0152ZZ
  =============================================================================
