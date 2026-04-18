.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/ext-ctrls-jpeg.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _jpeg-controls:

*************************
Tham khảo điều khiển JPEG
*************************

Lớp JPEG bao gồm các điều khiển cho các tính năng phổ biến của bộ mã hóa JPEG
và bộ giải mã. Hiện tại nó bao gồm các tính năng để triển khai codec
Quá trình nén DCT cơ sở lũy tiến với entropy Huffman
mã hóa.


.. _jpeg-control-id:

ID điều khiển JPEG
================

ZZ0001ZZ
    Bộ mô tả lớp JPEG. Đang gọi
    ZZ0000ZZ cho điều khiển này sẽ
    trả về mô tả của lớp điều khiển này.

ZZ0001ZZ
    Các yếu tố lấy mẫu màu sắc mô tả cách mỗi thành phần của một
    hình ảnh đầu vào được lấy mẫu, liên quan đến tốc độ mẫu tối đa trong mỗi
    chiều không gian. Xem ZZ0000ZZ, điều A.1.1. để biết thêm
    chi tiết. Điều khiển ZZ0002ZZ xác định
    cách các thành phần Cb và Cr được lấy mẫu xuống sau khi chuyển đổi đầu vào
    ảnh từ không gian màu RGB sang không gian màu Y'CbCr.

.. tabularcolumns:: |p{7.5cm}|p{10.0cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_JPEG_CHROMA_SUBSAMPLING_444``
      - No chroma subsampling, each pixel has Y, Cr and Cb values.
    * - ``V4L2_JPEG_CHROMA_SUBSAMPLING_422``
      - Horizontally subsample Cr, Cb components by a factor of 2.
    * - ``V4L2_JPEG_CHROMA_SUBSAMPLING_420``
      - Subsample Cr, Cb components horizontally and vertically by 2.
    * - ``V4L2_JPEG_CHROMA_SUBSAMPLING_411``
      - Horizontally subsample Cr, Cb components by a factor of 4.
    * - ``V4L2_JPEG_CHROMA_SUBSAMPLING_410``
      - Subsample Cr, Cb components horizontally by 4 and vertically by 2.
    * - ``V4L2_JPEG_CHROMA_SUBSAMPLING_GRAY``
      - Use only luminance component.



ZZ0000ZZ
    Khoảng thời gian khởi động lại xác định khoảng thời gian chèn RSTm
    điểm đánh dấu (m = 0..7). Mục đích của các dấu hiệu này là để bổ sung
    khởi tạo lại quy trình mã hóa để xử lý các khối của một
    hình ảnh một cách độc lập. Đối với quá trình nén bị mất, khởi động lại
    đơn vị khoảng là MCU (Đơn vị mã hóa tối thiểu) và giá trị của nó được chứa
    trong điểm đánh dấu DRI (Xác định khoảng thời gian khởi động lại). Nếu
    Điều khiển ZZ0001ZZ được đặt thành 0, DRI và RSTm
    điểm đánh dấu sẽ không được chèn vào.

.. _jpeg-quality-control:

ZZ0000ZZ
    Xác định sự cân bằng giữa chất lượng hình ảnh và kích thước.
    Nó cung cấp phương pháp đơn giản hơn cho các ứng dụng để kiểm soát chất lượng hình ảnh,
    mà không cần cấu hình lại trực tiếp độ chói và sắc độ
    các bảng lượng tử hóa. Trong trường hợp trình điều khiển sử dụng bảng lượng tử hóa
    được cấu hình trực tiếp bởi một ứng dụng, sử dụng các giao diện được xác định
    ở những nơi khác, điều khiển ZZ0001ZZ phải được đặt bởi
    trình điều khiển về 0.

Phạm vi giá trị của điều khiển này là dành riêng cho trình điều khiển. Chỉ tích cực,
    các giá trị khác 0 có ý nghĩa. Phạm vi được đề xuất là 1 - 100,
    trong đó giá trị lớn hơn tương ứng với chất lượng hình ảnh tốt hơn.

.. _jpeg-active-marker-control:

ZZ0000ZZ
    Chỉ định điểm đánh dấu JPEG nào được đưa vào luồng nén. Cái này
    điều khiển chỉ có hiệu lực đối với bộ mã hóa.



.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_JPEG_ACTIVE_MARKER_APP0``
      - Application data segment APP\ :sub:`0`.
    * - ``V4L2_JPEG_ACTIVE_MARKER_APP1``
      - Application data segment APP\ :sub:`1`.
    * - ``V4L2_JPEG_ACTIVE_MARKER_COM``
      - Comment segment.
    * - ``V4L2_JPEG_ACTIVE_MARKER_DQT``
      - Quantization tables segment.
    * - ``V4L2_JPEG_ACTIVE_MARKER_DHT``
      - Huffman tables segment.



Để biết thêm chi tiết về thông số kỹ thuật JPEG, hãy tham khảo ZZ0000ZZ,
ZZ0001ZZ, ZZ0002ZZ.