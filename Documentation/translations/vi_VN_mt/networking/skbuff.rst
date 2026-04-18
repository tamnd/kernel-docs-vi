.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/skbuff.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

cấu trúc sk_buff
================

ZZ0000ZZ là cấu trúc mạng chính đại diện cho
một gói.

Hình học sk_buff cơ bản
-----------------------

.. kernel-doc:: include/linux/skbuff.h
   :doc: Basic sk_buff geometry

Skbs được chia sẻ và bản sao skb
--------------------------------

ZZ0000ZZ là một lần đếm lại đơn giản cho phép nhiều thực thể
để duy trì cấu trúc sk_buff. skbs có ZZ0001ZZ được giới thiệu
thành skbs được chia sẻ (xem skb_shared()).

skb_clone() cho phép sao chép nhanh skbs. Không có bộ đệm dữ liệu nào
được sao chép, nhưng người gọi sẽ nhận được cấu trúc siêu dữ liệu mới (struct sk_buff).
&skb_shared_info.refcount cho biết số lượng skbs trỏ vào cùng một
dữ liệu gói (tức là bản sao).

dataref và skbs không tiêu đề
-----------------------------

.. kernel-doc:: include/linux/skbuff.h
   :doc: dataref and headerless skbs

Thông tin tổng kiểm tra
-----------------------

.. kernel-doc:: include/linux/skbuff.h
   :doc: skb checksums