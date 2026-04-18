.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/openrisc/todo.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

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
