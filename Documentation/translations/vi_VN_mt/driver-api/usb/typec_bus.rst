.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/usb/typec_bus.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.


API dành cho trình điều khiển Chế độ thay thế USB Type-C
=========================================

Giới thiệu
------------

Các chế độ thay thế yêu cầu liên lạc với đối tác bằng cách sử dụng Nhà cung cấp xác định
Thông báo (VDM) như được xác định trong Thông số kỹ thuật cung cấp điện USB Type-C và USB.
Giao tiếp cụ thể là SVID (ID tiêu chuẩn hoặc nhà cung cấp), tức là cụ thể cho
mọi chế độ thay thế, vì vậy mọi chế độ thay thế sẽ cần một trình điều khiển tùy chỉnh.

Xe buýt USB Type-C cho phép liên kết người lái xe với đối tác thay thế được phát hiện
chế độ bằng cách sử dụng SVID và số chế độ.

ZZ0000ZZ cung cấp thiết bị cho mọi người thay thế
chế độ mà một cổng hỗ trợ và thiết bị riêng biệt cho mọi chế độ thay thế mà đối tác
hỗ trợ. Trình điều khiển cho các chế độ thay thế được liên kết với đối tác thay thế
các thiết bị chế độ và các thiết bị chế độ thay thế cổng phải được xử lý bởi cổng
trình điều khiển.

Khi một thiết bị ở chế độ thay thế của đối tác mới được đăng ký, nó sẽ được liên kết với
thiết bị chế độ thay thế của cổng mà đối tác được gắn vào, có
phù hợp với SVID và chế độ. Giao tiếp giữa trình điều khiển cổng và chế độ thay thế
trình điều khiển sẽ xảy ra khi sử dụng cùng một API.

Các thiết bị ở chế độ thay thế cổng được sử dụng làm proxy giữa đối tác và
trình điều khiển chế độ thay thế, do đó, trình điều khiển cổng chỉ được yêu cầu vượt qua SVID
các lệnh cụ thể từ trình điều khiển chế độ thay thế cho đối tác và từ
đối tác với các trình điều khiển chế độ thay thế. Không có giao tiếp cụ thể SVID trực tiếp nào
cần thiết từ trình điều khiển cổng, nhưng trình điều khiển cổng cần cung cấp hoạt động
gọi lại cho các thiết bị ở chế độ thay thế cổng, giống như chế độ thay thế
người lái xe cần cung cấp chúng cho các thiết bị ở chế độ thay thế của đối tác.

Cách sử dụng:
------

Tổng quan
~~~~~~~

Theo mặc định, trình điều khiển chế độ thay thế chịu trách nhiệm vào chế độ này.
Cũng có thể để lại quyết định vào chế độ cho người dùng
dấu cách (Xem Tài liệu/ABI/testing/sysfs-class-typec). Trình điều khiển cổng không nên
tự mình nhập bất kỳ chế độ nào.

ZZ0001ZZ là lệnh gọi lại quan trọng nhất trong vectơ gọi lại hoạt động. Nó
sẽ được sử dụng để gửi tất cả các lệnh cụ thể SVID từ đối tác tới
trình điều khiển chế độ thay thế và ngược lại trong trường hợp trình điều khiển cổng. Các tài xế gửi
các lệnh cụ thể của SVID với nhau bằng ZZ0000ZZ.

Nếu giao tiếp với đối tác sử dụng các lệnh cụ thể của SVID có kết quả
cần cấu hình lại các chân trên đầu nối, trình điều khiển chế độ thay thế
cần thông báo cho xe buýt bằng ZZ0000ZZ. Người lái xe
chuyển giá trị cấu hình pin cụ thể SVID đã thương lượng cho hàm dưới dạng
tham số. Trình điều khiển xe buýt sau đó sẽ định cấu hình mux phía sau đầu nối bằng cách sử dụng
giá trị đó làm giá trị trạng thái cho mux.

NOTE: Các giá trị cấu hình pin cụ thể của SVID phải luôn bắt đầu từ
ZZ0000ZZ. Thông số kỹ thuật USB Type-C xác định hai trạng thái mặc định cho
đầu nối: ZZ0001ZZ và ZZ0002ZZ. Những giá trị này là
được xe buýt dành riêng làm giá trị đầu tiên có thể có cho trạng thái. Khi
chế độ thay thế được nhập, xe buýt sẽ đưa đầu nối vào
ZZ0003ZZ trước khi gửi lệnh Vào hoặc Thoát Chế độ như được xác định trong USB
Thông số kỹ thuật Type-C và cũng đặt đầu nối trở lại ZZ0004ZZ
sau khi thoát khỏi chế độ này.

Một ví dụ về định nghĩa hoạt động cho cấu hình chân cụ thể của SVID sẽ
trông như thế này::

liệt kê {
        ALTMODEX_CONF_A = TYPEC_STATE_MODAL,
        ALTMODEX_CONF_B,
        ...
    };

Macro trợ giúp ZZ0000ZZ cũng có thể được sử dụng ::

#define ALTMODEX_CONF_A = TYPEC_MODAL_STATE(0);
#define ALTMODEX_CONF_B = TYPEC_MODAL_STATE(1);

Các chế độ thay thế cắm cáp
~~~~~~~~~~~~~~~~~~~~~~~~~~

Trình điều khiển chế độ thay thế không bị ràng buộc với các thiết bị chế độ thay thế cắm cáp,
chỉ dành cho các thiết bị ở chế độ thay thế của đối tác. Nếu chế độ thay thế hỗ trợ, hoặc
yêu cầu cáp đáp ứng SOP Prime và tùy chọn SOP Double Prime
tin nhắn, trình điều khiển cho chế độ thay thế đó phải yêu cầu xử lý cáp
cắm các chế độ thay thế bằng ZZ0000ZZ và tiếp quản
sự kiểm soát của họ.

Trình điều khiển API
----------

Cấu trúc chế độ thay thế
~~~~~~~~~~~~~~~~~~~~~~

.. kernel-doc:: include/linux/usb/typec_altmode.h
   :functions: typec_altmode_driver typec_altmode_ops

Đăng ký/hủy đăng ký trình điều khiển chế độ thay thế
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. kernel-doc:: include/linux/usb/typec_altmode.h
   :functions: typec_altmode_register_driver typec_altmode_unregister_driver

Hoạt động của trình điều khiển chế độ thay thế
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. kernel-doc:: drivers/usb/typec/bus.c
   :functions: typec_altmode_enter typec_altmode_exit typec_altmode_attention typec_altmode_vdm typec_altmode_notify

API cho trình điều khiển cổng
~~~~~~~~~~~~~~~~~~~~~~~~

.. kernel-doc:: drivers/usb/typec/bus.c
   :functions: typec_match_altmode

Hoạt động cắm cáp
~~~~~~~~~~~~~~~~~~~~~

.. kernel-doc:: drivers/usb/typec/bus.c
   :functions: typec_altmode_get_plug typec_altmode_put_plug
