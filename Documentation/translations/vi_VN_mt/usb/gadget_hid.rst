.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/usb/gadget_hid.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================================
Trình điều khiển tiện ích Linux USB HID
=======================================

Giới thiệu
============

Trình điều khiển Tiện ích HID cung cấp mô phỏng Giao diện con người USB
Thiết bị (HID). Việc xử lý HID cơ bản được thực hiện trong kernel,
và báo cáo HID có thể được gửi/nhận thông qua I/O trên
Thiết bị ký tự /dev/hidgX.

Để biết thêm chi tiết về HID, hãy xem trang nhà phát triển trên
ZZ0000ZZ

Cấu hình
=============

g_hid là trình điều khiển nền tảng, vì vậy để sử dụng nó bạn cần thêm
struct platform_device(s) vào mã nền tảng của bạn để xác định
Bộ mô tả chức năng HID bạn muốn sử dụng - E.G. cái gì đó
thích::

#include <linux/platform_device.h>
  #include <linux/usb/g_hid.h>

/* ẩn phần mô tả của bàn phím */
  cấu trúc tĩnh hidg_func_descriptor my_hid_data = {
	.subclass = 0, /* Không có lớp con */
	.protocol = 1, /* Bàn phím */
	.report_length = 8,
	.report_desc_length = 63,
	.report_desc = {
		0x05, 0x01, /* USAGE_PAGE (Màn hình chung) */
		0x09, 0x06, /* USAGE (Bàn phím) */
		0xa1, 0x01, /* COLLECTION (Ứng dụng) */
		0x05, 0x07, /* USAGE_PAGE (Bàn phím) */
		0x19, 0xe0, /* USAGE_MINIMUM (Điều khiển bên trái bàn phím) */
		0x29, 0xe7, /* USAGE_MAXIMUM (Bàn phím bên phải GUI) */
		0x15, 0x00, /* LOGICAL_MINIMUM (0) */
		0x25, 0x01, /* LOGICAL_MAXIMUM (1) */
		0x75, 0x01, /* REPORT_SIZE (1) */
		0x95, 0x08, /* REPORT_COUNT (8) */
		0x81, 0x02, /* INPUT (Dữ liệu, Var, Abs) */
		0x95, 0x01, /* REPORT_COUNT (1) */
		0x75, 0x08, /* REPORT_SIZE (8) */
		0x81, 0x03, /* INPUT (Cnst,Var,Abs) */
		0x95, 0x05, /* REPORT_COUNT (5) */
		0x75, 0x01, /* REPORT_SIZE (1) */
		0x05, 0x08, /* USAGE_PAGE (đèn LED) */
		0x19, 0x01, /* USAGE_MINIMUM (Khóa số) */
		0x29, 0x05, /* USAGE_MAXIMUM (Kana) */
		0x91, 0x02, /* OUTPUT (Dữ liệu, Var, Abs) */
		0x95, 0x01, /* REPORT_COUNT (1) */
		0x75, 0x03, /* REPORT_SIZE (3) */
		0x91, 0x03, /* OUTPUT (Cnst,Var,Abs) */
		0x95, 0x06, /* REPORT_COUNT (6) */
		0x75, 0x08, /* REPORT_SIZE (8) */
		0x15, 0x00, /* LOGICAL_MINIMUM (0) */
		0x25, 0x65, /* LOGICAL_MAXIMUM (101) */
		0x05, 0x07, /* USAGE_PAGE (Bàn phím) */
		0x19, 0x00, /* USAGE_MINIMUM (Dành riêng) */
		0x29, 0x65, /* USAGE_MAXIMUM (Ứng dụng bàn phím) */
		0x81, 0x00, /* INPUT (Dữ liệu, Ary, Abs) */
		0xc0 /* END_COLLECTION */
	}
  };

cấu trúc tĩnh platform_device my_hid = {
	.name = "giấu",
	.id = 0,
	.num_resource = 0,
	.resource = 0,
	.dev.platform_data = &my_hid_data,
  };

Bạn có thể thêm bao nhiêu chức năng HID tùy thích, chỉ bị giới hạn bởi
số lượng điểm cuối ngắt mà trình điều khiển tiện ích của bạn hỗ trợ.

Cấu hình với configfs
===========================

