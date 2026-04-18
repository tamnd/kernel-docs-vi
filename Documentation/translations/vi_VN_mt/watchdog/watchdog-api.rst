.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/watchdog/watchdog-api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================================
Trình điều khiển Linux Watchdog API
=============================

Đánh giá lần cuối: 05/10/2007



Bản quyền 2002 Christer Weingel <wingel@nano-system.com>

Một số phần của tài liệu này được sao chép nguyên văn từ sbc60xxwdt
trình điều khiển là (c) Bản quyền 2000 Jakob Oestergaard <jakob@ostenfeld.dk>

Tài liệu này mô tả trạng thái của nhân Linux 2.4.18.

Giới thiệu
============

Bộ đếm thời gian Watchdog (WDT) là một mạch phần cứng có thể đặt lại
hệ thống máy tính khi có lỗi phần mềm.  Có lẽ bạn đã biết điều đó
rồi.

Thông thường, một daemon không gian người dùng sẽ thông báo cho trình điều khiển giám sát kernel thông qua
/dev/watchdog tệp thiết bị đặc biệt mà không gian người dùng vẫn còn tồn tại, tại
khoảng thời gian đều đặn.  Khi có thông báo như vậy xảy ra, người lái xe sẽ
thường nói với cơ quan giám sát phần cứng rằng mọi thứ đều ổn và
rằng cơ quan giám sát nên đợi thêm một thời gian nữa để thiết lập lại
hệ thống.  Nếu không gian người dùng bị lỗi (lỗi RAM, lỗi kernel, bất kỳ lỗi nào), thì
thông báo ngừng xảy ra và cơ quan giám sát phần cứng sẽ đặt lại
hệ thống (gây khởi động lại) sau khi hết thời gian chờ.

Cơ quan giám sát Linux API là một công trình khá đặc biệt và khác biệt
trình điều khiển triển khai các phần khác nhau và đôi khi không tương thích của nó.
Tệp này là một nỗ lực để ghi lại cách sử dụng hiện tại và cho phép
những người viết trình điều khiển trong tương lai sẽ sử dụng nó làm tài liệu tham khảo.

API đơn giản nhất
================

Tất cả các trình điều khiển đều hỗ trợ chế độ hoạt động cơ bản, trong đó cơ quan giám sát
kích hoạt ngay khi /dev/watchdog được mở và sẽ khởi động lại trừ khi
cơ quan giám sát được ping trong một thời gian nhất định, thời gian này được gọi là
thời gian chờ hoặc lề.  Cách đơn giản nhất để ping cơ quan giám sát là viết
một số dữ liệu vào thiết bị.  Vì vậy, một daemon giám sát rất đơn giản sẽ trông
giống như tệp nguồn này: xem samples/watchdog/watchdog-simple.c

Ví dụ, trình điều khiển nâng cao hơn có thể kiểm tra xem máy chủ HTTP có
vẫn phản hồi trước khi thực hiện lệnh gọi ghi tới ping cơ quan giám sát.

Khi thiết bị đóng, cơ quan giám sát sẽ bị vô hiệu hóa, trừ khi có lệnh "Magic
Tính năng Đóng" được hỗ trợ (xem bên dưới).  Điều này không phải lúc nào cũng như vậy
ý tưởng hay, vì nếu có lỗi trong trình nền của cơ quan giám sát và nó
gặp sự cố hệ thống sẽ không khởi động lại.  Bởi vì điều này, một số
trình điều khiển hỗ trợ tùy chọn cấu hình "Tắt tính năng tắt máy theo dõi
đóng", CONFIG_WATCHDOG_NOWAYOUT.  Nếu nó được đặt thành Y khi biên dịch
kernel, không có cách nào vô hiệu hóa cơ quan giám sát một khi nó đã được
bắt đầu.  Vì vậy, nếu daemon giám sát gặp sự cố, hệ thống sẽ khởi động lại
sau khi hết thời gian chờ. Các thiết bị Watchdog cũng thường hỗ trợ
tham số mô-đun nowoutout để có thể kiểm soát tùy chọn này tại
thời gian chạy.

Tính năng Magic Close
===================

