.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/doc-guide/parse-headers.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Bao gồm các tệp tiêu đề uAPI
==============================

Đôi khi, việc đưa các tệp tiêu đề và mã ví dụ C vào
để mô tả không gian người dùng API và tạo ra các tham chiếu chéo
giữa mã và tài liệu. Thêm tài liệu tham khảo chéo cho
Các tệp API trong không gian người dùng có một lợi thế bổ sung: Sphinx sẽ tạo ra các cảnh báo
nếu không tìm thấy biểu tượng trong tài liệu. Điều đó giúp giữ
Tài liệu uAPI đồng bộ với các thay đổi của Kernel.
ZZ0000ZZ cung cấp một cách để tạo ra những
tham khảo chéo. Nó phải được gọi thông qua Makefile, trong khi xây dựng
tài liệu. Vui lòng xem ZZ0001ZZ để biết ví dụ
về cách sử dụng nó bên trong cây Kernel.

.. _parse_headers:

công cụ/docs/parse_headers.py
^^^^^^^^^^^^^^^^^^^^^^^^^^^

NAME
****

pars_headers.py - phân tích tệp C, để xác định các hàm, cấu trúc,
enums và định nghĩa cũng như tạo các tham chiếu chéo tới sách Sphinx.

USAGE
*****

phân tích cú pháp-headers.py [-h] [-d] [-t] ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ

SYNOPSIS
********

Chuyển đổi tệp tiêu đề hoặc tệp nguồn C ZZ0000ZZ thành Văn bản được cấu trúc lại
được bao gồm thông qua khối ..parsed-literal với các tham chiếu chéo cho
các tệp tài liệu mô tả API. Nó chấp nhận một tùy chọn
Tệp ZZ0001ZZ để mô tả những phần tử nào sẽ bị bỏ qua hoặc
được trỏ đến một loại/tên tham chiếu không mặc định.

Đầu ra được ghi tại ZZ0000ZZ.

Nó có khả năng xác định ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ
và enum ZZ0004ZZ, tạo tham chiếu chéo cho tất cả chúng.

Nó cũng có khả năng phân biệt ZZ0000ZZ được sử dụng để chỉ định
Các macro dành riêng cho Linux được sử dụng để xác định ZZ0001ZZ.

ZZ0000ZZ tùy chọn chứa một bộ quy tắc như::

bỏ qua ioctl VIDIOC_ENUM_FMT
    thay thế ioctl VIDIOC_DQBUF vidioc_qbuf
    thay thế xác định V4L2_EVENT_MD_FL_HAVE_FRAME_SEQ ZZ0000ZZ

POSITIONAL ARGUMENTS
********************

ZZ0000ZZ
      Nhập tập tin C

ZZ0000ZZ
      Xuất ra tệp RST

ZZ0000ZZ
      Tệp ngoại lệ (tùy chọn)

OPTIONS
*******

ZZ0000ZZ, ZZ0001ZZ
      hiển thị thông báo trợ giúp và thoát
  ZZ0002ZZ, ZZ0003ZZ
      Tăng mức độ gỡ lỗi. Có thể sử dụng nhiều lần
  ZZ0004ZZ, ZZ0005ZZ
      thay vì một khối bằng chữ, xuất ra bảng TOC ở tệp RST


DESCRIPTION
***********

Tạo phiên bản phong phú của tệp tiêu đề Kernel với các liên kết chéo
tới từng loại cấu trúc dữ liệu C, từ ZZ0000ZZ, định dạng nó bằng
ký hiệu reStructuredText, nguyên trạng hoặc dưới dạng mục lục.

Nó chấp nhận một ZZ0000ZZ tùy chọn mô tả những phần tử nào sẽ có
bị bỏ qua hoặc được trỏ đến một tham chiếu không mặc định và tùy chọn
xác định không gian tên C sẽ được sử dụng.

Nó nhằm mục đích cho phép có tài liệu toàn diện hơn, trong đó
Tiêu đề uAPI sẽ tạo liên kết tham chiếu chéo tới mã.

Đầu ra được ghi tại ZZ0000ZZ.

ZZ0000ZZ có thể chứa ba loại câu lệnh:
ZZ0001ZZ, ZZ0002ZZ và ZZ0003ZZ.

Theo mặc định, nó tạo quy tắc cho tất cả các ký hiệu và định nghĩa, nhưng nó cũng
cho phép phân tích một tập tin ngoại lệ. Tệp như vậy chứa một bộ quy tắc
sử dụng cú pháp dưới đây:

1. Bỏ qua các quy tắc:

bỏ qua ZZ0000ZZ ZZ0001ZZ

Loại bỏ biểu tượng khỏi việc tạo tham chiếu.

2. Thay thế quy tắc:

thay thế ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ

Thay thế ZZ0000ZZ bằng ZZ0001ZZ.
    ZZ0002ZZ có thể là:

- Tên ký hiệu đơn giản;
    - Một tài liệu tham khảo Sphinx đầy đủ.

3. Quy tắc không gian tên

không gian tên ZZ0000ZZ

Đặt C ZZ0000ZZ được sử dụng trong quá trình tạo tham chiếu chéo. có thể
    bị ghi đè bởi các quy tắc thay thế.

Khi bỏ qua và thay thế các quy tắc, ZZ0000ZZ có thể:

- ioctl:
        để định nghĩa dạng ZZ0000ZZ, ví dụ: định nghĩa ioctl

- xác định:
        cho các định nghĩa khác

- biểu tượng:
        đối với các ký hiệu được xác định trong enums;

- typedef:
        cho typedef;

- enum:
        cho tên của một enum không ẩn danh;

- cấu trúc:
        cho các cấu trúc.


EXAMPLES
********

- Bỏ qua định nghĩa ZZ0000ZZ tại ZZ0001ZZ::

bỏ qua xác định _VIDEODEV2_H

- Trên cấu trúc dữ liệu như thế này enum::

enum foo { BAR1, BAR2, PRIVATE };

Nó sẽ không tạo ra các tham chiếu chéo cho ZZ0000ZZ::

bỏ qua biểu tượng PRIVATE

Ở cùng một cấu trúc, thay vì tạo một tham chiếu chéo cho mỗi ký hiệu,
  làm cho tất cả chúng đều trỏ đến loại ZZ0000ZZ C ::

thay thế ký hiệu BAR1 :c:type:\ZZ0000ZZ
    thay thế ký hiệu BAR2 :c:type:\ZZ0001ZZ


- Sử dụng namespace C ZZ0000ZZ cho tất cả các ký hiệu tại ZZ0001ZZ::

không gian tên MC

BUGS
****


Báo cáo lỗi cho Mauro Carvalho Chehab <mchehab@kernel.org>


COPYRIGHT
*********


Bản quyền (c) 2016, 2025 của Mauro Carvalho Chehab <mchehab+huawei@kernel.org>.

Giấy phép GPLv2: GNU GPL phiên bản 2 <ZZ0000ZZ

Đây là phần mềm miễn phí: bạn có thể tự do thay đổi và phân phối lại nó.
KHÔNG có WARRANTY, trong phạm vi pháp luật cho phép.
