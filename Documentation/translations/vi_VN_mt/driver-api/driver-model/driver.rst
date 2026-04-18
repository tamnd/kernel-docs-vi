.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/driver-model/driver.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================
Trình điều khiển thiết bị
=========================

Xem kerneldoc để biết struct device_driver.

Phân bổ
~~~~~~~~~~

Trình điều khiển thiết bị là các cấu trúc được phân bổ tĩnh. Mặc dù có thể có
là nhiều thiết bị trong một hệ thống mà trình điều khiển hỗ trợ, struct
device_driver đại diện cho toàn bộ trình điều khiển (không phải một trình điều khiển cụ thể
phiên bản thiết bị).

Khởi tạo
~~~~~~~~~~~~~~

Trình điều khiển phải khởi tạo ít nhất các trường tên và bus. Nó nên
cũng khởi tạo trường devclass (khi nó đến), do đó nó có thể nhận được
mối liên kết nội bộ phù hợp. Nó cũng nên khởi tạo càng nhiều
các cuộc gọi lại càng tốt, mặc dù mỗi cuộc gọi lại là tùy chọn.

Tuyên ngôn
~~~~~~~~~~~

Như đã nêu ở trên, các đối tượng struct device_driver ở trạng thái tĩnh
được phân bổ. Dưới đây là một tuyên bố ví dụ về eepro100
người lái xe. Tuyên bố này chỉ mang tính giả thuyết; nó phụ thuộc vào trình điều khiển
đang được chuyển đổi hoàn toàn sang mô hình mới::

cấu trúc tĩnh device_driver eepro100_driver = {
         .name = "eepro100",
         .bus = &pci_bus_type,

.probe = eepro100_probe,
         .remove = eepro100_remove,
         .suspend = eepro100_suspend,
         .resume = eepro100_resume,
  };

Hầu hết các trình điều khiển sẽ không thể chuyển đổi hoàn toàn sang phiên bản mới
mô hình vì xe buýt mà họ sở hữu có cấu trúc dành riêng cho xe buýt với
các trường cụ thể của xe buýt không thể khái quát hóa được.

Ví dụ phổ biến nhất về điều này là cấu trúc ID thiết bị. Một người lái xe
thường xác định một mảng ID thiết bị mà nó hỗ trợ. Định dạng
của các cấu trúc này và ngữ nghĩa để so sánh ID thiết bị là
hoàn toàn dành riêng cho xe buýt. Việc xác định chúng là các thực thể dành riêng cho xe buýt sẽ
hy sinh loại an toàn, vì vậy chúng tôi giữ lại các cấu trúc dành riêng cho xe buýt.

Trình điều khiển dành riêng cho xe buýt phải bao gồm một cấu trúc chung device_driver trong
định nghĩa của trình điều khiển dành riêng cho xe buýt. Như thế này::

cấu trúc pci_driver {
         const struct pci_device_id *id_table;
         trình điều khiển struct device_driver;
  };

Một định nghĩa bao gồm các trường dành riêng cho xe buýt sẽ giống như
(dùng lại driver eepro100)::

cấu trúc tĩnh pci_driver eepro100_driver = {
         .id_table = eepro100_pci_tbl,
         .driver = {
		.name = "eepro100",
		.bus = &pci_bus_type,
		.probe = eepro100_probe,
		.remove = eepro100_remove,
		.suspend = eepro100_suspend,
		.resume = eepro100_resume,
         },
  };

Một số người có thể thấy cú pháp khởi tạo cấu trúc nhúng khó xử hoặc
thậm chí có phần xấu xí. Cho đến nay, đó là cách tốt nhất mà chúng tôi tìm ra để làm được điều mình muốn...

Sự đăng ký
~~~~~~~~~~~~

::

int driver_register(struct device_driver *drv);

Trình điều khiển đăng ký cấu trúc khi khởi động. Đối với những người lái xe có
không có trường dành riêng cho xe buýt (tức là không có trình điều khiển dành riêng cho xe buýt
cấu trúc), họ sẽ sử dụng driver_register và chuyển một con trỏ tới
đối tượng struct device_driver.

Tuy nhiên, hầu hết các trình điều khiển sẽ có cấu trúc dành riêng cho xe buýt và sẽ
cần đăng ký với xe buýt bằng cách sử dụng cái gì đó như pci_driver_register.

Điều quan trọng là các tài xế phải đăng ký cấu trúc tài xế của mình càng sớm càng tốt.
có thể. Đăng ký với lõi sẽ khởi tạo một số trường trong
đối tượng struct device_driver, bao gồm số tham chiếu và
khóa. Các trường này được coi là hợp lệ mọi lúc và có thể
được sử dụng bởi lõi mô hình thiết bị hoặc trình điều khiển xe buýt.


Trình điều khiển xe buýt chuyển tiếp
~~~~~~~~~~~~~~~~~~~~~~

Bằng cách xác định các hàm bao bọc, việc chuyển đổi sang mô hình mới có thể được thực hiện
được thực hiện dễ dàng hơn. Trình điều khiển có thể bỏ qua cấu trúc chung hoàn toàn và
hãy để trình bao bọc xe buýt điền vào các trường. Đối với các cuộc gọi lại, xe buýt có thể
xác định các cuộc gọi lại chung để chuyển tiếp cuộc gọi đến xe buýt cụ thể
cuộc gọi lại của các trình điều khiển.

Giải pháp này chỉ nhằm mục đích tạm thời. Để có được lớp
thông tin trong trình điều khiển, dù sao thì trình điều khiển cũng phải được sửa đổi. Kể từ khi
việc chuyển đổi trình điều khiển sang mô hình mới sẽ giảm bớt một số chi phí cơ sở hạ tầng
độ phức tạp và kích thước mã, chúng tôi khuyên bạn nên chuyển đổi chúng thành
thông tin lớp học được thêm vào.

Truy cập
~~~~~~

Khi đối tượng đã được đăng ký, nó có thể truy cập vào các trường chung của
đối tượng, như khóa và danh sách thiết bị::

int driver_for_each_dev(struct device_driver *drv, void *data,
			  int (*callback)(struct device *dev, void *data));

Trường thiết bị là danh sách tất cả các thiết bị đã được liên kết với
người lái xe. Lõi LDM cung cấp chức năng trợ giúp để hoạt động trên tất cả
các thiết bị mà người lái xe điều khiển. Người trợ giúp này khóa trình điều khiển trên mỗi
truy cập nút và thực hiện việc đếm tham chiếu thích hợp trên từng thiết bị vì nó
truy cập nó.


sysfs
~~~~~

Khi một trình điều khiển được đăng ký, một thư mục sysfs sẽ được tạo trong đó
thư mục của xe buýt. Trong thư mục này, trình điều khiển có thể xuất giao diện
tới không gian người dùng để kiểm soát hoạt động của trình điều khiển trên cơ sở toàn cầu;
ví dụ. chuyển đổi đầu ra gỡ lỗi trong trình điều khiển.

Tính năng trong tương lai của thư mục này sẽ là thư mục 'thiết bị'. Cái này
thư mục sẽ chứa các liên kết tượng trưng đến các thư mục của thiết bị
hỗ trợ.



Cuộc gọi lại
~~~~~~~~~

::

int (*probe)	(struct device *dev);

Mục nhập thăm dò() được gọi trong ngữ cảnh tác vụ, với rwsem của xe buýt bị khóa
và trình điều khiển bị ràng buộc một phần với thiết bị.  Trình điều khiển thường được sử dụng
container_of() để chuyển đổi "dev" thành loại dành riêng cho xe buýt, cả trong thăm dò()
và các thói quen khác.  Loại đó thường cung cấp dữ liệu tài nguyên thiết bị, chẳng hạn như
dưới dạng pci_dev.resource[] hoặc platform_device.resources, được sử dụng trong
ngoài dev->platform_data để khởi tạo trình điều khiển.

