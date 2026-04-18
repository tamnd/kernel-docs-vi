.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hid/hid-transport.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================================
Trình điều khiển vận chuyển I/O HID
===================================

Hệ thống con HID độc lập với trình điều khiển vận chuyển cơ bản. Ban đầu,
chỉ hỗ trợ USB, nhưng các thông số kỹ thuật khác áp dụng thiết kế HID và
cung cấp tài xế vận tải mới. Hạt nhân bao gồm ít nhất sự hỗ trợ cho USB,
Trình điều khiển I/O Bluetooth, I2C và không gian người dùng.

1) Xe buýt HID
==============

Hệ thống con HID được thiết kế dưới dạng xe buýt. Bất kỳ hệ thống con I/O nào cũng có thể cung cấp HID
thiết bị và đăng ký chúng với bus HID. Lõi HID sau đó tải thiết bị chung
trình điều khiển trên đầu trang của nó. Trình điều khiển vận chuyển chịu trách nhiệm về dữ liệu thô
thiết lập/quản lý thiết bị và vận chuyển. Lõi HID chịu trách nhiệm
phân tích báo cáo, giải thích báo cáo và không gian người dùng API. Thông tin cụ thể về thiết bị
và các quirk được xử lý bởi tất cả các lớp tùy thuộc vào quirk.

::

+----------+ +-----------+ +----------+ +----------+ +
 ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ
 +----------+ +-----------+ +----------+ +----------+ +
          \\ // \\ //
        +-------------+ +-------------+
        ZZ0004ZZ ZZ0005ZZ
        +-------------+ +-------------+
              |ZZ0006ZZ|
     +-------------------+ +-------------------+
     ZZ0007ZZ ZZ0008ZZ
     +-------------------+ +-------------------+
                       \___ ___/
                           \ /
                          +----------------+
                          ZZ0009ZZ
                          +----------------+
                           / ZZ0010ZZ \
                          / ZZ0011ZZ \
             ____________/ ZZ0012ZZ \_________________
            / ZZ0013ZZ \
           / ZZ0014ZZ \
 ++-------+ +-----------+ +-------------------+ +-------------------+
 ZZ0015ZZ ZZ0016ZZ ZZ0017ZZ ZZ0018ZZ
 ++-------+ +-----------+ +-------------------+ +-------------------+

Trình điều khiển ví dụ:

- Đầu vào/ra: USB, I2C, Bluetooth-l2cap
  - Vận chuyển: USB-HID, I2C-HID, BT-HIDP

Mọi thứ bên dưới "Lõi HID" được đơn giản hóa trong biểu đồ này vì nó chỉ dành cho
quan tâm đến trình điều khiển thiết bị HID. Người lái xe vận tải không cần biết
chi tiết cụ thể.

1.1) Cài đặt thiết bị
---------------------

Trình điều khiển I/O thường cung cấp các API liệt kê thiết bị hoặc phát hiện cắm nóng cho
tài xế vận tải. Trình điều khiển vận chuyển sử dụng điều này để tìm bất kỳ thiết bị HID nào phù hợp.
Họ phân bổ các đối tượng thiết bị HID và đăng ký chúng với lõi HID. Vận chuyển
trình điều khiển không bắt buộc phải tự đăng ký với lõi HID. Lõi HID không bao giờ
biết trình điều khiển vận tải nào có sẵn và không quan tâm đến nó. Nó
chỉ quan tâm đến thiết bị.

Trình điều khiển vận chuyển đính kèm một đối tượng "struct hid_ll_driver" không đổi với mỗi đối tượng
thiết bị. Sau khi thiết bị được đăng ký với lõi HID, các lệnh gọi lại được cung cấp qua
cấu trúc này được lõi HID sử dụng để giao tiếp với thiết bị.

Trình điều khiển vận chuyển có trách nhiệm phát hiện lỗi thiết bị và rút phích cắm.
Lõi HID sẽ vận hành một thiết bị miễn là nó được đăng ký bất kể bất kỳ điều gì
lỗi thiết bị. Khi trình điều khiển vận chuyển phát hiện sự kiện rút phích cắm hoặc lỗi, họ
phải hủy đăng ký thiết bị khỏi lõi HID và lõi HID sẽ ngừng sử dụng
cung cấp các cuộc gọi lại.

1.2) Yêu cầu đối với người lái xe vận tải
-----------------------------------------

