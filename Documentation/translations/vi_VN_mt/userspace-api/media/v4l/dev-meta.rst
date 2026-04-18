.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/dev-meta.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _metadata:

*******************
Giao diện siêu dữ liệu
******************

Siêu dữ liệu đề cập đến bất kỳ dữ liệu phi hình ảnh nào bổ sung cho khung hình video bằng
thông tin bổ sung. Điều này có thể bao gồm số liệu thống kê được tính toán trên hình ảnh,
thông số chụp khung được cung cấp bởi nguồn hình ảnh hoặc thiết bị cụ thể
các tham số để chỉ định cách thiết bị xử lý hình ảnh. Giao diện này là
nhằm mục đích chuyển siêu dữ liệu giữa không gian người dùng và phần cứng và
kiểm soát hoạt động đó.

Giao diện siêu dữ liệu được triển khai trên các nút thiết bị video. Thiết bị có thể được
dành riêng cho siêu dữ liệu hoặc có thể hỗ trợ cả video và siêu dữ liệu như được chỉ định trong
khả năng được báo cáo.

Khả năng truy vấn
=====================

Các nút thiết bị hỗ trợ giao diện thu thập siêu dữ liệu đặt
Cờ ZZ0003ZZ trong trường ZZ0004ZZ của
Cấu trúc ZZ0000ZZ được trả về bởi ZZ0001ZZ
ioctl. Cờ đó có nghĩa là thiết bị có thể ghi siêu dữ liệu vào bộ nhớ. Tương tự,
các nút thiết bị hỗ trợ giao diện đầu ra siêu dữ liệu thiết lập
Cờ ZZ0005ZZ trong trường ZZ0006ZZ của
Cấu trúc ZZ0002ZZ. Cờ đó có nghĩa là thiết bị có thể đọc
siêu dữ liệu từ bộ nhớ.

Ít nhất một trong các phương thức đọc/ghi hoặc truyền phát I/O phải được hỗ trợ.


Đàm phán định dạng dữ liệu
=======================

Thiết bị siêu dữ liệu sử dụng ioctls ZZ0000ZZ để chọn định dạng chụp.
Định dạng nội dung bộ đệm siêu dữ liệu được liên kết với định dạng đã chọn đó. Ngoài ra
đối với ioctl ZZ0001ZZ cơ bản, ioctl ZZ0002ZZ phải là
cũng được hỗ trợ.

Để sử dụng các ứng dụng ioctls ZZ0000ZZ, hãy đặt trường ZZ0004ZZ của
Cấu trúc ZZ0001ZZ thành ZZ0005ZZ hoặc thành
ZZ0006ZZ và sử dụng ZZ0002ZZ ZZ0007ZZ
thành viên của liên minh ZZ0008ZZ khi cần thiết cho hoạt động mong muốn. Cả hai trình điều khiển
và các ứng dụng phải thiết lập phần còn lại của cấu trúc ZZ0003ZZ
đến 0.

Các thiết bị thu thập siêu dữ liệu theo dòng có cấu trúc v4l2_fmtdesc
Cờ ZZ0002ZZ được đặt cho ZZ0000ZZ. Như vậy
các thiết bị thường có thể ZZ0001ZZ. Điều này chủ yếu
liên quan đến các thiết bị nhận dữ liệu từ một thiết bị khác như máy ảnh
cảm biến.

.. c:type:: v4l2_meta_format

.. tabularcolumns:: |p{1.4cm}|p{2.4cm}|p{13.5cm}|

.. flat-table:: struct v4l2_meta_format
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``dataformat``
      - The data format, set by the application. This is a little endian
        :ref:`four character code <v4l2-fourcc>`. V4L2 defines metadata formats
        in :ref:`meta-formats`.
    * - __u32
      - ``buffersize``
      - Maximum buffer size in bytes required for data. The value is set by the
        driver.
    * - __u32
      - ``width``
      - Width of a line of metadata in Data Units. Valid when
	:c:type`v4l2_fmtdesc` flag ``V4L2_FMT_FLAG_META_LINE_BASED`` is set,
	otherwise zero. See :c:func:`VIDIOC_ENUM_FMT`.
    * - __u32
      - ``height``
      - Number of rows of metadata. Valid when :c:type`v4l2_fmtdesc` flag
	``V4L2_FMT_FLAG_META_LINE_BASED`` is set, otherwise zero. See
	:c:func:`VIDIOC_ENUM_FMT`.
    * - __u32
      - ``bytesperline``
      - Offset in bytes between the beginning of two consecutive lines. Valid
	when :c:type`v4l2_fmtdesc` flag ``V4L2_FMT_FLAG_META_LINE_BASED`` is
	set, otherwise zero. See :c:func:`VIDIOC_ENUM_FMT`.