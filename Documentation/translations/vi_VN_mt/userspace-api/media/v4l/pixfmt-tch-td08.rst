.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-tch-td08.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _V4L2-TCH-FMT-DELTA-TD08:

*******************************
V4L2_TCH_FMT_DELTA_TD08 ('TD08')
********************************

ZZ0000ZZ

Touch Delta có chữ ký 8 bit

Sự miêu tả
===========

Định dạng này thể hiện dữ liệu delta từ bộ điều khiển cảm ứng.

Giá trị Delta có thể nằm trong khoảng từ -128 đến 127. Thông thường, các giá trị này sẽ thay đổi theo
một phạm vi nhỏ tùy thuộc vào việc cảm biến có được chạm vào hay không. Giá trị đầy đủ
có thể được nhìn thấy nếu một trong các nút màn hình cảm ứng bị lỗi hoặc đường truyền không
được kết nối.

ZZ0000ZZ
Mỗi ô là một byte.



.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths:       2 1 1 1 1

    * - start + 0:
      - D'\ :sub:`00`
      - D'\ :sub:`01`
      - D'\ :sub:`02`
      - D'\ :sub:`03`
    * - start + 4:
      - D'\ :sub:`10`
      - D'\ :sub:`11`
      - D'\ :sub:`12`
      - D'\ :sub:`13`
    * - start + 8:
      - D'\ :sub:`20`
      - D'\ :sub:`21`
      - D'\ :sub:`22`
      - D'\ :sub:`23`
    * - start + 12:
      - D'\ :sub:`30`
      - D'\ :sub:`31`
      - D'\ :sub:`32`
      - D'\ :sub:`33`