.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/occ.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân occ-hwmon
===================================

Chip được hỗ trợ:

* POWER8
  * POWER9

Tác giả: Eddie James <eajames@linux.ibm.com>

Sự miêu tả
-----------

Trình điều khiển này hỗ trợ giám sát phần cứng cho Bộ điều khiển trên chip (OCC)
được nhúng trên bộ xử lý POWER. OCC là thiết bị thu thập và tổng hợp
dữ liệu cảm biến từ bộ xử lý và hệ thống. OCC có thể cung cấp dữ liệu thô
dữ liệu cảm biến cũng như thực hiện quản lý nhiệt và điện năng trên hệ thống.

Phiên bản P8 của trình điều khiển này là trình điều khiển máy khách của I2C. Nó có thể được thăm dò
theo cách thủ công nếu tìm thấy thiết bị tương thích "ibm,p8-occ-hwmon" trong
nút bus I2C thích hợp trong cây thiết bị.

Phiên bản P9 của trình điều khiển này là trình điều khiển máy khách của trình điều khiển OCC dựa trên FSI.
Nó sẽ được trình điều khiển OCC dựa trên FSI tự động kiểm tra.

Mục nhập hệ thống
-----------------

Các thuộc tính sau được hỗ trợ. Tất cả các thuộc tính đều ở chế độ chỉ đọc trừ khi
được chỉ định.

ID cảm biến OCC là một số nguyên đại diện cho mã định danh duy nhất của
cảm biến liên quan đến OCC. Ví dụ, cảm biến nhiệt độ thứ ba
Khe DIMM trong hệ thống có thể có ID cảm biến là 7. Ánh xạ này không khả dụng
tới trình điều khiển thiết bị, do đó phải xuất ID cảm biến nguyên trạng.

Một số mục chỉ xuất hiện với một số phiên bản cảm biến OCC nhất định hoặc chỉ trên
một số OCC nhất định trong hệ thống. Số phiên bản không được xuất cho người dùng
nhưng có thể suy ra.

tạm thời[1-n]_label
	ID cảm biến OCC.

[với cảm biến nhiệt độ phiên bản 1]

tạm thời[1-n]_input
			Nhiệt độ đo được của linh kiện tính bằng mili độ
			độ C.

[với phiên bản cảm biến nhiệt độ >= 2]

tạm thời[1-n]_type
				Loại FRU (Đơn vị có thể thay thế tại hiện trường)
				(được biểu thị bằng số nguyên) cho thành phần
				mà cảm biến này đo được.
    tạm thời[1-n]_fault
				lỗi cảm biến nhiệt độ boolean; 1 để chỉ
				có lỗi hoặc 0 để chỉ ra rằng
				không có lỗi hiện diện.

[với loại == 3 (loại FRU là VRM)]

nhiệt độ [1-n]_alarm
				Boolean báo động nhiệt độ VRM; 1 để chỉ
				báo động, 0 để biểu thị không có báo động

[khác]

tạm thời[1-n]_input
				Nhiệt độ đo được của linh kiện trong
				mili độ C.

tần số[1-n]_label
			ID cảm biến OCC.
tần số [1-n]_input
			Tần số đo được của thành phần tính bằng MHz.
nguồn [1-n]_input
			Chỉ số công suất đo mới nhất của thành phần trong
			microwatt.
sức mạnh [1-n]_trung bình
			Công suất trung bình của thành phần tính bằng microwatt.
sức mạnh [1-n]_average_interval
				Khoảng thời gian mà công suất trung bình
				được thực hiện trong micro giây.

[với phiên bản cảm biến điện < 2]

sức mạnh [1-n]_label
			ID cảm biến OCC.

[với phiên bản cảm biến điện >= 2]

sức mạnh [1-n]_label
			OCC ID cảm biến + ID chức năng + kênh ở dạng
			của một chuỗi, được phân cách bằng dấu gạch dưới, tức là "0_15_1".
			Cả ID hàm và kênh đều là số nguyên
			xác định thêm cảm biến công suất.

[với phiên bản cảm biến điện 0xa0]

sức mạnh [1-n]_label
			ID cảm biến OCC + loại cảm biến ở dạng chuỗi,
			được phân cách bằng dấu gạch dưới, tức là "0_system". Cảm biến
			loại sẽ là một trong các "system", "proc", "vdd" hoặc "vdn".
			Đối với phiên bản cảm biến này, ID cảm biến OCC sẽ giống nhau
			cho tất cả các cảm biến công suất.

[chỉ hiện diện trên "chính" OCC; đại diện cho sức mạnh toàn hệ thống; chỉ một trong số
loại cảm biến công suất này sẽ có mặt]

sức mạnh [1-n]_label
				"hệ thống"
    nguồn [1-n]_input
				Công suất đầu ra hệ thống mới nhất tính bằng microwatt.
    sức mạnh [1-n]_cap
				Giới hạn công suất hệ thống hiện tại tính bằng microwatt.
    sức mạnh [1-n]_cap_not_redundant
				Giới hạn công suất của hệ thống tính bằng microwatt khi
				không có nguồn năng lượng dư thừa.
    sức mạnh [1-n]_cap_max
				Giới hạn công suất tối đa mà OCC có thể thực thi trong
				microwatt.
    power[1-n]_cap_min Giới hạn công suất tối thiểu mà OCC có thể thực thi trong
				microwatt.
    power[1-n]_cap_user Giới hạn công suất do người dùng đặt, tính bằng microwatt.
				Thuộc tính này sẽ trả về 0 nếu không có quyền người dùng
				giới hạn đã được thiết lập. Thuộc tính này là đọc-ghi,
				nhưng viết bất kỳ độ chính xác nào dưới mức watt sẽ là
				bị bỏ qua, tức là yêu cầu giới hạn nguồn
				500900000 microwatt sẽ tạo ra giới hạn nguồn
				yêu cầu 500 watt.

[với phiên bản cảm biến mũ> 1]

sức mạnh [1-n]_cap_user_source
					Cho biết giới hạn năng lượng của người dùng như thế nào
					thiết lập. Đây là một số nguyên ánh xạ tới
					các thành phần hệ thống hoặc phần sụn có thể
					đặt giới hạn sức mạnh của người dùng.

Các cảm biến "extn" sau đây được xuất dưới dạng cách để OCC cung cấp dữ liệu
điều đó không phù hợp với bất cứ nơi nào khác. Ý nghĩa của những cảm biến này hoàn toàn
phụ thuộc vào dữ liệu của họ và không thể được xác định tĩnh.

ext[1-n]_label
			ID ASCII hoặc ID cảm biến OCC.
ext[1-n]_flags
			Đây là giá trị thập lục phân một byte. Bit 7 chỉ ra
			loại thuộc tính nhãn; 1 cho ID cảm biến, 0 cho
			Mã số ASCII. Các bit khác được dành riêng.
ext[1-n]_input
			6 byte dữ liệu thập lục phân, có nghĩa được xác định bởi
			ID cảm biến.