Cuộc gọi lại này chứa logic dành riêng cho trình điều khiển để liên kết trình điều khiển với một
thiết bị đã cho.  Điều đó bao gồm việc xác minh rằng thiết bị có mặt, rằng
đó là phiên bản mà trình điều khiển có thể xử lý, cấu trúc dữ liệu trình điều khiển đó có thể
được phân bổ và khởi tạo, và bất kỳ phần cứng nào cũng có thể được khởi tạo.
Trình điều khiển thường lưu trữ con trỏ tới trạng thái của chúng bằng dev_set_drvdata().
Khi trình điều khiển đã liên kết thành công với thiết bị đó, thì thăm dò()
trả về 0 và mã mô hình trình điều khiển sẽ hoàn thành phần liên kết của nó
trình điều khiển cho thiết bị đó.

Đầu dò của trình điều khiển() có thể trả về giá trị lỗi âm để chỉ ra rằng
trình điều khiển không liên kết với thiết bị này, trong trường hợp đó nó phải có
giải phóng tất cả các tài nguyên được phân bổ.

Tùy chọn, thăm dò() có thể trả về -EPROBE_DEFER nếu trình điều khiển phụ thuộc vào
các tài nguyên chưa có sẵn (ví dụ: được cung cấp bởi trình điều khiển
chưa được khởi tạo).  Lõi trình điều khiển sẽ đưa thiết bị lên
danh sách thăm dò bị trì hoãn và sẽ cố gắng gọi lại sau. Nếu một người lái xe
phải trì hoãn, nó sẽ trả về -EPROBE_DEFER càng sớm càng tốt
giảm lượng thời gian dành cho công việc thiết lập cần thiết
được giải phóng và thực hiện lại sau đó.

.. warning::
      -EPROBE_DEFER must not be returned if probe() has already created
      child devices, even if those child devices are removed again
      in a cleanup path. If -EPROBE_DEFER is returned after a child
      device has been registered, it may result in an infinite loop of
      .probe() calls to the same driver.

::

khoảng trống (*sync_state)	(struct device *dev);

sync_state chỉ được gọi một lần cho một thiết bị. Nó được gọi khi tất cả người tiêu dùng
các thiết bị của thiết bị đã thăm dò thành công. Danh sách người tiêu dùng của
thiết bị có được bằng cách xem xét các liên kết thiết bị kết nối thiết bị đó với thiết bị đó
thiết bị tiêu dùng.

Lần thử đầu tiên để gọi sync_state() được thực hiện trong thời gian Late_initcall_sync() tới
cho phần sụn và trình điều khiển thời gian để liên kết các thiết bị với nhau. Trong thời gian đầu tiên
thử gọi sync_state(), nếu tất cả người dùng thiết bị tại đó
tại một thời điểm đã được thăm dò thành công, sync_state() được gọi là đúng
đi xa. Nếu không có người sử dụng thiết bị trong lần thử đầu tiên thì
cũng được coi là "tất cả người tiêu dùng thiết bị đã được thăm dò" và sync_state()
được gọi ngay lập tức.

Nếu trong lần thử đầu tiên gọi sync_state() cho một thiết bị, có
vẫn là những người tiêu dùng chưa thăm dò thành công, lệnh gọi sync_state() là
bị hoãn lại và thử lại trong tương lai chỉ khi một hoặc nhiều người tiêu dùng của
thăm dò thiết bị thành công. Nếu trong quá trình thử lại, lõi trình điều khiển nhận thấy rằng
nếu có một hoặc nhiều người tiêu dùng thiết bị chưa thử nghiệm thì
cuộc gọi sync_state() lại bị hoãn lại.

