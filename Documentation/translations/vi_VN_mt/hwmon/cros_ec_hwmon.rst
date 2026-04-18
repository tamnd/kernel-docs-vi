.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/cros_ec_hwmon.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân cros_ec_hwmon
=======================================

Chip được hỗ trợ:

* Bộ điều khiển nhúng ChromeOS.

Tiền tố: 'cros_ec'

Địa chỉ được quét: -

Tác giả:

- Thomas Weißschuh <linux@weissschuh.net>

Sự miêu tả
-----------

Trình điều khiển này thực hiện hỗ trợ cho các lệnh giám sát phần cứng được hiển thị bởi
Bộ điều khiển nhúng ChromeOS được sử dụng trong Chromebook và các thiết bị khác.

Các nhãn kênh được hiển thị qua hwmon được lấy từ chính EC.

Các tính năng được hỗ trợ
-------------------------

Bài đọc của người hâm mộ
    Luôn được hỗ trợ.

Tốc độ mục tiêu của quạt
    Nếu được EC hỗ trợ.

Chỉ số nhiệt độ
    Luôn được hỗ trợ.

Ngưỡng nhiệt độ
    Nếu được EC hỗ trợ.

Điều khiển quạt PWM
    Nếu EC cũng hỗ trợ cài đặt giá trị quạt PWM và chế độ quạt.

Lưu ý EC sẽ chuyển chế độ điều khiển quạt về tự động khi bị treo.
    Trình điều khiển này sẽ khôi phục trạng thái quạt về trạng thái trước khi bị treo khi hoạt động trở lại.

Nếu quạt điều khiển được thì driver này sẽ đăng ký quạt đó làm thiết bị làm mát
    trong khuôn khổ nhiệt là tốt.