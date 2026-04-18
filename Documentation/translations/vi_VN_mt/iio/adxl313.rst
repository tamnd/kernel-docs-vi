.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/iio/adxl313.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
Trình điều khiển ADXL313
===============

Trình điều khiển này hỗ trợ ADXL313 của Thiết bị Analog trên bus SPI/I2C.

1. Thiết bị được hỗ trợ
====================

* ZZ0000ZZ

ADXL313 là máy đo gia tốc 3 trục có mật độ tiếng ồn thấp, công suất thấp với
phạm vi đo có thể lựa chọn ADXL313 hỗ trợ ±0,5 g, ±1 g, ±2 g và
Phạm vi ±4 g.

2. Thuộc tính thiết bị
====================

Các phép đo gia tốc luôn được cung cấp.

Mỗi thiết bị IIO, có một thư mục thiết bị trong ZZ0000ZZ,
trong đó X là chỉ số IIO của thiết bị. Dưới các thư mục này chứa một bộ
tập tin thiết bị, tùy thuộc vào đặc điểm và tính năng của phần cứng
thiết bị trong câu hỏi. Các tập tin này được khái quát hóa và ghi lại một cách nhất quán trong
tài liệu IIO ABI.

Các bảng sau đây hiển thị các tệp thiết bị liên quan đến adxl313, được tìm thấy trong
đường dẫn thư mục thiết bị cụ thể ZZ0000ZZ.

+---------------------------------------------------+----------------------------------------------------------+
ZZ0000ZZ Mô tả |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0001ZZ Thang đo cho các kênh gia tốc.                    |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0002ZZ Hiệu chỉnh bù cho kênh gia tốc kế trục X. |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0003ZZ Giá trị kênh gia tốc kế trục X thô.                  |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0004ZZ Hiệu chỉnh bù gia tốc trục y |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0005ZZ Giá trị kênh gia tốc kế trục Y thô.                  |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0006ZZ Hiệu chỉnh bù cho kênh gia tốc kế trục Z. |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0007ZZ Giá trị kênh gia tốc kế trục Z thô.                  |
+---------------------------------------------------+----------------------------------------------------------+

+---------------------------------------+------------------------------------------------------- +
ZZ0000ZZ Mô tả |
+---------------------------------------+------------------------------------------------------- +
ZZ0001ZZ Tên của thiết bị IIO.                      |
+---------------------------------------+------------------------------------------------------- +
ZZ0002ZZ Tỷ lệ mẫu hiện được chọn.              |
+---------------------------------------+------------------------------------------------------- +
ZZ0003ZZ Cấu hình tần số lấy mẫu có sẵn. |
+---------------------------------------+------------------------------------------------------- +

Cài đặt liên quan đến sự kiện iio, được tìm thấy trong ZZ0000ZZ.

+---------------------------------------------------+----------------------------------------------------------+
ZZ0000ZZ AC kết hợp thời gian không hoạt động.                              |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0001ZZ Ngưỡng không hoạt động kết hợp AC.                         |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0002ZZ Ngưỡng hoạt động kết hợp AC.                           |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0003ZZ Thời gian không hoạt động.                                         |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0004ZZ Ngưỡng không hoạt động.                                    |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0005ZZ Ngưỡng hoạt động.                                      |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0006ZZ Bật hoặc tắt các sự kiện không hoạt động được ghép nối AC.          |
+---------------------------------------------------+----------------------------------------------------------+
| in_accel_x\|y\ZZ0008ZZ Bật hoặc tắt các sự kiện hoạt động được ghép nối AC.            |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0009ZZ Kích hoạt hoặc vô hiệu hóa các sự kiện không hoạt động.                     |
+---------------------------------------------------+----------------------------------------------------------+
| in_accel_x\|y\ZZ0011ZZ Bật hoặc tắt các sự kiện hoạt động.                       |
+---------------------------------------------------+----------------------------------------------------------+

Khớp nối mặc định là các sự kiện được ghép nối DC. Trong trường hợp này ngưỡng sẽ
được đặt đúng vị trí, trong đó đối với trường hợp ghép AC, có một ngưỡng thích ứng
(được mô tả trong biểu dữ liệu) sẽ được cảm biến áp dụng. Trong hoạt động chung,
tức là ZZ0000ZZ hoặc ZZ0001ZZ và không hoạt động, tức là ZZ0002ZZ hoặc
ZZ0003ZZ, sẽ được liên kết với tính năng tự động ngủ khi cả hai đều được bật.
Điều này có nghĩa là ZZ0004ZZ cụ thể cũng có thể được liên kết với ZZ0005ZZ
và ngược lại, không có vấn đề gì.

