.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-g-selection.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_G_SELECTION:

********************************************
ioctl VIDIOC_G_SELECTION, VIDIOC_S_SELECTION
********************************************

Tên
====

VIDIOC_G_SELECTION - VIDIOC_S_SELECTION - Nhận hoặc đặt một trong các hình chữ nhật lựa chọn

Tóm tắt
========

.. c:macro:: VIDIOC_G_SELECTION

ZZ0000ZZ

.. c:macro:: VIDIOC_S_SELECTION

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Các ioctls được sử dụng để truy vấn và định cấu hình các hình chữ nhật lựa chọn.

Để truy vấn cấu trúc tập hợp hình chữ nhật cắt xén (sáng tác)
Trường ZZ0000ZZ ZZ0006ZZ tới
loại bộ đệm tương ứng. Bước tiếp theo là thiết lập
giá trị của cấu trúc ZZ0001ZZ ZZ0007ZZ
trường thành ZZ0008ZZ (ZZ0009ZZ). Hãy tham khảo
vào bảng ZZ0002ZZ hoặc ZZ0003ZZ để
các mục tiêu bổ sung. Các trường ZZ0010ZZ và ZZ0011ZZ của cấu trúc
ZZ0004ZZ bị bỏ qua và chúng phải được
chứa đầy số không. Trình điều khiển lấp đầy phần còn lại của cấu trúc hoặc quay trở lại
Mã lỗi EINVAL nếu sử dụng loại bộ đệm hoặc mục tiêu không chính xác. Nếu
cắt xén (sáng tác) không được hỗ trợ thì hình chữ nhật hoạt động không được hỗ trợ
có thể thay đổi và nó luôn bằng hình chữ nhật giới hạn. Cuối cùng,
struct ZZ0005ZZ ZZ0012ZZ hình chữ nhật được lấp đầy bằng
tọa độ cắt xén (sáng tác) hiện tại. Tọa độ là
được biểu thị bằng đơn vị phụ thuộc vào trình điều khiển. Ngoại lệ duy nhất là hình chữ nhật
đối với hình ảnh ở định dạng thô, tọa độ của nó luôn được thể hiện dưới dạng
pixel.

Để thay đổi hình chữ nhật cắt xén (sáng tác), hãy đặt cấu trúc
Trường ZZ0000ZZ ZZ0007ZZ tới
loại bộ đệm tương ứng. Bước tiếp theo là thiết lập
giá trị của cấu trúc ZZ0001ZZ ZZ0008ZZ thành
ZZ0009ZZ (ZZ0010ZZ). Vui lòng tham khảo bảng
ZZ0002ZZ hoặc ZZ0003ZZ để biết thêm
mục tiêu. Cấu trúc hình chữ nhật ZZ0004ZZ ZZ0011ZZ cần
để được đặt thành vùng hoạt động mong muốn. Cấu trúc trường
ZZ0005ZZ ZZ0012ZZ bị bỏ qua và
phải được điền bằng số không. Người lái xe có thể điều chỉnh tọa độ của
hình chữ nhật được yêu cầu. Một ứng dụng có thể đưa ra các ràng buộc để kiểm soát
hành vi làm tròn. Cấu trúc ZZ0006ZZ
Trường ZZ0013ZZ phải được đặt thành một trong các trường sau:

- ZZ0000ZZ - Người lái xe có thể tự do điều chỉnh kích thước hình chữ nhật và
   chọn một hình chữ nhật cắt/soạn càng gần với yêu cầu càng tốt
   một.

- ZZ0000ZZ - Trình điều khiển không được phép thu nhỏ
   hình chữ nhật. Hình chữ nhật ban đầu phải nằm bên trong hình đã điều chỉnh.

- ZZ0000ZZ - Trình điều khiển không được phép phóng to
   hình chữ nhật. Hình chữ nhật đã điều chỉnh phải nằm bên trong hình chữ nhật ban đầu.

- ZZ0000ZZ - Người lái xe phải chọn
   kích thước giống hệt như trong hình chữ nhật được yêu cầu.

