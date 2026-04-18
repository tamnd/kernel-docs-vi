.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/block/kyber-iosched.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===============================
Điều chỉnh lịch trình I/O của Kyber
============================

Hai điều chỉnh duy nhất cho bộ lập lịch Kyber là độ trễ mục tiêu cho
đọc và ghi đồng bộ. Kyber sẽ điều chỉnh các yêu cầu để đáp ứng
những độ trễ mục tiêu này.

đọc_lat_nsec
-------------
Độ trễ mục tiêu cho số lần đọc (tính bằng nano giây).

viết_lat_nsec
--------------
Độ trễ mục tiêu để ghi đồng bộ (tính bằng nano giây).
