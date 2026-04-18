.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/metafmt-generic.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

***************************************************************************************************************************************************************************************************************************************************************************************************************
V4L2_META_FMT_GENERIC_8 ('MET8'), V4L2_META_FMT_GENERIC_CSI2_10 ('MC1A'), V4L2_META_FMT_GENERIC_CSI2_12 ('MC1C'), V4L2_META_FMT_GENERIC_CSI2_14 ('MC1E'), V4L2_META_FMT_GENERIC_CSI2_16 ('MC1G'), V4L2_META_FMT_GENERIC_CSI2_20 ('MC1K'), V4L2_META_FMT_GENERIC_CSI2_24 ('MC1O')
********************************************************************************************************************************************************************************************************************************************************************************


Các định dạng siêu dữ liệu dựa trên dòng chung


Sự miêu tả
===========

Các định dạng siêu dữ liệu dựa trên dòng chung này xác định bố cục bộ nhớ của dữ liệu
mà không xác định định dạng hoặc ý nghĩa của siêu dữ liệu.

.. _v4l2-meta-fmt-generic-8:

V4L2_META_FMT_GENERIC_8
-----------------------

Định dạng V4L2_META_FMT_GENERIC_8 là định dạng siêu dữ liệu 8 bit đơn giản. Định dạng này
được sử dụng trên CSI-2 với 8 bit cho mỗi ZZ0000ZZ.

Ngoài ra, nó được sử dụng cho 16 bit trên mỗi Đơn vị Dữ liệu khi có hai byte siêu dữ liệu.
được đóng gói thành một Đơn vị dữ liệu 16 bit. Mặt khác, định dạng dữ liệu 16 bit trên mỗi pixel là
ZZ0000ZZ.

ZZ0000ZZ
Mỗi ô là một byte. "M" biểu thị một byte siêu dữ liệu.

.. tabularcolumns:: |p{2.4cm}|p{1.2cm}|p{1.2cm}|p{1.2cm}|p{1.2cm}|

.. flat-table:: Sample 4x2 Metadata Frame
    :header-rows:  0
    :stub-columns: 0
    :widths: 12 8 8 8 8

    * - start + 0:
      - M\ :sub:`00`
      - M\ :sub:`10`
      - M\ :sub:`20`
      - M\ :sub:`30`
    * - start + 4:
      - M\ :sub:`01`
      - M\ :sub:`11`
      - M\ :sub:`21`
      - M\ :sub:`31`

.. _v4l2-meta-fmt-generic-csi2-10:

V4L2_META_FMT_GENERIC_CSI2_10
-----------------------------

V4L2_META_FMT_GENERIC_CSI2_10 chứa siêu dữ liệu chung 8 bit được đóng gói trong 10 bit
Đơn vị dữ liệu, với một byte đệm sau mỗi bốn byte siêu dữ liệu. Cái này
định dạng thường được sử dụng bởi các máy thu CSI-2 với nguồn truyền
MEDIA_BUS_FMT_META_10 và bộ thu CSI-2 ghi dữ liệu nhận được vào bộ nhớ
nguyên trạng.

Việc đóng gói dữ liệu tuân theo thông số kỹ thuật MIPI CSI-2 và phần đệm của
dữ liệu được xác định trong thông số kỹ thuật MIPI CCS.

Định dạng này cũng được sử dụng cùng với 20 bit cho mỗi ZZ0000ZZ
các định dạng đóng gói hai byte siêu dữ liệu vào một Đơn vị Dữ liệu. Nếu không thì
Định dạng dữ liệu 20 bit cho mỗi pixel là ZZ0001ZZ.

Định dạng này là endian nhỏ.

ZZ0000ZZ
Mỗi ô là một byte. "M" biểu thị một byte siêu dữ liệu và "x" biểu thị một byte đệm.

.. tabularcolumns:: |p{2.4cm}|p{1.2cm}|p{1.2cm}|p{1.2cm}|p{1.2cm}|p{1.8cm}|

.. flat-table:: Sample 4x2 Metadata Frame
    :header-rows:  0
    :stub-columns: 0
    :widths: 12 8 8 8 8 8

    * - start + 0:
      - M\ :sub:`00`
      - M\ :sub:`10`
      - M\ :sub:`20`
      - M\ :sub:`30`
      - x
    * - start + 5:
      - M\ :sub:`01`
      - M\ :sub:`11`
      - M\ :sub:`21`
      - M\ :sub:`31`
      - x

.. _v4l2-meta-fmt-generic-csi2-12:

V4L2_META_FMT_GENERIC_CSI2_12
-----------------------------

V4L2_META_FMT_GENERIC_CSI2_12 chứa siêu dữ liệu chung 8 bit được đóng gói trong 12 bit
Đơn vị dữ liệu, với một byte đệm sau mỗi hai byte siêu dữ liệu. Định dạng này
thường được sử dụng bởi các máy thu CSI-2 với nguồn truyền
MEDIA_BUS_FMT_META_12 và bộ thu CSI-2 ghi dữ liệu nhận được vào bộ nhớ
nguyên trạng.

