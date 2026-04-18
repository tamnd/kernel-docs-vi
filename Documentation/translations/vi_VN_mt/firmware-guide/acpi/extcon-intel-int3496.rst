.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/firmware-guide/acpi/extcon-intel-int3496.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================================================
Tài liệu trình điều khiển máy mở rộng thiết bị Intel INT3496 ACPI
=================================================================

Trình điều khiển extcon thiết bị Intel INT3496 ACPI là trình điều khiển cho ACPI
các thiết bị có acpi-id là INT3496, chẳng hạn như được tìm thấy trên
Máy tính bảng Intel Baytrail và Cherrytrail.

Thiết bị ACPI này mô tả cách HĐH có thể đọc id-pin của thiết bị'
Cổng USB-otg, cũng như cách nó có thể tùy chọn kích hoạt đầu ra Vbus trên
cổng otg và cách nó có thể tùy ý kiểm soát việc trộn các chân dữ liệu
giữa máy chủ USB và bộ điều khiển ngoại vi USB.

Các thiết bị ACPI thể hiện chức năng này bằng cách trả về một mảng có tối đa
đến 3 bộ mô tả gpio từ lệnh gọi ACPI _CRS (Cài đặt tài nguyên hiện tại):

==================================================================================
Chỉ mục 0 GPio đầu vào cho id-pin, mã này luôn hiện diện và hợp lệ
Chỉ mục 1 GPio đầu ra để kích hoạt đầu ra Vbus từ thiết bị sang otg
         port, hãy ghi 1 để kích hoạt đầu ra Vbus (bộ mô tả gpio này có thể
         vắng mặt hoặc không hợp lệ)
Chỉ mục 2 GPio đầu ra để kết nối các chân dữ liệu giữa máy chủ USB và
         bộ điều khiển ngoại vi USB, ghi 1 vào mux vào thiết bị ngoại vi
         bộ điều khiển
==================================================================================

Có sự ánh xạ giữa các chỉ số và ID kết nối GPIO như sau

======= =======
	chỉ số id 0
	chỉ số vbus 1
	chỉ số mux 2
	======= =======