Lưu ý ở đây rằng ZZ0000ZZ và ZZ0001ZZ loại trừ lẫn nhau. Cái này
có nghĩa là cấu hình gần đây nhất sẽ được thiết lập. Ví dụ, nếu
ZZ0002ZZ được bật và ZZ0003ZZ sẽ được bật, trình điều khiển cảm biến
sẽ tắt ZZ0004ZZ nhưng kích hoạt ZZ0005ZZ. Điều tương tự là hợp lệ
vì không hoạt động. Trong trường hợp tắt một sự kiện, nó phải phù hợp với những gì
thực sự được bật, tức là bật ZZ0006ZZ và sau đó tắt ZZ0007ZZ
đơn giản là bị bỏ qua vì nó đã bị vô hiệu hóa. Hoặc, như thể nó không phải là cái gì khác
sự kiện được kích hoạt, quá.

Các giá trị được xử lý của kênh
-------------------------

Giá trị kênh có thể được đọc từ thuộc tính _raw của nó. Giá trị trả về là
giá trị thô như được báo cáo bởi các thiết bị. Để có được giá trị được xử lý của kênh,
áp dụng công thức sau:

.. code-block::

        processed value = (_raw + _offset) * _scale

Trong đó _offset và _scale là thuộc tính của thiết bị. Nếu không có thuộc tính _offset
hiện tại, chỉ cần giả sử giá trị của nó là 0.

Trình điều khiển ADXL313 cung cấp dữ liệu cho một loại kênh duy nhất, bảng bên dưới
hiển thị các đơn vị đo lường cho giá trị được xử lý, được xác định bởi
Khung IIO:

+--------------------------------------+-----------------------------+
ZZ0000ZZ Đơn vị đo lường |
+--------------------------------------+-----------------------------+
ZZ0001ZZ Mét trên giây bình phương |
+--------------------------------------+-----------------------------+

Ví dụ sử dụng
--------------

Hiển thị tên thiết bị:

.. code-block:: bash

        root:/sys/bus/iio/devices/iio:device0> cat name
        adxl313

Hiển thị giá trị kênh gia tốc:

.. code-block:: bash

        root:/sys/bus/iio/devices/iio:device0> cat in_accel_x_raw
        2
        root:/sys/bus/iio/devices/iio:device0> cat in_accel_y_raw
        -57
        root:/sys/bus/iio/devices/iio:device0> cat in_accel_z_raw
        2
        root:/sys/bus/iio/devices/iio:device0> cat in_accel_scale
        0.009576806

Các giá trị gia tốc kế sẽ là:

- Gia tốc trục X = in_accel_x_raw * in_accel_scale = 0,0191536 m/s^2
- Gia tốc trục Y = in_accel_y_raw * in_accel_scale = -0,5458779 m/s^2
- Gia tốc trục Z = in_accel_z_raw * in_accel_scale = 0,0191536 m/s^2

Đặt độ lệch hiệu chuẩn cho các kênh gia tốc kế. Lưu ý rằng việc hiệu chuẩn
sẽ được làm tròn theo cấp độ của đơn vị LSB:

.. code-block:: bash

        root:/sys/bus/iio/devices/iio:device0> cat in_accel_x_calibbias
        0

        root:/sys/bus/iio/devices/iio:device0> echo 50 > in_accel_x_calibbias
        root:/sys/bus/iio/devices/iio:device0> cat in_accel_x_calibbias
        48

Đặt tần số lấy mẫu:

.. code-block:: bash

        root:/sys/bus/iio/devices/iio:device0> cat in_accel_sampling_frequency
        100.000000
        root:/sys/bus/iio/devices/iio:device0> cat in_accel_sampling_frequency_available
        6.250000 12.500000 25.000000 50.000000 100.000000 200.000000 400.000000 800.000000 1600.000000 3200.000000

        root:/sys/bus/iio/devices/iio:device0> echo 400 > in_accel_sampling_frequency
        root:/sys/bus/iio/devices/iio:device0> cat in_accel_sampling_frequency
        400.000000

3. Bộ đệm và trình kích hoạt thiết bị
==============================

Trình điều khiển này hỗ trợ bộ đệm IIO.

Tất cả các thiết bị đều hỗ trợ truy xuất các phép đo gia tốc thô bằng bộ đệm.

Ví dụ sử dụng
--------------

Chọn kênh để đọc bộ đệm:

.. code-block:: bash

        root:/sys/bus/iio/devices/iio:device0> echo 1 > scan_elements/in_accel_x_en
        root:/sys/bus/iio/devices/iio:device0> echo 1 > scan_elements/in_accel_y_en
        root:/sys/bus/iio/devices/iio:device0> echo 1 > scan_elements/in_accel_z_en

Đặt số lượng mẫu sẽ được lưu trong bộ đệm:

.. code-block:: bash

        root:/sys/bus/iio/devices/iio:device0> echo 10 > buffer/length

Kích hoạt tính năng đọc bộ đệm:

.. code-block:: bash

        root:/sys/bus/iio/devices/iio:device0> echo 1 > buffer/enable

Lấy dữ liệu đệm:

