.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/proc_net_tcp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================================
Các biến proc/net/tcp và proc/net/tcp6
================================================

Tài liệu này mô tả các giao diện /proc/net/tcp và /proc/net/tcp6.
Lưu ý rằng các giao diện này không được dùng nữa mà thay vào đó là tcp_diag.

Các giao diện /proc này cung cấp thông tin về TCP hiện đang hoạt động
kết nối và được triển khai bởi tcp4_seq_show() trong net/ipv4/tcp_ipv4.c
và tcp6_seq_show() tương ứng trong net/ipv6/tcp_ipv6.c.

Trước tiên, nó sẽ liệt kê tất cả các ổ cắm TCP đang nghe và danh sách tiếp theo tất cả đã được thiết lập
Kết nối TCP. Một mục điển hình của /proc/net/tcp sẽ trông như thế này (split
lên thành 3 phần vì độ dài của dòng)::

46: 010310AC:9C4C 030310AC:1770 01
   ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ-> trạng thái kết nối
   ZZ0003ZZ ZZ0004ZZ |------> số cổng TCP từ xa
   ZZ0005ZZ ZZ0006ZZ-------------> địa chỉ IPv4 từ xa
   ZZ0007ZZ |--------------------> số cổng TCP cục bộ
   ZZ0008ZZ---------------------------> địa chỉ IPv4 cục bộ
   |----------------------------------> số mục nhập

00000150:00000000 01:00000019 00000000
      ZZ0000ZZ ZZ0001ZZ |--> số lần hết thời gian chờ RTO chưa được khôi phục
      ZZ0002ZZ ZZ0003ZZ----------> số lần nháy mắt cho đến khi hết giờ
      ZZ0004ZZ |----------------> time_active (xem bên dưới)
      ZZ0005ZZ----------------------> hàng đợi nhận
      |-------------------------------> hàng đợi truyền

1000 0 54165785 4 cd1e6040 25 4 27 3 -1
    ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ ZZ0004ZZ --> ngưỡng kích thước khởi động chậm,
    ZZ0005ZZ ZZ0006ZZ ZZ0007ZZ ZZ0008ZZ |      hoặc -1 nếu ngưỡng
    ZZ0009ZZ ZZ0010ZZ ZZ0011ZZ ZZ0012ZZ |      là >= 0xFFFF
    ZZ0013ZZ ZZ0014ZZ ZZ0015ZZ ZZ0016ZZ |----> gửi cửa sổ tắc nghẽn
    ZZ0017ZZ ZZ0018ZZ ZZ0019ZZ ZZ0020ZZ-------> (ack.quick<<1)|ack.pingpong
    ZZ0021ZZ ZZ0022ZZ ZZ0023ZZ |---------> Dự đoán tích tắc của đồng hồ mềm
    ZZ0024ZZ ZZ0025ZZ ZZ0026ZZ (dữ liệu điều khiển ACK bị trì hoãn)
    ZZ0027ZZ ZZ0028ZZ ZZ0029ZZ-----------> hết thời gian truyền lại
    ZZ0030ZZ ZZ0031ZZ |-------------------> vị trí của socket trong bộ nhớ
    ZZ0032ZZ ZZ0033ZZ--------------> số tham chiếu ổ cắm
    ZZ0034ZZ |-----------------------------> inode
    ZZ0035ZZ------------------------------------> đầu dò 0 cửa sổ chưa được trả lời
    |----------------------------------------------------------> uid

hẹn giờ_active:

======================================================================
  0 không có đồng hồ hẹn giờ nào đang chờ xử lý
  1 bộ đếm thời gian truyền lại đang chờ xử lý
  2 bộ hẹn giờ khác (ví dụ: xác nhận bị trì hoãn hoặc giữ nguyên) đang chờ xử lý
  3 đây là ổ cắm ở trạng thái TIME_WAIT. Không phải tất cả các trường sẽ chứa
     dữ liệu (hoặc thậm chí tồn tại)
  Bộ hẹn giờ thăm dò cửa sổ 4 số 0 đang chờ xử lý
 ======================================================================