.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/drm-kms-helpers.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Chức năng trợ giúp cài đặt chế độ
=============================

Hệ thống con DRM nhằm mục đích tách biệt rõ ràng giữa mã lõi và trình trợ giúp
thư viện. Mã lõi đảm nhiệm việc thiết lập chung, phân tích và giải mã
yêu cầu không gian người dùng tới các đối tượng bên trong kernel. Mọi thứ khác được xử lý bởi một
tập hợp lớn các thư viện trợ giúp, có thể được kết hợp tự do để chọn và chọn
cho mỗi trình điều khiển những gì phù hợp và tránh mã được chia sẻ khi có hành vi đặc biệt
cần thiết.

Sự khác biệt giữa mã lõi và các trình trợ giúp này đặc biệt rõ ràng trong
mã cài đặt chế độ, trong đó có không gian người dùng chung ABI cho tất cả các trình điều khiển. Đây là
trái ngược với phía kết xuất, nơi có hầu hết mọi thứ (với rất ít
ngoại lệ) có thể được coi là mã trợ giúp tùy chọn.

Có một số lĩnh vực mà những người trợ giúp này có thể nhóm lại thành:

* Người trợ giúp thực hiện cài đặt chế độ. Điều quan trọng ở đây là nguyên tử
  những người giúp đỡ. Trình điều khiển cũ vẫn thường sử dụng trình trợ giúp CRTC cũ. Cả hai đều chia sẻ
  cùng một bộ vtable trợ giúp thông thường. Đối với các trình điều khiển thực sự đơn giản (bất cứ điều gì
  điều đó sẽ rất phù hợp với hệ thống con fbdev không được dùng nữa) có
  cũng là những người trợ giúp ống hiển thị đơn giản.

* Có rất nhiều người trợ giúp để xử lý kết quả đầu ra. Đầu tiên là cây cầu chung
  người trợ giúp để xử lý các khối IP bộ mã hóa và bộ chuyển mã. Thứ hai là những người trợ giúp bảng điều khiển
  để xử lý thông tin và logic liên quan đến bảng điều khiển. Thêm vào đó là một bộ lớn
  trợ giúp cho các tiêu chuẩn bồn rửa khác nhau (DisplayPort, HDMI, MIPI DSI). Cuối cùng
  cũng có những công cụ trợ giúp chung để xử lý việc thăm dò đầu ra và để xử lý
  EDID.

* Nhóm trợ giúp cuối cùng liên quan đến giao diện người dùng của màn hình
  đường ống: Các mặt phẳng, xử lý các hình chữ nhật để kiểm tra tầm nhìn và cắt kéo,
  lật hàng đợi và các loại bit.

Tham khảo trợ giúp Modeset cho các Vtable thông thường
===========================================

.. kernel-doc:: include/drm/drm_modeset_helper_vtables.h
   :doc: overview

.. kernel-doc:: include/drm/drm_modeset_helper_vtables.h
   :internal:

.. _drm_atomic_helper:

Tham khảo các hàm trợ giúp của Atomic Modeset
=========================================

Tổng quan
--------

.. kernel-doc:: drivers/gpu/drm/drm_atomic_helper.c
   :doc: overview

Triển khai cam kết nguyên tử không đồng bộ
---------------------------------------

.. kernel-doc:: drivers/gpu/drm/drm_atomic_helper.c
   :doc: implementing nonblocking commit

Tham khảo các hàm trợ giúp
--------------------------

.. kernel-doc:: include/drm/drm_atomic_helper.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_atomic_helper.c
   :export:

Thiết lập lại và khởi tạo trạng thái nguyên tử
-------------------------------------

.. kernel-doc:: drivers/gpu/drm/drm_atomic_state_helper.c
   :doc: atomic state reset and initialization

Tài liệu tham khảo trợ giúp trạng thái nguyên tử
-----------------------------

.. kernel-doc:: drivers/gpu/drm/drm_atomic_state_helper.c
   :export:

Tài liệu tham khảo trợ giúp nguyên tử GEM
---------------------------

.. kernel-doc:: drivers/gpu/drm/drm_gem_atomic_helper.c
   :doc: overview

.. kernel-doc:: include/drm/drm_gem_atomic_helper.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_gem_atomic_helper.c
   :export:

Tài liệu tham khảo trợ giúp VBLANK
-----------------------

.. kernel-doc:: drivers/gpu/drm/drm_vblank_helper.c
   :doc: overview

.. kernel-doc:: include/drm/drm_vblank_helper.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_vblank_helper.c
   :export:

Tài liệu tham khảo về hàm trợ giúp fbdev
================================

.. kernel-doc:: drivers/gpu/drm/drm_fb_helper.c
   :doc: fbdev helpers

.. kernel-doc:: include/drm/drm_fb_helper.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_fb_helper.c
   :export:

tham chiếu các hàm trợ giúp định dạng
=================================

.. kernel-doc:: drivers/gpu/drm/drm_format_helper.c
   :export:

Tham khảo chức năng của bộ đệm khung DMA
==========================================

