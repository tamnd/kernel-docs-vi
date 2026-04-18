.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _pixfmt:

###############
Image Định dạng
###############
V4L2 API được thiết kế chủ yếu cho các thiết bị trao đổi dữ liệu hình ảnh
với các ứng dụng. Cấu trúc ZZ0000ZZ và
struct ZZ0001ZZ cấu trúc xác định
định dạng và bố cục của hình ảnh trong bộ nhớ. Cái trước được sử dụng với
API một mặt phẳng, trong khi cái sau được sử dụng với nhiều mặt phẳng
phiên bản (xem ZZ0002ZZ). Các định dạng hình ảnh được thỏa thuận với
ZZ0003ZZ ioctl. (Lời giải ở đây
tập trung vào việc quay và xuất video, dành cho các định dạng bộ đệm khung lớp phủ
xem thêm ZZ0004ZZ.)


.. toctree::
    :maxdepth: 1

    pixfmt-v4l2
    pixfmt-v4l2-mplane
    pixfmt-intro
    pixfmt-indexed
    pixfmt-rgb
    pixfmt-bayer
    yuv-formats
    hsv-formats
    depth-formats
    pixfmt-compressed
    sdr-formats
    tch-formats
    meta-formats
    pixfmt-reserved
    colorspaces
    colorspaces-defs
    colorspaces-details