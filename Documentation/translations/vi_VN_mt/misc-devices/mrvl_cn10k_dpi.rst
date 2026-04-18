.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/misc-devices/mrvl_cn10k_dpi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================================
Trình điều khiển giao diện gói Marvell CN10K DMA (DPI)
===============================================

Tổng quan
========

DPI là khối phần cứng giao diện gói DMA trong silicon CN10K của Marvell.
Phần cứng DPI bao gồm chức năng vật lý (PF), chức năng ảo của nó,
logic hộp thư và một bộ công cụ DMA & hàng đợi lệnh DMA.

Chức năng DPI PF là chức năng quản trị phục vụ hộp thư
yêu cầu từ các chức năng VF của nó và cung cấp tài nguyên động cơ DMA cho
đó là chức năng VF.

mrvl_cn10k_dpi.ko tải trình điều khiển linh tinh trên thiết bị DPI PF và phục vụ
các lệnh hộp thư do thiết bị VF gửi và theo đó sẽ khởi tạo
động cơ DMA và hàng đợi lệnh DMA của thiết bị VF. Ngoài ra, trình điều khiển tạo ra
Nút /dev/mrvl-cn10k-dpi để đặt công cụ DMA và cổng PEM (giao diện PCIe)
các thuộc tính như độ dài fifo, molr, mps & mrrs.

Trình điều khiển DPI PF chỉ là trình điều khiển quản trị để thiết lập thiết bị VF của nó
hàng đợi và cung cấp tài nguyên phần cứng, nó không thể khởi tạo bất kỳ
Hoạt động DMA. Chỉ các thiết bị VF mới được cung cấp khả năng DMA.

Vị trí tài xế
===============

trình điều khiển/misc/mrvl_cn10k_dpi.c

Trình điều khiển IOCTL
=============

ZZ0000ZZ
ioctl đặt kích thước tải trọng tối đa và tham số kích thước yêu cầu đọc tối đa của
một cổng pem mà động cơ DMA được kết nối.


ZZ0000ZZ
ioctl đặt kích thước fifo của công cụ DMA và yêu cầu tải tối đa chưa thanh toán
ngưỡng.

Ví dụ về mã không gian người dùng
=======================

Các thiết bị DPI VF được thăm dò và truy cập từ các ứng dụng không gian người dùng bằng cách sử dụng
trình điều khiển vfio-pci. Dưới đây là một ứng dụng dpi dma mẫu để minh họa trên
cách các ứng dụng sử dụng hộp thư và dịch vụ ioctl từ trình điều khiển hạt nhân DPI PF.

ZZ0000ZZ