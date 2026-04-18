.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/input/devices/appletouch.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

----------------------------------------------------
Trình điều khiển bàn di chuột của Apple (appletouch)
----------------------------------------------------

:Bản quyền: ZZ0000ZZ 2005 Stelian Pop <stelian@popies.net>

appletouch là trình điều khiển nhân Linux cho bàn di chuột USB được tìm thấy trên bài đăng
Tháng 2 năm 2005 và tháng 10 năm 2005 Apple Aluminium Powerbooks.

Trình điều khiển này được lấy từ trình điều khiển appletrackpad của Johannes Berg [#f1]_,
nhưng nó đã được cải thiện ở một số lĩnh vực:

* appletouch là trình điều khiển kernel đầy đủ, không cần chương trình không gian người dùng
	* Appletouch có thể được giao tiếp với trình điều khiển X11 synaptics, theo thứ tự
	  để tăng tốc bàn di chuột, cuộn, v.v.

Tín dụng thuộc về Johannes Berg vì đã thiết kế ngược giao thức bàn di chuột,
Frank Arnold cho những cải tiến hơn nữa và Alex Harper cho một số bổ sung
thông tin về hoạt động bên trong của cảm biến trên bàn di chuột. Michael
Hanselmann đã thêm hỗ trợ cho các mẫu tháng 10 năm 2005.

Cách sử dụng
------------

Để sử dụng bàn di chuột ở chế độ cơ bản, hãy biên dịch trình điều khiển và tải
mô-đun. Một thiết bị đầu vào mới sẽ được phát hiện và bạn sẽ có thể đọc
dữ liệu chuột từ /dev/input/mice (sử dụng gpm hoặc X11).

Trong X11, bạn có thể định cấu hình bàn di chuột để sử dụng trình điều khiển X11 synaptics.
sẽ cung cấp các chức năng bổ sung, như tăng tốc, cuộn, 2 ngón tay
chạm để mô phỏng chuột nút giữa, chạm 3 ngón tay để mô phỏng chuột nút phải
mô phỏng, v.v. Để thực hiện việc này, hãy đảm bảo bạn đang sử dụng phiên bản mới nhất của
trình điều khiển synap (đã thử nghiệm với 0.14.2, có sẵn từ [#f2]_) và định cấu hình
một thiết bị đầu vào mới trong tệp cấu hình X11 của bạn (hãy xem bên dưới để biết
ví dụ). Để biết cấu hình bổ sung, hãy xem tài liệu trình điều khiển synap::

Phần "Thiết bị đầu vào"
		Mã định danh "Bàn di chuột Synaptics"
		Trình điều khiển "synaptic"
		Tùy chọn "SendCoreEvents" "true"
		Tùy chọn "Thiết bị" "/dev/đầu vào/chuột"
		Tùy chọn "Giao thức" "tự động phát triển"
		Tùy chọn "LeftEdge" "0"
		Tùy chọn "RightEdge" "850"
		Tùy chọn "TopEdge" "0"
		Tùy chọn "BottomEdge" "645"
		Tùy chọn "Tốc độ tối thiểu" "0,4"
		Tùy chọn "Tốc độ tối đa" "1"
		Tùy chọn "AccelFactor" "0,02"
		Tùy chọn "FingerLow" "0"
		Tùy chọn "Ngón tay cao" "30"
		Tùy chọn "MaxTapMove" "20"
		Tùy chọn "MaxTapTime" "100"
		Tùy chọn "HorizScrollDelta" "0"
		Tùy chọn "VertScrollDelta" "30"
		Tùy chọn "SHMConfig" "bật"
	Phần cuối

Phần "Bố cục máy chủ"
		...
Thiết bị đầu vào "Chuột"
		Thiết bị đầu vào "Bàn di chuột Synaptics"
	...
Phần cuối

Vấn đề về lông tơ
-----------------

Cảm biến của bàn di chuột rất nhạy cảm với nhiệt và sẽ tạo ra nhiều
tiếng ồn khi nhiệt độ thay đổi. Điều này đặc biệt đúng khi bạn bật nguồn
máy tính xách tay lần đầu tiên.

Trình điều khiển appletouch cố gắng xử lý tiếng ồn này và tự động điều chỉnh, nhưng nó
không hoàn hảo. Nếu chuyển động của ngón tay không được nhận dạng nữa, hãy thử tải lại
người lái xe.

Bạn có thể kích hoạt gỡ lỗi bằng tham số mô-đun 'gỡ lỗi'. Giá trị 0
hủy kích hoạt bất kỳ gỡ lỗi nào, 1 kích hoạt truy tìm các mẫu không hợp lệ, 2 kích hoạt
truy tìm đầy đủ (mỗi mẫu đang được truy tìm)::

modprobe gỡ lỗi appletouch=1

hoặc::

echo "1" > /sys/module/appletouch/parameters/debug


.. Links:

.. [#f1] http://johannes.sipsolutions.net/PowerBook/touchpad/

.. [#f2] `<http://web.archive.org/web/*/http://web.telia.com/~u89404340/touchpad/index.html>`_
