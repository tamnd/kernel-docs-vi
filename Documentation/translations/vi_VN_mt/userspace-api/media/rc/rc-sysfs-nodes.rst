.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/rc/rc-sysfs-nodes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _remote_controllers_sysfs_nodes:

*******************************
Các nút sysfs của Bộ điều khiển từ xa
*******************************

Như được định nghĩa tại Documentation/ABI/testing/sysfs-class-rc, đó là
các nút sysfs điều khiển Bộ điều khiển từ xa:


.. _sys_class_rc:

/sys/lớp/rc/
==============

Thư mục con lớp ZZ0000ZZ thuộc về Remote
Lõi điều khiển và cung cấp giao diện sysfs để định cấu hình hồng ngoại
máy thu điều khiển từ xa.


.. _sys_class_rc_rcN:

/sys/class/rc/rcN/
==================

Một thư mục ZZ0000ZZ được tạo cho mỗi điều khiển từ xa
thiết bị thu trong đó N là số lượng thiết bị thu.


.. _sys_class_rc_rcN_protocols:

/sys/class/rc/rcN/giao thức
===========================

Đọc tệp này sẽ trả về danh sách các giao thức có sẵn, đại loại như ::

rc5 [rc6] không cần jvc [sony]

Các giao thức đã kích hoạt được hiển thị trong ngoặc [].

Việc viết "+proto" sẽ thêm một giao thức vào danh sách các giao thức được kích hoạt.

Việc viết "-proto" sẽ xóa giao thức khỏi danh sách đã bật
giao thức.

Viết "proto" sẽ chỉ kích hoạt "proto".

Viết "không" sẽ vô hiệu hóa tất cả các giao thức.

Ghi không thành công với ZZ0000ZZ nếu kết hợp giao thức không hợp lệ hoặc không xác định
tên giao thức được sử dụng.


.. _sys_class_rc_rcN_filter:

/sys/class/rc/rcN/bộ lọc
========================

Đặt giá trị mong đợi của bộ lọc scancode.

Sử dụng kết hợp với ZZ0000ZZ để thiết lập
giá trị mong đợi của các bit được đặt trong mặt nạ bộ lọc. Nếu phần cứng
hỗ trợ nó thì các scancode không phù hợp với bộ lọc sẽ bị loại bỏ.
bị phớt lờ. Nếu không việc ghi sẽ thất bại và có lỗi.

Giá trị này có thể được đặt lại về 0 nếu giao thức hiện tại bị thay đổi.


.. _sys_class_rc_rcN_filter_mask:

/sys/class/rc/rcN/filter_mask
=============================

Đặt mặt nạ bộ lọc scancode của các bit để so sánh. Sử dụng kết hợp
với ZZ0000ZZ để đặt các bit của scancode
nên được so sánh với giá trị kỳ vọng. Giá trị 0 vô hiệu hóa
bộ lọc để cho phép tất cả các scancode hợp lệ được xử lý.

Nếu phần cứng hỗ trợ thì mã quét không khớp với bộ lọc
sẽ bị bỏ qua. Nếu không việc ghi sẽ thất bại và có lỗi.

Giá trị này có thể được đặt lại về 0 nếu giao thức hiện tại bị thay đổi.


.. _sys_class_rc_rcN_wakeup_protocols:

/sys/class/rc/rcN/wakeup_protocols
==================================

Việc đọc tệp này sẽ trả về một danh sách các giao thức có sẵn để sử dụng cho
bộ lọc đánh thức, đại loại như ::

rc-5 nec-x rc-6-0 rc-6-6a-24 [rc-6-6a-32] rc-6-mce

Lưu ý rằng các biến thể giao thức được liệt kê, vì vậy ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ
có mã hóa độ dài bit khác nhau được liệt kê nếu có.

Lưu ý rằng tất cả các biến thể của giao thức đều được liệt kê.

Giao thức đánh thức đã bật được hiển thị trong dấu ngoặc [].

Mỗi lần chỉ có thể chọn một giao thức.

Viết "proto" sẽ sử dụng "proto" cho các sự kiện đánh thức.

Viết "không" sẽ vô hiệu hóa việc đánh thức.

Ghi không thành công với ZZ0000ZZ nếu kết hợp giao thức không hợp lệ hoặc không xác định
tên giao thức được sử dụng hoặc nếu phần cứng đánh thức không được hỗ trợ.


.. _sys_class_rc_rcN_wakeup_filter:

/sys/class/rc/rcN/wakeup_filter
===============================

Đặt giá trị mong đợi của bộ lọc đánh thức scancode. Sử dụng kết hợp với
ZZ0000ZZ để đặt giá trị mong đợi của
các bit được đặt trong mặt nạ bộ lọc đánh thức để kích hoạt sự kiện đánh thức hệ thống.

Nếu phần cứng hỗ trợ và Wakeup_filter_mask không bằng 0 thì
scancode phù hợp với bộ lọc sẽ đánh thức hệ thống từ ví dụ: đình chỉ
sang RAM hoặc tắt nguồn. Nếu không việc ghi sẽ thất bại và có lỗi.

Giá trị này có thể được đặt lại về 0 nếu giao thức đánh thức bị thay đổi.


.. _sys_class_rc_rcN_wakeup_filter_mask:

/sys/class/rc/rcN/wakeup_filter_mask
====================================

Đặt mặt nạ bộ lọc đánh thức scancode của các bit để so sánh. Sử dụng trong
kết hợp với ZZ0000ZZ để thiết lập các bit của
scancode cần được so sánh với giá trị mong đợi để
kích hoạt sự kiện đánh thức hệ thống.

Nếu phần cứng hỗ trợ và Wakeup_filter_mask không bằng 0 thì
scancode phù hợp với bộ lọc sẽ đánh thức hệ thống từ ví dụ: đình chỉ
sang RAM hoặc tắt nguồn. Nếu không việc ghi sẽ thất bại và có lỗi.

Giá trị này có thể được đặt lại về 0 nếu giao thức đánh thức bị thay đổi.