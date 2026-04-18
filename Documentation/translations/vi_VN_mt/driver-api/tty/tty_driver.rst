.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/tty/tty_driver.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Trình điều khiển TTY và hoạt động của TTY
=============================

.. contents:: :local:

Phân bổ
==========

Điều đầu tiên mà trình điều khiển cần làm là phân bổ struct tty_driver. Cái này
được thực hiện bởi tty_alloc_driver() (hoặc __tty_alloc_driver()). Tiếp theo, mới
cấu trúc được phân bổ chứa đầy thông tin. Xem ZZ0000ZZ tại
ở phần cuối của tài liệu này về những gì thực sự sẽ được điền vào.

Quy trình phân bổ yêu cầu một số thiết bị mà trình điều khiển có thể xử lý tại
nhất và cờ. Cờ là những cờ bắt đầu ZZ0000ZZ được liệt kê và mô tả
trong ZZ0001ZZ bên dưới.

Khi trình điều khiển sắp được giải phóng, tty_driver_kref_put() sẽ được gọi vào đó.
Nó sẽ giảm số lượng tham chiếu và nếu nó đạt đến 0, trình điều khiển sẽ
được giải thoát.

Để tham khảo, cả chức năng phân bổ và giải phóng đều được giải thích ở đây trong
chi tiết:

.. kernel-doc:: include/linux/tty_driver.h
   :identifiers: tty_alloc_driver
.. kernel-doc:: drivers/tty/tty_io.c
   :identifiers: __tty_alloc_driver tty_driver_kref_put

Cờ trình điều khiển TTY
----------------

Ở đây có tài liệu về các cờ được chấp nhận bởi tty_alloc_driver() (hoặc
__tty_alloc_driver()):

.. kernel-doc:: include/linux/tty_driver.h
   :identifiers: tty_driver_flag

----

Sự đăng ký
============

Khi một struct tty_driver được phân bổ và điền vào, nó có thể được đăng ký bằng cách sử dụng
tty_register_driver(). Nên vượt qua ZZ0000ZZ trong
cờ của tty_alloc_driver(). Nếu nó không được thông qua, các thiết bị ZZ0002ZZ cũng
đã đăng ký trong tty_register_driver() và đoạn sau của
thiết bị đăng ký có thể được bỏ qua cho các trình điều khiển như vậy. Tuy nhiên, cấu trúc
Phần tty_port trong ZZ0001ZZ vẫn có liên quan ở đó.

.. kernel-doc:: drivers/tty/tty_io.c
   :identifiers: tty_register_driver tty_unregister_driver

Đăng ký thiết bị
-------------------

Mọi thiết bị TTY phải được hỗ trợ bởi struct tty_port. Thông thường, trình điều khiển TTY
nhúng tty_port vào cấu trúc riêng tư của thiết bị. Thông tin chi tiết hơn về xử lý
tty_port có thể được tìm thấy trong ZZ0000ZZ. Trình điều khiển cũng được khuyến khích sử dụng
Việc đếm tham chiếu của tty_port theo tty_port_get() và tty_port_put(). trận chung kết
put có nhiệm vụ giải phóng tty_port bao gồm cả cấu trúc riêng tư của thiết bị.

Trừ khi ZZ0000ZZ được chuyển dưới dạng cờ cho tty_alloc_driver(),
Trình điều khiển TTY có nhiệm vụ đăng ký mọi thiết bị được phát hiện trong hệ thống
(cái sau được ưu tiên). Việc này được thực hiện bởi tty_register_device(). Hoặc bởi
tty_register_device_attr() nếu trình điều khiển muốn tiết lộ một số thông tin
thông qua struct attribute_group. Cả hai đều đăng ký thiết bị ZZ0001ZZ'th và
khi trở về, thiết bị có thể được mở ra. Ngoài ra còn có tty_port ưa thích
các biến thể được mô tả trong ZZ0002ZZ sau này. Tùy thuộc vào người lái xe
quản lý các chỉ số miễn phí và chọn đúng chỉ số. Lớp TTY chỉ từ chối
đăng ký nhiều thiết bị hơn mức được chuyển tới tty_alloc_driver().

Khi thiết bị được mở, lớp TTY sẽ phân bổ struct tty_struct và bắt đầu
gọi hoạt động từ ZZ0000ZZ, xem ZZ0001ZZ.

Trình tự đăng ký được ghi lại như sau:

.. kernel-doc:: drivers/tty/tty_io.c
   :identifiers: tty_register_device tty_register_device_attr
        tty_unregister_device

----

Liên kết thiết bị với cổng
------------------------
Như đã nêu trước đó, mọi thiết bị TTY sẽ có struct tty_port được gán cho
nó. Nó phải được biết đến với lớp TTY tại ZZ0000ZZ
muộn nhất.  Có rất ít người trợ giúp cho ZZ0001ZZ. Lý tưởng nhất là người lái xe sử dụng
tty_port_register_device() hoặc tty_port_register_device_attr() thay vì
tty_register_device() và tty_register_device_attr() tại thời điểm đăng ký.
Bằng cách này, trình điều khiển không cần quan tâm đến việc liên kết sau này.

Nếu không thể, trình điều khiển vẫn có thể liên kết tty_port với một cổng cụ thể
lập chỉ mục ZZ0001ZZ đăng ký thực tế theo tty_port_link_device(). Nếu nó vẫn còn
không phù hợp, tty_port_install() có thể được sử dụng từ
Móc ZZ0000ZZ là phương án cuối cùng. Cái cuối cùng là
dành riêng chủ yếu cho các thiết bị trong bộ nhớ như PTY nơi tty_port được phân bổ
theo yêu cầu.

Các thói quen liên kết được ghi lại ở đây:

.. kernel-doc::  drivers/tty/tty_port.c
   :identifiers: tty_port_link_device tty_port_register_device
        tty_port_register_device_attr

----

Tài liệu tham khảo trình điều khiển TTY
====================

Tất cả các thành viên của struct tty_driver đều được ghi lại ở đây. Các thành viên cần thiết là
ghi chú ở cuối. struct tty_Operation sẽ được ghi lại tiếp theo.

.. kernel-doc:: include/linux/tty_driver.h
   :identifiers: tty_driver

----

Tham khảo hoạt động TTY
========================

Khi TTY được đăng ký, các hook trình điều khiển này có thể được gọi bởi lớp TTY:

.. kernel-doc:: include/linux/tty_driver.h
   :identifiers: tty_operations
