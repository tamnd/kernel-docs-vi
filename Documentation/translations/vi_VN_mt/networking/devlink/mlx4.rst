.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/mlx4.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================
hỗ trợ liên kết phát triển mlx4
====================

Tài liệu này mô tả các tính năng của devlink được ZZ0000ZZ triển khai
trình điều khiển thiết bị.

Thông số
==========

.. list-table:: Generic parameters implemented

   * - Name
     - Mode
   * - ``internal_err_reset``
     - driverinit, runtime
   * - ``max_macs``
     - driverinit
   * - ``region_snapshot_enable``
     - driverinit, runtime

Trình điều khiển ZZ0000ZZ cũng triển khai các trình điều khiển cụ thể sau:
các thông số.

.. list-table:: Driver-specific parameters implemented
   :widths: 5 5 5 85

   * - Name
     - Type
     - Mode
     - Description
   * - ``enable_64b_cqe_eqe``
     - Boolean
     - driverinit
     - Enable 64 byte CQEs/EQEs, if the FW supports it.
   * - ``enable_4k_uar``
     - Boolean
     - driverinit
     - Enable using the 4k UAR.

Trình điều khiển ZZ0000ZZ hỗ trợ tải lại qua ZZ0001ZZ

Khu vực
=======

Driver ZZ0000ZZ hỗ trợ dump firmware PCI crspace và health
đệm trong khi xảy ra sự cố phần mềm quan trọng.

Trong trường hợp lệnh chương trình cơ sở hết thời gian, chương trình cơ sở bị kẹt hoặc khác 0
giá trị trên bộ đệm thảm khốc, trình điều khiển sẽ chụp ảnh nhanh.

Vùng ZZ0000ZZ sẽ chứa nội dung crspace PCI của phần sụn. các
Vùng ZZ0001ZZ sẽ chứa bộ đệm tình trạng của phần sụn thiết bị.
Ảnh chụp nhanh cho cả hai khu vực này được thực hiện trên cùng một trình kích hoạt sự kiện.