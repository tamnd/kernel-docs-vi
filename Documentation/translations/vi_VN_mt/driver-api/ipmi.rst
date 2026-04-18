.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/ipmi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Trình điều khiển Linux IPMI
===========================

:Tác giả: Corey Minyard <minyard@mvista.com> / <minyard@acm.org>

Giao diện quản lý nền tảng thông minh, hay IPMI, là một
tiêu chuẩn để điều khiển các thiết bị thông minh giám sát hệ thống.
Nó cung cấp khả năng khám phá động các cảm biến trong hệ thống và
khả năng giám sát các cảm biến và được thông báo khi cảm biến
giá trị thay đổi hoặc đi ra ngoài ranh giới nhất định.  Nó cũng có một
cơ sở dữ liệu được tiêu chuẩn hóa cho các đơn vị có thể thay thế tại hiện trường (FRU) và cơ quan giám sát
hẹn giờ.

Để sử dụng tính năng này, bạn cần có giao diện với bộ điều khiển IPMI trong
hệ thống (được gọi là Bộ điều khiển quản lý bảng cơ sở hoặc BMC) và
phần mềm quản lý có thể sử dụng hệ thống IPMI.

Tài liệu này mô tả cách sử dụng trình điều khiển IPMI cho Linux.  Nếu bạn
không quen thuộc với IPMI, hãy xem trang web tại
ZZ0000ZZ IPMI là một lớn
chủ đề và tôi không thể trình bày tất cả ở đây!

Cấu hình
-------------

Trình điều khiển Linux IPMI có dạng mô-đun, nghĩa là bạn phải chọn một số
mọi thứ để nó hoạt động tốt tùy thuộc vào phần cứng của bạn.  Hầu hết
những thứ này có sẵn trong menu 'Thiết bị ký tự', sau đó là IPMI
thực đơn.

Dù thế nào đi nữa, bạn cũng phải chọn 'Trình xử lý tin nhắn cấp cao nhất IPMI' để sử dụng
IPMI.  Những gì bạn làm ngoài điều đó phụ thuộc vào nhu cầu và phần cứng của bạn.

Trình xử lý tin nhắn không cung cấp bất kỳ giao diện cấp độ người dùng nào.
Mã hạt nhân (như cơ quan giám sát) vẫn có thể sử dụng nó.  Nếu bạn cần quyền truy cập
từ vùng người dùng, bạn cần chọn 'Giao diện thiết bị cho IPMI' nếu bạn
muốn truy cập thông qua trình điều khiển thiết bị.

Giao diện trình điều khiển phụ thuộc vào phần cứng của bạn.  Nếu hệ thống của bạn
cung cấp đúng thông tin SMBIOS cho IPMI, trình điều khiển sẽ phát hiện ra thông tin đó
và chỉ làm việc.  Nếu bạn có một bo mạch có giao diện chuẩn (Những
thường sẽ là "KCS", "SMIC" hoặc "BT", hãy tham khảo phần cứng của bạn
hướng dẫn sử dụng), hãy chọn tùy chọn 'Trình xử lý IPMI SI'.  Một trình điều khiển cũng tồn tại
để truy cập trực tiếp I2C vào bộ điều khiển quản lý IPMI.  Một số bảng
hỗ trợ điều này, nhưng không biết liệu nó có hoạt động trên mọi bảng hay không.  cho
này, hãy chọn 'Trình xử lý IPMI SMBus' nhưng hãy sẵn sàng thử thực hiện một số thao tác
đang tìm hiểu xem liệu nó có hoạt động trên hệ thống của bạn không nếu SMBIOS/ACPI
thông tin sai hoặc không có.  Khá an toàn khi có cả hai
những tính năng này được bật và cho phép trình điều khiển tự động phát hiện những gì hiện có.

Nói chung, bạn nên kích hoạt ACPI trên hệ thống của mình, giống như các hệ thống có IPMI
có thể có các bảng ACPI mô tả chúng.

Nếu bạn có giao diện chuẩn và nhà sản xuất bo mạch đã thực hiện
công việc của họ một cách chính xác, bộ điều khiển IPMI sẽ tự động
được phát hiện (thông qua bảng ACPI hoặc SMBIOS) và sẽ hoạt động.  Đáng buồn thay,
nhiều bảng không có thông tin này.  Tài xế cố gắng
mặc định tiêu chuẩn, nhưng chúng có thể không hoạt động.  Nếu bạn rơi vào trường hợp này
trong trường hợp này, bạn cần đọc phần bên dưới có tên 'Trình điều khiển SI' hoặc
"Trình điều khiển SMBus" về cách cấu hình thủ công hệ thống của bạn.

IPMI định nghĩa bộ đếm thời gian theo dõi tiêu chuẩn.  Bạn có thể kích hoạt tính năng này bằng
Tùy chọn cấu hình 'IPMI Watchdog Hẹn giờ'.  Nếu bạn biên dịch trình điều khiển thành
kernel, sau đó thông qua tùy chọn dòng lệnh kernel, bạn có thể có
bộ đếm thời gian của cơ quan giám sát bắt đầu ngay khi nó khởi tạo.  Nó cũng có rất nhiều
trong số các tùy chọn khác, hãy xem phần 'Cơ quan giám sát' bên dưới để biết thêm chi tiết.
Lưu ý rằng bạn cũng có thể yêu cầu cơ quan giám sát tiếp tục chạy nếu nó
đã đóng (theo mặc định nó bị tắt khi đóng).  Đi vào 'Cơ quan giám sát
Menu thẻ, bật 'Hỗ trợ hẹn giờ theo dõi' và bật tùy chọn
'Vô hiệu hóa việc tắt cơ quan giám sát khi đóng'.

Hệ thống IPMI thường có thể được tắt nguồn bằng lệnh IPMI.  chọn
'IPMI Poweroff' để thực hiện việc này.  Trình điều khiển sẽ tự động phát hiện nếu hệ thống
có thể được tắt nguồn bởi IPMI.  Việc kích hoạt tính năng này là an toàn ngay cả khi bạn
hệ thống không hỗ trợ tùy chọn này.  Điều này hoạt động trên các hệ thống ATCA,
Thẻ Radisys CPI1 và bất kỳ hệ thống IPMI nào hỗ trợ khung tiêu chuẩn
các lệnh quản lý.

