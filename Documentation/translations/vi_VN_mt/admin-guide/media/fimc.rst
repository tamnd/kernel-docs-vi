.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/fimc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

Trình điều khiển Samsung S5P/Exynos4 FIMC
=========================================

Bản quyền ZZ0000ZZ 2012 - 2013 Công ty TNHH Điện tử Samsung

Thiết bị FIMC (Camera di động tương tác hoàn toàn) đã có mặt tại Samsung
Bộ xử lý ứng dụng SoC là giao diện máy chủ tích hợp camera, màu sắc
bộ chuyển đổi không gian, bộ thay đổi kích thước hình ảnh và bộ quay vòng.  Nó cũng có khả năng bắt
dữ liệu từ bộ điều khiển LCD (FIMD) thông qua dữ liệu ghi lại nội bộ SoC
con đường.  Có nhiều phiên bản FIMC trong SoC (tối đa 4), có
các khả năng hơi khác một chút, như ràng buộc căn chỉnh pixel, công cụ quay vòng
tính khả dụng, hỗ trợ ghi lại LCD, v.v. Trình điều khiển được đặt tại
thư mục driver/media/platform/samsung/exynos4-is.

SoC được hỗ trợ
---------------

S5PC100 (chỉ mem-to-mem), S5PV210, Exynos4210

Các tính năng được hỗ trợ
-------------------------

- chụp giao diện song song của camera (ITU-R.BT601/565);
- chụp giao diện nối tiếp máy ảnh (MIPI-CSI2);
- xử lý bộ nhớ sang bộ nhớ (chuyển đổi không gian màu, chia tỷ lệ, phản chiếu
  và luân chuyển);
- cấu hình lại đường ống động trong thời gian chạy (đính kèm lại bất kỳ FIMC nào
  ví dụ với bất kỳ đầu vào video song song nào hoặc bất kỳ giao diện người dùng MIPI-CSI nào);
- thời gian chạy PM và tạm dừng/tiếp tục trên toàn hệ thống

Hiện không được hỗ trợ
-----------------------

- Đầu vào ghi lại LCD
- mỗi khung đồng hồ đo (mem-to-mem)

Giao diện không gian người dùng
-------------------------------

Giao diện thiết bị truyền thông
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Trình điều khiển hỗ trợ Bộ điều khiển phương tiện API như được xác định tại ZZ0000ZZ.
Tên trình điều khiển thiết bị đa phương tiện là "Samsung S5P FIMC".

Mục đích của giao diện này là cho phép thay đổi việc gán các phiên bản FIMC
tới đầu vào camera ngoại vi SoC trong thời gian chạy và tùy chọn để điều khiển nội bộ
kết nối của (các) thiết bị MIPI-CSIS với các thực thể FIMC.

Giao diện thiết bị đa phương tiện cho phép cấu hình SoC để chụp ảnh
dữ liệu từ cảm biến thông qua nhiều phiên bản FIMC (ví dụ: để xử lý đồng thời
kính ngắm và thiết lập chụp ảnh tĩnh).

Việc cấu hình lại được thực hiện bằng cách bật/tắt các liên kết phương tiện do trình điều khiển tạo
trong quá trình khởi tạo. Cấu trúc liên kết của thiết bị nội bộ có thể dễ dàng được phát hiện
thông qua thực thể truyền thông và liệt kê liên kết.

Nút video bộ nhớ-bộ nhớ
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Giao diện bộ nhớ với bộ nhớ V4L2 tại/dev/video? nút thiết bị.  Đây là độc lập
thiết bị video, nó không có media pad. Tuy nhiên xin lưu ý mem-to-mem và
không cho phép hoạt động ghi lại nút video trên cùng một phiên bản FIMC.  Người lái xe
phát hiện những trường hợp như vậy nhưng các ứng dụng nên ngăn chặn chúng để tránh
hành vi không xác định.

Nút quay video
~~~~~~~~~~~~~~~~~~

