.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-subdev-g-fmt.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_SUBDEV_G_FMT:

**********************************************
ioctl VIDIOC_SUBDEV_G_FMT, VIDIOC_SUBDEV_S_FMT
**********************************************

Tên
====

VIDIOC_SUBDEV_G_FMT - VIDIOC_SUBDEV_S_FMT - Nhận hoặc đặt định dạng dữ liệu trên bảng phụ

Tóm tắt
========

.. c:macro:: VIDIOC_SUBDEV_G_FMT

ZZ0000ZZ

.. c:macro:: VIDIOC_SUBDEV_S_FMT

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Các ioctl này được sử dụng để đàm phán định dạng khung ở các nhà phát triển con cụ thể.
miếng đệm trong đường ống hình ảnh.

Để truy xuất các ứng dụng định dạng hiện tại, hãy đặt trường ZZ0001ZZ của
struct ZZ0000ZZ theo ý muốn
số pad được báo cáo bởi phương tiện truyền thông API và trường ZZ0002ZZ cho
ZZ0003ZZ. Khi họ gọi
ZZ0004ZZ ioctl với một con trỏ tới cấu trúc này
trình điều khiển điền vào các thành viên của trường ZZ0005ZZ.

Để thay đổi các ứng dụng định dạng hiện tại, hãy đặt cả ZZ0001ZZ và
Các trường ZZ0002ZZ và tất cả các thành viên của trường ZZ0003ZZ. Khi họ gọi
ZZ0004ZZ ioctl với một con trỏ tới cấu trúc này
trình điều khiển xác minh định dạng được yêu cầu, điều chỉnh nó dựa trên phần cứng
khả năng và cấu hình thiết bị. Khi trả về cấu trúc
ZZ0000ZZ chứa dòng điện
định dạng như sẽ được trả về bởi lệnh gọi ZZ0005ZZ.

Các ứng dụng có thể truy vấn khả năng của thiết bị bằng cách đặt ZZ0000ZZ
tới ZZ0001ZZ. Khi được đặt, định dạng 'thử' sẽ không được áp dụng
vào thiết bị bởi trình điều khiển nhưng được thay đổi chính xác như các định dạng đang hoạt động
và được lưu trữ trong phần xử lý tệp của thiết bị phụ. Hai ứng dụng truy vấn
do đó, cùng một thiết bị phụ sẽ không tương tác với nhau.

Ví dụ: để thử định dạng ở bảng đầu ra của thiết bị phụ,
trước tiên các ứng dụng sẽ đặt định dạng thử ở đầu vào thiết bị phụ với
ZZ0000ZZ ioctl. Sau đó họ sẽ lấy lại
định dạng mặc định ở bảng đầu ra với ZZ0001ZZ ioctl,
hoặc đặt định dạng bảng đầu ra mong muốn bằng ZZ0002ZZ
ioctl và kiểm tra giá trị trả về.

Các định dạng thử không phụ thuộc vào các định dạng đang hoạt động mà có thể phụ thuộc vào
cấu hình liên kết hiện tại hoặc giá trị điều khiển thiết bị phụ. Ví dụ,
bộ lọc nhiễu thông thấp có thể cắt các pixel ở ranh giới khung,
sửa đổi kích thước khung đầu ra của nó.

Nếu nút thiết bị subdev đã được đăng ký ở chế độ chỉ đọc, hãy gọi tới
ZZ0000ZZ chỉ hợp lệ nếu trường ZZ0001ZZ được đặt thành
ZZ0002ZZ, nếu không sẽ trả về lỗi và lỗi sẽ xảy ra.
biến được đặt thành ZZ0003ZZ.

Trình điều khiển không được trả về lỗi chỉ vì định dạng được yêu cầu
không phù hợp với khả năng của thiết bị. Thay vào đó họ phải sửa đổi
định dạng phù hợp với những gì phần cứng có thể cung cấp. Định dạng được sửa đổi
phải càng gần với yêu cầu ban đầu càng tốt.

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. c:type:: v4l2_subdev_format

.. flat-table:: struct v4l2_subdev_format
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``pad``
      - Pad number as reported by the media controller API.
    * - __u32
      - ``which``
      - Format to modified, from enum
	:ref:`v4l2_subdev_format_whence <v4l2-subdev-format-whence>`.
    * - struct :c:type:`v4l2_mbus_framefmt`
      - ``format``
      - Definition of an image format, see :c:type:`v4l2_mbus_framefmt` for
	details.
    * - __u32
      - ``stream``
      - Stream identifier.
    * - __u32
      - ``reserved``\ [7]
      - Reserved for future extensions. Applications and drivers must set
	the array to zero.


.. tabularcolumns:: |p{6.6cm}|p{2.2cm}|p{8.5cm}|

.. _v4l2-subdev-format-whence:

.. flat-table:: enum v4l2_subdev_format_whence
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * - V4L2_SUBDEV_FORMAT_TRY
      - 0
      - Try formats, used for querying device capabilities.
    * - V4L2_SUBDEV_FORMAT_ACTIVE
      - 1
      - Active formats, applied to the hardware.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EBUSY
    Không thể thay đổi định dạng vì bảng này hiện đang bận. Cái này
    chẳng hạn, có thể do luồng video đang hoạt động trên bảng điều khiển gây ra.
    Không được thử lại ioctl mà không thực hiện hành động khác để
    khắc phục vấn đề đầu tiên. Chỉ được trả lại bởi ZZ0000ZZ

EINVAL
    Cấu trúc ZZ0000ZZ ZZ0001ZZ tham chiếu đến một cấu trúc không tồn tại
    pad hoặc trường ZZ0002ZZ có giá trị không được hỗ trợ.

EPERM
    ZZ0000ZZ ioctl đã được gọi trên một thiết bị con chỉ đọc
    và trường ZZ0001ZZ được đặt thành ZZ0002ZZ.

=============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.