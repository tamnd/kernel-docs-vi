.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/watchdog/watchdog-kernel-api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================================
Hạt nhân lõi trình điều khiển hẹn giờ Linux WatchDog API
===============================================

Đánh giá lần cuối: 12-02-2013

Wim Van Sebroeck <wim@iguana.be>

Giới thiệu
------------
Tài liệu này không mô tả Trình điều khiển hoặc Thiết bị WatchDog Hẹn giờ (WDT) là gì.
Nó cũng không mô tả API mà không gian người dùng có thể sử dụng để liên lạc
với Bộ đếm thời gian WatchDog. Nếu bạn muốn biết điều này thì hãy đọc phần sau
tập tin: Documentation/watchdog/watchdog-api.rst .

Vậy tài liệu này mô tả những gì? Nó mô tả API có thể được sử dụng bởi
Trình điều khiển hẹn giờ WatchDog muốn sử dụng Lõi trình điều khiển hẹn giờ WatchDog
Khung. Khung này cung cấp tất cả các giao diện hướng tới không gian người dùng để
cùng một mã không cần phải được sao chép mỗi lần. Điều này cũng có nghĩa là
trình điều khiển hẹn giờ của cơ quan giám sát sau đó chỉ cần cung cấp các quy trình khác nhau
(hoạt động) điều khiển bộ đếm thời gian theo dõi (WDT).

API
-------
Mỗi trình điều khiển hẹn giờ của cơ quan giám sát muốn sử dụng Lõi trình điều khiển hẹn giờ của WatchDog
phải #include <linux/watchdog.h> (dù sao bạn cũng phải làm điều này khi
viết trình điều khiển thiết bị giám sát). Tệp bao gồm này chứa sau
thói quen đăng ký/hủy đăng ký::

extern int watchdog_register_device(struct watchdog_device *);
	bên ngoài void watchdog_unregister_device(struct watchdog_device *);

Thủ tục watchdog_register_device đăng ký một thiết bị hẹn giờ theo dõi.
Tham số của thường trình này là một con trỏ tới cấu trúc watchdog_device.
Quy trình này trả về 0 nếu thành công và mã lỗi âm nếu thất bại.

Quy trình watchdog_unregister_device hủy đăng ký bộ đếm thời gian theo dõi đã đăng ký
thiết bị. Tham số của thủ tục này là con trỏ tới địa chỉ đã đăng ký
cấu trúc watchdog_device.

Hệ thống con cơ quan giám sát bao gồm cơ chế trì hoãn đăng ký,
cho phép bạn đăng ký một cơ quan giám sát sớm như bạn muốn trong thời gian
quá trình khởi động.

Cấu trúc thiết bị cơ quan giám sát trông như thế này::

cấu trúc cơ quan giám sát_device {
	int id;
	thiết bị cấu trúc *cha mẹ;
	const struct attribute_group **groups;
	const struct watchdog_info *thông tin;
	const struct watchdog_ops *ops;
	const struct watchdog_governor *gov;
	trạng thái khởi động int không dấu;
	hết thời gian chờ int;
	unsigned int pretimeout;
	unsigned int min_timeout;
	unsigned int max_timeout;
	unsigned int min_hw_heartbeat_ms;
	int unsign max_hw_heartbeat_ms;
	struct notifier_block khởi động lại_nb;
	struct notifier_block restart_nb;
	void *driver_data;
	cấu trúc watchdog_core_data *wd_data;
	trạng thái dài không dấu;
	struct list_head hoãn lại;
  };

Nó chứa các trường sau:

* id: được đặt bởi watchdog_register_device, id 0 là đặc biệt. Nó có cả một
  /dev/watchdog0 cdev (động chính, thứ 0) cũng như cũ
  /dev/watchdog miscdev. Id được đặt tự động khi gọi
  watchdog_register_device.
* cha mẹ: đặt cái này cho thiết bị mẹ (hoặc NULL) trước khi gọi
  watchdog_register_device.
* nhóm: Danh sách các nhóm thuộc tính sysfs sẽ tạo khi tạo cơ quan giám sát
  thiết bị.
