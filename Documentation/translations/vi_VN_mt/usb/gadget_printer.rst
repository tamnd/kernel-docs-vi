.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/usb/gadget_printer.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================
Trình điều khiển tiện ích máy in Linux USB
===============================

04/06/2007

Bản quyền (C) 2007 Craig W. Nadler <craig@nadler.us>



Tổng quan
=======

Trình điều khiển này có thể được sử dụng nếu bạn đang viết chương trình cơ sở máy in bằng Linux như
hệ điều hành nhúng. Trình điều khiển này không liên quan gì đến việc sử dụng máy in với
hệ thống máy chủ Linux của bạn.

Bạn sẽ cần bộ điều khiển thiết bị USB và trình điều khiển Linux để nó chấp nhận
trình điều khiển tiện ích / "lớp thiết bị" sử dụng Linux USB Gadget API. Sau khi
Trình điều khiển bộ điều khiển thiết bị USB được tải rồi tải trình điều khiển tiện ích máy in.
Điều này sẽ hiển thị giao diện máy in cho Máy chủ USB mà Thiết bị USB của bạn
cổng được kết nối tới.

Trình điều khiển này được cấu trúc cho chương trình cơ sở máy in chạy ở chế độ người dùng. các
chế độ người dùng chương trình cơ sở máy in sẽ đọc và ghi dữ liệu từ chế độ kernel
trình điều khiển tiện ích máy in bằng cách sử dụng tệp thiết bị. Máy in trả về trạng thái máy in
byte khi USB HOST gửi yêu cầu thiết bị để nhận trạng thái máy in.  các
chương trình cơ sở không gian người dùng có thể đọc hoặc ghi byte trạng thái này bằng tệp thiết bị
/dev/g_printer . Hỗ trợ cả cuộc gọi đọc/ghi chặn và không chặn.




Cách sử dụng trình điều khiển này
=====================

Để tải trình điều khiển bộ điều khiển thiết bị USB và trình điều khiển tiện ích máy in. các
ví dụ sau sử dụng trình điều khiển bộ điều khiển thiết bị Netchip 2280 USB::

modprobe net2280
	modprobe g_printer


Tham số dòng lệnh sau có thể được sử dụng khi tải tiện ích máy in
(ví dụ: modprobe g_printer idVendor=0x0525 idProduct=0xa4a8 ):

idVendor
	Đây là ID nhà cung cấp được sử dụng trong bộ mô tả thiết bị. Mặc định là
	id nhà cung cấp Netchip 0x0525. YOU MUST CHANGE ĐẾN YOUR OWN VENDOR ID
	BEFORE RELEASING A PRODUCT. Nếu bạn dự định tung ra một sản phẩm và không
	đã có ID nhà cung cấp, vui lòng xem www.usb.org để biết chi tiết về cách
	lấy một cái.

idSản phẩm
	Đây là ID sản phẩm được sử dụng trong bộ mô tả thiết bị. Mặc định
	là 0xa4a8, bạn nên thay đổi mã này thành ID chưa được sử dụng bởi bất kỳ ai trong số này
	các sản phẩm USB khác của bạn nếu bạn có bất kỳ sản phẩm nào. Sẽ là một ý tưởng tốt để
	bắt đầu đánh số sản phẩm của bạn bắt đầu bằng 0x0001.

thiết bị bcd
	Đây là số phiên bản của sản phẩm của bạn. Đó sẽ là một ý tưởng tốt
	để đặt phiên bản chương trình cơ sở của bạn ở đây.

iNhà sản xuất
	Một chuỗi chứa tên của Nhà cung cấp.

iSản phẩm
	Một chuỗi chứa Tên sản phẩm.

iSerialNum
	Một chuỗi chứa Số sê-ri. Điều này nên được thay đổi cho
	từng đơn vị sản phẩm của bạn.

chuỗi iPNP
	Chuỗi ID PNP được sử dụng cho máy in này. Bạn sẽ muốn thiết lập
	trên dòng lệnh hoặc mã cứng, chuỗi ID PNP được sử dụng cho
	sản phẩm máy in của bạn.

