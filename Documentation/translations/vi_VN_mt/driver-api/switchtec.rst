.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/switchtec.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Hỗ trợ Switchtec Linux
===========================

Dòng thiết bị chuyển mạch PCI "Switchtec" của Microsemi đã có sẵn
được hỗ trợ bởi kernel với trình điều khiển chuyển đổi PCI tiêu chuẩn. Tuy nhiên,
Thiết bị Switchtec quảng cáo một điểm cuối quản lý đặc biệt
cho phép một số chức năng bổ sung. Điều này bao gồm:

* Bộ đếm gói và byte
* Nâng cấp chương trình cơ sở
* Nhật ký sự kiện và lỗi
* Truy vấn trạng thái liên kết cổng
* Lệnh phần mềm người dùng tùy chỉnh

Mô-đun hạt nhân switchtec thực hiện chức năng này.


Giao diện
=========

Phương tiện giao tiếp chính với phần mềm quản lý Switchtec là
thông qua giao diện Cuộc gọi thủ tục từ xa được ánh xạ bộ nhớ (MRPC).
Các lệnh được gửi tới giao diện bằng lệnh 4 byte
mã định danh và tối đa 1KB dữ liệu lệnh cụ thể. Phần sụn sẽ
phản hồi bằng mã trả về 4 byte và tối đa 1KB dành riêng cho lệnh
dữ liệu. Giao diện chỉ xử lý một lệnh duy nhất tại một thời điểm.


Giao diện không gian người dùng
===============================

Giao diện MRPC sẽ được hiển thị với không gian người dùng thông qua một char đơn giản.
thiết bị: /dev/switchtec#, một thiết bị cho mỗi điểm cuối quản lý trong hệ thống.

Thiết bị char có ngữ nghĩa sau:

* Một bản ghi phải bao gồm ít nhất 4 byte và không quá 1028 byte.
  4 byte đầu tiên sẽ được hiểu là ID lệnh và
  phần còn lại sẽ được sử dụng làm dữ liệu đầu vào. Một lần viết sẽ gửi
  lệnh tới phần sụn để bắt đầu xử lý.

* Sau mỗi lần viết phải có đúng một lần đọc. Bất kỳ việc viết đôi nào cũng sẽ
  tạo ra lỗi và bất kỳ thao tác đọc nào không theo sau thao tác ghi sẽ
  tạo ra một lỗi.

* Quá trình đọc sẽ bị chặn cho đến khi phần sụn hoàn thành lệnh và quay trở lại
  Giá trị trả về lệnh 4 byte cộng với đầu ra lên tới 1024 byte
  dữ liệu. (Độ dài sẽ được chỉ định bởi tham số kích thước của phần đọc
  gọi -- đọc ít hơn 4 byte sẽ gây ra lỗi.)

* Cuộc gọi thăm dò ý kiến cũng sẽ được hỗ trợ cho các ứng dụng không gian người dùng
  cần làm những việc khác trong khi chờ lệnh hoàn thành.

Các IOCTL sau đây cũng được thiết bị hỗ trợ:

* SWITCHTEC_IOCTL_FLASH_INFO - Truy xuất số lượng và chiều dài chương trình cơ sở
  của các phân vùng trong thiết bị.

* SWITCHTEC_IOCTL_FLASH_PART_INFO - Truy xuất địa chỉ và độ dài cho
  bất kỳ phân vùng được chỉ định nào trong flash.

* SWITCHTEC_IOCTL_EVENT_SUMMARY - Đọc cấu trúc bitmap
  chỉ ra tất cả các sự kiện không rõ ràng.

* SWITCHTEC_IOCTL_EVENT_CTL - Lấy số đếm hiện tại, xóa và đặt cờ
  cho bất kỳ sự kiện nào. Ioctl này có cấu trúc switchtec_ioctl_event_ctl
  với sự kiện_id, chỉ mục và cờ được đặt (chỉ mục là phân vùng hoặc PFF
  số cho các sự kiện không mang tính toàn cầu). Nó trả về liệu sự kiện có
  đã xảy ra, số lần và bất kỳ dữ liệu cụ thể nào về sự kiện. Những lá cờ
  có thể được sử dụng để xóa số lượng hoặc bật và tắt các hành động đối với
  xảy ra khi sự kiện xảy ra.
  Bằng cách sử dụng cờ SWITCHTEC_IOCTL_EVENT_FLAG_EN_POLL,
  bạn có thể đặt một sự kiện để kích hoạt lệnh thăm dò ý kiến ​​để quay lại với
  POLLPRI. Bằng cách này, không gian người dùng có thể chờ các sự kiện xảy ra.

* Chuyển đổi SWITCHTEC_IOCTL_PFF_TO_PORT và SWITCHTEC_IOCTL_PORT_TO_PFF
  giữa số Khung chức năng PCI (được sử dụng bởi hệ thống sự kiện)
  và ID cổng logic Switchtec và số phân vùng (nhiều hơn
  thân thiện với người dùng).


Trình điều khiển cầu không trong suốt (NTB)
===========================================

Trình điều khiển phần cứng NTB được cung cấp cho phần cứng Switchtec ở
ntb_hw_switchtec. Hiện tại, nó chỉ hỗ trợ các switch được cấu hình bằng
chính xác 2 phân vùng NT và không có hoặc nhiều phân vùng không phải NT. Nó cũng đòi hỏi
các cài đặt cấu hình sau:

* Cả hai phân vùng NT phải có khả năng truy cập vào không gian GAS của nhau.
  Do đó, các bit trong Vector truy cập GAS trong Cài đặt quản lý
  phải được thiết lập để hỗ trợ điều này.
* Cấu hình hạt nhân MUST bao gồm hỗ trợ cho NTB (CONFIG_NTB cần
  được thiết lập)

NT EP BAR 2 sẽ được cấu hình động làm Cửa sổ trực tiếp và
tập tin cấu hình không cần phải cấu hình nó một cách rõ ràng.

Vui lòng tham khảo Tài liệu/driver-api/ntb.rst trong cây nguồn Linux để biết thông tin tổng thể
hiểu biết về ngăn xếp Linux NTB. ntb_hw_switchtec hoạt động như NTB
Trình điều khiển phần cứng trong ngăn xếp này.
