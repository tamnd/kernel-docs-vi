.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/rc/lirc-write.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: RC

.. _lirc-write:

*************
LIRC viết()
*************

Tên
====

lirc-write - Ghi vào thiết bị LIRC

Tóm tắt
========

.. code-block:: c

    #include <unistd.h>

.. c:function:: ssize_t write( int fd, void *buf, size_t count )

Đối số
=========

ZZ0000ZZ
    Bộ mô tả tệp được trả về bởi ZZ0001ZZ.

ZZ0000ZZ
    Bộ đệm chứa dữ liệu cần ghi

ZZ0000ZZ
    Số byte tại bộ đệm

Sự miêu tả
===========

ZZ0000ZZ ghi tối đa ZZ0001ZZ byte vào thiết bị
được tham chiếu bởi bộ mô tả tệp ZZ0002ZZ từ bộ đệm bắt đầu từ
ZZ0003ZZ.

Định dạng chính xác của dữ liệu phụ thuộc vào chế độ của trình điều khiển, hãy sử dụng
ZZ0000ZZ để nhận các chế độ được hỗ trợ và sử dụng
ZZ0001ZZ đặt chế độ.

Khi ở chế độ ZZ0000ZZ, dữ liệu được ghi vào
chardev là một chuỗi xung/không gian của các giá trị nguyên. Xung và không gian
chỉ được đánh dấu ngầm bởi vị trí của họ. Dữ liệu phải bắt đầu và kết thúc
do đó, với một xung, dữ liệu phải luôn bao gồm số lượng không đồng đều
mẫu. Khối chức năng ghi cho đến khi dữ liệu được truyền đi
bởi phần cứng. Nếu nhiều dữ liệu được cung cấp hơn mức phần cứng có thể gửi,
trình điều khiển trả về ZZ0001ZZ.

Khi ở chế độ ZZ0000ZZ, một
ZZ0003ZZ phải được ghi vào chardev tại một thời điểm, nếu không
ZZ0004ZZ được trả lại. Đặt scancode mong muốn trong thành viên ZZ0005ZZ,
và ZZ0001ZZ trong
ZZ0002ZZ: thành viên. Tất cả các thành viên khác phải
được đặt thành 0, nếu không ZZ0006ZZ sẽ được trả về. Nếu không có bộ mã hóa giao thức
đối với giao thức hoặc scancode không hợp lệ đối với giao thức đã chỉ định,
ZZ0007ZZ được trả lại. Khối chức năng ghi cho đến khi scancode
được truyền đi bởi phần cứng.

Giá trị trả về
============

Khi thành công, số byte đã ghi sẽ được trả về. Đó không phải là lỗi nếu
con số này nhỏ hơn số byte được yêu cầu hoặc số lượng
dữ liệu cần thiết cho một khung hình.  Nếu có lỗi, -1 được trả về và ZZ0001ZZ
biến được đặt phù hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.