.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hid/hid-sensor.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Khung cảm biến HID
=====================
Khung cảm biến HID cung cấp các giao diện cần thiết để triển khai trình điều khiển cảm biến,
được kết nối với một trung tâm cảm biến. Trung tâm cảm biến là một thiết bị HID và nó cung cấp
một bộ mô tả báo cáo phù hợp với bảng sử dụng cảm biến HID 1.12.

Mô tả từ thông số kỹ thuật HID 1.12 "Cách sử dụng cảm biến HID":
"Tiêu chuẩn hóa việc sử dụng HID cho cảm biến sẽ cho phép (nhưng không yêu cầu) cảm biến
các nhà cung cấp phần cứng để cung cấp giao diện Plug And Play nhất quán ở ranh giới USB,
nhờ đó cho phép một số hệ điều hành kết hợp các trình điều khiển thiết bị phổ biến để
có thể được tái sử dụng giữa các nhà cung cấp, giảm bớt mọi nhu cầu của nhà cung cấp để cung cấp
bản thân các tài xế."

Thông số kỹ thuật này mô tả nhiều ID sử dụng, mô tả loại cảm biến
và cả các trường dữ liệu riêng lẻ. Mỗi cảm biến có thể có số lượng khác nhau
các trường dữ liệu. Độ dài và thứ tự được chỉ định trong phần mô tả báo cáo. cho
ví dụ: một phần của bộ mô tả báo cáo có thể trông giống như::

INPUT(1)[INPUT]
   ..
      Field(2)
        Physical(0020.0073)
        Usage(1)
          0020.045f
        Logical Minimum(-32767)
        Logical Maximum(32767)
        Report Size(8)
        Report Count(1)
        Report Offset(16)
        Flags(Variable Absolute)
  ..
  ..

Báo cáo cho biết "trang cảm biến (0x20)" chứa gia tốc kế-3D (0x73).
Gia tốc kế-3D này có một số trường. Ví dụ ở đây trường 2 là cường độ chuyển động
(0x045f) với giá trị logic tối thiểu là -32767 và mức logic tối đa là 32767.
thứ tự của các trường và độ dài của mỗi trường rất quan trọng vì sự kiện đầu vào là thô
dữ liệu sẽ sử dụng định dạng này.


Thực hiện
==============

Thông số kỹ thuật này xác định nhiều loại cảm biến khác nhau với các bộ cảm biến khác nhau.
các trường dữ liệu. Rất khó để có một sự kiện đầu vào chung cho các ứng dụng không gian người dùng,
cho các cảm biến khác nhau. Ví dụ: gia tốc kế có thể gửi dữ liệu X, Y và Z, trong khi
cảm biến ánh sáng xung quanh có thể gửi dữ liệu chiếu sáng.
Vì vậy, việc thực hiện có hai phần:

- Trình điều khiển lõi HID
- Phần xử lý cảm biến riêng lẻ (trình điều khiển cảm biến)

Trình điều khiển cốt lõi
-----------
Trình điều khiển lõi (hid-sensor-hub) đăng ký làm trình điều khiển HID. Nó phân tích cú pháp
mô tả báo cáo và xác định tất cả các cảm biến hiện diện. Nó bổ sung thêm một thiết bị MFD
với tên HID-SENSOR-xxxx (trong đó xxxx là id sử dụng từ thông số kỹ thuật).

Ví dụ:

HID-SENSOR-200073 được đăng ký cho trình điều khiển Gia tốc kế 3D.

Vì vậy, nếu bất kỳ trình điều khiển nào có tên này được chèn vào thì quy trình thăm dò cho trình điều khiển đó
chức năng sẽ được gọi. Vì vậy, trình điều khiển xử lý gia tốc có thể đăng ký
với tên này và sẽ được thăm dò nếu phát hiện thấy gia tốc kế-3D.

Trình điều khiển cốt lõi cung cấp một bộ API có thể được sử dụng bởi quá trình xử lý
trình điều khiển để đăng ký và nhận sự kiện cho id sử dụng đó. Ngoài ra nó cung cấp phân tích cú pháp
các chức năng nhận và đặt từng báo cáo đầu vào/tính năng/đầu ra.

Phần xử lý cảm biến riêng lẻ (trình điều khiển cảm biến)
--------------------------------------------------

Trình điều khiển xử lý sẽ sử dụng giao diện do trình điều khiển lõi cung cấp để phân tích cú pháp
báo cáo và lấy chỉ mục của các trường và cũng có thể nhận các sự kiện. Người lái xe này
có thể sử dụng giao diện IIO để sử dụng ABI tiêu chuẩn được xác định cho một loại cảm biến.


