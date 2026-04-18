.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/thermal/intel_dptf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================================================
Giao diện Sysfs nền tảng động và khung nhiệt Intel(R)
=====================================================================

:Bản quyền: © 2022 Tập đoàn Intel

:Tác giả: Srinivas Pandruvada <srinivas.pandruvada@linux.intel.com>

Giới thiệu
------------

Nền tảng động và khung nhiệt Intel(R) (DPTF) là một nền tảng
giải pháp phần cứng/phần mềm cấp độ để quản lý năng lượng và nhiệt.

Là nơi chứa nhiều công nghệ năng lượng/nhiệt, DPTF cung cấp
một cách tiếp cận phối hợp cho các chính sách khác nhau để tác động đến phần cứng
trạng thái của một hệ thống.

Vì nó là một framework cấp nền tảng nên nó có một số thành phần.
Một số phần của công nghệ được triển khai trong phần sụn và sử dụng
Các thiết bị ACPI và PCI hiển thị các tính năng khác nhau để giám sát và
kiểm soát. Linux có một bộ trình điều khiển kernel hiển thị giao diện phần cứng
tới không gian người dùng. Điều này cho phép các giải pháp nhiệt không gian người dùng như
"Linux Thermal Daemon" để đọc nhiệt và năng lượng cụ thể của nền tảng
các bảng để mang lại hiệu suất phù hợp trong khi vẫn duy trì hệ thống ở mức
giới hạn nhiệt.

Giao diện trình điều khiển DPTF ACPI
------------------------------------

ZZ0000ZZ, trong đó <N>
=INT3400ZZ0001ZZINTC1041|INTC10A0

ZZ0000ZZ (RO)
	Một tập hợp các chuỗi UUID trình bày các chính sách có sẵn
	điều này sẽ được thông báo cho phần sụn khi
	không gian người dùng có thể hỗ trợ các chính sách đó.

Dây UUID:

"42A441D6-AE6A-462b-A84B-4A8CE79027D3" : Bị động 1

"3A95C389-E4B8-4629-A526-C52C88626BAE" : Đang hoạt động

"97C68AE7-15FA-499c-B8C9-5DA81D606E0A" : Quan trọng

"63BE270F-1C11-48FD-A6F7-3AF253FF3E2D" : Hiệu suất thích ứng

"5349962F-71E6-431D-9AE8-0A635B710AEE" : Cuộc gọi khẩn cấp

"9E04115A-AE87-4D1C-9500-0F3E340BFE75" : Bị động 2

"F5A35014-C209-46A4-993A-EB56DE7530A1" : Ông chủ quyền lực

"6ED722A7-9240-48A5-B479-31EEF723D7CF" : Cảm biến ảo

"16CAF1B7-DD38-40ED-B1C1-1B8A1913D531" : Chế độ làm mát

"BE84BABF-C4D4-403D-B495-3128FD44dAC1" : HDC

ZZ0000ZZ (RW)
	Không gian người dùng có thể ghi các chuỗi từ các UUID có sẵn, mỗi chuỗi một
	thời gian.

ZZ0000ZZ, trong đó <N>
=INT3400ZZ0001ZZINTC1041|INTC10A0

ZZ0000ZZ (WO)
	Daemon không gian người dùng ghi 1 để phản hồi sự kiện phần sụn
	để gửi thông báo duy trì sự sống. Không gian người dùng nhận được
	THERMAL_EVENT_KEEP_ALIVE kobject thông báo sự kiện khi
	chương trình cơ sở yêu cầu không gian người dùng phản hồi với imok ACPI
	phương pháp.

ZZ0000ZZ (RO)
	Giá trị biến trạng thái nhiệt của phần sụn. Bàn nhiệt
	yêu cầu xử lý khác nhau dựa trên các biến này
	các giá trị.

ZZ0000ZZ (RO)
	Bảng nhiệt nhị phân. tham khảo
	https://github.com/intel/thermal_daemon để giải mã
	bàn nhiệt.

ZZ0000ZZ (RO)
	Khi khác 0, nhà sản xuất khóa cấu hình nhiệt
	từ những thay đổi tiếp theo.

Giao diện bảng quan hệ nhiệt ACPI
------------------------------------------

ZZ0000ZZ

