.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/s390/driver-model.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================================
Giao diện mô hình trình điều khiển S/390
=============================

1. Thiết bị CCW
--------------

Tất cả các thiết bị có thể được đánh địa chỉ bằng ccw đều được gọi là 'thiết bị CCW' -
ngay cả khi chúng không thực sự được điều khiển bởi ccws.

Tất cả các thiết bị ccw đều được truy cập thông qua kênh con, điều này được phản ánh trong
cấu trúc dưới thiết bị/::

thiết bị/
     - hệ thống/
     - css0/
	   - 0.0.0000/0.0.0815/
	   - 0.0.0001/0.0.4711/
	   - 0,0,0002/
	   - 0.1.0000/0.1.1234/
	   ...
- không còn tồn tại/

Trong ví dụ này, thiết bị 0815 được truy cập qua kênh con 0 trong bộ kênh con 0,
thiết bị 4711 qua kênh con 1 trong kênh con được đặt 0 và kênh con 2 không phải là I/O
kênh phụ. Thiết bị 1234 được truy cập qua kênh con 0 trong bộ kênh con 1.

Kênh con có tên 'không còn tồn tại' không đại diện cho bất kỳ kênh con thực sự nào trên
hệ thống; đó là một kênh con giả nơi các thiết bị ccw bị ngắt kết nối được chuyển đến
nếu chúng bị dịch chuyển bởi một thiết bị ccw khác đang hoạt động trên
kênh phụ cũ. Các thiết bị ccw sẽ lại được chuyển sang kênh con thích hợp
nếu chúng hoạt động trở lại trên kênh con đó.

Bạn nên đánh địa chỉ một thiết bị ccw thông qua id bus của nó (ví dụ: 0.0.4711); thiết bị có thể
được tìm thấy trong bus/ccw/devices/.

Tất cả các thiết bị ccw xuất một số dữ liệu qua sysfs.

dễ thương:
	Loại/kiểu đơn vị điều khiển.

kiểu nhà phát triển:
	Loại/kiểu thiết bị, nếu có.

sẵn có:
	      Có thể 'tốt' hoặc 'đóng hộp'; 'không có đường dẫn' hoặc 'không có thiết bị' cho
	      các thiết bị bị ngắt kết nối.

trực tuyến:
	    Giao diện cài đặt thiết bị trực tuyến và ngoại tuyến.
	    Trong trường hợp đặc biệt thiết bị bị ngắt kết nối (xem phần
	    chức năng thông báo dưới 1.2), chuyển 0 sang trực tuyến sẽ buộc xóa
	    thiết bị.

Trình điều khiển thiết bị có thể thêm các mục để xuất dữ liệu và giao diện trên mỗi thiết bị.

Ngoài ra còn có một số dữ liệu được xuất trên cơ sở từng kênh phụ (xem bên dưới
xe buýt/css/thiết bị/):

chipid:
	Thông qua chip nào thiết bị được kết nối.

ma cô:
	Đường dẫn được cài đặt, đường dẫn có sẵn và mặt nạ hoạt động của đường dẫn.

Cũng có thể có dữ liệu bổ sung, ví dụ như cho các thiết bị khối.


1.1 Đưa lên thiết bị ccw
----------------------------

Điều này được thực hiện trong một số bước.

Một. Mỗi trình điều khiển có thể cung cấp một hoặc nhiều giao diện tham số trong đó các tham số có thể
   được chỉ định. Những giao diện này cũng thuộc trách nhiệm của người lái xe.
b. Sau một. đã được thực hiện, nếu cần, thiết bị cuối cùng sẽ được đưa lên
   thông qua giao diện 'trực tuyến'.


1.2 Viết driver cho thiết bị ccw
------------------------------------

Có thể tìm thấy cấu trúc dữ liệu struct ccw_device và struct ccw_driver cơ bản
dưới bao gồm/asm/ccwdev.h::

cấu trúc ccw_device {
	spinlock_t *ccwlock;
	struct ccw_device_private *riêng tư;
	cấu trúc ccw_device_id id;

cấu trúc ccw_driver *drv;
	nhà phát triển thiết bị cấu trúc;
	int trực tuyến;

void (*handler) (struct ccw_device *dev, intparm dài không dấu,
			 cấu trúc irb *irb);
  };

cấu trúc ccw_driver {
	mô-đun cấu trúc * chủ sở hữu;
	cấu trúc ccw_device_id *ids;
	int (ZZ0000ZZ);
	int (ZZ0001ZZ);
	int (ZZ0002ZZ);
	int (ZZ0003ZZ);
	int (ZZ0004ZZ, int);
	trình điều khiển struct device_driver;
	char *tên;
  };

