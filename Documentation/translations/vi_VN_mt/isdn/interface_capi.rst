.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/isdn/interface_capi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================================
Kernel CAPI Giao diện với trình điều khiển phần cứng
====================================================

1. Tổng quan
============

Từ thông số kỹ thuật CAPI 2.0:
COMMON-ISDN-API (CAPI) là chuẩn giao diện lập trình ứng dụng được sử dụng
để truy cập thiết bị ISDN được kết nối với giao diện tốc độ cơ bản (BRI) và giao diện chính
giao diện tốc độ (PRI).

Kernel CAPI hoạt động như một lớp điều phối giữa các ứng dụng CAPI và CAPI
trình điều khiển phần cứng. Trình điều khiển phần cứng đăng ký thiết bị ISDN (bộ điều khiển, trong CAPI
biệt ngữ) với Kernel CAPI để biểu thị mức độ sẵn sàng cung cấp dịch vụ của họ
đến các ứng dụng CAPI. Các ứng dụng CAPI cũng đăng ký với Kernel CAPI,
yêu cầu liên kết với thiết bị CAPI. Kernel CAPI sau đó gửi
đăng ký ứng dụng vào một thiết bị có sẵn, chuyển tiếp nó tới
trình điều khiển phần cứng tương ứng. Kernel CAPI sau đó chuyển tiếp tin nhắn CAPI ở cả hai
hướng dẫn giữa ứng dụng và trình điều khiển phần cứng.

Định dạng và ngữ nghĩa của tin nhắn CAPI được chỉ định trong tiêu chuẩn CAPI 2.0.
Tiêu chuẩn này được cung cấp miễn phí từ ZZ0000ZZ


2. Đăng ký trình điều khiển và thiết bị
=======================================

Trình điều khiển CAPI phải đăng ký từng thiết bị ISDN mà họ điều khiển bằng Kernel
CAPI bằng cách gọi hàm Kernel CAPI Attach_capi_ctr() bằng một con trỏ tới một
struct capi_ctr trước khi chúng có thể được sử dụng. Cấu trúc này phải được lấp đầy bằng
tên của trình điều khiển và bộ điều khiển và một số chức năng gọi lại
các con trỏ sau đó được Kernel CAPI sử dụng để liên lạc với
người lái xe. Việc đăng ký có thể được thu hồi bằng cách gọi hàm
tách_capi_ctr() bằng một con trỏ tới cùng cấu trúc capi_ctr.

Trước khi có thể sử dụng thiết bị thực sự, người lái xe phải điền thông tin vào thiết bị
các trường thông tin 'manu', 'version', 'profile' và 'serial' trong capi_ctr
cấu trúc của thiết bị và báo hiệu sự sẵn sàng của thiết bị bằng cách gọi capi_ctr_ready().
Từ đó trở đi, Kernel CAPI có thể gọi các hàm gọi lại đã đăng ký cho
thiết bị.

Nếu thiết bị không thể sử dụng được vì bất kỳ lý do gì (tắt máy, ngắt kết nối ...),
trình điều khiển phải gọi capi_ctr_down(). Điều này sẽ ngăn chặn các cuộc gọi tiếp theo đến
chức năng gọi lại của Kernel CAPI.


3. Đăng ký và liên lạc ứng dụng
=============================================

Kernel CAPI chuyển tiếp yêu cầu đăng ký từ các ứng dụng (gọi tới CAPI
hoạt động CAPI_REGISTER) tới trình điều khiển phần cứng thích hợp bằng cách gọi nó
hàm gọi lại register_appl(). ID ứng dụng duy nhất (ApplID, u16) là
được phân bổ bởi Kernel CAPI và chuyển tới register_appl() cùng với
cấu trúc tham số được cung cấp bởi ứng dụng. Điều này tương tự với
open() hoạt động trên các tập tin thông thường hoặc các thiết bị ký tự.

Sau khi trả về thành công từ register_appl(), các tin nhắn CAPI từ
ứng dụng có thể được chuyển tới trình điều khiển của thiết bị thông qua các cuộc gọi đến
hàm gọi lại send_message(). Ngược lại, trình điều khiển có thể gọi Kernel
Hàm capi_ctr_handle_message() của CAPI để chuyển tin nhắn CAPI đã nhận tới
Kernel CAPI để chuyển tiếp tới một ứng dụng, chỉ định ApplID của nó.

