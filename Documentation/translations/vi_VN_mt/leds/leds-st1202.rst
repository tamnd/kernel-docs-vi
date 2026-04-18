.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/leds/leds-st1202.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================================
Trình điều khiển hạt nhân cho STMicroelectronics LED1202
========================================================

/sys/class/leds/<led>/hw_pattern
--------------------------------

Chỉ định mẫu phần cứng cho ST1202 LED. Bộ điều khiển LED
thực hiện 12 máy phát điện phía thấp với khả năng điều chỉnh độ sáng độc lập
kiểm soát. Bộ nhớ dễ bay hơi bên trong cho phép người dùng lưu trữ tới 8
các mẫu khác nhau. Mỗi mẫu là một cấu hình đầu ra cụ thể
xét về chu kỳ nhiệm vụ và thời lượng của PWM (ms).

Để tương thích với định dạng mẫu phần cứng, tối đa 8 bộ dữ liệu
độ sáng (PWM) và thời lượng phải được ghi vào hw_pattern.

- Thời lượng mẫu tối thiểu: 22 ms
- Thời lượng mẫu tối đa: 5660 ms

Định dạng của các giá trị mẫu phần cứng phải là:
"thời lượng sáng thời lượng sáng ..."

/sys/class/leds/<led>/repeat
----------------------------

Chỉ định số lặp lại mẫu, số này chung cho tất cả các kênh.
Mặc định là 1; số âm và 0 không hợp lệ.

Tệp này sẽ luôn trả về số lần lặp lại được ghi ban đầu.

Khi giá trị 255 được ghi vào nó, tất cả các mẫu sẽ lặp lại
vô thời hạn.