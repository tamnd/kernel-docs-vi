.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/tty/n_gsm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================================
Bộ ghép kênh GSM 0710 tty HOWTO
==============================

.. contents:: :local:

Kỷ luật dòng này thực hiện giao thức ghép kênh GSM 07.10
được trình bày chi tiết trong tài liệu 3GPP sau:

ZZ0000ZZ

Tài liệu này đưa ra một số gợi ý về cách sử dụng trình điều khiển này với GPRS và 3G
modem được kết nối với một cổng nối tiếp vật lý.

Cách sử dụng nó
=============

Trình khởi tạo cấu hình
----------------

#. Khởi tạo modem ở chế độ mux 0710 (thường là lệnh ZZ0000ZZ) thông qua
   cổng nối tiếp của nó. Tùy theo modem sử dụng mà bạn có thể truyền nhiều hay ít
   các tham số cho lệnh này.

#. Chuyển dòng nối tiếp sang sử dụng kỷ luật dòng n_gsm bằng cách sử dụng
   ZZ0000ZZ ioctl.

#. Định cấu hình mux bằng ZZ0000ZZ/ZZ0001ZZ ioctl nếu cần.

#. Định cấu hình mux bằng ZZ0000ZZ/ZZ0001ZZ ioctl.

#. Định cấu hình các DLC bằng ZZ0000ZZ/ZZ0001ZZ ioctl cho các cài đặt không mặc định.

#. Lấy số gsmtty cơ sở cho cổng nối tiếp đã sử dụng.

Các phần chính của chương trình khởi tạo
   (điểm khởi đầu tốt là util-linux-ng/sys-utils/ldattach.c)::

#include <stdio.h>
      #include <stdint.h>
      #include <linux/gsmmux.h>
      #include <linux/tty.h>

#define DEFAULT_SPEED B115200
      #define SERIAL_PORT /dev/ttyS0

int ldisc = N_GSM0710;
      cấu trúc gsm_config c;
      cấu trúc gsm_config_ext ce;
      cấu trúc gsm_dlci_config dc;
      cấu hình termios;
      uint32_t trước;

/*mở cổng nối tiếp kết nối với modem */
      fd = mở(SERIAL_PORT, O_RDWR ZZ0000ZZ O_NDELAY);

/* cấu hình cổng nối tiếp: tốc độ, điều khiển luồng ... */

/* gửi lệnh AT để chuyển modem sang chế độ CMUX
         và kiểm tra xem nó có thành công không (sẽ trả về OK) */
      write(fd, "AT+CMUX=0\r", 10);

/* Kinh nghiệm cho thấy một số modem cần một thời gian trước
         có thể trả lời gói MUX đầu tiên nên độ trễ
         có thể cần thiết ở đây trong một số trường hợp */
      ngủ(3);

/* sử dụng kỷ luật dòng n_gsm */
      ioctl(fd, TIOCSETD, &ldisc);

/* lấy cấu hình mở rộng n_gsm */
      ioctl(fd, GSMIOC_GETCONF_EXT, &ce);
      /* sử dụng tính năng duy trì 5 giây một lần để giám sát kết nối modem */
      ce.keep_alive = 500;
      /*đặt cấu hình mở rộng mới */
      ioctl(fd, GSMIOC_SETCONF_EXT, &ce);
      /*lấy cấu hình n_gsm */
      ioctl(fd, GSMIOC_GETCONF, &c);
      /* chúng tôi là người khởi tạo và cần mã hóa 0 (cơ bản) */
      c.initiator = 1;
      c.đóng gói = 0;
      /* modem của chúng tôi mặc định có kích thước tối đa là 127 byte */
      c.mru = 127;
      c.mtu = 127;
      /*đặt cấu hình mới */
      ioctl(fd, GSMIOC_SETCONF, &c);
      /* lấy cấu hình DLC 1 */
      dc.channel = 1;
      ioctl(fd, GSMIOC_GETCONF_DLCI, &dc);
      /* kênh người dùng đầu tiên được ưu tiên cao hơn */
      dc.ưu tiên = 1;
      /* đặt cấu hình cụ thể DLC 1 mới */
      ioctl(fd, GSMIOC_SETCONF_DLCI, &dc);
      /* lấy nút thiết bị gsmtty đầu tiên */
      ioctl(fd, GSMIOC_GETFIRST, &first);
      printf("dòng được trộn đầu tiên: /dev/gsmtty%i\n", first);

/* và đợi mãi mãi để kích hoạt kỷ luật dòng */
      daemon(0,0);
      tạm dừng();

