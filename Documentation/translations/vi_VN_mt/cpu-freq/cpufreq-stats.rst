.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/cpu-freq/cpufreq-stats.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================================
Mô tả chung về thống kê CPUFreq của sysfs
==============================================

thông tin cho người dùng


Tác giả: Venkatesh Pallipadi <venkatesh.pallipadi@intel.com>

.. Contents

   1. Introduction
   2. Statistics Provided (with example)
   3. Configuring cpufreq-stats


1. Giới thiệu
===============

cpufreq-stats là trình điều khiển cung cấp số liệu thống kê tần số CPU cho mỗi CPU.
Các số liệu thống kê này được cung cấp trong /sysfs dưới dạng một loạt giao diện chỉ đọc. Cái này
giao diện (khi được định cấu hình) sẽ xuất hiện trong một thư mục riêng dưới cpufreq
trong /sysfs (<sysfs root>/devices/system/cpu/cpuX/cpufreq/stats/) cho mỗi CPU.
Các số liệu thống kê khác nhau sẽ tạo thành các tệp chỉ đọc trong thư mục này.

Trình điều khiển này được thiết kế độc lập với bất kỳ cpufreq_driver cụ thể nào
có thể đang chạy trên CPU của bạn. Vì vậy, nó sẽ hoạt động với mọi cpufreq_driver.


2. Thống kê được cung cấp (có ví dụ)
=====================================

số liệu thống kê cpufreq cung cấp số liệu thống kê sau (được giải thích chi tiết bên dưới).

- thời gian_in_state
- tổng_trans
- bảng dịch

Tất cả số liệu thống kê sẽ có từ thời điểm trình điều khiển thống kê được chèn
(hoặc thời điểm số liệu thống kê được đặt lại) cho đến thời điểm đọc một thông số cụ thể
thống kê được thực hiện. Rõ ràng, trình điều khiển thống kê sẽ không có bất kỳ thông tin nào
về sự chuyển đổi tần số trước khi chèn trình điều khiển thống kê.

::

<mysystem>:/sys/devices/system/cpu/cpu0/cpufreq/stats # ls -l
    tổng 0
    drwxr-xr-x 2 gốc gốc 0 14 tháng 5 16:06 .
    drwxr-xr-x 3 gốc gốc 0 14 tháng 5 15:58 ..
    --w------- 1 root gốc 4096 14 tháng 5 16:06 đặt lại
    -r--r--r-- 1 gốc 4096 Ngày 14 tháng 5 16:06 time_in_state
    -r--r--r-- 1 gốc 4096 Ngày 14 tháng 5 16:06 tổng_trans
    -r--r--r-- 1 gốc 4096 Ngày 14 tháng 5 16:06 trans_table

-ZZ0000ZZ

Thuộc tính chỉ ghi có thể được sử dụng để đặt lại bộ đếm chỉ số. Đây có thể là
hữu ích cho việc đánh giá hành vi của hệ thống dưới các bộ điều chỉnh khác nhau mà không cần
cần khởi động lại.

-ZZ0000ZZ

Điều này cho biết lượng thời gian dành cho mỗi tần số được hỗ trợ bởi
chiếc CPU này. Đầu ra cat sẽ có cặp "<tần số> <thời gian>" trên mỗi dòng.
có nghĩa là CPU này đã sử dụng <thời gian> đơn vị thời gian của người dùng ở <tần số>. đầu ra
sẽ có một dòng cho mỗi tần số được hỗ trợ. đơn vị thời gian người dùng ở đây
là 10mS (tương tự như thời gian khác được xuất trong /proc).

::

<mysystem>:/sys/devices/system/cpu/cpu0/cpufreq/stats # cat time_in_state
    3600000 2089
    3400000 136
    3200000 34
    3000000 67
    2800000 172488


-ZZ0000ZZ

Điều này cung cấp tổng số lần chuyển đổi tần số trên CPU này. Con mèo
đầu ra sẽ có một số đếm duy nhất là tổng số tần số
chuyển tiếp.

::

<mysystem>:/sys/devices/system/cpu/cpu0/cpufreq/stats # cat Total_trans
    20

-ZZ0000ZZ

Điều này sẽ cung cấp thông tin chi tiết về tất cả tần số CPU
chuyển tiếp. Đầu ra của cat ở đây là một ma trận hai chiều, trong đó một mục
<i,j> (hàng i, cột j) thể hiện số lần chuyển đổi từ
Tần số_i đến tần số_j. Các hàng Freq_i và các cột Freq_j tuân theo thứ tự sắp xếp trong
mà trình điều khiển đã cung cấp bảng tần số ban đầu cho lõi cpufreq
và do đó có thể được sắp xếp (tăng dần hoặc giảm dần) hoặc không được sắp xếp.  Đầu ra ở đây
cũng chứa các giá trị tần số thực tế cho mỗi hàng và cột để tốt hơn
khả năng đọc.

Nếu bảng chuyển đổi lớn hơn PAGE_SIZE, việc đọc phần này sẽ
trả về lỗi -EFBIG.

::

<mysystem>:/sys/devices/system/cpu/cpu0/cpufreq/stats # cat trans_table
    Từ: Đến
	    : 3600000 3400000 3200000 3000000 2800000
    3600000: 0 5 0 0 0
    3400000: 4 0 2 0 0
    3200000: 0 1 0 2 0
    3000000: 0 0 1 0 3
    2800000: 0 0 0 2 0

3. Cấu hình cpufreq-stats
============================

Để định cấu hình số liệu thống kê cpufreq trong kernel của bạn ::

Menu chính cấu hình
		Tùy chọn quản lý nguồn (ACPI, APM) --->
			CPU Thang đo tần số --->
				[*] CPU Thang đo tần số
				[*] Thống kê dịch tần số CPU


"CPU Tần số chia tỷ lệ" (CONFIG_CPU_FREQ) phải được bật để định cấu hình
số liệu thống kê cpufreq.

"Thống kê dịch tần số CPU" (CONFIG_CPU_FREQ_STAT) cung cấp
số liệu thống kê bao gồm time_in_state, Total_trans và trans_table.

Khi tùy chọn này được bật và CPU của bạn hỗ trợ tần số cpu, bạn
sẽ có thể xem số liệu thống kê tần số CPU trong /sysfs.