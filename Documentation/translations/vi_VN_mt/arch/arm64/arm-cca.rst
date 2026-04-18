.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm64/arm-cca.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
Kiến trúc điện toán bí mật của Arm
========================================

Các hệ thống cánh tay hỗ trợ Tiện ích mở rộng quản lý vương quốc (RME) chứa
phần cứng để cho phép máy khách VM chạy theo cách bảo vệ mã
và dữ liệu của khách từ hypervisor. Nó mở rộng "hai" cũ hơn
world" (Thế giới bình thường và thế giới an toàn) thành bốn thế giới: Bình thường, An toàn,
Cội rễ và cõi. Linux sau đó cũng có thể được chạy với tư cách là khách của màn hình
đang chạy trong thế giới Realm.

Màn hình chạy trong thế giới Realm được gọi là Realm Management
Giám sát (RMM) và triển khai Trình giám sát quản lý vương quốc
đặc điểm kỹ thuật [1]. Màn hình hoạt động hơi giống một bộ ảo hóa (ví dụ: nó chạy
trong EL2 và quản lý các bảng trang ở giai đoạn 2, v.v. của khách truy cập
Realm world), tuy nhiên phần lớn quyền kiểm soát được xử lý bởi một trình ảo hóa
đang chạy trong Thế giới bình thường. Trình ảo hóa Thế giới Bình thường sử dụng Vương quốc
Giao diện quản lý (RMI) được xác định bởi đặc tả RMM để yêu cầu
RMM để thực hiện các thao tác (ví dụ: ánh xạ bộ nhớ hoặc thực thi vCPU).

RMM xác định môi trường cho khách trong đó không gian địa chỉ (IPA)
được chia thành hai. Nửa dưới được bảo vệ - bất kỳ bộ nhớ nào được
Thế giới bình thường và RMM không thể nhìn thấy được ánh xạ ở nửa này
hạn chế những hoạt động mà Thế giới bình thường có thể thực hiện trên bộ nhớ này
(ví dụ: Thế giới bình thường không thể thay thế các trang trong khu vực này nếu không có
sự hợp tác của khách). Nửa trên được chia sẻ, Thế giới bình thường miễn phí
để thực hiện các thay đổi đối với các trang trong khu vực này và có thể mô phỏng MMIO
các thiết bị trong khu vực này cũng vậy.

Một vị khách đang chạy trong Vương quốc cũng có thể liên lạc với RMM bằng cách sử dụng
Giao diện dịch vụ Realm (RSI) để yêu cầu thay đổi trong môi trường của nó hoặc
để thực hiện chứng thực về môi trường của nó. Đặc biệt nó có thể
yêu cầu các khu vực của không gian địa chỉ được bảo vệ được chuyển đổi
giữa 'RAM' và 'EMPTY' (theo một trong hai hướng). Điều này cho phép một Vương quốc
khách từ bỏ ký ức để được trở về Thế giới bình thường, hoặc để
yêu cầu bộ nhớ mới từ Thế giới bình thường.  Nếu không có yêu cầu rõ ràng
từ vị khách của Vương quốc, RMM nếu không sẽ ngăn cản Thế giới bình thường
từ việc thực hiện những thay đổi này.

Linux như một vị khách thực sự
----------------------

Để chạy Linux với tư cách là khách trong Vương quốc, phải cung cấp những thông tin sau
bằng VMM hoặc bằng ZZ0000ZZ chạy trong Vương quốc trước Linux:

* Tất cả RAM được bảo vệ được mô tả cho Linux (bởi DT hoặc ACPI) phải được đánh dấu
   RIPAS RAM trước khi bàn giao quyền kiểm soát cho Linux.

* Các thiết bị MMIO phải không được bảo vệ (ví dụ: được mô phỏng bởi Normal
   World) hoặc được đánh dấu RIPAS DEV.

* Các thiết bị MMIO được Thế giới bình thường mô phỏng và được sử dụng từ rất sớm khi khởi động
   (cụ thể là Earlycon) phải được chỉ định ở nửa trên của IPA.
   Đối với Earlycon, điều này có thể được thực hiện bằng cách chỉ định địa chỉ trên
   dòng lệnh, ví dụ: với kích thước IPA là 33 bit và địa chỉ cơ sở
   của UART được mô phỏng ở 0x1000000: ZZ0000ZZ

* Linux sẽ sử dụng bộ đệm thoát để liên lạc với các thiết bị không được bảo vệ
   thiết bị. Nó sẽ chuyển một số bộ nhớ được bảo vệ sang RIPAS EMPTY và
   mong đợi có thể truy cập các trang không được bảo vệ tại cùng địa chỉ IPA
   nhưng với bộ bit IPA hợp lệ cao nhất. Kỳ vọng là
   VMM sẽ xóa các trang vật lý khỏi ánh xạ được bảo vệ và
   cung cấp các trang đó dưới dạng các trang không được bảo vệ.

Tài liệu tham khảo
----------
[1] ZZ0000ZZ