.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/camera-sensor.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _media_writing_camera_sensor_drivers:

Viết trình điều khiển cảm biến máy ảnh
======================================

Tài liệu này chỉ bao gồm các API trong kernel. Để biết các phương pháp hay nhất về
triển khai API trong không gian người dùng trong trình điều khiển cảm biến máy ảnh, vui lòng xem
ZZ0000ZZ.

Xe buýt CSI-2, song song và BT.656
----------------------------------

Vui lòng xem ZZ0000ZZ.

Xử lý đồng hồ
---------------

Cảm biến máy ảnh có cây đồng hồ bên trong bao gồm PLL và một số
số chia. Cây đồng hồ thường được cấu hình bởi trình điều khiển dựa trên một số
tham số đầu vào dành riêng cho phần cứng: tần số xung nhịp bên ngoài
và tần số liên kết. Hai tham số thường được lấy từ hệ thống
phần sụn. ZZ0000ZZ

Lý do tại sao tần số đồng hồ lại quan trọng đến vậy là vì tín hiệu đồng hồ
ra khỏi SoC và trong nhiều trường hợp, một tần số cụ thể được thiết kế để
được sử dụng trong hệ thống. Sử dụng tần số khác có thể gây ra tác hại
ở nơi khác. Do đó chỉ có các tần số được xác định trước mới có thể được cấu hình bởi
người dùng.

Tần số đồng hồ bên ngoài sẽ được lấy bằng cách lấy đồng hồ bên ngoài
bằng cách sử dụng chức năng trợ giúp ZZ0000ZZ và sau đó nhận được
tần số với ZZ0001ZZ. Việc sử dụng chức năng trợ giúp đảm bảo
hành vi chính xác bất kể cảm biến có được tích hợp trong thiết bị dựa trên DT hay không
hoặc hệ thống dựa trên ACPI.

ACPI
~~~~

Các hệ thống dựa trên ACPI thường không đăng ký đồng hồ bên ngoài cảm biến với
kernel, nhưng chỉ định tần số xung nhịp bên ngoài trong ZZ0000ZZ
Thuộc tính _DSD. Trình trợ giúp ZZ0001ZZ tạo và trả về một
đồng hồ cố định được đặt ở tốc độ đó.

cây thiết bị
~~~~~~~~~~~~

Các hệ thống dựa trên cây thiết bị khai báo đồng hồ bên ngoài cảm biến trong cây thiết bị
và tham chiếu nó từ nút cảm biến. Cách ưa thích để chọn bên ngoài
tần số xung nhịp là sử dụng ZZ0000ZZ, ZZ0001ZZ
và thuộc tính ZZ0002ZZ trong nút cảm biến để đặt đồng hồ
tỷ lệ. Xem ZZ0004ZZ
để biết thêm thông tin. Trình trợ giúp ZZ0003ZZ truy xuất và
trả lại chiếc đồng hồ đó.

Cách tiếp cận này có nhược điểm là không đảm bảo rằng tần số
chưa được sửa đổi trực tiếp hoặc gián tiếp bởi trình điều khiển khác hoặc được hỗ trợ bởi
cây đồng hồ của bảng để bắt đầu. Những thay đổi đối với Khung đồng hồ chung API
cần thiết để đảm bảo độ tin cậy.

Quản lý nguồn điện
------------------

Cảm biến camera được sử dụng kết hợp với các thiết bị khác để tạo thành camera
đường ống. Họ phải tuân theo các quy tắc được liệt kê ở đây để đảm bảo quyền lực mạch lạc
quản lý trên đường ống.

Trình điều khiển cảm biến camera có nhiệm vụ kiểm soát trạng thái nguồn của
thiết bị mà họ cũng kiểm soát. Họ sẽ sử dụng PM thời gian chạy để quản lý
các trạng thái quyền lực. PM thời gian chạy sẽ được bật tại thời điểm thăm dò và tắt khi xóa
thời gian. Trình điều khiển nên kích hoạt tính năng tự động tạm dừng PM thời gian chạy. Cũng xem
ZZ0000ZZ.

Trình xử lý PM thời gian chạy sẽ xử lý đồng hồ, bộ điều chỉnh, GPIO và các
tài nguyên hệ thống cần thiết để cấp nguồn cho cảm biến lên xuống. Đối với những người lái xe mà
không sử dụng bất kỳ tài nguyên nào trong số đó (chẳng hạn như trình điều khiển hỗ trợ hệ thống ACPI
chỉ), trình xử lý PM thời gian chạy có thể không được triển khai.

