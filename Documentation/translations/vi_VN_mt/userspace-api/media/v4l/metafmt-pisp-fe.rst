.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/metafmt-pisp-fe.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _v4l2-meta-fmt-rpi-fe-cfg:

*************************
V4L2_META_FMT_RPI_FE_CFG
*************************

Định dạng cấu hình Raspberry Pi PiSP Front End
================================================

Bộ xử lý tín hiệu hình ảnh Raspberry Pi PiSP Front End được cấu hình bởi
không gian người dùng bằng cách cung cấp bộ đệm chứa các tham số cấu hình cho
Nút thiết bị video đầu ra ZZ0001ZZ sử dụng
Giao diện ZZ0000ZZ.

ZZ0000ZZ
cung cấp mô tả chi tiết về cấu hình và lập trình Front End
mô hình.

.. _v4l2-meta-fmt-rpi-fe-stats:

**************************
V4L2_META_FMT_RPI_FE_STATS
**************************

Định dạng thống kê Raspberry Pi PiSP Front End
=============================================

Bộ xử lý tín hiệu hình ảnh Raspberry Pi PiSP Front End cung cấp dữ liệu thống kê
bằng cách ghi vào bộ đệm được cung cấp qua thiết bị quay video ZZ0001ZZ
nút bằng cách sử dụng
Giao diện ZZ0000ZZ.

ZZ0000ZZ
cung cấp mô tả chi tiết về cấu hình và lập trình Front End
mô hình.