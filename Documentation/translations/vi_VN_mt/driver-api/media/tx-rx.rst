.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/tx-rx.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _transmitter-receiver:

Trình điều khiển máy phát và máy thu dữ liệu pixel
==================================================

V4L2 hỗ trợ nhiều thiết bị khác nhau truyền và nhận dữ liệu pixel. Ví dụ về
các thiết bị này bao gồm cảm biến camera, bộ thu sóng TV và thiết bị song song, BT.656 hoặc
Bộ thu CSI-2 trong SoC.

Các loại xe buýt
----------------

Các xe buýt sau đây là phổ biến nhất. Phần này chỉ thảo luận về hai điều này.

MIPI CSI-2
^^^^^^^^^^

CSI-2 là bus dữ liệu dùng để truyền hình ảnh từ máy ảnh sang
SoC chủ. Nó được xác định bởi ZZ0000ZZ.

.. _`MIPI alliance`: https://www.mipi.org/

Song song và BT.656
^^^^^^^^^^^^^^^^^^^

Các bus song song và ZZ0000ZZ vận chuyển một bit dữ liệu trên mỗi chu kỳ xung nhịp
trên mỗi dòng dữ liệu. Bus song song sử dụng tính năng đồng bộ hóa và các tính năng bổ sung khác
tín hiệu trong khi BT.656 nhúng đồng bộ hóa.

.. _`BT.656`: https://en.wikipedia.org/wiki/ITU-R_BT.656

Trình điều khiển máy phát
-------------------------

Trình điều khiển máy phát thường cần cung cấp cho trình điều khiển máy thu thông tin
cấu hình của máy phát. Những gì được yêu cầu phụ thuộc vào loại
xe buýt. Đây là điểm chung cho cả hai xe buýt.

Mã pixel bus phương tiện
^^^^^^^^^^^^^^^^^^^^^^^^

Xem ZZ0000ZZ.

Tần số liên kết
^^^^^^^^^^^^^^^

Điều khiển ZZ0000ZZ được sử dụng để báo cho
nhận tần số của bus (tức là nó không giống với tốc độ ký hiệu).

Trình điều khiển không có tần số liên kết do người dùng định cấu hình nên báo cáo nó
thông qua hoạt động của bảng phụ ZZ0000ZZ, trong ZZ0001ZZ
trường struct v4l2_mbus_config, thay vì thông qua các điều khiển.

Trình điều khiển máy thu nên sử dụng trình trợ giúp ZZ0000ZZ để có được
tần số liên kết từ thiết bị phụ máy phát.

Lệnh gọi lại ZZ0000ZZ và ZZ0001ZZ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Cấu trúc v4l2_subdev_pad_ops->enable_streams() và struct
Lệnh gọi lại v4l2_subdev_pad_ops->disable_streams() được trình điều khiển máy thu sử dụng
để kiểm soát trạng thái truyền phát của trình điều khiển máy phát. Những cuộc gọi lại này có thể không
được gọi trực tiếp nhưng bằng cách sử dụng ZZ0000ZZ và
ZZ0001ZZ.

Dừng máy phát
^^^^^^^^^^^^^^^^^^^^^^^^

Máy phát ngừng gửi luồng hình ảnh do
gọi lại cuộc gọi lại ZZ0000ZZ. Một số máy phát có thể dừng
truyền phát ở ranh giới khung trong khi các luồng khác dừng ngay lập tức,
để lại khung hình hiện tại chưa hoàn thành một cách hiệu quả. Trình điều khiển máy thu
không nên đưa ra các giả định theo cách nào đó mà phải hoạt động đúng đắn trong cả hai
trường hợp.

Trình điều khiển máy phát CSI-2
-------------------------------

Tỷ lệ pixel
^^^^^^^^^^^

Tỷ lệ pixel trên bus được tính như sau::

pixel_rate = link_freq * 2 * nr_of_lanes * 16 / k / bit_per_sample

Ở đâu

.. list-table:: variables in pixel rate calculation
   :header-rows: 1

   * - variable or constant
     - description
   * - link_freq
     - The value of the ``V4L2_CID_LINK_FREQ`` integer64 menu item.
   * - nr_of_lanes
     - Number of data lanes used on the CSI-2 link.
   * - 2
     - Data is transferred on both rising and falling edge of the signal.
   * - bits_per_sample
     - Number of bits per sample.
   * - k
     - 16 for D-PHY and 7 for C-PHY.

Thông tin về việc D-PHY hay C-PHY được sử dụng và giá trị của ZZ0000ZZ có thể được lấy từ cấu hình điểm cuối OF.

.. note::

	The pixel rate calculated this way is **not** the same thing as the
	pixel rate on the camera sensor's pixel array which is indicated by the
	:ref:`V4L2_CID_PIXEL_RATE <v4l2-cid-pixel-rate>` control.

Trạng thái LP-11 và LP-111
^^^^^^^^^^^^^^^^^^^^^^^^^^

Là một phần của việc chuyển sang chế độ tốc độ cao, máy phát CSI-2 thường
nhanh chóng đặt bus về trạng thái LP-11 hoặc LP-111, tùy thuộc vào PHY. Thời kỳ này
có thể ngắn tới 100 µs, trong thời gian đó máy thu quan sát trạng thái này và
tiến hành phần riêng của mình trong quá trình chuyển đổi chế độ tốc độ cao.

Hầu hết các máy thu đều có khả năng tự động xử lý việc này một khi phần mềm đã
đã cấu hình chúng để làm như vậy, nhưng có những máy thu yêu cầu phần mềm
tham gia quan sát trạng thái LP-11 hoặc LP-111. 100 µs là khoảng thời gian ngắn để đạt được
trong phần mềm, đặc biệt là khi không có sự ngắt quãng khi thông báo điều gì đó đang diễn ra
đang xảy ra.

Một cách để giải quyết vấn đề này là cấu hình rõ ràng phía máy phát thành LP-11
hoặc trạng thái LP-111, yêu cầu hỗ trợ từ phần cứng máy phát. Đây là
không có sẵn phổ biến. Nhiều thiết bị trở lại trạng thái này sau khi kết thúc phát trực tuyến
dừng trong khi trạng thái sau khi bật nguồn là LP-00 hoặc LP-000.

Cuộc gọi lại ZZ0000ZZ có thể được sử dụng để chuẩn bị máy phát cho
chuyển sang trạng thái phát trực tuyến nhưng chưa bắt đầu phát trực tuyến. Tương tự, các
Lệnh gọi lại ZZ0001ZZ được sử dụng để hoàn tác những gì đã được thực hiện bởi
Gọi lại ZZ0002ZZ. Do đó, người gọi ZZ0003ZZ là bắt buộc
để gọi ZZ0004ZZ cho mỗi cuộc gọi thành công của ZZ0005ZZ.

Trong ngữ cảnh của CSI-2, lệnh gọi lại ZZ0000ZZ được sử dụng để chuyển đổi
máy phát sang trạng thái LP-11 hoặc LP-111. Điều này cũng yêu cầu bật nguồn
thiết bị, vì vậy việc này chỉ nên được thực hiện khi cần thiết.

Trình điều khiển máy thu không cần thiết lập trạng thái LP-11 hoặc LP-111 rõ ràng là
từ bỏ việc gọi hai cuộc gọi lại.