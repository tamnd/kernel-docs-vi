.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/acpi/scan_handlers.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

====================
Trình xử lý quét ACPI
==================

:Bản quyền: ZZ0000ZZ 2012, Tập đoàn Intel

:Tác giả: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

Trong quá trình khởi tạo hệ thống và thêm nóng thiết bị dựa trên ACPI, không gian tên ACPI
được quét để tìm kiếm các đối tượng thiết bị thường đại diện cho nhiều phần khác nhau
của phần cứng.  Điều này tạo ra một đối tượng struct acpi_device và
đã đăng ký với lõi trình điều khiển cho mọi đối tượng thiết bị trong không gian tên ACPI
và hệ thống phân cấp của các đối tượng struct acpi_device đó phản ánh không gian tên
bố cục (tức là các đối tượng thiết bị cha mẹ trong không gian tên được đại diện bởi cha mẹ
struct các đối tượng acpi_device và tương tự cho các đối tượng con của chúng).  Những cấu trúc đó
Các đối tượng acpi_device được gọi là "nút thiết bị" sau đây, nhưng chúng
không nên nhầm lẫn với các đối tượng struct device_node được Cây thiết bị sử dụng
mã phân tích cú pháp (mặc dù vai trò của chúng tương tự như vai trò của các đối tượng đó).

Trong các nút thiết bị loại bỏ nóng trên thiết bị dựa trên ACPI đại diện cho các phần cứng
bị xóa sẽ không được đăng ký và bị xóa.

Mã quét không gian tên ACPI cốt lõi trong driver/acpi/scan.c thực hiện các thao tác cơ bản
khởi tạo các nút thiết bị, chẳng hạn như truy xuất cấu hình chung
thông tin từ các đối tượng thiết bị được đại diện bởi chúng và điền chúng vào
dữ liệu thích hợp, nhưng một số dữ liệu trong số đó yêu cầu xử lý bổ sung sau khi chúng có
đã được đăng ký.  Ví dụ: nếu nút thiết bị đã cho đại diện cho máy chủ PCI
cầu, việc đăng ký của nó sẽ khiến xe buýt PCI dưới cây cầu đó bị
các thiết bị được liệt kê và PCI trên xe buýt đó phải được đăng ký với lõi trình điều khiển.
Tương tự, nếu nút thiết bị đại diện cho liên kết ngắt PCI thì cần thiết
để cấu hình liên kết đó để kernel có thể sử dụng nó.

Những tác vụ cấu hình bổ sung đó thường phụ thuộc vào loại phần cứng
thành phần được đại diện bởi nút thiết bị nhất định có thể được xác định trên
dựa trên ID phần cứng của nút thiết bị (HID).  Chúng được thực hiện bởi các đối tượng
được gọi là trình xử lý quét ACPI được biểu thị bằng cấu trúc sau ::

cấu trúc acpi_scan_handler {
		const struct acpi_device_id *ids;
		cấu trúc list_head list_node;
		int (*attach)(struct acpi_device *dev, const struct acpi_device_id *id);
		khoảng trống (*detach)(struct acpi_device *dev);
	};

trong đó id là danh sách ID của các nút thiết bị mà trình xử lý đã cho phải thực hiện
hãy cẩn thận, list_node là điểm kết nối với danh sách toàn cầu của trình xử lý quét ACPI
được duy trì bởi lõi ACPI và các lệnh gọi lại .attach() và .detach() được
được thực thi tương ứng sau khi đăng ký các nút thiết bị mới và trước
hủy đăng ký các nút thiết bị mà trình xử lý đã đính kèm trước đó.

Chức năng quét không gian tên, acpi_bus_scan(), trước tiên đăng ký tất cả
các nút thiết bị trong phạm vi không gian tên nhất định với lõi trình điều khiển.  Sau đó, nó cố gắng
để khớp trình xử lý quét với từng trình xử lý đó bằng cách sử dụng mảng id của
trình xử lý quét có sẵn.  Nếu tìm thấy trình xử lý quét phù hợp, thì .attach() của nó
cuộc gọi lại được thực thi cho nút thiết bị đã cho.  Nếu cuộc gọi lại đó trả về 1,
điều đó có nghĩa là trình xử lý đã yêu cầu nút thiết bị và hiện chịu trách nhiệm
để thực hiện bất kỳ nhiệm vụ cấu hình bổ sung nào liên quan đến nó.  Nó cũng sẽ
chịu trách nhiệm chuẩn bị nút thiết bị để hủy đăng ký trong trường hợp đó.
Sau đó, trường xử lý của nút thiết bị được điền địa chỉ quét
người xử lý đã xác nhận quyền sở hữu nó.

Nếu lệnh gọi lại .attach() trả về 0, điều đó có nghĩa là nút thiết bị không
thú vị đối với trình xử lý quét nhất định và có thể phù hợp với lần quét tiếp theo
người xử lý trong danh sách.  Nếu nó trả về mã lỗi (âm), điều đó có nghĩa là
quá trình quét không gian tên sẽ bị chấm dứt do có lỗi nghiêm trọng.  Mã lỗi
được trả về sau đó sẽ phản ánh loại lỗi.

Hàm cắt bớt không gian tên, acpi_bus_trim(), đầu tiên thực thi .detach()
lệnh gọi lại từ trình xử lý quét của tất cả các nút thiết bị trong không gian tên đã cho
phạm vi (nếu họ có trình xử lý quét).  Tiếp theo, nó hủy đăng ký tất cả thiết bị
các nút trong phạm vi đó.

Trình xử lý quét ACPI có thể được thêm vào danh sách được duy trì bởi lõi ACPI với
trợ giúp của hàm acpi_scan_add_handler() đưa con trỏ tới lần quét mới
xử lý như một đối số.  Thứ tự các trình xử lý quét được thêm vào danh sách
là thứ tự chúng được so khớp với các nút thiết bị trong không gian tên
quét.

Tất cả các tay cầm quét phải được thêm vào danh sách trước khi chạy acpi_bus_scan() cho
lần đầu tiên và chúng không thể bị xóa khỏi nó.