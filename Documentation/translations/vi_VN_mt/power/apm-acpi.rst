.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/power/apm-acpi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============
APM hay ACPI?
=============

Nếu bạn có hệ thống máy chủ, máy tính để bàn hoặc thiết bị di động x86 tương đối gần đây,
rất có thể là nó hỗ trợ Quản lý năng lượng nâng cao (APM) hoặc
Cấu hình nâng cao và giao diện nguồn (ACPI).  ACPI là phiên bản mới hơn
của hai công nghệ và đặt việc quản lý năng lượng vào tay của
hệ điều hành, cho phép quản lý năng lượng thông minh hơn
có thể thực hiện được với APM được điều khiển bởi BIOS.

Cách tốt nhất để xác định cái nào, nếu hệ thống của bạn hỗ trợ, là
xây dựng hạt nhân có bật cả ACPI và APM (kể từ 2.3.x ACPI là
được bật theo mặc định).  Nếu tìm thấy triển khai ACPI đang hoạt động,
Trình điều khiển ACPI sẽ ghi đè và vô hiệu hóa APM, nếu không thì trình điều khiển APM
sẽ được sử dụng.

Không, rất tiếc, bạn không thể bật và chạy cả ACPI và APM ở
một lần.  Một số người triển khai ACPI hoặc APM bị hỏng
muốn sử dụng cả hai để có được bộ đầy đủ các tính năng hoạt động, nhưng bạn
đơn giản là không thể trộn lẫn và kết hợp cả hai.  Chỉ có một quản lý năng lượng
giao diện có thể được điều khiển của máy cùng một lúc.  Hãy nghĩ về nó ..

Daemon không gian người dùng
------------------
Cả APM và ACPI đều dựa vào daemon không gian người dùng, apmd và acpid
tương ứng, có đầy đủ chức năng.  Có được cả hai thứ này
daemon từ bản phân phối Linux của bạn hoặc từ Internet (xem bên dưới)
và hãy chắc chắn rằng chúng được khởi động đôi khi trong quá trình khởi động hệ thống.
Hãy tiếp tục và bắt đầu cả hai.  Nếu ACPI hoặc APM không có sẵn trên thiết bị của bạn
hệ thống, daemon liên quan sẽ thoát ra một cách duyên dáng.

================================================
  apmd ZZ0000ZZ
  acpid ZZ0001ZZ
  ================================================
