.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/can/freescale/flexcan.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Trình điều khiển bộ điều khiển Flexcan CAN
=============================

Tác giả: Marc Kleine-Budde <mkl@pengutronix.de>,
Dario Binacchi <dario.binacchi@amarulasolutions.com>

Bật/tắt nhận khung hình RTR
===========================

Đối với hầu hết các lõi IP flexcan, trình điều khiển hỗ trợ 2 chế độ RX:

-FIFO
- hộp thư

Các lõi flexcan cũ hơn (được tích hợp vào i.MX25, i.MX28, i.MX35
và i.MX53 SOC) chỉ nhận các khung RTR nếu bộ điều khiển
được định cấu hình cho chế độ RX-FIFO.

Chế độ RX FIFO sử dụng phần cứng FIFO với độ sâu 6 khung hình CAN,
trong khi chế độ hộp thư sử dụng phần mềm FIFO có độ sâu lên tới 62
Khung CAN. Với sự trợ giúp của bộ đệm lớn hơn, chế độ hộp thư
hoạt động tốt hơn trong các tình huống tải hệ thống cao.

Vì việc tiếp nhận các khung RTR là một phần của tiêu chuẩn CAN, tất cả các khung flexcan
các lõi xuất hiện ở chế độ có thể nhận RTR.

Với cờ riêng "rx-rtr", khả năng nhận khung RTR có thể
được miễn trừ với việc mất khả năng nhận RTR
tin nhắn. Sự đánh đổi này có lợi trong một số trường hợp sử dụng nhất định.

"rx-rtr" đang bật
  Nhận khung RTR. (mặc định)

Bộ điều khiển CAN có thể và sẽ nhận các khung RTR.

Trên một số lõi IP, bộ điều khiển không thể nhận các khung RTR trong
  chế độ "hộp thư RX" hiệu quả hơn và sẽ sử dụng chế độ "RX FIFO"
  thay vào đó.

tắt "rx-rtr"

Từ bỏ khả năng nhận khung RTR. (không được hỗ trợ trên tất cả các lõi IP)

Chế độ này kích hoạt "Chế độ hộp thư RX" để có hiệu suất tốt hơn, trên
  Một số lõi IP khung RTR không thể nhận được nữa.

Cài đặt chỉ có thể được thay đổi nếu giao diện bị hỏng::

liên kết ip đặt dev can0 xuống
    ethtool --set-priv-flags can0 rx-rtr {tắt|bật}
    bộ liên kết ip dev can0 up