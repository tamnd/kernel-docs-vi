.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/lapb-module.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================
Giao diện mô-đun Linux LAPB
===============================

Phiên bản 1.3

Jonathan Naylor 29.12.96

Đã thay đổi (Henner Eisen, 2000-10-29): giá trị trả về int cho data_indication()

Mô-đun LAPB sẽ là mô-đun được biên dịch riêng để sử dụng bởi bất kỳ phần nào của
hệ điều hành Linux yêu cầu dịch vụ LAPB. Tài liệu này
xác định các giao diện và các dịch vụ được cung cấp bởi mô-đun này. các
mô-đun thuật ngữ trong ngữ cảnh này không ngụ ý rằng mô-đun LAPB là một
mô-đun có thể tải riêng biệt, mặc dù có thể như vậy. Thuật ngữ module được sử dụng trong
ý nghĩa tiêu chuẩn hơn của nó.

Giao diện của mô-đun LAPB bao gồm các chức năng của mô-đun,
cuộc gọi lại từ mô-đun để chỉ ra những thay đổi trạng thái quan trọng và
cấu trúc để nhận và thiết lập thông tin về mô-đun.

Cấu trúc
----------

Có lẽ cấu trúc quan trọng nhất là cấu trúc skbuff để giữ
dữ liệu được nhận và truyền đi, tuy nhiên nó nằm ngoài phạm vi của điều này
tài liệu.

Hai cấu trúc cụ thể của LAPB là cấu trúc khởi tạo LAPB và
cấu trúc tham số LAPB. Chúng sẽ được xác định trong một tiêu đề tiêu chuẩn
tập tin <linux/lapb.h>. Tệp tiêu đề <net/lapb.h> nằm trong LAPB
mô-đun và không được sử dụng.

Cấu trúc khởi tạo LAPB
-----------------------------

Cấu trúc này chỉ được sử dụng một lần trong lệnh gọi lapb_register (xem bên dưới).
Nó chứa thông tin về trình điều khiển thiết bị yêu cầu dịch vụ
của mô-đun LAPB::

cấu trúc lapb_register_struct {
		void (*connect_confirmation)(int token, int Reason);
		void (*connect_indication)(int token, int Reason);
		void (*disconnect_confirmation)(int token, int Reason);
		void (*disconnect_indication)(int token, int Reason);
		int (*data_indication)(int token, struct sk_buff *skb);
		khoảng trống (*data_transmit)(int token, struct sk_buff *skb);
	};

Mỗi thành viên của cấu trúc này tương ứng với một chức năng trong trình điều khiển thiết bị
được gọi khi một sự kiện cụ thể trong mô-đun LAPB xảy ra. Những điều này sẽ
được mô tả chi tiết dưới đây. Nếu không cần gọi lại (!!) thì NULL
có thể được thay thế.


Cấu trúc tham số LAPB
------------------------

Cấu trúc này được sử dụng với các hàm lapb_getparms và lapb_setparms
(xem bên dưới). Chúng được sử dụng để cho phép trình điều khiển thiết bị nhận và thiết lập
các tham số hoạt động của việc triển khai LAPB cho một kết nối nhất định::

cấu trúc lapb_parms_struct {
		unsign int t1;
		int t1timer không dấu;
		unsign int t2;
		int t2timer không dấu;
		unsign int n2;
		unsign int n2count;
		cửa sổ int không dấu;
		trạng thái int không dấu;
		chế độ int không dấu;
	};

T1 và T2 là các tham số thời gian của giao thức và được tính theo đơn vị 100ms. N2
là số lần thử tối đa trên liên kết trước khi nó được tuyên bố là lỗi.
Kích thước cửa sổ là số lượng gói dữ liệu còn lại tối đa được phép
không được đầu cuối từ xa thừa nhận, giá trị của cửa sổ nằm trong khoảng 1
và 7 đối với liên kết LAPB tiêu chuẩn và từ 1 đến 127 đối với LAPB mở rộng
liên kết.

Biến chế độ là trường bit được sử dụng để cài đặt (hiện tại) ba giá trị.
Các trường bit có ý nghĩa sau:

============================================================
Ý nghĩa bit
============================================================
0 hoạt động LAPB (0=LAPB_STANDARD 1=LAPB_EXTENDED).
1 [SM]Hoạt động LP (0=LAPB_SLP 1=LAPB=MLP).
2 Hoạt động DTE/DCE (0=LAPB_DTE 1=LAPB_DCE)
3-31 Dành riêng, phải bằng 0.
============================================================

