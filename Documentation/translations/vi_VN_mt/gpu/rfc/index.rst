.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/gpu/rfc/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================
Phần GPU RFC
===============

Đối với công việc phức tạp, đặc biệt là uapi mới, việc đạt được mức cao thường là điều tốt
các vấn đề về thiết kế trước khi bị lạc vào các chi tiết mã. Phần này nhằm mục đích
lưu trữ tài liệu như vậy:

* Mỗi RFC phải là một phần trong tệp này, giải thích mục tiêu và thiết kế chính
  cân nhắc. Đặc biệt đối với uapi, hãy đảm bảo bạn Cc: tất cả các dự án có liên quan
  danh sách gửi thư và những người có liên quan bên ngoài dri-devel.

* Đối với cấu trúc uapi, hãy thêm một tệp vào thư mục này và sau đó kéo
  kerneldoc giống như các tiêu đề uapi thực.

* Sau khi mã đã xuất hiện, hãy di chuyển tất cả tài liệu đến đúng vị trí trong
  phần lõi chính, phần trợ giúp hoặc trình điều khiển.

.. toctree::

    gpusvm.rst

.. toctree::

    i915_gem_lmem.rst

.. toctree::

    i915_scheduler.rst

.. toctree::

    i915_small_bar.rst

.. toctree::

    i915_vm_bind.rst

.. toctree::
    color_pipeline.rst