Trường hợp sử dụng điển hình của sync_state() là để kernel tiếp quản một cách rõ ràng
quản lý thiết bị từ bootloader. Ví dụ: nếu một thiết bị được bật
và tại một cấu hình phần cứng cụ thể của bộ nạp khởi động, thiết bị
trình điều khiển có thể cần giữ thiết bị ở cấu hình khởi động cho đến khi tất cả
người tiêu dùng thiết bị đã thăm dò. Sau khi tất cả người tiêu dùng thiết bị đã
được thăm dò, trình điều khiển của thiết bị có thể đồng bộ hóa trạng thái phần cứng của thiết bị với
phù hợp với trạng thái phần mềm tổng hợp được yêu cầu bởi tất cả người tiêu dùng. Do đó
tên sync_state().

Trong khi các ví dụ rõ ràng về tài nguyên có thể hưởng lợi từ sync_state() bao gồm
các tài nguyên như bộ điều chỉnh, sync_state() cũng có thể hữu ích cho các
các nguồn tài nguyên như IOMMU. Ví dụ: IOMMU có nhiều người tiêu dùng (thiết bị
có địa chỉ được ánh xạ lại bởi IOMMU) có thể cần giữ lại ánh xạ của chúng
đã sửa ở (hoặc bổ sung) cấu hình khởi động cho đến khi tất cả người tiêu dùng của nó có
đã thăm dò.

Trong khi trường hợp sử dụng điển hình của sync_state() là để kernel lấy sạch
về việc quản lý thiết bị từ bộ nạp khởi động, việc sử dụng sync_state() là
không bị hạn chế ở điều đó. Hãy sử dụng nó bất cứ khi nào bạn thấy cần phải hành động sau đó.
tất cả người tiêu dùng thiết bị đã thăm dò::

int (*remove)	(struct device *dev);

Remove được gọi để hủy liên kết trình điều khiển khỏi thiết bị. Đây có thể là
được gọi nếu một thiết bị bị xóa khỏi hệ thống về mặt vật lý, nếu
mô-đun trình điều khiển đang được tải xuống, trong quá trình khởi động lại, hoặc
trong các trường hợp khác.

Người lái xe có quyền quyết định xem thiết bị có hiện diện hay không
không. Nó sẽ giải phóng mọi tài nguyên được phân bổ cụ thể cho
thiết bị; tức là mọi thứ trong trường driver_data của thiết bị.

Nếu thiết bị vẫn còn hiện diện, thiết bị sẽ tắt thiết bị và đặt
nó sang trạng thái năng lượng thấp được hỗ trợ.

::

int (trạng thái *suspend)	(struct device *dev, pm_message_t);

đình chỉ được gọi để đặt thiết bị ở trạng thái năng lượng thấp.

::

int (*resume)	(struct device *dev);

Tiếp tục được sử dụng để đưa thiết bị trở lại từ trạng thái năng lượng thấp.


Thuộc tính
~~~~~~~~~~

::

cấu trúc driver_attribute {
          thuộc tính cấu trúc attr;
          ssize_t (*show)(struct device_driver *driver, char *buf);
          ssize_t (ZZ0001ZZ, const char *buf, size_t count);
  };

Trình điều khiển thiết bị có thể xuất các thuộc tính thông qua thư mục sysfs của chúng.
Trình điều khiển có thể khai báo các thuộc tính bằng DRIVER_ATTR_RW và DRIVER_ATTR_RO
macro hoạt động giống hệt với DEVICE_ATTR_RW và DEVICE_ATTR_RO
macro.

Ví dụ::

DRIVER_ATTR_RW(gỡ lỗi);

Điều này tương đương với việc khai báo::

cấu trúc driver_attribute driver_attr_debug;

Điều này sau đó có thể được sử dụng để thêm và xóa thuộc tính khỏi
thư mục trình điều khiển bằng cách sử dụng::

int driver_create_file(struct device_driver ZZ0000ZZ);
  void driver_remove_file(struct device_driver ZZ0001ZZ);
