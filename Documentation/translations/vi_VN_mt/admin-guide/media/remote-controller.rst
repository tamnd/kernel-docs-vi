.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/remote-controller.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================================================
Hỗ trợ điều khiển từ xa hồng ngoại trong trình điều khiển video4linux
=====================================================================

Tác giả: Gerd Hoffmann, Mauro Carvalho Chehab

Khái niệm cơ bản
================

Hầu hết các bo mạch TV analog và kỹ thuật số đều hỗ trợ bộ điều khiển từ xa. Một số
chúng có một bộ vi xử lý nhận các sóng mang IR, chuyển đổi thành
các chuỗi xung/không gian và sau đó quét mã, trả lại các mã đó cho
không gian người dùng ("chế độ quét mã"). Các bảng khác chỉ trả về xung/khoảng trống
trình tự ("chế độ thô").

Sự hỗ trợ cho bộ điều khiển từ xa ở chế độ scancode được cung cấp bởi
lớp đầu vào tiêu chuẩn của Linux. Hỗ trợ cho chế độ thô được cung cấp thông qua LIRC.

Để kiểm tra sự hỗ trợ và kiểm tra nó, bạn nên tải xuống
ZZ0000ZZ. Nó cung cấp
hai công cụ để xử lý bộ điều khiển từ xa:

- ir-keytable: cung cấp cách truy vấn bộ điều khiển từ xa, liệt kê các
  các giao thức mà nó hỗ trợ, cho phép hỗ trợ trong kernel cho bộ giải mã IR hoặc
  chuyển đổi giao thức và kiểm tra việc tiếp nhận mã quét;

- ir-ctl: cung cấp công cụ xử lý các bộ điều khiển từ xa hỗ trợ chế độ raw
  thông qua giao diện LIRC.

Thông thường, mô-đun điều khiển từ xa sẽ tự động được tải khi thẻ TV được cắm.
được phát hiện. Tuy nhiên, đối với một số thiết bị, bạn cần tải thủ công
mô-đun ir-kbd-i2c.

Nó hoạt động như thế nào
========================

Các mô-đun đăng ký điều khiển từ xa dưới dạng bàn phím trong đầu vào linux
layer, tức là bạn sẽ thấy các phím của điều khiển từ xa giống như các thao tác gõ phím thông thường
(nếu CONFIG_INPUT_KEYBOARD được bật).

Sử dụng các thiết bị sự kiện (CONFIG_INPUT_EVDEV) có thể
các ứng dụng để truy cập điều khiển từ xa thông qua thiết bị /dev/input/event<n>.
Udev/systemd sẽ tự động tạo các thiết bị. Nếu bạn cài đặt
ZZ0000ZZ, nó cũng có thể
tự động tải một bảng phím khác với bảng phím mặc định. Xin vui lòng xem
ZZ0001ZZ ir-keytable.1
trang man để biết chi tiết.

Công cụ ir-keytable rất hữu ích trong việc khắc phục sự cố, tức là để kiểm tra
bất cứ khi nào thiết bị đầu vào thực sự có mặt, thiết bị nào sẽ
là kiểm tra xem việc nhấn phím trên điều khiển từ xa có thực sự tạo ra
sự kiện và những thứ tương tự.  Bạn cũng có thể sử dụng bất kỳ tiện ích đầu vào nào khác thay đổi
các sơ đồ bàn phím, như tiện ích kbd đầu vào.


Sử dụng với lircd
-----------------

Các phiên bản mới nhất của daemon lircd hỗ trợ đọc các sự kiện từ
lớp đầu vào linux (thông qua thiết bị sự kiện). Nó cũng hỗ trợ nhận mã IR
ở chế độ lirc.


Sử dụng không có lircd
----------------------

Xorg nhận ra một số mã khóa IR có giá trị số thấp hơn
hơn 247. Với sự ra đời của Wayland, trình điều khiển đầu vào cũng được cập nhật,
và bây giờ sẽ chấp nhận tất cả các mã khóa. Tuy nhiên, bạn có thể muốn chỉ định lại
mã khóa cho thứ gì đó mà ứng dụng đa phương tiện yêu thích của bạn thích.

Điều này có thể được thực hiện bằng cách thiết lập
ZZ0000ZZ để tải của riêng bạn
bàn phím trong thời gian chạy. Vui lòng đọc trang man ir-keytable.1 để biết chi tiết.