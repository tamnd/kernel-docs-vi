.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/platform/device-hotplug.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================
Đầu cắm nóng thiết bị CXL
=========================

Hotplug thiết bị đề cập đến hotplug ZZ0000ZZ của một thiết bị (thêm hoặc xóa
của một thiết bị vật lý từ máy).

Phần mềm BIOS/EFI dự kiến sẽ cấu hình đủ tài nguyên **khi khởi động
time** để cho phép các thiết bị cắm nóng được cấu hình bằng phần mềm (chẳng hạn như
miền lân cận, vùng HPA và cấu hình cầu máy chủ).

BIOS/EFI không được mong đợi (ZZ0000ZZ) để định cấu hình cắm nóng
các thiết bị tại thời điểm cắm nóng (tức là bộ giải mã HDM không được lập trình).

Tài liệu này bao gồm một số ví dụ về các tài nguyên đó, nhưng không nên
được coi là đầy đủ.

Loại bỏ nóng
============
Việc gỡ nóng thiết bị thường yêu cầu gỡ bỏ phần mềm một cách cẩn thận
cấu trúc (vùng bộ nhớ, trình điều khiển liên quan) quản lý các thiết bị này.

Gỡ bỏ cứng thiết bị CXL.mem mà không cẩn thận xé ngăn xếp trình điều khiển
có khả năng khiến hệ thống phải kiểm tra máy (hoặc ít nhất là SIGBUS nếu bộ nhớ
quyền truy cập bị giới hạn trong không gian người dùng).

Thêm nóng thiết bị bộ nhớ
=========================
Một thiết bị có mặt khi khởi động có thể được liên kết với Cửa sổ bộ nhớ cố định CXL
được báo cáo trong ZZ0000ZZ.  CFMWS đó có thể phù hợp với kích thước của
thiết bị, nhưng cấu trúc của CEDT CFMWS được xác định theo nền tảng.

Việc thêm nóng một thiết bị bộ nhớ yêu cầu ZZ0000ZZ CFMWS được xác định trước này để
có đủ không gian HPA để mô tả thiết bị đó.

Có một vài tình huống phổ biến cần xem xét.

Thiết bị bộ nhớ điểm cuối duy nhất có mặt khi khởi động
-------------------------------------------------------
Một thiết bị có mặt khi khởi động có thể có dung lượng được báo cáo trong
ZZ0000ZZ.  Nếu một thiết bị bị tháo ra và một thiết bị mới được cắm nóng,
dung lượng của thiết bị mới sẽ bị giới hạn ở dung lượng CFMWS ban đầu.

Việc thêm dung lượng lớn hơn thiết bị gốc sẽ gây ra vùng bộ nhớ
quá trình tạo không thành công nếu kích thước vùng lớn hơn kích thước CFMWS.

CFMWS là ZZ0000ZZ và không thể điều chỉnh được.  Nền tảng có thể mong đợi
các thiết bị có kích thước khác nhau được cắm nóng phải phân bổ đủ dung lượng CFMWS
ZZ0001ZZ dành cho tất cả các thiết bị được mong đợi trong tương lai.

Thiết bị bộ nhớ đa điểm có mặt khi khởi động
--------------------------------------------
Các thiết bị Đa điểm cuối không dựa trên công tắc nằm ngoài phạm vi của những gì
Thông số kỹ thuật CXL mô tả, nhưng chúng có thể thực hiện được về mặt kỹ thuật. Chúng tôi mô tả
chúng ở đây chỉ nhằm mục đích hướng dẫn - điều này không hàm ý hỗ trợ Linux.

Một thiết bị bộ nhớ CXL có khả năng cắm nóng, chẳng hạn như một thiết bị có nhiều
thiết bị mở rộng dưới dạng một thiết bị có dung lượng lớn duy nhất nên báo cáo **tối đa
dung lượng có thể** cho thiết bị khi khởi động. ::