Nếu bạn muốn người lái xe đưa một sự kiện vào nhật ký sự kiện một cách hoảng loạn,
bật tùy chọn 'Tạo sự kiện hoảng loạn cho tất cả các BMC trong tình trạng hoảng loạn'.  Nếu
bạn muốn toàn bộ chuỗi hoảng loạn được đưa vào nhật ký sự kiện bằng OEM
sự kiện, hãy bật 'Tạo sự kiện OEM có chứa chuỗi hoảng loạn'
tùy chọn.  Bạn cũng có thể kích hoạt những tính năng này một cách linh hoạt bằng cách cài đặt mô-đun
tham số có tên "panic_op" trong mô-đun ipmi_msghandler thành "sự kiện"
hoặc "chuỗi".  Đặt tham số đó thành "không" sẽ tắt chức năng này.

Thiết kế cơ bản
------------

Trình điều khiển Linux IPMI được thiết kế rất mô-đun và linh hoạt, bạn
chỉ cần lấy những phần bạn cần và bạn có thể sử dụng nó vào nhiều việc
những cách khác nhau.  Vì lẽ đó, nó bị chia thành nhiều mảnh
mã.  Các khối này (theo tên mô-đun) là:

ipmi_msghandler - Đây là phần mềm trung tâm của IPMI
hệ thống.  Nó xử lý tất cả các tin nhắn, thời gian tin nhắn và phản hồi.  các
Người dùng IPMI gắn liền với điều này và các giao diện vật lý IPMI (được gọi là
Giao diện quản lý hệ thống hoặc SMI) cũng liên quan ở đây.  Cái này
cung cấp giao diện kernelland cho IPMI, nhưng không cung cấp
giao diện để sử dụng bởi các tiến trình ứng dụng.

ipmi_devintf - Điều này cung cấp giao diện IOCTL của người dùng cho IPMI
trình điều khiển, mỗi tệp đang mở cho thiết bị này sẽ liên kết với trình xử lý tin nhắn
với tư cách là người dùng IPMI.

ipmi_si - Trình điều khiển cho các giao diện hệ thống khác nhau.  Điều này hỗ trợ KCS,
Giao diện SMIC và BT.  Trừ khi bạn có giao diện SMBus hoặc
giao diện tùy chỉnh riêng, có thể bạn sẽ cần sử dụng giao diện này.

ipmi_ssif - Trình điều khiển để truy cập BMC trên SMBus. Nó sử dụng
Giao diện SMBus của trình điều khiển hạt nhân I2C để gửi và nhận tin nhắn IPMI
qua SMBus.

ipmi_powernv - Trình điều khiển để truy cập BMC trên hệ thống POWERNV.

ipmi_watchdog - IPMI yêu cầu hệ thống phải có cơ quan giám sát rất có năng lực
hẹn giờ.  Trình điều khiển này triển khai bộ đếm thời gian giám sát Linux tiêu chuẩn
giao diện phía trên trình xử lý tin nhắn IPMI.

ipmi_poweroff - Một số hệ thống hỗ trợ khả năng tắt thông qua
Các lệnh IPMI.

bt-bmc - Đây không phải là một phần của trình điều khiển chính mà thay vào đó là trình điều khiển cho
truy cập giao diện phía BMC của giao diện BT.  Nó được sử dụng trên BMC
chạy Linux để cung cấp giao diện cho máy chủ.

Tất cả đều có thể lựa chọn riêng lẻ thông qua các tùy chọn cấu hình.

Nhiều tài liệu về giao diện nằm trong các tệp đính kèm.  các
IPMI bao gồm các tập tin là:

linux/ipmi.h - Chứa giao diện người dùng và giao diện IOCTL cho IPMI.

linux/ipmi_smi.h - Chứa giao diện cho các giao diện quản lý hệ thống
(những thứ có giao diện với bộ điều khiển IPMI) để sử dụng.

linux/ipmi_msgdefs.h - Định nghĩa chung cho tin nhắn IPMI cơ bản.


Địa chỉ
----------

Địa chỉ IPMI hoạt động giống như địa chỉ IP, bạn có lớp phủ
để xử lý các loại địa chỉ khác nhau.  Lớp phủ là::

cấu trúc ipmi_addr
  {
	int addr_type;
	kênh ngắn;
	dữ liệu char [IPMI_MAX_ADDR_SIZE];
  };

addr_type xác định địa chỉ thực sự là gì.  Người lái xe
hiện hiểu hai loại địa chỉ khác nhau.

Địa chỉ "Giao diện hệ thống" được xác định là::

cấu trúc ipmi_system_interface_addr
  {
	int addr_type;
	kênh ngắn;
  };

và loại là IPMI_SYSTEM_INTERFACE_ADDR_TYPE.  Cái này dùng để nói chuyện
thẳng tới BMC trên thẻ hiện tại.  Kênh phải được
IPMI_BMC_CHANNEL.

Các tin nhắn được gửi đi trên xe buýt IPMB đi qua
BMC sử dụng loại địa chỉ IPMI_IPMB_ADDR_TYPE.  Định dạng là::

cấu trúc ipmi_ipmb_addr
  {
	int addr_type;
	kênh ngắn;
	char không dấu nô lệ_addr;
	char lun không dấu;
  };

"Kênh" ở đây nhìn chung bằng 0, nhưng một số thiết bị hỗ trợ nhiều hơn
hơn một kênh, nó tương ứng với kênh được xác định trong IPMI
thông số kỹ thuật.

Ngoài ra còn có địa chỉ trực tiếp IPMB dành cho trường hợp người gửi
trực tiếp trên xe buýt IPMB và không cần phải đi qua BMC.
Bạn có thể gửi tin nhắn đến bộ điều khiển quản lý (MC) cụ thể trên
IPMB sử dụng IPMI_IPMB_DIRECT_ADDR_TYPE với định dạng sau::

cấu trúc ipmi_ipmb_direct_addr
  {
	int addr_type;
	kênh ngắn;
	char không dấu nô lệ_addr;
	char không dấu rq_lun;
	ký tự không dấu rs_lun;
  };

