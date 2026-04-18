.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/openrisc/todo.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====
TODO
====

Cổng OpenRISC Linux có đầy đủ chức năng và đã được theo dõi ngược dòng
kể từ ngày 2.6.35.  Tuy nhiên, vẫn còn những hạng mục cần hoàn thành trong vòng
những tháng tới.  Dưới đây là danh sách các vật phẩm được biết đến ít hơn
sắp được điều tra, tức là danh sách TODO của chúng tôi:

- Triển khai phần còn lại của DMA API... dma_map_sg, v.v.

- Hoàn tất việc dọn dẹp đổi tên... có tham chiếu đến or32 trong mã
   đó là một tên cũ cho kiến trúc.  Tên chúng tôi đã quyết định là
   or1k và sự thay đổi này đang dần lan truyền khắp ngăn xếp.  cho thời gian
   hiện hữu, or32 tương đương với or1k.
