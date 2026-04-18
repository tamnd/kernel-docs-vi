.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/driver-model/porting.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================================================
Chuyển trình điều khiển sang mô hình trình điều khiển mới
=========================================================

Patrick Mochel

7 tháng 1 năm 2003


Tổng quan

Vui lòng tham khảo ZZ0000ZZ để biết định nghĩa về
các loại trình điều khiển và khái niệm khác nhau.

Hầu hết công việc chuyển driver của thiết bị sang model mới đều diễn ra
ở lớp trình điều khiển xe buýt. Điều này là có chủ ý, nhằm giảm thiểu
tác động tiêu cực đến trình điều khiển hạt nhân và cho phép chuyển đổi dần dần
của các tài xế xe buýt.

Tóm lại, mô hình trình điều khiển bao gồm một tập hợp các đối tượng có thể
được nhúng trong các đối tượng lớn hơn, dành riêng cho xe buýt. Các trường trong các trường chung này
các đối tượng có thể thay thế các trường trong các đối tượng dành riêng cho xe buýt.

Các đối tượng chung phải được đăng ký với lõi mô hình trình điều khiển. Bởi
làm như vậy, chúng sẽ được xuất qua hệ thống tệp sysfs. sysfs có thể
được gắn kết bằng cách thực hiện::

# mount -t sysfs sysfs /sys



Quy trình

Bước 0: Đọc include/linux/device.h để biết định nghĩa đối tượng và hàm.

Bước 1: Đăng ký tài xế xe buýt.


- Xác định struct bus_type cho bus driver::

cấu trúc bus_type pci_bus_type = {
          .name = "pci",
    };


- Đăng ký loại xe buýt.

Điều này nên được thực hiện trong chức năng khởi tạo cho loại xe buýt,
  thường là module_init() hoặc hàm tương đương::

int tĩnh __init pci_driver_init(void)
    {
            trả về bus_register(&pci_bus_type);
    }

subsys_initcall(pci_driver_init);


Loại xe buýt có thể chưa được đăng ký (nếu trình điều khiển xe buýt có thể được biên dịch
  dưới dạng mô-đun) bằng cách thực hiện::

bus_unregister(&pci_bus_type);


- Xuất loại xe buýt cho người khác sử dụng.

Mã khác có thể muốn tham chiếu loại xe buýt, vì vậy hãy khai báo nó theo kiểu
  tệp tiêu đề được chia sẻ và xuất biểu tượng.

Từ bao gồm/linux/pci.h::

cấu trúc bên ngoài bus_type pci_bus_type;


Từ tập tin đoạn mã trên xuất hiện trong::

EXPORT_SYMBOL(pci_bus_type);



- Điều này sẽ khiến xe buýt hiển thị trong /sys/bus/pci/ với hai
  thư mục con: 'thiết bị' và 'trình điều khiển'::