#. Sử dụng các thiết bị này làm cổng nối tiếp đơn giản.

Ví dụ: có thể:

- sử dụng ZZ0002ZZ để gửi / nhận SMS trên ZZ0000ZZ
   - sử dụng ZZ0003ZZ để thiết lập liên kết dữ liệu trên ZZ0001ZZ

#. Đầu tiên hãy đóng tất cả các cổng ảo trước khi đóng cổng vật lý.

Lưu ý rằng sau khi đóng cổng vật lý, modem vẫn ở chế độ ghép kênh
   chế độ. Điều này có thể ngăn cản việc mở lại cổng thành công sau này. Để tránh
   tình huống này hoặc hãy đặt lại modem nếu phần cứng của bạn cho phép điều đó hoặc gửi
   ngắt kết nối khung lệnh theo cách thủ công trước khi khởi tạo chế độ ghép kênh
   lần thứ hai. Chuỗi byte cho khung lệnh ngắt kết nối là::

0xf9, 0x03, 0xef, 0x03, 0xc3, 0x16, 0xf9

Người yêu cầu cấu hình
----------------

#. Nhận lệnh ZZ0000ZZ thông qua cổng nối tiếp của nó, khởi tạo chế độ mux
   config.

#. Chuyển dòng nối tiếp sang sử dụng kỷ luật dòng ZZ0001ZZ bằng cách sử dụng
   ZZ0000ZZ ioctl.

#. Định cấu hình mux bằng ZZ0000ZZ/ZZ0001ZZ
   ioctl nếu cần.

#. Định cấu hình mux bằng ZZ0000ZZ/ZZ0001ZZ ioctl.

#. Định cấu hình các DLC bằng ZZ0000ZZ/ZZ0001ZZ ioctl cho các cài đặt không mặc định.

#. Lấy số gsmtty cơ sở cho cổng nối tiếp đã sử dụng::

#include <stdio.h>
        #include <stdint.h>
        #include <linux/gsmmux.h>
        #include <linux/tty.h>
        #define DEFAULT_SPEED B115200
        #define SERIAL_PORT /dev/ttyS0

int ldisc = N_GSM0710;
	cấu trúc gsm_config c;
	cấu trúc gsm_config_ext ce;
	cấu trúc gsm_dlci_config dc;
	cấu hình termios;
	uint32_t trước;

/*mở cổng nối tiếp*/
	fd = mở(SERIAL_PORT, O_RDWR ZZ0000ZZ O_NDELAY);

/* cấu hình cổng nối tiếp: tốc độ, điều khiển luồng ... */

/* lấy dữ liệu nối tiếp và kiểm tra tham số "AT+CMUX=command" ... */

/* sử dụng kỷ luật dòng n_gsm */
	ioctl(fd, TIOCSETD, &ldisc);

/* lấy cấu hình mở rộng n_gsm */
	ioctl(fd, GSMIOC_GETCONF_EXT, &ce);
	/* sử dụng tính năng duy trì 5 giây một lần để giám sát kết nối ngang hàng */
	ce.keep_alive = 500;
	/*đặt cấu hình mở rộng mới */
	ioctl(fd, GSMIOC_SETCONF_EXT, &ce);
	/*lấy cấu hình n_gsm */
	ioctl(fd, GSMIOC_GETCONF, &c);
	/* chúng tôi là người yêu cầu và cần mã hóa 0 (cơ bản) */
	c.initiator = 0;
	c.đóng gói = 0;
	/* modem của chúng tôi mặc định có kích thước tối đa là 127 byte */
	c.mru = 127;
	c.mtu = 127;
	/*đặt cấu hình mới */
	ioctl(fd, GSMIOC_SETCONF, &c);
	/* lấy cấu hình DLC 1 */
	dc.channel = 1;
	ioctl(fd, GSMIOC_GETCONF_DLCI, &dc);
	/* kênh người dùng đầu tiên được ưu tiên cao hơn */
	dc.ưu tiên = 1;
	/* đặt cấu hình cụ thể DLC 1 mới */
	ioctl(fd, GSMIOC_SETCONF_DLCI, &dc);
	/* lấy nút thiết bị gsmtty đầu tiên */
	ioctl(fd, GSMIOC_GETFIRST, &first);
	printf("dòng được trộn đầu tiên: /dev/gsmtty%i\n", first);

/* và đợi mãi mãi để kích hoạt kỷ luật dòng */
	daemon(0,0);
	tạm dừng();

03-11-08 - Eric Bénard - <eric@eukrea.com>
