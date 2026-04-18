.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/locking/locktorture.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================================
Hoạt động thử nghiệm tra tấn khóa hạt nhân
==================================

CONFIG_LOCK_TORTURE_TEST
========================

Tùy chọn cấu hình CONFIG_LOCK_TORTURE_TEST cung cấp mô-đun hạt nhân
chạy các thử nghiệm tra tấn trên các nguyên thủy khóa kernel lõi. Hạt nhân
mô-đun, 'locktorture', có thể được xây dựng sau khi thực tế đang chạy
kernel để được kiểm tra, nếu muốn. Các bài kiểm tra trạng thái đầu ra định kỳ
tin nhắn qua printk(), có thể được kiểm tra qua dmesg (có lẽ
đang tìm cách "tra tấn").  Quá trình kiểm tra được bắt đầu khi mô-đun được tải,
và dừng lại khi mô-đun được dỡ tải. Chương trình này dựa trên cách RCU
bị tra tấn, thông qua tra tấn.

Thử nghiệm tra tấn này bao gồm việc tạo ra một số luồng nhân
lấy khóa và giữ nó trong một khoảng thời gian cụ thể, từ đó mô phỏng
hành vi khu vực quan trọng khác nhau. Số lượng tranh chấp về khóa
có thể được mô phỏng bằng cách mở rộng thời gian giữ vùng tới hạn này và/hoặc
tạo thêm kthreads.


Thông số mô-đun
=================

Mô-đun này có các tham số sau:


Khóa cụ thể
--------------------

nwriters_stress
		  Số lượng luồng nhân sẽ nhấn mạnh đến khóa độc quyền
		  quyền sở hữu (người viết). Giá trị mặc định là gấp đôi số
		  của CPU trực tuyến.

nreaders_stress
		  Số lượng luồng nhân sẽ nhấn mạnh khóa chia sẻ
		  quyền sở hữu (người đọc). Mặc định là số lượng người viết như nhau
		  ổ khóa. Nếu người dùng không chỉ định nwriters_stress thì
		  cả người đọc và người viết đều là số lượng CPU trực tuyến.

kiểu tra tấn
		  Loại khóa để tra tấn. Theo mặc định, chỉ có spinlocks mới
		  bị hành hạ. Mô-đun này có thể tra tấn các ổ khóa sau,
		  với các giá trị chuỗi như sau:

- "lock_busted":
				Mô phỏng việc thực hiện khóa lỗi.

- "spin_lock":
				cặp spin_lock() và spin_unlock().

- "spin_lock_irq":
				cặp spin_lock_irq() và spin_unlock_irq().

- "rw_lock":
				cặp rwlock đọc/ghi lock() và unlock().

- "rw_lock_irq":
				đọc/ghi lock_irq() và unlock_irq()
				cặp rwlock.

- "mutex_lock":
				cặp mutex_lock() và mutex_unlock().

- "rtmutex_lock":
				cặp rtmutex_lock() và rtmutex_unlock().
				Hạt nhân phải có CONFIG_RT_MUTEXES=y.

- "rwsem_lock":
				cặp semaphore đọc/ghi xuống() và lên().


Khung tra tấn (RCU + khóa)
---------------------------------

tắt máy_giây
		  Số giây chạy thử nghiệm trước khi kết thúc
		  kiểm tra và tắt nguồn hệ thống.  Mặc định là
		  bằng 0, điều này vô hiệu hóa việc chấm dứt kiểm tra và tắt hệ thống.
		  Khả năng này rất hữu ích cho việc kiểm tra tự động.

onoff_interval
		  Số giây giữa mỗi lần thử thực hiện một
		  hoạt động cắm nóng CPU được chọn ngẫu nhiên.  Mặc định
		  về 0, điều này sẽ vô hiệu hóa tính năng cắm nóng CPU.  trong
		  CONFIG_HOTPLUG_CPU=n hạt nhân, khóa tra tấn sẽ âm thầm
		  từ chối thực hiện bất kỳ thao tác CPU-hotplug nào bất kể
		  giá trị nào được chỉ định cho onoff_interval.

