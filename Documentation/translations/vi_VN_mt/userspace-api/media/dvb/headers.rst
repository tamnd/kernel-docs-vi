.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/headers.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

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
