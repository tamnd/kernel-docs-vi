.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/common.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _common:

####################
Common API Các phần tử
###################
Lập trình thiết bị V4L2 bao gồm các bước sau:

- Mở máy

- Thay đổi thuộc tính thiết bị, chọn đầu vào video và âm thanh, video
   tiêu chuẩn, độ sáng hình ảnh a. ồ.

- Thảo luận về định dạng dữ liệu

- Đàm phán phương thức đầu vào/đầu ra

- Vòng lặp đầu vào/đầu ra thực tế

- Đóng thiết bị

Trong thực tế, hầu hết các bước đều là tùy chọn và có thể được thực hiện không theo thứ tự. Nó
tùy thuộc vào loại thiết bị V4L2, bạn có thể đọc chi tiết trong
ZZ0000ZZ. Trong chương này chúng ta sẽ thảo luận về các khái niệm cơ bản
áp dụng cho tất cả các thiết bị.


.. toctree::
    :maxdepth: 1

    open
    querycap
    app-pri
    video
    audio
    tuner
    standard
    dv-timings
    control
    extended-controls
    ext-ctrls-camera
    ext-ctrls-flash
    ext-ctrls-image-source
    ext-ctrls-image-process
    ext-ctrls-codec
    ext-ctrls-codec-stateless
    ext-ctrls-jpeg
    ext-ctrls-dv
    ext-ctrls-rf-tuner
    ext-ctrls-fm-tx
    ext-ctrls-fm-rx
    ext-ctrls-detect
    ext-ctrls-colorimetry
    fourcc
    format
    planar-apis
    selection-api
    crop
    streaming-par