.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/ip_dynaddr.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================
Cổng hack địa chỉ IP động v0.03
==================================

Công cụ này cho phép các kết nối quay số ONESHOT được thiết lập bởi
thay đổi động địa chỉ nguồn gói (và ổ cắm nếu các tiến trình cục bộ).
Nó được triển khai cho các kết nối hộp quay số TCP(1) và IP_MASQuerading(2).

Nếu được bật\ [#]_ và giao diện chuyển tiếp đã thay đổi:

1) Địa chỉ nguồn socket (và gói) được viết lại TRÊN RETRANSMISSIONS
      khi ở trạng thái SYN_SENT (các quy trình hộp quay số).
  2) Địa chỉ nguồn MASQueraded ngoài giới hạn thay đổi TRÊN OUTPUT (khi
      máy chủ nội bộ thực hiện truyền lại) cho đến khi một gói từ bên ngoài được
      được nhận bởi đường hầm.

Điều này đặc biệt hữu ích cho các liên kết quay số tự động (quay số), trong đó
Địa chỉ gửi đi ZZ0000ZZ hiện chưa xác định được liên kết
đang đi lên. Vì vậy, các kết nối ZZ0001ZZ (AND cục bộ giả mạo) yêu cầu
đưa liên kết lên sẽ có thể được thiết lập.

.. [#] At boot, by default no address rewriting is attempted.

  To enable::

     # echo 1 > /proc/sys/net/ipv4/ip_dynaddr

  To enable verbose mode::

    # echo 2 > /proc/sys/net/ipv4/ip_dynaddr

  To disable (default)::

     # echo 0 > /proc/sys/net/ipv4/ip_dynaddr

Thưởng thức!

Juanjo <jjciarla@raiz.uncu.edu.ar>