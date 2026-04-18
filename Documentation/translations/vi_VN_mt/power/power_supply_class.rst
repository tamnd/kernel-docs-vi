.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/power/power_supply_class.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Lớp cung cấp năng lượng Linux
========================

Tóm tắt
~~~~~~~~
Loại nguồn điện được sử dụng để đại diện cho pin, nguồn điện UPS, AC hoặc DC
các thuộc tính cho không gian người dùng.

Nó xác định một tập hợp các thuộc tính cốt lõi có thể áp dụng cho (gần như)
mọi nguồn điện ngoài kia. Các thuộc tính có sẵn thông qua sysfs và uevent
giao diện.

Mỗi thuộc tính có một ý nghĩa được xác định rõ ràng tùy theo đơn vị đo được sử dụng. Trong khi
các thuộc tính được cung cấp được cho là có thể áp dụng phổ biến cho bất kỳ
nguồn điện, phần cứng giám sát cụ thể có thể không cung cấp được chúng
tất cả, vì vậy bất kỳ trong số chúng có thể bị bỏ qua.

Lớp cung cấp điện có thể mở rộng và cho phép người lái xe tự xác định
thuộc tính.  Bộ thuộc tính cốt lõi tuân theo sự phát triển tiêu chuẩn của Linux
(tức là, nếu một thuộc tính nào đó được tìm thấy có thể áp dụng cho nhiều lũy thừa
loại nguồn cung cấp hoặc trình điều khiển của chúng, nó có thể được thêm vào bộ lõi).

Nó cũng tích hợp với khung LED, nhằm mục đích cung cấp
phản hồi thường được mong đợi về trạng thái sạc/sạc đầy pin và
Trạng thái trực tuyến của nguồn điện AC/USB. (Lưu ý rằng các chi tiết cụ thể của
chỉ định (bao gồm cả việc có nên sử dụng nó hay không) hoàn toàn có thể được kiểm soát bởi
mặc định của người dùng và/hoặc máy cụ thể, theo nguyên tắc thiết kế của LED
khuôn khổ.)


Thuộc tính/thuộc tính
~~~~~~~~~~~~~~~~~~~~~
Lớp cung cấp điện có một tập hợp các thuộc tính được xác định trước. Điều này giúp loại bỏ mã
trùng lặp giữa các trình điều khiển. Lớp cung cấp điện nhất quyết tái sử dụng nó
thuộc tính được xác định trước ZZ0000ZZ đơn vị của họ.

Vì vậy, không gian người dùng nhận được một tập hợp các thuộc tính và đơn vị có thể dự đoán được cho bất kỳ
loại nguồn điện và có thể xử lý/trình bày chúng cho người dùng một cách nhất quán
cách. Kết quả cho các bộ nguồn và máy móc khác nhau cũng được trực tiếp
có thể so sánh được.

Xem driver/power/supply/ds2760_battery.c để biết ví dụ về cách khai báo
và xử lý các thuộc tính.


Đơn vị
~~~~~
Trích dẫn bao gồm/linux/power_supply.h:

Tất cả điện áp, dòng điện, điện tích, năng lượng, thời gian và nhiệt độ tính bằng µV,
  µA, µAh, µWh, giây và phần mười độ C trừ khi có trường hợp khác
  đã nêu. Công việc của trình điều khiển là chuyển đổi các giá trị thô của nó thành các đơn vị trong đó
  lớp này hoạt động.


Thuộc tính/thuộc tính chi tiết
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

+-----------------------------------------------------------------------------------+
ZZ0005ZZ
+-----------------------------------------------------------------------------------+
ZZ0006ZZ
ZZ0007ZZ
ZZ0008ZZ
ZZ0009ZZ
ZZ0010ZZ
ZZ0011ZZ
ZZ0012ZZ
ZZ0013ZZ
ZZ0014ZZ
+-----------------------------------------------------------------------------------+

Hậu tố:

_AVG
  Giá trị trung bình của ZZ0000ZZ, hãy sử dụng nó nếu phần cứng của bạn thực sự có khả năng
  báo cáo giá trị trung bình.
_NOW
  giá trị nhất thời/tức thời.

STATUS
  Thuộc tính này thể hiện trạng thái hoạt động (đang sạc, đầy,
  xả (tức là cấp nguồn cho tải), v.v.). Điều này tương ứng với
  Giá trị ZZ0000ZZ, như được xác định trong pin.h.

CHARGE_TYPE
  pin thường có thể sạc ở các mức giá khác nhau.
  Điều này xác định chi phí nhỏ giọt và nhanh chóng.  Đối với pin mà
  đã được sạc hoặc xả, 'n/a' có thể được hiển thị (hoặc
  'không xác định', nếu trạng thái không được biết).

AUTHENTIC
  cho biết nguồn điện (pin hoặc bộ sạc) được kết nối
  đối với nền tảng là xác thực(1) hoặc không xác thực(0).

HEALTH
  đại diện cho sức khỏe của pin. Giá trị tương ứng với
  POWER_SUPPLY_HEALTH_*, được xác định trong pin.h.