Thiết bị này cung cấp giao diện IOCTL để đọc ACPI tiêu chuẩn
	bảng quan hệ nhiệt thông qua phương pháp ACPI _TRT và _ART.
	Các IOCTL này được định nghĩa trong
	trình điều khiển/nhiệt/intel/int340x_thermal/acpi_thermal_rel.h

IOCTL:

ACPI_THERMAL_GET_TRT_LEN: Lấy chiều dài của bảng TRT

ACPI_THERMAL_GET_ART_LEN: Lấy chiều dài của bảng ART

ACPI_THERMAL_GET_TRT_COUNT: Số lượng bản ghi trong bảng TRT

ACPI_THERMAL_GET_ART_COUNT: Số lượng bản ghi trong bảng ART

ACPI_THERMAL_GET_TRT: Đọc bảng TRT nhị phân, độ dài cần đọc là
	được cung cấp thông qua đối số cho ioctl().

ACPI_THERMAL_GET_ART: Đọc bảng ART nhị phân, độ dài cần đọc là
	được cung cấp thông qua đối số cho ioctl().

Trình điều khiển cảm biến DPTF ACPI
-----------------------------------

Trình điều khiển cảm biến DPTF được trình bày dưới dạng vùng nhiệt hệ thống nhiệt tiêu chuẩn.


Trình điều khiển làm mát DPTF ACPI
----------------------------------

Trình điều khiển làm mát DPTF được trình bày dưới dạng thiết bị làm mát hệ thống nhiệt tiêu chuẩn.


DPTF Bộ xử lý nhiệt PCI Giao diện trình điều khiển
--------------------------------------------------

ZZ0000ZZ

Tham khảo Tài liệu/power/powercap/powercap.rst để biết powercap
ABI.

ZZ0000ZZ (RO)
	Hạn chế sysfs powercap tối đa_0_power_limit_uw cho Intel RAPL

ZZ0000ZZ (RO)
	Tăng/giảm giới hạn nguồn cho giới hạn nguồn 0 của Intel RAPL

ZZ0000ZZ (RO)
	Ràng buộc sysfs powercap tối thiểu_0_power_limit_uw cho Intel RAPL

ZZ0000ZZ (RO)
	Hạn chế sysfs powercap tối thiểu_0_time_window_us cho Intel RAPL

ZZ0000ZZ (RO)
	Hạn chế sysfs powercap tối đa_0_time_window_us cho Intel RAPL

ZZ0000ZZ (RO)
	Hạn chế sysfs powercap tối đa_1_power_limit_uw cho Intel RAPL

ZZ0000ZZ (RO)
	Tăng/giảm giới hạn nguồn cho giới hạn nguồn 1 của Intel RAPL

ZZ0000ZZ (RO)
	Ràng buộc sysfs powercap tối thiểu_1_power_limit_uw cho Intel RAPL

ZZ0000ZZ (RO)
	Ràng buộc sysfs powercap tối thiểu_1_time_window_us cho Intel RAPL

ZZ0000ZZ (RO)
	Hạn chế sysfs powercap tối đa_1_time_window_us cho Intel RAPL

ZZ0000ZZ (RO)
	Khi được đặt thành 1, mức công suất của hệ thống ở mức hiện tại
	đã đạt được cấu hình.  Nó cần phải được cấu hình lại để cho phép
	sức mạnh sẽ bị giảm thêm nữa.

ZZ0000ZZ (RW)
	Khi đặt thành 1, cho phép đọc và thông báo tầng điện
	trạng thái. Thông báo được kích hoạt cho power_floor_status
	thay đổi giá trị thuộc tính.

ZZ0000ZZ

ZZ0000ZZ (RW)
	TCC bù đắp từ nhiệt độ tới hạn nơi phần cứng sẽ điều tiết
	CPU.

ZZ0000ZZ

ZZ0000ZZ (RO)
	Các loại khối lượng công việc có sẵn. Không gian người dùng có thể chỉ định một trong các loại khối lượng công việc
	nó hiện đang thực thi thông qua khối lượng công việc_type. Ví dụ: nhàn rỗi, bùng nổ,
	duy trì v.v.

ZZ0000ZZ (RW)
	Không gian người dùng có thể chỉ định bất kỳ loại khối lượng công việc có sẵn nào bằng cách sử dụng
	giao diện này.

ZZ0000ZZ
ZZ0001ZZ
ZZ0002ZZ

