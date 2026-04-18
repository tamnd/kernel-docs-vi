.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/input/devices/iforce-protocol.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
Giao thức Iforce
===============

:Tác giả: Johann Deneux <johann.deneux@gmail.com>

Trang chủ tại ZZ0000ZZ

:Bổ sung: của Vojtech Pavlik.


Giới thiệu
============

Tài liệu này mô tả những gì tôi đã khám phá được về giao thức được sử dụng để
chỉ định hiệu ứng lực cho thiết bị I-Force 2.0.  Không có thông tin nào trong số này đến
từ Đắm chìm. Đó là lý do tại sao bạn không nên tin vào những gì được viết trong này
tài liệu. Tài liệu này nhằm mục đích giúp hiểu được giao thức.
Đây không phải là một tài liệu tham khảo. Bình luận và sửa chữa đều được chào đón.  Để liên hệ với tôi,
gửi email tới: johann.deneux@gmail.com

.. warning::

    I shall not be held responsible for any damage or harm caused if you try to
    send data to your I-Force device based on what you read in this document.

Ghi chú sơ bộ
=================

Tất cả các giá trị đều ở dạng thập lục phân với mã hóa big-endian (msb ở bên trái). Hãy coi chừng,
các giá trị bên trong các gói được mã hóa bằng little-endian.  Byte có vai trò
chưa biết được đánh dấu ???  Thông tin cần kiểm tra sâu hơn được đánh dấu (?)

Dạng chung của gói
------------------------

Đây là giao diện của các gói khi thiết bị sử dụng RS232 để liên lạc.

== == === ==== ==
2B OP LEN DATA CS
== == === ==== ==

CS là tổng kiểm tra. Nó bằng với độc quyền hoặc của tất cả các byte.

Khi sử dụng USB:

== ====
OP DATA
== ====

Các trường 2B, LEN và CS đã biến mất, có thể do USB xử lý
khung và hỏng dữ liệu được xử lý hoặc không đáng kể.

Đầu tiên mình mô tả các hiệu ứng được thiết bị gửi tới máy tính

Trạng thái đầu vào của thiết bị
==================

Gói này được sử dụng để cho biết trạng thái của mỗi nút và giá trị của mỗi nút.
trục::

OP= 01 cho cần điều khiển, 03 cho bánh xe
    LEN= Khác nhau tùy theo thiết bị
    00 Trục X lsb
    01 msb trục X
    02 trục Y lsb, hoặc bàn đạp ga cho bánh xe
    03 msb trục Y, hoặc bàn đạp phanh cho bánh xe
    04 Van tiết lưu
    05 Nút
    06 4 bit dưới: Nút
       4 bit trên: Mũ
    07 bánh lái

Trạng thái hiệu ứng thiết bị
=====================

::

OP= 02
    LEN= Khác nhau
    00 ? Bit 1 (Giá trị 2) là giá trị của switch deadman
    01 Bit 8 được đặt nếu hiệu ứng đang phát. Các bit từ 0 đến 7 là id hiệu ứng.
    02 ??
    03 Địa chỉ của khối tham số đã thay đổi (lsb)
    04 Địa chỉ của khối tham số đã thay đổi (msb)
    05 Địa chỉ của khối tham số thứ hai đã thay đổi (lsb)
    ... depending on the number of parameter blocks updated

Hiệu ứng lực
------------

::

OP= 01
    LEN= 0e
    00 Kênh (khi phát nhiều hiệu ứng cùng lúc, mỗi hiệu ứng phải
                được chỉ định một kênh)
    01 dạng sóng
	    Giá trị 00 Hằng số
	    Quảng trường Val 20
	    Tam giác Val 21
	    Val 22 sin
	    Val 23 răng cưa lên
	    Val 24 Răng cưa xuống
	    Val 40 Lò xo (Lực = f(pos))
	    Val 41 Ma sát (Lực = f(vận tốc)) và Quán tính
	           (Lực = f(gia tốc))


02 Trục bị ảnh hưởng và kích hoạt
	    Bit 4-7: Val 2 = hiệu ứng dọc theo một trục. Byte 05 chỉ hướng
		    Giá trị 4 = chỉ trục X. Byte 05 phải chứa 5a
		    Giá trị 8 = chỉ trục Y. Byte 05 phải chứa b4
		    Val c = trục X và Y. Byte 05 phải chứa 60
	    Bit 0-3: Val 0 = Không kích hoạt
		    Val x+1 = Nút x kích hoạt hiệu ứng
	    Khi toàn bộ byte bằng 0, hãy hủy kích hoạt đã đặt trước đó

