.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-querybuf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_QUERYBUF:

**********************
ioctl VIDIOC_QUERYBUF
*********************

Tên
====

VIDIOC_QUERYBUF - Truy vấn trạng thái của bộ đệm

Tóm tắt
========

.. c:macro:: VIDIOC_QUERYBUF

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Ioctl này là một phần của phương thức I/O ZZ0000ZZ. Nó có thể
được sử dụng để truy vấn trạng thái của bộ đệm bất cứ lúc nào sau khi bộ đệm có
đã được phân bổ bằng ZZ0001ZZ ioctl.

Các ứng dụng đặt trường ZZ0008ZZ của cấu trúc
ZZ0000ZZ sang loại bộ đệm giống như cũ
trước đây được sử dụng với cấu trúc ZZ0001ZZ ZZ0009ZZ
và cấu trúc ZZ0002ZZ ZZ0010ZZ,
và trường ZZ0011ZZ. Số chỉ mục hợp lệ nằm trong khoảng từ 0 đến
số lượng bộ đệm được phân bổ với
ZZ0003ZZ (cấu trúc
ZZ0004ZZ ZZ0012ZZ) trừ
một. Các trường ZZ0013ZZ và ZZ0014ZZ phải được đặt thành 0. Khi
sử dụng ZZ0005ZZ, ZZ0015ZZ
trường phải chứa một con trỏ không gian người dùng tới một mảng cấu trúc
ZZ0006ZZ và trường ZZ0016ZZ phải được đặt
số phần tử trong mảng đó. Sau khi gọi
ZZ0007ZZ với một con trỏ tới cấu trúc này, trình điều khiển sẽ trả về một
mã lỗi hoặc điền vào phần còn lại của cấu trúc.

Trong trường ZZ0001ZZ, ZZ0002ZZ,
ZZ0003ZZ, ZZ0004ZZ và
Cờ ZZ0005ZZ sẽ hợp lệ. Trường ZZ0006ZZ sẽ là
được đặt thành phương thức I/O hiện tại. Đối với API một mặt phẳng,
ZZ0007ZZ chứa phần bù của bộ đệm từ đầu
bộ nhớ thiết bị, kích thước của trường ZZ0008ZZ. Đối với API đa mặt phẳng,
các trường ZZ0009ZZ và ZZ0010ZZ trong mảng ZZ0011ZZ
các phần tử sẽ được sử dụng thay thế và trường ZZ0012ZZ của struct
ZZ0000ZZ được đặt thành số lượng điền vào
các phần tử mảng. Trình điều khiển có thể hoặc không thể đặt các trường còn lại và
cờ, chúng vô nghĩa trong bối cảnh này.

Cấu trúc ZZ0000ZZ được chỉ định trong
ZZ0001ZZ.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Bộ đệm ZZ0000ZZ không được hỗ trợ hoặc ZZ0001ZZ đã hết
    giới hạn.