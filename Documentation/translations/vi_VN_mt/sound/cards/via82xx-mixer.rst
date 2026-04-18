.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/cards/via82xx-mixer.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================
Máy trộn VIA82xx
================

Trên nhiều bo mạch VIA82xx, điều khiển bộ trộn ZZ0000ZZ không hoạt động.
Đặt nó thành ZZ0001ZZ trên các bảng như vậy sẽ khiến quá trình ghi bị treo hoặc không thành công
với EIO (lỗi đầu vào/đầu ra) thông qua mô phỏng OSS.  Điều khiển này nên được để lại
tại ZZ0002ZZ cho những thẻ như vậy.
