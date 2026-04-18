.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/power/basic-pm-debugging.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Gỡ lỗi chế độ ngủ đông và tạm dừng
====================================

(C) 2007 Rafael J. Wysocki <rjw@sisk.pl>, GPL

1. Kiểm tra chế độ ngủ đông (còn gọi là tạm dừng vào đĩa hoặc STD)
==================================================================

Để kiểm tra xem chế độ ngủ đông có hoạt động hay không, bạn có thể thử chế độ ngủ đông ở chế độ "khởi động lại"::

Khởi động lại # echo> /sys/power/đĩa
	Đĩa # echo > /sys/power/state

và hệ thống sẽ tạo hình ảnh ngủ đông, khởi động lại, tiếp tục và quay lại
dấu nhắc lệnh nơi bạn đã bắt đầu quá trình chuyển đổi.  Nếu điều đó xảy ra,
chế độ ngủ đông có nhiều khả năng hoạt động chính xác nhất.  Tuy nhiên, bạn cần phải lặp lại
kiểm tra ít nhất một vài lần liên tiếp để biết độ tin cậy.  [Điều này là cần thiết,
bởi vì một số vấn đề chỉ xuất hiện ở lần thử tạm dừng thứ hai và
tiếp tục hệ thống.] Hơn nữa, ngủ đông trong quá trình "khởi động lại" và "tắt máy"
các chế độ khiến lõi PM bỏ qua một số lệnh gọi lại liên quan đến nền tảng trên ACPI
hệ thống có thể cần thiết để thực hiện chế độ ngủ đông.  Vì vậy, nếu máy của bạn
không thể ngủ đông hoặc tiếp tục ở chế độ "khởi động lại", bạn nên thử
chế độ "nền tảng"::

Nền tảng # echo > /sys/power/đĩa
	Đĩa # echo > /sys/power/state

đó là chế độ ngủ đông mặc định và được khuyến nghị.

Thật không may, chế độ ngủ đông "nền tảng" không hoạt động trên một số hệ thống
với BIOS bị hỏng.  Trong những trường hợp như vậy, chế độ ngủ đông "tắt máy" có thể
công việc::

Tắt máy # echo > /sys/power/disk
	Đĩa # echo > /sys/power/state

(nó tương tự như chế độ "khởi động lại" nhưng yêu cầu bạn phải nhấn nút nguồn
để làm cho hệ thống tiếp tục lại).

Nếu cả chế độ ngủ đông "nền tảng" và "tắt máy" đều không hoạt động, bạn sẽ cần phải
xác định những gì sai.

a) Kiểm tra chế độ ngủ đông
----------------------------

Để tìm hiểu lý do tại sao chế độ ngủ đông không thành công trên hệ thống của bạn, bạn có thể sử dụng một thử nghiệm đặc biệt
tiện ích khả dụng nếu kernel được biên dịch với bộ CONFIG_PM_DEBUG.  Sau đó,
có tệp /sys/power/pm_test có thể được sử dụng để ngủ đông
lõi chạy ở chế độ thử nghiệm.  Có 5 chế độ kiểm tra có sẵn:

tủ đông
	- kiểm tra sự đóng băng của các quá trình

thiết bị
	- kiểm tra việc đóng băng các quy trình và tạm dừng thiết bị

nền tảng
	- kiểm tra việc đóng băng các quy trình, tạm dừng thiết bị và nền tảng
	  phương pháp kiểm soát toàn cầu [1]_

bộ vi xử lý
	- kiểm tra việc đóng băng các quy trình, tạm dừng thiết bị, nền tảng
	  các phương pháp điều khiển toàn cục [1]_ và vô hiệu hóa các CPU không khởi động được

cốt lõi
	- kiểm tra việc đóng băng các quy trình, tạm dừng thiết bị, nền tảng toàn cầu
	  các phương thức điều khiển\ [1]_, vô hiệu hóa các CPU không khởi động và tạm dừng
	  của các thiết bị nền tảng/hệ thống

.. [1]

    the platform global control methods are only available on ACPI systems
    and are only tested if the hibernation mode is set to "platform"

Để sử dụng một trong số chúng cần phải viết chuỗi tương ứng vào
/sys/power/pm_test (ví dụ: "thiết bị" để kiểm tra việc đóng băng các quy trình và
thiết bị treo) và đưa ra các lệnh ngủ đông tiêu chuẩn.  Ví dụ,
để sử dụng chế độ kiểm tra "thiết bị" cùng với chế độ ngủ đông "nền tảng",
bạn nên làm như sau::

Thiết bị # echo > /sys/power/pm_test
	Nền tảng # echo > /sys/power/đĩa
	Đĩa # echo > /sys/power/state

