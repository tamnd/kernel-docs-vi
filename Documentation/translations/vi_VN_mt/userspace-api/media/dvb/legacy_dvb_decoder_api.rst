.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later OR GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/legacy_dvb_decoder_api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _legacy_dvb_decoder_api:

===============================
API bộ giải mã DVB MPEG kế thừa
============================

.. _legacy_dvb_decoder_notes:

Ghi chú chung
=============

API này ban đầu chỉ được thiết kế cho DVB và do đó bị giới hạn ở
ZZ0000ZZ được sử dụng trong các hệ thống phát sóng truyền hình kỹ thuật số như vậy.

Để khắc phục những hạn chế này, ZZ0000ZZ API linh hoạt hơn có
được thiết kế. Phần này thay thế phần này của DVB API.

Tuy nhiên, đã có những dự án được xây dựng xung quanh chiếc API này.
Để đảm bảo khả năng tương thích, API này được giữ nguyên.

.. attention:: Do **not** use this API in new drivers!

    For audio and video use the :ref:`V4L2 <v4l2spec>` and ALSA APIs.

    Pipelines should be set up using the :ref:`Media Controller  API<media_controller>`.

Trên thực tế, các bộ giải mã dường như được xử lý khác nhau. Ứng dụng thường
biết bộ giải mã nào đang được sử dụng hoặc nó được viết riêng cho một loại bộ giải mã.
Khả năng truy vấn hiếm khi được sử dụng vì chúng đã được biết đến.


.. _legacy_dvb_decoder_formats:

Định dạng dữ liệu
============

API được thiết kế cho DVB và các hệ thống phát sóng tương thích.
Vì thực tế đó, các định dạng dữ liệu được hỗ trợ duy nhất là ISO/IEC 13818-1
các luồng MPEG tương thích. Tải trọng được hỗ trợ có thể thay đổi tùy thuộc vào
bộ giải mã được sử dụng.

Dấu thời gian luôn là MPEG PTS như được định nghĩa trong ITU T-REC-H.222.0 /
ISO/IEC 13818-1, nếu không có ghi chú khác.

Để lưu trữ các bản ghi, các luồng TS thường được sử dụng, ở mức độ thấp hơn là PES.
Cả hai biến thể thường được chấp nhận để phát lại nhưng có thể phụ thuộc vào trình điều khiển.




Mục lục
=================

.. toctree::
    :maxdepth: 2

    legacy_dvb_video
    legacy_dvb_audio
    legacy_dvb_osd