Trình điều khiển hỗ trợ Giao diện quay video V4L2 như được xác định tại
ZZ0000ZZ.

Tại các nút quay và video mem-to-mem, chỉ có API đa mặt phẳng là
được hỗ trợ. Để biết thêm chi tiết, xem: ZZ0000ZZ.

Các nhà phát triển phụ chụp ảnh bằng máy ảnh
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mỗi phiên bản FIMC xuất một nút thiết bị phụ (/dev/v4l-subdev?), một thiết bị phụ
nút cũng được tạo cho mỗi nút có sẵn và được kích hoạt ở cấp nền tảng
Thiết bị thu MIPI-CSI (hiện có tối đa hai).

sysfs
~~~~~

Để cho phép điều khiển đường dẫn camera chính xác hơn thông qua thiết bị phụ
Trình điều khiển API tạo mục nhập sysfs được liên kết với nền tảng "s5p-fimc-md"
thiết bị. Đường dẫn vào là: /sys/platform/devices/s5p-fimc-md/subdev_conf_mode.

Trong trường hợp sử dụng thông thường, có thể có cấu hình đường dẫn chụp sau:
subdev cảm biến -> subdev mipi-csi -> subdev fimc -> nút video

Khi chúng tôi định cấu hình các thiết bị này thông qua thiết bị phụ API tại không gian người dùng,
luồng cấu hình phải từ trái sang phải và nút video là
được cấu hình như cái cuối cùng.

Khi chúng tôi không sử dụng không gian người dùng thiết bị phụ API, toàn bộ cấu hình của tất cả
các thiết bị thuộc đường ống được thực hiện tại trình điều khiển nút video.
Mục sysfs cho phép hướng dẫn trình điều khiển nút chụp không định cấu hình
các thiết bị phụ (định dạng, cắt xén), để tránh đặt lại cấu hình của các thiết bị phụ
khi các bước cấu hình cuối cùng tại nút video được thực hiện.

Để được hỗ trợ điều khiển thiết bị phụ đầy đủ (các nhà phát triển phụ được định cấu hình tại không gian người dùng trước đó
bắt đầu truyền phát):

.. code-block:: none

	# echo "sub-dev" > /sys/platform/devices/s5p-fimc-md/subdev_conf_mode

Chỉ dành cho điều khiển nút video V4L2 (các nhà phát triển phụ được máy chủ định cấu hình nội bộ
người lái xe):

.. code-block:: none

	# echo "vid-dev" > /sys/platform/devices/s5p-fimc-md/subdev_conf_mode

Đây là một tùy chọn mặc định.

5. Ánh xạ thiết bị tới các nút thiết bị video và subdev
-------------------------------------------------------

Có hai nút thiết bị video được liên kết với mỗi phiên bản thiết bị trong
phần cứng - quay video và mem-to-mem và thêm vào đó là nút subdev cho
điều khiển hệ thống con chụp FIMC chính xác hơn. Ngoài ra còn có v4l2 riêng
nút thiết bị phụ được tạo trên mỗi thiết bị MIPI-CSIS.

Làm cách nào để tìm ra/dev/video? hoặc/dev/v4l-subdev? được giao cho cái nào
thiết bị?

Bạn có thể grep thông qua nhật ký kernel để tìm thông tin liên quan, tức là.

.. code-block:: none

	# dmesg | grep -i fimc

(lưu ý rằng udev, nếu có, vẫn có thể sắp xếp lại các nút video),

hoặc lấy thông tin từ/dev/media? với sự trợ giúp của công cụ media-ctl:

.. code-block:: none

	# media-ctl -p

7. Xây dựng
-----------

Nếu trình điều khiển được xây dựng dưới dạng mô-đun hạt nhân có thể tải được (CONFIG_VIDEO_SAMSUNG_S5P_FIMC=m)
hai mô-đun được tạo (ngoài các mô-đun lõi v4l2): s5p-fimc.ko và
tùy chọn s5p-csis.ko (subdev máy thu MIPI-CSI).