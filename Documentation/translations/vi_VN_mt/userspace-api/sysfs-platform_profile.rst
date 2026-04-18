.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/userspace-api/sysfs-platform_profile.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================================================================
Lựa chọn cấu hình nền tảng (ví dụ: /sys/firmware/acpi/platform_profile)
===========================================================================

Trên các hệ thống hiện đại, hiệu suất của nền tảng, nhiệt độ, quạt và các yếu tố khác
các đặc điểm liên quan đến phần cứng thường có thể cấu hình động. các
cấu hình nền tảng thường được tự động điều chỉnh theo hiện tại
điều kiện bằng một cơ chế tự động nào đó (có thể tồn tại rất tốt bên ngoài
hạt nhân).

Các cơ chế điều chỉnh nền tảng tự động này thường có thể được cấu hình bằng
một trong một số cấu hình nền tảng, có xu hướng thiên về công suất thấp
hoạt động hoặc hướng tới hiệu suất.

Mục đích của thuộc tính platform_profile là cung cấp một sysfs chung
API để chọn cấu hình nền tảng của các cơ chế tự động này.

Lưu ý rằng API này chỉ dành cho việc chọn cấu hình nền tảng, nó
NOT mục tiêu của API này là cho phép theo dõi hiệu suất đạt được
đặc điểm. Giám sát hiệu suất được thực hiện tốt nhất với thiết bị/nhà cung cấp
công cụ cụ thể, ví dụ: turbostat.

Cụ thể, khi lựa chọn một cấu hình hiệu suất cao, kết quả thực tế đạt được
hiệu suất có thể bị hạn chế bởi nhiều yếu tố khác nhau như: nhiệt sinh ra
bởi các thành phần khác, nhiệt độ phòng, luồng không khí tự do ở đáy tủ
máy tính xách tay, v.v. NOT rõ ràng là mục tiêu của API này để cho không gian người dùng biết
về bất kỳ điều kiện dưới mức tối ưu nào đang cản trở việc đạt được yêu cầu
mức hiệu suất.

Vì các con số tự nó không thể biểu diễn nhiều biến số mà một
cấu hình sẽ điều chỉnh (tiêu thụ điện năng, sinh nhiệt, v.v.) API này
sử dụng các chuỗi để mô tả các cấu hình khác nhau. Để đảm bảo rằng không gian người dùng
có được trải nghiệm nhất quán mà tài liệu sysfs-platform_profile ABI xác định
một bộ tên hồ sơ cố định. Trình điều khiển ZZ0000ZZ ánh xạ hồ sơ nội bộ của họ
biểu diễn trên tập cố định này.

Nếu không có kết quả phù hợp khi ánh xạ thì tên hồ sơ mới có thể
đã thêm vào. Người lái xe muốn giới thiệu tên hồ sơ mới phải:

1. Giải thích tại sao không thể sử dụng tên hồ sơ hiện tại.
 2. Thêm tên hồ sơ mới cùng với mô tả rõ ràng về
    hành vi mong đợi vào tài liệu sysfs-platform_profile ABI.

Hỗ trợ hồ sơ "Tùy chỉnh"
========================
Lớp platform_profile cũng hỗ trợ các cấu hình quảng cáo "tùy chỉnh"
hồ sơ. Điều này được thiết lập bởi các trình điều khiển khi cài đặt trong
trình điều khiển đã được sửa đổi theo cách mà cấu hình tiêu chuẩn không thể hiện được
tình trạng hiện tại.

Hỗ trợ nhiều trình điều khiển
=======================
Khi nhiều trình điều khiển trên hệ thống quảng cáo trình xử lý hồ sơ nền tảng,
lõi xử lý hồ sơ nền tảng sẽ chỉ quảng cáo các hồ sơ được
chung giữa tất cả các trình điều khiển cho giao diện ZZ0000ZZ.

Điều này nhằm đảm bảo không có sự mơ hồ về ý nghĩa của tên hồ sơ khi
tất cả các trình xử lý không hỗ trợ hồ sơ.

Các trình điều khiển riêng lẻ sẽ đăng ký một thiết bị lớp 'platform_profile' có
ngữ nghĩa tương tự như giao diện ZZ0000ZZ.

Để khám phá trình điều khiển nào được liên kết với trình xử lý hồ sơ nền tảng,
người dùng có thể đọc thuộc tính ZZ0000ZZ của thiết bị lớp.

Để khám phá các cấu hình có sẵn từ giao diện lớp, người dùng có thể đọc
Thuộc tính ZZ0000ZZ.

Nếu người dùng muốn chọn cấu hình cho một trình điều khiển cụ thể, họ có thể làm như vậy
bằng cách ghi vào thuộc tính ZZ0000ZZ của thiết bị lớp của trình điều khiển.

Điều này sẽ cho phép người dùng đặt các cấu hình khác nhau cho các trình điều khiển khác nhau trên
cùng một hệ thống. Nếu cấu hình được chọn bởi từng trình điều khiển khác nhau
lõi xử lý hồ sơ nền tảng sẽ hiển thị hồ sơ 'tùy chỉnh' để biểu thị
rằng các hồ sơ không giống nhau.

Trong khi thuộc tính ZZ0000ZZ có giá trị ZZ0001ZZ, việc viết một
hồ sơ chung từ ZZ0002ZZ đến platform_profile
thuộc tính của lõi xử lý hồ sơ nền tảng sẽ đặt hồ sơ cho tất cả
trình điều khiển.
