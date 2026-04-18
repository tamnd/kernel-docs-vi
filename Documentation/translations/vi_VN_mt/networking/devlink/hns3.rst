.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/hns3.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================
hỗ trợ liên kết phát triển hns3
====================

Tài liệu này mô tả các tính năng của devlink được ZZ0000ZZ triển khai
trình điều khiển thiết bị.

Trình điều khiển ZZ0000ZZ hỗ trợ tải lại qua ZZ0001ZZ.

Phiên bản thông tin
=============

Trình điều khiển ZZ0000ZZ báo cáo các phiên bản sau

.. list-table:: devlink info versions implemented
   :widths: 10 10 80

   * - Name
     - Type
     - Description
   * - ``fw``
     - running
     - Used to represent the firmware version.
   * - ``fw.scc``
     - running
     - Used to represent the Soft Congestion Control (SSC) firmware version.
       SCC is a firmware component which provides multiple RDMA congestion
       control algorithms, including DCQCN.