* info: con trỏ tới cấu trúc watchdog_info. Cấu trúc này mang lại một số
  thông tin bổ sung về chính bộ đếm thời gian của cơ quan giám sát. (Giống như cái tên độc đáo của nó)
* ops: con trỏ tới danh sách các hoạt động của cơ quan giám sát mà cơ quan giám sát hỗ trợ.
* gov: một con trỏ tới bộ điều chỉnh thời gian chờ trước của thiết bị giám sát được chỉ định hoặc NULL.
* timeout: giá trị thời gian chờ của bộ đếm thời gian của cơ quan giám sát (tính bằng giây).
  Đây là thời điểm sau đó hệ thống sẽ khởi động lại nếu dung lượng người dùng không còn.
  không gửi yêu cầu nhịp tim nếu WDOG_ACTIVE được đặt.
* pretimeout: giá trị pretimeout của bộ đếm thời gian của cơ quan giám sát (tính bằng giây).
* min_timeout: giá trị thời gian chờ tối thiểu của bộ đếm thời gian theo dõi (tính bằng giây).
  Nếu được đặt, giá trị có thể định cấu hình tối thiểu cho 'thời gian chờ'.
* max_timeout: giá trị thời gian chờ tối đa của bộ đếm thời gian theo dõi (tính bằng giây),
  như được nhìn thấy từ không gian người dùng. Nếu được đặt, giá trị cấu hình tối đa cho
  'hết thời gian'. Không được sử dụng nếu max_hw_heartbeat_ms khác 0.
* min_hw_heartbeat_ms: Giới hạn phần cứng cho thời gian tối thiểu giữa các nhịp tim,
  tính bằng mili giây. Giá trị này thường là 0; nó chỉ nên được cung cấp
  nếu phần cứng không thể chịu đựng được khoảng thời gian thấp hơn giữa các nhịp tim.
* max_hw_heartbeat_ms: Nhịp tim phần cứng tối đa, tính bằng mili giây.
  Nếu được đặt, cơ sở hạ tầng sẽ gửi nhịp tim đến trình điều khiển cơ quan giám sát
  nếu 'thời gian chờ' lớn hơn max_hw_heartbeat_ms, trừ khi WDOG_ACTIVE
  được đặt và không gian người dùng không thể gửi nhịp tim trong ít nhất 'hết thời gian'
  giây. max_hw_heartbeat_ms phải được đặt nếu trình điều khiển không triển khai
  chức năng dừng.
* khởi động lại_nb: khối thông báo được đăng ký cho thông báo khởi động lại, dành cho
  chỉ sử dụng nội bộ. Nếu trình điều khiển gọi watchdog_stop_on_reboot, lõi cơ quan giám sát
  sẽ dừng cơ quan giám sát đối với những thông báo như vậy.
* restart_nb: khối thông báo được đăng ký để khởi động lại máy, dành cho
  chỉ sử dụng nội bộ. Nếu cơ quan giám sát có khả năng khởi động lại máy, nó
  nên xác định ops->khởi động lại. Mức độ ưu tiên có thể được thay đổi thông qua
  cơ quan giám sát_set_restart_priority.
* bootstatus: trạng thái của thiết bị sau khi khởi động (báo cáo với cơ quan giám sát
  các bit trạng thái WDIOF_*).
* driver_data: con trỏ tới dữ liệu riêng tư của trình điều khiển của thiết bị giám sát.
  Dữ liệu này chỉ nên được truy cập thông qua watchdog_set_drvdata và
  thói quen watchdog_get_drvdata.
* wd_data: một con trỏ tới dữ liệu nội bộ lõi của cơ quan giám sát.
* trạng thái: trường này chứa một số bit trạng thái cung cấp thêm
  thông tin về trạng thái của thiết bị (Giống như: là bộ đếm thời gian theo dõi
  đang chạy/đang hoạt động hoặc là bit hiện tại được đặt).
* hoãn lại: mục trong wtd_deferred_reg_list được sử dụng để
  đăng ký cơ quan giám sát khởi tạo sớm.

Danh sách các hoạt động giám sát được xác định là::

