.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/gpu/amdgpu/display/display-manager.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================
Trình quản lý hiển thị AMDgpu
======================

.. contents:: Table of Contents
    :depth: 3

.. kernel-doc:: drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm.c
   :doc: overview

.. kernel-doc:: drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm.h
   :internal:

Vòng đời
=========

.. kernel-doc:: drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm.c
   :doc: DM Lifecycle

.. kernel-doc:: drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm.c
   :functions: dm_hw_init dm_hw_fini

Ngắt
==========

.. kernel-doc:: drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm_irq.c
   :doc: overview

.. kernel-doc:: drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm_irq.c
   :internal:

.. kernel-doc:: drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm.c
   :functions: register_hpd_handlers dm_crtc_high_irq dm_pflip_high_irq

Thực hiện nguyên tử
=====================

.. kernel-doc:: drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm.c
   :doc: atomic

.. kernel-doc:: drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm.c
   :functions: amdgpu_dm_atomic_check amdgpu_dm_atomic_commit_tail

Thuộc tính quản lý màu
===========================

.. kernel-doc:: drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm_color.c
   :doc: overview

.. kernel-doc:: drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm_color.c
   :internal:


Khả năng màu DC giữa các thế hệ DCN
---------------------------------------------

Khung DRM/KMS xác định ba thuộc tính hiệu chỉnh màu CRTC: degamma,
ma trận chuyển đổi màu (CTM) và gamma, cùng hai thuộc tính cho degamma và
kích thước gamma LUT. AMD DC lập trình một số tính năng chỉnh màu
trộn trước nhưng DRM/KMS không có đặc tính hiệu chỉnh màu trên mỗi mặt phẳng.

Nói chung, thuộc tính màu DRM CRTC được lập trình thành DC, như sau:
CRTC gamma sau khi trộn và CRTC degamma trước khi trộn. Mặc dù CTM là
được lập trình sau khi trộn, nó được ánh xạ tới các khối hw DPP (trộn trước). Khác
mũ màu có sẵn trong hw hiện không được hiển thị bởi giao diện DRM và
được bỏ qua.

.. kernel-doc:: drivers/gpu/drm/amd/display/dc/dc.h
   :doc: color-management-caps

.. kernel-doc:: drivers/gpu/drm/amd/display/dc/dc.h
   :internal:

Đường dẫn màu đã trải qua những thay đổi lớn giữa phần cứng DCN
nhiều thế hệ. Những gì có thể làm trước và sau khi trộn phụ thuộc vào
khả năng phần cứng, như được minh họa bên dưới bởi dòng DCN 2.0 và DCN 3.0
lược đồ.

ZZ0000ZZ

.. kernel-figure:: dcn2_cm_drm_current.svg

ZZ0000ZZ

.. kernel-figure:: dcn3_cm_drm_current.svg

Thuộc tính chế độ hòa trộn
=====================

Chế độ hòa trộn pixel là thuộc tính bố cục mặt phẳng DRM của ZZ0000ZZ được sử dụng để
mô tả cách các pixel từ mặt phẳng tiền cảnh (fg) được kết hợp với
mặt phẳng nền (bg). Ở đây, chúng tôi trình bày các khái niệm chính về chế độ hòa trộn DRM để giúp
để hiểu cách ánh xạ thuộc tính này tới giao diện AMD DC. Xem thêm về
thuộc tính DRM này và các phương trình trộn alpha trong ZZ0001ZZ.

Về cơ bản, chế độ hòa trộn đặt phương trình hòa trộn alpha cho mặt phẳng
thành phần phù hợp với chế độ mà kênh alpha ảnh hưởng đến trạng thái
giá trị màu pixel và do đó, màu pixel thu được. cho
Ví dụ, hãy xem xét các phần tử sau của phương trình trộn alpha:

- ZZ0002ZZ: Mỗi giá trị thành phần RGB từ pixel của nền trước.
- ZZ0003ZZ: Giá trị thành phần Alpha từ pixel của nền trước.
- ZZ0004ZZ: Mỗi giá trị thành phần RGB từ nền.
- ZZ0005ZZ: Giá trị alpha mặt phẳng được thiết lập bởi ZZ0001ZZ, xem
  nhiều hơn nữa trong ZZ0000ZZ.

