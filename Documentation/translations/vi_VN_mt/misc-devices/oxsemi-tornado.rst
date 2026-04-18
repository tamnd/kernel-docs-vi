.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/misc-devices/oxsemi-tornado.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================================================
Những lưu ý về thiết bị cổng nối tiếp Oxford Semiconductor PCIe (Tornado) 950
=============================================================================

Các thiết bị cổng nối tiếp Oxford Semiconductor PCIe (Tornado) 950 được điều khiển
bằng đầu vào xung nhịp 62,5 MHz cố định lấy từ xung nhịp PCI Express 100 MHz.

Tốc độ baud được tạo ra bởi bộ tạo baud được lấy từ đầu vào này
tần số bằng cách chia nó cho bộ đếm trước đồng hồ, có thể được đặt thành bất kỳ
giá trị từ 1 đến 63,875 với gia số 0,125 và sau đó là 16 bit thông thường
bộ chia được sử dụng giống như 8250 ban đầu để chia tần số cho
giá trị từ 1 đến 65535. Cuối cùng, tốc độ lấy mẫu quá mức có thể lập trình được sử dụng
có thể lấy bất kỳ giá trị nào từ 4 đến 16 để chia tần số xa hơn và
xác định tốc độ truyền thực tế được sử dụng.  Tốc độ truyền từ 15625000bps trở xuống
đến 0,933bps có thể đạt được theo cách này.

Theo mặc định, tốc độ lấy mẫu quá mức được đặt thành 16 và bộ chia tỷ lệ xung nhịp được đặt
được đặt thành 33,875, nghĩa là tần số được sử dụng làm tần số tham chiếu
đối với ước số 16 bit thông thường là 115313.653, đủ gần với
tần số 115200 được sử dụng bởi 8250 ban đầu cho cùng một giá trị
được sử dụng cho số chia để đạt được tốc độ truyền được yêu cầu bằng phần mềm
không biết về các điều khiển đồng hồ bổ sung có sẵn.

Tốc độ lấy mẫu quá mức được lập trình với thanh ghi TCR và đồng hồ
bộ đếm gộp trước được lập trình với cặp thanh ghi CPR/CPR2 [OX200]_ [OX952]_
[OX954]_ [OX958]_.  Để chuyển khỏi giá trị mặc định là 33,875 cho
Tuy nhiên, bộ chia tỷ lệ trước, chế độ nâng cao phải được bật rõ ràng bằng cách
bit thiết lập 4 của EFR.  Trong chế độ đó, cài đặt bit 7 trong MCR cho phép
bộ đếm gộp trước hoặc nếu không thì nó bị bỏ qua như thể giá trị 1 đã được sử dụng.
Ngoài ra, việc ghi bất kỳ giá trị nào vào CPR sẽ xóa CPR2 để tương thích với
phần mềm cũ được viết cho Chất bán dẫn Oxford PCI thông thường cũ hơn
các thiết bị không có bit thứ 9 bổ sung của bộ đếm gộp trước trong CPR2, do đó
Cặp thanh ghi CPR/CPR2 phải được lập trình theo đúng thứ tự.

Bằng cách sử dụng các tham số này, tốc độ từ 15625000bps xuống còn 1bps có thể được
thu được, với tốc độ bit thực tế chính xác hoặc có độ chính xác cao cho
tiêu chuẩn và nhiều mức giá không chuẩn.

Dưới đây là số liệu về tốc độ truyền tiêu chuẩn và một số tốc độ truyền không chuẩn
(bao gồm cả những trích dẫn trong tài liệu của Oxford Semiconductor), đưa ra
tỷ giá yêu cầu (r), tỷ giá thực tế mang lại (a) và độ lệch của nó
từ tốc độ được yêu cầu (d) và các giá trị của tốc độ lấy mẫu quá mức
(tcr), bộ đếm trước đồng hồ (cpr) và bộ chia (div) được tạo ra bởi
trình xử lý ZZ0000ZZ mới:

::

