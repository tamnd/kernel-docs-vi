.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/cpu-load.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========
Tải CPU
========

Linux xuất nhiều thông tin khác nhau qua ZZ0000ZZ và
ZZ0001ZZ mà các công cụ của người dùng, chẳng hạn như top(1), sử dụng để tính toán
hệ thống thời gian trung bình dành cho một trạng thái cụ thể, ví dụ::

$ iostat
    Linux 2.6.18.3-exp (linmac) 20/02/2007

avg-cpu: %user %nice %system %iowait %steal %idle
              10,01 0,00 2,92 5,44 0,00 81,63

    ...

Ở đây hệ thống cho rằng trong khoảng thời gian lấy mẫu mặc định,
hệ thống dành 10,01% thời gian để thực hiện công việc trong không gian người dùng, 2,92% trong không gian
kernel và nhìn chung có 81,63% thời gian không hoạt động.

Trong hầu hết các trường hợp, thông tin ZZ0000ZZ phản ánh khá thực tế
chặt chẽ, tuy nhiên do tính chất của cách thức/thời điểm hạt nhân thu thập
dữ liệu này đôi khi không thể tin cậy được chút nào.

Vậy thông tin này được thu thập như thế nào?  Bất cứ khi nào ngắt hẹn giờ là
báo hiệu kernel xem loại tác vụ nào đang chạy lúc này
thời điểm và tăng bộ đếm tương ứng với nhiệm vụ này
loại/trạng thái.  Vấn đề với điều này là hệ thống có thể có
chuyển đổi giữa các trạng thái khác nhau nhiều lần giữa hai bộ đếm thời gian
ngắt nhưng bộ đếm chỉ tăng ở trạng thái cuối cùng.


Ví dụ
-------

Nếu chúng ta tưởng tượng hệ thống có một nhiệm vụ đốt các chu kỳ theo chu kỳ
theo cách sau::

dòng thời gian giữa hai lần ngắt hẹn giờ
    ZZ0000ZZ
     ^ ^
     ZZ0001ZZ
                                          |_ thứ gì đó đi ngủ
                                         (chỉ được đánh thức khá sớm)

Trong tình huống trên, hệ thống sẽ được tải 0% theo
ZZ0000ZZ (vì việc ngắt hẹn giờ sẽ luôn xảy ra khi
hệ thống đang thực thi trình xử lý nhàn rỗi), nhưng trên thực tế tải là
gần đến 99%.

Người ta có thể tưởng tượng ra nhiều tình huống khác trong đó hành vi này của kernel
sẽ dẫn đến thông tin bên trong ZZ0000ZZ khá thất thường::


/* gcc -o hog Smallhog.c */
	#include <thời gian.h>
	#include <giới hạn.h>
	#include <tín hiệu.h>
	#include <sys/time.h>
	#define HIST 10

dừng sig_atomic_t tĩnh dễ bay hơi;

tĩnh void thở dài (int signr)
	{
		(vô hiệu) người ký;
		dừng = 1;
	}

con lợn dài không dấu tĩnh (niters dài không dấu)
	{
		dừng = 0;
		while (!stop && --niters);
		trả lại niter;
	}

	int main (void)
	{
		int i;
		struct itimerval it = {
			.it_interval = { .tv_sec = 0, .tv_usec = 1 },
			.it_value    = { .tv_sec = 0, .tv_usec = 1 } };
		sigset_t set;
		unsigned long v[HIST];
		double tmp = 0.0;
		unsigned long n;
		signal(SIGALRM, &sighandler);
		setitimer(ITIMER_REAL, &it, NULL);

lợn (ULONG_MAX);
		với (i = 0; i < HIST; ++i) v[i] = ULONG_MAX - hog(ULONG_MAX);
		for (i = 0; i < HIST; ++i) tmp += v[i];
		tmp /= HIST;
		n = tmp - (tmp/3.0);

		sigemptyset(&set);
		sigaddset(&set, SIGALRM);

		for (;;) {
			hog(n);
			sigwait(&set, &i);
		}
		return 0;
	}


References
----------

- https://lore.kernel.org/r/loom.20070212T063225-663@post.gmane.org
- Documentation/filesystems/proc.rst (1.8)


Thanks
------

Con Kolivas, Pavel Machek