Giao diện trình điều khiển lõi
=====================

Cấu trúc gọi lại::

Mỗi trình điều khiển xử lý có thể sử dụng cấu trúc này để thiết lập một số lệnh gọi lại.
	int (*suspend)(..): Gọi lại khi nhận được lệnh tạm dừng HID
	int (*resume)(..): Gọi lại khi nhận được sơ yếu lý lịch HID
	int (*capture_sample)(..): Chụp mẫu cho một trong các trường dữ liệu của nó
	int (*send_event)(..): Nhận được một sự kiện hoàn chỉnh có thể có
                               nhiều trường dữ liệu.

Chức năng đăng ký::

int cảm biến_hub_register_callback(struct hid_sensor_hub_device *hsdev,
			u32 use_id,
			cấu trúc hid_sensor_hub_callbacks *usage_callback):

Đăng ký cuộc gọi lại cho id sử dụng. Các chức năng gọi lại không được phép
đi ngủ::


int cảm biến_hub_remove_callback(struct hid_sensor_hub_device *hsdev,
			u32 use_id):

Loại bỏ các lệnh gọi lại cho id sử dụng.


Chức năng phân tích cú pháp::

int cảm biến_hub_input_get_attribute_info(struct hid_sensor_hub_device *hsdev,
			loại u8,
			u32 use_id, u32 attr_usage_id,
			cấu trúc hid_sensor_hub_attribute_info *thông tin);

Trình điều khiển xử lý có thể tìm kiếm một số lĩnh vực quan tâm và kiểm tra xem nó có tồn tại không
trong phần mô tả báo cáo. Nếu nó tồn tại nó sẽ lưu trữ thông tin cần thiết
để các trường có thể được đặt hoặc nhận riêng lẻ.
Các chỉ mục này tránh việc tìm kiếm mọi lúc và lấy chỉ mục trường để lấy hoặc đặt.


Đặt báo cáo tính năng::

int cảm biến_hub_set_feature(struct hid_sensor_hub_device *hsdev, u32 report_id,
			u32 field_index, giá trị s32);

Giao diện này được sử dụng để đặt giá trị cho một trường trong báo cáo tính năng. Ví dụ
nếu có trường report_interval, được phân tích cú pháp bằng lệnh gọi tới
cảm biến_hub_input_get_attribute_info trước đó, sau đó nó có thể trực tiếp thiết lập điều đó
trường riêng lẻ::


int cảm biến_hub_get_feature(struct hid_sensor_hub_device *hsdev, u32 report_id,
			u32 field_index, s32 *giá trị);

Giao diện này được sử dụng để lấy giá trị cho một trường trong báo cáo đầu vào. Ví dụ
nếu có trường report_interval, được phân tích cú pháp bằng lệnh gọi tới
Sensor_hub_input_get_attribute_info trước thì nó có thể trực tiếp lấy được thông tin đó
giá trị trường riêng lẻ::


int cảm biến_hub_input_attr_get_raw_value(struct hid_sensor_hub_device *hsdev,
			u32 use_id,
			u32 attr_usage_id, u32 report_id);

Điều này được sử dụng để nhận một giá trị trường cụ thể thông qua các báo cáo đầu vào. Ví dụ
gia tốc kế muốn thăm dò giá trị trục X, sau đó nó có thể gọi hàm này bằng
id sử dụng của trục X. Cảm biến HID có thể cung cấp các sự kiện nên điều này là không cần thiết
để thăm dò ý kiến ​​cho bất kỳ lĩnh vực nào. Nếu có một số mẫu mới, trình điều khiển cốt lõi sẽ gọi
chức năng gọi lại đã đăng ký để xử lý mẫu.


----------

HID Cảm biến tùy chỉnh và chung
------------------------------


Thông số cảm biến HID xác định hai loại sử dụng cảm biến đặc biệt. Vì họ
không đại diện cho cảm biến tiêu chuẩn, không thể xác định bằng Linux IIO
kiểu giao diện.
Mục đích của các cảm biến này là mở rộng chức năng hoặc cung cấp
cách để làm xáo trộn dữ liệu được truyền bởi cảm biến. Mà không biết
ánh xạ giữa dữ liệu và dạng đóng gói của nó, rất khó để
một ứng dụng/trình điều khiển để xác định dữ liệu nào đang được cảm biến truyền đạt.
Điều này cho phép một số trường hợp sử dụng khác biệt, trong đó nhà cung cấp có thể cung cấp ứng dụng.
Một số trường hợp sử dụng phổ biến là gỡ lỗi các cảm biến khác hoặc để cung cấp một số sự kiện như
gắn/tháo bàn phím hoặc đóng/mở nắp.

