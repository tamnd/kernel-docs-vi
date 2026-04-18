.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/selections-common.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _v4l2-selections-common:

Định nghĩa lựa chọn phổ biến
============================

Trong khi ZZ0000ZZ và
ZZ0001ZZ rất
tương tự nhau, có một sự khác biệt cơ bản giữa hai điều này. Bật
thiết bị phụ API, hình chữ nhật lựa chọn đề cập đến định dạng bus phương tiện,
và được liên kết với phần đệm của thiết bị phụ. Trên giao diện V4L2 lựa chọn
hình chữ nhật đề cập đến định dạng pixel trong bộ nhớ.

Phần này xác định các định nghĩa chung của các giao diện lựa chọn
trên hai API.


.. toctree::
    :maxdepth: 1

    v4l2-selection-targets
    v4l2-selection-flags