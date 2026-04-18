.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/dsa/bcm_sf2.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================================================
Trình điều khiển chuyển mạch Ethernet Broadcom Starfighter 2
=============================================

Khối phần cứng chuyển mạch Ethernet Starfighter 2 của Broadcom thường được tìm thấy và
triển khai ở các sản phẩm sau:

- Cổng xDSL như BCM63138
- Set Top Box phát trực tuyến/đa phương tiện như BCM7445
- Modem cáp/cổng dân dụng như BCM7145/BCM3390

Công tắc thường được triển khai trong cấu hình bao gồm từ 5 đến 13
cổng, cung cấp một loạt các giao diện tích hợp và có thể tùy chỉnh:

- Gigabit PHY tích hợp đơn
- Gigabit PHY tích hợp bốn cổng
- bộ ghép kênh Gigabit PHY bên ngoài với bộ ghép kênh MDIO
- Tích hợp MoCA PHY
- một số giao diện MII/RevMII/GMII/RGMII bên ngoài

Switch cũng hỗ trợ các tính năng kiểm soát tắc nghẽn cụ thể cho phép MoCA
chuyển đổi dự phòng để không làm mất các gói trong quá trình bầu chọn lại vai trò MoCA, cũng như hết
áp suất ngược băng tần tới giao diện mạng CPU của máy chủ khi giao diện hạ lưu
được kết nối ở tốc độ thấp hơn.

Khối phần cứng chuyển mạch thường được giao tiếp bằng cách sử dụng truy cập MMIO và
chứa một loạt các khối con/thanh ghi:

- ZZ0000ZZ: thanh ghi chuyển mạch chung
- ZZ0001ZZ: thanh ghi chuyển đổi giao diện bên ngoài
- ZZ0002ZZ: bộ điều khiển bus MDIO bên ngoài (có một bộ điều khiển khác trong SWITCH_CORE,
  được sử dụng để truy cập PHY gián tiếp)
- ZZ0003ZZ: khối trợ giúp đăng ký rộng 64 bit
- ZZ0004ZZ: Bộ điều khiển ngắt cấp 2
- ZZ0005ZZ: Khối kiểm soát nhập học
- ZZ0006ZZ: Khối điều khiển lỗi

Chi tiết triển khai
======================

Trình điều khiển được đặt trong ZZ0000ZZ và được triển khai dưới dạng DSA
người lái xe; xem ZZ0001ZZ để biết chi tiết về hệ thống con
và những gì nó cung cấp.

Công tắc SF2 được định cấu hình để kích hoạt thẻ chuyển đổi 4 byte cụ thể của Broadcom
được chèn bởi switch cho mỗi gói được chuyển tiếp tới CPU
giao diện mạng CPU nên chèn một thẻ tương tự cho giao diện mạng CPU
các gói đi vào cổng CPU. Định dạng thẻ được mô tả trong
ZZ0000ZZ.

Nhìn chung, trình điều khiển SF2 là trình điều khiển DSA khá thông thường; có một vài
chi tiết cụ thể được đề cập dưới đây.

Thăm dò cây thiết bị
-------------------

Trình điều khiển thiết bị nền tảng DSA được thử nghiệm bằng một chuỗi tương thích cụ thể
được cung cấp trong ZZ0000ZZ. Lý do là vì hệ thống con DSA có
hiện đã đăng ký làm trình điều khiển thiết bị nền tảng. DSA sẽ cung cấp những thứ cần thiết
con trỏ device_node mà sau đó có thể truy cập được bằng cách thiết lập trình điều khiển chuyển đổi
chức năng thiết lập các tài nguyên như phạm vi đăng ký và ngắt. Cái này
hiện hoạt động rất tốt vì không có hàm of_* nào được sử dụng bởi
trình điều khiển yêu cầu một thiết bị cấu trúc được liên kết với một struct device_node, nhưng mọi thứ
có thể thay đổi trong tương lai.

Truy cập gián tiếp MDIO
----------------------

Do hạn chế trong cách thiết kế các thiết bị chuyển mạch Broadcom, bên ngoài
Các bộ chuyển mạch Broadcom được kết nối với SF2 yêu cầu sử dụng bus MDIO của người dùng DSA
in order to properly configure them. Theo mặc định, địa chỉ SF2 giả PHY và
cả hai địa chỉ giả PHY của bộ chuyển mạch bên ngoài sẽ theo dõi MDIO gửi đến
giao dịch, vì chúng ở cùng một địa chỉ (30), dẫn đến một số loại
lập trình "kép". Sử dụng DSA và cài đặt ZZ0000ZZ tương ứng, chúng tôi
chuyển hướng có chọn lọc việc đọc và ghi vào các thiết bị chuyển mạch Broadcom bên ngoài
địa chỉ giả PHY. Các phiên bản mới hơn của phần cứng SF2 đã giới thiệu một
địa chỉ giả PHY có thể định cấu hình để phá vỡ giới hạn thiết kế ban đầu.

Giao diện đa phương tiện qua CoAxial (MoCA)
-----------------------------------------

Giao diện MoCA khá cụ thể và yêu cầu sử dụng blob chương trình cơ sở.
được tải vào (các) bộ xử lý MoCA để xử lý gói. Công tắc
phần cứng chứa logic sẽ xác nhận/hủy xác nhận trạng thái liên kết tương ứng cho
giao diện MoCA bất cứ khi nào cáp đồng trục MoCA bị ngắt kết nối hoặc
firmware được tải lại. Trình điều khiển SF2 dựa vào các sự kiện như vậy để thiết lập chính xác
Trạng thái sóng mang giao diện MoCA và báo cáo chính xác điều này cho ngăn xếp mạng.

Các giao diện MoCA được hỗ trợ bằng cách sử dụng PHY/PHY mô phỏng của thư viện PHY
thiết bị và trình điều khiển chuyển đổi đăng ký cuộc gọi lại ZZ0000ZZ cho những điều đó
PHY phản ánh trạng thái liên kết thu được từ trình xử lý ngắt.


Quản lý nguồn điện
----------------

Bất cứ khi nào có thể, trình điều khiển SF2 sẽ cố gắng giảm thiểu nguồn điện tổng thể của switch
tiêu dùng bằng cách áp dụng kết hợp:

- tắt bộ đệm/bộ nhớ trong
- vô hiệu hóa logic xử lý gói
- đưa PHY tích hợp vào IDDQ/công suất thấp
- giảm xung nhịp lõi của switch dựa trên số lượng cổng đang hoạt động
- kích hoạt và quảng cáo EEE
- tắt logic xử lý dữ liệu RGMII khi liên kết bị hỏng

Đánh thức-LAN
-----------

Wake-on-LAN hiện được triển khai bằng cách sử dụng Ethernet của bộ xử lý máy chủ
Logic đánh thức bộ điều khiển MAC. Bất cứ khi nào Wake-on-LAN được yêu cầu, giao lộ
giữa yêu cầu của người dùng và giao diện Ethernet của máy chủ được hỗ trợ WoL
khả năng được thực hiện và kết quả giao lộ được cấu hình. Trong thời gian
tạm dừng/tiếp tục trên toàn hệ thống, chỉ các cổng không tham gia Wake-on-LAN mới được
bị vô hiệu hóa.
