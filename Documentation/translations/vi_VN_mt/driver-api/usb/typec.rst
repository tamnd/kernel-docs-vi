.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/usb/typec.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _typec:

Lớp đầu nối USB Type-C
==========================

Giới thiệu
------------

Lớp typec dùng để mô tả các cổng USB Type-C trong hệ thống cho
không gian người dùng theo cách thống nhất. Lớp học được thiết kế để không cung cấp gì khác
ngoại trừ việc triển khai giao diện không gian người dùng với hy vọng rằng nó có thể được sử dụng
trên càng nhiều nền tảng càng tốt.

Các nền tảng dự kiến sẽ đăng ký mọi cổng USB Type-C mà họ có với
lớp học. Trong trường hợp bình thường, việc đăng ký sẽ được thực hiện bởi USB Type-C hoặc PD PHY
trình điều khiển, nhưng nó có thể là trình điều khiển cho giao diện phần sụn như UCSI, trình điều khiển cho
Bộ điều khiển USB PD hoặc thậm chí là trình điều khiển cho bộ điều khiển Thunderbolt3. Tài liệu này
coi thành phần đăng ký cổng USB Type-C với lớp là "cổng
tài xế".

Ngoài việc thể hiện các khả năng, lớp này còn cung cấp khả năng kiểm soát không gian của người dùng đối với
vai trò và chế độ thay thế của các cổng, đối tác và đầu cắm cáp khi cổng
driver có khả năng hỗ trợ những tính năng đó.

Lớp này cung cấp API cho trình điều khiển cổng được mô tả trong tài liệu này. các
các thuộc tính được mô tả trong Documentation/ABI/testing/sysfs-class-typec.

Giao diện không gian người dùng
--------------------
Mỗi cổng sẽ được trình bày dưới dạng thiết bị riêng trong /sys/class/typec/. các
cổng đầu tiên sẽ được đặt tên là "port0", "port1" thứ hai, v.v.

Khi được kết nối, đối tác cũng sẽ được hiển thị dưới dạng thiết bị của chính họ trong
/sys/class/typec/. Thiết bị mẹ của thiết bị đối tác sẽ luôn là cổng của nó
được gắn vào. Đối tác gắn với cổng "port0" sẽ được đặt tên
"port0-đối tác". Đường dẫn đầy đủ đến thiết bị sẽ là
/sys/class/typec/port0/port0-partner/.

Cáp và hai phích cắm trên đó cũng có thể được tùy chọn là của riêng chúng.
các thiết bị thuộc /sys/class/typec/. Cáp gắn vào cổng “port0” port
sẽ được đặt tên là port0-cable và phích cắm ở đầu SOP Prime (xem USB Power
Thông số kỹ thuật giao hàng ch. 2.4) sẽ được đặt tên là "port0-plug0" và trên SOP
Đầu đôi Prime "port0-plug1". Nguồn gốc của cáp sẽ luôn là cổng,
và nguồn gốc của phích cắm cáp sẽ luôn là cáp.

Nếu cổng, đối tác hoặc đầu cắm cáp hỗ trợ Chế độ thay thế, mọi chế độ được hỗ trợ
Chế độ thay thế SVID sẽ có thiết bị riêng mô tả chúng. Lưu ý rằng
Các thiết bị ở Chế độ thay thế sẽ không được gắn vào lớp typec. Cha mẹ của một
chế độ thay thế sẽ là thiết bị hỗ trợ nó, ví dụ như chế độ thay thế
chế độ của port0-partner sẽ được trình bày trong /sys/class/typec/port0-partner/.
Mỗi chế độ được hỗ trợ sẽ có nhóm riêng trong Chế độ thay thế
thiết bị có tên "mode<index>", ví dụ /sys/class/typec/port0/<alternate
chế độ>/mode1/. Các yêu cầu vào/ra một chế độ có thể được thực hiện bằng "active"
tập tin thuộc tính trong nhóm đó.

Trình điều khiển API
----------

Đăng ký các cổng
~~~~~~~~~~~~~~~~~~~~~

Trình điều khiển cổng sẽ mô tả mọi cổng Type-C mà họ điều khiển bằng struct
cấu trúc dữ liệu typec_capability và đăng ký chúng với API sau:

.. kernel-doc:: drivers/usb/typec/class.c
   :functions: typec_register_port typec_unregister_port

