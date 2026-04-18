.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/drivers/mali-c55.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển cánh tay Mali-C55 ISP
=======================

Trình điều khiển Arm Mali-C55 ISP thực hiện một điều khiển dành riêng cho trình điều khiển:

ZZ0000ZZ
    Trình bày chi tiết các khả năng của ISP bằng cách cung cấp thông tin chi tiết về các khối được trang bị.

    .. flat-table:: Bitmask meaning definitions
:hàng tiêu đề: 1
	:chiều rộng: 2 4 8

* - Chút
	  - Vĩ mô
	  - Ý nghĩa
        * - 0
          -MALI_C55_PONG
          - Không gian cấu hình Pông được trang bị trong ISP
        * - 1
          -MALI_C55_WDR
          - WDR Framestitch, offset và khuếch đại được trang bị trong ISP
        * - 2
          -MALI_C55_COMPRESSION
          - Nén nhiệt độ được trang bị trong ISP
        * - 3
          -MALI_C55_TEMPER
          - Nhiệt độ được trang bị trong ISP
        * - 4
          -MALI_C55_SINTER_LITE
          - Sinter Lite được trang bị trên ISP thay vì phiên bản Sinter đầy đủ
        * - 5
          -MALI_C55_SINTER
          - Sinter được trang bị trong ISP
        * - 6
          -MALI_C55_IRIDIX_LTM
          - Bản đồ giai điệu cục bộ Iridix được trang bị trong ISP
        * - 7
          -MALI_C55_IRIDIX_GTM
          - Ánh xạ giai điệu toàn cầu Iridix được trang bị trong ISP
        * - 8
          -MALI_C55_CNR
          - Tính năng giảm nhiễu màu được trang bị trên ISP
        * - 9
          -MALI_C55_FRSCALER
          - Bộ chia tỷ lệ đường ống có độ phân giải đầy đủ được trang bị trong ISP
        * - 10
          -MALI_C55_DS_PIPE
          - Ống downscale được lắp vào ISP

Mali-C55 ISP có thể được định cấu hình theo một số cách để bao gồm hoặc loại trừ
    những khối có thể không cần thiết. Việc kiểm soát này cung cấp một cách để
    trình điều khiển để liên lạc với không gian người dùng khối nào được lắp trong
    thiết kế.