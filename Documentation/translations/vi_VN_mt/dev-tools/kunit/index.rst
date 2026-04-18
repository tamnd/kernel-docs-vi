.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/dev-tools/kunit/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
KUnit - Kiểm tra đơn vị hạt nhân Linux
=================================

.. toctree::
	:maxdepth: 2
	:caption: Contents:

	start
	architecture
	run_wrapper
	run_manual
	usage
	api/index
	style
	faq
	running_tips

Phần này trình bày chi tiết về khung thử nghiệm đơn vị hạt nhân.

Giới thiệu
============

KUnit (Khung kiểm tra đơn vị hạt nhân) cung cấp một khung chung cho
kiểm tra đơn vị trong nhân Linux. Sử dụng KUnit, bạn có thể xác định các nhóm
của các trường hợp thử nghiệm được gọi là bộ thử nghiệm. Các bài kiểm tra chạy trên kernel boot
nếu được tích hợp sẵn hoặc tải dưới dạng mô-đun. KUnit tự động gắn cờ và báo cáo
trường hợp kiểm tra thất bại trong nhật ký kernel. Kết quả kiểm tra xuất hiện trong
ZZ0000ZZ.
Nó được lấy cảm hứng từ JUnit, unittest.mock của Python và GoogleTest/GoogleMock
(Khung kiểm tra đơn vị C++).

Các bài kiểm tra KUnit là một phần của kernel, được viết bằng C (lập trình)
ngôn ngữ và các phần kiểm tra của quá trình triển khai Kernel (ví dụ: C
chức năng ngôn ngữ). Không bao gồm thời gian xây dựng, từ khi gọi đến
hoàn thành, KUnit có thể chạy khoảng 100 bài kiểm tra trong vòng chưa đầy 10 giây.
KUnit có thể kiểm tra bất kỳ thành phần kernel nào, ví dụ: hệ thống tệp, hệ thống
cuộc gọi, quản lý bộ nhớ, trình điều khiển thiết bị, v.v.

KUnit tuân theo phương pháp thử nghiệm hộp trắng. Bài kiểm tra có quyền truy cập vào
chức năng hệ thống nội bộ. KUnit chạy trong không gian kernel và không
bị giới hạn ở những thứ tiếp xúc với không gian người dùng.

Ngoài ra, KUnit còn có kunit_tool, tập lệnh (ZZ0001ZZ)
cấu hình nhân Linux, chạy thử nghiệm KUnit trong QEMU hoặc UML
(ZZ0000ZZ),
phân tích kết quả kiểm tra và
hiển thị chúng theo cách thân thiện với người dùng.

Đặc trưng
--------

- Cung cấp một khuôn khổ để viết bài kiểm tra đơn vị.
- Chạy thử nghiệm trên mọi kiến ​​trúc kernel.
- Chạy thử nghiệm tính bằng mili giây.

Điều kiện tiên quyết
-------------

- Bất kỳ phần cứng tương thích với nhân Linux.
- Đối với Kernel đang thử nghiệm, Linux kernel phiên bản 5.5 trở lên.

Kiểm tra đơn vị
============

Kiểm thử đơn vị kiểm tra một đơn vị mã riêng biệt. Một bài kiểm tra đơn vị là tốt nhất
mức độ chi tiết của việc kiểm tra và cho phép tất cả các đường dẫn mã có thể được kiểm tra trong
mã đang được thử nghiệm. Điều này có thể thực hiện được nếu mã đang được kiểm tra nhỏ và không
có bất kỳ sự phụ thuộc bên ngoài nào nằm ngoài tầm kiểm soát của bài kiểm tra như phần cứng.


Viết bài kiểm tra đơn vị
----------------

Để viết bài kiểm thử đơn vị tốt, có một mẫu đơn giản nhưng hiệu quả:
Sắp xếp-Hành động-Khẳng định. Đây là một cách tuyệt vời để cấu trúc các ca kiểm thử và
xác định trình tự thực hiện các thao tác.

- Sắp xếp đầu vào và mục tiêu: Khi bắt đầu kiểm thử, sắp xếp dữ liệu
  cho phép một chức năng hoạt động. Ví dụ: khởi tạo một câu lệnh hoặc
  đối tượng.
- Hành động theo hành vi mục tiêu: Gọi hàm/mã của bạn đang được kiểm tra.
- Khẳng định kết quả mong đợi: Xác minh rằng kết quả (hoặc trạng thái kết quả) là như
  mong đợi.

Ưu điểm của thử nghiệm đơn vị
-----------------------

- Tăng tốc độ test và phát triển về lâu dài.
- Phát hiện lỗi ở giai đoạn đầu và do đó giảm chi phí sửa lỗi
  so với kiểm thử chấp nhận.
- Cải thiện chất lượng mã.
- Khuyến khích viết mã có thể kiểm tra được.

Đọc thêm ZZ0000ZZ.

Làm cách nào để sử dụng nó?
================

Bạn có thể tìm thấy hướng dẫn từng bước để viết và chạy thử nghiệm KUnit trong
Tài liệu/dev-tools/kunit/start.rst

Ngoài ra, vui lòng xem qua phần còn lại của tài liệu KUnit,
hoặc để thử nghiệm với tools/testing/kunit/kunit.py và thử nghiệm ví dụ bên dưới
lib/kunit/kunit-example-test.c

Chúc bạn thử nghiệm vui vẻ!