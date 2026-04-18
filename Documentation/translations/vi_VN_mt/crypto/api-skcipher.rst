.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/crypto/api-skcipher.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Mật mã khóa đối xứng
====================

Định nghĩa thuật toán mã hóa khối
----------------------------------

.. kernel-doc:: include/linux/crypto.h
   :doc: Block Cipher Algorithm Definitions

.. kernel-doc:: include/linux/crypto.h
   :functions: crypto_alg cipher_alg compress_alg

Mật mã khóa đối xứng API
------------------------

.. kernel-doc:: include/crypto/skcipher.h
   :doc: Symmetric Key Cipher API

.. kernel-doc:: include/crypto/skcipher.h
   :functions: crypto_alloc_skcipher crypto_free_skcipher crypto_has_skcipher crypto_skcipher_ivsize crypto_skcipher_blocksize crypto_skcipher_setkey crypto_skcipher_reqtfm crypto_skcipher_encrypt crypto_skcipher_decrypt

Xử lý yêu cầu mật mã khóa đối xứng
-----------------------------------

.. kernel-doc:: include/crypto/skcipher.h
   :doc: Symmetric Key Cipher Request Handle

.. kernel-doc:: include/crypto/skcipher.h
   :functions: crypto_skcipher_reqsize skcipher_request_set_tfm skcipher_request_alloc skcipher_request_free skcipher_request_set_callback skcipher_request_set_crypt

Mật mã khối đơn API
-----------------------

.. kernel-doc:: include/crypto/internal/cipher.h
   :doc: Single Block Cipher API

.. kernel-doc:: include/crypto/internal/cipher.h
   :functions: crypto_alloc_cipher crypto_free_cipher crypto_has_cipher crypto_cipher_blocksize crypto_cipher_setkey crypto_cipher_encrypt_one crypto_cipher_decrypt_one