Yêu cầu hủy đăng ký (CAPI hoạt động CAPI_RELEASE) từ các ứng dụng được
được chuyển tiếp dưới dạng lệnh gọi đến hàm gọi lại Release_appl(), chuyển tiếp lệnh gọi tương tự
ApplID như với register_appl(). Sau khi trở về từ Release_appl(), không có CAPI
tin nhắn cho ứng dụng đó có thể được chuyển đến hoặc từ thiết bị nữa.


4. Cấu trúc dữ liệu
===================

4.1 cấu trúc capi_driver
------------------------

Cấu trúc này mô tả chính trình điều khiển Kernel CAPI. Nó được sử dụng trong
Các hàm register_capi_driver() và unregister_capi_driver() và chứa
các trường không riêng tư sau đây, tất cả đều do trình điều khiển đặt trước khi gọi
register_capi_driver():

ZZ0000ZZ
	tên của trình điều khiển, dưới dạng chuỗi ASCII kết thúc bằng 0
ZZ0001ZZ
	số sửa đổi của trình điều khiển, dưới dạng chuỗi ASCII kết thúc bằng 0

4.2 cấu trúc capi_ctr
---------------------

Cấu trúc này mô tả một thiết bị ISDN (bộ điều khiển) được xử lý bởi Kernel CAPI
người lái xe. Sau khi đăng ký thông qua hàm Attach_capi_ctr(), nó sẽ được chuyển tới
tất cả các chức năng gọi lại và giao diện lớp dưới cụ thể của bộ điều khiển để
xác định bộ điều khiển để hoạt động.

Nó chứa các trường không riêng tư sau:

được trình điều khiển thiết lập trước khi gọi Attach_capi_ctr():
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

ZZ0000ZZ
	con trỏ tới mô-đun trình điều khiển sở hữu thiết bị

ZZ0000ZZ
	một con trỏ mờ tới dữ liệu cụ thể của trình điều khiển, không được Kernel CAPI chạm vào

ZZ0000ZZ
	tên của bộ điều khiển, dưới dạng chuỗi ASCII kết thúc bằng 0

ZZ0000ZZ
	tên của trình điều khiển, dưới dạng chuỗi ASCII kết thúc bằng 0

ZZ0000ZZ
	(tùy chọn) con trỏ tới chức năng gọi lại để gửi chương trình cơ sở và
	dữ liệu cấu hình cho thiết bị

Chức năng có thể quay trở lại trước khi thao tác hoàn tất.

Việc hoàn thành phải được báo hiệu bằng lệnh gọi tới capi_ctr_ready().

Giá trị trả về: 0 nếu thành công, mã lỗi nếu có lỗi
	Được gọi trong bối cảnh quá trình.

ZZ0000ZZ
	(tùy chọn) con trỏ tới chức năng gọi lại để dừng thiết bị,
	phát hành tất cả các ứng dụng đã đăng ký

Chức năng có thể quay trở lại trước khi thao tác hoàn tất.

Việc hoàn thành phải được báo hiệu bằng lệnh gọi tới capi_ctr_down().

Được gọi trong bối cảnh quá trình.

ZZ0000ZZ
	con trỏ tới hàm gọi lại để đăng ký
	ứng dụng với thiết bị

Các cuộc gọi đến các chức năng này được Kernel CAPI tuần tự hóa để chỉ
	một cuộc gọi đến bất kỳ ai trong số họ sẽ được kích hoạt bất cứ lúc nào.

ZZ0000ZZ
	con trỏ tới chức năng gọi lại hủy đăng ký
	ứng dụng với thiết bị

Các cuộc gọi đến các chức năng này được Kernel CAPI tuần tự hóa để chỉ
	một cuộc gọi đến bất kỳ ai trong số họ sẽ được kích hoạt bất cứ lúc nào.

ZZ0000ZZ
	con trỏ tới hàm gọi lại để gửi tin nhắn CAPI tới
	thiết bị

Giá trị trả về: Mã lỗi CAPI

Nếu phương thức trả về 0 (CAPI_NOERROR), trình điều khiển đã có quyền sở hữu
	của skb và người gọi có thể không truy cập được nữa. Nếu nó trả về một
	giá trị khác 0 (lỗi) thì quyền sở hữu skb sẽ trả về cho người gọi
	người có thể tái sử dụng hoặc giải phóng nó.

