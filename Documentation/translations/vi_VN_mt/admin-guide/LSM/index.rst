.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/LSM/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Cách sử dụng mô-đun bảo mật Linux
===========================

Khung Mô-đun bảo mật Linux (LSM) cung cấp cơ chế cho
các kiểm tra bảo mật khác nhau sẽ được thực hiện bởi các phần mở rộng kernel mới. Tên
"mô-đun" hơi bị dùng sai vì những phần mở rộng này thực tế không phải là
các mô-đun hạt nhân có thể tải được. Thay vào đó, chúng có thể được lựa chọn tại thời điểm xây dựng thông qua
CONFIG_DEFAULT_SECURITY và có thể bị ghi đè khi khởi động thông qua
Đối số dòng lệnh kernel ZZ0000ZZ, trong trường hợp có nhiều
LSM được tích hợp vào một kernel nhất định.

Người dùng chính của giao diện LSM là Kiểm soát truy cập bắt buộc
(MAC) tiện ích mở rộng cung cấp chính sách bảo mật toàn diện. Ví dụ
bao gồm SELinux, Smack, Tomoyo và AppArmor. Ngoài cái lớn hơn
Các tiện ích mở rộng MAC, các tiện ích mở rộng khác có thể được xây dựng bằng LSM để cung cấp
những thay đổi cụ thể đối với hoạt động của hệ thống khi những chỉnh sửa này không có sẵn
trong chức năng cốt lõi của chính Linux.

Các mô-đun khả năng của Linux sẽ luôn được bao gồm. Đây có thể là
theo sau là bất kỳ số lượng mô-đun "nhỏ" nào và nhiều nhất là một mô-đun "chính".
Để biết thêm chi tiết về các khả năng, hãy xem ZZ0000ZZ trong Linux
dự án man-page.

Có thể tìm thấy danh sách các mô-đun bảo mật đang hoạt động bằng cách đọc
ZZ0000ZZ. Đây là danh sách được phân tách bằng dấu phẩy và
sẽ luôn bao gồm mô-đun khả năng. Danh sách phản ánh
thứ tự thực hiện kiểm tra. Mô-đun khả năng sẽ luôn
đầu tiên, tiếp theo là bất kỳ mô-đun "nhỏ" nào (ví dụ: Yama) và sau đó
một mô-đun "chính" (ví dụ: SELinux) nếu có một mô-đun được định cấu hình.

Các thuộc tính quy trình được liên kết với các mô-đun bảo mật "chính" phải
được truy cập và duy trì bằng các tệp đặc biệt trong ZZ0000ZZ.
Một mô-đun bảo mật có thể duy trì một thư mục con cụ thể của mô-đun ở đó,
được đặt tên theo mô-đun. ZZ0001ZZ được cung cấp bởi Smack
mô-đun bảo mật và chứa tất cả các tệp đặc biệt của nó. Các tập tin trực tiếp
trong ZZ0002ZZ vẫn là giao diện cũ cho các mô-đun cung cấp
các thư mục con.

.. toctree::
   :maxdepth: 1

   apparmor
   LoadPin
   SELinux
   Smack
   tomoyo
   Yama
   SafeSetID
   ipe
   landlock
