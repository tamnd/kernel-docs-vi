.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/misc-devices/bh1770glc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========================
Trình điều khiển hạt nhân bh1770glc
=======================

Chip được hỗ trợ:

- ROHM BH1770GLC
- OSRAM SFH7770

Bảng dữ liệu:
Không có sẵn miễn phí

tác giả:
Samu Onkalo <samu.p.onkalo@nokia.com>

Sự miêu tả
-----------
BH1770GLC và SFH7770 là cảm biến ánh sáng xung quanh và cảm biến tiệm cận kết hợp.
ALS và các bộ phận lân cận hoạt động độc lập nhưng chúng có chung I2C
giao diện và logic ngắt. Về nguyên tắc chúng có thể tự chạy,
nhưng kết quả phụ của ALS được sử dụng để ước tính độ tin cậy của cảm biến tiệm cận.

ALS tạo ra giá trị lux 16 bit. Con chip chứa logic ngắt để tạo ra
ngắt ngưỡng thấp và cao.

Phần lân cận chứa trình điều khiển IR-led lên đến 3 đèn LED IR. Con chip đo lường
lượng ánh sáng hồng ngoại phản xạ và tạo ra kết quả gần. Độ phân giải là
8 bit. Trình điều khiển chỉ hỗ trợ một kênh. Trình điều khiển sử dụng kết quả ALS để ước tính
độ tin cậy của kết quả lân cận. Do đó ALS luôn chạy trong khi
cần phát hiện sự gần gũi.

Trình điều khiển sử dụng các ngưỡng ngắt để tránh phải thăm dò các giá trị.
Ngắt lân cận thấp không tồn tại trong chip. Điều này được mô phỏng
bằng cách sử dụng một công việc bị trì hoãn. Miễn là có ngưỡng lân cận trên
làm gián đoạn công việc bị trì hoãn được đẩy về phía trước. Vì vậy, khi mức độ gần nhau tăng
dưới giá trị ngưỡng thì không bị gián đoạn và công việc bị trì hoãn sẽ
cuối cùng cũng chạy. Điều này được xử lý như không có dấu hiệu gần gũi.

Trạng thái chip được kiểm soát thông qua khung thời gian chạy chiều khi được bật trong config.

Hệ số Calibscale được sử dụng để che giấu sự khác biệt giữa các chip. Theo mặc định
giá trị được đặt thành hệ số ý nghĩa trạng thái trung tính là 1,00. Để có được giá trị phù hợp,
nguồn ánh sáng được hiệu chỉnh là cần thiết để tham khảo. Hệ số hiệu chỉnh được thiết lập
để phép đo đó tạo ra giá trị lux dự kiến.

SYSFS
-----

chip_id
	RO - hiển thị loại và phiên bản chip được phát hiện

trạng thái sức mạnh
	RW - bật/tắt chip

Sử dụng logic đếm

- 1 kích hoạt chip
	     - 0 vô hiệu hóa chip

lux0_input
	RO - giá trị lux đo được

sysfs_notify được gọi khi xảy ra ngắt ngưỡng

lux0_sensor_range
	RO - giá trị tối đa lux0_input

lux0_rate
	RW - tốc độ đo tính bằng Hz

lux0_rate_avail
	RO - tốc độ đo được hỗ trợ

lux0_thresh_above_value
	RW - Giá trị ngưỡng mức HI

Tất cả các kết quả trên giá trị
	     gây ra một sự gián đoạn. 65535 (tức là cảm biến_range) vô hiệu hóa các mục trên
	     ngắt lời.

lux0_thresh_below_value
	RW - Giá trị ngưỡng mức LO

Tất cả các kết quả dưới giá trị
	     gây ra một sự gián đoạn. 0 vô hiệu hóa ngắt bên dưới.

lux0_calibscale
	RW - giá trị hiệu chuẩn

Đặt thành giá trị trung tính theo mặc định.
	     Kết quả đầu ra được nhân với calibscale/calibscale_default
	     giá trị.

lux0_calibscale_default
	RO - giá trị hiệu chuẩn trung tính

prox0_raw
	RO - giá trị lân cận đo được

sysfs_notify được gọi khi xảy ra ngắt ngưỡng

prox0_sensor_range
	RO - giá trị tối đa prox0_raw

prox0_raw_en
	RW - bật / tắt vùng lân cận

Sử dụng logic đếm

- 1 cho phép sự gần gũi
	     - 0 vô hiệu hóa sự gần gũi

prox0_thresh_above_count
	RW - số lần ngắt lân cận cần thiết trước khi kích hoạt sự kiện

prox0_rate_trên
	RW - Tốc độ đo (tính bằng Hz) khi mức trên ngưỡng
	tức là khi khoảng cách bật đã được báo cáo.

prox0_rate_below
	RW - Tốc độ đo (tính bằng Hz) khi mức dưới ngưỡng
	tức là khi khoảng cách tắt đã được báo cáo.

prox0_rate_avail
	RO - Tốc độ đo độ gần được hỗ trợ tính bằng Hz

prox0_thresh_above0_value
	RW - mức ngưỡng kích hoạt các sự kiện lân cận.

Được lọc theo bộ lọc liên tục (prox0_thresh_above_count)

prox0_thresh_above1_value
	RW - mức ngưỡng kích hoạt sự kiện ngay lập tức