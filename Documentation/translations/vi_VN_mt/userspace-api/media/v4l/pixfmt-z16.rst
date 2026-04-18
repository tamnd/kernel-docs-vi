.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-z16.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _V4L2-PIX-FMT-Z16:

*************************
V4L2_PIX_FMT_Z16 ('Z16')
*************************


Dữ liệu độ sâu 16 bit với các giá trị khoảng cách ở mỗi pixel


Sự miêu tả
===========

Đây là định dạng 16 bit, thể hiện dữ liệu độ sâu. Mỗi pixel là một
khoảng cách đến điểm tương ứng trong tọa độ ảnh. Đơn vị khoảng cách
có thể khác nhau và phải được thương lượng riêng với thiết bị. Mỗi pixel
được lưu trữ trong một từ 16 bit theo thứ tự byte endian nhỏ.

ZZ0000ZZ
Mỗi ô là một byte.




.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - start + 0:
      - Z\ :sub:`00low`
      - Z\ :sub:`00high`
      - Z\ :sub:`01low`
      - Z\ :sub:`01high`
      - Z\ :sub:`02low`
      - Z\ :sub:`02high`
      - Z\ :sub:`03low`
      - Z\ :sub:`03high`
    * - start + 8:
      - Z\ :sub:`10low`
      - Z\ :sub:`10high`
      - Z\ :sub:`11low`
      - Z\ :sub:`11high`
      - Z\ :sub:`12low`
      - Z\ :sub:`12high`
      - Z\ :sub:`13low`
      - Z\ :sub:`13high`
    * - start + 16:
      - Z\ :sub:`20low`
      - Z\ :sub:`20high`
      - Z\ :sub:`21low`
      - Z\ :sub:`21high`
      - Z\ :sub:`22low`
      - Z\ :sub:`22high`
      - Z\ :sub:`23low`
      - Z\ :sub:`23high`
    * - start + 24:
      - Z\ :sub:`30low`
      - Z\ :sub:`30high`
      - Z\ :sub:`31low`
      - Z\ :sub:`31high`
      - Z\ :sub:`32low`
      - Z\ :sub:`32high`
      - Z\ :sub:`33low`
      - Z\ :sub:`33high`