Kênh luôn bằng 0.  Bạn cũng có thể nhận lệnh từ người khác
Các MC mà bạn đã đăng ký để xử lý và phản hồi nên bạn có thể
sử dụng điều này để triển khai bộ điều khiển quản lý trên xe buýt..

Tin nhắn
--------

Tin nhắn được định nghĩa là::

cấu trúc ipmi_msg
  {
	char netfn không dấu;
	char lun không dấu;
	cmd ký tự không dấu;
	dữ liệu char * không dấu;
	dữ liệu int_len;
  };

Trình điều khiển đảm nhiệm việc thêm/bớt thông tin tiêu đề.  các
phần dữ liệu chỉ là dữ liệu được gửi (làm NOT đặt thông tin địa chỉ
ở đây) hoặc phản hồi.  Lưu ý rằng mã hoàn thành của phản hồi là
mục đầu tiên trong "dữ liệu" không bị lược bỏ vì đó là cách
tất cả các thông báo được xác định trong thông số kỹ thuật (và do đó làm cho việc đếm
bù đắp dễ dàng hơn một chút :-).

Khi sử dụng giao diện IOCTL từ vùng người dùng, bạn phải cung cấp một khối
dữ liệu cho "dữ liệu", điền vào và đặt data_len theo độ dài của
khối dữ liệu, ngay cả khi nhận được tin nhắn.  Nếu không thì tài xế
sẽ không có chỗ để đặt tin nhắn.

Các tin nhắn đến từ trình xử lý tin nhắn trong kernelland sẽ xuất hiện
như::

cấu trúc ipmi_recv_msg
  {
	liên kết struct list_head;

/* Loại thông báo như được xác định trong "Loại nhận"
           định nghĩa ở trên. */
	int recv_type;

ipmi_user_t *người dùng;
	struct ipmi_addr addr;
	tin nhắn dài;
	struct ipmi_msg tin nhắn;

/* Gọi lệnh này khi thực hiện xong với tin nhắn.  Có lẽ nó sẽ miễn phí
	   thông báo và thực hiện bất kỳ việc dọn dẹp cần thiết nào khác. */
	khoảng trống (*done)(struct ipmi_recv_msg *msg);

/* Giữ chỗ cho dữ liệu, không đưa ra bất kỳ giả định nào về
	   kích thước hoặc sự tồn tại của điều này, vì nó có thể thay đổi. */
	thông điệp char không dấu [IPMI_MAX_MSG_LENGTH];
  };

Bạn nên nhìn vào kiểu nhận và xử lý tin nhắn
một cách thích hợp.


Giao diện lớp trên (Trình xử lý tin nhắn)
-------------------------------------------

Lớp trên của giao diện cung cấp cho người dùng một giao diện nhất quán
giao diện của IPMI.  Nó cho phép nhiều giao diện SMI được
đã được giải quyết (vì một số bảng thực sự có nhiều BMC trên đó)
và người dùng không cần phải quan tâm đến loại SMI nào ở bên dưới chúng.


Theo dõi giao diện
^^^^^^^^^^^^^^^^^^^^^^^

Khi mã của bạn xuất hiện, trình điều khiển IPMI có thể đã phát hiện hoặc không
nếu thiết bị IPMI tồn tại.  Vì vậy, bạn có thể phải trì hoãn việc thiết lập của mình cho đến khi
thiết bị được phát hiện hoặc bạn có thể thực hiện việc đó ngay lập tức.
Để xử lý vấn đề này và cho phép khám phá, bạn đăng ký SMI
người theo dõi với ipmi_smi_watcher_register() để lặp qua các giao diện
và cho bạn biết khi nào họ đến và đi.


Tạo người dùng
^^^^^^^^^^^^^^^^^

Để sử dụng trình xử lý tin nhắn, trước tiên bạn phải tạo người dùng bằng cách sử dụng
ipmi_create_user.  Số giao diện chỉ định SMI nào bạn muốn
để kết nối và bạn phải cung cấp các hàm gọi lại để được gọi
khi có dữ liệu. Điều này cũng cho phép bạn chuyển một phần dữ liệu vào,
handler_data sẽ được chuyển lại cho bạn trong tất cả các cuộc gọi.

Khi bạn đã hoàn tất, hãy gọi ipmi_destroy_user() để loại bỏ người dùng.

Từ vùng người dùng, việc mở thiết bị sẽ tự động tạo người dùng và
việc đóng thiết bị sẽ tự động hủy hoại người dùng.


Nhắn tin
^^^^^^^^^

Để gửi tin nhắn từ kernel-land, lệnh gọi ipmi_request_settime() sẽ thực hiện
khá nhiều tất cả việc xử lý tin nhắn.  Hầu hết các tham số đều
tự giải thích.  Tuy nhiên, nó cần tham số "msgid".  Đây là NOT
số thứ tự của tin nhắn.  Nó chỉ đơn giản là một giá trị dài
được gửi lại khi phản hồi cho tin nhắn được trả lại.  Bạn có thể
sử dụng nó cho bất cứ điều gì bạn thích.

Các phản hồi sẽ quay trở lại trong hàm được chỉ ra bởi ipmi_recv_hndl
trường "trình xử lý" mà bạn đã chuyển vào ipmi_create_user().
Hãy nhớ nhìn vào loại nhận.

Từ vùng người dùng, bạn điền vào cấu trúc ipmi_req_t và sử dụng
IPMICTL_SEND_COMMAND ioctl.  Đối với nội dung đến, bạn có thể sử dụng select()
hoặc poll() để chờ tin nhắn đến. Tuy nhiên, bạn không thể sử dụng
read() để có được chúng, bạn phải gọi IPMICTL_RECEIVE_MSG bằng
cấu trúc ipmi_recv_t để thực sự nhận được tin nhắn.  Hãy nhớ rằng bạn
phải cung cấp một con trỏ tới một khối dữ liệu trong trường msg.data và
bạn phải điền vào trường msg.data_len kích thước của dữ liệu.
Điều này mang lại cho người nhận một nơi để thực sự gửi tin nhắn.

Nếu tin nhắn không khớp với dữ liệu bạn cung cấp, bạn sẽ nhận được
Lỗi EMSGSIZE và trình điều khiển sẽ để lại dữ liệu ở phần nhận
xếp hàng.  Nếu bạn muốn lấy nó và cắt bớt tin nhắn, hãy sử dụng
IPMICTL_RECEIVE_MSG_TRUNC ioctl.