r: 15625000, a: 15625000,00, d: 0,0000%, tcr: 4, cpr: 1.000, div: 1
 r: 12500000, a: 12500000,00, d: 0,0000%, tcr: 5, cpr: 1.000, div: 1
 r: 10416666, a: 10416666.67, d: 0,0000%, tcr: 6, cpr: 1.000, div: 1
 r: 8928571, a: 8928571.43, d: 0,0000%, tcr: 7, cpr: 1.000, div: 1
 r: 7812500, a: 7812500,00, d: 0,0000%, tcr: 8, cpr: 1.000, div: 1
 r: 4000000, a: 4000000,00, d: 0,0000%, tcr: 5, cpr: 3.125, div: 1
 r: 3686400, a: 3676470,59, d: -0,2694%, tcr: 8, cpr: 2,125, div: 1
 r: 3500000, a: 3496503,50, d: -0,0999%, tcr: 13, cpr: 1,375, div: 1
 r: 3000000, a: 2976190,48, d: -0,7937%, tcr: 14, cpr: 1.500, div: 1
 r: 2500000, a: 2500000,00, d: 0,0000%, tcr: 10, cpr: 2.500, div: 1
 r: 2000000, a: 2000000,00, d: 0,0000%, tcr: 10, cpr: 3.125, div: 1
 r: 1843200, a: 1838235.29, d: -0.2694%, tcr: 16, cpr: 2.125, div: 1
 r: 1500000, a: 1492537.31, d: -0.4975%, tcr: 5, cpr: 8.375, div: 1
 r: 1152000, a: 1152073,73, d: 0,0064%, tcr: 14, cpr: 3,875, div: 1
 r: 921600, a: 919117.65, d: -0.2694%, tcr: 16, cpr: 2.125, div: 2
 r: 576000, a: 576036,87, d: 0,0064%, tcr: 14, cpr: 3,875, div: 2
 r: 460800, a: 460829,49, d: 0,0064%, tcr: 7, cpr: 3,875, div: 5
 r: 230400, a: 230414,75, d: 0,0064%, tcr: 14, cpr: 3,875, div: 5
 r: 115200, a: 115207,37, d: 0,0064%, tcr: 14, cpr: 1,250, div: 31
 r: 57600, a: 57603,69, d: 0,0064%, tcr: 8, cpr: 3,875, div: 35
 r: 38400, a: 38402,46, d: 0,0064%, tcr: 14, cpr: 3,875, div: 30
 r: 19200, a: 19201,23, d: 0,0064%, tcr: 8, cpr: 3,875, div: 105
 r: 9600, a: 9600,06, d: 0,0006%, tcr: 9, cpr: 1.125, div: 643
 r: 4800, a: 4799,98, d: -0,0004%, tcr: 7, cpr: 2,875, div: 647
 r: 2400, a: 2400,02, d: 0,0008%, tcr: 9, cpr: 2,250, div: 1286
 r: 1200, a: 1200,00, d: 0,0000%, tcr: 14, cpr: 2,875, div: 1294
 r: 300, a: 300,00, d: 0,0000%, tcr: 11, cpr: 2,625, div: 7215
 r: 200, a: 200,00, d: 0,0000%, tcr: 16, cpr: 1.250, div: 15625
 r: 150, a: 150,00, d: 0,0000%, tcr: 13, cpr: 2,250, div: 14245
 r: 134, a: 134,00, d: 0,0000%, tcr: 11, cpr: 2,625, div: 16153
 r: 110, a: 110,00, d: 0,0000%, tcr: 12, cpr: 1.000, div: 47348
 r: 75, a: 75,00, d: 0,0000%, tcr: 4, cpr: 5,875, div: 35461
 r: 50, a: 50,00, d: 0,0000%, tcr: 16, cpr: 1,250, div: 62500
 r: 25, a: 25,00, d: 0,0000%, tcr: 16, cpr: 2.500, div: 62500
 r: 4, a: 4,00, d: 0,0000%, tcr: 16, cpr: 20.000, div: 48828
 r: 2, a: 2,00, d: 0,0000%, tcr: 16, cpr: 40.000, div: 48828
 r: 1, a: 1,00, d: 0,0000%, tcr: 16, cpr: 63,875, div: 61154

Với cơ sở baud được đặt thành 15625000 và UART_DIV_MAX 16 bit không dấu
giới hạn được áp đặt bởi tốc độ truyền tiêu chuẩn ZZ0000ZZ
dưới 300bps sẽ không khả dụng theo cách thông thường, ví dụ: tỷ lệ của
200bps yêu cầu cơ sở baud phải chia cho 78125 và vượt quá
phạm vi 16-bit không dấu.

Maciej W. Rozycki <macro@orcam.me.uk>

.. [OX200] "OXPCIe200 PCI Express Multi-Port Bridge", Oxford Semiconductor,
   Inc., DS-0045, 10 Nov 2008, Section "950 Mode", pp. 64-65

.. [OX952] "OXPCIe952 PCI Express Bridge to Dual Serial & Parallel Port",
   Oxford Semiconductor, Inc., DS-0046, Mar 06 08, Section "950 Mode",
   p. 20

.. [OX954] "OXPCIe954 PCI Express Bridge to Quad Serial Port", Oxford
   Semiconductor, Inc., DS-0047, Feb 08, Section "950 Mode", p. 20

.. [OX958] "OXPCIe958 PCI Express Bridge to Octal Serial Port", Oxford
   Semiconductor, Inc., DS-0048, Feb 08, Section "950 Mode", p. 20