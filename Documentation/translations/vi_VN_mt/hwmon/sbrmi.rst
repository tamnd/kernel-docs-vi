.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/sbrmi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân sbrmi
===================

Phần cứng được hỗ trợ:

* AMD SoC tương thích với Giao diện quản lý từ xa Sideband (SB-RMI)
    thiết bị được kết nối với BMC thông qua APML.

Tiền tố: 'sbrmi'

Địa chỉ được quét: Trình điều khiển này không hỗ trợ quét địa chỉ.

Để khởi tạo trình điều khiển này trên AMD CPU bằng SB-RMI
    hỗ trợ, số bus i2c sẽ là bus được kết nối từ bo mạch
    bộ điều khiển quản lý (BMC) sang CPU.
    Địa chỉ SMBus thực sự là 7 bit. Một số nhà cung cấp và SMBus
    thông số kỹ thuật hiển thị địa chỉ là 8 bit, căn trái bằng R/W
    bit dưới dạng ghi (0) tạo thành bit 0. Một số nhà cung cấp chỉ sử dụng 7 bit
    để mô tả địa chỉ.
    Như đã đề cập trong thông số kỹ thuật APML của AMD, Địa chỉ SB-RMI là
    thông thường 78h(0111 100W) hoặc 3Ch(011 1100) cho ổ cắm 0 và 70h(0111 000W)
    hoặc 38h(011 1000) cho socket 1, nhưng nó có thể thay đổi tùy theo phần cứng
    chân chọn địa chỉ.

Bảng dữ liệu: Giao diện và giao thức SB-RMI cùng với Advanced
               Thông số kỹ thuật của Liên kết quản lý nền tảng (APML) có sẵn
               như một phần của tham chiếu đăng ký SoC nguồn mở tại:

ZZ0000ZZ

Tác giả: Akshay Gupta <akshay.gupta@amd.com>

Sự miêu tả
-----------

APML cung cấp cách giao tiếp với giao diện Quản lý từ xa SB
(SB-RMI) từ máy chủ SMBus bên ngoài có thể được sử dụng để báo cáo ổ cắm
cấp nguồn cho nền tảng AMD bằng lệnh hộp thư và giống với điều khiển từ xa 8 chân thông thường
giao diện I2C của cảm biến nguồn tới BMC.

Trình điều khiển này thực hiện nguồn điện hiện tại với nắp nguồn và nắp nguồn tối đa.

giao diện sysfs
---------------
Cảm biến nguồn có thể được truy vấn và thiết lập thông qua giao diện ZZ0000ZZ tiêu chuẩn
trên ZZ0001ZZ, trong thư mục ZZ0002ZZ để lấy một số giá trị
của ZZ0003ZZ (tìm kiếm ZZ0004ZZ sao cho ZZ0005ZZ có
nội dung ZZ0006ZZ)

===================== ==============================================================
Tên Perm Mô tả
===================== ==============================================================
power1_input RO Hiện tại Công suất tiêu thụ
power1_cap RW Giới hạn nguồn có thể được đặt trong khoảng từ 0 đến power1_cap_max
power1_cap_max RO Giới hạn công suất tối đa được SMU FW tính toán và báo cáo
===================== ==============================================================

Ví dụ sau đây cho thấy thuộc tính 'Power' từ địa chỉ i2c
có thể được giám sát bằng các tiện ích không gian người dùng như nhị phân ZZ0000ZZ ::

# sensors
  sbrmi-i2c-1-38
  Bộ chuyển đổi: Bộ chuyển đổi bcm2835 I2C
  công suất1: 61,00 W (nắp = 225,00 W)

sbrmi-i2c-1-3c
  Bộ chuyển đổi: Bộ chuyển đổi bcm2835 I2C
  công suất1: 28,39 W (nắp = 224,77 W)
  #

Ngoài ra, Dưới đây cho thấy cách nhận và đặt các giá trị từ các mục sysfs riêng lẻ ::
  # cat /sys/class/hwmon/hwmon1/power1_cap_max
  225000000

# echo 180000000 > /sys/class/hwmon/hwmon1/power1_cap
  # cat /sys/class/hwmon/hwmon1/power1_cap
  180000000