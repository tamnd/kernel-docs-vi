.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/fwctl/pds_fwctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
trình điều khiển pds fwctl
==========================

:Tác giả: Shannon Nelson

Tổng quan
=========

Thiết bị PDS Core cung cấp dịch vụ fwctl thông qua
thiết bị phụ trợ có tên pds_core.fwctl.N.  Trình điều khiển pds_fwctl liên kết với
thiết bị này và tự đăng ký với hệ thống con fwctl.  Kết quả
giao diện không gian người dùng được sử dụng bởi một ứng dụng là một phần của
Gói phần mềm AMD Pensando dành cho Thẻ dịch vụ phân phối (DSC).

Trình điều khiển pds_fwctl có ít kiến ​​thức về phần bên trong của phần sụn.
Nó chỉ biết cách gửi lệnh thông qua hàng đợi tin nhắn của pds_core tới
chương trình cơ sở cho các yêu cầu fwctl.  Tập hợp các hoạt động fwctl có sẵn
phụ thuộc vào phần sụn trong DSC và ứng dụng vùng người dùng
Phiên bản phải phù hợp với phần sụn để chúng có thể nói chuyện với nhau.

Khi một kết nối được tạo ra, trình điều khiển pds_fwctl sẽ yêu cầu từ
phần sụn một danh sách các điểm cuối đối tượng phần sụn và đối với mỗi điểm cuối,
trình điều khiển yêu cầu danh sách các hoạt động cho điểm cuối đó.

Mỗi mô tả hoạt động bao gồm một thuộc tính lệnh được xác định phần sụn
ánh xạ tới các cấp độ phạm vi FWCTL.  Trình điều khiển dịch các phần sụn đó
các giá trị vào các giá trị phạm vi FWCTL, sau đó có thể được sử dụng để lọc
yêu cầu của người dùng trong phạm vi.

pds_fwctl Người dùng API
========================

Mỗi yêu cầu RPC bao gồm điểm cuối đích và id hoạt động, đồng thời trong
và ra độ dài bộ đệm và con trỏ.  Người lái xe xác minh sự tồn tại
của điểm cuối và hoạt động được yêu cầu, sau đó kiểm tra phạm vi yêu cầu
so với phạm vi yêu cầu của hoạt động.  Sau đó yêu cầu được đặt
cùng với dữ liệu yêu cầu và được gửi qua hàng đợi tin nhắn của pds_core
vào phần sụn và kết quả được trả về cho người gọi.

Điểm cuối, hoạt động và nội dung bộ đệm của RPC được xác định bởi
gói chương trình cơ sở cụ thể trong thiết bị, gói này khác nhau tùy theo
cấu hình sản phẩm có sẵn.  Các chi tiết có sẵn trong
tài liệu sản phẩm cụ thể SDK.