Khi bạn gửi một lệnh (được xác định bởi bit thứ tự thấp nhất của
netfn trên thông số IPMI) trên xe buýt IPMB, người lái xe sẽ
tự động gán số thứ tự cho lệnh và lưu lại
lệnh.  Nếu không nhận được phản hồi trong IPMI do 5 chỉ định
giây, nó sẽ tự động tạo ra phản hồi bằng cách nói lệnh
đã hết thời gian.  Nếu có phản hồi không mong muốn (nếu sau 5
giây chẳng hạn), phản hồi đó sẽ bị bỏ qua.

Ở kernelland, sau khi bạn nhận được một tin nhắn và xử lý xong nó, bạn
MUST gọi ipmi_free_recv_msg() trên đó, nếu không bạn sẽ rò rỉ tin nhắn.  Lưu ý
rằng bạn nên làm phiền NEVER với trường "xong" của tin nhắn, nghĩa là
cần thiết để dọn dẹp tin nhắn đúng cách.

Lưu ý khi gửi sẽ có lệnh gọi ipmi_request_supply_msgs()
cho phép bạn cung cấp smi và nhận tin nhắn.  Điều này hữu ích cho
những đoạn mã cần hoạt động ngay cả khi hệ thống hết bộ đệm
(ví dụ, bộ đếm thời gian của cơ quan giám sát sử dụng cái này).  Bạn tự cung cấp
đệm và sở hữu các thói quen miễn phí.  Điều này không được khuyến khích sử dụng bình thường,
tuy nhiên, vì việc quản lý bộ đệm của riêng bạn rất khó.


Sự kiện và lệnh đến
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Người lái xe đảm nhận việc bỏ phiếu cho các sự kiện IPMI và nhận
lệnh (lệnh là các thông báo không phải là phản hồi, chúng là
lệnh mà những thứ khác trên xe buýt IPMB đã gửi cho bạn).  Để nhận
những thứ này, bạn phải đăng ký chúng, chúng sẽ không tự động được gửi
cho bạn.

Để nhận sự kiện, bạn phải gọi ipmi_set_gets_events() và đặt
"val" thành khác không.  Bất kỳ sự kiện nào đã được người lái xe nhận được
kể từ khi khởi động sẽ ngay lập tức được gửi đến người dùng đầu tiên
đăng ký cho các sự kiện.  Sau đó, nếu nhiều người dùng được đăng ký
đối với các sự kiện, tất cả họ sẽ nhận được tất cả các sự kiện diễn ra.

Để nhận lệnh, bạn phải đăng ký từng lệnh mà bạn
muốn nhận.  Gọi ipmi_register_for_cmd() và cung cấp netfn
và tên lệnh cho mỗi lệnh bạn muốn nhận.  Bạn cũng vậy
chỉ định một bitmask của các kênh bạn muốn nhận lệnh từ đó
(hoặc sử dụng IPMI_CHAN_ALL cho tất cả các kênh nếu bạn không quan tâm).  Chỉ có một
người dùng có thể được đăng ký cho mỗi netfn/cmd/channel, nhưng những người dùng khác nhau
có thể đăng ký các lệnh khác nhau hoặc cùng một lệnh nếu
mặt nạ bit kênh không trùng nhau.

Để phản hồi lệnh đã nhận, hãy đặt bit phản hồi trong giá trị được trả về
netfn, hãy sử dụng địa chỉ từ tin nhắn đã nhận và sử dụng địa chỉ tương tự
msgstr mà bạn nhận được trong tin nhắn đã nhận.

Từ vùng người dùng, các IOCTL tương đương được cung cấp để thực hiện các chức năng này.


Giao diện lớp dưới (SMI)
-------------------------------

Như đã đề cập trước đó, nhiều giao diện SMI có thể được đăng ký vào
trình xử lý tin nhắn, mỗi cái này được gán một số giao diện khi
họ đăng ký với người xử lý tin nhắn.  Họ thường được giao
theo thứ tự chúng đăng ký, mặc dù nếu SMI hủy đăng ký và sau đó
một người khác đăng ký, tất cả cược sẽ bị hủy.

ipmi_smi.h xác định giao diện cho các giao diện quản lý, xem
đó để biết thêm chi tiết.


Trình điều khiển SI
-------------

Trình điều khiển SI cho phép cấu hình các giao diện KCS, BT và SMIC
trong hệ thống.  Nó khám phá các giao diện thông qua một loạt các giao diện khác nhau
phương pháp, tùy thuộc vào hệ thống.

Bạn có thể chỉ định tối đa bốn giao diện trên dòng tải mô-đun và
kiểm soát một số thông số mô-đun::

modprobe ipmi_si.o type=<type1>,<type2>....
       cổng=<port1>,<port2>... addrs=<addr1>,<addr2>...
       irqs=<irq1>,<irq2>...
       regspacings=<sp1>,<sp2>,... regsizes=<size1>,<size2>,...
       regshifts=<shift1>,<shift2>,...
       nô lệ_addrs=<addr1>,<addr2>,...
       Force_kipmid=<enable1>,<enable2>,...
       kipmid_max_busy_us=<ustime1>,<ustime2>,...
       dỡ_khi_empty=[0|1]
       trydmi=[0|1] tryacpi=[0|1]
       tryplatform=[0|1] trypci=[0|1]

Mỗi trong số này ngoại trừ các mục thử... là một danh sách, mục đầu tiên dành cho
giao diện đầu tiên, mục thứ hai cho giao diện thứ hai, v.v.

si_type có thể là "kcs", "smic" hoặc "bt".  Nếu bạn để trống thì nó
mặc định là "kcs".

Nếu bạn chỉ định địa chỉ khác 0 cho một giao diện, trình điều khiển sẽ
sử dụng địa chỉ bộ nhớ được cung cấp làm địa chỉ của thiết bị.  Cái này
ghi đè si_ports.

Nếu bạn chỉ định các cổng khác 0 cho một giao diện, trình điều khiển sẽ
sử dụng cổng I/O được cung cấp làm địa chỉ thiết bị.

