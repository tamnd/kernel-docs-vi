.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/w1/slaves/w1_therm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================
Trình điều khiển hạt nhân w1_therm
======================

Chip được hỗ trợ:

* Cảm biến nhiệt độ dựa trên Maxim ds18*20.
  * Cảm biến nhiệt độ dựa trên Maxim ds1825.
  * Cảm biến nhiệt độ GXCAS GX20MH01.
  * Giao diện nhiệt kế Maxim MAX31850.

Tác giả: Evgeniy Polykov <johnpol@2ka.mipt.ru>


Sự miêu tả
-----------

w1_therm cung cấp khả năng chuyển đổi nhiệt độ cơ bản cho ds18*20, ds28ea00, GX20MH01
và các thiết bị MAX31850.

Mã gia đình được hỗ trợ:

==========================
W1_THERM_DS18S20 0x10
W1_THERM_DS1822 0x22
W1_THERM_DS18B20 0x28
W1_THERM_DS1825 0x3B
W1_THERM_DS28EA00 0x42
==========================

Hỗ trợ được cung cấp thông qua mục sysfs ZZ0000ZZ. Mỗi lần mở và
trình tự đọc sẽ bắt đầu chuyển đổi nhiệt độ, sau đó cung cấp hai
dòng đầu ra ASCII. Dòng đầu tiên chứa chín byte hex
đọc cùng với giá trị crc được tính toán và YES hoặc NO nếu nó khớp.
Nếu crc khớp thì giá trị trả về sẽ được giữ lại. Dòng thứ hai
hiển thị các giá trị được giữ lại cùng với nhiệt độ tính bằng mili độ
Độ C sau t=.

Ngoài ra, nhiệt độ có thể được đọc bằng hệ thống ZZ0000ZZ, nó
chỉ trả về nhiệt độ tính bằng mili độ C.

Có thể thực hiện đọc hàng loạt tất cả các thiết bị trên xe buýt bằng cách ghi ZZ0000ZZ
vào mục nhập ZZ0001ZZ ở cấp độ w1_bus_master. Điều này sẽ
gửi lệnh chuyển đổi tới tất cả các thiết bị trên xe buýt và nếu ký sinh trùng
các thiết bị được cấp nguồn được phát hiện trên xe buýt (và tính năng pullup mạnh được bật
trong mô-đun), nó sẽ đẩy dòng lên cao trong quá trình chuyển đổi dài hơn
thời gian cần thiết của thiết bị được cung cấp năng lượng ký sinh trên đường dây. Đọc
ZZ0002ZZ sẽ trả về 0 nếu không có chuyển đổi hàng loạt nào đang chờ xử lý,
-1 nếu ít nhất một cảm biến vẫn đang chuyển đổi, 1 nếu chuyển đổi hoàn tất
nhưng ít nhất một giá trị cảm biến chưa được đọc. Nhiệt độ kết quả là
sau đó được truy cập bằng cách đọc mục nhập ZZ0003ZZ của từng thiết bị, mục này
có thể trả về trống nếu quá trình chuyển đổi vẫn đang diễn ra. Lưu ý rằng nếu một số lượng lớn
đọc được gửi đi nhưng một cảm biến không được đọc ngay lập tức, lần truy cập tiếp theo vào
ZZ0004ZZ trên thiết bị này sẽ trả về nhiệt độ đo được tại
thời điểm phát lệnh đọc số lượng lớn (không phải nhiệt độ hiện tại).

Một pullup mạnh sẽ được áp dụng trong quá trình chuyển đổi nếu được yêu cầu.

ZZ0000ZZ được sử dụng để lấy thời gian chuyển đổi hiện tại (đọc) và
điều chỉnh nó (viết). Thời gian chuyển đổi nhiệt độ phụ thuộc vào loại thiết bị và
độ phân giải hiện tại của nó. Thời gian chuyển đổi mặc định được thiết lập bởi trình điều khiển theo
vào bảng dữ liệu thiết bị. Thời gian chuyển đổi cho nhiều bản sao thiết bị gốc
đi chệch khỏi thông số kỹ thuật của bảng dữ liệu. Có ba tùy chọn: 1) đặt thủ công
sửa thời gian chuyển đổi bằng cách ghi giá trị tính bằng mili giây vào ZZ0001ZZ; 2)
tự động đo và đặt thời gian chuyển đổi bằng cách viết ZZ0002ZZ vào
ZZ0003ZZ; 3) sử dụng ZZ0004ZZ để kích hoạt cuộc thăm dò ý kiến để chuyển đổi
hoàn thành. Tùy chọn 2, 3 không thể được sử dụng ở chế độ năng lượng ký sinh. Để quay lại
thời gian chuyển đổi mặc định ghi ZZ0005ZZ vào ZZ0006ZZ.

Việc ghi giá trị độ phân giải (tính bằng bit) vào ZZ0000ZZ sẽ thay đổi
độ chính xác của cảm biến cho lần đọc tiếp theo. Độ phân giải được phép được xác định bởi
cảm biến. Độ phân giải được đặt lại khi cảm biến được cấp nguồn.

Để lưu trữ độ phân giải hiện tại trong EEPROM, hãy ghi ZZ0000ZZ vào ZZ0001ZZ.
Vì EEPROM có số lượng ghi hạn chế (>50k), nên lệnh này phải được
được sử dụng một cách khôn ngoan.

Ngoài ra, độ phân giải có thể được đọc hoặc ghi bằng cách sử dụng
Mục nhập ZZ0000ZZ trên mỗi thiết bị, nếu được cảm biến hỗ trợ.

Một số chip DS18B20 không chính hãng chỉ được cố định ở chế độ 12 bit, do đó, giá trị thực tế
độ phân giải được đọc lại từ chip và được xác minh.

