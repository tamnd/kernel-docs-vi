.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/cpu-freq/cpu-drivers.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================================
Cách triển khai trình điều khiển bộ xử lý CPUFreq mới
===============================================

tác giả:


- Dominik Brodowski <linux@brodo.de>
	- Rafael J. Wysocki <rafael.j.wysocki@intel.com>
	- Viresh Kumar <viresh.kumar@linaro.org>

.. Contents

   1.   What To Do?
   1.1  Initialization
   1.2  Per-CPU Initialization
   1.3  verify
   1.4  target/target_index or setpolicy?
   1.5  target/target_index
   1.6  setpolicy
   1.7  get_intermediate and target_intermediate
   2.   Frequency Table Helpers



1. Phải làm gì?
==============

Vì vậy, bạn vừa có một CPU / chipset hoàn toàn mới với bảng dữ liệu và muốn
thêm hỗ trợ cpufreq cho CPU/chipset này? Tuyệt vời. Dưới đây là một số gợi ý
về những gì cần thiết:


1.1 Khởi tạo
------------------

Trước hết, ở __initcall cấp 7 (module_init()) trở lên
chức năng kiểm tra xem kernel này có chạy trên CPU bên phải và bên phải không
chipset. Nếu vậy, hãy đăng ký struct cpufreq_driver với lõi CPUfreq
sử dụng cpufreq_register_driver()

Cấu trúc cpufreq_driver này sẽ chứa gì?

.name - Tên của trình điều khiển này.

.init - Một con trỏ tới hàm khởi tạo theo chính sách.

.verify - Con trỏ tới hàm "xác minh".

.setpolicy _or_ .fast_switch _or_ .target _or_ .target_index - Xem
 dưới đây về sự khác biệt.

Và tùy chọn

.flags - Gợi ý về lõi cpufreq.

.driver_data - dữ liệu cụ thể của trình điều khiển cpufreq.

.get_intermediate và target_intermediate - Dùng để chuyển sang ổn định
 tần số trong khi thay đổi tần số CPU.

.get - Trả về tần số hiện tại của CPU.

.bios_limit - Trả về giới hạn tần số tối đa HW/BIOS cho CPU.

.exit - Một con trỏ tới hàm dọn dẹp theo chính sách được gọi trong khi
 Giai đoạn CPU_POST_DEAD của quá trình cắm nóng CPU.

.suspend - Một con trỏ tới hàm tạm dừng theo chính sách được gọi
 với các ngắt bị vô hiệu hóa và _after_ bộ điều tốc bị dừng trong
 chính sách.

.resume - Một con trỏ tới hàm tiếp tục theo chính sách được gọi
 với các ngắt bị vô hiệu hóa và _trước_ bộ điều tốc được khởi động lại.

.ready - Một con trỏ tới hàm sẵn sàng cho mỗi chính sách được gọi sau
 chính sách được khởi tạo đầy đủ.

.attr - Một con trỏ tới danh sách "struct freq_attr" được kết thúc bằng NULL.
 cho phép xuất giá trị sang sysfs.

.boost_enabled - Nếu được đặt, tần số tăng cường sẽ được bật.

.set_boost - Con trỏ tới hàm theo chính sách để bật/tắt tăng cường
 tần số.


1.2 Khởi tạo Per-CPU
--------------------------

Bất cứ khi nào CPU mới được đăng ký với kiểu thiết bị hoặc sau
Trình điều khiển cpufreq tự đăng ký, hàm khởi tạo cho mỗi chính sách
cpufreq_driver.init được gọi nếu không có chính sách cpufreq nào tồn tại cho CPU.
Lưu ý rằng các thường trình .init() và .exit() chỉ được gọi một lần cho
chính sách chứ không phải cho mỗi CPU được chính sách quản lý. Nó lấy ZZ0000ZZ làm đối số. Phải làm gì bây giờ?

Nếu cần, hãy kích hoạt hỗ trợ CPUfreq trên CPU của bạn.

Sau đó, trình điều khiển phải điền vào các giá trị sau:

+-----------------------------------+--------------------------------------+
ZZ0000ZZ |
ZZ0001ZZ tần số tối thiểu và tối đa |
ZZ0002ZZ (tính bằng kHz) được hỗ trợ bởi |
ZZ0003ZZ CPU này |
+-----------------------------------+--------------------------------------+
ZZ0004ZZ thời gian cần thiết trên CPU này để |
ZZ0005ZZ chuyển đổi giữa hai tần số trong |
ZZ0006ZZ nano giây |
+-----------------------------------+--------------------------------------+
ZZ0007ZZ Tần số hoạt động hiện tại của |
ZZ0008ZZ CPU này (nếu thích hợp) |
+-----------------------------------+--------------------------------------+
ZZ0009ZZ |
ZZ0010ZZ |
ZZ0011ZZ |
ZZ0012ZZ phải chứa "chính sách mặc định" cho|
ZZ0013ZZ CPU này. Một lúc sau, |
ZZ0014ZZ cpufreq_driver.verify và |
ZZ0015ZZ cpufreq_driver.setpolicy hoặc |
ZZ0016ZZ cpufreq_driver.target/target_index là|
ZZ0017ZZ được gọi với các giá trị này.		   |
+-----------------------------------+--------------------------------------+
ZZ0018ZZ Cập nhật phần này với các mặt nạ của |
CPU ZZ0019ZZ (trực tuyến + ngoại tuyến) làm DVFS |
ZZ0020ZZ cùng với CPU này (tức là chia sẻ|
Đồng hồ / đường ray điện áp ZZ0021ZZ với nó).	   |
+-----------------------------------+--------------------------------------+

Để đặt một số giá trị này (cpuinfo.min[max]_freq, Policy->min[max]),
người trợ giúp bảng tần số có thể hữu ích. Xem phần 2 để biết thêm thông tin
trên chúng.


1.3 xác minh
----------

Khi người dùng quyết định một chính sách mới (bao gồm
"policy,governor,min,max") sẽ được đặt, chính sách này phải được xác thực
để có thể sửa các giá trị không tương thích. Để xác minh những điều này
giá trị cpufreq_verify_within_limits(ZZ0000ZZ,
ZZ0001ZZ, ZZ0002ZZ) có thể hữu ích.
Xem phần 2 để biết chi tiết về trợ giúp bảng tần số.

Bạn cần đảm bảo rằng ít nhất một tần số hợp lệ (hoặc tần số hoạt động
phạm vi) nằm trong chính sách->tối thiểu và chính sách->tối đa. Nếu cần thiết hãy tăng
chính sách->tối đa trước và chỉ khi đây không phải là giải pháp, hãy giảm chính sách->tối thiểu.


1.4 mục tiêu hoặc target_index hoặc setpolicy hoặc fast_switch?
-------------------------------------------------------

Hầu hết các trình điều khiển cpufreq hoặc thậm chí hầu hết các thuật toán mở rộng tần số cpu
chỉ cho phép tần số CPU được đặt thành các giá trị cố định được xác định trước. cho
này, bạn sử dụng ->target(), ->target_index() hoặc ->fast_switch()
cuộc gọi lại.

Một số bộ xử lý có khả năng cpufreq chuyển đổi tần số giữa các
giới hạn của riêng mình. Chúng sẽ sử dụng lệnh gọi lại ->setpolicy().


1.5. mục tiêu/target_index
------------------------

Lệnh gọi target_index có hai đối số: ZZ0000ZZ,
và chỉ số ZZ0001ZZ (vào bảng tần số tiếp xúc).

Trình điều khiển CPUfreq phải đặt tần số mới khi được gọi ở đây. các
tần số thực tế phải được xác định bởi freq_table[index].tần số.

Nó phải luôn khôi phục về tần số trước đó (tức là chính sách->restore_freq) trong
trường hợp có lỗi, ngay cả khi chúng tôi đã chuyển sang tần số trung gian trước đó.

Không được dùng nữa
----------
Cuộc gọi mục tiêu có ba đối số: ZZ0000ZZ,
tần số mục tiêu int không dấu, quan hệ int không dấu.

Trình điều khiển CPUfreq phải đặt tần số mới khi được gọi ở đây. các
tần số thực tế phải được xác định bằng cách sử dụng các quy tắc sau:

- theo sát "target_freq"
- chính sách->min <= new_freq <= chính sách->max (THIS MUST BE VALID!!!)
- nếu quan hệ==CPUFREQ_REL_L, hãy thử chọn new_freq cao hơn hoặc bằng
  target_freq. ("L là thấp nhất nhưng không thấp hơn")
- nếu quan hệ==CPUFREQ_REL_H, hãy thử chọn new_freq thấp hơn hoặc bằng
  target_freq. ("H là cao nhất nhưng không cao hơn")

Ở đây một lần nữa người trợ giúp bảng tần số có thể hỗ trợ bạn - xem phần 2
để biết chi tiết.

1.6. fast_switch
----------------

Chức năng này được sử dụng để chuyển tần số từ ngữ cảnh của bộ lập lịch.
Không phải tất cả các tài xế đều phải thực hiện nó, vì ngủ từ bên trong
cuộc gọi lại này không được phép. Cuộc gọi lại này phải được tối ưu hóa cao để
thực hiện chuyển đổi càng nhanh càng tốt.

Hàm này có hai đối số: ZZ0000ZZ và
ZZ0001ZZ.


