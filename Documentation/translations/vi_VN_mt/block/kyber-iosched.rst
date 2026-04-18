.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/block/kyber-iosched.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================================
Điều chỉnh lịch trình I/O của Kyber
===================================

Hai điều chỉnh duy nhất cho bộ lập lịch Kyber là độ trễ mục tiêu cho
đọc và ghi đồng bộ. Kyber sẽ điều chỉnh các yêu cầu để đáp ứng
những độ trễ mục tiêu này.

đọc_lat_nsec
-------------
Độ trễ mục tiêu cho số lần đọc (tính bằng nano giây).

viết_lat_nsec
--------------
Độ trễ mục tiêu để ghi đồng bộ (tính bằng nano giây).
