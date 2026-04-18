.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/ina2xx.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân ina2xx
====================

Chip được hỗ trợ:

* Dụng cụ Texas INA219


Tiền tố: 'ina219'
    Địa chỉ: I2C 0x40 - 0x4f

Bảng dữ liệu: Có sẵn công khai tại trang web Texas Instruments

ZZ0000ZZ

* Dụng cụ Texas INA220

Tiền tố: 'ina220'

Địa chỉ: I2C 0x40 - 0x4f

Bảng dữ liệu: Có sẵn công khai tại trang web Texas Instruments

ZZ0000ZZ

* Dụng cụ Texas INA226

Tiền tố: 'ina226'

Địa chỉ: I2C 0x40 - 0x4f

Bảng dữ liệu: Có sẵn công khai tại trang web Texas Instruments

ZZ0000ZZ

* Dụng cụ Texas INA230

Tiền tố: 'ina230'

Địa chỉ: I2C 0x40 - 0x4f

Bảng dữ liệu: Có sẵn công khai tại trang web Texas Instruments

ZZ0000ZZ

* Dụng cụ Texas INA231

Tiền tố: 'ina231'

Địa chỉ: I2C 0x40 - 0x4f

Bảng dữ liệu: Có sẵn công khai tại trang web Texas Instruments

ZZ0000ZZ

* Dụng cụ Texas INA260

Tiền tố: 'ina260'

Địa chỉ: I2C 0x40 - 0x4f

Bảng dữ liệu: Có sẵn công khai tại trang web Texas Instruments

ZZ0000ZZ

* Silergy SY24655

Tiền tố: 'sy24655'

Địa chỉ: I2C 0x40 - 0x4f

Bảng dữ liệu: Có sẵn công khai tại trang web Silergy

ZZ0000ZZ


* Dụng cụ Texas INA234

Tiền tố: 'ina234'

Địa chỉ: I2C 0x40 - 0x43

Bảng dữ liệu: Có sẵn công khai tại trang web Texas Instruments

ZZ0000ZZ

Tác giả: Lothar Felten <lothar.felten@gmail.com>

Sự miêu tả
-----------

INA219 là thiết bị theo dõi dòng điện và công suất shunt phía cao với I2C
giao diện. INA219 giám sát cả điện áp nguồn và điện áp rơi shunt, với
thời gian chuyển đổi và lọc có thể lập trình.

INA220 là thiết bị theo dõi dòng điện và công suất shunt phía cao hoặc thấp với I2C
giao diện. INA220 giám sát cả điện áp nguồn và điện áp rơi shunt.

INA226 là thiết bị theo dõi nguồn điện và shunt hiện tại với giao diện I2C.
INA226 giám sát cả sự sụt giảm điện áp shunt và điện áp cung cấp bus.

INA230, INA231 và INA234 là bộ giám sát nguồn và shunt dòng điện phía cao hoặc phía thấp
với giao diện I2C. Các chip giám sát cả sự sụt giảm điện áp shunt và
điện áp cung cấp xe buýt.

INA260 là thiết bị theo dõi dòng điện và công suất phía cao hoặc thấp với shunt tích hợp
điện trở.

SY24655 là thiết bị theo dõi dòng điện và công suất shunt phía cao và phía thấp với I2C
giao diện. SY24655 hỗ trợ cả điện áp nguồn và điện áp rơi shunt, với
giá trị hiệu chuẩn có thể lập trình và thời gian chuyển đổi. SY24655 cũng có thể
tính toán công suất trung bình sử dụng trong chuyển hóa năng lượng.

Giá trị shunt tính bằng micro-ohms có thể được đặt thông qua dữ liệu nền tảng hoặc cây thiết bị tại
thời gian biên dịch hoặc thông qua thuộc tính shunt_resistor trong sysfs vào thời gian chạy. làm ơn
tham khảo Tài liệu/devicetree/binds/hwmon/ti,ina2xx.yaml để biết các ràng buộc
nếu cây thiết bị được sử dụng.

Ngoài ra ina226 còn hỗ trợ thuộc tính update_interval như được mô tả trong
Tài liệu/hwmon/sysfs-interface.rst. Bên trong khoảng là tổng của
thời gian chuyển đổi điện áp bus và shunt nhân với tốc độ trung bình. Chúng tôi
không chạm vào thời gian chuyển đổi và chỉ sửa đổi số lượng trung bình. các
giới hạn dưới của update_interval là 2 ms, giới hạn trên là 2253 ms.
Khoảng thời gian được lập trình thực tế có thể khác với giá trị mong muốn.

Các mục sysfs chung
---------------------

============================================================================
in0_input Kênh điện áp Shunt (mV)
in1_input Kênh điện áp bus (mV)
kênh đo dòng điện (mA) hiện tại
power1_input Kênh đo công suất (uW)
shunt_resistor Kênh điện trở shunt(uOhm) (không dùng cho ina260)
============================================================================

Các mục sysfs bổ sung
------------------------

Các mục bổ sung có sẵn cho các chip sau:

* ina226
  * ina230
  * ina231
  * ina234
  * ina260
  *sy24655

=================================================================================
curr1_lcrit Dòng điện cực thấp tới hạn
Curr1_crit Dòng điện cao tới hạn
curr1_lcrit_alarm Báo động thấp tới mức hiện tại
curr1_crit_alarm Báo động nghiêm trọng hiện tại ở mức cao
in0_lcrit Điện áp shunt thấp tới hạn
in0_crit Điện áp shunt cao tới hạn
in0_lcrit_alarm Báo động điện áp Shunt thấp tới hạn
in0_crit_alarm Cảnh báo điện áp shunt cao tới hạn
in1_lcrit Điện áp bus thấp tới hạn
in1_crit Điện áp bus cao tới hạn
in1_lcrit_alarm Báo động điện áp bus cực thấp
in1_crit_alarm Báo động điện áp bus cao tới hạn
power1_crit Sức mạnh quan trọng cao
power1_crit_alarm Báo động nghiêm trọng về nguồn điện
update_interval thời gian chuyển đổi dữ liệu; ảnh hưởng đến số lượng mẫu được sử dụng
			đến kết quả trung bình cho điện áp shunt và bus.
=================================================================================

Các mục Sysfs chỉ dành cho sy24655
------------------------------

=================================================================================
power1_average công suất trung bình từ lần đọc cuối cùng đến hiện tại.
=================================================================================

.. note::

   - Configure `shunt_resistor` before configure `power1_crit`, because power
     value is calculated based on `shunt_resistor` set.
   - Because of the underlying register implementation, only one `*crit` setting
     and its `alarm` can be active. Writing to one `*crit` setting clears other
     `*crit` settings and alarms. Writing 0 to any `*crit` setting clears all
     `*crit` settings and alarms.
