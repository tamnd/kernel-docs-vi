.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/yogafan.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================================================================================================
Trình điều khiển hạt nhân yogafan
=======================================================================================================

Chip được hỗ trợ:

* Bộ điều khiển nhúng Lenovo Yoga, Legion, IdeaPad, Slim, Flex và LOQ
  * Tiền tố: 'yogafan'
  * Địa chỉ: Tay cầm ACPI (Xem cơ sở dữ liệu bên dưới)

Tác giả: Sergio Melas <sergiomelas@gmail.com>

Sự miêu tả
-----------

Trình điều khiển này cung cấp khả năng giám sát tốc độ quạt cho máy tính xách tay tiêu dùng hiện đại của Lenovo.
Hầu hết các máy tính xách tay Lenovo không cung cấp dữ liệu đo tốc độ quạt thông qua tiêu chuẩn
Chip giám sát phần cứng ISA/LPC. Thay vào đó, dữ liệu được lưu trữ trong
Bộ điều khiển nhúng (EC) và được hiển thị qua ACPI.

Trình điều khiển triển khai bộ lọc ZZ0000ZZ để xử lý
lấy mẫu có độ phân giải thấp và không ổn định có trong phần mềm điều khiển Lenovo EC.

Nhận dạng phần cứng và logic nhân
--------------------------------------------

Trình điều khiển hỗ trợ hai kiến ​​trúc EC riêng biệt. Sự khác biệt được xử lý
một cách xác định thông qua bảng giải quyết vấn đề của Dòng sản phẩm DMI trong giai đoạn thăm dò,
loại bỏ sự cần thiết của phương pháp phỏng đoán thời gian chạy.

1. Kiến trúc EC 8 bit (Hệ số nhân: 100)

- ZZ0000ZZ Yoga, IdeaPad, Mỏng, Flex.
   - ZZ0001ZZ Các mô hình này phân bổ một thanh ghi 8 bit duy nhất cho
     dữ liệu máy đo tốc độ. Vì các trường 8 bit được giới hạn ở giá trị 255, nên
     BIOS lưu trữ tốc độ quạt theo đơn vị 100 RPM (ví dụ: 42 = 4200 RPM).

2. Kiến trúc EC 16 bit (Hệ số nhân: 1)

- Quân đoàn ZZ0000ZZ, LOQ.
   - ZZ0001ZZ Các mẫu máy chơi game hiệu năng cao yêu cầu cao hơn
     độ chính xác cho quạt vượt quá 6000 RPM. Chúng sử dụng một từ 16 bit (2 byte)
     lưu trữ trực tiếp giá trị RPM thô.

Lọc chi tiết
--------------

Bộ lọc RLLag là mô hình độ trễ bậc nhất theo thời gian rời rạc thụ động để đảm bảo:
  - ZZ0000ZZ Gia số bước có độ phân giải thấp được làm mịn thành gia số 1-RPM.
  - ZZ0001ZZ Ngăn chặn các kết quả đọc không thực tế bằng cách giới hạn thay đổi
    đến 1500 RPM/s, phù hợp với quán tính vật lý của quạt.
  - ZZ0002ZZ Bộ lọc toán thang đo dựa trên đồng bằng thời gian
    giữa các lần đọc không gian người dùng, đảm bảo đường cong vật lý nhất quán bất kể
    về tần suất bỏ phiếu.

Tạm dừng và tiếp tục
------------------

Trình điều khiển sử dụng đồng hồ thời gian khởi động (ktime_get_boottime()) để tính toán
lấy mẫu delta. Điều này đảm bảo rằng thời gian dành cho việc tạm dừng hệ thống được tính đến
cho. Nếu thời gian delta vượt quá 5 giây (ví dụ: sau khi đánh thức máy tính xách tay),
bộ lọc tự động đặt lại về giá trị phần cứng hiện tại để ngăn chặn
báo cáo dữ liệu RPM "ma" từ trước trạng thái ngủ.

Cách sử dụng
-----

