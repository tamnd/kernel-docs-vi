.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-g-crop.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_G_CROP:

**********************************
ioctl VIDIOC_G_CROP, VIDIOC_S_CROP
**********************************

Tên
====

VIDIOC_G_CROP - VIDIOC_S_CROP - Nhận hoặc đặt hình chữ nhật cắt xén hiện tại

Tóm tắt
========

.. c:macro:: VIDIOC_G_CROP

ZZ0000ZZ

.. c:macro:: VIDIOC_S_CROP

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Để truy vấn các ứng dụng vị trí và kích thước hình chữ nhật cắt xén, hãy đặt
Trường ZZ0002ZZ của cấu trúc ZZ0000ZZ cho
loại bộ đệm (luồng) tương ứng và gọi ZZ0001ZZ ioctl
với một con trỏ tới cấu trúc này. Người lái xe lấp đầy phần còn lại của
cấu trúc hoặc trả về mã lỗi ZZ0003ZZ nếu việc cắt xén không được hỗ trợ.

Để thay đổi các ứng dụng cắt hình chữ nhật, hãy khởi tạo ZZ0002ZZ
và cấu trúc con ZZ0000ZZ có tên ZZ0003ZZ của một
cấu trúc v4l2_crop và gọi ZZ0001ZZ ioctl bằng một con trỏ
đến cấu trúc này.

Trình điều khiển trước tiên điều chỉnh kích thước được yêu cầu theo phần cứng
giới hạn, tức là đ. giới hạn được đưa ra bởi cửa sổ chụp/xuất và nó
làm tròn đến các giá trị gần nhất có thể của độ lệch ngang và dọc,
chiều rộng và chiều cao. Đặc biệt người lái xe phải làm tròn phương thẳng đứng
phần bù của hình chữ nhật cắt xén thành các đường khung theo modulo hai, sao cho
thứ tự trường không thể bị nhầm lẫn.

Thứ hai trình điều khiển điều chỉnh kích thước hình ảnh (hình chữ nhật đối diện của
quá trình chia tỷ lệ, nguồn hoặc đích tùy thuộc vào hướng dữ liệu) để
kích thước gần nhất có thể trong khi vẫn duy trì chiều ngang hiện tại và
hệ số tỷ lệ dọc.

Cuối cùng, trình điều khiển lập trình phần cứng bằng cách cắt xén thực tế và
thông số hình ảnh. ZZ0000ZZ là ioctl chỉ ghi, không
trả về các tham số thực tế. Để truy vấn chúng, các ứng dụng phải gọi
ZZ0001ZZ và ZZ0002ZZ. Khi
các tham số không phù hợp, ứng dụng có thể sửa đổi việc cắt xén hoặc
thông số hình ảnh và lặp lại chu trình cho đến khi có các thông số thỏa đáng
được đàm phán.

Khi việc cắt xén không được hỗ trợ thì không có tham số nào được thay đổi và
ZZ0000ZZ trả về mã lỗi ZZ0001ZZ.

.. c:type:: v4l2_crop

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. flat-table:: struct v4l2_crop
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``type``
      - Type of the data stream, set by the application. Only these types
	are valid here: ``V4L2_BUF_TYPE_VIDEO_CAPTURE``, ``V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE``,
	``V4L2_BUF_TYPE_VIDEO_OUTPUT``, ``V4L2_BUF_TYPE_VIDEO_OUTPUT_MPLANE`` and
	``V4L2_BUF_TYPE_VIDEO_OVERLAY``. See :c:type:`v4l2_buf_type` and the note below.
    * - struct :c:type:`v4l2_rect`
      - ``c``
      - Cropping rectangle. The same co-ordinate system as for struct
	:c:type:`v4l2_cropcap` ``bounds`` is used.

.. note::
   Unfortunately in the case of multiplanar buffer types
   (``V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE`` and ``V4L2_BUF_TYPE_VIDEO_OUTPUT_MPLANE``)
   this API was messed up with regards to how the :c:type:`v4l2_crop` ``type`` field
   should be filled in. Some drivers only accepted the ``_MPLANE`` buffer type while
   other drivers only accepted a non-multiplanar buffer type (i.e. without the
   ``_MPLANE`` at the end).

   Starting with kernel 4.13 both variations are allowed.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

ENODATA
    Việc cắt xén không được hỗ trợ cho đầu vào hoặc đầu ra này.