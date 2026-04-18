.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/headers.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

***********************
Ký hiệu uAPI truyền hình kỹ thuật số
***********************

.. contents:: Table of Contents
   :depth: 2
   :local:

Giao diện người dùng
========

.. kernel-include:: include/uapi/linux/dvb/frontend.h
    :generate-cross-refs:
    :exception-file: frontend.h.rst.exceptions
    :toc:
    :warn-broken:

Demux
=====

.. kernel-include:: include/uapi/linux/dvb/dmx.h
    :generate-cross-refs:
    :exception-file: dmx.h.rst.exceptions
    :toc:
    :warn-broken:

Truy cập có điều kiện
==================

.. kernel-include:: include/uapi/linux/dvb/ca.h
    :generate-cross-refs:
    :exception-file: ca.h.rst.exceptions
    :toc:
    :warn-broken:

Mạng
=======

.. kernel-include:: include/uapi/linux/dvb/net.h
    :generate-cross-refs:
    :exception-file: net.h.rst.exceptions
    :toc:
    :warn-broken:
