.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/PCI/endpoint/pci-vntb-function.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===================
Chức năng PCI vNTB
=================

:Tác giả: Frank Li <Frank.Li@nxp.com>

Sự khác biệt giữa chức năng PCI NTB và chức năng PCI vNTB là

Chức năng PCI NTB cần ở hai phiên bản điểm cuối và kết nối HOST1
và HOST2.

Chức năng PCI vNTB chỉ sử dụng một máy chủ và một điểm cuối (EP), sử dụng NTB
kết nối máy chủ EP và PCI

.. code-block:: text


  +------------+         +---------------------------------------+
  |            |         |                                       |
  +------------+         |                        +--------------+
  | NTB        |         |                        | NTB          |
  | NetDev     |         |                        | NetDev       |
  +------------+         |                        +--------------+
  | NTB        |         |                        | NTB          |
  | Transfer   |         |                        | Transfer     |
  +------------+         |                        +--------------+
  |            |         |                        |              |
  |  PCI NTB   |         |                        |              |
  |    EPF     |         |                        |              |
  |   Driver   |         |                        | PCI Virtual  |
  |            |         +---------------+        | NTB Driver   |
  |            |         | PCI EP NTB    |<------>|              |
  |            |         |  FN Driver    |        |              |
  +------------+         +---------------+        +--------------+
  |            |         |               |        |              |
  |  PCI BUS   | <-----> |  PCI EP BUS   |        |  Virtual PCI |
  |            |  PCI    |               |        |     BUS      |
  +------------+         +---------------+--------+--------------+
      PCI RC                        PCI EP

Các cấu trúc dùng để triển khai vNTB
=====================================

1) Vùng cấu hình
	2) Thanh ghi tự Scratchpad
	3) Thanh ghi Scratchpad ngang hàng
	4) Thanh ghi chuông cửa (DB)
	5) Cửa sổ bộ nhớ (MW)


Vùng cấu hình:
--------------

Nó giống như trình điều khiển chức năng PCI NTB

Thanh ghi Scratchpad:
---------------------

Nó được thêm vào sau vùng Cấu hình.

.. code-block:: text


  +--------------------------------------------------+ Base
  |                                                  |
  |                                                  |
  |                                                  |
  |          Common Config Register                  |
  |                                                  |
  |                                                  |
  |                                                  |
  +-----------------------+--------------------------+ Base + span_offset
  |                       |                          |
  |    Peer Span Space    |    Span Space            |
  |                       |                          |
  |                       |                          |
  +-----------------------+--------------------------+ Base + span_offset
  |                       |                          |      + span_count * 4
  |                       |                          |
  |     Span Space        |   Peer Span Space        |
  |                       |                          |
  +-----------------------+--------------------------+
        Virtual PCI             Pcie Endpoint
        NTB Driver               NTB Driver


Thanh ghi chuông cửa:
-------------------

Các thanh ghi chuông cửa được các máy chủ sử dụng để làm gián đoạn lẫn nhau.

Cửa sổ bộ nhớ:
--------------

Việc truyền dữ liệu thực tế giữa hai máy chủ sẽ diễn ra bằng cách sử dụng
  cửa sổ bộ nhớ.

Cấu trúc mô hình hóa:
====================

BAR 32-bit.

====== =================
BAR KHÔNG CONSTRUCTS USED
====== =================
Vùng cấu hình BAR0
Chuông cửa BAR1
Cửa sổ bộ nhớ BAR2 1
Cửa sổ bộ nhớ BAR3 2
Cửa sổ bộ nhớ BAR4 3
Cửa sổ bộ nhớ BAR5 4
====== =================

BAR 64-bit.

========================================
BAR KHÔNG CONSTRUCTS USED
========================================
Vùng cấu hình BAR0 + Scratchpad
BAR1
Chuông cửa BAR2
BAR3
Cửa sổ bộ nhớ BAR4 1
BAR5
========================================

