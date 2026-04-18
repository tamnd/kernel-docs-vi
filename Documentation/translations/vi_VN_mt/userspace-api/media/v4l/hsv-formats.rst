.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/hsv-formats.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

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