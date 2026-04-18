.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/thmc50.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân thmc50
================================

Chip được hỗ trợ:

* Thiết bị tương tự ADM1022

Tiền tố: 'adm1022'

Địa chỉ được quét: I2C 0x2c - 0x2e

Bảng dữ liệu: ZZ0000ZZ

* Dụng cụ Texas THMC50

Tiền tố: 'thmc50'

Địa chỉ được quét: I2C 0x2c - 0x2e

Bảng dữ liệu: ZZ0000ZZ


Tác giả: Krzysztof Helt <krzysztof.h1@wp.pl>

Trình điều khiển này được lấy từ tệp nguồn thmc50.c kernel 2.4.

Tín dụng:

thmc50.c (hạt nhân 2.4):

- Frodo Looijaard <frodol@dds.nl>
	- Philip Edelbrock <phil@netroedge.com>

Thông số mô-đun
-----------------

* adm1022_temp3: mảng ngắn
    Danh sách các bộ điều hợp, cặp địa chỉ để buộc chip vào chế độ ADM1022 với
    nhiệt độ từ xa thứ hai. Điều này không hoạt động đối với chip THMC50 gốc.

Sự miêu tả
-----------

THMC50 thực hiện: cảm biến nhiệt độ bên trong, hỗ trợ
cảm biến nhiệt độ loại điốt bên ngoài (tương thích với cảm biến điốt bên trong
nhiều bộ xử lý) và một quạt/analog_out DAC có thể điều khiển được. Đối với nhiệt độ
cảm biến, giới hạn có thể được đặt thông qua Tắt máy quá nhiệt thích hợp
đăng ký và đăng ký trễ. Mỗi giá trị có thể được đặt và đọc ở mức nửa độ
độ chính xác.  Một cảnh báo được đưa ra (thường là cho LM78 được kết nối) khi
nhiệt độ cao hơn giá trị Tắt quá nhiệt; nó vẫn tiếp tục
cho đến khi nhiệt độ giảm xuống dưới giá trị Độ trễ. Tất cả nhiệt độ đều ở
độ C và được đảm bảo trong phạm vi từ -55 đến +125 độ.

THMC50 chỉ cập nhật giá trị của nó sau mỗi 1,5 giây; đọc nó thường xuyên hơn
sẽ không gây hại gì nhưng sẽ trả về giá trị 'cũ'.

THMC50 thường được sử dụng kết hợp với các chip giống LM78 để đo
nhiệt độ của (các) bộ xử lý.

ADM1022 hoạt động giống như THMC50 nhưng nhanh hơn (5 Hz thay vì
1 Hz cho THMC50). Nó cũng có thể được đưa vào một chế độ mới để xử lý các vấn đề bổ sung
cảm biến nhiệt độ từ xa. Trình điều khiển sử dụng chế độ do BIOS đặt theo mặc định.

Trong trường hợp BIOS bị hỏng và cài đặt chế độ không chính xác, bạn có thể buộc
chế độ có thêm nhiệt độ từ xa với tham số adm1022_temp3.
Triệu chứng điển hình của việc cài đặt sai là quạt bị buộc phải chạy hết tốc độ.

Tính năng trình điều khiển
--------------------------

Trình điều khiển cung cấp tới ba nhiệt độ:

tạm thời1
	- nội bộ
temp2
	- từ xa
temp3
	- Điều khiển từ xa thứ 2 chỉ dành cho ADM1022

pwm1
	- tốc độ quạt (0 = dừng, 255 = đầy)
pwm1_mode
	- luôn là 0 (chế độ DC)

Giá trị 0 cho pwm1 cũng buộc tín hiệu FAN_OFF từ chip,
vì vậy nó sẽ dừng quạt ngay cả khi giá trị 0 vào thanh ghi ANALOG_OUT không dừng.

Trình điều khiển đã được thử nghiệm trên Compaq AP550 với hai chip ADM1022 (một hoạt động
ở chế độ temp3), năm chỉ số nhiệt độ và hai quạt.
