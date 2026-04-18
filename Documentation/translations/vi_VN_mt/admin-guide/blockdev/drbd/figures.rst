.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/blockdev/drbd/figures.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. The here included files are intended to help understand the implementation

Các luồng dữ liệu liên quan đến một số chức năng và ghi các gói
========================================================

.. kernel-figure:: DRBD-8.3-data-packets.svg
    :alt:   DRBD-8.3-data-packets.svg
    :align: center

.. kernel-figure:: DRBD-data-packets.svg
    :alt:   DRBD-data-packets.svg
    :align: center


Biểu đồ con của quá trình chuyển đổi trạng thái của DRBD
======================================

.. kernel-figure:: conn-states-8.dot
    :alt:   conn-states-8.dot
    :align: center

.. kernel-figure:: disk-states-8.dot
    :alt:   disk-states-8.dot
    :align: center

.. kernel-figure:: peer-states-8.dot
    :alt:   peer-states-8.dot
    :align: center