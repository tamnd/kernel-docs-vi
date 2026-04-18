.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/thermal/sysfs-api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================================
Trình điều khiển Sysfs nhiệt chung Cách thực hiện
===================================

Viết bởi Sujith Thomas <sujith.thomas@intel.com>, Zhang Rui <rui.zhang@intel.com>

Bản quyền (c) 2008 Tập đoàn Intel


0. Giới thiệu
===============

Các hệ thống nhiệt chung cung cấp một bộ giao diện cho vùng nhiệt
thiết bị (cảm biến) và thiết bị làm mát nhiệt (quạt, bộ xử lý...) để đăng ký
với giải pháp quản lý nhiệt và trở thành một phần của nó.

Cách thực hiện này tập trung vào việc cho phép các thiết bị làm mát và vùng nhiệt mới hoạt động
tham gia quản lý nhiệt.
Giải pháp này độc lập với nền tảng và mọi loại thiết bị vùng nhiệt
và các thiết bị làm mát có thể tận dụng được cơ sở hạ tầng.

Nhiệm vụ chính của trình điều khiển sysfs nhiệt là hiển thị các thuộc tính vùng nhiệt
cũng như các thuộc tính của thiết bị làm mát đối với không gian người dùng.
Một ứng dụng quản lý nhiệt thông minh có thể đưa ra quyết định dựa trên
đầu vào từ các thuộc tính vùng nhiệt (nhiệt độ hiện tại và điểm ngắt
nhiệt độ) và thiết bị điều tiết thích hợp.

- ZZ0000ZZ biểu thị mọi số dương bắt đầu từ 0
- ZZ0001ZZ biểu thị bất kỳ số dương nào bắt đầu từ 1

1. chức năng giao diện trình điều khiển sysfs nhiệt
===========================================

1.1 Giao diện thiết bị vùng nhiệt
---------------------------------

    ::

cấu trúc Thermal_zone_device *
	Thermal_zone_device_register_with_trips(const char *type,
					const struct Thermal_trip *chuyến đi,
					int num_trips, void *devdata,
					const struct Thermal_zone_device_ops *ops,
					const struct Thermal_zone_params *tzp,
					unsigned int thụ động_delay,
					bỏ phiếu int không dấu_delay)

Chức năng giao diện này bổ sung thêm một thiết bị vùng nhiệt (cảm biến) mới vào
    /sys/class/thermal thư mục dưới dạng ZZ0000ZZ. Nó cố gắng ràng buộc tất cả
    thiết bị làm mát nhiệt được đăng ký với nó cùng một lúc.

gõ:
	loại vùng nhiệt.
    chuyến đi:
	bảng các điểm dừng cho vùng nhiệt này.
    dữ liệu phát triển:
	dữ liệu riêng tư của thiết bị
    rất tiếc:
	cuộc gọi lại thiết bị vùng nhiệt.

.nên_bind:
		kiểm tra xem một thiết bị làm mát nhất định có nên bị ràng buộc với
		một điểm dừng nhất định trong vùng nhiệt này.
	.get_temp:
		lấy nhiệt độ hiện tại của vùng nhiệt.
	.set_trips:
		đặt cửa sổ điểm chuyến đi. Bất cứ khi nào nhiệt độ hiện tại
		được cập nhật, các điểm chuyến đi ngay bên dưới và bên trên
		nhiệt độ hiện tại được tìm thấy.
	.change_mode:
		thay đổi chế độ (bật/tắt) của vùng nhiệt.
	.set_trip_temp:
		đặt nhiệt độ của một điểm chuyến đi nhất định.
	.get_crit_temp:
		có được nhiệt độ tới hạn cho vùng nhiệt này.
	.set_emul_temp:
		đặt nhiệt độ mô phỏng giúp gỡ lỗi
		điểm nhiệt độ ngưỡng khác nhau.
	.get_trend:
		nhận được xu hướng thay đổi nhiệt độ khu vực gần đây nhất.
	.nóng:
		người xử lý điểm chuyến đi nóng.
	.quan trọng:
		người xử lý điểm chuyến đi quan trọng.
    tzp:
	thông số nền tảng vùng nhiệt.
    thụ động_delay:
	số mili giây chờ giữa các cuộc thăm dò khi thực hiện thụ động
	làm mát.
    bỏ phiếu_delay:
	số mili giây chờ giữa các cuộc thăm dò khi kiểm tra
	liệu các điểm ngắt đã bị vượt qua hay chưa (0 đối với các hệ thống điều khiển ngắt).

    ::

