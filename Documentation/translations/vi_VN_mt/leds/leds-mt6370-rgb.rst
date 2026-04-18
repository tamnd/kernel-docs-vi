.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/leds/leds-mt6370-rgb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================
Thiết bị dành cho Mediatek MT6370 RGB LED
=============================================

Sự miêu tả
-----------

MT6370 tích hợp trình điều khiển RGB LED bốn kênh, được thiết kế để cung cấp
nhiều hiệu ứng ánh sáng cho các ứng dụng thiết bị di động. Các thiết bị RGB LED
bao gồm bộ điều khiển chuỗi LED thông minh và nó có thể điều khiển 3 kênh đèn LED với
dòng điện chìm lên tới 24mA và đèn báo nguồn tốt CHG_VIN LED có bồn rửa
dòng điện lên tới 6mA. Nó cung cấp ba chế độ hoạt động cho đèn LED RGB:
PWM Chế độ làm mờ, chế độ kiểu nhịp thở và chế độ dòng điện không đổi. thiết bị
có thể tăng hoặc giảm độ sáng của RGB LED thông qua giao diện I2C.

Mẫu hơi thở cho một kênh có thể được lập trình bằng cách sử dụng trình kích hoạt "mẫu",
sử dụng thuộc tính hw_pattern.

/sys/class/leds/<led>/hw_pattern
--------------------------------

Chỉ định mẫu hơi thở phần cứng cho MT6370 RGB LED.

Kiểu nhịp thở là một chuỗi các cặp thời gian, với thời gian giữ được biểu thị bằng
mili giây. Và độ sáng được điều khiển bởi
'/sys/class/leds/<led>/độ sáng'. Mẫu không bao gồm độ sáng
thiết lập. Mẫu phần cứng chỉ kiểm soát thời gian cho từng giai đoạn mẫu
tùy thuộc vào cài đặt độ sáng hiện tại.

Sơ đồ mẫu::

"0 Tr1 0 Tr2 0 Tf1 0 Tf2 0 Ton 0 Toff" --> '0' cho mã độ sáng giả

^
          |           =============
          |          / \ /
    Icurr |         / \ /
          |        / \ /
          |       /\ /.....lặp lại
          |      / \ /
          |   --- --- ---
          |--- --- ---
          +-----------------------------------==============-----------> Thời gian
          < Tr1><Tr2>< Tấn ><Tf1><Tf2 >< Toff >< Tr1><Tr2>

Mô tả thời gian:

* Tr1: Thời gian tăng lần đầu khi tải 0% - 30%.
  * Tr2: Lần tăng thứ 2 khi tải 31% - 100%.
  * Tôn: Đúng thời gian tải 100%.
  * Tf1: Thời gian rơi lần đầu khi tải 100% - 31%.
  * Tf2: Thời gian rơi thứ hai khi tải từ 30% về 0%.
  * Toff: Thời gian tắt khi tải 0%.

* Tr1/Tr2/Tf1/Tf2/Ton: 125ms đến 3125ms, 200ms mỗi bước.
  * Toff: 250ms đến 6250ms, 400ms mỗi bước.

Ví dụ về mẫu::

"0 125 0 125 0 125 0 125 0 625 0 1050"

Điều này sẽ định cấu hình Tr1/Tr2/Tf1/Tf2 thành 125m, Ton thành 625ms và Toff thành 1050ms.