.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/fpga/fpga-region.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Vùng FPGA
===========

Tổng quan
---------

This document is meant to be a brief overview of the FPGA region API usage.  A
cái nhìn mang tính khái niệm hơn về các vùng có thể được tìm thấy trong liên kết Cây thiết bị
tài liệu [#f1]_.

Vì mục đích của tài liệu API này, giả sử rằng một khu vực liên kết
Trình quản lý FPGA và một cầu nối (hoặc các cầu nối) với vùng có thể lập trình lại của một
FPGA hoặc toàn bộ FPGA.  API cung cấp cách đăng ký vùng và
lập trình một vùng.

Hiện tại lớp duy nhất phía trên fpga-khu vực.c trong kernel là Cây thiết bị
hỗ trợ (of-fpga-khu vực.c) được mô tả trong [#f1]_.  Lớp hỗ trợ DT sử dụng các vùng
để lập trình FPGA và sau đó là DT để xử lý việc liệt kê.  Mã vùng chung
được dự định sẽ được sử dụng bởi các chương trình khác có những cách khác để hoàn thành
liệt kê sau khi lập trình.

Một vùng fpga có thể được thiết lập để biết những điều sau:

* Trình quản lý FPGA nào sẽ được sử dụng để lập trình

* nên tắt cầu nối nào trước khi lập trình và kích hoạt sau đó.

Thông tin bổ sung cần thiết để lập trình hình ảnh FPGA được truyền vào cấu trúc
fpga_image_info bao gồm:

* con trỏ tới hình ảnh dưới dạng bộ đệm thu thập phân tán, liền kề
   bộ đệm hoặc tên của tệp chương trình cơ sở

* cờ biểu thị các chi tiết cụ thể như liệu hình ảnh có phải là một phần hay không
   cấu hình lại.

Cách thêm vùng FPGA mới
----------------------------

Bạn có thể xem ví dụ về cách sử dụng trong chức năng thăm dò của [#f2]_.

.. [#f1] ../devicetree/bindings/fpga/fpga-region.txt
.. [#f2] ../../drivers/fpga/of-fpga-region.c

API để thêm vùng FPGA mới
----------------------------

* struct fpga_zone - Cấu trúc vùng FPGA
* struct fpga_khu vực_info - Cấu trúc tham số cho __fpga_khu vực_register_full()
* __fpga_zone_register_full() - Tạo và đăng ký vùng FPGA bằng cách sử dụng
  Cấu trúc fpga_khu vực_info để cung cấp đầy đủ tính linh hoạt của các tùy chọn
* __fpga_khu vực_register() - Tạo và đăng ký vùng FPGA bằng tiêu chuẩn
  lý lẽ
* fpga_zone_unregister() - Hủy đăng ký vùng FPGA

Macro trợ giúp ZZ0000ZZ và ZZ0001ZZ
tự động đặt mô-đun đăng ký vùng FPGA làm chủ sở hữu.

Chức năng thăm dò của vùng FPGA sẽ cần có tham chiếu đến FPGA
Trình quản lý nó sẽ được sử dụng để lập trình.  Điều này thường sẽ xảy ra
trong chức năng thăm dò của khu vực.

* fpga_mgr_get() - Nhận tham chiếu đến người quản lý FPGA, tăng số lượng giới thiệu
* of_fpga_mgr_get() - Tham khảo người quản lý FPGA, tăng số lượng giới thiệu,
  đưa ra một nút thiết bị.
* fpga_mgr_put() - Đặt trình quản lý FPGA

Vùng FPGA sẽ cần chỉ định cầu nối nào sẽ điều khiển trong khi lập trình
FPGA.  Trình điều khiển khu vực có thể xây dựng danh sách các cây cầu trong thời gian thăm dò
(ZZ0000ZZ) hoặc nó có thể có chức năng tạo
danh sách các cầu nối để lập trình ngay trước khi lập trình
(ZZ0001ZZ).  Khung cầu FPGA cung cấp
các API sau để xử lý việc xây dựng hoặc phá bỏ danh sách đó.

* fpga_bridge_get_to_list() - Nhận thông tin giới thiệu về cầu nối FPGA, thêm nó vào
  danh sách
* of_fpga_bridge_get_to_list() - Nhận thông tin giới thiệu về cầu nối FPGA, thêm nó vào
  danh sách, được cung cấp một nút thiết bị
* fpga_bridges_put() - Đưa ra danh sách các bridge, đặt chúng

.. kernel-doc:: include/linux/fpga/fpga-region.h
   :functions: fpga_region

.. kernel-doc:: include/linux/fpga/fpga-region.h
   :functions: fpga_region_info

.. kernel-doc:: drivers/fpga/fpga-region.c
   :functions: __fpga_region_register_full

.. kernel-doc:: drivers/fpga/fpga-region.c
   :functions: __fpga_region_register

.. kernel-doc:: drivers/fpga/fpga-region.c
   :functions: fpga_region_unregister

.. kernel-doc:: drivers/fpga/fpga-mgr.c
   :functions: fpga_mgr_get

.. kernel-doc:: drivers/fpga/fpga-mgr.c
   :functions: of_fpga_mgr_get

.. kernel-doc:: drivers/fpga/fpga-mgr.c
   :functions: fpga_mgr_put

.. kernel-doc:: drivers/fpga/fpga-bridge.c
   :functions: fpga_bridge_get_to_list

.. kernel-doc:: drivers/fpga/fpga-bridge.c
   :functions: of_fpga_bridge_get_to_list

.. kernel-doc:: drivers/fpga/fpga-bridge.c
   :functions: fpga_bridges_put