Sau đó, kernel sẽ cố gắng đóng băng các tiến trình, tạm dừng thiết bị, đợi một vài giây.
giây (5 theo mặc định, nhưng có thể định cấu hình bằng mô-đun treo.pm_test_delay
tham số), tiếp tục các thiết bị và làm tan băng các quá trình.  Nếu "nền tảng" được ghi vào
/sys/power/pm_test , thì sau khi tạm dừng thiết bị, kernel sẽ bổ sung thêm
gọi các phương thức điều khiển toàn cục (ví dụ: các phương thức điều khiển toàn cục ACPI) được sử dụng để
chuẩn bị phần sụn nền tảng cho chế độ ngủ đông.  Tiếp theo, nó sẽ đợi một
số giây có thể định cấu hình và gọi nền tảng (ví dụ: ACPI) toàn cầu
phương pháp được sử dụng để hủy bỏ chế độ ngủ đông, v.v.

Viết "none" vào /sys/power/pm_test khiến kernel chuyển sang trạng thái bình thường
hoạt động ngủ đông/tạm dừng.  Ngoài ra, khi mở để đọc, /sys/power/pm_test
chứa danh sách tất cả các bài kiểm tra có sẵn được phân tách bằng dấu cách (bao gồm cả "không có"
đại diện cho chức năng bình thường) trong đó mức độ kiểm tra hiện tại là
được biểu thị bằng dấu ngoặc vuông.

Nói chung, như bạn có thể thấy, mỗi cấp độ kiểm tra đều "xâm lấn" hơn cấp độ trước đó.
một và cấp độ "cốt lõi" kiểm tra phần cứng và trình điều khiển một cách sâu sắc nhất có thể
mà không tạo ra một hình ảnh ngủ đông.  Rõ ràng, nếu việc kiểm tra "thiết bị" thất bại,
thử nghiệm "nền tảng" cũng sẽ thất bại, v.v.  Vì vậy, theo nguyên tắc chung, bạn
nên thử các chế độ thử nghiệm bắt đầu từ "tủ đông", thông qua "thiết bị", "nền tảng"
và "bộ xử lý" cho đến "lõi" (lặp lại thử nghiệm ở mỗi cấp độ một vài lần
để đảm bảo tránh được mọi yếu tố ngẫu nhiên).

Nếu thử nghiệm "tủ đông" thất bại, có một nhiệm vụ không thể đóng băng (trong trường hợp đó
thường có thể xác định nhiệm vụ vi phạm bằng cách phân tích đầu ra của
dmesg thu được sau lần kiểm tra thất bại).  Thất bại ở cấp độ này thường có nghĩa là
rằng có một vấn đề với hệ thống con tủ đông nhiệm vụ cần được khắc phục
báo cáo.

Nếu kiểm tra "thiết bị" không thành công, rất có thể có trình điều khiển không thể tạm dừng
hoặc tiếp tục lại thiết bị của nó (trong trường hợp sau, hệ thống có thể bị treo hoặc không ổn định
sau khi kiểm tra, vì vậy hãy cân nhắc điều đó).  Để tìm trình điều khiển này,
bạn có thể thực hiện tìm kiếm nhị phân theo các quy tắc:

- nếu kiểm tra thất bại, hãy dỡ một nửa số trình điều khiển hiện đang được tải và lặp lại
  (điều đó có thể liên quan đến việc khởi động lại hệ thống, vì vậy hãy luôn lưu ý những trình điều khiển nào
  đã được tải trước khi thử nghiệm),
- nếu thử nghiệm thành công, hãy tải một nửa số trình điều khiển mà bạn đã tải xuống nhiều nhất
  gần đây và lặp lại.

Khi bạn đã tìm thấy trình điều khiển bị lỗi (có thể có nhiều hơn một trình điều khiển
chúng), bạn phải dỡ nó mỗi lần trước khi ngủ đông.  Trong trường hợp đó xin vui lòng
đảm bảo báo cáo vấn đề với trình điều khiển.

Cũng có thể việc kiểm tra "thiết bị" vẫn thất bại sau khi bạn đã
đã dỡ bỏ tất cả các mô-đun. Trong trường hợp đó, bạn có thể muốn xem trong kernel của mình
cấu hình cho các trình điều khiển có thể được biên dịch thành các mô-đun (và kiểm tra lại
với các trình điều khiển này được biên dịch dưới dạng mô-đun).  Bạn cũng có thể thử sử dụng một số cách đặc biệt
các tùy chọn dòng lệnh kernel như "noapic", "noacpi" hoặc thậm chí "acpi=off".

