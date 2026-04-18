.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/cards/via82xx-mixer.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==============
Máy trộn VIA82xx
=============

Trên nhiều bo mạch VIA82xx, điều khiển bộ trộn ZZ0000ZZ không hoạt động.
Đặt nó thành ZZ0001ZZ trên các bảng như vậy sẽ khiến quá trình ghi bị treo hoặc không thành công
với EIO (lỗi đầu vào/đầu ra) thông qua mô phỏng OSS.  Điều khiển này nên được để lại
tại ZZ0002ZZ cho những thẻ như vậy.
