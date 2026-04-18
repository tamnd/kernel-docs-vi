.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/tty/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===
TTY
===

Lớp Teletypewriter (TTY) xử lý tất cả các thiết bị nối tiếp đó. Bao gồm
những cái ảo như pseudoterminal (PTY).

Cấu trúc TTY
==============

Có một số cấu trúc TTY chính. Mọi thiết bị TTY trong hệ thống đều có
cấu trúc tty_port tương ứng. Các thiết bị này được duy trì bởi trình điều khiển TTY
đó là cấu trúc tty_driver. Cấu trúc này mô tả trình điều khiển nhưng cũng
chứa tham chiếu đến các hoạt động có thể được thực hiện trên TTY. Đó là
cấu trúc tty_ hoạt động. Sau đó, khi mở, struct tty_struct được phân bổ và
sống cho đến khi kết thúc cuối cùng. Trong thời gian này, một số lệnh gọi lại từ struct
tty_Operations được gọi bởi lớp TTY.

Mọi ký tự mà kernel nhận được (cả từ thiết bị và người dùng) đều được chuyển qua
thông qua ZZ0000ZZ được chọn trước (trong
ldisc ngắn; trong C, cấu trúc tty_ldisc_ops). Nhiệm vụ của nó là biến đổi nhân vật
như được xác định bởi một ldisc cụ thể hoặc bởi người dùng. Cái mặc định là n_tty,
thực hiện tiếng vang, xử lý tín hiệu, kiểm soát công việc, ký tự đặc biệt
xử lý, và nhiều hơn nữa. Các ký tự được chuyển đổi sẽ được chuyển tiếp cho
người dùng/thiết bị, tùy thuộc vào nguồn.

Mô tả chi tiết về cấu trúc TTY được đặt tên có trong các tài liệu riêng biệt:

.. toctree::
   :maxdepth: 2

   tty_driver
   tty_port
   tty_struct
   tty_ldisc
   tty_buffer
   tty_ioctl
   tty_internals
   console

Viết trình điều khiển TTY
=========================

Trước khi bắt đầu viết trình điều khiển TTY, họ phải xem xét
ZZ0000ZZ và ZZ0001ZZ
lớp đầu tiên. Trình điều khiển cho các thiết bị nối tiếp thường có thể sử dụng một trong những trình điều khiển cụ thể này
các lớp để triển khai trình điều khiển nối tiếp. Chỉ nên xử lý các thiết bị đặc biệt
trực tiếp bởi Lớp TTY. Nếu bạn định viết một trình điều khiển như vậy, hãy đọc tiếp.

Trình tự ZZ0000ZZ mà trình điều khiển TTY thực hiện như sau:

#. Phân bổ và đăng ký trình điều khiển TTY (init module)
#. Tạo và đăng ký các thiết bị TTY khi chúng được thăm dò (chức năng thăm dò)
#. Xử lý các hoạt động và sự kiện TTY như các ngắt (lõi TTY gọi
   trước đây, thiết bị sau)
#. Xóa các thiết bị khi chúng sắp biến mất (xóa chức năng)
#. Hủy đăng ký và giải phóng trình điều khiển TTY (thoát mô-đun)

Các bước liên quan đến trình điều khiển, tức là 1., 3. và 5. được mô tả chi tiết trong
ZZ0000ZZ. Đối với hai phần còn lại (xử lý thiết bị), hãy xem xét
ZZ0001ZZ.

Tài liệu khác
===================

Tài liệu khác có thể được tìm thấy thêm trong các tài liệu này:

.. toctree::
   :maxdepth: 2

   moxa-smartio
   n_gsm
   n_tty