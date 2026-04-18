.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/block/ioprio.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================
Chặn các ưu tiên của io
===================


giới thiệu
-----

Tính năng ưu tiên io cho phép người dùng io các quy trình hoặc nhóm quy trình tốt,
tương tự như những gì đã có thể làm được với việc lập lịch CPU từ lâu. Hỗ trợ cho io
mức độ ưu tiên phụ thuộc vào bộ lập lịch io và hiện được hỗ trợ bởi bfq và
mq-thời hạn.

Lên lịch các lớp học
------------------

Ba lớp lập kế hoạch chung được triển khai cho các mức độ ưu tiên của io
xác định cách io được phục vụ cho một quy trình.

IOPRIO_CLASS_RT: Đây là lớp io thời gian thực. Lớp lập kế hoạch này được đưa ra
mức độ ưu tiên cao hơn bất kỳ quy trình nào khác trong hệ thống, các quy trình từ lớp này được
được cấp quyền truy cập đầu tiên vào đĩa mỗi lần. Vì vậy nó cần phải được sử dụng với một số
cẩn thận, một quy trình io RT có thể làm chết đói toàn bộ hệ thống. Trong lớp RT,
có 8 cấp độ dữ liệu lớp học xác định chính xác lượng thời gian này
quá trình cần đĩa cho mỗi dịch vụ. Trong tương lai điều này có thể thay đổi
để có thể ánh xạ trực tiếp hơn tới hiệu suất, bằng cách chuyển dữ liệu mong muốn
tỷ lệ thay thế.

IOPRIO_CLASS_BE: Đây là lớp lập kế hoạch nỗ lực tốt nhất, là lớp mặc định
đối với bất kỳ quy trình nào chưa đặt mức độ ưu tiên io cụ thể. Dữ liệu lớp
xác định lượng băng thông io mà quá trình sẽ nhận được, nó có thể được ánh xạ trực tiếp
đến mức CPU đẹp chỉ được triển khai thô sơ hơn. 0 là cao nhất
Cấp độ BE trước, 7 là thấp nhất. Ánh xạ giữa cấp độ CPU Nice và io
mức độ đẹp được xác định là: io_nice = (cpu_nice + 20)/5.

IOPRIO_CLASS_IDLE: Đây là lớp lập lịch nhàn rỗi, các tiến trình đang chạy ở đây
cấp độ chỉ nhận được thời gian io khi không có ai khác cần đĩa. Lớp nhàn rỗi không có
dữ liệu lớp, vì nó không thực sự áp dụng ở đây.

Công cụ
-----

Xem bên dưới để biết mẫu công cụ ionice. Cách sử dụng::

# ionice -c<class> -n<level> -p<pid>

Nếu không cung cấp pid thì quy trình hiện tại sẽ được giả định. Cài đặt ưu tiên IO
được kế thừa trên fork, vì vậy bạn có thể sử dụng ionice để bắt đầu quá trình tại một thời điểm nhất định
cấp độ::

# ionice -c2 -n0 /bin/ls

sẽ chạy ls ở lớp lập kế hoạch nỗ lực tốt nhất ở mức ưu tiên cao nhất.
Đối với một quy trình đang chạy, bạn có thể cung cấp pid thay thế ::

# ionice -c1 -n2 -p100

sẽ thay đổi pid 100 để chạy ở lớp lập lịch thời gian thực, ở mức ưu tiên 2.

công cụ ionice.c::

#include <stdio.h>
  #include <stdlib.h>
  #include <errno.h>
  #include <getopt.h>
  #include <unistd.h>
  #include <sys/ptrace.h>
  #include <asm/unistd.h>

extern int sys_ioprio_set(int, int, int);
  extern int sys_ioprio_get(int, int);

#if được xác định(__i386__)
  #define __NR_ioprio_set 289
  #define __NR_ioprio_get 290
  #elif được xác định(__ppc__)
  #define __NR_ioprio_set 273
  #define __NR_ioprio_get 274
  #elif được xác định(__x86_64__)
  #define __NR_ioprio_set 251
  #define __NR_ioprio_get 252
  #else
  #error "Vòm không được hỗ trợ"
  #endif

nội tuyến tĩnh int ioprio_set(int which, int who, int ioprio)
  {
	return syscall(__NR_ioprio_set, which, who, ioprio);
  }

nội tuyến tĩnh int ioprio_get(int which, int who)
  {
	return syscall(__NR_ioprio_get, which, who);
  }

liệt kê {
	IOPRIO_CLASS_NONE,
	IOPRIO_CLASS_RT,
	IOPRIO_CLASS_BE,
	IOPRIO_CLASS_IDLE,
  };

liệt kê {
	IOPRIO_WHO_PROCESS = 1,
	IOPRIO_WHO_PGRP,
	IOPRIO_WHO_USER,
  };

#define IOPRIO_CLASS_SHIFT 13

const char *to_prio[] = { "không", "thời gian thực", "nỗ lực tốt nhất", "nhàn rỗi", };

int main(int argc, char *argv[])
  {
	int ioprio = 4, set = 0, ioprio_class = IOPRIO_CLASS_BE;
	int c, pid = 0;

while ((c = getopt(argc, argv, "+n:c:p:")) != EOF) {
		chuyển đổi (c) {
		trường hợp 'n':
			ioprio = strtol(optarg, NULL, 10);
			đặt = 1;
			phá vỡ;
		trường hợp 'c':
			ioprio_class = strtol(optarg, NULL, 10);
			đặt = 1;
			phá vỡ;
		trường hợp 'p':
			pid = strtol(optarg, NULL, 10);
			phá vỡ;
		}
	}

chuyển đổi (ioprio_class) {
		vỏ IOPRIO_CLASS_NONE:
			ioprio_class = IOPRIO_CLASS_BE;
			phá vỡ;
		vỏ IOPRIO_CLASS_RT:
		vỏ IOPRIO_CLASS_BE:
			phá vỡ;
		vỏ IOPRIO_CLASS_IDLE:
			ioprio = 7;
			phá vỡ;
		mặc định:
			printf("Lớp ưu tiên xấu %d\n", ioprio_class);
			trả về 1;
	}

nếu (! Bộ) {
		if (!pid && argv[optind])
			pid = strtol(argv[optind], NULL, 10);

ioprio = ioprio_get(IOPRIO_WHO_PROCESS, pid);

printf("pid=%d, %d\n", pid, ioprio);

nếu (ioprio == -1)
			perror("ioprio_get");
		khác {
			ioprio_class = ioprio >> IOPRIO_CLASS_SHIFT;
			ioprio = ioprio & 0xff;
			printf("%s: prio %d\n", to_prio[ioprio_class], ioprio);
		}
	} khác {
		if (ioprio_set(IOPRIO_WHO_PROCESS, pid, ioprio | ioprio_class << IOPRIO_CLASS_SHIFT) == -1) {
			perror("ioprio_set");
			trả về 1;
		}

nếu (argv[optind])
			execvp(argv[optind], &argv[optind]);
	}

trả về 0;
  }


Ngày 11 tháng 3 năm 2005, Jens Axboe <jens.axboe@oracle.com>