Việc đóng gói dữ liệu tuân theo thông số kỹ thuật MIPI CSI-2 và phần đệm của
dữ liệu được xác định trong thông số kỹ thuật MIPI CCS.

Định dạng này cũng được sử dụng cùng với 24 bit cho mỗi ZZ0000ZZ
các định dạng đóng gói hai byte siêu dữ liệu vào một Đơn vị Dữ liệu. Nếu không thì
Định dạng dữ liệu 24 bit trên mỗi pixel là ZZ0001ZZ.

Định dạng này là endian nhỏ.

ZZ0000ZZ
Mỗi ô là một byte. "M" biểu thị một byte siêu dữ liệu và "x" biểu thị một byte đệm.

.. tabularcolumns:: |p{2.4cm}|p{1.2cm}|p{1.2cm}|p{1.8cm}|p{1.2cm}|p{1.2cm}|p{1.8cm}|

.. flat-table:: Sample 4x2 Metadata Frame
    :header-rows:  0
    :stub-columns: 0
    :widths: 12 8 8 8 8 8 8

    * - start + 0:
      - M\ :sub:`00`
      - M\ :sub:`10`
      - x
      - M\ :sub:`20`
      - M\ :sub:`30`
      - x
    * - start + 6:
      - M\ :sub:`01`
      - M\ :sub:`11`
      - x
      - M\ :sub:`21`
      - M\ :sub:`31`
      - x

.. _v4l2-meta-fmt-generic-csi2-14:

V4L2_META_FMT_GENERIC_CSI2_14
-----------------------------

V4L2_META_FMT_GENERIC_CSI2_14 chứa siêu dữ liệu chung 8 bit được đóng gói trong 14 bit
Đơn vị dữ liệu, với ba byte đệm sau mỗi bốn byte siêu dữ liệu. Cái này
định dạng thường được sử dụng bởi các máy thu CSI-2 với nguồn truyền
MEDIA_BUS_FMT_META_14 và bộ thu CSI-2 ghi dữ liệu nhận được vào bộ nhớ
nguyên trạng.

Việc đóng gói dữ liệu tuân theo thông số kỹ thuật MIPI CSI-2 và phần đệm của
dữ liệu được xác định trong thông số kỹ thuật MIPI CCS.

Định dạng này là endian nhỏ.

ZZ0000ZZ
Mỗi ô là một byte. "M" biểu thị một byte siêu dữ liệu và "x" biểu thị một byte đệm.

.. tabularcolumns:: |p{2.4cm}|p{1.2cm}|p{1.2cm}|p{1.2cm}|p{1.2cm}|p{1.8cm}|p{1.8cm}|p{1.8cm}|

.. flat-table:: Sample 4x2 Metadata Frame
    :header-rows:  0
    :stub-columns: 0
    :widths: 12 8 8 8 8 8 8 8

    * - start + 0:
      - M\ :sub:`00`
      - M\ :sub:`10`
      - M\ :sub:`20`
      - M\ :sub:`30`
      - x
      - x
      - x
    * - start + 7:
      - M\ :sub:`01`
      - M\ :sub:`11`
      - M\ :sub:`21`
      - M\ :sub:`31`
      - x
      - x
      - x

.. _v4l2-meta-fmt-generic-csi2-16:

V4L2_META_FMT_GENERIC_CSI2_16
-----------------------------

V4L2_META_FMT_GENERIC_CSI2_16 chứa siêu dữ liệu chung 8 bit được đóng gói trong 16 bit
Đơn vị dữ liệu, với một byte đệm sau mỗi byte siêu dữ liệu. Định dạng này là
thường được sử dụng bởi các máy thu CSI-2 với nguồn truyền
MEDIA_BUS_FMT_META_16 và bộ thu CSI-2 ghi dữ liệu nhận được vào bộ nhớ
nguyên trạng.

Việc đóng gói dữ liệu tuân theo thông số kỹ thuật MIPI CSI-2 và phần đệm của
dữ liệu được xác định trong thông số kỹ thuật MIPI CCS.

Một số thiết bị hỗ trợ đóng gói siêu dữ liệu hiệu quả hơn kết hợp với
Dữ liệu hình ảnh 16 bit. Trong trường hợp đó, định dạng dữ liệu là
ZZ0000ZZ.

Định dạng này là endian nhỏ.

ZZ0000ZZ
Mỗi ô là một byte. "M" biểu thị một byte siêu dữ liệu và "x" biểu thị một byte đệm.

.. tabularcolumns:: |p{2.4cm}|p{1.2cm}|p{.8cm}|p{1.2cm}|p{.8cm}|p{1.2cm}|p{.8cm}|p{1.2cm}|p{.8cm}|

