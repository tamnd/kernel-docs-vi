.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/drivers/vgxy61.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển cảm biến máy ảnh ST VGXY61
==============================

Trình điều khiển ST VGXY61 thực hiện các điều khiển sau:

ZZ0000ZZ
-------------------------------
Thay đổi chế độ HDR của cảm biến. Một hình ảnh HDR thu được bằng cách hợp nhất hai
    chụp cùng một cảnh bằng hai khoảng thời gian phơi sáng khác nhau.

.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 4

    * - HDR linearize
      - The merger outputs a long exposure capture as long as it is not
        saturated.
    * - HDR subtraction
      - This involves subtracting the short exposure frame from the long
        exposure frame.
    * - No HDR
      - This mode is used for standard dynamic range (SDR) exposures.