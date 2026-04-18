.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/marvell/octeon_ep.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========================================================================
Trình điều khiển mạng nhân Linux cho Điểm cuối NIC của Octeon PCI của Marvell
====================================================================

Trình điều khiển mạng cho Marvell's Octeon PCI EndPoint NIC.
Bản quyền (c) 2020 Marvell International Ltd.

Nội dung
========

-ZZ0000ZZ
-ZZ0001ZZ
-ZZ0002ZZ

Tổng quan
========
Trình điều khiển này triển khai chức năng kết nối mạng của Marvell's Octeon PCI
Điểm cuối NIC.

Thiết bị được hỗ trợ
=================
Hiện tại, trình điều khiển này hỗ trợ các thiết bị sau:
 * Bộ điều khiển mạng: Cavium, Inc. Device b100
 * Bộ điều khiển mạng: Cavium, Inc. Device b200
 * Bộ điều khiển mạng: Cavium, Inc. Device b400
 * Bộ điều khiển mạng: Cavium, Inc. Device b900
 * Bộ điều khiển mạng: Cavium, Inc. Thiết bị ba00
 * Bộ điều khiển mạng: Cavium, Inc. Device bc00
 * Bộ điều khiển mạng: Cavium, Inc. Device bd00

Kiểm soát giao diện
=================
Kiểm soát giao diện mạng như thay đổi mtu, tốc độ liên kết, liên kết xuống/lên
được thực hiện bằng cách viết lệnh vào hàng đợi lệnh hộp thư, giao diện hộp thư
được thực hiện thông qua vùng dành riêng trong BAR4.
Trình điều khiển này ghi các lệnh vào hộp thư và chương trình cơ sở trên
Thiết bị Octeon xử lý chúng. Phần sụn cũng gửi thông báo không mong muốn
để điều khiển các sự kiện như thay đổi liên kết, thông qua hàng đợi thông báo
được triển khai như một phần của giao diện hộp thư.