.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/iio/adxl345.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================
Trình điều khiển ADXL345
========================

Trình điều khiển này hỗ trợ ADXL345/375 của Thiết bị Analog trên bus SPI/I2C.

1. Thiết bị được hỗ trợ
====================

* ZZ0000ZZ
* ZZ0001ZZ

ADXL345 là máy đo gia tốc 3 trục, công suất thấp, có thể lựa chọn
các phạm vi đo. ADXL345 hỗ trợ các phạm vi ±2 g, ±4 g, ±8 g và ±16 g.

2. Thuộc tính thiết bị
====================

Mỗi thiết bị IIO, có một thư mục thiết bị trong ZZ0000ZZ,
trong đó X là chỉ số IIO của thiết bị. Dưới các thư mục này chứa một bộ
tập tin thiết bị, tùy thuộc vào đặc điểm và tính năng của phần cứng
thiết bị trong câu hỏi. Các tập tin này được khái quát hóa và ghi lại một cách nhất quán trong
tài liệu IIO ABI.

Bảng sau hiển thị các tệp thiết bị liên quan đến ADXL345, được tìm thấy trong
đường dẫn thư mục thiết bị cụ thể ZZ0000ZZ.

+---------------------------------------------------+----------------------------------------------------------+
ZZ0000ZZ Mô tả |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0001ZZ Tỷ lệ mẫu hiện được chọn.                          |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0002ZZ Cấu hình tần số lấy mẫu có sẵn.             |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0003ZZ Tỷ lệ/phạm vi cho các kênh gia tốc kế.              |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0004ZZ Phạm vi tỷ lệ có sẵn cho kênh gia tốc kế.    |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0005ZZ Hiệu chỉnh bù cho kênh gia tốc kế trục X. |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0006ZZ Giá trị kênh gia tốc kế trục X thô.                  |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0007ZZ Hiệu chỉnh bù gia tốc trục y |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0008ZZ Giá trị kênh gia tốc kế trục Y thô.                  |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0009ZZ Hiệu chỉnh bù cho kênh gia tốc kế trục Z. |
+---------------------------------------------------+----------------------------------------------------------+
ZZ0010ZZ Giá trị kênh gia tốc kế trục Z thô.                  |
+---------------------------------------------------+----------------------------------------------------------+

Giá trị được xử lý kênh
-------------------------

Giá trị kênh có thể được đọc từ thuộc tính _raw của nó. Giá trị trả về là
giá trị thô như được báo cáo bởi các thiết bị. Để có được giá trị được xử lý của kênh,
áp dụng công thức sau:

.. code-block:: bash

        processed value = (_raw + _offset) * _scale

Trong đó _offset và _scale là thuộc tính của thiết bị. Nếu không có thuộc tính _offset
hiện tại, chỉ cần giả sử giá trị của nó là 0.

+--------------------------------------+-----------------------------+
ZZ0000ZZ Đơn vị đo lường |
+--------------------------------------+-----------------------------+
ZZ0001ZZ Mét trên giây bình phương |
+--------------------------------------+-----------------------------+

Sự kiện cảm biến
-------------

Các sự kiện IIO cụ thể được kích hoạt bởi các ngắt tương ứng của chúng. Cảm biến
trình điều khiển không hỗ trợ hoặc không hỗ trợ một dòng ngắt hoạt động (INT), có thể lựa chọn
từ hai tùy chọn có sẵn: INT1 hoặc INT2. Dòng INT đang hoạt động phải là
được chỉ định trong cây thiết bị. Nếu không có dòng INT nào được cấu hình, cảm biến sẽ mặc định
sang chế độ bỏ qua FIFO, trong đó tính năng phát hiện sự kiện bị tắt và chỉ có trục X, Y và Z
các phép đo có sẵn.

Bảng bên dưới liệt kê các tệp thiết bị liên quan đến ADXL345 nằm trong thư mục
đường dẫn dành riêng cho thiết bị: ZZ0000ZZ.
Lưu ý rằng theo mặc định, tính năng phát hiện hoạt động và không hoạt động được ghép nối DC;
do đó, chỉ các sự kiện hoạt động và không hoạt động được kết hợp với AC mới được xác định rõ ràng
được liệt kê.