qlen
	Số lượng bộ đệm 8k sẽ sử dụng cho mỗi điểm cuối. Mặc định là 10 bạn nhé
	nên điều chỉnh điều này cho sản phẩm của bạn. Bạn cũng có thể muốn điều chỉnh
	kích thước của mỗi bộ đệm cho sản phẩm của bạn.




Sử dụng mã ví dụ
======================

Mã ví dụ này nói chuyện với thiết bị xuất chuẩn, thay vì công cụ in.

Để biên dịch mã kiểm tra bên dưới:

1) lưu nó vào một tệp có tên prn_example.c
2) biên dịch mã bằng lệnh sau ::

gcc prn_example.c -o prn_example



Để đọc dữ liệu máy in từ máy chủ đến thiết bị xuất chuẩn ::

# prn_example-đọc_dữ liệu


Để ghi dữ liệu máy in từ một tệp (data_file) vào máy chủ::

Tệp dữ liệu # cat | prn_example -write_data


Để biết trạng thái máy in hiện tại cho trình điều khiển tiện ích:::

# prn_example -get_status

Tình trạng máy in là:
	     Máy in được chọn NOT
	     Giấy đã hết
	     Máy in ổn


Để đặt máy in ở chế độ Đã chọn/Trực tuyến::

# prn_example -đã chọn


Để đặt máy in ở chế độ Không được chọn/Ngoại tuyến::

# prn_example -not_selected


Để đặt trạng thái giấy thành giấy ra::

# prn_example -paper_out


Để đặt trạng thái giấy thành giấy đã được nạp::

# prn_example -paper_loaded


Để đặt trạng thái lỗi cho máy in OK::

# prn_example -no_error


Để đặt trạng thái lỗi thành ERROR::

# prn_example-lỗi




Mã ví dụ
============

::


#include <stdio.h>
  #include <stdlib.h>
  #include <fcntl.h>
  #include <linux/poll.h>
  #include <sys/ioctl.h>
  #include <linux/usb/g_printer.h>

#define PRINTER_FILE "/dev/g_printer"
  #define BUF_SIZE 512


/*
   * 'usage()' - Hiển thị cách sử dụng chương trình.
   */

