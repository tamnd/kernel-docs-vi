.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/wbrf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
WBRF - Băng tần Wifi RFI Giảm nhẹ
=================================

Do những hạn chế về điện và cơ khí trong một số thiết kế nền tảng nhất định
có thể có sự can thiệp của các sóng hài công suất tương đối cao của
đồng hồ bộ nhớ GPU với các dải tần số mô-đun vô tuyến cục bộ được sử dụng bởi
một số băng tần Wifi nhất định.

Để giảm thiểu khả năng gây nhiễu của RFI, các nhà sản xuất có thể quảng cáo
tần suất sử dụng và người tiêu dùng có thể sử dụng thông tin này để tránh sử dụng
những tần số này cho các tính năng nhạy cảm.

Khi một nền tảng được biết là có vấn đề này với bất kỳ thiết bị nào được chứa,
nhà thiết kế nền tảng sẽ quảng cáo tính khả dụng của tính năng này thông qua
Thiết bị ACPI với phương pháp dành riêng cho thiết bị (_DSM).
* Các nhà sản xuất có _DSM này sẽ có thể quảng cáo tần số đang sử dụng.
* Người tiêu dùng có _DSM này sẽ có thể đăng ký nhận thông báo về
tần số đang sử dụng.

Một số điều khoản chung
==================

Nhà sản xuất: bộ phận có thể tạo ra tần số vô tuyến công suất cao
Người tiêu dùng: thành phần có thể điều chỉnh tần suất sử dụng của nó theo
đáp ứng với tần số vô tuyến của các thành phần khác để giảm thiểu
có thể là RFI.

Để cơ chế hoạt động, những nhà sản xuất đó phải thông báo việc sử dụng tích cực
tần số cụ thể của họ để những người tiêu dùng khác có thể đưa ra quyết định tương đối
điều chỉnh nội bộ khi cần thiết để tránh sự cộng hưởng này.

Giao diện ACPI
==============

Mặc dù ban đầu được sử dụng cho các trường hợp sử dụng wifi + dGPU, giao diện ACPI
có thể được thu nhỏ theo bất kỳ loại thiết bị nào mà nhà thiết kế nền tảng phát hiện ra
có thể gây nhiễu.

GUID được sử dụng cho _DSM là 7B7656CF-DC3D-4C1C-83E9-66E721DE3070.

3 chức năng có sẵn trong _DSM này:

* 0: khám phá các chức năng # of có sẵn
* 1: ghi lại các băng tần RF đang sử dụng
* 2: truy xuất các băng tần RF đang sử dụng

Giao diện lập trình điều khiển
============================

.. kernel-doc:: drivers/platform/x86/amd/wbrf.c

Cách sử dụng mẫu
=============

Dòng chảy dự kiến cho các nhà sản xuất:
1. Trong quá trình thăm dò, hãy gọi ZZ0000ZZ để kiểm tra xem WBRF có
có thể được kích hoạt cho thiết bị.
2. Khi sử dụng một số băng tần, hãy gọi ZZ0001ZZ bằng 'add'
param để những người tiêu dùng khác được thông báo chính xác.
3. Hoặc khi ngừng sử dụng băng tần nào đó, hãy gọi
ZZ0002ZZ với thông số 'xóa' để thông báo cho những người tiêu dùng khác.

Dòng chảy dự kiến cho người tiêu dùng:
1. Trong quá trình thăm dò, hãy gọi ZZ0000ZZ để kiểm tra xem WBRF có
có thể được kích hoạt cho thiết bị.
2. Gọi ZZ0001ZZ để đăng ký nhận thông báo
thay đổi băng tần (thêm hoặc xóa) từ các nhà sản xuất khác.
3. Gọi ZZ0002ZZ ban đầu để lấy
các dải tần hoạt động hiện tại đang được xem xét bởi một số nhà sản xuất có thể phát sóng
thông tin như vậy trước khi người tiêu dùng lên.
4. Khi nhận được thông báo thay đổi băng tần, hãy chạy
ZZ0003ZZ một lần nữa để lấy bản mới nhất
dải tần hoạt động.
5. Trong quá trình dọn dẹp trình điều khiển, hãy gọi ZZ0004ZZ để
hủy đăng ký người thông báo.