.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/serial/serial-iso7816.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================================
Truyền thông nối tiếp ISO7816
=============================

1. Giới thiệu
===============

ISO/IEC7816 là một loạt các tiêu chuẩn chỉ định thẻ mạch tích hợp (ICC)
  còn được gọi là thẻ thông minh.

2. Những cân nhắc liên quan đến phần cứng
==================================

Một số CPU/UART (ví dụ: Microchip AT91) có chế độ tích hợp có khả năng
  xử lý giao tiếp bằng thẻ thông minh.

Đối với các bộ vi điều khiển này, trình điều khiển Linux phải có khả năng
  hoạt động ở cả hai chế độ và phải thực hiện ioctls thích hợp (xem phần sau)
  có sẵn ở cấp độ người dùng để cho phép chuyển từ chế độ này sang chế độ khác và
  ngược lại.

3. Cấu trúc dữ liệu đã có sẵn trong kernel
==================================================

Nhân Linux cung cấp cấu trúc serial_iso7816 (xem [1]) để xử lý
  Truyền thông ISO7816. Cấu trúc dữ liệu này được sử dụng để thiết lập và cấu hình
  Các tham số ISO7816 trong ioctls.

Bất kỳ trình điều khiển nào cho các thiết bị có khả năng hoạt động cả RS232 và ISO7816 đều nên
  triển khai lệnh gọi lại iso7816_config trong cấu trúc uart_port. các
  serial_core gọi iso7816_config để thực hiện phần cụ thể của thiết bị để phản hồi
  tới TIOCGISO7816 và TIOCSISO7816 ioctls (xem bên dưới). Iso7816_config
  cuộc gọi lại nhận được một con trỏ tới struct serial_iso7816.

4. Cách sử dụng từ cấp độ người dùng
========================

Từ cấp độ người dùng, cấu hình ISO7816 có thể được lấy/đặt bằng cách sử dụng cấu hình trước đó
  ioctls. Ví dụ: để đặt ISO7816, bạn có thể sử dụng mã sau ::

#include <linux/serial.h>

/* Bao gồm định nghĩa cho ISO7816 ioctls: TIOCSISO7816 và TIOCGISO7816 */
	#include <sys/ioctl.h>

/* Mở thiết bị cụ thể của bạn (ví dụ: /dev/mydevice): */
	int fd = open ("/dev/mydevice", O_RDWR);
	nếu (fd < 0) {
		/* Xử lý lỗi. Xem lỗi. */
	}

cấu trúc serial_iso7816 iso7816conf;

/* Các trường dành riêng sẽ có giá trị bằng 0 */
	bộ nhớ(&iso7816conf, 0, sizeof(iso7816conf));

/* Kích hoạt chế độ ISO7816: */
	iso7816conf.flags |= SER_ISO7816_ENABLED;

/* Chọn giao thức: */
	/* T=0 */
	iso7816conf.flags |= SER_ISO7816_T(0);
	/* hoặc T=1 */
	iso7816conf.flags |= SER_ISO7816_T(1);

/* Đặt thời gian bảo vệ: */
	iso7816conf.tg = 2;

/*Đặt tần số xung nhịp*/
	iso7816conf.clk = 3571200;

/* Đặt hệ số truyền: */
	iso7816conf.sc_fi = 372;
	iso7816conf.sc_di = 1;

if (ioctl(fd_usart, TIOCSISO7816, &iso7816conf) < 0) {
		/* Xử lý lỗi. Xem lỗi. */
	}

/* Sử dụng các lệnh gọi tòa nhà đọc() và write() ở đây... */

/* Đóng thiết bị khi hoàn tất: */
	nếu (đóng (fd) < 0) {
		/* Xử lý lỗi. Xem lỗi. */
	}

5. Tài liệu tham khảo
=============

[1] bao gồm/uapi/linux/serial.h
