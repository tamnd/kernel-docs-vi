.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/blockdev/drbd/figures.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

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