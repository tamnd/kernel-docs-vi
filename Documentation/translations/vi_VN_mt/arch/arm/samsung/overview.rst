.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/samsung/overview.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Tổng quan về Samsung ARM Linux
==============================

Giới thiệu
------------

Dòng SoC ARM của Samsung bao gồm nhiều thiết bị tương tự, từ thiết bị đầu tiên
  ARM9 cho đến các lõi ARM mới nhất. Tài liệu này trình bày tổng quan về
  hỗ trợ kernel hiện tại, cách sử dụng và tìm mã ở đâu
  hỗ trợ điều này.

Các SoC hiện được hỗ trợ là:

-S3C64XX: S3C6400 và S3C6410
  -S5PC110 / S5PV210


Cấu hình
-------------

Một số cấu hình được cung cấp vì hiện tại không có cách nào để
  hợp nhất tất cả các SoC thành một hạt nhân.

s5pc110_defconfig
	- Cấu hình mặc định cụ thể của S5PC110
  s5pv210_defconfig
	- Cấu hình mặc định cụ thể của S5PV210


Cách trình bày
--------------

Bố cục thư mục hiện đang được cơ cấu lại và bao gồm
  một số thư mục nền tảng và sau đó là các thư mục cụ thể của máy
  của các CPU được xây dựng cho.

plat-samsung cung cấp cơ sở cho tất cả việc triển khai và là
  cuối cùng trong dòng bao gồm các thư mục được xử lý để xây dựng
  thông tin cụ thể. Nó chứa đồng hồ cơ sở, GPIO và định nghĩa thiết bị
  để hệ thống hoạt động.

plat-s5p dành cho các bản dựng cụ thể của s5p và chứa hỗ trợ chung cho
  Hệ thống cụ thể S5P. Không phải tất cả S5P đều sử dụng tất cả các tính năng trong thư mục này
  do sự khác biệt về phần cứng.


Thay đổi bố cục
---------------

Các thư mục plat-s3c và plat-s5pc1xx cũ đã bị xóa, với
  hỗ trợ được chuyển sang plat-samsung hoặc plat-s5p nếu cần. Những động thái này
  nơi đơn giản hóa các vấn đề bao gồm và phụ thuộc liên quan đến việc có
  rất nhiều thư mục nền tảng khác nhau.


Người đóng góp cổng
-------------------

Ben Dooks (BJD)
  Vincent Sanders
  Herbert Potzl
  Arnaud Patard (RTP)
  Roc Wu
  Klaus Fetscher
  Dimitry Andric
  Shannon Hà Lan
  Guillaume Gourat (NexVision)
  Christer Weinigel (cánh) (Acer N30)
  Biệt thự Lucas Correia Real (cảng S3C2400)


Tác giả tài liệu
----------------

Bản quyền 2009-2010 Ben Dooks <ben-linux@fluff.org>