onoff_holdoff
		  Số giây chờ cho đến khi khởi động CPU-hotplug
		  hoạt động.  Điều này thường chỉ được sử dụng khi
		  locktorture đã được tích hợp vào kernel và bắt đầu
		  tự động khi khởi động, trong trường hợp này nó rất hữu ích
		  để tránh nhầm lẫn mã thời gian khởi động với CPU
		  đến và đi. Tham số này chỉ hữu ích nếu
		  CONFIG_HOTPLUG_CPU được kích hoạt.

stat_interval
		  Số giây giữa các printk() liên quan đến thống kê.
		  Theo mặc định, locktorture sẽ báo cáo số liệu thống kê cứ sau 60 giây.
		  Việc đặt khoảng thời gian thành 0 sẽ làm cho số liệu thống kê
		  được in -chỉ- khi mô-đun được dỡ xuống.

nói lắp
		  Khoảng thời gian để chạy thử nghiệm trước khi tạm dừng việc này
		  cùng một khoảng thời gian.  Mặc định là "nói lắp = 5", vì vậy
		  để chạy và tạm dừng trong khoảng thời gian (khoảng) năm giây.
		  Chỉ định "stutter=0" khiến bài kiểm tra chạy liên tục
		  không ngừng nghỉ.

xáo trộn_interval
		  Số giây để giữ cho các luồng thử nghiệm được liên kết
		  đối với một tập hợp con cụ thể của CPU, mặc định là 3 giây.
		  Được sử dụng cùng với test_no_idle_hz.

dài dòng
		  Cho phép in gỡ lỗi chi tiết, thông qua printk(). Đã bật
		  theo mặc định. Thông tin bổ sung này chủ yếu liên quan đến
		  lỗi cấp cao và báo cáo từ 'sự tra tấn' chính
		  khuôn khổ.


Thống kê
==========

Thống kê được in theo định dạng sau::

spin_lock-torture: Ghi: Tổng cộng: 93746064 Tối đa/Tối thiểu: 0/0 Thất bại: 0
     (A) (B) (C) (D) (E)

(A): Loại khóa đang bị tra tấn - tham số Tort_type.

(B): Số lần mua lại khóa nhà văn. Nếu xử lý việc đọc/ghi
       nguyên thủy, dòng thống kê "Đọc" thứ hai được in.

(C): Số lần khóa được lấy.

(D): Số lần tối thiểu và tối đa các luồng không lấy được khóa.

(E): giá trị đúng/sai nếu có lỗi khi lấy khóa. Điều này nên
       -chỉ- tích cực nếu có lỗi trong khóa nguyên thủy
       thực hiện. Nếu không, khóa sẽ không bao giờ bị lỗi (tức là spin_lock()).
       Tất nhiên, điều tương tự cũng áp dụng cho (C) ở trên. Một ví dụ giả về điều này là
       loại "lock_busted".

Cách sử dụng
=====

Đoạn script sau có thể được sử dụng để tra tấn ổ khóa::

#!/bin/sh

tra tấn khóa modprobe
	ngủ 3600
	sự tra tấn khóa rmmod
	dmesg | tra tấn grep:

Đầu ra có thể được kiểm tra thủ công để tìm cờ lỗi "!!!".
Tất nhiên người ta có thể tạo ra một tập lệnh phức tạp hơn để tự động
đã kiểm tra các lỗi như vậy.  Lệnh "rmmod" buộc "SUCCESS",
Chỉ báo "FAILURE" hoặc "RCU_HOTPLUG" sẽ được printk()ed.  đầu tiên
hai là tự giải thích, trong khi cái cuối cùng chỉ ra rằng mặc dù có
không có lỗi khóa, đã phát hiện sự cố CPU-hotplug.

Xem thêm: Documentation/RCU/torture.rst
