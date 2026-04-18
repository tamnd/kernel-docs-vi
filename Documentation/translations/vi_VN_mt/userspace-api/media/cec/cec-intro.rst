.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/cec/cec-intro.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _cec-intro:

Giới thiệu
============

Đầu nối HDMI cung cấp một chân duy nhất để Điện tử Tiêu dùng sử dụng
Giao thức điều khiển. Giao thức này cho phép các thiết bị khác nhau được kết nối bằng một
Cáp HDMI để giao tiếp. Giao thức cho CEC phiên bản 1.4 được xác định
trong phần bổ sung 1 (CEC) và 2 (HEAC hoặc HDMI Ethernet và trả lại âm thanh
Channel) của thông số kỹ thuật HDMI 1.4a (ZZ0000ZZ) và
các tiện ích mở rộng được thêm vào CEC phiên bản 2.0 được xác định trong chương 11 của
Thông số kỹ thuật HDMI 2.0 (ZZ0001ZZ).

Tốc độ bit rất chậm (thực tế không quá 36 byte mỗi giây)
và dựa trên giao thức AV.link cổ được sử dụng trong SCART cũ
đầu nối. Giao thức gần giống với Rube Goldberg điên rồ
thiết bị kỳ lạ và là sự kết hợp xấu xa giữa các thông điệp cấp thấp và cấp cao. Một số
các tin nhắn, đặc biệt là những phần của giao thức HEAC được xếp chồng lên trên
CEC, cần được xử lý bởi kernel, các phần khác có thể được xử lý bởi
kernel hoặc theo không gian người dùng.

Ngoài ra, CEC có thể được triển khai trong các máy thu, máy phát và máy phát HDMI.
trong các thiết bị USB có đầu vào HDMI và đầu ra HDMI và
chỉ điều khiển chân CEC.

Trình điều khiển hỗ trợ CEC sẽ tạo nút thiết bị CEC (/dev/cecX) để
cấp quyền truy cập không gian người dùng vào bộ điều hợp CEC. các
ZZ0000ZZ ioctl sẽ cho người dùng biết những gì nó được phép làm.

Để kiểm tra sự hỗ trợ và kiểm tra nó, bạn nên tải xuống
gói ZZ0000ZZ. Nó
cung cấp ba công cụ để xử lý CEC:

- cec-ctl: con dao quân đội Thụy Sĩ của CEC. Cho phép bạn cấu hình, truyền tải
  và theo dõi tin nhắn CEC.

- tuân thủ cec: thực hiện kiểm tra tuân thủ CEC của thiết bị CEC từ xa để
  xác định mức độ tuân thủ của việc triển khai CEC.

- cec-follower: mô phỏng người theo dõi CEC.