khoảng trống tĩnh
  Cách sử dụng (const char ZZ0000ZZ I - Chuỗi tùy chọn hoặc NULL */
  {
	nếu (tùy chọn) {
		fprintf(stderr,"prn_example: Tùy chọn không xác định \"%s\"!\n",
				tùy chọn);
	}

fputs("\n", stderr);
	fputs("Cách sử dụng: prn_example -[options]\n", stderr);
	fputs("Tùy chọn:\n", stderr);
	fputs("\n", stderr);
	fputs("-get_status Lấy trạng thái máy in hiện tại.\n", stderr);
	fputs("-selected Đặt trạng thái đã chọn thành đã chọn.\n", stderr);
	fputs("-not_selected Đặt trạng thái đã chọn thành NOT đã chọn.\n",
			stderr);
	fputs("-error Đặt trạng thái lỗi thành error.\n", stderr);
	fputs("-no_error Đặt trạng thái lỗi thành KHÔNG có lỗi.\n", stderr);
	fputs("-paper_out Đặt trạng thái giấy thành giấy ra.\n", stderr);
	fputs("-paper_loaded Đặt trạng thái giấy thành giấy đã được nạp.\n",
			stderr);
	fputs("-read_data Đọc dữ liệu máy in từ trình điều khiển.\n", stderr);
	fputs("-write_data Ghi sata máy in vào driver.\n", stderr);
	fputs("-NB_read_data (Không chặn) Đọc dữ liệu máy in từ trình điều khiển.\n",
			stderr);
	fputs("\n\n", stderr);

thoát (1);
  }


int tĩnh
  read_printer_data()
  {
	cấu trúc pollfd fd[1];

/* Mở file thiết bị cho tiện ích máy in. */
	fd[0].fd = open(PRINTER_FILE, O_RDWR);
	nếu (fd[0].fd < 0) {
		printf("Lỗi %d khi mở %s\n", fd[0].fd, PRINTER_FILE);
		close(fd[0].fd);
		trở lại (-1);
	}

fd[0].events = POLLIN | POLLRDNORM;

trong khi (1) {
		buf char tĩnh [BUF_SIZE];
		int byte_read;
		int trả về;

/* Đợi tối đa 1 giây để lấy dữ liệu. */
		retval = thăm dò ý kiến(fd, 1, 1000);

if (retval && (fd[0].revents & POLLRDNORM)) {

/* Đọc dữ liệu từ trình điều khiển tiện ích máy in. */
			byte_read = read(fd[0].fd, buf, BUF_SIZE);

nếu (byte_read < 0) {
				printf("Lỗi %d khi đọc từ %s\n",
						fd[0].fd, PRINTER_FILE);
				close(fd[0].fd);
				trở lại (-1);
			} khác nếu (byte_read > 0) {
				/* Ghi dữ liệu vào OUTPUT tiêu chuẩn (thiết bị xuất chuẩn). */
				fwrite(buf, 1, bytes_read, stdout);
				fflush(stdout);
			}

		}

	}

/* Đóng tệp thiết bị. */
	close(fd[0].fd);

trả về 0;
  }


int tĩnh
  write_printer_data()
  {
	cấu trúc pollfd fd[1];

/* Mở file thiết bị cho tiện ích máy in. */
	fd[0].fd = mở (PRINTER_FILE, O_RDWR);
	nếu (fd[0].fd < 0) {
		printf("Lỗi %d khi mở %s\n", fd[0].fd, PRINTER_FILE);
		close(fd[0].fd);
		trở lại (-1);
	}

fd[0].events = POLLOUT | POLLWRNORM;

trong khi (1) {
		int trả về;
		buf char tĩnh [BUF_SIZE];
		/* Đọc dữ liệu từ INPUT (stdin) tiêu chuẩn. */
		int bytes_read = fread(buf, 1, BUF_SIZE, stdin);

nếu (!byte_read) {
			phá vỡ;
		}

trong khi (byte_read) {

/* Đợi tối đa 1 giây để gửi dữ liệu. */
			retval = thăm dò ý kiến(fd, 1, 1000);

/* Ghi dữ liệu vào trình điều khiển tiện ích máy in. */
			if (retval && (fd[0].revents & POLLWRNORM)) {
				retval = write(fd[0].fd, buf, bytes_read);
				if (retval < 0) {
					printf("Lỗi %d ghi vào %s\n",
							fd[0].fd,
							PRINTER_FILE);
					close(fd[0].fd);
					trở lại (-1);
				} khác {
					bytes_read -= trả lại;
				}

			}

		}

	}

/* Đợi cho đến khi dữ liệu được gửi đi. */
	fsync(fd[0].fd);

/* Đóng tệp thiết bị. */
	close(fd[0].fd);

trả về 0;
  }


int tĩnh
  read_NB_printer_data()
  {
	int fd;
	buf char tĩnh [BUF_SIZE];
	int byte_read;

/* Mở file thiết bị cho tiện ích máy in. */
	fd = mở(PRINTER_FILE, O_RDWR|O_NONBLOCK);
	nếu (fd < 0) {
		printf("Lỗi %d khi mở %s\n", fd, PRINTER_FILE);
		đóng(fd);
		trở lại (-1);
	}

trong khi (1) {
		/* Đọc dữ liệu từ trình điều khiển tiện ích máy in. */
		byte_read = đọc(fd, buf, BUF_SIZE);
		nếu (byte_read <= 0) {
			phá vỡ;
		}

/* Ghi dữ liệu vào OUTPUT tiêu chuẩn (thiết bị xuất chuẩn). */
		fwrite(buf, 1, bytes_read, stdout);
		fflush(stdout);
	}

/* Đóng tệp thiết bị. */
	đóng(fd);

trả về 0;
  }


int tĩnh
  get_printer_status()
  {
	int trả lại;
	int fd;

/* Mở file thiết bị cho tiện ích máy in. */
	fd = mở(PRINTER_FILE, O_RDWR);
	nếu (fd < 0) {
		printf("Lỗi %d khi mở %s\n", fd, PRINTER_FILE);
		đóng(fd);
		trở lại (-1);
	}

/* Thực hiện cuộc gọi IOCTL. */
	retval = ioctl(fd, GADGET_GET_PRINTER_STATUS);
	if (retval < 0) {
		fprintf(stderr, "ERROR: Không thể đặt trạng thái máy in\n");
		trở lại (-1);
	}

/* Đóng tệp thiết bị. */
	đóng(fd);

return(retval);
  }


int tĩnh
  set_printer_status(unsign char buf, int clear_printer_status_bit)
  {
	int trả lại;
	int fd;

retval = get_printer_status();
	if (retval < 0) {
		fprintf(stderr, "ERROR: Không lấy được trạng thái máy in\n");
		trở lại (-1);
	}

/* Mở file thiết bị cho tiện ích máy in. */
	fd = mở(PRINTER_FILE, O_RDWR);

nếu (fd < 0) {
		printf("Lỗi %d khi mở %s\n", fd, PRINTER_FILE);
		đóng(fd);
		trở lại (-1);
	}

nếu (clear_printer_status_bit) {
		trả lại &= ~buf;
	} khác {
		trả lại |= buf;
	}

/* Thực hiện cuộc gọi IOCTL. */
	if (ioctl(fd, GADGET_SET_PRINTER_STATUS, (unsigned char)retval)) {
		fprintf(stderr, "ERROR: Không thể đặt trạng thái máy in\n");
		trở lại (-1);
	}

/* Đóng tệp thiết bị. */
	đóng(fd);

trả về 0;
  }


int tĩnh
  display_printer_status()
  {
	char máy in_status;

máy in_status = get_printer_status();
	if (printer_status < 0) {
		fprintf(stderr, "ERROR: Không lấy được trạng thái máy in\n");
		trở lại (-1);
	}

printf("Trạng thái máy in là:\n");
	if (printer_status & PRINTER_SELECTED) {
		printf(" Máy in đã được chọn\n");
	} khác {
		printf(" Máy in được chọn NOT\n");
	}
	if (printer_status & PRINTER_PAPER_EMPTY) {
		printf("Hết giấy\n");
	} khác {
		printf(" Giấy đã được nạp\n");
	}
	if (printer_status & PRINTER_NOT_ERROR) {
		printf(" Máy in OK\n");
	} khác {
		printf(" Máy in ERROR\n");
	}

trở lại (0);
  }


int
  chính(int argc, char *argv[])
  {
	int tôi;		/* Vòng lặp var */
	int retval = 0;

/* Không có đối số */
	nếu (argc == 1) {
		cách sử dụng(0);
		thoát (0);
	}

for (i = 1; i < argc && !retval; i ++) {

if (argv[i][0] != '-') {
			tiếp tục;
		}

if (!strcmp(argv[i], "-get_status")) {
			nếu (display_printer_status()) {
				giá trị hồi phục = 1;
			}

} else if (!strcmp(argv[i], "-paper_loaded")) {
			if (set_printer_status(PRINTER_PAPER_EMPTY, 1)) {
				giá trị hồi phục = 1;
			}

} else if (!strcmp(argv[i], "-paper_out")) {
			if (set_printer_status(PRINTER_PAPER_EMPTY, 0)) {
				giá trị hồi phục = 1;
			}

} else if (!strcmp(argv[i], "-selected")) {
			if (set_printer_status(PRINTER_SELECTED, 0)) {
				giá trị hồi phục = 1;
			}

} else if (!strcmp(argv[i], "-not_selected")) {
			if (set_printer_status(PRINTER_SELECTED, 1)) {
				giá trị hồi phục = 1;
			}

} else if (!strcmp(argv[i], "-error")) {
			if (set_printer_status(PRINTER_NOT_ERROR, 1)) {
				giá trị hồi phục = 1;
			}

} else if (!strcmp(argv[i], "-no_error")) {
			if (set_printer_status(PRINTER_NOT_ERROR, 0)) {
				giá trị hồi phục = 1;
			}

} else if (!strcmp(argv[i], "-read_data")) {
			nếu (read_printer_data()) {
				giá trị hồi phục = 1;
			}

} else if (!strcmp(argv[i], "-write_data")) {
			nếu (write_printer_data()) {
				giá trị hồi phục = 1;
			}

} else if (!strcmp(argv[i], "-NB_read_data")) {
			nếu (read_NB_printer_data()) {
				giá trị hồi phục = 1;
			}

} khác {
			cách sử dụng (argv [i]);
			giá trị hồi phục = 1;
		}
	}

thoát (trở lại);
  }
