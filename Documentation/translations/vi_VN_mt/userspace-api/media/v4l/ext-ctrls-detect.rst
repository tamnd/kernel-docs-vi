.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/ext-ctrls-detect.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _detect-controls:

*******************************
Phát hiện tham chiếu điều khiển
*******************************

Lớp Phát hiện bao gồm các điều khiển cho các đặc điểm chung của nhiều chuyển động khác nhau
hoặc các thiết bị có khả năng phát hiện đối tượng.


.. _detect-control-id:

Phát hiện ID kiểm soát
==================

ZZ0001ZZ
    Bộ mô tả lớp Phát hiện. Đang gọi
    ZZ0000ZZ cho điều khiển này sẽ
    trả về mô tả của lớp điều khiển này.

ZZ0000ZZ
    Đặt chế độ phát hiện chuyển động.

.. tabularcolumns:: |p{7.7cm}|p{9.8cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_DETECT_MD_MODE_DISABLED``
      - Disable motion detection.
    * - ``V4L2_DETECT_MD_MODE_GLOBAL``
      - Use a single motion detection threshold.
    * - ``V4L2_DETECT_MD_MODE_THRESHOLD_GRID``
      - The image is divided into a grid, each cell with its own motion
	detection threshold. These thresholds are set through the
	``V4L2_CID_DETECT_MD_THRESHOLD_GRID`` matrix control.
    * - ``V4L2_DETECT_MD_MODE_REGION_GRID``
      - The image is divided into a grid, each cell with its own region
	value that specifies which per-region motion detection thresholds
	should be used. Each region has its own thresholds. How these
	per-region thresholds are set up is driver-specific. The region
	values for the grid are set through the
	``V4L2_CID_DETECT_MD_REGION_GRID`` matrix control.



ZZ0000ZZ
    Đặt ngưỡng phát hiện chuyển động chung sẽ được sử dụng với
    Chế độ phát hiện chuyển động ZZ0001ZZ.

ZZ0000ZZ
    Đặt ngưỡng phát hiện chuyển động cho từng ô trong lưới. Đến
    được sử dụng với chuyển động ZZ0001ZZ
    chế độ phát hiện Phần tử ma trận (0, 0) đại diện cho ô tại
    phía trên bên trái của lưới.

ZZ0000ZZ
    Đặt giá trị vùng phát hiện chuyển động cho từng ô trong lưới. Đến
    được sử dụng với chuyển động ZZ0001ZZ
    chế độ phát hiện Phần tử ma trận (0, 0) đại diện cho ô tại
    phía trên bên trái của lưới.