void Thermal_zone_device_unregister(struct Thermal_zone_device *tz)

Chức năng giao diện này loại bỏ thiết bị vùng nhiệt.
    Nó xóa mục tương ứng khỏi thư mục /sys/class/thermal và
    hủy liên kết tất cả các thiết bị làm mát nhiệt mà nó sử dụng.

	::

cấu trúc Thermal_zone_device
	   *thermal_zone_of_sensor_register(struct device *dev, int cảm biến_id,
				làm mất hiệu lực dữ liệu *,
				const struct Thermal_zone_of_device_ops *ops)

Giao diện này thêm một cảm biến mới vào vùng nhiệt DT.
	Chức năng này sẽ tìm kiếm danh sách các vùng nhiệt được mô tả trong
	cây thiết bị và tìm vùng đề cập đến thiết bị cảm biến
	được dev->of_node chỉ định là nhà cung cấp nhiệt độ. Đối với khu vực
	trỏ tới nút cảm biến, cảm biến sẽ được thêm vào DT
	thiết bị vùng nhiệt.

Các thông số cho giao diện này là:

nhà phát triển:
			Nút thiết bị của cảm biến chứa con trỏ nút hợp lệ trong
			dev->of_node.
	cảm biến_id:
			một mã định danh cảm biến, trong trường hợp IP cảm biến có nhiều hơn
			nhiều hơn một cảm biến
	dữ liệu:
			một con trỏ riêng (thuộc sở hữu của người gọi) sẽ
			được truyền trở lại khi cần đọc nhiệt độ.
	rất tiếc:
			ZZ0000ZZ.

==========================================================
			get_temp một con trỏ tới hàm đọc
					cảm biến nhiệt độ. Đây là điều bắt buộc
					gọi lại được cung cấp bởi trình điều khiển cảm biến.
			set_trips một con trỏ tới hàm đặt một
					cửa sổ nhiệt độ. Khi cửa sổ này được
					bên trái tài xế phải thông báo cho nhiệt
					lõi thông qua Thermal_zone_device_update.
			get_trend một con trỏ tới hàm đọc
					xu hướng nhiệt độ cảm biến.
			set_emul_temp một con trỏ tới hàm đặt
					cảm biến nhiệt độ mô phỏng.
			==========================================================

Nhiệt độ vùng nhiệt được cung cấp bởi hàm get_temp()
	con trỏ của Thermal_zone_of_device_ops. Khi được gọi, nó sẽ
	lấy lại con trỏ riêng @data.

Nó trả về con trỏ lỗi nếu không thành công, thiết bị vùng nhiệt hợp lệ
	xử lý. Người gọi nên kiểm tra tay cầm trả lại bằng IS_ERR() để tìm
	dù có thành công hay không.

	::

void Thermal_zone_of_sensor_unregister(thiết bị cấu trúc *dev,
						   cấu trúc Thermal_zone_device *tzd)

Giao diện này hủy đăng ký cảm biến khỏi vùng nhiệt DT đã được
	được thêm thành công bởi giao diện Thermal_zone_of_sensor_register().
	Chức năng này loại bỏ các lệnh gọi lại cảm biến và dữ liệu riêng tư khỏi
	thiết bị vùng nhiệt được đăng ký với Thermal_zone_of_sensor_register()
	giao diện. Nó cũng sẽ làm im lặng vùng bằng cách xóa .get_temp() và
	get_trend() gọi lại thiết bị vùng nhiệt.

	::

cấu trúc Thermal_zone_device
	  *devm_thermal_zone_of_sensor_register(struct device *dev,
				int cảm biến_id,
				làm mất hiệu lực dữ liệu *,
				const struct Thermal_zone_of_device_ops *ops)

Giao diện này là phiên bản quản lý tài nguyên của
	Thermal_zone_of_sensor_register().

Tất cả các chi tiết về Thermal_zone_of_sensor_register() được mô tả trong
	phần 1.1.3 được áp dụng ở đây.

