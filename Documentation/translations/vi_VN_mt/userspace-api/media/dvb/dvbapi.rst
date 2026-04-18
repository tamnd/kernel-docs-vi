.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/dvbapi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

.. _dvbapi:

#########################
Part II - Tivi kỹ thuật số API
########################

.. note::

   This API is also known as Linux **DVB API**.

   It it was originally written to support the European digital TV
   standard (DVB), and later extended to support all digital TV standards.

   In order to avoid confusion, within this document, it was opted to refer to
   it, and to associated hardware as **Digital TV**.

   The word **DVB** is reserved to be used for:

     - the Digital TV API version
       (e. g. DVB API version 3 or DVB API version 5);
     - digital TV data types (enums, structs, defines, etc);
     - digital TV device nodes (``/dev/dvb/...``);
     - the European DVB standard.

ZZ0000ZZ

.. toctree::
    :caption: Table of Contents
    :maxdepth: 5
    :numbered:

    intro
    frontend
    demux
    ca
    net
    legacy_dvb_apis
    examples
    headers


**********************
Sửa đổi và Bản quyền
**********************

tác giả:

- J. K. Metzler, Ralph <rjkm@metzlerbros.de>

- Tác giả gốc của tài liệu Digital TV API.

- O. C. Metzler, Marcus <rjkm@metzlerbros.de>

- Tác giả gốc của tài liệu Digital TV API.

- Carvalho Chehab, Mauro <mchehab+samsung@kernel.org>

- Đã chuyển tài liệu sang Docbook XML, bổ sung DVBv5 API, sửa các lỗ hổng tài liệu.

ZZ0000ZZ ZZ0001ZZ 2002-2003: Hội tụ GmbH

ZZ0000ZZ ZZ0001ZZ 2009-2017 : Mauro Carvalho Chehab

****************
Lịch sử sửa đổi
****************

:sửa đổi: 2.2.0 / 2017-09-01 (ZZ0000ZZ)

Hầu hết các khoảng trống giữa tài liệu uAPI và việc triển khai Kernel
đã được sửa cho API không cũ.

:sửa đổi: 2.1.0 / 29-05-2015 (ZZ0000ZZ)

Cải tiến và dọn dẹp DocBook, để ghi lại các cuộc gọi hệ thống
theo cách chuẩn hơn và cung cấp thêm mô tả về hiện tại
Tivi kỹ thuật số API.

:sửa đổi: 2.0.4 / 2011-05-06 (ZZ0000ZZ)

Thêm thông tin thêm về DVBv5 API, mô tả rõ hơn về frontend
GET/SET đạo cụ ioctl's.


:sửa đổi: 2.0.3 / 2010-07-03 (ZZ0000ZZ)

Thêm một số cờ khả năng giao diện người dùng, có trên kernel nhưng bị thiếu ở
các thông số kỹ thuật.


:sửa đổi: 2.0.2 / 2009-10-25 (ZZ0000ZZ)

tài liệu FE_SET_FRONTEND_TUNE_MODE và
FE_DISHETWORK_SEND_LEGACY_CMD ioctls.


:sửa đổi: 2.0.1 / 2009-09-16 (ZZ0000ZZ)

Đã thêm bài kiểm tra ISDB-T do Patrick Boettcher viết ban đầu


:sửa đổi: 2.0.0 / 2009-09-06 (ZZ0000ZZ)

Chuyển đổi từ LaTex sang DocBook XML. Nội dung cũng giống như
phiên bản LaTex gốc.


:sửa đổi: 1.0.0 / 2003-07-24 (ZZ0000ZZ)

Bản sửa đổi ban đầu trên LaTEX.