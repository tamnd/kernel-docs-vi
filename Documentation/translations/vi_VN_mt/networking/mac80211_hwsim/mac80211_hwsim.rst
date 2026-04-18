.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/mac80211_hwsim/mac80211_hwsim.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

========================================================================
mac80211_hwsim - phần mềm giả lập radio 802.11 cho mac80211
========================================================================

:Bản quyền: ZZ0000ZZ 2008, Jouni Malinen <j@w1.fi>

Chương trình này là phần mềm miễn phí; bạn có thể phân phối lại nó và/hoặc sửa đổi
nó theo các điều khoản của Giấy phép Công cộng GNU phiên bản 2 như
được xuất bản bởi Tổ chức Phần mềm Tự do.


Giới thiệu
============

mac80211_hwsim là mô-đun hạt nhân Linux có thể được sử dụng để mô phỏng
số lượng radio IEEE 802.11 tùy ý cho mac80211. Nó có thể được sử dụng để
kiểm tra hầu hết các công cụ không gian người dùng và chức năng mac80211 (ví dụ:
Hostapd và wpa_supplicant) theo cách rất phù hợp với
trường hợp bình thường khi sử dụng phần cứng WLAN thực. Từ chế độ xem mac80211
điểm, mac80211_hwsim vẫn là một trình điều khiển phần cứng khác, tức là không có thay đổi nào
Cần có mac80211 để sử dụng công cụ kiểm tra này.

Mục tiêu chính của mac80211_hwsim là giúp các nhà phát triển dễ dàng hơn
để kiểm tra mã của họ và làm việc với các tính năng mới cho mac80211, Hostapd,
và wpa_supplicant. Bộ đàm mô phỏng không có giới hạn
của phần cứng thực, do đó dễ dàng tạo ra một thiết lập thử nghiệm tùy ý
và luôn sao chép cùng một thiết lập cho các thử nghiệm trong tương lai. Ngoài ra,
vì tất cả hoạt động vô tuyến đều được mô phỏng nên bất kỳ kênh nào cũng có thể được sử dụng trong
kiểm tra bất chấp các quy định pháp lý.

mô-đun hạt nhân mac80211_hwsim có tham số 'radio' có thể được sử dụng
để chọn số lượng radio được mô phỏng (mặc định 2). Điều này cho phép
cấu hình của cả hai thiết lập rất đơn giản (ví dụ: chỉ một lần truy cập
điểm và một trạm) hoặc các thử nghiệm quy mô lớn (nhiều điểm truy cập với
hàng trăm trạm).

mac80211_hwsim hoạt động bằng cách theo dõi kênh hiện tại của từng ảo
radio và sao chép tất cả các khung được truyền sang tất cả các radio khác
hiện được kích hoạt và trên cùng kênh với kênh đang truyền
đài phát thanh. Mã hóa phần mềm trong mac80211 được sử dụng để các khung được
thực sự được mã hóa qua giao diện không khí ảo để cho phép nhiều hơn
kiểm tra hoàn chỉnh việc mã hóa.

Một netdev giám sát toàn cầu, hwsim#, được tạo ra độc lập với
mac80211. Giao diện này có thể được sử dụng để giám sát tất cả các khung được truyền
bất kể kênh nào.


Ví dụ đơn giản
==============

Ví dụ này cho thấy cách sử dụng mac80211_hwsim để mô phỏng hai radio:
một hoạt động như một điểm truy cập và một hoạt động như một trạm
liên kết với AP. Hostapd và wpa_supplicant được sử dụng để lấy
chăm sóc xác thực WPA2-PSK. Ngoài ra, Hostapd còn
xử lý phía điểm truy cập của liên kết.

::


# Build mac80211_hwsim như một phần của cấu hình kernel

# Load mô-đun
    modprobe mac80211_hwsim

# Run máy chủ lưu trữ (AP) cho wlan0
    Hostapd Hostapd.conf

# Run wpa_supplicant (trạm) cho wlan1
    wpa_supplicant -Dnl80211 -iwlan1 -c wpa_supplicant.conf


Nhiều trường hợp thử nghiệm khác có sẵn trong Hostap.git:
git://w1.fi/srv/git/hostap.git và thư mục con mac80211_hwsim/tests
(ZZ0000ZZ