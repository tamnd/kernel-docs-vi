.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/x25-iface.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Giao diện trình điều khiển thiết bị X.25
========================================

Phiên bản 1.1

Jonathan Naylor 26.12.96

Đây là mô tả về các tin nhắn được chuyển giữa Gói X.25
Lớp và trình điều khiển thiết bị X.25. Chúng được thiết kế để cho phép dễ dàng
cài đặt chế độ LAPB từ bên trong Lớp gói.

Trình điều khiển thiết bị X.25 sẽ được mã hóa bình thường theo trình điều khiển thiết bị Linux
tiêu chuẩn. Hầu hết các trình điều khiển thiết bị X.25 sẽ tương tự ở mức độ vừa phải với
trình điều khiển thiết bị Ethernet hiện có. Tuy nhiên, không giống như những trình điều khiển đó,
Trình điều khiển thiết bị X.25 có trạng thái liên quan đến nó và thông tin này
cần phải được chuyển đến và đi từ Lớp gói để hoạt động bình thường.

Tất cả tin nhắn được giữ trong sk_buff giống như dữ liệu thực được truyền đi
qua liên kết LAPB. Byte đầu tiên của skbuff cho biết ý nghĩa của
phần còn lại của skbuff, nếu có thêm thông tin.


Lớp gói tới trình điều khiển thiết bị
-------------------------------------

Byte đầu tiên = 0x00 (X25_IFACE_DATA)

Điều này chỉ ra rằng phần còn lại của skbuff chứa dữ liệu được truyền đi
qua liên kết LAPB. Liên kết LAPB phải tồn tại trước khi bất kỳ dữ liệu nào được
được truyền lại.

Byte đầu tiên = 0x01 (X25_IFACE_CONNECT)

Thiết lập liên kết LAPB. Nếu liên kết đã được thiết lập thì kết nối
tin nhắn xác nhận sẽ được trả lại càng sớm càng tốt.

Byte đầu tiên = 0x02 (X25_IFACE_DISCONNECT)

Chấm dứt liên kết LAPB. Nếu nó đã bị ngắt kết nối thì ngắt kết nối
tin nhắn xác nhận sẽ được trả lại càng sớm càng tốt.

Byte đầu tiên = 0x03 (X25_IFACE_PARAMS)

Thông số LAPB. Để được xác định.


Trình điều khiển thiết bị cho lớp gói
-------------------------------------

Byte đầu tiên = 0x00 (X25_IFACE_DATA)

Điều này chỉ ra rằng phần còn lại của skbuff chứa dữ liệu đã được
nhận được qua liên kết LAPB.

Byte đầu tiên = 0x01 (X25_IFACE_CONNECT)

Liên kết LAPB đã được thiết lập. Thông báo tương tự được sử dụng cho cả LAPB
liên kết connect_confirmation và connect_indication.

Byte đầu tiên = 0x02 (X25_IFACE_DISCONNECT)

Liên kết LAPB đã bị chấm dứt. Thông báo tương tự này được sử dụng cho cả LAPB
liên kết ngắt kết nối_confirmation và ngắt kết nối_indication.

Byte đầu tiên = 0x03 (X25_IFACE_PARAMS)

Thông số LAPB. Để được xác định.


Yêu cầu đối với trình điều khiển thiết bị
-----------------------------------------

Các gói không được sắp xếp lại hoặc bị loại bỏ khi phân phối giữa
Lớp gói và trình điều khiển thiết bị.

Để tránh các gói tin bị sắp xếp lại hoặc bị rớt khi gửi từ
trình điều khiển thiết bị vào Lớp gói, trình điều khiển thiết bị không nên
gọi "netif_rx" để gửi các gói đã nhận. Thay vào đó nên
gọi "netif_receive_skb_core" từ ngữ cảnh softirq để phân phối chúng.