+---------------------------------------------+---------------------------------------------+
ZZ0000ZZ Mô tả |
+---------------------------------------------+---------------------------------------------+
ZZ0001ZZ Kích hoạt tính năng phát hiện chạm hai lần trên tất cả các trục |
+---------------------------------------------+---------------------------------------------+
ZZ0002ZZ Cửa sổ nhấn đúp vào [us] |
+---------------------------------------------+---------------------------------------------+
ZZ0003ZZ Nhấn đúp tiềm ẩn trong [chúng tôi] |
+---------------------------------------------+---------------------------------------------+
ZZ0004ZZ Thời lượng một lần nhấn ở [chúng tôi] |
+---------------------------------------------+---------------------------------------------+
ZZ0005ZZ Giá trị ngưỡng một lần nhấn trong 62,5/LSB |
+---------------------------------------------+---------------------------------------------+
ZZ0006ZZ Thời gian không hoạt động tính bằng giây |
+---------------------------------------------+---------------------------------------------+
ZZ0007ZZ Giá trị ngưỡng không hoạt động trong 62,5/LSB |
+---------------------------------------------+---------------------------------------------+
ZZ0008ZZ Kích hoạt hoạt động ghép nối AC trên trục X |
+---------------------------------------------+---------------------------------------------+
ZZ0009ZZ AC kết hợp thời gian không hoạt động tính bằng giây |
+---------------------------------------------+---------------------------------------------+
ZZ0010ZZ Ngưỡng không hoạt động kết hợp AC ở 62,5/LSB |
+---------------------------------------------+---------------------------------------------+
ZZ0011ZZ Ngưỡng hoạt động kết hợp AC ở 62,5/LSB |
+---------------------------------------------+---------------------------------------------+
ZZ0012ZZ Kích hoạt tính năng phát hiện hoạt động trên trục X |
+---------------------------------------------+---------------------------------------------+
ZZ0013ZZ Giá trị ngưỡng hoạt động trong 62,5/LSB |
+---------------------------------------------+---------------------------------------------+
ZZ0014ZZ Kích hoạt tính năng phát hiện một lần nhấn trên trục X |
+---------------------------------------------+---------------------------------------------+
ZZ0015ZZ Kích hoạt tính năng phát hiện không hoạt động trên tất cả các trục |
+---------------------------------------------+---------------------------------------------+
ZZ0016ZZ Cho phép không hoạt động ghép nối AC trên tất cả các trục |
+---------------------------------------------+---------------------------------------------+
ZZ0017ZZ Kích hoạt tính năng phát hiện một lần chạm trên trục Y |
+---------------------------------------------+---------------------------------------------+
ZZ0018ZZ Kích hoạt tính năng phát hiện một lần chạm trên trục Z |
+---------------------------------------------+---------------------------------------------+

Vui lòng tham khảo bảng dữ liệu của cảm biến để biết mô tả chi tiết về điều này
chức năng.

Cài đặt thủ công ZZ0000ZZ sẽ khiến trình điều khiển ước tính các giá trị mặc định
đối với thời gian phát hiện không hoạt động, trong đó giá trị ODR cao hơn tương ứng với thời gian dài hơn
thời gian chờ mặc định và hạ giá trị ODR xuống giá trị ngắn hơn. Nếu những giá trị mặc định này làm
không đáp ứng nhu cầu của ứng dụng, bạn có thể định cấu hình rõ ràng trạng thái không hoạt động
thời gian chờ đợi. Đặt giá trị này thành 0 sẽ trở lại hành vi mặc định.

Khi thay đổi cấu hình ZZ0000ZZ, trình điều khiển cố gắng ước tính
ngưỡng hoạt động và không hoạt động thích hợp bằng cách chia tỷ lệ các giá trị mặc định
dựa trên tỷ lệ của phạm vi trước đó và phạm vi mới. Ngưỡng kết quả
sẽ không bao giờ bằng 0 và sẽ luôn nằm trong khoảng từ 1 đến 255, tương ứng với
đến 62,5g/LSB như được chỉ định trong biểu dữ liệu. Tuy nhiên, bạn có thể ghi đè lên những
ngưỡng ước tính bằng cách thiết lập các giá trị rõ ràng.

