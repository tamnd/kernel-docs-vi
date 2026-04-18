.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/serial/serial-rs485.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Truyền thông nối tiếp RS485
==============================

1. Giới thiệu
===============

EIA-485, còn được gọi là TIA/EIA-485 hoặc RS-485, là tiêu chuẩn xác định
   đặc tính điện của bộ điều khiển và bộ thu để sử dụng trong hệ thống cân bằng
   hệ thống đa điểm kỹ thuật số.
   Tiêu chuẩn này được sử dụng rộng rãi cho truyền thông trong tự động hóa công nghiệp
   bởi vì nó có thể được sử dụng hiệu quả trên khoảng cách xa và trong lĩnh vực điện
   môi trường ồn ào.

2. Những cân nhắc liên quan đến phần cứng
==================================

Một số CPU/UART (ví dụ: Atmel AT91 hoặc 16C950 UART) có tích hợp sẵn
   chế độ bán song công có khả năng tự động điều khiển hướng đường truyền bằng cách
   chuyển đổi tín hiệu RTS hoặc DTR. Điều đó có thể được sử dụng để kiểm soát bên ngoài
   phần cứng bán song công như bộ thu phát RS485 hoặc bất kỳ kết nối RS232 nào
   các thiết bị bán song công như một số modem.

Đối với các bộ vi điều khiển này, trình điều khiển Linux phải có khả năng
   hoạt động ở cả hai chế độ và phải thực hiện ioctls thích hợp (xem phần sau)
   có sẵn ở cấp độ người dùng để cho phép chuyển từ chế độ này sang chế độ khác và
   ngược lại.

3. Cấu trúc dữ liệu đã có sẵn trong kernel
==================================================

Nhân Linux cung cấp struct serial_rs485 để xử lý RS485
   thông tin liên lạc. Cấu trúc dữ liệu này được sử dụng để thiết lập và định cấu hình RS485
   các tham số trong dữ liệu nền tảng và trong ioctls.

Cây thiết bị cũng có thể cung cấp các tham số thời gian khởi động RS485
   [#DT-bindings]_. Lõi nối tiếp điền vào cấu trúc serial_rs485 từ
   các giá trị do cây thiết bị đưa ra khi trình điều khiển gọi
   uart_get_rs485_mode().

Bất kỳ trình điều khiển nào cho các thiết bị có khả năng hoạt động cả RS232 và RS485 đều nên
   triển khai lệnh gọi lại ZZ0000ZZ và cung cấp ZZ0001ZZ
   trong ZZ0002ZZ. Lõi nối tiếp gọi ZZ0003ZZ để thực hiện
   phần cụ thể của thiết bị phản hồi với TIOCSRS485 ioctl (xem bên dưới). các
   Lệnh gọi lại ZZ0004ZZ nhận được một con trỏ tới cấu trúc đã được khử trùng
   nối tiếp_rs485. Không gian người dùng struct serial_rs485 cung cấp đã được làm sạch
   trước khi gọi ZZ0005ZZ bằng ZZ0006ZZ cho biết
   RS485 có những tính năng gì mà trình điều khiển hỗ trợ cho ZZ0007ZZ.
   TIOCGRS485 ioctl có thể được sử dụng để đọc lại struct serial_rs485
   phù hợp với cấu hình hiện tại.

.. kernel-doc:: include/uapi/linux/serial.h
   :identifiers: serial_rs485 uart_get_rs485_mode

4. Cách sử dụng từ cấp độ người dùng
========================

Từ cấp độ người dùng, cấu hình RS485 có thể được lấy/đặt bằng cách sử dụng cấu hình trước đó
   ioctls. Ví dụ: để đặt RS485, bạn có thể sử dụng mã sau ::

#include <linux/serial.h>

/* Bao gồm định nghĩa cho RS485 ioctls: TIOCGRS485 và TIOCSRS485 */
	#include <sys/ioctl.h>

/* Mở thiết bị cụ thể của bạn (ví dụ: /dev/mydevice): */
	int fd = open ("/dev/mydevice", O_RDWR);
	nếu (fd < 0) {
		/* Xử lý lỗi. Xem lỗi. */
	}

cấu trúc serial_rs485 rs485conf;

/* Kích hoạt chế độ RS485: */
	rs485conf.flags |= SER_RS485_ENABLED;

/* Đặt mức logic cho chân RTS bằng 1 khi gửi: */
	rs485conf.flags |= SER_RS485_RTS_ON_SEND;
	/* hoặc, đặt mức logic cho chân RTS bằng 0 khi gửi: */
	rs485conf.flags &= ~(SER_RS485_RTS_ON_SEND);

/* Đặt mức logic cho chân RTS bằng 1 sau khi gửi: */
	rs485conf.flags |= SER_RS485_RTS_AFTER_SEND;
	/* hoặc, đặt mức logic cho chân RTS bằng 0 sau khi gửi: */
	rs485conf.flags &= ~(SER_RS485_RTS_AFTER_SEND);

/* Đặt độ trễ rts trước khi gửi, nếu cần: */
	rs485conf.delay_rts_b Before_send = ...;

/* Đặt độ trễ rts sau khi gửi, nếu cần: */
	rs485conf.delay_rts_after_send = ...;

/* Đặt cờ này nếu bạn muốn nhận dữ liệu ngay cả khi đang gửi dữ liệu */
	rs485conf.flags |= SER_RS485_RX_DURING_TX;

if (ioctl (fd, TIOCSRS485, &rs485conf) < 0) {
		/* Xử lý lỗi. Xem lỗi. */
	}

/* Sử dụng các lệnh gọi tòa nhà đọc() và write() ở đây... */

/* Đóng thiết bị khi hoàn tất: */
	nếu (đóng (fd) < 0) {
		/* Xử lý lỗi. Xem lỗi. */
	}

5. Đánh địa chỉ đa điểm
========================

Nhân Linux cung cấp chế độ đánh địa chỉ cho nối tiếp RS-485 đa điểm
   đường truyền thông. Chế độ địa chỉ được kích hoạt với
   Cờ ZZ0000ZZ trong cấu trúc serial_rs485. Cấu trúc serial_rs485
   có hai cờ và trường bổ sung để cho phép nhận và đích
   địa chỉ.

Cờ chế độ địa chỉ:
	- ZZ0000ZZ: Đã bật chế độ đánh địa chỉ (cũng đặt ADDRB trong thuật ngữ).
	- ZZ0001ZZ: Đã bật địa chỉ nhận (bộ lọc).
	- ZZ0002ZZ: Đặt địa chỉ đích.

Các trường địa chỉ (được bật bằng cờ ZZ0000ZZ tương ứng):
	- ZZ0001ZZ: Nhận địa chỉ.
	- ZZ0002ZZ: Địa chỉ đích.

Khi địa chỉ nhận được thiết lập, việc liên lạc chỉ có thể xảy ra với
   thiết bị cụ thể và các thiết bị ngang hàng khác sẽ được lọc ra. Nó được để lại cho
   phía người nhận để thực thi việc lọc. Địa chỉ nhận sẽ bị xóa
   nếu ZZ0000ZZ không được đặt.

Lưu ý: không phải tất cả các thiết bị hỗ trợ RS485 đều hỗ trợ địa chỉ đa điểm.

6. Tài liệu tham khảo
=============

.. [#DT-bindings]	Documentation/devicetree/bindings/serial/rs485.txt
