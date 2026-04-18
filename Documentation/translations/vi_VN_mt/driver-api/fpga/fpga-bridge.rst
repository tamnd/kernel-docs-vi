.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/fpga/fpga-bridge.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Cầu FPGA
===========

API triển khai cầu FPGA mới
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* struct fpga_bridge - Cấu trúc cầu FPGA
* struct fpga_bridge_ops - Hoạt động của trình điều khiển Bridge cấp thấp
* __fpga_bridge_register() - Tạo và đăng ký một cây cầu
* fpga_bridge_unregister() - Hủy đăng ký một cây cầu

Macro trợ giúp ZZ0000ZZ tự động thiết lập
mô-đun đăng ký cầu FPGA làm chủ sở hữu.

.. kernel-doc:: include/linux/fpga/fpga-bridge.h
   :functions: fpga_bridge

.. kernel-doc:: include/linux/fpga/fpga-bridge.h
   :functions: fpga_bridge_ops

.. kernel-doc:: drivers/fpga/fpga-bridge.c
   :functions: __fpga_bridge_register

.. kernel-doc:: drivers/fpga/fpga-bridge.c
   :functions: fpga_bridge_unregister