Nếu bạn chỉ định các irq khác 0 cho một giao diện, trình điều khiển sẽ
cố gắng sử dụng ngắt đã cho cho thiết bị.

Các mục thử... khác vô hiệu hóa khả năng phát hiện bằng cách tương ứng của chúng
những cái tên.  Tất cả đều được bật theo mặc định, đặt chúng về 0 để tắt
họ.  Tryplatform vô hiệu hóa openfirmware.

Ba tham số tiếp theo liên quan đến bố cục thanh ghi.  các
các thanh ghi được sử dụng bởi các giao diện có thể không xuất hiện liên tiếp
các vị trí và chúng có thể không có trong các thanh ghi 8 bit.  Các thông số này
cho phép bố trí dữ liệu trong sổ đăng ký chính xác hơn
được chỉ định.

Tham số regsspaces cung cấp số byte giữa các byte liên tiếp
đăng ký địa chỉ bắt đầu.  Chẳng hạn, nếu khoảng cách được đặt thành 4
và địa chỉ bắt đầu là 0xca2, sau đó là địa chỉ thứ hai
đăng ký sẽ là 0xca6.  Điều này mặc định là 1.

Tham số regsizes cho biết kích thước của một thanh ghi, tính bằng byte.  các
dữ liệu được IPMI sử dụng rộng 8 bit, nhưng nó có thể nằm trong một phạm vi lớn hơn
đăng ký.  Tham số này cho phép chỉ định kiểu đọc và ghi.
Nó có thể là 1, 2, 4 hoặc 8. Mặc định là 1.

Vì kích thước thanh ghi có thể lớn hơn 32 bit nên dữ liệu IPMI có thể không
ở 8 bit thấp hơn.  Tham số regshifts cho biết số lượng cần dịch chuyển
dữ liệu để lấy dữ liệu IPMI thực tế.

Slave_addrs chỉ định địa chỉ IPMI của BMC cục bộ.  Đây là
thường là 0x20 và trình điều khiển mặc định là như vậy, nhưng trong trường hợp không phải vậy thì nó
có thể được chỉ định khi trình điều khiển khởi động.

Tham số Force_ipmid kích hoạt mạnh mẽ (nếu được đặt thành 1) hoặc tắt
(nếu được đặt thành 0) daemon IPMI của kernel.  Thông thường điều này được tự động phát hiện
bởi trình điều khiển, nhưng các hệ thống bị gián đoạn có thể cần được kích hoạt,
hoặc người dùng không muốn daemon (không cần hiệu năng, không
muốn đánh CPU) có thể vô hiệu hóa nó.

Nếu unload_when_empty được đặt thành 1, trình điều khiển sẽ không được tải nếu nó
không tìm thấy bất kỳ giao diện nào hoặc tất cả các giao diện đều không hoạt động.  các
mặc định là một.  Đặt thành 0 rất hữu ích với hotmod, nhưng
rõ ràng chỉ hữu ích cho các mô-đun.

Khi được biên dịch vào kernel, các tham số có thể được chỉ định trên
dòng lệnh kernel như::

ipmi_si.type=<type1>,<type2>...
       ipmi_si.ports=<port1>,<port2>... ipmi_si.addrs=<addr1>,<addr2>...
       ipmi_si.irqs=<irq1>,<irq2>...
       ipmi_si.regspaces=<sp1>,<sp2>,...
       ipmi_si.regsizes=<size1>,<size2>,...
       ipmi_si.regshifts=<shift1>,<shift2>,...
       ipmi_si.slave_addrs=<addr1>,<addr2>,...
       ipmi_si.force_kipmid=<enable1>,<enable2>,...
       ipmi_si.kipmid_max_busy_us=<ustime1>,<ustime2>,...

Nó hoạt động giống như các tham số mô-đun cùng tên.

Nếu giao diện IPMI của bạn không hỗ trợ ngắt và là KCS hoặc
Giao diện SMIC, trình điều khiển IPMI sẽ khởi động một luồng nhân cho
giao diện để giúp tăng tốc mọi thứ.  Đây là hạt nhân có mức độ ưu tiên thấp
luồng liên tục thăm dò trình điều khiển IPMI trong khi hoạt động IPMI
đang được tiến hành.  Tham số mô-đun Force_kipmid sẽ cho phép người dùng
để buộc bật hoặc tắt chủ đề này.  Nếu bạn buộc phải tắt nó đi và không có
bị gián đoạn, trình điều khiển sẽ chạy VERY chậm.  Đừng trách tôi,
những giao diện này thật tệ.

Thật không may, chủ đề này có thể sử dụng rất nhiều CPU tùy thuộc vào
hiệu suất của giao diện.  Điều này có thể lãng phí rất nhiều CPU và gây ra
nhiều vấn đề khác nhau khi phát hiện CPU nhàn rỗi và sử dụng thêm nguồn điện.  Đến
tránh điều này, kipmid_max_busy_us đặt lượng thời gian tối đa, trong
micro giây, kipmid đó sẽ quay trước khi ngủ trong tích tắc.  Cái này
giá trị đặt ra sự cân bằng giữa hiệu suất và chất thải CPU và cần phải được
điều chỉnh theo nhu cầu của bạn.  Có thể một ngày nào đó tính năng tự động điều chỉnh sẽ được thêm vào, nhưng
đó không phải là điều đơn giản và ngay cả việc tự động điều chỉnh cũng cần phải có
điều chỉnh theo hiệu suất mong muốn của người dùng.

Trình điều khiển hỗ trợ thêm và xóa giao diện nóng.  Lối này,
các giao diện có thể được thêm vào hoặc gỡ bỏ sau khi kernel hoạt động.
Việc này được thực hiện bằng cách sử dụng /sys/modules/ipmi_si/parameters/hotmod, đây là một
tham số chỉ ghi.  Bạn viết một chuỗi vào giao diện này.  Chuỗi
có định dạng::

<op1>[:op2[:op3...]]

Các "op" là::

add|remove,kcs|bt|smic,mem|i/o,<địa chỉ>[,<opt1>[,<opt2>[,...]]]

Bạn có thể chỉ định nhiều hơn một giao diện trên dòng.  Các "lựa chọn" là::