Lợi ích của việc sử dụng giao diện này để đăng ký cảm biến là nó
	không cần phải gọi một cách rõ ràng Thermal_zone_of_sensor_unregister()
	trong đường dẫn lỗi hoặc trong quá trình hủy liên kết trình điều khiển vì việc này được thực hiện bởi trình điều khiển
	người quản lý tài nguyên.

	::

void devm_thermal_zone_of_sensor_unregister(thiết bị cấu trúc *dev,
						cấu trúc Thermal_zone_device *tzd)

Giao diện này là phiên bản quản lý tài nguyên của
	Thermal_zone_of_sensor_unregister().
	Tất cả các chi tiết về Thermal_zone_of_sensor_unregister() được mô tả trong
	phần 1.1.4 được áp dụng ở đây.
	Thông thường hàm này sẽ không cần phải gọi và tài nguyên
	mã quản lý sẽ đảm bảo rằng tài nguyên được giải phóng.

	::

int Thermal_zone_get_slope(struct Thermal_zone_device *tz)

Giao diện này được sử dụng để đọc giá trị thuộc tính độ dốc
	cho thiết bị vùng nhiệt, có thể hữu ích cho nền tảng
	trình điều khiển để tính toán nhiệt độ.

	::

int Thermal_zone_get_offset(struct Thermal_zone_device *tz)

Giao diện này được sử dụng để đọc giá trị thuộc tính offset
	cho thiết bị vùng nhiệt, có thể hữu ích cho nền tảng
	trình điều khiển để tính toán nhiệt độ.

1.2 giao diện thiết bị làm mát nhiệt
------------------------------------


    ::

cấu trúc Thermal_cooling_device
	*thermal_cooling_device_register(char *name,
			vô hiệu ZZ0001ZZ)

Chức năng giao diện này bổ sung thêm một thiết bị làm mát nhiệt mới (quạt/bộ xử lý/...)
    vào thư mục /sys/class/thermal/ dưới dạng ZZ0000ZZ. Nó cố gắng tự ràng buộc
    cho tất cả các thiết bị vùng nhiệt được đăng ký cùng một lúc.

tên:
	tên thiết bị làm mát
    dữ liệu phát triển:
	dữ liệu riêng tư của thiết bị.
    rất tiếc:
	cuộc gọi lại thiết bị làm mát nhiệt.

.get_max_state:
		có được trạng thái tiết lưu tối đa của thiết bị làm mát.
	.get_cur_state:
		có được trạng thái ga hiện được yêu cầu của
		thiết bị làm mát.
	.set_cur_state:
		đặt trạng thái ga hiện tại của thiết bị làm mát.

    ::

void Thermal_cooling_device_unregister(struct Thermal_cooling_device *cdev)

Chức năng giao diện này loại bỏ thiết bị làm mát bằng nhiệt.
    Nó xóa mục tương ứng khỏi thư mục /sys/class/thermal và
    tự hủy liên kết với tất cả các thiết bị vùng nhiệt sử dụng nó.

1.4 Thông số vùng nhiệt
---------------------------

    ::

cấu trúc nhiệt_zone_params

Cấu trúc này xác định các tham số cấp nền tảng cho vùng nhiệt.
    Dữ liệu này, đối với mỗi vùng nhiệt phải đến từ lớp nền tảng.
    Đây là một tính năng tùy chọn mà một số nền tảng có thể chọn không
    cung cấp dữ liệu này.

.governor_name:
	       Tên của bộ điều chỉnh nhiệt được sử dụng cho vùng này
    .no_hwmon:
	       một boolean để cho biết liệu giao diện nhiệt tới hwmon sysfs
	       được yêu cầu. khi no_hwmon == false, giao diện hwmon sysfs
	       sẽ được tạo ra. khi no_hwmon == true, sẽ không có gì được thực hiện.
	       Trong trường hợp Thermal_zone_params là NULL, giao diện hwmon
	       sẽ được tạo (để tương thích ngược).

2. Cấu trúc thuộc tính sysfs
=============================

===================
Giá trị chỉ đọc RO
WO chỉ ghi giá trị
Giá trị đọc/ghi RW
===================

