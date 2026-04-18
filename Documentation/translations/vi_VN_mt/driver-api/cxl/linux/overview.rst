.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/linux/overview.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========
Tổng quan
=========

Phần này trình bày quy trình cấu hình của thiết bị bộ nhớ CXL Type-3,
và cuối cùng nó được hiển thị như thế nào với người dùng dưới dạng thiết bị ZZ0000ZZ hoặc
các trang bộ nhớ bình thường thông qua bộ cấp phát trang của kernel.

Các phần được đánh dấu bằng dấu đầu dòng là các điểm mà tại đó các đối tượng kernel nhất định
được tạo ra.

1) Khởi động sớm

a) Các tham số BIOS, bản dựng và khởi động

i) EFI_MEMORY_SP
    ii) CONFIG_EFI_SOFT_RESERVE
    iii) CONFIG_MHP_DEFAULT_ONLINE_TYPE
    iv) nosoftreserve

b) Tạo bản đồ bộ nhớ

i) Bản đồ bộ nhớ EFI / E820 được tư vấn cho dự trữ mềm

* Bộ nhớ CXL được dành riêng để trình điều khiển CXL xử lý

* Tài nguyên IO dự trữ mềm được tạo cho mục nhập CFMWS

c) Tạo nút NUMA

* Các nút được tạo từ các miền lân cận ACPI CEDT CFMWS và SRAT (PXM)

d) Tạo tầng bộ nhớ

* Memory_tier mặc định được tạo với tất cả các nút.

e) Phân bổ bộ nhớ liền kề

* Mọi CMA được yêu cầu đều được phân bổ từ các nút Trực tuyến

f) Ban đầu kết thúc, trình điều khiển bắt đầu thăm dò

2) Trình điều khiển ACPI và PCI

a) Phát hiện thiết bị PCI là CXL, đánh dấu thiết bị để thăm dò bằng trình điều khiển CXL

3) Hoạt động của trình điều khiển CXL

a) Tạo thiết bị cơ sở

* đã tạo các thiết bị root, port và memdev
    * CEDT CFMWS Tạo tài nguyên IO

b) Tạo bộ giải mã

* đã tạo bộ giải mã root, switch và endpoint

c) Tạo thiết bị logic

* đã tạo vùng nhớ và thiết bị điểm cuối

d) Các thiết bị được liên kết với nhau

* Nếu bộ giải mã tự động (bộ giải mã được lập trình BIOS), trình điều khiển sẽ xác thực
      cấu hình, xây dựng liên kết và khóa cấu hình tại thời điểm thăm dò.

* Nếu do người dùng định cấu hình, xác thực và liên kết được xây dựng tại
      thời gian cam kết giải mã.

e) Các vùng được hiển thị dưới dạng vùng DAX

* dax_zone đã được tạo

* Thiết bị DAX được tạo thông qua trình điều khiển DAX

4) Hoạt động của trình điều khiển DAX

a) Trình điều khiển DAX hiển thị vùng DAX dưới dạng một trong hai chế độ thiết bị dax

* kmem - thiết bị dax được chuyển đổi thành khối bộ nhớ cắm nóng

* DAX kmem Tạo tài nguyên IO

* hmem - thiết bị dax được để lại dưới dạng daxdev để được truy cập dưới dạng tệp.

* Nếu hmm, hành trình kết thúc tại đây.

b) DAX kmem hiển thị vùng bộ nhớ vào Memory Hotplug để thêm vào trang
     cấp phát là "bộ nhớ được quản lý bởi trình điều khiển"

5) Cắm nóng bộ nhớ

a) thành phần mhp hiển thị vùng bộ nhớ thiết bị dax dưới dạng nhiều bộ nhớ
     chặn vào bộ cấp phát trang

* các khối xuất hiện trong ZZ0000ZZ và được liên kết với nút NUMA

b) các khối được trực tuyến vào vùng được yêu cầu (NORMAL hoặc MOVABLE)

* Bộ nhớ được đánh dấu là "Trình điều khiển được quản lý" để tránh kexec sử dụng nó làm vùng
      để cập nhật kernel