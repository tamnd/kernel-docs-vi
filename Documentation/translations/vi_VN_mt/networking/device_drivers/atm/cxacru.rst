.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/atm/cxacru.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Trình điều khiển thiết bị cxacru ATM
========================

Cần có chương trình cơ sở cho thiết bị này: ZZ0000ZZ

Mặc dù nó có khả năng quản lý/duy trì kết nối ADSL mà không cần
mô-đun được tải, thiết bị đôi khi sẽ ngừng phản hồi sau khi dỡ mô-đun xuống
driver và cần phải rút/rút nguồn điện ra khỏi thiết bị để khắc phục lỗi này.

Lưu ý: hỗ trợ cho cxacru-cf.bin đã bị xóa. Nó không được tải chính xác
vì vậy nó không ảnh hưởng đến cấu hình thiết bị. Việc sửa nó có thể đã dừng lại
các thiết bị hiện có đang hoạt động khi cung cấp cấu hình không hợp lệ.

Có một tập lệnh cxacru-cf.py để chuyển đổi tệp hiện có sang dạng sysfs.

Các thiết bị được phát hiện sẽ xuất hiện dưới dạng thiết bị ATM có tên "cxacru". Trong /sys/class/atm/
đây là những thư mục có tên cxacruN trong đó N là số thiết bị. Một liên kết tượng trưng
thiết bị được đặt tên trỏ tới thư mục của thiết bị giao diện USB chứa
một số tệp thuộc tính sysfs để truy xuất số liệu thống kê thiết bị:

* adsl_controller_version

* quảng cáo_headend
* môi trường adsl_headend_

- Thông tin về headend từ xa.

* adsl_config

- Giao diện viết cấu hình.
	- Viết tham số ở dạng thập lục phân <index>=<value>,
	  được phân tách bằng khoảng trắng, ví dụ:

"1=0 a=5"

- Tối đa 7 tham số cùng một lúc sẽ được gửi và modem sẽ khởi động lại
	  kết nối ADSL khi bất kỳ giá trị nào được đặt. Chúng được ghi lại cho tương lai
	  tham khảo.

* suy giảm hạ lưu (dB)
* xuôi_bits_per_frame
* tốc độ xuôi dòng (kbps)
* xuôi dòng_snr_margin (dB)

- Số liệu thống kê hạ lưu.

* suy giảm ngược dòng (dB)
* upstream_bits_per_frame
* tốc độ ngược dòng (kbps)
* upstream_snr_margin (dB)
* công suất máy phát (dBm/Hz)

- Thống kê ngược dòng.

* xuôi_crc_errors
* downstream_fec_errors
* downstream_hec_errors
* upstream_crc_errors
* upstream_fec_errors
* thượng nguồn_hec_errors

- Số lỗi.

* dòng_startable

- Cho biết hỗ trợ ADSL trên thiết bị
	  đã/có thể được bật, hãy xem adsl_start.

* dòng_status

- "khởi tạo"
	 - "xuống"
	 - "đang cố gắng kích hoạt"
	 - "huấn luyện"
	 - "phân tích kênh"
	 - "trao đổi"
	 - "đợi"
	 - "lên"

Thay đổi giữa "xuống" và "cố gắng kích hoạt"
	nếu không có tín hiệu.

* trạng thái liên kết

- "không kết nối"
	 - "được kết nối"
	 - "bị mất"

* địa chỉ mac

* điều chế

- "" (khi không được kết nối)
	 - "ANSI T1.413"
	 - "ITU-T G.992.1 (G.DMT)"
	 - "ITU-T G.992.2 (G.LITE)"

* startup_attempts

- Tổng số lần thử khởi tạo ADSL.

Để bật/tắt ADSL, có thể ghi nội dung sau vào tệp adsl_state:

- "bắt đầu"
	 - "dừng lại
	 - "khởi động lại" (dừng, đợi 1,5 giây rồi bắt đầu)
	 - "thăm dò ý kiến" (được sử dụng để tiếp tục thăm dò trạng thái nếu nó bị vô hiệu hóa do lỗi)

Những thay đổi về trạng thái adsl/line được báo cáo qua thông báo nhật ký kernel::

[4942145.150704] ATM dev 0: Trạng thái ADSL: đang chạy
	[4942243.663766] ATM dev 0: dòng ADSL: không hoạt động
	[4942249.665075] ATM dev 0: dòng ADSL: đang cố gắng kích hoạt
	[4942253.654954] ATM dev 0: dòng ADSL: đào tạo
	[4942255.666387] ATM dev 0: dòng ADSL: phân tích kênh
	[4942259.656262] ATM dev 0: dòng ADSL: trao đổi
	[2635357.696901] ATM dev 0: Dòng ADSL: lên (8128 kb/s xuống | 832 kb/s lên)