Tất cả các điều khiển này cần có đặc quyền của quản trị viên để cập nhật.

ZZ0000ZZ (RW)
	1 để bật, 0 để tắt. Hiển thị trạng thái kích hoạt hiện tại của
	tính năng kiểm soát nhiệt độ nền tảng. Không gian người dùng có thể bật/tắt
	điều khiển phần cứng.

ZZ0000ZZ (RW)
	Cập nhật mục tiêu nhiệt độ mới tính bằng mili độ C cho phần cứng để
	dùng để điều khiển nhiệt độ.

ZZ0000ZZ (RW)
	Thuộc tính này nằm trong khoảng từ 0 đến 7, trong đó 0 đại diện cho
	sự kiểm soát tích cực nhất để tránh bất kỳ sự vượt quá nhiệt độ nào, và
	7 thể hiện một cách tiếp cận duyên dáng hơn, thiên về hiệu suất ngay cả ở
	chi phí do nhiệt độ vượt quá.
	Lưu ý: Mức này có thể không quy mô tuyến tính. Ví dụ: giá trị 3 không
	không nhất thiết hàm ý sự cải thiện 50% về hiệu suất so với
	giá trị 0.

Vì đây là bộ phận kiểm soát nhiệt độ của bệ nên dự kiến rằng
người quản lý cấp người dùng duy nhất sở hữu và quản lý các điều khiển. Nếu nhiều
các ứng dụng phần mềm ở cấp độ người dùng cố gắng viết các mục tiêu khác nhau, nó
có thể dẫn đến hành vi không mong muốn.


DPTF Bộ xử lý nhiệt Giao diện RFIM
--------------------------------------------

Giao diện RFIM cho phép điều chỉnh FIVR (Bộ điều chỉnh điện áp tích hợp đầy đủ),
DDR (Tốc độ dữ liệu kép) và DLVR (Bộ điều chỉnh điện áp tuyến tính kỹ thuật số)
tần số để tránh nhiễu RF với WiFi và 5G.

Bộ điều chỉnh điện áp chuyển mạch (VR) tạo ra EMI hoặc RFI bức xạ ở
tần số cơ bản và các sóng hài của nó. Một số sóng hài có thể gây nhiễu
với các bộ thu không dây rất nhạy như Wi-Fi và mạng di động
được tích hợp vào hệ thống máy chủ như máy tính xách tay.  Một trong những biện pháp giảm nhẹ
đang yêu cầu chuyển tần số VR tích hợp SOC (IVR) sang tần số
% nhỏ và loại bỏ nhiễu điều hòa tiếng ồn chuyển mạch từ
các kênh phát thanh.  OEM hoặc ODM có thể sử dụng trình điều khiển để điều khiển SOC IVR
hoạt động trong phạm vi không ảnh hưởng đến hiệu suất của IVR.

Một số sản phẩm sử dụng DLVR thay vì FIVR làm bộ điều chỉnh điện áp chuyển mạch.
Trong trường hợp này, các thuộc tính của DLVR phải được điều chỉnh thay vì FIVR.

Trong khi thay đổi tần số, tiếng ồn đồng hồ bổ sung có thể được tạo ra,
được bù đắp bằng cách điều chỉnh phần trăm trải phổ. Điều này giúp
để giảm tiếng ồn đồng hồ nhằm đáp ứng sự tuân thủ quy định. Sự lan rộng này
% tăng băng thông truyền tín hiệu và do đó làm giảm
ảnh hưởng của nhiễu, nhiễu và suy giảm tín hiệu.

Các thiết bị DRAM của giao diện DDR IO và mặt phẳng nguồn của chúng có thể tạo ra EMI
ở tốc độ dữ liệu. Tương tự như cơ chế điều khiển IVR, Intel cung cấp
cơ chế mà tốc độ dữ liệu DDR có thể được thay đổi nếu một số điều kiện
được đáp ứng: có nhiễu RFI mạnh do DDR; Nguồn CPU
quản lý không có hạn chế nào khác trong việc thay đổi tốc độ dữ liệu DDR;
PC ODM kích hoạt tính năng này (Giảm nhẹ DDR RFI theo thời gian thực được gọi là
DDR-RFIM) cho Wi-Fi từ BIOS.


Thuộc tính FIVR

ZZ0000ZZ

