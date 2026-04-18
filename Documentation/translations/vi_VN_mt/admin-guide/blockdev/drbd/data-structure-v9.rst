.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/blockdev/drbd/data-structure-v9.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
cấu trúc dữ liệu hạt nhân cho DRBD-9
================================

Phần này mô tả cấu trúc dữ liệu trong kernel cho DRBD-9. Bắt đầu với
Linux v3.14 chúng tôi đang tổ chức lại DRBD để sử dụng cấu trúc dữ liệu này.

Cấu trúc dữ liệu cơ bản
====================

Một nút có một số tài nguyên DRBD.  Mỗi tài nguyên như vậy có một số
thiết bị (còn gọi là khối lượng) và kết nối với các nút khác ("nút ngang hàng"). Mỗi DRBD
thiết bị được đại diện bởi một thiết bị khối cục bộ.

Các đối tượng DRBD được kết nối với nhau để tạo thành ma trận như mô tả bên dưới; một
Đối tượng drbd_peer_device nằm ở mỗi giao điểm giữa drbd_device và
drbd_connection::

/--------------+--------------+.....+--------------\
  Thiết bị ZZ0000ZZ Thiết bị ZZ0001ZZ |
  +--------------+--------------+.....+---------------+
  ZZ0002ZZ thiết bị ngang hàng ZZ0003ZZ thiết bị ngang hàng |
  +--------------+--------------+.....+---------------+
  : : : : :
  : : : : :
  +--------------+--------------+.....+---------------+
  ZZ0004ZZ thiết bị ngang hàng ZZ0005ZZ thiết bị ngang hàng |
  \--------------+--------------+.....+--------------/

Trong bảng này, theo chiều ngang, các thiết bị có thể được truy cập từ các tài nguyên bằng cách
số lượng.  Tương tự như vậy, các thiết bị ngang hàng có thể được truy cập từ các kết nối bằng
số khối của chúng.  Các vật thể theo hướng thẳng đứng được kết nối bằng đôi
danh sách liên kết.  Có các con trỏ ngược từ các thiết bị ngang hàng tới các kết nối của chúng
thiết bị và từ các kết nối, thiết bị tới tài nguyên của chúng.

Tất cả các tài nguyên đều nằm trong danh sách liên kết đôi drbd_resources.  Ngoài ra, tất cả
các thiết bị có thể được truy cập bằng số thiết bị phụ của chúng thông qua idr drbd_devices.

Các đối tượng drbd_resource, drbd_connection và drbd_device là tham chiếu
được tính.  Các đối tượng ngang hàng chỉ dùng để thiết lập các liên kết giữa
thiết bị và kết nối; thời gian tồn tại của chúng được xác định bởi thời gian tồn tại của
thiết bị và kết nối mà họ tham chiếu.
