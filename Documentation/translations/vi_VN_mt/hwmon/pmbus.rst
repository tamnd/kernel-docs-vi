.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/pmbus.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân pmbus
===============================

Chip được hỗ trợ:

* Linh hoạt BMR310, BMR453, BMR454, BMR456, BMR457, BMR458, BMR480,
    BMR490, BMR491, BMR492

Tiền tố: 'bmr310', 'bmr453', 'bmr454', 'bmr456', 'bmr457', 'bmr458', 'bmr480',
    'bmr490', 'bmr491', 'bmr492'

Địa chỉ được quét: -

Bảng dữ liệu:

ZZ0000ZZ


* TRÊN Chất bán dẫn ADP4000, NCP4200, NCP4208

Tiền tố: 'adp4000', 'ncp4200', 'ncp4208'

Địa chỉ được quét: -

Bảng dữ liệu:

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

* Sức mạnh dòng dõi

Tiền tố: 'mdt040', 'pdt003', 'pdt006', 'pdt012', 'udt020'

Địa chỉ được quét: -

Bảng dữ liệu:

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

* Dụng cụ Texas TPS40400, TPS544B20, TPS544B25, TPS544C20, TPS544C25

Tiền tố: 'tps40400', 'tps544b20', 'tps544b25', 'tps544c20', 'tps544c25'

Địa chỉ được quét: -

Bảng dữ liệu:

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

* Tối đa MAX20796

Tiền tố: 'max20796'

Địa chỉ được quét: -

Bảng dữ liệu:

ZZ0000ZZ

* Thiết bị PMBus chung

Tiền tố: 'pmbus'

Địa chỉ được quét: -

Bảng dữ liệu: n.a.


Tác giả: Guenter Roeck <linux@roeck-us.net>


Sự miêu tả
-----------

Trình điều khiển này hỗ trợ giám sát phần cứng cho các thiết bị tương thích PMBus khác nhau.
Nó hỗ trợ các cảm biến điện áp, dòng điện, nguồn và nhiệt độ được hỗ trợ
bởi thiết bị.

Mỗi kênh được giám sát đều có giới hạn cao và thấp riêng, cộng với mức tới hạn
giới hạn.

Hỗ trợ người hâm mộ sẽ được thêm vào trong phiên bản sau của trình điều khiển này.


Ghi chú sử dụng
---------------

Trình điều khiển này không thăm dò các thiết bị PMBus vì không có đăng ký
có thể được sử dụng một cách an toàn để nhận dạng chip (Thanh ghi MFG_ID không
được hỗ trợ bởi tất cả các chip) và vì không có dải địa chỉ được xác định rõ ràng cho
Thiết bị PMBus. Bạn sẽ phải khởi tạo các thiết bị một cách rõ ràng.

Ví dụ: phần sau sẽ tải trình điều khiển cho LTC2978 tại địa chỉ 0x60
trên xe buýt I2C #1::

$ modprobe pmbus
	$ echo ltc2978 0x60 > /sys/bus/i2c/devices/i2c-1/new_device


Hỗ trợ dữ liệu nền tảng
-----------------------

Có thể thêm hỗ trợ cho các chip PMBus bổ sung bằng cách xác định các tham số chip trong
một tập tin trình điều khiển cụ thể của chip mới. Ví dụ: mã (chưa được kiểm tra) để thêm hỗ trợ cho
Các mô-đun nguồn Emerson DS1200 có thể trông như sau::

cấu trúc tĩnh pmbus_driver_info ds1200_info = {
	.trang = 1,
	/* Lưu ý: Tất cả các cảm biến khác đều ở chế độ tuyến tính */
	.direct[PSC_VOLTAGE_OUT] = đúng,
	.direct[PSC_TEMPERATURE] = đúng,
	.direct[PSC_CURRENT_OUT] = đúng,
	.m[PSC_VOLTAGE_IN] = 1,
	.b[PSC_VOLTAGE_IN] = 0,
	.R[PSC_VOLTAGE_IN] = 3,
	.m[PSC_VOLTAGE_OUT] = 1,
	.b[PSC_VOLTAGE_OUT] = 0,
	.R[PSC_VOLTAGE_OUT] = 3,
	.m[PSC_TEMPERATURE] = 1,
	.b[PSC_TEMPERATURE] = 0,
	.R[PSC_TEMPERATURE] = 3,
	.func[0] = PMBUS_HAVE_VIN ZZ0000ZZ PMBUS_HAVE_STATUS_INPUT
		   ZZ0001ZZ PMBUS_HAVE_STATUS_VOUT
		   ZZ0002ZZ PMBUS_HAVE_STATUS_IOUT
		   ZZ0003ZZ PMBUS_HAVE_POUT
		   ZZ0004ZZ PMBUS_HAVE_STATUS_TEMP
		   ZZ0005ZZ PMBUS_HAVE_STATUS_FAN12,
  };