Thay vì thêm các thiết bị và trình điều khiển nền tảng giả mạo để vượt qua
một số dữ liệu vào kernel, nếu HID là một phần của tiện ích được tạo bằng
configfs, hidg_func_descriptor.report_desc được truyền vào kernel
bằng cách ghi luồng byte thích hợp vào thuộc tính configfs.

Gửi và nhận báo cáo HID
============================

Báo cáo HID có thể được gửi/nhận bằng cách đọc/ghi trên
Thiết bị ký tự /dev/hidgX. Xem bên dưới để biết chương trình ví dụ
để làm điều này

hid_gadget_test là một chương trình tương tác nhỏ để kiểm tra HID
trình điều khiển tiện ích. Để sử dụng, hãy trỏ nó vào một thiết bị ẩn và đặt
loại thiết bị (bàn phím/chuột/cần điều khiển) - E.G.::

Bàn phím # hid_gadget_test /dev/hidg0

Bây giờ bạn đang ở trong dấu nhắc của hid_gadget_test. Bạn có thể gõ bất kỳ
sự kết hợp của các lựa chọn và giá trị. Các tùy chọn có sẵn và
các giá trị được liệt kê khi bắt đầu chương trình. Ở chế độ bàn phím, bạn có thể
gửi tối đa sáu giá trị.

Ví dụ gõ: g i s t r --left-shift

Nhấn quay lại và báo cáo tương ứng sẽ được gửi bởi
Tiện ích HID.

Một ví dụ thú vị khác là thử nghiệm khóa mũ. Loại
--caps-lock và nhấn return. Sau đó, một báo cáo sẽ được gửi bởi
tiện ích và bạn sẽ nhận được câu trả lời của máy chủ, tương ứng
đến trạng thái khóa mũ LED::

--caps-lock
	báo cáo recv:2

Với lệnh này::

Chuột # hid_gadget_test/dev/hidg1

Bạn có thể kiểm tra mô phỏng chuột. Giá trị là hai số có dấu.


Mã mẫu::

/* hid_gadget_test */

#include <pthread.h>
    #include <string.h>
    #include <stdio.h>
    #include <ctype.h>
    #include <fcntl.h>
    #include <errno.h>
    #include <stdio.h>
    #include <stdlib.h>
    #include <unistd.h>

#define BUF_LEN 512

tùy chọn cấu trúc {
	const char *opt;
	giá trị char không dấu;
  };

tùy chọn cấu trúc tĩnh kmod[] = {
	{.opt = "--left-ctrl", .val = 0x01},
	{.opt = "--right-ctrl", .val = 0x10},
	{.opt = "--left-shift", .val = 0x02},
	{.opt = "--right-shift", .val = 0x20},
	{.opt = "--left-alt", .val = 0x04},
	{.opt = "--right-alt", .val = 0x40},
	{.opt = "--left-meta", .val = 0x08},
	{.opt = "--right-meta", .val = 0x80},
	{.opt = NULL}
  };

tùy chọn cấu trúc tĩnh kval[] = {
	{.opt = "--return", .val = 0x28},
	{.opt = "--esc", .val = 0x29},
	{.opt = "--bckspc", .val = 0x2a},
	{.opt = "--tab", .val = 0x2b},
	{.opt = "--phím cách", .val = 0x2c},
	{.opt = "--caps-lock", .val = 0x39},
	{.opt = "--f1", .val = 0x3a},
	{.opt = "--f2", .val = 0x3b},
	{.opt = "--f3", .val = 0x3c},
	{.opt = "--f4", .val = 0x3d},
	{.opt = "--f5", .val = 0x3e},
	{.opt = "--f6", .val = 0x3f},
	{.opt = "--f7", .val = 0x40},
	{.opt = "--f8", .val = 0x41},
	{.opt = "--f9", .val = 0x42},
	{.opt = "--f10", .val = 0x43},
	{.opt = "--f11", .val = 0x44},
	{.opt = "--f12", .val = 0x45},
	{.opt = "--insert", .val = 0x49},
	{.opt = "--home", .val = 0x4a},
	{.opt = "--pageup", .val = 0x4b},
	{.opt = "--del", .val = 0x4c},
	{.opt = "--end", .val = 0x4d},
	{.opt = "--pagedown", .val = 0x4e},
	{.opt = "--right", .val = 0x4f},
	{.opt = "--left", .val = 0x50},
	{.opt = "--down", .val = 0x51},
	{.opt = "--kp-enter", .val = 0x58},
	{.opt = "--up", .val = 0x52},
	{.opt = "--num-lock", .val = 0x53},
	{.opt = NULL}
  };

