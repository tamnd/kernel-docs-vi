.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/hsv-formats.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _hsv-formats:

*************
Định dạng HSV
***********

Các định dạng này lưu trữ thông tin màu sắc của hình ảnh
trong một biểu diễn hình học. Màu sắc được ánh xạ vào một
hình trụ, trong đó góc là HUE, chiều cao là VALUE
và khoảng cách đến trung tâm là SATURATION. Đây là một điều rất
định dạng hữu ích cho các thuật toán phân đoạn hình ảnh.


.. toctree::
    :maxdepth: 1

    pixfmt-packed-hsv