.. kernel-doc:: drivers/gpu/drm/drm_fb_dma_helper.c
   :doc: framebuffer dma helper functions

.. kernel-doc:: drivers/gpu/drm/drm_fb_dma_helper.c
   :export:

Tham khảo trợ giúp Framebuffer GEM
================================

.. kernel-doc:: drivers/gpu/drm/drm_gem_framebuffer_helper.c
   :doc: overview

.. kernel-doc:: drivers/gpu/drm/drm_gem_framebuffer_helper.c
   :export:

.. _drm_bridges:

Cầu
=======

Tổng quan
--------

.. kernel-doc:: drivers/gpu/drm/drm_bridge.c
   :doc: overview

Tích hợp trình điều khiển hiển thị
--------------------------

.. kernel-doc:: drivers/gpu/drm/drm_bridge.c
   :doc: display driver integration

Chăm sóc đặc biệt với cầu MIPI-DSI
----------------------------------

.. kernel-doc:: drivers/gpu/drm/drm_bridge.c
   :doc: special care dsi

Vận hành cầu
-----------------

.. kernel-doc:: drivers/gpu/drm/drm_bridge.c
   :doc: bridge operations

Trình trợ giúp kết nối cầu
-----------------------

.. kernel-doc:: drivers/gpu/drm/display/drm_bridge_connector.c
   :doc: overview


Tài liệu tham khảo của người trợ giúp cầu nối
-------------------------

.. kernel-doc:: include/drm/drm_bridge.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_bridge.c
   :export:

Vận hành cầu MIPI-DSI
-------------------------

.. kernel-doc:: drivers/gpu/drm/drm_bridge.c
   :doc: dsi bridge operations


Tài liệu tham khảo của người trợ giúp kết nối cầu
---------------------------------

.. kernel-doc:: drivers/gpu/drm/display/drm_bridge_connector.c
   :export:

Tài liệu tham khảo trợ giúp cầu bảng điều khiển
-----------------------------

.. kernel-doc:: drivers/gpu/drm/bridge/panel.c
   :export:

.. _drm_panel_helper:

Tài liệu tham khảo của người trợ giúp bảng điều khiển
======================

.. kernel-doc:: drivers/gpu/drm/drm_panel.c
   :doc: drm panel

.. kernel-doc:: include/drm/drm_panel.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_panel.c
   :export:

.. kernel-doc:: drivers/gpu/drm/drm_panel_orientation_quirks.c
   :export:

.. kernel-doc:: drivers/gpu/drm/drm_panel_backlight_quirks.c
   :export:

Tài liệu tham khảo về trình trợ giúp tự làm mới bảng điều khiển
===================================

.. kernel-doc:: drivers/gpu/drm/drm_self_refresh_helper.c
   :doc: overview

.. kernel-doc:: drivers/gpu/drm/drm_self_refresh_helper.c
   :export:

Người trợ giúp trạng thái nguyên tử HDMI
=========================

Tổng quan
--------

.. kernel-doc:: drivers/gpu/drm/display/drm_hdmi_state_helper.c
   :doc: hdmi helpers

Tham khảo chức năng
-------------------

.. kernel-doc:: drivers/gpu/drm/display/drm_hdmi_state_helper.c
   :export:

Tham khảo chức năng trợ giúp HDCP
===============================

.. kernel-doc:: drivers/gpu/drm/display/drm_hdcp_helper.c
   :export:

Tham chiếu chức năng trợ giúp cổng hiển thị
=======================================

.. kernel-doc:: drivers/gpu/drm/display/drm_dp_helper.c
   :doc: dp helpers

.. kernel-doc:: include/drm/display/drm_dp.h
   :internal:

.. kernel-doc:: include/drm/display/drm_dp_helper.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/display/drm_dp_helper.c
   :export:

Tham khảo chức năng của trình trợ giúp cổng hiển thị CEC
===========================================

.. kernel-doc:: drivers/gpu/drm/display/drm_dp_cec.c
   :doc: dp cec helpers

.. kernel-doc:: drivers/gpu/drm/display/drm_dp_cec.c
   :export:

Cổng hiển thị Chức năng trợ giúp bộ điều hợp chế độ kép Tham khảo
=========================================================

.. kernel-doc:: drivers/gpu/drm/display/drm_dp_dual_mode_helper.c
   :doc: dp dual mode helpers

.. kernel-doc:: include/drm/display/drm_dp_dual_mode_helper.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/display/drm_dp_dual_mode_helper.c
   :export:

Trình trợ giúp cổng hiển thị MST
========================

Tổng quan
--------

.. kernel-doc:: drivers/gpu/drm/display/drm_dp_mst_topology.c
   :doc: dp mst helper

.. kernel-doc:: drivers/gpu/drm/display/drm_dp_mst_topology.c
   :doc: Branch device and port refcounting

Tham khảo chức năng
-------------------

.. kernel-doc:: include/drm/display/drm_dp_mst_helper.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/display/drm_dp_mst_topology.c
   :export:

Cấu trúc liên kết nội bộ trọn đời
---------------------------

Các chức năng này không được xuất sang trình điều khiển nhưng được ghi lại ở đây để giúp thực hiện
Trình trợ giúp cấu trúc liên kết MST dễ hiểu hơn

.. kernel-doc:: drivers/gpu/drm/display/drm_dp_mst_topology.c
   :functions: drm_dp_mst_topology_try_get_mstb drm_dp_mst_topology_get_mstb
               drm_dp_mst_topology_put_mstb
               drm_dp_mst_topology_try_get_port drm_dp_mst_topology_get_port
               drm_dp_mst_topology_put_port
               drm_dp_mst_get_mstb_malloc drm_dp_mst_put_mstb_malloc

Tham khảo chức năng trợ giúp MIPI DBI
===================================

.. kernel-doc:: drivers/gpu/drm/drm_mipi_dbi.c
   :doc: overview

.. kernel-doc:: include/drm/drm_mipi_dbi.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_mipi_dbi.c
   :export:

Tham khảo chức năng trợ giúp MIPI DSI
===================================

.. kernel-doc:: drivers/gpu/drm/drm_mipi_dsi.c
   :doc: dsi helpers

.. kernel-doc:: include/drm/drm_mipi_dsi.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_mipi_dsi.c
   :export:

Tham chiếu chức năng trợ giúp nén luồng hiển thị
=====================================================

.. kernel-doc:: drivers/gpu/drm/display/drm_dsc_helper.c
   :doc: dsc helpers

.. kernel-doc:: include/drm/display/drm_dsc.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/display/drm_dsc_helper.c
   :export:

Tham khảo các hàm trợ giúp thăm dò đầu ra
=========================================

.. kernel-doc:: drivers/gpu/drm/drm_probe_helper.c
   :doc: output probing helper overview

.. kernel-doc:: drivers/gpu/drm/drm_probe_helper.c
   :export:

Tham khảo chức năng trợ giúp EDID
===============================

.. kernel-doc:: include/drm/drm_edid.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_edid.c
   :export:

.. kernel-doc:: include/drm/drm_eld.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_eld.c
   :export:

Tham khảo chức năng trợ giúp SCDC
===============================

.. kernel-doc:: drivers/gpu/drm/display/drm_scdc_helper.c
   :doc: scdc helpers

.. kernel-doc:: include/drm/display/drm_scdc_helper.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/display/drm_scdc_helper.c
   :export:

Tài liệu tham khảo trợ giúp khung thông tin HDMI
================================

Nói đúng ra đây không phải là thư viện trợ giúp DRM nhưng nhìn chung có thể sử dụng được
bởi bất kỳ trình điều khiển nào giao tiếp với đầu ra HDMI như trình điều khiển v4l hoặc alsa.
Nhưng nó rất phù hợp với chủ đề chung của trình trợ giúp cài đặt chế độ
thư viện và do đó cũng được bao gồm ở đây.

.. kernel-doc:: include/linux/hdmi.h
   :internal:

.. kernel-doc:: drivers/video/hdmi.c
   :export:

Tham khảo tiện ích hình chữ nhật
=============================

.. kernel-doc:: include/drm/drm_rect.h
   :doc: rect utils

.. kernel-doc:: include/drm/drm_rect.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_rect.c
   :export:

Tài liệu tham khảo về người trợ giúp công việc lật
==========================

.. kernel-doc:: include/drm/drm_flip_work.h
   :doc: flip utils

.. kernel-doc:: include/drm/drm_flip_work.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_flip_work.c
   :export:

Người trợ giúp chế độ phụ trợ
=========================

.. kernel-doc:: drivers/gpu/drm/drm_modeset_helper.c
   :doc: aux kms helpers

.. kernel-doc:: drivers/gpu/drm/drm_modeset_helper.c
   :export:

Người trợ giúp OF/DT
=============

.. kernel-doc:: drivers/gpu/drm/drm_of.c
   :doc: overview

.. kernel-doc:: drivers/gpu/drm/drm_of.c
   :export:

Tài liệu tham khảo về người trợ giúp máy bay kế thừa
=============================

.. kernel-doc:: drivers/gpu/drm/drm_plane_helper.c
   :doc: overview

.. kernel-doc:: drivers/gpu/drm/drm_plane_helper.c
   :export:

Tham khảo các chức năng trợ giúp của Modeset CRTC/Modeset kế thừa
==============================================

.. kernel-doc:: drivers/gpu/drm/drm_crtc_helper.c
   :doc: overview

.. kernel-doc:: drivers/gpu/drm/drm_crtc_helper.c
   :export:

Lớp kiểm soát quyền riêng tư
====================

.. kernel-doc:: drivers/gpu/drm/drm_privacy_screen.c
   :doc: overview

.. kernel-doc:: include/drm/drm_privacy_screen_driver.h
   :internal:

.. kernel-doc:: include/drm/drm_privacy_screen_machine.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_privacy_screen.c
   :export:
