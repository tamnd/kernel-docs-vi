.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/vfio-pci-device-specific-driver-acceptance.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Tiêu chí chấp nhận cho các biến thể trình điều khiển cụ thể của thiết bị vfio-pci
================================================================

Tổng quan
--------
Trình điều khiển vfio-pci tồn tại dưới dạng trình điều khiển bất khả tri của thiết bị bằng cách sử dụng
hệ thống IOMMU và dựa vào độ bền của lỗi nền tảng
xử lý để cung cấp quyền truy cập thiết bị bị cô lập vào không gian người dùng.  Trong khi
Trình điều khiển vfio-pci bao gồm một số hỗ trợ dành riêng cho thiết bị, hơn nữa
không có tiện ích mở rộng cho các tính năng cụ thể của thiết bị nâng cao hơn
bền vững.  Do đó, trình điều khiển vfio-pci đã tách ra
vfio-pci-core dưới dạng thư viện có thể được sử dụng lại để triển khai các tính năng
yêu cầu kiến thức cụ thể về thiết bị, ví dụ. thiết bị lưu và tải
nhà nước nhằm mục đích hỗ trợ di cư.

Để hỗ trợ các tính năng như vậy, dự kiến một số thiết bị cụ thể
các biến thể có thể tương tác với các thiết bị gốc (ví dụ: SR-IOV PF để hỗ trợ
người dùng được chỉ định VF) hoặc các tiện ích mở rộng khác có thể không có
có thể truy cập thông qua trình điều khiển cơ sở vfio-pci.  Tác giả của các trình điều khiển như vậy
nên cẩn thận không tạo ra các giao diện có thể khai thác thông qua những
tương tác hoặc cho phép dữ liệu không gian người dùng không được kiểm tra có hiệu lực
vượt quá phạm vi của thiết bị được chỉ định.

Do đó, việc gửi trình điều khiển mới phải được phê duyệt thông qua
đăng xuất/ack/đánh giá/etc cho bất kỳ tương tác nào với trình điều khiển chính.
Ngoài ra, người lái xe nên cố gắng cung cấp đủ
tài liệu dành cho người đánh giá để hiểu cụ thể về thiết bị
các tiện ích mở rộng, ví dụ như trong trường hợp dữ liệu di chuyển, làm thế nào
trạng thái thiết bị được cấu tạo và sử dụng, phần nào không được
có sẵn cho người dùng thông qua vfio-pci, những biện pháp bảo vệ nào tồn tại để xác thực
dữ liệu, v.v. Ở mức độ đó, các tác giả cũng nên mong đợi
yêu cầu đánh giá từ ít nhất một trong những người đánh giá được liệt kê, ngoài ra
đến người duy trì vfio tổng thể.