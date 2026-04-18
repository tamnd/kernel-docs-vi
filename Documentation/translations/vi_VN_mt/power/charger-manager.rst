.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/power/charger-manager.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================
Trình quản lý bộ sạc
====================

(C) 2011 MyungJoo Ham <myungjoo.ham@samsung.com>, GPL

Trình quản lý bộ sạc cung cấp tính năng quản lý bộ sạc pin trong kernel
yêu cầu theo dõi nhiệt độ trong trạng thái tạm dừng ở trạng thái RAM
và nơi mỗi pin có thể được gắn nhiều bộ sạc và vùng người dùng
muốn xem thông tin tổng hợp của nhiều bộ sạc.

Trình quản lý bộ sạc là một platform_driver có các mục nhập cấp nguồn.
Một phiên bản của Trình quản lý bộ sạc (một thiết bị nền tảng được tạo bằng Trình quản lý bộ sạc)
đại diện cho một pin độc lập với bộ sạc. Nếu có nhiều
pin có bộ sạc riêng hoạt động độc lập trong một hệ thống,
hệ thống có thể cần nhiều phiên bản Trình quản lý bộ sạc.

1. Giới thiệu
===============

Trình quản lý bộ sạc hỗ trợ các tính năng sau:

* Hỗ trợ nhiều bộ sạc (ví dụ: thiết bị có USB, AC và tấm pin mặt trời)
	Một hệ thống có thể có nhiều bộ sạc (hoặc nguồn điện) và một số
	chúng có thể được kích hoạt cùng một lúc. Mỗi bộ sạc có thể có
	loại cung cấp điện riêng và mỗi loại cung cấp điện có thể cung cấp
	thông tin khác nhau về tình trạng pin. Khung này
	tổng hợp thông tin liên quan đến bộ sạc từ nhiều nguồn và
	hiển thị thông tin kết hợp dưới dạng một loại nguồn cung cấp điện duy nhất.

* Hỗ trợ bỏ phiếu tạm dừng cho RAM (với lệnh gọi lại Suspend_again)
	Trong khi pin đang được sạc và hệ thống ở trạng thái tạm dừng với RAM,
	chúng ta có thể cần theo dõi tình trạng pin bằng cách quan sát môi trường xung quanh hoặc
	nhiệt độ pin. Chúng ta có thể thực hiện điều này bằng cách đánh thức hệ thống
	định kỳ. Tuy nhiên, phương pháp như vậy sẽ đánh thức thiết bị một cách không cần thiết vì
	theo dõi tình trạng và tác vụ của pin cũng như các quy trình của người dùng
	đáng lẽ phải bị đình chỉ. Điều đó lại gây ra sức mạnh không cần thiết
	tiêu thụ và làm chậm quá trình sạc. Hoặc thậm chí, sức mạnh đỉnh cao như vậy
	mức tiêu thụ có thể dừng bộ sạc khi đang sạc
	(đầu vào nguồn điện bên ngoài < mức tiêu thụ điện năng của thiết bị), không
	chỉ ảnh hưởng đến thời gian sạc mà còn ảnh hưởng đến tuổi thọ của pin.

Trình quản lý bộ sạc cung cấp chức năng "cm_suspend_again" có thể
	được sử dụng làm lệnh gọi lại Suspend_again của platform_suspend_ops. Nếu nền tảng
	yêu cầu các tác vụ khác ngoài cm_suspend_again, nó có thể thực hiện tác vụ riêng của mình
	gọi lại Suspend_again gọi cm_suspend_again ở giữa.
	Thông thường, nền tảng sẽ cần tiếp tục và tạm dừng một số thiết bị
	được sử dụng bởi Trình quản lý sạc.

* Hỗ trợ xử lý sự kiện pin đầy sớm
	Nếu điện áp pin giảm "fullbatt_vchkdrop_uV" sau
	"fullbatt_vchkdrop_ms" từ sự kiện đầy pin, khung
	khởi động lại quá trình sạc. Việc kiểm tra này cũng được thực hiện khi bị đình chỉ bởi
	thiết lập thời gian đánh thức phù hợp và sử dụng Suspend_again.

