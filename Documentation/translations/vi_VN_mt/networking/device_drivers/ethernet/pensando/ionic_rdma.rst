.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/pensando/ionic_rdma.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================================================
Trình điều khiển RDMA dành cho dòng bộ điều hợp Ethernet AMD Pensando(R)
========================================================================

Trình điều khiển AMD Pensando RDMA.
Bản quyền (C) 2018-2025, Advanced Micro Devices, Inc.

Tổng quan
=========

Trình điều khiển ionic_rdma cung cấp chức năng Truy cập bộ nhớ trực tiếp từ xa
dành cho thiết bị AMD Pensando DSC (Thẻ dịch vụ phân phối). Người lái xe này
triển khai các khả năng của RDMA như một trình điều khiển phụ hoạt động trong
kết hợp với trình điều khiển ethernet ion.

Trình điều khiển ethernet ion phát hiện khả năng RDMA trong thiết bị
khởi tạo và tạo các thiết bị phụ trợ mà trình điều khiển ionic_rdma
liên kết với, thiết lập đường dẫn dữ liệu RDMA và giao diện điều khiển.

Xác định bộ chuyển đổi
=======================

Xem Tài liệu/mạng/device_drivers/ethernet/pensando/ionic.rst
để biết thêm thông tin về cách xác định bộ chuyển đổi.

Kích hoạt trình điều khiển
==========================

Trình điều khiển ionic_rdma phụ thuộc vào trình điều khiển ethernet ion.
Xem Tài liệu/mạng/device_drivers/ethernet/pensando/ionic.rst
để biết thông tin chi tiết về cách bật và định cấu hình trình điều khiển ion.

Trình điều khiển ionic_rdma được kích hoạt thông qua hệ thống cấu hình kernel tiêu chuẩn,
sử dụng lệnh tạo ::

tạo oldconfig/menuconfig/etc.

Trình điều khiển nằm trong cấu trúc menu tại:

-> Trình điều khiển thiết bị
    -> Hỗ trợ InfiniBand
      -> Hỗ trợ AMD Pensando DSC RDMA/RoCE

Ủng hộ
=======

Để được hỗ trợ chung về Linux RDMA, vui lòng sử dụng gửi thư RDMA
danh sách, được giám sát bởi nhân viên AMD Pensando::

linux-rdma@vger.kernel.org