# tree -d /sys/bus/pci/
    /sys/bus/pci/
    |-- thiết bị
    `-- trình điều khiển



Bước 2: Đăng ký thiết bị.

struct device đại diện cho một thiết bị duy nhất. Nó chủ yếu chứa siêu dữ liệu
mô tả mối quan hệ của thiết bị với các thực thể khác.


- Nhúng thiết bị cấu trúc vào loại thiết bị dành riêng cho xe buýt::


cấu trúc pci_dev {
           ...
nhà phát triển thiết bị cấu trúc;            /*Giao diện thiết bị chung */
           ...
    };

Khuyến cáo rằng thiết bị chung không phải là mục đầu tiên trong
  cấu trúc ngăn cản các lập trình viên thực hiện các thao tác thiếu suy nghĩ
  giữa các loại đối tượng. Thay vào đó là macro hoặc hàm nội tuyến,
  nên được tạo để chuyển đổi từ loại đối tượng chung ::


#define to_pci_dev(n) container_of(n, struct pci_dev, dev)

hoặc

cấu trúc nội tuyến tĩnh pci_dev * to_pci_dev(struct kobject * kobj)
    {
	trả về container_of(n, struct pci_dev, dev);
    }

Điều này cho phép trình biên dịch xác minh tính an toàn của các hoạt động
  được thực hiện (tốt).


- Khởi tạo thiết bị khi đăng ký.

Khi thiết bị được phát hiện hoặc đăng ký với loại xe buýt,
  tài xế xe buýt nên khởi tạo thiết bị chung. Điều quan trọng nhất
  những thứ cần khởi tạo là các trường bus_id, parent và bus.

Bus_id là một chuỗi ASCII chứa địa chỉ của thiết bị trên
  xe buýt. Định dạng của chuỗi này là dành riêng cho xe buýt. Đây là
  cần thiết để thể hiện các thiết bị trong sysfs.

cha mẹ là cha mẹ vật lý của thiết bị. Điều quan trọng là
  tài xế xe buýt đặt trường này một cách chính xác.

Mô hình trình điều khiển duy trì một danh sách có thứ tự các thiết bị mà nó sử dụng
  cho việc quản lý điện năng. Danh sách này phải nhằm đảm bảo rằng
  các thiết bị bị tắt trước cha mẹ vật lý của chúng và ngược lại.
  Thứ tự của danh sách này được xác định bởi phụ huynh của học sinh đã đăng ký
  thiết bị.

Ngoài ra, vị trí của thư mục sysfs của thiết bị phụ thuộc vào
  cha mẹ của thiết bị. sysfs xuất cấu trúc thư mục phản ánh
  hệ thống phân cấp thiết bị. Việc thiết lập chính xác cha mẹ đảm bảo rằng
  sysfs sẽ thể hiện chính xác hệ thống phân cấp.

Trường bus của thiết bị là con trỏ tới loại bus của thiết bị
  thuộc về. Điều này nên được đặt thành bus_type đã được khai báo
  và được khởi tạo trước đó.

Tùy chọn, trình điều khiển xe buýt có thể đặt tên và giải phóng thiết bị
  lĩnh vực.

Trường tên là một chuỗi ASCII mô tả thiết bị, như

"ATI Technologies Inc Radeon QD"

Trường phát hành là một lệnh gọi lại mà lõi mô hình trình điều khiển gọi
  khi thiết bị đã bị xóa và tất cả các tham chiếu đến nó đều có
  được thả ra. Thêm về điều này trong giây lát.


- Đăng ký thiết bị.

Khi thiết bị chung đã được khởi tạo, nó có thể được đăng ký
  với lõi mô hình trình điều khiển bằng cách thực hiện::

device_register(&dev->dev);

Sau này nó có thể được hủy đăng ký bằng cách thực hiện::

device_unregister(&dev->dev);

Điều này sẽ xảy ra trên các xe buýt hỗ trợ các thiết bị có thể cắm nóng.
  Nếu tài xế xe buýt hủy đăng ký một thiết bị, thiết bị đó sẽ không được giải phóng ngay lập tức
  nó. Thay vào đó, nó nên đợi lõi mô hình trình điều khiển gọi
  phương thức giải phóng của thiết bị, sau đó giải phóng đối tượng dành riêng cho xe buýt.
  (Có thể có mã khác hiện đang tham chiếu đến thiết bị
  cấu trúc và sẽ là thô lỗ nếu giải phóng thiết bị trong khi đó
  xảy ra).


Khi thiết bị được đăng ký, một thư mục trong sysfs sẽ được tạo.
  Cây PCI trong sysfs trông giống như::

/sys/thiết bị/pci0/
    |-- 00:00.0
    |-- 00:01.0
    |   ZZ0000ZZ-- 02:1f.0
    |       ZZ0001ZZ-- 04:04.0
    |-- 00:1f.0
    |-- 00:1f.1
    ZZ0004ZZ-- ide0
    ZZ0005ZZ |-- 0,0
    ZZ0006ZZ ZZ0002ZZ-- ide1
    |       ZZ0003ZZ-- 00:1f.5

Ngoài ra, các liên kết tượng trưng được tạo trong thư mục 'thiết bị' của xe buýt
  trỏ đến thư mục của thiết bị trong hệ thống phân cấp vật lý::

/sys/bus/pci/thiết bị/
    |-- 00:00.0 -> ../../../devices/pci0/00:00.0
    |-- 00:01.0 -> ../../../devices/pci0/00:01.0
    |-- 00:02.0 -> ../../../devices/pci0/00:02.0
    |-- 00:1e.0 -> ../../../devices/pci0/00:1e.0
    |-- 00:1f.0 -> ../../../devices/pci0/00:1f.0
    |-- 00:1f.1 -> ../../../devices/pci0/00:1f.1
    |-- 00:1f.2 -> ../../../devices/pci0/00:1f.2
    |-- 00:1f.3 -> ../../../devices/pci0/00:1f.3
    |-- 00:1f.5 -> ../../../devices/pci0/00:1f.5
    |-- 01:00.0 -> ../../../devices/pci0/00:01.0/01:00.0
    |-- 02:1f.0 -> ../../../devices/pci0/00:02.0/02:1f.0
    |-- 03:00.0 -> ../../../devices/pci0/00:02.0/02:1f.0/03:00.0
    `-- 04:04.0 -> ../../../devices/pci0/00:1e.0/04:04.0



Bước 3: Đăng ký Driver.