Để cho phép ứng dụng sử dụng các cảm biến này, ở đây chúng được xuất bằng sysfs
nhóm thuộc tính, thuộc tính và giao diện thiết bị linh tinh.

Một ví dụ về cách biểu diễn này trên sysfs::

/sys/devices/pci0000:00/INT33C2:00/i2c-0/i2c-INT33D1:00/0018:8086:09FA.0001/HID-SENSOR-2000e1.6.auto$ cây -R
  .
  │   ├── kích hoạt_cảm biến
  │   │   ├── feature-0-200316
  │   │   │   ├── tính năng-0-200316-tối đa
  │   │   │   ├── tính năng-0-200316-tối thiểu
  │   │   │   ├── feature-0-200316-name
  │   │   │   ├── feature-0-200316-size
  │   │   │   ├── feature-0-200316-unit-expo
  │   │   │   ├── feature-0-200316-unit
  │   │   │   ├── tính năng-0-200316-giá trị
  │   │   ├── feature-1-200201
  │   │   │   ├── tính năng-1-200201-tối đa
  │   │   │   ├── tính năng-1-200201-tối thiểu
  │   │   │   ├── feature-1-200201-name
  │   │   │   ├── feature-1-200201-size
  │   │   │   ├── feature-1-200201-unit-expo
  │   │   │   ├── tính năng-1-200201-đơn vị
  │   │   │   ├── tính năng-1-200201-giá trị
  │   │   ├── đầu vào-0-200201
  │   │   │   ├── đầu vào-0-200201-tối đa
  │   │   │   ├── đầu vào-0-200201-tối thiểu
  │   │   │   ├── input-0-200201-name
  │   │   │   ├── kích thước đầu vào-0-200201
  │   │   │   ├── input-0-200201-unit-expo
  │   │   │   ├── đầu vào-0-200201-đơn vị
  │   │   │   ├── giá trị đầu vào-0-200201
  │   │   ├── đầu vào-1-200202
  │   │   │   ├── đầu vào-1-200202-tối đa
  │   │   │   ├── đầu vào-1-200202-tối thiểu
  │   │   │   ├── đầu vào-1-200202-tên
  │   │   │   ├── kích thước đầu vào-1-200202
  │   │   │   ├── input-1-200202-unit-expo
  │   │   │   ├── đầu vào-1-200202-đơn vị
  │   │   │   ├── giá trị đầu vào-1-200202

Ở đây có một cảm biến tùy chỉnh với bốn trường: hai tính năng và hai đầu vào.
Mỗi trường được đại diện bởi một tập hợp các thuộc tính. Tất cả các trường ngoại trừ "giá trị"
chỉ được đọc. Trường giá trị là trường đọc-ghi.

Ví dụ::

/sys/bus/platform/devices/HID-SENSOR-2000e1.6.auto/feature-0-200316$ grep -r . *
  feature-0-200316-maximum:6
  tính năng-0-200316-tối thiểu: 0
  feature-0-200316-name:property-báo cáo-trạng thái
  feature-0-200316-size:1
  feature-0-200316-unit-expo:0
  feature-0-200316-unit:25
  feature-0-200316-value:1

Làm thế nào để kích hoạt cảm biến như vậy?
^^^^^^^^^^^^^^^^^^^^^^^^^^

Theo mặc định, cảm biến có thể được cấp nguồn. Để bật thuộc tính sysfs, "enable" có thể là
đã sử dụng::

$ echo 1 > Enable_sensor

Sau khi được bật và bật, cảm biến có thể báo cáo giá trị bằng báo cáo HID.
Các báo cáo này được gửi bằng giao diện thiết bị linh tinh theo thứ tự FIFO::

/dev$cây | grep HID-SENSOR-2000e1.6.auto
	│   │   │   ├── 10:53 -> ../HID-SENSOR-2000e1.6.auto
	│   ├── HID-SENSOR-2000e1.6.auto

Mỗi báo cáo có thể có độ dài thay đổi trước một tiêu đề. Tiêu đề này
bao gồm id sử dụng 32 bit, dấu thời gian 64 bit và trường thô có độ dài 32 bit
dữ liệu.
