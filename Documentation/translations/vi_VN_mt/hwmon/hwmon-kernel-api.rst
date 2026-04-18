.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/hwmon-kernel-api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Hạt nhân giám sát phần cứng Linux API
========================================

Guenter Roeck

Giới thiệu
------------

Tài liệu này mô tả API có thể được sử dụng để giám sát phần cứng
trình điều khiển muốn sử dụng khung giám sát phần cứng.

Tài liệu này không mô tả Trình điều khiển hoặc Trình điều khiển giám sát phần cứng (hwmon) là gì
Thiết bị là. Nó cũng không mô tả API có thể được sử dụng bởi không gian người dùng
để giao tiếp với một thiết bị giám sát phần cứng. Nếu bạn muốn biết điều này
thì vui lòng đọc tệp sau: Documentation/hwmon/sysfs-interface.rst.

Để có thêm hướng dẫn về cách viết và cải thiện trình điều khiển hwmon, vui lòng
đồng thời đọc Tài liệu/hwmon/submit-patches.rst.

API
-------
Mỗi trình điều khiển giám sát phần cứng phải có #include <linux/hwmon.h> và, trong một số
trường hợp, <linux/hwmon-sysfs.h>. linux/hwmon.h tuyên bố như sau
chức năng đăng ký/hủy đăng ký::

thiết bị cấu trúc *
  hwmon_device_register_with_info(thiết bị cấu trúc *dev,
				  const char *name, void *drvdata,
				  const struct hwmon_chip_info *thông tin,
				  const struct attribute_group **extra_groups);

thiết bị cấu trúc *
  devm_hwmon_device_register_with_info(thiết bị cấu trúc *dev,
				       const char * tên,
				       vô hiệu * drvdata,
				       const struct hwmon_chip_info *thông tin,
				       const struct attribute_group **extra_groups);

void hwmon_device_unregister(struct device *dev);

char *hwmon_sanitize_name(const char *name);

char *devm_hwmon_sanitize_name(struct device *dev, const char *name);

void hwmon_lock(struct device *dev);
  void hwmon_unlock(struct device *dev);

hwmon_device_register_with_info đăng ký một thiết bị giám sát phần cứng.
Nó tạo ra các thuộc tính sysfs tiêu chuẩn trong lõi giám sát phần cứng,
thay vào đó hãy để trình điều khiển tập trung vào việc đọc và ghi vào chip
phải bận tâm với các thuộc tính sysfs. Tham số thiết bị gốc
cũng như thông số chip không được là NULL. Các thông số của nó được mô tả
chi tiết hơn dưới đây.

devm_hwmon_device_register_with_info tương tự như
hwmon_device_register_with_info. Tuy nhiên, nó được quản lý bởi thiết bị, có nghĩa là
thiết bị hwmon không cần phải được loại bỏ một cách rõ ràng bằng chức năng loại bỏ.

Tất cả các chức năng đăng ký thiết bị giám sát phần cứng khác đều không được dùng nữa
và không được sử dụng trong trình điều khiển mới.

hwmon_device_unregister hủy đăng ký thiết bị giám sát phần cứng đã đăng ký.
Tham số của hàm này là con trỏ tới phần cứng đã đăng ký
Cấu trúc thiết bị giám sát. Chức năng này phải được gọi từ trình điều khiển
xóa chức năng nếu thiết bị giám sát phần cứng đã được đăng ký với
hwmon_device_register_with_info.

Tất cả các chức năng đăng ký thiết bị hwmon được hỗ trợ chỉ chấp nhận thiết bị hợp lệ
những cái tên. Tên thiết bị bao gồm các ký tự không hợp lệ (khoảng trắng, '*' hoặc '-')
sẽ bị từ chối. Nếu NULL được truyền dưới dạng tham số tên, giám sát phần cứng
tên thiết bị sẽ được lấy từ tên thiết bị mẹ.

Nếu trình điều khiển không sử dụng tên thiết bị tĩnh (ví dụ: nó sử dụng
dev_name()), và do đó không thể đảm bảo tên chỉ chứa hợp lệ
ký tự, hwmon_sanitize_name có thể được sử dụng. Chức năng tiện lợi này
sẽ nhân đôi chuỗi và thay thế bất kỳ ký tự không hợp lệ nào bằng một
gạch dưới. Nó sẽ phân bổ bộ nhớ cho chuỗi mới và đó là
trách nhiệm của người gọi là giải phóng bộ nhớ khi thiết bị
bị loại bỏ.

devm_hwmon_sanitize_name là phiên bản được quản lý tài nguyên của
hwmon_sanitize_name; bộ nhớ sẽ tự động được giải phóng trên thiết bị
loại bỏ.

