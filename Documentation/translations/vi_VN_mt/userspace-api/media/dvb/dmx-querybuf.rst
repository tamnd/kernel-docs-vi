.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/dmx-querybuf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.dmx

.. _DMX_QUERYBUF:

*******************
ioctl DMX_QUERYBUF
*******************

Tên
====

DMX_QUERYBUF - Truy vấn trạng thái của bộ đệm

.. warning:: this API is still experimental

Tóm tắt
========

.. c:macro:: DMX_QUERYBUF

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Ioctl này là một phần của phương thức I/O truyền phát mmap. Nó có thể
được sử dụng để truy vấn trạng thái của bộ đệm bất cứ lúc nào sau khi bộ đệm có
đã được phân bổ với ZZ0000ZZ ioctl.

Các ứng dụng đặt trường ZZ0002ZZ. Số chỉ mục hợp lệ nằm trong khoảng từ 0
với số lượng bộ đệm được phân bổ với ZZ0000ZZ
(struct ZZ0001ZZ ZZ0003ZZ) trừ một.

Sau khi gọi ZZ0000ZZ bằng một con trỏ tới cấu trúc này,
trình điều khiển trả về mã lỗi hoặc điền vào phần còn lại của cấu trúc.

Nếu thành công, ZZ0000ZZ sẽ chứa phần bù của bộ đệm từ
bắt đầu của bộ nhớ thiết bị, trường ZZ0001ZZ kích thước của nó và
ZZ0002ZZ số byte bị chiếm bởi dữ liệu trong bộ đệm (tải trọng).

Giá trị trả về
============

Khi trả về thành công 0, ZZ0000ZZ sẽ chứa phần bù của
bộ đệm từ khi bắt đầu bộ nhớ thiết bị, trường ZZ0001ZZ có kích thước tương ứng,
và ZZ0002ZZ số byte bị chiếm bởi dữ liệu trong bộ đệm
(tải trọng).

Nếu có lỗi, nó trả về -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    ZZ0000ZZ nằm ngoài giới hạn.