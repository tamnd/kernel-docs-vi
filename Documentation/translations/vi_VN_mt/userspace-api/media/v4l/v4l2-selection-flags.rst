.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/v4l2-selection-flags.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _v4l2-selection-flags:

****************
Cờ lựa chọn
****************

.. _v4l2-selection-flags-table:

.. raw:: latex

   \small

.. tabularcolumns:: |p{5.6cm}|p{2.0cm}|p{6.5cm}|p{1.2cm}|p{1.2cm}|

.. cssclass:: longtable

.. flat-table:: Selection flag definitions
    :header-rows:  1
    :stub-columns: 0

    * - Flag name
      - id
      - Definition
      - Valid for V4L2
      - Valid for V4L2 subdev
    * - ``V4L2_SEL_FLAG_GE``
      - (1 << 0)
      - Suggest the driver it should choose greater or equal rectangle (in
	size) than was requested. Albeit the driver may choose a lesser
	size, it will only do so due to hardware limitations. Without this
	flag (and ``V4L2_SEL_FLAG_LE``) the behaviour is to choose the
	closest possible rectangle.
      - Yes
      - Yes
    * - ``V4L2_SEL_FLAG_LE``
      - (1 << 1)
      - Suggest the driver it should choose lesser or equal rectangle (in
	size) than was requested. Albeit the driver may choose a greater
	size, it will only do so due to hardware limitations.
      - Yes
      - Yes
    * - ``V4L2_SEL_FLAG_KEEP_CONFIG``
      - (1 << 2)
      - The configuration must not be propagated to any further processing
	steps. If this flag is not given, the configuration is propagated
	inside the subdevice to all further processing steps.
      - No
      - Yes

.. raw:: latex

   \normalsize