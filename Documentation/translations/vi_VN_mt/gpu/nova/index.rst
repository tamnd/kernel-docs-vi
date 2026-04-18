.. SPDX-License-Identifier: (GPL-2.0+ OR MIT)

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/gpu/nova/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========================
trình điều khiển nova NVIDIA GPU
=======================

Dự án trình điều khiển nova bao gồm hai trình điều khiển riêng biệt nova-core và
nova-drm và dự định thay thế trình điều khiển mới cho GPU NVIDIA dựa trên
Bộ xử lý hệ thống GPU (GSP).

Các tài liệu sau đây áp dụng cho cả nova-core và nova-drm.

.. toctree::
   :titlesonly:

   guidelines

lõi nova
=========

Trình điều khiển nova-core là trình điều khiển cốt lõi cho GPU NVIDIA dựa trên GSP. lõi nova,
với tư cách là trình điều khiển cấp 1, cung cấp sự trừu tượng hóa xung quanh GPU cứng và
giao diện phần sụn cung cấp cơ sở chung cho trình điều khiển cấp 2, chẳng hạn như
Trình quản lý vGPU VFIO và trình điều khiển nova-drm.

.. toctree::
   :titlesonly:

   core/guidelines
   core/todo
   core/vbios
   core/devinit
   core/fwsec
   core/falcon