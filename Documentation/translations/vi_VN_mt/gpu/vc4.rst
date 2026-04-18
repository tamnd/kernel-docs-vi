.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/vc4.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================================
 Trình điều khiển đồ họa drm/vc4 Broadcom VC4
=====================================

.. kernel-doc:: drivers/gpu/drm/vc4/vc4_drv.c
   :doc: Broadcom VC4 Graphics Driver

Xử lý phần cứng hiển thị
=========================

Phần này bao gồm mọi thứ liên quan đến phần cứng hiển thị bao gồm
cơ sở hạ tầng thiết lập chế độ, xử lý mặt phẳng, sprite và con trỏ và
hiển thị, thăm dò đầu ra và các chủ đề liên quan.

Van Pixel (DRM CRTC)
----------------------

.. kernel-doc:: drivers/gpu/drm/vc4/vc4_crtc.c
   :doc: VC4 CRTC module

HVS
---

.. kernel-doc:: drivers/gpu/drm/vc4/vc4_hvs.c
   :doc: VC4 HVS module.

Máy bay HVS
----------

.. kernel-doc:: drivers/gpu/drm/vc4/vc4_plane.c
   :doc: VC4 plane module

Bộ mã hóa HDMI
------------

.. kernel-doc:: drivers/gpu/drm/vc4/vc4_hdmi.c
   :doc: VC4 Falcon HDMI module

Bộ mã hóa DSI
-----------

.. kernel-doc:: drivers/gpu/drm/vc4/vc4_dsi.c
   :doc: VC4 DSI0/DSI1 module

Bộ mã hóa DPI
-----------

.. kernel-doc:: drivers/gpu/drm/vc4/vc4_dpi.c
   :doc: VC4 DPI module

Bộ mã hóa VEC (Đầu ra TV tổng hợp)
------------------------------

.. kernel-doc:: drivers/gpu/drm/vc4/vc4_vec.c
   :doc: VC4 SDTV module

Kiểm tra KUnit
===========

Trình điều khiển VC4 sử dụng KUnit để thực hiện đơn vị dành riêng cho trình điều khiển và
các bài kiểm tra tích hợp.

Các thử nghiệm này đang sử dụng trình điều khiển mô phỏng và có thể được chạy bằng cách sử dụng
lệnh bên dưới, trên kiến trúc nhánh hoặc nhánh64,

.. code-block:: bash

	$ ./tools/testing/kunit/kunit.py run \
		--kunitconfig=drivers/gpu/drm/vc4/tests/.kunitconfig \
		--cross_compile aarch64-linux-gnu- --arch arm64

Các bộ phận của trình điều khiển hiện đang được kiểm tra bao gồm:
 * Phép gán FIFO động từ HVS sang PixelValve, dành cho BCM2835-7
   và BCM2711.

Quản lý bộ nhớ và gửi lệnh 3D
===========================================

Phần này đề cập đến việc triển khai GEM trong trình điều khiển vc4.

Quản lý đối tượng bộ đệm (BO) GPU
---------------------------------

.. kernel-doc:: drivers/gpu/drm/vc4/vc4_bo.c
   :doc: VC4 GEM BO management support

Xác thực danh sách lệnh binner V3D (BCL)
----------------------------------------

.. kernel-doc:: drivers/gpu/drm/vc4/vc4_validate.c
   :doc: Command list validator for VC4.

Tạo danh sách lệnh kết xuất V3D (RCL)
----------------------------------------

.. kernel-doc:: drivers/gpu/drm/vc4/vc4_render_cl.c
   :doc: Render command list generation

Trình xác thực Shader cho VC4
---------------------------
.. kernel-doc:: drivers/gpu/drm/vc4/vc4_validate_shaders.c
   :doc: Shader validator for VC4.

Ngắt V3D
--------------

.. kernel-doc:: drivers/gpu/drm/vc4/vc4_irq.c
   :doc: Interrupt management for the V3D engine