ZZ0000ZZ (RW)
	Mã tham chiếu VCO là trường 11 bit và điều khiển FIVR
	tần số chuyển mạch. Đây là trường LSB 3 bit.

ZZ0000ZZ (RW)
	Mã tham chiếu VCO là trường 11 bit và điều khiển FIVR
	tần số chuyển mạch. Đây là trường MSB 8 bit.

ZZ0000ZZ (RW)
	Đặt phần trăm xung nhịp trải phổ FIVR

ZZ0000ZZ (RW)
	Bật/tắt tính năng xung nhịp trải phổ FIVR

ZZ0000ZZ (RW)
	Trường này là một thanh ghi trạng thái chỉ đọc phản ánh
	tần số chuyển đổi FIVR hiện tại

ZZ0000ZZ (RW)
	Trường này cho biết bản sửa đổi của FIVR HW.


Thuộc tính DVFS

ZZ0000ZZ

ZZ0000ZZ (RW)
	Yêu cầu hạn chế tốc độ dữ liệu DDR cụ thể và đặt điều này
	giá trị 1. Tự đặt lại về 0 sau khi hoạt động.

ZZ0000ZZ (RW)
	0 :Yêu cầu được chấp nhận, 1:Tính năng bị tắt,
	2: yêu cầu hạn chế nhiều điểm hơn mức cho phép

ZZ0000ZZ (RW)
	Tốc độ dữ liệu DDR bị hạn chế để bảo vệ RFI: Giới hạn dưới

ZZ0000ZZ (RW)
	Tốc độ dữ liệu DDR bị hạn chế để bảo vệ RFI: Giới hạn trên

ZZ0000ZZ (RO)
	Lựa chọn tốc độ dữ liệu DDR điểm đầu tiên

ZZ0000ZZ (RO)
	Lựa chọn tốc độ dữ liệu DDR điểm thứ 2

ZZ0000ZZ (RO)
	Lựa chọn tốc độ dữ liệu DDR điểm thứ 3

ZZ0000ZZ (RO)
	Lựa chọn tốc độ dữ liệu DDR điểm thứ 4

ZZ0000ZZ
	Tắt tính năng thay đổi tỷ giá DDR

Thuộc tính DLVR

ZZ0000ZZ

ZZ0000ZZ (RO)
	Bản sửa đổi phần cứng DLVR.

ZZ0000ZZ (RO)
	Tần số DLVR PLL hiện tại tính bằng MHz.

ZZ0000ZZ (RW)
	Đặt tần số xung nhịp DLVR PLL. Sau khi được đặt và bật qua
	dlvr_rfim_enable, dlvr_freq_mhz sẽ hiển thị hiện tại
	Tần số DLVR PLL.

ZZ0000ZZ (RO)
	PLL không thể chấp nhận thay đổi tần số khi được đặt.

ZZ0000ZZ (RW)
	0: Tắt nhảy tần RF, 1: Bật nhảy tần RF.

ZZ0000ZZ (RW)
	Đặt giá trị phần trăm trải phổ DLVR.

ZZ0000ZZ (RW)
        Chỉ định cách trải rộng tần số bằng cách sử dụng trải phổ.
        0: Chênh lệch giảm,
        1: Trải rộng ở trung tâm.

ZZ0000ZZ (RW)
    1: việc ghi trong tương lai bị bỏ qua.

DPTF Nguồn điện và giao diện pin
----------------------------------------

Tham khảo Tài liệu/ABI/testing/sysfs-platform-dptf

Điều khiển quạt DPTF
----------------------------------------

Tham khảo Tài liệu/admin-guide/acpi/fan_performance_states.rst

Gợi ý loại khối lượng công việc
----------------------------------------

Phần sụn trong thế hệ bộ xử lý Meteor Lake có khả năng xác định
loại khối lượng công việc và chuyển các gợi ý liên quan đến nó tới hệ điều hành. Một sysf đặc biệt
giao diện được cung cấp để cho phép không gian người dùng nhận được gợi ý về loại khối lượng công việc từ
phần sụn và kiểm soát tốc độ chúng được cung cấp.

Không gian người dùng có thể thăm dò thuộc tính "workload_type_index" cho gợi ý hiện tại hoặc
có thể nhận được thông báo bất cứ khi nào giá trị của thuộc tính này được cập nhật.

tập tin:ZZ0000ZZ
Segment 0, bus 0, thiết bị 4, chức năng 0 được dành riêng cho bộ xử lý nhiệt
thiết bị trên tất cả các bộ xử lý máy khách Intel. Vì vậy, đường dẫn trên không thay đổi
dựa trên thế hệ bộ xử lý.

ZZ0000ZZ (RW)
	Kích hoạt chương trình cơ sở để gửi gợi ý về loại khối lượng công việc tới không gian người dùng.

ZZ0000ZZ (RW)
	Kích hoạt chương trình cơ sở để gửi gợi ý về loại khối lượng công việc chậm tới không gian người dùng.

ZZ0000ZZ (RW)
	Độ trễ tối thiểu tính bằng mili giây trước khi chương trình cơ sở thông báo cho hệ điều hành. Đây là
	để kiểm soát tỷ lệ thông báo. Độ trễ này là giữa việc thay đổi
	dự đoán loại khối lượng công việc trong chương trình cơ sở và thông báo cho HĐH về
	sự thay đổi. Độ trễ mặc định là 1024 ms. Độ trễ bằng 0 là không hợp lệ.
	Độ trễ được làm tròn lên lũy thừa gần nhất là 2 để đơn giản hóa phần sụn
	lập trình giá trị độ trễ. Việc đọc notification_delay_ms
	thuộc tính hiển thị giá trị hiệu quả được sử dụng.

ZZ0000ZZ (RO)
	Chỉ số loại khối lượng công việc dự đoán. Không gian người dùng có thể nhận được thông báo về
	thay đổi thông qua cơ chế thông báo thay đổi thuộc tính sysfs hiện có.

Các giá trị chỉ số được hỗ trợ và ý nghĩa của chúng đối với Hồ Sao Băng
	thế hệ vi xử lý như sau:

0 - Không hoạt động: Hệ thống không thực hiện nhiệm vụ nào, nguồn điện và trạng thái không hoạt động bị ngắt
		luôn ở mức thấp trong thời gian dài.

1 – Tuổi thọ pin: Nguồn điện tương đối thấp nhưng bộ xử lý có thể
		vẫn đang tích cực thực hiện một nhiệm vụ, chẳng hạn như phát lại video cho
		một thời gian dài.

2 – Sustained: Mức công suất tương đối cao trong thời gian dài
		thời gian, với rất ít hoặc không có khoảng thời gian nhàn rỗi, điều này sẽ
		cuối cùng cạn kiệt Giới hạn sức mạnh RAPL 1 và 2.

3 – Bursty: Tiêu tốn một lượng điện năng trung bình tương đối ổn định, nhưng
		khoảng thời gian nhàn rỗi tương đối bị gián đoạn bởi sự bùng nổ của
		hoạt động. Các đợt bùng phát tương đối ngắn và thời gian
		sự nhàn rỗi tương đối giữa chúng thường ngăn cản RAPL Power
		Giới hạn 1 khỏi bị kiệt sức.

4 – Unknown: Không thể phân loại.

Trên các bộ xử lý bắt đầu từ Panther Lake, các gợi ý bổ sung được cung cấp.
	Phần cứng phân tích khối lượng công việc cư trú trong một khoảng thời gian dài để
	xác định xem phân loại khối lượng công việc có xu hướng nhàn rỗi/pin
	trạng thái cuộc sống hoặc trạng thái hiệu suất/được duy trì. Dựa trên điều này lâu dài
	phân tích, nó phân loại:

Phân loại nguồn điện: Nếu khối lượng công việc cho thấy thời gian rảnh rỗi hoặc pin nhiều hơn
	nơi cư trú thì nó được xếp vào loại “quyền lực”.

Phân loại hiệu suất: Nếu khối lượng công việc được duy trì lâu hơn hoặc
	cư trú hiệu suất, nó được phân loại là "hiệu suất".

Cách tiếp cận này cho phép các ứng dụng bỏ qua khối lượng công việc ngắn hạn
	biến động và thay vào đó phản ứng với sức mạnh dài hạn hơn so với hiệu suất
	xu hướng.

Ngưỡng cư trú cho phân loại này là dành riêng cho thế hệ CPU.
	Việc phân loại được báo cáo qua bit 4 của khối lượng công việc_type_index:

Bit 4 = 1: Phân loại nguồn điện

Bit 4 = 0: Phân loại hiệu suất