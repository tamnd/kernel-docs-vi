.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/metafmt-vsp1-hgt.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _v4l2-meta-fmt-vsp1-hgt:

*******************************
V4L2_META_FMT_VSP1_HGT ('VSPT')
*******************************

Dữ liệu biểu đồ 2-D của Renesas R-Car VSP1


Sự miêu tả
===========

Định dạng này mô tả dữ liệu biểu đồ được tạo bởi Renesas R-Car VSP1
Công cụ biểu đồ 2-D (HGT).

VSP1 HGT là một công cụ tính toán biểu đồ hoạt động trên HSV
dữ liệu. Nó hoạt động trên một hình ảnh đầu vào có thể bị cắt và lấy mẫu phụ và
tính tổng, giá trị lớn nhất và giá trị nhỏ nhất của thành phần S cũng như giá trị
biểu đồ tần số có trọng số dựa trên các thành phần H và S.

Biểu đồ là ma trận gồm 6 nhóm Hue và 32 nhóm Saturation, 192 in
tổng cộng. Mỗi giá trị HSV được thêm vào một hoặc nhiều nhóm có trọng số
trong khoảng từ 1 đến 16 tùy thuộc vào cấu hình khu vực Huế. Tìm kiếm
các nhóm tương ứng được thực hiện bằng cách kiểm tra giá trị H và S một cách độc lập.

Vị trí bão hòa ZZ0000ZZ (0 - 31) của nhóm trong ma trận là
được tìm thấy bởi biểu thức:

n = S/8

Vị trí Hue ZZ0000ZZ (0 - 5) của nhóm trong ma trận phụ thuộc vào
cách cấu hình các khu vực HGT Hue. Có 6 người dùng có thể cấu hình Huế
Các khu vực có thể được cấu hình để bao gồm các giá trị Hue chồng chéo:

.. raw:: latex

    \small

::

Khu 0 Khu 1 Khu 2 Khu 3 Khu 4 Khu 5
        ________ ________ ________ ________ ________ ________
   \ /ZZ0000ZZ\ /ZZ0001ZZ\ /ZZ0002ZZ\ /ZZ0003ZZ\ /ZZ0004ZZ\ /ZZ0005ZZ\ /
    \ / ZZ0006ZZ \ / ZZ0007ZZ \ / ZZ0008ZZ \ / ZZ0009ZZ \ / ZZ0010ZZ \ / ZZ0011ZZ \ /
     X ZZ0012ZZ X ZZ0013ZZ X ZZ0014ZZ X ZZ0015ZZ X ZZ0016ZZ X ZZ0017ZZ X
    / \ ZZ0018ZZ / \ ZZ0019ZZ / \ ZZ0020ZZ / \ ZZ0021ZZ / \ ZZ0022ZZ / \ ZZ0023ZZ / \
   / \ZZ0024ZZ/ \ZZ0025ZZ/ \ZZ0026ZZ/ \ZZ0027ZZ/ \ZZ0028ZZ/ \ZZ0029ZZ/ \
  5U 0L 0U 1L 1U 2L 2U 3L 3U 4L 4U 5L 5U 0L
        <0...........Giá trị màu sắc...........255>


.. raw:: latex

    \normalsize

Khi hai khu vực liên tiếp không chồng lên nhau (n+1L bằng nU) ranh giới
giá trị được coi là một phần của khu vực thấp hơn.

Các pixel có giá trị màu nằm ở trung tâm của một khu vực (giữa nL và nU
được bao gồm) được quy cho khu vực duy nhất đó và có trọng số là 16. Điểm ảnh
với giá trị màu sắc nằm trong vùng chồng lấp giữa hai vùng (giữa
loại trừ n+1L và nU) được quy cho cả hai khu vực và có trọng số cho mỗi khu vực
của các diện tích này tỉ lệ với vị trí của chúng dọc theo các đường chéo
(làm tròn xuống).

Thiết lập khu vực Huế phải phù hợp với một trong các ràng buộc sau:

::

0L <= 0U <= 1L <= 1U <= 2L <= 2U <= 3L <= 3U <= 4L <= 4U <= 5L <= 5U

::

0U <= 1L <= 1U <= 2L <= 2U <= 3L <= 3U <= 4L <= 4U <= 5L <= 5U <= 0L

ZZ0000ZZ
Tất cả dữ liệu được lưu trữ trong bộ nhớ ở định dạng endian nhỏ. Mỗi ô trong bảng
chứa một byte.

.. flat-table:: VSP1 HGT Data - (776 bytes)
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
      - -
      - S max [7:0]
      - -
      - S min [7:0]
    * - 4
      - :cspan:`4` S sum [31:0]
    * - 8
      - :cspan:`4` Histogram bucket (m=0, n=0) [31:0]
    * - 12
      - :cspan:`4` Histogram bucket (m=0, n=1) [31:0]
    * -
      - :cspan:`4` ...
    * - 132
      - :cspan:`4` Histogram bucket (m=0, n=31) [31:0]
    * - 136
      - :cspan:`4` Histogram bucket (m=1, n=0) [31:0]
    * -
      - :cspan:`4` ...
    * - 264
      - :cspan:`4` Histogram bucket (m=2, n=0) [31:0]
    * -
      - :cspan:`4` ...
    * - 392
      - :cspan:`4` Histogram bucket (m=3, n=0) [31:0]
    * -
      - :cspan:`4` ...
    * - 520
      - :cspan:`4` Histogram bucket (m=4, n=0) [31:0]
    * -
      - :cspan:`4` ...
    * - 648
      - :cspan:`4` Histogram bucket (m=5, n=0) [31:0]
    * -
      - :cspan:`4` ...
    * - 772
      - :cspan:`4` Histogram bucket (m=5, n=31) [31:0]