int tĩnh ds1200_probe(struct i2c_client *client)
  {
	trả về pmbus_do_probe(client, &ds1200_info);
  }

cấu trúc const tĩnh i2c_device_id ds1200_id[] = {
	{"ds1200"},
	{}
  };

MODULE_DEVICE_TABLE(i2c, ds1200_id);

/* Đây là trình điều khiển sẽ được chèn vào */
  cấu trúc tĩnh i2c_driver ds1200_driver = {
	.driver = {
		   .name="ds1200",
		   },
	.probe = ds1200_probe,
	.id_table = ds1200_id,
  };

int tĩnh __init ds1200_init(void)
  {
	trả về i2c_add_driver(&ds1200_driver);
  }

khoảng trống tĩnh __exit ds1200_exit(void)
  {
	i2c_del_driver(&ds1200_driver);
  }


Mục nhập hệ thống
-----------------

Khi thăm dò chip, trình điều khiển sẽ xác định các thanh ghi PMBus nào
được hỗ trợ và xác định các cảm biến có sẵn từ thông tin này.
Các tệp thuộc tính chỉ tồn tại nếu các cảm biến tương ứng được chip hỗ trợ.
Nhãn được cung cấp để thông báo cho người dùng về cảm biến liên quan đến
một mục sysfs nhất định.

Các thuộc tính sau được hỗ trợ. Giới hạn là đọc-ghi; tất cả những thứ khác
thuộc tính chỉ đọc.

=====================================================================================
inX_input Đo điện áp. Từ đăng ký READ_VIN hoặc READ_VOUT.
inX_min Điện áp tối thiểu.
			Từ đăng ký VIN_UV_WARN_LIMIT hoặc VOUT_UV_WARN_LIMIT.
inX_max Điện áp tối đa.
			Từ đăng ký VIN_OV_WARN_LIMIT hoặc VOUT_OV_WARN_LIMIT.
inX_lcrit Điện áp tối thiểu tới hạn.
			Từ đăng ký VIN_UV_FAULT_LIMIT hoặc VOUT_UV_FAULT_LIMIT.
inX_crit Điện áp tối đa tới hạn.
			Từ đăng ký VIN_OV_FAULT_LIMIT hoặc VOUT_OV_FAULT_LIMIT.
inX_min_alarm Báo động điện áp thấp. Từ trạng thái VOLTAGE_UV_WARNING.
inX_max_alarm Báo động điện áp cao. Từ trạng thái VOLTAGE_OV_WARNING.
inX_lcrit_alarm Báo động điện áp thấp tới mức nghiêm trọng.
			Từ trạng thái VOLTAGE_UV_FAULT.
inX_crit_alarm Báo động điện áp tới hạn cao.
			Từ trạng thái VOLTAGE_OV_FAULT.
inX_label "vin", "vcap" hoặc "voutY"
inX_rated_min Điện áp định mức tối thiểu.
			Từ đăng ký MFR_VIN_MIN hoặc MFR_VOUT_MIN.
inX_rated_max Điện áp định mức tối đa.
			Từ đăng ký MFR_VIN_MAX hoặc MFR_VOUT_MAX.

currX_input Đo dòng điện. Từ đăng ký READ_IIN hoặc READ_IOUT.
currX_max Dòng điện tối đa.
			Từ đăng ký IIN_OC_WARN_LIMIT hoặc IOUT_OC_WARN_LIMIT.
currX_lcrit Dòng điện đầu ra tối thiểu tới hạn.
			Từ đăng ký IOUT_UC_FAULT_LIMIT.
