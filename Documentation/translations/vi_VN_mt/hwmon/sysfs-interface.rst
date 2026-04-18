.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/sysfs-interface.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Tiêu chuẩn đặt tên và định dạng dữ liệu cho file sysfs
================================================

Thư viện libsensors cung cấp giao diện cho dữ liệu cảm biến thô
thông qua giao diện sysfs. Kể từ lm-sensors 3.0.0, libsensors là
hoàn toàn không phụ thuộc vào chip. Nó giả định rằng tất cả các trình điều khiển kernel
triển khai giao diện sysfs tiêu chuẩn được mô tả trong tài liệu này.
Điều này làm cho việc thêm hoặc cập nhật hỗ trợ cho bất kỳ chip cụ thể nào trở nên rất dễ dàng, như
libsensors và các ứng dụng sử dụng nó không cần phải sửa đổi.
Đây là một cải tiến lớn so với cảm biến lm 2.

Lưu ý rằng các bo mạch chủ rất khác nhau về kết nối với chip cảm biến.
Chẳng hạn, không có tiêu chuẩn nào đảm bảo rằng điều thứ hai
cảm biến nhiệt độ được kết nối với CPU hoặc quạt thứ hai đang bật
CPU. Ngoài ra, một số giá trị được chip báo cáo cần thực hiện một số tính toán
trước khi chúng có ý nghĩa đầy đủ. Ví dụ: hầu hết các chip chỉ có thể đo
điện áp từ 0 đến +4V. Các điện áp khác được thu nhỏ lại
phạm vi sử dụng điện trở bên ngoài. Vì giá trị của các điện trở này
có thể thay đổi từ bo mạch chủ này sang bo mạch chủ khác, việc chuyển đổi không thể thực hiện được
được mã hóa cứng vào trình điều khiển và phải được thực hiện trong không gian người dùng.

Vì lý do này, ngay cả khi chúng tôi hướng tới các cảm biến lib không phụ thuộc vào chip, nó sẽ
vẫn yêu cầu tệp cấu hình (ví dụ: /etc/sensors.conf) cho phù hợp
chuyển đổi giá trị, ghi nhãn đầu vào và ẩn các đầu vào không sử dụng.

Một phương pháp thay thế mà một số chương trình sử dụng là truy cập vào sysfs
tập tin trực tiếp. Tài liệu này mô tả ngắn gọn các tiêu chuẩn mà
trình điều khiển theo sau, để chương trình ứng dụng có thể quét các mục nhập và
truy cập dữ liệu này một cách đơn giản và nhất quán. Điều đó nói lên rằng, những chương trình như vậy
sẽ phải thực hiện chuyển đổi, gắn nhãn và ẩn đầu vào. cho
vì lý do này, vẫn không nên bỏ qua thư viện.

Mỗi chip có thư mục riêng trong cây sysfs/sys/devices.  Đến
tìm thấy tất cả các chip cảm biến, việc theo dõi các liên kết tượng trưng của thiết bị sẽ dễ dàng hơn
ZZ0000ZZ.

Lên đến lm-sensors 3.0.0, libsensors sẽ tìm kiếm các thuộc tính giám sát phần cứng
trong thư mục thiết bị "vật lý". Kể từ lm-sensors 3.0.1, các thuộc tính được tìm thấy
trong thư mục thiết bị "class" hwmon cũng được hỗ trợ. Trình điều khiển phức tạp
(ví dụ: trình điều khiển cho chip đa chức năng) có thể muốn sử dụng khả năng này để
tránh ô nhiễm không gian tên. Hạn chế duy nhất là các phiên bản cũ hơn của
libsensors sẽ không hỗ trợ trình điều khiển được đề cập.

Tất cả các giá trị sysfs là số điểm cố định.