Nếu trình điều khiển hỗ trợ "Magic Close", trình điều khiển sẽ không vô hiệu hóa
cơ quan giám sát trừ khi một nhân vật ma thuật cụ thể 'V' đã được gửi tới
/dev/watchdog ngay trước khi đóng tệp.  Nếu daemon không gian người dùng
đóng tập tin mà không gửi ký tự đặc biệt này, trình điều khiển
sẽ cho rằng daemon (và không gian người dùng nói chung) đã chết và sẽ
ngừng ping cơ quan giám sát mà không tắt nó trước.  Điều này sau đó sẽ
khởi động lại nếu cơ quan giám sát không được mở lại trong thời gian đủ.

ioctl API
=============

Tất cả các trình điều khiển phù hợp cũng hỗ trợ ioctl API.

Ping cơ quan giám sát bằng ioctl:

Tất cả các trình điều khiển có giao diện ioctl đều hỗ trợ ít nhất một ioctl,
KEEPALIVE.  Ioctl này thực hiện chính xác điều tương tự như ghi vào
thiết bị giám sát, do đó vòng lặp chính trong chương trình trên có thể là
được thay thế bằng::

trong khi (1) {
		ioctl(fd, WDIOC_KEEPALIVE, 0);
		ngủ(10);
	}

đối số cho ioctl bị bỏ qua.

Cài đặt và nhận thời gian chờ
===============================

Đối với một số trình điều khiển, có thể sửa đổi thời gian chờ của cơ quan giám sát trên
bay với SETTIMEOUT ioctl, những người lái xe đó có WDIOF_SETTIMEOUT
cờ được đặt trong trường tùy chọn của họ.  Đối số là một số nguyên
đại diện cho thời gian chờ tính bằng giây.  Tài xế trả xe thật
thời gian chờ được sử dụng trong cùng một biến và thời gian chờ này có thể khác với
yêu cầu do hạn chế của phần cứng::

thời gian chờ int = 45;
    ioctl(fd, WDIOC_SETTIMEOUT, &hết thời gian);
    printf("Thời gian chờ được đặt thành %d giây\n", timeout);

Ví dụ này thực sự có thể in "Thời gian chờ được đặt thành 60 giây"
nếu thiết bị có mức độ chi tiết về số phút trong thời gian chờ.

Bắt đầu với nhân Linux 2.4.18, có thể truy vấn
thời gian chờ hiện tại bằng GETTIMEOUT ioctl::

ioctl(fd, WDIOC_GETTIMEOUT, &hết thời gian);
    printf("Thời gian chờ là %d giây\n", timeout);

Hết giờ
===========

Một số bộ hẹn giờ giám sát có thể được đặt để kích hoạt tắt trước khi
thời gian thực tế họ sẽ thiết lập lại hệ thống.  Điều này có thể được thực hiện với NMI,
ngắt hoặc cơ chế khác.  Điều này cho phép Linux ghi lại những thông tin hữu ích
thông tin (như thông tin hoảng loạn và kernel coredumps) trước nó
đặt lại::

trước thời gian chờ = 10;
    ioctl(fd, WDIOC_SETPRETIMEOUT, &pretimeout);

Lưu ý rằng thời gian chờ là số giây trước thời điểm
khi thời gian chờ sẽ tắt.  Đây không phải là số giây cho đến khi
thời gian chờ trước.  Vì vậy, ví dụ: nếu bạn đặt thời gian chờ là 60 giây
và thời gian chờ là 10 giây, thời gian chờ sẽ tắt sau 50 giây
giây.  Đặt thời gian chờ về 0 sẽ vô hiệu hóa nó.

Ngoài ra còn có chức năng get để lấy thời gian chờ trước ::

ioctl(fd, WDIOC_GETPRETIMEOUT, &hết thời gian);
    printf("Thời gian chờ trước là %d giây\n", hết thời gian chờ);

Không phải tất cả các trình điều khiển cơ quan giám sát đều hỗ trợ thời gian chờ trước.

Lấy số giây trước khi khởi động lại
=======================================

Một số trình điều khiển cơ quan giám sát có khả năng báo cáo thời gian còn lại
trước khi hệ thống khởi động lại. WDIOC_GETTIMELEFT là ioctl
trả về số giây trước khi khởi động lại::

ioctl(fd, WDIOC_GETTIMELEFT, &timeleft);
    printf("Thời gian chờ là %d giây\n", timeleft);

Giám sát môi trường
========================

Tất cả các trình điều khiển cơ quan giám sát được yêu cầu trả lại thêm thông tin về hệ thống,
một số thực hiện giám sát nhiệt độ, quạt và mức năng lượng, một số có thể cho bạn biết
lý do cho lần khởi động lại cuối cùng của hệ thống.  GETSUPPORT ioctl là
có sẵn để hỏi xem thiết bị có thể làm gì::

