.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/timekeeping.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

phụ kiện ktime
===============

Trình điều khiển thiết bị có thể đọc thời gian hiện tại bằng cách sử dụng ktime_get() và nhiều
các hàm liên quan được khai báo trong linux/timekeeping.h. Theo nguyên tắc chung,
sử dụng một trình truy cập có tên ngắn hơn được ưu tiên hơn một trình truy cập có tên dài hơn
name nếu cả hai đều phù hợp như nhau cho một trường hợp sử dụng cụ thể.

Giao diện dựa trên ktime_t cơ bản
------------------------------

Biểu mẫu đơn giản nhất được đề xuất trả về một ktime_t mờ, với các biến thể
thời gian trả về cho các tham chiếu đồng hồ khác nhau:


.. c:function:: ktime_t ktime_get( void )

	CLOCK_MONOTONIC

	Useful for reliable timestamps and measuring short time intervals
	accurately. Starts at system boot time but stops during suspend.

.. c:function:: ktime_t ktime_get_boottime( void )

	CLOCK_BOOTTIME

	Like ktime_get(), but does not stop when suspended. This can be
	used e.g. for key expiration times that need to be synchronized
	with other machines across a suspend operation.

.. c:function:: ktime_t ktime_get_real( void )

	CLOCK_REALTIME

	Returns the time in relative to the UNIX epoch starting in 1970
	using the Coordinated Universal Time (UTC), same as gettimeofday()
	user space. This is used for all timestamps that need to
	persist across a reboot, like inode times, but should be avoided
	for internal uses, since it can jump backwards due to a leap
	second update, NTP adjustment settimeofday() operation from user
	space.

.. c:function:: ktime_t ktime_get_clocktai( void )

	 CLOCK_TAI

	Like ktime_get_real(), but uses the International Atomic Time (TAI)
	reference instead of UTC to avoid jumping on leap second updates.
	This is rarely useful in the kernel.

.. c:function:: ktime_t ktime_get_raw( void )

	CLOCK_MONOTONIC_RAW

	Like ktime_get(), but runs at the same rate as the hardware
	clocksource without (NTP) adjustments for clock drift. This is
	also rarely needed in the kernel.

nano giây, timespec64 và đầu ra thứ hai
-----------------------------------------

Đối với tất cả những điều trên, có những biến thể trả về thời gian theo dạng
định dạng khác nhau tùy thuộc vào những gì người dùng yêu cầu:

.. c:function:: u64 ktime_get_ns( void )
		u64 ktime_get_boottime_ns( void )
		u64 ktime_get_real_ns( void )
		u64 ktime_get_clocktai_ns( void )
		u64 ktime_get_raw_ns( void )

	Same as the plain ktime_get functions, but returning a u64 number
	of nanoseconds in the respective time reference, which may be
	more convenient for some callers.

.. c:function:: void ktime_get_ts64( struct timespec64 * )
		void ktime_get_boottime_ts64( struct timespec64 * )
		void ktime_get_real_ts64( struct timespec64 * )
		void ktime_get_clocktai_ts64( struct timespec64 * )
		void ktime_get_raw_ts64( struct timespec64 * )

	Same above, but returns the time in a 'struct timespec64', split
	into seconds and nanoseconds. This can avoid an extra division
	when printing the time, or when passing it into an external
	interface that expects a 'timespec' or 'timeval' structure.

.. c:function:: time64_t ktime_get_seconds( void )
		time64_t ktime_get_boottime_seconds( void )
		time64_t ktime_get_real_seconds( void )
		time64_t ktime_get_clocktai_seconds( void )
		time64_t ktime_get_raw_seconds( void )

	Return a coarse-grained version of the time as a scalar
	time64_t. This avoids accessing the clock hardware and rounds
	down the seconds to the full seconds of the last timer tick
	using the respective reference.

Truy cập thô và nhanh_ns
-------------------------

Một số biến thể bổ sung tồn tại cho các trường hợp chuyên biệt hơn:

.. c:function:: ktime_t ktime_get_coarse( void )
		ktime_t ktime_get_coarse_boottime( void )
		ktime_t ktime_get_coarse_real( void )
		ktime_t ktime_get_coarse_clocktai( void )

