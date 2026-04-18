.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/intel-hfi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================================================
Giao diện phản hồi phần cứng để lên lịch trên Phần cứng Intel
=================================================================

Tổng quan
---------

Intel đã mô tả Giao diện phản hồi phần cứng (HFI) trong Intel 64 và
Hướng dẫn dành cho nhà phát triển phần mềm kiến trúc IA-32 (Intel SDM) Phần 3
14.6 [1]_.

HFI mang đến cho hệ điều hành hiệu suất và hiệu quả sử dụng năng lượng
dữ liệu khả năng cho mỗi CPU trong hệ thống. Linux có thể sử dụng thông tin từ
HFI để tác động đến quyết định sắp xếp nhiệm vụ.

Giao diện phản hồi phần cứng
-------------------------------

Giao diện phản hồi phần cứng cung cấp thông tin cho hệ điều hành
về hiệu suất và hiệu quả sử dụng năng lượng của từng CPU trong hệ thống. Mỗi
khả năng được đưa ra dưới dạng đại lượng không có đơn vị trong phạm vi [0-255]. Giá trị cao hơn
cho thấy khả năng cao hơn. Hiệu suất và hiệu suất năng lượng được báo cáo trong
những khả năng riêng biệt. Mặc dù trên một số hệ thống, hai số liệu này có thể
liên quan, chúng được chỉ định là các khả năng độc lập trong Intel SDM.

Những khả năng này có thể thay đổi trong thời gian chạy do những thay đổi trong
điều kiện hoạt động của hệ thống hoặc tác động của các yếu tố bên ngoài. tỷ lệ
thời điểm các khả năng này được cập nhật là dành riêng cho từng kiểu bộ xử lý. Bật
một số kiểu máy, khả năng được đặt khi khởi động và không bao giờ thay đổi. Trên những người khác,
khả năng có thể thay đổi cứ sau hàng chục mili giây. Ví dụ, một điều khiển từ xa
cơ chế có thể được sử dụng để giảm Công suất thiết kế nhiệt. Sự thay đổi như vậy có thể
được phản ánh trong HFI. Tương tự như vậy, nếu hệ thống cần được điều chỉnh do
nhiệt độ quá cao, HFI có thể phản ánh hiệu suất giảm trên các CPU cụ thể.

Hạt nhân hoặc daemon chính sách không gian người dùng có thể sử dụng những khả năng này để sửa đổi
quyết định bố trí nhiệm vụ. Ví dụ, nếu hiệu suất hoặc năng lượng
khả năng của một bộ xử lý logic nhất định trở thành 0, đó là dấu hiệu cho thấy
phần cứng khuyến nghị hệ điều hành không lên lịch bất kỳ tác vụ nào trên
bộ xử lý đó vì lý do hiệu suất hoặc hiệu quả năng lượng tương ứng.

Chi tiết triển khai cho Linux
--------------------------------

Cơ sở hạ tầng để xử lý các sự kiện ngắt nhiệt có hai phần. trong
Bảng vectơ cục bộ của APIC cục bộ của CPU, tồn tại một thanh ghi cho
Đăng ký theo dõi nhiệt. Thanh ghi này kiểm soát cách thức các ngắt được phân phối
tới CPU khi màn hình nhiệt tạo ra và ngắt. Thông tin chi tiết
có thể được tìm thấy trong Intel SDM Vol. 3 Mục 10.5 [1]_.

Bộ giám sát nhiệt có thể tạo ra các ngắt trên mỗi CPU hoặc trên mỗi gói. HFI
tạo ra các ngắt ở mức gói. Màn hình này được cấu hình và khởi tạo
thông qua một tập hợp các thanh ghi dành riêng cho máy. Cụ thể, HFI ngắt và
trạng thái được điều khiển thông qua các bit được chỉ định trong IA32_PACKAGE_THERM_INTERRUPT
và các thanh ghi IA32_PACKAGE_THERM_STATUS tương ứng. Có tồn tại một HFI
bảng cho mỗi gói. Thông tin chi tiết có thể được tìm thấy trong Intel SDM Vol. 3
Mục 14.9 [1]_.

Phần cứng gặp sự cố ngắt HFI sau khi cập nhật bảng HFI và đã sẵn sàng
để hệ điều hành sử dụng nó. CPU nhận được sự gián đoạn như vậy thông qua
mục nhiệt trong Bảng Vector cục bộ của APIC cục bộ.

Khi phục vụ ngắt như vậy, trình điều khiển HFI sẽ phân tích bảng đã cập nhật và
chuyển tiếp bản cập nhật tới không gian người dùng bằng khung thông báo nhiệt. Cho
rằng có thể có nhiều bản cập nhật HFI mỗi giây, các bản cập nhật được chuyển tiếp tới
không gian người dùng được điều chỉnh với tốc độ CONFIG_HZ trong nháy mắt.

Tài liệu tham khảo
------------------

.. [1] https://www.intel.com/sdm