int keyboard_fill_report(char report[8], char buf[BUF_LEN], int *hold)
  {
	char *tok = strtok(buf, " ");
	khóa int = 0;
	int tôi = 0;

for (; tok != NULL; tok = strtok(NULL, " ")) {

if (strcmp(tok, "--quit") == 0)
			trả về -1;

if (strcmp(tok, "--hold") == 0) {
			*giữ = 1;
			Tiếp tục;
		}

nếu (khóa < 6) {
			for (i = 0; kval[i].opt != NULL; i++)
				if (strcmp(tok, kval[i].opt) == 0) {
					report[2 + key++] = kval[i].val;
					phá vỡ;
				}
			if (kval[i].opt != NULL)
				tiếp tục;
		}

nếu (khóa < 6)
			if (islow(tok[0])) {
				report[2 + key++] = (tok[0] - ('a' - 0x04));
				Tiếp tục;
			}

cho (i = 0; kmod[i].opt != NULL; i++)
			if (strcmp(tok, kmod[i].opt) == 0) {
				báo cáo[0] = báo cáo[0] | kmod[i].val;
				phá vỡ;
			}
		if (kmod[i].opt != NULL)
			tiếp tục;

nếu (khóa < 6)
			fprintf(stderr, "tùy chọn không xác định: %s\n", tok);
	}
	trả lại 8;
  }

tùy chọn cấu trúc tĩnh mmod[] = {
	{.opt = "--b1", .val = 0x01},
	{.opt = "--b2", .val = 0x02},
	{.opt = "--b3", .val = 0x04},
	{.opt = NULL}
  };

int mouse_fill_report(char report[8], char buf[BUF_LEN], int *hold)
  {
	char *tok = strtok(buf, " ");
	int mvt = 0;
	int tôi = 0;
	for (; tok != NULL; tok = strtok(NULL, " ")) {

if (strcmp(tok, "--quit") == 0)
			trả về -1;

if (strcmp(tok, "--hold") == 0) {
			*giữ = 1;
			Tiếp tục;
		}

cho (i = 0; mmod[i].opt != NULL; i++)
			if (strcmp(tok, mmod[i].opt) == 0) {
				báo cáo[0] = báo cáo[0] | mmod[i].val;
				phá vỡ;
			}
		if (mmod[i].opt != NULL)
			tiếp tục;

if (!(tok[0] == '-' && tok[1] == '-') && mvt < 2) {
			lỗi = 0;
			report[1 + mvt++] = (char)strtol(tok, NULL, 0);
			if (errno != 0) {
				fprintf(stderr, "Bad value:'%s'\n", tok);
				báo cáo[1 + mvt--] = 0;
			}
			Tiếp tục;
		}

fprintf(stderr, "tùy chọn không xác định: %s\n", tok);
	}
	trở lại 3;
  }

tùy chọn cấu trúc tĩnh jmod[] = {
	{.opt = "--b1", .val = 0x10},
	{.opt = "--b2", .val = 0x20},
	{.opt = "--b3", .val = 0x40},
	{.opt = "--b4", .val = 0x80},
	{.opt = "--hat1", .val = 0x00},
	{.opt = "--hat2", .val = 0x01},
	{.opt = "--hat3", .val = 0x02},
	{.opt = "--hat4", .val = 0x03},
	{.opt = "--hatneutral", .val = 0x04},
	{.opt = NULL}
  };

int joystick_fill_report(char report[8], char buf[BUF_LEN], int *hold)
  {
	char *tok = strtok(buf, " ");
	int mvt = 0;
	int tôi = 0;

*giữ = 1;

/*đặt vị trí mũ mặc định: trung lập */
	báo cáo [3] = 0x04;

for (; tok != NULL; tok = strtok(NULL, " ")) {

if (strcmp(tok, "--quit") == 0)
			trả về -1;

cho (i = 0; jmod[i].opt != NULL; i++)
			if (strcmp(tok, jmod[i].opt) == 0) {
				báo cáo[3] = (báo cáo[3] & 0xF0) | jmod[i].val;
				phá vỡ;
			}
		if (jmod[i].opt != NULL)
			tiếp tục;

if (!(tok[0] == '-' && tok[1] == '-') && mvt < 3) {
			lỗi = 0;
			report[mvt++] = (char)strtol(tok, NULL, 0);
			if (errno != 0) {
				fprintf(stderr, "Bad value:'%s'\n", tok);
				báo cáo[mvt--] = 0;
			}
			Tiếp tục;
		}

fprintf(stderr, "tùy chọn không xác định: %s\n", tok);
	}
	trả về 4;
  }

