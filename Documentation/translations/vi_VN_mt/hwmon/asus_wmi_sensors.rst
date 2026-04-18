.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/asus_wmi_sensors.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân asus_wmi_sensors
==========================================

Các bảng được hỗ trợ:
 * PRIME X399-A,
 * PRIME X470-PRO,
 * ROG CROSSHAIR VI EXTREME,
 * ROG CROSSHAIR VI HERO,
 * ROG CROSSHAIR VI HERO (WI-FI AC),
 * ROG CROSSHAIR VII HERO,
 * ROG CROSSHAIR VII HERO (WI-FI),
 * ROG STRIX B450-E GAMING,
 * ROG STRIX B450-F GAMING,
 * ROG STRIX B450-I GAMING,
 * ROG STRIX X399-E GAMING,
 * ROG STRIX X470-F GAMING,
 * ROG STRIX X470-I GAMING,
 * ROG ZENITH EXTREME,
 * ROG ZENITH EXTREME ALPHA.

tác giả:
    - Ed Brindley <kernel@maidavale.org>

Sự miêu tả:
------------
Bo mạch chính ASUS xuất bản thông tin giám sát phần cứng thông qua giao diện WMI.

Giao diện ASUS WMI cung cấp các phương thức để lấy danh sách các cảm biến và giá trị của
như vậy, được trình điều khiển này sử dụng để xuất bản các chỉ số cảm biến đó tới
Hệ thống HWMON.

Người lái xe nhận biết và đọc được các cảm biến sau:
 * Điện áp lõi CPU,
 * Điện áp CPU SOC,
 * Điện áp DRAM,
 * Điện áp VDDP,
 * Điện áp 1.8V PLL,
 * Điện áp +12V,
 * Điện áp +5V,
 * Điện áp 3VSB,
 * Điện áp VBAT,
 * Điện áp AVCC3,
 * Điện áp SB 1.05V,
 * Điện áp lõi CPU,
 * Điện áp CPU SOC,
 * Điện áp DRAM,
 * Quạt CPU RPM,
 * Quạt khung 1 RPM,
 * Quạt khung 2 RPM,
 * Quạt khung 3 RPM,
 * Quạt HAMP RPM,
 * Máy bơm nước RPM,
 * CPU OPT RPM,
 * Lưu lượng nước RPM,
 * Máy bơm AIO RPM,
 * Nhiệt độ CPU,
 * Nhiệt độ ổ cắm CPU,
 * Nhiệt độ bo mạch chủ,
 * Nhiệt độ Chipset,
 * Cảm biến nhiệt độ 1,
 * Nhiệt độ CPU VRM,
 * Nước vào,
 * Hết nước,
 * Dòng điện đầu ra CPU VRM.

Các vấn đề đã biết:
 * Việc triển khai WMI trong một số BIOS của Asus có lỗi. Điều này có thể dẫn đến
   quạt dừng, quạt bị kẹt ở tốc độ tối đa hoặc chỉ số nhiệt độ
   bị mắc kẹt. Đây không phải là vấn đề với trình điều khiển mà là BIOS. thủ tướng
   X470 Pro có vẻ đặc biệt tệ cho việc này. WMI càng thường xuyên
   giao diện được thăm dò thì khả năng điều này xảy ra càng lớn. Cho đến khi bạn
   đã đưa máy tính của bạn vào một bài kiểm tra ngâm kéo dài trong khi bỏ phiếu
   cảm biến thường xuyên, đừng để máy tính của bạn không được giám sát. Đang nâng cấp lên mới
   Phiên bản BIOS với phiên bản phương thức lớn hơn hoặc bằng hai nên
   khắc phục vấn đề.
 * Một số bảng báo cáo điện áp 12v là ~10v.