03-04 Thời lượng hiệu ứng (mã hóa endian nhỏ, tính bằng mili giây)

05 Hướng tác động, nếu có. Ngược lại, xem 02 để biết giá trị được gán.

06-07 Thời gian tối thiểu giữa các lần kích hoạt.

08-09 Địa chỉ của các tham số tuần hoàn hoặc cường độ
    0a-0b Địa chỉ của các tham số tấn công và mờ dần, hoặc ffff nếu không có.
    ZZ0000ZZ
    08-09 Địa chỉ của các tham số tương tác cho trục X,
          hoặc ffff nếu không áp dụng
    0a-0b Địa chỉ của các tham số tương tác cho trục Y,
	  hoặc ffff nếu không áp dụng

0c-0d Độ trễ trước khi thực hiện hiệu ứng (mã hóa endian nhỏ, tính bằng mili giây)


Thông số dựa trên thời gian
---------------------

Tấn công và mờ dần
^^^^^^^^^^^^^^^

::

OP= 02
    LEN= 08
    00-01 Địa chỉ nơi lưu trữ các thông số
    02-03 Thời lượng tấn công (mã hóa endian nhỏ, tính bằng ms)
    04 Cấp độ khi kết thúc cuộc tấn công. Byte đã ký.
    05-06 Thời gian mờ dần.
    07 Cấp độ ở cuối độ mờ.

Kích cỡ
^^^^^^^^^

::

OP= 03
    LEN= 03
    00-01 Địa chỉ
    02 cấp độ. Byte đã ký.

Tính định kỳ
^^^^^^^^^^^

::

OP= 04
    LEN= 07
    00-01 Địa chỉ
    02 độ lớn. Byte đã ký.
    03 Bù đắp. Byte đã ký.
    04 Giai Đoạn. Giá trị 00 = 0 độ, Giá trị 40 = 90 độ.
    Khoảng thời gian 05-06 (mã hóa endian nhỏ, tính bằng mili giây)

Thông số tương tác
----------------------

::

OP= 05
    LEN= 0a
    00-01 Địa chỉ
    02 Hệ số dương
    03 Hệ số âm
    Độ lệch 04+05 (giữa)
    06+07 Dải chết (Val 01F4 = 5000 (thập phân))
    08 Độ bão hòa dương (Val 0a = 1000 (thập phân) Val 64 = 10000 (thập phân))
    09 Độ bão hòa âm

Việc mã hóa ở đây hơi buồn cười: Đối với các coeff, đây là các giá trị đã ký. các
giá trị tối đa là 64 (100 thập phân), tối thiểu là 9c.
Đối với phần bù, giá trị tối thiểu là FE0C, giá trị tối đa là 01F4.
Đối với dải chết, giá trị tối thiểu là 0, tối đa là 03E8.

Điều khiển
--------

::

OP= 41
    LEN= 03
    00 kênh
    01 Bắt đầu/Dừng
	    Giá trị 00: Dừng lại
	    Val 01: Bắt đầu và chơi một lần.
	    Giá trị 41: Bắt đầu và phát n lần (Xem byte 02 bên dưới)
    02 Số lần lặp n.

Ban đầu
----


Tính năng truy vấn
^^^^^^^^^^^^^^^^^
::

OP= ff
    Lệnh truy vấn. Độ dài thay đổi tùy theo loại truy vấn.
    Định dạng chung của gói này là:
    ff 01 QUERY [INDEX] CHECKSUM
    các câu trả lời có dạng giống nhau:
    FF LEN QUERY VALUE_QUERIED CHECKSUM2
    trong đó LEN = 1 + chiều dài (VALUE_QUERIED)

Kích thước ram truy vấn
~~~~~~~~~~~~~~

::

QUERY = 42 (kích thước 'B'uffer)

Thiết bị sẽ trả lời với cùng một gói cộng với hai byte bổ sung
chứa kích thước của bộ nhớ:
ff 03 42 03 e8 CS có nghĩa là thiết bị có sẵn 1000 byte ram.

Truy vấn số hiệu ứng
~~~~~~~~~~~~~~~~~~~~~~~

