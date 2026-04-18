.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/linux/memory-hotplug.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================
Cắm nóng bộ nhớ
================
Giai đoạn cuối cùng của việc đưa bộ nhớ CXL vào bộ cấp phát trang kernel là dành cho
trình điều khiển ZZ0000ZZ để hiển thị vùng bộ nhớ ZZ0001ZZ thông qua
thành phần cắm nóng bộ nhớ.

Có bốn cấu hình chính cần xem xét:

1) Hành vi trực tuyến mặc định (bật/tắt và vùng)
2) Kích thước khối bộ nhớ cắm nóng
3) Vị trí tài nguyên bản đồ bộ nhớ
4) Chỉ định bộ nhớ do trình điều khiển quản lý

Hành vi trực tuyến mặc định
=======================
Hoạt động trực tuyến mặc định của bộ nhớ cắm nóng được quy định như sau:
theo thứ tự ưu tiên:

- Cấu hình xây dựng ZZ0000ZZ
- Thông số khởi động ZZ0001ZZ
- Giá trị ZZ0002ZZ

Những điều này cho biết liệu các khối bộ nhớ được cắm nóng có đến một trong ba trạng thái hay không:

1) Ngoại tuyến
2) Trực tuyến trong ZZ0000ZZ
3) Trực tuyến trong ZZ0001ZZ

ZZ0000ZZ ngụ ý rằng khả năng này có thể được sử dụng cho hầu hết mọi hoạt động phân bổ,
trong khi ZZ0001ZZ ngụ ý rằng dung lượng này chỉ nên được sử dụng cho
phân bổ có thể di chuyển.

ZZ0000ZZ cố gắng duy trì khả năng cắm nóng của khối bộ nhớ
để sau này toàn bộ khu vực có thể được rút phích cắm nóng.  Mọi công suất
trực tuyến vào ZZ0001ZZ nên được coi là gắn liền vĩnh viễn với
người cấp phát trang.

Kích thước khối bộ nhớ cắm nóng
=========================
Theo mặc định, trên hầu hết các kiến trúc, Kích thước khối bộ nhớ Hotplug là
128 MB hoặc 256 MB.  Trên x86, kích thước khối tăng lên tới 2GB dưới dạng tổng bộ nhớ
dung lượng vượt quá 64GB.  Kể từ v6.15, Linux không tính đến
kích thước và căn chỉnh của các vùng ACPI CEDT CFMWS (xem tài liệu Khởi động sớm) khi
quyết định Kích thước khối bộ nhớ Hotplug.

Bản đồ bộ nhớ
==========
Vị trí phân bổ ZZ0000ZZ để thể hiện việc cắm nóng
dung lượng bộ nhớ được quyết định bởi các cài đặt hệ thống sau:

-ZZ0000ZZ
-ZZ0001ZZ

Nếu cả hai tham số này được đặt thành true, ZZ0000ZZ cho điều này
dung lượng sẽ được khắc ra khỏi khối bộ nhớ đang được trực tuyến.  Cái này có
ý nghĩa về hiệu suất nếu bộ nhớ có độ trễ đặc biệt cao và
ZZ0001ZZ của nó trở nên tranh cãi gay gắt.

Nếu một trong hai tham số được đặt thành sai, ZZ0000ZZ cho dung lượng này
sẽ được phân bổ từ nút cục bộ của bộ xử lý đang chạy hotplug
thủ tục.  Dung lượng này sẽ được phân bổ từ ZZ0001ZZ vào
nút đó, vì nó là phân bổ ZZ0002ZZ.

Các hệ thống có số lượng bộ nhớ ZZ0000ZZ cực lớn (ví dụ:
Nhóm bộ nhớ CXL) phải đảm bảo có đủ bộ nhớ cục bộ
Dung lượng ZZ0001ZZ để lưu trữ bản đồ bộ nhớ cho dung lượng cắm nóng.

Bộ nhớ được quản lý bởi trình điều khiển
=====================
Trình điều khiển DAX chuyển bộ nhớ này vào bộ cắm nóng bộ nhớ dưới dạng "Trình điều khiển được quản lý". Cái này
không phải là cài đặt có thể định cấu hình nhưng điều quan trọng cần lưu ý là trình điều khiển được quản lý
bộ nhớ bị loại trừ rõ ràng khỏi việc sử dụng trong kexec.  Điều này là cần thiết để đảm bảo
mọi hoạt động đặt lại hoặc ngoài băng tần mà thiết bị CXL có thể phải thực hiện trong quá trình
khởi động lại hệ thống theo chức năng (chẳng hạn như thiết lập lại trên đầu dò) sẽ không gây ra các phần của
hạt nhân kexec sẽ bị ghi đè.