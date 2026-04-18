.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/nvme/feature-and-quirk-policy.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================================
Tính năng và chính sách khắc phục sự cố của Linux NVMe
======================================================

Tệp này giải thích chính sách được sử dụng để quyết định những gì được hỗ trợ bởi
Trình điều khiển Linux NVMe và những gì không.


Giới thiệu
============

NVM Express là một tập hợp mở các tiêu chuẩn và thông tin.

Trình điều khiển máy chủ Linux NVMe trong trình điều khiển/nvme/host/thiết bị hỗ trợ
triển khai dòng thông số kỹ thuật NVM Express (NVMe), trong đó
Hiện nay bao gồm một số tài liệu:

- đặc điểm kỹ thuật cơ sở NVMe
 - các thông số kỹ thuật của Bộ lệnh khác nhau (ví dụ: Bộ lệnh NVM)
 - các thông số kỹ thuật Vận chuyển khác nhau (ví dụ: PCIe, Kênh sợi quang, RDMA, TCP)
 - đặc tả Giao diện quản lý NVMe

Xem ZZ0000ZZ để biết thông số kỹ thuật NVMe.


Các tính năng được hỗ trợ
==================

NVMe là một bộ thông số kỹ thuật lớn và chứa các tính năng chỉ
hữu ích hoặc phù hợp cho các trường hợp sử dụng cụ thể. Điều quan trọng cần lưu ý là Linux
không nhằm mục đích thực hiện mọi tính năng trong đặc tả.  Mỗi lần bổ sung
tính năng được triển khai giới thiệu nhiều mã hơn, bảo trì nhiều hơn và có khả năng nhiều hơn
lỗi.  Do đó có sự cân bằng cố hữu giữa chức năng và
khả năng bảo trì của trình điều khiển máy chủ NVMe.

Mọi tính năng được triển khai trong trình điều khiển máy chủ Linux NVMe đều phải hỗ trợ
yêu cầu sau:

1. Tính năng này được chỉ định trong phiên bản phát hành của NVMe chính thức
     đặc điểm kỹ thuật hoặc trong Đề xuất kỹ thuật (TP) đã được phê duyệt
     có sẵn trên trang web NVMe. Hoặc nếu nó không liên quan trực tiếp đến
     giao thức trực tuyến, không mâu thuẫn với bất kỳ thông số kỹ thuật NVMe nào.
  2. Không xung đột với kiến trúc Linux cũng như thiết kế của
     Trình điều khiển máy chủ NVMe.
  3. Có đề xuất giá trị rõ ràng, không thể chối cãi và có sự đồng thuận rộng rãi trên toàn thế giới
     cộng đồng.

Các tiện ích mở rộng dành riêng cho nhà cung cấp thường không được hỗ trợ trong máy chủ NVMe
người lái xe.

Chúng tôi thực sự khuyên bạn nên làm việc với Linux NVMe và lớp khối
người bảo trì và nhận phản hồi về những thay đổi đặc điểm kỹ thuật dự định
được trình điều khiển máy chủ Linux NVMe sử dụng để tránh xung đột tại một thời điểm
giai đoạn sau.


Quirks
======

Đôi khi việc triển khai các tiêu chuẩn mở không triển khai chính xác các phần
của các tiêu chuẩn.  Linux sử dụng các đặc điểm dựa trên mã định danh để giải quyết vấn đề đó
lỗi triển khai.  Mục đích của quirks là để giải quyết các vấn đề có sẵn rộng rãi
phần cứng, thường là dành cho người tiêu dùng, mà người dùng Linux không thể sử dụng nếu không có những đặc điểm này.
Thông thường, những triển khai này không hoặc chỉ được thử nghiệm sơ bộ với Linux
bởi nhà sản xuất phần cứng.

Các nhà bảo trì NVMe Linux quyết định đặc biệt xem có nên ngừng triển khai hay không
dựa trên tác động của sự cố đối với người dùng Linux và tác động của nó
khả năng bảo trì của người lái xe.  Nói chung những điều kỳ quặc là giải pháp cuối cùng, nếu không
các bản cập nhật chương trình cơ sở hoặc cách giải quyết khác có sẵn từ nhà cung cấp.

Quirks sẽ không được thêm vào nhân Linux đối với phần cứng không có sẵn
trên thị trường đại chúng.  Phần cứng không đủ điều kiện cho Linux doanh nghiệp
bản phân phối, ChromeOS, Android hoặc những người dùng khác sử dụng nhân Linux
nên được sửa trước khi được xuất xưởng thay vì dựa vào các lỗi của Linux.