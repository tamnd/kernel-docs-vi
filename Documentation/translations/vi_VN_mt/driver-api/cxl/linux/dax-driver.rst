.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/linux/dax-driver.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================
Hoạt động của trình điều khiển DAX
==================================
Trình điều khiển ZZ0000ZZ ban đầu được thiết kế để cung cấp
cơ chế truy cập giống bộ nhớ tới các thiết bị khối giống bộ nhớ.  Đó là
được mở rộng để hỗ trợ các Thiết bị bộ nhớ CXL, cung cấp các thiết bị được người dùng định cấu hình
các thiết bị bộ nhớ.

Hệ thống con CXL phụ thuộc vào hệ thống con DAX để:

- Tạo giao diện giống như tệp cho vùng người dùng thông qua ZZ0000ZZ hoặc
- Tham gia giao diện cắm nóng bộ nhớ để thêm bộ nhớ CXL vào bộ cấp phát trang.

Hệ thống con DAX thể hiện khả năng này thông qua trình điều khiển ZZ0000ZZ.
ZZ0001ZZ cung cấp bản dịch giữa CXL ZZ0002ZZ và
một chiếc ZZ0003ZZ.

Thiết bị DAX
============
ZZ0002ZZ là một giao diện giống như tệp được hiển thị trong ZZ0000ZZ. A
Vùng bộ nhớ được hiển thị qua thiết bị dax có thể được truy cập thông qua phần mềm người dùng
thông qua lệnh gọi hệ thống ZZ0001ZZ.  Kết quả là ánh xạ trực tiếp tới
Dung lượng CXL trong các bảng trang của tác vụ.

Người dùng muốn xử lý việc phân bổ bộ nhớ CXL theo cách thủ công nên sử dụng tính năng này
giao diện.

chuyển đổi kmem
===============
Trình điều khiển ZZ0000ZZ chuyển đổi ZZ0002ZZ thành một loạt ZZ0003ZZ do ZZ0001ZZ quản lý.  Năng lực này
sẽ được hiển thị với bộ cấp phát trang kernel trong bộ nhớ do người dùng chọn
khu.

Cài đặt ZZ0000ZZ (cả cục bộ và toàn cầu của thiết bị DAX)
chỉ ra nơi kernell sẽ phân bổ các bộ mô tả ZZ0001ZZ
vì ký ức này sẽ đến từ đâu.  Nếu ZZ0002ZZ được đặt, bộ nhớ
hotplug sẽ dành một phần dung lượng khối bộ nhớ để phân bổ
folio. Nếu không được đặt, bộ nhớ sẽ được phân bổ thông qua ZZ0003ZZ bình thường
phân bổ - và kết quả là rất có thể sẽ nằm ở nút NUM cục bộ của
CPU thực hiện thao tác cắm nóng.