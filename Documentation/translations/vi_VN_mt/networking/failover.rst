.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/failover.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========
FAILOVER
========

Tổng quan
=========

Mô-đun chuyển đổi dự phòng cung cấp giao diện chung cho trình điều khiển song song
để đăng ký một netdev và một tập hợp các hoạt động có phiên bản chuyển đổi dự phòng. hoạt động
được sử dụng làm trình xử lý sự kiện được gọi để xử lý đăng ký netdev/
sự kiện hủy đăng ký/thay đổi liên kết/thay đổi tên trên thiết bị ethernet pci phụ
có cùng địa chỉ mac với netdev chuyển đổi dự phòng.

Điều này cho phép các trình điều khiển song song sử dụng VF làm độ trễ thấp được tăng tốc
đường dẫn dữ liệu. Nó cũng cho phép di chuyển trực tiếp các máy ảo có VF được gắn trực tiếp bằng cách
không thể chuyển sang đường dẫn dữ liệu ảo ảo khi rút phích cắm VF.