Khi các sự kiện ZZ0000ZZ và ZZ0001ZZ được bật, trình điều khiển
tự động quản lý hành vi trễ bằng cách đặt ZZ0002ZZ và
Các bit ZZ0003ZZ. Bit liên kết kết nối hoạt động và không hoạt động
hoạt động sao cho cái này nối tiếp cái kia. Chức năng tự động ngủ sẽ đặt
cảm biến chuyển sang chế độ ngủ khi phát hiện không hoạt động, giảm mức tiêu thụ điện năng
ở tốc độ dưới 12,5Hz.

Thời gian không hoạt động có thể được cấu hình trong khoảng từ 1 đến 255 giây. Ngoài ra
phát hiện không hoạt động, cảm biến cũng hỗ trợ phát hiện rơi tự do, từ
phối cảnh IIO, được coi là sự giảm độ lớn trên tất cả các trục. trong
Theo thuật ngữ cảm biến, sự rơi tự do được xác định bằng khoảng thời gian không hoạt động trong khoảng từ 0,000
đến 1.000 giây.

Người lái xe xử lý như sau:

* Nếu khoảng thời gian không hoạt động được định cấu hình là 1 giây trở lên, trình điều khiển sẽ sử dụng
  thanh ghi không hoạt động của cảm biến. Điều này cho phép sự kiện được liên kết với
  phát hiện hoạt động, sử dụng chế độ tự động ngủ và được ghép nối AC hoặc DC.

* Nếu khoảng thời gian không hoạt động dưới 1 giây, sự kiện được coi là đơn giản
  không hoạt động hoặc phát hiện rơi tự do. Trong trường hợp này, chế độ tự động ngủ và khớp nối
  (AC/DC) không được áp dụng.

* Nếu cài đặt thời gian không hoạt động là 0 giây, trình điều khiển sẽ chọn một
  khoảng thời gian mặc định được xác định theo kinh nghiệm (lớn hơn 1 giây) để tối ưu hóa
  tiêu thụ điện năng. Điều này cũng sử dụng đăng ký không hoạt động.

Lưu ý: Theo bảng dữ liệu, ODR tối ưu để phát hiện hoạt động,
hoặc không hoạt động (hoặc khi hoạt động với thanh ghi rơi tự do) sẽ nằm trong khoảng
dải tần từ 12,5 Hz đến 400 Hz. Ngưỡng rơi tự do được khuyến nghị là giữa
300 mg và 600 mg (đăng ký giá trị 0x05 đến 0x09).

Ở chế độ ghép nối DC, cường độ gia tốc hiện tại được so sánh trực tiếp với
các giá trị trong thanh ghi THRESH_ACT và THRESH_INACT để xác định hoạt động hoặc
không hoạt động. Ngược lại, tính năng phát hiện hoạt động được ghép nối AC sử dụng khả năng tăng tốc
giá trị khi bắt đầu phát hiện làm điểm tham chiếu và các mẫu tiếp theo được
so sánh với tài liệu tham khảo này. Trong khi khớp nối DC là chế độ so sánh mặc định
giá trị trực tiếp đến ngưỡng cố định-khớp nối AC dựa trên bộ lọc bên trong
so với ngưỡng được cấu hình.

Chế độ ghép nối AC và DC được cấu hình riêng cho hoạt động và không hoạt động
phát hiện, nhưng mỗi lần chỉ có thể kích hoạt một chế độ cho mỗi chế độ. Ví dụ, nếu
Tính năng phát hiện hoạt động được ghép nối AC được bật và sau đó chế độ ghép nối DC được thiết lập, chỉ
Tính năng phát hiện hoạt động được ghép nối DC sẽ được kích hoạt. Nói cách khác, chỉ nhất
cấu hình gần đây được áp dụng.

Có thể định cấu hình tính năng phát hiện ZZ0000ZZ trên mỗi biểu dữ liệu bằng cách đặt
các tham số ngưỡng và thời lượng. Khi chỉ bật tính năng phát hiện một lần nhấn,
ngắt một lần nhấn sẽ kích hoạt ngay khi gia tốc vượt quá
ngưỡng (đánh dấu điểm bắt đầu của khoảng thời gian) và sau đó giảm xuống dưới ngưỡng đó, với điều kiện là
giới hạn thời lượng không được vượt quá. Nếu phát hiện cả hai thao tác nhấn một lần và nhấn đúp
được bật, ngắt nhấn một lần chỉ được kích hoạt sau khi nhấn đúp
sự kiện đã được xác nhận hoặc bị loại bỏ.

