.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/crypto/api-sig.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Chữ ký bất đối xứng
====================

Định nghĩa thuật toán chữ ký bất đối xứng
------------------------------------------

.. kernel-doc:: include/crypto/sig.h
   :functions: sig_alg

Chữ ký bất đối xứng API
------------------------

.. kernel-doc:: include/crypto/sig.h
   :doc: Generic Public Key Signature API

.. kernel-doc:: include/crypto/sig.h
   :functions: crypto_alloc_sig crypto_free_sig crypto_sig_set_pubkey crypto_sig_set_privkey crypto_sig_keysize crypto_sig_maxsize crypto_sig_digestsize crypto_sig_sign crypto_sig_verify