Hoạt động LAPB mở rộng cho biết việc sử dụng số thứ tự mở rộng và
do đó kích thước cửa sổ lớn hơn, mặc định là hoạt động LAPB tiêu chuẩn.
Hoạt động của MLP giống như hoạt động của SLP ngoại trừ các địa chỉ được sử dụng bởi
LAPB khác nhau để biểu thị chế độ hoạt động, mặc định là Đơn
Thủ tục liên kết. Sự khác biệt giữa hoạt động DCE và DTE là (i)
địa chỉ được sử dụng cho các lệnh và phản hồi và (ii) khi DCE không
được kết nối, nó sẽ gửi DM mà không đặt cuộc thăm dò ý kiến, vào mỗi T1. Hằng số chữ hoa
tên sẽ được xác định trong tệp tiêu đề LAPB công khai.


Chức năng
---------

Mô-đun LAPB cung cấp một số điểm vào chức năng.

::

int lapb_register(void *token, struct lapb_register_struct);

Điều này phải được gọi trước khi mô-đun LAPB có thể được sử dụng. Nếu cuộc gọi là
thành công thì LAPB_OK được trả về. Mã thông báo phải là mã định danh duy nhất
được tạo bởi trình điều khiển thiết bị để cho phép nhận dạng duy nhất
phiên bản của liên kết LAPB. Nó được trả về bởi mô-đun LAPB trong tất cả các
gọi lại và được trình điều khiển thiết bị sử dụng trong tất cả các lệnh gọi đến mô-đun LAPB.
Đối với nhiều liên kết LAPB trong một trình điều khiển thiết bị, nhiều lệnh gọi tới
lapb_register phải được thực hiện. Định dạng của lapb_register_struct được đưa ra
ở trên. Các giá trị trả về là:

==============================================
LAPB_OK LAPB đã đăng ký thành công.
Mã thông báo LAPB_BADTOKEN đã được đăng ký.
LAPB_NOMEM Hết bộ nhớ
==============================================

::

int lapb_unregister(void *token);

Điều này giải phóng tất cả các tài nguyên được liên kết với liên kết LAPB. Bất kỳ dòng điện nào
Liên kết LAPB sẽ bị hủy mà không có tin nhắn nào được chuyển tiếp. Sau
cuộc gọi này, giá trị của mã thông báo không còn hợp lệ đối với bất kỳ cuộc gọi nào tới LAPB
chức năng. Các giá trị trả về hợp lệ là:

================================================
LAPB_OK LAPB hủy đăng ký thành công.
LAPB_BADTOKEN Mã thông báo LAPB không hợp lệ/không xác định.
================================================

::

int lapb_getparms(void *token, struct lapb_parms_struct *parms);

Điều này cho phép trình điều khiển thiết bị nhận các giá trị của LAPB hiện tại
các biến, lapb_parms_struct được mô tả ở trên. Các giá trị trả về hợp lệ
là:

==============================================
LAPB_OK LAPB getparms đã thành công.
LAPB_BADTOKEN Mã thông báo LAPB không hợp lệ/không xác định.
==============================================

::

int lapb_setparms(void *token, struct lapb_parms_struct *parms);

Điều này cho phép trình điều khiển thiết bị đặt các giá trị của LAPB hiện tại
các biến, lapb_parms_struct được mô tả ở trên. Các giá trị của t1timer,
t2timer và n2count bị bỏ qua, tương tự như vậy việc thay đổi các bit chế độ khi
được kết nối sẽ bị bỏ qua. Một lỗi ngụ ý rằng không có giá trị nào có
đã được thay đổi. Các giá trị trả về hợp lệ là:

====================================================================
LAPB_OK LAPB getparms đã thành công.
LAPB_BADTOKEN Mã thông báo LAPB không hợp lệ/không xác định.
LAPB_INVALUE Một trong những giá trị nằm ngoài phạm vi cho phép.
====================================================================

::

int lapb_connect_request(void *mã thông báo);

Bắt đầu kết nối bằng cách sử dụng cài đặt tham số hiện tại. Sự trở lại hợp lệ
giá trị là:

===================================================
LAPB_OK LAPB đang bắt đầu kết nối.
LAPB_BADTOKEN Mã thông báo LAPB không hợp lệ/không xác định.
Mô-đun LAPB_CONNECTED LAPB đã được kết nối.
===================================================

::

int lapb_disconnect_request(void *mã thông báo);

Bắt đầu ngắt kết nối. Các giá trị trả về hợp lệ là:

====================================================
LAPB_OK LAPB đang bắt đầu ngắt kết nối.
LAPB_BADTOKEN Mã thông báo LAPB không hợp lệ/không xác định.
Mô-đun LAPB_NOTCONNECTED LAPB chưa được kết nối.
====================================================

::

int lapb_data_request(void *token, struct sk_buff *skb);

Xếp hàng dữ liệu với mô-đun LAPB để truyền qua liên kết. Nếu cuộc gọi
thành công thì skbuff thuộc sở hữu của mô-đun LAPB và có thể không
được trình điều khiển thiết bị sử dụng lại. Các giá trị trả về hợp lệ là:

