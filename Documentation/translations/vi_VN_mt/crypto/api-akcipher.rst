.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/crypto/api-akcipher.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Mật mã bất đối xứng
===================

Định nghĩa thuật toán mã hóa bất đối xứng
-----------------------------------------

.. kernel-doc:: include/crypto/akcipher.h
   :functions: akcipher_alg akcipher_request

Mật mã bất đối xứng API
-----------------------

.. kernel-doc:: include/crypto/akcipher.h
   :doc: Generic Public Key Cipher API

.. kernel-doc:: include/crypto/akcipher.h
   :functions: crypto_alloc_akcipher crypto_free_akcipher crypto_akcipher_set_pub_key crypto_akcipher_set_priv_key crypto_akcipher_maxsize crypto_akcipher_encrypt crypto_akcipher_decrypt

Xử lý yêu cầu mật mã bất đối xứng
---------------------------------

.. kernel-doc:: include/crypto/akcipher.h
   :functions: akcipher_request_alloc akcipher_request_free akcipher_request_set_callback akcipher_request_set_crypt
