.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-inzi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _V4L2-PIX-FMT-INZI:

**************************
V4L2_PIX_FMT_INZI ('INZI')
**************************

Hồng ngoại 10 bit được liên kết với hình ảnh Độ sâu 16 bit


Sự miêu tả
===========

Định dạng đa mặt phẳng độc quyền được sử dụng bởi máy ảnh Độ sâu Intel SR300, bao gồm
Hình ảnh hồng ngoại theo sau là dữ liệu Độ sâu. Độ phân giải pixel là 32-bpp,
với Dữ liệu Độ sâu và Hồng ngoại được chia thành các mặt phẳng liên tục riêng biệt
kích thước giống nhau.



Mặt phẳng thứ nhất - Dữ liệu hồng ngoại - được lưu trữ theo
Định dạng thang độ xám ZZ0000ZZ.
Mỗi pixel là một ô 16 bit, với dữ liệu thực tế được lưu trữ trong 10 LSB
với các giá trị trong khoảng từ 0 đến 1023.
Sáu MSB còn lại được đệm bằng số không.


Mặt phẳng thứ hai cung cấp dữ liệu Độ sâu 16 bit cho mỗi pixel được sắp xếp theo
Định dạng ZZ0000ZZ.


ZZ0000ZZ
Mỗi ô là một từ 16 bit với dữ liệu quan trọng hơn được lưu trữ ở mức cao hơn
địa chỉ bộ nhớ (thứ tự byte là little-endian).


.. raw:: latex

    \small

.. tabularcolumns:: |p{2.5cm}|p{2.5cm}|p{2.5cm}|p{2.5cm}|p{2.5cm}|p{2.5cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 1
    :widths:    1 1 1 1 1 1

    * - Ir\ :sub:`0,0`
      - Ir\ :sub:`0,1`
      - Ir\ :sub:`0,2`
      - ...
      - ...
      - ...
    * - :cspan:`5` ...
    * - :cspan:`5` Infrared Data
    * - :cspan:`5` ...
    * - ...
      - ...
      - ...
      - Ir\ :sub:`n-1,n-3`
      - Ir\ :sub:`n-1,n-2`
      - Ir\ :sub:`n-1,n-1`
    * - Depth\ :sub:`0,0`
      - Depth\ :sub:`0,1`
      - Depth\ :sub:`0,2`
      - ...
      - ...
      - ...
    * - :cspan:`5` ...
    * - :cspan:`5` Depth Data
    * - :cspan:`5` ...
    * - ...
      - ...
      - ...
      - Depth\ :sub:`n-1,n-3`
      - Depth\ :sub:`n-1,n-2`
      - Depth\ :sub:`n-1,n-1`

.. raw:: latex

    \normalsize