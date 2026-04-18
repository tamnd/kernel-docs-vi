.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/ftsteutates.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân ftsteutates
=========================

Chip được hỗ trợ:

* FTS Teutates

Tiền tố: 'ftsteutates'

Địa chỉ được quét: I2C 0x73 (7-Bit)

Tác giả: Thilo Cestonaro <thilo.cestonaro@ts.fujitsu.com>


Sự miêu tả
-----------

BMC Teutates là thế hệ thứ mười một của Hệ thống ưu việt
giải pháp giám sát và quản lý nhiệt. Nó được xây dựng trên cơ sở
chức năng của BMC Theseus và chứa một số tính năng mới và
cải tiến. Nó có thể giám sát tới 4 điện áp, 16 nhiệt độ và
8 người hâm mộ. Nó cũng chứa một cơ quan giám sát tích hợp hiện đang
được thực hiện trong trình điều khiển này.

Thuộc tính ZZ0000ZZ hiển thị cảm biến nhiệt độ nào
hiện đang điều hành kênh fan nào. Giá trị này có thể thay đổi linh hoạt
trong thời gian chạy tùy thuộc vào cảm biến nhiệt độ được chọn bởi
mạch điều khiển quạt.

4 điện áp yêu cầu hệ số nhân dành riêng cho bo mạch, vì BMC có thể
chỉ đo điện áp lên tới 3,3V và do đó dựa vào các bộ chia điện áp.
Tham khảo hướng dẫn sử dụng bo mạch chủ của bạn để biết chi tiết.

Để xóa cảnh báo nhiệt độ hoặc quạt, hãy thực hiện lệnh sau với
đường dẫn chính xác đến tập tin cảnh báo::

echo 0 >XXXX_alarm

Thông số kỹ thuật của chip có thể tìm thấy tại ZZ0000ZZ (tên người dùng = "ẩn danh", không cần mật khẩu)
theo đường dẫn sau:

/Services/Software_Tools/Linux_SystemMonitoring_Watchdog_GPIO/BMC-Teutates_Specification_V1.21.pdf
