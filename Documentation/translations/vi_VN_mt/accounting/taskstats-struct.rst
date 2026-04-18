.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/accounting/taskstats-struct.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================
Thống kê tác vụ cấu trúc
========================

Tài liệu này chứa phần giải thích về các trường struct taskstats.

Có ba nhóm trường khác nhau trong taskstats cấu trúc:

1) Các lĩnh vực kế toán phổ biến và cơ bản
    Nếu CONFIG_TASKSTATS được đặt, giao diện taskstats sẽ được bật và
    các lĩnh vực chung và lĩnh vực kế toán cơ bản được tập hợp cho
    giao hàng tại do_exit() của một nhiệm vụ.
2) Lĩnh vực kế toán trễ
    Các trường này được đặt giữa::

/* Trì hoãn việc bắt đầu các trường kế toán */

Và::

/* Trì hoãn kết thúc trường kế toán */

Giá trị của chúng được thu thập nếu CONFIG_TASK_DELAY_ACCT được đặt.
3) Lĩnh vực kế toán mở rộng
    Các trường này được đặt giữa::

/* Các trường kế toán mở rộng bắt đầu */

Và::

/* Các trường kế toán mở rộng kết thúc */

Giá trị của chúng được thu thập nếu CONFIG_TASK_XACCT được đặt.

4) Thống kê số lượng chuyển đổi ngữ cảnh trên mỗi tác vụ và mỗi luồng

5) Tính toán thời gian cho máy SMT

6) Các trường tính toán độ trễ mở rộng để lấy lại bộ nhớ

Tiện ích mở rộng trong tương lai sẽ thêm các trường vào cuối cấu trúc taskstats và
không nên thay đổi vị trí tương đối của từng trường trong cấu trúc.

::

cấu trúc nhiệm vụ {

1) Các lĩnh vực kế toán phổ biến và cơ bản::

/* Số phiên bản của cấu trúc này. Trường này luôn được đặt thành
	 * TASKSTATS_VERSION, được định nghĩa trong <linux/taskstats.h>.
	 * Mỗi lần thay đổi cấu trúc, giá trị sẽ tăng lên.
	 */
	__u16 phiên bản;

/* Mã thoát của một tác vụ. */
	__u32 ac_exitcode;		/*Trạng thái thoát */

/* Cờ kế toán của một tác vụ như được định nghĩa trong <linux/acct.h>
	 * Các giá trị được xác định là AFORK, ASU, ACOMPAT, ACORE và AXSIG.
	 */
	__u8 ac_flag;		/* Cờ ghi */

/* Giá trị task_nice() của một tác vụ. */
	__u8 ac_nice;		/* task_nice */

/* Tên lệnh bắt đầu tác vụ này. */
	char ac_comm[TS_COMM_LEN];	/* Tên lệnh */

/* Kỷ luật lập kế hoạch như được đặt trong trường nhiệm vụ->chính sách. */
	__u8 ac_sched;		/* Lập kế hoạch kỷ luật */

__u8 ac_pad[3];
	__u32 ac_uid;			/*ID người dùng */
	__u32 ac_gid;			/* Mã nhóm */
	__u32 ac_pid;			/*ID tiến trình */
	__u32 ac_ppid;		/* ID tiến trình gốc */

/* Thời gian khi một nhiệm vụ bắt đầu, tính bằng [giây] kể từ năm 1970. */
	__u32 ac_btime;		/* Thời gian bắt đầu [giây kể từ năm 1970] */

/* Thời gian đã trôi qua của một tác vụ, trong [usec]. */
	__u64 ac_etime;		/* Thời gian đã trôi qua [usec] */

/* Người dùng CPU thời gian thực hiện một tác vụ, trong [usec]. */
	__u64 ac_utime;		/* Người dùng CPU thời gian [usec] */

/* Hệ thống CPU thời gian của một tác vụ, trong [usec]. */
	__u64 ac_stime;		/* Hệ thống CPU thời gian [usec] */

/* Số lỗi trang nhỏ của một tác vụ, như được đặt trong task->min_flt. */
	__u64 ac_minflt;		/* Số lỗi trang nhỏ */

/* Số lượng lỗi trang chính của một tác vụ, như được đặt trong task->maj_flt. */
	__u64 ac_majflt;		/* Số lỗi trang chính */


2) Lĩnh vực kế toán trễ::

/* Trì hoãn việc bắt đầu các trường kế toán
	 *
	 * Tất cả các giá trị, cho đến khi nhận xét "Trì hoãn kết thúc trường kế toán" là
	 * chỉ khả dụng nếu tính năng tính toán độ trễ được bật, mặc dù tùy chọn cuối cùng
	 * một số trường không bị chậm trễ
	 *
	 * xxx_count là số giá trị độ trễ được ghi lại
	 * xxx_delay_total là độ trễ tích lũy tương ứng tính bằng nano giây
	 *
	 * xxx_delay_total gần bằng 0 khi tràn
	 * xxx_count tăng lên bất kể tràn
	 */

