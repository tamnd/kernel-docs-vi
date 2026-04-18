.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-subdev-g-frame-interval.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_SUBDEV_G_FRAME_INTERVAL:

**********************************************************************
ioctl VIDIOC_SUBDEV_G_FRAME_INTERVAL, VIDIOC_SUBDEV_S_FRAME_INTERVAL
**********************************************************************

Tên
====

VIDIOC_SUBDEV_G_FRAME_INTERVAL - VIDIOC_SUBDEV_S_FRAME_INTERVAL - Nhận hoặc đặt khoảng thời gian khung hình trên bảng phụ

Tóm tắt
========

.. c:macro:: VIDIOC_SUBDEV_G_FRAME_INTERVAL

ZZ0000ZZ

.. c:macro:: VIDIOC_SUBDEV_S_FRAME_INTERVAL

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Các ioctl này được sử dụng để lấy và đặt khoảng thời gian khung hình ở mức cụ thể
miếng đệm subdev trong đường dẫn hình ảnh. Khoảng thời gian khung hình chỉ có ý nghĩa
dành cho các thiết bị phụ có thể tự kiểm soát thời gian khung hình. Cái này
bao gồm, ví dụ, cảm biến hình ảnh và bộ điều chỉnh TV. Các thiết bị phụ
không hỗ trợ khoảng thời gian khung không được triển khai các ioctls này.

Để truy xuất các ứng dụng khoảng thời gian khung hình hiện tại, hãy đặt ZZ0001ZZ
trường của một cấu trúc
ZZ0000ZZ tới
số pad mong muốn do bộ điều khiển phương tiện API báo cáo. Khi nào
họ gọi ZZ0002ZZ ioctl bằng một con trỏ tới
cấu trúc này trình điều khiển sẽ điền vào các thành viên của trường ZZ0003ZZ.

Để thay đổi các ứng dụng khoảng thời gian khung hình hiện tại, hãy đặt cả ZZ0001ZZ
trường và tất cả các thành viên của trường ZZ0002ZZ. Khi họ gọi
ZZ0003ZZ ioctl với một con trỏ tới đây
cấu trúc trình điều khiển xác minh khoảng thời gian được yêu cầu, điều chỉnh nó dựa trên
về khả năng phần cứng và cấu hình thiết bị. Khi trở về
cấu trúc
ZZ0000ZZ
chứa khoảng thời gian khung hiện tại sẽ được trả về bởi một
Cuộc gọi ZZ0004ZZ.

Nếu nút thiết bị subdev đã được đăng ký ở chế độ chỉ đọc, hãy gọi tới
ZZ0000ZZ chỉ hợp lệ nếu trường ZZ0001ZZ được đặt
tới ZZ0002ZZ, nếu không sẽ trả về lỗi và lỗi sẽ xảy ra.
biến được đặt thành ZZ0003ZZ.

Trình điều khiển không được trả lại lỗi chỉ vì khoảng thời gian được yêu cầu
không phù hợp với khả năng của thiết bị. Thay vào đó họ phải sửa đổi
khoảng thời gian để phù hợp với những gì phần cứng có thể cung cấp. Khoảng thời gian được sửa đổi
phải càng gần với yêu cầu ban đầu càng tốt.

Việc thay đổi khoảng thời gian khung sẽ không bao giờ thay đổi định dạng. Thay đổi
mặt khác, định dạng có thể thay đổi khoảng thời gian khung.

Các thiết bị phụ hỗ trợ ioctls khoảng thời gian khung nên triển khai chúng
chỉ trên một miếng đệm duy nhất. Hành vi của họ khi được hỗ trợ trên nhiều miếng đệm của
cùng một thiết bị phụ không được xác định.

.. c:type:: v4l2_subdev_frame_interval

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. flat-table:: struct v4l2_subdev_frame_interval
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``pad``
      - Pad number as reported by the media controller API.
    * - struct :c:type:`v4l2_fract`
      - ``interval``
      - Period, in seconds, between consecutive video frames.
    * - __u32
      - ``stream``
      - Stream identifier.
    * - __u32
      - ``which``
      - Active or try frame interval, from enum
	:ref:`v4l2_subdev_format_whence <v4l2-subdev-format-whence>`.
    * - __u32
      - ``reserved``\ [7]
      - Reserved for future extensions. Applications and drivers must set
	the array to zero.

Giá trị trả về
==============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EBUSY
    Không thể thay đổi khoảng thời gian khung hình vì phần đệm hiện đang
    bận rộn. Ví dụ: điều này có thể xảy ra do luồng video đang hoạt động trên
    cái đệm. Không được thử lại ioctl mà không thực hiện thao tác khác
    hành động để khắc phục vấn đề đầu tiên. Chỉ được trả lại bởi
    ZZ0000ZZ

EINVAL
    Cấu trúc ZZ0000ZZ ZZ0001ZZ tham chiếu đến một
    phần đệm không tồn tại, trường ZZ0002ZZ có giá trị không được hỗ trợ hoặc phần đệm
    không hỗ trợ khoảng thời gian khung.

EPERM
    ZZ0000ZZ ioctl đã được gọi trên chế độ chỉ đọc
    thiết bị con và trường ZZ0001ZZ được đặt thành ZZ0002ZZ.