Khi đăng ký cổng, thành viên Prefer_role trong struct typec_capability
xứng đáng được thông báo đặc biệt. Nếu cổng đang được đăng ký không có
tùy chọn vai trò ban đầu, có nghĩa là cổng không thực thi Try.SNK hoặc
Try.SRC theo mặc định, thành viên phải có giá trị TYPEC_NO_PREFERRED_ROLE.
Ngược lại, nếu cổng thực thi Try.SNK theo mặc định thì thành viên phải có giá trị
TYPEC_DEVICE và với Try.SRC, giá trị phải là TYPEC_HOST.

Đăng ký đối tác
~~~~~~~~~~~~~~~~~~~~

Sau khi kết nối thành công với đối tác, trình điều khiển cổng cần đăng ký
đồng hành cùng lớp. Thông tin chi tiết về đối tác cần được mô tả trong struct
typec_partner_desc. Lớp sao chép thông tin chi tiết của đối tác trong quá trình
đăng ký. Lớp cung cấp API sau để đăng ký/hủy đăng ký
đối tác.

.. kernel-doc:: drivers/usb/typec/class.c
   :functions: typec_register_partner typec_unregister_partner

Lớp sẽ cung cấp một điều khiển cho struct typec_partner nếu việc đăng ký được thực hiện
thành công hoặc NULL.

Nếu đối tác có khả năng cung cấp năng lượng cho USB và trình điều khiển cổng có thể
hiển thị kết quả của lệnh Discover Identity, cấu trúc mô tả đối tác
nên bao gồm phần xử lý cho phiên bản struct usb_pd_identity. Khi đó lớp sẽ
tạo thư mục sysfs cho danh tính trong thiết bị đối tác. kết quả
của lệnh Discover Identity sau đó có thể được báo cáo bằng API sau:

.. kernel-doc:: drivers/usb/typec/class.c
   :functions: typec_partner_set_identity

Đăng ký cáp
~~~~~~~~~~~~~~~~~~

Sau khi kết nối thành công cáp hỗ trợ USB Power Delivery
Cấu trúc VDM "Khám phá danh tính", driver cổng cần đăng ký cáp
và một hoặc hai phích cắm, tùy thuộc vào việc có bộ điều khiển CC Double Prime hay không
trong cáp hay không. Vậy một sợi cáp có khả năng giao tiếp SOP Prime chứ không phải SOP
Giao tiếp Double Prime, chỉ nên đăng ký một phích cắm. Để biết thêm
thông tin về giao tiếp SOP, vui lòng đọc chương về nó từ
thông số kỹ thuật phân phối điện USB mới nhất.

Các phích cắm được thể hiện dưới dạng thiết bị của riêng họ. Cáp được đăng ký đầu tiên,
tiếp theo là đăng ký phích cắm cáp. Cáp sẽ là thiết bị mẹ
cho các phích cắm. Chi tiết về cáp cần được mô tả trong struct
typec_cable_desc và về phần cắm trong struct typec_plug_desc. Các bản sao của lớp
các chi tiết trong quá trình đăng ký. Lớp học cung cấp API sau đây cho
đăng ký/hủy đăng ký cáp và phích cắm của chúng:

.. kernel-doc:: drivers/usb/typec/class.c
   :functions: typec_register_cable typec_unregister_cable typec_register_plug typec_unregister_plug

Lớp này sẽ cung cấp một điều khiển cho struct typec_cable và struct typec_plug nếu
đăng ký thành công hoặc NULL nếu không.

Nếu cáp có khả năng USB Power Delivery và trình điều khiển cổng có thể hiển thị
kết quả của lệnh Discover Identity, cấu trúc bộ mô tả cáp sẽ
bao gồm xử lý cho phiên bản struct usb_pd_identity. Sau đó lớp sẽ tạo một
sysfs để nhận dạng dưới thiết bị cáp. Kết quả khám phá
Lệnh nhận dạng sau đó có thể được báo cáo bằng API sau:

.. kernel-doc:: drivers/usb/typec/class.c
   :functions: typec_cable_set_identity

Thông báo
~~~~~~~~~~~~~

Khi đối tác đã thực hiện thay đổi vai trò hoặc khi vai trò mặc định thay đổi
trong quá trình kết nối đối tác hoặc cáp, trình điều khiển cổng phải sử dụng thông tin sau
API để báo cáo với lớp:

.. kernel-doc:: drivers/usb/typec/class.c
   :functions: typec_set_data_role typec_set_pwr_role typec_set_vconn_role typec_set_pwr_opmode

Chế độ thay thế
~~~~~~~~~~~~~~~