void print_options(char c)
  {
	int tôi = 0;

nếu (c == 'k') {
		printf("tùy chọn bàn phím:\n"
		       " --giữ\n");
		cho (i = 0; kmod[i].opt != NULL; i++)
			printf("\t\t%s\n", kmod[i].opt);
		printf("\n giá trị bàn phím:\n"
		       " [a-z] hoặc\n");
		for (i = 0; kval[i].opt != NULL; i++)
			printf("\t\t%-8s%s", kval[i].opt, i % 2 ? "\n" : "");
		printf("\n");
	} khác nếu (c == 'm') {
		printf("tùy chọn chuột:\n"
		       " --giữ\n");
		for (i = 0; mmod[i].opt != NULL; i++)
			printf("\t\t%s\n", mmod[i].opt);
		printf("\n giá trị chuột:\n"
		       " Hai số có dấu\n"
		       "--thoát để đóng\n");
	} khác {
		printf(" tùy chọn cần điều khiển:\n");
		cho (i = 0; jmod[i].opt != NULL; i++)
			printf("\t\t%s\n", jmod[i].opt);
		printf("\n giá trị cần điều khiển:\n"
		       " ba số có dấu\n"
		       "--thoát để đóng\n");
	}
  }

int main(int argc, const char *argv[])
  {
	const char *tên tệp = NULL;
	int fd = 0;
	char buf[BUF_LEN];
	int cmd_len;
	báo cáo char[8];
	int to_send = 8;
	int giữ = 0;
	fd_set rfds;
	int trả về, i;

nếu (argc < 3) {
		fprintf(stderr, "Cách sử dụng: %s tên nhà phát triển mouse|keyboard|joystick\n",
			argv[0]);
		trả về 1;
	}

if (argv[2][0] != 'k' && argv[2][0] != 'm' && argv[2][0] != 'j')
	  trở lại 2;

tên tệp = argv[1];

if ((fd = open(tên tệp, O_RDWR, 0666)) == -1) {
		lỗi (tên tệp);
		trở lại 3;
	}

print_options(argv[2][0]);

trong khi (42) {

FD_ZERO(&rfds);
		FD_SET(STDIN_FILENO, &rfds);
		FD_SET(fd, &rfds);

retval = select(fd + 1, &rfds, NULL, NULL, NULL);
		if (retval == -1 && errno == EINTR)
			tiếp tục;
		if (retval < 0) {
			perror("select()");
			trả về 4;
		}

nếu (FD_ISSET(fd, &rfds)) {
			cmd_len = read(fd, buf, BUF_LEN - 1);
			printf("báo cáo recv:");
			cho (i = 0; i < cmd_len; i++)
				printf(" %02x", buf[i]);
			printf("\n");
		}

nếu (FD_ISSET(STDIN_FILENO, &rfds)) {
			memset(báo cáo, 0x0, sizeof(báo cáo));
			cmd_len = đọc(STDIN_FILENO, buf, BUF_LEN - 1);

nếu (cmd_len == 0)
				phá vỡ;

buf[cmd_len - 1] = '\0';
			giữ = 0;

memset(báo cáo, 0x0, sizeof(báo cáo));
			nếu (argv[2][0] == 'k')
				to_send = keyboard_fill_report(báo cáo, buf, &hold);
			khác nếu (argv[2][0] == 'm')
				to_send = mouse_fill_report(báo cáo, buf, &hold);
			khác
				to_send = joystick_fill_report(báo cáo, buf, &hold);

nếu (to_send == -1)
				phá vỡ;

if (write(fd, report, to_send) != to_send) {
				lỗi (tên tệp);
				trả lại 5;
			}
			nếu (!giữ) {
				memset(báo cáo, 0x0, sizeof(báo cáo));
				if (write(fd, report, to_send) != to_send) {
					lỗi (tên tệp);
					trả lại 6;
				}
			}
		}
	}

đóng(fd);
	trả về 0;
  }