Giá trị trả về chỉ nên được sử dụng để báo hiệu các vấn đề liên quan đến
	để chấp nhận hoặc xếp hàng tin nhắn. Các lỗi xảy ra trong quá trình
	Quá trình xử lý thực tế của tin nhắn phải được báo hiệu bằng một
	tin nhắn trả lời thích hợp.

Có thể được gọi trong quá trình hoặc bối cảnh gián đoạn.

Các cuộc gọi đến chức năng này không được Kernel CAPI tuần tự hóa, tức là. nó phải
	chuẩn bị nhập lại.

ZZ0000ZZ
	con trỏ tới hàm gọi lại trả về mục nhập cho thiết bị trong
	bảng thông tin bộ điều khiển CAPI, /proc/capi/controller

Lưu ý:
  Các hàm gọi lại ngoại trừ send_message() không bao giờ được gọi khi bị gián đoạn
  bối cảnh.

cần điền trước khi gọi capi_ctr_ready():
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

ZZ0000ZZ
	giá trị trả về cho CAPI_GET_MANUFACTURER

ZZ0000ZZ
	giá trị trả về cho CAPI_GET_VERSION

ZZ0000ZZ
	giá trị trả về cho CAPI_GET_PROFILE

ZZ0000ZZ
	giá trị trả về cho CAPI_GET_SERIAL


4.3 SKB
--------

Tin nhắn CAPI được chuyển giữa Kernel CAPI và trình điều khiển thông qua send_message()
và capi_ctr_handle_message(), được lưu trữ trong phần dữ liệu của bộ đệm ổ cắm
(skb).  Mỗi skb chứa một thông báo CAPI được mã hóa theo CAPI 2.0
tiêu chuẩn.

Đối với các tin nhắn truyền dữ liệu, DATA_B3_REQ và DATA_B3_IND, giá trị thực tế
dữ liệu tải trọng ngay lập tức theo sau thông báo CAPI trong cùng một skb.
Các tham số Data và Data64 không được sử dụng để xử lý. Dữ liệu64
tham số có thể được bỏ qua bằng cách đặt trường độ dài của thông báo CAPI thành 22
thay vì 30.


4.4 Cấu trúc _cmsg
-----------------------

(được khai báo trong <linux/isdn/capiutil.h>)

Cấu trúc _cmsg lưu trữ nội dung của tin nhắn CAPI 2.0 một cách dễ dàng
hình thức có thể truy cập được. Nó chứa các thành viên cho tất cả các tham số CAPI 2.0 có thể có,
bao gồm các thông số phụ của Thông tin bổ sung và Giao thức B có cấu trúc
tham số, với các ngoại lệ sau:

* Số bên gọi thứ hai (CONNECT_IND)

* Dữ liệu64 (DATA_B3_REQ và DATA_B3_IND)

* Gửi hoàn tất (tham số phụ của Thông tin bổ sung, CONNECT_REQ và INFO_REQ)

* Cấu hình toàn cầu (tham số phụ của Giao thức B, CONNECT_REQ, CONNECT_RESP
  và SELECT_B_PROTOCOL_REQ)

Chỉ những tham số xuất hiện trong loại thông báo hiện đang được xử lý
thực sự được sử dụng. Các thành viên không sử dụng nên được đặt thành 0.

Các thành viên được đặt tên theo tên tiêu chuẩn CAPI 2.0 của các thông số mà họ
đại diện. Xem <linux/isdn/capiutil.h> để biết cách viết chính xác. Dữ liệu thành viên
các loại là:

============ =======================================================================
u8 cho các tham số CAPI thuộc loại 'byte'

u16 cho các tham số CAPI của loại 'word'

u32 cho các tham số CAPI của loại 'dword'

_cstruct cho các tham số CAPI thuộc loại 'struct'
	    Thành viên này là một con trỏ tới bộ đệm chứa tham số trong
	    Mã hóa CAPI (độ dài + nội dung). Nó cũng có thể là NULL, sẽ
	    được coi là đại diện cho một tham số trống (độ dài bằng 0).
	    Các tham số phụ được lưu trữ ở dạng được mã hóa trong phần nội dung.

_cmstruct biểu diễn thay thế cho các tham số CAPI thuộc loại 'struct'
	    (chỉ được sử dụng cho các tham số 'Thông tin bổ sung' và 'Giao thức B')
	    Biểu diễn là một byte đơn chứa một trong các giá trị:
	    CAPI_DEFAULT: Tham số trống/không có.
	    CAPI_COMPOSE: Có tham số.
	    Các giá trị tham số phụ được lưu trữ riêng lẻ trong thư mục tương ứng
	    _cmsg thành viên cấu trúc.