struct device_driver là một cấu trúc trình điều khiển đơn giản chứa một tập hợp
của các hoạt động mà lõi mô hình trình điều khiển có thể gọi.


- Nhúng struct device_driver vào trình điều khiển dành riêng cho xe buýt.

Cũng giống như với các thiết bị, hãy làm điều gì đó như::

cấu trúc pci_driver {
           ...
trình điều khiển struct device_driver;
    };


- Khởi tạo cấu trúc driver chung.

Khi trình điều khiển đăng ký với xe buýt (ví dụ: thực hiện pci_register_driver()),
  khởi tạo các trường cần thiết của trình điều khiển: tên và xe buýt
  lĩnh vực.


- Đăng ký tài xế.

Sau khi trình điều khiển chung đã được khởi tạo, hãy gọi::

driver_register(&drv->driver);

để đăng ký trình điều khiển với lõi.

Khi tài xế bị hủy đăng ký khỏi xe buýt, hãy hủy đăng ký tài xế khỏi xe buýt.
  cốt lõi bằng cách thực hiện::

driver_unregister(&drv->driver);

Lưu ý rằng điều này sẽ chặn cho đến khi tất cả các tham chiếu đến trình điều khiển có
  đã đi xa. Thông thường sẽ không có đâu.


- Đại diện Sysfs.

Trình điều khiển được xuất qua sysfs trong thư mục trình điều khiển của xe buýt.
  Ví dụ::

