.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/leds/ledtrig-usbport.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Cổng USB Kích hoạt cổng LED
====================

Trình kích hoạt LED này có thể được sử dụng để báo hiệu cho người dùng về sự hiện diện của thiết bị USB
trong một cổng nhất định. Nó chỉ đơn giản là bật LED khi thiết bị xuất hiện và tắt nó đi
khi nó biến mất.

Nó yêu cầu chọn các cổng USB cần được quan sát. Tất cả những cái có sẵn là
được liệt kê dưới dạng các mục riêng biệt trong thư mục con "cổng". Việc lựa chọn được xử lý bởi
lặp lại "1" đến một cổng đã chọn.

Xin lưu ý rằng trình kích hoạt này cho phép chọn nhiều cổng USB cho một cổng
LED.

Điều này có thể hữu ích trong hai trường hợp:

1) Thiết bị có một USB LED và một vài cổng vật lý
====================================================

Trong trường hợp như vậy LED sẽ được bật miễn là có ít nhất một kết nối
Thiết bị USB.

2) Thiết bị có cổng vật lý được xử lý bởi một số bộ điều khiển
=========================================================

Một số thiết bị có thể có một bộ điều khiển cho mỗi tiêu chuẩn PHY. Ví dụ. Vật lý USB 3.0
cổng có thể được xử lý bởi ohci-platform, ehci-platform và xhci-hcd. Nếu có
rất có thể chỉ có một người dùng LED muốn gán cổng từ cả 3 hub.


Trình kích hoạt này có thể được kích hoạt từ không gian người dùng trên các thiết bị lớp led như được hiển thị
dưới đây::

echo cổng USB > kích hoạt

Điều này thêm các thuộc tính sysfs vào LED được ghi lại trong:
Tài liệu/ABI/thử nghiệm/sysfs-class-led-trigger-usbport

Trường hợp sử dụng ví dụ::

echo cổng USB > kích hoạt
  echo 1 > cổng/usb1-port1
  echo 1 > cổng/usb2-port1
  cổng mèo/usb1-port1
  echo 0 > cổng/usb1-port1
