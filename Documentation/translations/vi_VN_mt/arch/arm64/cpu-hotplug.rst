.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm64/cpu-hotplug.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _cpuhp_index:

======================
CPU Hotplug và ACPI
====================

Hotplug CPU trong thế giới arm64 thường được sử dụng để mô tả việc lấy kernel
CPU trực tuyến/ngoại tuyến sử dụng PSCI. Tài liệu này nói về phần mềm ACPI cho phép
Những CPU không có sẵn trong quá trình khởi động sẽ được thêm vào hệ thống sau này.

ZZ0000ZZ và ZZ0001ZZ đề cập đến trạng thái của CPU mà linux nhìn thấy.


CPU Hotplug trên hệ thống vật lý - CPU không có khi khởi động
----------------------------------------------------------

Các hệ thống vật lý cần đánh dấu CPU là ZZ0000ZZ chứ không phải ZZ0001ZZ là
là ZZ0002ZZ. Một ví dụ là một máy có ổ cắm kép, trong đó gói
trong một trong các ổ cắm có thể được thay thế trong khi hệ thống đang chạy.

Điều này không được hỗ trợ.

Trong thế giới arm64, CPU không phải là một thiết bị đơn lẻ mà là một phần của hệ thống.
Không có hệ thống nào hỗ trợ việc bổ sung (hoặc loại bỏ) vật lý CPU
trong khi hệ thống đang chạy và ACPI không thể mô tả đầy đủ
họ.

ví dụ. CPU mới đi kèm với bộ đệm mới, nhưng cấu trúc liên kết bộ đệm của nền tảng
được mô tả trong một bảng tĩnh, PPTT. Cách chia sẻ bộ nhớ đệm giữa các CPU là
không thể phát hiện được và phải được mô tả bằng phần sụn.

ví dụ. Bộ phân phối lại GIC cho mỗi CPU phải được trình điều khiển truy cập trong
boot để khám phá các tính năng được hỗ trợ trên toàn hệ thống. ACPI MADT GICC của ACPI
các cấu trúc có thể mô tả bộ phân phối lại được liên kết với CPU bị vô hiệu hóa, nhưng
không thể mô tả liệu nhà phân phối lại có thể truy cập được hay không, chỉ có điều là không
'luôn bật'.

Các bảng ACPI của arm64 giả định rằng mọi thứ được mô tả là ZZ0000ZZ.


CPU Hotplug trên hệ thống ảo - CPU không được bật khi khởi động
---------------------------------------------------------

Hệ thống ảo có ưu điểm là tất cả các thuộc tính của hệ thống sẽ
từng có có thể được mô tả khi khởi động. Không có cân nhắc về miền quyền lực
vì các thiết bị như vậy được mô phỏng.

Hỗ trợ CPU Hotplug trên hệ thống ảo. Nó khác biệt với vật chất
CPU Hotplug vì tất cả các tài nguyên được mô tả là ZZ0000ZZ, nhưng CPU có thể
được đánh dấu là bị vô hiệu hóa bởi phần sụn. Chỉ có hành vi trực tuyến/ngoại tuyến của CPU là
bị ảnh hưởng bởi firmware. Một ví dụ là khi máy ảo khởi động với
CPU duy nhất và các CPU bổ sung được thêm vào sau khi bộ điều phối đám mây triển khai
khối lượng công việc.

Đối với máy ảo, VMM (ví dụ: Qemu) đóng vai trò phần sụn.

Virtual hotplug được triển khai như một chính sách phần sụn ảnh hưởng đến CPU nào có thể được
đưa lên mạng. Phần sụn có thể thực thi chính sách của nó thông qua mã trả lại của PSCI. ví dụ.
ZZ0000ZZ.

Các bảng ACPI phải mô tả tất cả tài nguyên của máy ảo. CPU
chương trình cơ sở đó muốn vô hiệu hóa từ lúc khởi động (hoặc phiên bản mới hơn) sẽ không được
ZZ0000ZZ trong cấu trúc MADT GICC, nhưng nên có ZZ0001ZZ
được đặt bit để cho biết chúng có thể được kích hoạt sau này. Khởi động CPU phải được đánh dấu là
ZZ0002ZZ.  Cấu trúc GICR 'luôn bật' phải được sử dụng để mô tả
các nhà phân phối lại.

Các CPU được mô tả là ZZ0000ZZ nhưng không phải ZZ0001ZZ có thể được đặt thành bật
bằng phương thức _STA của đối tượng Bộ xử lý của DSDT. Trên hệ thống ảo phương pháp _STA
phải luôn báo cáo CPU là ZZ0002ZZ. Những thay đổi đối với chính sách phần sụn có thể
được thông báo cho HĐH thông qua kiểm tra thiết bị hoặc yêu cầu đẩy ra.

Các CPU được mô tả là ZZ0000ZZ trong bảng tĩnh, không nên có _STA của chúng
được sửa đổi linh hoạt bởi firmware. Các tính năng khởi động lại mềm như kexec sẽ
đọc lại các thuộc tính tĩnh của hệ thống từ các bảng tĩnh này và
có thể gặp trục trặc nếu những điều này không còn mô tả hệ thống đang chạy. Linux sẽ
khám phá lại các thuộc tính động của hệ thống từ phương pháp _STA sau
trong quá trình khởi động.