Nói chung, thiết bị phải được bật nguồn ít nhất khi các thanh ghi của nó được
đang được truy cập và khi nó đang phát trực tuyến. Người lái xe nên sử dụng
ZZ0000ZZ khi bắt đầu truyền phát và
ZZ0001ZZ hoặc ZZ0002ZZ khi dừng
phát trực tuyến. Họ có thể cấp nguồn cho thiết bị vào thời điểm thăm dò (ví dụ để đọc
thanh ghi nhận dạng), nhưng không nên cấp nguồn vô điều kiện sau
thăm dò.

Tại thời điểm hệ thống tạm dừng, toàn bộ đường dẫn camera phải ngừng phát trực tuyến và
khởi động lại khi hệ thống được nối lại. Điều này đòi hỏi sự phối hợp giữa các
cảm biến camera và phần còn lại của đường ống camera. Trình điều khiển cầu là
chịu trách nhiệm về sự phối hợp này và hướng dẫn các cảm biến camera dừng và
khởi động lại phát trực tuyến bằng cách gọi các hoạt động subdev thích hợp
(ZZ0000ZZ hoặc ZZ0001ZZ). Trình điều khiển cảm biến camera sẽ
do đó ZZ0002ZZ theo dõi trạng thái phát trực tuyến để ngừng phát trực tuyến trong PM
tạm dừng xử lý và khởi động lại nó trong trình xử lý sơ yếu lý lịch. Nói chung người lái xe nên
không triển khai các trình xử lý PM của hệ thống.

Trình điều khiển cảm biến máy ảnh ZZ0003ZZ sẽ triển khai ZZ0000ZZ subdev
hoạt động, vì nó không được dùng nữa. Trong khi hoạt động này được thực hiện ở một số
trình điều khiển hiện tại trước khi ngừng sử dụng, trình điều khiển mới sẽ sử dụng thời gian chạy
Thay vào đó hãy PM. Nếu bạn cảm thấy cần bắt đầu gọi ZZ0001ZZ từ ISP hoặc
trình điều khiển cầu nối, thay vào đó hãy thêm hỗ trợ PM thời gian chạy cho trình điều khiển cảm biến mà bạn đang có
sử dụng và thả trình xử lý ZZ0002ZZ của nó.

Vui lòng xem thêm ZZ0000ZZ.

Khung kiểm soát
~~~~~~~~~~~~~~~~~

Chức năng ZZ0000ZZ có thể không được sử dụng trong thời gian chạy của thiết bị
Gọi lại PM ZZ0001ZZ, vì nó không có cách nào để tìm ra trạng thái nguồn
của thiết bị. Điều này là do trạng thái nguồn của thiết bị chỉ được thay đổi
sau khi quá trình chuyển đổi trạng thái năng lượng diễn ra. Cuộc gọi lại ZZ0002ZZ có thể
được sử dụng để lấy trạng thái nguồn của thiết bị sau khi chuyển đổi trạng thái nguồn:

.. c:function:: int pm_runtime_get_if_in_use(struct device *dev);

Hàm trả về một giá trị khác 0 nếu nó thành công trong việc lấy số lũy thừa hoặc
thời gian chạy PM đã bị vô hiệu hóa, trong một trong hai trường hợp đó, trình điều khiển có thể tiếp tục
truy cập vào thiết bị.

Xoay, định hướng và lật
----------------------------------

Sử dụng ZZ0000ZZ để xoay và định hướng
thông tin từ phần sụn hệ thống và ZZ0001ZZ tới
đăng ký các điều khiển thích hợp.

.. _media-camera-sensor-examples:

Trình điều khiển mẫu
--------------------

Các tính năng do trình điều khiển cảm biến triển khai sẽ khác nhau và tùy thuộc vào bộ
các tính năng được hỗ trợ và các phẩm chất khác, trình điều khiển cảm biến cụ thể sẽ phục vụ tốt hơn
mục đích của một ví dụ Các trình điều khiển sau đây được coi là ví dụ điển hình:

.. flat-table:: Example sensor drivers
    :header-rows: 0
    :widths:      1 1 1 2

    * - Driver name
      - File(s)
      - Driver type
      - Example topic
    * - CCS
      - ``drivers/media/i2c/ccs/``
      - Freely configurable
      - Power management (ACPI and DT), UAPI
    * - imx219
      - ``drivers/media/i2c/imx219.c``
      - Register list based
      - Power management (DT), UAPI, mode selection
    * - imx319
      - ``drivers/media/i2c/imx319.c``
      - Register list based
      - Power management (ACPI and DT)