Để định cấu hình phát hiện ZZ0000ZZ, bạn cũng phải đặt cửa sổ và độ trễ
các thông số tính bằng micro giây (µs). Khoảng thời gian trễ bắt đầu sau một lần nhấn
tín hiệu giảm xuống dưới ngưỡng và hoạt động như một thời gian chờ đợi trong đó bất kỳ
các đột biến được bỏ qua để phát hiện chạm hai lần. Sau khi thời gian trễ kết thúc,
cửa sổ phát hiện bắt đầu. Nếu gia tốc tăng vượt quá ngưỡng và sau đó
lại rơi xuống dưới nó trong cửa sổ này, sự kiện nhấn đúp sẽ được kích hoạt khi
sự tụt xuống dưới ngưỡng.

Tính năng phát hiện sự kiện nhấn đúp được giải thích kỹ lưỡng trong biểu dữ liệu. Sau một
sự kiện chạm một lần được phát hiện, sự kiện chạm hai lần có thể xảy ra sau đó, miễn là có tín hiệu
đáp ứng những tiêu chí nhất định. Tuy nhiên, tính năng phát hiện nhấn đúp có thể bị vô hiệu đối với
ba lý do:

* Nếu ZZ0000ZZ được đặt, bất kỳ sự tăng tốc nào phía trên vòi
  ngưỡng trong khoảng thời gian chờ chạm sẽ ngay lập tức vô hiệu hóa thao tác nhấn đúp
  phát hiện. Nói cách khác, không được phép tăng đột biến trong thời gian trễ khi
  bit ngăn chặn đang hoạt động.

* Sự kiện nhấn đúp không hợp lệ nếu khả năng tăng tốc vượt quá ngưỡng tại
  sự bắt đầu của cửa sổ nhấn đúp.

* Tính năng phát hiện nhấn đúp cũng bị vô hiệu nếu thời gian tăng tốc vượt quá
  giới hạn được thiết lập bởi thanh ghi thời lượng.

Để phát hiện nhấn đúp, thời lượng tương tự áp dụng cho nhấn một lần:
gia tốc phải tăng trên ngưỡng và sau đó giảm xuống dưới ngưỡng đó trong khoảng thời gian
thời hạn quy định. Lưu ý rằng bit triệt tiêu thường được bật khi tăng gấp đôi
tính năng phát hiện nhấn đang hoạt động.

Ví dụ sử dụng
--------------

Hiển thị tên thiết bị:

.. code-block:: bash

        root:/sys/bus/iio/devices/iio:device0> cat name
        adxl345

Hiển thị giá trị kênh gia tốc:

.. code-block:: bash

        root:/sys/bus/iio/devices/iio:device0> cat in_accel_x_raw
        -1
        root:/sys/bus/iio/devices/iio:device0> cat in_accel_y_raw
        2
        root:/sys/bus/iio/devices/iio:device0> cat in_accel_z_raw
        -253

Đặt độ lệch hiệu chuẩn cho các kênh gia tốc:

.. code-block:: bash

        root:/sys/bus/iio/devices/iio:device0> cat in_accel_x_calibbias
        0

        root:/sys/bus/iio/devices/iio:device0> echo 50 > in_accel_x_calibbias
        root:/sys/bus/iio/devices/iio:device0> cat in_accel_x_calibbias
        50

Với độ phân giải đầy đủ 13 bit, phạm vi khả dụng được tính bằng
công thức sau:

.. code-block:: bash

        (g * 2 * 9.80665) / (2^(resolution) - 1) * 100; for g := 2|4|8|16

Cấu hình phạm vi quy mô:

