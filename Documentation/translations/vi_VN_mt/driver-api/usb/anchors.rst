.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/usb/anchors.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Mỏ neo USB
~~~~~~~~~~~

Mỏ neo là gì?
===============

Trình điều khiển USB cần hỗ trợ một số lệnh gọi lại yêu cầu
trình điều khiển để dừng tất cả IO trên một giao diện. Để làm như vậy, một
người lái xe phải theo dõi các URB mà nó đã gửi
để biết họ đã hoàn thành hoặc gọi usb_kill_urb
cho họ. Mỏ neo là một cấu trúc dữ liệu đảm nhiệm việc
theo dõi các URB và cung cấp các phương pháp để giải quyết
nhiều URB.

Phân bổ và khởi tạo
=============================

Không có API để phân bổ mỏ neo. Nó được khai báo đơn giản
dưới dạng cấu trúc usb_anchor. ZZ0000ZZ phải được gọi tới
khởi tạo cấu trúc dữ liệu.

Phân bổ
============

Khi nó không còn URB nào được liên kết với nó nữa, mỏ neo có thể được
được giải phóng bằng các hoạt động quản lý bộ nhớ thông thường.

Sự liên kết và phân tách URB với các điểm neo
===================================================

Việc liên kết các URB với một điểm neo được thực hiện bằng một lệnh rõ ràng
gọi tới ZZ0000ZZ. Sự liên kết được duy trì cho đến khi
URB được hoàn thành bằng cách hoàn thành (thành công). Như vậy sự phân ly
là tự động. Một chức năng được cung cấp để buộc phải kết thúc (giết)
tất cả các URB được liên kết với một mỏ neo.
Hơn nữa, việc phân tách có thể được thực hiện với ZZ0001ZZ

Hoạt động trên nhiều URB
================================

ZZ0000ZZ
--------------------------------

Hàm này loại bỏ tất cả các URB được liên kết với một điểm neo. các URB
được gọi theo thứ tự thời gian ngược lại mà chúng đã được gửi.
Bằng cách này, không có dữ liệu nào có thể được sắp xếp lại.

ZZ0000ZZ
-----------------------------------

Tất cả các URB của một mỏ neo đều không được neo.

ZZ0000ZZ
---------------------------------------

Hàm này đợi tất cả các URB được liên kết với một điểm neo hoàn tất
hoặc thời gian chờ, tùy điều kiện nào đến trước. Giá trị trả về của nó sẽ cho bạn biết
liệu đã đạt đến thời gian chờ hay chưa.

ZZ0000ZZ
--------------------------

Trả về true nếu không có URB nào được liên kết với một điểm neo. Khóa
là trách nhiệm của người gọi.

ZZ0000ZZ
-----------------------------

Trả về URB được neo lâu đời nhất của một mỏ neo. URB không được neo
và trả lại với một tài liệu tham khảo. Vì bạn có thể trộn URB với một số
các điểm đến trong một mỏ neo, bạn không có gì đảm bảo về trình tự thời gian
URB được gửi lần đầu sẽ được trả lại.
