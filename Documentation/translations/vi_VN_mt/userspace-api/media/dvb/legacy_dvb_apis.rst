.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/legacy_dvb_apis.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _legacy_dvb_apis:

****************************
API truyền hình kỹ thuật số không được dùng nữa
***************************

Các API được mô tả ở đây ZZ0000ZZ được sử dụng trên các trình điều khiển hoặc ứng dụng mới.

Giao diện DVBv3 API có vấn đề với các hệ thống phân phối mới, bao gồm
DVB-S2, DVB-T2, ISDB, v.v.

.. attention::

   The APIs described here doesn't necessarily reflect the current
   code implementation, as this section of the document was written
   for DVB version 1, while the code reflects DVB version 3
   implementation.


.. toctree::
    :maxdepth: 1

    frontend_legacy_dvbv3_api
    legacy_dvb_decoder_api