.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/timers/hpet.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================================
Trình điều khiển hẹn giờ sự kiện có độ chính xác cao cho Linux
===========================================

Phần cứng Bộ đếm thời gian sự kiện có độ chính xác cao (HPET) tuân theo thông số kỹ thuật
của Intel và Microsoft, bản sửa đổi 1.

Mỗi HPET có một bộ đếm tốc độ cố định (ở mức 10+ MHz, do đó có "Độ chính xác cao")
và lên tới 32 bộ so sánh.  Thông thường ba hoặc nhiều bộ so sánh được cung cấp,
mỗi trong số đó có thể tạo ra các ngắt oneshot và ít nhất một trong số đó có
phần cứng bổ sung để hỗ trợ các ngắt định kỳ.  Các bộ so sánh là
còn được gọi là "bộ hẹn giờ", điều này có thể gây hiểu nhầm vì thông thường bộ hẹn giờ được
độc lập với nhau ... những thứ này chia sẻ một bộ đếm, làm phức tạp việc đặt lại.

Thiết bị HPET có thể hỗ trợ hai chế độ định tuyến ngắt.  Trong một chế độ,
bộ so sánh là nguồn ngắt bổ sung không có hệ thống cụ thể
vai trò.  Nhiều người viết x86 BIOS hoàn toàn không định tuyến các ngắt HPET, điều này
ngăn chặn việc sử dụng chế độ đó.  Họ hỗ trợ "sự thay thế di sản" khác
chế độ trong đó hai bộ so sánh đầu tiên chặn từ 8254 bộ định thời
và từ RTC.

Trình điều khiển hỗ trợ phát hiện phân bổ và khởi tạo trình điều khiển HPET
của HPET trước khi quy trình driver module_init được gọi.  Điều này cho phép
mã nền tảng sử dụng bộ định thời 0 hoặc 1 làm bộ định thời chính để chặn HPET
khởi tạo.  Một ví dụ về việc khởi tạo này có thể được tìm thấy trong
Arch/x86/kernel/hpet.c.

Trình điều khiển cung cấp không gian người dùng API giống với API được tìm thấy trong
Khung trình điều khiển RTC.  Một chương trình không gian người dùng mẫu được cung cấp trong
tập tin: mẫu/bộ hẹn giờ/hpet_example.c
