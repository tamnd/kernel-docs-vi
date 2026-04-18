.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/driver-model/binding.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================
Ràng buộc trình điều khiển
==============

Liên kết trình điều khiển là quá trình liên kết một thiết bị với một thiết bị
trình điều khiển có thể điều khiển nó. Tài xế xe buýt thường xử lý việc này
bởi vì đã có những cấu trúc dành riêng cho xe buýt để thể hiện
thiết bị và trình điều khiển. Với thiết bị chung và trình điều khiển thiết bị
cấu trúc, hầu hết các ràng buộc có thể diễn ra bằng cách sử dụng mã chung.


xe buýt
~~~

Cấu trúc kiểu bus chứa danh sách tất cả các thiết bị trên bus đó
gõ vào hệ thống. Khi device_register được gọi cho một thiết bị, nó là
được chèn vào cuối danh sách này. Đối tượng xe buýt cũng chứa một
danh sách tất cả các trình điều khiển của loại xe buýt đó. Khi driver_register được gọi
đối với trình điều khiển, nó được chèn vào cuối danh sách này. Đây là những
hai sự kiện kích hoạt liên kết trình điều khiển.


thiết bị_đăng ký
~~~~~~~~~~~~~~~

Khi một thiết bị mới được thêm vào, danh sách trình điều khiển của xe buýt sẽ được lặp lại
để tìm một cái hỗ trợ nó. Để xác định được điều đó, thiết bị
ID của thiết bị phải khớp với một trong các ID thiết bị mà trình điều khiển
hỗ trợ. Định dạng và ngữ nghĩa để so sánh ID là dành riêng cho từng bus.
Thay vì cố gắng tạo ra một máy trạng thái phức tạp và kết hợp
thuật toán, tài xế xe buýt có thể cung cấp lệnh gọi lại để so sánh
một thiết bị dựa trên ID của trình điều khiển. Xe buýt trả về 1 nếu có kết quả trùng khớp
tìm thấy; 0 nếu không.

int match(struct device * dev, struct device_driver * drv);

Nếu tìm thấy kết quả khớp, trường trình điều khiển của thiết bị sẽ được đặt thành trình điều khiển
và cuộc gọi lại thăm dò của trình điều khiển được gọi. Điều này mang lại cho người lái xe một
cơ hội để xác minh rằng nó thực sự hỗ trợ phần cứng và
nó đang ở trạng thái hoạt động.

Lớp thiết bị
~~~~~~~~~~~~

Sau khi hoàn thành thăm dò thành công, thiết bị sẽ được đăng ký với
lớp mà nó thuộc về. Trình điều khiển thiết bị thuộc về một và chỉ một
class và được đặt trong trường devclass của trình điều khiển.
devclass_add_device được gọi để liệt kê thiết bị trong lớp
và thực sự đăng ký nó với lớp, điều này xảy ra với
cuộc gọi lại register_dev của lớp.


Tài xế
~~~~~~

Khi một trình điều khiển được gắn vào một thiết bị, chức năng thăm dò() của trình điều khiển là
được gọi. Trong phạm vi thăm dò(), trình điều khiển khởi tạo thiết bị và phân bổ
và khởi tạo cấu trúc dữ liệu trên mỗi thiết bị. Trạng thái trên mỗi thiết bị này là
được liên kết với đối tượng thiết bị miễn là trình điều khiển vẫn bị ràng buộc
đến nó. Về mặt khái niệm, dữ liệu trên mỗi thiết bị này cùng với sự ràng buộc với
thiết bị có thể được coi là một phiên bản của trình điều khiển.

sysfs
~~~~~

Một liên kết tượng trưng được tạo trong thư mục 'thiết bị' của xe buýt trỏ đến
thư mục của thiết bị trong hệ thống phân cấp vật lý.

Một liên kết tượng trưng được tạo trong thư mục 'thiết bị' của trình điều khiển trỏ tới
vào thư mục của thiết bị trong hệ thống phân cấp vật lý.