Khi sử dụng ZZ0000ZZ để đăng ký
thiết bị giám sát phần cứng, truy cập bằng các chức năng truy cập liên quan
được tuần tự hóa bởi lõi giám sát phần cứng. Nếu người lái xe cần khóa
cho các chức năng khác như bộ xử lý ngắt hoặc cho các thuộc tính
được triển khai đầy đủ trong trình điều khiển, có thể sử dụng hwmon_lock() và hwmon_unlock()
để đảm bảo rằng các cuộc gọi đến các chức năng đó được tuần tự hóa.

Sử dụng devm_hwmon_device_register_with_info()
----------------------------------------------

hwmon_device_register_with_info() đăng ký một thiết bị giám sát phần cứng.
Các tham số của hàm này là

========================================================================================================
ZZ0000ZZ Con trỏ tới thiết bị mẹ
ZZ0001ZZ Tên thiết bị
Dữ liệu riêng tư của trình điều khiển ZZ0002ZZ
ZZ0003ZZ Con trỏ tới mô tả chip.
ZZ0004ZZ Danh sách phi tiêu chuẩn bổ sung không được chấm dứt
						nhóm thuộc tính sysfs.
========================================================================================================

Hàm này trả về một con trỏ tới thiết bị giám sát phần cứng đã tạo
về thành công và mã lỗi âm cho thất bại.

Cấu trúc hwmon_chip_info trông như sau::

cấu trúc hwmon_chip_info {
		const struct hwmon_ops *ops;
		const struct hwmon_channel_info * const *info;
	};

Nó chứa các trường sau:

*Ôi:
	Con trỏ tới hoạt động của thiết bị.
* thông tin:
	Danh sách mô tả kênh thiết bị đã kết thúc NULL.

Danh sách các hoạt động hwmon được định nghĩa là::

cấu trúc hwmon_ops {
	umode_t (ZZ0000ZZ, loại enum hwmon_sensor_types,
			      u32 attr, int);
	int (ZZ0001ZZ, loại enum hwmon_sensor_types,
		    u32 attr, int, dài *);
	int (ZZ0002ZZ, loại enum hwmon_sensor_types,
		     u32 attr, int, dài);
  };

Nó xác định các hoạt động sau đây.

* is_visible:
    Con trỏ tới một hàm để trả về chế độ tệp cho từng được hỗ trợ
    thuộc tính. Chức năng này là bắt buộc.

* đọc:
    Con trỏ tới hàm đọc giá trị từ chip. Chức năng này
    là tùy chọn, nhưng phải được cung cấp nếu có bất kỳ thuộc tính có thể đọc được nào.

* viết:
    Con trỏ tới hàm để ghi giá trị vào chip. Chức năng này là
    tùy chọn, nhưng phải được cung cấp nếu có bất kỳ thuộc tính có thể ghi nào tồn tại.

Mỗi kênh cảm biến được mô tả bằng cấu trúc hwmon_channel_info, đó là
được xác định như sau::

cấu trúc hwmon_channel_info {
		loại enum hwmon_sensor_types;
		u32 *cấu hình;
	};

Nó chứa các trường sau:

* gõ:
    Loại cảm biến giám sát phần cứng.

Các loại cảm biến được hỗ trợ là

=========================================================================
     hwmon_chip Một loại cảm biến ảo, dùng để mô tả các thuộc tính
			không bị ràng buộc với một đầu vào hoặc đầu ra cụ thể
     hwmon_temp Cảm biến nhiệt độ
     hwmon_in Cảm biến điện áp
     hwmon_curr Cảm biến hiện tại
     hwmon_power Cảm biến nguồn
     hwmon_energy Cảm biến năng lượng
     hwmon_energy64 Cảm biến năng lượng, được báo cáo là giá trị có dấu 64-bit
     hwmon_humidity Cảm biến độ ẩm
     hwmon_fan Cảm biến tốc độ quạt
     điều khiển hwmon_pwm PWM
     =========================================================================

*cấu hình:
    Con trỏ tới danh sách các giá trị cấu hình kết thúc bằng 0 cho mỗi
    loại cảm biến đã cho. Mỗi giá trị là sự kết hợp của các giá trị bit
    mô tả các thuộc tính được cho là của một cảm biến duy nhất.

Ví dụ: đây là tệp mô tả đầy đủ cho thiết bị tương thích LM75
chíp cảm biến. Con chip này có một cảm biến nhiệt độ duy nhất. Người lái xe muốn
đăng ký với hệ thống con nhiệt (HWMON_C_REGISTER_TZ) và nó hỗ trợ
thuộc tính update_interval (HWMON_C_UPDATE_INTERVAL). Chip hỗ trợ
đọc nhiệt độ (HWMON_T_INPUT), nó có nhiệt độ tối đa
thanh ghi (HWMON_T_MAX) cũng như thanh ghi trễ nhiệt độ tối đa
(HWMON_T_MAX_HYST)::