Trường 'riêng tư' chỉ chứa dữ liệu cần thiết cho hoạt động I/O nội bộ và
không có sẵn cho trình điều khiển thiết bị.

Mỗi trình điều khiển phải khai báo trong MODULE_DEVICE_TABLE loại/model CU nào
và/hoặc loại/kiểu thiết bị mà nó quan tâm. Thông tin này sau đó có thể được tìm thấy
trong các trường cấu trúc ccw_device_id::

cấu trúc ccw_device_id {
	__u16 match_flags;

__u16 cu_type;
	__u16 dev_type;
	__u8 cu_model;
	__u8 dev_model;

driver_info dài không dấu;
  };

Các hàm trong ccw_driver nên được sử dụng theo cách sau:

thăm dò:
	 Chức năng này được gọi bởi lớp thiết bị cho mỗi thiết bị mà trình điều khiển
	 được quan tâm. Người lái xe chỉ nên phân bổ các cấu trúc riêng tư
	 để đặt dev->driver_data và tạo thuộc tính (nếu cần). Ngoài ra,
	 trình xử lý ngắt (xem bên dưới) phải được đặt ở đây.

::

int (*probe) (struct ccw_device *cdev);

Thông số:
		cdev
			- thiết bị cần thăm dò.


xóa:
	 Chức năng này được gọi bởi lớp thiết bị khi loại bỏ trình điều khiển,
	 thiết bị hoặc mô-đun. Người lái xe nên thực hiện dọn dẹp ở đây.

::

int (*remove) (struct ccw_device *cdev);

Thông số:
		cdev
			- thiết bị cần được gỡ bỏ.


set_online:
	    Chức năng này được gọi bởi lớp I/O chung khi thiết bị
	    được kích hoạt thông qua thuộc tính 'trực tuyến'. Người lái xe cuối cùng nên
	    thiết lập và kích hoạt thiết bị tại đây.

::

int (ZZ0000ZZ);

Thông số:
		cdev
			- thiết bị được kích hoạt. Lớp chung có
			  đã xác minh rằng thiết bị chưa trực tuyến.


set_offline: Chức năng này được gọi bởi lớp I/O chung khi thiết bị
	     hủy kích hoạt thông qua thuộc tính 'trực tuyến'. Tài xế nên im lặng
	     tắt thiết bị nhưng không hủy phân bổ dữ liệu riêng tư của thiết bị.

::

int (ZZ0000ZZ);

Thông số:
		cdev
			- thiết bị sẽ bị vô hiệu hóa. Lớp chung có
			   đã xác minh rằng thiết bị đang trực tuyến.


thông báo:
	Hàm này được lớp I/O chung gọi để thực hiện một số thay đổi trạng thái
	của thiết bị.

Tín hiệu cho người lái xe là:

* Ở trạng thái trực tuyến, thiết bị đã bị ngắt kết nối (CIO_GONE) hoặc đường dẫn cuối cùng đã biến mất
	  (CIO_NO_PATH). Người lái xe phải quay lại !0 để giữ máy; cho
	  trả về mã 0 thì máy sẽ bị xóa như bình thường (cả khi không có
	  chức năng thông báo đã được đăng ký). Nếu người lái xe muốn giữ
	  thiết bị, nó sẽ được chuyển sang trạng thái ngắt kết nối.
	* Ở trạng thái ngắt kết nối, thiết bị hoạt động trở lại (CIO_OPER). các
	  Lớp I/O chung thực hiện một số kiểm tra độ chính xác trên số thiết bị và
	  Thiết bị / CU để có thể chắc chắn một cách hợp lý nếu nó vẫn là thiết bị tương tự.
	  Nếu không, thiết bị cũ sẽ bị xóa và thiết bị mới sẽ được đăng ký. Bởi
	  trả về mã của chức năng thông báo mà trình điều khiển thiết bị sẽ báo hiệu nếu nó
	  muốn lấy lại thiết bị: !0 để giữ, 0 để giữ lại thiết bị
	  đã xóa và đăng ký lại.

::

int (ZZ0000ZZ, int);

Thông số:
		cdev
			- thiết bị có trạng thái thay đổi.

sự kiện
			- sự kiện đã xảy ra. Đây có thể là một trong CIO_GONE,
			  CIO_NO_PATH hoặc CIO_OPER.