struct watchdog_info nhận dạng;
	ioctl(fd, WDIOC_GETSUPPORT, &ident);

các trường được trả về trong cấu trúc nhận dạng là:

===================================================================
        nhận dạng một chuỗi xác định trình điều khiển cơ quan giám sát
	firmware_version phiên bản phần sụn của thẻ nếu có
	tùy chọn một lá cờ mô tả những gì thiết bị hỗ trợ
	===================================================================

trường tùy chọn có thể có các bit sau được đặt và mô tả những gì
loại thông tin mà ioctls GET_STATUS và GET_BOOT_STATUS có thể
trở lại.

=============================================
	WDIOF_OVERHEAT Reset do CPU quá nóng
	=============================================

Máy được cơ quan giám sát khởi động lại lần cuối vì giới hạn nhiệt là
vượt quá:

=============== ===========
	Quạt WDIOF_FANFAULT bị lỗi
	=============== ===========

Quạt hệ thống được giám sát bằng thẻ giám sát đã bị lỗi

============== ==================
	WDIOF_EXTERN1 Rơle ngoài 1
	============== ==================

Rơ-le giám sát bên ngoài/nguồn 1 đã được kích hoạt. Bộ điều khiển dành cho
các ứng dụng trong thế giới thực bao gồm các chân giám sát bên ngoài sẽ kích hoạt
một sự thiết lập lại.

============== ==================
	WDIOF_EXTERN2 Rơle ngoài 2
	============== ==================

Rơle giám sát bên ngoài/nguồn 2 đã được kích hoạt

========================================
	WDIOF_POWERUNDER Lỗi nguồn/lỗi nguồn
	========================================

Máy đang hiển thị trạng thái điện áp thấp

================================================
	Thẻ WDIOF_CARDRESET trước đó đã đặt lại CPU
	================================================

Lần khởi động lại gần đây nhất là do thẻ giám sát

========================================
	WDIOF_POWEROVER Nguồn quá điện áp
	========================================

Máy đang hiển thị trạng thái quá điện áp. Lưu ý rằng nếu một cấp độ là
dưới và một trên cả hai bit sẽ được đặt - điều này có vẻ kỳ quặc nhưng khiến
ý nghĩa.

==========================================
	WDIOF_KEEPALIVEPING Duy trì phản hồi ping sống động
	==========================================

Cơ quan giám sát đã nhìn thấy ping liên tục kể từ lần truy vấn cuối cùng.

==========================================
	WDIOF_SETTIMEOUT Có thể đặt/nhận thời gian chờ
	==========================================

Cơ quan giám sát có thể thực hiện pretimeouts.

====================================================
	WDIOF_PRETIMEOUT Thời gian chờ trước (tính bằng giây), nhận/đặt
	====================================================


Đối với những trình điều khiển trả về bất kỳ bit nào được đặt trong trường tùy chọn,
GETSTATUS và GETBOOTSTATUS ioctls có thể được sử dụng để yêu cầu hiện tại
trạng thái và trạng thái ở lần khởi động lại gần đây nhất::

cờ int;
    ioctl(fd, WDIOC_GETSTATUS, &flags);

hoặc

ioctl(fd, WDIOC_GETBOOTSTATUS, &flags);

Lưu ý rằng không phải tất cả các thiết bị đều hỗ trợ hai cuộc gọi này và một số chỉ
hỗ trợ cuộc gọi GETBOOTSTATUS.

Một số trình điều khiển có thể đo nhiệt độ bằng GETTEMP ioctl.  các
giá trị trả về là nhiệt độ tính bằng độ F::

nhiệt độ int;
    ioctl(fd, WDIOC_GETTEMP, &nhiệt độ);

Cuối cùng, SETOPTIONS ioctl có thể được sử dụng để kiểm soát một số khía cạnh của
hoạt động của thẻ::

tùy chọn int = 0;
    ioctl(fd, WDIOC_SETOPTIONS, &options);

Các tùy chọn sau đây có sẵn:

=====================================================
	WDIOS_DISABLECARD Tắt bộ đếm thời gian theo dõi
	WDIOS_ENABLECARD Bật bộ đếm thời gian theo dõi
	WDIOS_TEMPPANIC Hạt nhân hoảng loạn trong chuyến đi nhiệt độ
	=====================================================

[FIXME - giải thích tốt hơn]
