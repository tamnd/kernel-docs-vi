.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/gpio/bt8xxgpio.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================================================================
Trình điều khiển cho thẻ PCI GPIO-card dựa trên BT8xx giá rẻ tự chế (bt8xxgpio)
===============================================================================

Để biết tài liệu nâng cao, hãy xem ZZ0000ZZ

Thẻ PCI GPIO 24 cổng kỹ thuật số chung có thể được xây dựng ngoài thẻ thông thường
Thẻ điều chỉnh TV analog dựa trên Brooktree bt848, bt849, bt878 hoặc bt879. các
Chip Brooktree được sử dụng trong các thẻ Hauppauge WinTV PCI tương tự cũ. Bạn có thể dễ dàng
tìm thấy chúng được sử dụng với giá thấp trên mạng.

Chip bt8xx có 24 cổng GPIO kỹ thuật số.
Các cổng này có thể truy cập được thông qua 24 chân trên gói chip SMD.


Cách truy cập vật lý vào các chân GPIO
======================================

Có một số cách để truy cập vào các chân này. Người ta có thể hàn toàn bộ con chip
và đặt nó lên bảng PCI tùy chỉnh hoặc người ta chỉ có thể hàn từng cá nhân
Ghim GPIO và hàn nó vào một số dây nhỏ. Vì gói chip thực sự rất nhỏ
có một số kỹ năng hàn nâng cao cần thiết trong mọi trường hợp.

Sơ đồ chân vật lý được vẽ theo hình ASCII sau đây.
Các chân GPIO được đánh dấu bằng G00-G23::

G G G G G G G G G G G G G G G G
                                           0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1
                                           0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7
           ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ ZZ0004ZZ ZZ0005ZZ ZZ0006ZZ ZZ0007ZZ ZZ0008ZZ ZZ0009ZZ ZZ0010ZZ ZZ0011ZZ ZZ0012ZZ ZZ0013ZZ ZZ0014ZZ ZZ0015ZZ ZZ0016ZZ ZZ0017ZZ ZZ0018ZZ
           --------------------------------------------------------------------------
         --ZZ0019ZZ--
         --ZZ0020ZZ--
         --ZZ0021ZZ--
         --ZZ0022ZZ-- G18
         --ZZ0023ZZ-- G19
         --ZZ0024ZZ-- G20
         --ZZ0025ZZ-- G21
         --ZZ0026ZZ-- G22
         --ZZ0027ZZ-- G23
         --ZZ0028ZZ--
         --ZZ0029ZZ--
         --ZZ0030ZZ--
         --ZZ0031ZZ--
         --ZZ0032ZZ--
         --ZZ0033ZZ--
         --ZZ0034ZZ--
         --ZZ0035ZZ--
         --ZZ0036ZZ--
         --ZZ0037ZZ--
         --ZZ0038ZZ--
         --ZZ0039ZZ--
         --ZZ0040ZZ--
         --ZZ0041ZZ--
         --ZZ0042ZZ--
         --ZZ0043ZZ--
         --ZZ0044ZZ--
           --------------------------------------------------------------------------
           ZZ0045ZZ ZZ0046ZZ ZZ0047ZZ ZZ0048ZZ ZZ0049ZZ ZZ0050ZZ ZZ0051ZZ ZZ0052ZZ ZZ0053ZZ ZZ0054ZZ ZZ0055ZZ ZZ0056ZZ ZZ0057ZZ ZZ0058ZZ ZZ0059ZZ ZZ0060ZZ ZZ0061ZZ ZZ0062ZZ ZZ0063ZZ
           ^
           Đây là chân 1

