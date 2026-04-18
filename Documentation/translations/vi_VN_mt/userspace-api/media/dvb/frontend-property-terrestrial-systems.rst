.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/frontend-property-terrestrial-systems.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _frontend-property-terrestrial-systems:

*******************************************************
Thuộc tính sử dụng trên hệ thống phân phối trên mặt đất
*******************************************************


.. _dvbt-params:

Hệ thống phân phối DVB-T
=====================

Các tham số sau hợp lệ cho DVB-T:

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

Ngoài ra, ZZ0000ZZ
cũng có hiệu lực.


.. _dvbt2-params:

Hệ thống phân phối DVB-T2
======================

Hỗ trợ DVB-T2 hiện đang trong giai đoạn phát triển ban đầu, vì vậy
mong đợi rằng phần này có thể phát triển và trở nên chi tiết hơn theo thời gian.

Các tham số sau hợp lệ cho DVB-T2:

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

Ngoài ra, ZZ0000ZZ
cũng có hiệu lực.


.. _isdbt:

Hệ thống phân phối ISDB-T
======================

Tiện ích mở rộng ISDB-T/ISDB-Tsb API này sẽ phản ánh tất cả thông tin cần thiết
để điều chỉnh bất kỳ phần cứng ISDB-T/ISDB-Tsb nào. Tất nhiên có thể một số
các thiết bị rất phức tạp sẽ không cần các thông số nhất định để điều chỉnh.

Thông tin được cung cấp ở đây sẽ giúp người viết ứng dụng biết cách
để xử lý phần cứng ISDB-T và ISDB-Tsb bằng Linux Digital TV API.

Các chi tiết được đưa ra ở đây về ISDB-T và ISDB-Tsb là vừa đủ để
về cơ bản hiển thị sự phụ thuộc giữa các giá trị tham số cần thiết, nhưng
chắc chắn một số thông tin bị bỏ sót. Để biết thêm thông tin chi tiết xem
các tài liệu sau:

ARIB STD-B31 - "Hệ thống truyền dẫn cho truyền hình kỹ thuật số mặt đất
phát thanh” và

ARIB TR-B14 - "Hướng dẫn vận hành cho truyền hình kỹ thuật số mặt đất
Phát sóng".

Để hiểu các thông số cụ thể của ISDB, người ta phải có
một số kiến thức về cấu trúc kênh trong ISDB-T và ISDB-Tsb. tức là nó có
để người đọc biết rằng kênh ISDB-T bao gồm 13
các phân đoạn, nó có thể có tối đa 3 lớp chia sẻ các phân đoạn đó và
những thứ như thế.

Các tham số sau hợp lệ cho ISDB-T:

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

Ngoài ra, ZZ0000ZZ
cũng có hiệu lực.


.. _atsc-params:

Hệ thống phân phối ATSC
====================

Các tham số sau hợp lệ cho ATSC:

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

Ngoài ra, ZZ0000ZZ
cũng có hiệu lực.


.. _atscmh-params:

Hệ thống phân phối ATSC-MH
=======================

Các tham số sau hợp lệ cho ATSC-MH:

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

Ngoài ra, ZZ0000ZZ
cũng có hiệu lực.


.. _dtmb-params:

Hệ thống phân phối DTMB
====================

Các tham số sau hợp lệ cho DTMB:

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

Ngoài ra, ZZ0000ZZ
cũng có hiệu lực.