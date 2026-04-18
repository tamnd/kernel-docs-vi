.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/dmx-qbuf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.dmx

.. _DMX_QBUF:

*************************
ioctl DMX_QBUF, DMX_DQBUF
*************************

Tên
====

DMX_QBUF - DMX_DQBUF - Trao đổi bộ đệm với trình điều khiển

.. warning:: this API is still experimental

Tóm tắt
========

.. c:macro:: DMX_QBUF

ZZ0000ZZ

.. c:macro:: DMX_DQBUF

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Các ứng dụng gọi ZZ0000ZZ ioctl để xếp hàng trống
Bộ đệm (chụp) hoặc đầy (đầu ra) trong hàng đợi đến của trình điều khiển.
Ngữ nghĩa phụ thuộc vào phương pháp I/O đã chọn.

Để xếp hàng các ứng dụng bộ đệm, hãy đặt trường ZZ0004ZZ. chỉ mục hợp lệ
các số nằm trong khoảng từ 0 đến số lượng bộ đệm được phân bổ bằng
ZZ0000ZZ (cấu trúc ZZ0001ZZ ZZ0005ZZ) trừ
một. Nội dung của struct ZZ0002ZZ được trả về
bởi ZZ0003ZZ ioctl cũng sẽ làm được.

Khi ZZ0000ZZ được gọi với một con trỏ tới cấu trúc này, nó sẽ khóa
các trang bộ nhớ của bộ đệm trong bộ nhớ vật lý nên chúng không thể hoán đổi được
ra đĩa. Bộ đệm vẫn bị khóa cho đến khi được xếp hàng đợi, cho đến khi
thiết bị đã đóng.

Các ứng dụng gọi ZZ0001ZZ ioctl để loại bỏ một
(chụp) bộ đệm từ hàng đợi gửi đi của trình điều khiển.
Họ chỉ đặt trường ZZ0002ZZ có ID bộ đệm sẽ được xếp hàng đợi.
Khi ZZ0003ZZ được gọi bằng một con trỏ tới cấu trúc ZZ0000ZZ,
trình điều khiển điền vào các trường còn lại hoặc trả về mã lỗi.

Theo mặc định, ZZ0001ZZ sẽ chặn khi không có bộ đệm ở đầu ra
xếp hàng. Khi cờ ZZ0002ZZ được trao cho
Hàm ZZ0000ZZ, trả về ZZ0003ZZ
ngay lập tức kèm theo mã lỗi ZZ0004ZZ khi không có bộ đệm.

Cấu trúc ZZ0000ZZ được chỉ định trong
ZZ0001ZZ.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EAGAIN
    I/O không chặn đã được chọn bằng ZZ0000ZZ và không
    bộ đệm nằm trong hàng đợi gửi đi.

EINVAL
    ZZ0000ZZ nằm ngoài giới hạn hoặc chưa có bộ đệm nào được phân bổ.

EIO
    ZZ0000ZZ không thành công do lỗi nội bộ. Cũng có thể chỉ ra
    các sự cố tạm thời như mất tín hiệu hoặc lỗi CRC.