.. code-block:: bash

        root:/sys/bus/iio/devices/iio:device0> hexdump -C /dev/iio\:device0
        ...
        000000d0  01 fc 31 00 c7 ff 03 fc  31 00 c7 ff 04 fc 33 00  |..1.....1.....3.|
        000000e0  c8 ff 03 fc 32 00 c5 ff  ff fc 32 00 c7 ff 0a fc  |....2.....2.....|
        000000f0  30 00 c8 ff 06 fc 33 00  c7 ff 01 fc 2f 00 c8 ff  |0.....3...../...|
        00000100  02 fc 32 00 c6 ff 04 fc  33 00 c8 ff 05 fc 33 00  |..2.....3.....3.|
        00000110  ca ff 02 fc 31 00 c7 ff  02 fc 30 00 c9 ff 09 fc  |....1.....0.....|
        00000120  35 00 c9 ff 08 fc 35 00  c8 ff 02 fc 31 00 c5 ff  |5.....5.....1...|
        00000130  03 fc 32 00 c7 ff 04 fc  32 00 c7 ff 02 fc 31 00  |..2.....2.....1.|
        00000140  c7 ff 08 fc 30 00 c7 ff  02 fc 32 00 c5 ff ff fc  |....0.....2.....|
        00000150  31 00 c5 ff 04 fc 31 00  c8 ff 03 fc 32 00 c8 ff  |1.....1.....2...|
        00000160  01 fc 31 00 c7 ff 05 fc  31 00 c3 ff 04 fc 31 00  |..1.....1.....1.|
        00000170  c5 ff 04 fc 30 00 c7 ff  03 fc 31 00 c9 ff 03 fc  |....0.....1.....|
        ...

Cho phép phát hiện hoạt động:

.. code-block:: bash

        root:/sys/bus/iio/devices/iio:device0> echo 1.28125 > ./events/in_accel_mag_rising_value
        root:/sys/bus/iio/devices/iio:device0> echo 1 > ./events/in_accel_x\|y\|z_mag_rising_en

        root:/sys/bus/iio/devices/iio:device0> iio_event_monitor adxl313
        Found IIO device with name adxl313 with device number 0
        <only while moving the sensor>
        Event: time: 1748795762298351281, type: accel(x|y|z), channel: 0, evtype: mag, direction: rising
        Event: time: 1748795762302653704, type: accel(x|y|z), channel: 0, evtype: mag, direction: rising
        Event: time: 1748795762304340726, type: accel(x|y|z), channel: 0, evtype: mag, direction: rising
        ...

Vô hiệu hóa phát hiện hoạt động:

.. code-block:: bash

        root:/sys/bus/iio/devices/iio:device0> echo 0 > ./events/in_accel_x\|y\|z_mag_rising_en
        root:/sys/bus/iio/devices/iio:device0> iio_event_monitor adxl313
        <nothing>

Bật tính năng phát hiện không hoạt động:

.. code-block:: bash

        root:/sys/bus/iio/devices/iio:device0> echo 1.234375 > ./events/in_accel_mag_falling_value
        root:/sys/bus/iio/devices/iio:device0> echo 5 > ./events/in_accel_mag_falling_period
        root:/sys/bus/iio/devices/iio:device0> echo 1 > ./events/in_accel_x\&y\&z_mag_falling_en

        root:/sys/bus/iio/devices/iio:device0> iio_event_monitor adxl313
        Found IIO device with name adxl313 with device number 0
        Event: time: 1748796324115962975, type: accel(x&y&z), channel: 0, evtype: mag, direction: falling
        Event: time: 1748796329329981772, type: accel(x&y&z), channel: 0, evtype: mag, direction: falling
        Event: time: 1748796334543399706, type: accel(x&y&z), channel: 0, evtype: mag, direction: falling
        ...
        <every 5s now indicates inactivity>

Bây giờ, cho phép hoạt động, ví dụ: bộ phận đối ứng được ghép nối AC ZZ0000ZZ

.. code-block:: bash

        root:/sys/bus/iio/devices/iio:device0> echo 1.28125 > ./events/in_accel_mag_rising_value
        root:/sys/bus/iio/devices/iio:device0> echo 1 > ./events/in_accel_x\|y\|z_mag_rising_en

        root:/sys/bus/iio/devices/iio:device0> iio_event_monitor adxl313
        Found IIO device with name adxl313 with device number 0
        <some activity with the sensor>
        Event: time: 1748796880354686777, type: accel(x|y|z), channel: 0, evtype: mag_adaptive, direction: rising
        <5s of inactivity, then>
        Event: time: 1748796885543252017, type: accel(x&y&z), channel: 0, evtype: mag, direction: falling
        <some other activity detected by accelerating the sensor>
        Event: time: 1748796887756634678, type: accel(x|y|z), channel: 0, evtype: mag_adaptive, direction: rising
        <again, 5s of inactivity>
        Event: time: 1748796892964368352, type: accel(x&y&z), channel: 0, evtype: mag, direction: falling
        <stays like this until next activity in auto-sleep>

Lưu ý, khi khớp nối AC được lắp đặt, loại sự kiện sẽ là ZZ0000ZZ.
Các sự kiện kết hợp AC hoặc DC (mặc định) được sử dụng tương tự.

4. Công cụ giao tiếp IIO
========================

Xem Documentation/iio/iio_tools.rst để biết mô tả về IIO có sẵn
các công cụ giao tiếp.