.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/misc-devices/dw-xdata-pcie.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================================================================================
Trình điều khiển cho trình tạo lưu lượng truy cập Synopsys DesignWare PCIe (còn được gọi là xData)
==================================================================================================

Chip được hỗ trợ:
Tóm tắt giải pháp nguyên mẫu DesignWare PCIe

Bảng dữ liệu:
Không có sẵn miễn phí

tác giả:
Gustavo Pimentel <gustavo.pimentel@synopsys.com>

Sự miêu tả
-----------

Trình điều khiển này nên được sử dụng làm trình điều khiển phía máy chủ (Root Complex) và Synopsys
Nguyên mẫu DesignWare bao gồm IP này.

Trình điều khiển dw-xdata-pcie có thể được sử dụng để bật/tắt lưu lượng PCIe
máy phát điện theo một trong hai hướng (loại trừ lẫn nhau) bên cạnh việc cho phép
Phân tích hiệu suất liên kết PCIe.

Sự tương tác với trình điều khiển này được thực hiện thông qua tham số mô-đun và
có thể được thay đổi trong thời gian chạy. Trình điều khiển xuất trạng thái lệnh được yêu cầu
thông tin tới ZZ0000ZZ hoặc dmesg.

Ví dụ
-------

Viết TLP tạo lưu lượng truy cập - Root Complex đến hướng Endpoint
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tạo lưu lượng truy cập::

# echo 1 > /sys/class/misc/dw-xdata-pcie.0/write

Nhận thông lượng liên kết tính bằng MB/s::

# cat /sys/class/misc/dw-xdata-pcie.0/write
 204

Dừng giao thông theo bất kỳ hướng nào::

# echo 0 > /sys/class/misc/dw-xdata-pcie.0/write

Đọc tạo lưu lượng TLP - Điểm cuối đến gốc Hướng phức tạp
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tạo lưu lượng truy cập::

# echo 1 > /sys/class/misc/dw-xdata-pcie.0/read

Nhận thông lượng liên kết tính bằng MB/s::

# cat /sys/class/misc/dw-xdata-pcie.0/read
 199

Dừng giao thông theo bất kỳ hướng nào::

# echo 0 > /sys/class/misc/dw-xdata-pcie.0/read