Lưu ý: Việc thay đổi độ phân giải sẽ hoàn nguyên thời gian chuyển đổi về mặc định.

Mục nhập sysfs chỉ ghi ZZ0000ZZ là một mục thay thế cho các hoạt động EEPROM.
Viết ZZ0001ZZ để lưu thiết bị RAM vào EEPROM. Viết ZZ0002ZZ để khôi phục EEPROM
dữ liệu trong thiết bị RAM.

Mục ZZ0000ZZ cho phép kiểm tra trạng thái nguồn của từng thiết bị. Đọc
ZZ0001ZZ nếu thiết bị được cấp nguồn ký sinh, ZZ0002ZZ nếu thiết bị được cấp nguồn bên ngoài.

Sysfs ZZ0000ZZ cho phép đọc hoặc ghi cảnh báo TH và TL (Nhiệt độ cao và thấp).
Các giá trị phải cách nhau bằng dấu cách và nằm trong phạm vi thiết bị (điển hình là -55 độ C).
đến 125 độ C). Các giá trị là số nguyên vì chúng được lưu trữ trong thanh ghi 8 bit ở
thiết bị. Giá trị thấp nhất được tự động đưa vào TL. Sau khi được đặt, báo thức có thể
được tìm kiếm ở cấp độ chính.

Tham số mô-đun strong_pullup có thể được đặt thành 0 để tắt
pullup mạnh, 1 để kích hoạt tính năng tự động phát hiện hoặc 2 để buộc pullup mạnh.
Trong trường hợp tự động phát hiện, trình điều khiển sẽ sử dụng "READ POWER SUPPLY"
lệnh để kiểm tra xem có thiết bị hỗ trợ pariste trên xe buýt hay không.
Nếu vậy, nó sẽ kích hoạt lực kéo mạnh mẽ của chủ nhân.
Trong trường hợp việc phát hiện các thiết bị ký sinh bằng lệnh này không thành công
(có vẻ như là trường hợp của một số DS18S20) lực kéo mạnh có thể
được kích hoạt bằng vũ lực.

Nếu tính năng pullup mạnh được kích hoạt, pullup mạnh mẽ của chủ sẽ được kích hoạt.
được điều khiển khi quá trình chuyển đổi diễn ra, miễn là trình điều khiển chính
không hỗ trợ pullup mạnh mẽ (hoặc nó rơi trở lại pullup
điện trở).  Thông số kỹ thuật của cảm biến nhiệt độ DS18b20 liệt kê một
dòng điện tối đa là 1,5mA và điện trở kéo lên 5k thì không
đủ.  Lực kéo mạnh được thiết kế để cung cấp thêm lực
yêu cầu hiện tại.

DS28EA00 cung cấp thêm hai chân để thực hiện trình tự
thuật toán phát hiện.  Tính năng này cho phép bạn xác định tính chất vật lý
vị trí của chip trong bus 1 dây mà không cần có sẵn
kiến thức về việc đặt hàng xe buýt.  Hỗ trợ được cung cấp thông qua sysfs
ZZ0000ZZ. Tệp sẽ chứa một dòng duy nhất có giá trị nguyên
đại diện cho chỉ số thiết bị trong bus bắt đầu từ 0.

Mục nhập hệ thống ZZ0000ZZ kiểm soát cài đặt trình điều khiển tùy chọn cho mỗi thiết bị.
Không đủ năng lượng ở chế độ ký sinh, nhiễu đường truyền và chuyển đổi không đủ
thời gian có thể dẫn đến chuyển đổi thất bại. DS18B20 gốc và một số bản sao cho phép
phát hiện chuyển đổi không hợp lệ. Ghi mặt nạ bit ZZ0001ZZ vào ZZ0002ZZ để kích hoạt
kiểm tra chuyển đổi thành công. Nếu byte 6 của bộ nhớ Scratchpad là 0xC sau
chuyển đổi và nhiệt độ đọc là 85,00 (giá trị khởi động) hoặc 127,94 (không đủ
power), trình điều khiển sẽ trả về lỗi chuyển đổi. Mặt nạ bit ZZ0003ZZ cho phép thăm dò ý kiến
hoàn thành chuyển đổi (chỉ nguồn điện bình thường) bằng cách tạo chu kỳ đọc trên bus
sau khi bắt đầu chuyển đổi. Ở chế độ năng lượng ký sinh, tính năng này không khả dụng.
Mặt nạ bit tính năng có thể được kết hợp (HOẶC). Thêm chi tiết trong
Tài liệu/ABI/testing/sysfs-driver-w1_therm

Thiết bị GX20MH01 có chung số họ 0x28 với DS18*20. Thiết bị nói chung là
tương thích với DS18B20. Đã thêm nhiệt độ 2\ZZ0000ZZ, 2\ZZ0001ZZ thấp nhất
bit trong thanh ghi Cấu hình; Bit R2 trong thanh ghi Cấu hình cho phép 13 và 14 bit
nghị quyết. Thiết bị được cấp nguồn ở chế độ độ phân giải 14 bit. Sự chuyển đổi
thời gian được chỉ định trong biểu dữ liệu quá thấp và phải tăng lên. các
thiết bị hỗ trợ tính năng trình điều khiển ZZ0002ZZ và ZZ0003ZZ.

Thiết bị MAX31850 có chung số họ 0x3B với DS1825. Thiết bị nói chung là
tương thích với DS1825. 4 bit cao hơn của thanh ghi Cấu hình đọc tất cả 1,
chỉ ra 15, nhưng thiết bị luôn hoạt động ở chế độ phân giải 14 bit.
