.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/netlabel/cipso_ipv4.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================
Công cụ giao thức NetLabel CIPSO/IPv4
===================================

Paul Moore, paul.moore@hp.com

Ngày 17 tháng 5 năm 2006

Tổng quan
========

Công cụ giao thức NetLabel CIPSO/IPv4 dựa trên IETF Thương mại
Bản dự thảo Tùy chọn Bảo mật IP (CIPSO) từ ngày 16 tháng 7 năm 1992. Một bản sao của bản này
bản nháp có thể được tìm thấy trong thư mục này
(dự thảo-ietf-cipso-ipsecurity-01.txt).  Trong khi bản nháp IETF chưa bao giờ được thực hiện
nó theo tiêu chuẩn RFC, nó đã trở thành một tiêu chuẩn thực tế cho việc dán nhãn
mạng và được sử dụng trong nhiều hệ điều hành đáng tin cậy.

Xử lý gói gửi đi
==========================

Công cụ giao thức CIPSO/IPv4 áp dụng tùy chọn IP CIPSO cho các gói bằng cách
thêm nhãn CIPSO vào ổ cắm.  Điều này khiến tất cả các gói rời khỏi
hệ thống thông qua ổ cắm để áp dụng tùy chọn IP CIPSO.  Ổ cắm của
Nhãn CIPSO có thể được thay đổi bất kỳ lúc nào, tuy nhiên, nên thay đổi nhãn này
rằng nó được thiết lập khi tạo ổ cắm.  LSM có thể đặt CIPSO của ổ cắm
nhãn bằng cách sử dụng mô-đun bảo mật NetLabel API; nếu "miền" NetLabel là
được định cấu hình để sử dụng CIPSO để ghi nhãn gói thì tùy chọn IP CIPSO sẽ là
được tạo và gắn vào socket.

Xử lý gói gửi đến
=========================

Công cụ giao thức CIPSO/IPv4 xác thực mọi tùy chọn IP CIPSO mà nó tìm thấy ở
Lớp IP mà LSM không yêu cầu bất kỳ xử lý đặc biệt nào.  Tuy nhiên, để
để giải mã và dịch nhãn CIPSO trên gói, LSM phải sử dụng
Mô-đun bảo mật NetLabel API để trích xuất các thuộc tính bảo mật của gói.
Điều này thường được thực hiện ở lớp socket bằng cách sử dụng 'socket_sock_rcv_skb()'
Móc LSM.

Dịch nhãn
=================

Công cụ giao thức CIPSO/IPv4 chứa cơ chế dịch bảo mật CIPSO
các thuộc tính như mức độ nhạy cảm và danh mục đối với các giá trị
phù hợp với chủ nhà.  Các ánh xạ này được xác định là một phần của CIPSO
Định nghĩa Miền phiên dịch (DOI) và được định cấu hình thông qua
Lớp giao tiếp không gian người dùng NetLabel.  Mỗi định nghĩa DOI có thể có một
bảng ánh xạ thuộc tính bảo mật khác nhau.

Bộ đệm dịch nhãn
=======================

Hệ thống NetLabel cung cấp một khung cho thuộc tính bảo mật bộ nhớ đệm
ánh xạ từ nhãn mạng tới mã định danh LSM tương ứng.  các
Công cụ giao thức CIPSO/IPv4 hỗ trợ cơ chế bộ nhớ đệm này.
