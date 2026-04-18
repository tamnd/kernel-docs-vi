.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/metafmt-vivid.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _v4l2-meta-fmt-vivid:

*******************************
V4L2_META_FMT_VIVID ('VIVD')
*******************************

Định dạng siêu dữ liệu VIVID


Sự miêu tả
===========

Điều này mô tả định dạng siêu dữ liệu được trình điều khiển sống động sử dụng.

Nó đặt Độ sáng, Độ bão hòa, Độ tương phản và Màu sắc, mỗi thứ đều ánh xạ tới
các điều khiển tương ứng của trình điều khiển sống động liên quan đến phạm vi và giá trị mặc định.

Nó chứa các trường sau:

.. flat-table:: VIVID Metadata
    :widths: 1 4
    :header-rows:  1
    :stub-columns: 0

    * - Field
      - Description
    * - u16 brightness;
      - Image brightness, the value is in the range 0 to 255, with the default value as 128.
    * - u16 contrast;
      - Image contrast, the value is in the range 0 to 255, with the default value as 128.
    * - u16 saturation;
      - Image color saturation, the value is in the range 0 to 255, with the default value as 128.
    * - s16 hue;
      - Image color balance, the value is in the range -128 to 128, with the default value as 0.