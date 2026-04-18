.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/crypto/api-rng.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình tạo số ngẫu nhiên (RNG)
=============================

Định nghĩa thuật toán số ngẫu nhiên
-----------------------------------

.. kernel-doc:: include/crypto/rng.h
   :functions: rng_alg

Tiền điện tử API Số ngẫu nhiên API
----------------------------

.. kernel-doc:: include/crypto/rng.h
   :doc: Random number generator API

.. kernel-doc:: include/crypto/rng.h
   :functions: crypto_alloc_rng crypto_rng_alg crypto_free_rng crypto_rng_generate crypto_rng_get_bytes crypto_rng_reset crypto_rng_seedsize