Nếu thử nghiệm "nền tảng" thất bại thì có vấn đề với việc xử lý
chương trình cơ sở nền tảng (ví dụ: ACPI) trên hệ thống của bạn.  Trong trường hợp đó chế độ "nền tảng"
chế độ ngủ đông không có khả năng hoạt động.  Bạn có thể thử chế độ "tắt máy", nhưng điều đó
đúng hơn là cách giải quyết của một người nghèo.

Nếu kiểm tra "bộ xử lý" không thành công thì việc tắt/bật các CPU không khởi động sẽ không thành công.
hoạt động (tất nhiên, đây chỉ có thể là sự cố trên hệ thống SMP) và sự cố
nên được báo cáo.  Trong trường hợp đó, bạn cũng có thể thử chuyển đổi CPU nonboot
tắt và bật bằng cách sử dụng thuộc tính /sys/devices/system/cpu/cpu*/online sysfs và
xem liệu nó có hiệu quả không.

Nếu thử nghiệm "lõi" không thành công, điều đó có nghĩa là việc tạm dừng hệ thống/nền tảng
các thiết bị đã bị lỗi (các thiết bị này bị treo trên một CPU và bị tắt),
vấn đề rất có thể liên quan đến phần cứng và nghiêm trọng, vì vậy cần phải giải quyết
báo cáo.

Việc thất bại trong bất kỳ thử nghiệm "nền tảng", "bộ xử lý" hoặc "lõi" nào có thể khiến bạn
hệ thống bị treo hoặc không ổn định, vì vậy hãy cẩn thận.  Sự thất bại như vậy thường
chỉ ra một vấn đề nghiêm trọng có thể liên quan đến phần cứng, nhưng
xin vui lòng báo cáo nó dù sao đi nữa.

b) Test cấu hình tối thiểu
--------------------------------

Nếu tất cả các chế độ kiểm tra chế độ ngủ đông đều hoạt động, bạn có thể khởi động hệ thống bằng
Tham số dòng lệnh "init=/bin/bash" và cố gắng ngủ đông trong
Các chế độ "khởi động lại", "tắt máy" và "nền tảng".  Nếu cách đó không hiệu quả thì có
có thể có vấn đề với trình điều khiển được biên dịch tĩnh vào kernel và bạn
có thể cố gắng biên dịch nhiều trình điều khiển hơn dưới dạng mô-đun để có thể kiểm tra chúng
riêng lẻ.  Nếu không thì có vấn đề với trình điều khiển mô-đun và bạn có thể
tìm nó bằng cách tải một nửa mô-đun bạn thường sử dụng và tìm kiếm nhị phân
theo thuật toán:
- nếu có n mô-đun được tải và nỗ lực tạm dừng và tiếp tục không thành công,
dỡ n/2 mô-đun và thử lại (điều đó có thể liên quan đến việc khởi động lại
hệ thống),
- nếu có n mô-đun được tải và nỗ lực tạm dừng và tiếp tục thành công,
tải thêm n/2 mô-đun và thử lại.

Một lần nữa, nếu bạn tìm thấy (các) mô-đun vi phạm, thì (chúng) phải được dỡ bỏ mỗi lần.
trước khi ngủ đông và vui lòng báo cáo sự cố với nó (họ).

c) Sử dụng tùy chọn ngủ đông "test_resume"
---------------------------------------------

/sys/power/disk thường cho kernel biết phải làm gì sau khi tạo một
hình ảnh ngủ đông.  Một trong những tùy chọn có sẵn là "test_resume"
khiến hình ảnh vừa tạo được sử dụng để khôi phục ngay lập tức.  Cụ thể là,
sau khi thực hiện::

# echo test_resume > /sys/power/đĩa
	Đĩa # echo > /sys/power/state

một hình ảnh ngủ đông sẽ được tạo và một sơ yếu lý lịch từ nó sẽ được kích hoạt
ngay lập tức mà không liên quan đến phần sụn nền tảng dưới bất kỳ hình thức nào.

Thử nghiệm đó có thể được sử dụng để kiểm tra xem liệu việc tiếp tục hoạt động trở lại sau chế độ ngủ đông có bị lỗi hay không.
liên quan đến tương tác xấu với phần mềm nền tảng.  Nghĩa là, nếu ở trên
hoạt động mọi lúc, nhưng tiếp tục từ chế độ ngủ đông thực tế không hoạt động hoặc
không đáng tin cậy, phần sụn nền tảng có thể là nguyên nhân gây ra lỗi.

Trên các kiến trúc và nền tảng hỗ trợ sử dụng các kernel khác nhau để khôi phục
hình ảnh ngủ đông (nghĩa là kernel được sử dụng để đọc hình ảnh từ bộ lưu trữ và
tải nó vào bộ nhớ khác với bộ nhớ có trong hình ảnh) hoặc hỗ trợ
ngẫu nhiên hóa không gian địa chỉ kernel, nó cũng có thể được sử dụng để kiểm tra xem có lỗi không
để tiếp tục có thể liên quan đến sự khác biệt giữa khôi phục và hình ảnh
hạt nhân.