cấu trúc cơ quan giám sát_ops {
	mô-đun cấu trúc * chủ sở hữu;
	/*các thao tác bắt buộc*/
	int (ZZ0000ZZ);
	/*các thao tác tùy chọn*/
	int (ZZ0001ZZ);
	int (ZZ0002ZZ);
	int không dấu (ZZ0003ZZ);
	int (ZZ0004ZZ, int không dấu);
	int (ZZ0005ZZ, int không dấu);
	int không dấu (ZZ0006ZZ);
	int (ZZ0007ZZ);
	dài (ZZ0008ZZ, int không dấu, dài không dấu);
  };

Điều quan trọng là trước tiên bạn phải xác định chủ sở hữu mô-đun của bộ đếm thời gian theo dõi
hoạt động của người lái xe. Chủ sở hữu mô-đun này sẽ được sử dụng để khóa mô-đun khi
cơ quan giám sát đang hoạt động. (Điều này để tránh sự cố hệ thống khi bạn dỡ bỏ
mô-đun và/dev/watchdog vẫn mở).

Một số thao tác là bắt buộc và một số là tùy chọn. Các thao tác bắt buộc
là:

* bắt đầu: đây là con trỏ tới quy trình khởi động bộ đếm thời gian theo dõi
  thiết bị.
  Thủ tục này cần một con trỏ tới cấu trúc thiết bị hẹn giờ của cơ quan giám sát như một
  tham số. Nó trả về 0 nếu thành công hoặc mã lỗi âm nếu thất bại.

Không phải tất cả phần cứng bộ đếm thời gian của cơ quan giám sát đều hỗ trợ chức năng giống nhau. Đó là lý do tại sao
tất cả các thói quen/hoạt động khác là tùy chọn. Chúng chỉ cần được cung cấp nếu
họ được hỗ trợ. Các thói quen/hoạt động tùy chọn này là:

* dừng: với thói quen này, thiết bị hẹn giờ giám sát đang bị dừng.

Thủ tục này cần một con trỏ tới cấu trúc thiết bị hẹn giờ của cơ quan giám sát như một
  tham số. Nó trả về 0 nếu thành công hoặc mã lỗi âm nếu thất bại.
  Một số phần cứng hẹn giờ của cơ quan giám sát chỉ có thể được khởi động và không thể dừng lại. A
  trình điều khiển hỗ trợ phần cứng đó không phải thực hiện quy trình dừng.

Nếu trình điều khiển không có chức năng dừng, lõi cơ quan giám sát sẽ đặt WDOG_HW_RUNNING
  và bắt đầu gọi chức năng ping cố định của trình điều khiển sau cơ quan giám sát
  thiết bị đã đóng.

Nếu trình điều khiển cơ quan giám sát không thực hiện chức năng dừng thì nó phải đặt
  max_hw_heartbeat_ms.
* ping: đây là quy trình gửi ping liên tục đến bộ đếm thời gian theo dõi
  phần cứng.

Thủ tục này cần một con trỏ tới cấu trúc thiết bị hẹn giờ của cơ quan giám sát như một
  tham số. Nó trả về 0 nếu thành công hoặc mã lỗi âm nếu thất bại.

Hầu hết phần cứng không hỗ trợ chức năng này như một chức năng riêng biệt đều sử dụng
  chức năng khởi động để khởi động lại phần cứng bộ đếm thời gian của cơ quan giám sát. Và đó cũng là điều
  lõi trình điều khiển hẹn giờ của cơ quan giám sát thực hiện: gửi ping liên tục đến cơ quan giám sát
  phần cứng hẹn giờ, nó sẽ sử dụng thao tác ping (nếu có) hoặc
  bắt đầu hoạt động (khi không có hoạt động ping).

(Lưu ý: lệnh gọi ioctl WDIOC_KEEPALIVE sẽ chỉ hoạt động khi
  Bit WDIOF_KEEPALIVEPING đã được đặt trong trường tùy chọn trên cơ quan giám sát
  cấu trúc thông tin).
* trạng thái: thói quen này kiểm tra trạng thái của thiết bị hẹn giờ theo dõi. các
  trạng thái của thiết bị được báo cáo bằng cờ/bit trạng thái WDIOF_* của cơ quan giám sát.

