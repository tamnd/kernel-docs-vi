.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/sunxi/clocks.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================================================
Những câu hỏi thường gặp về hệ thống đồng hồ sunxi
=======================================================

Tài liệu này chứa những thông tin hữu ích mà mọi người có xu hướng hỏi
về hệ thống đồng hồ sunxi, cũng như nghệ thuật ASCII đi kèm khi đầy đủ.

Hỏi: Tại sao bộ dao động 24 MHz chính có thể điều khiển được? Chẳng phải điều đó sẽ phá vỡ
   hệ thống?

Trả lời: Bộ dao động 24 MHz cho phép gating để tiết kiệm điện. Thật vậy, nếu bị chặn
   bất cẩn, hệ thống sẽ ngừng hoạt động, nhưng với quyền
   bước, người ta có thể cổng nó và giữ cho hệ thống hoạt động. Hãy xem xét điều này
   ví dụ đình chỉ đơn giản hóa:

Trong khi hệ thống đang hoạt động, bạn sẽ thấy một cái gì đó như::

24 MHz 32kHz
       |
      PLL1
       \
        \_ CPU Mux
             |
           [CPU]

Khi bạn sắp tạm dừng, bạn chuyển CPU Mux sang 32kHz
   bộ dao động::

24 MHz 32kHz
       ZZ0000ZZ
      PLL1 |
                     /
           CPU Mux _/
             |
           [CPU]

Cuối cùng, bạn có thể cổng bộ dao động chính ::

32kHz
                      |
                      |
                     /
           CPU Mux _/
             |
           [CPU]

Hỏi: Tôi có thể tìm hiểu thêm về đồng hồ sunxi không?

A: Wiki linux-sunxi có một trang ghi lại các thanh ghi đồng hồ,
   bạn có thể tìm thấy nó ở

ZZ0000ZZ

Nguồn thông tin có thẩm quyền tại thời điểm này là trình điều khiển ccmu
   được phát hành bởi Allwinner, bạn có thể tìm thấy nó tại

ZZ0000ZZ
