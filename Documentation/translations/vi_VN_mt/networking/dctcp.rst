.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/dctcp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
DCTCP (Trung tâm dữ liệu TCP)
=============================

DCTCP là một cải tiến của thuật toán kiểm soát tắc nghẽn TCP cho dữ liệu
mạng trung tâm và tận dụng Thông báo tắc nghẽn rõ ràng (ECN) trong
mạng trung tâm dữ liệu để cung cấp phản hồi nhiều bit cho máy chủ cuối.

Để kích hoạt nó trên máy chủ cuối::

sysctl -w net.ipv4.tcp_congestion_control=dctcp
  sysctl -w net.ipv4.tcp_ecn_fallback=0 (tùy chọn)

Tất cả các switch trong mạng trung tâm dữ liệu chạy DCTCP phải hỗ trợ ECN
đánh dấu và được cấu hình để đánh dấu khi đạt đến bộ đệm chuyển đổi được xác định
ngưỡng. Heuristic ngưỡng đánh dấu ECN mặc định cho DCTCP trên
chuyển mạch là 20 gói (30KB) ở tốc độ 1Gbps và 65 gói (~100KB) ở tốc độ 10Gbps,
nhưng có thể cần điều chỉnh cẩn thận hơn nữa.

Để biết thêm chi tiết, xem tài liệu dưới đây:

Giấy:

Thuật toán được mô tả chi tiết hơn trong hai phần sau
Giấy tờ SIGCOMM/SIGMETRICS:

i) Mohammad Alizadeh, Albert Greenberg, David A. Maltz, Jitendra Padhye,
    Parveen Patel, Balaji Prabhakar, Sudipta Sengupta và Murari Sridharan:

"Trung tâm dữ liệu TCP (DCTCP)", phiên Mạng trung tâm dữ liệu"

Proc. ACM SIGCOMM, New Delhi, 2010.

ZZ0000ZZ
    ZZ0001ZZ

ii) Mohammad Alizadeh, Adel Javanmard và Balaji Prabhakar:

"Phân tích DCTCP: Tính ổn định, hội tụ và công bằng"
      Proc. ACM SIGMETRICS, San Jose, 2011.

ZZ0000ZZ

Dự thảo thông tin IETF:

ZZ0000ZZ

Trang web DCTCP:

ZZ0000ZZ