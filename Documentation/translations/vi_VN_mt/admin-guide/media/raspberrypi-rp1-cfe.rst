.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/raspberrypi-rp1-cfe.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================================
Mặt trước của máy ảnh Raspberry Pi PiSP (rp1-cfe)
============================================

Giao diện người dùng của máy ảnh PiSP
=========================

Mặt trước của máy ảnh PiSP (CFE) là một mô-đun kết hợp bộ thu CSI-2 với
một ISP đơn giản, được gọi là Front End (FE).

CFE có bốn công cụ DMA và có thể ghi khung từ bốn luồng riêng biệt
nhận được từ CSI-2 vào bộ nhớ. Một trong những luồng đó cũng có thể được định tuyến
trực tiếp tới FE, có thể xử lý hình ảnh tối thiểu, viết hai phiên bản
(ví dụ: phiên bản không chia tỷ lệ và thu nhỏ) của các khung nhận được vào bộ nhớ và
cung cấp số liệu thống kê về các khung nhận được.

Các thanh ghi FE được ghi lại trong ZZ0000ZZ,
và mã ví dụ cho FE có thể được tìm thấy trong ZZ0001ZZ.

Trình điều khiển rp1-cfe
==================

Trình điều khiển Raspberry Pi PiSP Camera Front End (rp1-cfe) nằm bên dưới
trình điều khiển/phương tiện/nền tảng/raspberrypi/rp1-cfe. Nó sử dụng ZZ0000ZZ để đăng ký
một số thiết bị quay và xuất video, ZZ0001ZZ để đăng ký
thiết bị phụ cho CSI-2 đã nhận và FE kết nối các thiết bị video trong
một biểu đồ đa phương tiện được thực hiện bằng ZZ0002ZZ.

Cấu trúc liên kết phương tiện được đăng ký bởi trình điều khiển ZZ0000ZZ, đặc biệt là
ví dụ được kết nối với cảm biến imx219, là ví dụ sau:

.. _rp1-cfe-topology:

.. kernel-figure:: raspberrypi-rp1-cfe.dot
    :alt:   Diagram of an example media pipeline topology
    :align: center

Biểu đồ phương tiện chứa các nút thiết bị video sau:

- rp1-cfe-csi2-ch0: thiết bị chụp cho luồng CSI-2 đầu tiên
- rp1-cfe-csi2-ch1: thiết bị chụp cho luồng CSI-2 thứ hai
- rp1-cfe-csi2-ch2: thiết bị chụp cho luồng CSI-2 thứ ba
- rp1-cfe-csi2-ch3: thiết bị chụp cho luồng CSI-2 thứ tư
- rp1-cfe-fe-image0: thiết bị chụp cho đầu ra FE đầu tiên
- rp1-cfe-fe-image1: thiết bị chụp cho đầu ra FE thứ hai
- rp1-cfe-fe-stats: thiết bị thu thập số liệu thống kê FE
- rp1-cfe-fe-config: thiết bị đầu ra cho cấu hình FE

rp1-cfe-csi2-chX
----------------

Thiết bị chụp rp1-cfe-csi2-chX là thiết bị chụp V4L2 bình thường.
có thể được sử dụng để ghi lại các khung hình video hoặc siêu dữ liệu nhận được từ CSI-2.

rp1-cfe-fe-image0, rp1-cfe-fe-image1
------------------------------------

Thiết bị chụp rp1-cfe-fe-image0 và rp1-cfe-fe-image1 được sử dụng để ghi
các khung đã được xử lý vào bộ nhớ.

rp1-cfe-fe-stats
----------------

Định dạng của bộ đệm thống kê FE được xác định bởi
Cấu trúc ZZ0000ZZ C và ý nghĩa từng tham số là
được mô tả trong tài liệu ZZ0001ZZ.

rp1-cfe-fe-config
-----------------

Định dạng của bộ đệm cấu hình FE được xác định bởi
Cấu trúc ZZ0000ZZ C và ý nghĩa từng tham số là
được mô tả trong tài liệu ZZ0001ZZ.