Trường xử lý của struct ccw_device có nghĩa là được đặt thành ngắt
xử lý cho thiết bị. Để phù hợp với những người lái xe sử dụng nhiều
trình xử lý riêng biệt (ví dụ: thiết bị đa kênh con), đây là thành viên của ccw_device
thay vì ccw_driver.
Trình xử lý được đăng ký với lớp chung trong quá trình xử lý set_online()
trước khi trình điều khiển được gọi và bị hủy đăng ký trong set_offline() sau
tài xế đã được gọi. Ngoài ra, sau khi đăng ký/trước khi hủy đăng ký, đường dẫn
nhóm tương ứng. việc giải tán nhóm đường dẫn (nếu có) được thực hiện.

::

void (*handler) (struct ccw_device *dev, intparm dài không dấu, struct irb *irb);

Tham số: dev - thiết bị mà trình xử lý được gọi
		intparm - intparm cho phép trình điều khiển thiết bị xác định
			  I/O mà ngắt được liên kết hoặc để nhận ra
			  sự gián đoạn là không được yêu cầu.
		irb - khối phản hồi gián đoạn chứa thông tin tích lũy
			  trạng thái.

Trình điều khiển thiết bị được gọi từ lớp ccw_device chung và có thể truy xuất
thông tin về ngắt từ tham số irb.


thiết bị nhóm 1.3 ccw
--------------------

Cơ chế ccwgroup được thiết kế để xử lý các thiết bị bao gồm nhiều ccw
các thiết bị, như qeth hoặc ctc.

Trình điều khiển ccw cung cấp thuộc tính 'nhóm'. Dẫn id bus của thiết bị ccw tới
thuộc tính này tạo ra một thiết bị ccwgroup bao gồm các thiết bị ccw này (nếu
có thể). Thiết bị ccwgroup này có thể được đặt trực tuyến hoặc ngoại tuyến giống như bình thường
thiết bị ccw.

Mỗi thiết bị ccwgroup cũng cung cấp thuộc tính “ungroup” để hủy thiết bị
lại (chỉ khi ngoại tuyến). Đây là cơ chế ccwgroup chung (trình điều khiển thực hiện
không cần phải thực hiện bất cứ điều gì ngoài thói quen loại bỏ thông thường).

Một thiết bị ccw là thành viên của thiết bị ccwgroup mang một con trỏ tới
thiết bị ccwgroup trong driver_data của cấu trúc thiết bị của nó. Trường này không được
được trình điều khiển chạm vào - nó nên sử dụng driver_data của thiết bị ccwgroup cho
dữ liệu riêng tư.

Để triển khai trình điều khiển ccwgroup, vui lòng tham khảo include/asm/ccwgroup.h. Giữ trong
hãy nhớ rằng hầu hết các trình điều khiển sẽ cần triển khai cả ccwgroup và ccw
người lái xe.


2. Đường dẫn kênh
-----------------

Đường dẫn kênh hiển thị, giống như các kênh con, trong thư mục gốc của hệ thống con kênh (css0)
và được gọi là 'chp0.<chpid>'. Họ không có tài xế và không thuộc bất kỳ xe buýt nào.
Xin lưu ý rằng không giống như /proc/chpids trong 2.4, các đối tượng đường dẫn kênh phản ánh
chỉ trạng thái logic chứ không phải trạng thái vật lý, vì chúng ta không thể theo dõi
về sau một cách nhất quán do thiếu sự hỗ trợ của máy (chúng ta không cần phải biết
dù sao đi nữa).

trạng thái
       - Có thể là 'trực tuyến' hoặc 'ngoại tuyến'.
	 Đặt 'bật' hoặc 'tắt' đặt chpid trực tuyến/ngoại tuyến một cách hợp lý.
	 Việc 'bật' đường dẫn tới một chpid trực tuyến sẽ kích hoạt việc dò lại đường dẫn cho tất cả các thiết bị
	 chpid kết nối tới. Điều này có thể được sử dụng để buộc kernel sử dụng lại
	 đường dẫn kênh mà người dùng biết là trực tuyến nhưng máy thì không
	 đã tạo một máy kiểm tra.

loại
       - Kiểu vật lý của đường dẫn kênh.

đã chia sẻ
       - Liệu đường dẫn kênh có được chia sẻ hay không.

cmg
       - Nhóm đo kênh.

3. Thiết bị hệ thống
-----------------

3.1 xpram
---------

xpram hiển thị dưới thiết bị/hệ thống/dưới dạng 'xpram'.

3,2 bộ vi xử lý
--------

Đối với mỗi CPU, một thư mục được tạo trong devices/system/cpu/. Mỗi CPU có một
thuộc tính 'trực tuyến' có thể là 0 hoặc 1.
