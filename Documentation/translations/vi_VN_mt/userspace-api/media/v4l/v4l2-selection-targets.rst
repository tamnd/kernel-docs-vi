.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/v4l2-selection-targets.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _v4l2-selection-targets:

*****************
Mục tiêu lựa chọn
*****************

Ý nghĩa chính xác của các mục tiêu lựa chọn có thể phụ thuộc vào
của hai giao diện chúng được sử dụng.


.. _v4l2-selection-targets-table:

.. raw:: latex

   \small

.. tabularcolumns:: |p{6.2cm}|p{1.4cm}|p{7.3cm}|p{1.2cm}|p{0.8cm}|

.. cssclass:: longtable

.. flat-table:: Selection target definitions
    :header-rows:  1
    :stub-columns: 0

    * - Target name
      - id
      - Definition
      - Valid for V4L2
      - Valid for V4L2 subdev
    * - ``V4L2_SEL_TGT_CROP``
      - 0x0000
      - Crop rectangle. Defines the cropped area.
      - Yes
      - Yes
    * - ``V4L2_SEL_TGT_CROP_DEFAULT``
      - 0x0001
      - Suggested cropping rectangle that covers the "whole picture".
        This includes only active pixels and excludes other non-active
        pixels such as black pixels.
      - Yes
      - Yes
    * - ``V4L2_SEL_TGT_CROP_BOUNDS``
      - 0x0002
      - Bounds of the crop rectangle. All valid crop rectangles fit inside
	the crop bounds rectangle.
      - Yes
      - Yes
    * - ``V4L2_SEL_TGT_NATIVE_SIZE``
      - 0x0003
      - The native size of the device, e.g. a sensor's pixel array.
	``left`` and ``top`` fields are zero for this target.
      - Yes
      - Yes
    * - ``V4L2_SEL_TGT_COMPOSE``
      - 0x0100
      - Compose rectangle. Used to configure scaling and composition.
      - Yes
      - Yes
    * - ``V4L2_SEL_TGT_COMPOSE_DEFAULT``
      - 0x0101
      - Suggested composition rectangle that covers the "whole picture".
      - Yes
      - No
    * - ``V4L2_SEL_TGT_COMPOSE_BOUNDS``
      - 0x0102
      - Bounds of the compose rectangle. All valid compose rectangles fit
	inside the compose bounds rectangle.
      - Yes
      - Yes
    * - ``V4L2_SEL_TGT_COMPOSE_PADDED``
      - 0x0103
      - The active area and all padding pixels that are inserted or
	modified by hardware.
      - Yes
      - No

.. raw:: latex

   \normalsize