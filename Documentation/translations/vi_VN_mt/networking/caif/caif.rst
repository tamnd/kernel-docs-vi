.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/caif/caif.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>


==================
Sử dụng Linux CAIF
==================


:Bản quyền: ZZ0000ZZ ST-Ericsson AB 2010

:Tác giả: Sjur Brendeland/ sjur.brandeland@stericsson.com

Bắt đầu
=====

Nếu bạn đã biên dịch CAIF cho các mô-đun, hãy làm::

$modprobe crc_ccitt
    $modprobe caif
    $modprobe caif_socket
    $modprobe chnl_net


Chuẩn bị thiết lập với modem STE
====================================

Nếu bạn đang tiến hành tích hợp CAIF, bạn nên đảm bảo
rằng hạt nhân được xây dựng với sự hỗ trợ mô-đun.

Có một số điều cần tinh chỉnh lại để có được hosting TTY chính xác
thiết lập để nói chuyện với modem.
Vì ngăn xếp CAIF đang chạy trong kernel và chúng tôi muốn sử dụng phiên bản hiện có
TTY, chúng tôi đang cài đặt trình điều khiển nối tiếp vật lý của mình như dòng trên
thiết bị TTY.

Để đạt được điều này, chúng ta cần cài đặt ldisc N_CAIF từ không gian người dùng.
Lợi ích là chúng ta có thể kết nối với bất kỳ TTY nào.

Việc sử dụng tiện ích mở rộng Bắt đầu khung (STX) cũng phải được đặt là
tham số mô-đun "ser_use_stx".

Thông thường Kiểm tra khung luôn được sử dụng trên UART, nhưng điều này cũng được cung cấp dưới dạng
tham số mô-đun "ser_use_fcs".

::

$ modprobe caif_serial ser_ttyname=/dev/ttyS0 ser_use_stx=yes
    $ ifconfig caif_ttyS0 lên

PLEASE NOTE:
		Có một hạn chế trong Android shell.
		Nó chỉ chấp nhận một đối số cho insmod/modprobe!

Xử lý sự cố
================

Có các tham số debugfs được cung cấp cho giao tiếp nối tiếp.
/sys/kernel/debug/caif_serial/<tty-name>/

* ser_state: In trạng thái mặt nạ bit trong đó

- 0x02 có nghĩa là SENDING, đây là trạng thái nhất thời.
  - 0x10 có nghĩa là FLOW_OFF_SENT, tức là khung trước đó chưa được gửi
    và đang chặn hoạt động gửi tiếp theo. Dòng OFF đã được truyền bá
    tới tất cả các Kênh CAIF sử dụng TTY này.

* tty_status: In thông tin trạng thái tty mặt nạ bit

- 0x01 - tty-> cảnh báo đang bật.
  - 0x04 - tty->pack được bật.
  - 0x08 - tty->flow.tco_stopped đang bật.
  - 0x10 - tty->hw_stopped đang bật.
  - 0x20 - tty->flow.stopped đang bật.

* Last_tx_msg: blob nhị phân In khung truyền cuối cùng.

Điều này có thể được in bằng::

$od --format=x1 /sys/kernel/debug/caif_serial/<tty>/last_rx_msg.

Hai tin nhắn tx đầu tiên được gửi trông như thế này. Lưu ý: Ban đầu
  byte 02 là phần bắt đầu của phần mở rộng khung (STX) được sử dụng để đồng bộ lại
  khi có lỗi.

- Đếm::

0000000 02 05 00 00 03 01 d2 02
                 ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ
                 STX(1) ZZ0003ZZ ZZ0004ZZ
                    Chiều dài(2)ZZ0005ZZ |
                          Kênh điều khiển(1)
                             Lệnh:Đếm(1)
                                ID liên kết(1)
                                    Tổng kiểm tra(2)

- Thiết lập kênh::

0000000 02 07 00 00 00 21 a1 00 48 df
                 ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ
                 STX(1) ZZ0004ZZ ZZ0005ZZ ZZ0006ZZ
                    Chiều dài(2)ZZ0007ZZ ZZ0008ZZ |
                          Kênh điều khiển(1)
                             Lệnh:Thiết lập kênh(1)
                                Loại kênh(1)
                                    Mức độ ưu tiên và ID liên kết(1)
				      Điểm cuối(1)
					  Tổng kiểm tra(2)

*last_rx_msg: In frame được truyền cuối cùng.

Các thông báo RX cho LinkSetup trông gần giống nhau nhưng chúng có
  bit 0x20 được đặt trong bit lệnh và Thiết lập kênh đã thêm một byte
  trước Tổng kiểm tra chứa ID kênh.

NOTE:
	Một số Tin nhắn CAIF có thể được nối với nhau. Gỡ lỗi tối đa
	kích thước bộ đệm là 128 byte.

Tình huống lỗi
===============

- Last_tx_msg chứa thông báo thiết lập kênh và Last_rx_msg trống ->
  Máy chủ dường như có thể gửi UART qua, ít nhất là CAIF ldisc nhận được
  thông báo rằng việc gửi đã hoàn tất.

- Last_tx_msg chứa thông báo liệt kê và Last_rx_msg trống ->
  Máy chủ không thể gửi tin nhắn từ UART, tty chưa được gửi
  có thể hoàn thành hoạt động truyền tải.

- nếu /sys/kernel/debug/caif_serial/<tty>/tty_status khác 0 ở đó
  có thể có vấn đề khi truyền qua UART.

Ví dụ. Hệ thống dây máy chủ và modem không chính xác mà bạn thường thấy
  tty_status = 0x10 (hw_stopped) và ser_state = 0x10 (FLOW_OFF_SENT).

Bạn có thể sẽ thấy thông báo liệt kê trong Last_tx_message
  và trống Last_rx_message.