Một thư mục cho thiết bị được tạo trong thư mục của lớp. A
liên kết tượng trưng được tạo trong thư mục đó trỏ đến thiết bị
vị trí vật lý trong cây sysfs.

Một liên kết tượng trưng có thể được tạo (mặc dù điều này chưa được thực hiện) trong thư mục của thiết bị.
thư mục vật lý vào thư mục lớp của nó hoặc thư mục của lớp
thư mục cấp cao nhất. Một cái cũng có thể được tạo để trỏ đến trình điều khiển của nó
thư mục cũng có.


tài xế_đăng ký
~~~~~~~~~~~~~~~

Quá trình này gần như giống hệt khi thêm trình điều khiển mới.
Danh sách thiết bị của xe buýt được lặp đi lặp lại để tìm kết quả phù hợp. Thiết bị
đã có trình điều khiển sẽ được bỏ qua. Tất cả các thiết bị đều được lặp lại
hơn, để liên kết càng nhiều thiết bị càng tốt với trình điều khiển.


Loại bỏ
~~~~~~~

Khi một thiết bị bị xóa, số tham chiếu của thiết bị đó cuối cùng sẽ
chuyển về 0. Khi đó, lệnh gọi lại loại bỏ trình điều khiển sẽ được gọi. Nó
bị xóa khỏi danh sách thiết bị của trình điều khiển và số lượng tham chiếu
của người lái xe bị giảm đi. Tất cả các liên kết tượng trưng giữa hai đều bị loại bỏ.

Khi gỡ bỏ trình điều khiển, danh sách các thiết bị mà nó hỗ trợ là
lặp đi lặp lại và lệnh gọi lại loại bỏ của trình điều khiển được gọi cho mỗi
một. Thiết bị bị xóa khỏi danh sách đó và các liên kết tượng trưng bị xóa.


Ghi đè trình điều khiển
~~~~~~~~~~~~~~~

Không gian người dùng có thể ghi đè kết hợp tiêu chuẩn bằng cách viết tên trình điều khiển vào
thuộc tính sysfs ZZ0000ZZ của thiết bị.  Khi cài thì chỉ có driver thôi
có tên khớp với thông tin ghi đè sẽ được xem xét trong quá trình ràng buộc.  Cái này
bỏ qua tất cả các kết hợp dành riêng cho xe buýt (OF, ACPI, bảng ID, v.v.).

Việc ghi đè có thể được xóa bằng cách viết một chuỗi trống, trả về
thiết bị theo quy tắc kết hợp tiêu chuẩn.  Viết thư cho ZZ0000ZZ
không tự động hủy liên kết thiết bị khỏi trình điều khiển hiện tại hoặc
thực hiện bất kỳ nỗ lực nào để tải trình điều khiển được chỉ định.

Xe buýt chọn tham gia cơ chế này bằng cách đặt cờ ZZ0000ZZ trong
ZZ0001ZZ của họ::

const struct bus_type ví dụ_bus_type = {
      ...
.driver_override = đúng,
  };

Khi cờ được đặt, lõi trình điều khiển sẽ tự động tạo
Thuộc tính sysfs ZZ0000ZZ cho mọi thiết bị trên xe buýt đó.

Cuộc gọi lại ZZ0000ZZ của xe buýt nên kiểm tra ghi đè trước khi thực hiện
kết hợp riêng của nó, sử dụng ZZ0001ZZ::

static int example_match(thiết bị cấu trúc *dev, const struct device_driver *drv)
  {
      int ret;

ret = device_match_driver_override(dev, drv);
      nếu (ret >= 0)
          trở lại ret;

/* Chuyển sang đối sánh cụ thể với xe buýt... */
  }

ZZ0000ZZ trả về > 0 nếu phần ghi đè khớp
trình điều khiển đã cho, 0 nếu ghi đè được đặt nhưng không khớp hoặc < 0 nếu
không có ghi đè nào được đặt cả.

Người trợ giúp bổ sung có sẵn:

- ZZ0000ZZ - đặt hoặc xóa phần ghi đè khỏi mã hạt nhân.
- ZZ0001ZZ - kiểm tra xem cài đặt ghi đè có được đặt hay không.
