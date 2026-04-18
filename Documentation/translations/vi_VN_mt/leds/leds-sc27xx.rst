.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/leds/leds-sc27xx.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================================
Trình điều khiển hạt nhân cho Spreadtrum SC27XX
===============================================

/sys/class/leds/<led>/hw_pattern
--------------------------------

Chỉ định mẫu phần cứng cho SC27XX LED. Dành cho SC27XX
Bộ điều khiển LED, nó chỉ hỗ trợ 4 giai đoạn để tạo thành một
mẫu phần cứng, được sử dụng để cấu hình thời gian tăng,
thời gian cao, thời gian rơi và thời gian thấp cho chế độ thở.

Đối với chế độ thở, SC27XX LED chỉ mong đợi một độ sáng
cho giai đoạn cao. Để tương thích với mẫu phần cứng
định dạng, chúng ta nên đặt độ sáng là 0 cho giai đoạn tăng, giảm
giai đoạn và giai đoạn thấp.

- Thời lượng giai đoạn tối thiểu: 125 ms
- Thời lượng giai đoạn tối đa: 31875 ms

Vì bước thời lượng của giai đoạn là 125 ms nên thời lượng phải là
hệ số nhân là 125, như 125ms, 250ms, 375ms, 500ms ... 31875ms.

Do đó, định dạng của các giá trị mẫu phần cứng phải là:
"0 tăng_duration độ sáng high_duration 0 fall_duration 0 low_duration".