currX_crit Dòng tối đa tới hạn.
			Từ đăng ký IIN_OC_FAULT_LIMIT hoặc IOUT_OC_FAULT_LIMIT.
currX_alarm Báo động cao hiện tại.
			Từ trạng thái IIN_OC_WARNING hoặc IOUT_OC_WARNING.
currX_max_alarm Báo động cao hiện tại.
			Từ trạng thái IIN_OC_WARN_LIMIT hoặc IOUT_OC_WARN_LIMIT.
currX_lcrit_alarm Xuất cảnh báo hiện tại ở mức thấp tới hạn.
			Từ trạng thái IOUT_UC_FAULT.
currX_crit_alarm Báo động nghiêm trọng hiện tại ở mức cao.
			Từ trạng thái IIN_OC_FAULT hoặc IOUT_OC_FAULT.
currX_label "iin", "iinY", "iinY.Z", "ioutY" hoặc "ioutY.Z",
			trong đó Y phản ánh số trang và Z phản ánh
			giai đoạn.
currX_rated_max Dòng điện định mức tối đa.
			Từ đăng ký MFR_IIN_MAX hoặc MFR_IOUT_MAX.

powerX_input Đo công suất. Từ đăng ký READ_PIN hoặc READ_POUT.
powerX_cap Nắp nguồn đầu ra. Từ đăng ký POUT_MAX.
powerX_max Giới hạn công suất. Từ PIN_OP_WARN_LIMIT hoặc
			Đăng ký POUT_OP_WARN_LIMIT.
powerX_crit Giới hạn công suất đầu ra quan trọng.
			Từ đăng ký POUT_OP_FAULT_LIMIT.
powerX_alarm Báo động nguồn cao.
			Từ trạng thái PIN_OP_WARNING hoặc POUT_OP_WARNING.
powerX_crit_alarm Báo động nghiêm trọng về nguồn điện đầu ra.
			Từ trạng thái POUT_OP_FAULT.
powerX_label "pin", "pinY", "pinY.Z", "bĩu môi" hoặc "bĩu môiY.Z",
			trong đó Y phản ánh số trang và Z phản ánh
			giai đoạn.
powerX_rated_max Công suất định mức tối đa.
			Từ đăng ký MFR_PIN_MAX hoặc MFR_POUT_MAX.

tempX_input Đo nhiệt độ.
			Từ đăng ký READ_TEMPERATURE_X.
tempX_min Nhiệt độ tối thiểu. Từ đăng ký UT_WARN_LIMIT.
tempX_max Nhiệt độ tối đa. Từ đăng ký OT_WARN_LIMIT.
tempX_lcrit Nhiệt độ thấp tới hạn.
			Từ đăng ký UT_FAULT_LIMIT.
tempX_crit Nhiệt độ cao tới hạn.
			Từ đăng ký OT_FAULT_LIMIT.
tempX_min_alarm Báo động nhiệt độ chip thấp. Đặt bằng cách so sánh
			READ_TEMPERATURE_X với UT_WARN_LIMIT nếu
			Trạng thái TEMP_UT_WARNING được đặt.
tempX_max_alarm Báo động nhiệt độ chip cao. Đặt bằng cách so sánh
			READ_TEMPERATURE_X với OT_WARN_LIMIT nếu
			Trạng thái TEMP_OT_WARNING được đặt.
tempX_lcrit_alarm Báo động nhiệt độ chip ở mức thấp tới hạn. Đặt bằng cách so sánh
			READ_TEMPERATURE_X với UT_FAULT_LIMIT nếu
			Trạng thái TEMP_UT_FAULT được đặt.
tempX_crit_alarm Báo động nhiệt độ chip tới hạn cao. Đặt bằng cách so sánh
			READ_TEMPERATURE_X với OT_FAULT_LIMIT nếu
			Trạng thái TEMP_OT_FAULT được đặt.
tempX_rated_min Nhiệt độ định mức tối thiểu.
			Từ đăng ký MFR_TAMBIENT_MIN.
tempX_rated_max Nhiệt độ định mức tối đa.
			Từ MFR_TAMBIENT_MAX, MFR_MAX_TEMP_1, MFR_MAX_TEMP_2 hoặc
			Đăng ký MFR_MAX_TEMP_3.
=====================================================================================
