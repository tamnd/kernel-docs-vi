.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/soc/clocking.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================
Đồng hồ âm thanh
================

Văn bản này mô tả các thuật ngữ xung nhịp âm thanh trong ASoC và âm thanh kỹ thuật số trong
chung. Lưu ý: Đồng hồ âm thanh có thể phức tạp!


Đồng hồ chủ
------------

Mọi hệ thống con âm thanh đều được điều khiển bởi đồng hồ chính (đôi khi được gọi là MCLK
hoặc SYSCLK). Đồng hồ chủ âm thanh này có thể được lấy từ một số nguồn
(ví dụ: đồng hồ pha lê, PLL, CPU) và chịu trách nhiệm sản xuất chính xác
phát lại âm thanh và ghi lại tốc độ lấy mẫu.

Một số đồng hồ chính (ví dụ: đồng hồ dựa trên PLL và CPU) có thể được cấu hình theo cách đó.
tốc độ của chúng có thể được thay đổi bằng phần mềm (tùy thuộc vào việc sử dụng hệ thống và để tiết kiệm
quyền lực). Các đồng hồ chính khác được cố định ở tần số đã đặt (tức là tinh thể).


Đồng hồ DAI
-----------
Giao diện âm thanh kỹ thuật số thường được điều khiển bởi Đồng hồ bit (thường được gọi là
như BCLK). Đồng hồ này được sử dụng để điều khiển dữ liệu âm thanh kỹ thuật số trên liên kết
giữa codec và CPU.

DAI cũng có đồng hồ khung để báo hiệu sự bắt đầu của mỗi khung âm thanh. Cái này
đồng hồ đôi khi được gọi là LRC (đồng hồ bên trái) hoặc FRAME. Đồng hồ này
chạy ở tốc độ mẫu chính xác (LRC = Tốc độ).

Đồng hồ bit có thể được tạo như sau: -

- BCLK = MCLK/x, hoặc
- BCLK = LRC * x, hoặc
- BCLK = LRC * Kênh * Kích thước Word

Mối quan hệ này phụ thuộc vào codec hoặc SoC CPU nói riêng. Nói chung
tốt nhất nên cấu hình BCLK ở tốc độ thấp nhất có thể (tùy thuộc vào
tốc độ, số lượng kênh và kích thước từ) để tiết kiệm năng lượng.

Bạn cũng nên sử dụng codec (nếu có thể) để điều khiển (hoặc làm chủ)
đồng hồ âm thanh vì nó thường cho tốc độ mẫu chính xác hơn CPU.

ASoC cung cấp API đồng hồ
-------------------------

.. kernel-doc:: sound/soc/soc-dai.c
   :identifiers: snd_soc_dai_set_sysclk

.. kernel-doc:: sound/soc/soc-dai.c
   :identifiers: snd_soc_dai_set_clkdiv

.. kernel-doc:: sound/soc/soc-dai.c
   :identifiers: snd_soc_dai_set_pll

.. kernel-doc:: sound/soc/soc-dai.c
   :identifiers: snd_soc_dai_set_bclk_ratio
