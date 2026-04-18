.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/sa1100/lart.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================================
Thiết bị đầu cuối vô tuyến nâng cao Linux (LART)
====================================

LART là bo mạch SA-1100 nhỏ (7,5 x 10 cm), được thiết kế để nhúng
ứng dụng. Nó có 32 MB DRAM, 4 MB Flash ROM, gấp đôi RS232 và tất cả
các tiện ích StrongARM khác. Hầu như tất cả các tín hiệu SA đều có thể truy cập trực tiếp
thông qua một số đầu nối. Nguồn điện chấp nhận điện áp
trong khoảng từ 3,5V đến 16V và có kích thước quá lớn để hỗ trợ nhiều loại
bảng con gái. Một bo mạch con bốn Ethernet / IDE / PS2 / âm thanh
đang được phát triển, cùng với nhiều dự án khác ở các giai đoạn khác nhau của
lập kế hoạch.

Các thiết kế phần cứng cho bo mạch này đã được phát hành theo giấy phép mở;
xem trang LART tại ZZ0000ZZ để biết thêm thông tin.
