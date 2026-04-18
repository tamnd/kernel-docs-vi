.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/chipcap2.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân ChipCap2
======================

Chip được hỗ trợ:

* Amphenol CC2D23, CC2D23S, CC2D25, CC2D25S, CC2D33, CC2D33S, CC2D35, CC2D35S

Tiền tố: 'chipcap2'

Địa chỉ được quét: -

Bảng dữ liệu: ZZ0000ZZ

Tác giả:

- Javier Carrasco <javier.carrasco.cruz@gmail.com>

Sự miêu tả
-----------

Trình điều khiển này triển khai hỗ trợ cho Amphenol ChipCap 2, độ ẩm và
họ chip nhiệt độ. Nhiệt độ được đo bằng mili độ C,
độ ẩm tương đối được biểu thị bằng phần trăm mili. Các phạm vi đo
như sau:

- Độ ẩm tương đối: 0 đến 100000 pcm (độ phân giải 14-bit)
  - Nhiệt độ: -40000 đến +125000 m°C (độ phân giải 14-bit)

Thiết bị giao tiếp với giao thức I2C và sử dụng địa chỉ I2C 0x28
theo mặc định.

Tùy thuộc vào cấu hình phần cứng, có thể kiểm soát tối đa hai cảnh báo độ ẩm
giá trị tối thiểu và tối đa được cung cấp. Ngưỡng và độ trễ của chúng có thể
được cấu hình thông qua sysfs.

Ngưỡng và độ trễ phải được cung cấp theo phần trăm. Những giá trị này
có thể bị cắt bớt để phù hợp với độ phân giải của thiết bị 14 bit (6,1 pcm/LSB)

Sự cố đã biết
------------

Trình điều khiển không hỗ trợ sửa đổi độ dài cửa sổ lệnh và địa chỉ I2C.

giao diện sysfs
---------------

Danh sách sau đây bao gồm các thuộc tính sysfs mà trình điều khiển luôn cung cấp,
quyền của họ và mô tả ngắn gọn:

================================ ======= =============================================
Tên Perm Mô tả
================================ ======= =============================================
temp1_input: Đầu vào nhiệt độ RO
độ ẩm1_input: đầu vào độ ẩm RO
================================ ======= =============================================

Danh sách sau đây bao gồm các thuộc tính sysfs mà trình điều khiển có thể cung cấp
tùy thuộc vào cấu hình phần cứng:

================================ ======= =============================================
Tên Perm Mô tả
================================ ======= =============================================
độ ẩm1_min: giới hạn độ ẩm RW thấp. Các phép đo dưới
                                        giới hạn này kích hoạt báo động độ ẩm thấp
độ ẩm1_max: giới hạn độ ẩm RW cao. Số đo trên
                                        giới hạn này kích hoạt báo động độ ẩm cao
độ ẩm1_min_hyst: độ trễ RW độ ẩm thấp
độ ẩm1_max_hyst: RW độ trễ độ ẩm cao
độ ẩm1_min_alarm: Chỉ báo cảnh báo độ ẩm RO thấp
độ ẩm1_max_alarm: Chỉ báo cảnh báo độ ẩm RO cao
================================ ======= =============================================