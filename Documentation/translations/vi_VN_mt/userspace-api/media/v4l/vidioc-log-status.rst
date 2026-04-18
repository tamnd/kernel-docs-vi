.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-log-status.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_LOG_STATUS:

***********************
ioctl VIDIOC_LOG_STATUS
***********************

Tên
====

VIDIOC_LOG_STATUS - Nhật ký thông tin trạng thái trình điều khiển

Tóm tắt
========

.. c:macro:: VIDIOC_LOG_STATUS

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

Sự miêu tả
===========

Khi các thiết bị video/âm thanh trở nên phức tạp hơn thì việc
vấn đề gỡ lỗi. Khi ioctl này được gọi, trình điều khiển sẽ xuất ra
trạng thái thiết bị hiện tại vào nhật ký kernel. Điều này đặc biệt hữu ích khi
xử lý các vấn đề như không có âm thanh, không có video và điều chỉnh không chính xác
các kênh. Ngoài ra còn có nhiều thiết bị hiện đại tự động phát hiện các tiêu chuẩn video và âm thanh
và ioctl này sẽ báo cáo thiết bị nghĩ tiêu chuẩn là gì.
Sự không phù hợp có thể cho biết vấn đề nằm ở đâu.

Ioctl này là tùy chọn và không phải tất cả các trình điều khiển đều hỗ trợ nó. Nó đã được giới thiệu
trong Linux 2.6.15.

Giá trị trả về
==============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.