::

QUERY = 4e ('Số lượng hiệu ứng)

Thiết bị sẽ phản hồi bằng cách gửi số lượng hiệu ứng có thể phát
cùng một lúc (một byte)
ff 02 4e 14 CS sẽ đại diện cho 20 hiệu ứng.

Id của nhà cung cấp
~~~~~~~~~~~

::

QUERY = 4d ('Nhà sản xuất)

Truy vấn nhà cung cấp'id (2 byte)

Mã sản phẩm
~~~~~~~~~~

::

QUERY = 50 ('Sản phẩm')

Truy vấn id sản phẩm (2 byte)

Mở thiết bị
~~~~~~~~~~~

::

QUERY = 4f ('O'pen)

Không có dữ liệu được trả lại.

Đóng thiết bị
~~~~~~~~~~~~

::

QUERY = 43 ('C')thua

Không có dữ liệu được trả lại.

Hiệu ứng truy vấn
~~~~~~~~~~~~

::

QUERY = 45 ('E')

Gửi loại hiệu ứng.
Trả về khác 0 nếu được hỗ trợ (2 byte)

Phiên bản phần mềm
~~~~~~~~~~~~~~~~

::

QUERY = 56 ('V'ersion)

Gửi lại 3 byte - chính, phụ, phụ

Khởi tạo thiết bị
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Đặt điều khiển
~~~~~~~~~~~

.. note::
    Device dependent, can be different on different models!

::

OP= 40 <idx> <val> [<val>]
    LEN= 2 hoặc 3
    00 IDx
       Idx 00 Đặt vùng chết (0..2048)
       Idx 01 Bỏ qua cảm biến Deadman (0..1)
       Idx 02 Kích hoạt cơ quan giám sát comm (0..1)
       Idx 03 Cài đặt độ bền của lò xo (0..100)
       Idx 04 Kích hoạt hoặc vô hiệu hóa lò xo (0/1)
       Idx 05 Đặt ngưỡng bão hòa trục (0..2048)

Đặt trạng thái hiệu ứng
~~~~~~~~~~~~~~~~

::

OP= 42 <giá trị>
    LEN= 1
    00 Bang
       Bit 3 Tạm dừng phản hồi lực
       Bit 2 Kích hoạt phản hồi lực
       Bit 0 Dừng tất cả các hiệu ứng

Đặt tổng thể
~~~~~~~~~~~

::

OP= 43 <giá trị>
    LEN= 1
    00 Tăng
       Giá trị 00 = 0%
       Giá trị 40 = 50%
       Giá trị 80 = 100%

Bộ nhớ tham số
----------------

Mỗi thiết bị có một lượng bộ nhớ nhất định để lưu trữ các thông số của hiệu ứng.
Số lượng RAM có thể khác nhau, tôi gặp các giá trị từ 200 đến 1000 byte. Dưới đây
là dung lượng bộ nhớ rõ ràng cần thiết cho mỗi bộ tham số:

- thời gian : 0c
 - độ lớn: 02
 - tấn công và mờ dần: 0e
 - tương tác : 08

Phụ lục: Nghiên cứu quy trình như thế nào?
====================================

1. Tạo hiệu ứng bằng trình chỉnh sửa lực được cung cấp cùng với DirectX SDK hoặc
sử dụng Immersion Studio (có sẵn miễn phí trên trang web của họ trong phần dành cho nhà phát triển:
www.immersion.com)
2. Bắt đầu theo dõi mềm RS232 hoặc USB (tùy thuộc vào nơi bạn kết nối
cần điều khiển/bánh xe). Tôi đã sử dụng ComPortSpy từ fCoder (phiên bản alpha!)
3. Phát hiệu ứng và xem điều gì xảy ra trên màn hình gián điệp.

Đôi lời về ComPortSpy:
Thoạt nhìn, phần mềm này có vẻ, ừm... có lỗi. Trên thực tế, dữ liệu xuất hiện với một
độ trễ vài giây. Cá nhân tôi khởi động lại nó mỗi khi tôi phát một hiệu ứng.
Hãy nhớ rằng nó miễn phí (như bia miễn phí) và alpha!

URLS
====

Kiểm tra ZZ0000ZZ để biết Immersion Studio,
và ZZ0001ZZ cho ComPortSpy.


I-Force là thương hiệu của Immersion Corp.