const tĩnh u32 lm75_chip_config[] = {
		HWMON_C_REGISTER_TZ | HWMON_C_UPDATE_INTERVAL,
		0
	};

cấu trúc const tĩnh hwmon_channel_info lm75_chip = {
		.type = hwmon_chip,
		.config = lm75_chip_config,
	};

const tĩnh u32 lm75_temp_config[] = {
		HWMON_T_INPUT ZZ0000ZZ HWMON_T_MAX_HYST,
		0
	};

cấu trúc const tĩnh hwmon_channel_info lm75_temp = {
		.type = hwmon_temp,
		.config = lm75_temp_config,
	};

cấu trúc const tĩnh hwmon_channel_info * const lm75_info[] = {
		&lm75_chip,
		&lm75_temp,
		NULL
	};

Macro HWMON_CHANNEL_INFO() có thể và nên được sử dụng khi có thể.
	Với macro này, ví dụ trên có thể được đơn giản hóa thành

cấu trúc const tĩnh hwmon_channel_info * const lm75_info[] = {
		HWMON_CHANNEL_INFO(chip,
				HWMON_C_REGISTER_TZ | HWMON_C_UPDATE_INTERVAL),
		HWMON_CHANNEL_INFO(nhiệt độ,
				HWMON_T_INPUT ZZ0000ZZ HWMON_T_MAX_HYST),
		NULL
	};

Các khai báo còn lại như sau.

cấu trúc const tĩnh hwmon_ops lm75_hwmon_ops = {
		.is_visible = lm75_is_visible,
		.read = lm75_read,
		.write = lm75_write,
	};

cấu trúc const tĩnh hwmon_chip_info lm75_chip_info = {
		.ops = &lm75_hwmon_ops,
		.info = lm75_info,
	};

Danh sách đầy đủ các giá trị bit cho biết hỗ trợ thuộc tính riêng lẻ
được định nghĩa trong include/linux/hwmon.h. Tiền tố định nghĩa như sau.

======================================================================
HWMON_C_xxxx Thuộc tính chip, để sử dụng với hwmon_chip.
HWMON_T_xxxx Thuộc tính nhiệt độ, để sử dụng với hwmon_temp.
HWMON_I_xxxx Thuộc tính điện áp, để sử dụng với hwmon_in.
HWMON_C_xxxx Thuộc tính hiện tại, để sử dụng với hwmon_curr.
		Lưu ý sự trùng lặp tiền tố với thuộc tính chip.
HWMON_P_xxxx Thuộc tính sức mạnh, để sử dụng với hwmon_power.
HWMON_E_xxxx Thuộc tính năng lượng, để sử dụng với hwmon_energy.
HWMON_H_xxxx Thuộc tính độ ẩm, để sử dụng với hwmon_humidity.
HWMON_F_xxxx Thuộc tính tốc độ quạt, để sử dụng với hwmon_fan.
Thuộc tính điều khiển HWMON_PWM_xxxx PWM, để sử dụng với hwmon_pwm.
======================================================================

Chức năng gọi lại trình điều khiển
----------------------------------

Mỗi trình điều khiển cung cấp các chức năng is_visible, đọc và ghi. Thông số
và giá trị trả về cho các hàm đó như sau::

umode_t is_visible_func(const void *data, enum hwmon_sensor_types,
			  u32 attr, kênh int)

Thông số:
	dữ liệu:
		Con trỏ tới cấu trúc dữ liệu riêng tư của thiết bị.
	gõ:
		Loại cảm biến.
	chú thích:
		Mã định danh thuộc tính được liên kết với một thuộc tính cụ thể.
		Ví dụ: giá trị thuộc tính cho HWMON_T_INPUT sẽ là
		hwmon_temp_input. Để ánh xạ hoàn chỉnh các trường bit tới
		giá trị thuộc tính vui lòng xem include/linux/hwmon.h.
	kênh:
		Số kênh cảm biến

Giá trị trả về:
	Chế độ tập tin cho thuộc tính này. Thông thường, giá trị này sẽ là 0 (
	thuộc tính sẽ không được tạo), 0444 hoặc 0644.

::

int read_func(struct device *dev, enum hwmon_sensor_types type,
		      u32 attr, kênh int, dài *val)