Các thuộc tính sysfs nhiệt sẽ được biểu diễn dưới /sys/class/thermal.
Phần mở rộng I/F của Hwmon sysfs cũng có sẵn trong /sys/class/hwmon
nếu hwmon được biên dịch hoặc xây dựng dưới dạng mô-đun.

I/F hệ thống của thiết bị vùng nhiệt, được tạo sau khi được đăng ký::

/sys/class/thermal/thermal_zone[0-*]:
    |---type: Loại vùng nhiệt
    |---temp: Nhiệt độ hiện tại
    |---mode: Chế độ làm việc của vùng nhiệt
    |---chính sách: Bộ điều chỉnh nhiệt được sử dụng cho khu vực này
    |---available_policies: Bộ điều chỉnh nhiệt có sẵn cho vùng này
    |---trip_point_[0-*]_temp: Nhiệt độ điểm chuyến đi
    |---trip_point_[0-*]_type: Loại điểm chuyến đi
    |---trip_point_[0-*]_hyst: Giá trị trễ cho điểm ngắt này
    |---emul_temp: Nút đặt nhiệt độ mô phỏng
    |---stainable_power: Sức mạnh bền vững có thể tiêu tan
    |---k_po: Số hạng tỉ lệ khi nhiệt độ vượt quá
    |---k_pu: Số hạng tỉ lệ trong quá trình giảm nhiệt độ
    |---k_i: Số hạng tích phân của PID trong gov cấp nguồn
    |---k_d: Thuật ngữ đạo hàm của PID trong bộ cấp nguồn
    |---integral_cutoff: Phần bù trên các lỗi được tích lũy
    |---độ dốc: Hằng số độ dốc được áp dụng dưới dạng ngoại suy tuyến tính
    |---offset: Hằng số offset được áp dụng dưới dạng ngoại suy tuyến tính

Hệ thống I/F của thiết bị làm mát bằng nhiệt, được tạo sau khi được đăng ký::

/sys/class/thermal/cooling_device[0-*]:
    |---type: Loại thiết bị làm mát(bộ xử lý/quạt/...)
    |---max_state: Trạng thái làm mát tối đa của thiết bị làm mát
    |---cur_state: Trạng thái làm mát hiện tại của thiết bị làm mát
    |---stats: Thư mục chứa số liệu thống kê của thiết bị làm mát
    |---số liệu thống kê/đặt lại: Viết bất kỳ giá trị nào sẽ đặt lại số liệu thống kê
    |---stats/time_in_state_ms: Thời gian (msec) ở các trạng thái làm mát khác nhau
    |---stats/total_trans: Tổng số lần thay đổi trạng thái làm mát
    |---stats/trans_table: Bảng chuyển đổi trạng thái làm mát


Sau đó, hai thuộc tính động tiếp theo sẽ được tạo/xóa theo cặp. Họ đại diện
mối quan hệ giữa vùng nhiệt và thiết bị làm mát liên quan của nó.

::

/sys/class/thermal/thermal_zone[0-*]:
    |---cdev[0-ZZ0000ZZ]thiết bị làm mát thứ trong vùng nhiệt hiện tại
    |---cdev[0-ZZ0001ZZ] được liên kết với
    |---cdev[0-*]_weight: Ảnh hưởng của thiết bị làm mát trong
				vùng nhiệt này

Bên cạnh I/F hệ thống thiết bị vùng nhiệt và I/F hệ thống thiết bị làm mát,
trình điều khiển nhiệt chung cũng tạo I/F hwmon sysfs cho mỗi _type_
của thiết bị vùng nhiệt. Ví dụ. trình điều khiển nhiệt chung đăng ký một hwmon
thiết bị lớp và xây dựng I/F hwmon sysfs liên quan cho tất cả các thiết bị đã đăng ký
Vùng nhiệt ACPI.

Vui lòng đọc Tài liệu/ABI/testing/sysfs-class-thermal cho nhiệt
chi tiết thuộc tính vùng và thiết bị làm mát.

::

/sys/class/hwmon/hwmon[0-*]:
    |---tên: Loại thiết bị vùng nhiệt
    |---nhiệt độ[1-ZZ0000ZZ]
    |---nhiệt độ[1-ZZ0001ZZ]