trong phương trình trộn alpha cơ bản::

out.rgb = alpha * fg.rgb + (1 - alpha) * bg.rgb

giá trị kênh alpha của mỗi pixel trong một mặt phẳng bị bỏ qua và chỉ mặt phẳng đó
alpha ảnh hưởng đến giá trị màu pixel thu được.

DRM có ba chế độ hòa trộn để xác định công thức hòa trộn trong thành phần mặt phẳng:

* ZZ0000ZZ: Công thức hòa trộn bỏ qua pixel alpha.

* ZZ0000ZZ: Công thức hòa trộn giả định các giá trị màu pixel trong một
  mặt phẳng đã được nhân trước với kênh alpha của chính nó trước khi lưu trữ.

* ZZ0000ZZ: Công thức hòa trộn giả định các giá trị màu pixel không
  được nhân trước với các giá trị kênh alpha.

và được nhân trước là chế độ hòa trộn pixel mặc định, có nghĩa là khi không hòa trộn
thuộc tính chế độ được tạo hoặc xác định, DRM coi các pixel của mặt phẳng có
giá trị màu được nhân trước. Trên các công cụ IGT GPU, bài kiểm tra kms_plane_alpha_blend
cung cấp một tập hợp các phép trừ để xác minh các thuộc tính chế độ hòa trộn và alpha mặt phẳng.

Chế độ hòa trộn DRM và các phần tử của nó sau đó được ánh xạ bởi trình quản lý hiển thị AMDGPU
(DM) để lập trình cấu hình trộn của Hệ thống kết hợp nhiều ống/mặt phẳng
(MPC), như sau:

.. kernel-doc:: drivers/gpu/drm/amd/display/dc/inc/hw/mpc.h
   :identifiers: mpcc_blnd_cfg

Do đó, cấu hình trộn cho một phiên bản MPCC duy nhất trên MPC
cây được xác định bởi ZZ0000ZZ, trong đó
ZZ0001ZZ là cờ chế độ nhân trước alpha được sử dụng để
đặt ZZ0002ZZ. Nó kiểm soát liệu alpha có phải là
được nhân lên (đúng/sai), chỉ đúng với chế độ hòa trộn được nhân trước của DRM.
ZZ0003ZZ xác định chế độ hòa trộn alpha liên quan đến pixel
giá trị alpha và alpha phẳng. Nó đặt một trong ba chế độ cho
ZZ0004ZZ, như được mô tả bên dưới.

.. kernel-doc:: drivers/gpu/drm/amd/display/dc/inc/hw/mpc.h
   :identifiers: mpcc_alpha_blend_mode

DM sau đó ánh xạ các phần tử của ZZ0000ZZ tới các phần tử trong DRM
công thức pha trộn như sau:

* ZZ0000ZZ khớp với ZZ0001ZZ làm giá trị thành phần alpha
  từ pixel của máy bay
* ZZ0002ZZ khớp với ZZ0003ZZ khi pixel alpha cần
  bị bỏ qua và do đó, giá trị pixel không được nhân trước
* ZZ0004ZZ giả định giá trị ZZ0005ZZ khi cả hai *DRM
  fg.alpha* và ZZ0006ZZ tham gia vào phương trình hòa trộn

Nói tóm lại, ZZ0003ZZ bị bỏ qua bằng cách chọn
ZZ0000ZZ. Mặt khác, (plane_alpha *
thành phần fg.alpha) sẽ khả dụng bằng cách chọn
ZZ0001ZZ. Và
ZZ0002ZZ xác định xem giá trị màu pixel có
nhân trước với alpha hay không.

Pha trộn luồng cấu hình
------------------------

Phương trình trộn alpha được cấu hình từ giao diện DRM sang DC bởi
đường dẫn sau:

1. Khi cập nhật ZZ0000ZZ, DM gọi
   ZZ0001ZZ bản đồ
   Thuộc tính ZZ0002ZZ cho
   Cấu trúc ZZ0003ZZ được xử lý trong
   Thành phần bất khả tri của hệ điều hành (DC).

2. Trên giao diện DC, ZZ0000ZZ lập trình
   Cấu hình hỗn hợp MPCC xem xét đầu vào ZZ0001ZZ từ DPP.