.. c:function:: u64 ktime_get_coarse_ns( void )
		u64 ktime_get_coarse_boottime_ns( void )
		u64 ktime_get_coarse_real_ns( void )
		u64 ktime_get_coarse_clocktai_ns( void )

.. c:function:: void ktime_get_coarse_ts64( struct timespec64 * )
		void ktime_get_coarse_boottime_ts64( struct timespec64 * )
		void ktime_get_coarse_real_ts64( struct timespec64 * )
		void ktime_get_coarse_clocktai_ts64( struct timespec64 * )

	These are quicker than the non-coarse versions, but less accurate,
	corresponding to CLOCK_MONOTONIC_COARSE and CLOCK_REALTIME_COARSE
	in user space, along with the equivalent boottime/tai/raw
	timebase not available in user space.

	The time returned here corresponds to the last timer tick, which
	may be as much as 10ms in the past (for CONFIG_HZ=100), same as
	reading the 'jiffies' variable.  These are only useful when called
	in a fast path and one still expects better than second accuracy,
	but can't easily use 'jiffies', e.g. for inode timestamps.
	Skipping the hardware clock access saves around 100 CPU cycles
	on most modern machines with a reliable cycle counter, but
	up to several microseconds on older hardware with an external
	clocksource.

.. c:function:: u64 ktime_get_mono_fast_ns( void )
		u64 ktime_get_raw_fast_ns( void )
		u64 ktime_get_boot_fast_ns( void )
		u64 ktime_get_tai_fast_ns( void )
		u64 ktime_get_real_fast_ns( void )

	These variants are safe to call from any context, including from
	a non-maskable interrupt (NMI) during a timekeeper update, and
	while we are entering suspend with the clocksource powered down.
	This is useful in some tracing or debugging code as well as
	machine check reporting, but most drivers should never call them,
	since the time is allowed to jump under certain conditions.

Giao diện thời gian không dùng nữa
--------------------------

Các hạt nhân cũ hơn đã sử dụng một số giao diện khác hiện đang bị loại bỏ
nhưng có thể xuất hiện trong trình điều khiển của bên thứ ba được chuyển vào đây. Đặc biệt,
tất cả các giao diện trả về 'struct timeval' hoặc 'struct timespec' đều có
đã được thay thế vì thành viên tv_sec tràn vào năm 2038 trên 32-bit
kiến trúc. Đây là những thay thế được đề xuất:

.. c:function:: void ktime_get_ts( struct timespec * )

	Use ktime_get() or ktime_get_ts64() instead.

.. c:function:: void do_gettimeofday( struct timeval * )
		void getnstimeofday( struct timespec * )
		void getnstimeofday64( struct timespec64 * )
		void ktime_get_real_ts( struct timespec * )

	ktime_get_real_ts64() is a direct replacement, but consider using
	monotonic time (ktime_get_ts64()) and/or a ktime_t based interface
	(ktime_get()/ktime_get_real()).

.. c:function:: struct timespec current_kernel_time( void )
		struct timespec64 current_kernel_time64( void )
		struct timespec get_monotonic_coarse( void )
		struct timespec64 get_monotonic_coarse64( void )

	These are replaced by ktime_get_coarse_real_ts64() and
	ktime_get_coarse_ts64(). However, A lot of code that wants
	coarse-grained times can use the simple 'jiffies' instead, while
	some drivers may actually want the higher resolution accessors
	these days.

.. c:function:: struct timespec getrawmonotonic( void )
		struct timespec64 getrawmonotonic64( void )
		struct timespec timekeeping_clocktai( void )
		struct timespec64 timekeeping_clocktai64( void )
		struct timespec get_monotonic_boottime( void )
		struct timespec64 get_monotonic_boottime64( void )

	These are replaced by ktime_get_raw()/ktime_get_raw_ts64(),
	ktime_get_clocktai()/ktime_get_clocktai_ts64() as well
	as ktime_get_boottime()/ktime_get_boottime_ts64().
	However, if the particular choice of clock source is not
	important for the user, consider converting to
	ktime_get()/ktime_get_ts64() instead for consistency.
