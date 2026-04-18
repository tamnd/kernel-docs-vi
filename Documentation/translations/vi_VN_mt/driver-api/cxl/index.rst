.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================
Tính toán liên kết nhanh
====================

Cấu hình thiết bị CXL có sự chuyển giao phức tạp giữa nền tảng (Phần cứng,
BIOS, EFI), hệ điều hành (khởi động sớm, kernel lõi, trình điều khiển) và các quyết định chính sách người dùng
đó có tác động lẫn nhau.  Các tài liệu ở đây chia nhỏ các bước cấu hình.

.. toctree::
   :maxdepth: 2
   :caption: Overview

   theory-of-operation
   maturity-map
   conventions

.. toctree::
   :maxdepth: 2
   :caption: Device Reference

   devices/device-types

.. toctree::
   :maxdepth: 2
   :caption: Platform Configuration

   platform/bios-and-efi
   platform/acpi
   platform/cdat
   platform/example-configs
   platform/device-hotplug

.. toctree::
   :maxdepth: 2
   :caption: Linux Kernel Configuration

   linux/overview
   linux/early-boot
   linux/cxl-driver
   linux/dax-driver
   linux/memory-hotplug
   linux/access-coordinates

.. toctree::
   :maxdepth: 2
   :caption: Memory Allocation

   allocation/dax
   allocation/page-allocator
   allocation/reclaim
   allocation/hugepages.rst