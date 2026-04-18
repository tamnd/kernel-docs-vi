.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/yuv-formats.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _yuv-formats:

*************
Định dạng YUV
***********

YUV là định dạng dành riêng cho tín hiệu video tổng hợp và phát sóng truyền hình. Nó
tách thông tin độ sáng (Y) khỏi thông tin màu (U
và V hoặc Cb và Cr). Thông tin màu sắc bao gồm màu đỏ và màu xanh
Tín hiệu ZZ0001ZZ, theo cách này, thành phần màu xanh lá cây có thể được
được xây dựng lại bằng cách trừ đi thành phần độ sáng. Xem
ZZ0000ZZ để biết ví dụ chuyển đổi. YUV được chọn vì
truyền hình thời kỳ đầu chỉ truyền tải thông tin về độ sáng. Để thêm
màu sắc theo cách tương thích với các máy thu hiện có một sóng mang tín hiệu mới
đã được thêm vào để truyền tín hiệu khác biệt màu sắc.


Lấy mẫu con
===========

Các định dạng YUV thường mã hóa hình ảnh có độ phân giải thấp hơn cho sắc độ
thành phần hơn so với thành phần luma. Kỹ thuật nén này, lấy
Ưu điểm của mắt người là nhạy cảm với độ chói hơn màu sắc
sự khác biệt, được gọi là lấy mẫu sắc độ.

Trong khi nhiều sự kết hợp của các yếu tố lấy mẫu con theo chiều ngang và chiều dọc
có thể có hướng, các hệ số chung là 1 (không có mẫu phụ), 2 và 4, với
lấy mẫu con ngang luôn lớn hơn hoặc bằng lấy mẫu con dọc.
Các kết hợp phổ biến được đặt tên như sau.

- ZZ0000ZZ: Không lấy mẫu con
- ZZ0001ZZ: Lấy mẫu con theo chiều ngang bằng 2, không lấy mẫu con theo chiều dọc
- ZZ0002ZZ: Lấy mẫu con ngang 2, lấy mẫu con dọc 2
- ZZ0003ZZ: Lấy mẫu con ngang theo 4, không lấy mẫu con dọc
- ZZ0004ZZ: Lấy mẫu con ngang 4, lấy mẫu con dọc 4

Việc lấy mẫu con thành phần sắc độ sẽ tạo ra các giá trị sắc độ một cách hiệu quả có thể được
nằm ở các vị trí không gian khác nhau:

- .. _yuv-chroma-làm trung tâm:

Giá trị sắc độ được lấy mẫu phụ có thể được tính bằng cách lấy trung bình của sắc độ
  giá trị của hai pixel liên tiếp. Nó mô hình hóa sắc độ của pixel một cách hiệu quả
  được đặt giữa hai pixel gốc. Điều này được gọi là trung tâm hoặc
  sắc độ xen kẽ.

- .. _yuv-chroma-cosit:

Tùy chọn khác là lấy mẫu phụ các giá trị sắc độ theo cách đặt chúng vào
  các vị trí không gian giống như các pixel. Điều này có thể được thực hiện bằng cách bỏ qua mọi
  mẫu sắc độ khác (tạo các tạo phẩm răng cưa) hoặc với các bộ lọc sử dụng
  số vòi lẻ. Điều này được gọi là sắc độ đồng vị trí.

Các ví dụ sau đây cho thấy sự kết hợp khác nhau của việc định vị sắc độ trong một màn hình 4x4
hình ảnh.

.. flat-table:: 4:2:2 subsampling, interstitially sited
    :header-rows: 1
    :stub-columns: 1

    * -
      - 0
      -
      - 1
      -
      - 2
      -
      - 3
    * - 0
      - Y
      - C
      - Y
      -
      - Y
      - C
      - Y
    * - 1
      - Y
      - C
      - Y
      -
      - Y
      - C
      - Y
    * - 2
      - Y
      - C
      - Y
      -
      - Y
      - C
      - Y
    * - 3
      - Y
      - C
      - Y
      -
      - Y
      - C
      - Y

.. flat-table:: 4:2:2 subsampling, co-sited
    :header-rows: 1
    :stub-columns: 1

    * -
      - 0
      -
      - 1
      -
      - 2
      -
      - 3
    * - 0
      - Y/C
      -
      - Y
      -
      - Y/C
      -
      - Y
    * - 1
      - Y/C
      -
      - Y
      -
      - Y/C
      -
      - Y
    * - 2
      - Y/C
      -
      - Y
      -
      - Y/C
      -
      - Y
    * - 3
      - Y/C
      -
      - Y
      -
      - Y/C
      -
      - Y

.. flat-table:: 4:2:0 subsampling, horizontally interstitially sited, vertically co-sited
    :header-rows: 1
    :stub-columns: 1

    * -
      - 0
      -
      - 1
      -
      - 2
      -
      - 3
    * - 0
      - Y
      - C
      - Y
      -
      - Y
      - C
      - Y
    * - 1
      - Y
      -
      - Y
      -
      - Y
      -
      - Y
    * - 2
      - Y
      - C
      - Y
      -
      - Y
      - C
      - Y
    * - 3
      - Y
      -
      - Y
      -
      - Y
      -
      - Y

.. flat-table:: 4:1:0 subsampling, horizontally and vertically interstitially sited
    :header-rows: 1
    :stub-columns: 1

    * -
      - 0
      -
      - 1
      -
      - 2
      -
      - 3
    * - 0
      - Y
      -
      - Y
      -
      - Y
      -
      - Y
    * -
      -
      -
      -
      -
      -
      -
      -
    * - 1
      - Y
      -
      - Y
      -
      - Y
      -
      - Y
    * -
      -
      -
      -
      - C
      -
      -
      -
    * - 2
      - Y
      -
      - Y
      -
      - Y
      -
      - Y
    * -
      -
      -
      -
      -
      -
      -
      -
    * - 3
      - Y
      -
      - Y
      -
      - Y
      -
      - Y


.. toctree::
    :maxdepth: 1

    pixfmt-packed-yuv
    pixfmt-yuv-planar
    pixfmt-yuv-luma
    pixfmt-y8i
    pixfmt-y12i
    pixfmt-y16i
    pixfmt-uv8
    pixfmt-m420