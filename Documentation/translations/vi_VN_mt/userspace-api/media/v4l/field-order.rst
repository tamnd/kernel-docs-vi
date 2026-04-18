.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/field-order.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _field-order:

*************
Thứ tự trường
***********

Chúng ta phải phân biệt giữa video lũy tiến và xen kẽ.
Video lũy tiến truyền tuần tự tất cả các dòng của hình ảnh video.
Video xen kẽ chia hình ảnh thành hai trường, chỉ chứa
các dòng lẻ và chẵn của hình ảnh tương ứng. Thay thế cái gọi là
trường chẵn và lẻ được truyền đi và do có độ trễ nhỏ giữa
trường, TV tia âm cực hiển thị các đường xen kẽ, mang lại kết quả
khung ban đầu. Kỹ thuật gây tò mò này được phát minh bởi vì lúc làm mới
tương tự như phim, hình ảnh sẽ mờ đi quá nhanh. truyền tải
các trường làm giảm nhấp nháy mà không cần tăng gấp đôi khung hình
tốc độ và cùng với đó là băng thông cần thiết cho mỗi kênh.

Điều quan trọng là phải hiểu máy quay video không hiển thị một khung hình
tại một thời điểm, chỉ truyền các khung được tách thành các trường. các
các trường trên thực tế được ghi lại ở hai thời điểm khác nhau. Một
đối tượng trên màn hình có thể di chuyển giữa trường này và trường tiếp theo. cho
ứng dụng phân tích chuyển động, điều quan trọng nhất là phải nhận ra
trường nào của khung cũ hơn, ZZ0000ZZ.

Khi trình điều khiển cung cấp hoặc chấp nhận từng trường hình ảnh thay vì
xen kẽ nhau, điều quan trọng là các ứng dụng phải hiểu các trường như thế nào
kết hợp thành khung. Chúng ta phân biệt giữa trên (hay còn gọi là số lẻ) và dưới cùng (còn gọi là
chẵn), ZZ0000ZZ: Dòng đầu tiên của trường trên cùng là
dòng đầu tiên của khung đan xen, dòng đầu tiên của phần dưới cùng
trường là dòng thứ hai của khung đó.

Tuy nhiên vì ruộng lần lượt bị chiếm nên tranh cãi
việc khung bắt đầu bằng trường trên cùng hay dưới cùng là vô nghĩa. bất kỳ
hai trường trên cùng và dưới cùng hoặc dưới cùng và trên cùng liên tiếp mang lại giá trị hợp lệ
khung. Chỉ khi nguồn bắt đầu tiến triển, e. g. khi nào
chuyển phim sang video, hai trường có thể đến từ cùng một khung hình,
tạo ra một trật tự tự nhiên.

Ngược lại với trực giác, trường trên cùng không nhất thiết phải là trường cũ hơn.
Trường cũ hơn chứa dòng trên cùng hay dòng dưới cùng là quy ước
được xác định bởi tiêu chuẩn video. Do đó sự khác biệt giữa thời gian
và trật tự không gian của các trường. Các sơ đồ dưới đây sẽ thực hiện điều này
rõ ràng hơn.

Trong V4L, giả định rằng tất cả các máy quay video đều truyền các trường trên phương tiện
xe buýt theo đúng thứ tự mà chúng được chụp, vì vậy nếu trường trên cùng là
được bắt đầu tiên (là trường cũ hơn), trường trên cùng cũng được truyền đi
đầu tiên trên xe buýt.

Tất cả các thiết bị quay và xuất video phải báo cáo trường hiện tại
đặt hàng. Một số trình điều khiển có thể cho phép lựa chọn một thứ tự khác, để
ứng dụng cuối này khởi tạo trường cấu trúc ZZ0002ZZ
ZZ0000ZZ trước khi gọi
ZZ0001ZZ ioctl. Nếu điều này là không mong muốn
phải có giá trị ZZ0003ZZ (0).


enum v4l2_field
===============

.. c:type:: v4l2_field

.. tabularcolumns:: |p{5.8cm}|p{0.6cm}|p{10.9cm}|

.. cssclass:: longtable

.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * - ``V4L2_FIELD_ANY``
      - 0
      - Applications request this field order when any field format
	is acceptable. Drivers choose depending on hardware capabilities or
	e.g. the requested image size, and return the actual field order.
	Drivers must never return ``V4L2_FIELD_ANY``.
	If multiple field orders are possible the
	driver must choose one of the possible field orders during
	:ref:`VIDIOC_S_FMT <VIDIOC_G_FMT>` or
	:ref:`VIDIOC_TRY_FMT <VIDIOC_G_FMT>`. struct
	:c:type:`v4l2_buffer` ``field`` can never be
	``V4L2_FIELD_ANY``.
    * - ``V4L2_FIELD_NONE``
      - 1
      - Images are in progressive (frame-based) format, not interlaced
        (field-based).
    * - ``V4L2_FIELD_TOP``
      - 2
      - Images consist of the top (aka odd) field only.
    * - ``V4L2_FIELD_BOTTOM``
      - 3
      - Images consist of the bottom (aka even) field only. Applications
	may wish to prevent a device from capturing interlaced images
	because they will have "comb" or "feathering" artefacts around
	moving objects.
    * - ``V4L2_FIELD_INTERLACED``
      - 4
      - Images contain both fields, interleaved line by line. The temporal
	order of the fields (whether the top or bottom field is older)
	depends on the current video standard. In M/NTSC the bottom
	field is the older field. In all other standards the top field
	is the older field.
    * - ``V4L2_FIELD_SEQ_TB``
      - 5
      - Images contain both fields, the top field lines are stored first
	in memory, immediately followed by the bottom field lines. Fields
	are always stored in temporal order, the older one first in
	memory. Image sizes refer to the frame, not fields.
    * - ``V4L2_FIELD_SEQ_BT``
      - 6
      - Images contain both fields, the bottom field lines are stored
	first in memory, immediately followed by the top field lines.
	Fields are always stored in temporal order, the older one first in
	memory. Image sizes refer to the frame, not fields.
    * - ``V4L2_FIELD_ALTERNATE``
      - 7
      - The two fields of a frame are passed in separate buffers, in
	temporal order, i. e. the older one first. To indicate the field
	parity (whether the current field is a top or bottom field) the
	driver or application, depending on data direction, must set
	struct :c:type:`v4l2_buffer` ``field`` to
	``V4L2_FIELD_TOP`` or ``V4L2_FIELD_BOTTOM``. Any two successive
	fields pair to build a frame. If fields are successive, without
	any dropped fields between them (fields can drop individually),
	can be determined from the struct
	:c:type:`v4l2_buffer` ``sequence`` field. This
	format cannot be selected when using the read/write I/O method
	since there is no way to communicate if a field was a top or
	bottom field.
    * - ``V4L2_FIELD_INTERLACED_TB``
      - 8
      - Images contain both fields, interleaved line by line, top field
	first. The top field is the older field.
    * - ``V4L2_FIELD_INTERLACED_BT``
      - 9
      - Images contain both fields, interleaved line by line, top field
	first. The bottom field is the older field.



.. _fieldseq-tb:

Thứ tự trường, Trường trên cùng được truyền đầu tiên
========================================

.. kernel-figure:: fieldseq_tb.svg
    :alt:    fieldseq_tb.svg
    :align:  center

    Field Order, Top Field First Transmitted


.. _fieldseq-bt:

Thứ tự trường, Trường dưới cùng được truyền đầu tiên
===========================================

.. kernel-figure:: fieldseq_bt.svg
    :alt:    fieldseq_bt.svg
    :align:  center

    Field Order, Bottom Field First Transmitted