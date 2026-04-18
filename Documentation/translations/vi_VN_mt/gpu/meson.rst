.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/meson.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================================
drm/meson Bộ xử lý video AmLogic Meson
=================================================

.. kernel-doc:: drivers/gpu/drm/meson/meson_drv.c
   :doc: Video Processing Unit

Bộ xử lý video
=====================

Bộ điều khiển Amlogic Meson Display bao gồm một số thành phần
sẽ được ghi lại dưới đây:

.. code::

  DMC|---------------VPU (Video Processing Unit)----------------|------HHI------|
     | vd1   _______     _____________    _________________     |               |
  D  |-------|      |----|            |   |                |    |   HDMI PLL    |
  D  | vd2   | VIU  |    | Video Post |   | Video Encoders |<---|-----VCLK      |
  R  |-------|      |----| Processing |   |                |    |               |
     | osd2  |      |    |            |---| Enci ----------|----|-----VDAC------|
  R  |-------| CSC  |----| Scalers    |   | Encp ----------|----|----HDMI-TX----|
  A  | osd1  |      |    | Blenders   |   | Encl ----------|----|---------------|
  M  |-------|______|----|____________|   |________________|    |               |
  ___|__________________________________________________________|_______________|

Bộ đầu vào video
================

.. kernel-doc:: drivers/gpu/drm/meson/meson_viu.c
   :doc: Video Input Unit

Xử lý bài đăng video
=====================

.. kernel-doc:: drivers/gpu/drm/meson/meson_vpp.c
   :doc: Video Post Processing

Bộ mã hóa video
=============

.. kernel-doc:: drivers/gpu/drm/meson/meson_venc.c
   :doc: Video Encoder

Đồng hồ video
============

.. kernel-doc:: drivers/gpu/drm/meson/meson_vclk.c
   :doc: Video Clocks

Đầu ra video HDMI
=================

.. kernel-doc:: drivers/gpu/drm/meson/meson_dw_hdmi.c
   :doc: HDMI Output
