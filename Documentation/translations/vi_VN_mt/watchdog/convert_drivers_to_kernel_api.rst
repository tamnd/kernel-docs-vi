.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/watchdog/convert_drivers_to_kernel_api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================================================================
Chuyển đổi trình điều khiển cơ quan giám sát cũ sang khung cơ quan giám sát
===========================================================================

bởi Wolfram Sang <wsa@kernel.org>

Trước khi khung giám sát được đưa vào kernel, mọi trình điều khiển đều phải
tự mình triển khai API. Bây giờ, khi khuôn khổ đã đưa ra điểm chung
các thành phần, những trình điều khiển đó có thể được giảm nhẹ để biến nó thành người dùng của khung.
Tài liệu này sẽ hướng dẫn bạn thực hiện nhiệm vụ này. Các bước cần thiết được mô tả
cũng như những điều cần chú ý.


Xóa cấu trúc file_Operations
---------------------------------

Trình điều khiển cũ xác định file_operating của riêng chúng cho các hành động như open(), write(),
v.v... Những thứ này hiện được xử lý bởi khung và chỉ gọi trình điều khiển khi
cần thiết. Vì vậy, nói chung, các hàm cấu trúc và các loại 'file_Operations' có thể
đi. Chỉ có rất ít chi tiết dành riêng cho trình điều khiển phải được chuyển sang các chức năng khác.
Dưới đây là tổng quan về các chức năng và các hành động có thể cần thiết:

- open: Mọi thứ liên quan đến quản lý tài nguyên (kiểm tra mở tệp, phép thuật
  chuẩn bị chặt chẽ) có thể đơn giản là đi. Nội dung cụ thể của thiết bị cần phải đi tới
  chức năng khởi động cụ thể của trình điều khiển. Lưu ý rằng đối với một số trình điều khiển, chức năng khởi động
  cũng đóng vai trò là chức năng ping. Nếu đúng như vậy và bạn cần bắt đầu/dừng
  để được cân bằng (đồng hồ!), tốt hơn hết bạn nên tái cấu trúc một chức năng khởi động riêng biệt.

- đóng: Gợi ý tương tự như khi áp dụng mở.

- viết: Có thể đơn giản đi, tất cả các hành vi được xác định đều được khung xử lý,
  tức là xử lý ping khi ghi và magic char ('V').

- ioctl: Mặc dù trình điều khiển được phép có phần mở rộng cho giao diện IOCTL,
  những cái phổ biến nhất được xử lý theo khung, được hỗ trợ bởi một số hỗ trợ
  từ người lái xe:

WDIOC_GETSUPPORT:
		Trả về cấu trúc watchdog_info bắt buộc từ trình điều khiển

WDIOC_GETSTATUS:
		Cần xác định trạng thái gọi lại, nếu không thì trả về 0

WDIOC_GETBOOTSTATUS:
		Cần thành viên bootstatus được thiết lập đúng cách. Hãy chắc chắn rằng nó bằng 0 nếu bạn
		không có hỗ trợ thêm!

WDIOC_SETOPTIONS:
		Không cần chuẩn bị

WDIOC_KEEPALIVE:
		Nếu muốn, các tùy chọn trong watchdog_info cần phải có WDIOF_KEEPALIVEPING
		đặt

WDIOC_SETTIMEOUT:
		Các tùy chọn trong watchdog_info cần phải được đặt WDIOF_SETTIMEOUT
		và phải xác định set_timeout-callback. Cốt lõi cũng sẽ
		thực hiện kiểm tra giới hạn, nếu min_timeout và max_timeout trong cơ quan giám sát
		thiết bị đã được thiết lập. Tất cả là tùy chọn.

WDIOC_GETTIMEOUT:
		Không cần chuẩn bị

WDIOC_GETTIMELEFT:
		Nó cần xác định hàm gọi lại get_timeleft(). Nếu không thì nó
		sẽ trả lại EOPNOTSUPP

Các IOCTL khác có thể được cung cấp bằng cách sử dụng lệnh gọi lại ioctl. Lưu ý rằng điều này chủ yếu
  dành cho việc chuyển các trình điều khiển cũ; trình điều khiển mới không nên phát minh ra IOCTL riêng tư.
  IOCTL riêng tư được xử lý đầu tiên. Khi cuộc gọi lại trở lại với
  -ENOIOCTLCMD, IOCTL của khung cũng sẽ được thử. Bất kỳ lỗi nào khác
  được trao trực tiếp cho người dùng.

Chuyển đổi ví dụ::

-static const struct file_Operations s3c2410wdt_fops = {
  - .chủ sở hữu = THIS_MODULE,
  - .write =s3c2410wdt_write,
  - .unlocked_ioctl = s3c2410wdt_ioctl,
  - .open = s3c2410wdt_open,
  - .release=s3c2410wdt_release,
  -};

Kiểm tra các chức năng dành riêng cho thiết bị và giữ lại để sử dụng sau
tái cấu trúc. Phần còn lại có thể đi.


Tháo thiết bị khác
---------------------

Vì file_Operations hiện không còn nữa nên bạn cũng có thể xóa 'struct
thiết bị sai lầm'. Khung công tác sẽ tạo nó trên watchdog_dev_register() được gọi bởi
watchdog_register_device()::

-static struct miscdevice s3c2410wdt_miscdev = {
  - .minor = WATCHDOG_MINOR,
  - .name = "cơ quan giám sát",
  - .fops = &s3c2410wdt_fops,
  -};


