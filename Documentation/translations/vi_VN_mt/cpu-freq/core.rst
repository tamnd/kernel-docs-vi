.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/cpu-freq/core.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================================================================
Mô tả chung về lõi CPUFreq và bộ thông báo CPUFreq
===================================================================

tác giả:
	- Dominik Brodowski <linux@brodo.de>
	- David Kimdon <dwhedon@debian.org>
	- Rafael J. Wysocki <rafael.j.wysocki@intel.com>
	- Viresh Kumar <viresh.kumar@linaro.org>

.. Contents:

   1.  CPUFreq core and interfaces
   2.  CPUFreq notifiers
   3.  CPUFreq Table Generation with Operating Performance Point (OPP)

1. Thông tin chung
======================

Mã lõi CPUFreq nằm trong driver/cpufreq/cpufreq.c. Cái này
Mã cpufreq cung cấp giao diện được tiêu chuẩn hóa cho CPUFreq
trình điều khiển kiến trúc (những đoạn mã thực hiện
chuyển đổi tần số), cũng như "bộ thông báo". Đây là những thiết bị
trình điều khiển hoặc phần khác của kernel cần được thông báo
thay đổi chính sách (ví dụ: mô-đun nhiệt như ACPI) hoặc tất cả
thay đổi tần số (ví dụ: mã thời gian) hoặc thậm chí cần phải ép buộc một số
giới hạn tốc độ (như trình điều khiển LCD trên kiến trúc ARM). Ngoài ra,
kernel "không đổi" loops_per_jiffy được cập nhật khi thay đổi tần số
ở đây.

Việc đếm tham chiếu các chính sách cpufreq được thực hiện bởi cpufreq_cpu_get
và cpufreq_cpu_put, đảm bảo rằng trình điều khiển cpufreq được
được đăng ký chính xác với lõi và sẽ không được tải cho đến khi
cpufreq_put_cpu được gọi. Điều đó cũng đảm bảo rằng cpufreq tương ứng
chính sách không được giải phóng trong khi đang được sử dụng.

2. Trình thông báo CPUFreq
==========================

Trình thông báo CPUFreq tuân theo giao diện trình thông báo kernel tiêu chuẩn.
Xem linux/include/linux/notifier.h để biết chi tiết về trình thông báo.

Có hai trình thông báo CPUFreq khác nhau - trình thông báo chính sách và
thông báo chuyển tiếp.


2.1 Trình thông báo chính sách CPUFreq
--------------------------------------

Chúng được thông báo khi một chính sách mới được tạo hoặc xóa.

Giai đoạn được chỉ định trong đối số thứ hai cho trình thông báo.  Giai đoạn là
CPUFREQ_CREATE_POLICY khi chính sách được tạo lần đầu tiên và nó được
CPUFREQ_REMOVE_POLICY khi chính sách bị xóa.

Đối số thứ ba, ZZ0000ZZ, trỏ đến cấu trúc cpufreq_policy
bao gồm một số giá trị, bao gồm min, max (dưới và trên
tần số (tính bằng kHz) của chính sách mới).


2.2 Thông báo chuyển tiếp CPUFreq
---------------------------------

Chúng được thông báo hai lần cho mỗi CPU trực tuyến trong chính sách, khi
Trình điều khiển CPUfreq chuyển đổi tần số lõi CPU và thay đổi này không có
bất kỳ tác động bên ngoài nào.

Đối số thứ hai chỉ định pha - CPUFREQ_PRECHANGE hoặc
CPUFREQ_POSTCHANGE.

Đối số thứ ba là cấu trúc cpufreq_freqs với nội dung sau
giá trị:

====== ==========================================
chính sách một con trỏ tới cấu trúc cpufreq_policy
tần số cũ
tần số mới mới
cờ cờ của trình điều khiển cpufreq
====== ==========================================

3. Tạo bảng CPUFreq với Điểm hiệu suất vận hành (OPP)
==================================================================
Để biết chi tiết về OPP, hãy xem Tài liệu/power/opp.rst

dev_pm_opp_init_cpufreq_table -
	Chức năng này cung cấp một quy trình chuyển đổi sẵn sàng sử dụng để dịch
	thông tin nội bộ của lớp OPP về các tần số khả dụng
	sang định dạng sẵn sàng cung cấp cho cpufreq.

	.. Warning::

	   Do not use this function in interrupt context.

Ví dụ::

soc_pm_init()
	 {
		/*Làm những việc*/
		r = dev_pm_opp_init_cpufreq_table(dev, &freq_table);
		nếu (!r)
			chính sách->freq_table = freq_table;
		/*Làm việc khác*/
	 }

	.. note::

	   This function is available only if CONFIG_CPU_FREQ is enabled in
	   addition to CONFIG_PM_OPP.

dev_pm_opp_free_cpufreq_table
	Giải phóng bảng được phân bổ bởi dev_pm_opp_init_cpufreq_table