.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/asus_ec_sensors.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân asus_ec_sensors
=================================

Các bảng được hỗ trợ:
 * MAXIMUS VI HERO
 * PRIME X470-PRO
 * PRIME X570-PRO
 * PRIME X670E-PRO WIFI
 * PRIME Z270-A
 * Pro WS TRX50-SAGE WIFI
 * Pro WS TRX50-SAGE WIFI A
 * Pro WS X570-ACE
 * Pro WS WRX90E-SAGE SE
 * ProArt X570-CREATOR WIFI
 * ProArt X670E-CREATOR WIFI
 * ProArt X870E-CREATOR WIFI
 * ProArt B550-CREATOR
 * ROG CROSSHAIR VIII DARK HERO
 * ROG CROSSHAIR VIII HERO (WI-FI)
 * ROG CROSSHAIR VIII FORMULA
 * ROG CROSSHAIR VIII HERO
 * ROG CROSSHAIR VIII IMPACT
 * ROG CROSSHAIR X670E EXTREME
 * ROG CROSSHAIR X670E HERO
 * ROG CROSSHAIR X670E GENE
 * ROG MAXIMUS X HERO
 * ROG MAXIMUS XI HERO
 * ROG MAXIMUS XI HERO (WI-FI)
 * ROG MAXIMUS Z690 FORMULA
 * ROG STRIX B550-E GAMING
 * ROG STRIX B550-I GAMING
 * ROG STRIX B650E-I GAMING WIFI
 * ROG STRIX B850-I GAMING WIFI
 * ROG STRIX X470-F GAMING
 * ROG STRIX X470-I GAMING
 * ROG STRIX X570-E GAMING
 * ROG STRIX X570-E GAMING WIFI II
 * ROG STRIX X570-F GAMING
 * ROG STRIX X570-I GAMING
 * ROG STRIX X670E-E GAMING WIFI
 * ROG STRIX X670E-I GAMING WIFI
 * ROG STRIX X870-F GAMING WIFI
 * ROG STRIX X870-I GAMING WIFI
 * ROG STRIX X870E-E GAMING WIFI
 * ROG STRIX X870E-H GAMING WIFI7
 * ROG STRIX Z390-F GAMING
 * ROG STRIX Z490-F GAMING
 * ROG STRIX Z690-A GAMING WIFI D4
 * ROG STRIX Z690-E GAMING WIFI
 * ROG STRIX Z790-E GAMING WIFI II
 * ROG STRIX Z790-H GAMING WIFI
 * ROG STRIX Z790-I GAMING WIFI
 * ROG ZENITH II EXTREME
 * ROG ZENITH II EXTREME ALPHA
 * TUF GAMING X670E PLUS
 * TUF GAMING X670E PLUS WIFI

tác giả:
    - Eugene Shalygin <eugene.shalygin@gmail.com>

Sự miêu tả:
------------
Bo mạch chính ASUS công bố thông tin giám sát phần cứng thông qua Super I/O
chip và các thanh ghi bộ điều khiển nhúng (EC) ACPI. Một số cảm biến
chỉ có sẵn thông qua EC.

Người lái xe nhận biết và đọc được các cảm biến sau:

1. Nhiệt độ chipset (PCH)
2. Nhiệt độ gói CPU
3. Nhiệt độ bo mạch chủ
4. Các bài đọc từ tiêu đề T_Sensor
5. Nhiệt độ VRM
6. Quạt CPU_Opt RPM
7. Quạt tản nhiệt VRM RPM
8. Quạt chipset RPM
9. Kết quả đọc từ tiêu đề "Đồng hồ đo lưu lượng nước" (RPM)
10. Các bài đọc từ tiêu đề nhiệt độ "Water In" và "Water Out"
11. Dòng điện CPU
12. Điện áp lõi CPU

Các giá trị cảm biến được đọc từ các thanh ghi EC và để tránh chạy đua với bảng
chương trình cơ sở trình điều khiển sẽ mua mutex ACPI, chương trình được WMI sử dụng khi nó
phương pháp truy cập EC.

Thông số mô-đun
-----------------
* mutex_path: chuỗi
		Trình điều khiển giữ đường dẫn đến mutex ACPI cho mỗi bảng (thực ra,
		đường dẫn hầu như giống hệt nhau đối với họ). Nếu ASUS thay đổi đường dẫn này
		trong bản cập nhật BIOS trong tương lai, tham số này có thể được sử dụng để ghi đè
		được lưu trữ trong giá trị trình điều khiển cho đến khi nó được cập nhật.
		Một chuỗi đặc biệt ":GLOBAL_LOCK" có thể được chuyển để sử dụng ACPI
		khóa toàn cầu thay vì một mutex chuyên dụng.