/* Trì hoãn chờ CPU, trong khi có thể chạy được
	 * đếm, delay_total NOT được cập nhật nguyên tử
	 */
	__u64 cpu_count;
	__u64 cpu_delay_total;

/* Bốn trường sau đây được cập nhật nguyên tử bằng cách sử dụng task->delays->lock */

/* Trì hoãn chờ khối I/O đồng bộ hoàn tất
	 * không tính đến sự chậm trễ trong việc gửi I/O
	 */
	__u64 blkio_count;
	__u64 blkio_delay_total;

/* Trì hoãn chờ I/O lỗi trang (chỉ trao đổi) */
	__u64 swapin_count;
	__u64 swapin_delay_total;

/* thời gian chạy của "đồng hồ treo tường" cpu
	 * Trên một số kiến trúc, giá trị sẽ điều chỉnh theo thời gian CPU bị đánh cắp
	 * từ kernel trong tình trạng chờ đợi không tự nguyện do ảo hóa.
	 * Giá trị được tích lũy, tính bằng nano giây, không có số đếm tương ứng
	 * và âm thầm bao quanh số 0 khi tràn
	 */
	__u64 cpu_run_real_total;

/* thời gian chạy CPU "ảo"
	 * Sử dụng các khoảng thời gian mà kernel nhìn thấy, tức là không cần điều chỉnh
	 * đối với sự chờ đợi không tự nguyện của kernel do ảo hóa.
	 * Giá trị được tích lũy, tính bằng nano giây, không có số đếm tương ứng
	 * và âm thầm bao quanh số 0 khi tràn
	 */
	__u64 cpu_run_virtual_total;
	/* Trì hoãn kết thúc trường kế toán */
	/* phiên bản 1 kết thúc tại đây */


3) Các lĩnh vực kế toán mở rộng::

/* Các trường kế toán mở rộng bắt đầu */

/* Mức sử dụng RSS tích lũy trong thời gian thực hiện một tác vụ, tính bằng MBytes-usecs.
	 * Việc sử dụng rss hiện tại được thêm vào bộ đếm này mỗi lần
	 * một tích tắc được tính vào thời gian hệ thống của nhiệm vụ. Vì vậy, cuối cùng chúng tôi
	 * sẽ có mức sử dụng bộ nhớ nhân với thời gian hệ thống. Như vậy một
	 * Có thể tính mức sử dụng trung bình trên mỗi đơn vị thời gian hệ thống.
	 */
	__u64 lõimem;		/* Mức sử dụng RSS tích lũy tính bằng MB-usec */

/* Mức sử dụng bộ nhớ ảo tích lũy trong suốt thời gian thực hiện một tác vụ.
	 * Tương tự như acct_rss_mem1 ở trên ngoại trừ việc chúng tôi theo dõi việc sử dụng VM.
	 */
	__u64 virtmem;		/* Mức sử dụng VM tích lũy trong MB-usec */

/* Hình mờ cao về mức sử dụng RSS trong thời gian thực hiện tác vụ, tính bằng KBytes. */
	__u64 hiwater_rss;		/* Hình mờ cao khi sử dụng RSS */

/* Hình mờ cao về việc sử dụng VM trong thời gian thực hiện tác vụ, tính bằng KBytes. */
	__u64 hiwater_vm;		/* Mức sử dụng bộ nhớ ảo ở mức cao */

/* Bốn trường sau đây là số liệu thống kê I/O của một tác vụ. */
	__u64 read_char;		/* số byte đã đọc */
	__u64 write_char;		/* byte được ghi */
	__u64 read_syscalls;		/* đọc các cuộc gọi hệ thống */
	__u64 write_syscalls;		/* ghi các cuộc gọi hệ thống */

/* Các trường kế toán mở rộng kết thúc */

4) Thống kê theo từng tác vụ và theo từng luồng ::

__u64 nvcsw;			/* Bộ đếm chuyển đổi bối cảnh tự nguyện */
	__u64 nivcsw;			/* Bộ đếm chuyển đổi không tự nguyện theo ngữ cảnh */

5) Tính toán thời gian cho máy SMT::

__u64 ac_utimescaled;		/* utime được chia theo tần số, v.v. */
	__u64 ac_stimescaled;		/* thời gian được chia tỷ lệ theo tần số, v.v. */
	__u64 cpu_scaled_run_real_total; /* chia tỷ lệ cpu_run_real_total */

6) Các trường tính toán độ trễ mở rộng để lấy lại bộ nhớ::

/* Trì hoãn chờ lấy lại bộ nhớ */
	__u64 trang miễn phí_count;
	__u64 trang miễn phí_delay_total;

::

  }
