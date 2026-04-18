.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/stpddc60.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân stpddc60
======================

Chip được hỗ trợ:

*ST STPDDC60

Tiền tố: 'stpddc60', 'bmr481'

Địa chỉ được quét: -

Bảng dữ liệu: ZZ0000ZZ

Tác giả: Erik Rosen <erik.rosen@metormote.com>


Sự miêu tả
-----------

Trình điều khiển này hỗ trợ giám sát phần cứng cho chip điều khiển ST STPDDC60 và
các mô-đun tương thích.

Trình điều khiển là trình điều khiển máy khách cho trình điều khiển PMBus cốt lõi. Xin vui lòng xem
Documentation/hwmon/pmbus.rst và Documentation.hwmon/pmbus-core để biết chi tiết
trên trình điều khiển máy khách PMBus.


Ghi chú sử dụng
-----------

Trình điều khiển này không tự động phát hiện thiết bị. Bạn sẽ phải khởi tạo
thiết bị một cách rõ ràng. Vui lòng xem Documentation/i2c/instantiating-devices.rst để biết
chi tiết.

Các giới hạn dưới và quá điện áp vout được đặt liên quan đến lệnh
điện áp đầu ra dưới dạng bù dương hoặc âm trong khoảng 50mV đến 400mV
theo bước 50mV. Điều này có nghĩa là giá trị tuyệt đối của các giới hạn sẽ thay đổi
khi điện áp đầu ra lệnh thay đổi. Ngoài ra, cần lưu ý khi
ghi vào các giới hạn đó vì trong trường hợp xấu nhất, điện áp đầu ra được lệnh
có thể thay đổi cùng lúc với giới hạn được ghi vào, điều này sẽ dẫn đến
kết quả khó lường.


Hỗ trợ dữ liệu nền tảng
---------------------

Trình điều khiển hỗ trợ dữ liệu nền tảng trình điều khiển PMBus tiêu chuẩn.


Mục nhập hệ thống
-------------

Các thuộc tính sau được hỗ trợ. Giới hạn Vin, iout, bĩu môi và nhiệt độ
được đọc-ghi; tất cả các thuộc tính khác là chỉ đọc.

=====================================================================================
in1_label "vin"
in1_input Đo điện áp đầu vào.
in1_lcrit Điện áp đầu vào tối thiểu tới hạn.
in1_crit Điện áp đầu vào tối đa tới hạn.
in1_lcrit_alarm Báo động điện áp đầu vào cực thấp.
in1_crit_alarm Báo động điện áp đầu vào tới hạn cao.

in2_label "vout1"
in2_input Đo điện áp đầu ra.
in2_lcrit Điện áp đầu ra tối thiểu tới hạn.
in2_crit Điện áp đầu ra tối đa tới hạn.
in2_lcrit_alarm Báo động điện áp đầu ra tới hạn ở mức thấp tới hạn.
in2_crit_alarm Báo động điện áp đầu ra tới hạn ở mức cao tới hạn.

curr1_label "iout1"
curr1_input Đo dòng điện đầu ra.
curr1_max Dòng điện đầu ra tối đa.
curr1_max_alarm Xuất cảnh báo hiện tại ở mức cao.
curr1_crit Dòng điện đầu ra tối đa tới hạn.
curr1_crit_alarm Xuất cảnh báo tới hạn hiện tại ở mức cao.

power1_label "bĩu môi1"
power1_input Đo công suất đầu ra.
power1_crit Công suất đầu ra tối đa tới hạn.
power1_crit_alarm Báo động nghiêm trọng về nguồn điện đầu ra.

temp1_input Đo nhiệt độ tối đa của tất cả các pha.
temp1_max Giới hạn nhiệt độ tối đa.
temp1_max_alarm Báo động nhiệt độ cao.
temp1_crit Giới hạn nhiệt độ tối đa tới hạn.
temp1_crit_alarm Báo động nhiệt độ tối đa tới hạn.
=====================================================================================