============ =======================================================================


5. Chức năng giao diện lớp dưới
==================================

::

int Attach_capi_ctr(struct capi_ctr *ctrlr)
  int tách_capi_ctr(struct capi_ctr *ctrlr)

đăng ký/hủy đăng ký thiết bị (bộ điều khiển) với Kernel CAPI

::

void capi_ctr_ready(struct capi_ctr *ctrlr)
  void capi_ctr_down(struct capi_ctr *ctrlr)

Bộ điều khiển tín hiệu sẵn sàng/chưa sẵn sàng

::

void capi_ctr_handle_message(struct capi_ctr * ctrlr, ứng dụng u16,
			       cấu trúc sk_buff *skb)

chuyển tin nhắn CAPI đã nhận tới Kernel CAPI
để chuyển tiếp đến ứng dụng được chỉ định


6. Chức năng trợ giúp và macro
==============================

Macro để trích xuất/đặt các giá trị phần tử từ/trong tiêu đề thư CAPI
(từ <linux/isdn/capiutil.h>):

============================================================================
Lấy phần tử Macro Set Macro (Loại)
============================================================================
CAPIMSG_LEN(m) CAPIMSG_SETLEN(m, len) Tổng chiều dài (u16)
CAPIMSG_APPID(m) CAPIMSG_SETAPPID(m, ứng dụng) ID ứng dụng (u16)
Lệnh CAPIMSG_COMMAND(m) CAPIMSG_SETCOMMAND(m,cmd) (u8)
CAPIMSG_SUBCOMMAND(m) CAPIMSG_SETSUBCOMMAND(m, cmd) Lệnh phụ (u8)
CAPIMSG_CMD(m) - Lệnh*256
							+ Lệnh phụ (u16)
CAPIMSG_MSGID(m) CAPIMSG_SETMSGID(m, msgid) Số tin nhắn (u16)

Bộ điều khiển CAPIMSG_CONTROL(m) CAPIMSG_SETCONTROL(m, contr)/PLCI/NCCI
							(u32)
CAPIMSG_DATALEN(m) CAPIMSG_SETDATALEN(m, len) Độ dài dữ liệu (u16)
============================================================================


Các hàm thư viện để làm việc với cấu trúc _cmsg
(từ <linux/isdn/capiutil.h>):

ZZ0000ZZ
	Trả về tên thông báo CAPI 2.0 tương ứng với lệnh đã cho
	và các giá trị lệnh phụ, dưới dạng chuỗi ASCII tĩnh. Giá trị trả về có thể
	là NULL nếu lệnh/lệnh phụ không phải là một trong những lệnh được xác định trong
	Tiêu chuẩn CAPI 2.0.


7. Gỡ lỗi
============

Mô-đun kernelcapi có tham số mô-đun showcapimsgs kiểm soát một số
đầu ra gỡ lỗi được tạo ra bởi mô-đun. Nó chỉ có thể được thiết lập khi mô-đun được
được tải, thông qua tham số "showcapimsgs=<n>" cho lệnh modprobe, hoặc trên
dòng lệnh hoặc trong tập tin cấu hình.

Nếu bit thấp nhất của showcapimsgs được đặt, bộ điều khiển nhật ký kernelcapi và
sự kiện lên xuống của ứng dụng.

Ngoài ra, mọi bộ điều khiển CAPI đã đăng ký đều có dấu vết liên quan
tham số kiểm soát cách các tin nhắn CAPI được gửi từ và đến bộ điều khiển
đã đăng nhập. Tham số traceflag được khởi tạo với giá trị của
tham số showcapimsgs khi bộ điều khiển được đăng ký, nhưng sau này có thể được
đã thay đổi thông qua lệnh MANUFACTURER_REQ KCAPI_CMD_TRACE.

Nếu giá trị của traceflag khác 0, các thông báo CAPI sẽ được ghi lại.
Tin nhắn DATA_B3 chỉ được ghi lại nếu giá trị của traceflag > 2.

Nếu bit thấp nhất của traceflag được đặt thì chỉ có lệnh/lệnh phụ và thông báo
chiều dài được ghi lại. Mặt khác, kernelcapi ghi lại một biểu diễn có thể đọc được của
toàn bộ tin nhắn.