.. flat-table:: Sample 4x2 Metadata Frame
    :header-rows:  0
    :stub-columns: 0
    :widths: 12 8 8 8 8 8 8 8 8

    * - start + 0:
      - M\ :sub:`00`
      - x
      - M\ :sub:`10`
      - x
      - M\ :sub:`20`
      - x
      - M\ :sub:`30`
      - x
    * - start + 8:
      - M\ :sub:`01`
      - x
      - M\ :sub:`11`
      - x
      - M\ :sub:`21`
      - x
      - M\ :sub:`31`
      - x

.. _v4l2-meta-fmt-generic-csi2-20:

V4L2_META_FMT_GENERIC_CSI2_20
-----------------------------

V4L2_META_FMT_GENERIC_CSI2_20 chứa siêu dữ liệu chung 8 bit được đóng gói trong 20 bit
Đơn vị dữ liệu, với một hoặc hai byte đệm xen kẽ sau mỗi byte của
siêu dữ liệu. Định dạng này thường được sử dụng bởi các máy thu CSI-2 với nguồn
truyền MEDIA_BUS_FMT_META_20 và bộ thu CSI-2 ghi dữ liệu đã nhận
vào bộ nhớ như hiện trạng.

Việc đóng gói dữ liệu tuân theo thông số kỹ thuật MIPI CSI-2 và phần đệm của
dữ liệu được xác định trong thông số kỹ thuật MIPI CCS.

Một số thiết bị hỗ trợ đóng gói siêu dữ liệu hiệu quả hơn kết hợp với
Dữ liệu hình ảnh 16 bit. Trong trường hợp đó, định dạng dữ liệu là
ZZ0000ZZ.

Định dạng này là endian nhỏ.

ZZ0000ZZ
Mỗi ô là một byte. "M" biểu thị một byte siêu dữ liệu và "x" biểu thị một byte đệm.

.. tabularcolumns:: |p{2.4cm}|p{1.2cm}|p{1.2cm}|p{1.2cm}|p{1.2cm}|p{1.8cm}|p{1.2cm}|p{1.2cm}|p{1.2cm}|p{1.2cm}|p{1.8cm}

.. flat-table:: Sample 4x2 Metadata Frame
    :header-rows:  0
    :stub-columns: 0
    :widths: 12 8 8 8 8 8 8 8 8 8 8

    * - start + 0:
      - M\ :sub:`00`
      - x
      - M\ :sub:`10`
      - x
      - x
      - M\ :sub:`20`
      - x
      - M\ :sub:`30`
      - x
      - x
    * - start + 10:
      - M\ :sub:`01`
      - x
      - M\ :sub:`11`
      - x
      - x
      - M\ :sub:`21`
      - x
      - M\ :sub:`31`
      - x
      - x

.. _v4l2-meta-fmt-generic-csi2-24:

V4L2_META_FMT_GENERIC_CSI2_24
-----------------------------

V4L2_META_FMT_GENERIC_CSI2_24 chứa siêu dữ liệu chung 8 bit được đóng gói trong 24 bit
Đơn vị dữ liệu, có hai byte đệm sau mỗi byte siêu dữ liệu. Định dạng này là
thường được sử dụng bởi các máy thu CSI-2 với nguồn truyền
MEDIA_BUS_FMT_META_24 và bộ thu CSI-2 ghi dữ liệu nhận được vào bộ nhớ
nguyên trạng.

Việc đóng gói dữ liệu tuân theo thông số kỹ thuật MIPI CSI-2 và phần đệm của
dữ liệu được xác định trong thông số kỹ thuật MIPI CCS.

Một số thiết bị hỗ trợ đóng gói siêu dữ liệu hiệu quả hơn kết hợp với
Dữ liệu hình ảnh 16 bit. Trong trường hợp đó, định dạng dữ liệu là
ZZ0000ZZ.

Định dạng này là endian nhỏ.

ZZ0000ZZ
Mỗi ô là một byte. "M" biểu thị một byte siêu dữ liệu và "x" biểu thị một byte đệm.

.. tabularcolumns:: |p{2.4cm}|p{1.2cm}|p{.8cm}|p{.8cm}|p{1.2cm}|p{.8cm}|p{.8cm}|p{1.2cm}|p{.8cm}|p{.8cm}|p{1.2cm}|p{.8cm}|p{.8cm}|

.. flat-table:: Sample 4x2 Metadata Frame
    :header-rows:  0
    :stub-columns: 0
    :widths: 12 8 8 8 8 8 8 8 8 8 8 8 8

    * - start + 0:
      - M\ :sub:`00`
      - x
      - x
      - M\ :sub:`10`
      - x
      - x
      - M\ :sub:`20`
      - x
      - x
      - M\ :sub:`30`
      - x
      - x
    * - start + 12:
      - M\ :sub:`01`
      - x
      - x
      - M\ :sub:`11`
      - x
      - x
      - M\ :sub:`21`
      - x
      - x
      - M\ :sub:`31`
      - x
      - x