Thông số:
	nhà phát triển:
		Con trỏ tới thiết bị giám sát phần cứng.
	gõ:
		Loại cảm biến.
	chú thích:
		Mã định danh thuộc tính được liên kết với một thuộc tính cụ thể.
		Ví dụ: giá trị thuộc tính cho HWMON_T_INPUT sẽ là
		hwmon_temp_input. Để có bản đồ hoàn chỉnh, vui lòng xem
		bao gồm/linux/hwmon.h.
	kênh:
		Số kênh cảm biến
	giá trị:
		Con trỏ tới giá trị thuộc tính.
		Đối với hwmon_energy64, ZZ0000ZZ' được chuyển là ZZ0001ZZ nhưng cần
		một kiểu chữ tới ZZ0002ZZ.

Giá trị trả về:
	0 nếu thành công, ngược lại là số lỗi âm.

::

int write_func(struct device *dev, enum hwmon_sensor_types type,
		       u32 attr, kênh int, giá trị dài)

Thông số:
	nhà phát triển:
		Con trỏ tới thiết bị giám sát phần cứng.
	gõ:
		Loại cảm biến.
	chú thích:
		Mã định danh thuộc tính được liên kết với một thuộc tính cụ thể.
		Ví dụ: giá trị thuộc tính cho HWMON_T_INPUT sẽ là
		hwmon_temp_input. Để có bản đồ hoàn chỉnh, vui lòng xem
		bao gồm/linux/hwmon.h.
	kênh:
		Số kênh cảm biến
	giá trị:
		Giá trị để ghi vào chip.

Giá trị trả về:
	0 nếu thành công, ngược lại là số lỗi âm.


Thuộc tính sysfs do trình điều khiển cung cấp
---------------------------------------------

Trong hầu hết các trường hợp, trình điều khiển không cần thiết phải cung cấp sysfs
các thuộc tính do lõi giám sát phần cứng tạo ra các thuộc tính đó trong nội bộ.
Chỉ cần cung cấp thêm các thuộc tính sysfs không chuẩn.

Tệp tiêu đề linux/hwmon-sysfs.h cung cấp một số macro hữu ích để
khai báo và sử dụng các thuộc tính sysfs giám sát phần cứng.

Trong nhiều trường hợp, bạn có thể sử dụng định nghĩa DEVICE_ATTR hiện có hoặc các biến thể của nó
DEVICE_ATTR_{RW,RO,WO} để khai báo các thuộc tính đó. Điều này khả thi nếu một
thuộc tính không có ngữ cảnh bổ sung. Tuy nhiên, trong nhiều trường hợp sẽ có
thông tin bổ sung như chỉ số cảm biến sẽ cần được chuyển qua
đến chức năng xử lý thuộc tính sysfs.

SENSOR_DEVICE_ATTR và SENSOR_DEVICE_ATTR_2 có thể được sử dụng để xác định thuộc tính
cần thông tin ngữ cảnh bổ sung như vậy. SENSOR_DEVICE_ATTR yêu cầu
một đối số bổ sung, SENSOR_DEVICE_ATTR_2 yêu cầu hai đối số.

Có sẵn các biến thể đơn giản hóa của SENSOR_DEVICE_ATTR và SENSOR_DEVICE_ATTR_2
và nên được sử dụng nếu các quyền thuộc tính tiêu chuẩn và tên hàm được
khả thi. Quyền tiêu chuẩn là 0644 cho SENSOR_DEVICE_ATTR[_2]_RW,
0444 cho SENSOR_DEVICE_ATTR[_2]_RO và 0200 cho SENSOR_DEVICE_ATTR[_2]_WO.
Các hàm tiêu chuẩn, tương tự như DEVICE_ATTR_{RW,RO,WO}, có _show và _store
được thêm vào tên hàm được cung cấp.

SENSOR_DEVICE_ATTR và các biến thể của nó xác định cấu trúc cảm biến_device_attribute
biến. Cấu trúc này có các trường sau::

cấu trúc cảm biến_device_attribute {
		cấu trúc device_attribute dev_attr;
		chỉ số int;
	};

Bạn có thể sử dụng to_sensor_dev_attr để lấy con trỏ tới cấu trúc này từ
chức năng đọc hoặc ghi thuộc tính. Tham số của nó là thiết bị mà
thuộc tính được đính kèm.

SENSOR_DEVICE_ATTR_2 và các biến thể của nó xác định cấu trúc cảm biến_device_attribute_2
biến, được định nghĩa như sau::

cấu trúc cảm biến_device_attribute_2 {
		cấu trúc device_attribute dev_attr;
		chỉ số u8;
		u8 nr;
	};

Sử dụng to_sensor_dev_attr_2 để đưa con trỏ tới cấu trúc này. Tham số của nó
là thiết bị mà thuộc tính được gắn vào.
