.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-g-std.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_G_STD:

*******************************************************************************
ioctl VIDIOC_G_STD, VIDIOC_S_STD, VIDIOC_SUBDEV_G_STD, VIDIOC_SUBDEV_S_STD
*******************************************************************************

Tên
====

VIDIOC_G_STD - VIDIOC_S_STD - VIDIOC_SUBDEV_G_STD - VIDIOC_SUBDEV_S_STD - Truy vấn hoặc chọn chuẩn video của đầu vào hiện tại

Tóm tắt
========

.. c:macro:: VIDIOC_G_STD

ZZ0000ZZ

.. c:macro:: VIDIOC_S_STD

ZZ0000ZZ

.. c:macro:: VIDIOC_SUBDEV_G_STD

ZZ0000ZZ

.. c:macro:: VIDIOC_SUBDEV_S_STD

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới ZZ0000ZZ.

Sự miêu tả
===========

Để truy vấn và chọn các ứng dụng tiêu chuẩn video hiện tại, hãy sử dụng
ZZ0000ZZ và ZZ0001ZZ ioctls đưa con trỏ tới một
ZZ0002ZZ gõ làm đối số. ZZ0003ZZ
có thể trả về một cờ hoặc một tập hợp cờ như trong struct
Trường ZZ0004ZZ ZZ0006ZZ. Các lá cờ phải được
rõ ràng đến mức chúng chỉ xuất hiện trong một danh sách được liệt kê
cấu trúc cấu trúc ZZ0005ZZ.

ZZ0000ZZ chấp nhận một hoặc nhiều cờ, là ioctl chỉ ghi
không trả về tiêu chuẩn mới thực tế như ZZ0001ZZ. Khi nào
không có cờ nào được đưa ra hoặc đầu vào hiện tại không hỗ trợ yêu cầu
tiêu chuẩn trình điều khiển trả về mã lỗi ZZ0003ZZ. Khi tiêu chuẩn được đặt ra
trình điều khiển không rõ ràng có thể trả về ZZ0004ZZ hoặc chọn bất kỳ yêu cầu nào
tiêu chuẩn. Nếu đầu vào hoặc đầu ra hiện tại không hỗ trợ tiêu chuẩn
thời gian video (ví dụ: nếu ZZ0002ZZ
không đặt cờ ZZ0005ZZ), thì mã lỗi ZZ0006ZZ là
đã quay trở lại.

Gọi ZZ0000ZZ trên nút thiết bị subdev đã được đăng ký
ở chế độ chỉ đọc không được phép. Một lỗi được trả về và biến errno là
được đặt thành ZZ0001ZZ.

Giá trị trả về
==============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Tham số ZZ0000ZZ không phù hợp.

ENODATA
    Định giờ video tiêu chuẩn không được hỗ trợ cho đầu vào hoặc đầu ra này.

EPERM
    ZZ0000ZZ đã được gọi trên thiết bị con chỉ đọc.