.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/crypto/api-aead.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Mã hóa được xác thực với dữ liệu liên kết (AEAD)
====================================================

Định nghĩa thuật toán mã hóa được xác thực bằng dữ liệu liên kết (AEAD)
--------------------------------------------------------------------------

.. kernel-doc:: include/crypto/aead.h
   :doc: Authenticated Encryption With Associated Data (AEAD) Cipher API

.. kernel-doc:: include/crypto/aead.h
   :functions: aead_request aead_alg

Mã hóa được xác thực bằng mật mã dữ liệu liên kết (AEAD) API
---------------------------------------------------------------

.. kernel-doc:: include/crypto/aead.h
   :functions: crypto_alloc_aead crypto_free_aead crypto_aead_ivsize crypto_aead_authsize crypto_aead_blocksize crypto_aead_setkey crypto_aead_setauthsize crypto_aead_encrypt crypto_aead_decrypt

Xử lý yêu cầu AEAD không đồng bộ
--------------------------------

.. kernel-doc:: include/crypto/aead.h
   :doc: Asynchronous AEAD Request Handle

.. kernel-doc:: include/crypto/aead.h
   :functions: crypto_aead_reqsize aead_request_set_tfm aead_request_alloc aead_request_free aead_request_set_callback aead_request_set_crypt aead_request_set_ad