==================================================
LAPB_OK LAPB đã chấp nhận dữ liệu.
LAPB_BADTOKEN Mã thông báo LAPB không hợp lệ/không xác định.
Mô-đun LAPB_NOTCONNECTED LAPB chưa được kết nối.
==================================================

::

int lapb_data_received(void *token, struct sk_buff *skb);

Xếp hàng dữ liệu với mô-đun LAPB đã được nhận từ thiết bị. Nó
dự kiến rằng dữ liệu được truyền tới mô-đun LAPB có skb->trỏ dữ liệu
đến đầu dữ liệu LAPB. Nếu cuộc gọi thành công thì skbuff
được sở hữu bởi mô-đun LAPB và trình điều khiển thiết bị có thể không được sử dụng lại.
Các giá trị trả về hợp lệ là:

===========================================
LAPB_OK LAPB đã chấp nhận dữ liệu.
LAPB_BADTOKEN Mã thông báo LAPB không hợp lệ/không xác định.
===========================================

Cuộc gọi lại
---------

Các lệnh gọi lại này là các chức năng do trình điều khiển thiết bị cung cấp cho LAPB
module để gọi khi một sự kiện xảy ra. Họ đã được đăng ký với LAPB
mô-đun có lapb_register (xem ở trên) trong cấu trúc lapb_register_struct
(xem ở trên).

::

void (*connect_confirmation)(void *token, lý do int);

Điều này được mô-đun LAPB gọi khi kết nối được thiết lập sau
được yêu cầu bởi một cuộc gọi tới lapb_connect_request (xem ở trên). Lý do là
luôn là LAPB_OK.

::

void (*connect_indication)(void *token, lý do int);

Điều này được mô-đun LAPB gọi khi liên kết được thiết lập bởi điều khiển từ xa
hệ thống. Giá trị của lý trí luôn là LAPB_OK.

::

void (*disconnect_confirmation)(void *token, lý do int);

Điều này được mô-đun LAPB gọi khi một sự kiện xảy ra sau khi thiết bị
trình điều khiển đã gọi lapb_disconnect_request (xem ở trên). Nguyên nhân chỉ ra
chuyện gì đã xảy ra vậy Trong mọi trường hợp, liên kết LAPB có thể được coi là
chấm dứt. Các giá trị cho lý do là:

==========================================================================
LAPB_OK Liên kết LAPB đã bị chấm dứt bình thường.
LAPB_NOTCONNECTED Hệ thống từ xa không được kết nối.
LAPB_TIMEDOUT Không nhận được phản hồi trong N2 lần thử từ xa
			hệ thống.
==========================================================================

::

void (*disconnect_indication)(void *token, lý do int);

Điều này được mô-đun LAPB gọi khi liên kết bị chấm dứt bởi điều khiển từ xa
hệ thống hoặc sự kiện khác đã xảy ra để chấm dứt liên kết. Đây có thể là
được trả về để phản hồi lapb_connect_request (xem ở trên) nếu điều khiển từ xa
hệ thống từ chối yêu cầu Các giá trị cho lý do là:

==========================================================================
LAPB_OK Liên kết LAPB đã được kết thúc bình thường bằng điều khiển từ xa
			hệ thống.
LAPB_REFUSED Hệ thống từ xa từ chối yêu cầu kết nối.
LAPB_NOTCONNECTED Hệ thống từ xa không được kết nối.
LAPB_TIMEDOUT Không nhận được phản hồi trong N2 lần thử từ xa
			hệ thống.
==========================================================================

::

int (*data_indication)(void *token, struct sk_buff *skb);

Điều này được mô-đun LAPB gọi khi dữ liệu được nhận từ
hệ thống từ xa sẽ được chuyển lên lớp tiếp theo trong giao thức
ngăn xếp. Skbuff trở thành tài sản của trình điều khiển thiết bị và LAPB
mô-đun sẽ không thực hiện thêm bất kỳ hành động nào trên đó. Con trỏ dữ liệu skb-> sẽ
đang trỏ đến byte dữ liệu đầu tiên sau tiêu đề LAPB.

Phương thức này sẽ trả về NET_RX_DROP (như được định nghĩa trong tiêu đề
file include/linux/netdevice.h) khi và chỉ khi khung bị loại bỏ
trước khi nó có thể được chuyển đến lớp trên.

::

void (*data_transmit)(void *token, struct sk_buff *skb);

Điều này được mô-đun LAPB gọi khi dữ liệu được truyền đến
hệ thống từ xa bởi trình điều khiển thiết bị. Skbuff trở thành tài sản của
trình điều khiển thiết bị và mô-đun LAPB sẽ không thực hiện thêm bất kỳ hành động nào trên đó.
Con trỏ dữ liệu skb-> sẽ trỏ đến byte đầu tiên của tiêu đề LAPB.