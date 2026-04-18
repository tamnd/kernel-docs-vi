.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/radiotap-headers.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Cách sử dụng tiêu đề radiotap
==============================

Con trỏ tới tệp bao gồm radiotap
------------------------------------

Các tiêu đề radiotap có độ dài thay đổi và có thể mở rộng, bạn có thể nhận được hầu hết các
thông tin bạn cần biết về họ từ::

./include/net/ieee80211_radiotap.h

Tài liệu này cung cấp cái nhìn tổng quan và cảnh báo về một số trường hợp góc cạnh.


Cấu trúc của tiêu đề
-----------------------

Có một phần cố định khi bắt đầu chứa bitmap u32 xác định
liệu đối số có thể có liên quan đến bit đó có tồn tại hay không.  Vậy nếu b0
của thành viên it_hiện tại của ieee80211_radiotap_header được đặt, điều đó có nghĩa là
tiêu đề cho chỉ số đối số 0 (IEEE80211_RADIOTAP_TSFT) có trong
khu vực tranh luận.

::

< ieee80211_radiotap_header 8 byte >
   [ < phần mở rộng bitmap đối số có thể có ... > ]
   [ <đối số> ... ]

Hiện tại chỉ có 13 chỉ mục đối số có thể được xác định, nhưng trong trường hợp
chúng tôi hết dung lượng trong thành viên u32 it_hiện tại, nó được xác định là bộ b31
chỉ ra rằng có một bitmap u32 khác theo sau (được hiển thị là "có thể
phần mở rộng bitmap đối số..." ở trên) và phần bắt đầu của đối số được di chuyển
chuyển tiếp 4 byte mỗi lần.

Cũng lưu ý rằng thành viên it_len __le16 được đặt thành tổng số byte
được bao phủ bởi ieee80211_radiotap_header và bất kỳ đối số nào sau đây.


Yêu cầu về lập luận
--------------------------

Sau phần cố định của tiêu đề là các đối số theo sau cho từng đối số
chỉ mục có bit khớp được đặt trong thành viên it_hiện tại của
ieee80211_radiotap_header.

- tất cả các đối số đều được lưu trữ ở dạng little-endian!

- tải trọng đối số cho một chỉ mục đối số nhất định có kích thước cố định.  Vì vậy
   IEEE80211_RADIOTAP_TSFT hiện diện luôn biểu thị đối số 8 byte là
   hiện tại.  Xem các nhận xét trong ./include/net/ieee80211_radiotap.h để hiểu rõ hơn
   phân tích tất cả các kích thước đối số

- các đối số phải được căn chỉnh theo ranh giới của kích thước đối số bằng cách sử dụng
   đệm.  Vì vậy, đối số u16 phải bắt đầu ở ranh giới u16 tiếp theo nếu không
   đã có trên một, u32 phải bắt đầu ở ranh giới u32 tiếp theo, v.v.

- "căn chỉnh" liên quan đến điểm bắt đầu của ieee80211_radiotap_header, tức là
   byte đầu tiên của tiêu đề radiotap.  Sự liên kết tuyệt đối đầu tiên đó
   byte không được xác định.  Vì vậy, ngay cả khi toàn bộ tiêu đề radiotap bắt đầu tại, ví dụ:
   địa chỉ 0x00000003, byte đầu tiên của tiêu đề radiotap vẫn được coi là
   0 cho mục đích căn chỉnh.

- điểm trên có thể không có sự liên kết tuyệt đối cho multibyte
   các thực thể trong tiêu đề radiotap cố định hoặc vùng đối số có nghĩa là bạn
   phải thực hiện hành động né tránh đặc biệt khi cố gắng truy cập các multibyte này
   các thực thể.  Một số vòm như Blackfin không thể giải quyết được nỗ lực
   sự hủy đăng ký, ví dụ: một con trỏ u16 đang trỏ đến một địa chỉ lẻ.  Thay vào đó
   bạn phải sử dụng kernel API get_unaligned() để hủy đăng ký con trỏ,
   sẽ thực hiện từng bước trên các vòm yêu cầu điều đó.

- Các đối số cho một chỉ mục đối số nhất định có thể là sự kết hợp của nhiều loại
   cùng nhau.  Ví dụ IEEE80211_RADIOTAP_CHANNEL có tải trọng đối số
   bao gồm hai u16 có tổng chiều dài 4. Khi điều này xảy ra, phần đệm
   quy tắc được áp dụng để xử lý u16, NOT xử lý một thực thể đơn 4 byte.


Ví dụ tiêu đề radiotap hợp lệ
-----------------------------

::

0x00, 0x00, // <-- phiên bản radiotap + byte pad
	0x0b, 0x00, // <- độ dài tiêu đề radiotap
	0x04, 0x0c, 0x00, 0x00, // <- bitmap
	0x6c, // <-- tốc độ (tính bằng đơn vị 500kHz)
	0x0c, //<-- nguồn điện
	0x01 //<-- ăng-ten


Sử dụng Trình phân tích cú pháp Radiotap
-------------------------

Nếu bạn phải phân tích cấu trúc radiotap, bạn có thể đơn giản hóa triệt để
bằng cách sử dụng trình phân tích cú pháp radiotap có trong net/wireless/radiotap.c và có
nguyên mẫu của nó có sẵn trong include/net/cfg80211.h.  Bạn sử dụng nó như thế này::

#include <net/cfg80211.h>

/* buf trỏ đến phần bắt đầu của phần tiêu đề radiotap */

int MyFunction(u8 * buf, int buflen)
    {
	    int pkt_rate_100kHz = 0, anten = 0, pwr = 0;
	    struct ieee80211_radiotap_iterator iterator;
	    int ret = ieee80211_radiotap_iterator_init(&iterator, buf, buflen);

trong khi (!ret) {

ret = ieee80211_radiotap_iterator_next(&iterator);

nếu (ret)
			    tiếp tục;

/* xem liệu đối số này có thể được sử dụng không */

chuyển đổi (iterator.this_arg_index) {
		    /*
		    * Bạn phải cẩn thận khi hủy tham chiếu iterator.this_arg
		    * đối với loại nhiều byte... con trỏ không được căn chỉnh.  sử dụng
		    * get_unaligned((type *)iterator.this_arg) để hủy đăng ký
		    * iterator.this_arg để gõ "gõ" an toàn trên tất cả các vòm.
		    */
		    vỏ IEEE80211_RADIOTAP_RATE:
			    /* radiotap "rate" u8 is in
			    * Đơn vị 500kbps, ví dụ: 0x02=1Mbps
			    */
			    pkt_rate_100kHz = (ZZ0000ZZ 5;
			    phá vỡ;

vỏ IEEE80211_RADIOTAP_ANTENNA:
			    /* radiotap sử dụng số 0 cho con kiến thứ nhất */
			    anten = *iterator.this_arg);
			    phá vỡ;

vỏ IEEE80211_RADIOTAP_DBM_TX_POWER:
			    pwr = *iterator.this_arg;
			    phá vỡ;

mặc định:
			    phá vỡ;
		    }
	    } /* trong khi có thêm tiêu đề rt */

nếu (ret != -ENOENT)
		    trả lại TXRX_DROP;

/* loại bỏ phần tiêu đề radiotap */
	    buf += iterator.max_length;
	    buflen -= iterator.max_length;

	    ...

    }

Andy Green <andy@warmcat.com>