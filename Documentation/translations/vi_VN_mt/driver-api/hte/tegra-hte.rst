.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/hte/tegra-hte.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển nhà cung cấp hạt nhân HTE
==========================================

Sự miêu tả
-----------
Nhà cung cấp Nvidia tegra HTE còn được gọi là GTE (Công cụ đánh dấu thời gian chung)
trình điều khiển triển khai hai phiên bản GTE: 1) GPIO GTE và 2) LIC
(Bộ điều khiển ngắt kế thừa) IRQ GTE. Cả hai phiên bản GTE đều có dấu thời gian
từ bộ đếm hệ thống TSC có tốc độ xung nhịp 31,25 MHz và trình điều khiển
chuyển đổi tốc độ đánh dấu đồng hồ thành nano giây trước khi lưu trữ dưới dạng giá trị dấu thời gian.

GPIO GTE
--------

Phiên bản GTE này đánh dấu thời gian của GPIO theo thời gian thực. Để điều đó xảy ra GPIO
cần phải được cấu hình làm đầu vào. Chỉ có bộ điều khiển GPIO luôn bật (AON)
instance hỗ trợ GPIO đánh dấu thời gian trong thời gian thực vì nó được kết hợp chặt chẽ với
GPIO GTE. Để hỗ trợ điều này, GPIOLIB bổ sung thêm hai API tùy chọn như đã đề cập
bên dưới. Mã GPIO GTE hỗ trợ cả người tiêu dùng kernel và không gian người dùng. các
người tiêu dùng không gian kernel có thể nói chuyện trực tiếp với hệ thống con HTE trong khi không gian người dùng
yêu cầu dấu thời gian của người tiêu dùng đi qua khung GPIOLIB CDEV đến HTE
hệ thống con. Liên kết hte devicetree được mô tả tại
ZZ0000ZZ cung cấp một ví dụ về cách
người tiêu dùng có thể yêu cầu dòng GPIO.

Xem gpiod_enable_hw_timestamp_ns() và gpiod_disable_hw_timestamp_ns().

Đối với người sử dụng không gian người dùng, cờ GPIO_V2_LINE_FLAG_EVENT_CLOCK_HTE phải
được chỉ định trong các cuộc gọi IOCTL. Tham khảo ZZ0000ZZ, trong đó
trả về dấu thời gian tính bằng nano giây.

LIC (Bộ điều khiển ngắt kế thừa) IRQ GTE
-----------------------------------------

Phiên bản GTE này đánh dấu các dòng LIC IRQ trong thời gian thực. Cây thiết bị hte
ràng buộc được mô tả tại ZZ0000ZZ
cung cấp một ví dụ về cách người tiêu dùng có thể yêu cầu đường dây IRQ. Vì nó là một
ánh xạ một-một với nhà cung cấp IRQ GTE, người tiêu dùng có thể chỉ định IRQ một cách đơn giản
số mà họ quan tâm. Không có hỗ trợ người tiêu dùng không gian người dùng cho
phiên bản GTE này trong khung HTE.

Mã nguồn nhà cung cấp của cả hai phiên bản IRQ và GPIO GTE đều có tại
ZZ0000ZZ. Người lái thử
ZZ0001ZZ trình diễn cách sử dụng HTE API cho cả IRQ
và GPIO GTE.