rsp=<regspace>
   rsi=<regsize>
   rsh=<regshift>
   irq=<irq>
   ipmb=<địa chỉ nô lệ ipmb>

và những điều này có ý nghĩa tương tự như đã thảo luận ở trên.  Lưu ý rằng bạn
cũng có thể sử dụng điều này trên dòng lệnh kernel để có định dạng nhỏ gọn hơn
để chỉ định một giao diện.  Lưu ý rằng khi loại bỏ một giao diện,
chỉ ba tham số đầu tiên (loại si, loại địa chỉ và địa chỉ)
được sử dụng để so sánh.  Mọi tùy chọn đều bị bỏ qua để loại bỏ.

Trình điều khiển SMBus (SSIF)
-----------------------

Trình điều khiển SMBus cho phép cấu hình tối đa 4 thiết bị SMBus trong
hệ thống.  Theo mặc định, trình điều khiển sẽ chỉ đăng ký với thứ gì đó mà nó
tìm thấy trong các bảng DMI hoặc ACPI.  Bạn có thể thay đổi điều này
tại thời điểm tải mô-đun (đối với mô-đun) với::

modprobe ipmi_ssif.o
	addr=<i2caddr1>[,<i2caddr2>[,...]]
	bộ chuyển đổi=<adapter1>[,<adapter2>[...]]
	dbg=<flags1>,<flags2>...
	nô lệ_addrs=<addr1>,<addr2>,...
	tryacpi=[0|1] trydmi=[0|1]
	[dbg_probe=1]
	cảnh báo_broken

Các địa chỉ là địa chỉ I2C bình thường.  Bộ chuyển đổi là chuỗi
tên của bộ chuyển đổi, như được hiển thị trong /sys/bus/i2c/devices/i2c-<n>/name.
Bản thân nó là ZZ0000ZZ i2c-<n>.  Ngoài ra, việc so sánh được thực hiện bỏ qua
dấu cách, vì vậy nếu tên là "Đây là chip I2C", bạn có thể nói
adapter_name=ThisisanI2cchip.  Điều này là do rất khó để vượt qua
khoảng trống trong các tham số kernel.

Cờ gỡ lỗi là cờ bit cho mỗi BMC được tìm thấy, chúng là:
Thông báo IPMI: 1, trạng thái trình điều khiển: 2, thời gian: 4, đầu dò I2C: 8

Các tham số tryxxx có thể được sử dụng để vô hiệu hóa các giao diện phát hiện
từ nhiều nguồn khác nhau.

Đặt dbg_probe thành 1 sẽ cho phép gỡ lỗi quá trình thăm dò và
quá trình phát hiện BMC trên SMBusses.

Slave_addrs chỉ định địa chỉ IPMI của BMC cục bộ.  Đây là
thường là 0x20 và trình điều khiển mặc định là như vậy, nhưng trong trường hợp không phải vậy thì nó
có thể được chỉ định khi trình điều khiển khởi động.

cảnh báo_broken không bật cảnh báo SMBus cho SSIF. Nếu không thì SMBus
cảnh báo sẽ được bật trên phần cứng được hỗ trợ.

Việc phát hiện IPMI tuân thủ BMC trên SMBus có thể khiến thiết bị bật
xe buýt I2C bị lỗi. Trình điều khiển SMBus ghi "Nhận ID thiết bị" IPMI
tin nhắn dưới dạng khối ghi vào bus I2C và chờ phản hồi.
Hành động này có thể gây bất lợi cho một số thiết bị I2C. Nó rất cao
khuyến nghị cung cấp địa chỉ I2C đã biết cho trình điều khiển SMBus trong
tham số smb_addr trừ khi bạn có dữ liệu DMI hoặc ACPI để thông báo
lái xe những gì để sử dụng.

Khi được biên dịch vào kernel, các địa chỉ có thể được chỉ định trên
dòng lệnh kernel như::

ipmb_ssif.addr=<i2caddr1>[,<i2caddr2>[...]]
	ipmi_ssif.adapter=<adapter1>[,<adapter2>[...]]
	ipmi_ssif.dbg=<flags1>[,<flags2>[...]]
	ipmi_ssif.dbg_probe=1
	ipmi_ssif.slave_addrs=<addr1>[,<addr2>[...]]
	ipmi_ssif.tryacpi=[0|1] ipmi_ssif.trydmi=[0|1]

Đây là các tùy chọn tương tự như trên dòng lệnh mô-đun.

Trình điều khiển I2C không hỗ trợ truy cập không chặn hoặc bỏ phiếu, vì vậy
trình điều khiển này không thể thực hiện các sự kiện hoảng loạn IPMI, mở rộng cơ quan giám sát khi hoảng loạn
time hoặc các hàm IPMI liên quan đến hoảng loạn khác mà không có kernel đặc biệt
các bản vá và sửa đổi trình điều khiển.  Bạn có thể lấy chúng ở openipmi
trang web.

Trình điều khiển hỗ trợ thêm và xóa giao diện nóng thông qua I2C
giao diện sysfs.

Trình điều khiển IPMI IPMB
--------------------

Trình điều khiển này dùng để hỗ trợ hệ thống nằm trên xe buýt IPMB; nó
cho phép giao diện trông giống như giao diện IPMI bình thường.  Đang gửi
giao diện hệ thống gửi tin nhắn tới nó sẽ khiến tin nhắn biến mất
tới BMC đã đăng ký trên hệ thống (mặc định ở địa chỉ IPMI 0x20).

Nó cũng cho phép bạn gọi trực tiếp các MC khác trên xe buýt bằng cách sử dụng
địa chỉ trực tiếp ipmb  Bạn có thể nhận lệnh từ các MC khác trên
xe buýt và chúng sẽ được xử lý thông qua lệnh nhận được thông thường
cơ chế được mô tả ở trên.

Các thông số là::

ipmi_ipmb.bmcaddr=<địa chỉ sử dụng cho các thông báo địa chỉ giao diện hệ thống>
	ipmi_ipmb.retry_time_ms=<Thời gian giữa các lần thử lại trên IPMB>
	ipmi_ipmb.max_retries=<Số lần thử lại tin nhắn>

Việc tải mô-đun sẽ không tự động tạo ra trình điều khiển
bắt đầu trừ khi có thông tin cây thiết bị đang thiết lập nó.  Nếu
bạn muốn khởi tạo một trong những thứ này bằng tay, hãy làm::

