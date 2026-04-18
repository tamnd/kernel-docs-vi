.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/firmware/built-in-fw.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Phần sụn tích hợp
=================

Phần sụn có thể được tích hợp sẵn trong kernel, điều này có nghĩa là xây dựng phần sụn
trực tiếp vào vmlinux, để tránh phải tìm kiếm chương trình cơ sở từ
hệ thống tập tin. Thay vào đó, phần sụn có thể được tìm kiếm bên trong kernel
trực tiếp. Bạn có thể kích hoạt chương trình cơ sở tích hợp bằng cấu hình kernel
tùy chọn:

* CONFIG_EXTRA_FIRMWARE
  * CONFIG_EXTRA_FIRMWARE_DIR

Có một số lý do khiến bạn có thể muốn xem xét việc xây dựng chương trình cơ sở của mình
vào kernel bằng CONFIG_EXTRA_FIRMWARE:

* Tốc độ
* Cần có phần sụn để truy cập thiết bị khởi động và người dùng thì không
  muốn nhét phần sụn vào initramfs khởi động.

Ngay cả khi bạn có những nhu cầu này thì vẫn có một số lý do khiến bạn không thể
có thể sử dụng phần sụn tích hợp:

* Legalese - phần sụn không tương thích với GPL
* Một số phần sụn có thể là tùy chọn
* Có thể nâng cấp chương trình cơ sở, do đó chương trình cơ sở mới sẽ liên quan đến
  xây dựng lại kernel hoàn chỉnh.
* Một số tập tin phần sụn có thể có kích thước rất lớn. Hệ thống con remote-proc
  là một hệ thống con ví dụ xử lý các loại phần sụn này
* Phần sụn có thể cần được loại bỏ khỏi một số vị trí cụ thể của thiết bị
  một cách linh hoạt, một ví dụ là dữ liệu hiệu chỉnh cho một số chipset WiFi. Cái này
  dữ liệu hiệu chuẩn có thể là duy nhất cho mỗi thiết bị được bán.

