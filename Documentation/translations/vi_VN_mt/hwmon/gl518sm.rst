.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/gl518sm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân gl518sm
=================================

Chip được hỗ trợ:

* Genesys Logic GL518SM phát hành 0x00

Tiền tố: 'gl518sm'

Địa chỉ được quét: I2C 0x2c và 0x2d

* Genesys Logic GL518SM phát hành 0x80

Tiền tố: 'gl518sm'

Địa chỉ được quét: I2C 0x2c và 0x2d

Bảng dữ liệu: ZZ0000ZZ

tác giả:
       - Frodo Looijaard <frodol@dds.nl>,
       - Kyösti Mälkki <kmalkki@cc.hut.fi>
       - Hong-Gunn Chew <hglinux@gunnet.org>
       - Jean Delvare <jdelvare@suse.de>

Sự miêu tả
-----------

.. important::

   For the revision 0x00 chip, the in0, in1, and in2  values (+5V, +3V,
   and +12V) CANNOT be read. This is a limitation of the chip, not the driver.

Trình điều khiển này hỗ trợ chip Genesys Logic GL518SM. Có ít nhất
hai bản sửa đổi của chip này, mà chúng tôi gọi là bản sửa đổi 0x00 và 0x80. Sửa đổi
Chip 0x80 chỉ hỗ trợ đọc tất cả điện áp và sửa đổi 0x00
cho VIN3.

GL518SM thực hiện một cảm biến nhiệt độ, hai tốc độ quay của quạt
cảm biến và bốn cảm biến điện áp. Nó có thể báo cáo cảnh báo thông qua
loa máy tính.

Nhiệt độ được đo bằng độ C. Chuông báo động sẽ vang lên trong khi
nhiệt độ vượt quá giới hạn nhiệt độ và chưa giảm
dưới giới hạn trễ. Báo động luôn phản ánh hiện tại
tình huống. Các phép đo được đảm bảo trong khoảng từ -10 độ đến +110
độ, với độ chính xác +/- 3 độ.

Tốc độ quay được báo cáo bằng RPM (số vòng quay mỗi phút). Một báo động là
được kích hoạt nếu tốc độ quay giảm xuống dưới giới hạn có thể lập trình. trong
trường hợp khi bạn đã chọn tắt fan1, không có cảnh báo fan1 nào được kích hoạt.

Số đọc của quạt có thể được chia bằng bộ chia có thể lập trình (1, 2, 4 hoặc 8) để
cung cấp cho các bài đọc nhiều phạm vi hoặc độ chính xác.  Không phải tất cả các giá trị RPM đều có thể
được biểu diễn chính xác nên việc làm tròn được thực hiện. Với một bộ chia
bằng 2, giá trị biểu thị thấp nhất là khoảng 1900 RPM.

Cảm biến điện áp (còn được gọi là cảm biến VIN) báo cáo giá trị của chúng bằng vôn.
Cảnh báo sẽ được kích hoạt nếu điện áp vượt quá mức tối thiểu có thể lập trình hoặc
giới hạn tối đa. Lưu ý rằng mức tối thiểu trong trường hợp này luôn có nghĩa là 'gần nhất với
không'; điều này rất quan trọng đối với các phép đo điện áp âm. Đầu vào VDD
đo điện áp từ 0,000 đến 5,865 volt, với độ phân giải 0,023
vôn. Các đầu vào khác đo điện áp trong khoảng từ 0,000 đến 4,845 volt, với
độ phân giải 0,019 volt. Lưu ý rằng chip 0x00 sửa đổi không hỗ trợ
đọc điện áp hiện tại của bất kỳ đầu vào nào ngoại trừ VIN3; thiết lập giới hạn và
Tuy nhiên, báo động vẫn hoạt động tốt.

Khi cảnh báo được kích hoạt, bạn có thể được cảnh báo bằng tín hiệu bíp thông qua
loa máy tính. Có thể kích hoạt tất cả tiếng bíp trên toàn cầu hoặc chỉ
tiếng bíp cho một số báo động.

Nếu cảnh báo kích hoạt, nó sẽ vẫn được kích hoạt cho đến khi phần cứng đăng ký
được đọc ít nhất một lần (ngoại trừ cảnh báo nhiệt độ). Điều này có nghĩa là
nguyên nhân khiến báo động có thể đã biến mất! Lưu ý rằng trong hiện tại
thực hiện, tất cả các thanh ghi phần cứng sẽ được đọc bất cứ khi nào có dữ liệu được đọc
(trừ khi chưa đến 1,5 giây kể từ lần cập nhật cuối cùng). Điều này có nghĩa là
bạn có thể dễ dàng bỏ lỡ các báo thức chỉ một lần.

GL518SM chỉ cập nhật giá trị của nó sau mỗi 1,5 giây; đọc nó thường xuyên hơn
sẽ không gây hại gì nhưng sẽ trả về giá trị 'cũ'.
