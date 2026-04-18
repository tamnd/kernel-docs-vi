.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/bel-pfe.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân bel-pfe
======================

Chip được hỗ trợ:

* BEL PFE1100

Tiền tố: 'pfe1100'

Địa chỉ được quét: -

Bảng dữ liệu: ZZ0000ZZ

* BEL PFE3000

Tiền tố: 'pfe3000'

Địa chỉ được quét: -

Bảng dữ liệu: ZZ0000ZZ

Tác giả: Tao Ren <rentao.bupt@gmail.com>


Sự miêu tả
-----------

Trình điều khiển này hỗ trợ giám sát phần cứng cho các thiết bị cấp nguồn bên dưới
hỗ trợ Giao thức PMBus:

* BEL PFE1100

Bộ nguồn 1100 Watt AC sang DC đã điều chỉnh hệ số công suất (PFC).
    Sổ tay hướng dẫn giao tiếp PMBus không được công bố rộng rãi.

* BEL PFE3000

Bộ nguồn DC-DC 3000 Watt AC/DC đã hiệu chỉnh hệ số công suất (PFC) và DC-DC.
    Sổ tay hướng dẫn giao tiếp PMBus không được công bố rộng rãi.

Trình điều khiển là trình điều khiển máy khách cho trình điều khiển PMBus cốt lõi. Xin vui lòng xem
Documentation/hwmon/pmbus.rst để biết chi tiết về trình điều khiển máy khách PMBus.


Ghi chú sử dụng
-----------

Trình điều khiển này không tự động phát hiện thiết bị. Bạn sẽ phải khởi tạo
thiết bị một cách rõ ràng. Vui lòng xem Documentation/i2c/instantiating-devices.rst để biết
chi tiết.

Ví dụ: phần sau sẽ tải trình điều khiển cho PFE3000 tại địa chỉ 0x20
trên xe buýt I2C #1::

$ modprobe bel-pfe
	$ echo pfe3000 0x20 > /sys/bus/i2c/devices/i2c-1/new_device


Hỗ trợ dữ liệu nền tảng
---------------------

Trình điều khiển hỗ trợ dữ liệu nền tảng trình điều khiển PMBus tiêu chuẩn.


Mục nhập hệ thống
-------------

====================================================================================
curr1_label "iin"
curr1_input Đo dòng điện đầu vào
curr1_max Nhập giá trị tối đa hiện tại
curr1_max_alarm Nhập cảnh báo tối đa hiện tại

Curr[2-3]_label "iout[1-2]"
curr[2-3]_input Đo dòng điện đầu ra
curr[2-3]_max Giá trị tối đa hiện tại đầu ra
curr[2-3]_max_alarm Cảnh báo dòng điện đầu ra tối đa

fan[1-2]_input Tốc độ quạt 1 và 2 trong RPM
fan1_target Đặt tham chiếu tốc độ quạt cho cả hai quạt

in1_label "vin"
in1_input Đo điện áp đầu vào
in1_crit Giá trị cực đại tới hạn của điện áp đầu vào
in1_crit_alarm Cảnh báo cực đại tới hạn của điện áp đầu vào
in1_lcrit Giá trị tối thiểu quan trọng của điện áp đầu vào
in1_lcrit_alarm Cảnh báo tối thiểu quan trọng của điện áp đầu vào
in1_max Giá trị tối đa của điện áp đầu vào
in1_max_alarm Báo động điện áp đầu vào tối đa

in2_label "vcap"
in2_input Giữ điện áp tụ điện

trong[3-8]_label "vout[1-3,5-7]"
in[3-8]_input Đo điện áp đầu ra
báo động điện áp đầu ra in[3-4]_alarm vout[1-2]

power[1-2]_label "pin[1-2]"
power[1-2]_input Công suất đầu vào đo được
power[1-2]_alarm Báo động nguồn đầu vào cao

power[3-4]_label "bĩu môi[1-2]"
power[3-4]_input Công suất đầu ra đo được

temp[1-3]_input Nhiệt độ đo được
temp[1-3]_alarm Báo động nhiệt độ
====================================================================================

.. note::

    - curr3, fan2, vout[2-7], vcap, pin2, pout2 and temp3 attributes only
      exist for PFE3000.
