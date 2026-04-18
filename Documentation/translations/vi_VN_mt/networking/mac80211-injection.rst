.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/mac80211-injection.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================
Cách sử dụng tính năng tiêm gói với mac80211
=========================================

mac80211 hiện cho phép các gói tùy ý được đưa vào bất kỳ Chế độ giám sát nào
giao diện từ vùng người dùng.  Gói bạn đưa vào cần phải được soạn trong
định dạng sau::

[tiêu đề radiotap]
 [tiêu đề ieee80211]
 [ tải trọng ]

Định dạng radiotap được thảo luận trong
./Documentation/networking/radiotap-headers.rst.

Mặc dù nhiều tham số radiotap hiện đang được xác định, nhưng hầu hết chỉ có ý nghĩa
xuất hiện trên các gói nhận được.  Thông tin sau đây được phân tích từ
tiêu đề radiotap và được sử dụng để kiểm soát việc tiêm:

* IEEE80211_RADIOTAP_FLAGS

=========================================================================
   IEEE80211_RADIOTAP_F_FCS FCS sẽ bị xóa và tính toán lại
   Khung IEEE80211_RADIOTAP_F_WEP sẽ được mã hóa nếu có khóa
   Khung IEEE80211_RADIOTAP_F_FRAG sẽ bị phân mảnh nếu dài hơn
			      ngưỡng phân mảnh hiện tại.
   =========================================================================

* IEEE80211_RADIOTAP_TX_FLAGS

==========================================================================
   Khung IEEE80211_RADIOTAP_F_TX_NOACK phải được gửi mà không cần chờ đợi
				  ACK ngay cả khi đó là khung unicast
   ==========================================================================

* IEEE80211_RADIOTAP_RATE

tốc độ kế thừa cho việc truyền tải (chỉ dành cho các thiết bị không có kiểm soát tốc độ riêng)

* IEEE80211_RADIOTAP_MCS

Tốc độ HT để truyền (chỉ dành cho các thiết bị không có điều khiển tốc độ riêng).
   Ngoài ra một số cờ được phân tích cú pháp

=========================================================
   IEEE80211_RADIOTAP_MCS_SGI sử dụng khoảng bảo vệ ngắn
   IEEE80211_RADIOTAP_MCS_BW_40 gửi ở chế độ HT40
   =========================================================

* IEEE80211_RADIOTAP_DATA_RETRIES

số lần thử lại khi IEEE80211_RADIOTAP_RATE hoặc
   IEEE80211_RADIOTAP_MCS đã được sử dụng

* IEEE80211_RADIOTAP_VHT

MC VHT và số luồng được sử dụng trong quá trình truyền (chỉ dành cho thiết bị
   không có sự kiểm soát tỷ giá riêng). Ngoài ra các trường khác cũng được phân tích cú pháp

trường cờ
	IEEE80211_RADIOTAP_VHT_FLAG_SGI: sử dụng khoảng bảo vệ ngắn

trường băng thông
	* 1: gửi sử dụng độ rộng kênh 40 MHz
	* 4: gửi sử dụng độ rộng kênh 80 MHz
	* 11: gửi sử dụng độ rộng kênh 160 MHz

Mã tiêm cũng có thể bỏ qua tất cả các trường radiotap hiện được xác định khác
tạo điều kiện phát lại trực tiếp các tiêu đề radiotap đã chụp.

Dưới đây là một ví dụ về tiêu đề radiotap hợp lệ xác định một số tham số ::

0x00, 0x00, // <-- phiên bản radiotap
	0x0b, 0x00, // <- độ dài tiêu đề radiotap
	0x04, 0x0c, 0x00, 0x00, // <- bitmap
	0x6c, // <- tỷ lệ
	0x0c, //<-- nguồn điện
	0x01 //<-- ăng-ten

Tiêu đề ieee80211 xuất hiện ngay sau đó, ví dụ như
cái này::

0x08, 0x01, 0x00, 0x00,
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
	0x13, 0x22, 0x33, 0x44, 0x55, 0x66,
	0x13, 0x22, 0x33, 0x44, 0x55, 0x66,
	0x10, 0x86

Cuối cùng là tải trọng.

Sau khi soạn thảo nội dung gói, nó được gửi bằng lệnh send()-ing đến một logic
giao diện mac80211 ở chế độ Màn hình.  Libpcap cũng có thể được sử dụng,
(việc này dễ hơn việc thực hiện công việc gắn ổ cắm vào bên phải
giao diện), dọc theo các dòng sau:::

ppcap = pcap_open_live(szInterfaceName, 800, 1, 20, szErrbuf);
	...
r = pcap_inject(ppcap, u8aSendBuffer, nLength);

Bạn cũng có thể tìm thấy liên kết đến ứng dụng tiêm hoàn chỉnh tại đây:

ZZ0000ZZ

Andy Green <andy@warmcat.com>