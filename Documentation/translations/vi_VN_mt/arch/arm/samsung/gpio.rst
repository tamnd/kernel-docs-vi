.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/samsung/gpio.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Triển khai Samsung GPIO
===========================

Giới thiệu
------------

Phần này phác thảo cách triển khai và kiến trúc của Samsung GPIO
các cuộc gọi cụ thể được cung cấp cùng với trình điều khiển/lõi gpio.


Tích hợp GPIOLIB
-------------------

Việc triển khai gpio sử dụng gpiolib càng nhiều càng tốt, chỉ cung cấp
các cuộc gọi cụ thể cho các mục yêu cầu xử lý cụ thể của Samsung, chẳng hạn như
như chân chức năng đặc biệt hoặc điều khiển điện trở kéo.

Việc đánh số GPIO được đồng bộ hóa giữa hệ thống Samsung và gpiolib.


Cấu hình PIN
-----------------

Cấu hình chân cắm dành riêng cho kiến trúc của Samsung, với mỗi SoC
đăng ký thông tin cần thiết cho cấu hình gpio lõi
thực hiện để cấu hình các chân khi cần thiết.

s3c_gpio_cfgpin() và s3c_gpio_setpull() cung cấp phương tiện cho
trình điều khiển hoặc máy để thay đổi cấu hình gpio.

Xem Arch/arm/mach-s3c/gpio-cfg.h để biết thêm thông tin về các chức năng này.
