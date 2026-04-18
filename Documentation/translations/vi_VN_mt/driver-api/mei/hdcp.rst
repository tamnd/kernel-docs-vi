.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/mei/hdcp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

HDCP:
=====

ME FW với tư cách là một công cụ bảo mật cung cấp khả năng thiết lập
Đàm phán giao thức HDCP2.2 giữa thiết bị đồ họa Intel và
bồn rửa HDC2.2.

ME FW chuẩn bị các tham số đàm phán HDCP2.2, ký và mã hóa chúng
theo thông số HDCP 2.2. Đồ họa Intel gửi đốm màu đã tạo
đến bồn rửa HDCP2.2.

Tương tự, phản hồi của bồn rửa HDCP2.2 được chuyển đến ME FW
để giải mã và xác minh.

Sau khi hoàn tất tất cả các bước đàm phán HDCP2.2,
theo yêu cầu ME FW sẽ cấu hình cổng được xác thực và cung cấp
khóa mã hóa HDCP cho phần cứng đồ họa Intel.


trình điều khiển mei_hdcp
---------------
.. kernel-doc:: drivers/misc/mei/hdcp/mei_hdcp.c
    :doc: MEI_HDCP Client Driver

api mei_hdcp
------------

.. kernel-doc:: drivers/misc/mei/hdcp/mei_hdcp.c
    :functions:
