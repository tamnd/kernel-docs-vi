.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/acpi_power_meter.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Power_meter trình điều khiển hạt nhân
=====================================

Trình điều khiển này nói chuyện với đồng hồ đo điện ACPI 4.0.

Các hệ thống được hỗ trợ:

* Bất kỳ hệ thống nào gần đây có ACPI 4.0.

Tiền tố: 'power_meter'

Bảng dữ liệu: ZZ0000ZZ phần 10.4.

Tác giả: Darrick J. Wong

Sự miêu tả
-----------

Trình điều khiển này triển khai hỗ trợ đọc cảm biến cho các đồng hồ đo điện ở
thông số ACPI 4.0 (Chương 10.4).  Các thiết bị này có một bộ đơn giản gồm
các tính năng--đồng hồ đo điện trả về mức sử dụng năng lượng trung bình trên một thiết bị có thể định cấu hình
khoảng thời gian, cơ chế giới hạn tùy chọn và một số điểm dừng.  các
Giao diện sysfs phù hợp với thông số kỹ thuật được nêu trong phần "Nguồn"
của Tài liệu/hwmon/sysfs-interface.rst.

Tính năng đặc biệt
------------------

Núm ZZ0000ZZ cho biết nguồn điện có phải là pin hay không.
Cả ZZ0001ZZ phải được đặt trước khi các điểm ngắt hoạt động.
Khi cả hai đều được thiết lập, một sự kiện ACPI sẽ được phát trên liên kết mạng ACPI
socket và thông báo thăm dò ý kiến sẽ được gửi đến địa chỉ thích hợp
Tệp hệ thống ZZ0002ZZ.

Hiển thị các trường ZZ0000ZZ
các chuỗi tùy ý mà ACPI cung cấp cùng với đồng hồ đo.  Các biện pháp/thư mục
chứa các liên kết tượng trưng đến các thiết bị mà đồng hồ này đo lường.

Một số máy tính có khả năng thực thi giới hạn nguồn trong phần cứng.  Nếu đây là
trong trường hợp này, ZZ0000ZZ và các tệp sysfs liên quan sẽ xuất hiện.
Để biết thông tin về cách bật tính năng nắp nguồn, hãy tham khảo phần mô tả
của tùy chọn "force_on_cap" trong chương "Tham số mô-đun".
Để sử dụng đúng tính năng power cap, bạn cần đặt giá trị phù hợp
(tính bằng microWatt) vào các tệp sysfs ZZ0001ZZ.
Giá trị phải nằm trong phạm vi giữa giá trị tối thiểu tại ZZ0002ZZ
và giá trị tối đa tại ZZ0003ZZ.

Khi mức tiêu thụ điện năng trung bình vượt quá giới hạn, sự kiện ACPI sẽ xảy ra
phát trên ổ cắm sự kiện netlink và thông báo thăm dò ý kiến sẽ được gửi đến
tệp ZZ0000ZZ thích hợp để cho biết rằng việc giới hạn đã bắt đầu và
phần cứng đã thực hiện hành động để giảm mức tiêu thụ điện năng.  Nhiều khả năng điều này sẽ
dẫn đến hiệu suất giảm.

Có một số thông báo ACPI khác có thể được gửi bằng chương trình cơ sở.  trong
trong mọi trường hợp, sự kiện ACPI sẽ được phát trên ổ cắm sự kiện liên kết mạng ACPI dưới dạng
cũng như được gửi dưới dạng thông báo thăm dò tới tệp sysfs.  Các sự kiện như
sau:

ZZ0000ZZ sẽ được thông báo nếu phần sụn thay đổi nắp nguồn.
ZZ0001ZZ sẽ được thông báo nếu phần sụn thay đổi giá trị trung bình
khoảng.

Thông số mô-đun
-----------------

* Force_cap_on: bool
                        Buộc bật tính năng giới hạn nguồn để chỉ định
                        giới hạn trên của mức tiêu thụ điện năng của hệ thống.

Theo mặc định, tính năng giới hạn nguồn điện của trình điều khiển chỉ
                        được kích hoạt trên các sản phẩm IBM.
                        Do đó, trên các hệ thống khác hỗ trợ giới hạn nguồn điện,
                        bạn sẽ cần phải sử dụng tùy chọn để kích hoạt nó.

Lưu ý: giới hạn nguồn điện là tính năng có thể không an toàn.
                        Vui lòng kiểm tra thông số kỹ thuật của nền tảng để đảm bảo
                        giới hạn đó được hỗ trợ trước khi sử dụng tùy chọn này.
