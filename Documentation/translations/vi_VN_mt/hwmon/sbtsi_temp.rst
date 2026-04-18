.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/sbtsi_temp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân sbtsi_temp
====================================

Phần cứng được hỗ trợ:

* Giao diện cảm biến nhiệt độ Sideband (SBI) (SB-TSI)
    thiết bị nhiệt độ SoC AMD tương thích.

Tiền tố: 'sbtsi_temp'

Địa chỉ được quét: Trình điều khiển này không hỗ trợ quét địa chỉ.

Để khởi tạo trình điều khiển này trên AMD CPU bằng SB-TSI
    hỗ trợ, số bus i2c sẽ là bus được kết nối từ bo mạch
    bộ điều khiển quản lý (BMC) sang CPU. Địa chỉ i2c được chỉ định trong
    Mục 6.3.1 của tham chiếu thanh ghi SoC: Địa chỉ SB-TSI thường là
    98h cho socket 0 và 90h cho socket 1, nhưng nó có thể thay đổi tùy theo phần cứng
    chân chọn địa chỉ.

Bảng dữ liệu: Giao diện và giao thức SB-TSI có sẵn như một phần của
               tham chiếu đăng ký SoC nguồn mở tại:

ZZ0000ZZ

Đặc tả Liên kết quản lý nền tảng nâng cao (APML) là
               có sẵn tại:

ZZ0000ZZ

Tác giả: Kun Yi <kunyi@google.com>

Sự miêu tả
-----------

Giao diện cảm biến nhiệt độ SBI (SB-TSI) là mô phỏng của phần mềm
và giao diện vật lý của cảm biến nhiệt độ từ xa 8 chân điển hình (RTS) trên
SoC AMD. Nó thực hiện một cảm biến nhiệt độ với số đọc và giới hạn
các thanh ghi mã hóa nhiệt độ theo gia số 0,125 từ 0 đến 255,875.
Giới hạn có thể được đặt thông qua các ngưỡng có thể ghi và nếu đạt đến sẽ kích hoạt
tín hiệu cảnh báo tương ứng.