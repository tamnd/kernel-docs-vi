.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/gpd-fan.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân gpd-fan
=========================

tác giả:
    - Cryolitia PukNgae <cryolitia@uniontech.com>

Sự miêu tả
------------

Thiết bị cầm tay của Công ty TNHH Công nghệ GPD Thâm Quyến cung cấp thông số đọc của quạt
và điều khiển quạt thông qua bộ điều khiển nhúng của chúng.

Thiết bị được hỗ trợ
-----------------

Hiện nay driver hỗ trợ các thiết bị cầm tay sau:

- GPD Win Mini (7840U)
 - GPD Win Mini (8840U)
 - GPD Win Mini (HX370)
 - GPD Túi 4
 - GPD Bộ Đôi
 - GPD Thắng Max 2 (6800U)
 - GPD Win Max 2 2023 (7840U)
 - GPD Win Max 2 2024 (8840U)
 - GPD Win Max 2 2025 (HX370)
 -GPD Win 4 (6800U)
 -GPD Win 4 (7840U)
 - GPD Micro PC 2

Thông số mô-đun
-----------------

gpd_fan_board
  Buộc cụ thể nên sử dụng mô-đun nào.
  Sử dụng nó như "gpd_fan_board=wm2".

- wm2
       -GPD Win 4 (7840U)
       - GPD Thắng Max 2 (6800U)
       - GPD Win Max 2 2023 (7840U)
       - GPD Win Max 2 2024 (8840U)
       - GPD Win Max 2 2025 (HX370)
   - win4
       -GPD Win 4 (6800U)
   - win_mini
       - GPD Win Mini (7840U)
       - GPD Win Mini (8840U)
       - GPD Win Mini (HX370)
       - GPD Túi 4
       - GPD Bộ Đôi
   - mpc2
       - GPD Micro PC 2

Mục nhập hệ thống
-------------

Các thuộc tính sau được hỗ trợ:

fan1_input
  Chỉ đọc. Đọc quạt hiện tại RPM.

pwm1_enable
  Đọc/Ghi. Bật điều khiển quạt thủ công. Viết "0" để tắt điều khiển và chạy
  ở tốc độ tối đa. Viết “1” để cài đặt thủ công, viết “2” để EC điều khiển
  quyết định tốc độ quạt. Đọc thuộc tính này để xem trạng thái hiện tại.

Lưu ý: Để đảm bảo an toàn cho thiết bị, khi cài đặt ở chế độ thủ công,
  tốc độ pwm sẽ được đặt ở giá trị tối đa (255) theo mặc định. Bạn có thể thiết lập
  một giá trị khác bằng cách viết pwm1 sau.

pwm1
  Đọc/Ghi. Đọc thuộc tính này để xem chu kỳ nhiệm vụ hiện tại trong phạm vi
  [0-255]. Khi pwm1_enable được đặt thành "1" (thủ công), hãy ghi bất kỳ giá trị nào vào
  phạm vi [0-255] để đặt tốc độ quạt.

Lưu ý: Nhiều bảng (ngoại trừ được liệt kê trong wm2 ở trên) không hỗ trợ đọc
  giá trị pwm hiện tại ở chế độ tự động. Điều đó sẽ trả về EOPNOTSUPP. Trong hướng dẫn sử dụng
  chế độ nó sẽ luôn trả về giá trị thực.