WDIOF_MAGICCLOSE và WDIOF_KEEPALIVEPING được báo cáo bởi lõi cơ quan giám sát;
  không cần thiết phải báo cáo những bit đó từ trình điều khiển. Ngoài ra, nếu không có trạng thái
  được cung cấp bởi trình điều khiển, lõi cơ quan giám sát báo cáo các bit trạng thái
  được cung cấp trong biến bootstatus của struct watchdog_device.

* set_timeout: quy trình này kiểm tra và thay đổi thời gian chờ của cơ quan giám sát
  thiết bị hẹn giờ. Nó trả về 0 khi thành công, -EINVAL cho "tham số ngoài phạm vi"
  và -EIO cho "không thể ghi giá trị cho cơ quan giám sát". Về thành công này
  thường trình nên đặt giá trị thời gian chờ của watchdog_device thành
  đã đạt được giá trị thời gian chờ (có thể khác với giá trị được yêu cầu
  vì cơ quan giám sát không nhất thiết phải có độ phân giải 1 giây).

Trình điều khiển triển khai max_hw_heartbeat_ms đặt nhịp tim của cơ quan giám sát phần cứng
  đến mức tối thiểu thời gian chờ và max_hw_heartbeat_ms. Những trình điều khiển đó thiết lập
  giá trị thời gian chờ của watchdog_device bằng giá trị thời gian chờ được yêu cầu
  (nếu nó lớn hơn max_hw_heartbeat_ms) hoặc giá trị thời gian chờ đạt được.
  (Lưu ý: WDIOF_SETTIMEOUT cần được đặt trong trường tùy chọn của
  cấu trúc thông tin của cơ quan giám sát).

Nếu trình điều khiển cơ quan giám sát không phải thực hiện bất kỳ hành động nào ngoài việc thiết lập
  watchdog_device.timeout, cuộc gọi lại này có thể được bỏ qua.

Nếu set_timeout không được cung cấp nhưng WDIOF_SETTIMEOUT được đặt, cơ quan giám sát
  cơ sở hạ tầng cập nhật giá trị thời gian chờ của watchdog_device trong nội bộ
  đến giá trị được yêu cầu.

Nếu tính năng pretimeout được sử dụng (WDIOF_PRETIMEOUT), thì set_timeout phải
  Ngoài ra, hãy chú ý kiểm tra xem thời gian chờ có còn hiệu lực hay không và thiết lập bộ hẹn giờ
  tương ứng. Điều này không thể được thực hiện trong lõi nếu không có chủng tộc, vì vậy nó là
  nhiệm vụ của người lái xe.
* set_pretimeout: thủ tục này kiểm tra và thay đổi giá trị pretimeout của
  cơ quan giám sát. Đây là tùy chọn vì không phải tất cả các cơ quan giám sát đều hỗ trợ thời gian chờ trước
  thông báo. Giá trị thời gian chờ không phải là thời gian tuyệt đối mà là số lượng
  giây trước khi thời gian chờ thực sự xảy ra. Nó trả về 0 khi thành công,
  -EINVAL cho "tham số nằm ngoài phạm vi" và -EIO cho "không thể ghi giá trị vào
  cơ quan giám sát". Giá trị 0 sẽ tắt thông báo trước thời gian chờ.

(Lưu ý: WDIOF_PRETIMEOUT cần được đặt trong trường tùy chọn của
  cấu trúc thông tin của cơ quan giám sát).

Nếu trình điều khiển cơ quan giám sát không phải thực hiện bất kỳ hành động nào ngoài việc thiết lập
  watchdog_device.pretimeout, cuộc gọi lại này có thể được bỏ qua. Điều đó có nghĩa là nếu
  set_pretimeout không được cung cấp nhưng WDIOF_PRETIMEOUT được đặt, cơ quan giám sát
  cơ sở hạ tầng cập nhật giá trị trước thời gian chờ của watchdog_device trong nội bộ
  đến giá trị được yêu cầu.