* Hỗ trợ thông báo sự kiện
	Với các sự kiện liên quan đến bộ sạc, thiết bị sẽ gửi
	thông báo cho người dùng với UEVENT.

2. Dữ liệu Trình quản lý bộ sạc toàn cầu liên quan đến Suspend_again
====================================================================
Để thiết lập Trình quản lý sạc với tính năng tạm dừng
(giám sát tạm dừng), người dùng nên cung cấp charger_global_desc
với setup_charger_manager(ZZ0000ZZ).
Dữ liệu charger_global_desc này để theo dõi tình trạng tạm dừng là dữ liệu toàn cầu
như tên cho thấy. Vì vậy, người dùng chỉ cần cung cấp một lần duy nhất
nếu có nhiều pin. Nếu có nhiều pin,
nhiều phiên bản của Trình quản lý bộ sạc dùng chung một bộ sạc_global_desc
và nó sẽ quản lý việc giám sát tạm dừng cho tất cả các phiên bản của Trình quản lý bộ sạc.

Người dùng cần cung cấp cả ba mục nhập cho ZZ0000ZZ
đúng cách để kích hoạt giám sát tạm dừng:

ZZ0000ZZ
	Tên của rtc (ví dụ: "rtc0") được sử dụng để đánh thức hệ thống từ
	tạm dừng cho Trình quản lý bộ sạc. Ngắt cảnh báo (AIE) của rtc
	sẽ có thể đánh thức hệ thống khỏi trạng thái tạm dừng. Trình quản lý bộ sạc
	lưu và khôi phục giá trị cảnh báo và sử dụng giá trị đã xác định trước đó
	báo động nếu nó sắp tắt sớm hơn Trình quản lý bộ sạc để
	Trình quản lý bộ sạc không can thiệp vào các cảnh báo được xác định trước đó.

ZZ0000ZZ
	Cuộc gọi lại này sẽ cho CM biết liệu
	việc đánh thức do tạm dừng chỉ được gây ra bởi cảnh báo "rtc" trong
	cùng một cấu trúc. Nếu có bất kỳ nguồn đánh thức nào khác kích hoạt
	thức dậy, nó sẽ trả về sai. Nếu "rtc" là lần đánh thức duy nhất
	lý do, nó sẽ trả về đúng.

ZZ0000ZZ
	nếu đúng, Trình quản lý bộ sạc sẽ giả định rằng
	bộ hẹn giờ (CM sử dụng jiffies làm bộ đếm thời gian) dừng trong khi tạm dừng. Sau đó CM
	giả định rằng thời lượng tạm dừng giống như thời lượng cảnh báo.


3. Cách thiết lập Suspend_again
===============================
Trình quản lý bộ sạc cung cấp chức năng "extern bool cm_suspend_again(void)".
Khi cm_suspend_again được gọi, nó sẽ giám sát mọi pin. Đình chỉ_ops
gọi lại platform_suspend_ops của hệ thống có thể gọi cm_suspend_again
để biết liệu Trình quản lý bộ sạc có muốn tạm dừng lại hay không.
Nếu không có thiết bị hoặc tác vụ nào khác muốn sử dụng Suspend_again
tính năng này, platform_suspend_ops có thể đề cập trực tiếp đến cm_suspend_again
cho cuộc gọi lại Suspend_again của nó.

cm_suspend_again() trả về true (có nghĩa là "Tôi muốn tạm dừng lại")
nếu hệ thống được đánh thức bởi Trình quản lý bộ sạc và việc bỏ phiếu
(giám sát tạm dừng) cho kết quả "bình thường".

4. Dữ liệu trình quản lý bộ sạc (struct charger_desc)
=====================================================
Đối với mỗi pin được sạc độc lập với các pin khác (nếu một loạt pin
pin được sạc bằng một bộ sạc duy nhất, chúng được tính là một bộ sạc độc lập
pin), một phiên bản của Trình quản lý bộ sạc được đính kèm với nó. Sau đây

Các phần tử struct charger_desc:

ZZ0000ZZ
	Tên cấp nguồn của pin. Mặc định là
	"pin" nếu psy_name là NULL. Người dùng có thể truy cập các mục tâm lý
	tại "/sys/class/power_supply/[psy_name]/".

