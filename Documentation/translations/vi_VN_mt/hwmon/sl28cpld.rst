.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/sl28cpld.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân sl28cpld
==================================

Chip được hỗ trợ:

* Kontron sl28cpld

Tiền tố: 'sl28cpld'

Bảng dữ liệu: không có sẵn

Tác giả: Michael Walle <michael@walle.cc>

Sự miêu tả
-----------

sl28cpld là bộ điều khiển quản lý bo mạch cũng hiển thị phần cứng
bộ điều khiển giám sát. Hiện tại bộ điều khiển này hỗ trợ một quạt duy nhất
người giám sát. Trong tương lai có thể có những hương vị khác và bổ sung thêm
giám sát phần cứng có thể được hỗ trợ.

Người giám sát quạt có một thanh ghi bộ đếm 7 bit và khoảng thời gian truy cập là 1
thứ hai. Nếu bộ đếm 7 bit tràn, người giám sát sẽ tự động
chuyển sang chế độ x8 để hỗ trợ phạm vi đầu vào rộng hơn khi mất
độ chi tiết.

Mục nhập hệ thống
-----------------

Các thuộc tính sau được hỗ trợ.

=====================================================================================
fan1_input Quạt RPM. Giả sử 2 xung trên mỗi vòng quay.
=====================================================================================