1.7 chính sách thiết lập
-------------

Lệnh gọi setpolicy chỉ nhận ZZ0000ZZ làm
lý lẽ. Bạn cần đặt giới hạn dưới của bộ xử lý trong hoặc
chuyển đổi tần số động trong chipset sang chính sách->min, giới hạn trên
tới chính sách->tối đa và -nếu được hỗ trợ- chọn định hướng hiệu suất
cài đặt khi chính sách->chính sách là CPUFREQ_POLICY_PERFORMANCE và
cài đặt hướng tới tiết kiệm năng lượng khi CPUFREQ_POLICY_POWERSAVE. Đồng thời kiểm tra
việc triển khai tham chiếu trong driver/cpufreq/longrun.c

1.8 get_intermediate và target_intermediate
--------------------------------------------

Chỉ dành cho trình điều khiển chưa đặt target_index() và CPUFREQ_ASYNC_NOTIFICATION.

get_intermediate sẽ trả về nền tảng tần số trung gian ổn định muốn
chuyển sang và target_intermediate() nên đặt CPU ở tần số đó trước khi
nhảy đến tần số tương ứng với 'chỉ số'. Core sẽ chăm sóc
gửi thông báo và trình điều khiển không phải xử lý chúng
target_intermediate() hoặc target_index().

Trình điều khiển có thể trả về '0' từ get_intermediate() trong trường hợp họ không muốn chuyển đổi
đến tần số trung gian cho một số tần số mục tiêu. Trong trường hợp đó cốt lõi sẽ
gọi trực tiếp ->target_index().

NOTE: ->target_index() nên khôi phục về chính sách->restore_freq trong trường hợp
lỗi vì lõi sẽ gửi thông báo về điều đó.


2. Người trợ giúp bảng tần số
==========================

Vì hầu hết các bộ xử lý cpufreq chỉ cho phép đặt thành một số cài đặt cụ thể
tần số, một "bảng tần số" với một số chức năng có thể hỗ trợ
một số công việc của trình điều khiển bộ xử lý. Một "bảng tần số" như vậy bao gồm
một mảng các mục struct cpufreq_number_table, với trình điều khiển cụ thể
các giá trị trong "driver_data", tần số tương ứng trong "tần số" và
cờ được đặt. Ở cuối bảng, bạn cần thêm một
mục nhập cpufreq_ Frequency_table với tần số được đặt thành CPUFREQ_TABLE_END.
Và nếu bạn muốn bỏ qua một mục trong bảng, hãy đặt tần suất thành
CPUFREQ_ENTRY_INVALID. Các mục không cần phải được sắp xếp theo bất kỳ cách nào
thứ tự cụ thể, nhưng nếu chúng là lõi cpufreq thì sẽ làm DVFS một chút
nhanh chóng cho họ vì việc tìm kiếm kết quả phù hợp nhất sẽ nhanh hơn.

Bảng cpufreq được lõi tự động xác minh nếu chính sách chứa
con trỏ hợp lệ trong trường chính sách->freq_table của nó.

cpufreq_ Frequency_table_verify() đảm bảo rằng ít nhất một giá trị hợp lệ
tần suất nằm trong chính sách->tối thiểu và chính sách->tối đa và tất cả các tiêu chí khác
được đáp ứng. Điều này hữu ích cho cuộc gọi ->xác minh.

cpufreq_ Frequency_table_target() là bảng tần số tương ứng
người trợ giúp cho giai đoạn ->target. Chỉ cần chuyển các giá trị cho hàm này,
và hàm này trả về mục nhập bảng tần số
chứa tần số mà CPU sẽ được đặt thành.

Các macro sau có thể được sử dụng làm trình vòng lặp trên cpufreq_ Frequency_table:

cpufreq_for_each_entry(pos, table) - lặp lại tất cả các mục tần số
cái bàn.

cpufreq_for_each_valid_entry(pos, table) - lặp lại tất cả các mục,
không bao gồm tần số CPUFREQ_ENTRY_INVALID.
Sử dụng đối số "pos" - ZZ0000ZZ làm con trỏ vòng lặp và
"bảng" - ZZ0001ZZ bạn muốn lặp lại.

Ví dụ::

cấu trúc cpufreq_tần_table *pos, *driver_freq_table;

cpufreq_for_each_entry(pos, driver_freq_table) {
		/* Làm gì đó với pos */
		vị trí->tần số = ...
	}

Nếu bạn cần làm việc với vị trí của pos trong driver_freq_table,
đừng trừ con trỏ vì nó khá tốn kém. Thay vào đó, hãy sử dụng
macro cpufreq_for_each_entry_idx() và cpufreq_for_each_valid_entry_idx().