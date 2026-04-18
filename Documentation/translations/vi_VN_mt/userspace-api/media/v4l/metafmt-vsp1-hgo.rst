.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/metafmt-vsp1-hgo.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _v4l2-meta-fmt-vsp1-hgo:

*******************************
V4L2_META_FMT_VSP1_HGO ('VSPH')
*******************************

Dữ liệu biểu đồ 1-D của Renesas R-Car VSP1


Sự miêu tả
===========

Định dạng này mô tả dữ liệu biểu đồ được tạo bởi Renesas R-Car VSP1 1-D
Động cơ biểu đồ (HGO).

VSP1 HGO là một công cụ tính toán biểu đồ có thể hoạt động trên RGB, YCrCb
hoặc dữ liệu HSV. Nó hoạt động trên một hình ảnh đầu vào có thể bị cắt và lấy mẫu phụ và
tính toán mức tối thiểu, tối đa và tổng của tất cả các pixel cũng như trên mỗi kênh
biểu đồ.

HGO có thể tính toán biểu đồ độc lập trên mỗi kênh, ở mức tối đa
ba kênh (chỉ dữ liệu RGB) hoặc chỉ trên kênh Y (chỉ YCbCr). Nó có thể
ngoài ra còn xuất biểu đồ với 64 hoặc 256 thùng, dẫn đến bốn
các phương thức hoạt động có thể có.

- Trong ZZ0000ZZ, HGO hoạt động độc lập trên ba kênh
  để tính toán ba biểu đồ 64 thùng. Các định dạng hình ảnh RGB, YCbCr và HSV là
  được hỗ trợ.
- Ở ZZ0001ZZ, HGO hoạt động tối đa (R, G, B)
  các kênh để tính toán biểu đồ 64 thùng. Chỉ có định dạng hình ảnh RGB là
  được hỗ trợ.
- Trong ZZ0002ZZ, HGO hoạt động trên kênh Y để tính toán
  biểu đồ 256 thùng đơn. Chỉ hỗ trợ định dạng hình ảnh YCbCr.
- Ở ZZ0003ZZ, HGO hoạt động tối đa (R, G, B)
  các kênh để tính toán biểu đồ 256 thùng. Chỉ có định dạng hình ảnh RGB là
  được hỗ trợ.

ZZ0000ZZ
Tất cả dữ liệu được lưu trữ trong bộ nhớ ở định dạng endian nhỏ. Mỗi ô trong bảng
chứa một byte.

.. flat-table:: VSP1 HGO Data - 64 Bins, Normal Mode (792 bytes)
    :header-rows:  2
    :stub-columns: 0

    * - Offset
      - :cspan:`4` Memory
    * -
      - [31:24]
      - [23:16]
      - [15:8]
      - [7:0]
    * - 0
      -
      - R/Cr/H max [7:0]
      -
      - R/Cr/H min [7:0]
    * - 4
      -
      - G/Y/S max [7:0]
      -
      - G/Y/S min [7:0]
    * - 8
      -
      - B/Cb/V max [7:0]
      -
      - B/Cb/V min [7:0]
    * - 12
      - :cspan:`4` R/Cr/H sum [31:0]
    * - 16
      - :cspan:`4` G/Y/S sum [31:0]
    * - 20
      - :cspan:`4` B/Cb/V sum [31:0]
    * - 24
      - :cspan:`4` R/Cr/H bin 0 [31:0]
    * -
      - :cspan:`4` ...
    * - 276
      - :cspan:`4` R/Cr/H bin 63 [31:0]
    * - 280
      - :cspan:`4` G/Y/S bin 0 [31:0]
    * -
      - :cspan:`4` ...
    * - 532
      - :cspan:`4` G/Y/S bin 63 [31:0]
    * - 536
      - :cspan:`4` B/Cb/V bin 0 [31:0]
    * -
      - :cspan:`4` ...
    * - 788
      - :cspan:`4` B/Cb/V bin 63 [31:0]

.. flat-table:: VSP1 HGO Data - 64 Bins, Max Mode (264 bytes)
    :header-rows:  2
    :stub-columns: 0

    * - Offset
      - :cspan:`4` Memory
    * -
      - [31:24]
      - [23:16]
      - [15:8]
      - [7:0]
    * - 0
      -
      - max(R,G,B) max [7:0]
      -
      - max(R,G,B) min [7:0]
    * - 4
      - :cspan:`4` max(R,G,B) sum [31:0]
    * - 8
      - :cspan:`4` max(R,G,B) bin 0 [31:0]
    * -
      - :cspan:`4` ...
    * - 260
      - :cspan:`4` max(R,G,B) bin 63 [31:0]

.. flat-table:: VSP1 HGO Data - 256 Bins, Normal Mode (1032 bytes)
    :header-rows:  2
    :stub-columns: 0

    * - Offset
      - :cspan:`4` Memory
    * -
      - [31:24]
      - [23:16]
      - [15:8]
      - [7:0]
    * - 0
      -
      - Y max [7:0]
      -
      - Y min [7:0]
    * - 4
      - :cspan:`4` Y sum [31:0]
    * - 8
      - :cspan:`4` Y bin 0 [31:0]
    * -
      - :cspan:`4` ...
    * - 1028
      - :cspan:`4` Y bin 255 [31:0]

.. flat-table:: VSP1 HGO Data - 256 Bins, Max Mode (1032 bytes)
    :header-rows:  2
    :stub-columns: 0

    * - Offset
      - :cspan:`4` Memory
    * -
      - [31:24]
      - [23:16]
      - [15:8]
      - [7:0]
    * - 0
      -
      - max(R,G,B) max [7:0]
      -
      - max(R,G,B) min [7:0]
    * - 4
      - :cspan:`4` max(R,G,B) sum [31:0]
    * - 8
      - :cspan:`4` max(R,G,B) bin 0 [31:0]
    * -
      - :cspan:`4` ...
    * - 1028
      - :cspan:`4` max(R,G,B) bin 255 [31:0]