Các cổng, đối tác và đầu cắm cáp loại C của USB có thể hỗ trợ Chế độ thay thế. Mỗi
Chế độ thay thế sẽ có mã định danh được gọi là SVID, đây là ID tiêu chuẩn
được cung cấp bởi USB-IF hoặc ID nhà cung cấp và mỗi SVID được hỗ trợ có thể có 1 - 6 chế độ. các
lớp cung cấp struct typec_mode_desc để mô tả chế độ riêng của SVID,
và struct typec_altmode_desc là nơi chứa tất cả các chế độ được hỗ trợ.

Các cổng hỗ trợ Chế độ thay thế cần phải đăng ký từng SVID mà chúng hỗ trợ
API sau đây:

.. kernel-doc:: drivers/usb/typec/class.c
   :functions: typec_port_register_altmode

Nếu đối tác hoặc đầu cắm cáp cung cấp danh sách SVID dưới dạng phản hồi cho USB Power
Phân phối có cấu trúc VDM Khám phá tin nhắn SVID, mỗi SVID cần phải được
đã đăng ký.

API dành cho đối tác:

.. kernel-doc:: drivers/usb/typec/class.c
   :functions: typec_partner_register_altmode

API cho phích cắm cáp:

.. kernel-doc:: drivers/usb/typec/class.c
   :functions: typec_plug_register_altmode

Vì vậy, các cổng, đối tác và đầu cắm cáp sẽ đăng ký các chế độ thay thế với
các chức năng riêng, nhưng việc đăng ký sẽ luôn trả về một điều khiển cho struct
typec_altmode nếu thành công hoặc NULL. Việc hủy đăng ký sẽ xảy ra tương tự
chức năng:

.. kernel-doc:: drivers/usb/typec/class.c
   :functions: typec_unregister_altmode

Nếu đối tác hoặc đầu cắm cáp vào hoặc thoát khỏi một chế độ, trình điều khiển cổng cần phải
thông báo cho lớp bằng API sau:

.. kernel-doc:: drivers/usb/typec/class.c
   :functions: typec_altmode_update_active

Bộ chuyển mạch ghép kênh/khử ghép kênh
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Đầu nối USB Type-C có thể có một hoặc nhiều công tắc mux/demux phía sau chúng. Kể từ khi
phích cắm có thể được cắm theo hướng bên phải hoặc lộn ngược, cần có công tắc để
định tuyến các cặp dữ liệu chính xác từ đầu nối đến bộ điều khiển USB. Nếu
Chế độ thay thế hoặc phụ kiện được hỗ trợ, cần có một công tắc khác có thể
định tuyến các chân trên đầu nối tới một số thành phần khác ngoài USB. USB Loại-C
Lớp Trình kết nối cung cấp API để đăng ký các bộ chuyển mạch đó.

.. kernel-doc:: drivers/usb/typec/mux.c
   :functions: typec_switch_register typec_switch_unregister typec_mux_register typec_mux_unregister

Trong hầu hết các trường hợp, cùng một mux vật lý sẽ xử lý cả hướng và chế độ.
Tuy nhiên, vì trình điều khiển cổng sẽ chịu trách nhiệm định hướng và
trình điều khiển chế độ thay thế cho chế độ này, cả hai luôn được tách thành
các thành phần logic riêng: "mux" cho chế độ và "switch" cho hướng.

Khi một cổng được đăng ký, Lớp trình kết nối USB Type-C yêu cầu cả mux và
công tắc cho cổng. Sau đó, các trình điều khiển có thể sử dụng API sau đây để
kiểm soát chúng:

.. kernel-doc:: drivers/usb/typec/class.c
   :functions: typec_set_orientation typec_set_mode

Nếu đầu nối có khả năng đảm nhận vai trò kép thì cũng có thể có một công tắc cho dữ liệu
vai trò. Lớp đầu nối USB Type-C không cung cấp API riêng cho chúng. các
trình điều khiển cổng có thể sử dụng USB Role Class API với những cổng đó.

Hình minh họa các mux phía sau đầu nối hỗ trợ chế độ thay thế::

---------------
                     ZZ0000ZZ
                     ---------------
                            ZZ0001ZZ
                     ---------------
                      \ Định hướng /
                       --------------------
                                |
                       --------------------
                      / Chế độ \
                     ---------------
                         / \
      ------------------------- -------------------
      Vai trò ZZ0002ZZ / USB \
      --------------- ------------------------
                                         / \
                     --------------- ------------------------
                     ZZ0003ZZ ZZ0004ZZ
                     --------------- ------------------------
