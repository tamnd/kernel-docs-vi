.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/serial/driver.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
API nối tiếp cấp thấp
====================


Tài liệu này nhằm mục đích tổng quan ngắn gọn về một số khía cạnh của ấn phẩm mới
người lái xe.  Nó chưa đầy đủ, bất kỳ câu hỏi nào bạn có nên được chuyển đến
<rmk@arm.linux.org.uk>

Việc triển khai tham chiếu được chứa trong amba-pl011.c.



Trình điều khiển phần cứng nối tiếp cấp thấp
--------------------------------

Trình điều khiển phần cứng nối tiếp cấp thấp chịu trách nhiệm cung cấp cổng
thông tin (được xác định bởi uart_port) và một tập hợp các phương thức điều khiển (được xác định
bởi uart_ops) vào trình điều khiển nối tiếp lõi.  Trình điều khiển cấp thấp cũng
chịu trách nhiệm xử lý các ngắt cho cổng và cung cấp bất kỳ
hỗ trợ bảng điều khiển.


Hỗ trợ bảng điều khiển
---------------

Lõi nối tiếp cung cấp một số chức năng trợ giúp.  Điều này bao gồm
giải mã các đối số dòng lệnh (uart_parse_options()).

Ngoài ra còn có một hàm trợ giúp (uart_console_write()) thực hiện một
viết từng ký tự, dịch các dòng mới sang chuỗi CRLF.
Người viết trình điều khiển được khuyến nghị sử dụng chức năng này thay vì thực hiện
phiên bản riêng của họ.


Khóa
-------

Trình điều khiển phần cứng cấp thấp có trách nhiệm thực hiện
khóa cần thiết bằng cách sử dụng cổng-> khóa.  Có một số trường hợp ngoại lệ (mà
được mô tả trong danh sách struct uart_ops bên dưới.)

Có hai ổ khóa.  Một spinlock trên mỗi cổng và một semaphore tổng thể.

Từ góc độ trình điều khiển cốt lõi, port->lock khóa như sau
dữ liệu::

cổng->mctrl
	cổng->icount
	port->state->xmit.head (circ_buf->head)
	port->state->xmit.tail (circ_buf->tail)

Trình điều khiển cấp thấp có thể tự do sử dụng khóa này để cung cấp thêm bất kỳ
khóa.

Semaphore port_sem được sử dụng để bảo vệ chống lại các cổng được thêm vào/
bị xóa hoặc cấu hình lại vào những thời điểm không thích hợp. Kể từ v2.6.27, điều này
semaphore đã là thành viên 'mutex' của cấu trúc tty_port và
thường được gọi là cổng mutex.


uart_ops
--------

.. kernel-doc:: include/linux/serial_core.h
   :identifiers: uart_ops

Các chức năng khác
---------------

.. kernel-doc:: drivers/tty/serial/serial_core.c
   :identifiers: uart_update_timeout uart_get_baud_rate uart_get_divisor
           uart_match_port uart_write_wakeup uart_register_driver
           uart_unregister_driver uart_suspend_port uart_resume_port
           uart_add_one_port uart_remove_one_port uart_console_write
           uart_parse_earlycon uart_parse_options uart_set_options
           uart_get_lsr_info uart_handle_dcd_change uart_handle_cts_change
           uart_try_toggle_sysrq

.. kernel-doc:: include/linux/serial_core.h
   :identifiers: uart_port_tx_limited uart_port_tx

Ghi chú khác
-----------

Dự định một ngày nào đó sẽ loại bỏ các mục 'không sử dụng' khỏi uart_port và
cho phép trình điều khiển cấp thấp đăng ký uart_port của riêng họ với
cốt lõi.  Điều này sẽ cho phép trình điều khiển sử dụng uart_port làm con trỏ tới
cấu trúc chứa cả mục uart_port với phần mở rộng của riêng chúng,
do đó::

cấu trúc my_port {
		cấu trúc cổng uart_port;
		int my_stuff;
	};

Đường dây điều khiển modem qua GPIO
----------------------------

Một số trợ giúp được cung cấp để thiết lập/nhận các đường điều khiển modem thông qua GPIO.

.. kernel-doc:: drivers/tty/serial/serial_mctrl_gpio.c
   :identifiers: mctrl_gpio_init mctrl_gpio_to_gpiod
           mctrl_gpio_set mctrl_gpio_get mctrl_gpio_enable_ms
           mctrl_gpio_disable_ms_sync mctrl_gpio_disable_ms_no_sync
