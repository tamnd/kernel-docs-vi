.. SPDX-License-Identifier: (GPL-2.0-only OR MIT)

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/c3-isp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

===========================================================
Trình điều khiển xử lý tín hiệu hình ảnh Amlogic C3 (C3ISP)
===========================================================

Giới thiệu
============

Tệp này ghi lại trình điều khiển Amlogic C3ISP nằm bên dưới
trình điều khiển/phương tiện/nền tảng/amlogic/c3/isp.

Phiên bản hiện tại của trình điều khiển hỗ trợ C3ISP được tìm thấy trên
Bộ xử lý Amlogic C308L.

Trình điều khiển triển khai các giao diện V4L2, Bộ điều khiển đa phương tiện và V4L2.
Hỗ trợ cảm biến camera sử dụng giao diện subdev V4L2 trong kernel.

Trình điều khiển đã được thử nghiệm trên nền tảng AW419-C308L-Socket.

Amlogic C3 ISP
==============

Phần cứng Máy ảnh được tìm thấy trên bộ xử lý C308L và được hỗ trợ bởi
người lái xe bao gồm:

- 1 module MIPI-CSI-2: xử lý lớp vật lý của bộ thu MIPI CSI-2 và
  nhận dữ liệu từ cảm biến camera được kết nối.
- 1 module MIPI-ADAPTER: tổ chức dữ liệu MIPI đáp ứng yêu cầu đầu vào ISP và
  gửi dữ liệu MIPI tới ISP.
- 1 module ISP (Xử lý tín hiệu hình ảnh): chứa một đường dẫn xử lý hình ảnh
  các khối phần cứng. Đường ống ISP chứa ba bộ thay đổi kích thước ở cuối mỗi đường dẫn.
  chúng được kết nối với giao diện DMA để ghi dữ liệu đầu ra vào bộ nhớ.

Dưới đây là chế độ xem chức năng cấp cao của C3 ISP.::

+----------+ +-------+
                                                                   ZZ0000ZZ--->ZZ0001ZZ
  +----------+ +-------------+ +--------------+ +-------+ |----------+ +-------+
  ZZ0002ZZ--->ZZ0003ZZ--->ZZ0004ZZ--->ZZ0005ZZ---|----------+ +-------+
  +----------+ +-------------+ +--------------+ +-------+ ZZ0006ZZ--->ZZ0007ZZ
                                                                   +----------+ +-------+
                                                                   |----------+ +-------+
                                                                   ZZ0008ZZ--->ZZ0009ZZ
                                                                   +----------+ +-------+

Kiến trúc và thiết kế trình điều khiển
==============================

Với mục tiêu mô hình hóa các liên kết phần cứng giữa các mô-đun và để lộ ra một
giao diện sạch sẽ, hợp lý và có thể sử dụng, trình điều khiển đăng ký V4L2 sau
thiết bị phụ:

- 1 thiết bị phụ ZZ0000ZZ - bộ thu MIPI CSI-2
- 1 thiết bị phụ ZZ0001ZZ - bộ chuyển đổi MIPI
- 1 thiết bị phụ ZZ0002ZZ - lõi ISP
- 3 thiết bị phụ ZZ0003ZZ - bộ thay đổi kích thước ISP

Thiết bị con ZZ0000ZZ được liên kết với 2 nút thiết bị video để thống kê
lập trình chụp và tham số:

- nút thiết bị quay video ZZ0000ZZ để thu thập số liệu thống kê
- thiết bị video đầu ra ZZ0001ZZ để lập trình thông số

Mỗi thiết bị phụ ZZ0000ZZ được liên kết với nút thiết bị quay video trong đó
khung hình được chụp từ:

- ZZ0000ZZ được liên kết với thiết bị quay video ZZ0001ZZ
- ZZ0002ZZ được liên kết với thiết bị quay video ZZ0003ZZ
- ZZ0004ZZ được liên kết với thiết bị quay video ZZ0005ZZ

Biểu đồ đường dẫn của bộ điều khiển phương tiện như sau (với một kết nối
Cảm biến máy ảnh IMX290):

.. _isp_topology_graph:

.. kernel-figure:: c3-isp.dot
    :alt:   c3-isp.dot
    :align: center

    Media pipeline topology

Thực hiện
==============

Cấu hình thời gian chạy của phần cứng ISP được thực hiện trên ZZ0002ZZ
nút thiết bị video sử dụng ZZ0000ZZ làm định dạng dữ liệu. Cấu trúc bộ đệm được xác định bởi
ZZ0001ZZ.

Số liệu thống kê được ghi lại từ nút thiết bị video ZZ0001ZZ bằng cách sử dụng
Định dạng dữ liệu ZZ0000ZZ.

Kích thước và định dạng hình ảnh cuối cùng được định cấu hình bằng video V4L2
giao diện chụp trên các nút thiết bị video ZZ0000ZZ.

Amlogic C3 ISP được ZZ0000ZZ hỗ trợ với
trình xử lý đường dẫn chuyên dụng và các thuật toán thực hiện chỉnh sửa hình ảnh trong thời gian chạy
và nâng cao.