Chỉ có một giá trị cho mỗi tệp, không giống như đặc tả /proc cũ hơn.
Cách đặt tên tập tin phổ biến là: <type><number>_<item>. thông thường
loại cho chip cảm biến là “in” (điện áp), “temp” (nhiệt độ) và
“quạt” (quạt). Các mục thông thường là "đầu vào" (giá trị đo được), "tối đa" (cao
ngưỡng, "min" (ngưỡng thấp). Việc đánh số thường bắt đầu từ 1,
ngoại trừ các điện áp bắt đầu từ 0 (vì hầu hết các bảng dữ liệu đều sử dụng
cái này). Một số luôn được sử dụng cho các phần tử có thể xuất hiện nhiều hơn
hơn một lần, ngay cả khi chỉ có một phần tử thuộc loại đã cho trên
chíp cụ thể. Các tệp khác không đề cập đến một phần tử cụ thể, vì vậy
họ có một cái tên đơn giản và không có số.

Cảnh báo là các chỉ dẫn trực tiếp được đọc từ chip. Các trình điều khiển làm NOT
so sánh các số đọc với các ngưỡng. Điều này cho phép vi phạm
giữa các lần đọc để được phát hiện và báo động. Định nghĩa chính xác của một
báo động (ví dụ, liệu một ngưỡng phải được đáp ứng hay phải vượt quá
để gây ra cảnh báo) phụ thuộc vào chip.

Khi thiết lập giá trị của thuộc tính hwmon sysfs, biểu diễn chuỗi của
giá trị mong muốn phải được viết, lưu ý rằng các chuỗi không phải là số
được hiểu là 0! Để biết thêm về cách diễn giải các chuỗi bằng văn bản, hãy xem
phần "giải thích ghi thuộc tính sysfs" ở cuối tệp này.

Quyền truy cập thuộc tính
----------------

Thuộc tính sysfs giám sát phần cứng được hiển thị theo không gian người dùng không hạn chế
ứng dụng. Vì lý do này, tất cả các thuộc tính ABI tiêu chuẩn sẽ là thế giới
có thể đọc được. Các thuộc tính ABI tiêu chuẩn có thể ghi được sẽ chỉ có thể ghi được đối với
người dùng đặc quyền.

-------------------------------------------------------------------------

======= ===============================================
ZZ0000ZZ biểu thị bất kỳ số dương nào bắt đầu từ 0
ZZ0001ZZ biểu thị bất kỳ số dương nào bắt đầu từ 1
Giá trị chỉ đọc RO
WO chỉ ghi giá trị
Giá trị đọc/ghi RW
======= ===============================================

Các giá trị đọc/ghi có thể ở dạng chỉ đọc đối với một số chip, tùy thuộc vào
triển khai phần cứng.

Tất cả các mục (ngoại trừ tên) là tùy chọn và chỉ nên được tạo trong một
trình điều khiển nhất định nếu chip có tính năng này.

Xem Documentation/ABI/testing/sysfs-class-hwmon để biết mô tả đầy đủ
của các thuộc tính.

*******************
Thuộc tính toàn cầu
*******************

ZZ0000ZZ
		Tên chip.

ZZ0000ZZ
		Nhãn mô tả cho phép nhận dạng duy nhất một thiết bị
		trong hệ thống.

ZZ0000ZZ
		Khoảng thời gian mà chip sẽ cập nhật số đọc.


********
Điện áp
********

ZZ0000ZZ
		Giá trị điện áp tối thiểu.

ZZ0000ZZ
		Giá trị tối thiểu tới hạn của điện áp.

ZZ0000ZZ
		Giá trị điện áp tối đa.

ZZ0000ZZ
		Giá trị tối đa quan trọng của điện áp.

ZZ0000ZZ
		Giá trị điện áp đầu vào.

ZZ0000ZZ
		Điện áp trung bình

ZZ0000ZZ
		Điện áp tối thiểu lịch sử

ZZ0000ZZ
		Điện áp tối đa lịch sử

ZZ0000ZZ
		Đặt lại inX_lowest và inX_highest

ZZ0000ZZ
		Đặt lại inX_lowest và inX_highest cho tất cả các cảm biến

ZZ0000ZZ
		Nhãn kênh điện áp được đề xuất.

ZZ0000ZZ
		Kích hoạt hoặc vô hiệu hóa các cảm biến.

ZZ0000ZZ
		Điện áp tham chiếu lõi CPU.

ZZ0000ZZ
		Số phiên bản Mô-đun điều chỉnh điện áp.

ZZ0000ZZ
		Điện áp định mức tối thiểu.

ZZ0000ZZ
		Điện áp định mức tối đa.

Đồng thời xem phần Cảnh báo để biết các cờ trạng thái liên quan đến điện áp.


************
người hâm mộ
************

ZZ0000ZZ
		Giá trị tối thiểu của quạt

ZZ0000ZZ
		Giá trị tối đa của quạt

ZZ0000ZZ
		Giá trị đầu vào của quạt.

ZZ0000ZZ
		Bộ chia quạt.

ZZ0000ZZ
		Số xung của máy đo tốc độ trên mỗi vòng quay của quạt.

ZZ0000ZZ
		Tốc độ quạt mong muốn

ZZ0000ZZ
		Nhãn kênh người hâm mộ được đề xuất.

ZZ0000ZZ
		Kích hoạt hoặc vô hiệu hóa các cảm biến.

Đồng thời xem phần Cảnh báo để biết các cờ trạng thái liên quan đến người hâm mộ.


***
PWM
***

ZZ0000ZZ
		Điều khiển quạt điều chế độ rộng xung.

ZZ0000ZZ
		Phương pháp điều khiển tốc độ quạt.

ZZ0000ZZ
		điều chế dòng điện một chiều hoặc độ rộng xung.

ZZ0000ZZ
		Tần số PWM cơ bản tính bằng Hz.

ZZ0000ZZ
		Chọn kênh nhiệt độ nào ảnh hưởng đến đầu ra PWM này trong
		chế độ tự động.

ZZ0000ZZ / ZZ0001ZZ / ZZ0002ZZ
		Xác định đường cong PWM so với nhiệt độ.

ZZ0000ZZ / ZZ0001ZZ / ZZ0002ZZ
		Xác định đường cong PWM so với nhiệt độ.

Có trường hợp thứ ba trong đó các điểm ngắt được liên kết với cả đầu ra PWM
kênh và kênh nhiệt độ: các giá trị PWM được liên kết với PWM
kênh đầu ra trong khi các giá trị nhiệt độ có liên quan đến nhiệt độ
các kênh. Trong trường hợp đó, kết quả được xác định bằng cách ánh xạ giữa
đầu vào nhiệt độ và đầu ra PWM. Khi có một số đầu vào nhiệt độ
được ánh xạ tới đầu ra PWM nhất định, điều này dẫn đến một số giá trị PWM ứng cử viên.
Kết quả thực tế tùy chip nhưng nói chung là ứng viên cao nhất
value (tốc độ quạt nhanh nhất) sẽ thắng.


*************
Nhiệt độ
*************

ZZ0000ZZ
		Lựa chọn loại cảm biến.

ZZ0000ZZ
		Giá trị nhiệt độ tối đa.

ZZ0000ZZ
		Giá trị nhiệt độ tối thiểu.

ZZ0000ZZ
		Giá trị trễ nhiệt độ cho giới hạn tối đa.

ZZ0000ZZ
		Giá trị trễ nhiệt độ cho giới hạn tối thiểu.

ZZ0000ZZ
		Giá trị đầu vào nhiệt độ.

ZZ0000ZZ
		Giá trị tối đa tới hạn của nhiệt độ, thường lớn hơn
		giá trị temp_max tương ứng.

ZZ0000ZZ
		Giá trị trễ nhiệt độ cho giới hạn tới hạn.

ZZ0000ZZ
		Giá trị tối đa khẩn cấp về nhiệt độ, đối với các chip hỗ trợ nhiều hơn
		hai giới hạn nhiệt độ trên.

ZZ0000ZZ
		Giá trị trễ nhiệt độ cho giới hạn khẩn cấp.

ZZ0000ZZ
		Giá trị tối thiểu tới hạn của nhiệt độ, thường thấp hơn
		giá trị temp_min tương ứng.

ZZ0000ZZ
		Giá trị trễ nhiệt độ cho giới hạn tối thiểu tới hạn.

ZZ0000ZZ
		Độ lệch nhiệt độ được thêm vào số đọc nhiệt độ
		bởi con chip.

ZZ0000ZZ
		Nhãn kênh nhiệt độ được đề xuất.

ZZ0000ZZ
		Nhiệt độ tối thiểu lịch sử

ZZ0000ZZ
		Nhiệt độ tối đa lịch sử

ZZ0000ZZ
		Đặt lại temp_lowest và temp_highest

ZZ0000ZZ
		Đặt lại temp_lowest và temp_highest cho tất cả các cảm biến

ZZ0000ZZ
		Kích hoạt hoặc vô hiệu hóa các cảm biến.

ZZ0000ZZ
		Nhiệt độ định mức tối thiểu.

ZZ0000ZZ
		Nhiệt độ định mức tối đa.

Một số chip đo nhiệt độ bằng nhiệt điện trở bên ngoài và ADC, đồng thời
báo cáo kết quả đo nhiệt độ dưới dạng điện áp. Chuyển đổi điện áp này
trở lại nhiệt độ (hoặc ngược lại đối với các giới hạn) yêu cầu
các hàm toán học không có sẵn trong kernel, vì vậy việc chuyển đổi
phải xảy ra trong không gian người dùng. Đối với những chip này, tất cả các tệp tạm thời* được mô tả
ở trên phải chứa các giá trị được biểu thị bằng milivolt thay vì mili độ
độ C. Nói cách khác, các kênh nhiệt độ như vậy được xử lý dưới dạng điện áp
kênh của người lái xe.

Đồng thời xem phần Cảnh báo để biết các cờ trạng thái liên quan đến nhiệt độ.


*********
Dòng điện
*********

ZZ0000ZZ
		Giá trị tối đa hiện tại.

ZZ0000ZZ
		Giá trị tối thiểu hiện tại.

ZZ0000ZZ
		Giá trị thấp tới hạn hiện tại

ZZ0000ZZ
		Giá trị cao tới hạn hiện tại.

ZZ0000ZZ
		Giá trị đầu vào hiện tại.

ZZ0000ZZ
		Mức sử dụng hiện tại trung bình.

ZZ0000ZZ
		Dòng điện tối thiểu lịch sử

ZZ0000ZZ
		Dòng điện tối đa lịch sử.

ZZ0000ZZ
		Đặt lại currX_lowest và currX_highest

WO

ZZ0000ZZ
		Đặt lại currX_lowest và currX_highest cho tất cả các cảm biến.

ZZ0000ZZ
		Kích hoạt hoặc vô hiệu hóa các cảm biến.

ZZ0000ZZ
		Dòng định mức tối thiểu.

ZZ0000ZZ
		Dòng định mức tối đa.

Đồng thời xem phần Cảnh báo để biết các cờ trạng thái liên quan đến dòng điện.

*********
Quyền lực
*********

ZZ0000ZZ
		Sử dụng điện năng trung bình.

ZZ0000ZZ
		Khoảng thời gian sử dụng năng lượng trung bình.

ZZ0000ZZ
		Khoảng thời gian trung bình sử dụng công suất tối đa.

ZZ0000ZZ
		Khoảng thời gian trung bình sử dụng năng lượng tối thiểu.

ZZ0000ZZ
		Mức sử dụng năng lượng tối đa trung bình trong lịch sử

ZZ0000ZZ
		Sử dụng năng lượng tối thiểu trung bình trong lịch sử

ZZ0000ZZ
		Thông báo thăm dò ý kiến được gửi tới ZZ0001ZZ khi
		việc sử dụng năng lượng tăng lên trên giá trị này.

ZZ0000ZZ
		Thông báo thăm dò ý kiến được gửi tới ZZ0001ZZ khi
		mức sử dụng điện năng giảm xuống dưới giá trị này.

ZZ0000ZZ
		Sử dụng năng lượng tức thời.

ZZ0000ZZ
		Sử dụng năng lượng tối đa lịch sử

ZZ0000ZZ
		Sử dụng năng lượng tối thiểu trong lịch sử.

ZZ0000ZZ
		Đặt lại đầu vào_cao nhất, đầu vào_thấp nhất, trung bình_cao nhất và
		trung bình_thấp nhất.

ZZ0000ZZ
		Độ chính xác của đồng hồ đo điện.

ZZ0000ZZ
		Nếu việc sử dụng năng lượng tăng lên trên giới hạn này,
		hệ thống nên thực hiện hành động để giảm mức sử dụng năng lượng.

ZZ0000ZZ
		Biên độ trễ được xây dựng xung quanh giới hạn và thông báo.

ZZ0000ZZ
		Giới hạn tối đa có thể được đặt.

ZZ0000ZZ
		Giới hạn tối thiểu có thể được đặt.

ZZ0000ZZ
		Công suất tối đa.

ZZ0000ZZ
				Sức mạnh tối đa quan trọng.

Nếu công suất tăng đến hoặc cao hơn giới hạn này,
				hệ thống dự kiến sẽ có hành động quyết liệt để giảm
				mức tiêu thụ điện năng, chẳng hạn như tắt hệ thống hoặc
				buộc phải tắt nguồn một số thiết bị.

Đơn vị: microWatt

RW

ZZ0000ZZ
				Kích hoạt hoặc vô hiệu hóa các cảm biến.

Khi bị tắt, kết quả đọc cảm biến sẽ quay trở lại
				-ENODATA.

- 1: Kích hoạt
				- 0: Tắt

RW

ZZ0000ZZ
				Công suất định mức tối thiểu.

Đơn vị: microWatt

RO

ZZ0000ZZ
				Công suất định mức tối đa.

Đơn vị: microWatt

RO

Đồng thời xem phần Cảnh báo để biết các cờ trạng thái liên quan đến chỉ số nguồn.

**********
Năng lượng
**********

ZZ0000ZZ
				Sử dụng năng lượng tích lũy

Đơn vị: microJoule

RO

ZZ0000ZZ
				Kích hoạt hoặc vô hiệu hóa các cảm biến.

Khi bị tắt, kết quả đọc cảm biến sẽ quay trở lại
				-ENODATA.

- 1: Kích hoạt
				- 0: Tắt

RW

********
Độ ẩm
********

ZZ0000ZZ
		Độ ẩm.

ZZ0000ZZ
		Kích hoạt hoặc vô hiệu hóa các cảm biến.

ZZ0000ZZ
		Độ ẩm định mức tối thiểu.

ZZ0000ZZ
		Độ ẩm định mức tối đa.

********
Báo thức
********

Mỗi kênh hoặc giới hạn có thể có một tệp cảnh báo liên quan, chứa một
giá trị boolean. 1 nghĩa là tồn tại tình trạng cảnh báo, 0 nghĩa là không có cảnh báo.

Thông thường, một con chip nhất định sẽ sử dụng các cảnh báo liên quan đến kênh hoặc
báo động liên quan đến giới hạn, không phải cả hai. Trình điều khiển chỉ nên phản ánh phần cứng
thực hiện.

+------------------------------+--------------+
ZZ0005ZZ Báo động kênh |
ZZ0006ZZ |
ZZ0007ZZ - 0: không báo động |
ZZ0008ZZ - 1: báo động |
ZZ0009ZZ |
ZZ0010ZZ RO |
+------------------------------+--------------+

ZZ0000ZZ

+------------------------------+--------------+
ZZ0018ZZ Báo động giới hạn |
ZZ0019ZZ |
ZZ0020ZZ - 0: không báo động |
ZZ0021ZZ - 1: báo động |
ZZ0022ZZ |
ZZ0023ZZ RO |
ZZ0024ZZ |
ZZ0025ZZ |
ZZ0026ZZ |
ZZ0027ZZ |
ZZ0028ZZ |
ZZ0029ZZ |
ZZ0030ZZ |
ZZ0031ZZ |
ZZ0032ZZ |
ZZ0033ZZ |
ZZ0034ZZ |
ZZ0035ZZ |
+------------------------------+--------------+

Mỗi kênh đầu vào có thể có một tệp lỗi liên quan. Điều này có thể được sử dụng
để thông báo điốt mở, quạt không được kết nối, v.v. nơi phần cứng
hỗ trợ nó. Khi boolean này có giá trị 1, phép đo cho giá trị đó
kênh không đáng tin cậy.

ZZ0000ZZ / ZZ0001ZZ
		Tình trạng lỗi đầu vào.

Một số chip cũng có khả năng phát ra tiếng bíp khi xảy ra cảnh báo:

ZZ0000ZZ
		Kích hoạt tiếng bíp chính.

ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ,
		Tiếng bíp của kênh.

Về lý thuyết, một con chip có thể cung cấp tính năng che tiếng bíp theo giới hạn, nhưng không có con chip nào như vậy
đã được nhìn thấy cho đến nay.

Trình điều khiển cũ cung cấp giao diện khác, không chuẩn cho hệ thống báo động và
tiếng bíp. Các tệp giao diện này không được dùng nữa nhưng sẽ được giữ lại
vì lý do tương thích:

ZZ0000ZZ
		Mặt nạ bit báo động.

ZZ0000ZZ
		Bitmask cho tiếng bíp.


*******************
Phát hiện xâm nhập
*******************

ZZ0000ZZ
		Phát hiện xâm nhập khung gầm.

ZZ0000ZZ
		Tiếng bíp xâm nhập khung gầm.

****************************
Cấu hình mẫu trung bình
****************************

Các thiết bị cho phép đọc các giá trị {in,power,curr,temp__average có thể xuất
các thuộc tính để kiểm soát số lượng mẫu được sử dụng để tính trung bình.

+--------------+-------------------------------------------------------------- +
ZZ0000ZZ Đặt số lượng mẫu trung bình cho tất cả các loại phép đo. |
ZZ0001ZZ |
ZZ0002ZZ RW |
+--------------+-------------------------------------------------------------- +
ZZ0003ZZ Đặt số lượng mẫu trung bình cho loại |
Các phép đo ZZ0004ZZ.						       |
ZZ0005ZZ |
ZZ0006ZZ Lưu ý rằng trên một số thiết bị, không thể đặt tất cả |
ZZ0007ZZ chúng thành các giá trị khác nhau nên việc thay đổi một giá trị cũng có thể thay đổi |
ZZ0008ZZ một số khác.						       |
ZZ0009ZZ |
ZZ0010ZZ RW |
+--------------+-------------------------------------------------------------- +

thuộc tính sysfs viết diễn giải
-------------------------------------

Thuộc tính hwmon sysfs luôn chứa số, vì vậy điều đầu tiên cần làm là
chuyển đổi đầu vào thành số, có 2 cách để thực hiện việc này tùy thuộc vào việc
số có thể âm hoặc không::

dài không dấu u = simple_strtoul(buf, NULL, 10);
	dài s = simple_strtol(buf, NULL, 10);

Với buf là bộ đệm với đầu vào của người dùng được hạt nhân truyền vào.
Lưu ý rằng chúng ta không sử dụng đối số thứ hai của strto[u]l, và do đó không thể
cho biết khi nào 0 được trả về, nếu đây thực sự là 0 hoặc do đầu vào không hợp lệ.
Việc này được thực hiện có chủ ý vì việc kiểm tra điều này ở mọi nơi sẽ gây ra nhiều
mã vào kernel.

Lưu ý rằng điều quan trọng là luôn lưu trữ giá trị được chuyển đổi trong một
không được ký dài hoặc dài, để không có sự xung quanh nào có thể xảy ra trước đó nữa
kiểm tra.

Sau khi chuỗi đầu vào được chuyển đổi thành dài (không dấu), giá trị sẽ là
kiểm tra nếu nó chấp nhận được. Hãy cẩn thận với các chuyển đổi tiếp theo về giá trị
trước khi kiểm tra tính hợp lệ của nó, vì những chuyển đổi này vẫn có thể gây ra sự cố
xung quanh trước khi kiểm tra. Ví dụ: không nhân kết quả và chỉ
cộng/trừ nếu nó đã được chia trước khi cộng/trừ.

Phải làm gì nếu một giá trị được phát hiện là không hợp lệ, tùy thuộc vào loại
thuộc tính sysfs đang được đặt. Nếu đó là một cài đặt liên tục như
thuộc tính tempX_max hoặc inX_max thì giá trị đó phải được gắn với thuộc tính của nó
giới hạn sử dụng kẹp_val(value, min_limit, max_limit). Nếu không liên tục
ví dụ như tempX_type, khi một giá trị không hợp lệ được ghi,
-EINVAL nên được trả lại.

Ví dụ1, temp1_max, thanh ghi là giá trị 8 bit có dấu (-128 - 127 độ)::

dài v = simple_strtol(buf, NULL, 10) / 1000;
	v = kẹp_val(v, -128, 127);
	/*viết v để đăng ký */

Ví dụ2, cài đặt bộ chia quạt, giá trị hợp lệ 2, 4 và 8::

dài không dấu v = simple_strtoul(buf, NULL, 10);

chuyển đổi (v) {
	trường hợp 2: v = 1; phá vỡ;
	trường hợp 4: v = 2; phá vỡ;
	trường hợp 8: v = 3; phá vỡ;
	mặc định:
		trả về -EINVAL;
	}
	/*viết v để đăng ký */