Vui lòng đọc Tài liệu/hwmon/sysfs-interface.rst để biết thêm thông tin.

3. Cách thực hiện đơn giản
==========================

Vùng nhiệt ACPI có thể hỗ trợ nhiều điểm ngắt như quan trọng, nóng,
thụ động, chủ động. Nếu vùng nhiệt ACPI hỗ trợ quan trọng, thụ động,
active[0] và active[1] cùng lúc, nó có thể tự đăng ký dưới dạng
Thermal_zone_device (thermal_zone1) có tất cả 4 điểm dừng.
Nó có một bộ xử lý và một quạt, cả hai đều được đăng ký là
thiết bị làm mát_nhiệt. Cả hai đều được coi là có cùng
hiệu quả làm mát vùng nhiệt.

Nếu bộ xử lý được liệt kê trong phương pháp _PSL và quạt được liệt kê trong _AL0
phương thức, cấu trúc I/F sys sẽ được xây dựng như thế này::

/sys/class/nhiệt:
  |thermal_zone1:
    |---loại: acpitz
    |---nhiệt độ: 37000
    |---chế độ: đã bật
    |---chính sách: step_wise
    |---available_policies: step_wise fair_share
    |---trip_point_0_temp: 100000
    |---trip_point_0_type: quan trọng
    |---trip_point_1_temp: 80000
    |---trip_point_1_type: bị động
    |---trip_point_2_temp: 70000
    |---trip_point_2_type: hoạt động0
    |---trip_point_3_temp: 60000
    |---trip_point_3_type: hoạt động1
    |---cdev0: --->/sys/class/thermal/cooling_device0
    |---cdev0_trip_point: 1 /* cdev0 có thể được sử dụng cho thụ động */
    |---cdev0_weight: 1024
    |---cdev1: --->/sys/class/thermal/cooling_device3
    |---cdev1_trip_point: 2 /* cdev1 có thể được sử dụng cho hoạt động[0]*/
    |---cdev1_weight: 1024

|thiết bị làm mát0:
    |---loại: Bộ xử lý
    |---trạng thái tối đa: 8
    |---cur_state: 0

|làm mát_device3:
    |---loại: Quạt
    |---trạng thái tối đa: 2
    |---cur_state: 0

/sys/class/hwmon:
  |hwmon0:
    |---tên: acpitz
    |---temp1_input: 37000
    |---temp1_crit: 100000

4. Xuất API biểu tượng
=====================

4.1. get_tz_xu hướng
-----------------

Hàm này trả về xu hướng của vùng nhiệt, tức là tốc độ thay đổi
nhiệt độ của vùng nhiệt. Lý tưởng nhất là trình điều khiển cảm biến nhiệt
có nhiệm vụ thực hiện cuộc gọi lại. Nếu không, nhiệt
framework đã tính toán xu hướng bằng cách so sánh trước đó và hiện tại
các giá trị nhiệt độ.

4.2. nhiệt_cdev_update
------------------------

Chức năng này đóng vai trò như một trọng tài để thiết lập trạng thái làm mát
thiết bị. Nó đặt thiết bị làm mát về trạng thái làm mát sâu nhất nếu
có thể.

5. Sự kiện quan trọng
==================

Trong trường hợp vượt qua nhiệt độ chuyến đi quan trọng, khung nhiệt
sẽ kích hoạt tắt nguồn bảo vệ phần cứng (tắt máy) hoặc khởi động lại,
tùy thuộc vào cấu hình.

Lúc đầu, kernel sẽ thử tắt nguồn hoặc khởi động lại theo thứ tự, nhưng
chấp nhận độ trễ sau đó nó tiến hành tắt nguồn cưỡng bức hoặc
khởi động lại tương ứng. Nếu điều này không thành công, ZZ0000ZZ sẽ được gọi
như là phương sách cuối cùng.

Sự chậm trễ phải được lập hồ sơ cẩn thận để có đủ thời gian cho việc
tắt nguồn hoặc khởi động lại theo thứ tự.

Nếu độ trễ được đặt thành 0 thì hành động khẩn cấp sẽ không được hỗ trợ. Vì vậy, một
giá trị dương khác 0 được định hình cẩn thận là điều bắt buộc trong trường hợp khẩn cấp
hành động cần được kích hoạt.
