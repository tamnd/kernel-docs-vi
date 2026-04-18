.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/i2c/busses/scx200_acb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Trình điều khiển hạt nhân scx200_acb
========================

Tác giả: Christer Weinigel <wingel@nano-system.com>

Trình điều khiển thay thế trình điều khiển cũ hơn, chưa bao giờ được hợp nhất có tên i2c-nscacb.

Thông số mô-đun
-----------------

* cơ sở: tối đa 4 int
  Địa chỉ cơ sở cho bộ điều khiển ACCESS.bus trên thiết bị SCx200 và SC1100

Theo mặc định, trình điều khiển sử dụng hai địa chỉ cơ sở 0x820 và 0x840.
  Nếu bạn chỉ muốn một địa chỉ cơ sở, hãy chỉ định địa chỉ thứ hai là 0 để
  ghi đè mặc định này.

Sự miêu tả
-----------

Cho phép sử dụng bộ điều khiển ACCESS.bus trên Geode SCx200 và
Bộ xử lý SC1100 và các thiết bị đồng hành CS5535 và CS5536 Geode.

Ghi chú dành riêng cho thiết bị
---------------------

Bo mạch SC1100 WRAP được biết là sử dụng địa chỉ cơ sở 0x810 và 0x820.
Nếu trình điều khiển scx200_acb được tích hợp vào kernel, hãy thêm phần sau
tham số cho dòng lệnh khởi động của bạn ::

scx200_acb.base=0x810,0x820

Nếu trình điều khiển scx200_acb được xây dựng dưới dạng mô-đun, hãy thêm dòng sau vào
thay vào đó, một tệp cấu hình trong /etc/modprobe.d/ ::

tùy chọn scx200_acb base=0x810,0x820