Thuật ngữ "không đồng bộ" và "đồng bộ" trong tài liệu này mô tả
hành vi truyền tải liên quan đến xác nhận. Một kênh không đồng bộ phải
không thực hiện bất kỳ hoạt động đồng bộ nào như chờ xác nhận hoặc
xác minh. Nói chung, các cuộc gọi HID hoạt động trên các kênh không đồng bộ phải được
chạy trong bối cảnh nguyên tử tốt.
Mặt khác, các kênh đồng bộ có thể được thực hiện bằng cách vận chuyển
lái xe theo bất cứ cách nào họ thích. Chúng có thể giống như không đồng bộ
kênh, nhưng họ cũng có thể cung cấp các báo cáo xác nhận, tự động
truyền lại khi bị lỗi, v.v. theo cách chặn. Nếu chức năng đó được
được yêu cầu trên các kênh không đồng bộ, trình điều khiển vận chuyển phải thực hiện điều đó thông qua
chủ đề công nhân của riêng mình.

Lõi HID yêu cầu trình điều khiển vận chuyển phải tuân theo một thiết kế nhất định. một phương tiện giao thông
trình điều khiển phải cung cấp hai kênh I/O hai chiều cho mỗi thiết bị HID. Những cái này
các kênh không nhất thiết phải là hai chiều trong chính phần cứng. A
trình điều khiển vận tải có thể chỉ cung cấp 4 kênh một chiều. Hoặc nó có thể
ghép cả bốn trên một kênh vật lý duy nhất. Tuy nhiên, trong tài liệu này chúng tôi
sẽ mô tả chúng như hai kênh hai chiều vì chúng có một số
tài sản chung.

- Interrupt Channel (intr): Kênh intr dùng cho dữ liệu không đồng bộ
   báo cáo. Không có lệnh quản lý hoặc xác nhận dữ liệu nào được gửi trên này
   kênh. Mọi báo cáo dữ liệu đến hoặc đi không được yêu cầu phải được gửi vào
   kênh này và không bao giờ được phía từ xa thừa nhận. Các thiết bị thường
   gửi các sự kiện đầu vào của họ trên kênh này. Các sự kiện đi diễn ra bình thường
   không được gửi qua intr, trừ khi yêu cầu thông lượng cao.
 - Kênh điều khiển (ctrl): Kênh ctrl được sử dụng cho các yêu cầu đồng bộ và
   quản lý thiết bị. Các sự kiện nhập dữ liệu không được yêu cầu không được gửi trên này
   kênh và thường bị bỏ qua. Thay vào đó, thiết bị chỉ gửi quản lý
   sự kiện hoặc câu trả lời cho các yêu cầu lưu trữ trên kênh này.
   Kênh điều khiển được sử dụng để chặn truy vấn trực tiếp tới thiết bị
   độc lập với bất kỳ sự kiện nào trên kênh nội bộ.
   Các báo cáo gửi đi thường được gửi trên kênh ctrl thông qua tính năng đồng bộ
   Yêu cầu SET_REPORT.

Giao tiếp giữa các thiết bị và lõi HID hầu hết được thực hiện thông qua các báo cáo HID. A
báo cáo có thể thuộc một trong ba loại:

- Báo cáo INPUT: Báo cáo đầu vào cung cấp dữ liệu từ thiết bị đến máy chủ. Cái này
   dữ liệu có thể bao gồm các sự kiện nút, sự kiện trục, trạng thái pin hoặc hơn thế nữa. Cái này
   dữ liệu được thiết bị tạo ra và gửi đến máy chủ có hoặc không có
   yêu cầu những yêu cầu rõ ràng. Thiết bị có thể chọn gửi dữ liệu liên tục hoặc
   chỉ khi thay đổi.
 - Báo cáo OUTPUT: Báo cáo đầu ra thay đổi trạng thái thiết bị. Chúng được gửi từ máy chủ
   tới thiết bị và có thể bao gồm các yêu cầu LED, yêu cầu ầm ầm hoặc hơn thế nữa. đầu ra
   các báo cáo không bao giờ được gửi từ thiết bị tới máy chủ, nhưng máy chủ có thể truy xuất các báo cáo đó
   trạng thái hiện tại.
   Máy chủ có thể chọn gửi báo cáo đầu ra liên tục hoặc chỉ trên
   thay đổi.
 - Báo cáo FEATURE: Báo cáo tính năng được sử dụng cho các tính năng thiết bị tĩnh cụ thể
   và không bao giờ báo cáo một cách tự phát. Máy chủ có thể đọc và/hoặc ghi chúng để truy cập
   dữ liệu như trạng thái pin hoặc cài đặt thiết bị.
   Báo cáo tính năng không bao giờ được gửi mà không có yêu cầu. Máy chủ phải thiết lập rõ ràng
   hoặc truy xuất một báo cáo tính năng. Điều này cũng có nghĩa là các báo cáo tính năng sẽ không bao giờ được gửi
   trên kênh intr vì kênh này không đồng bộ.