d) Gỡ lỗi nâng cao
---------------------

Trong trường hợp chế độ ngủ đông không hoạt động trên hệ thống của bạn ngay cả ở mức tối thiểu
cấu hình và biên dịch thêm trình điều khiển dưới dạng mô-đun là không thực tế hoặc một số
không thể tải các mô-đun xuống, bạn có thể sử dụng một trong những tính năng sửa lỗi nâng cao hơn
các kỹ thuật để tìm ra vấn đề.  Đầu tiên, nếu có cổng nối tiếp trong hộp của bạn,
bạn có thể khởi động kernel với tham số 'no_console_suspend' và thử đăng nhập
thông báo kernel bằng bảng điều khiển nối tiếp.  Điều này có thể cung cấp cho bạn một số
thông tin về lý do đình chỉ (tiếp tục) thất bại.  Ngoài ra,
có thể sử dụng cổng FireWire để gỡ lỗi bằng firescope
(ZZ0000ZZ Trên x86 cũng có thể
sử dụng cơ chế PM_TRACE được ghi lại trong Documentation/power/s2ram.rst.

2. Kiểm tra tạm dừng RAM (STR)
===============================

Để xác minh rằng STR có hoạt động hay không, sử dụng s2ram thường sẽ thuận tiện hơn
công cụ có sẵn từ ZZ0000ZZ và được ghi lại tại
ZZ0001ZZ (S2RAM_LINK).

Cụ thể, sau khi viết "tủ đông", "thiết bị", "nền tảng", "bộ xử lý" hoặc "lõi"
vào /sys/power/pm_test (khả dụng nếu kernel được biên dịch bằng
Bộ CONFIG_PM_DEBUG) mã tạm dừng sẽ hoạt động ở chế độ kiểm tra tương ứng
tới chuỗi đã cho.  Các chế độ kiểm tra STR được xác định theo cách tương tự như đối với
ngủ đông, vì vậy vui lòng tham khảo Phần 1 để biết thêm thông tin về chúng.  trong
Đặc biệt, bài kiểm tra "cốt lõi" cho phép bạn kiểm tra mọi thứ ngoại trừ bài kiểm tra thực tế.
gọi phần sụn nền tảng để đưa hệ thống vào trạng thái ngủ
trạng thái.

Trong số những thứ khác, việc kiểm tra với sự trợ giúp của /sys/power/pm_test có thể cho phép
bạn xác định các trình điều khiển không tạm dừng hoặc tiếp tục lại thiết bị của họ.  Họ
nên được dỡ bỏ mỗi lần trước khi chuyển đổi STR.

Tiếp theo, bạn có thể làm theo hướng dẫn tại S2RAM_LINK để kiểm tra hệ thống, nhưng nếu
nó không hoạt động "ngay lập tức", bạn có thể cần phải khởi động nó bằng
"init=/bin/bash" và kiểm tra s2ram ở cấu hình tối thiểu.  Trong trường hợp đó,
bạn có thể tìm kiếm các trình điều khiển bị lỗi bằng cách làm theo quy trình
tương tự như mô tả trong phần 1. Nếu bạn tìm thấy một số trình điều khiển bị lỗi,
bạn sẽ phải dỡ chúng mỗi lần trước khi chuyển đổi STR (tức là trước
bạn chạy s2ram) và vui lòng báo cáo sự cố với họ.

Có một mục debugfs hiển thị việc tạm dừng số liệu thống kê RAM. Đây là một
ví dụ về đầu ra của nó::

# mount -t debugfs không/sys/kernel/debug
	# cat/sys/kernel/debug/suspend_stats
	thành công: 20
	thất bại: 5
	thất bại_freeze: 0
	thất bại_chuẩn bị: 0
	thất bại_đình chỉ: 5
	thất bại_suspend_noirq: 0
	thất bại_sơ yếu lý lịch: 0
	thất bại_resume_noirq: 0
	thất bại:
	  Last_failed_dev: báo động
				adc
	  Last_failed_errno: -16
				-16
	  Last_failed_step: đình chỉ
				đình chỉ

Thành công trường có nghĩa là số lần tạm dừng thành công đối với RAM và trường không thành công có nghĩa là
số thất bại. Những cái khác là số lần thất bại của các bước đình chỉ khác nhau
tới RAM. Suspend_stats chỉ liệt kê 2 thiết bị bị lỗi gần đây nhất, số lỗi và
bước đình chỉ thất bại.
