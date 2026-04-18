.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-g-edid.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_G_EDID:

**********************************************************************************
ioctl VIDIOC_G_EDID, VIDIOC_S_EDID, VIDIOC_SUBDEV_G_EDID, VIDIOC_SUBDEV_S_EDID
**********************************************************************************

Tên
====

VIDIOC_G_EDID - VIDIOC_S_EDID - VIDIOC_SUBDEV_G_EDID - VIDIOC_SUBDEV_S_EDID - Nhận hoặc đặt EDID của bộ thu/phát video

Tóm tắt
========

.. c:macro:: VIDIOC_G_EDID

ZZ0000ZZ

.. c:macro:: VIDIOC_S_EDID

ZZ0000ZZ

.. c:macro:: VIDIOC_SUBDEV_G_EDID

ZZ0000ZZ

.. c:macro:: VIDIOC_SUBDEV_S_EDID

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
   Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Các ioctls này có thể được sử dụng để nhận hoặc đặt EDID được liên kết với đầu vào
từ máy thu hoặc đầu ra của thiết bị phát. Chúng có thể được sử dụng
với các nút thiết bị con (/dev/v4l-subdevX) hoặc với các nút video
(/dev/videoX).

Khi được sử dụng với các nút video, trường ZZ0002ZZ đại diện cho đầu vào (đối với
thiết bị quay video) hoặc chỉ mục đầu ra (đối với thiết bị đầu ra video) như hiện tại
được trả về bởi ZZ0000ZZ và
ZZ0001ZZ tương ứng. Khi sử dụng
với các nút thiết bị con, trường ZZ0003ZZ đại diện cho đầu vào hoặc đầu ra
pad của thiết bị phụ. Nếu không có hỗ trợ EDID cho ZZ0004ZZ đã cho
thì mã lỗi ZZ0005ZZ sẽ được trả về.

Để có được dữ liệu EDID, ứng dụng phải điền vào ZZ0001ZZ,
Các trường ZZ0002ZZ, ZZ0003ZZ và ZZ0004ZZ, không có ZZ0005ZZ
mảng và gọi ZZ0000ZZ. EDID hiện tại từ khối
ZZ0006ZZ và kích thước ZZ0007ZZ sẽ được lưu vào bộ nhớ
ZZ0008ZZ chỉ tới. Con trỏ ZZ0009ZZ ít nhất phải trỏ tới bộ nhớ
ZZ0010ZZ * lớn 128 byte (kích thước của một khối là 128 byte).

Nếu có ít khối hơn quy định thì trình điều khiển sẽ đặt
ZZ0000ZZ với số khối thực tế. Nếu không có khối EDID
không có sẵn thì mã lỗi ZZ0001ZZ đã được đặt.

Nếu các khối phải được lấy từ sink thì lệnh gọi này sẽ chặn
cho đến khi chúng được đọc.

Nếu ZZ0001ZZ và ZZ0002ZZ đều được đặt thành 0 khi
ZZ0000ZZ được gọi, khi đó trình điều khiển sẽ đặt ZZ0003ZZ thành
tổng số khối EDID có sẵn và nó sẽ trả về 0 mà không có
sao chép bất kỳ dữ liệu nào. Đây là một cách dễ dàng để khám phá có bao nhiêu khối EDID
có đấy.

.. note::

   If there are no EDID blocks available at all, then
   the driver will set ``blocks`` to 0 and it returns 0.

Để đặt khối EDID của bộ thu, ứng dụng phải điền vào
Các trường ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ, đặt ZZ0003ZZ thành 0 và
bằng không mảng ZZ0004ZZ. Không thể đặt một phần của EDID,
nó luôn luôn là tất cả hoặc không có gì. Việc đặt dữ liệu EDID chỉ hợp lệ cho
máy thu vì nó không có ý nghĩa đối với máy phát.

Trình điều khiển giả định rằng EDID đầy đủ đã được chuyển vào. Nếu có nhiều hơn
Khối EDID vượt quá khả năng xử lý của phần cứng thì EDID không được ghi,
nhưng thay vào đó, mã lỗi ZZ0000ZZ được đặt và ZZ0001ZZ được đặt thành
tối đa mà phần cứng hỗ trợ. Nếu ZZ0002ZZ là bất kỳ giá trị nào
khác 0 thì mã lỗi ZZ0003ZZ được đặt.

Để tắt EDID, bạn đặt ZZ0000ZZ thành 0. Tùy thuộc vào phần cứng
điều này sẽ khiến chân cắm nóng ở mức thấp và/hoặc chặn nguồn đọc
dữ liệu EDID theo một cách nào đó. Trong mọi trường hợp, kết quả cuối cùng đều giống nhau:
EDID không còn có sẵn.

.. c:type:: v4l2_edid

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. flat-table:: struct v4l2_edid
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``pad``
      - Pad for which to get/set the EDID blocks. When used with a video
	device node the pad represents the input or output index as
	returned by :ref:`VIDIOC_ENUMINPUT` and
	:ref:`VIDIOC_ENUMOUTPUT` respectively.
    * - __u32
      - ``start_block``
      - Read the EDID from starting with this block. Must be 0 when
	setting the EDID.
    * - __u32
      - ``blocks``
      - The number of blocks to get or set. Must be less or equal to 256
	(the maximum number of blocks as defined by the standard). When
	you set the EDID and ``blocks`` is 0, then the EDID is disabled or
	erased.
    * - __u32
      - ``reserved``\ [5]
      - Reserved for future extensions. Applications and drivers must set
	the array to zero.
    * - __u8 *
      - ``edid``
      - Pointer to memory that contains the EDID. The minimum size is
	``blocks`` * 128.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

ZZ0000ZZ
    Dữ liệu EDID không có sẵn.

ZZ0000ZZ
    Dữ liệu EDID bạn cung cấp nhiều hơn mức phần cứng có thể xử lý.