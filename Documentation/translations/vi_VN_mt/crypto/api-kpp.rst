.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/crypto/api-kpp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Nguyên tắc giao thức thỏa thuận chính (KPP)
=======================================

Định nghĩa thuật toán mã hóa giao thức thỏa thuận khóa (KPP)
--------------------------------------------------------------------

.. kernel-doc:: include/crypto/kpp.h
   :functions: kpp_request crypto_kpp kpp_alg kpp_secret

Thỏa thuận khóa Nguyên thủy giao thức (KPP) Mật mã API
--------------------------------------------------

.. kernel-doc:: include/crypto/kpp.h
   :doc: Generic Key-agreement Protocol Primitives API

.. kernel-doc:: include/crypto/kpp.h
   :functions: crypto_alloc_kpp crypto_free_kpp crypto_kpp_set_secret crypto_kpp_generate_public_key crypto_kpp_compute_shared_secret crypto_kpp_maxsize

Xử lý yêu cầu mã hóa nguyên thủy giao thức thỏa thuận khóa (KPP)
-------------------------------------------------------------

.. kernel-doc:: include/crypto/kpp.h
   :functions: kpp_request_alloc kpp_request_free kpp_request_set_callback kpp_request_set_input kpp_request_set_output

Chức năng trợ giúp ECDH
---------------------

.. kernel-doc:: include/crypto/ecdh.h
   :doc: ECDH Helper Functions

.. kernel-doc:: include/crypto/ecdh.h
   :functions: ecdh crypto_ecdh_key_len crypto_ecdh_encode_key crypto_ecdh_decode_key

Chức năng trợ giúp DH
-------------------

.. kernel-doc:: include/crypto/dh.h
   :doc: DH Helper Functions

.. kernel-doc:: include/crypto/dh.h
   :functions: dh crypto_dh_key_len crypto_dh_encode_key crypto_dh_decode_key
