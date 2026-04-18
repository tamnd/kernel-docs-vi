.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/iio/adxl380.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================
Trình điều khiển ADXL380
========================

Trình điều khiển này hỗ trợ ADXL380/382 của Thiết bị Analog trên bus SPI/I2C.

1. Thiết bị được hỗ trợ
=======================

* ZZ0000ZZ
* ZZ0001ZZ

ADXL380/ADXL382 là máy đo gia tốc 3 trục có mật độ tiếng ồn thấp, công suất thấp,
phạm vi đo có thể lựa chọn ADXL380 hỗ trợ ±4 g, ±8 g và ±16 g
phạm vi và ADXL382 hỗ trợ các phạm vi ±15 g, ±30 g và ±60 g.

2. Thuộc tính thiết bị
======================

Các phép đo gia tốc luôn được cung cấp.

Dữ liệu nhiệt độ cũng được cung cấp. Dữ liệu này có thể được sử dụng để theo dõi
nhiệt độ bên trong hệ thống hoặc để cải thiện sự ổn định nhiệt độ của
thiết bị thông qua hiệu chuẩn.

Mỗi thiết bị IIO, có một thư mục thiết bị trong ZZ0000ZZ,
trong đó X là chỉ số IIO của thiết bị. Dưới các thư mục này chứa một bộ
tập tin thiết bị, tùy thuộc vào đặc điểm và tính năng của phần cứng
thiết bị trong câu hỏi. Các tập tin này được khái quát hóa và ghi lại một cách nhất quán trong
tài liệu IIO ABI.

Các bảng sau hiển thị các tệp thiết bị liên quan đến adxl380, được tìm thấy trong
đường dẫn thư mục thiết bị cụ thể ZZ0000ZZ.

+---------------------------------------------------+----------------------------------------------------------+
ZZ0000ZZ Mô tả |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0001ZZ Thang đo cho các kênh gia tốc.                    |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0002ZZ Băng thông bộ lọc thông thấp.                               |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0003ZZ Cấu hình băng thông bộ lọc thông thấp có sẵn.      |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0004ZZ Băng thông bộ lọc thông cao.                              |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0005ZZ Cấu hình băng thông bộ lọc thông cao có sẵn.     |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0006ZZ Hiệu chỉnh bù cho kênh gia tốc kế trục X. |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0007ZZ Giá trị kênh gia tốc kế trục X thô.                  |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0008ZZ Hiệu chỉnh bù gia tốc trục y |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0009ZZ Giá trị kênh gia tốc kế trục Y thô.                  |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0010ZZ Hiệu chỉnh bù cho kênh gia tốc kế trục Z. |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0011ZZ Giá trị kênh gia tốc trục Z thô.                  |
+---------------------------------------------------+----------------------------------------------------------+

+-----------------------------------+---------------------------------------------+
ZZ0000ZZ Mô tả |
+-----------------------------------+---------------------------------------------+
ZZ0001ZZ Giá trị kênh nhiệt độ thô.             |
+-----------------------------------+---------------------------------------------+
ZZ0002ZZ Offset cho kênh cảm biến nhiệt độ. |
+-----------------------------------+---------------------------------------------+
ZZ0003ZZ Cân cho kênh cảm biến nhiệt độ.  |
+-----------------------------------+---------------------------------------------+

+------------------------------+-------------------------------------------------------+
ZZ0000ZZ Mô tả |
+------------------------------+-------------------------------------------------------+
ZZ0001ZZ Tên của thiết bị IIO.                      |
+------------------------------+-------------------------------------------------------+
ZZ0002ZZ Tỷ lệ mẫu hiện được chọn.              |
+------------------------------+-------------------------------------------------------+
ZZ0003ZZ Cấu hình tần số lấy mẫu có sẵn. |
+------------------------------+-------------------------------------------------------+

Các giá trị được xử lý của kênh
-------------------------------

Giá trị kênh có thể được đọc từ thuộc tính _raw của nó. Giá trị trả về là
giá trị thô như được báo cáo bởi các thiết bị. Để có được giá trị được xử lý của kênh,
áp dụng công thức sau:

.. code-block:: bash

        processed value = (_raw + _offset) * _scale

Trong đó _offset và _scale là thuộc tính của thiết bị. Nếu không có thuộc tính _offset
hiện tại, chỉ cần giả sử giá trị của nó là 0.

Trình điều khiển ADXL380 cung cấp dữ liệu cho 2 loại kênh, bảng bên dưới hiển thị
đơn vị đo lường cho giá trị được xử lý, được xác định bởi IIO
khuôn khổ:

+--------------------------------------+-----------------------------+
ZZ0000ZZ Đơn vị đo lường |
+--------------------------------------+-----------------------------+
ZZ0001ZZ Mét trên giây bình phương |
+--------------------------------------+-----------------------------+
ZZ0002ZZ Millidegrees C |
+--------------------------------------+-----------------------------+

Ví dụ sử dụng
--------------

Hiển thị tên thiết bị:

.. code-block:: bash

	root:/sys/bus/iio/devices/iio:device0> cat name
        adxl382

Hiển thị giá trị kênh gia tốc:

.. code-block:: bash

        root:/sys/bus/iio/devices/iio:device0> cat in_accel_x_raw
        -1771
        root:/sys/bus/iio/devices/iio:device0> cat in_accel_y_raw
        282
        root:/sys/bus/iio/devices/iio:device0> cat in_accel_z_raw
        -1523
        root:/sys/bus/iio/devices/iio:device0> cat in_accel_scale
        0.004903325

- Gia tốc trục X = in_accel_x_raw * in_accel_scale = −8,683788575 m/s^2
- Gia tốc trục Y = in_accel_y_raw * in_accel_scale = 1,38273765 m/s^2
- Gia tốc trục Z = in_accel_z_raw * in_accel_scale = -7,467763975 m/s^2

Đặt độ lệch hiệu chuẩn cho các kênh gia tốc:

.. code-block:: bash

        root:/sys/bus/iio/devices/iio:device0> cat in_accel_x_calibbias
        0

        root:/sys/bus/iio/devices/iio:device0> echo 50 > in_accel_x_calibbias
        root:/sys/bus/iio/devices/iio:device0> cat in_accel_x_calibbias
        50

Đặt tần số lấy mẫu:

.. code-block:: bash

	root:/sys/bus/iio/devices/iio:device0> cat sampling_frequency
        16000
        root:/sys/bus/iio/devices/iio:device0> cat sampling_frequency_available
        16000 32000 64000

        root:/sys/bus/iio/devices/iio:device0> echo 32000 > sampling_frequency
        root:/sys/bus/iio/devices/iio:device0> cat sampling_frequency
        32000

Đặt băng thông bộ lọc thông thấp cho các kênh gia tốc:

.. code-block:: bash

        root:/sys/bus/iio/devices/iio:device0> cat in_accel_filter_low_pass_3db_frequency
        32000
        root:/sys/bus/iio/devices/iio:device0> cat in_accel_filter_low_pass_3db_frequency_available
        32000 8000 4000 2000

        root:/sys/bus/iio/devices/iio:device0> echo 2000 > in_accel_filter_low_pass_3db_frequency
        root:/sys/bus/iio/devices/iio:device0> cat in_accel_filter_low_pass_3db_frequency
        2000

3. Bộ đệm thiết bị
==================

Trình điều khiển này hỗ trợ bộ đệm IIO.

Tất cả các thiết bị đều hỗ trợ truy xuất các phép đo nhiệt độ và gia tốc thô
sử dụng bộ đệm.

Ví dụ sử dụng
--------------

Chọn kênh để đọc bộ đệm:

.. code-block:: bash

        root:/sys/bus/iio/devices/iio:device0> echo 1 > scan_elements/in_accel_x_en
        root:/sys/bus/iio/devices/iio:device0> echo 1 > scan_elements/in_accel_y_en
        root:/sys/bus/iio/devices/iio:device0> echo 1 > scan_elements/in_accel_z_en
        root:/sys/bus/iio/devices/iio:device0> echo 1 > scan_elements/in_temp_en

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
        002bc300  f7 e7 00 a8 fb c5 24 80  f7 e7 01 04 fb d6 24 80  |......$.......$.|
        002bc310  f7 f9 00 ab fb dc 24 80  f7 c3 00 b8 fb e2 24 80  |......$.......$.|
        002bc320  f7 fb 00 bb fb d1 24 80  f7 b1 00 5f fb d1 24 80  |......$...._..$.|
        002bc330  f7 c4 00 c6 fb a6 24 80  f7 a6 00 68 fb f1 24 80  |......$....h..$.|
        002bc340  f7 b8 00 a3 fb e7 24 80  f7 9a 00 b1 fb af 24 80  |......$.......$.|
        002bc350  f7 b1 00 67 fb ee 24 80  f7 96 00 be fb 92 24 80  |...g..$.......$.|
        002bc360  f7 ab 00 7a fc 1b 24 80  f7 b6 00 ae fb 76 24 80  |...z..$......v$.|
        002bc370  f7 ce 00 a3 fc 02 24 80  f7 c0 00 be fb 8b 24 80  |......$.......$.|
        002bc380  f7 c3 00 93 fb d0 24 80  f7 ce 00 d8 fb c8 24 80  |......$.......$.|
        002bc390  f7 bd 00 c0 fb 82 24 80  f8 00 00 e8 fb db 24 80  |......$.......$.|
        002bc3a0  f7 d8 00 d3 fb b4 24 80  f8 0b 00 e5 fb c3 24 80  |......$.......$.|
        002bc3b0  f7 eb 00 c8 fb 92 24 80  f7 e7 00 ea fb cb 24 80  |......$.......$.|
        002bc3c0  f7 fd 00 cb fb 94 24 80  f7 e3 00 f2 fb b8 24 80  |......$.......$.|
        ...

Xem Documentation/iio/iio_devbuf.rst để biết thêm thông tin về cách lưu vào bộ đệm
dữ liệu được cấu trúc.

4. Công cụ giao tiếp IIO
========================

Xem Documentation/iio/iio_tools.rst để biết mô tả về IIO có sẵn
các công cụ giao tiếp.