echo ipmi-ipmb <addr> > /sys/class/i2c-dev/i2c-<n>/device/new_device

Lưu ý địa chỉ bạn đưa ở đây là địa chỉ I2C chứ không phải IPMI
địa chỉ.  Vì vậy nếu bạn muốn địa chỉ MC của mình là 0x60 thì bạn đặt 0x30
ở đây.  Xem thông tin trình điều khiển I2C để biết thêm chi tiết.

Lệnh kết nối với các bus IPMB khác thông qua giao diện này không
làm việc.  Hàng đợi nhận tin nhắn không được triển khai theo thiết kế.  Ở đó
chỉ có một hàng đợi tin nhắn nhận trên BMC và điều đó dành cho
trình điều khiển máy chủ, không phải thứ gì đó trên xe buýt IPMB.

BMC có thể có nhiều bus IPMB, bus mà thiết bị của bạn nằm trên đó
phụ thuộc vào cách hệ thống được nối dây.  Bạn có thể tìm nạp các kênh với
"ipmitool kênh thông tin <n>" trong đó <n> là kênh, với
các kênh là 0-7 và thử các kênh IPMB.

Những mảnh khác
------------

Nhận thông tin chi tiết liên quan đến thiết bị IPMI
--------------------------------------------------

Một số người dùng cần thông tin chi tiết hơn về thiết bị, chẳng hạn như vị trí
địa chỉ đến từ hoặc thiết bị cơ sở thô cho giao diện IPMI.
Bạn có thể sử dụng IPMI smi_watcher để nắm bắt các giao diện IPMI khi chúng
đến hoặc đi và để lấy thông tin, bạn có thể sử dụng chức năng
ipmi_get_smi_info(), trả về cấu trúc sau::

cấu trúc ipmi_smi_info {
	enum ipmi_addr_src addr_src;
	thiết bị cấu trúc *dev;
	công đoàn {
		cấu trúc {
			void *acpi_handle;
		} acpi_info;
	} addr_info;
  };

Hiện tại thông tin đặc biệt chỉ dành cho nguồn địa chỉ SI_ACPI là
đã quay trở lại.  Những người khác có thể được thêm vào khi cần thiết.

Lưu ý rằng con trỏ dev được bao gồm trong cấu trúc trên và
giả sử ipmi_smi_get_info trả về thành công, bạn phải gọi put_device
trên con trỏ dev.


Cơ quan giám sát
--------

Một bộ đếm thời gian theo dõi được cung cấp để thực hiện tiêu chuẩn Linux
giao diện hẹn giờ của cơ quan giám sát.  Nó có ba tham số mô-đun có thể được
được sử dụng để kiểm soát nó::

modprobe ipmi_watchdog timeout=<t> pretimeout=<t> action=<action type>
      preaction=<loại phản ứng> preop=<loại preop> start_now=x
      nowout=x ifnum_to_use=n Panic_wdt_timeout=<t>

ifnum_to_use chỉ định giao diện mà bộ đếm thời gian giám sát nên sử dụng.
Mặc định là -1, nghĩa là chọn cái đầu tiên được đăng ký.

Thời gian chờ là số giây thực hiện hành động và thời gian chờ trước
là số giây trước khi thiết lập lại mà cơn hoảng loạn trước thời gian chờ sẽ xảy ra
xảy ra (nếu thời gian chờ trước bằng 0 thì thời gian chờ trước sẽ không được bật).  Lưu ý
rằng thời gian chờ trước là thời gian trước thời gian chờ cuối cùng.  Vì vậy nếu
thời gian chờ là 50 giây và thời gian chờ trước là 10 giây, sau đó thời gian chờ trước
sẽ xảy ra sau 40 giây (10 giây trước khi hết thời gian chờ). Sự hoảng loạn_wdt_timeout
là giá trị thời gian chờ được đặt trên kernel hoảng loạn, để cho phép các hành động
chẳng hạn như kdump xảy ra trong lúc hoảng loạn.

Hành động có thể là "đặt lại", "power_cycle" hoặc "power_off" và
chỉ định những việc cần làm khi hết giờ và mặc định là
"đặt lại".

Phản ứng có thể là "pre_smi" cho chỉ báo thông qua SMI
giao diện, "pre_int" để chỉ báo thông qua SMI với
ngắt và "pre_nmi" cho NMI trên một phản ứng trước.  Đây là cách
người lái xe được thông báo về thời gian chờ trước.

Preop có thể được đặt thành "preop_none" để không thực hiện thao tác nào trong thời gian chờ trước,
"preop_panic" để đặt hoạt động trước thành hoảng loạn hoặc "preop_give_data"
để cung cấp dữ liệu để đọc từ thiết bị giám sát khi hết thời gian chờ
xảy ra.  Cài đặt "pre_nmi" CANNOT được sử dụng với "preop_give_data"
bởi vì bạn không thể thực hiện các thao tác dữ liệu từ NMI.

Khi preop được đặt thành "preop_give_data", một byte sẽ sẵn sàng để đọc
trên thiết bị khi xảy ra thời gian chờ trước.  Chọn và fasync hoạt động
thiết bị này cũng vậy.

Nếu start_now được đặt thành 1, bộ đếm thời gian theo dõi sẽ bắt đầu chạy như
ngay sau khi trình điều khiển được tải.

Nếu nowout được đặt thành 1, bộ đếm thời gian theo dõi sẽ không dừng khi
thiết bị giám sát đã đóng.  Giá trị mặc định của nowout là đúng
nếu tùy chọn CONFIG_WATCHDOG_NOWAYOUT được bật hoặc sai nếu không.

Khi biên dịch vào kernel sẽ có sẵn dòng lệnh kernel
để định cấu hình cơ quan giám sát::

ipmi_watchdog.timeout=<t> ipmi_watchdog.pretimeout=<t>
	ipmi_watchdog.action=<loại hành động>
	ipmi_watchdog.preaction=<loại phản ứng>
	ipmi_watchdog.preop=<loại chuẩn bị>
	ipmi_watchdog.start_now=x
	ipmi_watchdog.nowayout=x
	ipmi_watchdog.panic_wdt_timeout=<t>