/sys/bus/pci/trình điều khiển/
    |-- 3c59x
    |-- Ensoniq AudioPCI
    |-- agpgart-amdk7
    |-- e100
    `-- nối tiếp


Bước 4: Xác định phương pháp chung cho trình điều khiển.

struct device_driver xác định một tập hợp các hoạt động mà mô hình trình điều khiển
cuộc gọi cốt lõi. Hầu hết các hoạt động này có lẽ tương tự như
các hoạt động mà xe buýt đã xác định cho người lái xe, nhưng thực hiện các thao tác khác
các thông số.

Sẽ rất khó khăn và tẻ nhạt khi buộc mọi tài xế trên xe buýt phải
đồng thời chuyển đổi trình điều khiển của họ sang định dạng chung. Thay vào đó,
trình điều khiển xe buýt nên xác định các trường hợp đơn lẻ của các phương thức chung
chuyển tiếp cuộc gọi đến các tài xế xe buýt cụ thể. Ví dụ::


int tĩnh pci_device_remove(thiết bị cấu trúc * dev)
  {
          cấu trúc pci_dev * pci_dev = to_pci_dev(dev);
          struct pci_driver * drv = pci_dev->driver;

nếu (drv) {
                  nếu (drv-> xóa)
                          drv->xóa(pci_dev);
                  pci_dev->trình điều khiển = NULL;
          }
          trả về 0;
  }


Trình điều khiển chung phải được khởi tạo bằng các phương thức này trước khi nó
được đăng ký::

/* khởi tạo các trường trình điều khiển chung */
        drv->driver.name = drv->tên;
        drv->driver.bus = &pci_bus_type;
        drv->driver.probe = pci_device_probe;
        drv->driver.resume = pci_device_resume;
        drv->driver.suspend = pci_device_suspend;
        drv->driver.remove = pci_device_remove;

/*đăng ký với lõi */
        driver_register(&drv->driver);


Lý tưởng nhất là xe buýt chỉ nên khởi tạo các trường nếu chúng không
đã được thiết lập rồi. Điều này cho phép các trình điều khiển thực hiện chung của riêng họ
phương pháp.


Bước 5: Hỗ trợ liên kết trình điều khiển chung.

Mô hình giả định rằng một thiết bị hoặc trình điều khiển có thể hoạt động linh hoạt
đăng ký với xe buýt bất cứ lúc nào. Khi đăng ký xảy ra,
các thiết bị phải được liên kết với một trình điều khiển hoặc các trình điều khiển phải được liên kết với tất cả
các thiết bị mà nó hỗ trợ.

Trình điều khiển thường chứa danh sách ID thiết bị mà nó hỗ trợ. các
tài xế xe buýt so sánh các ID này với ID của thiết bị đã đăng ký với nó.
Định dạng của ID thiết bị và ngữ nghĩa để so sánh chúng là
dành riêng cho xe buýt, vì vậy mô hình chung cố gắng khái quát hóa chúng.

Thay vào đó, một bus có thể cung cấp một phương thức trong struct bus_type để thực hiện
so sánh::

int (nhà phát triển ZZ0000ZZ, struct device_driver * drv);

match sẽ trả về giá trị dương nếu trình điều khiển hỗ trợ thiết bị,
và ngược lại bằng 0. Nó cũng có thể trả về mã lỗi (ví dụ
-EPROBE_DEFER) nếu xác định rằng trình điều khiển đã cho hỗ trợ thiết bị là
không thể được.

Khi một thiết bị được đăng ký, danh sách trình điều khiển của xe buýt sẽ được lặp lại
kết thúc. bus->match() được gọi cho mỗi cái cho đến khi tìm thấy kết quả khớp.

Khi một tài xế được đăng ký, danh sách thiết bị của xe buýt sẽ được lặp lại
kết thúc. bus->match() được gọi cho từng thiết bị chưa có
được một tài xế tố cáo.

Khi một thiết bị được liên kết thành công với trình điều khiển, thiết bị->trình điều khiển sẽ
được đặt, thiết bị sẽ được thêm vào danh sách thiết bị theo trình điều khiển và
liên kết tượng trưng được tạo trong thư mục sysfs của trình điều khiển trỏ đến
thư mục vật lý của thiết bị::

/sys/bus/pci/trình điều khiển/
  |-- 3c59x
  |   ZZ0000ZZ-- 00:00.0 -> ../../../../devices/pci0/00:00.0
  |-- e100
  |   ZZ0001ZZ -- nối tiếp


Liên kết trình điều khiển này sẽ thay thế liên kết trình điều khiển hiện có
cơ chế mà xe buýt hiện đang sử dụng.


Bước 6: Cung cấp lệnh gọi lại hotplug.

Bất cứ khi nào một thiết bị được đăng ký với lõi mô hình trình điều khiển,
chương trình không gian người dùng /sbin/hotplug được gọi để thông báo không gian người dùng.
Người dùng có thể xác định các hành động cần thực hiện khi thiết bị được lắp vào hoặc
bị loại bỏ.

Lõi mô hình trình điều khiển chuyển một số đối số tới không gian người dùng thông qua
các biến môi trường, bao gồm

- ACTION: đặt thành 'thêm' hoặc 'xóa'
- DEVPATH: thiết lập đường dẫn vật lý của thiết bị trong sysfs.

Trình điều khiển xe buýt cũng có thể cung cấp các tham số bổ sung cho không gian người dùng để
tiêu thụ. Để làm điều này, bus phải thực hiện phương pháp 'hotplug' trong
cấu trúc bus_type::

int (*hotplug) (struct device *dev, char **envp,
                     int num_envp, char *buffer, int buffer_size);

Lệnh này được gọi ngay trước khi /sbin/hotplug được thực thi.


Bước 7: Dọn dẹp tài xế xe buýt.

Cấu trúc bus, thiết bị và trình điều khiển chung cung cấp một số trường
có thể thay thế những thứ được xác định riêng cho tài xế xe buýt.

- Danh sách thiết bị.

struct bus_type chứa danh sách tất cả các thiết bị đã đăng ký với bus
loại. Điều này bao gồm tất cả các thiết bị trên tất cả các phiên bản của loại xe buýt đó.
Danh sách nội bộ mà xe buýt sử dụng có thể bị xóa để sử dụng
cái này

Phần lõi cung cấp một trình vòng lặp để truy cập các thiết bị này::

int bus_for_each_dev(struct bus_type * bus, struct device * start,
                       dữ liệu void *, int (ZZ0000ZZ, void *));


- Danh sách tài xế.

struct bus_type cũng chứa danh sách tất cả các trình điều khiển đã đăng ký với
nó. Một danh sách nội bộ các tài xế mà tài xế xe buýt duy trì có thể
được loại bỏ để sử dụng cái chung.

Trình điều khiển có thể được lặp đi lặp lại, như devices::

int bus_for_each_drv(struct bus_type * bus, struct device_driver * start,
                       dữ liệu void *, int (ZZ0000ZZ, void *));


Vui lòng xem driver/base/bus.c để biết thêm thông tin.


- rwsem

struct bus_type chứa rwsem bảo vệ tất cả các quyền truy cập lõi vào
danh sách thiết bị và trình điều khiển. Điều này có thể được sử dụng bởi tài xế xe buýt
nội bộ và nên được sử dụng khi truy cập vào thiết bị hoặc trình điều khiển
danh sách xe buýt duy trì.


- Trường thiết bị và trình điều khiển.

Một số trường trong struct device và struct device_driver trùng lặp
các trường trong các biểu diễn dành riêng cho xe buýt của các đối tượng này. Hãy thoải mái
để loại bỏ những cái dành riêng cho xe buýt và ưu tiên những cái chung. Lưu ý
Tuy nhiên, điều này có thể có nghĩa là phải sửa tất cả các trình điều khiển
tham chiếu các trường dành riêng cho xe buýt (mặc dù tất cả các trường đó phải là 1 dòng
thay đổi).