VOLTAGE_OCV
  điện áp mạch hở của pin.

VOLTAGE_MAX_DESIGN, VOLTAGE_MIN_DESIGN
  giá trị thiết kế cho điện áp nguồn tối đa và tối thiểu.
  Giá trị trung bình tối đa/tối thiểu của điện áp khi xem xét pin
  "đầy"/"trống" ở điều kiện bình thường. Vâng, không có mối quan hệ trực tiếp
  giữa điện áp và dung lượng pin, nhưng một số điều ngớ ngẩn
  pin sử dụng điện áp để tính toán công suất rất gần đúng.
  Trình điều khiển pin cũng có thể sử dụng thuộc tính này chỉ để thông báo không gian người dùng
  về ngưỡng điện áp tối đa và tối thiểu của một loại pin nhất định.

VOLTAGE_MAX, VOLTAGE_MIN
  giống như các giá trị điện áp _DESIGN ngoại trừ những giá trị này nên được sử dụng
  nếu phần cứng chỉ có thể đoán (đo lường và giữ lại) các ngưỡng của
  cung cấp điện nhất định.

VOLTAGE_BOOT
  Báo cáo điện áp đo được trong quá trình khởi động

CURRENT_BOOT
  Báo cáo dòng điện đo được trong quá trình khởi động

CHARGE_FULL_DESIGN, CHARGE_EMPTY_DESIGN
  giá trị sạc thiết kế, khi pin được coi là đầy/hết.

ENERGY_FULL_DESIGN, ENERGY_EMPTY_DESIGN
  tương tự như trên nhưng về năng lượng.

CHARGE_FULL, CHARGE_EMPTY
  Các thuộc tính này có nghĩa là "giá trị sạc được ghi nhớ lần cuối khi pin
  trở nên đầy/trống". Chúng cũng có thể có nghĩa là "giá trị sạc khi pin hết
  được coi là đầy/trống ở các điều kiện nhất định (nhiệt độ, tuổi)".
  Tức là, các thuộc tính này đại diện cho ngưỡng thực chứ không phải giá trị thiết kế.

ENERGY_FULL, ENERGY_EMPTY
  tương tự như trên nhưng về năng lượng.

CHARGE_COUNTER
  bộ đếm điện tích hiện tại (tính bằng µAh).  Điều này có thể dễ dàng
  tiêu cực; không có giá trị trống hoặc đầy đủ.  Nó chỉ hữu ích cho
  các phép đo tương đối, dựa trên thời gian.

PRECHARGE_CURRENT
  dòng sạc tối đa trong giai đoạn nạp trước của chu kỳ sạc
  (thường là 20% dung lượng pin).

CHARGE_TERM_CURRENT
  Sạc chấm dứt hiện tại. Chu kỳ sạc kết thúc khi pin
  điện áp ở trên ngưỡng nạp lại và dòng sạc ở dưới
  cài đặt này (thường là 10% dung lượng pin).

CONSTANT_CHARGE_CURRENT
  dòng sạc không đổi được lập trình bởi bộ sạc.

CONSTANT_CHARGE_CURRENT_MAX
  dòng sạc tối đa được hỗ trợ bởi đối tượng cung cấp điện.

CONSTANT_CHARGE_VOLTAGE
  điện áp sạc không đổi được lập trình bởi bộ sạc.

CONSTANT_CHARGE_VOLTAGE_MAX
  điện áp sạc tối đa được hỗ trợ bởi đối tượng cung cấp điện.

INPUT_CURRENT_LIMIT
  giới hạn dòng điện đầu vào được lập trình bởi bộ sạc. chỉ ra
  dòng điện rút ra từ nguồn sạc.
INPUT_VOLTAGE_LIMIT
  giới hạn điện áp đầu vào được lập trình bởi bộ sạc. chỉ ra
  giới hạn điện áp từ nguồn sạc.
INPUT_POWER_LIMIT
  giới hạn nguồn điện đầu vào được lập trình bởi bộ sạc. chỉ ra
  giới hạn công suất từ nguồn sạc.

CHARGE_CONTROL_LIMIT
  cài đặt giới hạn kiểm soát sạc hiện tại
CHARGE_CONTROL_LIMIT_MAX
  cài đặt giới hạn kiểm soát sạc tối đa

CALIBRATE
  trạng thái hiệu chuẩn pin hoặc bộ đếm Coulomb

CAPACITY
  công suất tính bằng phần trăm.
CAPACITY_ALERT_MIN
  giá trị cảnh báo công suất tối thiểu tính bằng phần trăm.
CAPACITY_ALERT_MAX
  giá trị cảnh báo công suất tối đa tính bằng phần trăm.
CAPACITY_LEVEL
  mức năng lực. Điều này tương ứng với POWER_SUPPLY_CAPACITY_LEVEL_*.

TEMP
  nhiệt độ của nguồn điện.
TEMP_ALERT_MIN
  cảnh báo nhiệt độ pin tối thiểu.
