.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/idr.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==============
Phân bổ ID
=============

:Tác giả: Matthew Wilcox

Tổng quan
========

Một vấn đề phổ biến cần giải quyết là phân bổ số nhận dạng (ID); nói chung
những con số nhỏ xác định một sự vật.  Ví dụ bao gồm mô tả tập tin,
ID tiến trình, số nhận dạng gói trong giao thức mạng, thẻ SCSI
và số phiên bản thiết bị.  IDR và IDA cung cấp một mức giá hợp lý
giải pháp cho vấn đề để tránh mọi người tự phát minh ra giải pháp của riêng mình.  IDR
cung cấp khả năng ánh xạ ID tới một con trỏ, trong khi IDA cung cấp
chỉ phân bổ ID và kết quả là tiết kiệm bộ nhớ hơn nhiều.

Giao diện IDR không được dùng nữa; vui lòng sử dụng ZZ0000ZZ
thay vào đó.

Cách sử dụng IDR
=========

Bắt đầu bằng cách khởi tạo IDR, với DEFINE_IDR()
đối với các IDR được phân bổ tĩnh hoặc idr_init() đối với các IDR được phân bổ động
IDR được phân bổ.

Bạn có thể gọi idr_alloc() để phân bổ ID chưa sử dụng.  Tra cứu
con trỏ bạn đã liên kết với ID bằng cách gọi idr_find()
và giải phóng ID bằng cách gọi idr_remove().

Nếu bạn cần thay đổi con trỏ được liên kết với ID, bạn có thể gọi
idr_replace().  Một lý do phổ biến để làm điều này là để dành một
ID bằng cách chuyển con trỏ ZZ0000ZZ tới hàm phân bổ; khởi tạo
đối tượng có ID dành riêng và cuối cùng chèn đối tượng được khởi tạo
vào IDR.

Một số người dùng cần phân bổ ID lớn hơn ZZ0000ZZ.  Cho đến nay tất cả
những người dùng này đã hài lòng với giới hạn ZZ0001ZZ và họ sử dụng
idr_alloc_u32().  Nếu bạn cần ID không vừa với u32,
chúng tôi sẽ làm việc với bạn để giải quyết nhu cầu của bạn.

Nếu bạn cần phân bổ ID tuần tự, bạn có thể sử dụng
idr_alloc_cycle().  IDR trở nên kém hiệu quả hơn khi giao dịch
với ID lớn hơn, vì vậy việc sử dụng chức năng này sẽ tốn một ít chi phí.

Để thực hiện một hành động trên tất cả các con trỏ được IDR sử dụng, bạn có thể
sử dụng idr_for_each() dựa trên cuộc gọi lại hoặc
kiểu lặp idr_for_each_entry().  Bạn có thể cần phải sử dụng
idr_for_each_entry_continue() để tiếp tục lặp lại.  bạn có thể
cũng sử dụng idr_get_next() nếu trình vòng lặp không phù hợp với nhu cầu của bạn.

Khi bạn sử dụng xong IDR, bạn có thể gọi idr_destroy()
để giải phóng bộ nhớ được IDR sử dụng.  Điều này sẽ không giải phóng các đối tượng
được trỏ đến từ IDR; nếu bạn muốn làm điều đó, hãy sử dụng một trong các trình vòng lặp
để làm điều đó.

Bạn có thể sử dụng idr_is_empty() để tìm hiểu xem có bất kỳ
ID hiện được phân bổ.

Nếu bạn cần lấy khóa trong khi phân bổ ID mới từ IDR,
bạn có thể cần phải vượt qua một bộ cờ GFP hạn chế, điều này có thể dẫn đến
đến IDR không thể phân bổ bộ nhớ.  Để giải quyết vấn đề này,
bạn có thể gọi idr_preload() trước khi lấy khóa, sau đó
idr_preload_end() sau khi phân bổ.

.. kernel-doc:: include/linux/idr.h
   :doc: idr sync

Cách sử dụng IDA
=========

.. kernel-doc:: lib/idr.c
   :doc: IDA description

Chức năng và cấu trúc
========================

.. kernel-doc:: include/linux/idr.h
   :functions:
.. kernel-doc:: lib/idr.c
   :functions: