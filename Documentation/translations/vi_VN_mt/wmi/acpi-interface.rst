.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/wmi/acpi-interface.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================
Giao diện ACPI WMI
====================

Giao diện ACPI WMI là phần mở rộng độc quyền của thông số kỹ thuật ACPI được tạo ra
của Microsoft cho phép các nhà cung cấp phần cứng nhúng WMI (Công cụ quản lý Windows)
các đối tượng bên trong phần mềm ACPI của họ. Các chức năng điển hình được triển khai trên ACPI WMI
là các sự kiện phím nóng trên máy tính xách tay hiện đại và cấu hình các tùy chọn BIOS.

Thiết bị PNP0C14 ACPI
---------------------

Việc khám phá các đối tượng WMI được xử lý bằng cách xác định các thiết bị ACPI có ID PNP
của ZZ0000ZZ. Các thiết bị này sẽ chứa một bộ phương thức và bộ đệm ACPI
được sử dụng để ánh xạ và thực thi các phương thức và/hoặc truy vấn WMI. Nếu có tồn tại
nhiều thiết bị như vậy thì mỗi thiết bị bắt buộc phải có một
ACPI UID độc đáo.

Bộ đệm _WDG
-----------

Bộ đệm ZZ0000ZZ được sử dụng để khám phá các đối tượng WMI và được yêu cầu phải
tĩnh. Cấu trúc bên trong của nó bao gồm các khối dữ liệu có kích thước 20 byte,
chứa các dữ liệu sau:

====================== ===========================================================
Kích thước bù đắp (tính bằng byte) Nội dung
====================== ===========================================================
0x00 16 128 bit Biến thể 2 đối tượng GUID.
0x10 2 ID phương thức 2 ký tự hoặc ID thông báo byte đơn.
0x12 1 Số lượng phiên bản đối tượng.
0x13 1 Cờ đối tượng.
====================== ===========================================================

Cờ đối tượng WMI kiểm soát xem phương thức hoặc ID thông báo có được sử dụng hay không:

- 0x1: Khối dữ liệu tốn nhiều chi phí để thu thập.
- 0x2: Khối dữ liệu chứa các phương thức WMI.
- 0x4: Khối dữ liệu chứa chuỗi ASCIZ.
- 0x8: Khối dữ liệu mô tả sự kiện WMI, thay vào đó hãy sử dụng ID thông báo
  của ID phương thức.

Mỗi đối tượng WMI GUID có thể xuất hiện nhiều lần trong hệ thống.
ID phương thức/thông báo được sử dụng để xây dựng tên phương thức ACPI được sử dụng cho
tương tác với đối tượng WMI.

Phương pháp WQxx ACPI
---------------------

Nếu một khối dữ liệu không chứa các phương thức WMI thì nội dung của nó có thể được truy xuất
bằng phương pháp ACPI bắt buộc này. Hai ký tự cuối cùng của tên phương thức ACPI
là ID phương thức của khối dữ liệu cần truy vấn. Tham số duy nhất của chúng là một
số nguyên mô tả thể hiện cần được truy vấn. Thông số này có thể
được bỏ qua nếu khối dữ liệu chỉ chứa một thể hiện duy nhất.

Phương pháp WSxx ACPI
---------------------

Tương tự như các phương pháp ZZ0000ZZ ACPI, ngoại trừ việc nó là tùy chọn và cần một
bộ đệm bổ sung làm đối số thứ hai của nó. Đối số thể hiện cũng không thể
được bỏ qua.

Các phương pháp WMxx ACPI
-------------------------

Được sử dụng để thực thi các phương thức WMI được liên kết với khối dữ liệu. Hai cái cuối cùng
các ký tự của tên phương thức ACPI là ID phương thức của khối dữ liệu
chứa các phương pháp WMI. Tham số đầu tiên của chúng là một số nguyên mô tả
dụ những phương thức nào sẽ được thực thi. Tham số thứ hai là một số nguyên
mô tả ID phương thức WMI để thực thi và tham số thứ ba là bộ đệm
chứa các tham số phương thức WMI. Nếu khối dữ liệu được đánh dấu là chứa
một chuỗi ASCIZ thì bộ đệm này phải chứa một chuỗi ASCIZ. ACPI
sẽ trả về kết quả của phương thức WMI đã thực thi.

Các phương pháp WExx ACPI
-------------------------

Được sử dụng để tùy chọn bật/tắt các sự kiện WMI, hai ký tự cuối cùng của
phương thức ACPI là ID thông báo của khối dữ liệu mô tả WMI
sự kiện dưới dạng giá trị thập lục phân. Tham số đầu tiên của chúng là một số nguyên có giá trị
bằng 0 nếu sự kiện WMI bị tắt, các giá trị khác sẽ kích hoạt
sự kiện WMI.

Các phương thức ACPI đó luôn được gọi ngay cả đối với các sự kiện WMI chưa được đăng ký là
việc thu thập rất tốn kém để phù hợp với hành vi của trình điều khiển Windows.

Các phương pháp WCxx ACPI
-------------------------
Tương tự như các phương thức ZZ0000ZZ ACPI, ngoại trừ việc thay vì các sự kiện WMI, nó điều khiển
thu thập dữ liệu của các khối dữ liệu được đăng ký là tốn kém để thu thập. Vì thế
hai ký tự cuối cùng của tên phương thức ACPI là ID phương thức của khối dữ liệu
để bật/tắt.

Các phương thức ACPI đó cũng được gọi trước khi thiết lập các khối dữ liệu để khớp với
hoạt động của trình điều khiển Windows.

Phương pháp _WED ACPI
---------------------

Được sử dụng để truy xuất dữ liệu sự kiện WMI bổ sung, tham số duy nhất của nó là số nguyên
giữ ID thông báo của sự kiện. Phương pháp này cần được đánh giá mỗi
thời điểm nhận được thông báo ACPI, vì một số triển khai ACPI sử dụng
hàng đợi để lưu trữ các mục dữ liệu sự kiện WMI. Hàng đợi này sẽ tràn sau một vài
nhận được các sự kiện WMI mà không truy xuất dữ liệu sự kiện WMI liên quan.

Quy tắc chuyển đổi cho kiểu dữ liệu ACPI
----------------------------------------

Người tiêu dùng giao diện ACPI-WMI sử dụng bộ đệm nhị phân để trao đổi dữ liệu với lõi trình điều khiển WMI,
với cấu trúc bên trong của bộ đệm chỉ có người tiêu dùng mới biết. Lõi trình điều khiển WMI là
do đó chịu trách nhiệm chuyển đổi dữ liệu bên trong bộ đệm thành kiểu dữ liệu ACPI thích hợp cho
mức tiêu thụ của phần sụn ACPI. Ngoài ra, mọi dữ liệu được trả về bởi các phương thức ACPI khác nhau đều cần
được chuyển đổi trở lại thành bộ đệm nhị phân.

Bố cục của bộ đệm nói trên được xác định bằng mô tả MOF của phương pháp WMI hoặc khối dữ liệu trong
câu hỏi [1]_:

=========================================================================================== ==========
Căn chỉnh bố cục kiểu dữ liệu
=========================================================================================== ==========
ZZ0000ZZ Bắt đầu bằng số nguyên cuối nhỏ 16 bit không dấu chỉ định 2 byte
                độ dài của dữ liệu chuỗi tính bằng byte, theo sau là dữ liệu chuỗi
                được mã hóa dưới dạng UTF-16LE với phần cuối và phần đệm ZZ0013ZZ NULL.
                Hãy nhớ rằng một số việc triển khai chương trình cơ sở có thể phụ thuộc vào
                chấm dứt sự hiện diện của ký tự NULL. Ngoài ra phần đệm nên
                luôn được thực hiện với các ký tự NULL.
ZZ0001ZZ Một byte trong đó 0 có nghĩa là ZZ0002ZZ và khác 0 có nghĩa là ZZ0003ZZ.         1 byte
ZZ0004ZZ Số nguyên 8 bit có dấu.                                                   1 byte
ZZ0005ZZ Số nguyên 8 bit không dấu.                                                 1 byte
ZZ0006ZZ Số nguyên endian nhỏ 16 bit có dấu.                                    2 byte
ZZ0007ZZ Số nguyên cuối nhỏ 16 bit không dấu.                                  2 byte
ZZ0008ZZ Số nguyên endian nhỏ 32 bit có dấu.                                    4 byte
ZZ0009ZZ Số nguyên endian nhỏ 32 bit không dấu.                                  4 byte
ZZ0010ZZ Số nguyên endian nhỏ 64-bit có dấu.                                    8 byte
ZZ0011ZZ Số nguyên endian nhỏ 64 bit không dấu.                                  8 byte
ZZ0012ZZ Chuỗi UTF-16LE có độ dài cố định 25 ký tự với định dạng 2 byte
                ZZ0014ZZ trong đó ZZ0015ZZ là năm có 4 chữ số, ZZ0016ZZ là
                tháng có 2 chữ số, ZZ0017ZZ là ngày có 2 chữ số, ZZ0018ZZ là giờ có 2 chữ số
                dựa trên đồng hồ 24 giờ, ZZ0019ZZ là phút có 2 chữ số, ZZ0020ZZ là
                Giây 2 chữ số, ZZ0021ZZ là micro giây 6 chữ số, ZZ0022ZZ là dấu cộng hoặc
                ký tự trừ tùy thuộc vào ZZ0023ZZ là dương hay âm
                phần bù từ UTC (hoặc dấu hai chấm nếu ngày là khoảng thời gian). Không có dân cư
                các trường phải được điền bằng dấu hoa thị.
=========================================================================================== ==========

Các mảng phải được căn chỉnh dựa trên sự căn chỉnh của kiểu cơ sở của chúng, trong khi các đối tượng phải được căn chỉnh
căn chỉnh dựa trên căn chỉnh lớn nhất của một phần tử bên trong chúng.

Tất cả các bộ đệm được lõi trình điều khiển WMI trả về đều được căn chỉnh 8 byte. Khi chuyển đổi kiểu dữ liệu ACPI
vào các bộ đệm như vậy, các quy tắc chuyển đổi sau sẽ được áp dụng:

==================================================================================
Kiểu dữ liệu ACPI được chuyển đổi thành
==================================================================================
Bộ đệm được sao chép nguyên trạng.
Số nguyên được chuyển đổi thành ZZ0000ZZ.
Chuỗi được chuyển đổi thành ZZ0001ZZ với ký tự NULL kết thúc
                để phù hợp với hành vi của trình điều khiển Windows.
Gói Mỗi phần tử bên trong gói được chuyển đổi bằng cách căn chỉnh
                của các kiểu dữ liệu kết quả được tôn trọng. Gói lồng nhau
                không được phép.
==================================================================================

Trình điều khiển Windows cố gắng xử lý các gói lồng nhau nhưng điều này dẫn đến dữ liệu nội bộ
(ZZ0000ZZ) bị sao chép nhầm vào bộ đệm kết quả.
Do đó, việc triển khai chương trình cơ sở ACPI sẽ không trả về các gói lồng nhau từ các phương thức ACPI
được liên kết với giao diện ACPI-WMI.

Tài liệu tham khảo
==================

.. [1] https://learn.microsoft.com/en-us/windows-hardware/drivers/kernel/driver-defined-wmi-data-items