HB0
                  RP0
                   |
     [Thiết bị bộ nhớ đa điểm cuối]
              _____|_____
             ZZ0000ZZ
        [Điểm cuối0] [Trống]


Việc giới hạn kích thước ở mức dung lượng đặt trước khi khởi động sẽ hạn chế hỗ trợ hot-add
để thay thế dung lượng đã có khi khởi động.

Không có thiết bị CXL nào hiện diện khi khởi động
-------------------------------------------------
Khi không có thiết bị bộ nhớ CXL nào xuất hiện khi khởi động, một số nền tảng sẽ bỏ qua CFMWS
trong ZZ0000ZZ.  Khi điều này xảy ra, không thể thêm nóng.

Phần này mô tả trường hợp cơ bản cho bất kỳ thiết bị cụ thể nào không có mặt khi khởi động.
Nếu một thiết bị có thể có trong tương lai không được mô tả trong CEDT khi khởi động, hãy thêm nóng
của thiết bị đó bị hạn chế hoặc không thể thực hiện được.

Để một nền tảng hỗ trợ thêm nóng thiết bị bộ nhớ đầy đủ, nó phải phân bổ
vùng CEDT CFMWS có đủ dung lượng bộ nhớ để bao gồm tất cả các dữ liệu trong tương lai
dung lượng có thể được bổ sung (cùng với mọi mục nhập CEDT CHBS có liên quan).

Để hỗ trợ cắm nóng bộ nhớ trực tiếp trên cầu nối máy chủ/cổng gốc hoặc trên bộ chuyển mạch
ở phía hạ lưu của cầu chủ, nền tảng phải xây dựng CEDT CFMWS khi khởi động
có đủ tài nguyên để hỗ trợ hotplug tối đa có thể (hoặc dự kiến)
dung lượng bộ nhớ. ::

HB0 HB1
      RP0 RP1 RP2
       ZZ0000ZZ |
     Trống rỗng USP
                      ________|________
                      ZZ0001ZZ ZZ0002ZZ
                     DSP DSP DSP DSP
                      ZZ0003ZZ ZZ0004ZZ
                         Tất cả trống rỗng

Ví dụ: BIOS/EFI có thể hiển thị tùy chọn để định cấu hình CEDT CFMWS với
một lượng dung lượng bộ nhớ được cấu hình sẵn (trên mỗi cầu máy chủ hoặc cầu máy chủ
bộ xen kẽ), ngay cả khi không có thiết bị nào được gắn vào Cổng gốc hoặc Hạ lưu
Các cổng khi khởi động (như mô tả trong hình trên).


Bộ xen kẽ
===============

Cầu nối xen kẽ máy chủ
----------------------
Các vùng bộ nhớ xen kẽ cầu máy chủ được xác định ZZ0001ZZ trong
ZZ0000ZZ.  Để áp dụng xen kẽ cầu nối máy chủ, mục nhập CFMWS
mô tả rằng phần xen kẽ đó phải được cung cấp ZZ0002ZZ.  Đã cắm nóng
các thiết bị không thể thêm khả năng xen kẽ cầu nối máy chủ tại thời điểm cắm nóng.

Xem ZZ0000ZZ
ví dụ để xem cách một nền tảng có thể cung cấp loại tính linh hoạt này liên quan đến
thiết bị bộ nhớ cắm nóng.  Phần mềm BIOS/EFI nên xem xét các tùy chọn để
trình bày cấu hình CEDT linh hoạt với hỗ trợ cắm nóng.

HDM xen kẽ
--------------
Interleave áp dụng bộ giải mã có thể xử lý linh hoạt các thiết bị được cắm nóng, như bộ giải mã
có thể được lập trình lại sau khi cắm nóng.

Để thêm hoặc xóa thiết bị đến/khỏi vùng xen kẽ được áp dụng HDM hiện có,
vùng đó phải được phá bỏ và tạo lại.