* get_timeleft: thủ tục này trả về thời gian còn lại trước khi thiết lập lại.
* khởi động lại: thói quen này khởi động lại máy. Nó trả về 0 nếu thành công hoặc
  mã lỗi tiêu cực cho sự thất bại.
* ioctl: nếu thủ tục này tồn tại thì nó sẽ được gọi trước khi chúng ta thực hiện
  xử lý cuộc gọi ioctl nội bộ của chúng tôi. Thói quen này sẽ trả về -ENOIOCTLCMD
  nếu một lệnh không được hỗ trợ. Các tham số được truyền tới ioctl
  gọi là: watchdog_device, cmd và arg.

Các bit trạng thái nên (tốt nhất) nên được đặt giống nhau với set_bit và clear_bit
hoạt động bit. Các bit trạng thái được xác định là:

* WDOG_ACTIVE: bit trạng thái này cho biết có thiết bị hẹn giờ theo dõi hay không
  đang hoạt động hay không từ góc độ người dùng. Không gian người dùng dự kiến sẽ gửi
  yêu cầu nhịp tim tới trình điều khiển trong khi cờ này được đặt.
* WDOG_NO_WAY_OUT: bit này lưu trữ cài đặt tạm thời cho cơ quan giám sát.
  Nếu bit này được đặt thì bộ đếm thời gian theo dõi sẽ không thể dừng lại.
* WDOG_HW_RUNNING: Được thiết lập bởi trình điều khiển cơ quan giám sát nếu cơ quan giám sát phần cứng
  đang chạy. Bit này phải được đặt nếu phần cứng bộ đếm thời gian của cơ quan giám sát không thể
  dừng lại. Bit này cũng có thể được đặt nếu bộ đếm thời gian theo dõi đang chạy sau
  khởi động, trước khi thiết bị giám sát được mở. Nếu được đặt, cơ quan giám sát
  cơ sở hạ tầng sẽ gửi các thông tin lưu giữ tới phần cứng cơ quan giám sát trong khi
  WDOG_ACTIVE chưa được đặt.
  Lưu ý: khi bạn đăng ký thiết bị hẹn giờ cơ quan giám sát với tập bit này,
  sau đó mở /dev/watchdog sẽ bỏ qua thao tác bắt đầu nhưng gửi một bản lưu giữ
  thay vào đó hãy yêu cầu.

Để đặt bit trạng thái WDOG_NO_WAY_OUT (trước khi đăng ký cơ quan giám sát của bạn
  thiết bị hẹn giờ), bạn có thể:

* đặt nó tĩnh trong cấu trúc watchdog_device của bạn với

.status = WATCHDOG_NOWAYOUT_INIT_STATUS,

(điều này sẽ đặt giá trị giống như CONFIG_WATCHDOG_NOWAYOUT) hoặc
  * sử dụng chức năng trợ giúp sau::

nội tuyến tĩnh void watchdog_set_nowayout(struct watchdog_device *wdd,
						 int bây giờ)

Lưu ý:
   Lõi trình điều khiển hẹn giờ WatchDog hỗ trợ tính năng đóng kỳ diệu và
   tính năng hiện tại. Để sử dụng tính năng đóng kỳ diệu, bạn phải đặt
   Bit WDIOF_MAGICCLOSE trong trường tùy chọn của cấu trúc thông tin của cơ quan giám sát.

Tính năng tạm thời sẽ ghi đè tính năng đóng kỳ diệu.

Để lấy hoặc đặt dữ liệu cụ thể của trình điều khiển, cần có hai chức năng trợ giúp sau:
đã sử dụng::

nội tuyến tĩnh void watchdog_set_drvdata(struct watchdog_device *wdd,
					  void *dữ liệu)
  khoảng trống nội tuyến tĩnh *watchdog_get_drvdata(struct watchdog_device *wdd)

Chức năng watchdog_set_drvdata cho phép bạn thêm dữ liệu cụ thể của trình điều khiển. các
đối số của hàm này là thiết bị giám sát nơi bạn muốn thêm
điều khiển dữ liệu cụ thể tới và một con trỏ tới chính dữ liệu đó.

Chức năng watchdog_get_drvdata cho phép bạn truy xuất dữ liệu cụ thể của trình điều khiển.
Đối số của hàm này là thiết bị giám sát nơi bạn muốn truy xuất
dữ liệu từ. Hàm trả về con trỏ tới dữ liệu cụ thể của trình điều khiển.

Để khởi tạo trường thời gian chờ, có thể sử dụng chức năng sau ::

extern int watchdog_init_timeout(struct watchdog_device *wdd,
                                   thời gian chờ_parm không dấu int,
                                   thiết bị cấu trúc const *dev);

Hàm watchdog_init_timeout cho phép bạn khởi tạo trường hết thời gian chờ
sử dụng tham số thời gian chờ của mô-đun hoặc bằng cách truy xuất thuộc tính timeout-sec từ
cây thiết bị (nếu tham số thời gian chờ của mô-đun không hợp lệ). Thực hành tốt nhất là
để đặt giá trị thời gian chờ mặc định làm giá trị thời gian chờ trong watchdog_device và
sau đó sử dụng chức năng này để đặt giá trị thời gian chờ "ưa thích" của người dùng.
Quy trình này trả về 0 nếu thành công và mã lỗi âm nếu thất bại.

Để tắt cơ quan giám sát khi khởi động lại, người dùng phải gọi người trợ giúp sau::

nội tuyến tĩnh void watchdog_stop_on_reboot(struct watchdog_device *wdd);

Để vô hiệu hóa cơ quan giám sát khi hủy đăng ký cơ quan giám sát, người dùng phải gọi
người trợ giúp sau đây. Lưu ý rằng điều này sẽ chỉ dừng cơ quan giám sát nếu
cờ nowout không được đặt.

::

nội tuyến tĩnh void watchdog_stop_on_unregister(struct watchdog_device *wdd);

Để thay đổi mức độ ưu tiên của trình xử lý khởi động lại, cần có trình trợ giúp sau
đã sử dụng::

void watchdog_set_restart_priority(struct watchdog_device *wdd, int ưu tiên);

Người dùng nên làm theo các nguyên tắc sau để đặt mức độ ưu tiên:

* 0: nên được gọi trong trường hợp cuối cùng, khả năng khởi động lại bị hạn chế
* 128: trình xử lý khởi động lại mặc định, sử dụng nếu không có trình xử lý nào khác được mong đợi
  khả dụng và/hoặc nếu khởi động lại là đủ để khởi động lại toàn bộ hệ thống
* 255: mức ưu tiên cao nhất, sẽ ưu tiên tất cả các trình xử lý khởi động lại khác

Để đưa ra thông báo trước thời gian chờ, nên sử dụng chức năng sau ::

void watchdog_notify_pretimeout(struct watchdog_device *wdd)

Hàm có thể được gọi trong ngữ cảnh ngắt. Nếu cơ quan giám sát hết thời gian chờ
khung thống đốc (biểu tượng kbuild CONFIG_WATCHDOG_PRETIMEOUT_GOV) được bật,
một hành động được thực hiện bởi một bộ điều chỉnh thời gian chờ được cấu hình sẵn được chỉ định trước cho
thiết bị giám sát. Nếu khung điều hành pretimeout của cơ quan giám sát không
được bật, watchdog_notify_pretimeout() sẽ in thông báo tới
bộ đệm nhật ký kernel.

Để đặt thời gian lưu giữ CTNH cuối cùng đã biết cho cơ quan giám sát, chức năng sau
nên sử dụng::

int watchdog_set_last_hw_keepalive(struct watchdog_device *wdd,
                                     int unsigned_ping_ms)

Chức năng này phải được gọi ngay sau khi đăng ký cơ quan giám sát. Nó
đặt nhịp tim phần cứng đã biết gần đây nhất đã xảy ra lần cuối_ping_ms trước đó
thời điểm hiện tại. Việc gọi này chỉ cần thiết nếu cơ quan giám sát đang chạy
khi thăm dò được gọi và cơ quan giám sát chỉ có thể được ping sau khi
min_hw_heartbeat_ms thời gian đã trôi qua kể từ lần ping cuối cùng.
