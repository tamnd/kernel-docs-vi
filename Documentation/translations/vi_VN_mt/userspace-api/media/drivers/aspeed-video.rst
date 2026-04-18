.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/drivers/aspeed-video.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

Trình điều khiển video ASPEED
=============================

Công cụ video ASPEED được tìm thấy trên SoC AST2400/2500/2600 hỗ trợ hiệu suất cao
nén video với nhiều chất lượng video và tỷ lệ nén
tùy chọn. Thuật toán nén được áp dụng là thuật toán JPEG đã được sửa đổi.

Có 2 loại nén trong IP này.

* Chế độ tiêu chuẩn JPEG JFIF: để nén khung đơn và quản lý
* Chế độ độc quyền của ASPEED: để nén đa khung và nén vi sai.
  Hỗ trợ sơ đồ nén video 2-pass (chất lượng cao) (Đang chờ cấp bằng sáng chế bởi
  ASPEED). Cung cấp chất lượng nén video không bị mất chất lượng trực quan hoặc để giảm
  tải trung bình của mạng trong các ứng dụng mạng nội bộ KVM.

VIDIOC_S_FMT có thể được sử dụng để chọn định dạng bạn muốn. V4L2_PIX_FMT_JPEG
là viết tắt của chế độ tiêu chuẩn JPEG JFIF; V4L2_PIX_FMT_AJPG là viết tắt của ASPEED
chế độ độc quyền.

Bạn có thể tìm thêm thông tin chi tiết về hoạt động của phần cứng video ASPEED trong
ZZ0001ZZ của SDK_User_Guide có sẵn trên
ZZ0000ZZ.

Trình điều khiển video ASPEED thực hiện điều khiển dành riêng cho trình điều khiển sau:

ZZ0000ZZ
---------------------------
Bật/Tắt chế độ Chất lượng cao của ASPEED. Đây là sự kiểm soát riêng tư
    có thể được sử dụng để kích hoạt chất lượng cao cho chế độ độc quyền tốc độ.

.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 4

    * - ``(0)``
      - ASPEED HQ mode is disabled.
    * - ``(1)``
      - ASPEED HQ mode is enabled.

ZZ0000ZZ
-----------------------------------
Xác định chất lượng của chế độ Chất lượng cao của ASPEED. Đây là sự kiểm soát riêng tư
    có thể được sử dụng để quyết định chất lượng nén nếu bật chế độ Chất lượng cao
    . Giá trị cao hơn, chất lượng tốt hơn và kích thước lớn hơn.

.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 4

    * - ``(1)``
      - minimum
    * - ``(12)``
      - maximum
    * - ``(1)``
      - step
    * - ``(1)``
      - default

ZZ0000ZZ ZZ0001ZZ 2022 ASPEED Công nghệ Inc.