Báo cáo INPUT và OUTPUT có thể được gửi dưới dạng báo cáo dữ liệu thuần túy trên kênh intr.
Đối với báo cáo INPUT, đây là chế độ hoạt động thông thường. Nhưng đối với các báo cáo của OUTPUT,
điều này hiếm khi được thực hiện vì các báo cáo OUTPUT thường khá khan hiếm. Nhưng các thiết bị được
được tự do sử dụng quá mức các báo cáo OUTPUT không đồng bộ (ví dụ: tùy chỉnh
Loa âm thanh HID tận dụng tối đa tính năng này).

Tuy nhiên, các báo cáo đơn giản không được gửi trên kênh ctrl. Thay vào đó, ctrl
kênh cung cấp các yêu cầu GET/SET_REPORT đồng bộ. Các báo cáo đơn giản chỉ
được phép trên kênh intr và là phương tiện dữ liệu duy nhất ở đó.

- GET_REPORT: Yêu cầu GET_REPORT có ID báo cáo là tải trọng và được gửi
   từ máy chủ tới thiết bị. Thiết bị phải trả lời bằng một báo cáo dữ liệu cho
   ID báo cáo được yêu cầu trên kênh ctrl dưới dạng xác nhận đồng bộ.
   Chỉ có một yêu cầu GET_REPORT có thể chờ xử lý cho mỗi thiết bị. Hạn chế này
   được thực thi bởi lõi HID vì một số trình điều khiển truyền tải không cho phép nhiều
   yêu cầu GET_REPORT đồng thời.
   Lưu ý rằng các báo cáo dữ liệu được gửi dưới dạng câu trả lời cho yêu cầu GET_REPORT là
   không được xử lý như các sự kiện chung của thiết bị. Nghĩa là, nếu một thiết bị không hoạt động
   ở chế độ báo cáo dữ liệu liên tục, câu trả lời cho GET_REPORT không thay thế
   báo cáo dữ liệu thô trên kênh intr về sự thay đổi trạng thái.
   GET_REPORT chỉ được sử dụng bởi trình điều khiển thiết bị HID tùy chỉnh để truy vấn trạng thái thiết bị.
   Thông thường, lõi HID lưu trữ mọi trạng thái thiết bị nên yêu cầu này là không cần thiết
   trên các thiết bị tuân theo thông số HID ngoại trừ trong quá trình khởi tạo thiết bị thành
   truy xuất trạng thái hiện tại.
   Yêu cầu GET_REPORT có thể được gửi cho bất kỳ loại báo cáo nào trong số 3 loại báo cáo và sẽ
   trả về trạng thái báo cáo hiện tại của thiết bị. Tuy nhiên, OUTPUT báo cáo là
   tải trọng có thể bị chặn bởi trình điều khiển vận chuyển cơ bản nếu
   đặc điểm kỹ thuật không cho phép họ.
 - SET_REPORT: Yêu cầu SET_REPORT có ID báo cáo cộng với dữ liệu dưới dạng tải trọng. Đó là
   được gửi từ máy chủ đến thiết bị và thiết bị phải cập nhật trạng thái báo cáo hiện tại
   theo dữ liệu đã cho. Có thể sử dụng bất kỳ loại báo cáo nào trong số 3 loại báo cáo. Tuy nhiên,
   INPUT báo cáo rằng tải trọng có thể bị chặn bởi trình điều khiển vận chuyển cơ bản
   nếu đặc điểm kỹ thuật không cho phép chúng.
   Thiết bị phải trả lời bằng xác nhận đồng bộ. Tuy nhiên, lõi HID
   không yêu cầu người điều khiển phương tiện vận chuyển chuyển tiếp xác nhận này tới HID
   cốt lõi.
   Tương tự như đối với GET_REPORT, mỗi lần chỉ có một SET_REPORT có thể chờ xử lý. Cái này
   hạn chế được thực thi bởi lõi HID vì một số trình điều khiển truyền tải không hỗ trợ
   nhiều yêu cầu SET_REPORT đồng bộ.

Các yêu cầu kênh ctrl khác được USB-HID hỗ trợ nhưng không khả dụng
(hoặc không được dùng nữa) trong hầu hết các thông số kỹ thuật cấp độ vận chuyển khác:

- GET/SET_IDLE: Chỉ được sử dụng bởi USB-HID và I2C-HID.
 - GET/SET_PROTOCOL: Không được sử dụng bởi lõi HID.
 - RESET: Được sử dụng bởi I2C-HID, không nối vào lõi HID.
 - SET_POWER: Được sử dụng bởi I2C-HID, không nối vào lõi HID.

2) HID API
==========

2.1) Khởi tạo
-------------------

Trình điều khiển vận tải thường sử dụng quy trình sau để đăng ký thiết bị mới
với lõi HID::

cấu trúc hid_device *hid;
	int ret;

hid = hid_allocate_device();
	nếu (IS_ERR(hid)) {
		ret = PTR_ERR(ẩn);
		đã xảy ra lỗi_<...>;
	}

strscpy(hid->name, <tên thiết bị-src>, sizeof(hid->name));
	strscpy(hid->phys, <device-phys-src>, sizeof(hid->phys));
	strscpy(hid->uniq, <device-uniq-src>, sizeof(hid->uniq));

hid->ll_driver = &custom_ll_driver;
	hid->bus = <device-bus>;
	hid->nhà cung cấp = <nhà cung cấp thiết bị>;
	hid->product = <device-product>;
	hid->version = <device-version>;
	hid->country = <device-country>;
	hid->dev.parent = <con trỏ tới thiết bị gốc>;
	hid->driver_data = <transport-driver-data-field>;

ret = hid_add_device(hid);
	nếu (ret)
		đã xảy ra lỗi_<...>;

Sau khi nhập hid_add_device(), lõi HID có thể sử dụng các lệnh gọi lại được cung cấp trong
"custom_ll_driver". Lưu ý rằng các trường như "quốc gia" có thể bị bỏ qua bởi
trình điều khiển vận chuyển nếu không được hỗ trợ.

Để hủy đăng ký một thiết bị, hãy sử dụng::

hid_destroy_device(ẩn);

Khi hid_destroy_device() trả về, lõi HID sẽ không còn sử dụng bất kỳ
cuộc gọi lại của tài xế.

2.2) hoạt động hid_ll_driver
-----------------------------

Các lệnh gọi lại HID có sẵn là:

   ::

int (*start) (struct hid_device *hdev)

Được gọi từ trình điều khiển thiết bị HID khi họ muốn sử dụng thiết bị. Vận chuyển
   người lái xe có thể chọn thiết lập thiết bị của họ trong cuộc gọi lại này. Tuy nhiên, thông thường
   các thiết bị đã được thiết lập trước khi trình điều khiển vận chuyển đăng ký chúng vào lõi HID
   vì vậy điều này hầu như chỉ được sử dụng bởi USB-HID.

   ::

khoảng trống (ZZ0000Zhdev)

Được gọi từ trình điều khiển thiết bị HID sau khi chúng hoàn tất với thiết bị. Vận chuyển
   trình điều khiển có thể giải phóng mọi bộ đệm và khởi tạo lại thiết bị. Nhưng lưu ý rằng
   ->start() có thể được gọi lại nếu trình điều khiển thiết bị HID khác được tải trên
   thiết bị.

Trình điều khiển vận chuyển có thể tự do bỏ qua nó và khởi tạo lại thiết bị sau khi chúng
   đã tiêu diệt chúng thông qua hid_destroy_device().

   ::

int (*open) (struct hid_device *hdev)

Được gọi từ trình điều khiển thiết bị HID khi họ quan tâm đến báo cáo dữ liệu.
   Thông thường, mặc dù không gian người dùng không mở bất kỳ đầu vào API/v.v. nào, trình điều khiển thiết bị là
   không quan tâm đến dữ liệu thiết bị và trình điều khiển vận chuyển có thể khiến thiết bị ở chế độ ngủ.
   Tuy nhiên, khi ->open() được gọi, trình điều khiển truyền tải phải sẵn sàng cho I/O.
   ->open() các lệnh gọi được lồng vào nhau cho mỗi máy khách mở thiết bị HID.

   ::

khoảng trống (ZZ0000Zhdev)

Được gọi từ trình điều khiển thiết bị HID sau khi ->open() được gọi nhưng chúng không hoạt động
   còn quan tâm đến báo cáo thiết bị. (Thông thường nếu không gian người dùng đóng bất kỳ đầu vào nào
   thiết bị của người lái xe).