Trình điều khiển hiển thị các thuộc tính hwmon sysfs tiêu chuẩn:

===============================================
Mô tả thuộc tính
fanX_input Tốc độ quạt được lọc trong RPM.
===============================================


Lưu ý: Nếu phần cứng báo cáo 0 RPM, bộ lọc sẽ bị bỏ qua và 0 được báo cáo
ngay lập tức để đảm bảo người dùng biết quạt đã dừng.


===========================================================================================================
                 LENOVO FAN CONTROLLER: MASTER REFERENCE DATABASE (2026)
===========================================================================================================

::

MODEL (DMI PN) ZZ0001ZZ EC OFFSET ZZ0002ZZ WIDTH | NHIỀU
 -------------------------------------------------------------------------------------------------------------------
 82N7 ZZ0003ZZ 0x06 ZZ0004ZZ 8-bit | 100
 80V2 / 81C3 ZZ0005ZZ 0x06 ZZ0006ZZ 8-bit | 100
 83E2 / 83DN ZZ0007ZZ 0xFE ZZ0008ZZ 8-bit | 100
 82A2 / 82A3 ZZ0009ZZ 0x06 ZZ0010ZZ 8-bit | 100
 81YM / 82FG ZZ0011ZZ 0x06 ZZ0012ZZ 8-bit | 100
 82JW / 82JU ZZ0013ZZ 0xFE/0xFF ZZ0014ZZ 16-bit | 1
 82JW / 82JU ZZ0015ZZ 0xFE/0xFF ZZ0016ZZ 16-bit | 1
 82WQ ZZ0017ZZ 0xFE/0xFF ZZ0018ZZ 16-bit | 1
 82WQ ZZ0019ZZ 0xFE/0xFF ZZ0020ZZ 16-bit | 1
 82XV / 83DV ZZ0021ZZ 0xFE/0xFF ZZ0022ZZ 16-bit | 1
 83AK ZZ0023ZZ 0x06 ZZ0024ZZ 8-bit | 100
 81X1 ZZ0025ZZ 0x06 ZZ0026ZZ 8-bit | 100
 ZZ0000ZZ ZZ0027ZZ 0x06 ZZ0028ZZ 8-bit | 100
 -------------------------------------------------------------------------------------------------------------------

METHODOLOGY & IDENTIFICATION:

1. DSDT ANALYSIS (THE PATH):
   Các bảng BIOS ACPI được phân tích bằng cách sử dụng 'iasl' và được tham chiếu chéo với
   bãi rác công cộng. Nhãn nội bộ (FANS, FAN0, FA2S) được ánh xạ tới
   EmbeddedControl OperationRegion bù đắp.

2. EC MEMORY MAPPING (THE OFFSET):
   Được xác thực bằng cách khớp logic NBFC (NoteBook FanControl) XML với Trường DSDT
   định nghĩa được tìm thấy trong phần mềm BIOS.

3. DATA-WIDTH ANALYSIS (THE MULTIPLIER):
   - 8-bit (Hệ số nhân 100): Tiêu chuẩn cho Yoga/IdeaPad. Giá trị thô (0-255).
   - 16-bit (Hệ số nhân 1): Tiêu chuẩn cho Legion/LOQ. Hai thanh ghi (0xFE/0xFF).


Tài liệu tham khảo
----------

1. Tài liệu ZZ0000ZZ về cách 8-bit và 16-bit
   các trường được truy cập trong OperationRegions.
   ZZ0001ZZ

2. ZZ0000ZZ Kỹ thuật đảo ngược hướng đến cộng đồng
   của bản đồ bộ nhớ Lenovo Legion/LOQ EC (thanh ghi thô 16 bit).
   ZZ0001ZZ

3. Tài liệu ZZ0000ZZ cho ktime_get_boottime() và
   xử lý vùng đồng bằng trên các trạng thái đình chỉ.
   ZZ0001ZZ

4. ZZ0000ZZ Tham khảo cho phần cứng dựa trên DMI
   tính năng cổng trong máy tính xách tay Lenovo.
   ZZ0001ZZ