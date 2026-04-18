.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/v4l2grab-example.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _v4l2grab-example:

*************************************
Ví dụ về Video Grabber sử dụng libv4l
*************************************

Chương trình này trình bày cách lấy hình ảnh V4L2 ở định dạng ppm bằng cách sử dụng
trình xử lý libv4l. Ưu điểm là công cụ lấy này có khả năng hoạt động
với bất kỳ trình điều khiển V4L2 nào.


.. toctree::
    :maxdepth: 1

    v4l2grab.c