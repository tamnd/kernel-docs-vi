.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/ext-ctrls-colorimetry.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _colorimetry-controls:

*****************************
Tài liệu tham khảo kiểm soát đo màu
*****************************

Lớp Đo màu bao gồm các điều khiển cho Dải động cao
hình ảnh để thể hiện màu sắc trong hình ảnh kỹ thuật số và video. các
nên sử dụng các điều khiển để mã hóa và giải mã video và hình ảnh
cũng như trong máy thu và phát HDMI.

ID kiểm soát đo màu
-----------------------

.. _colorimetry-control-id:

ZZ0001ZZ
    Bộ mô tả lớp Colorimetry. Đang gọi
    ZZ0000ZZ cho điều khiển này sẽ
    trả về mô tả của lớp điều khiển này.

ZZ0000ZZ
    Mức ánh sáng nội dung xác định giới hạn trên cho mục tiêu danh nghĩa
    độ sáng mức độ ánh sáng của hình ảnh.

.. c:type:: v4l2_ctrl_hdr10_cll_info

.. cssclass:: longtable

.. flat-table:: struct v4l2_ctrl_hdr10_cll_info
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u16
      - ``max_content_light_level``
      - The upper bound for the maximum light level among all individual
        samples for the pictures of a video sequence, cd/m\ :sup:`2`.
        When equal to 0 no such upper bound is present.
    * - __u16
      - ``max_pic_average_light_level``
      - The upper bound for the maximum average light level among the
        samples for any individual picture of a video sequence,
        cd/m\ :sup:`2`. When equal to 0 no such upper bound is present.

ZZ0000ZZ
    Màn hình chính xác định khối lượng màu (màu cơ bản,
    điểm trắng và phạm vi độ chói) của màn hình được coi là
    hiển thị chính cho nội dung video hiện tại.

.. c:type:: v4l2_ctrl_hdr10_mastering_display

.. cssclass:: longtable

.. flat-table:: struct v4l2_ctrl_hdr10_mastering_display
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u16
      - ``display_primaries_x[3]``
      - Specifies the normalized x chromaticity coordinate of the color
        primary component c of the mastering display in increments of 0.00002.
        For describing the mastering display that uses Red, Green and Blue
        color primaries, index value c equal to 0 corresponds to the Green
        primary, c equal to 1 corresponds to Blue primary and c equal to 2
        corresponds to the Red color primary.
    * - __u16
      - ``display_primaries_y[3]``
      - Specifies the normalized y chromaticity coordinate of the color
        primary component c of the mastering display in increments of 0.00002.
        For describing the mastering display that uses Red, Green and Blue
        color primaries, index value c equal to 0 corresponds to the Green
        primary, c equal to 1 corresponds to Blue primary and c equal to 2
        corresponds to Red color primary.
    * - __u16
      - ``white_point_x``
      - Specifies the normalized x chromaticity coordinate of the white
        point of the mastering display in increments of 0.00002.
    * - __u16
      - ``white_point_y``
      - Specifies the normalized y chromaticity coordinate of the white
        point of the mastering display in increments of 0.00002.
    * - __u32
      - ``max_luminance``
      - Specifies the nominal maximum display luminance of the mastering
        display in units of 0.0001 cd/m\ :sup:`2`.
    * - __u32
      - ``min_luminance``
      - specifies the nominal minimum display luminance of the mastering
        display in units of 0.0001 cd/m\ :sup:`2`.