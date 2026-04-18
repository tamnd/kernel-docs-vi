.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/intro.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============
Giới thiệu
============

Tài liệu này bao gồm Nhân Linux cho Không gian người dùng API được video sử dụng
và các thiết bị phát sóng vô tuyến, bao gồm máy quay video, analog và kỹ thuật số
Thẻ thu TV, thẻ thu AM/FM, Đài phát thanh được xác định bằng phần mềm (SDR),
thiết bị thu và phát trực tuyến, thiết bị codec và bộ điều khiển từ xa.

Phần cứng thiết bị đa phương tiện điển hình được hiển thị tại ZZ0000ZZ.

.. _typical_media_device:

.. kernel-figure:: typical_media_device.svg
    :alt:   typical_media_device.svg
    :align: center

    Typical Media Device

Cơ sở hạ tầng truyền thông API được thiết kế để điều khiển các thiết bị như vậy. Đó là
chia thành năm phần.

1. ZZ0000ZZ bao gồm radio, quay video và đầu ra,
   máy ảnh, thiết bị TV analog và codec.

2. ZZ0000ZZ bao gồm API được sử dụng cho TV kỹ thuật số và
   Tiếp nhận Internet thông qua một trong một số tiêu chuẩn truyền hình kỹ thuật số. Trong khi đó là
   được gọi là DVB API, trên thực tế nó bao gồm một số tiêu chuẩn video khác nhau
   bao gồm DVB-T/T2, DVB-S/S2, DVB-C, ATSC, ISDB-T, ISDB-S, DTMB, v.v.
   danh sách đầy đủ các tiêu chuẩn được hỗ trợ có thể được tìm thấy tại
   ZZ0001ZZ.

3. ZZ0000ZZ bao gồm Bộ điều khiển từ xa API.

4. ZZ0000ZZ bao gồm Bộ điều khiển phương tiện API.

5. ZZ0000ZZ bao gồm CEC (Điều khiển Điện tử Tiêu dùng) API.

Cũng cần lưu ý rằng thiết bị đa phương tiện cũng có thể có các thành phần âm thanh, như
bộ trộn, thu PCM, phát lại PCM, v.v., được điều khiển thông qua ALSA API.  cho
thông tin bổ sung và để biết mã phát triển mới nhất, hãy xem:
ZZ0000ZZ.  Để thảo luận về những cải tiến,
báo cáo sự cố, gửi trình điều khiển mới, v.v., vui lòng gửi thư đến: ZZ0001ZZ.