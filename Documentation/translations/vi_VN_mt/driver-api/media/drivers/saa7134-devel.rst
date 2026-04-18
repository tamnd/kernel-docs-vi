.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/drivers/saa7134-devel.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển saa7134
==================

Tác giả Gerd Hoffmann


Các biến thể của thẻ:
----------------

Thẻ có thể sử dụng một trong hai tinh thể này (xtal):

- 32,11 MHz -> .audio_clock=0x187de7
- 24,576 MHz -> .audio_clock=0x200000 (xtal * .audio_clock = 51539600)

Một số thông tin chi tiết về ngày 34/30/35:

- saa7130 - chip giá rẻ, không có mute, đó là lý do tại sao tất cả những thứ đó
  thẻ phải có trường .mute được xác định trong cấu trúc bộ điều chỉnh của chúng.

- saa7134 - chip thông thường

- saa7133/35 - saa7135 có lẽ là một quyết định tiếp thị, vì tất cả những điều đó
  chip tự nhận mình là 33 trên pci.

GPIO LifeView
--------------

Phần này được viết bởi: Peter Missel <peter.missel@onlinehome.de>

- LifeView FlyTV Platinum FM (LR214WF)

- Chân GP27 MDT2005 PB4 10
    - Chân GP26 MDT2005 PB3 9
    - Chân GP25 MDT2005 PB2 8
    - Chân GP23 MDT2005 PB1 7
    - Chân GP22 MDT2005 PB0 6
    - Chân GP21 MDT2005 PB5 11
    - Chân GP20 MDT2005 PB6 12
    - Chân GP19 MDT2005 PB7 13
    - chân nc MDT2005 PA3 2
    - Remote MDT2005 PA2 chân 1
    - Chân GP18 MDT2005 PA1 18
    - nc MDT2005 PA0 pin 17 dây đeo thấp
    - Dây đeo GP17 "GP7"=Cao
    - Dây đeo GP16 "GP6"=Cao

- 0=Đài 1=Truyền hình
	- Điều khiển chân SA630D ENCH1 và HEF4052 A1 để phát đài FM thông qua
	  Đầu vào SIF

- GP15 nc
    - GP14 nc
    - GP13 nc
    - Dây đeo GP12 "GP5" = Cao
    - Dây đeo GP11 “GP4” = Cao
    - Dây đeo GP10 "GP3" = Cao
    - Dây đeo GP09 "GP2" = Thấp
    - Dây đeo GP08 "GP1" = Thấp
    - GP07.00 nc

Tín dụng
-------

andrew.stevens@philips.com + werner.leeb@philips.com đã cung cấp
thông số phần cứng và bảng mẫu saa7134.