ZZ0000ZZ
	  CM_POLL_DISABLE:
		không thăm dò pin này.
	  CM_POLL_ALWAYS:
		thăm dò pin này luôn.
	  CM_POLL_EXTERNAL_POWER_ONLY:
		thăm dò pin này nếu và chỉ khi có nguồn điện bên ngoài
		nguồn được đính kèm.
	  CM_POLL_CHARGING_ONLY:
		thăm dò pin này khi và chỉ khi pin đang được sạc.

ZZ0000ZZ
	Nếu cả hai đều có giá trị khác 0, Trình quản lý bộ sạc sẽ kiểm tra
	điện áp pin giảm fullbatt_vchkdrop_ms sau khi pin đầy
	tính phí. Nếu điện áp sụt quá fullbatt_vchkdrop_uV, Bộ sạc
	Người quản lý sẽ cố gắng sạc lại pin bằng cách tắt và bật
	bộ sạc. Chỉ sạc lại với điều kiện sụt áp (không có độ trễ
	điều kiện) là cần thiết để được thực hiện với các ngắt phần cứng từ
	đồng hồ đo nhiên liệu hoặc thiết bị/chip sạc.

ZZ0000ZZ
	Nếu được chỉ định bằng giá trị khác 0, Trình quản lý bộ sạc sẽ giả định
	rằng pin đã đầy (dung lượng = 100) nếu pin không hoạt động
	đã sạc và điện áp pin bằng hoặc lớn hơn
	fullbatt_uV.

ZZ0000ZZ
	Khoảng thời gian bỏ phiếu bắt buộc tính bằng ms. Trình quản lý bộ sạc sẽ thăm dò ý kiến
	pin này sẽ được sử dụng vào mỗi polling_interval_ms hoặc thường xuyên hơn.

ZZ0000ZZ
	CM_BATTERY_PRESENT:
		giả sử rằng pin tồn tại.
	CM_NO_BATTERY:
		giả định rằng pin không tồn tại.
	CM_FUEL_GAUGE:
		lấy thông tin hiện diện của pin từ đồng hồ đo nhiên liệu.
	CM_CHARGER_STAT:
		nhận được sự hiện diện của pin từ bộ sạc.

ZZ0000ZZ
	Một mảng kết thúc bằng NULL có tên loại nguồn cung cấp điện là
	bộ sạc. Mỗi loại cấp nguồn phải cung cấp "PRESENT" (nếu
	hiện tại pin là "CM_CHARGER_STAT"), "ONLINE" (cho biết liệu
	nguồn điện bên ngoài có được gắn hay không) và "STATUS" (cho biết liệu
	pin là {"FULL" hay không FULL} hoặc {"FULL", "Đang sạc",
	"Đang xả", "Không sạc"}).

ZZ0000ZZ
	Bộ điều chỉnh đại diện cho bộ sạc ở dạng dành cho
	chức năng số lượng lớn của khung điều chỉnh.

ZZ0000ZZ
	Tên loại cấp điện của đồng hồ đo nhiên liệu.

ZZ0000ZZ
	Cuộc gọi lại này trả về 0 nếu nhiệt độ an toàn để sạc,
	một số dương nếu quá nóng để sạc và một số âm
	nếu trời quá lạnh để sạc. Với biến mC, lệnh gọi lại trả về
	nhiệt độ tính bằng 1/1000 độ C.
	Nguồn nhiệt độ có thể là pin hoặc nguồn nhiệt độ xung quanh tùy theo
	giá trị của số đo_battery_temp.


5. Những cân nhắc khác
=======================

Tại các sự kiện liên quan đến bộ sạc/pin như rút pin,
bộ sạc đã rút ra, đã lắp bộ sạc, DCIN quá điện áp/dưới điện áp, đã dừng bộ sạc,
và những thứ khác quan trọng đối với bộ sạc, hệ thống phải được cấu hình để thức dậy.
Ít nhất những điều sau đây sẽ đánh thức hệ thống khỏi trạng thái tạm dừng:
a) bật/tắt bộ sạc b) vào/ra nguồn điện bên ngoài c) vào/ra pin (trong khi sạc)

Nó thường được thực hiện bằng cách định cấu hình PMIC làm nguồn đánh thức.
