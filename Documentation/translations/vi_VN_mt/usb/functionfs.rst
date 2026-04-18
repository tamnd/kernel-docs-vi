.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/usb/functionfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================
Cách thức hoạt động của FunctionFS
==================================

Tổng quan
========

Từ quan điểm hạt nhân, nó chỉ là một hàm tổng hợp với một số
hành vi độc đáo.  Nó chỉ có thể được thêm vào cấu hình USB sau
trình điều khiển không gian người dùng đã đăng ký bằng cách viết mô tả và
chuỗi (chương trình không gian người dùng phải cung cấp thông tin tương tự
các hàm tổng hợp cấp hạt nhân cung cấp khi chúng được thêm vào
cấu hình).

Điều này đặc biệt có nghĩa là các hàm khởi tạo tổng hợp
có thể không có trong phần init (tức là không được sử dụng thẻ __init).

Từ quan điểm không gian người dùng, nó là một hệ thống tập tin mà khi
mount cung cấp tệp "ep0".  Trình điều khiển không gian người dùng cần
viết mô tả và chuỗi vào tập tin đó.  Nó không cần
phải lo lắng về điểm cuối, giao diện hoặc số chuỗi nhưng
chỉ cần cung cấp các mô tả chẳng hạn như nếu hàm đó là
chỉ một (điểm cuối và số chuỗi bắt đầu từ một và
số giao diện bắt đầu từ số 0).  Các thay đổi của FunctionFS
chúng khi cần thiết cũng xử lý tình huống khi các số khác nhau
cấu hình khác nhau.

Để biết thêm thông tin về bộ mô tả FunctionFS, hãy xem ZZ0000ZZ

Khi bộ mô tả và chuỗi được ghi, tệp "ep#" xuất hiện
(một cho mỗi điểm cuối được khai báo) xử lý giao tiếp trên
một điểm cuối duy nhất.  Một lần nữa, FunctionFS sẽ xử lý vấn đề thực tế
số và thay đổi cấu hình (có nghĩa là
Tệp "ep1" thực sự có thể được ánh xạ tới điểm cuối 3 (và khi
cấu hình thay đổi thành (giả sử) điểm cuối 2)).  "ep0" được sử dụng
để nhận các sự kiện và xử lý các yêu cầu thiết lập.

Khi tất cả các tập tin được đóng lại, chức năng này sẽ tự tắt.

Điều tôi cũng muốn đề cập là FunctionFS được thiết kế theo cách như vậy
một cách mà có thể gắn nó nhiều lần để cuối cùng
một tiện ích có thể sử dụng một số chức năng FunctionFS. Ý tưởng là vậy
mỗi phiên bản FunctionFS được xác định bằng tên thiết bị được sử dụng
khi lắp.

Người ta có thể tưởng tượng một tiện ích có giao diện Ethernet, MTP và HID
trong đó hai cái cuối cùng được triển khai thông qua FunctionFS.  Trên không gian người dùng
cấp độ nó sẽ trông như thế này::

$ insmod g_ffs.ko idVendor=<ID> iSerialNumber=<string> function=mtp,hid
  $ mkdir /dev/ffs-mtp && mount -t functionfs mtp /dev/ffs-mtp
  $ ( cd /dev/ffs-mtp && mtp-daemon ) &
  $ mkdir /dev/ffs-hid && mount -t functionfs hid /dev/ffs-hid
  $ ( cd /dev/ffs-hid && hid-daemon ) &

Ở cấp độ kernel, tiện ích sẽ kiểm tra ffs_data->dev_name để xác định
liệu FunctionFS của nó được thiết kế cho MTP ("mtp") hay HID ("ẩn").

Nếu không có tham số mô-đun "chức năng" nào được cung cấp, trình điều khiển sẽ chấp nhận
chỉ một chức năng với bất kỳ tên nào.

Khi tham số mô-đun "chức năng" được cung cấp, chỉ các chức năng
với tên được liệt kê được chấp nhận. Đặc biệt, nếu "chức năng"
giá trị của tham số chỉ là danh sách một phần tử, thì hành vi
tương tự như khi không có "chức năng" nào cả; tuy nhiên,
chỉ một hàm có tên được chỉ định mới được chấp nhận.

Tiện ích chỉ được đăng ký sau tất cả chức năng được khai báo
hệ thống tập tin đã được gắn kết và bộ mô tả USB của tất cả các chức năng
đã được ghi vào ep0 của họ.

Ngược lại, tiện ích sẽ bị hủy đăng ký sau chức năng USB đầu tiên
đóng các điểm cuối của nó.

Giao diện DMABUF
================

FunctionFS còn hỗ trợ thêm giao diện dựa trên DMABUF, trong đó
không gian người dùng có thể đính kèm các đối tượng DMABUF (được tạo bên ngoài) vào điểm cuối,
và sau đó sử dụng chúng để truyền dữ liệu.

Sau đó, một ứng dụng không gian người dùng có thể sử dụng giao diện này để chia sẻ DMABUF
các đối tượng giữa một số giao diện, cho phép nó truyền dữ liệu một cách
kiểu không sao chép, chẳng hạn như giữa IIO và ngăn xếp USB.

Là một phần của giao diện này, ba IOCTL mới đã được thêm vào. Ba người này
IOCTL phải được thực hiện trên điểm cuối dữ liệu (tức là không phải ep0). Họ là:

ZZ0000ZZ
    Đính kèm đối tượng DMABUF, được xác định bởi bộ mô tả tệp của nó, vào
    điểm cuối dữ liệu. Trả về 0 nếu thành công và giá trị lỗi âm
    về lỗi.

ZZ0000ZZ
    Tách đối tượng DMABUF đã cho, được xác định bởi bộ mô tả tệp của nó,
    từ điểm cuối dữ liệu. Trả về 0 nếu thành công và âm
    không có giá trị lỗi. Lưu ý rằng việc đóng tệp của điểm cuối
    bộ mô tả sẽ tự động tách tất cả các DMABUF đính kèm.

ZZ0000ZZ
    Đưa DMABUF đã đính kèm trước đó vào hàng đợi chuyển.
    Đối số là một cấu trúc đóng gói bộ mô tả tệp của DMABUF,
    kích thước tính bằng byte cần truyền (thường tương ứng với
    kích thước của DMABUF) và trường 'cờ' không được sử dụng
    bây giờ. Trả về 0 nếu thành công và giá trị lỗi âm nếu
    lỗi.