Các tùy chọn cũng giống như các tùy chọn tham số mô-đun.

Cơ quan giám sát sẽ hoảng sợ và bắt đầu hết thời gian chờ thiết lập lại 120 giây nếu nó
nhận được một hành động trước.  Trong lúc hoảng loạn hoặc khởi động lại, cơ quan giám sát sẽ
bắt đầu hẹn giờ 120 nếu nó đang chạy để đảm bảo quá trình khởi động lại xảy ra.

Lưu ý rằng nếu bạn sử dụng tính năng xử lý NMI cho cơ quan giám sát, bạn sẽ có MUST NOT
sử dụng cơ quan giám sát nmi.  Không có cách nào hợp lý để biết liệu NMI có
đến từ bộ điều khiển IPMI, vì vậy nó phải giả định rằng nếu nó nhận được
nếu không thì NMI chưa xử lý được thì phải từ IPMI nó sẽ hoảng loạn
ngay lập tức.

Khi bạn mở bộ đếm thời gian theo dõi, bạn phải viết ký tự 'V' vào
thiết bị để đóng nó lại, nếu không bộ hẹn giờ sẽ không dừng.  Đây là một ngữ nghĩa mới
dành cho người lái xe nhưng phải nhất quán với phần còn lại của cơ quan giám sát
trình điều khiển trong Linux.


Hết thời gian hoảng loạn
--------------

Trình điều khiển OpenIPMI hỗ trợ khả năng đặt bán tùy chỉnh và tùy chỉnh
các sự kiện trong nhật ký sự kiện hệ thống nếu xảy ra hoảng loạn.  nếu bạn kích hoạt
Tùy chọn 'Tạo sự kiện hoảng loạn cho tất cả BMC trong tình trạng hoảng loạn', bạn sẽ nhận được
một sự kiện gây hoảng loạn ở định dạng sự kiện IPMI tiêu chuẩn.  Nếu bạn kích hoạt
tùy chọn 'Tạo sự kiện OEM chứa chuỗi hoảng loạn', bạn sẽ
cũng nhận được một loạt các sự kiện OEM đang gây ra chuỗi hoảng loạn.


Cài đặt trường của các sự kiện là:

* ID trình tạo: 0x21 (kernel)
* EvM Rev: 0x03 (sự kiện này được định dạng ở định dạng IPMI 1.0)
* Loại cảm biến: 0x20 (Cảm biến dừng quan trọng của hệ điều hành)
* Cảm biến #: Byte đầu tiên của chuỗi hoảng loạn (0 nếu không có chuỗi hoảng loạn)
* Đạo diễn sự kiện | Loại sự kiện: 0x6f (Xác nhận, thông tin sự kiện dành riêng cho cảm biến)
* Dữ liệu sự kiện 1: 0xa1 (Dừng thời gian chạy ở OEM byte 2 và 3)
* Dữ liệu sự kiện 2: byte thứ hai của chuỗi hoảng loạn
* Dữ liệu sự kiện 3: byte thứ ba của chuỗi hoảng loạn

Xem thông số IPMI để biết chi tiết về cách bố trí sự kiện.  Sự kiện này là
luôn được gửi đến bộ điều khiển quản lý cục bộ.  Nó sẽ xử lý việc định tuyến
tin nhắn đến đúng nơi

Các sự kiện OEM khác có định dạng sau:

* ID bản ghi (byte 0-1): Được đặt bởi SEL.
* Loại bản ghi (byte 2): 0xf0 (OEM không có dấu thời gian)
* byte 3: Địa chỉ nô lệ của thẻ cứu nguy
* byte 4: Số thứ tự (bắt đầu từ số 0)
  Phần còn lại của byte (11 byte) là chuỗi hoảng loạn.  Nếu chuỗi hoảng loạn
  dài hơn 11 byte, nhiều tin nhắn sẽ được gửi với tốc độ tăng dần
  số thứ tự.

Vì bạn không thể gửi sự kiện OEM bằng giao diện chuẩn nên điều này
sẽ cố gắng tìm SEL và thêm các sự kiện vào đó.  Nó
đầu tiên sẽ truy vấn khả năng của bộ điều khiển quản lý cục bộ.
Nếu nó có SEL thì chúng sẽ được lưu trữ trong SEL của cục bộ
người điều khiển quản lý.  Nếu không, bộ điều khiển quản lý cục bộ sẽ
trình tạo sự kiện, trình nhận sự kiện từ ban quản lý cục bộ
bộ điều khiển sẽ được truy vấn và các sự kiện được gửi đến SEL trên đó
thiết bị.  Nếu không, các sự kiện sẽ chẳng đi đến đâu vì không có nơi nào để
gửi chúng.


Tắt nguồn
--------

Nếu khả năng tắt nguồn được chọn, trình điều khiển IPMI sẽ cài đặt
một chức năng tắt máy vào con trỏ chức năng tắt nguồn tiêu chuẩn.  Cái này
nằm trong mô-đun ipmi_poweroff.  Khi hệ thống yêu cầu tắt nguồn,
nó sẽ gửi các lệnh IPMI thích hợp để thực hiện việc này.  Điều này được hỗ trợ trên
một số nền tảng.

Có một tham số mô-đun có tên là "poweroff_powercycle" có thể
bằng 0 (thực hiện tắt nguồn) hoặc khác 0 (thực hiện chu kỳ nguồn, tắt nguồn
tắt hệ thống, sau đó bật lại sau vài giây).  Cài đặt
ipmi_poweroff.poweroff_control=x sẽ làm điều tương tự trên kernel
dòng lệnh.  Tham số này cũng có sẵn thông qua hệ thống tập tin Proc
trong /proc/sys/dev/ipmi/poweroff_powercycle.  Lưu ý rằng nếu hệ thống
không hỗ trợ đạp xe nguồn, nó sẽ luôn tắt nguồn.

Tham số "ifnum_to_use" chỉ định giao diện nào sẽ tắt nguồn
mã nên sử dụng.  Mặc định là -1, nghĩa là chọn cái đầu tiên
đã đăng ký.

Lưu ý rằng nếu bạn đã bật ACPI, hệ thống sẽ ưu tiên sử dụng ACPI hơn
tắt nguồn.