Vui lòng tham khảo ZZ0000ZZ.

Trình điều khiển có thể phải điều chỉnh kích thước được yêu cầu theo phần cứng
giới hạn và các phần khác như đường ống, tức là giới hạn được đưa ra bởi
cửa sổ chụp/xuất hoặc màn hình TV. Các giá trị gần nhất có thể của
độ lệch ngang và dọc và kích thước được chọn theo
ưu tiên sau:

1. Thỏa mãn ràng buộc từ struct
   ZZ0000ZZ ZZ0001ZZ.

2. Điều chỉnh chiều rộng, chiều cao, bên trái và trên cùng theo giới hạn phần cứng và
   sự sắp xếp.

3. Giữ tâm của hình chữ nhật đã điều chỉnh càng gần hình chữ nhật càng tốt.
   bản gốc.

4. Giữ chiều rộng và chiều cao càng gần với chiều rộng và chiều cao ban đầu càng tốt.

5. Giữ offset ngang và dọc càng gần với bản gốc càng tốt
   những cái đó.

Khi thành công, trường struct ZZ0000ZZ ZZ0001ZZ
chứa hình chữ nhật đã điều chỉnh. Khi các thông số không phù hợp
ứng dụng có thể sửa đổi các thông số cắt xén (sáng tác) hoặc hình ảnh và
lặp lại chu trình cho đến khi đạt được các thông số thỏa đáng. Nếu
cờ ràng buộc phải bị vi phạm lúc đó ZZ0002ZZ sẽ được trả về. các
lỗi chỉ ra rằng ZZ0003ZZ thỏa mãn
những hạn chế.

Mục tiêu lựa chọn và cờ được ghi lại trong
ZZ0000ZZ.

.. _sel-const-adjust:

.. kernel-figure::  constraints.svg
    :alt:    constraints.svg
    :align:  center

    Size adjustments with constraint flags.

    Behaviour of rectangle adjustment for different constraint flags.



.. c:type:: v4l2_selection

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. flat-table:: struct v4l2_selection
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``type``
      - Type of the buffer (from enum
	:c:type:`v4l2_buf_type`).
    * - __u32
      - ``target``
      - Used to select between
	:ref:`cropping and composing rectangles <v4l2-selections-common>`.
    * - __u32
      - ``flags``
      - Flags controlling the selection rectangle adjustments, refer to
	:ref:`selection flags <v4l2-selection-flags>`.
    * - struct :c:type:`v4l2_rect`
      - ``r``
      - The selection rectangle.
    * - __u32
      - ``reserved[9]``
      - Reserved fields for future use. Drivers and applications must zero
	this array.

.. note::
   Unfortunately in the case of multiplanar buffer types
   (``V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE`` and ``V4L2_BUF_TYPE_VIDEO_OUTPUT_MPLANE``)
   this API was messed up with regards to how the :c:type:`v4l2_selection` ``type`` field
   should be filled in. Some drivers only accepted the ``_MPLANE`` buffer type while
   other drivers only accepted a non-multiplanar buffer type (i.e. without the
   ``_MPLANE`` at the end).

   Starting with kernel 4.13 both variations are allowed.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Cho trước loại bộ đệm ZZ0000ZZ hoặc mục tiêu lựa chọn ZZ0001ZZ không phải là
    được hỗ trợ hoặc đối số ZZ0002ZZ không hợp lệ.

ERANGE
    Không thể điều chỉnh cấu trúc ZZ0000ZZ
    Hình chữ nhật ZZ0001ZZ để đáp ứng tất cả các ràng buộc được đưa ra trong ZZ0002ZZ
    lý lẽ.

ENODATA
    Lựa chọn không được hỗ trợ cho đầu vào hoặc đầu ra này.

EBUSY
    Không thể áp dụng thay đổi hình chữ nhật lựa chọn tại
    khoảnh khắc. Thông thường là do quá trình phát trực tuyến đang diễn ra.