.. code-block:: bash

        root:/sys/bus/iio/devices/iio:device0> cat ./in_accel_scale
        0.478899
        root:/sys/bus/iio/devices/iio:device0> cat ./in_accel_scale_available
        0.478899 0.957798 1.915595 3.831190

        root:/sys/bus/iio/devices/iio:device0> echo 1.915595 > ./in_accel_scale
        root:/sys/bus/iio/devices/iio:device0> cat ./in_accel_scale
        1.915595

Đặt tốc độ dữ liệu đầu ra (ODR):

.. code-block:: bash

        root:/sys/bus/iio/devices/iio:device0> cat ./in_accel_sampling_frequency
        200.000000

        root:/sys/bus/iio/devices/iio:device0> cat ./in_accel_sampling_frequency_available
        0.097000 0.195000 0.390000 0.781000 1.562000 3.125000 6.250000 12.500000 25.000000 50.000000 100.000000 200.000000 400.000000 800.000000 1600.000000 3200.000000

        root:/sys/bus/iio/devices/iio:device0> echo 1.562000 > ./in_accel_sampling_frequency
        root:/sys/bus/iio/devices/iio:device0> cat ./in_accel_sampling_frequency
        1.562000

Định cấu hình một hoặc một số sự kiện:

.. code-block:: bash

        root:> cd /sys/bus/iio/devices/iio:device0

        root:/sys/bus/iio/devices/iio:device0> echo 1 > ./buffer0/in_accel_x_en
        root:/sys/bus/iio/devices/iio:device0> echo 1 > ./buffer0/in_accel_y_en
        root:/sys/bus/iio/devices/iio:device0> echo 1 > ./buffer0/in_accel_z_en

        root:/sys/bus/iio/devices/iio:device0> echo 1 > ./scan_elements/in_accel_x_en
        root:/sys/bus/iio/devices/iio:device0> echo 1 > ./scan_elements/in_accel_y_en
        root:/sys/bus/iio/devices/iio:device0> echo 1 > ./scan_elements/in_accel_z_en

        root:/sys/bus/iio/devices/iio:device0> echo 14   > ./in_accel_x_calibbias
        root:/sys/bus/iio/devices/iio:device0> echo 2    > ./in_accel_y_calibbias
        root:/sys/bus/iio/devices/iio:device0> echo -250 > ./in_accel_z_calibbias

        root:/sys/bus/iio/devices/iio:device0> echo 24 > ./buffer0/length

        ## AC coupled activity, threshold [62.5/LSB]
        root:/sys/bus/iio/devices/iio:device0> echo 6 > ./events/in_accel_mag_adaptive_rising_value

        ## AC coupled inactivity, threshold, [62.5/LSB]
        root:/sys/bus/iio/devices/iio:device0> echo 4 > ./events/in_accel_mag_adaptive_falling_value

        ## AC coupled inactivity, time [s]
        root:/sys/bus/iio/devices/iio:device0> echo 3 > ./events/in_accel_mag_adaptive_falling_period

        ## singletap, threshold
        root:/sys/bus/iio/devices/iio:device0> echo 35 > ./events/in_accel_gesture_singletap_value

        ## singletap, duration [us]
        root:/sys/bus/iio/devices/iio:device0> echo 0.001875  > ./events/in_accel_gesture_singletap_timeout

        ## doubletap, window [us]
        root:/sys/bus/iio/devices/iio:device0> echo 0.025 > ./events/in_accel_gesture_doubletap_reset_timeout

        ## doubletap, latent [us]
        root:/sys/bus/iio/devices/iio:device0> echo 0.025 > ./events/in_accel_gesture_doubletap_tap2_min_delay

        ## AC coupled activity, enable
        root:/sys/bus/iio/devices/iio:device0> echo 1 > ./events/in_accel_mag_adaptive_rising_en

        ## AC coupled inactivity, enable
        root:/sys/bus/iio/devices/iio:device0> echo 1 > ./events/in_accel_x\&y\&z_mag_adaptive_falling_en

        ## singletap, enable
        root:/sys/bus/iio/devices/iio:device0> echo 1 > ./events/in_accel_x_gesture_singletap_en
        root:/sys/bus/iio/devices/iio:device0> echo 1 > ./events/in_accel_y_gesture_singletap_en
        root:/sys/bus/iio/devices/iio:device0> echo 1 > ./events/in_accel_z_gesture_singletap_en

        ## doubletap, enable
        root:/sys/bus/iio/devices/iio:device0> echo 1 > ./events/in_accel_gesture_doubletap_en