TEMP_ALERT_MAX
  cảnh báo nhiệt độ pin tối đa.
TEMP_AMBIENT
  nhiệt độ môi trường xung quanh.
TEMP_AMBIENT_ALERT_MIN
  cảnh báo nhiệt độ môi trường tối thiểu.
TEMP_AMBIENT_ALERT_MAX
  cảnh báo nhiệt độ môi trường tối đa.
TEMP_MIN
  nhiệt độ hoạt động tối thiểu
TEMP_MAX
  nhiệt độ hoạt động tối đa

TIME_TO_EMPTY
  giây còn lại để pin được coi là trống
  (tức là trong khi pin cung cấp năng lượng cho tải)
TIME_TO_FULL
  giây còn lại để pin được coi là đầy
  (tức là trong khi đang sạc pin)


Pin <-> tương tác nguồn điện bên ngoài
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Thông thường các nguồn cung cấp năng lượng đều đóng vai trò là nguồn cung cấp và chất thay thế cùng một lúc.
thời gian. Pin là ví dụ điển hình. Vì vậy, pin thường quan tâm liệu chúng có
nguồn điện bên ngoài hay không.

Trong trường hợp đó, lớp cung cấp điện thực hiện cơ chế thông báo cho
pin.

Nguồn điện bên ngoài (AC) liệt kê tên các chất thay thế (pin) trong
Thành viên cấu trúc "supplied_to" và mỗi lệnh gọi power_supply_changed()
được cung cấp bởi nguồn điện bên ngoài sẽ thông báo cho người thay thế thông qua
cuộc gọi lại external_power_changed.


Đặc điểm pin của Devicetree
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Người lái xe nên gọi power_supply_get_battery_info() để lấy pin
đặc điểm từ nút pin cây thiết bị, được xác định trong
Tài liệu/devicetree/ràng buộc/nguồn/cung cấp/pin.yaml. Đây là
được triển khai trong trình điều khiển/nguồn/cung cấp/bq27xxx_battery.c.

Các thuộc tính trong struct power_supply_battery_info và các thuộc tính tương đương của chúng trong
nút pin có tên tương ứng với các thành phần trong enum power_supply_property,
để đặt tên thống nhất giữa các thuộc tính sysfs và thuộc tính nút pin.


Hỏi đáp
~~~

Hỏi:
   Thuộc tính POWER_SUPPLY_PROP_XYZ ở đâu?
Đáp:
   Nếu bạn không thể tìm thấy thuộc tính phù hợp với nhu cầu lái xe của mình, hãy thoải mái
   để thêm nó và gửi một bản vá cùng với trình điều khiển của bạn.

Các thuộc tính hiện có là những thuộc tính được cung cấp bởi
   trình điều khiển được viết.

Các ứng cử viên phù hợp để thêm vào trong tương lai: model/part#, Cycle_time, nhà sản xuất,
   v.v.


Hỏi:
   Tôi có một số thuộc tính rất cụ thể (ví dụ: màu pin). Tôi có nên thêm
   thuộc tính này thành thuộc tính tiêu chuẩn?
Đáp:
   Rất có thể là không. Thuộc tính như vậy có thể được đặt trong chính trình điều khiển, nếu
   nó rất hữu ích. Tất nhiên, nếu thuộc tính được đề cập có thể áp dụng cho
   một bộ pin lớn, được cung cấp bởi nhiều tài xế và/hoặc đến từ
   một số thông số/tiêu chuẩn chung về pin, nó có thể là một ứng cử viên cho
   được thêm vào tập thuộc tính cốt lõi.


Hỏi:
   Giả sử chip/phần mềm giám sát pin của tôi không cung cấp dung lượng
   tính bằng phần trăm, nhưng cung cấp charge_{now,full,empty}. Tôi có nên tính toán
   phần trăm dung lượng theo cách thủ công, bên trong trình điều khiển và đăng ký CAPACITY
   thuộc tính? Câu hỏi tương tự về time_to_empty/time_to_full.
Đáp:
   Rất có thể là không. Lớp này được thiết kế để xuất các thuộc tính
   có thể đo lường trực tiếp bằng phần cứng cụ thể có sẵn.

Suy ra các thuộc tính không có sẵn bằng cách sử dụng một số phương pháp phỏng đoán hoặc toán học
   mô hình không phải là chủ đề công việc của người điều khiển pin. Chức năng như vậy
   nên được tính đến, và trên thực tế, apm_power, trình điều khiển để phục vụ
   APM API kế thừa trên lớp cung cấp điện, sử dụng phương pháp phỏng đoán đơn giản về
   xấp xỉ dung lượng pin còn lại dựa trên mức sạc, dòng điện,
   điện áp và như vậy. Nhưng một mẫu pin đầy đủ có thể không phải là một chủ đề
   đối với kernel, vì nó sẽ yêu cầu tính toán dấu phẩy động để
   xử lý những thứ như phương trình vi phân và bộ lọc Kalman. Đây là
   tốt hơn nên được xử lý bằng pin/libbattery, chưa được viết.
