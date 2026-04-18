.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/netlabel/lsm_interface.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============================================
Giao diện mô-đun bảo mật NetLabel Linux
========================================

Paul Moore, paul.moore@hp.com

Ngày 17 tháng 5 năm 2006

Tổng quan
========

NetLabel là một cơ chế có thể thiết lập và truy xuất các thuộc tính bảo mật từ
các gói mạng.  Nó được thiết kế để sử dụng bởi các nhà phát triển LSM muốn tạo ra
sử dụng một cơ sở mã chung cho một số giao thức ghi nhãn gói khác nhau.
Mô-đun bảo mật NetLabel API được định nghĩa trong 'include/net/netlabel.h' nhưng một
tổng quan ngắn gọn được đưa ra dưới đây.

Thuộc tính bảo mật NetLabel
============================

Vì NetLabel hỗ trợ nhiều giao thức ghi nhãn gói và LSM khác nhau
nó sử dụng khái niệm thuộc tính bảo mật để đề cập đến tính bảo mật của gói
nhãn.  Các thuộc tính bảo mật NetLabel được xác định bởi
Cấu trúc 'netlbl_lsm_secattr' trong tệp tiêu đề NetLabel.  Trong nội bộ
Hệ thống con NetLabel chuyển đổi các thuộc tính bảo mật thành và từ chính xác
nhãn gói cấp thấp tùy thuộc vào thời gian xây dựng và thời gian chạy NetLabel
cấu hình.  Việc dịch NetLabel tùy thuộc vào nhà phát triển LSM
thuộc tính bảo mật vào bất kỳ định danh bảo mật nào đang được sử dụng cho chúng.
đặc biệt là LSM.

Hoạt động của giao thức NetLabel LSM
================================

Đây là những chức năng cho phép nhà phát triển LSM thao tác với nhãn
trên các gói đi cũng như đọc nhãn trên các gói đến.  Chức năng
tồn tại để hoạt động trực tiếp trên cả socket cũng như sk_buffs.  Những cao này
các chức năng cấp độ được chuyển thành các hoạt động giao thức cấp thấp dựa trên cách thức
quản trị viên đã cấu hình hệ thống con NetLabel.

Hoạt động bộ đệm ánh xạ nhãn NetLabel
=======================================

Tùy thuộc vào cấu hình chính xác, việc dịch giữa các gói mạng
nhãn và mã định danh bảo mật LSM nội bộ có thể tốn thời gian.  các
Bộ đệm ánh xạ nhãn NetLabel là một cơ chế bộ nhớ đệm có thể được sử dụng để
bỏ qua phần lớn chi phí này sau khi lập bản đồ.  Một khi
LSM đã nhận được một gói, sử dụng NetLabel để giải mã các thuộc tính bảo mật của nó,
và dịch các thuộc tính bảo mật thành mã định danh nội bộ LSM là LSM
có thể sử dụng các chức năng bộ nhớ đệm NetLabel để liên kết nội bộ LSM
mã định danh có nhãn của gói mạng.  Điều này có nghĩa là trong tương lai
khi một gói đến khớp với giá trị được lưu trong bộ nhớ cache thì không chỉ nội bộ
Cơ chế dịch NetLabel bị bỏ qua nhưng cơ chế dịch LSM vẫn
cũng được bỏ qua, điều này sẽ giúp giảm đáng kể chi phí.