Xác minh các sự kiện đến:

.. code-block:: bash

        root:# iio_event_monitor adxl345
        Found IIO device with name adxl345 with device number 0
        Event: time: 1739063415957073383, type: accel(z), channel: 0, evtype: mag, direction: rising
        Event: time: 1739063415963770218, type: accel(z), channel: 0, evtype: mag, direction: rising
        Event: time: 1739063416002563061, type: accel(z), channel: 0, evtype: gesture, direction: singletap
        Event: time: 1739063426271128739, type: accel(x&y&z), channel: 0, evtype: mag, direction: falling
        Event: time: 1739063436539080713, type: accel(x&y&z), channel: 0, evtype: mag, direction: falling
        Event: time: 1739063438357970381, type: accel(z), channel: 0, evtype: mag, direction: rising
        Event: time: 1739063446726161586, type: accel(z), channel: 0, evtype: mag, direction: rising
        Event: time: 1739063446727892670, type: accel(z), channel: 0, evtype: mag, direction: rising
        Event: time: 1739063446743019768, type: accel(z), channel: 0, evtype: mag, direction: rising
        Event: time: 1739063446744650696, type: accel(z), channel: 0, evtype: mag, direction: rising
        Event: time: 1739063446763559386, type: accel(z), channel: 0, evtype: gesture, direction: singletap
        Event: time: 1739063448818126480, type: accel(x&y&z), channel: 0, evtype: mag, direction: falling
        ...

Hoạt động và không hoạt động thuộc về nhau và biểu thị các thay đổi trạng thái như sau

.. code-block:: bash

        root:# iio_event_monitor adxl345
        Found IIO device with name adxl345 with device number 0
        Event: time: 1744648001133946293, type: accel(x), channel: 0, evtype: mag, direction: rising
          <after inactivity time elapsed>
        Event: time: 1744648057724775499, type: accel(x&y&z), channel: 0, evtype: mag, direction: falling
        ...

3. Bộ đệm thiết bị
=================

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

Đặt số lượng mẫu sẽ được lưu trong bộ đệm:

.. code-block:: bash

        root:/sys/bus/iio/devices/iio:device0> echo 10 > buffer/length

Kích hoạt tính năng đọc bộ đệm:

.. code-block:: bash

        root:/sys/bus/iio/devices/iio:device0> echo 1 > buffer/enable

Lấy dữ liệu đệm:

.. code-block:: bash

        root:> iio_readdev -b 16 -s 1024 adxl345 | hexdump -d
        WARNING: High-speed mode not enabled
        0000000   00003   00012   00013   00005   00010   00011   00005   00011
        0000010   00013   00004   00012   00011   00003   00012   00014   00007
        0000020   00011   00013   00004   00013   00014   00003   00012   00013
        0000030   00004   00012   00013   00005   00011   00011   00005   00012
        0000040   00014   00005   00012   00014   00004   00010   00012   00004
        0000050   00013   00011   00003   00011   00012   00005   00011   00013
        0000060   00003   00012   00012   00003   00012   00012   00004   00012
        0000070   00012   00003   00013   00013   00003   00013   00012   00005
        0000080   00012   00013   00003   00011   00012   00005   00012   00013
        0000090   00003   00013   00011   00005   00013   00014   00003   00012
        00000a0   00012   00003   00012   00013   00004   00012   00015   00004
        00000b0   00014   00011   00003   00014   00013   00004   00012   00011
        00000c0   00004   00012   00013   00004   00014   00011   00004   00013
        00000d0   00012   00002   00014   00012   00005   00012   00013   00005
        00000e0   00013   00013   00003   00013   00013   00005   00012   00013
        00000f0   00004   00014   00015   00005   00012   00011   00005   00012
        ...

Xem Documentation/iio/iio_devbuf.rst để biết thêm thông tin về cách lưu vào bộ đệm
dữ liệu được cấu trúc.

4. Công cụ giao tiếp IIO
========================

Xem Documentation/iio/iio_tools.rst để biết mô tả về IIO có sẵn
các công cụ giao tiếp.