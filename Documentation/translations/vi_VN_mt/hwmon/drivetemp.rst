.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/drivetemp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Nhiệt độ ổ đĩa trình điều khiển hạt nhân
========================================


Tài liệu tham khảo
------------------

ANS T13/1699-D
Công nghệ thông tin - AT Bản đính kèm 8 - Bộ lệnh ATA/ATAPI (ATA8-ACS)

Dự án ANS T10/BSR INCITS 513
Công nghệ thông tin - Các lệnh chính SCSI - 4 (SPC-4)

Dự án ANS INCITS 557
Công nghệ thông tin - Dịch thuật SCSI/ATA - 5 (SAT-5)


Sự miêu tả
-----------

Trình điều khiển này hỗ trợ báo cáo nhiệt độ của đĩa và trạng thái rắn
truyền động có cảm biến nhiệt độ.

Nếu được hỗ trợ, nó sẽ sử dụng tính năng ATA SCT Command Transport để đọc
nhiệt độ ổ đĩa hiện tại và, nếu có, giới hạn nhiệt độ
cũng như nhiệt độ tối thiểu và tối đa lịch sử. Nếu lệnh SCT
Vận chuyển không được hỗ trợ, trình điều khiển sử dụng thuộc tính SMART để đọc
nhiệt độ ổ đĩa.


Lưu ý sử dụng
-------------

Việc đọc nhiệt độ ổ đĩa có thể đặt lại bộ đếm thời gian quay xuống trên một số ổ đĩa.
Điều này đã được quan sát thấy với các ổ đĩa WD120EFAX, nhưng có thể được nhìn thấy với các ổ đĩa khác
ổ đĩa là tốt. Hành vi tương tự được quan sát thấy nếu 'hdtemp' hoặc 'smartd'
công cụ được sử dụng để truy cập vào ổ đĩa.
Với ổ WD120EFAX, đọc nhiệt độ ổ bằng drivetemp
trình điều khiển vẫn có thể sử dụng được _sau_ nó đã chuyển sang chế độ chờ và
việc đọc nhiệt độ ổ đĩa ở chế độ này sẽ không làm cho ổ đĩa bị
thay đổi chế độ của nó (có nghĩa là ổ đĩa sẽ không quay). Không biết có khác không
ổ đĩa trải nghiệm hành vi tương tự.

Một cách giải quyết đã biết đối với ổ WD120EFAX là đọc nhiệt độ ổ ở mức
khoảng thời gian lớn hơn hai lần thời gian quay xuống. Nếu không thì ổ đĩa bị ảnh hưởng
sẽ không bao giờ quay xuống.


Mục nhập hệ thống
-----------------

Chỉ có thuộc tính temp1_input luôn có sẵn. Các thuộc tính khác là
chỉ khả dụng nếu được ổ đĩa báo cáo. Tất cả nhiệt độ được báo cáo trong
mili độ C.

=================================================================================
temp1_input Nhiệt độ ổ đĩa hiện tại
temp1_lcrit Giới hạn nhiệt độ tối thiểu. Vận hành thiết bị bên dưới
			nhiệt độ này có thể gây ra thiệt hại vật lý cho
			thiết bị.
temp1_min Giới hạn hoạt động liên tục tối thiểu được đề xuất
temp1_max Nhiệt độ hoạt động liên tục tối đa được đề nghị
temp1_crit Giới hạn nhiệt độ tối đa. Vận hành thiết bị trên
			nhiệt độ này có thể gây ra thiệt hại vật lý cho
			thiết bị.
temp1_lowest Nhiệt độ tối thiểu thấy được trong chu kỳ điện này
temp1_highest Nhiệt độ tối đa thấy được trong chu kỳ cấp nguồn này
=================================================================================