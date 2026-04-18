.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/firmware-guide/acpi/acpi-lid.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. include:: <isonum.txt>

==============================================================
Mô hình sử dụng đặc biệt của thiết bị nắp phương pháp điều khiển ACPI
=========================================================

:Bản quyền: ZZ0000ZZ 2016, Tập đoàn Intel

:Tác giả: Lv Zheng <lv.zheng@intel.com>

Tóm tắt
========
Nền tảng chứa nắp truyền trạng thái nắp (mở/đóng) tới OSPM
sử dụng thiết bị nắp phương pháp điều khiển. Để thực hiện điều này, vấn đề về bảng AML
Notify(lid_device, 0x80) để thông báo cho OSPM bất cứ khi nào trạng thái nắp có
đã thay đổi. Phương pháp điều khiển _LID cho thiết bị nắp phải được triển khai để
báo cáo trạng thái "hiện tại" của nắp là "đã mở" hoặc "đóng".

Đối với hầu hết các nền tảng, cả phương pháp _LID và thông báo trên nắp đều
đáng tin cậy. Tuy nhiên, vẫn có những ngoại lệ. Để làm việc với những thứ này
nền tảng có lỗi đặc biệt, các hạn chế và ngoại lệ đặc biệt phải được
được tính đến. Tài liệu này mô tả các hạn chế và
ngoại lệ của trình điều khiển thiết bị nắp Linux ACPI.


Hạn chế về giá trị trả về của phương pháp điều khiển _LID
==============================================================

Phương pháp điều khiển _LID được mô tả để trả về trạng thái nắp "hiện tại".
Tuy nhiên, từ "hiện tại" có sự mơ hồ, một số bảng AML có lỗi sẽ trả về
trạng thái nắp khi có thông báo nắp cuối cùng thay vì trả lại nắp
trạng thái sau lần đánh giá _LID cuối cùng. Sẽ không có sự khác biệt khi
Phương pháp điều khiển _LID được đánh giá trong thời gian chạy, vấn đề là ở chỗ nó
giá trị trả về ban đầu. Khi các bảng AML triển khai phương thức điều khiển này
với giá trị được lưu trong bộ nhớ cache, giá trị trả về ban đầu có thể không đáng tin cậy.
Có những nền tảng luôn trả về trạng thái "đóng" như trạng thái nắp ban đầu.

Hạn chế của thông báo thay đổi trạng thái nắp
==================================================

Có các bảng AML bị lỗi không bao giờ thông báo khi trạng thái thiết bị nắp là
đổi thành "đã mở". Do đó, thông báo "đã mở" không được đảm bảo. Nhưng
đảm bảo rằng các bảng AML luôn thông báo "đóng" khi nắp
trạng thái được thay đổi thành "đóng". Thông báo "đã đóng" thường được sử dụng để
kích hoạt một số hoạt động tiết kiệm năng lượng hệ thống trên Windows. Vì nó hoàn toàn
đã được thử nghiệm, nó đáng tin cậy từ tất cả các bảng AML.

Ngoại lệ đối với người dùng không gian người dùng của trình điều khiển thiết bị nắp ACPI
================================================================

Trình điều khiển nút ACPI xuất trạng thái nắp sang không gian người dùng thông qua
tập tin sau::

/proc/acpi/nút/nắp/LID0/trạng thái

Tệp này thực sự gọi phương thức điều khiển _LID được mô tả ở trên. Và đưa ra
theo lời giải thích trước đó, nó không đủ tin cậy trên một số nền tảng. Vì vậy
chương trình không gian người dùng được khuyên không nên chỉ dựa vào tệp này
để xác định trạng thái nắp thực tế.

Trình điều khiển nút ACPI phát ra sự kiện đầu vào sau vào không gian người dùng:
  * SW_LID

Trình điều khiển thiết bị nắp ACPI được triển khai để cố gắng cung cấp nền tảng
đã kích hoạt các sự kiện cho không gian người dùng. Tuy nhiên, với thực tế là chiếc xe buggy
chương trình cơ sở không thể đảm bảo các sự kiện "đã mở"/"đóng" được ghép nối, ACPI
trình điều khiển nút sử dụng 3 chế độ sau để không gây ra sự cố.

Nếu không gian người dùng chưa được chuẩn bị để bỏ qua "đã mở" không đáng tin cậy
sự kiện và thông báo trạng thái ban đầu không đáng tin cậy, người dùng Linux có thể sử dụng
các tham số kernel sau để xử lý các sự cố có thể xảy ra:

A. Button.lid_init_state=phương thức:
   Khi tùy chọn này được chỉ định, trình điều khiển nút ACPI sẽ báo cáo
   trạng thái nắp ban đầu bằng cách sử dụng giá trị trả về của phương pháp điều khiển _LID
   và liệu các sự kiện "đã mở"/"đã đóng" có được ghép nối hoàn toàn hay không phụ thuộc vào
   triển khai phần mềm cơ sở.

Tùy chọn này có thể được sử dụng để sửa một số nền tảng trong đó giá trị trả về
   của phương pháp điều khiển _LID là đáng tin cậy nhưng trạng thái nắp ban đầu
   thông báo bị thiếu.

Tùy chọn này là hành vi mặc định trong khoảng thời gian không gian người dùng
   chưa sẵn sàng để xử lý các bảng AML có lỗi.

B. nút.lid_init_state=open:
   Khi tùy chọn này được chỉ định, trình điều khiển nút ACPI luôn báo cáo
   trạng thái nắp ban đầu là "đã mở" và liệu các sự kiện "đã mở"/"đã đóng" hay chưa
   được ghép nối hoàn toàn dựa vào việc triển khai chương trình cơ sở.

Điều này có thể khắc phục một số nền tảng trong đó giá trị trả về của _LID
   phương pháp điều khiển không đáng tin cậy và thông báo trạng thái nắp ban đầu là
   thiếu.

Nếu không gian người dùng đã được chuẩn bị để bỏ qua các sự kiện "đã mở" không đáng tin cậy
và thông báo trạng thái ban đầu không đáng tin cậy, người dùng Linux phải luôn
sử dụng tham số kernel sau:

C. nút.lid_init_state=bỏ qua:
   Khi tùy chọn này được chỉ định, trình điều khiển nút ACPI không bao giờ báo cáo
   trạng thái nắp ban đầu và có một cơ chế bù được thực hiện để
   đảm bảo rằng các thông báo "đã đóng" đáng tin cậy luôn có thể được gửi
   vào không gian người dùng bằng cách luôn ghép nối các sự kiện đầu vào "đóng" với phần bổ sung
   sự kiện đầu vào "đã mở". Nhưng vẫn chưa có gì đảm bảo rằng việc “mở”
   thông báo có thể được gửi đến không gian người dùng khi nắp thực sự được
   mở do một số bảng AML không gửi thông báo "đã mở"
   đáng tin cậy.

Trong chế độ này, nếu mọi thứ được nền tảng triển khai chính xác
   firmware, các chương trình không gian người dùng cũ vẫn hoạt động. Nếu không,
   cần có các chương trình không gian người dùng mới để hoạt động với trình điều khiển nút ACPI.
   Tùy chọn này sẽ là hành vi mặc định sau khi không gian người dùng sẵn sàng
   xử lý các bảng AML có lỗi.