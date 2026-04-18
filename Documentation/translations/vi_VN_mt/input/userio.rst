.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/input/userio.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

=====================
Giao thức userio
===================


:Bản quyền: ZZ0000ZZ 2015 Stephen Chandler Paul <thatslyude@gmail.com>

Được tài trợ bởi Red Hat


Giới thiệu
=============

Mô-đun này nhằm mục đích hỗ trợ cuộc sống của các nhà phát triển trình điều khiển đầu vào
dễ dàng hơn bằng cách cho phép họ thử nghiệm nhiều thiết bị serio khác nhau (chủ yếu là các loại
bàn di chuột được tìm thấy trên máy tính xách tay) mà không cần phải có thiết bị vật lý ở phía trước
của họ. userio thực hiện điều này bằng cách cho phép bất kỳ chương trình không gian người dùng đặc quyền nào
để tương tác trực tiếp với trình điều khiển serio của kernel và điều khiển serio ảo
cổng từ đó.

Tổng quan về cách sử dụng
==============

Để tương tác với mô-đun hạt nhân userio, người ta chỉ cần mở
thiết bị ký tự /dev/userio trong ứng dụng của họ. Các lệnh được gửi đến
mô-đun hạt nhân bằng cách ghi vào thiết bị và mọi dữ liệu nhận được từ serio
trình điều khiển được đọc nguyên trạng từ thiết bị/dev/userio. Tất cả các cấu trúc và
macro bạn cần để tương tác với thiết bị được xác định trong <linux/userio.h> và
<linux/serio.h>.

Cấu trúc lệnh
=================

Cấu trúc được sử dụng để gửi lệnh tới /dev/userio như sau::

cấu trúc userio_cmd {
		__u8 loại;
		__u8 dữ liệu;
	};

ZZ0000ZZ mô tả loại lệnh đang được gửi. Đây có thể là bất kỳ ai
của macro USERIO_CMD được xác định trong <linux/userio.h>. ZZ0001ZZ là đối số
điều đó đi cùng với lệnh. Trong trường hợp lệnh không có
đối số, trường này có thể được giữ nguyên và sẽ bị kernel bỏ qua.
Mỗi lệnh phải được gửi bằng cách viết cấu trúc trực tiếp vào ký tự
thiết bị. Trong trường hợp lệnh bạn gửi không hợp lệ sẽ xảy ra lỗi
được thiết bị ký tự trả về và một lỗi mang tính mô tả hơn sẽ được in ra
vào nhật ký hạt nhân. Mỗi lần chỉ có thể gửi một lệnh, mọi dữ liệu bổ sung
được ghi vào thiết bị ký tự sau lệnh ban đầu sẽ bị bỏ qua.

Để đóng cổng serio ảo, chỉ cần đóng /dev/userio.

Lệnh
========

USERIO_CMD_REGISTER
~~~~~~~~~~~~~~~~~~~

Đăng ký cổng với trình điều khiển serio và bắt đầu truyền dữ liệu trở lại và
ra. Việc đăng ký chỉ có thể được thực hiện khi loại cổng được đặt bằng
USERIO_CMD_SET_PORT_TYPE. Không có lý lẽ.

USERIO_CMD_SET_PORT_TYPE
~~~~~~~~~~~~~~~~~~~~~~~~

Đặt loại cổng mà chúng tôi đang mô phỏng, trong đó ZZ0000ZZ là loại cổng đang được mô phỏng
thiết lập. Có thể là bất kỳ macro nào từ <linux/serio.h>. Ví dụ: SERIO_8042
sẽ đặt loại cổng thành cổng PS/2 bình thường.

USERIO_CMD_SEND_INTERRUPT
~~~~~~~~~~~~~~~~~~~~~~~~~

Gửi một ngắt thông qua cổng serio ảo tới trình điều khiển serio, trong đó
ZZ0000ZZ là dữ liệu ngắt được gửi.

Công cụ không gian người dùng
===============

Các công cụ không gian người dùng userio có thể ghi lại các thiết bị PS/2 bằng cách sử dụng một số
gỡ lỗi thông tin từ i8042 và phát lại các thiết bị trên/dev/userio. các
Bạn có thể tìm thấy phiên bản mới nhất của những công cụ này tại:

ZZ0000ZZ