Trình điều khiển vận chuyển có thể đặt các thiết bị ở chế độ ngủ và chấm dứt mọi thao tác I/O
   Lệnh gọi ->open() được theo sau bởi lệnh gọi ->close(). Tuy nhiên, ->start() có thể
   được gọi lại nếu trình điều khiển thiết bị quan tâm đến báo cáo đầu vào lần nữa.

   ::

int (*parse) (struct hid_device *hdev)

Được gọi một lần trong quá trình thiết lập thiết bị sau khi ->start() được gọi. Vận chuyển
   trình điều khiển phải đọc phần mô tả báo cáo HID từ thiết bị và thông báo cho lõi HID
   về nó thông qua hid_parse_report().

   ::

int (*power) (struct hid_device *hdev, cấp độ int)

Được gọi bởi lõi HID để đưa ra gợi ý PM cho tài xế vận tải. Thông thường đây là
   tương tự với các gợi ý ->open() và ->close() và dư thừa.

   ::

void (ZZ0000Zhdev, struct hid_report *báo cáo,
		       int reqtype)

Gửi yêu cầu HID trên kênh ctrl. "báo cáo" chứa báo cáo rằng
   phải được gửi và "reqtype" loại yêu cầu. Loại yêu cầu có thể là
   HID_REQ_SET_REPORT hoặc HID_REQ_GET_REPORT.

Cuộc gọi lại này là tùy chọn. Nếu không được cung cấp, lõi HID sẽ lắp ráp một bản thô
   báo cáo theo thông số kỹ thuật HID và gửi nó qua lệnh gọi lại ->raw_request().
   Trình điều khiển vận chuyển có thể tự do thực hiện điều này một cách không đồng bộ.

   ::

int (*wait) (struct hid_device *hdev)

Được sử dụng bởi lõi HID trước khi gọi lại ->request(). Người lái xe vận tải có thể sử dụng
   nó chờ mọi yêu cầu đang chờ xử lý hoàn thành nếu chỉ có một yêu cầu
   được phép tại một thời điểm.

   ::

int (*raw_request) (struct hid_device *hdev, báo cáo char không dấu,
                          __u8 *buf, số lượng size_t, rtype char không dấu,
                          int reqtype)

Tương tự như ->request() nhưng cung cấp báo cáo dưới dạng bộ đệm thô. Yêu cầu này sẽ
   được đồng bộ. Người lái xe vận chuyển không được sử dụng ->wait() để hoàn thành việc đó
   yêu cầu. Yêu cầu này là bắt buộc và lõi ẩn sẽ từ chối thiết bị nếu
   nó bị thiếu.

   ::

int (ZZ0000Zhdev, __u8 *buf, size_t len)

Gửi báo cáo đầu ra thô qua kênh intr. Được sử dụng bởi một số trình điều khiển thiết bị HID
   đòi hỏi thông lượng cao cho các yêu cầu gửi đi trên kênh nội bộ. Cái này
   không được gây ra cuộc gọi SET_REPORT! Điều này phải được thực hiện dưới dạng không đồng bộ
   báo cáo đầu ra trên kênh intr!

   ::

int (*idle) (struct hid_device *hdev, báo cáo int, int nhàn rỗi, int reqtype)

Thực hiện yêu cầu SET/GET_IDLE. Chỉ được sử dụng bởi USB-HID, không thực hiện!

2.3) Đường dẫn dữ liệu
----------------------

Trình điều khiển vận chuyển chịu trách nhiệm đọc dữ liệu từ các thiết bị I/O. Họ phải
tự xử lý mọi hoạt động theo dõi trạng thái liên quan đến I/O. Lõi HID không triển khai
bắt tay giao thức hoặc các lệnh quản lý khác có thể được yêu cầu bởi
đưa ra thông số kỹ thuật vận chuyển HID.

Mọi gói dữ liệu thô được đọc từ thiết bị phải được đưa vào lõi HID thông qua
hid_input_report(). Bạn phải chỉ định loại kênh (intr hoặc ctrl) và báo cáo
loại (đầu vào/đầu ra/tính năng). Trong điều kiện bình thường, chỉ có báo cáo đầu vào mới được
được cung cấp qua API này.

Phản hồi các yêu cầu GET_REPORT qua ->request() cũng phải được cung cấp qua đây
API. Các phản hồi cho ->raw_request() là đồng bộ và phải được chặn bởi
trình điều khiển vận chuyển và không được chuyển tới hid_input_report().
Lời cảm ơn đối với các yêu cầu của SET_REPORT không được lõi HID quan tâm.

---------------------------------------------------

Viết năm 2013, David Herrmann <dh.herrmann@gmail.com>
