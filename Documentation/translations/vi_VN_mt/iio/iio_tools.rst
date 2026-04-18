.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/iio/iio_tools.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Công cụ giao tiếp IIO
=====================

1. Công cụ hạt nhân Linux
=====================

Hạt nhân Linux cung cấp một số công cụ không gian người dùng có thể được sử dụng để truy xuất dữ liệu
từ hệ thống IIO:

* lsiio: ứng dụng ví dụ cung cấp danh sách các thiết bị và trình kích hoạt IIO
* iio_event_monitor: ứng dụng mẫu đọc các sự kiện từ thiết bị IIO
  và in chúng
* iio_generic_buffer: ví dụ ứng dụng đọc dữ liệu từ bộ đệm
* iio_utils: bộ API, thường được sử dụng để truy cập các tệp sysfs.

2. LibIIO
=========

LibIIO là thư viện C/C++ cung cấp quyền truy cập chung vào các thiết bị IIO. các
thư viện trừu tượng hóa các chi tiết cấp thấp của phần cứng và cung cấp một cách đơn giản
giao diện lập trình hoàn chỉnh có thể được sử dụng cho các dự án nâng cao.

Để biết thêm thông tin về LibIIO, vui lòng xem:
ZZ0000ZZ