Xóa bao gồm và xác định lỗi thời
------------------------------------

Do sự đơn giản hóa, một số định nghĩa có thể hiện không được sử dụng. Xóa
họ. Bao gồm cũng có thể được gỡ bỏ. Ví dụ::

- #include <linux/fs.h>
  - #include <linux/miscdevice.h> (nếu MODULE_ALIAS_MISCDEV không được sử dụng)
  - #include <linux/uaccess.h> (nếu không sử dụng IOCTL tùy chỉnh)


Thêm các hoạt động giám sát
---------------------------

Tất cả các cuộc gọi lại có thể được xác định trong 'struct watchdog_ops'. Bạn có thể tìm thấy nó
được giải thích trong 'watchdog-kernel-api.txt' trong thư mục này. bắt đầu() và
chủ sở hữu phải được đặt, phần còn lại là tùy chọn. Bạn sẽ dễ dàng tìm thấy tương ứng
chức năng trong trình điều khiển cũ. Lưu ý rằng bây giờ bạn sẽ nhận được một con trỏ tới
watchdog_device làm tham số cho các chức năng này, vì vậy bạn có thể phải
thay đổi tiêu đề chức năng. Những thay đổi khác rất có thể là không cần thiết, bởi vì
ở đây chỉ đơn giản là việc truy cập phần cứng trực tiếp. Nếu bạn có thiết bị cụ thể
mã còn lại từ các bước trên, nó sẽ được cấu trúc lại thành các lệnh gọi lại này.

Đây là một ví dụ đơn giản::

+cấu trúc tĩnh watchdog_ops s3c2410wdt_ops = {
  + .chủ sở hữu = THIS_MODULE,
  + .start = s3c2410wdt_start,
  + .stop = s3c2410wdt_stop,
  + .ping = s3c2410wdt_keepalive,
  + .set_timeout = s3c2410wdt_set_heartbeat,
  +};

Một thay đổi tiêu đề hàm điển hình trông giống như::

-static void s3c2410wdt_keepalive(void)
  +static int s3c2410wdt_keepalive(struct watchdog_device *wdd)
   {
  ...
+++++
  + trả về 0;
   }

  ...

- s3c2410wdt_keepalive();
  + s3c2410wdt_keepalive(&s3c2410_wdd);


Thêm thiết bị giám sát
-----------------------

Bây giờ chúng ta cần tạo một 'struct watchdog_device' và điền vào đó
thông tin cần thiết cho khuôn khổ. Cấu trúc cũng được giải thích chi tiết
trong 'watchdog-kernel-api.txt' trong thư mục này. Chúng tôi chuyển nó thành điều bắt buộc
cấu trúc watchdog_info và watchdog_ops mới được tạo. Thông thường, các tài xế cũ
có hệ thống lưu giữ hồ sơ riêng cho những thứ như trạng thái khởi động và thời gian chờ bằng cách sử dụng
các biến tĩnh. Chúng phải được chuyển đổi để sử dụng các thành viên trong
cơ quan giám sát_device. Lưu ý rằng các giá trị thời gian chờ là unsigned int. Một số trình điều khiển
sử dụng signature int, vì vậy cái này cũng phải được chuyển đổi.

Đây là một ví dụ đơn giản về thiết bị giám sát::

+cấu trúc tĩnh watchdog_device s3c2410_wdd = {
  + .info = &s3c2410_wdt_ident,
  + .ops = &s3c2410wdt_ops,
  +};


Xử lý tính năng 'nowayout'
-----------------------------

Một số trình điều khiển sử dụng nowout tĩnh, tức là không có tham số mô-đun cho nó
và chỉ CONFIG_WATCHDOG_NOWAYOUT xác định xem tính năng này có được hỗ trợ hay không
đã sử dụng. Điều này cần được chuyển đổi bằng cách khởi tạo biến trạng thái của
watchdog_device như thế này::

.status = WATCHDOG_NOWAYOUT_INIT_STATUS,

Tuy nhiên, hầu hết các trình điều khiển cũng cho phép cấu hình thời gian chạy của nowout, thường là
bằng cách thêm một tham số mô-đun. Việc chuyển đổi cho điều này sẽ giống như ::

watchdog_set_nowayout(&s3c2410_wdd, nowout);

Bản thân tham số mô-đun cần được giữ nguyên, mọi thứ khác liên quan đến nowout
nhưng có thể đi Đây có thể sẽ là một số mã ở dạng open(), close() hoặc write().


Đăng ký thiết bị giám sát
----------------------------

Thay thế misc_register(&miscdev) bằng watchdog_register_device(&watchdog_dev).
Đảm bảo giá trị trả về được kiểm tra và thông báo lỗi, nếu có,
vẫn phù hợp. Đồng thời chuyển đổi trường hợp hủy đăng ký::

- ret = misc_register(&s3c2410wdt_miscdev);
  + ret = watchdog_register_device(&s3c2410_wdd);

  ...

- misc_deregister(&s3c2410wdt_miscdev);
  + watchdog_unregister_device(&s3c2410_wdd);


Cập nhật mục nhập Kconfig
-------------------------

Mục nhập cho trình điều khiển bây giờ cần chọn WATCHDOG_CORE:

+ chọn WATCHDOG_CORE


Tạo một bản vá và gửi nó lên thượng nguồn
-----------------------------------------

Đảm bảo rằng bạn đã hiểu Documentation/process/submit-patches.rst và gửi bản vá của bạn tới
linux-watchdog@vger.kernel.org. Chúng tôi rất mong chờ nó :)
